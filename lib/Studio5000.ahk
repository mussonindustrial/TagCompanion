#Requires AutoHotkey v2.0

; Running Studio5000 Instance
class Studio5000 {

    ; Create a new tag using the "New Tag" editor.
    static CreateTag(tag) {

        tagWindow := NewTagWindow.Open()
        tagWindow.ApplyTag(tag)
        success := tagWindow.Create()
        if (!success) {
            errorWindow := NewTagErrorWindow.GetByWait()
            if (errorWindow.handle) {
                errorWindow.Ok()
                tagWindow.Cancel()
            } 
            tagWindow.WaitClose()
        }
        return success != 0
    }

    static CopyTagNameToDescription() {
        tagWindow := NewTagWindow.GetByWaitActive()
        tagWindow.Description := tagWindow.Name . "`r`nSuggested Description"
    }

}



class TagUsage {
    static Local := "Local Tag"
    static Input := "Input Parameter"
    static Output := "Output Parameter"
    static InputOutput := "InputOutput Parameter"
    static Public := "Public Parameter"
}

class TagType {
    static _Base := "Base"
    static Alias := "Alias"
    static Produced := "Produced"
    static Consumed := "Consumed"
}

class TagExternalAccess {
    static None := "None"
    static Read := "Read"
    static ReadWrite := "Read/Write"
}

class TagStyle {
    static Binary := "Binary"
    static Octal := "Octal"
    static Decimal := "Decimal"
    static Hex := "Hex"
    static ASCII := "ASCII"
    static Float := "Float"
    static Exponential := "Exponential"
}

GroupAdd("NewTag", "New Tag")
GroupAdd("NewTag", "New Parameter or Tag")

class NewTagWindow {

    static title := "ahk_group NewTag"

    static control := {
        name: "Edit1",
        description: "Edit2",
        alias: "Edit3" ,
        datatype: "Edit4",
        usage: "ComboBox1",
        type: "ComboBox2",
        scope: "ComboBox3",
        externalAccess: "ComboBox4",
        style: "ComboBox5",
        constant: "Button6",
        create: "Button10",
        cancel: "Button11"
    }

    __New(handle) {
        this.handle := handle
    }

    static Open() {
        Send "{Ctrl Down}w{Ctrl Up}"
        handle := WinWaitActive(NewTagWindow.title)
        return NewTagWindow(handle)
    }

    static GetByWait(timeout := 5) {
        handle := WinWait(NewTagWindow.title,,timeout)
        return NewTagWindow(handle)
    }

    static GetByWaitActive(Seconds := 0) {
        handle := WinWaitActive(NewTagWindow.title,,Seconds)
        return NewTagWindow(handle)
    }

    WaitClose() {
        return WinWaitClose(this.handle)
    }


    Cancel() {
        ControlClick(NewTagWindow.control.cancel, this.handle)
    }

    Create() {
        ControlClick(NewTagWindow.control.create, this.handle)
        return WinWaitClose(this.handle,,1)
    }

    ApplyTag(tag) {
        this.Name := tag.Get("Name")
        this.Description := tag.Get("Description", "")
        this.Alias := tag.Get("Alias", "")
        this.Datatype := tag.Get("Datatype")
        this.Usage := tag.Get("Usage", TagUsage.Local)
        this.Type := tag.Get("Type", TagType._Base)
        this.Scope := tag.Get("Scope", "")
        this.ExternalAccess := tag.Get("ExternalAccess", TagExternalAccess.ReadWrite)
        this.Style := tag.Get("Style", "")
        this.Constant := tag.Get("Constant", false)
    }

    Name {
        get => ControlGetText(NewTagWindow.control.name, this.handle)
        set => ControlSetText(value, NewTagWindow.control.name, this.handle)
    }

    Description {
        get => ControlGetText(NewTagWindow.control.description, this.handle)
        set => ControlSetText(value, NewTagWindow.control.description, this.handle)
    }

    Alias {
        get => ControlGetText(NewTagWindow.control.alias, this.handle)
        set => ControlSetText(value, NewTagWindow.control.alias, this.handle)
    }

    Datatype {
        get => ControlGetText(NewTagWindow.control.datatype, this.handle)
        set => ControlSetText(value, NewTagWindow.control.datatype, this.handle)
    }

    Usage {
        get => ControlGetChoice(NewTagWindow.control.usage, this.handle)
        set => ControlChooseString(value, NewTagWindow.control.usage, this.handle)
    }

    Type {
        get => ControlGetChoice(NewTagWindow.control.type, this.handle)
        set => ControlChooseString(value, NewTagWindow.control.type, this.handle)
    }

    Scope {
        get => ControlGetChoice(NewTagWindow.control.scope, this.handle)
        set => ControlChooseString(value, NewTagWindow.control.scope, this.handle)
    }

    ExternalAccess {
        get => ControlGetChoice(NewTagWindow.control.externalAccess, this.handle)
        set => ControlChooseString(value, NewTagWindow.control.externalAccess, this.handle)
    }

    Style {
        get => ControlGetChoice(NewTagWindow.control.style, this.handle)
        set => ControlChooseString(value, NewTagWindow.control.style, this.handle)
    }

    Constant {
        get => ControlGetChecked(NewTagWindow.control.constant, this.handle)
        set => ControlSetChecked(value, NewTagWindow.control.constant, this.handle)
    }
}

class NewTagErrorWindow {
    static text := "Failed to create a new tag."

    static control := {
        ok: "Button1"
    }

    __New(handle) {
        this.handle := handle
    }

    static GetByWait(timeout := 5 ) {
        handle := WinWait(,this.text,timeout)
        return NewTagErrorWindow(handle)
    }

    static GetByWaitActive(Seconds := 0) {
        handle := WinWaitActive(this.text,,Seconds)
        return NewTagErrorWindow(handle)
    }

    Ok() {
        ControlClick(NewTagErrorWindow.control.ok, this.handle)
    }
}