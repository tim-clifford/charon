# SolidWorks Git Tools
Provides integration with git for SolidWorks parts and assemblies. Add this
repo as a submodule and then run `./sldworks-git-tools/setup.sh` from git bash.

You will also need to enable *SOLIDWORKS Utilities* at startup, you can do this
by navigating (in SolidWorks) to *Tools->Add-Ins* and checking the startup box
next to *SOLIDWORKS Utilities*

`git diff` is fully functional, `git merge` currently requires some unnecessary
user intervention, but it's in the roadmap to make that fully functional too.

There are a lot of possible edge cases so this is still a little rough around
the edges. Please open an issue if anything isn't working quite as expected, or
if there are ways that you think your workflow could be improved.
