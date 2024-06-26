#Include "..\include\GuiReSizer.ahk"
#Include "..\include\LightJson.ahk"

#Include "Strings.ahk"
#Include "NamedValues.ahk"
#Include "RegExHotstringHook.ahk"

class HotstringManager {

	static OptionFlags := { NoEndChar: "*", TriggerInside: "?", NoAutoBack: "B0", OmitEndChar: "O", NoBufferReset: "R0" }

	__New(context) {
		this.context := context
		this.hook := NewRegExHotstringHook(context)

		this.guiEdit := Gui(, "Add Hotstring"), this.guiEdit.Opt("+AlwaysOnTop +Resize +MinSize550x300")
		this.guiEdit.OnEvent("Size", GuiReSizer)
		this.guiEdit.OnEvent("Escape", (*) => this.guiEdit.Hide)
		this.guiEdit.Edit := {}, this.guiEdit.Checkbox := {}, this.guiEdit.Button := {}, this.guiEdit.Text := {}

		this.guiEdit.Text.Hotstring := this.guiEdit.Add("Text",, "Hotstring:")
		this.guiEdit.Text.Hotstring.X := guiCommon.margin
		this.guiEdit.Text.Hotstring.Y := guiCommon.margin + 3
		this.guiEdit.Text.Hotstring.W := 80

		this.guiEdit.Edit.Hotstring := this.guiEdit.Add("Edit",)
		this.guiEdit.Edit.Hotstring.X := this.guiEdit.Text.Hotstring.W + (2*guiCommon.margin)
		this.guiEdit.Edit.Hotstring.Y := guiCommon.margin
		this.guiEdit.Edit.Hotstring.W := -220

		this.guiEdit.Text.Replace := this.guiEdit.Add("Text",, "Replacement:")
		this.guiEdit.Text.Replace.X := guiCommon.margin
		this.guiEdit.Text.Replace.Y := 24 + (2*guiCommon.margin)
		this.guiEdit.Text.Replace.W := 80

		this.guiEdit.Edit.Replace := this.guiEdit.Add("Edit","Multi t8 WantTab -Wrap HScroll",)
		this.guiEdit.Edit.Replace.X := this.guiEdit.Text.Replace.W + (2*guiCommon.margin)
		this.guiEdit.Edit.Replace.Y := 24 + (2*guiCommon.margin)
		this.guiEdit.Edit.Replace.W := -220
		this.guiEdit.Edit.Replace.H := -guiCommon.margin * 2

		this.guiEdit.Line := this.guiEdit.Add("Text","0x11")
		this.guiEdit.Line.H := -2*guiCommon.margin
		this.guiEdit.Line.X := -220 + (2*guiCommon.margin)
		this.guiEdit.Line.Y := 2*guiCommon.margin
		this.guiEdit.Checkbox.NoEndChar := this.guiEdit.Add("Checkbox", , "No ending character (*)")
		this.guiEdit.Checkbox.TriggerInside := this.guiEdit.Add("Checkbox", , "Trigger inside another word (?)")
		this.guiEdit.Checkbox.NoAutoBack := this.guiEdit.Add("Checkbox", , "No automatic backspacing (B0)")
		this.guiEdit.Checkbox.OmitEndChar := this.guiEdit.Add("Checkbox", , "Omit ending character (O)")
		this.guiEdit.Checkbox.NoBufferReset := this.guiEdit.Add("Checkbox", , "Don't reset input buffer (R0)")
		For flag, value in HotstringManager.OptionFlags.OwnProps()	; Position Checkboxes
		{
			this.guiEdit.Checkbox.%flag%.X := -220 + (3*guiCommon.margin)
			this.guiEdit.Checkbox.%flag%.Y := 48 + (3*guiCommon.margin) + 3 + (A_Index * guiCommon.margin * 3)
		}
		this.guiEdit.Button.Confirm := this.guiEdit.Add("Button",, "&Confirm")
		this.guiEdit.Button.Confirm.OnEvent("Click", (*) => this.HotstringAddEvent())
		this.guiEdit.Button.Cancel := this.guiEdit.Add("Button",, "&Cancel")
		this.guiEdit.Button.Cancel.OnEvent("Click", (*) => this.CloseEditor())
		this.guiEdit.Button.Confirm.X := -220 + (3*guiCommon.margin)
		this.guiEdit.Button.Confirm.Y := guiCommon.margin
		this.guiEdit.Button.Confirm.W := -guiCommon.margin
		this.guiEdit.Button.Cancel.X := -220 + (3*guiCommon.margin)
		this.guiEdit.Button.Cancel.Y := 24 + (2*guiCommon.margin) + 3
		this.guiEdit.Button.Cancel.W := -guiCommon.margin
		;}
    }

	InitializeListView(guiObj) {
		this.ListView := guiObj.Add("ListView", "+LV0x4000", ["Options", "Hotstring", "Replacement"])
		this.ListView.OnEvent("DoubleClick", (*) => this.OpenEditor())
		this.ListView.OnEvent("ContextMenu", (GuiCtrlObj, Item, IsRightClick, X, Y) => this.OpenContext(Item))
		return this.ListView
	}

	/**
	 * Get the hotstring for a given key.
	 * @param {String} Key 
	 * @return {Hotstring} hotstring object
	 */
	 Get(Key) {
		return this.hook.Get(Key)
	}

	/**
	 * Add a new Hotstring.
	 * @param {String} Key hotstring match key
	 * @param {String} Replacement match result
	 * @param {String} Options 
	 * @param {Boolean} RemoveDuplicates if true, remove any existing hotstring with an identical key
	 */
	 Add(Key, Replacement, Options, RemoveDuplicates := true) {
		; remove any list View duplicate
		if removeDuplicates {
			Loop this.ListView.GetCount()
				If (this.ListView.GetText(A_Index) = options and this.ListView.GetText(A_Index, 2) = key)
					this.ListView.Delete(A_Index)
		}
		this.hook.Add(key, StringTemplateToRegex(key), replacement, options, true)
		this.ListView.Add(, options, key, StringEscapeCC(replacement))

	}

	/**
	 * Prompt the user to open and load a Hotstring Config file.
	 */
	ShowFileLoad() {
		filePath := FileSelect("1", "", "Open Hotstring Config", "Hotstring Config (*.json)")
		if(filePath = "") {
			return
		}
		this.Load(filePath)
	}

	/**
	 * Load a Hotstring Config file.
	 * @param {String} FileName
	 */
	Load(FileName) {
		try {
			json := FileRead(FileName)
			saveObj := LightJson.Parse(json)
		}
		catch {
			this.SaveAs()
			return
		}

		hs := saveObj['hotstrings']
		for value in hs {
			try {
				key := value.Get("key", "")
				replacement := value.Get("replacement", "")
				options := value.Get("options", "")
				this.Add(key, replacement, options)
			}
		}
		this.ListView.ModifyCol(2, "Sort")
		this.ListView.ModifyCol
		Loop 3
			this.ListView.ModifyCol(A_Index, "AutoHdr")
	}

	/**
	 * Save configured hotstrings to a file.
	 * @param {String} FileName
	 */
	Save(FileName) {
		try FileMove(FileName, FileName ".bak", true)
		FileAppend(this.Serialize(this.hook.hotstrings), FileName)
		try FileDelete(FileName ".bak")
	}

	Serialize(hotstrings) {
		hs := []
		for k, v in hotstrings {
			hs.Push(v.ToObject())
		}

		return LightJson.Stringify({
			hotstrings: hs
		}, "`t")
	}

	/**
	 * Prompt the user to save configured hotstrings to a new file.
	 */
	SaveAs() {
		filePath := FileSelect("S8", this.context.SettingsManager.settings['hotstrings']['filePath'], "Save Hotstring Config", "Hotstring Config (*.json)")
		if(filePath = "") {
			return
		}
		this.Save(filePath)
		this.context.SettingsManager.settings['hotstrings']['filePath'] := filePath
		this.context.SettingsManager.Autosave()
	}

	Autosave() {
		this.Save(this.context.SettingsManager.settings['hotstrings']['filePath'])
	}

	/**
	 * Get the selected hotstring.
	 * @return {Selected}
	 */
	GetSelected() {
		row := this.ListView.GetNext()
		if row = 0
		{
			MsgBox("No hotstring selected.", "Tag Companion")
			return 
		}
		return this.GetRow(row)
	}

	/**
	 * Get the hotstring at a row in the ListView.
	 * @param {Integer} row
	 * @return {Selected}
	 */
	GetRow(row) {
		key := this.ListView.GetText(row, 2)
		hs := this.Get(key)
		return { row: row, key: key, hs: hs }
	}

	/**
	 * Open the editor for the selected hotstring.
	 */
	OpenEditor(row := 0) {
		selected := this.GetSelected()
		if (!selected) {
			return
		}

		this.guiEdit.Edit.Hotstring.Text := selected.key
		if selected.hs {
			this.guiEdit.Edit.Replace.Text := StrReplace(selected.hs.replacement, "`n", "`r`n")
			for flag, value in HotstringManager.OptionFlags.OwnProps() {
					this.guiEdit.Checkbox.%flag%.value := RegExMatch(selected.hs.options, "\Q" value "\E(?!\d)") != 0
				}
		}

		this.guiEdit.Title := "Edit Hotstring"
		this.guiEdit.Edit.Hotstring.Focus()
		this.guiEdit.Show
	}

	/**
	 * Open the editor for creating a new hotstring.
	 */
	OpenNewEditor() {
		for description, prop in this.guiEdit.Edit.OwnProps()
			prop.Text := ""
		for flag, value in HotstringManager.OptionFlags.OwnProps()
			this.guiEdit.Checkbox.%flag%.Value := false
		this.guiEdit.Checkbox.OmitEndChar.Value := true
		this.guiEdit.Title := "Add Hotstring"
		this.guiEdit.Show()
	}

	/**
	 * Close the hotstring editor.
	 */
	CloseEditor() {
		this.guiEdit.Hide
	}

	OpenContext(row := 0) {
		try {
			item := this.GetRow(row)
		} catch {
			item := ""
		}

		contextMenu := Menu()
		contextMenu.Add("&Edit`tCtrl+E", (*) => this.OpenEditor(row))
		contextMenu.Add("&Copy`tCtrl+C", (*) => this.CopyToClipboard(item))
		contextMenu.Add("&Duplicate`tCtrl+D", (*) => this.Duplicate(item))
		contextMenu.Add()
		contextMenu.Add("New...", (*) => this.OpenNewEditor())
		contextMenu.Add()
		contextMenu.Add("Delete", (*) => this.Delete(item.row))


		if (!item) {
			contextMenu.Disable("&Edit`tCtrl+E")
			contextMenu.Disable("&Copy`tCtrl+C")
			contextMenu.Disable("&Duplicate`tCtrl+D")
			contextMenu.Disable("Delete")
		}

		contextMenu.Show()
	}

	/**
	 * Copy a hotstring to the clipboard.
	 * @param {Hotstring} item 
	 */
	CopyToClipboard(item) {
		A_Clipboard := this.Serialize([item.hs])
	}

	/**
	 * Duplicate a row in the ListView.
	 * @param {Integer} row 
	 */
	Duplicate(row) {
		newKey := StringIncrement(row.key, "Last", 1)
		if (newKey == row.key) {
			newKey .= "_1"
		}
		this.Add(newKey, row.hs.replacement, row.hs.options)
	}

	/**
	 * Delete a hotstring at a row.
	 * @param {Integer} row if no is specified, the current selected row will be used.
	 */
	Delete(row := 0, confirm := true) {
		if (!row) {
			item := this.GetSelected()
		} else  {
			item := this.GetRow(row)
		}
		
		if (!item) {
			return
		}

		if (confirm) {
			doDelete := MsgBox("Are you sure you want to delete:`n`nHotstring: " item.key "`nReplacement: " item.hs.replacement, "Confirm Hotstring Deletion", 4 + 32 + 256 + 4096) = "Yes"
		} else {
			doDelete := true
		}

		if doDelete {
			this.ListView.Delete(item.row)
			this.hook.Delete(item.key)
		}
	
	}

	HotstringAddEvent() {
		this.guiEdit.Hide
		Options := ""
		For Opt, Flag in HotstringManager.OptionFlags.OwnProps()
			If this.guiEdit.Checkbox.%Opt%.Value
				Options .= Flag
		If this.guiEdit.Title ~= "Edit"
		{
			this.Delete(,false)
		}

		this.Add(this.guiEdit.Edit.Hotstring.Value, this.guiEdit.Edit.Replace.Value, options)

	}
}
