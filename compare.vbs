' **************************************************
' * SOLIDWORKS MACRO OF ETERNAL PAIN               *
' * "I'M CRYING BLOOD" - H. FRANKS, SATISFIED USER *
' **************************************************
' vi: ft=basic
' 
' =============================================================================
'
' Copyright (C) 2021 Tim Clifford, Henry Franks
'
' This program is free software: you can redistribute it and/or modify
' it under the terms of the GNU Affero General Public License as
' published by the Free Software Foundation, either version 3 of the
' License, or (at your option) any later version.
'
' This program is distributed in the hope that it will be useful,
' but WITHOUT ANY WARRANTY; without even the implied warranty of
' MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
' GNU Affero General Public License for more details.
'
' You should have received a copy of the GNU Affero General Public License
' along with this program.  If not, see <https://www.gnu.org/licenses/>.
'
' =============================================================================

utilDLL = "C:\Program Files\SOLIDWORKS Corp\SOLIDWORKS\sldutils\SwLoaderSw.dll"

' Get Solidworks and the Utilites add-on (make sure that's installed)
Set swApp = CreateObject("SldWorks.Application")

swApp.LoadAddIn(utilDLL)
Set swUtil = swApp.GetAddInObject("Utilities.UtilitiesApp")

If swUtil is Nothing Then
    MsgBox "HELP"
    Wscript.Quit
End If

' This gets the solidworks compare interface, don't ask me how
Dim longStatus
Set longStatus = 0

' MsgBox VarType(swUtil.GetToolInterface(2, longStatus))
swUtilCompGeom = swUtil.GetToolInterface(CInt(2), longStatus)

' Check for errors raised getting the compare tool
' If so, CheckErr creates a popup box, then we exit
If CheckErr(longStatus) Then : Wscript.Quit : End If

' We split our args based on a somewhat arbitrary delimiter,
'  but notably one that cannot appear in any file paths
Set Args = Wscript.Arguments

' If file paths aren't correctly specified, warn the user and exit
If Args.Count <> 2 Then
    MsgBox "Incorrect number of arguments"
    Wscript.Quit
End If

' Run the actual geometry compare
' We can't put the comments on each line because of how VBA parses line
'  breaks, so we call the function basically as follows:
'
' Function CompareGeometry3(
'     ref file (+ empty config)
'     mod file (+ empty config)
'     gtGdfVolumeCompare [gtGdfOperationOption_e]
'     gtResultShowUI [gtResultOptions_e]
'     empty report path
'     don't add to binder
'     don't overwrite
'     status variables
' )
Set longStatus = swUtilCompGeom.CompareGeometry3( _
    Args.Item(0), "", Args.Item(1), "", _
    1, 1, "", False, False, _
    volStatus, faceStatus _
)

' Create a popup box if this throws an error
CheckErr longStatus

' This will probably only happen in the case longStatus = -1 (unknown)
' But we'll check regardless of the longStatus code
If volStatus <> 0 And volStatus <> 1 Then
    MsgBox "Volume comparison error: " _
        + Str(volStatus) + " - " + diffStatusToString(volStatus)
End If

' Close the geometry compare tool
' You may think that leaving the tool open will give us a nice visual
'  diff like the when it's used manually. This is not the case.
' Closing the compare tool stops the program from hanging.
If longStatus = 0 Then
    ' If we haven't had an error so far, try closing
    '  the tool and return an error if it raises one
    CheckErr swUtilCompGeom.Close()
Else
    ' If we've already thrown an error, this will probably throw
    ' error 7007 (gtErrCompareGeometryNotExecuted), in which case
    ' there's no point in us bothering the user further
    swUtilCompGeom.Close
End If


Function CheckErr(status)
	' Generic catch-all error message that will eventually
	'  make its way to my inbox, whether I like it or not

	' Check if we have a nonzero error code
	' Also exclude status code 15 (gtErrIncorrectReportPath)
	' We also return whether or not this triggers a reasonable error as a bool
	If status <> 0 And status <> 15 Then
		MsgBox "Comparison failed with exit code " + Str(status) _
			+ ". Please open an issue at " _
			+ "https://github.com/smh-my-head/charon"
		CheckErr = True ' Assign return value
	End If

	' Default return value is False (so don't bother setting CheckErr = False)
End Function


Function diffStatusToString(status)
	' Get a string for our gtVolDiffStatusOptionType_e error code
	' Diff status codes are fairly limited in number so we can easily
	'  create a switch like this. Creating a similar function for
	'  gtError_e would be a fool's errand.

    Select Case status
        Case 0
            diffStatusToString = "Succeeded"
        Case 1
            diffStatusToString = "Not performed"
        Case 2
            diffStatusToString = "Canceled"
        Case 3
            diffStatusToString = "Failed"
        Case 4
            diffStatusToString = "Identical parts"
        Case 5
            diffStatusToString = "Different parts"
        Case 6
            diffStatusToString = "No solid body found"
        Case 7
            diffStatusToString = "Already saved"
		Case Else
			diffStatusToString = "Undefined"
    End Select

End Function

