#!/bin/sh
# executed by git: files to compare are $1 and $2
# filetypes are preserved so this is just one script to prevent clutter
# TODO: find the solidworks install location, might not always be this
# TODO: some sort of macro thing for parts
#echo "Waiting for SolidWorks to exit..."
#/c/Program\ Files/SOLIDWORKS\ Corp/SOLIDWORKS/SLDWORKS.exe /m sldworks-git-tools/compareprt.swp $1 $2

# Do nothing particularly useful until the macro is ready
diff $1 $2
