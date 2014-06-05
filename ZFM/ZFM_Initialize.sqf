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
ZFM_Version = "v0.3.5";

diag_log(format["%1 %2 - ZFM_Initialize.sqf - Waiting for server to initialize.",ZFM_Name,ZFM_Version]);
waitUntil{initialized};

/*
	Globals used to ensure that things can function
*/

ZFM_Includes_Mission = "\z\addons\dayz_server\ZFM\ZFM_Mission.sqf";
call compile preprocessFileLineNumbers ZFM_Includes_Mission;

/*
*	ZFM_Includes_Mission_Config
*	
*	Contains the configuration for units and the general runtime configuration of ZFM missions.
*/ 
ZFM_Includes_Mission_Config = "\z\addons\dayz_server\ZFM\Config\ZFM_Mission_Config.sqf";
call compile preprocessFileLineNumbers ZFM_Includes_Mission_Config;

/*
*	ZFM_Includes_Mission_Functions
*	
*	Contains functions for generating and supporting missions
*/
ZFM_Includes_Mission_Functions = "\z\addons\dayz_server\ZFM\ZFM_Mission_Functions.sqf";
call compile preprocessFileLineNumbers ZFM_Includes_Mission_Functions;


/*
*	ZFM_Includes_Mission_Functions
*	
*	Contains functions for handling loot
*/
ZFM_Includes_Loot_Functions = "\z\addons\dayz_server\ZFM\ZFM_LootHandler.sqf";
call compile preprocessFileLineNumbers ZFM_Includes_Loot_Functions;

 
/*
*	ZFM_Includes_Loot_Config
*	
*	Configuration files for loot config..
*/
ZFM_Includes_Loot_Config = "\z\addons\dayz_server\ZFM\Config\ZFM_Loot_Config.sqf";

// We need to get access to these functions..
call compile preprocessFileLineNumbers ZFM_Includes_Loot_Config;


// Bootstrap the AI
[] call ZFM_DoBootStrap;

// Single call to start the mission scheduler..
[] call ZFM_Mission_Handler_Start;

