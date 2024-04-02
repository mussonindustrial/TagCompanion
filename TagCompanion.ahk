
#Requires Autohotkey v2
#SingleInstance Force

#Include "include\GuiReSizer.ahk"
#Include "include\LightJson.ahk"
#Include "libs\Context.ahk"
#Include "libs\clipboard.ahk"

guiCommon := {
	margin: 8
}

/**
 * Tray definition 
 */
A_IconTip := "Tag Companion"
FileInstall("images\favicon.ico", "\images\favicon.ico")
TraySetIcon( A_WorkingDir . "\images\favicon.ico",,true)
TrayTip("(Win + H) to Open...", "Tag Companion Started")


/**
 * Initialize Application Context
 */
context := TagCompanionContext()

/**
 * Main GUI
 */
context.GuiMain.Tab := {}
context.GuiMain.Tab.Nav := context.GuiMain.Add("Tab3",, ["Hotstrings"])
context.GuiMain.Tab.Nav.W := -8
context.GuiMain.Tab.Nav.H := -8

context.GuiMain.Tab.Nav.UseTab("Hotstrings")
context.GuiMain.Edit := {}, context.GuiMain.Button := {}, context.GuiMain.ListView := {}, context.GuiMain.Checkbox := {}

context.GuiMain.ListView := context.HotstringManager.InitializeListView(context.GuiMain)
context.GuiMain.ListView.Y := (4*guiCommon.margin)
context.GuiMain.ListView.H := -24 - (3*guiCommon.margin)
context.GuiMain.ListView.W := -(3*guiCommon.margin) + 2

context.GuiMain.Button.HotstringDelete := context.GuiMain.Add("Button",, "Delete")
context.GuiMain.Button.HotstringDelete.H := 24
context.GuiMain.Button.HotstringDelete.W := 60
context.GuiMain.Button.HotstringDelete.X := -80
context.GuiMain.Button.HotstringDelete.Y := - (2*guiCommon.margin) - context.GuiMain.Button.HotstringDelete.H
context.GuiMain.Button.HotstringDelete.OnEvent("Click", (*) => context.HotstringManager.DeleteSelected())

context.GuiMain.Button.HotstringAdd := context.GuiMain.Add("Button",, "Add")
context.GuiMain.Button.HotstringAdd.H := 24
context.GuiMain.Button.HotstringAdd.W := 60
context.GuiMain.Button.HotstringAdd.X := context.GuiMain.Button.HotstringDelete.X - context.GuiMain.Button.HotstringAdd.W - guiCommon.margin
context.GuiMain.Button.HotstringAdd.Y := - (2*guiCommon.margin) - context.GuiMain.Button.HotstringAdd.H
context.GuiMain.Button.HotstringAdd.OnEvent("Click", (*) => context.HotstringManager.OpenNewEditor())

/**
 * Load Hotstrings (Once GUI is Ready)
 */
context.HotstringManager.Load(context.SettingsManager.settings['hotstrings']['filePath'])
RegExHotstring("\Q#now\E", (*) => Send(FormatTime(, "yyyy/MM/dd h:mm tt")), "*O")
RegExHotstring("\Q#date\E", (*) => Send(FormatTime(, "yyyy MMdd")), "*")


/**
 * Hotkeys
 */
#SuspendExempt
#h:: context.GuiMain.Show
#ESC:: Reload

/**
 * Fix Ctrl+Backspace for applications that use special characters.
 */
#HotIf WinActive("ahk_class AutoHotkeyGUI")
#HotIf WinActive('ahk_exe LogixDesigner.Exe')
^BS::Send("^+{Left}{Delete}")
#HotIf

; Space without expanding hotstring
#Space::
{
	Hotstring("Reset")
	Send "{Space}"
}

; Toggle Hotstrings on and off.
^#space:: {
    context.SettingsManager.HotstringsToggle()
}

; Increment number in selection.
^Up:: {
	ClipboardIncrement("First", context.SettingsManager.settings['increment']['up'])
}

; Decrement number in selection.
^Down:: {
	ClipboardIncrement("First", context.SettingsManager.settings['increment']['down'])
}

#SuspendExempt false
