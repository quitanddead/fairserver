/*
	ZFSS - Zambino's FairServer System v0.5
	A Dayz Epoch server solution proving a dynamic mission system and fun, more interesting missions and a more equitable way of doing them. 
	Not messing with the bandit/hero dynamic, just making the game a little less rage-inducing :)

	Copyright (C) 2014 Jordan Ashley Craw

	This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
 */

if(!isServer) exitWith { diag_log("ZFM: This shouldn't be run by anything other than a server!") };

/*
	System utility variables.
*/
ZFSS_Installed = true;
ZFM_Name = "Zambino FairMission System [ZFM] ";
ZFM_Version = "v0.4.0";

diag_log(format["%1 %2 - ZFM_Initialize.sqf - Waiting for server to initialize.",ZFM_Name,ZFM_Version]);
waitUntil{initialized};

/*
*	ZFM_Includes_Mission_Config
*	
*	Contains the configuration for units and the general runtime configuration of ZFM missions.
*/ 
ZFM_Includes_Mission_Config = "\z\addons\dayz_server\ZFM\Config\ZFM_Mission_Config.sqf";
call compile preprocessFileLineNumbers ZFM_Includes_Mission_Config;


/*
*	ZFM_Includes_Loot_Config
*	
*	Configuration files for loot config..
*/
ZFM_Includes_Loot_Config = "\z\addons\dayz_server\ZFM\Config\ZFM_Loot_Config.sqf";
call compile preprocessFileLineNumbers ZFM_Includes_Loot_Config;

/*
*	ZFM_Includes_Layout_Config
*	
*	Functions for calculating and creating loot
*/
ZFM_Includes_Layout_Config = "\z\addons\dayz_server\ZFM\ZFM_Layout_Config.sqf";
call compile preprocessFileLineNumbers ZFM_Includes_Layout_Config;

/*
*	ZFM_Includes_Mission
*
*	Mission handler.
*/
ZFM_Includes_Mission = "\z\addons\dayz_server\ZFM\ZFM_Mission.sqf";
call compile preprocessFileLineNumbers ZFM_Includes_Mission;

/*
*	ZFM_Includes_Mission_Functions
*	
*	Contains functions for generating and supporting missions
*/
ZFM_Includes_Mission_Functions = "\z\addons\dayz_server\ZFM\ZFM_Mission_Functions.sqf";
call compile preprocessFileLineNumbers ZFM_Includes_Mission_Functions;


/*
*	ZFM_Includes_Loot
*	
*	Functions for calculating and creating loot
*/
ZFM_Includes_Loot = "\z\addons\dayz_server\ZFM\ZFM_Loot.sqf";
call compile preprocessFileLineNumbers ZFM_Includes_Loot;


/*
*	ZFM_Includes_Loot
*	
*	Functions for calculating and creating loot
*/
ZFM_Includes_Layout = "\z\addons\dayz_server\ZFM\ZFM_Layout.sqf";
call compile preprocessFileLineNumbers ZFM_Includes_Layout;

// Remove
ZFM_Layouts_Array =[
	[["CampEast",0,[]],[ZFM_LAYOUT_OBJECT_LOOT,0,["EASY","TKSpecialWeapons_EP1",["PISTOLS","SNIPERS"]]],["CampEast",0,[]]],
	[0,["Land_tent_east",0,[]],0]
];

[ZFM_Layouts_Array,[1,1],[4600,10160,0],20] call ZFM_Layout_Parse;


/*
	Debugging - remove
*/



/*
*	Main (Minimal) init for ZFM
*/

// Declared universally so that ALL AI are put under its spell, rather than one group.

// DEBUGGING - Uncomment to enable BootStrap
// DEBUGGING - Uncomment to enable BootStrap
// DEBUGGING - Uncomment to enable BootStrap
// DEBUGGING - Uncomment to enable BootStrap
//[] call ZFM_DoBootStrap;

// Run the main mission handler -- this loops and waits for mission events to start/finish
//[] call ZFM_Mission_Handler_Start;

// Handle JIP events for players joining after-the-fact so we can update their mission markers
//onPlayerConnected ZFM_Handle_JIP;

