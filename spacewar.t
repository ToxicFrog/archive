%version 1.02
import GUI in "%oot/lib/GUI"

%Object class proto
include "object.ti"
%record definitions
include "recordtypes.ti"
%function headers
include "common.th"
%consts
include "config.ti"

%background screens
const MainMenuBG : int := Pic.FileNew("images/MainMenu.bmp")
const NewGameBG : int := Pic.FileNew("images/NewGame.bmp")
const ConfigBG : int := Pic.FileNew("images/Config.bmp")
const RemapBG : int := Pic.FileNew("images/Remap.bmp")
const HelpBG : int := Pic.FileNew("images/Help.bmp")

%loadout indicators
var *WpnImages           : array 1 .. 1 of int
WpnImages(1) := Pic.FileNew("images/wpn_massdriver.bmp")
var *AltWpnImages        : array 1 .. 1 of int
AltWpnImages(1) := Pic.FileNew("images/wpn_impactmsl.bmp")
var *fpsavg : int :=30
var *Players : array 1 .. 2 of PlayerStats
var *ExitConditions : boolean := false

%handle node to The Ring
var *knot : ^node
var *current : ^node

%configuration record instance
var *SWConf : Configuration

%weapon % item stats
include "primaries.ti"
include "secondaries.ti"
include "boxes.ti"

%initialize The Ring
var *input : array char of boolean
new knot
current := knot
new knot->next
knot->prev := knot->next
knot->next->next := knot
knot->next->prev := knot

%SWConf settings
include "defaults.ti"
%weapon class defs
include "weapons.ti"
include "missiles.ti"
%the engine itself
include "player.ti"
include "system.ti"

%set up text and fonts
Text.ColorBack(7)
Text.Color(0)
cls
var FontMain : int := Font.New ("impact:36")
var FontTitle : int := Font.New ("impact:12")
var FontSub : int := Font.New ("impact:8")
var ExitCall : boolean := false

%widgets appear invisible by default now
GUI.SetDisplayWhenCreated(false)

%widgets for shell
include "mainmenuwidgets.ti"
include "newgamewidgets.ti"
include "remapmenuwidgets.ti"
include "helpmenuwidgets.ti"
include "configmenuwidgets.ti"
GUI.SetCheckBox(NewGameWidgets(3),true)

%initialize the shell
for i : 1 .. 5
    GUI.Show(MainMenuButtons(i))
end for
Pic.Draw(MainMenuBG,0,0,0)
GUI.Refresh
Font.Draw ("MAIN MENU", 275, 650, FontMain, white)
View.Update
loop
    exit when GUI.ProcessEvent
end loop
GUI.CloseWindow(Window.GetActive())

%called to do final configuration for a new game
body procedure StartNewGame()
    for i : 1 .. 5
        GUI.Hide(MainMenuButtons(i))
    end for
    for i : 1..12
    GUI.Show(NewGameWidgets(i))
    end for
    cls
    Pic.Draw(NewGameBG,0,0,0)
    GUI.Refresh
    Font.Draw ("NEW GAME", 275, 650, FontMain, 30)
    Font.Draw("Player 1 Color",32,495,FontTitle,black)
    Font.Draw("Player 2 Color",32,460,FontTitle,black)
    Font.Draw("Start with Mass Driver",164,400,FontTitle,black)
    Font.Draw("Start with Double Mass Driver",164,352,FontTitle,black)
    Font.Draw("Start with X-ray Lasers",164,304,FontTitle,black)
    Font.Draw("Start with Bright Lance",164,256,FontTitle,black)
    Font.Draw("Impacters",32,216,FontTitle,black)
    Font.Draw("TCPWs",32,181,FontTitle,black)
    Font.Draw("Needlers",32,146,FontTitle,black)
    Font.Draw("Beamers",32,111,FontTitle,black)
    UpdatePlayer1ColorSlider(SWConf.Player1Color)
    UpdatePlayer2ColorSlider(SWConf.Player2Color)
    UpdateMassDriver(SWConf.InitMassDriver)
    UpdateWMassDriver(SWConf.InitWMassDriver)
    UpdateXRL(SWConf.InitXRL)
    UpdateBrightLance(SWConf.InitBrightLance)
    UpdateInitImpactMissiles(SWConf.InitImpactMissiles)
    UpdateInitBlastMissiles(SWConf.InitBlastMissiles)
    UpdateInitNeedlers(SWConf.InitNeedlers)
    UpdateInitBeamMissiles(SWConf.InitBeamMissiles)
    loop
        exit when GUI.ProcessEvent or ExitCall
    end loop
    ExitCall := false
    for i : 1 .. 5
        GUI.Show(MainMenuButtons(i))
    end for
    for i : 1..12
        GUI.Hide(NewGameWidgets(i))
    end for
    Pic.Draw(MainMenuBG,0,0,0)
    GUI.Refresh
    Font.Draw ("MAIN MENU", 275, 650, FontMain, white)
    View.Update
end StartNewGame

%change the keybindings
body procedure RemapKeys()    
    for i : 1 .. 5
        GUI.Hide(MainMenuButtons(i))
    end for
    for i : 1..15
        GUI.Show(RemapWidgets(i))
    end for
    Pic.Draw(HelpBG,0,0,0) %we do this because RemapBG is 20 pixels too thin, so we fill in the gap with HelpBG
    Pic.Draw(RemapBG,20,0,0)
    GUI.Refresh
    Font.Draw ("   REMAP ", 275, 650, FontMain, white)
    Font.Draw("Player 1",200,590,FontTitle,white)
    Font.Draw("Player 2",508,590,FontTitle,white)
    Font.Draw("  Thrust",340,555,FontTitle,white)
    Font.Draw(" Turn Left",340,505,FontTitle,white)
    Font.Draw(" Turn Right",340,455,FontTitle,white)
    Font.Draw("  Fire Gun",340,405,FontTitle,white)
    Font.Draw("Fire Missile",340,355,FontTitle,white)
    Font.Draw("  Next Gun",340,305,FontTitle,white)
    Font.Draw("Next Missile",340,255,FontTitle,white)
    Font.Draw("Click on a button to change the associated binding",100,100,FontTitle,white)
    Font.Draw("Then, press the key you wish to bind",100,50,FontTitle,white)
    
    View.Update
    loop
        exit when GUI.ProcessEvent or ExitCall
    end loop
    ExitCall := false
    for i : 1 .. 5
        GUI.Show(MainMenuButtons(i))
    end for
    for i : 1..15
        GUI.Hide(RemapWidgets(i))
    end for
    Pic.Draw(MainMenuBG,0,0,0)
    GUI.Refresh
    Font.Draw ("MAIN MENU", 275, 650, FontMain, white)
    View.Update
end RemapKeys

body procedure ChangeConfig()
    for i : 1 .. 5
        GUI.Hide(MainMenuButtons(i))
    end for
    for i : 1..3
        GUI.Show(ConfigMenuWidgets(i))
    end for
    Pic.Draw(ConfigBG,0,0,0)
    ShowOtherConfig
    %GUI.Refresh
    View.Update
    loop
        exit when GUI.ProcessEvent or ExitCall
    end loop
    ExitCall := false
    for i : 1 .. 5
        GUI.Show(MainMenuButtons(i))
    end for
    for i : 1..11
        GUI.Hide(ConfigMenuSystemWidgets(i))
    end for
    for i : 1..7
        GUI.Hide(ConfigMenuDamageWidgets(i))
    end for
    for i : 1..3
        GUI.Hide(ConfigMenuWidgets(i))
    end for
    Pic.Draw(MainMenuBG,0,0,0)
    GUI.Refresh
    Font.Draw ("MAIN MENU", 275, 650, FontMain, white)
    View.Update
end ChangeConfig

%display the help screen widgets
body procedure ShowHelp
    for i : 1 .. 5
        GUI.Hide(MainMenuButtons(i))
    end for
    for i : 1..6
        GUI.Show(HelpMenuWidgets(i))
    end for
    Pic.Draw(HelpBG,0,0,0)
    GUI.Refresh
    View.Update
    loop
        exit when GUI.ProcessEvent or ExitCall
    end loop
    ExitCall := false
    for i : 1 .. 5
        GUI.Show(MainMenuButtons(i))
    end for
    for i : 1..6
        GUI.Hide(HelpMenuWidgets(i))
    end for
    Pic.Draw(MainMenuBG,0,0,0)
    GUI.Refresh
    Font.Draw ("MAIN MENU", 275, 650, FontMain, white)
    View.Update
end ShowHelp

%the heart of Spacewar
include "main.ti"
%trig functions
include "enginemath.ti"
%Ring functions
include "nodeops.ti"
%beams 'n' stuff
include "effects.ti"
