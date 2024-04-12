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

/**
 * Find and increment a number inside a string
 * @param {String} String input string
 * @param {'First'|'Last'} IncrementMode
 * @param {Integer} Offset value to add
 * @returns {String} output string
 */
StringIncrement(String, IncrementMode, Offset){
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
            newValue := Format("{:0" found.Len "}", found[] + Offset)

            newText := SubStr(String, 1, found.Pos - 1)
            newText .= newValue
            newText .= SubStr(String, found.Pos + found.Len)
            return newText
        }
        return String
    }
}

/**
 * Parse an f-string expression to regex.
 * @param {String} StringTemplate string template with interpolation parameters (e.g. ${name}).
 * @return {String} regex pattern that can be used to match against the template
 */
StringTemplateToRegex(StringTemplate) {
    fstring := "(\$\{(\w+)?\})"
    searchPos := 1
    out := "\Q"

    while foundPos := RegExMatch(StringTemplate, fstring, &result, searchPos) {
        group := result[1]
        token := result[2]

        out .= SubStr(StringTemplate, searchPos, foundPos-searchPos) "\E"
        out .= "(?<" token ">.+?)" "\Q"
        
        searchPos := foundPos + StrLen(group)
    }

    regex := out SubStr(StringTemplate, searchPos) "\E"
    return regex  

}