#Include "..\include\GuiReSizer.ahk"

#Include "HotstringManager.ahk"
#Include "MenuManager.ahk"
#Include "SettingsManager.ahk"


class TagCompanionContext {
    __New() {
        this.SettingsManager := SettingsManager(this)
        this.HotstringManager := HotstringManager(this)

        this.SettingsManager.Load(SettingsManager.configPath)	

        this.GuiMain := Gui()
        this.GuiMain.Title := "Tag Companion"
        this.GuiMain.OnEvent("Size", GuiResizer)
        this.GuiMain.OnEvent("Escape", (*) => this.GuiMain.Hide)
        this.GuiMain.OnEvent("Close", (*) => {})
        this.GuiMain.Opt("+Resize +MinSize450x350")

        this.MenuManager := MenuManager(this)

        this.GuiAbout := Gui()
        this.GuiAbout.Title := "About"
        this.GuiAbout.OnEvent("Size", GuiResizer)
        this.GuiAbout.Opt("+MinSize450x350")
        this.GuiAbout.Text := {}, this.GuiAbout.Pic := {}, this.GuiAbout.Button := {}
        this.GuiAbout.Pic.Logo := this.GuiAbout.Add("Pic", "w-1 h40 -Border", "HBITMAP:*" LoadPicture(".\images\logo.png"))
        this.GuiAbout.Pic.Logo.Y := 16
        this.GuiAbout.Button.Close := this.GuiAbout.Add("Button",,"Close")
        this.GuiAbout.Button.Close.OnEvent("Click", (*) => this.CloseAbout())
        this.GuiAbout.Button.Close.W := 100
        this.GuiAbout.Button.Close.H := 50
        this.GuiAbout.Button.Close.X := -30 - this.GuiAbout.Button.Close.W
        this.GuiAbout.Button.Close.Y := 12
        this.GuiAbout.Text.Name := this.GuiAbout.Add("Text",,"Tag Companion ${{VERSION}} (x64)")
        license := "
        (
        Copyright (C) 2024 Musson Industrial

        This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
        
        This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
        
        You should have received a copy of the GNU General Public License along with this program; if not, see <a href="http://www.gnu.org/licenses/gpl-3.0">here</a>.
        )"
        this.GuiAbout.Text.License := this.GuiAbout.Add("Link","w400",license)
    }

    OpenAbout() {
        this.GuiAbout.Show()
    }

    CloseAbout() {
        this.GuiAbout.Hide
    }
}