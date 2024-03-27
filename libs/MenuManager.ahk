class MenuManager {
    __New(context) {
        this.context := context
        
        this.FileMenu := Menu()
        this.FileMenu.Add("&Open Hotstrings...`tCtrl+O", (*) => context.HotstringManager.ShowFileLoad())
        this.FileMenu.Add("&Save Hotstrings`tCtrl+S", (*) => context.HotstringManager.Save(context.SettingsManager.settings['hotstrings']['filePath']))
        this.FileMenu.Add("Save Hotstrings As...", (*) => context.HotstringManager.SaveAs())
        this.FileMenu.Add()
        this.FileMenu.Add("Load Settings...", (*) => context.SettingsManager.PromptLoad())
        this.FileMenu.Add()
        this.FileMenu.Add("Minimize`tWin+H", (*) => context.GuiMain.Hide())
        this.FileMenu.Add("Exit", (*) => ExitApp())
        this.FileMenu.SetIcon("&Open Hotstrings...`tCtrl+O","shell32.dll", 4)
        this.FileMenu.SetIcon("&Save Hotstrings`tCtrl+S","shell32.dll", 259)
        
        this.HelpMenu := Menu()
        this.HelpMenu.Add("&Help`tF1", this.MenuHandler)
        this.HelpMenu.Add()
        this.HelpMenu.Add("About", (*) => this.context.OpenAbout())
        this.HelpMenu.SetIcon("&Help`tF1","shell32.dll", 24)
        this.MenuBar := MenuBar()
        this.MenuBar.Add("&File", this.FileMenu)
        this.MenuBar.Add("Help", this.HelpMenu)
        this.context.GuiMain.MenuBar := this.MenuBar
    }


    MenuHandler(*) {
        ToolTip("Click! This is a sample action.`n", 77, 277)
        SetTimer () => ToolTip(), -3000
    }

    ControlDelayMenuHandler(ItemName, ItemPos, MenuInstance) {
        Switch ItemName {
            case "Send It (Fastest)": 
                this.context.SettingsManager.SetControlDelay(-1)
            case "~0ms (Fast)": 
                this.context.SettingsManager.SetControlDelay(0)
            case "20ms (Default)": 
                this.context.SettingsManager.SetControlDelay(20)
            case "100ms (Slow)": 
                this.context.SettingsManager.SetControlDelay(100)
            case "300ms (Slower)": 
                this.context.SettingsManager.SetControlDelay(300)
            case "1000ms (Turtle)": 
                this.context.SettingsManager.SetControlDelay(1000)
        }
        Loop 6 {
            this.MenuInstance.Uncheck(A_Index . "&")
        }
        this.MenuInstance.Check(ItemPos . "&")
    }

    WindowDelayMenuHandler(ItemName, ItemPos, MenuInstance) {
        Switch ItemName {
            case "Send It (Fastest)": 
                this.context.SettingsManager.SetWindowDelay(-1)
            case "~0ms (Faster)": 
                this.context.SettingsManager.SetWindowDelay(0)
            case "50ms (Fast)": 
                this.context.SettingsManager.SetWindowDelay(50)
            case "100ms (Default)": 
                this.context.SettingsManager.SetWindowDelay(100)
            case "300ms (Slower)": 
                this.context.SettingsManager.SetWindowDelay(300)
            case "1000ms (Turtle)": 
                this.context.SettingsManager.SetWindowDelay(1000)
        }
        Loop 6 {
            this.MenuInstance.Uncheck(A_Index . "&")
        }
        this.MenuInstance.Check(ItemPos . "&")
    }
}
