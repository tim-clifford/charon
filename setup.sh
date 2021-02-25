#!/bin/sh

# SolidWorks Git Tools
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

# Yes yes yes some of this code is duplicated. Shell is hard, okay?

# Set cat as the default pager so that we can more easily read/write text
git config core.pager cat

# Remove existing sld config if it exists and replace it with the latest config
header_start="\
### --------------- BEGIN AUTO ADDED SOLIDWORKS TOOLS --------------------- ###\
"
header_end="\
### ---------------- END AUTO ADDED SOLIDWORKS TOOLS ---------------------- ###\
"
if cat .git/config | grep -q "$header_start"; then
	echo "Found existing solidworks config, replacing..."
	# This is cursed, can't indent properly without introducing an indent into
	# the config file. If you're thinking of a way to, I've probably tried it.
	# At least it's not vba...

	gitconfig="\
$(cat .git/config|grep -B9999 "$header_start"|grep -v "$header_start")
$(cat .git/config|grep -A9999 "$header_end"  |grep -v "$header_end")
$header_start
$(cat sldworks-git-tools/gitconfig)
$header_end"

	# Can't oneline this because of order of operations
	echo "$gitconfig" > .git/config

else
	# Thanks, I hate it
	echo "\
$header_start
$(cat sldworks-git-tools/gitconfig)
$header_end" >> .git/config

fi

if ! [ -f .gitattributes ]; then
	# Thanks, I hate it
	echo "\
$header_start
$(cat sldworks-git-tools/gitattributes)
$header_end" >> .gitattributes

elif cat .gitattributes | grep -q "$header_start"; then
	echo "Found existing solidworks attibutes, replacing..."
	# This is cursed, can't indent properly without introducing an indent into
	# the config file. If you're thinking of a way to, I've probably tried it.
	# At least it's not vba...

	gitattributes="\
$(cat .gitattributes|grep -B9999 "$header_start"|grep -v "$header_start")
$(cat .gitattributes|grep -A9999 "$header_end"  |grep -v "$header_end")
$header_start
$(cat sldworks-git-tools/gitattributes)
$header_end"

	# Can't oneline this because of order of operations
	echo "$gitattributes" > .gitattributes

else
	# Thanks, I hate it
	echo "\
$header_start
$(cat sldworks-git-tools/gitattributes)
$header_end" >> .gitattributes

fi
