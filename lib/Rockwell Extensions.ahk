#Include lib\CSV.ahk
#Include lib\Studio5000.ahk
#include lib\UIA.ahk

#SingleInstance Force

; Tray definition 
A_IconTip := "Rockwell Extensions"
Application := { Name: "Rockwell Extensions", Version: "0.1" }
TraySetIcon( A_WorkingDir . "\data\favicon.ico")
TrayTip("(Ctrl + Right Click)", "Listening for Hotkeys...")

^ESC:: {
    Reload
    ; Sleep(1000) ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
    ; Result := MsgBox("The script could not be reloaded. Would you like to open it for editing?",, 4)
    ; if (Result = "Yes")
    ;     Edit()
    return
}

ImportTags() {
    filePath := FileSelect("1", "", "Select Tag Import File", "Tag Import (*.csv; *.xlxs; *.xlx)")
    if(filePath = "") {
        MsgBox("No import file selected.", "Error")
        return
    }

    csvArray := ImportCSV(filePath)
    totalCount := csvArray.Count
    failedTags := []

    TrayTip("Importing " . totalCount . " tags...", "Import Tags")
    SetKeyDelay(50,200)
    for index, row in csvArray {
        if(!Studio5000.CreateTag(row)) {
            failedTags.Push(row)
        }
    }

    totalCount := csvArray.Count
    failureCount := failedTags.Length
    successCount := totalCount - failureCount
    
    title := "Tag Import Complete"
    icon := 0 ; No Icon
    if (failureCount > 0) {
        message := failureCount . "/" . totalCount . " tags failed to import."
        icon := 2 ; Warning Icon
    } else {
        message := successCount . "/" . totalCount . " tags imported successfully."
    }
    TrayTip(message, title, icon)
}

ImportTagsMenuItem(ItemName, ItemPos, MenuInstance) {
    SetControlDelay(ControlDelay)
    SetWinDelay(WindowDelay)
    ImportTags()
}

TagWindowOpened() {
    tagWindow := NewTagWindow.GetByWaitActive()
    suggestion := StrReplace(tagWindow.Name, "OCmd_", "1=Operator Command to ")
    suggestion := StrReplace(suggestion, "ORdy_", "1=Ready for Operator Command to ")
    suggestion := StrReplace(suggestion, "PCmd_", "1=Program Command to ")
    suggestion := StrReplace(suggestion, "PRdy_", "1=Ready for Program Command to ")
    suggestion := StrReplace(suggestion, "MCmd_", "1=Maintenance Command to ")
    suggestion := StrReplace(suggestion, "MRdy_", "1=Ready for Maintenance Command to ")
    suggestion := StrReplace(suggestion, "Sts_", "Status`r`n")
    suggestion := StrReplace(suggestion, "Wrk_", "Working Register`r`n")
    suggestion := StrReplace(suggestion, "Cmd_", "Command`r`n")
    tagWindow.Description := suggestion
}

IncrementMode := "None"
SetIncrementMode(ItemName, ItemPos, MenuInstance) {
    Switch ItemName {
        case "&None":
            global IncrementMode := "None"
        case "&First":
            global IncrementMode := "First"
        case "&Last":
            global IncrementMode := "Last"
    }
    Loop 3 {
        MenuInstance.Uncheck(A_Index . "&")
    }
    MenuInstance.Check(ItemPos . "&")
}

ControlDelay := 20
SetControlDelayMenu(ItemName, ItemPos, MenuInstance) {
    Switch ItemName {
        case "Send It (Fastest)": 
            global ControlDelay := -1
        case "~0ms (Fast)": 
            global ControlDelay := -0
        case "20ms (Default)": 
            global ControlDelay := 20
        case "100ms (Slow)": 
            global ControlDelay := 100
        case "300ms (Slower)": 
            global ControlDelay := 300
        case "1000ms (Turtle)": 
            global ControlDelay := 1000
    }
    Loop 6 {
        MenuInstance.Uncheck(A_Index . "&")
    }
    MenuInstance.Check(ItemPos . "&")
}

WindowDelay := 50
SetWindowDelayMenu(ItemName, ItemPos, MenuInstance) {
    Switch ItemName {
        case "Send It (Fastest)": 
            global WindowDelay := -1
        case "~0ms (Faster)": 
            global WindowDelay := -0
        case "50ms (Fast)": 
            global WindowDelay := 50
        case "100ms (Default)": 
            global WindowDelay := 100
        case "300ms (Slower)": 
            global WindowDelay := 300
        case "1000ms (Turtle)": 
            global WindowDelay := 1000
    }
    Loop 6 {
        MenuInstance.Uncheck(A_Index . "&")
    }
    MenuInstance.Check(ItemPos . "&")
}

HotKeyMenu := Menu()

TimingMenu := Menu()
ControlDelayMenu := Menu()
ControlDelayMenu.Add("Send It (Fastest)", SetControlDelayMenu)
ControlDelayMenu.Add("~0ms (Fast)", SetControlDelayMenu)
ControlDelayMenu.Add("20ms (Default)", SetControlDelayMenu)
ControlDelayMenu.Check("20ms (Default)")
ControlDelayMenu.Add("100ms (Slow)", SetControlDelayMenu)
ControlDelayMenu.Add("300ms (Slower)", SetControlDelayMenu)
ControlDelayMenu.Add("1000ms (Turtle)", SetControlDelayMenu)
TimingMenu.Add("Control Delay", ControlDelayMenu)
WindowDelayMenu := Menu()
WindowDelayMenu.Add("Send It (Fastest)", SetWindowDelayMenu)
WindowDelayMenu.Add("~0ms (Faster)", SetWindowDelayMenu)
WindowDelayMenu.Add("50ms (Fast)", SetWindowDelayMenu)
WindowDelayMenu.Add("100ms (Default)", SetWindowDelayMenu)
WindowDelayMenu.Check("100ms (Default)")
WindowDelayMenu.Add("300ms (Slower)", SetWindowDelayMenu)
WindowDelayMenu.Add("1000ms (Turtle)", SetWindowDelayMenu)
TimingMenu.Add("Window Delay", WindowDelayMenu)

IncrementMenu := Menu()
IncrementMenu.Add("&None", SetIncrementMode)
IncrementMenu.Check("&None")
IncrementMenu.Add("&First", SetIncrementMode)
IncrementMenu.Add("&Last", SetIncrementMode)

ImportMenu := Menu()
ImportMenu.Add("&Tags...", ImportTagsMenuItem)

HotKeyMenu.Add("&Timing", TimingMenu)
HotKeyMenu.Add("&Increment Mode", IncrementMenu)
HotKeyMenu.Add()
HotKeyMenu.Add("&Import", ImportMenu)


^RButton:: {
    DetectHiddenWindows("On")
    WinActivate("ahk_id " .  A_ScriptHwnd)
    WinWaitActive("ahk_id " . A_ScriptHwnd)
    HotKeyMenu.Show()
}


; Window Change Events
; Caching is necessary to ensure that we won't be requesting information about windows that don't exist any more (eg after close), or when a window was created and closed while our handler function was running
cacheRequest := UIA.CreateCacheRequest(["Name", "Type", "NativeWindowHandle"])
; I'm using an event handler group, but if only one event is needed then a regular event handler could be used as well
groupHandler := UIA.CreateEventHandlerGroup()
handler := UIA.CreateAutomationEventHandler(AutomationEventHandler)
groupHandler.AddAutomationEventHandler(handler, UIA.Event.Window_WindowOpened, UIA.TreeScope.Subtree, cacheRequest)
groupHandler.AddAutomationEventHandler(handler, UIA.Event.Window_WindowClosed, UIA.TreeScope.Subtree, cacheRequest)
; Root element = Desktop element, which means that using UIA.TreeScope.Subtree, all windows on the desktop will be monitored
UIA.AddEventHandlerGroup(groupHandler, UIA.GetRootElement())
; Persistent()

AutomationEventHandler(sender, eventId) {
    if eventId = UIA.Event.Window_WindowOpened {
        ; hwnd := DllCall("GetAncestor", "UInt", sender.CachedNativeWindowHandle, "UInt", 2) ; If the window handle (winId) is needed
        if InStr(sender.CachedName, "New Tag") {
            TagWindowOpened()
        } 
    }
}

;Find and increment the number in a string
;References the Increment mode set in the GUI
IncrementText(textString, offset){

    regex := ""

    Switch IncrementMode {
        case "First":
            regex := "(\d+)"
        case "Last":
            regex := "(\d+)(?!.*\d+)"
    }

    if (regex == "") {
        return textString
    } else {
        if RegExMatch(textString, regex, &found) {
            newValue := Format("{:0" found.Len "}", found[] + offset)

            newText := SubStr(textString, 1, found.Pos - 1)
            newText .= newValue
            newText .= SubStr(textString, found.Pos + found.Len)
            return newText
        }
        return textString
    }
}



; Increment Macro
^Up::{

    ; Save the entire clipboard contents.
    ClipSaved := ClipboardAll()

    ; Reset clipboard and wait for copy.
    A_Clipboard := ""
    SendInput("^c")
    ClipWait(1)

    ; Convert to text and check for contents.
    A_Clipboard := A_Clipboard
    if A_Clipboard == "" {
        return
    }

    ; Loop through the clipboard and increment.
    i := 0
    newText := ""
    Loop Parse A_Clipboard, "`n" {
        newText .= IncrementText(A_LoopField, 1)
        i := i + 1
    }

    SendInput newText

    ; Reselect the current region
    SendInput("^+{Left}")
    if i > 1 {
        Loop (i - 1) {
            SendInput("^+{Up}")
        }

    }

    ; Restore the original clipboard.
    A_Clipboard := ClipSaved 
    ClipSaved := ""

}

; Decrement Macro
^Down::{

    A_Clipboard := ""
    SendInput("^c")
    ClipWait(1)
    A_Clipboard := A_Clipboard
    if A_Clipboard == "" {
        return
    }

    A_Clipboard := IncrementText(A_Clipboard, -1)
       
    SendInput("^v")
    SendInput("^+{Left}")

}


^+BackSpace:: {
    Send("{Ctrl Down}{Shift Down}{Left}{Ctrl Up}{Shift Up}")
    Send("{Backspace}")
}

^BackSpace:: {
    Send("{Ctrl Down}{Shift Down}{Left}{Ctrl Up}{Shift Up}")
    Send("{Backspace}")
}


:*:#OCmd:: {
    Send("1=Operator Command to")
}

:*:#ORdy:: {
    Send("1=Ready for Operator Command to")
}

:*:#PCmd:: {
    Send("1=Program Command to")
}

:*:#Sts:: {
    Send("Status`n")
}

:*:#Cmd:: {
    Send("Command`n")
}

:*:#Wrk:: {
    Send("Working Register`n")
}

:*:#now:: {
    Send(FormatTime(, "yyyy/MM/dd h:mm tt"))
}

:*:#date:: {
    Send(FormatTime(, "yyyy MMdd"))
}
:*:#===:: {
    Send("================`n")
    Send("BlockComment`n")
    Send("================")
    Send("{Up}")
    Send("{Ctrl Down}{Shift Down}{Left}{Ctrl Up}{Shift Up}")
}

:*:#---:: {
    Send("-------------------`n")
    Send("BlockComment`n")
    Send("-------------------")
    Send("{Up}")
    Send("{Ctrl Down}{Shift Down}{Left}{Ctrl Up}{Shift Up}")
}
