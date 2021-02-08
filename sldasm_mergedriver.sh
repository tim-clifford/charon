#!/bin/sh
# executed by git: with arguments $1: HEAD~, $2: HEAD, $3: merge
# the filetype is lost so we have to create new temporary files
cur_filename="$2.sldasm"
mrg_filename="$3.sldasm"
cp $2 $cur_filename
cp $3 $mrg_filename

# TODO: find the solidworks install location, might not always be this
# TODO: some sort of macro thing for assemblies
# echo "Waiting for SolidWorks to exit..."
# /c/Program\ Files/SOLIDWORKS\ Corp/SOLIDWORKS/SLDWORKS.exe /m sldworks-git-tools/compareasm.swp $cur_filename $mrg_filename

# copy merge result back to file that git expects
mv $cur_filename $2
rm $mrg_filename

# Fail for now since we're not actaully doing anything
exit 1
