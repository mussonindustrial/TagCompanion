
#Requires Autohotkey v2
#SingleInstance Force

#Include "include\GuiReSizer.ahk"
#Include "libs\settings.ahk"
#Include "libs\Hotstrings.ahk"
#Include "libs\clipboard.ahk"


If Settings.Save.INI {
	SettingsLoad()
}
	

; Tray definition 
A_IconTip := "Tag Companion"
TraySetIcon( A_WorkingDir . "\libs\favicon.ico")
TrayTip("(Win + H) to Open...", "Tag Companion Started")

;; Main GUI
;{-----------------------------------------------
;
guiCommon := {
	margin: 8
}

guiMain := Gui()
guiMain.Title := "Tag Companion"
guiMain.OnEvent("Size", GuiResizer)
guiMain.OnEvent("Escape", GuiHide)
guiMain.OnEvent("Close", (*) => {})
guiMain.Opt("+Resize +MinSize450x350")
FileMenu := Menu()
FileMenu.Add("Save Settings...", (*) => SettingsSave())
FileMenu.Add()
FileMenu.Add("&Import Hotstrings...`tCtrl+O", (*) => HotstringOpen(guiMain.ListView))
FileMenu.Add("&Save Hotstrings`tCtrl+S", (*) => HotstringSave(Settings.File.HS))
FileMenu.Add("Save Hotstrings As...", (*) => HotstringSaveAs())
FileMenu.SetIcon("&Import Hotstrings...`tCtrl+O","shell32.dll", 4)
FileMenu.SetIcon("&Save Hotstrings`tCtrl+S","shell32.dll", 259)
FileMenu.Add()
FileMenu.Add("&Help`tF1", MenuHandler)
FileMenu.Add()
FileMenu.Add("Settings...", MenuHandler)
HotstringsMenu := Menu()
HotstringsMenu.Add("Enabled", (*) => HotstringSetEnabled(!Settings.Hotstrings.Enabled))
HotstringSetEnabled(Settings.Hotstrings.Enabled)
FileMenu.SetIcon("Settings...","shell32.dll", 166)
FileMenu.SetIcon("&Help`tF1","shell32.dll", 24)
SettingsMenu := Menu()
ControlDelayMenu := Menu()
ControlDelayMenu.Add("Send It (Fastest)", ControlDelayMenuHandler)
ControlDelayMenu.Add("~0ms (Fast)", ControlDelayMenuHandler)
ControlDelayMenu.Add("20ms (Default)", ControlDelayMenuHandler)
ControlDelayMenu.Check("20ms (Default)")
ControlDelayMenu.Add("100ms (Slow)", ControlDelayMenuHandler)
ControlDelayMenu.Add("300ms (Slower)", ControlDelayMenuHandler)
ControlDelayMenu.Add("1000ms (Turtle)", ControlDelayMenuHandler)
SettingsMenu.Add("Control Delay", ControlDelayMenu)
WindowDelayMenu := Menu()
WindowDelayMenu.Add("Send It (Fastest)", WindowDelayMenuHandler)
WindowDelayMenu.Add("~0ms (Faster)", WindowDelayMenuHandler)
WindowDelayMenu.Add("50ms (Fast)", WindowDelayMenuHandler)
WindowDelayMenu.Add("100ms (Default)", WindowDelayMenuHandler)
WindowDelayMenu.Check("100ms (Default)")
WindowDelayMenu.Add("300ms (Slower)", WindowDelayMenuHandler)
WindowDelayMenu.Add("1000ms (Turtle)", WindowDelayMenuHandler)
SettingsMenu.Add("Window Delay", WindowDelayMenu)
MenuBar_Storage := MenuBar()
MenuBar_Storage.Add("&File", FileMenu)
MenuBar_Storage.Add("&Hotstrings", HotstringsMenu)
MenuBar_Storage.Add("&Settings", SettingsMenu)
guiMain.MenuBar := MenuBar_Storage
; guiMain.TreeView := {}
; guiMain.TreeView.Nav := guiMain.Add("TreeView",,"Test")
; guiMain.TreeView.Nav.Add("Hotstrings")
; guiMain.TreeView.Nav.W := 98
; guiMain.TreeView.Nav.H := -8

guiMain.Tab := {}
guiMain.Tab.Nav := guiMain.Add("Tab3",, ["Hotstrings"])
guiMain.Tab.Nav.W := -8
guiMain.Tab.Nav.H := -8

guiMain.Tab.Nav.UseTab("Hotstrings")
guiMain.Edit := {}, guiMain.Button := {}, guiMain.ListView := {}
guiMain.Edit.HotstringSearchBar := guiMain.Add("Edit",,)
guiMain.Edit.HotstringSearchBar.H := 20
guiMain.Edit.HotstringSearchBar.X := 60 + guiCommon.margin
guiMain.Edit.HotstringSearchBar.Y := guiMain.Edit.HotstringSearchBar.H + (2*guiCommon.margin) + 1
guiMain.Edit.HotstringSearchBar.W := -3*guiCommon.margin
guiMain.SearchLabel := guiMain.Add("Text",,"Search:")
guiMain.SearchLabel.X := (3*guiCommon.margin)
guiMain.SearchLabel.Y := guiMain.Edit.HotstringSearchBar.H + (2*guiCommon.margin) + 4
guiMain.SearchLabel.W := 60

; guiMain.Button.HotstringSearch := guiMain.Add("Button",, "Search")
; guiMain.Button.HotstringSearch.H := 22
; guiMain.Button.HotstringSearch.Y := guiMain.Edit.HotstringSearchBar.H + (2*guiCommon.margin)
; guiMain.Button.HotstringSearch.X := -80
; guiMain.Button.HotstringSearch.W := 60

guiMain.ListView := guiMain.Add("ListView", "+LV0x4000", ["O", "Hotstring", "Replacement"])
guiMain.ListView.Y := 22 + (6*guiCommon.margin)
guiMain.ListView.H := -24 - (3*guiCommon.margin)
guiMain.ListView.W := -(3*guiCommon.margin) + 2
guiMain.ListView.OnEvent("DoubleClick", HotstringEditEvent)

guiMain.Button.HotstringDelete := guiMain.Add("Button",, "Delete")
guiMain.Button.HotstringDelete.H := 24
guiMain.Button.HotstringDelete.W := 60
guiMain.Button.HotstringDelete.X := -80
guiMain.Button.HotstringDelete.Y := - (2*guiCommon.margin) - guiMain.Button.HotstringDelete.H
guiMain.Button.HotstringDelete.OnEvent("Click", HotstringDeleteEvent)

guiMain.Button.HotstringAdd := guiMain.Add("Button",, "Add")
guiMain.Button.HotstringAdd.H := 24
guiMain.Button.HotstringAdd.W := 60
guiMain.Button.HotstringAdd.X := guiMain.Button.HotstringDelete.X - guiMain.Button.HotstringAdd.W - guiCommon.margin
guiMain.Button.HotstringAdd.Y := - (2*guiCommon.margin) - guiMain.Button.HotstringAdd.H
guiMain.Button.HotstringAdd.OnEvent("Click", HotstringAddEvent)


guiMain.OnEvent('Close', (*) => ExitApp())
;}

;{ guiAddHotstring
guiAddHotstring := Gui(, "Add Hotstring"), guiAddHotstring.Opt("+AlwaysOnTop +Resize +MinSize550x300")
guiAddHotstring.OnEvent("Size", GuiReSizer)
guiAddHotstring.OnEvent("Escape", GuiHide)
guiAddHotstring.Edit := {}, guiAddHotstring.Checkbox := {}, guiAddHotstring.Button := {}, guiAddHotstring.Text := {}
guiAddHotstring.Text.Abbr := guiAddHotstring.Add("Text",, "Abbreviation:")
guiAddHotstring.Text.Abbr.X := guiCommon.margin
guiAddHotstring.Text.Abbr.Y := guiCommon.margin + 3
guiAddHotstring.Text.Abbr.W := 80
guiAddHotstring.Edit.Abbr := guiAddHotstring.Add("Edit",)
guiAddHotstring.Edit.Abbr.X := guiAddHotstring.Text.Abbr.W + (2*guiCommon.margin)
guiAddHotstring.Edit.Abbr.Y := guiCommon.margin
guiAddHotstring.Edit.Abbr.W := -220

guiAddHotstring.Text.Replace := guiAddHotstring.Add("Text",, "Replacement:")
guiAddHotstring.Text.Replace.X := guiCommon.margin
guiAddHotstring.Text.Replace.Y := 24 + (2*guiCommon.margin) + 3
guiAddHotstring.Text.Replace.W := 80
guiAddHotstring.Edit.Replace := guiAddHotstring.Add("Edit","Multi",)
guiAddHotstring.Edit.Replace.X := guiAddHotstring.Text.Replace.W + (2*guiCommon.margin)
guiAddHotstring.Edit.Replace.Y := 24 + (2*guiCommon.margin)
guiAddHotstring.Edit.Replace.W := -220
guiAddHotstring.Edit.Replace.H := -guiCommon.margin * 2
guiAddHotstring.Line := guiAddHotstring.Add("Text","0x11")
guiAddHotstring.Line.H := -2*guiCommon.margin
guiAddHotstring.Line.X := -220 + (2*guiCommon.margin)
guiAddHotstring.Line.Y := 2*guiCommon.margin
guiAddHotstring.Checkbox.NoEndChar := guiAddHotstring.Add("Checkbox", , "No ending character (*)")
guiAddHotstring.Checkbox.CaseSensitive := guiAddHotstring.Add("Checkbox", , "Case sensitive (C)")
guiAddHotstring.Checkbox.TriggerInside := guiAddHotstring.Add("Checkbox", , "Trigger inside another word (?)")
guiAddHotstring.Checkbox.NoConformCase := guiAddHotstring.Add("Checkbox", , "Do not conform to typed case (C1)")
guiAddHotstring.Checkbox.NoAutoBack := guiAddHotstring.Add("Checkbox", , "No automatic backspacing (B0)")
guiAddHotstring.Checkbox.OmitEndChar := guiAddHotstring.Add("Checkbox", , "Omit ending character (O)")
guiAddHotstring.Checkbox.SendRaw := guiAddHotstring.Add("Checkbox", , "Send raw (R)")
guiAddHotstring.Checkbox.TextRaw := guiAddHotstring.Add("Checkbox", , "Send text raw (T)")
For FlagName, Val in OptionFlags.OwnProps()	; Position Checkboxes
{
	guiAddHotstring.Checkbox.%FlagName%.X := -220 + (3*guiCommon.margin)
	guiAddHotstring.Checkbox.%FlagName%.Y := 48 + (3*guiCommon.margin) + 3 + (A_Index * guiCommon.margin * 3)
}
guiAddHotstring.Button.Confirm := guiAddHotstring.Add("Button",, "&Confirm")
guiAddHotstring.Button.Confirm.OnEvent("Click", HostringAddConfirmEvent)
guiAddHotstring.Button.Cancel := guiAddHotstring.Add("Button",, "&Cancel")
guiAddHotstring.Button.Cancel.OnEvent("Click", HostringAddCancelEvent)
guiAddHotstring.Button.Confirm.X := -220 + (3*guiCommon.margin)
guiAddHotstring.Button.Confirm.Y := guiCommon.margin
guiAddHotstring.Button.Confirm.W := -guiCommon.margin
guiAddHotstring.Button.Cancel.X := -220 + (3*guiCommon.margin)
guiAddHotstring.Button.Cancel.Y := 24 + (2*guiCommon.margin) + 3
guiAddHotstring.Button.Cancel.W := -guiCommon.margin
;}

HotstringSetEnabled(Value) {
	Settings.Hotstrings.Enabled := Value
	Value ? HotstringsMenu.Check("Enabled") : HotstringsMenu.Uncheck("Enabled")
}

HotstringAddEvent(*) {
	For PropDesc, Prop in guiAddHotstring.Edit.OwnProps()
		Prop.Text := ""
	guiAddHotstring.Title := "Add Hotstring"
	guiAddHotstring.Show()
}

HotstringDeleteEvent(GuiCtrlObj, Info)
{
	RowNumber := guiMain.ListView.GetNext()
	If RowNumber = 0
	{
		MsgBox "Select Hotstring to Delete"
		Return
	}
	Options := guiMain.ListView.GetText(RowNumber, 1)
	Abbr := guiMain.ListView.GetText(RowNumber, 2)
	Replace := guiMain.ListView.GetText(RowNumber, 3)
	If MsgBox("Are you sure you want to delete:`n`nHotstring: " Abbr "`nReplacement: " Replace, "Confirm Hotstring Deletion", 4 + 32 + 256 + 4096) = "Yes"
	{
		guiMain.ListView.Delete(RowNumber)
		Hotstrings.Delete(Options ":" Abbr)
		RegExHotstring(Abbr, Replace, Options, false)
		; Hotstring(":" Options ":" Abbr, , false)
	}
}

HotstringSearch(ListView, Edit) 
{
	; ListView.Delete(), wordList := StrSplit(Edit.Text, ' '), filter := Trim(Edit.Text) != ''
	; Loop Parse txt, '`n', '`r' {
	; 	cell := [], addRow := !filter
	; 	Loop Parse, A_LoopField, 'CSV' {
	; 		cell.Push(A_LoopField)
	; 		If filter
	; 		For each, word in wordList ; Loop through words (find any)
	; 			(word != '') && addRow |= InStr(A_LoopField, word)
	; 		}
	; 	(addRow) && ListView.Add(, cell*)
	; }
	; SB.SetText '   Rows: ' ListView.GetCount()
}


HotstringEditEvent(GuiCtrlObj, RowNumber := 0)	; also List View DoubleClick
{
	Global CurrentHS
	If !RowNumber
		RowNumber := guiMain.ListView.GetNext()
	If RowNumber = 0
	{
		MsgBox "Select Hotsting to Edit"
		Return 
	}
	Options := guiMain.ListView.GetText(RowNumber)
	guiAddHotstring.Edit.Abbr.Text := Abbr := guiMain.ListView.GetText(RowNumber, 2)
	guiAddHotstring.Edit.Replace.Text := StrReplace(Replace := Hotstrings[Options ":" Abbr], "`n", "`r`n")
	For Flag, Value in OptionFlags.OwnProps()
	{
		If RegExMatch(Options, "\Q" Value "\E(?!\d)")
			guiAddHotstring.Checkbox.%Flag%.Value := true
		Else
			guiAddHotstring.Checkbox.%Flag%.Value := false
	}
	guiAddHotstring.Title := "Edit Hotstring"
	CurrentHS := { RowNumber: RowNumber, Options: Options, Abbr: Abbr, Replace: Replace }
	guiAddHotstring.Edit.Abbr.Focus()
	guiAddHotstring.Show
}

HostringAddConfirmEvent(*)
{
	guiAddHotstring.Hide
	Options := ""
	For Opt, Flag in OptionFlags.OwnProps()
		If guiAddHotstring.Checkbox.%Opt%.Value
			Options .= Flag
	If guiAddHotstring.Title ~= "Edit"
	{
		; when editting - delete current Hotstring to recreate
		guiMain.ListView.Delete(CurrentHS.RowNumber)
		Hotstrings.Delete(CurrentHS.Options ":" CurrentHS.Abbr)
		RegExHotstring(CurrentHS.Abbr, CurrentHS.Replace, CurrentHS.Options, false)
		Hotstring(":BCO0R0*0:" CurrentHS.Abbr, CurrentHS.Replace, false)	; Disable Exsisting Options Variants (C)
		Hotstring(":BC1O0R0*0:" CurrentHS.Abbr, CurrentHS.Replace, false)	; Disable Exsisting Options Variants (C1)
		Hotstring(":BC0O0R0*0:" CurrentHS.Abbr, CurrentHS.Replace, false)	; Disable Exsisting Options Variants (C0)
	}
	; remove any list View duplicate
	Loop guiMain.ListView.GetCount()
		If (guiMain.ListView.GetText(A_Index) = Options and guiMain.ListView.GetText(A_Index, 2) = guiAddHotstring.Edit.Abbr)
			guiMain.ListView.Delete(A_Index)
	; create Hotstring
	Hotstrings[Options ":" guiAddHotstring.Edit.Abbr.Value] := guiAddHotstring.Edit.Replace.Value
	; Hotstring(":" Options ":" guiAddHotstring.Edit.Abbr.Value, guiAddHotstring.Edit.Replace.Value, true)
	RegExHotstring(guiAddHotstring.Edit.Abbr.Value, guiAddHotstring.Edit.Replace.Value, Options, true)
	guiMain.ListView.Add(, Options, guiAddHotstring.Edit.Abbr.Value, StringEscapeCC(guiAddHotstring.Edit.Replace.Value))
}

HostringAddCancelEvent(*)
{
	guiAddHotstring.Hide
}

GuiHide(GuiObj)
{
	GuiObj.Hide
}

MenuHandler(*)
{
	ToolTip("Click! This is a sample action.`n", 77, 277)
	SetTimer () => ToolTip(), -3000 ; tooltip timer
}

ControlDelay := 20
ControlDelayMenuHandler(ItemName, ItemPos, MenuInstance) {
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
WindowDelayMenuHandler(ItemName, ItemPos, MenuInstance) {
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

;; AUTO-EXECUTE
;{-----------------------------------------------
;
; Load Hotstrings
If Settings.Save.HS
	HotstringLoad(Settings.File.HS, guiMain.ListView)
;}

;; HOTKEYS
;{-----------------------------------------------
;
#SuspendExempt	; Only Hotstrings affected by Suspend
#h:: guiMain.Show	; <-- TagCompanion- Main

#Space::	; <-- Space without expanding Hotstring
{
	Hotstring("Reset")
	Send "{Space}"
}

; Toggle Hotstrings on and off.
^#space:: {
	HotstringSetEnabled(!Settings.Hotstrings.Enabled)
	ToolTip "Tag Companion Hotstrings`n" (Settings.Hotstrings.Enabled ? "ON" : "OFF")
	SetTimer () => ToolTip(), -5000
	(Settings.Hotstrings.Enabled ? Suspend(false) : Suspend(true))
}

; Reload the script.
#ESC:: {
    Reload
    return
}

^Up:: {
	ClipboardIncrement("First", Settings.Increment.Up)
}

^Down:: {
	ClipboardIncrement("First", Settings.Increment.Down)
}

#HotIf WinActive('ahk_exe LogixDesigner.Exe')
^BackSpace:: {
    Send("{Ctrl Down}{Shift Down}{Left}{Ctrl Up}{Shift Up}")
    Send("{Backspace}")
}
#HotIf

:*:#now:: {
    Send(FormatTime(, "yyyy/MM/dd h:mm tt"))
}

:*:#date:: {
    Send(FormatTime(, "yyyy MMdd"))
}

#SuspendExempt false
;}

