#Include "..\include\LightJson.ahk"
#Include "strings.ahk"

FileInstall("settings.json", "\settings.json")

class SettingsManager {

	static configPath := "settings.json"

	settings := {
		hotstrings: {
			enabled: true,
			filePath: "hotstrings.json"
		},
		increment: {
			mode: "first",
			up: 1,
			down: -1
		},
		delay: {
			control: 20,
			window: 20
		}
	}

	__New(context) {
		this.context := context
	}

	/**
	 * Prompt the user to open and load a Tag Companion settings file.
	 */
	PromptLoad() {
		filePath := FileSelect("1", SettingsManager.configPath, "Open Tag Companion Settings", "Tag Companion Settings (*.json;)")
		if(filePath = "") {
			return
		}
		this.Load(filePath)
	}

	/**
	 * Load a Tag Companion settings file.
	 * @param {String} FileName
	 */
	Load(FileName) {
		try {
			json := FileRead(FileName)
			savedObj := LightJson.Parse(json)
		}
		catch {
			MsgBox("Error parsing settings file.", "Error", 16)
			this.SaveAs()
			return
		}
		this.settings := savedObj
	}

	/**
	 * Save configured settings to a file.
	 * @param {String} FileName
	 */
	Save(FileName) {
		try FileMove(FileName, FileName ".bak", true)
		FileAppend(this.Serialize(this.settings), FileName)
		try FileDelete(FileName ".bak")
	}

	Autosave() {
		this.Save(SettingsManager.configPath)
	}

	Serialize(settings) {
		return LightJson.Stringify(settings, "`t")
	}

	/**
	 * Prompt the user to save configured settings to a new file.
	 */
	SaveAs() {
		filePath := FileSelect("S8", SettingsManager.configPath, "Save Tag Companion Settings", "Tag Companion Settings (*.json;)")
		if(filePath = "") {
			return
		}
		this.Save(filePath)
	}

	SetControlDelay(Value) {
		this.settings.delay.control := Value
	}

	SetWindowDelay(Value) {
		this.settings.delay.window := Value
	}

	HotstringsToggle() {
		this.HotstringsSetEnabled(!this.settings['hotstrings']['enabled'])
		state := (this.settings['hotstrings']['enabled'] ? "Enabled" : "Disabled")
		SetTimer () => ToolTip(), -5000
		TrayTip("Hotstrings " state, "Tag Companion")
		(this.settings['hotstrings']['enabled'] ? Suspend(false) : Suspend(true))
	}

	HotstringsSetEnabled(Value) {
		this.settings['hotstrings']['enabled'] := Value
	}
}