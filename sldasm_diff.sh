#!/bin/sh
# executed by git: files to compare are $1 and $2

# TODO: some sort of macro thing
# A macro can be invoked with e.g.
#/c/Program\ Files/SOLIDWORKS\ Corp/SOLIDWORKS/SLDWORKS.exe /m sldworks-git-tools/compareasm.swp $1 $2

# exit if the parts are identical
if diff $1 $2 >/dev/null 2>/dev/null; then
	exit 0
fi

# move the second file somewhere nicer
diff_filename="$(echo "$1" | sed 's/\(.*\)\.\([^.]*\)/\1_OTHER\.\2/')"
cp $2 $diff_filename

echo "Assemblies $1 and $diff_filename differ."
echo "You can use the compare feature in SolidWorks to see a diff."
read -p "Press enter to continue (this will delete $diff_filename)"
rm diff_filename
