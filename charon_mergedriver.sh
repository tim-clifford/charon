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

# executed by git: with arguments $1: BASE, $2: LOCAL, $3: REMOTE $4: filename

# check filetype
case $@ in
	*sldprt) ;&
	*SLDPRT) ;&
	*sldasm) ;&
	*SLDASM)
		driver="$(dirname $(realpath $0))/solidworks_driver.sh"
		prog_name="SolidWorks"
		;;
	*)
		echo "Unsupported filetype for Charon"
		;;
esac


# make the filenames human-readable.
local_filename="$(echo  "$4" | sed 's/\(.*\)\.\([^.]*\)/\1_LOCAL\.\2/')"
remote_filename="$(echo "$4" | sed 's/\(.*\)\.\([^.]*\)/\1_REMOTE\.\2/')"
cp $2 $local_filename
cp $3 $remote_filename

# Delete all the files with message if a keyboard interrupt occurs
trap "
	echo ' Aborting merge...'
	rm -f $1 $2 $3 $local_filename $remote_filename
	exit 127
" INT

while true; do
	echo "$4 conflicts. Choose one of the following options:"
	echo "  local:  take the local  file (what you are merging into)"
	echo "  remote: take the remote file (what you are merging)"
	echo "  edit:   open the files in $prog_name to edit manually"
	echo "  abort:  abort the merge resolution"
	read -p "Enter your choice: " choice
	case "$choice" in
		"local" )
			mv $local_filename $2
			rm $remote_filename
			exit 0;;
		"remote" )
			mv $remote_filename $2
			rm $local_filename
			exit 0;;
		"edit" )
			# The driver will check health etc
			echo "Opening $prog_name to merge $4..."
			echo "$prog_name must exit fully before this merge can continue"
			echo "You can then choose a file to take, or abort"
			$driver "$local_filename" "$remote_filename"
			;;
		"abort" )
			rm $local_filename
			rm $remote_filename
			exit 1;;
		*)
			echo "Please choose one of the specified options";;
	esac
done
