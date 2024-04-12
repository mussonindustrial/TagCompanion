#Requires AutoHotkey v2.0

/**
 * Create a RegEx Hotstring or replace already existing one
 * @param {String} String [RegEx string](https://www.autohotkey.com/docs/v2/misc/RegEx-QuickRef.htm)
 * @param {Func or String} CallBack calls function with [RegExMatchInfo](https://www.autohotkey.com/docs/v2/lib/RegExMatch.htm#MatchObject)
 * and array of additional params or replace string like [RegExReplace](https://www.autohotkey.com/docs/v2/lib/RegExReplace.htm)
 * @param {String} Options A string of zero or more of the following options (in any order, with optional spaces in between)
 * 
 * Use the following options follow by a zero to turn them off:
 * 
 * `*` (asterisk): An ending character (e.g. Space, Tab, or Enter) is not required to trigger the hotstring.
 * 
 * `?` (question mark): The hotstring will be triggered even when it is inside another word;
 * that is, when the character typed immediately before it is alphanumeric.
 * 
 * `B0` (B followed by a zero): Automatic backspacing is not done to erase the abbreviation you type.
 * Use a plain B to turn backspacing back on after it was previously turned off.
 * 
 * `C`: Case sensitive: When you type an abbreviation, it must exactly match the case defined in the script.
 * 
 * `O`: Omit the ending character of auto-replace hotstrings when the replacement is produced.
 * 
 * `R0`: Don't reset the input buffer after sending replacement text.
 *
 * @param {Params} Params additional params pass to CallBack, check [Variadic functions](https://www.autohotkey.com/docs/v2/Functions.htm#Variadic)
 * and [Variadic function calls](https://www.autohotkey.com/docs/v2/Functions.htm#VariadicCall), only works when CallBack is a function.
 */

NewRegExHotstringHook(context, level := 2) {
	newHook := RegExHotstringHook("V I2")
	newHook.MinSendLevel := level
	newHook.NotifyNonText := true
	newHook.KeyOpt("{Space}{Tab}{Enter}{NumpadEnter}", "+VN")
	newHook.Start()
	newHook.SetContext(context)
	return newHook
}

class RegExHotstringHook extends InputHook {

	hotstrings := Map()
	inputBuffer := "" ; Our own input buffer. Needed for proper tracking during recursive hotstrings.

	SetContext(context) {
		this.context := context
	}

	class RegExHotstring {
		__New(key, regex, replacement, options, on, params*) {
			this.key := key
			this.regex := regex
			this.replacement := replacement
			this.params := params
			this.options := options

			this.opt := Map("*", false, "?", false, "B", true, "C", false, "O", false, "R", true)
			loop parse (options) {
				switch A_LoopField {
					case "*", "?", "B", "C", "O", "R":
						this.opt[A_LoopField] := true
					case "0":
						try
							this.opt[temp] := false
						catch
							throw ValueError("Unknown Option: " A_LoopField)
					case " ":
						continue
					default:
						throw ValueError("Unknown Option: " A_LoopField)
				}
				temp := A_LoopField
			}
			this.regex := this.opt["?"] ? this.regex "$" : "^" this.regex "$"
			this.regex := this.opt["C"] ? this.regex : "xi)" this.regex

			switch on {
				case "On", 1, true:
					this.on := true
				case "Off", 0, false:
					this.on := false
				case "Toggle", -1:
					this.on := true
				default:
					throw ValueError("Unknown OnOffToggle: " on)
			}
		}

		; Convert to an Object representation.
		ToObject() {
			return {
				key: this.key,
				regex: this.regex,
				replacement: this.replacement,
				options: this.options,
				params: this.params
			}
		}
	}

	; Add a new hotstring.
	Add(key, regex, replacement, options := "", OnOffToggle := "On", Params*) {
		toggle := false
		switch OnOffToggle {
			case "Toggle", -1:
				toggle := true
		}

		hs := RegExHotstringHook.RegExHotstring(key, regex, replacement, options, OnOffToggle, Params*)
		if (toggle) {
			try hs.on := !this.hotstrings[key].on
		}
		this.hotstrings[key] := hs
	}
	
	; Delete an existing hotstring.
	Delete(key) {
		return this.hotstrings.Delete(key)
	}
	
	; Get an existing hotstring.
	Get(key) {
		return this.hotstrings.Get(key)
	}

	OnKeyHotstrings {
		get {
			hs := Map()
			for k, v in this.hotstrings {
				if (!v.opt['*']) {
					hs[k] := v
				}
			}
			return hs
		}
	}


	OnCharHotstrings {
		get {
			hs := Map()
			for k, v in this.hotstrings {
				if (v.opt['*']) {
					hs[k] := v
				}
			}
			return hs
		}
	}

	; Clear the hook's input buffer.
	ClearInput() {
		this.Stop()
		this.Start()
		this.inputBuffer := ""
		ToolTip("{CLEARED}")
	}

	OnKeyDown := this.KeyDown
	KeyDown(vk, sc) {

		keyName := GetKeyName(Format("vk{:x}sc{:x}", vk, sc))
		
		switch keyName {
			case "Backspace":
				this.inputBuffer := SubStr(this.inputBuffer, 1, StrLen(this.inputBuffer) - 1)
			case "LShift", "RShift", "LCaps", "RCaps":
			case "Space":
				this.match(this.OnKeyHotstrings, this.inputBuffer, 0, keyName)
			case "Tab", "Enter": 
				if (!this.match(this.OnKeyHotstrings, this.inputBuffer, 0, keyName)) {
					this.ClearInput()						
				}
			default:
				; clear input when press non-text key
				this.ClearInput()	
		}
		ToolTip(this.inputBuffer)
	}

	OnChar := this.char
	char(c) {
		ToolTip(this.inputBuffer)
		switch c {
			case " ":
				this.match(this.OnKeyHotstrings, , 0, c)
			case "`r", "`n", "`t", "`r`n":
				return this.match(this.OnKeyHotstrings, , 0, c)
		}

		this.inputBuffer .= c
		loop parse c {
			this.match(this.OnCharHotstrings, , 1, c)
		}
		ToolTip(this.inputBuffer)
	}

	SendEventInteruptable(text) {
		loop parse text {
			SendEvent("{Text}" A_LoopField)

			; Give space for InputHook to retrigger, and possibly interupt this send.
			Critical("Off")
			Sleep(-1)
			Critical("On")
		}
	}

	match(hotstrings, input := this.inputBuffer, deleteCount := 0, lastKey := "") {

		SendLevel(this.MinSendLevel)		
		SetKeyDelay(-1, 0)

		; Loop through each strings and find the first match
		for , hs in hotstrings {
			if (!hs.on)
				continue

			start := RegExMatch(input, hs.regex, &match)

			; Match Found
			if (start) {
				this.ClearInput()

				; Delete existing text
				if (hs.opt["B"])
					SendEvent("{Backspace " match.Len[0] + 1 - deleteCount "}")

				; Perform string replacement.
				if (hs.replacement is String) {
					withGlobals := this.context.GlobalValues.ApplyTo(hs.replacement)
					replacedString := RegExReplace(SubStr(input, start), hs.regex, withGlobals)
					this.SendEventInteruptable(replacedString)

				} else if (hs.replacement is Func) {
					hs.replacement(match, hs.params*)

				} else {
					throw TypeError('Replacement should be "String" or "Function"')
				}

				; Resend the last key
				if (!hs.opt["O"] && !hs.opt["*"]) {
					SendEvent("{" lastKey "}")
				}

				; Give space for any sends to finish.
				Critical("Off")
				Sleep(-1)
				Critical("On")

				; Reset the Input buffer
				if (hs.opt["R"]) {
					this.ClearInput()
				}

				return true
			}
		}

		return false
	}
}