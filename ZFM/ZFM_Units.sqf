/*
	ZFSS - Zambino's FairServer System v0.5
	A Dayz Epoch server solution proving a dynamic mission system and fun, more interesting missions and a more equitable way of doing them. 
	Not messing with the bandit/hero dynamic, just making the game a little less rage-inducing :)
	Copyright (C) 2014 Jordan Ashley Craw

	This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
 */


/*
*	ZFM_GenerateRandomUnits
*
*	Generates an array of ZFM-typed random units.
*/
ZFM_GenerateRandomUnits ={

	private ["_difficulty","_maxBound","_generatedUnits","_x","_initRandSeed","_newType"];
	_difficulty = _this select 0;

	_generatedUnits = [];
	
	switch(_difficulty) do 
	{
		case "DEADMEAT": {
			_maxBound = 20;
		};
		case "EASY": {
			_maxBound = 22;
		};
		case "MEDIUM": {
			_maxBound = 28;
		};
		case "HARD": {
			_maxBound = 30;
		};
		case "WAR_MACHINE": {
			_maxBound = 34;
		};
	};
	
	// TODO: Units like commander / gunner / etc in squads will be delayed until a later stage
	_initRandSeed = (round random _maxBound);
	
	// We don't want just ONE unit, do we? 
	if(_initRandSeed < ZFM_MINIMUM_AI_PER_MISSION) then 
	{
		_initRandSeed = ZFM_MINIMUM_AI_PER_MISSION; 
	};
	
	for [{_x =0},{_x <= _initRandSeed-1},{_x = _x +1} ] do
	{
		_newType = ZFM_AI_TYPES call BIS_fnc_selectRandom;
		_generatedUnits = _generatedUnits + [_newType];
	};
	
	_generatedUnits
};

/*
	ZFM_CreateUnitGroup
	
	Takes an array input and other requirements to generate groups of AI at once. Returns in an array for convenience.
*/
ZFM_CreateUnitGroup ={
	private["_unitsArray","_difficulty","_side","_thisUnit","_spawnAt","_uArrayReturn","_unitGroup","_unitsArrayCount","_aiType","_thisUnit","_x"];

	_unitsArray = _this select 0;
	_difficulty = _this select 1;
	_side = _this select 2;
	_spawnAt = _this select 3;
	_missionID = _this select 4;
	

	["Creating Unit Group from MissionID %1","ZFM_Units::ZFM_CreateUnitGroup",_missionID] call ZFM_Common_Log;

	_uArrayReturn = [];
	
	if(typeName _unitsArray =="ARRAY") then
	{
		_unitsArrayCount = count _unitsArray; 
	
		if(_unitsArrayCount > 0) then
		{
			//Create AI group..
			_unitGroup = [_side] call ZFM_CreateAIGroup;
			
			for [{_x =0},{_x <= _unitsArrayCount-1},{_x = _x +1} ] do
			{
				_aiType = _unitsArray select _x;
				
				if(_aiType in ZFM_AI_TYPES) then
				{
					// Stagger them so they aren't just crushed or what have you.
					_staggerSpawnAt = [_crashPos,(round random 10),(round random 10)] call ZFM_Create_OffsetPosition;
				
					["Creating individual unit %1 of %2 (Type %3)",[_x,(_unitsArrayCount-1),_aiType]] call ZFM_Common_Log;

					_thisUnit = [_unitGroup,_difficulty,_staggerSpawnAt,_aiType] call ZFM_CreateUnit;
				
					// Lets us find out which mission the unit is attached to.
					_thisUnit setVariable ["ZFM_MISSION_ID",_missionID];

					_thisUnit addMPEventHandler["MPKilled",{
						[(_this select 0),(_this select 1)] call ZFM_Handle_MissionUnitKilled;
					}];
					
					// Add to the array return
					_uArrayReturn = _uArrayReturn + [_thisUnit];
				};
			};
			
			// Stops them from killing eachother when they fire..s
			_unitGroup setFormation "ECH LEFT";
			
		};
	};
	
	// Return the units so we can muck around with them, tell them to get in cars, etc. 
	[_unitGroup,_uArrayReturn]
};

/*
*	ZFM_EquipAIFromArray
*
*	Provide an array in the ZFM format, and equip the unit with the weapons proscribed.
*/
ZFM_EquipAIFromArray ={
	private ["_ai","_equipArray","_primaryWeap","_numMagazines","_unitBackPk","_unitBackPack","_primaryWeapon","_magazineToAdd","_x"];
	
	_ai = _this select 0;
	_equipArray = _this select 1;
	
	// Select things from the AI array.
	_primaryWeap = _equipArray select 1;
	
	// What number of magazines will they spawn with? 
	_numMagazines = _equipArray select 2;
	_numMagazines = _numMagazines +5; // Make sure they have at least 5 magazines to start with.
	
	// What backpack?
	_unitBackPk = _equipArray select 3;
	
	// Random pick from the equipment Array
	_primaryWeapon = _primaryWeap call BIS_fnc_selectRandom;
	
	// Random pick from the backpack array
	_unitBackPack = _unitBackPk call BIS_fnc_selectRandom;

	// Get a magazine for that weapon.
	_magazineToAdd = getArray(configFile >> "CfgWeapons" >> _primaryWeapon >> "magazines") select 0;	
		
	["Equipping Unit with: Primary %1, %2 magazines, Backpack %3, Unit %4, Magazine %5 ",[_primaryWeap,_numMagazines,_primaryWeapon,_unitBackPack,_ai,_magazineToAdd]] call ZFM_Common_Log;

	// Removed unnecessary loop and used addMagazine _array instead
	_ai addMagazine [_magazineToAdd,_numMagazines];
	_ai addWeapon _primaryWeapon;
	_ai addBackpack _unitBackPack;
};

/*
	ZFM_SetAISkills
	
	Sets AI skills based on config arrays. 
*/
ZFM_SetAISkills ={
	private ["_unit","_difficulty","_skillsArray","_numSkills","_thisRow","_skill","_currSkill","_x"];
	
	_unit  = _this select 0;
	_difficulty = _this select 1;
	
	_skillsArray = [];
	
	//Changing this to procedural rather than array-bases, as arrays are resource-intensive.
	switch(_difficulty) do 
	{
		case "DEADMEAT": {
			_skillsArray =[
				random(0.1),
				random(1),
				random(0.1),
				random(0.1),
				random(0.1),
				random(0.1),
				random(0.1),
				random(0.1),
				random(0.1),
				random(0.1)
			];
		};
		case "EASY": {
			_skillsArray =[
				random(0.25),
				random(0.8),
				random(0.25),
				random(0.25),
				random(0.25),
				random(0.25),
				random(0.25),
				random(0.25),
				random(0.25),
				random(0.25)
			];
		};
		case "MEDIUM": {
			_skillsArray =[
				random(0.65),
				random(0.6),
				random(0.65),
				random(0.65),
				random(0.65),
				random(0.65),
				random(0.65),
				random(0.65),
				random(0.65),
				random(0.65)
			];
		};
		case "HARD": {
			_skillsArray =[
				random(0.85),
				random(0.4),
				random(0.85),
				random(0.85),
				random(0.85),
				random(0.85),
				random(0.85),
				random(0.85),
				random(0.85),
				random(0.85)
			];
		};
		case "WAR_MACHINE": {
			_skillsArray =[
				1,
				0,
				1,
				1,
				1,
				1,
				1,
				1,
				1,
				1
			];
		};
	};

	// Set pseudo-manually as it's quicker and requires no array recursion.
	_unit setSkill ["aimingAccuracy",_skillsArray select 0];
	_unit setSkill ["aimingShake",_skillsArray select 1];
    _unit setSkill ["aimingSpeed",_skillsArray select 2];
    _unit setSkill ["endurance",_skillsArray select 3];
    _unit setSkill ["spotDistance",_skillsArray select 4];
    _unit setSkill ["spotTime",_skillsArray select 5];
    _unit setSkill ["courage",_skillsArray select 6];
    _unit setSkill ["reloadSpeed",_skillsArray select 7];
    _unit setSkill ["commanding",_skillsArray select 8];
    _unit setSkill ["general",_skillsArray select 9];
};

/*
*	ZFM_CreateUnit
*
*	Create a ZFM_typed unit.
*/
ZFM_CreateUnit ={
	private ["_aiGroup","_difficulty","_skin","_unit","_location","_equipArray"];

	_aiGroup = _this select 0;
	_difficulty = _this select 1;
	_location = _this select 2;
	_unitType = _this select 3;
	
	if not (_unitType in ZFM_UNIT_TYPES_TEXT) exitWith { ["Unknown unit type provided. Exiting function.","ZFM_Units::ZFM_CreateUnit"] call ZFM_Common_Log };
	
	// I love call compile format. Points right to the array with the unit's stuff in it.
	_equipArray = call compile format["ZFM_UNIT_EQUIPMENT_%1_%2",_unitType,_difficulty];	

	// Added as I imagine people will want to use overpoch and all that nonsense :-P
	if(typeName _equipArray == "ARRAY") then
	{
		// Set the skin -- get it from an array if it is an array, or a string.
		if(typeName (_equipArray select 0) == "ARRAY") then
		{
			_skin = (_equipArray select 0) call BIS_fnc_selectRandom;
		}
		else
		{	
			// If someone just types random gibberish..
			if(typeName (_equipArray select 0) != "STRING") then
			{
				_skin = "Bandit1_DZ";
			}
			else
			{
				_skin = _equipArray select 0;
			};
		};

		// Create the unit 
		_unit = _aiGroup createUnit[_skin,_location,[],0,"FORM"];

		// Join the group silently, no radio comms
		[_unit] joinSilent _aiGroup;

		// Remove default weapons from the unit so they don't start with random crap
		removeAllWeapons _unit;

		// Now, add the equipment from the equiparray for that unit.
		[_unit,_equipArray] call ZFM_EquipAIFromArray;

		// Now, set the skills of the unit.
		[_unit,_difficulty] call ZFM_SetAISkills;

		// Now we set the variables for the unit so we can distinguish this unit from others.
		_unit setVariable ["ZFM_Unit",true];
		_unit setVariable ["ZFM_UnitType",_unitType];
		_unit setVariable ["ZFM_UnitDifficulty",_difficulty];

		// Finally, enable the AI behaviours.
		_unit enableAI "TARGET";
		_unit enableAI "AUTOTARGET";
		_unit enableAI "MOVE";
		_unit enableAI "ANIM";
		_unit enableAI "FSM";
		_unit setCombatMode "RED";
		_unit setBehaviour "COMBAT";
		
		// Return the unit
		_unit
	}
	else
	{
		 ["Wrong format for EquipArray for unit. You need to restore ZFM defaults or fix what you broke.","ZFM_Units::ZFM_CreateUnit"] call ZFM_Common_Log;
	};
};

/*
*	ZFM_CreateAIGroup
*
*	Create a group for a group of AI.
*/
ZFM_Units_CreateGroup = {

	private ["_sideType","_createdGroup"];
	_sideType = _this select 0;

	// Create a group with the specific side type.
	_createdGroup = createGroup _sideType;
	
	//Return the group
	_createdGroup
};

/*
*	ZFM_AI_Get_View_Distance
*
*	Determines the unit's view distance.
*/
ZFM_Units_Get_View_Distance = {
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