#Include "strings.ahk"

Settings := { Save: {}, File: {}, Hotstrings: {}, Increment: {} }
Settings.Save.HS := true
Settings.Save.INI := true
Settings.File.HS := "hotstring.conf"
Settings.File.INI := "settings.ini"
Settings.Hotstrings.Enabled := true
Settings.Increment.Up := 1
Settings.Increment.Down := -1

SettingsSave()
{
	Try FileMove(Settings.File.INI, Settings.File.INI ".bak", true)
	; For GuiName, Pos in Settings.GuiPositions.OwnProps()
	; {
	; 	%GuiName%.GetPos(&X, &Y, &W, &H)
	; 	Pos.X := X, Pos.Y := Y, Pos.Width := W, Pos.Height := H
	; }
	For Section_Name, Section in Settings.OwnProps()
		For Setting_Name, Value in Section.OwnProps()
			If !IsObject(Value)
				IniWrite Value, Settings.File.INI, Section_Name, Setting_Name

	; For Section_Name, Section in Settings.GuiPositions.OwnProps()
	; 	For Setting_Name, Value in Section.OwnProps()
	; 		IniWrite Value, Settings.File.INI, Section_Name, Setting_Name
}

SettingsLoad()
{
	For Section_Name, Section in Settings.OwnProps()
		For Setting_Name, Value in Section.OwnProps()
			If !IsObject(Value)
				Try Settings.%Section_Name%.%Setting_Name% := IniRead(Settings.File.INI, Section_Name, Setting_Name)
	; For Section_Name, Section in Settings.GuiPositions.OwnProps()
	; 	For Setting_Name, Value in Section.OwnProps()
	; 		Try Settings.GuiPositions.%Section_Name%.%Setting_Name% := IniRead(Settings.File.INI, Section_Name, Setting_Name)
}

