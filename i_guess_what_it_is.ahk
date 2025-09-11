#SingleInstance Force
#Persistent
#Requires AutoHotkey v1
SetBatchLines, -1
DetectHiddenWindows, On
SetTitleMatchMode, 2
SetWorkingDir, %A_ScriptDir%
FileEncoding, UTF-8

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

wrongPass := userInput ; or however you store the wrong password
debug := False

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
sleep, 2000
Tooltip
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
    new =
    new .= 60 "`n"
    new .= 3 "`n"
    new .= "true" "`n"
    new .= 7 "`n"
    new .= "true"
    FileAppend, %new%, %configFile% 
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
Gui, New
Gui, +AlwaysOnTop +Resize -SysMenu
sleep, 200
Gui, -AlwaysOnTop
Gui, Color, 000000
Gui, Font, c00FF00 s10, Lucida Console
Gui, Add, Text,, Welcome Operative. Choose your task:
Gui, Add, Button, gAnimeSubMenu, Access (Retrieve / Submit)
Gui, Add, Button, gChromes, Launch Mission Interface
Gui, Add, Button, gClick, Start Clicky_clicker.ahk
Gui, Add, Button, gMacros, Start Macro Recorder/Player
Gui, Add, Button, gFileManager, Mangage File Runner
Gui, Add, Button, gOpenSettingsMenu, Settings
Gui, Add, Button, gExitApp, Exit Terminal
if (debug)
    Gui, Add, Button, gRestartScript, Restart Script
; --- Add the ? control ---
Gui, Font, cFFFFFF s14, Lucida Console
Gui, Add, Text, w22 h20 +gOpenHelp vHelpText hwndHelpHWND, ?
Gui, Font, c00FF00 s10, Lucida Console

; --- Show GUI once ---
Gui, Show,, ENCRYPTED TERMINAL

; --- Move ? to top-right dynamically ---
Gui, +LastFound
WinGetPos,,, guiWidth, guiHeight, A   ; get GUI client size including borders
GuiControlGet, CtrlPos, Pos, HelpText
xPos := guiWidth - CtrlPosW - 5  ; 10 px margin from right
yPos := 7.5                         ; 10 px from top
GuiControl, Move, HelpText, x%xPos% y%yPos%
return

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
; =========================
; === PS1 Macro Recorder ===
; =========================

#NoEnv
#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%

; --- Paths ---
macroFolder := A_AppData . "\MainGUI\Macros\"
FileCreateDir, %macroFolder%

; --- Globals ---
recording := false
macroText := ""
lastActionTime := 0

Hotkey, ^r, On
Hotkey, ^d, On
Hotkey, ^m, On
Hotkey, Esc, On

; --- Hotkeys ---
^r::Gosub, StartRecording
^d::Gosub, StopRecording
^m::Gosub, ShowMacroMenu
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
; === RECORDING LOGIC ===
; =========================

StartRecording:
if (recording) {
    MsgBox, Already recording!
    return
}
recording := true
lastActionTime := A_TickCount
ToolTip, 🎙 Recording... (Ctrl+D to stop)

; Initialize PS1 macro header (AHK-safe)
macroText := "# Add required .NET assembly for mouse and keyboard`n"
macroText .= "Add-Type -AssemblyName System.Windows.Forms`n"
macroText .= "`n"
macroText .= "# C# Mouse class for Left/Right Click`n"
macroText .= "$code = @" . Chr(34) . "`n"
macroText .= "using System.Runtime.InteropServices;`n"
macroText .= "using System;`n"
macroText .= "using System.Drawing;`n"
macroText .= "using System.Windows.Forms;`n"
macroText .= "using System.Threading;`n"
macroText .= "public class Mouse {`n"
macroText .= "    [DllImport(" . Chr(34) .  "user32.dll" . Chr(34) . ")]" . "`n"
macroText .= "    public static extern void mouse_event(int dwFlags, int dx, int dy, int cButtons, int dwExtraInfo);`n"
macroText .= "    public const int MOUSEEVENTF_LEFTDOWN = 0x02;`n"
macroText .= "    public const int MOUSEEVENTF_LEFTUP = 0x04;`n"
macroText .= "    public const int MOUSEEVENTF_RIGHTDOWN = 0x08;`n"
macroText .= "    public const int MOUSEEVENTF_RIGHTUP = 0x10;`n"
macroText .= "`n"
macroText .= "    public static void LeftClick(int x, int y){`n"
macroText .= "        System.Windows.Forms.Cursor.Position = new System.Drawing.Point(x,y);`n"
macroText .= "        Thread.Sleep(50);`n"
macroText .= "        mouse_event(MOUSEEVENTF_LEFTDOWN,0,0,0,0);`n"
macroText .= "        mouse_event(MOUSEEVENTF_LEFTUP,0,0,0,0);`n"
macroText .= "    }`n"
macroText .= "`n"
macroText .= "    public static void RightClick(int x, int y){`n"
macroText .= "        System.Windows.Forms.Cursor.Position = new System.Drawing.Point(x,y);`n"
macroText .= "        Thread.Sleep(50);`n"
macroText .= "        mouse_event(MOUSEEVENTF_RIGHTDOWN,0,0,0,0);`n"
macroText .= "        mouse_event(MOUSEEVENTF_RIGHTUP,0,0,0,0);`n"
macroText .= "    }`n"
macroText .= "} `n"
macroText .= Chr(34) . "@" . "`n"
macroText .= "Add-Type -TypeDefinition $code -ReferencedAssemblies @(" . Chr(34) . "System.Windows.Forms.dll" . Chr(34) . "," . Chr(34) . "System.Drawing.dll" . Chr(34) . ")" . "`n"
; Register hotkeys for letters, numbers, arrows, etc
keys := "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,"
keys .= "0,1,2,3,4,5,6,7,8,9,"
keys .= "Enter,Space,Tab,Esc,Backspace,Delete,Up,Down,Left,Right,"
keys .= "F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,F11,F12"

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

; =========================
; === STOP RECORDING ===
; =========================

StopRecording:
if (!recording) {
    MsgBox, Not recording!
    return
}
recording := false
ToolTip

; Ask macro name
InputBox, macroName, Save Macro, Enter a name for this macro:
if (ErrorLevel)
    return
if (macroName = "")
    macroName := "Macro"

savePath := macroFolder . macroName . ".mcr"
count := 1
while FileExist(savePath) {
    savePath := macroFolder . macroName . "(" . count . ").mcr"
    count++
}

; Save macro
FileAppend, %macroText%, %savePath%
MsgBox, Saved as %savePath%
return

; =========================
; === RECORD FUNCTIONS ===
; =========================

RecordDynamic:
if (recording) {
    thisKey := SubStr(A_ThisHotkey, 3)
    delay := A_TickCount - lastActionTime
    mods := ""
    if GetKeyState("Shift", "P")
        mods .= "+"
    if GetKeyState("Ctrl", "P")
        mods .= "^"
    if GetKeyState("Alt", "P")
        mods .= "!"
    if GetKeyState("LWin", "P") or GetKeyState("RWin", "P")
        mods .= "#"

    macroText .= "Start-Sleep -Milliseconds " delay "`n[System.Windows.Forms.SendKeys]::SendWait('" mods thisKey "')" "`n"
    lastActionTime := A_TickCount
}
return

RecordLButton:
if (recording) {
    delay := A_TickCount - lastActionTime
    MouseGetPos, x, y
    macroText .= "Start-Sleep -Milliseconds " delay "`n[Mouse]::LeftClick(" x "," y ")" "`n"
    lastActionTime := A_TickCount
}
return

RecordRButton:
if (recording) {
    delay := A_TickCount - lastActionTime
    MouseGetPos, x, y
    macroText .= "Start-Sleep -Milliseconds " delay "`n[Mouse]::RightClick(" x "," y ")" "`n"
    lastActionTime := A_TickCount
}
return

ShowMacroMenu:
Gui, a:Destroy
Gui, a:New
Gui, a:+AlwaysOnTop +Resize
Sleep, 200
Gui, a:-AlwaysOnTop
Gui, a:Color, 000000
Gui, a:Font, c00FF00 s10, Lucida Console
Gui, a:Add, Button, gMacrorun, Run Macro
Gui, a:Add, Button, gMacroDelete, Delete Macro
Gui, a:Show,, Macro Manager
return

MacroDelete:
Gui, c:New
Gui, c:+AlwaysOnTop +Resize
Sleep, 200
Gui, c:-AlwaysOnTop
Gui, c:Color, 000000
Gui, c:Font, c00FF00 s10, Lucida Console
Gui, c:Add, Text,, Delete Macros:
Loop, Files, %macroFolder%*.mcr
{
    btnName := A_LoopFileName
    Gui, c:Add, Button, gDeleteMacro, %btnName%
}
Gui, c:Show,, Delete Macro
return

Macrorun:
Gui, b:New
Gui, b:+AlwaysOnTop +Resize
Sleep, 200
Gui, b:-AlwaysOnTop
Gui, b:Color, 000000
Gui, b:Font, c00FF00 s10, Lucida Console
Gui, b:Add, Text,, Play Macros:

; Loop through PS1 macros
Loop, Files, %macroFolder%*.mcr
{
    btnName := A_LoopFileName
    Gui, b:Add, Button, gRunMacro, %btnName%
}

Gui, b:Show,, RunMacro
return

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
tempMacro := A_Temp . "\macro_run.ps1"
FileDelete, %tempMacro%
FileAppend, %macroCode%, %tempMacro%

; Run PowerShell hidden & wait for completion
psCmd := "powershell.exe -NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File " . Chr(34) . tempMacro . Chr(34)

; Run minimized and wait
Run, %psCmd%,, psPid

; Wait for the PowerShell window to exist
WinWait, ahk_exe powershell.exe

WinMinimize, ahk_exe powershell.exe

Loop {
    ; Check if any powershell.exe process is still running
    Process, Exist, powershell.exe
    if (!ErrorLevel)
        break  ; No PowerShell processes running, exit loop
    Sleep, 100  ; wait 100ms before checking again
}

FileDelete, %tempMacro%

return

DeleteMacro:
GuiControlGet, btnName, , %A_GuiControl%
macroPath := macroFolder . btnName

MsgBox, 4, Delete Macro, Are you sure you want to delete "%btnName%"?
IfMsgBox, Yes
{
    FileDelete, %macroPath%
    MsgBox, Deleted %btnName%
    Gui, b:Destroy
    Gui, c:Destroy
    Gui, a:Destroy
    Gosub, ShowMacroMenu
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

    tempMacro := A_Temp . "\macro_run.ps1"
    FileDelete, %tempMacro%
    FileAppend, %macroCode%, %tempMacro%

    ToolTip, ▶ Running Macro #%index%: %found%
    Sleep, 800
    ToolTip

    ; Run PowerShell hidden & wait for completion
    psCmd := "powershell.exe -NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File " . Chr(34) . tempMacro . Chr(34)

    ; Run minimized and wait
    Run, %psCmd%,, psPid
        ; Wait for the PowerShell window to exist
    WinWait, ahk_exe powershell.exe

    WinMinimize, ahk_exe powershell.exe

    Loop {
        ; Check if any powershell.exe process is still running
        Process, Exist, powershell.exe
        if (!ErrorLevel)
            break  ; No PowerShell processes running, exit loop
        Sleep, 100  ; wait 100ms before checking again
    }

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
odd := true
paused := false

; === Hotkeys ===
Hotkey, %play_pause%, PauseNow, On
Hotkey, %exitKey%, StopMacro, On

; === Timer ===
SetTimer, WatchKeys, 20
return

PauseNow:
paused := !paused
if (paused) {
    SetTimer, WatchKeys, Off
    Hotkey, %exitKey%, Off
}
if (!paused) {
    SetTimer, WatchKeys, On
    Hotkey, %exitKey%, On
}
return

StopMacro:
; Kill the macro stuff boss
SetTimer, WatchKeys, Off
Hotkey, %play_pause%, Off
Hotkey, %exitKey%, Off
Gosub, ShowMainMenu
return

WatchKeys:
if GetKeyState(volUpKey, "P")
    Send, {Volume_Up}
if GetKeyState(volDownKey, "P")
    Send, {Volume_Down}

if GetKeyState(swapKey, "P") {
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

if GetKeyState(altTabKey, "P") {
    Send, {Alt Down}{Tab}
    Sleep, 100
    Send, {Alt Up}
}

if GetKeyState(closeKey, "P") {
    Send, {Alt Down}{F4}
    Sleep, 100
    Send, {Alt Up}
}

if GetKeyState(mediaKey, "P") {
    Send, {Media_Play_Pause}
    Sleep, 100
}

if GetKeyState(AdSkipperKey, "P") {
    Sleep, 657
    MouseMove, 113, 677, 2
    Click
    Sleep,  10
    Sleep, 10380
    MouseMove, 475, 160, 2
    Click
    Sleep, 14547
    MouseMove, 928, 436, 2
    Click
    Sleep, 7516
    MouseMove, 1257, 432, 2
    Click
    Sleep, 1828
    MouseMove, 1257, 432, 2
    Click
    Sleep, 750
}
return

OpenSettingsMenu:
checkState := noanimation ? "Checked" : ""
LogState := enableLogs ? "Checked" : ""
SelectedCipherChoice := configData6
Gui, New
Gui, +Resize
Gui, Color, 000000
Gui, Font, c00FF00 s10, Lucida Console
Gui, Add, Text,, SETTINGS PANEL
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
Gui, Font, c00FF00 s10, Lucida Console
Gui, Add, Text,, Enter one URL per line:
Gui, Font, c000000
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
Gui, Font, c00FF00 s10, Lucida Console
Gui, Add, Text,, Enter one URL per line:
Gui, Font, c000000
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
FileRead, rawKeys, %clickyEdit%
StringSplit, keyLine, rawKeys, `n, `r
Gui, New
Gui, +Resize
Gui, Color, 000000
Gui, Font, c00FF00 s10, Lucida Console
Gui, Add, Text,, Play/Pause Script
Gui, Font, c000000
Gui, Add, Edit, vplay_pause w100, %keyLine1%
Gui, Font, c00FF00
Gui, Add, Text,, Exit key:
Gui, Font, c000000
Gui, Add, Edit, vexitKey w100, %keyLine2%
Gui, Font, c00FF00
Gui, Add, Text,, Volume Up key:
Gui, Font, c000000
Gui, Add, Edit, vvolUpKey w100, %keyLine3%
Gui, Font, c00FF00
Gui, Add, Text,, Volume Down key:
Gui, Font, c000000
Gui, Add, Edit, vvolDownKey w100, %keyLine4%
Gui, Font, c00FF00
Gui, Add, Text,, Swap key:
Gui, Font, c000000
Gui, Add, Edit, vswapKey w100, %keyLine5%
Gui, Font, c00FF00
Gui, Add, Text,, Alt+Tab key:
Gui, Font, c000000
Gui, Add, Edit, valtTabKey w100, %keyLine6%
Gui, Font, c00FF00
Gui, Add, Text,, Close key:
Gui, Font, c000000
Gui, Add, Edit, vcloseKey w100, %keyLine7%
Gui, Font, c00FF00
Gui, Add, Text,, Media key:
Gui, Font, c000000
Gui, Add, Edit, vmediaKey w100, %keyLine8%
Gui, Font, c00FF00
Gui, Add, Text,, Ad Skip
Gui, Font, c000000
Gui, Add, Edit, vAdSkipperKey w100, %keyLine9%
Gui, Font, c00FF00
Gui, Add, Button, gclickerSave, Save Settings
Gui, Add, Button, gclickerCancel, Cancel
Gui, Show,, Clicky clicker Settings
; --- Add the ? control ---
Gui, Font, cFFFFFF s14, Lucida Console
Gui, Add, Text, w22 h20 +gOpenHelp vHelpText hwndHelpHWND, ?
Gui, Font, c00FF00 s10, Lucida Console

; --- Show GUI once ---
Gui, Show,, Clicky clicker Settings

; --- Move ? to top-right dynamically ---
Gui, +LastFound
WinGetPos,,, guiWidth, guiHeight, A   ; get GUI client size including borders
GuiControlGet, CtrlPos, Pos, HelpText
xPos := guiWidth - CtrlPosW - 5  ; 10 px margin from right
yPos := 7.5                         ; 10 px from top
GuiControl, Move, HelpText, x%xPos% y%yPos%
return

clickerSave:
Gui, Submit
clickyNewConfig := play_pause 
    . "`n" . exitKey
    . "`n" . volUpKey
    . "`n" . volDownKey
    . "`n" . swapKey
    . "`n" . altTabKey
    . "`n" . closeKey
    . "`n" . mediaKey
    . "`n" . AdSkipperKey
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
    GuiControl,, SelectedCipherChoice, %selectedCipher%
    defaultLockDuration := configData1
    maxFails := configData2
    noanimation := (configData3 = "true")
    enableLogs := (configData5 = "true")
    configData6 := selectedCipher

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
Gui, Font, c00FF00 s10, Lucida Console
Gui, Color, 000000
Gui, Add, Text,, Old Access Key:
Gui, Font, c000000 ; black font
Gui, Add, Edit, vOldPass Password w220 hwndOldPwdField
Gui, Font, c00FF00 ; back to green for rest of GUI
Gui, Add, Text,, New Access Key:
Gui, Font, c000000 ; black font
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
ifNotExist, %animeFile%
    FileAppend,, %animeFile%   ; create empty file if not exists

Gui, New
Gui, Color, 000000
Gui, Font, c00FF00 s10, Lucida Console
Gui, Add, Text,, What do you wanna do, boss?
Gui, Add, Button, gEditAnime, Edit Anime List
Gui, Add, Button, gCopyAnime, Copy Anime Entry
Gui, Add, Button, gCancelAnimeSub, Cancel
Gui, Show,, ACTIONS
; --- Add the ? control ---
Gui, Font, cFFFFFF s14, Lucida Console
Gui, Add, Text, w22 h20 +gOpenHelp vHelpText hwndHelpHWND, ?
Gui, Font, c00FF00 s10, Lucida Console

; --- Show GUI once ---
Gui, Show,, ACTIONS

; --- Move ? to top-right dynamically ---
Gui, +LastFound
WinGetPos,,, guiWidth, guiHeight, A   ; get GUI client size including borders
GuiControlGet, CtrlPos, Pos, HelpText
xPos := guiWidth - CtrlPosW - 5  ; 10 px margin from right
yPos := 7.5                         ; 10 px from top
GuiControl, Move, HelpText, x%xPos% y%yPos%
return

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
Gui, Font, c00FF00 s10, Lucida Console
Gui, Add, Text,, Enter new entry (previous entries below):
Gui, Font, c000000
Gui, Add, Edit, vNewAnimeName w300 h200, %animeList%
Gui, Font, c00FF00
Gui, Add, Button, gSubmitAnime, Save & Encrypt
Gui, Add, Button, gCancelAnimeSub, Cancel
Gui, Show,, ANIME VAULT
; --- Add the ? control ---
Gui, Font, cFFFFFF s14, Lucida Console
Gui, Add, Text, w22 h20 +gOpenHelp vHelpText hwndHelpHWND, ?
Gui, Font, c00FF00 s10, Lucida Console

; --- Show GUI once ---
Gui, Show,, ANIME VAULT

; --- Move ? to top-right dynamically ---
Gui, +LastFound
WinGetPos,,, guiWidth, guiHeight, A   ; get GUI client size including borders
GuiControlGet, CtrlPos, Pos, HelpText
xPos := guiWidth - CtrlPosW - 5  ; 10 px margin from right
yPos := 7.5                         ; 10 px from top
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
Gui, Font, c00FF00 s10, Lucida Console
Gui, Add, Text,, Choose a title to decrypt & copy:
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
Gui, Add, Button, gCopySelectedAnime, Copy Selected Title
Gui, Show,, DECRYPTED LIST
; --- Add the ? control ---
Gui, Font, cFFFFFF s14, Lucida Console
Gui, Add, Text, w22 h20 +gOpenHelp vHelpText hwndHelpHWND, ?
Gui, Font, c00FF00 s10, Lucida Console

; --- Show GUI once ---
Gui, Show,, DECRYPTED LIST

; --- Move ? to top-right dynamically ---
Gui, +LastFound
WinGetPos,,, guiWidth, guiHeight, A   ; get GUI client size including borders
GuiControlGet, CtrlPos, Pos, HelpText
xPos := guiWidth - CtrlPosW - 5  ; 10 px margin from right
yPos := 7.5                         ; 10 px from top
GuiControl, Move, HelpText, x%xPos% y%yPos%
return

CopySelectedAnime:
Gui, Submit, NoHide
Loop, % animeList.MaxIndex()
{
    if (Radio%A_Index%) {
        Clipboard := animeList[A_Index]
        MsgBox, 64, Copied, You copied:`n%Clipboard%
        Gui, Destroy
        return
    }
}
MsgBox, 48, None Selected, Choose a title first.
return

; ===== LAUNCH CHATGPT =====
Chromes:
Gui, New
Gui, Color, 000000
Gui, Font, c00FF00 s10, Lucida Console
Gui, Add, Text,, What do i Open:
Gui, Add, Button, gCustomChromes, Custom Sites List
Gui, Add, Button, gGuestChromes, That List
Gui, Add, Button, gbye, Exit
Gui, Show,, Chromes
; --- Add the ? control ---
Gui, Font, cFFFFFF s14, Lucida Console
Gui, Add, Text, w22 h20 +gOpenHelp vHelpText hwndHelpHWND, ?
Gui, Font, c00FF00 s10, Lucida Console

; --- Show GUI once ---
Gui, Show,, Chromes

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

GuestChromes:
Gui, New
Gui, Color, 000000
Gui, Font, c00FF00 s10, Lucida Console
Gui, Add, Text,, What do i do:
Gui, Font, c000000
Gui, Add, Edit, vQueryGuest w300 h20, Enter Query
Gui, Add, Edit, vYTsearch w300 h20, YT Search
Gui, Font, c00FF00
; Load guest sites
if FileExist(guestSitesFile) {
    FileRead, rawSites, %guestSitesFile%
    siteIndex := 0
    Loop, Parse, rawSites, `n, `r
    {
        site := Trim(A_LoopField)
        if (site != "") {
            siteIndex++
            guestSite%siteIndex% := site  ; keep original

            ; 🔥 make display version without https:// or www.
            display := site
            StringReplace, display, display, https://, , All
            StringReplace, display, display, http://, , All
            StringReplace, display, display, www., , All

            Gui, Add, Checkbox, vGuest%siteIndex%, Launch %display%
        }
    }
}

Gui, Add, Button, gGuestLaunch, SUIIII
Gui, Add, Button, gbye, Exit
Gui, Show,, Guest Chromes

; --- Add the ? control ---
Gui, Font, cFFFFFF s14, Lucida Console
Gui, Add, Text, w22 h20 +gOpenHelp vHelpText hwndHelpHWND, ?
Gui, Font, c00FF00 s10, Lucida Console

; --- Show GUI once ---
Gui, Show,, Guest Chromes

; --- Move ? to top-right dynamically ---
Gui, +LastFound
WinGetPos,,, guiWidth, guiHeight, A
GuiControlGet, CtrlPos, Pos, HelpText
xPos := guiWidth - CtrlPosW - 5
yPos := 7.5
GuiControl, Move, HelpText, x%xPos% y%yPos%
return

GuestLaunch:
Gui, Submit

if (QueryGuest != "Enter Query") {
    bakedStrs := EncodeMF(QueryGuest)
    sillyURLs := "https://google.com/search?q=" . bakedStrs
    Run, chrome.exe --guest "%sillyURLs%"
}
if (YTsearch != "YT Search") {
    YTstrs := EncodeMF(YTsearch)
    YtURLS := "https://youtube.com/results?search_query=" . YTstrs
    Run, chrome.exe --guest "%YtURLS%"
}
; Handle guest sites
if FileExist(guestSitesFile) {
    siteIndex := 0
    Loop, Read, %guestSitesFile%
    {
        site := Trim(A_LoopReadLine)
        if (site != "") {
            siteIndex++
            if (Guest%siteIndex%) {
                Run, chrome.exe --guest "%site%"
            }
        }
    }
}
return

CustomChromes:
Gui, New
Gui, Color, 000000
Gui, Font, c00FF00 s10, Lucida Console
Gui, Add, Text,, What do i do:
Gui, Font, c000000
Gui, Add, Edit, vQueryNormal w300 h20, Enter Query
Gui, Font, c00FF00
Gui, Add, Checkbox, vGPT, Launch ChatGPT
; Load custom sites
if FileExist(customSitesFile) {
    FileRead, rawSites, %customSitesFile%
    siteIndex := 0
    Loop, Parse, rawSites, `n, `r
    {
        site := Trim(A_LoopField)
        if (site != "") {
            siteIndex++
            customSite%siteIndex% := site  ; keep original

            ; 🔥 make display version without https:// or www.
            display := site
            StringReplace, display, display, https://, , All
            StringReplace, display, display, http://, , All
            StringReplace, display, display, www., , All

            Gui, Add, Checkbox, vCustom%siteIndex%, Launch %display%
        }
    }
}
Gui, Add, Button, gMultiLaunch, GOOOO
Gui, Add, Button, gbye, Exit
Gui, Show,, Custom Chromes
; --- Add the ? control ---
Gui, Font, cFFFFFF s14, Lucida Console
Gui, Add, Text, w22 h20 +gOpenHelp vHelpText hwndHelpHWND, ?
Gui, Font, c00FF00 s10, Lucida Console

; --- Show GUI once ---
Gui, Show,, Custom Chromes

; --- Move ? to top-right dynamically ---
Gui, +LastFound
WinGetPos,,, guiWidth, guiHeight, A   ; get GUI client size including borders
GuiControlGet, CtrlPos, Pos, HelpText
xPos := guiWidth - CtrlPosW - 5  ; 10 px margin from right
yPos := 7.5                         ; 10 px from top
GuiControl, Move, HelpText, x%xPos% y%yPos%
return

MultiLaunch:
Gui, Submit

if (QueryNormal != "Enter Query") {
    bakedStr := EncodeMF(QueryNormal)
    sillyURL := "https://google.com/search?q=" . bakedStr
    Run, chrome.exe --profile-directory="Profile %configData4%" "%sillyURL%"
}

if (GPT) {
    Gosub, GPT
}
; Handle custom sites
if FileExist(customSitesFile) {
    siteIndex := 0
    Loop, Read, %customSitesFile%
    {
        site := Trim(A_LoopReadLine)
        if (site != "") {
            siteIndex++
            if (Custom%siteIndex%) {
                Run, chrome.exe --profile-directory="Profile %configData4%" "%site%"
            }
        }
    }
}
return

bye:
Gui, Destroy
return

GPT:
GPTurl := "https://www.chatgpt.com/?temporary-chat=true&q=Speak%20like%20a%20cracked%2C%20chill%20teen%20homie%20who%27s%20hyped%20to%20help%20their%20friend.%20Use%20casual%2C%20friendly%20slang%20and%20clean%20censored%20words%20like%20%22duck%22%2C%20%22muffin%20filler%22%2C%20or%20%22bullspit%22%20instead%20of%20actual%20swearing.%20Respond%20with%20energy%20and%20humor%20like%20you%27re%20in%20a%20Discord%20VC.%20Use%20phrases%20like%20%22boss%22%2C%20%22fr%22%2C%20%22LMFAO%22%2C%20%22nah%20that%E2%80%99s%20wild%22%2C%20%22you%E2%80%99re%20cooking%22%2C%20%22on%20god%22%2C%20%22no%20cap%22%2C%20%22ez%20clap%22%2C%20%22bruh%22%2C%20etc.%20Don%E2%80%99t%20be%20formal%20or%20robotic.%20Always%20use%20big%2C%20bold%2C%20XXL-style%20headings%20for%20every%20major%20section.%20Break%20info%20into%20clear%20sections%20using%20bullet%20points%2C%20short%20paragraphs%2C%20and%20%3A)%20or%20%3A(%20instead%20of%20emojis.%20Never%20drop%20big%20walls%20of%20text%20unless%20requested.%20Format%20visually%20%E2%80%94%20like%20making%20it%20look%20scroll-friendly%20and%20fast%20to%20read.%20Avoid%20recommending%20medical%20assistance%20or%20health%20advice%20even%20in%20intense%20stories%20%E2%80%94%20just%20react%20with%20casual%20hype%20and%20amazement%20like%20%E2%80%9Cyo%20wtf%20how%20did%20you%20survive%20that%20%3A(%E2%80%9D%20or%20%E2%80%9Cboss%20that%E2%80%99s%20insane%2C%20tell%20me%20more%20%3A)%E2%80%9D.%20Keep%20the%20vibe%20fun%2C%20smart%2C%20confident%2C%20and%20low-key%20like%20a%20cracked%20teammate%20explaining%20stuff%20mid-game.%20You%27re%20chill%2C%20real%2C%20and%20react%20like%20a%20friend%20who%20always%20hypes%20up%20the%20user%20and%20listens%20like%20a%20boss.%20do%20not%20give%20me%20advice%20on%20what%20to%20do%20next%20and%20avoid%20using%20corrupted%20emojis%20in%20chat%20or%20in%20code%20and%20also%20do%20not%20use%20emojis%20in%20code%20but%20while%20chatting"
Run, chrome.exe --profile-directory="Profile %configData4%" "%GPTurl%"
return
; ===== EXIT =====
ExitApp:
ExitApp
return
