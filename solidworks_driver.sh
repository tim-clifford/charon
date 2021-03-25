#!/bin/sh

# Charon
# Copyright (C) 2021 Tim Clifford, Henry Franks
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# executed with args $1 $2 as location of files

# attempt to determine the OS and type of file path


usage() {
	cat << EOF
Usage: $0 [OPTION]... FILE1 FILE2
Opens a comparison between the two files in SolidWorks.

  -h, --help            display this help and exit
  -c, --check-health    check if a virtual machine is accessible

If you are using a VM, this will make some assumptions
(which are the defaults of solidworks-vm)

1. if you are using qemu and require the vm to access the host, there is a
   network drive at //10.0.2.4/qemu which mounts $HOME
2. If you require ssh access to the guest, MSYS2 is accessible at
   archuser@localhost:6969
3. The password of the guest is 'a'. (This should not be a security issue, as
   no ports on the guest should be exposed)

EOF
}

check_vm() {
	# check vm is running
	if ! pgrep qemu >/dev/null 2>&1; then
		echo "No virtual machine running"
		exit 1
	fi

	# check we have sshpass
	if ! sshpass -h >/dev/null 2>&1; then
		echo "sshpass is required for scripting ssh, please install it"
		exit 1
	fi

	# check vm is accessible over ssh
	if ! sshpass -p 'a' ssh -p 6969 archuser@localhost 'exit 0'; then
		echo "Cannot access VM over ssh"
		exit 1
	fi

	# check vm has mounted host
	if ! sshpass -p 'a' ssh -p 6969 archuser@localhost \
			'ls //10.0.2.4/qemu >/dev/null'
	then
		echo "VM does not appear to have mounted the host on //10.0.2.4/qemu"
		exit 1
	fi

	# check vm has mounted host at $HOME
	# checks if it can find this script under //10.0.2.4/qemu in the right

	fpath="$(realpath $0)"
	if ! echo "$fpath" | egrep -q "^$HOME"; then
		echo -n "Please put this script somewhere under $HOME "
		echo    "when using it on Linux"
		exit 1
	fi
	if ! sshpass -p 'a' ssh -p 6969 archuser@localhost \
		ls "$(echo $fpath | sed "s|$HOME|//10.0.2.4/qemu|")" >/dev/null
	then
		echo "VM does not appear to have mounted the host at $HOME"
		exit 1
	fi
}


left_filename=""
right_filename=""
for i in "$@"; do
	case "$i" in
		-*) case "$i" in
				-h | --help)
					usage
					exit 0
					;;
				-c | --check-health)
					check_vm
					exit 0
					;;
			esac
			;;
		*)
			# assume the first two arguments not starting with '-' are the
			# files
			if [ "$left_filename" = "" ]; then
				left_filename="$i"
			elif [ "$right_filename" = "" ]; then
				right_filename="$i"
			else
				# too many non-option arguments
				usage; exit 1
			fi
			;;
	esac
done

# check we have both files
if [ "$left_filename" = "" ] || [ "$right_filename" = "" ]; then
	# not enough arguments
	usage
	exit 1
fi

# attempt to figure out how to do this

ssh_required=false
case "$(uname)" in
	Linux)
		# assume the files are on the linux drive and ssh is required
		ssh_required=true
		check_vm

		# make sure the files are accessible
		if ! echo "$(realpath $left_filename)" | egrep -q "^$HOME"; then
			echo "$left_filename does not appear to be accessible to QEMU"
			echo "it must be under $HOME"
			exit 1
		fi
		if ! echo "$(realpath $right_filename)" | egrep -q "^$HOME"; then
			echo "$right_filename does not appear to be accessible to QEMU"
			echo "it must be under $HOME"
			exit 1
		fi

		# set ssh filepaths
		left_filename="$(echo "$(realpath "$left_filename")" \
				| sed "s|^$HOME|//10.0.2.4/qemu|;s|/|\\\\|g")"
		right_filename="$(echo "$(realpath "$right_filename")" \
				| sed "s|^$HOME|//10.0.2.4/qemu|;s|/|\\\\|g")"
		macro_filename="$(echo "$(realpath "charon/compare.swb")" \
				| sed "s|^$HOME|//10.0.2.4/qemu|;s|/|\\\\|g")"
		;;

	Darwin)
		echo -n "macOS is not supported. Go install an operating system which"
		echo    "values your right to have control of an object that you own."
		;;
	*)
		# assume the files are already a path accessible to windows
		left_filename="$( realpath $left_filename  | xargs cygpath -w)"
		right_filename="$(realpath $right_filename | xargs cygpath -w)"
		macro_filename="charon/compare.swb"
		;;
esac

if $ssh_required; then
	# note that MSYS2 replaces - with /
	# (and / with /c/msys2/ or wherever it's installed)
	sshpass -p 'a' ssh -p 6969 archuser@localhost "\
		schtasks -create -f -tn CharonSolidWorks -tr \
			'C:\\Program Files\\SOLIDWORKS Corp\\SOLIDWORKS\\SLDWORKS.exe \
				/m $macro_filename /*$left_filename /*$right_filename' \
			-sc ONCE -st 00:00
		schtasks -run -tn CharonSolidWorks"
	read -p "Press Enter to kill SolidWorks and continue"
	sshpass -p 'a' ssh -p 6969 archuser@localhost "\
		schtasks -end -tn CharonSolidWorks"
else
	/c/Program\ Files/SOLIDWORKS\ Corp/SOLIDWORKS/SLDWORKS.exe \
		//m sldworks-git-tools/compare.swb \
		/*$left_filename \
		/*$right_filename
fi
