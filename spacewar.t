import GUI in "%oot/lib/GUI"


include "object.ti"
include "recordtypes.ti"
include "common.th"
include "config.ti"

const MainMenuBG : int := Pic.FileNew("images/MainMenu.bmp")
const NewGameBG : int := Pic.FileNew("images/NewGame.bmp")
const ConfigBG : int := Pic.FileNew("images/Config.bmp")
const HelpBG : int := Pic.FileNew("images/Help.bmp")

var *WpnImages           : array 1 .. 1 of int
WpnImages(1) := Pic.FileNew("images/wpn_massdriver.bmp")
var *AltWpnImages        : array 1 .. 1 of int
AltWpnImages(1) := Pic.FileNew("images/wpn_impactmsl.bmp")
var *fpsavg : int :=30
var *Players : array 1 .. 2 of PlayerStats
var *ExitConditions : boolean := false

var *knot : ^node
var *current : ^node
var *SWConf : Configuration

include "primaries.ti"
include "secondaries.ti"
include "boxes.ti"

var *input : array char of boolean
new knot
current := knot
new knot->next
knot->prev := knot->next
knot->next->next := knot
knot->next->prev := knot

SWConf.PlayerHP := 100
SWConf.Player1Color := 9
SWConf.Player2Color := 10
SWConf.PlayerAccel := 0.512

SWConf.Gravity := 8
SWConf.KillsToWin := 15
SWConf.DeathsToLose := 15
SWConf.MissilesPerPack := 5

SWConf.DamagePerBullet := 5
SWConf.DamagePerMiniBeam := 1
SWConf.DamagePerLightBeam := 5
SWConf.DamagePerHeavyBeam := 5
SWConf.DamagePerMissileImpact := 20
SWConf.DamagePerMissileBlast := 100
SWConf.DamagePerMissileNeedler := 2

SWConf.MiniBeamRange := 60
SWConf.LightBeamRange := 120
SWConf.HeavyBeamRange := 320
SWConf.MissileImpactAccel := 0.1
SWConf.MissileBlastAccel := 0.3
SWConf.MissileNeedlerAccel := 0.4
SWConf.MissileBeamAccel := 0.2

SWConf.InitMassDriver := true
SWConf.InitWMassDriver := false
SWConf.InitXRL :=false
SWConf.InitBrightLance := false
SWConf.InitImpactMissiles := 5
SWConf.InitBlastMissiles := 0
SWConf.InitNeedlers := 0
SWConf.InitBeamMissiles := 0

SWConf.Key1Up := 'w'
SWConf.Key1Lf := 'a'
SWConf.Key1Rt := 'd'
SWConf.Key1Gun := 's'
SWConf.Key1Msl := 'x'
SWConf.Key1NextGun := 'z'
SWConf.Key1NextMsl := 'c'

SWConf.Key2Up := '8'
SWConf.Key2Lf := '4'
SWConf.Key2Rt := '6'
SWConf.Key2Gun := '5'
SWConf.Key2Msl := '2'
SWConf.Key2NextGun := '1'
SWConf.Key2NextMsl := '3'

include "weapons.ti"
include "missiles.ti"
include "player.ti"
include "system.ti"

Text.ColorBack(7)
Text.Color(0)
cls
var FontMain : int := Font.New ("impact:36")
var FontTitle : int := Font.New ("impact:12")
var FontSub : int := Font.New ("impact:8")
var FontMid : int := Font.New ("impact:32")
var ExitCall : boolean := false

GUI.SetDisplayWhenCreated(false)

include "mainmenuwidgets.ti"
include "newgamewidgets.ti"
include "remapmenuwidgets.ti"
include "helpmenuwidgets.ti"
include "configmenuwidgets.ti"

var ConfigItemTypes : array 1 .. 22 of string(40)

ConfigItemTypes(1) := "int:1|9999;Player HP"      %player HP
ConfigItemTypes(2) := "int:1|9999;Bullet Damage "      %damage
ConfigItemTypes(3) := "int:1|9999;XRL Damage"      %damage
ConfigItemTypes(4) := "int:1|9999;Bright Lance Damage"      %damage
ConfigItemTypes(5) := "int:1|9999;Impacter Damage"      %damage
ConfigItemTypes(6) := "int:1|9999;TCPW Damage"      %damage
ConfigItemTypes(7) := "int:1|9999;Needler Damage"      %damage
ConfigItemTypes(8) := "int:1|9999;Beam Missile Damage"      %damage
ConfigItemTypes(9) := "int:1|1024;Kills To Win"      %kills
ConfigItemTypes(10) := "int:1|1024;Deaths To Lose"      %deaths

GUI.SetCheckBox(NewGameWidgets(3),true)

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
%Main

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

body procedure RemapKeys()    
    for i : 1 .. 5
        GUI.Hide(MainMenuButtons(i))
    end for
    for i : 1..15
        GUI.Show(RemapWidgets(i))
    end for
    Pic.Draw(ConfigBG,0,0,0)
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
    GUI.Refresh
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
%include "menus.ti"
include "main.ti"
include "enginemath.ti"
include "nodeops.ti"
include "effects.ti"
%include "menu_config.ti"
