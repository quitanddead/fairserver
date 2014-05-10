/*
	ZFSS - Zambino's FairServer System v0.5
	A DayZ epoch script to limit the impact of assholes on servers.  Very loosely based on the "Safezone commander" script by AlienX.
	Copyright (C) 2014 Jordan Ashley Craw

	This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
 */
 private["_aiGroup","_playerz","_playerPos","_playerPoop","_unit"];
 
 ZFM_GROUP_EAST = objNull;
 ZFM_GROUP_WEST = objNull;
 ZFM_GROUP_CIVILIAN = objNull;
 ZFM_GROUP_RESISTANCE = objNull;

 /*
 *	ZFM AI Types
 *
 *	These are simple constants used for AI types.
 */
 
 ZFM_AI_TYPE_SNIPER = "1x101010";
 
 /*
 *	ZFM_InitUnitSpawn
 *
 *	Test function for creating AI.
 */
 ZFM_InitUnitSpawn = {
	private ["_groupHQ","_skin","_spawnAt","_person","_unit"];
	
	// Get the Group HQ
	_groupHQ = _this select 0;
	_skin = _this select 1;
	_spawnAt = _this select 2;
	
	// Create a unit!
	_unit = _groupHQ createUnit [_skin,_spawnAt,[], 10, "PRIVATE"];

	diag_log(format["Spawned Unit at %1,%2",getPos _person,Position _person]);
	titleText[format["Spawned Unit at %1,%2",getPos _person,Position _person],"PLAIN DOWN"];
	
	// Join the group
	[_unit] joinSilent _groupHQ;
	
	// Get rid of everything they're carrying.
	removeAllWeapons _unit;

	_unit
};
 
/*
*	ZFM_CreateAIGroup
*
*	Create a group for a group of AI.
*/
ZFM_CreateAIGroup = {
	private ["_sideType","_createdGroup"];
	_sideType = _this select 0;

	// Create a group with the specific side type.
	_createdGroup = createGroup _sideType;
	
	//Return the group
	_createdGroup
};

ZFM_AI_Get_View_Distance = {
	private ["_difficulty","_viewRange"];
	
	_difficulty = _this select 0;
	
	_viewRange = 50;
	
	switch(_difficulty) do
	{
		case "DEADMEAT": {
			_viewRange = 30;
		};
		case "EASY": {
			_viewRange = 60;
		};
		case "MEDIUM": {
			_viewRange = 100;
		};
		case "HARD": {
			_viewRange = 200;
		};
		case "WAR_MACHINE": {
			_viewRange = 400;
		};
	};
	
	_viewRange
	
};

/*
*	ZFM_AI_Find_Nearby_Cover
*
*	Used for any type. Will find nearby trees to hide in.
*/
ZFM_AI_Find_Nearby_Cover = {
	private["_unit","_issuingUnit","_difficulty","_unitPosition","_viewRange","_nearbyTrees","_nearestTree","_nearestTreeFound","_objectName"];
	
	_unit = _this select 0;
	_issuingUnit = _this select 1;
	_difficulty = _this select 2;
	
	// Find out where the unit is.
	_unitPosition = getPos _unit;
		
	// Array for nearest tree..
	_nearestTree = [];

	// How many trees are there? So far none, but when we search.. ? 
	_nearbyTrees = 0;
	
	// Get the viewRange for the units.
	_viewRange = [_difficulty] call ZFM_AI_Get_View_Distance;
	
	diag_log(format["View range: %1",_viewRange]);
	
	_nearestTreeFound = false;
	{
		if("" == typeOf _x) then
		{
			if(alive _x ) then 
			{
				
				_objectName = _x call DZE_getModelName;
				
				diag_log(format["objectName: %1",_objectName]);
				
				if(_objectName in DZE_trees) then
				{
					if(!_nearestTreeFound) then
					{
						// Add to an array.
						_nearestTree set [(count _nearestTree),_x];
						_nearestTreeFound = true;
						diag_log("Found nearby tree..");
					};
					_nearbyTrees = _nearbyTrees + 1;
				};
			};
		};
	} forEach nearestObjects [getPos _unit,[],_viewRange];

	if(_nearbyTrees > 3) then
	{
		// Tell the group
		if(_difficulty == "HARD" || _difficulty == "WAR_MACHINE") then
		{	
			_unit groupChat "ZFS_ETC_FOUND -  Roger that. Found nearby tree cover.";
			_unit sideChat "Roger that. Found nearby tree cover.";
		};
		
		// Go to the tree!
		_unit doMove (getPos _nearestTree); 
		diag_log("Moving to..");
	}
	else
	{
		// Tell the group
		if(_difficulty == "HARD" || _difficulty == "WAR_MACHINE") then
		{	
			_unit groupChat "ZFS_ETC_NOTFOUND - Negative! Cannot find tree cover."; 
			_unit sideChat "Negative! Cannot find tree cover."; 
		};
	};
};

/*
	ZFM_DoBootStrap
	
	Starts up all the checks necessary to ensure that AI and Missions can be loaded.
*/
ZFM_DoBootStrap = {

    private["_checkAI","_outputMessage","_checkAI"];
    
	// Check to see if any AI is already set. 
	_checkAI = [] call ZFM_CheckExistingAI;
	
	// Consistency with error or information logging.
	_outputMessage = ZFM_Name + ZFM_Version;
	
	if(!_checkAI) exitWith { diag_log(_outputMessage + "CheckExistingAI - No other AI is installed. Proceeding with initialization steps for ZFM") };	

	diag_log(_outputMessage + "DoBootStrap - Adding Centers for AI to congregate around..");
	
	// Create the Centers for AI
	ZFM_GROUP_EAST = createCenter east;
	ZFM_GROUP_WEST = createCenter west;
	ZFM_GROUP_CIVILIAN = createCenter civilian;
	ZFM_GROUP_RESISTANCE = createCenter resistance; // Vive Le Resistance!
	
	// unfriendly AI bandits
	EAST setFriend [WEST, 0];
	EAST setFriend [RESISTANCE, 0];

	// Players
	WEST setFriend [EAST, 0];
	WEST setFriend [RESISTANCE, 1];

	// friendly AI
	RESISTANCE setFriend [EAST, 0];
	RESISTANCE setFriend [WEST, 1];
};

/*
*	ZFM_CheckExistingAI
* 
*	Check to see if existing AI systems are installed. 
*/
ZFM_CheckExistingAI = {
    private["_doExit","_outputMessage"];
    
    
	_doExit = false;
	_outputMessage = ZFM_Name + ZFM_Version;
	
	/*
	* 	 Check For WickedAI.
	*/
	if(!isNil(WAIconfigloaded)) then
	{
		diag_log(_outputMessage + "CheckExistingAI - WickedAI discovered. This will interfere with ZFM, and must be disabled before ZFM can run. Exiting.");
		_doExit = true;
	};
	
	/*
	*	Check for SARGE AI
	*/
	if(!isNil(SAR_version)) then
	{
		diag_log(_outputMessage + "CheckExistingAI - SARGE AI discovered. This will interfere with ZFM, and must be disabled before ZFM can run. Exiting.");
		_doExit = true;
	};
	
	/*
	*	Check for DZ AI
	*/
	if(!isNil(DZAI_isActive)) then
	{
		diag_log(_outputMessage + "CheckExistingAI - DZ AI discovered. This will interfere with ZFM, and must be disabled before ZFM can run. Exiting.");
		_doExit = true;	
	};

	_doExit
};

/*
*	ZFM_EquipAIFromArray
*
*	Provide an array in the ZFM format, and equip the unit with the weapons proscribed.
*/
ZFM_EquipAIFromArray ={
	private ["_ai","_equipArray","_primaryWeap","_numMagazines","_unitBackPk","_unitBackPack","_primaryWeapon","_magazineToAdd"];
	
	_ai = _this select 0;
	_equipArray = _this select 1;
	
	// Select things from the AI array.
	_skin = _equipArray select 0;
	_primaryWeap = _equipArray select 1;
	
	// What number of magazines will they spawn with? 
	_numMagazines = _equipArray select 2;
	
	// What backpack?
	_unitBackPk = _equipArray select 3;
	
	// Random pick from the equipment Array
	_primaryWeapon = _primaryWeap call BIS_fnc_selectRandom;
	
	// Random pick from the backpack array
	_unitBackPack = _unitBackPk call BIS_fnc_selectRandom;
	
	// Get the magazine for the weapon out of the config file. DZMS is fun, but why always give them the first one? 
	_magazineToAdd = getArray(configFile >> "CfgWeapons" >> _primaryWeapon >> "magazines") select 0;	
		
	diag_log(format["Skin %1, PrimaryWeap %2, NumMagazines %3,Primary Weapon %4,Backpack %5 ,AI %6, magazine %7",_skin,_primaryWeap,_numMagazines,_primaryWeapon,_unitBackPack,_ai,_magazineToAdd
	]);
		
	// This is messy; I should join the magazines array and the med supplies array and loop through them all, but fuck it. 
	for [{_x =1},{_x <= _numMagazines},{_x = _x +1} ] do
	{
		_ai addMagazine _magazineToAdd;
	};
	
	_ai addWeapon _primaryWeapon;
	_ai addBackpack _unitBackPack;
};

/*
	This is a fairly heavy function, which 
*/
ZFM_CreateUnit_Sniper ={
	private ["_aiGroup","_difficulty","_spawnAt","_equipArray"];

	_aiGroup = _this select 0;
	_difficulty = _this select 1;
	_spawnAt = _this select 2;
	
	_equipArray = [];
	
	switch(_difficulty) do
	{
		case "DEADMEAT": {
			_equipArray = ZFS_Equipment_Sniper_EASY;
		};
		case "EASY": {
			_equipArray = ZFS_Equipment_Sniper_EASY;
		};
		case "MEDIUM": {
			_equipArray = ZFS_Equipment_Sniper_MEDIUM;
		};
		case "HARD": {
			_equipArray = ZFS_Equipment_Sniper_HARD;
		};
		case "WAR_MACHINE": {
			_equipArray = ZFS_Equipment_Sniper_WAR_MACHINE;
		};
	};
	
	diag_log(format["EquipArray %1",_equipArray]);
	
	
	// Get the skin out of the ZFM unit type
	_skin = equipArray select 0;
	
	// Spawn the unit..
	_unit = [_aiGroup,_skin,_spawnAt] call ZFM_InitUnitSpawn;
	
	if(_difficulty == "HARD" || _difficulty == "WAR_MACHINE") then
	{
		_unit globalChat "I'm in. Time to make some mess.";
	};
	
	// Ad the relevant equipment from the EquipArray
	[_unit,_equipArray] call ZFM_EquipAIFromArray;
	
	// Add variables to unit for ZFM
	_unit setVariable ["ZFM_UnitType","SNIPER"];
	_unit setVariable ["ZFM_UnitDifficulty",_difficulty];
	
	// Don't start running around.
	doStop _unit;
	
	// Remove this for production -- debugging
	_unit setSkill ["courage",1];
};


// Get the config stuff..
ZFM_Includes_AI_Config = "\z\addons\dayz_server\ZFM\Config\ZFM_AI_Config.sqf";

// We need to get access to these functions..
call compile preprocessFileLineNumbers ZFM_Includes_AI_Config;

// Call AI bootstrap
[] call ZFM_DoBootStrap;

// Sample AI group
_aiGroup = [east] call ZFM_CreateAIGroup;


while{true} do
{
	if(count playableUnits >0) then
	{
		_playerz = playableUnits;
		_playerPos = _playerz select 0;
		_playerPoop = getPos _playerPos;
	
		diag_log("Calling Unit Spawn..");
		_unit = [_aiGroup,"EASY",_playerPoop] call ZFM_CreateUnit_Sniper;
	};
sleep 50;
};
