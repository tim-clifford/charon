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

# executed by git with the following args:
# |  $1  |      $2      |  $3  |  $4  |      $5      |  $6  |  $7  |
# | name | tmp_location | hash | mode | tmp_location | hash | mode |
# |------|----------------------------|----------------------------|
# |      |          left diff         |         right diff         |

# check filetype
case $1 in
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

# exit if the parts are identical
if [ "$3" = "$6" ]; then
	if ! [ "$4" = "$7" ]; then
		echo "$1 differs in mode"
		exit 1
	else
		exit 0
	fi
fi

# move the files somewhere more understandable
left_filename="$(echo "$1" | sed 's/\(.*\)\.\([^.]*\)/\1_LEFT\.\2/')"
right_filename="$(echo "$1" | sed 's/\(.*\)\.\([^.]*\)/\1_RIGHT\.\2/')"
cp $2 $left_filename
cp $5 $right_filename

# Delete the files with message if a keyboard interrupt occurs
trap "
	echo ' Aborting diff...'
	rm $left_filename $right_filename
	exit 127
" INT

if ! $driver --check-health; then
	echo "File $1 differs"
else
	echo "Opening $prog_name to diff $1..."
	echo "$prog_name must exit fully before this diff can exit"
	$driver $left_filename $right_filename
fi

rm $left_filename $right_filename
