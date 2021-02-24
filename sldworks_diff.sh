#!/bin/sh
# executed by git: I can't find actual documentation but I think
# it is executed with the following args:
# |  $1  |      $2      |  $3  |  $4  |      $5      |  $6  |  $7  |
# | name | tmp_location | hash | mode | tmp_location | hash | mode |
# |------|----------------------------|----------------------------|
# |      |          left diff         |         right diff         |

# exit if the parts are identical
if [ "$3" = "$6" ]; then
	if ! [ "$4" = "$7" ]; then
		echo "$1 differs in mode"
		exit 1
	else
		exit 0
	fi
fi

if ! [ -f /c/Program\ Files/SOLIDWORKS\ Corp/SOLIDWORKS/SLDWORKS.exe ]; then
	echo "It does not appear that SolidWorks is installed"
	echo "Files $left_filename and $right_filename differ"
	exit 1
fi

# move the files somewhere more understandable
left_filename="$(echo "$1" | sed 's/\(.*\)\.\([^.]*\)/\1_LEFT\.\2/')"
right_filename="$(echo "$1" | sed 's/\(.*\)\.\([^.]*\)/\1_RIGHT\.\2/')"
cp $2 $left_filename
cp $5 $right_filename

echo "Opening SolidWorks to diff $left_filename and $right_filename..."
echo "SolidWorks must exit fully before this diff can exit"

/c/Program\ Files/SOLIDWORKS\ Corp/SOLIDWORKS/SLDWORKS.exe \
	//m sldworks-git-tools/compare.swb \
	/*$(realpath $left_filename | xargs cygpath -w) \
	/*$(realpath $right_filename | xargs cygpath -w)

rm $left_filename $right_filename
