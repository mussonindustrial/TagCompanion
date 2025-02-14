#Include "strings.ahk"

ClipboardIncrement(IncrementMode, offset) {
    ; Save the entire clipboard contents.
    ClipSaved := ClipboardAll()

    ; Reset clipboard and wait for copy.
    A_Clipboard := ""
    SendInput("^c")
    ClipWait(1)

    ; Convert to text and check for contents.
    A_Clipboard := A_Clipboard
    if A_Clipboard == "" {
        return
    }

    ; Loop through the clipboard and increment.
    i := 0
    newText := ""
    Loop Parse A_Clipboard, "`n" {
        newText .= StringIncrement(A_LoopField, IncrementMode, offset)
        i := i + 1
    }

    SendInput newText

    ; Reselect the current region
    Loop (StrLen(newText)) {
        SendInput("+{Up}")
    }
    ; SendInput("^+{Left}")
    if i > 1 {
        Loop (i - 1) {
            SendInput("^+{Up}")
        }

    }

    ; Restore the original clipboard.
    A_Clipboard := ClipSaved 
    ClipSaved := ""
}