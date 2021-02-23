#!/bin/sh
# Yes yes yes some of this code is duplicated. Shell is hard, okay?

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
