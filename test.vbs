Set Args = Wscript.Arguments

' If file paths aren't correctly specified, warn the user and exit
If Args.Count <> 2 Then
    WScript.Echo "Incorrect number of arguments"
    Wscript.Quit
End If

Set swApp = CreateObject("SldWorks.Application")

swApp.Visible = True

path1 = Args(0)
path2 = Args(1)

set fso = CreateObject("Scripting.FileSystemObject")

ext1 = UCase(fso.GetExtensionName(path1))
ext2 = UCase(fso.GetExtensionName(path2))

If ext1 <> ext2 Then
    Wscript.Echo "File types don't match"
    WScript.Quit
End If

Dim FileType_Int ' swDocumentTypes_e type as System.Integer

Select Case ext1
    Case "SLDPRT"
        FileType_Int = 1 ' swDocPART

    Case "SLDASM"
        FileType_Int = 2 ' swDocASSEMBLY

    Case Else
        FileType_Int = 0 ' swDocNONE
End Select

OpenDocOptions = 1 ' swOpenDocOptions_Silent as System.Integer

FileError = CLng(0)
Dim FileWarning

Wscript.Echo TypeName(FileError)

swApp.OpenDoc6 CStr(path1), _
    FileType_Int, OpenDocOptions, CStr(""), _
    FileError ', FileWarning

'swApp.CreateNewWindow
'swApp.CreateNewWindow
'swApp.ArrangeWindows 2
'swapp.ExitApp()

