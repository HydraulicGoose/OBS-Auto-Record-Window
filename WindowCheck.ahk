#Requires AutoHotkey v2
#SingleInstance Force
#NoTrayIcon

; Allows admin program interaction
if (!A_IsCompiled && !InStr(A_AhkPath, "_UIA")) {
    Run "*uiAccess " A_ScriptFullPath
    ExitApp
}


; ---------- Functions
GetActiveWindow() {  ; Gets active window and exports it to temp file
    global lastActiveExe

    tempFile := A_Temp "\auto_record_window_script.txt"  ; Temp file path
	activeExe := WinExist("A") ? WinGetProcessName("A") : ""  ; Get exe of active window
	
	; If current exe is the same as last exe, skip function (saves some resources)
	if activeExe == lastActiveExe {
	    return
	}
	
	; Clears old temp file
	if FileExist(tempFile) {
        FileDelete tempFile
    }

    ; If no window focused, add "no_window_focused" to temp file
    if (!activeExe) {
	    FileAppend "no_window_focused", tempFile
        return  ; no active window
	}
	
    FileAppend activeExe, tempFile  ; If window is focused, add window exe to temp file
	lastActiveExe := activeExe  ; Logs last exe

}

KillOnOBSClose() {

    if !ProcessExist("obs64.exe") {
        ExitApp
    }
	
}


; ---------- Code
if A_LineFile = A_ScriptFullPath {

    ; Stores last active window exe
	lastActiveExe := ""
	
	SetTimer(() => GetActiveWindow(), 100)  ; Checks active window every 100ms
	SetTimer(() => KillOnOBSClose(), 15000)  ; Checks if obs exists every 15 seconds, and kills script if obs is no longer running
	
}
