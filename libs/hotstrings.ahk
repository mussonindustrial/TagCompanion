#Include "strings.ahk"
#Include "..\include\RegExHotstring.ahk"

Hotstrings := Map(), Hotstrings.Default := ""
OptionFlags := { NoEndChar: "*", CaseSensitive: "C", TriggerInside: "?", NoConformCase: "C1", NoAutoBack: "B0", OmitEndChar: "O", SendRaw: "R", TextRaw: "T" }

HotstringOpen(ListView) {
	filePath := FileSelect("1", "", "Open Hotstring Config", "Hotstring Config (*.conf; *.conf.bak;)")
	if(filePath = "") {
        return
    }
	HotstringLoad(filePath, ListView)
}

HotstringSave(FileName) {
	For Opt_Abbr, Replacement in Hotstrings
		String .= ":" Opt_Abbr "::" StringEscapeCC(Replacement) "`n"
	Try FileMove(FileName, FileName ".bak", true)
	Try FileAppend(SubStr(String, 1, -1), FileName)
}

HotstringSaveAs() {
	filePath := FileSelect("S8", "hotstring.conf", "Save Hotstring Config", "Hotstring Config (*.conf; *.conf.bak;)")
	if(filePath = "") {
        return
    }
	HotstringSave(filePath)
}

HotstringLoad(FileName, ListView) {
	Try
		String := FileRead(FileName)
	Catch
		Return
	Loop Parse, String, "`n", "`r" {
		If RegExMatch(A_LoopField, "U)^:(?<Options>.*):(?<Abbr>.*)::(?<Replace>.*)$", &Match) {
			If StringEscapeCC(Hotstrings[Match.Options ":" Match.Abbr]) !== Match.Replace {
				ListView.Add(, Match.Options, Match.Abbr, Match.Replace)
				Match.Replace := StringUnescapeCC(Match.Replace)
				Hotstrings[Match.Options ":" Match.Abbr] := Match.Replace
				; Hotstring(":" Match.Options ":" Match.Abbr, Match.Replace, true)
				; Hotstring(":" Match.Options ":" Match.Abbr, HotstringTest.Bind(Match.Replace), true)
				RegExHotstring(Match.Abbr, Match.Replace, Match.Options)
			}
		}
	}
	ListView.ModifyCol(2, "Sort")
	ListView.ModifyCol
	Loop 3
		ListView.ModifyCol(A_Index, "AutoHdr")
}