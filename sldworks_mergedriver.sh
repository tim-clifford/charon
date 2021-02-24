#!/bin/sh
# executed by git: with arguments $1: BASE, $2: LOCAL, $3: REMOTE $4: filename

# make the filenames human-readable.
local_filename="$(echo  "$4" | sed 's/\(.*\)\.\([^.]*\)/\1_LOCAL\.\2/')"
remote_filename="$(echo "$4" | sed 's/\(.*\)\.\([^.]*\)/\1_REMOTE\.\2/')"
cp $2 $local_filename
cp $3 $remote_filename

while true; do
	echo "$4 conflicts. Choose one of the following options:"
	echo "  local:  take the local  file (what you are merging into)"
	echo "  remote: take the remote file (what you are merging)"
	echo "  edit:   open the files in SolidWorks to edit manually"
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
			echo "Opening SolidWorks to merge $4..."
			echo "SolidWorks must exit fully before this merge can continue"
			echo "You can then choose a file to take, or abort"
			/c/Program\ Files/SOLIDWORKS\ Corp/SOLIDWORKS/SLDWORKS.exe \
				//m sldworks-git-tools/compare.swb \
				/*$(realpath $local_filename | xargs cygpath -w) \
				/*$(realpath $remote_filename | xargs cygpath -w)
			;;
		"abort" )
			rm $local_filename
			rm $remote_filename
			exit 1;;
		*)
			echo "Please choose one of the specified options";;
	esac
done
