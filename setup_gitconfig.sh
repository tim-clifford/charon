#!/bin/dash
# Remove existing sld config if it exists and replace it with the latest config
header_start="\
### --------------- BEGIN AUTO ADDED SOLIDWORKS TOOLS --------------------- ###\
"
header_end="\
### ---------------- END AUTO ADDED SOLIDWORKS TOOLS ---------------------- ###\
"
if cat .git/config | grep -q "$header_start"; then
	echo "found header"
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
	echo "no header found"

	# Thanks, I hate it
	echo "\
$header_start
$(cat sldworks-git-tools/gitconfig)
$header_end" >> .git/config

fi
