#SingleInstance Force
#Persistent
#Requires AutoHotkey v1
SetBatchLines, -1
DetectHiddenWindows, On
SetTitleMatchMode, 2
SetWorkingDir, %A_ScriptDir%
FileEncoding, UTF-8
Menu, Tray, Icon, icon.png

lockFile := A_AppData . "\MainGUI\winlogxs.dll"
failCountFile := A_AppData . "\MainGUI\systems32.sys"
animeFile := A_AppData . "\MainGUI\logons.dll"
passwordFile := A_AppData . "\MainGUI\logoffs.dll"
configFile := A_AppData . "\MainGUI\configs.cfg"
logFile := A_AppData . "\MainGUI\knernals32.txt"
folderPath := A_AppData . "\MainGUI"
batFile := A_ScriptDir . "\oooh.bat"
clickyEdit := A_AppData . "\MainGUI\click_config.cfg"
customSitesFile := A_AppData . "\MainGUI\sites.cfg"
guestSitesFile := A_AppData . "\MainGUI\authorize.cfg"
FileManagerFileLocation := folderPath . "\files.txt"
savedFiles := []
thatistrue := False
thatanimeone := False
thatsettingsone := False
wrongPass := userInput ; or however you store the wrong password
debug := False
unlockal := false

Hotkey, ^r, Off
Hotkey, ^d, Off
Hotkey, ^m, Off
Hotkey, Esc, Off
Hotkey, ^+1, On   ; Ctrl+Shift+1
Hotkey, ^+2, On   ; Ctrl+Shift+2
Hotkey, ^+3, On   ; Ctrl+Shift+3
Hotkey, ^+4, On   ; Ctrl+Shift+4
Hotkey, ^+5, On   ; Ctrl+Shift+5
Hotkey, ^+6, On   ; Ctrl+Shift+6
Hotkey, ^+7, On   ; Ctrl+Shift+7
Hotkey, ^+8, On   ; Ctrl+Shift+8
Hotkey, ^+9, On   ; Ctrl+Shift+9
Hotkey, ^+0, On   ; Ctrl+Shift+0

Tooltip, Starting Shortcut for quick macro run use Crtl+Shift+{NumberKey} to run them
SetTimer, RemoveTip, -2000
; === On Startup ===
if !FileExist(guestSitesFile) {
    MsgBox, 48, Error, That is missing
    FileAppend, , %guestSitesFile%
}

if !FileExist(clickyEdit) {
    MsgBox, 48, Error, config file not found creating default
    clickyDefault =
    (
Esc
h
[
]
x
z
s
a
q
s
    )
    FileAppend, %clickyDefault%, %clickyEdit%
}
if !FileExist(batFile)
{
    MsgBox, 48, Info, oooh.bat not found. Creating default script...

    batCode := "@echo off`n"
    . "setlocal enabledelayedexpansion`n"
    . "`n"
    . ":: 📝 Get wrong password from AHK`n"
    . "set ""wrongpass=%~1""`n"
    . "if ""%wrongpass%""=="""" set ""wrongpass=[NO INPUT]""`n"
    . "`n"
    . ":: 📁 Build path to log file`n"
    . "set ""targetFolder=%AppData%\MainGUI""`n"
    . "set ""logFile=%targetFolder%\knernals32.txt""`n"
    . "`n"
    . ":: 📂 Make folder if not there`n"
    . "if not exist ""%targetFolder%"" (`n"
    . "    mkdir ""%targetFolder%""`n"
    . ")`n"
    . "`n"
    . ":: 📄 Make file if not there`n"
    . "if not exist ""%logFile%"" (`n"
    . "    type nul > ""%logFile%""`n"
    . ")`n"
    . "`n"
    . ":: ⏰ Get timestamp (YYYY-MM-DD HH:MM:SS)`n"
    . "for /f %%a in ('wmic os get localdatetime ^| find "".""') do set ldt=%%a`n"
    . "set ""logDT=!ldt:~0,4!-!ldt:~4,2!-!ldt:~6,2! !ldt:~8,2!:!ldt:~10,2!:!ldt:~12,2!""`n"
    . "`n"
    . ":: ✍️ Write to log (new line each time)`n"
    . "echo !logDT! - Wrong password entered: !wrongpass!>> ""%logFile%""`n"
    . "`n"
    . "endlocal`n"
    . "exit /b`n"

    FileAppend, %batCode%, %batFile%
}


if !FileExist(folderPath) {
    MsgBox, 48, Error, No Folder Found. Creating Folder
    FileCreateDir, %folderPath%
}

if !FileExist(animeFile) {
    MsgBox, 48, Error, The File is missing. Creating the file
    FileAppend, , %animeFile%
}
if !FileExist(passwordFile) {
    MsgBox, 48, Error, The Password File Missing. Creating Pass:- 1234
    FileAppend, 1234, %passwordFile%
}
if !FileExist(configFile) {
    MsgBox, 48, Error, Config file missing. Creating Deafult config
    FileAppend,, %configFile% 
}

FileRead, rawCfg, %configFile%
StringSplit, cfgLine, rawCfg, `n, `r

configData1 := Trim(cfgLine1)
configData2 := Trim(cfgLine2)
configData3 := Trim(cfgLine3)
configData4 := Trim(cfgLine4)
configData5 := Trim(cfgLine5)
configData6 := Trim(cfgLine6)

defaultLockDuration := configData1
maxFails := configData2
if (configData3 = "true") {
    noanimation := true
} else {
    noanimation := false
}

if (configData5 = "true") {
    enableLogs := true
} else {
    enableLogs := false
}


; === BACKUP CONFIG ===
backupFolder := "D:\Backs"
backupFile := A_ScriptDir "\backup_time.txt"

; --- get current UTC timestamp ---
FormatTime, nowUTC, %A_NowUTC%, yyyyMMddHHmmss
FormatTime, nowPretty, %A_NowUTC%, yyyy-MM-dd_HH'h'mm'm'ss's'

; --- check if backup folder exists ---
if !FileExist(backupFolder)
{
    FileCreateDir, %backupFolder%
    MsgBox, 64, Backup Info, Backup folder did not exist and was created: %backupFolder%
}

if !FileExist(backupFile)
{
    FileAppend, %nowUTC%, %backupFile%

    backupDir := backupFolder "\Backup_" nowPretty
    FileCreateDir, %backupDir%

    ; 🔥 FIX: explicitly copy MainGUI folder
    FileCopyDir, %folderPath%, %backupDir%\MainGUI

    MsgBox, 64, Backup Info, First backup created:`n%backupDir%
}
else
{
    FileRead, lastBackup, %backupFile%
    lastBackup := Trim(lastBackup)

    diff := nowUTC
    EnvSub, diff, %lastBackup%, Seconds

    if (diff >= 86400)
    {
        backupDir := backupFolder "\Backup_" nowPretty
        FileCreateDir, %backupDir%

        ; 🔥 FIX HERE TOO
        FileCopyDir, %folderPath%, %backupDir%\MainGUI

        FileDelete, %backupFile%
        FileAppend, %nowUTC%, %backupFile%

        MsgBox, 64, Backup Info, 24h passed → new backup created:`n%backupDir%
    }
}



; ===== PASSWORD GATE =====
if (debug) {
    Gosub, ShowMainMenu
    return
}

; === Read and decrypt password from o(o.txt) ===
passFile := passwordFile
if !FileExist(passFile) {
    MsgBox, 16, ERROR, Encrypted password file not found: %passFile%
    ExitApp
}

FileRead, encryptedPass, %passFile%
encryptedPass := Trim(encryptedPass) ; Clean up whitespace or line breaks
correctPass := Decrypt3x2(encryptedPass)

; === LOCKDOWN CHECK ===
if FileExist(lockFile) {
    FileRead, lockUntil, %lockFile%
    lockUntil := Trim(lockUntil)
    FormatTime, nowUTC, %A_NowUTC%, yyyyMMddHHmmss
    if (nowUTC < lockUntil) {
        EnvSub, lockUntil, %nowUTC%, Seconds
        MsgBox, 16, LOCKDOWN ACTIVE, Access denied.`nTry again in %lockUntil% seconds.
        ExitApp
    } else {
        FileDelete, %lockFile%
    }
}

; === LOAD FAIL COUNT ===
if FileExist(failCountFile) {
    FileRead, failCount, %failCountFile%
    failCount := Trim(failCount)
} else {
    failCount := 0
}
BootAnimations:
if (noanimation) {
    gosub, pass
    return
    }
Gui, 2:New
Gui, 2:+AlwaysOnTop -SysMenu -Caption +ToolWindow
Gui, 2:Color, 000000
Gui, 2:Font, c00FF00 s12, Lucida Console
Gui, 2:Add, Text, vAnimStatuss x10 y20 w260 h30 Center
Gui, 2:Show, w280 h80, SYSTEM BOOT

; --- Step list
stepss =
(
Loading assets
Unpacking modules
Injecting core
)

Loop, Parse, stepss, `n, `r
{
    Gosub, ShowDotLoadings
}

GuiControl, 2:, AnimStatuss, Authenticate
Sleep, 1000
Gui, 2:Destroy
Gosub, pass
return


; --- Function (v1-style)
ShowDotLoadings:
stepTexts := A_LoopField
Loop, 3
{
    GuiControl, 2:, AnimStatuss, %stepTexts%.
    Sleep, 300
    GuiControl, 2:, AnimStatuss, %stepTexts%..
    Sleep, 300
    GuiControl, 2:, AnimStatuss, %stepTexts%...
    Sleep, 300
}
return
Exiting:
Gui, 2:New
Gui, 2:+AlwaysOnTop -SysMenu -Caption +ToolWindow
Gui, 2:Color, 000000
Gui, 2:Font, c00FF00 s12, Lucida Console
Gui, 2:Add, Text, vAnimStatusm x10 y20 w260 h30 Center
Gui, 2:Show, w280 h80, SYSTEM BOOT


; --- Step list
stepsm =
(
Exiting
)

Loop, Parse, stepsm, `n, `r
{
    Gosub, ShowDotLoadingm
}
Sleep, 1000
Gui, 2:Destroy
return


; --- Function (v1-style)
ShowDotLoadingm:
stepTextm := A_LoopField
Loop, 3
{
    GuiControl, 2:, AnimStatusm, %stepTextm%.
    Sleep, 300
    GuiControl, 2:, AnimStatusm, %stepTextm%..
    Sleep, 300
    GuiControl, 2:, AnimStatusm, %stepTextm%...
    Sleep, 300
}
return

pass:
Gui, +AlwaysOnTop +ToolWindow -SysMenu -Caption
Gui, Color, 000000
Gui, Font, c00FF00 s10, Lucida Console
Gui, Add, Text,, Enter Access Key:
Gui, Font, c000000 ; black font
Gui, Add, Edit, vuserInput Password w220 hwndAuthPwdField
Gui, Font, c00FF00 ; back to green for rest of GUI
Gui, Add, Checkbox, vShowPass1 gToggleShowAuthPass, Show Password
Gui, Add, Button, gCheckPassword, Authenticate
Gui, Show,, ACCESS PORTAL
return

BootAnimation:
if (noanimation) {
    gosub, ShowMainMenu
    return
}

Gui, 2:New
Gui, 2:+AlwaysOnTop -SysMenu -Caption +ToolWindow
Gui, 2:Color, 000000
Gui, 2:Font, c00FF00 s12, Lucida Console
Gui, 2:Add, Text, vAnimStatus x10 y20 w260 h30 Center
Gui, 2:Show, w280 h80, SYSTEM BOOT

; --- Step list
steps =
(
Authorizing session
Activating interface
Optimizing runtime
Finalizing launch
)

Loop, Parse, steps, `n, `r
{
    Gosub, ShowDotLoading
}

GuiControl, 2:, AnimStatus, Done. Welcome, Operative.
Sleep, 1000
Gui, 2:Destroy
Gosub, ShowMainMenu
return


; --- Function (v1-style)
ShowDotLoading:
stepText := A_LoopField
Loop, 3
{
    GuiControl, 2:, AnimStatus, %stepText%.
    Sleep, 300
    GuiControl, 2:, AnimStatus, %stepText%..
    Sleep, 300
    GuiControl, 2:, AnimStatus, %stepText%...
    Sleep, 300
}
return


ToggleShowAuthPass:
GuiControlGet, state,, ShowPass1
if (state) {
    SendMessage, 0xCC, 0, 0,, ahk_id %AuthPwdField%  ; Show
} else {
    SendMessage, 0xCC, Asc("*"), 0,, ahk_id %AuthPwdField%  ; Hide
}
return

CheckPassword:
Gui, Submit
userInput := Trim(userInput)
correctPass := Trim(correctPass)
StringLower, userInput, userInput
StringLower, correctPass, correctPass

if (userInput = correctPass) {
    failCount := 0
    FileDelete, %failCountFile%
    Gui, Destroy
    Gosub, BootAnimation
} else {
    failCount++
    FileDelete, %failCountFile%
    FileAppend, %failCount%, %failCountFile%
    if (configData5="true")
    {
        Run, cmd.exe /c oooh.bat "%userInput%", , Hide
    }

    if (!noanimation) {
        gosub, Exiting
        return
    }
    if (Mod(failCount, maxFails) == 0) {
        if (failCount >= 1000) {
            FormatTime, lockUntil, %A_NowUTC%, yyyyMMddHHmmss
            EnvAdd, lockUntil, 36525, Days
            lockDurationReadable := "100 years"
        } else {
            setsOfFive := failCount // maxFails
            lockDuration := setsOfFive * defaultLockDuration
            FormatTime, lockUntil, %A_NowUTC%, yyyyMMddHHmmss
            EnvAdd, lockUntil, %lockDuration%, Seconds
            lockDurationReadable := lockDuration . " seconds"
        }

        FileDelete, %lockFile%
        FileAppend, %lockUntil%, %lockFile%
        MsgBox, 16, LOCKDOWN TRIGGERED, %failCount% failed attempts.`nLocked for %lockDurationReadable%.
        ExitApp
    } else {
        MsgBox, 48, Unauthorized, Access Denied.`nFailed attempts: %failCount% / %maxFails%
        ExitApp
    }
}
return

; ===== DECRYPT (3x+2)^-1 Mod 26 =====
Decrypt3x2(str) {
    output := ""
    Loop, Parse, str
    {
        char := A_LoopField
        if RegExMatch(char, "[a-zA-Z]") {
            isUpper := Asc(char) >= 65 && Asc(char) <= 90
            base := isUpper ? 65 : 97
            y := Asc(char) - base + 1 ; encrypted position (1–26)

            found := false
            Loop, 26 {
                x := A_Index
                result := Mod((3 * x + 2), 26)
                if (result == y || (result == 0 && y == 26)) {
                    output .= Chr(base + x - 1)
                    found := true
                    break
                }
            }
            if (!found)
                output .= "?"
        } else {
            output .= char
        }
    }
    return output
}

; ===== ENCRYPT (3x+2 Mod 26) =====
Encrypt3x2(str) {
    output := ""
    Loop, Parse, str
    {
        char := A_LoopField
        if RegExMatch(char, "[a-zA-Z]") {
            isUpper := (Asc(char) >= 65 && Asc(char) <= 90)
            base := isUpper ? 65 : 97
            x := Asc(char) - base + 1
            encIndex := Mod((3 * x + 2), 26)
            if (encIndex = 0)
                encIndex := 26
            output .= Chr(base + encIndex - 1)
        } else {
            output .= char
        }
    }
    return output
}

; ===== MAIN MENU =====
ShowMainMenu:
Gui, akun:New
Gui, akun:+AlwaysOnTop +Resize -SysMenu
Sleep, 200
Gui, akun:-AlwaysOnTop
Gui, akun:Color, 000000
Gui, akun:Font, c00FF00 s15, Lucida Console
Gui, akun:Add, Text,, Welcome Operative. Choose your task:
Gui, akun:Font, s10
Gui, akun:Add, Button, gAnimeSubMenu, Access (Retrieve / Submit)
Gui, akun:Add, Button, gChromes, Launch Mission Interface
Gui, akun:Add, Button, gClick, Start Clicky_clicker.ahk
Gui, akun:Add, Button, gMacros, Start Macro Recorder/Player
Gui, akun:Add, Button, gFileManager, Mangage File Runner
Gui, akun:Add, Button, gOpenSettingsMenu, Settings

; --- Big lock button that toggles unlockal ---
Gui, akun:Add, Button, gExitApp, Exit Terminal
if (debug)
    Gui, akun:Add, Button, gRestartScript, Restart Script

Gui, akun:Font, s30, Segoe UI Symbol
Gui, akun:Add, Button, w100 h100 x300 y125 vLockBtn gToggleLockUnlock, % Chr(0x26BF)  ; ⚿ Lock symbol
Gui, akun:Font, s10, Lucida Console   ; Restore original font
if (unlockal)
    Gui, akun:Add, Text,, Unlocked
else
    Gui, akun:Add, Text,, Locked
; --- Add the ? control ---
Gui, akun:Font, cFFFFFF s14, Lucida Console
Gui, akun:Add, Text, w22 h20 +gOpenHelp vHelpText hwndHelpHWND, ?
Gui, akun:Font, c00FF00 s10, Lucida Console

; --- Show GUI ---
Gui, akun:Show,, ENCRYPTED TERMINAL

; --- Move ? to top-right dynamically ---
Gui, akun:+LastFound
WinGetPos,,, guiWidth, guiHeight, A
GuiControlGet, CtrlPos, Pos, HelpText
xPos := guiWidth - CtrlPosW - 5
yPos := 7.5
GuiControl, akun:Move, HelpText, x%xPos% y%yPos%
Return

; --- Toggle lock button subroutine ---
ToggleLockUnlock:
if (!unlockal) {
    Gui, akun:Submit, NoHide  ; Update variables from GUI controlsi
    Gui, New
    Gui, +AlwaysOnTop +ToolWindow +SysMenu
    Gui, Color, 000000
    Gui, Font, c00FF00 s10, Lucida Console
    Gui, Add, Text,, Enter Access Key:
    Gui, Font, c000000
    Gui, Add, Edit, vuserInputsb Password w220 hwndAuthPwdField
    Gui, Font, c00FF00
    Gui, Add, Checkbox, vShowPass1 gToggleShowAuthPass, Show Password
    Gui, Add, Button, gCheckPasswordsb, Authenticate
    Gui, Show,, ACCESS PORTAL
} else {
    unlockal := false
    Gui, akun:Destroy
    unlockeverything := false
    thatsettingsone := false
    thatanimeone := false
    thatistrue := false
    Gosub, ShowMainMenu

}
Return

CheckPasswordsb:
Gui, Submit
userInputsb := Trim(userInputsb)
correctPass := Trim(correctPass)
StringLower, userInputsb, userInputsb
StringLower, correctPass, correctPass

if (userInputsb = correctPass) {
    unlockal := true
    Gui, akun:Destroy
    unlockeverything := true
    thatsettingsone := true
    thatanimeone := true
    thatistrue := true
    Gosub, ShowMainMenu
} else {
    Msgbox, 16, Wrong Pass, Ooo...Nice try But you do not have correct password
    unlockal := false
    Gui, akun:Destroy
    unlockeverything := false
    thatsettingsone := false
    thatanimeone := false
    thatistrue := false
    Gosub, ShowMainMenu

}
Return

FileManager:
; ---------------------------
; AHK v1 script — MainGUI (Add / Run / Delete)
; ---------------------------
#Persistent
SetBatchLines, -1
DetectHiddenWindows, On
SetTitleMatchMode, 2
#InstallKeybdHook

; --- Load existing saves on start ---
LoadSavedFiles()
; === ESC Key Timer ===
; ---------------------------
; Main GUI
; ---------------------------
FileManagerGUI:
Gui, Main:New
Gui, Main: +AlwaysOnTop +Resize
sleep, 200
Gui, Main: -AlwaysOnTop
Gui, Main: Color, 000000
Gui, Main: Font, c00FF00 s10, Lucida Console
Gui, Main:Add, Button, gOpenFile w200 h30, Open File
Gui, Main:Add, Button, gShowSaved w200 h30, Saved Files
Gui, Main:Add, Button, gDeleteSaved w200 h30, Delete Entries
Gui, Main:Show, w250 h140, FileManagerGUI
return

; ---------------------------
; Open File -> select + save (prevent duplicates)
; ---------------------------
OpenFile:
FileSelectFile, pickedFile, 3, , Select a file
if (ErrorLevel || pickedFile = "")
    return

global FileManagerFileLocation, savedFiles

; Reload saved files from disk
LoadSavedFiles()

; Check for duplicate (case-insensitive)
StringLower, lowerPicked, pickedFile
for index, existing in savedFiles
{
    StringLower, existingLower, existing
    if (existingLower = lowerPicked)
    {
        MsgBox, 48, Already Saved, That file is already saved boss :)
        return
    }
}

; Add the new file
savedFiles.Push(pickedFile)
; Rewrite files.txt cleanly
FileDelete, %FileManagerFileLocation%
Loop, % savedFiles.Length()
{
    val := savedFiles[A_Index]
    if (A_Index = 1)
        FileAppend, %val%, %FileManagerFileLocation%
    else
        FileAppend, `n%val%, %FileManagerFileLocation%
}

LoadSavedFiles()
return

; ---------------------------
; Saved Files GUI
; ---------------------------
ShowSaved:
Gui, Saved:Destroy
Gui, Saved:New

LoadSavedFiles()

if (savedFiles.Length() = 0)
{
    Gui, Saved:Add, Text,, No saved files :(
    Gui, Saved:Show, w350 h120, Saved Files
    return
}

i := 0
for index, fullPath in savedFiles
{
    i++
    SplitPath, fullPath, fileName
    Gui, Saved:Add, Button, gRunFile vBtn%i% w300 h30, %fileName%
}

height := 20 + (i * 36)
if (height < 120)
    height := 120
Gui, Saved:Show, w350 h%height%, Saved Files
return

; ---------------------------
; Run saved file
; ---------------------------
RunFile:
global savedFiles
GuiControlGet, ctrl, FocusV
if (ctrl = "")
    return

StringTrimLeft, idx, ctrl, 3
idx := idx + 0
if (idx < 1)
    return

filePath := savedFiles[idx]
if (filePath = "")
{
    MsgBox, 48, Error, Could not find the file path in memory.
    return
}

if FileExist(filePath)
    Run, %filePath%
else
    MsgBox, 48, Error, File not found: %filePath%
return

; ---------------------------
; Delete Entries GUI
; ---------------------------
DeleteSaved:
Gui, Delete:Destroy
Gui, Delete:New

LoadSavedFiles()

if (savedFiles.Length() = 0)
{
    Gui, Delete:Add, Text,, No saved files :(
    Gui, Delete:Show, w350 h120, Delete Entries
    return
}

i := 0
for index, fullPath in savedFiles
{
    i++
    SplitPath, fullPath, fileName
    ; Store the index in v variable
    Gui, Delete:Add, Button, gDeleteFile w300 h30 vDelBtn%index%, %fileName%
}

height := 20 + (i * 36)
if (height < 120)
    height := 120
Gui, Delete:Show, w350 h%height%, Delete Entries
return

DeleteFile:
global FileManagerFileLocation

; Get the file path from the clicked button text
GuiControlGet, clickedText,, %A_GuiControl%
fileToDelete := clickedText

; Read all lines from the file into an array
FileRead, content, %FileManagerFileLocation%
if (ErrorLevel)
    return

lines := []
Loop, Parse, content, `n, `r
{
    line := A_LoopField
    StringTrimRight, line, line, 0
    if (line != "")
        lines.Push(line)
}

; Find the exact line matching the button text
found := false
for index, val in lines
{
    SplitPath, val, name
    if (name = fileToDelete)
    {
        found := true
        break
    }
}

if (!found)
{
    MsgBox, 48, Error, Could not find the file to delete.
    return
}

; Confirm deletion
MsgBox, 4, Confirm Delete, Are you sure you want to delete "%val%"?
IfMsgBox, No
    return

; Remove the file from the array
lines.Remove(index)

; Rewrite the file
FileDelete, %FileManagerFileLocation%
for idx, val in lines
{
    if (idx = 1)
        FileAppend, %val%, %FileManagerFileLocation%
    else
        FileAppend, `n%val%, %FileManagerFileLocation%
}

; Close and rebuild Delete GUI so indices match
Gui, Delete:Destroy

; Optionally, also rebuild Main GUI
Gui, Main:Destroy
Gosub, FileManagerGUI
return

; ---------------------------
; Utility: load saved files from disk
; ---------------------------
LoadSavedFiles()
{
    global FileManagerFileLocation, savedFiles
    savedFiles := []
    if !FileExist(FileManagerFileLocation)
        return

    FileRead, content, %FileManagerFileLocation%
    if (ErrorLevel)
        return

    Loop, Parse, content, `n, `r
    {
        line := A_LoopField
        StringReplace, line, line, `r,, All
        if (line = "")
            continue
        savedFiles.Push(line)
    }
}

; ---------------------------
; Close all GUIs
; ---------------------------
return

Macros:
Gui, Destroy

#NoEnv
#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Screen

; === Paths ===
macroFolder := A_AppData . "\MainGUI\Macros\"
FileCreateDir, %macroFolder%

; === Globals ===
recording := false
macroText := ""
lastActionTime := 0
MouseSpeed := 2

Hotkey, ^r, On
Hotkey, ^d, On
Hotkey, ^m, On
Hotkey, Esc, On

; === Hotkeys ===
^r::Gosub, StartRecording   ; Ctrl+R = Start recording
^d::Gosub, StopRecording    ; Ctrl+D = Stop recording
^m::Gosub, ShowMacroMenu    ; Ctrl+M = Macro manager GUI

Esc::
Hotkey, ^r, Off
Hotkey, ^d, Off
Hotkey, ^m, Off
Gui, a:Destroy
Gui, b:Destroy
Gui, c:Destroy
Gosub, ShowMainMenu
Hotkey, Esc, Off
return
; =========================
; === RECORDING LOGIC ====
; =========================

StartRecording:
if (recording) {
    MsgBox, Already recording!
    return
}
recording := true
macroText := "#NoEnv`nSendMode Input`nSetWorkingDir %A_ScriptDir%`nCoordMode, Mouse, Screen`n`n"
lastActionTime := A_TickCount
ToolTip, 🎙 Recording... (Ctrl+D to stop)

; Register dynamic hotkeys for all keys we want
keys := "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,"
keys .= "0,1,2,3,4,5,6,7,8,9,"
keys .= "Enter,Space,Tab,Esc,Backspace,Delete,Up,Down,Left,Right,"
keys .= "Shift,Ctrl,Alt,LWin,RWin,F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,F11,F12"

Loop, Parse, keys, `,
{
    k := A_LoopField
    if (k = "")
        continue
    Hotkey, ~*%k%, RecordDynamic, On
}

; Mouse hotkeys
Hotkey, ~LButton, RecordLButton, On
Hotkey, ~RButton, RecordRButton, On

return

StopRecording:
if (!recording) {
    MsgBox, Not recording!
    return
}
recording := false
ToolTip

; Ask name
InputBox, macroName, Save Macro, Enter a name for this macro:
if (ErrorLevel)
    return
if (macroName = "")
    macroName := "Macro"

; Ensure unique name
savePath := macroFolder . macroName . ".mcr"
count := 1
while FileExist(savePath) {
    savePath := macroFolder . macroName . "(" . count . ").mcr"
    count++
}

; End macro with ExitApp
macroText .= "`nExitApp"

FileAppend, %macroText%, %savePath%
MsgBox, Saved as %savePath%
return

; =========================
; === RECORD FUNCTIONS ====
; =========================

RecordDynamic:
if (recording) {
    thisKey := SubStr(A_ThisHotkey, 3)  ; strip "~*"
    delay := A_TickCount - lastActionTime
    ; Detect modifiers
    mods := ""
    if GetKeyState("Shift", "P")
        mods .= "+"
    if GetKeyState("Ctrl", "P")
        mods .= "^"
    if GetKeyState("Alt", "P")
        mods .= "!"
    if GetKeyState("LWin", "P") or GetKeyState("RWin", "P")
        mods .= "#"

    macroText .= "Sleep, " delay "`nSend, " mods "{" thisKey "}`n"
    lastActionTime := A_TickCount
}
return

RecordLButton:
if (recording) {
    delay := A_TickCount - lastActionTime
    MouseGetPos, x, y
    macroText .= "Sleep, " delay "`nMouseMove, " x ", " y ", " MouseSpeed "`nClick`n"
    lastActionTime := A_TickCount
}
return

RecordRButton:
if (recording) {
    delay := A_TickCount - lastActionTime
    MouseGetPos, x, y
    macroText .= "Sleep, " delay "`nMouseMove, " x ", " y ", " MouseSpeed "`nClick right`n"
    lastActionTime := A_TickCount
}
return

; =========================
; === MACRO MENU GUI =====
; =========================

ShowMacroMenu:
Gui, a:New
Gui, a:+AlwaysOnTop +Resize
sleep, 200
Gui, a:-AlwaysOnTop
Gui, a:Color, 000000
Gui, a:Font, c00FF00 s10, Lucida Console
Gui, a:Add, Text,, Play Macros
Gui, a:Add, Button, gPlay, Play
Gui, a:Add, Text,, Delete Macros
Gui, a:Add, Button, gDeleteMacros, Delete macros
Gui, a:Show,, Macro Manager
return

Play:
Gui, b:New
Gui, b:+AlwaysOnTop +Resize
sleep, 200
Gui, b:-AlwaysOnTop
Gui, b:Color, 000000
Gui, b:Font, c00FF00 s15, Lucida Console
Gui, b:Add, Text,, ▶ Play Macros:
Gui, Font, s10
Loop, Files, %macroFolder%*.mcr
{
    btnName := A_LoopFileName
    Gui, b:Add, Button, gRunMacro, %btnName%
}
Gui, b:Show,, Macro Manager
return
DeleteMacros:
Gui, c:New
Gui, c:+AlwaysOnTop +Resize
sleep, 200
Gui, c:-AlwaysOnTop
Gui, c:Color, 000000
Gui, c:Font, c00FF00 s15, Lucida Console
Gui, c:Add, Text,, ❌ Delete Macros:
Gui, Font, s10
Loop, Files, %macroFolder%*.mcr
{
    btnName := A_LoopFileName
    Gui, c:Add, Button, gDeleteMacro, %btnName%
}

Gui, c:Show,, Macro Manager
return

; --- Play Macro ---
RunMacro:
GuiControlGet, btnName, , %A_GuiControl%
macroPath := macroFolder . btnName

; Read macro code
FileRead, macroCode, %macroPath%
if (ErrorLevel) {
    MsgBox, Failed to read %macroPath%
    return
}

; Write to temporary .ahk
tempMacro := A_Temp . "\macro_run.ahk"
FileDelete, %tempMacro%
FileAppend, %macroCode%, %tempMacro%

; Run & wait
RunWait, %A_AhkPath% "%tempMacro%",, UseErrorLevel

; Delete after finished
FileDelete, %tempMacro%
return

; --- Delete Macro ---
DeleteMacro:
GuiControlGet, btnName, , %A_GuiControl%
macroPath := macroFolder . btnName

MsgBox, 4, Delete Macro, Are you sure you want to delete "%btnName%"?
IfMsgBox, Yes
{
    FileDelete, %macroPath%
    MsgBox, Deleted %btnName%
    Gosub, ShowMacroMenu  ; refresh list
}
return
; =========================
; === QUICK RUN KEYS =====
; =========================

^+1::Gosub, RunMacro1
^+2::Gosub, RunMacro2
^+3::Gosub, RunMacro3
^+4::Gosub, RunMacro4
^+5::Gosub, RunMacro5
^+6::Gosub, RunMacro6
^+7::Gosub, RunMacro7
^+8::Gosub, RunMacro8
^+9::Gosub, RunMacro9
^+0::Gosub, RunMacro10

RunMacro1: 
Gosub, RunMacroByIndex1 
return
RunMacro2: 
Gosub, RunMacroByIndex2 
return
RunMacro3: 
Gosub, RunMacroByIndex3 
return
RunMacro4: 
Gosub, RunMacroByIndex4 
return
RunMacro5: 
Gosub, RunMacroByIndex5 
return
RunMacro6: 
Gosub, RunMacroByIndex6 
return
RunMacro7: 
Gosub, RunMacroByIndex7 
return
RunMacro8: 
Gosub, RunMacroByIndex8 
return
RunMacro9: 
Gosub, RunMacroByIndex9 
return
RunMacro10: 
Gosub, RunMacroByIndex10 
return

; Core logic, pass index
RunMacroByIndex1: 
index := 1 
Gosub, RunMacroByIndex 
return
RunMacroByIndex2: 
index := 2 
Gosub, RunMacroByIndex 
return
RunMacroByIndex3: 
index := 3 
Gosub, RunMacroByIndex 
return
RunMacroByIndex4: 
index := 4 
Gosub, RunMacroByIndex 
return
RunMacroByIndex5: 
index := 5 
Gosub, RunMacroByIndex 
return
RunMacroByIndex6: 
index := 6 
Gosub, RunMacroByIndex 
return
RunMacroByIndex7: 
index := 7 
Gosub, RunMacroByIndex 
return
RunMacroByIndex8: 
index := 8 
Gosub, RunMacroByIndex 
return
RunMacroByIndex9: 
index := 9 
Gosub, RunMacroByIndex 
return
RunMacroByIndex10: 
index := 10 
Gosub, RunMacroByIndex 
return

RunMacroByIndex:
    global macroFolder
    i := 0
    found := ""
    Loop, Files, %macroFolder%*.mcr
    {
        i++
        if (i = index) {
            found := A_LoopFileFullPath
            break
        }
    }
    if (found = "") {
        MsgBox, 48, Macro Not Found, No macro at slot #%index%.
        return
    }

    FileRead, macroCode, %found%
    if ErrorLevel {
        MsgBox, Failed to read %found%
        return
    }

    tempMacro := A_Temp . "\macro_run.ahk"
    FileDelete, %tempMacro%
    FileAppend, %macroCode%, %tempMacro%

    ToolTip, ▶ Running Macro #%index%: %found%
    Sleep, 800
    ToolTip

    RunWait, %A_AhkPath% "%tempMacro%",, UseErrorLevel
    FileDelete, %tempMacro%
return

return

RestartScript:
Reload
return

; When clicked this label opens the help:
OpenHelp:
  helpChm := A_ScriptDir . "\help\MyAppHelp.chm"
  helpHtml := A_ScriptDir . "\help\index.htm"
  if FileExist(helpChm)
    Run, %helpChm%
  else if FileExist(helpHtml)
    Run, %helpHtml%
  else
    MsgBox, 48, Help not found, Help files are missing in the help folder.
return

Click:
Gui, Destroy

; === Macro Setup ===
#NoEnv
#Persistent
SetBatchLines, -1
DetectHiddenWindows, On
SetTitleMatchMode, 2
#InstallKeybdHook  ; <-- ensures hotkeys work even when focus is ducked
SendMode Input
CoordMode, Mouse, Screen


configFile := A_AppData "\MainGUI\click_config.cfg"
if !FileExist(configFile) {
    MsgBox, 48, Error, No config file found. Exiting
    Gosub, ShowMainMenu
    return
}

FileRead, rawKeys, %configFile%
StringSplit, keyLine, rawKeys, `n, `r

play_pause := keyLine1
exitKey    := keyLine2
volUpKey   := keyLine3
volDownKey := keyLine4
swapKey    := keyLine5
altTabKey  := keyLine6
closeKey   := keyLine7
mediaKey   := keyLine8
AdSkipperKey := keyLine9
blackScreen := keyLine10
ForceBrightness := keyLine11
odd := true
paused := false
blackScreen_yes := false
brightForce := false
ForceBrightDecreaseNumber := configData6
; === Hotkeys ===
if !(play_pause ~= "i)^disable$")
    Hotkey, %play_pause%, PauseNow, On

if !(exitKey ~= "i)^disable$")
    Hotkey, %exitKey%, StopMacro, On

; === Timer ===
SetTimer, WatchKeys, 20
return

PauseNow:
paused := !paused
if (paused) {
    SetTimer, WatchKeys, Off
    Hotkey, %exitKey%, Off
    SetTimer, ContinueWhenPause, 500
}
if (!paused) {
    SetTimer, WatchKeys, On
    Hotkey, %exitKey%, On
    SetTimer, ContinueWhenPause, Off
}
return

ContinueWhenPause:
if (blackScreen_yes) {
    MouseMove, 9999, 9999
}
return

StopMacro:
; Kill the macro stuff boss
SetTimer, WatchKeys, Off
Hotkey, %play_pause%, Off
Hotkey, %exitKey%, Off
Gui, blackolala:Destroy
blackScreen_yes := false
Gosub, ShowMainMenu
return

WatchKeys:
if (blackScreen_yes) {
    MouseMove, 9999, 9999
}

; === Volume Up ===
if !(volUpKey ~= "i)^disable$") && GetKeyState(volUpKey, "P")
    Send, {Volume_Up}

; === Volume Down ===
if !(volDownKey ~= "i)^disable$") && GetKeyState(volDownKey, "P")
    Send, {Volume_Down}

; === Swap Key ===
if !(swapKey ~= "i)^disable$") && GetKeyState(swapKey, "P") {
    if odd {
        Send, {Space}
        Sleep, 50
        Send, {Alt Down}{Tab}
        Sleep, 100
        Send, {Alt Up}
    } else {
        Send, {Alt Down}{Tab}
        Sleep, 100
        Send, {Alt Up}
        Sleep, 100
        Send, {Space}
    }
    odd := !odd
}

; === Alt Tab Key ===
if !(altTabKey ~= "i)^disable$") && GetKeyState(altTabKey, "P") {
    Send, {Alt Down}{Tab}
    Sleep, 100
    Send, {Alt Up}
}

; === Close Key ===
if !(closeKey ~= "i)^disable$") && GetKeyState(closeKey, "P") {
    Send, {Alt Down}{F4}
    Sleep, 100
    Send, {Alt Up}
}

; === Media Key ===
if !(mediaKey ~= "i)^disable$") && GetKeyState(mediaKey, "P") {
    Send, {Media_Play_Pause}
    Sleep, 100
}

; === AdSkip sequence using WaitOrInterrupt with internal interrupt tooltip ===
if !(AdSkipperKey ~= "i)^disable$") && GetKeyState(AdSkipperKey, "P")
{
    MsgBox, 48, Info, Comming Soon...
}

if !(blackScreen ~= "i)^disable$") && GetKeyState(blackScreen, "P")
{
    KeyWait, %blackScreen%
    ; flip the toggle
    blackScreen_yes := !blackScreen_yes
    if (blackScreen_yes)
    {
        ; === Create the fullscreen black GUI ===
        Gui, blackolala:New, +AlwaysOnTop -Caption +ToolWindow
        Gui, blackolala:Color, 000000
        Gui, blackolala:Show, x0 y0 w%A_ScreenWidth% h%A_ScreenHeight%, blackolala
    }
    else
    {
        ; === Destroy the GUI ===
        Gui, blackolala:Destroy
    }
}
if !(ForceBrightness ~= "i)^disable$") && GetKeyState(ForceBrightness, "P") {
    brightForce := !brightForce
    if (brightForce) {
        Gui, Forcebright:New, -Caption +AlwaysOnTop +ToolWindow +HWNDguiHwnd +E0x20
        Gui, Forcebright:Color, 000000
        Gui, Forcebright:Show, x0 y0 w%A_ScreenWidth% h%A_ScreenHeight%, Forcebright
        WinSet, Transparent, %ForceBrightDecreaseNumber%, % "ahk_id " guiHwnd
    }
    else
    {
        Gui, Forcebright:Destroy
    }
    Sleep, 200
}

return
RemoveTip:
    ToolTip
return

; === Helper function: wait or stop if any key is pressed, shows "Interrupted" tooltip ===
WaitOrInterrupt(ms) {
    start := A_TickCount
    while (A_TickCount - start < ms) {
        Sleep, 5  ; tiny pause to avoid maxing CPU
        Loop, 255
        {
            if (GetKeyState(Chr(A_Index), "P")) {  ; any key pressed
                ToolTip, Interrupted
                SetTimer, RemoveTip, -2000
                return false
            }
        }
    }
    return true
}

OpenSettingsMenu:
if (!thatsettingsone) {
    Gui, New
    Gui, +AlwaysOnTop +ToolWindow +SysMenu
    Gui, Color, 000000
    Gui, Font, c00FF00 s10, Lucida Console
    Gui, Add, Text,, Enter Access Key:
    Gui, Font, c000000 ; black font
    Gui, Add, Edit, vuserInputsa Password w220 hwndAuthPwdField
    Gui, Font, c00FF00 ; back to green for rest of GUI
    Gui, Add, Checkbox, vShowPass1 gToggleShowAuthPass, Show Password
    Gui, Add, Button, gCheckPasswordsa, Authenticate
    Gui, Show,, ACCESS PORTAL
} else {
    Gosub, OpenSettings
}
return

CheckPasswordsa:
Gui, Submit
userInputsa := Trim(userInputsa)
correctPass := Trim(correctPass)
StringLower, userInputsa, userInputsa
StringLower, correctPass, correctPass

if (userInputsa = correctPass) {
    thatsettingsone := True
    Gosub, OpenSettings
} else {
    Msgbox, 16, Wrong Pass, Who are you?...Go away
}
return

OpenSettings:
checkState := noanimation ? "Checked" : ""
LogState := enableLogs ? "Checked" : ""
SelectedCipherChoice := configData6
Gui, New
Gui, +Resize
Gui, Color, 000000
Gui, Font, c00FF00 s15, Lucida Console
Gui, Add, Text,, SETTINGS PANEL
Gui, Font, s10
Gui, Add, Button, gChangePassword, Change Access Key
Gui, Add, Text,, Lockdown Timer (seconds):
Gui, Font, c000000
Gui, Add, Edit, vLockDurationInput w100, %configData1%
Gui, Font, c00FF00 ; back to green for rest of GUI
Gui, Add, Text,, Max Failed Attempts Before Lockdown:
Gui, Font, c000000
Gui, Add, Edit, vMaxFailInput w100, %configData2%
Gui, Font, c00FF00
Gui, Add, Checkbox, %checkState% vNoAnimCheckbox gToggleAnim, Disable Animations?
Gui, Add, Text,, Tick the box to disable animations.
Gui, Add, Text,, Enter the Profile Number From The Chrome Shortcut
Gui, Font, c000000
Gui, Add, Edit, vProfileNumber w100, %configData4%
Gui, Font, c00FF00
Gui, Add, Text,, Force Brightness Transparency (Decrease Only)
Gui, Font, c000000
Gui, Add, Edit, w100 vForceBrightDecreaseNumber, %configData6%
Gui, Font, c00FF00
Gui, Add, Checkbox, %LogState% vLogs gToggleLogs, Enable Logs?
Gui, Add, Text,, Tick the box to enable Logs.
Gui, Add, Button, gClickerConfig, Edit Config File for Clicky_clicker.ahk
Gui, Add, Button, gManageCustomSites, Manage Custom Sites
Gui, Add, Button, gManageGuestSistes, Manage That
Gui, Add, Button, gApplySettings, Save Settings
Gui, Show,, Settings
; --- Add the ? control ---
Gui, Font, cFFFFFF s14, Lucida Console
Gui, Add, Text, w22 h20 +gOpenHelp vHelpText hwndHelpHWND, ?
Gui, Font, c00FF00 s10, Lucida Console
Gui, Show,, Settings

; --- Move ? to top-right dynamically ---
Gui, +LastFound
WinGetPos,,, guiWidth, guiHeight, A   ; get GUI client size including borders
GuiControlGet, CtrlPos, Pos, HelpText
xPos := guiWidth - CtrlPosW - 5  ; 10 px margin from right
yPos := 7.5                         ; 10 px from top
GuiControl, Move, HelpText, x%xPos% y%yPos%
return

ManageGuestSistes:
FileRead, guestSites, %guestSitesFile%
Gui, New
Gui, Color, 000000
Gui, Font, c00FF00 s15, Lucida Console
Gui, Add, Text,, Enter one URL per line:
Gui, Font, c000000 s10
Gui, Add, Edit, vGuestList w300 h200, %guestSites%
Gui, Font, c00FF00
Gui, Add, Button, gSaveGuestSites, Save
Gui, Add, Button, gCancelGuestSites, Cancel
Gui, Show,, JUST DO IT
; --- Add the ? control ---
Gui, Font, cFFFFFF s14, Lucida Console
Gui, Add, Text, w22 h20 +gOpenHelp vHelpText hwndHelpHWND, ?
Gui, Font, c00FF00 s10, Lucida Console

; --- Show GUI once ---
Gui, Show,, JUST DO IT

; --- Move ? to top-right dynamically ---
Gui, +LastFound
WinGetPos,,, guiWidth, guiHeight, A   ; get GUI client size including borders
GuiControlGet, CtrlPos, Pos, HelpText
xPos := guiWidth - CtrlPosW - 5  ; 10 px margin from right
yPos := 7.5                         ; 10 px from top
GuiControl, Move, HelpText, x%xPos% y%yPos%
return

SaveGuestSites:
Gui, Submit
if (GuestList != "") {
    FileDelete, %guestSitesFile%
    FileAppend, %GuestList%, %guestSitesFile%
    MsgBox, 64, Saved, Done.
} else {
    MsgBox, 48, Warning, Nothing to save, boss!
}
Gui, Destroy
return

CancelGuestSites:
Gui, Destroy
return

ManageCustomSites:
if !FileExist(customSitesFile) {
    FileAppend, , %customSitesFile%
}
FileRead, rawSites, %customSitesFile%
Gui, New
Gui, Color, 000000
Gui, Font, c00FF00 s15, Lucida Console
Gui, Add, Text,, Enter one URL per line:
Gui, Font, c000000 s10
Gui, Add, Edit, vSiteList w300 h200, %rawSites%
Gui, Font, c00FF00
Gui, Add, Button, gSaveCustomSites, Save
Gui, Add, Button, gCancelCustomSites, Cancel
Gui, Show,, CUSTOM SITES
; --- Add the ? control ---
Gui, Font, cFFFFFF s14, Lucida Console
Gui, Add, Text, w22 h20 +gOpenHelp vHelpText hwndHelpHWND, ?
Gui, Font, c00FF00 s10, Lucida Console

; --- Show GUI once ---
Gui, Show,, CUSTOM SITES

; --- Move ? to top-right dynamically ---
Gui, +LastFound
WinGetPos,,, guiWidth, guiHeight, A   ; get GUI client size including borders
GuiControlGet, CtrlPos, Pos, HelpText
xPos := guiWidth - CtrlPosW - 5  ; 10 px margin from right
yPos := 7.5                         ; 10 px from top
GuiControl, Move, HelpText, x%xPos% y%yPos%
return

SaveCustomSites:
Gui, Submit
if (SiteList != "") {
    FileDelete, %customSitesFile%
    FileAppend, %SiteList%, %customSitesFile%
    MsgBox, 64, Saved, Custom sites updated boss.
} else {
    MsgBox, 48, Warning, Nothing to save, boss!
}
Gui, Destroy
return

CancelCustomSites:
Gui, Destroy
return

ClickerConfig:
; --- read existing config content ---
FileRead, rawKeys, %clickyEdit%
StringSplit, keyLine, rawKeys, `n, `r

; --- GUI setup ---
Gui, New, +Resize
Gui, Color, 000000
Gui, Font, c00FF00 s10, Lucida Console

y := 10
rowHeight := 30

; --- Play/Pause ---
isDisable := RegExMatch(keyLine1, "i)^disable$")
Gui, Font, c000000
Gui, Add, Edit, vplay_pause w100 x150 y%y%, % (isDisable ? "" : keyLine1)
Gui, Font, c00FF00
Gui, Add, Text, x10 y%y%, Play/Pause Script
Gui, Add, Checkbox, vplay_pause_chk x260 y%y%, Disable
if (isDisable)
    GuiControl,, play_pause_chk, 1
y += rowHeight

; --- Exit Key ---
isDisable := RegExMatch(keyLine2, "i)^disable$")
Gui, Font, c000000
Gui, Add, Edit, vexitKey w100 x150 y%y%, % (isDisable ? "" : keyLine2)
Gui, Font, c00FF00
Gui, Add, Text, x10 y%y%, Exit key:
Gui, Add, Checkbox, vexitKey_chk x260 y%y%, Disable
if (isDisable)
    GuiControl,, exitKey_chk, 1
y += rowHeight

; --- Volume Up ---
isDisable := RegExMatch(keyLine3, "i)^disable$")
Gui, Font, c000000
Gui, Add, Edit, vvolUpKey w100 x150 y%y%, % (isDisable ? "" : keyLine3)
Gui, Font, c00FF00
Gui, Add, Text, x10 y%y%, Volume Up key:
Gui, Add, Checkbox, vvolUpKey_chk x260 y%y%, Disable
if (isDisable)
    GuiControl,, volUpKey_chk, 1
y += rowHeight

; --- Volume Down ---
isDisable := RegExMatch(keyLine4, "i)^disable$")
Gui, Font, c000000
Gui, Add, Edit, vvolDownKey w100 x150 y%y%, % (isDisable ? "" : keyLine4)
Gui, Font, c00FF00
Gui, Add, Text, x10 y%y%, Volume Down key:
Gui, Add, Checkbox, vvolDownKey_chk x260 y%y%, Disable
if (isDisable)
    GuiControl,, volDownKey_chk, 1
y += rowHeight

; --- Swap Key ---
isDisable := RegExMatch(keyLine5, "i)^disable$")
Gui, Font, c000000
Gui, Add, Edit, vswapKey w100 x150 y%y%, % (isDisable ? "" : keyLine5)
Gui, Font, c00FF00
Gui, Add, Text, x10 y%y%, Swap key:
Gui, Add, Checkbox, vswapKey_chk x260 y%y%, Disable
if (isDisable)
    GuiControl,, swapKey_chk, 1
y += rowHeight

; --- Alt+Tab Key ---
isDisable := RegExMatch(keyLine6, "i)^disable$")
Gui, Font, c000000
Gui, Add, Edit, valtTabKey w100 x150 y%y%, % (isDisable ? "" : keyLine6)
Gui, Font, c00FF00
Gui, Add, Text, x10 y%y%, Alt+Tab key:
Gui, Add, Checkbox, valtTabKey_chk x260 y%y%, Disable
if (isDisable)
    GuiControl,, altTabKey_chk, 1
y += rowHeight

; --- Close Key ---
isDisable := RegExMatch(keyLine7, "i)^disable$")
Gui, Font, c000000
Gui, Add, Edit, vcloseKey w100 x150 y%y%, % (isDisable ? "" : keyLine7)
Gui, Font, c00FF00
Gui, Add, Text, x10 y%y%, Close key:
Gui, Add, Checkbox, vcloseKey_chk x260 y%y%, Disable
if (isDisable)
    GuiControl,, closeKey_chk, 1
y += rowHeight

; --- Media Key ---
isDisable := RegExMatch(keyLine8, "i)^disable$")
Gui, Font, c000000
Gui, Add, Edit, vmediaKey w100 x150 y%y%, % (isDisable ? "" : keyLine8)
Gui, Font, c00FF00
Gui, Add, Text, x10 y%y%, Media key:
Gui, Add, Checkbox, vmediaKey_chk x260 y%y%, Disable
if (isDisable)
    GuiControl,, mediaKey_chk, 1
y += rowHeight

; --- Ad Skipper Key ---
isDisable := RegExMatch(keyLine9, "i)^disable$")
Gui, Font, c000000
Gui, Add, Edit, vAdSkipperKey w100 x150 y%y%, % (isDisable ? "" : keyLine9)
Gui, Font, c00FF00
Gui, Add, Text, x10 y%y%, Ad Skip:
Gui, Add, Checkbox, vAdSkipperKey_chk x260 y%y%, Disable
if (isDisable)
    GuiControl,, AdSkipperKey_chk, 1
y += rowHeight

isDisable := RegExMatch(keyLine10, "i)^disable$")
Gui, Font, c000000
Gui, Add, Edit, vblackScreen w100 x150 y%y%, % (isDisable ? "" : keyLine10)
Gui, Font, c00FF00
Gui, Add, Text, x10 y%y%, Black Screen:
Gui, Add, Checkbox, vblackScreen_chk x260 y%y%, Disable
if (isDisable)
    GuiControl,, blackScreen_chk, 1
y += rowHeight

isDisable := RegExMatch(keyLine11, "i)^disable$")
Gui, Font, c000000
Gui, Add, Edit, vForceBrightness w100 x150 y%y%, % (isDisable ? "" : keyLine11)
Gui, Font, c00FF00,
Gui, Add, Text, x10 y%y%, Force Brightness (Decrease Only):
Gui, Add, Checkbox, vForceBrightness_chk x260 y%y%, Disable
if (isDisable)
    GuiControl,, ForceBrightness_chk, 1
y += rowHeight

; --- Buttons ---
Gui, Add, Button, gclickerSave x10 w100 h30, Save
Gui, Add, Button, gclickerCancel x10 w100 h30, Cancel

; small help text top-right (optional)
Gui, Font, cFFFFFF s14, Lucida Console
Gui, Add, Text, w22 h20 +gOpenHelp vHelpText hwndHelpHWND, ?
Gui, Font, c00FF00 s10, Lucida Console

Gui, Show,, Clicky clicker Settings

; move ? to top-right
Gui, +LastFound
WinGetPos,,, guiWidth, guiHeight, A
GuiControlGet, CtrlPos, Pos, HelpText
xPos := guiWidth - CtrlPosW - 5
yPos := 7
GuiControl, Move, HelpText, x%xPos% y%yPos%
return

; --------------------------
clickerSave:
Gui, Submit

; Build each line: if checkbox checked => "disable", else the edit text
if (play_pause_chk)
    v1 := "disable"
else
    v1 := play_pause

if (exitKey_chk)
    v2 := "disable"
else
    v2 := exitKey

if (volUpKey_chk)
    v3 := "disable"
else
    v3 := volUpKey

if (volDownKey_chk)
    v4 := "disable"
else
    v4 := volDownKey

if (swapKey_chk)
    v5 := "disable"
else
    v5 := swapKey

if (altTabKey_chk)
    v6 := "disable"
else
    v6 := altTabKey

if (closeKey_chk)
    v7 := "disable"
else
    v7 := closeKey

if (mediaKey_chk)
    v8 := "disable"
else
    v8 := mediaKey

if (AdSkipperKey_chk)
    v9 := "disable"
else
    v9 := AdSkipperKey

if (blackScreen_chk)
    v10 := "disable"
else
    v10 := blackScreen

if (ForceBrightness_chk)
    v11 := "disable"
else
    v11 := ForceBrightness


clickyNewConfig := v1 . "`n" . v2 . "`n" . v3 . "`n" . v4 . "`n" . v5 . "`n" . v6 . "`n" . v7 . "`n" . v8 . "`n" . v9 . "`n" . v10 . "`n" . v11

FileDelete, %clickyEdit%
FileAppend, %clickyNewConfig%, %clickyEdit%
MsgBox, 64, Success, Saved Data successfully
Gui, Destroy
return

clickerCancel:
Gui, Destroy
return

ToggleAnim:
Gui, Submit, NoHide  ; Update variables from GUI controls
if (NoAnimCheckbox) {
    noanimation := true
} else {
    noanimation := false
}
return
ToggleLogs:
Gui, Submit, NoHide  ; Update variables from GUI controls
if (Logs) {
    enableLogs := true
} else {
    enableLogs := false
}
return

ApplySettings:
Gui, Submit, NoHide
; === Update cipher selection ===
selectedCipher := SelectedCipherChoice

if (LockDurationInput is digit AND MaxFailInput is digit AND ProfileNumber is digit) {
    configData1 := LockDurationInput  ; Line 1
    configData2 := MaxFailInput       ; Line 2
    GuiControlGet, NoAnimCheckbox     ; Checkbox state
    configData3 := NoAnimCheckbox ? "true" : "false"  ; Line 3
    configData4 := ProfileNumber
    GuiControlGet, Logs
    configData5 := Logs ? "true" : "false"
    defaultLockDuration := configData1
    maxFails := configData2
    noanimation := (configData3 = "true")
    enableLogs := (configData5 = "true")
    configData6 := ForceBrightDecreaseNumber

    newCfg =
    newCfg .= configData1 "`n"
    newCfg .= configData2 "`n"
    newCfg .= configData3 "`n"
    newCfg .= configData4 "`n"
    newCfg .= configData5 "`n"
    newCfg .= configData6

    FileDelete, %configFile%
    FileAppend, %newCfg%, %configFile%

    MsgBox, 64, Saved, Settings updated boss
} else {
    MsgBox, 48, Error, Both values gotta be numbers my guy
}
return

ChangePassword:
Gui, New
Gui, Font, c00FF00 s15, Lucida Console
Gui, Color, 000000
Gui, Add, Text,, Old Access Key:
Gui, Font, c000000 s10 ; black font
Gui, Add, Edit, vOldPass Password w220 hwndOldPwdField
Gui, Font, c00FF00 s15 ; back to green for rest of GUI
Gui, Add, Text,, New Access Key:
Gui, Font, c000000 s10 ; black font
Gui, Add, Edit, vNewPass Password w220 hwndChangePwdField
Gui, Font, c00FF00 ; back to green for rest of GUI
Gui, Add, Checkbox, vShowNewPass gToggleShowNewPass, Show Password
Gui, Add, Checkbox, vShowOldPass gToggleShowOldPass, Show Old Password
Gui, Add, Button, gSubmitPasswordChange, Submit Change
Gui, Show,, MODIFY ACCESS KEY
; --- Add the ? control ---
Gui, Font, cFFFFFF s14, Lucida Console
Gui, Add, Text, w22 h20 +gOpenHelp vHelpText hwndHelpHWND, ?
Gui, Font, c00FF00 s10, Lucida Console

; --- Show GUI once ---
Gui, Show,, MODIFY ACCESS KEY

; --- Move ? to top-right dynamically ---
Gui, +LastFound
WinGetPos,,, guiWidth, guiHeight, A   ; get GUI client size including borders
GuiControlGet, CtrlPos, Pos, HelpText
xPos := guiWidth - CtrlPosW - 5  ; 10 px margin from right
yPos := 7.5                         ; 10 px from top
GuiControl, Move, HelpText, x%xPos% y%yPos%
return

ToggleShowNewPass:
GuiControlGet, state,, ShowNewPass
if (state) {
    SendMessage, 0xCC, 0, 0,, ahk_id %ChangePwdField%  ; Show
} else {
    SendMessage, 0xCC, Asc("*"), 0,, ahk_id %ChangePwdField%  ; Hide
}
return

ToggleShowOldPass:
GuiControlGet, state,, ShowOldPass
if (state)
    SendMessage, 0xCC, 0, 0,, ahk_id %OldPwdField%
else
    SendMessage, 0xCC, Asc("*"), 0,, ahk_id %OldPwdField%
return

SubmitPasswordChange:
Gui, Submit

; === Read and decrypt current password
FileRead, encryptedPass, %passwordFile%
correctPass := Decrypt3x2(Trim(encryptedPass))
StringLower, OldPass, OldPass
StringLower, correctPass, correctPass

if (OldPass != correctPass) {
    MsgBox, 16, Wrong Key, The old key you typed is bogus. Try again boss.
    return
}

; === Validate new input
if (NewPass == "") {
    MsgBox, 48, Missing Info, You forgot to enter the new key, my dude.
    return
}

; === Prepare new encrypted password (but don’t save yet)
finalEncryptedPass := Encrypt3x2(NewPass)
tryCount := 0

; === Ask user to retype the new password to confirm
Loop {
    InputBox, retryPass, Confirm Key, Type your new access key again to confirm., HIDE

    if (retryPass == "") {
        MsgBox, 48, Error, You backed out. Password not changed.
        return
    }

    StringLower, retryPass, retryPass
    tempLowerNew := NewPass
    StringLower, tempLowerNew, tempLowerNew

    if (retryPass == tempLowerNew) {
        FileDelete, %passwordFile%
        FileAppend, %finalEncryptedPass%, %passwordFile%
        MsgBox, 64, Done, Access key updated successfully.
        Gui, Destroy
        return
    } else {
        tryCount++
        if (tryCount >= 10) {
            MsgBox, 16, Outta Luck, You hit 10 wrong attempts. The correct key was:`n%NewPass%
            return
        } else {
            MsgBox, 48, Nope, That ain't it. (%tryCount% / 10 tries used)
        }
    }
}
return

AnimeSubMenu:
if (!thatanimeone) {
    Gui, New
    Gui, +AlwaysOnTop +ToolWindow +SysMenu
    Gui, Color, 000000
    Gui, Font, c00FF00 s10, Lucida Console
    Gui, Add, Text,, Enter Access Key:
    Gui, Font, c000000 ; black font
    Gui, Add, Edit, vuserInputss Password w220 hwndAuthPwdField
    Gui, Font, c00FF00 ; back to green for rest of GUI
    Gui, Add, Checkbox, vShowPass1 gToggleShowAuthPass, Show Password
    Gui, Add, Button, gCheckPasswordss, Authenticate
    Gui, Show,, ACCESS PORTAL
} else {
    thatanimeone := True
    Gosub, AnimeMenu
}
return

CheckPasswordss:
Gui, Submit
userInputss := Trim(userInputss)
correctPass := Trim(correctPass)
StringLower, userInputss, userInputss
StringLower, correctPass, correctPass

if (userInputss = correctPass) {
    Gosub, AnimeMenu
    thatanimeone := True
} else {
    Msgbox, 16, Wrong Pass, Who are you?...Go away
}
return

AnimeMenu:
ifNotExist, %animeFile%
    FileAppend,, %animeFile%  ; create empty file if not exists

Gui, New
Gui, Color, 000000
Gui, Font, c00FF00 s15, Lucida Console
Gui, Add, Text,, What do you wanna do, boss?
Gui, Font, s10
Gui, Add, Button, gEditAnime, Edit Anime List
Gui, Add, Button, gCopyAnime, Search Anime Entry
Gui, Add, Button, gCancelAnimeSub, Cancel
Gui, Show,, ACTIONS

; --- Add the ? control ---
Gui, Font, cFFFFFF s14, Lucida Console
Gui, Add, Text, w22 h20 +gOpenHelp vHelpText hwndHelpHWND, ?
Gui, Font, c00FF00 s10, Lucida Console

; --- Move ? to top-right dynamically ---
Gui, +LastFound
WinGetPos,,, guiWidth, guiHeight, A
GuiControlGet, CtrlPos, Pos, HelpText
xPos := guiWidth - CtrlPosW - 5
yPos := 7.5
GuiControl, Move, HelpText, x%xPos% y%yPos%
return


; ===== CANCEL =====
CancelAnimeSub:
Gui, Destroy
return


; ===== EDIT ANIME LIST =====
EditAnime:
animeCount := 0
animeList := ""
FileRead, rawList, %animeFile%

Loop, Parse, rawList, `n, `r
{
    line := Trim(A_LoopField)
    if (line != "")
    {
        animeCount++
        animeEncrypted%animeCount% := line
        decrypted := Decrypt3x2(line)
        animeDecrypted%animeCount% := decrypted
        animeList .= decrypted . "`n"
    }
}

Gui, New
Gui, Color, 000000
Gui, Font, c00FF00 s15, Lucida Console
Gui, Add, Text,, Enter new entry (previous entries below):
Gui, Font, c000000 s10
Gui, Add, Edit, vNewAnimeName w300 h200, %animeList%
Gui, Font, c00FF00
Gui, Add, Button, gSubmitAnime, Save & Encrypt
Gui, Add, Button, gCancelAnimeSub, Cancel
Gui, Show,, ANIME VAULT

; --- Add the ? control ---
Gui, Font, cFFFFFF s14, Lucida Console
Gui, Add, Text, w22 h20 +gOpenHelp vHelpText hwndHelpHWND, ?
Gui, Font, c00FF00 s10, Lucida Console

; --- Move ? to top-right dynamically ---
Gui, +LastFound
WinGetPos,,, guiWidth, guiHeight, A
GuiControlGet, CtrlPos, Pos, HelpText
xPos := guiWidth - CtrlPosW - 5
yPos := 7.5
GuiControl, Move, HelpText, x%xPos% y%yPos%
return


; ===== SAVE ANIME ENTRY =====
SubmitAnime:
Gui, Submit, NoHide
newContent := Trim(NewAnimeName)

if (newContent != "")
{
    ; 🔥 Delete old anime file
    FileDelete, %animeFile%

    ; 🔥 Split textarea into lines
    StringSplit, lines, newContent, `n, `r

    ; 🔥 Encrypt & rewrite every line into new file
    Loop, %lines0%
    {
        entry := Trim(lines%A_Index%)
        if (entry != "")
        {
            encrypted := Encrypt3x2(entry)
            FileAppend, %encrypted%`n, %animeFile%
        }
    }

    MsgBox, 64, Success, Anime vault refreshed boss. All entries re-encrypted & saved.
}
Gui, Destroy
return


; ===== COPY ANIME FROM FILE =====
CopyAnime:
ifNotExist, %animeFile%
{
    MsgBox, 48, Error, File not found: %animeFile%
    return
}

animeList := []
Gui, New
Gui, +Resize
Gui, Color, 000000
Gui, Font, c00FF00 s15, Lucida Console
Gui, Add, Text,, Choose a title to decrypt & Search:
Gui, Font, s10

FileRead, rawList, %animeFile%
Loop, Parse, rawList, `n, `r
{
    line := Trim(A_LoopField)
    if (line != "")
    {
        decrypted := Decrypt3x2(line)
        animeList.Push(decrypted)
        Gui, Add, Radio, vRadio%A_Index%, %A_Index%. %decrypted%
    }
}

Gui, Add, Button, gCopySelectedAnime, Search Selected Title
Gui, Show,, DECRYPTED LIST

; --- Add the ? control ---
Gui, Font, cFFFFFF s14, Lucida Console
Gui, Add, Text, w22 h20 +gOpenHelp vHelpText hwndHelpHWND, ?
Gui, Font, c00FF00 s10, Lucida Console

; --- Move ? to top-right dynamically ---
Gui, +LastFound
WinGetPos,,, guiWidth, guiHeight, A
GuiControlGet, CtrlPos, Pos, HelpText
xPos := guiWidth - CtrlPosW - 5
yPos := 7.5
GuiControl, Move, HelpText, x%xPos% y%yPos%
return


; ===== COPY SELECTED ANIME =====
CopySelectedAnime:
Gui, Submit, NoHide
Loop, % animeList.MaxIndex()
{
    if (Radio%A_Index%)
    {
        chromeanimesan := animeList[A_Index]
        chromeanimesan := EncodeMF(chromeanimesan)
        chromeanimeonisan := "https://google.com/search?q=" . chromeanimesan
        Run, chrome.exe --guest "%chromeanimeonisan%"
        MsgBox, 64, Info, Launched query %chromeanimesan%
        Gui, Destroy
        return
    }
}
MsgBox, 48, None Selected, Choose a title first.
return

; ===== LAUNCH CHATGPT =====
Chromes:
QueryNormal := "Enter Query"
LinkGuest := "Enter Link"
QueryGuest := "Enter Query"
YTsearch := "YT Search"
Gui, chrome:New
Gui, chrome:Color, 000000
Gui, chrome:Font, c00FF00 s15, Lucida Console
Gui, chrome:Add, Text,, What do i do:
Gui, chrome:Font, c000000 s10
Gui, chrome:Add, Edit, vQueryNormal w300 h20, Enter Query
Gui, chrome:Font, c00FF00
; --- CUSTOM SITES: ListView (black bg, green text, VScroll allowed, HScroll enabled) ---
Gui, chrome:Color, 000000                      ; ensure GUI BG is black
Gui, chrome:Font, c00FF00 s13, Lucida Console  ; your green font style
Gui, chrome:Add, ListView, w300 h200 Checked HScroll -Grid Background000000 vLV_CustomSites, Site
LV_ModifyCol(1, 280)

if FileExist(customSitesFile)
{
    FileRead, rawSites, %customSitesFile%
    siteIndex := 0
    Loop, Parse, rawSites, `n, `r
    {
        site := Trim(A_LoopField)
        if (site != "")
        {
            siteIndex++

            ; keep original full URL for launching
            customSiteTemp := site

            ; build display name: remove scheme + www, then drop path AFTER domain,
            ; then extract the main domain (second-level domain) for display
            display := site
            StringReplace, display, display, https://,, All
            StringReplace, display, display, http://,, All
            StringReplace, display, display, www.,, All

            ; remove path after the domain (everything from first slash onward)
            display := RegExReplace(display, "/.*")

            ; extract main domain (ignore subdomains) => "example" from "sub.example.com"
            display := RegExReplace(display, "^(?:[^.]+\.)*([^.]+)\.[^.]+$", "$1")

            ; Add to ListView and store the original URL keyed by ListView row
            newRow := LV_Add("", display)
            customSite%newRow% := customSiteTemp
        }
    }
}

; --- GUEST SITES: ListView (keep path after domain, just remove scheme/www) ---
if (thatistrue)
{
    Gui, chrome:Font, c000000 s10
    Gui, chrome:Add, Edit, vQueryGuest w300 h20, Enter Query
    Gui, chrome:Add, Edit, vYTsearch w300 h20, YT Search
    Gui, chrome:Add, Edit, vLinkGuest w300 h20, Enter Link
    Gui, chrome:Font, c00FF00
    Gui, chrome:Font, c00FF00 s13, Lucida Console
    Gui, chrome:Add, ListView, w300 h200 Checked HScroll -Grid Background000000 vLV_GuestSites, Site
    LV_ModifyCol(1, 2000)

    if FileExist(guestSitesFile)
    {
        FileRead, rawSites, %guestSitesFile%
        siteIndex := 0
        Loop, Parse, rawSites, `n, `r
        {
            site := Trim(A_LoopField)
            if (site != "")
            {
                siteIndex++
    
                ; keep original full URL for launching
                guestSiteTemp := site
    
                ; try to extract human-readable title + chapter
                ExtractTitleChapter(site, parsedTitle, parsedChapter)
                if StrLen(parsedTitle)
                {
                    display := parsedTitle
                    if (StrLen(parsedChapter))
                        display := display . " - " . parsedChapter
                }
                else
                {
                    ; fallback: remove scheme + www if no title found
                    display := site
                    StringReplace, display, display, https://,, All
                    StringReplace, display, display, http://,, All
                    StringReplace, display, display, www.,, All
                }

                newRow := LV_Add("", display)
                guestSite%newRow% := guestSiteTemp
            }
        }
    }
}
Gui, chrome:Font, s10
Gui, chrome:Add, Button, gMultiLaunch, GOOOO
Gui, chrome:Add, Button, gbye, Exit
Gui, chrome:Add, Button, gThat, That
Gui, chrome:Show,, Custom Chromes

; --- Add the ? control ---
Gui, chrome:Font, cFFFFFF s14, Lucida Console
Gui, chrome:Add, Text, w22 h20 +gOpenHelp vHelpText hwndHelpHWND, ?
Gui, chrome:Font, c00FF00 s10, Lucida Console

; --- Show GUI once ---
Gui, chrome:Show,, Chromes

; --- Move ? to top-right dynamically ---
Gui, +LastFound
WinGetPos,,, guiWidth, guiHeight, A   ; get GUI client size including borders
GuiControlGet, CtrlPos, Pos, HelpText
xPos := guiWidth - CtrlPosW - 5  ; 10 px margin from right
yPos := 7.5                         ; 10 px from top
GuiControl, Move, HelpText, x%xPos% y%yPos%
return

EncodeMF(scuffedStr) {
    sillySauce := ""
    Loop, Parse, scuffedStr
    {
        lilChar := A_LoopField
        if (lilChar = " ") {
            sillySauce .= "+"
        } else if (lilChar ~= "^[A-Za-z0-9._~-]$") {
            sillySauce .= lilChar
        } else {
            sillySauce .= "%" . Format("{:02X}", Ord(lilChar))
        }
    }
    return sillySauce
}
; ----------------------------
; ExtractTitleChapter(url, ByRef outTitle, ByRef outChapter)
; AHK v1 compatible, robust for messy manga URLs
; ----------------------------
ExtractTitleChapter(url, ByRef outTitle, ByRef outChapter) {
    local s, parts, idx, part, i, j, m, t, candidate, keysStr, key, low, nxt, p, lastSeg

    ; ---- normalize input ----
    s := url
    StringReplace, s, s, https://, , All
    StringReplace, s, s, http://, , All
    StringReplace, s, s, www., , All
    s := RegExReplace(s, "\?.*$")   ; strip query
    s := RegExReplace(s, "#.*$")    ; strip fragment

    ; ---- split path into parts (includes domain as first part) ----
    parts := []
    idx := 0
    Loop, Parse, s, /
    {
        if (A_LoopField != "")
        {
            idx++
            parts[idx] := A_LoopField
            lastSeg := A_LoopField
        }
    }

    outTitle := ""
    outChapter := ""

    ; ---- chapter regex (case-insensitive) ----
    chapterRE := "i)\b(?:chapter|chap|ch)[-_ ]?(\d+(?:[-_.]\d+)*)\b"

    ; ---- 1) scan from end for chapter token ----
    Loop, % idx
    {
        i := idx - A_Index + 1
        part := parts[i]
        if RegExMatch(part, chapterRE, m) {
            ; m1 holds the captured number part
            outChapter := "ch " . m1

            ; remove trailing chapter segment from same slug (if present)
            t := RegExReplace(part, "i)-?(?:chapter|chap|ch)[-_. ]?\d[\w-]*$")
            t := Trim(t, "-_ ")

            ; if leftover is empty or numeric or looks like UUID, search earlier parts
            if (t = "" or RegExMatch(t, "^\d+$") or RegExMatch(t, "i)^[0-9a-f]{8,}(-[0-9a-f]{4,})+")) {
                ; search backwards for first part that contains letters
                Loop, % i-1
                {
                    j := i - A_Index
                    candidate := parts[j]
                    if RegExMatch(candidate, "[A-Za-z]") {
                        outTitle := candidate
                        break
                    }
                }
            } else {
                outTitle := t
            }
            break
        }
    }

    ; ---- 2) if no title yet, look for common markers like /manga/ /title/ /reader/ ----
    if (outTitle = "") {
        keysStr := "manga,title,reader,series,comic,book,novel"
        Loop, Parse, keysStr, `,
        {
            key := A_LoopField
            Loop, % idx
            {
                p := parts[A_Index]
                StringLower, low, p
                if (low = key) {
                    if (A_Index+1 <= idx)
                        nxt := parts[A_Index+1]
                    else
                        nxt := ""
                    ; skip UUID-like segment if encountered
                    if RegExMatch(nxt, "i)^[0-9a-f]{8,}(-[0-9a-f]{4,})+") and (A_Index+2 <= idx)
                        nxt := parts[A_Index+2]
                    if (nxt != "") {
                        outTitle := nxt
                        break 2
                    }
                }
            }
        }
    }

    ; ---- 3) fallback: first segment that contains a letter and isn't UUID ----
    if (outTitle = "") {
        Loop, % idx
        {
            p := parts[A_Index]
            if RegExMatch(p, "[A-Za-z]") and !RegExMatch(p, "i)^[0-9a-f]{8,}(-[0-9a-f]{4,})+") {
                outTitle := p
                break
            }
        }
    }

    ; ---- 4) final universal fallback: show path after domain ----
    if (outTitle = "")
    {
        ; split the URL by /
        Loop, Parse, s, /
        {
            ; skip the first part (domain)
            if (A_Index = 1)
                continue
            if (A_LoopField != "")
            {
                outTitle := A_LoopField
                break
            }
        }

        ; if even that fails, fallback to domain itself
        if (outTitle = "")
        {
            Loop, Parse, s, /
            {
                if (A_LoopField != "")
                {
                    outTitle := A_LoopField
                    break
                }
            }
        }
    }

    ; ---- 5) cleanup title text ----
    if (outTitle != "") {
        outTitle := RegExReplace(outTitle, "i)^\d+-[a-z]{2}-") ; remove numeric-lang prefix like 247508-en-
        StringReplace, outTitle, outTitle, -, %A_Space%, All
        StringReplace, outTitle, outTitle, _, %A_Space%, All
        outTitle := Trim(outTitle)
        if (StrLen(m1))
            outTitle := outTitle . m1
    }

    ; outChapter already normalized like "ch 44" or empty
}


That:
if (!thatistrue) {
    Gui, New
    Gui, +AlwaysOnTop +ToolWindow +SysMenu
    Gui, Color, 000000
    Gui, Font, c00FF00 s10, Lucida Console
    Gui, Add, Text,, Enter Access Key:
    Gui, Font, c000000 ; black font
    Gui, Add, Edit, vuserInputs Password w220 hwndAuthPwdField
    Gui, Font, c00FF00 ; back to green for rest of GUI
    Gui, Add, Checkbox, vShowPass1 gToggleShowAuthPass, Show Password
    Gui, Add, Button, gCheckPasswords, Authenticate
    Gui, Show,, ACCESS PORTAL
} else {
    if (thatistrue) {
        thatistrue := False
    } else {
        thatistrue :=True
    }
    Gui, chrome:Destroy
    Sleep, 50
    Gosub, Chromes

}
return

CheckPasswords:
Gui, Submit
userInputs := Trim(userInputs)
correctPass := Trim(correctPass)
StringLower, userInputs, userInputs
StringLower, correctPass, correctPass

if (userInputs = correctPass) {
    if (thatistrue) {
        thatistrue := False
    } else {
        thatistrue := True
    }
    Gui, chrome:Destroy
    Sleep, 50
    Gosub, Chromes
} else {
    Msgbox, 16, Wrong Pass, Who are you?...Go away
}
return

MultiLaunch:
Gui, Submit

; ---- normal query (profile) ----
if (QueryNormal != "Enter Query") {
    bakedStr := EncodeMF(QueryNormal)
    sillyURL := "https://google.com/search?q=" . bakedStr
    Run, chrome.exe --profile-directory="Profile %configData4%" "%sillyURL%"
}

; ---- handle custom sites via ListView checked rows ----
Gui, chrome:ListView, LV_CustomSites
Row := 0
Loop
{
    Row := LV_GetNext(Row, "C") ; next checked row
    if (!Row)
        break
    LV_GetText(display, Row, 1)        ; optional human text
    site := customSite%Row%            ; original full URL we stored earlier
    if (site != "")
        Run, chrome.exe --profile-directory="Profile %configData4%" "%site%"
}

; ---- guest search + youtube search (guest profile) ----
if (QueryGuest != "Enter Query") {
    bakedStrs := EncodeMF(QueryGuest)
    sillyURLs := "https://google.com/search?q=" . bakedStrs
    Run, chrome.exe --guest "%sillyURLs%"
}
if (LinkGuest != "Enter Link") {
    Run, chrome.exe --guest "%LinkGuest%"
}
if (YTsearch != "YT Search") {
    YTstrs := EncodeMF(YTsearch)
    YtURLS := "https://youtube.com/results?search_query=" . YTstrs
    Run, chrome.exe --guest "%YtURLS%"
}

; ---- handle guest sites via ListView checked rows ----
Gui, chrome:ListView, LV_GuestSites
Row := 0
Loop
{
    Row := LV_GetNext(Row, "C")
    if (!Row)
        break
    LV_GetText(display, Row, 1)
    site := guestSite%Row%
    if (site != "")
        Run, chrome.exe --guest "%site%"
}


return

bye:
Gui, Destroy
return
; ===== EXIT =====
ExitApp:
ExitApp
return
