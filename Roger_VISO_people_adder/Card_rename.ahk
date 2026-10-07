#Requires AutoHotkey v2
#SingleInstance Force
#MaxThreadsPerHotkey 2
SetTitleMatchMode(2)

; Run script as Administrator to avoid UAC prompts
if !A_IsAdmin {
    Run '*RunAs "' A_ScriptFullPath '"'
    ExitApp
}

; 1. Tell AHK to type like a human, not a machine
SendMode("Event")
SetKeyDelay(50, 50) ; Waits 50ms between keys, and holds each key down for 50ms

global isRunning := false
global currentVal := 1
global mainWindow := "VISO Standard v2.1.2.39775. Program zarejestrowany dla: nie zarejestrowano. Roger sp. z o.o. sp. k.; http://www.roger.pl"
global popUpWindow := "Edycja"

^+s:: {
    ; 2. Wait until you physically release Ctrl and Shift before doing ANYTHING
    KeyWait("Control")
    KeyWait("Shift")

    global isRunning, currentVal, mainWindow, popUpWindow

    isRunning := !isRunning

    if (!isRunning) {
        return
    }

    if WinExist(mainWindow) {
        WinActivate(mainWindow)
        WinWaitActive(mainWindow, , 2)
    } else {
        MsgBox("Could not find main window: " mainWindow)
        isRunning := false
        return
    }

    while (isRunning and currentVal <= 206) {
        Send("{Enter}")

        if (popUpWindow != "") {
            WinWaitActive(popUpWindow, , 2)
        } else {
            Sleep(500)
        }

        Send("^a")
        Sleep(100) ; Small buffer to ensure text is highlighted before typing over it

        Send(currentVal)
        Send("{Enter}")

        Sleep(400)
        WinActivate(mainWindow)
        Sleep(100) ; Small buffer to ensure the main window is actually ready to receive inputs

        if (currentVal < 206) {
            Send("{Down}")
        }

        currentVal++
        Sleep(100)
    }

    if (currentVal > 206) {
        isRunning := false
        currentVal := 1
    }
}

Esc:: ExitApp