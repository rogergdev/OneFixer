Option Explicit

Dim objShell, objWMIService, regPath, subKeys, subKeyName, keyCount, keyDict, backupContent, backupFile, oneDrivePath, actionTaken

Set objShell = CreateObject("Shell.Application")
Set objWMIService = GetObject("winmgmts:\\.\root\default:StdRegProv")
Set keyDict = CreateObject("Scripting.Dictionary")

regPath = "Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace"
actionTaken = False 

oneDrivePath = GetOneDrivePath()

If oneDrivePath <> "" And IsOneDriveRunning() Then
    Call CloseOneDrive()
End If

If Not IsAdmin() Then
    objShell.ShellExecute "wscript.exe", """" & WScript.ScriptFullName & """", "", "runas", 1
    WScript.Quit
End If

objWMIService.EnumKey &H80000001, regPath, subKeys

If IsArray(subKeys) Then
    keyCount = 0
    backupContent = "Windows Registry Editor Version 5.00" & vbCrLf & vbCrLf

    For Each subKeyName In subKeys
        keyCount = keyCount + 1
        keyDict.Add subKeyName, regPath & "\" & subKeyName

        backupContent = backupContent & "[" & "HKEY_CURRENT_USER\" & regPath & "\" & subKeyName & "]" & vbCrLf & vbCrLf
    Next

    If keyCount > 0 Then
        actionTaken = True
        backupFile = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName) & "\backup.reg"
        
        Dim objFileSystem
        Set objFileSystem = CreateObject("Scripting.FileSystemObject")
        If objFileSystem.FileExists(backupFile) Then
            objFileSystem.DeleteFile(backupFile)
            WScript.Echo "Se ha eliminado el backup anterior."
        End If
        
        Dim backupFileHandle
        Set backupFileHandle = objFileSystem.CreateTextFile(backupFile, True)
        backupFileHandle.Write backupContent
        backupFileHandle.Close
        Set backupFileHandle = Nothing
        Set objFileSystem = Nothing
        WScript.Echo "Se ha creado un nuevo backup en: " & backupFile
    End If

    If keyCount > 0 Then
        WScript.Echo "Buscando y eliminando claves duplicadas de OneDrive en el registro..."
        For Each subKeyName In keyDict.Keys
            On Error Resume Next
            objWMIService.DeleteKey &H80000001, keyDict(subKeyName)
            If Err.Number <> 0 Then
                WScript.Echo "No se pudo eliminar la clave: " & keyDict(subKeyName)
            Else
                WScript.Echo "Clave eliminada: " & keyDict(subKeyName)
            End If
            On Error GoTo 0
        Next
        WScript.Echo "Reiniciando el Explorador de Windows, por favor espera..."
        Call RestartExplorer()
    End If
Else
    WScript.Echo "No se han encontrado claves de OneDrive duplicadas."
End If

If actionTaken Then
    WaitForExplorerRestart()
    WScript.Echo "El proceso ha finalizado correctamente. Por favor, inicia OneDrive manualmente."
Else
    WScript.Echo "El proceso ha finalizado y no se ha realizado ninguna accion."
End If

Function GetOneDrivePath()
    Dim fso, defaultPath1, defaultPath2
    Set fso = CreateObject("Scripting.FileSystemObject")
    defaultPath1 = "C:\Program Files\Microsoft OneDrive\OneDrive.exe"
    defaultPath2 = "C:\Program Files (x86)\Microsoft OneDrive\OneDrive.exe"
    
    If fso.FileExists(defaultPath1) Then
        GetOneDrivePath = defaultPath1
    ElseIf fso.FileExists(defaultPath2) Then
        GetOneDrivePath = defaultPath2
    Else
        GetOneDrivePath = ""
    End If
End Function

Function IsOneDriveRunning()
    Dim command, shellOutput
    command = "tasklist /FI ""IMAGENAME eq OneDrive.exe"" | find ""OneDrive.exe"""
    shellOutput = CreateObject("WScript.Shell").Run("cmd /c " & command, 0, True)
    If shellOutput = 0 Then
        IsOneDriveRunning = True
    Else
        IsOneDriveRunning = False
    End If
End Function

Sub CloseOneDrive()
    Dim command
    command = "taskkill /f /im OneDrive.exe"
    CreateObject("WScript.Shell").Run "cmd /c " & command, 0, True
    WScript.Echo "Se ha cerrado OneDrive."
End Sub

Sub RestartExplorer()
    Dim command, wmiService, processList, process
    command = "taskkill /f /im explorer.exe"
    CreateObject("WScript.Shell").Run "cmd /c " & command, 0, True

    WScript.Sleep 2000
    Set wmiService = GetObject("winmgmts:\\.\root\cimv2")
    Set processList = wmiService.ExecQuery("Select * from Win32_Process Where Name='explorer.exe'")
    Do While processList.Count > 0
        WScript.Sleep 1000
        Set processList = wmiService.ExecQuery("Select * from Win32_Process Where Name='explorer.exe'")
    Loop

    CreateObject("WScript.Shell").Run "explorer.exe", 0, False
End Sub

Sub WaitForExplorerRestart()
    Dim wmiService, processList
    Set wmiService = GetObject("winmgmts:\\.\root\cimv2")
    Set processList = wmiService.ExecQuery("Select * from Win32_Process Where Name='explorer.exe'")
    Do While processList.Count = 0
        WScript.Sleep 1000
        Set processList = wmiService.ExecQuery("Select * from Win32_Process Where Name='explorer.exe'")
    Loop
    WScript.Sleep 3000
End Sub

Function IsAdmin()
    Dim objNetwork, strUserDomain, strUserName
    Set objNetwork = CreateObject("WScript.Network")
    strUserDomain = objNetwork.UserDomain
    strUserName = objNetwork.UserName
    On Error Resume Next
    IsAdmin = CBool(CreateObject("WScript.Shell").Run("cmd.exe /c whoami /groups | find ""S-1-16-12288"" > nul", 0, True) = 0)
    On Error GoTo 0
End Function

Set objShell = Nothing
Set objWMIService = Nothing
Set keyDict = Nothing

' by Roger
