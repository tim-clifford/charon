#!/bin/sh
# executed by git: with arguments $1: HEAD~, $2: HEAD, $3: merge
# make the filenames human-readable. Open a PR if you can think of a better name

# TODO: some sort of macro thing
# A macro can be invoked with e.g.
#/c/Program\ Files/SOLIDWORKS\ Corp/SOLIDWORKS/SLDWORKS.exe /m sldworks-git-tools/compareasm.swp $1 $2

cur_filename="MERGE_CURRENT.sldasm"
mrg_filename="MERGE_OTHER.sldasm"
cp $2 $cur_filename
cp $3 $mrg_filename

while true; do
	read -p "Conflicting assembly found. Do you want to merge manually? (y/n) " yn
	case "$yn" in
		"y" )
			echo "Assemblies to merge are $cur_filename and $mrg_filename."
			echo "You can use the compare feature in SolidWorks to see a diff."
			echo "When you are finished, $cur_filename will be taken."
			echo "(You will have the option to abort the merge)"
			break;;
		"n" )
			exit 1
			break;;
		*)
			echo "Please choose an option"
			break;;
	esac
done

# Check that the user still wants to merge
while true; do
	read -p "Are you happy with the contents of $cur_filename? " yn
	case "$yn" in
		"y" )
			# move merge result back to file that git expects
			mv $cur_filename $2
			rm $mrg_filename
			exit 0
			break;; # not strictly necessary since we are exiting i guess
		"n" )
			rm $cur_filename
			rm $mrg_filename
			exit 1
			break;; # not strictly necessary since we are exiting i guess
		*)
			echo "Please choose an option"
			break;;
	esac
done


