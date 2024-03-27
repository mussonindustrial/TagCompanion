HighlightMacro(Settings, &Code) {
	; Thank you to the Rouge project for compiling these keyword lists
	; https://github.com/jneen/rouge/blob/master/lib/rouge/lexers/javascript.rb
	static Keywords := "for|in|of|while|do|break|return|continue|switch|case|default|if|else|throw|try|catch|finally|new|delete|typeof|instanceof|void|this|yield|import|export|from|as|async|super|this"
	, Declarations := "var|let|const|with|function|class|extends|constructor|get|set"
	, Constants := "true|false|null|NaN|Infinity|undefined"
	, Builtins := "Array|Boolean|Date|Error|Function|Math|netscape|Number|Object|Packages|RegExp|String|sun|decodeURI|decodeURIComponent|encodeURI|encodeURIComponent|Error|eval|isFinite|isNaN|parseFloat|parseInt|document|window|console|navigator|self|global|Promise|Set|Map|WeakSet|WeakMap|Symbol|Proxy|Reflect|Int8Array|Uint8Array|Uint8ClampedArray|Int16Array|Uint16Array|Uint16ClampedArray|Int32Array|Uint32Array|Uint32ClampedArray|Float32Array|Float64Array|DataView|ArrayBuffer"
    , Needle := (						; opens a "continuation by enclosure" for better readability
        "ims)"							; options for the regex needle: i=caseinsensitive  m=multiline  s=DotAll  )=end of options      see https://www.autohotkey.com/docs/v2/misc/RegEx-QuickRef.htm
        "(\/\/[^\n]+)"               	; Comments
        "|(\/\*.*?\*\/)"             	; Multiline comments
        "|([+*!~&\/\\<>^|=?:@;"      	; Punctuation
        ",().```%{}\[\]\-]+)"        	; Punctuation (continued)
        "|\b(0x[0-9a-fA-F]+|[0-9]+)" 	; Numbers
        "|(`"[^`"]*`"|'[^']*')"      	; Strings
        "|\b(" Constants ")\b"       	; Constants
        "|\b(" Keywords ")\b"        	; Keywords
        "|\b(" Declarations ")\b"    	; Declarations
        "|\b(" Builtins ")\b"        	; Builtins
        "|(\$\{(.*?)\})"                ; String Template
        "|(([a-zA-Z_$]+)(?=\())"     	; Functions
        
    )									; closes the "continuation by enclosure"


	GenHighlighterCache(Settings)
	ColMap := Settings.Cache.ColorMap

	RTF := ""

	Pos := 1
	while FoundPos := RegExMatch(Code, Needle, &Match, Pos) {
		RTF .= (													;continuation by enclosure
			"\cf" ColMap.Plain " "
			EscapeRTF(SubStr(Code, Pos, FoundPos - Pos))
			"\cf" (
				Match.1 ? ColMap.Comments :
				Match.2 ? ColMap.Multiline :
				Match.3 ? ColMap.Punctuation :
				Match.4 ? ColMap.Numbers :
				Match.5 ? ColMap.Strings :
				Match.6 ? ColMap.Constants :
				Match.7 ? ColMap.Keywords :
				Match.8 ? ColMap.Declarations :
				Match.9 ? ColMap.Builtins :
				Match.11 ? ColMap.Functions :
                Match.10 ? ColMap.StringTemplates :
				ColMap.Plain
			) " "
			EscapeRTF(Match.0)
		)
		Pos := FoundPos + Match.Len()
	}

	return (
		Settings.Cache.RTFHeader
		RTF
		"\cf" ColMap.Plain " "
		EscapeRTF(SubStr(Code, Pos))
		"\`n}"
	)
}




GenHighlighterCache(Settings)
{
	if Settings.HasOwnProp("Cache")
		return
	Cache := Settings.Cache := {}


	; --- Process Colors ---
	Cache.Colors := Settings.Colors.Clone()

	; Inherit from the Settings array's base
	BaseSettings := Settings
	while (BaseSettings := BaseSettings.Base)
		if BaseSettings.HasProp("Colors")
			for Name, Color in BaseSettings.Colors.OwnProps()
				if !Cache.Colors.HasProp(Name)
					Cache.Colors.%Name% := Color

	; Include the color of plain text
	if !Cache.Colors.HasOwnProp("Plain")
		Cache.Colors.Plain := Settings.FGColor

	; Create a Name->Index map of the colors
	Cache.ColorMap := {}
	for Name, Color in Cache.Colors.OwnProps()
		Cache.ColorMap.%Name% := A_Index


	; --- Generate the RTF headers ---
	RTF := "{\urtf"

	; Color Table
	RTF .= "{\colortbl;"
	for Name, Color in Cache.Colors.OwnProps()
	{
		RTF .= "\red"   Color>>16 & 0xFF
		RTF .= "\green" Color>>8  & 0xFF
		RTF .= "\blue"  Color     & 0xFF ";"
	}
	RTF .= "}"

	; Font Table
	if Settings.Font
	{
		FontTable .= "{\fonttbl{\f0\fmodern\fcharset0 "
		FontTable .= Settings.Font.Typeface
		FontTable .= ";}}"
		RTF .= "\fs" Settings.Font.Size * 2 ; Font size (half-points)
		if Settings.Font.Bold
			RTF .= "\b"
	}

	; Tab size (twips)
	RTF .= "\deftab" GetCharWidthTwips(Settings.Font) * Settings.TabSize

	Cache.RTFHeader := RTF
}

GetCharWidthTwips(Font)
{
	static Cache := Map()

	if Cache.Has(Font.Typeface "_" Font.Size "_" Font.Bold)
		return Cache[Font.Typeface "_" font.Size "_" Font.Bold]

	; Calculate parameters of CreateFont
	Height := -Round(Font.Size*A_ScreenDPI/72)
	Weight := 400+300*(!!Font.Bold)
	Face := Font.Typeface

	; Get the width of "x"
	hDC := DllCall("GetDC", "UPtr", 0)
	hFont := DllCall("CreateFont"
	, "Int", Height ; _In_ int     nHeight,
	, "Int", 0      ; _In_ int     nWidth,
	, "Int", 0      ; _In_ int     nEscapement,
	, "Int", 0      ; _In_ int     nOrientation,
	, "Int", Weight ; _In_ int     fnWeight,
	, "UInt", 0     ; _In_ DWORD   fdwItalic,
	, "UInt", 0     ; _In_ DWORD   fdwUnderline,
	, "UInt", 0     ; _In_ DWORD   fdwStrikeOut,
	, "UInt", 0     ; _In_ DWORD   fdwCharSet, (ANSI_CHARSET)
	, "UInt", 0     ; _In_ DWORD   fdwOutputPrecision, (OUT_DEFAULT_PRECIS)
	, "UInt", 0     ; _In_ DWORD   fdwClipPrecision, (CLIP_DEFAULT_PRECIS)
	, "UInt", 0     ; _In_ DWORD   fdwQuality, (DEFAULT_QUALITY)
	, "UInt", 0     ; _In_ DWORD   fdwPitchAndFamily, (FF_DONTCARE|DEFAULT_PITCH)
	, "Str", Face   ; _In_ LPCTSTR lpszFace
	, "UPtr")
	hObj := DllCall("SelectObject", "UPtr", hDC, "UPtr", hFont, "UPtr")
	size := Buffer(8, 0)
	DllCall("GetTextExtentPoint32", "UPtr", hDC, "Str", "x", "Int", 1, "Ptr", SIZE)
	DllCall("SelectObject", "UPtr", hDC, "UPtr", hObj, "UPtr")
	DllCall("DeleteObject", "UPtr", hFont)
	DllCall("ReleaseDC", "UPtr", 0, "UPtr", hDC)

	; Convert to twpis
	Twips := Round(NumGet(size, 0, "UInt")*1440/A_ScreenDPI)
	Cache[Font.Typeface "_" Font.Size "_" Font.Bold] := Twips
	return Twips
}

EscapeRTF(Code)
{
	for Char in ["\", "{", "}", "`n"]
		Code := StrReplace(Code, Char, "\" Char)
	return StrReplace(StrReplace(Code, "`t", "\tab "), "`r")
}


