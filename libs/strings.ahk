; Escape / Unescape Control Characters
StringEscapeCC(String)
{
	String := StrReplace(String, "`n", "``n")
	String := StrReplace(String, "`t", "``t")
	String := StrReplace(String, "`b", "``b")
	Return String
}

; Unescape Control Characters
StringUnescapeCC(String)	
{
	String := StrReplace(String, "``n", "`n")
	String := StrReplace(String, "``t", "`t")
	String := StrReplace(String, "``b", "`b")
	Return String
}

;Find and increment the number in a string
; * @param {'First'|'Last'} IncrementMode
StringIncrement(String, IncrementMode, offset){

    regex := ""

    Switch IncrementMode {
        case "First":
            regex := "(\d+)"
        case "Last":
            regex := "(\d+)(?!.*\d+)"
    }

    if (regex == "") {
        return String
    } else {
        if RegExMatch(String, regex, &found) {
            newValue := Format("{:0" found.Len "}", found[] + offset)

            newText := SubStr(String, 1, found.Pos - 1)
            newText .= newValue
            newText .= SubStr(String, found.Pos + found.Len)
            return newText
        }
        return String
    }
}