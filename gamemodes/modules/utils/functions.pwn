stock loadATMs() {
	mysql_query("SELECT * FROM atms", THREAD_LOAD_ATMS);
	return 1;
}

stock unixTimeConvert(timestamp, compare = -1) 
{
    if(compare == -1)
		compare = gettime();

    new n, returnstr[32];
        Float:d = (timestamp > compare) ? (timestamp - compare) : (compare - timestamp);

	if(d < 60)
	{
		returnstr = "< 1 minute";
		return returnstr;
	}
	else if(d < 3600)
		n = floatround(floatdiv(d, 60.0), floatround_floor), returnstr = "minute";
	else if(d < 86400)
		n = floatround(floatdiv(d, 3600.0), floatround_floor), returnstr = "hour";
	else if(d < 2592000)
		n = floatround(floatdiv(d, 86400.0), floatround_floor), returnstr = "day";
	else if(d < 31536000)
		n = floatround(floatdiv(d, 2592000.0), floatround_floor), returnstr = "month";
	else
		n = floatround(floatdiv(d, 31536000.0), floatround_floor), returnstr = "year";
	
	if(n == 1)
		format(returnstr, sizeof(returnstr), "1 %s", returnstr);
    else
        format(returnstr, sizeof(returnstr), "%d %ss", n, returnstr);
	
    return returnstr;
}

function genderSelection(const playerid) {
	return ShowPlayerDialog(playerid, DIALOG_GENDER_SELECTION, DIALOG_STYLE_MSGBOX, "SERVER: Gender Selection", "What sex/gender is your character?", "Male", "Female");
}

function OnPlayerShootPlayer(Shooter,Target,Float:HealthLost,Float:ArmourLost) {
	if(playerVariables[Shooter][pTazer] == 1 && groupVariables[playerVariables[Shooter][pGroup]][gGroupType] == 1 && playerVariables[Shooter][pGroup] != 0 && GetPlayerWeapon(Shooter) == 22) {
	    if(IsPlayerInAnyVehicle(Target) || IsPlayerInAnyVehicle(Shooter))
	        return 1;

		if(groupVariables[playerVariables[Target][pGroup]][gGroupType] == 1 && playerVariables[Target][pGroup] != 0)
		    return 1;

		new
		    playerNames[2][MAX_PLAYER_NAME];

		GetPlayerName(Shooter, playerNames[0], MAX_PLAYER_NAME);
		GetPlayerName(Target, playerNames[1], MAX_PLAYER_NAME);

		TogglePlayerControllable(Target, 0);
		playerVariables[Target][pFreezeTime] = 15;
		playerVariables[Target][pFreezeType] = 1;
		GameTextForPlayer(Target, "~n~~r~ Tazed!",4000, 4);

		format(szMessage, sizeof(szMessage), "* %s fires their tazer at %s, stunning them.", playerNames[0], playerNames[1]);
		nearByMessage(Shooter, COLOR_PURPLE, szMessage);
		format(szMessage, sizeof(szMessage), "You have successfully stunned %s.", playerNames[1]);
		SendClientMessage(Shooter, COLOR_NICESKY, szMessage);
		ApplyAnimation(Target,"CRACK","crckdeth2",4.1,0,1,1,1,1,1);
	}
	return 1;
}

function playerTabbedLoop() {
	foreach(Player, x) {
	    if(playerVariables[x][pTabbed] == 0 && IsValidDynamic3DTextLabel(playerVariables[x][pAFKLabel]))
			DestroyDynamic3DTextLabel(playerVariables[x][pAFKLabel]);

	    playerVariables[x][pConnectedSeconds] += 1;

	    if(playerVariables[x][pConnectedSeconds] < gettime()-1 && playerVariables[x][pTabbed] != 1 && playerVariables[x][pConnectedSeconds] >= 5 && GetPlayerState(x) != 9 && GetPlayerState(x) != 0 && GetPlayerState(x) != 7) {
	        playerVariables[x][pTabbed] = 1;
	        playerVariables[x][pAFKLabel] = CreateDynamic3DTextLabel("Paused.", COLOR_RED, 0, 0, 0, 7.5, x, _, 1, _, _, _, 7.5);
	    }
	}
	return 1;
}

function restartTimer() {
	iGMXTick--;

	switch(iGMXTick) {
	    case 0: {
		    SendClientMessageToAll(COLOR_LIGHTRED, "AdmCmd:{FFFFFF} The server is now restarting...");

			mysql_close();
			KillTimer(iGMXTimer);

			SendRconCommand("gmx");
	    }
	    case 1: GameTextForAll("~w~The server will restart...~n~ ~r~NOW!", 1110, 5);
	    case 2: GameTextForAll("~w~The server will restart in...~n~ ~r~2~w~ seconds.", 1110, 5);
	    case 3: GameTextForAll("~w~The server will restart in...~n~ ~r~3~w~ seconds.", 1110, 5);
	    case 4: GameTextForAll("~w~The server will restart in...~n~ ~r~4~w~ seconds.", 1110, 5);
	    case 5: GameTextForAll("~w~The server will restart in...~n~ ~r~5~w~ seconds.", 1110, 5);
	}

	return 1;
} 
stock encode_lights(light1, light2, light3, light4) {
    return light1 | (light2 << 1) | (light3 << 2) | (light4 << 3);
}

stock encode_doors(bonnet, boot, driver_door, passenger_door) {
    return bonnet | (boot << 8) | (driver_door << 16) | (passenger_door << 24);
}

stock encode_panels(flp, frp, rlp, rrp, windshield, front_bumper, rear_bumper) {
    return flp | (frp << 4) | (rlp << 8) | (rrp << 12) | (windshield << 16) | (front_bumper << 20) | (rear_bumper << 24);
}

function ShutUp(slot) { // One function for eight doors. A WINRAR IS YOU!
	if(LSPDObjs[slot][2] == 1) switch(slot) {
		case 0: {
			MoveDynamicObject(LSPDObjs[0][0],232.89999390,107.57499695,1009.21179199,3.5); //commander south
			MoveDynamicObject(LSPDObjs[0][1],232.89941406,110.57499695,1009.21179199,3.5); //commander north
			LSPDObjs[0][2] = 0;
		}
		case 1: {
			MoveDynamicObject(LSPDObjs[1][0],275.75000000,118.89941406,1003.61718750,3.5); // interrogation north
			MoveDynamicObject(LSPDObjs[1][1],275.75000000,115.89941406,1003.61718750,3.5); // interrogation south
			LSPDObjs[1][2] = 0;
		}
		case 2: {
			MoveDynamicObject(LSPDObjs[2][0],253.20410156,107.59960938,1002.22070312,3.5); // north west lobby door
			MoveDynamicObject(LSPDObjs[2][1],253.19921875,110.59960938,1002.22070312,3.5); // north east lobby door
			LSPDObjs[2][2] = 0;
		}
		case 3: {
			MoveDynamicObject(LSPDObjs[3][0],239.56933594,116.09960938,1002.22070312,3.5); // south west lobby door
			MoveDynamicObject(LSPDObjs[3][1],239.56445312,119.09960938,1002.22070312,3.5); // south east lobby door
			LSPDObjs[3][2] = 0;
		}
		case 4: {
			MoveDynamicObject(LSPDObjs[4][0],264.45019531,115.82421875,1003.62286377,3.5); //object(gen_doorext15) (3)
			MoveDynamicObject(LSPDObjs[4][1],267.45214844,115.82910156,1003.62286377,3.5); //object(gen_doorext15) (8)
			LSPDObjs[4][2] = 0;
		}
		case 5: {
			MoveDynamicObject(LSPDObjs[5][0],267.32000732,112.53222656,1003.62286377,3.5); //object(gen_doorext15) (4)
			MoveDynamicObject(LSPDObjs[5][1],264.32000732,112.52929688,1003.62286377,3.5); //object(gen_doorext15) (5)
			LSPDObjs[5][2] = 0;
		}
		case 6: {
			MoveDynamicObject(LSPDObjs[6][0],229.59960938,119.52929688,1009.22442627,3.5); //object(gen_doorext15) (9)
			MoveDynamicObject(LSPDObjs[6][1],232.59960938,119.53515625,1009.22442627,3.5); //object(gen_doorext15) (10)
			LSPDObjs[6][2] = 0;
		}
		case 7: {
			MoveDynamicObject(LSPDObjs[7][0],219.30000305,116.52999878,998.01562500,3.5); //cell east door
			MoveDynamicObject(LSPDObjs[7][1],216.30000305,116.52929688,998.01562500,3.5); //cell west door
			LSPDObjs[7][2] = 0;
		}
	}
	return 1;
}
function AFKTimer() {
	foreach(Player, i) {
	    if(playerVariables[i][pAdminLevel] < 1) {
			GetPlayerPos(i, PlayerPos[i][0], PlayerPos[i][1], PlayerPos[i][2]);

			if(PlayerPos[i][0] == PlayerPos[i][3] && PlayerPos[i][1] == PlayerPos[i][4] && PlayerPos[i][2] == PlayerPos[i][5]) {
			    savePlayerData(i);
			    
	    		if(playerVariables[i][pCarModel] >= 1)
					DestroyVehicle(playerVariables[i][pCarID]);
					
			    playerVariables[i][pStatus] = 0;
				RemovePlayerFromVehicle(i);
			    SendClientMessage(i, COLOR_GREY, "You have been logged out due to inactivity.");
			    ShowPlayerDialog(i, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "SERVER: Login", "Welcome to the "SERVER_NAME" Server.\n\nPlease enter your password below!", "Login", "Cancel");
			}

			PlayerPos[i][3] = PlayerPos[i][0];
			PlayerPos[i][4] = PlayerPos[i][1];
			PlayerPos[i][5] = PlayerPos[i][2];
		}
	}

	return 1;
}
stock GetWeaponSlot(weaponid) {
	switch(weaponid) {
		case 0, 1: return 0;
		case 2 .. 9: return 1;
		case 22 .. 24: return 2;
		case 25 .. 27: return 3;
		case 28, 29, 32: return 4;
		case 30, 31: return 5;
		case 33, 34: return 6;
		case 35 .. 38: return 7;
		case 16, 17, 18, 39, 40: return 8;
		case 41 .. 43: return 9;
		case 10 .. 15: return 10;
		case 44 .. 46: return 11;
	}
	return -1;
}

stock PlayerPlaySoundEx(soundid, Float:x, Float:y, Float:z) { // Realistic sound playback
	foreach(Player, i) {
		if(IsPlayerInRangeOfPoint(i, 30.0, x, y, z))
			PlayerPlaySound(i, soundid, x, y, z);
	}

	return 1;
}

stock GetClosestPlayer(const playerid) {
    new
		Float:Distance,
		target = -1;

    foreach(Player, i) {
        if (playerid != i && playerVariables[i][pSpectating] == INVALID_PLAYER_ID && (target < 0 || Distance > GetDistanceBetweenPlayers(playerid, i))) {
            target = i;
            Distance = GetDistanceBetweenPlayers(playerid, i);
        }
    }
    return target;
}

stock GetClosestVehicle(playerid, exception = INVALID_VEHICLE_ID) {
    new
		Float:Distance,
		target = -1;

    for(new v; v < MAX_VEHICLES; v++) if(doesVehicleExist(v)) {
        if(v != exception && (target < 0 || Distance > GetDistancePlayerVeh(playerid, v))) {
            target = v;
            Distance = GetDistancePlayerVeh(playerid, v);
        }
    }
    return target;
}

stock checkVehicleSeat(vehicleid, seatid) {
	foreach(Player, x) {
	    if(GetPlayerVehicleID(x) == vehicleid && GetPlayerVehicleSeat(x) == seatid) return 1;
	}
	return 0;
}

stock IsValidSkin(skinid) {
	if(skinid < 0 || skinid > 299)
		return false;

	switch(skinid) {
		case 3, 4, 5, 6, 8, 42, 65, 74, 86, 119, 149, 208, 268, 273, 289: return false;
	}
	return true;
}

stock IsPublicSkin(skinid) {
	if(!IsValidSkin(skinid)) return false;

	switch(skinid) {
		case 274 .. 288, 265 .. 267, 71: return false;
	}
	return true;
}

function loginCheck(playerid) {
	// This function will be used to see if the query times out.
	
	// Ban check step
	if(GetPVarInt(playerid, "bcs") == 0) {
	    // If it's 0, we have a problem.
	    ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "MySQL problem!", "You missed a step! Here's a list of the potential causes:\n\n- the MySQL connection details are invalid\n- the database dump wasn't imported correctly\n- an unexpected error ocurred\n\nPlease revisit the installation instructions.", "OK", "");
	}
	return 1;
}
stock getIdFromName(const szPlayerName2[]) {
	new
		szEsc[24];

	mysql_real_escape_string(szPlayerName2, szEsc);
	format(szQueryOutput, sizeof(szQueryOutput), "SELECT `playerID` FROM `playeraccounts` WHERE `playerName` = '%e'", szEsc);
	mysql_query(szQueryOutput);
	mysql_store_result();
	print(szQueryOutput);

	if(mysql_num_rows() > 1) {
	    mysql_retrieve_row();
		new iResult = mysql_fetch_int();
		mysql_free_result();
		return iResult;
	} else return -1;
}

stock SendToGroup(groupid, colour, const string[]) {
	if(groupid > 0) {
		foreach(Player, i) {
			if(playerVariables[i][pStatus] == 1 && playerVariables[i][pGroup] == groupid) {
				SendClientMessage(i, colour, string);
			}
		}
	}
	return 1;
}

stock FetchLevelFromHours(const iHours) {
	switch(iHours) {
	    case 0..24: return 1;
	    case 25..48: return 2;
	    case 49..72: return 3;
	    case 73..100: return 4;
	    case 101..175: return 5;
	    case 176..200: return 6;
	    case 201..208: return 8;
	    case 209..336: return 9;
	    case 337..480: return 10;
	}
	return 0;
}

stock SendToFrequency(const frequency, const colour, const string[]) {
	if(frequency > 0) {
		foreach(Player, i) {
			if(playerVariables[i][pStatus] == 1 && playerVariables[i][pWalkieTalkie] == frequency) {
				SendClientMessage(i, colour, string);
			}
		}
	}
	return 1;
}

stock sendDepartmentMessage(const colour, const string[]) {
	foreach(Player, i) {
	    if(playerVariables[i][pStatus] == 1 && (groupVariables[playerVariables[i][pGroup]][gGroupType] == 1 || groupVariables[playerVariables[i][pGroup]][gGroupType] == 2)) {
	        SendClientMessage(i, colour, string);
		}
	}
	return 1;
}

stock IsKeyJustDown(key, newkeys, oldkeys) {
	if((newkeys & key) && !(oldkeys & key))
		return 1;

	return 0;
}

stock IsInvalidNOSVehicle(const modelid)
{
	switch(modelid)
	{
		case 581, 523, 462, 521, 463, 522, 461, 448, 468, 586, 509, 481, 510, 472, 473, 493, 595, 484, 430, 453, 452, 446, 454, 590, 569, 537, 538, 570, 449: return true;
	}
	return false;
}

stock givePlayerValidWeapon(playerid, weapon) {
	switch(weapon) {
		case 0, 1: {
	        playerVariables[playerid][pWeapons][0] = weapon;
	        GivePlayerWeapon(playerid, weapon, 99999);
	    }
	    case 2, 3, 4, 5, 6, 7, 8, 9: {
	        playerVariables[playerid][pWeapons][1] = weapon;
	        GivePlayerWeapon(playerid, weapon, 99999);
	    }
	    case 22, 23, 24: {
	        playerVariables[playerid][pWeapons][2] = weapon;
	        GivePlayerWeapon(playerid, weapon, 99999);
	    }
	    case 25, 26, 27: {
	        playerVariables[playerid][pWeapons][3] = weapon;
	        GivePlayerWeapon(playerid, weapon, 99999);
	    }
	    case 28, 29, 32: {
	        playerVariables[playerid][pWeapons][4] = weapon;
	        GivePlayerWeapon(playerid, weapon, 99999);
	    }
	    case 30, 31: {
	        playerVariables[playerid][pWeapons][5] = weapon;
	        GivePlayerWeapon(playerid, weapon, 99999);
	    }
	    case 33, 34: {
	        playerVariables[playerid][pWeapons][6] = weapon;
	        GivePlayerWeapon(playerid, weapon, 99999);
	    }
	    case 35, 36, 37, 38: {
	        playerVariables[playerid][pWeapons][7] = weapon;
	        GivePlayerWeapon(playerid, weapon, 99999);
	    }
	    case 16, 17, 18, 39: {
	        playerVariables[playerid][pWeapons][8] = weapon;
	        GivePlayerWeapon(playerid, weapon, 99999);
	    }
	    case 41, 42, 43: {
	        playerVariables[playerid][pWeapons][9] = weapon;
	        GivePlayerWeapon(playerid, weapon, 99999);
	    }
	    case 10, 11, 12, 13, 14, 15: {
	        playerVariables[playerid][pWeapons][10] = weapon;
	        GivePlayerWeapon(playerid, weapon, 99999);
	    }
	    case 44, 45, 46: {
	        playerVariables[playerid][pWeapons][11] = weapon;
	        GivePlayerWeapon(playerid, weapon, 99999);
	    }
	    case 40: {
	        playerVariables[playerid][pWeapons][12] = weapon;
	        GivePlayerWeapon(playerid, weapon, 99999);
	    }
	}
	return 1;
}

stock GymMap() {
	/*
	    --- CUSTOM MAP ---
	    
		Credits to: Marcel_Collins
		Release thread: http://forum.sa-mp.com/showthread.php?p=1537421
	*/
	
	CreateDynamicObject(1257,2242.38281250,-1725.93640137,13.82606697,0.00000000,0.00000000,90.00000000); //object(bustopm)(1)
	CreateDynamicObject(1229,2240.03955078,-1727.28039551,14.10655499,0.00000000,0.00000000,88.00000000); //object(bussign1)(1)
	CreateDynamicObject(1215,2224.59545898,-1712.75476074,13.11704731,0.00000000,0.00000000,0.00000000); //object(bollardlight)(1)
	CreateDynamicObject(1215,2236.68701172,-1725.17114258,13.11119843,0.00000000,0.00000000,0.00000000); //object(bollardlight)(3)
	CreateDynamicObject(1215,2221.71606445,-1723.97021484,13.12682343,0.00000000,0.00000000,0.00000000); //object(bollardlight)(4)
	CreateDynamicObject(1215,2225.08544922,-1726.94616699,13.12256432,0.00000000,0.00000000,0.00000000); //object(bollardlight)(5) (5)
	CreateDynamicObject(996,2230.76025391,-1727.23754883,13.29563046,0.00000000,0.00000000,0.00000000); //object(lhouse_barrier1)(1)
	CreateDynamicObject(997,2238.22485352,-1727.02954102,12.54687500,0.00000000,0.00000000,88.00000000); //object(lhouse_barrier3)(2)
	CreateDynamicObject(997,2225.60278320,-1727.18811035,12.65393353,0.00000000,0.00000000,0.00000000); //object(lhouse_barrier3)(3)
	CreateDynamicObject(997,2222.02197266,-1724.68554688,12.56250000,0.00000000,0.00000000,318.00000000); //object(lhouse_barrier3)(4)
	CreateDynamicObject(997,2221.68579102,-1719.86242676,12.53577995,0.00000000,0.00000000,266.00000000); //object(lhouse_barrier3)(5)
	CreateDynamicObject(996,2221.84472656,-1718.27014160,13.26626015,0.00000000,0.00000000,84.00000000); //object(lhouse_barrier1)(2)
	CreateDynamicObject(997,2223.02758789,-1710.96203613,12.58030415,0.00000000,0.00000000,0.00000000); //object(lhouse_barrier3)(7)
	return 1;
}

stock LSMall() {
	CreateDynamicObject(19322,1117.58000000,-1490.01000000,32.72000000,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(19323,1117.58000000,-1490.01000000,32.72000000,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(19325,1155.40000000,-1434.89000000,16.49000000,0.00000000,0.00000000,0.30000000); //
	CreateDynamicObject(19325,1155.37000000,-1445.41000000,16.31000000,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(19325,1155.29000000,-1452.38000000,16.31000000,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(19325,1157.36000000,-1468.35000000,16.31000000,0.00000000,0.00000000,18.66000000); //
	CreateDynamicObject(19325,1160.64000000,-1478.37000000,16.31000000,0.00000000,0.00000000,17.76000000); //
	CreateDynamicObject(19325,1159.84000000,-1502.06000000,16.31000000,0.00000000,0.00000000,-19.92000000); //
	CreateDynamicObject(19325,1139.28000000,-1523.71000000,16.31000000,0.00000000,0.00000000,-69.36000000); //
	CreateDynamicObject(19325,1117.06000000,-1523.43000000,16.51000000,0.00000000,0.00000000,-109.44000000); //
	CreateDynamicObject(19325,1097.18000000,-1502.43000000,16.51000000,0.00000000,0.00000000,-158.58000000); //
	CreateDynamicObject(19325,1096.47000000,-1478.29000000,16.51000000,0.00000000,0.00000000,-197.94000000); //
	CreateDynamicObject(19325,1099.70000000,-1468.27000000,16.51000000,0.00000000,0.00000000,-197.94000000); //
	CreateDynamicObject(19325,1101.81000000,-1445.45000000,16.22000000,0.00000000,0.00000000,-180.24000000); //
	CreateDynamicObject(19325,1101.76000000,-1452.47000000,16.22000000,0.00000000,0.00000000,-181.62000000); //
	CreateDynamicObject(19325,1101.77000000,-1434.88000000,16.22000000,0.00000000,0.00000000,-180.24000000); //
	CreateDynamicObject(19325,1094.31000000,-1444.92000000,23.47000000,0.00000000,0.00000000,-180.24000000); //
	CreateDynamicObject(19325,1094.37000000,-1458.37000000,23.47000000,0.00000000,0.00000000,-179.46000000); //
	CreateDynamicObject(19325,1093.01000000,-1517.44000000,23.44000000,0.00000000,0.00000000,-138.72000000); //
	CreateDynamicObject(19325,1101.08000000,-1526.64000000,23.42000000,0.00000000,0.00000000,-137.34000000); //
	CreateDynamicObject(19325,1155.12000000,-1526.38000000,23.46000000,0.00000000,0.00000000,-42.12000000); //
	CreateDynamicObject(19325,1163.09000000,-1517.25000000,23.46000000,0.00000000,0.00000000,-40.74000000); //
	CreateDynamicObject(19325,1163.04000000,-1442.06000000,23.40000000,0.00000000,0.00000000,-0.12000000); //
	CreateDynamicObject(19325,1163.09000000,-1428.47000000,23.50000000,0.00000000,0.00000000,0.54000000); //
	CreateDynamicObject(19326,1155.34000000,-1446.73000000,16.38000000,0.00000000,0.00000000,-89.82000000); //
	CreateDynamicObject(19326,1155.25000000,-1443.85000000,16.36000000,0.00000000,0.00000000,-89.82000000); //
	CreateDynamicObject(19326,1155.37000000,-1436.32000000,16.36000000,0.00000000,0.00000000,-89.82000000); //
	CreateDynamicObject(19326,1155.35000000,-1433.51000000,16.36000000,0.00000000,0.00000000,-89.70000000); //
	CreateDynamicObject(19329,1155.18000000,-1440.22000000,18.70000000,0.00000000,0.00000000,89.04000000); //
	CreateDynamicObject(19329,1161.59000000,-1431.50000000,17.93000000,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(19329,1160.40000000,-1448.79000000,17.96000000,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(2543,1168.18000000,-1436.39000000,14.79000000,0.00000000,0.00000000,0.30000000); //
	CreateDynamicObject(2535,1182.74000000,-1448.30000000,14.70000000,0.00000000,0.00000000,-90.96000000); //
	CreateDynamicObject(2543,1167.10000000,-1436.40000000,14.79000000,0.00000000,0.00000000,0.31000000); //
	CreateDynamicObject(2538,1172.31000000,-1435.32000000,14.79000000,0.00000000,0.00000000,180.34000000); //
	CreateDynamicObject(2539,1171.38000000,-1435.31000000,14.79000000,0.00000000,0.00000000,180.19000000); //
	CreateDynamicObject(2540,1169.56000000,-1435.36000000,14.79000000,0.00000000,0.00000000,180.17000000); //
	CreateDynamicObject(1984,1157.37000000,-1442.59000000,14.79000000,0.00000000,0.00000000,-450.06000000); //
	CreateDynamicObject(2012,1163.25000000,-1448.31000000,14.75000000,0.00000000,0.00000000,-179.16000000); //
	CreateDynamicObject(2012,1169.29000000,-1431.92000000,14.75000000,0.00000000,0.00000000,359.80000000); //
	CreateDynamicObject(1987,1163.13000000,-1436.34000000,14.79000000,0.00000000,0.00000000,361.06000000); //
	CreateDynamicObject(1988,1164.13000000,-1436.33000000,14.79000000,0.00000000,0.00000000,360.80000000); //
	CreateDynamicObject(2871,1164.79000000,-1443.96000000,14.79000000,0.00000000,0.00000000,177.73000000); //
	CreateDynamicObject(2871,1164.70000000,-1444.98000000,14.79000000,0.00000000,0.00000000,358.07000000); //
	CreateDynamicObject(2942,1155.52000000,-1464.68000000,15.43000000,0.00000000,0.00000000,-71.22000000); //
	CreateDynamicObject(1987,1164.12000000,-1435.32000000,14.77000000,0.00000000,0.00000000,180.96000000); //
	CreateDynamicObject(2530,1171.13000000,-1443.79000000,14.79000000,0.00000000,0.00000000,-182.16000000); //
	CreateDynamicObject(1991,1173.75000000,-1439.56000000,14.79000000,0.00000000,0.00000000,179.47000000); //
	CreateDynamicObject(1996,1169.82000000,-1439.50000000,14.79000000,0.00000000,0.00000000,179.10000000); //
	CreateDynamicObject(1996,1174.24000000,-1435.38000000,14.79000000,0.00000000,0.00000000,179.24000000); //
	CreateDynamicObject(1991,1175.23000000,-1435.39000000,14.79000000,0.00000000,0.00000000,179.57000000); //
	CreateDynamicObject(1995,1182.65000000,-1435.10000000,14.79000000,0.00000000,0.00000000,90.00000000); //
	CreateDynamicObject(1994,1182.66000000,-1438.07000000,14.79000000,0.00000000,0.00000000,90.00000000); //
	CreateDynamicObject(1993,1182.66000000,-1437.08000000,14.79000000,0.00000000,0.00000000,90.00000000); //
	CreateDynamicObject(2542,1163.78000000,-1443.92000000,14.76000000,0.00000000,0.00000000,178.77000000); //
	CreateDynamicObject(2536,1166.88000000,-1445.07000000,14.70000000,0.00000000,0.00000000,-0.42000000); //
	CreateDynamicObject(2542,1163.70000000,-1444.93000000,14.78000000,0.00000000,0.00000000,-1.74000000); //
	CreateDynamicObject(1984,1157.34000000,-1435.71000000,14.79000000,0.00000000,0.00000000,-450.06000000); //
	CreateDynamicObject(2012,1166.31000000,-1448.28000000,14.75000000,0.00000000,0.00000000,-180.12000000); //
	CreateDynamicObject(2530,1172.14000000,-1443.83000000,14.79000000,0.00000000,0.00000000,-181.38000000); //
	CreateDynamicObject(2530,1173.14000000,-1443.85000000,14.79000000,0.00000000,0.00000000,-180.96000000); //
	CreateDynamicObject(2530,1174.13000000,-1443.88000000,14.79000000,0.00000000,0.00000000,-181.50000000); //
	CreateDynamicObject(1981,1170.76000000,-1439.52000000,14.79000000,0.00000000,0.00000000,-181.74000000); //
	CreateDynamicObject(1981,1171.76000000,-1439.54000000,14.79000000,0.00000000,0.00000000,-180.80000000); //
	CreateDynamicObject(1981,1172.75000000,-1439.55000000,14.79000000,0.00000000,0.00000000,-180.84000000); //
	CreateDynamicObject(2535,1182.75000000,-1447.28000000,14.70000000,0.00000000,0.00000000,-90.78000000); //
	CreateDynamicObject(2535,1182.74000000,-1446.28000000,14.70000000,0.00000000,0.00000000,-90.78000000); //
	CreateDynamicObject(2535,1182.74000000,-1445.26000000,14.70000000,0.00000000,0.00000000,-90.00000000); //
	CreateDynamicObject(2541,1182.75000000,-1444.22000000,14.79000000,0.00000000,0.00000000,-90.06000000); //
	CreateDynamicObject(2541,1182.75000000,-1443.20000000,14.79000000,0.00000000,0.00000000,-90.06000000); //
	CreateDynamicObject(2541,1182.74000000,-1442.16000000,14.79000000,0.00000000,0.00000000,-90.06000000); //
	CreateDynamicObject(2543,1182.76000000,-1441.18000000,14.79000000,0.00000000,0.00000000,-90.84000000); //
	CreateDynamicObject(2541,1182.79000000,-1440.17000000,14.79000000,0.00000000,0.00000000,-90.06000000); //
	CreateDynamicObject(2543,1182.72000000,-1439.15000000,14.79000000,0.00000000,0.00000000,-90.84000000); //
	CreateDynamicObject(1990,1182.66000000,-1431.67000000,14.79000000,0.00000000,0.00000000,3.30000000); //
	CreateDynamicObject(1990,1181.63000000,-1431.73000000,14.79000000,0.00000000,0.00000000,3.30000000); //
	CreateDynamicObject(1990,1180.61000000,-1431.81000000,14.79000000,0.00000000,0.00000000,3.30000000); //
	CreateDynamicObject(1990,1179.61000000,-1431.83000000,14.79000000,0.00000000,0.00000000,3.30000000); //
	CreateDynamicObject(1990,1178.61000000,-1431.89000000,14.79000000,0.00000000,0.00000000,3.30000000); //
	CreateDynamicObject(1990,1177.59000000,-1431.86000000,14.79000000,0.00000000,0.00000000,3.30000000); //
	CreateDynamicObject(1993,1182.66000000,-1436.09000000,14.79000000,0.00000000,0.00000000,90.00000000); //
	CreateDynamicObject(2012,1175.50000000,-1431.82000000,14.75000000,0.00000000,0.00000000,361.17000000); //
	CreateDynamicObject(2012,1172.42000000,-1431.87000000,14.75000000,0.00000000,0.00000000,359.93000000); //
	CreateDynamicObject(2012,1160.10000000,-1448.35000000,14.75000000,0.00000000,0.00000000,-179.94000000); //
	CreateDynamicObject(2539,1170.45000000,-1435.33000000,14.79000000,0.00000000,0.00000000,181.26000000); //
	CreateDynamicObject(2545,1161.82000000,-1431.84000000,14.91000000,0.00000000,0.00000000,-90.54000000); //
	CreateDynamicObject(2545,1160.82000000,-1431.83000000,14.91000000,0.00000000,0.00000000,-90.54000000); //
	CreateDynamicObject(2545,1159.81000000,-1431.86000000,14.91000000,0.00000000,0.00000000,-90.54000000); //
	CreateDynamicObject(2545,1162.82000000,-1431.87000000,14.91000000,0.00000000,0.00000000,-90.54000000); //
	CreateDynamicObject(1988,1163.13000000,-1435.34000000,14.79000000,0.00000000,0.00000000,541.46000000); //
	CreateDynamicObject(1988,1166.07000000,-1436.32000000,14.79000000,0.00000000,0.00000000,360.80000000); //
	CreateDynamicObject(1987,1165.07000000,-1436.33000000,14.79000000,0.00000000,0.00000000,361.06000000); //
	CreateDynamicObject(1987,1166.11000000,-1435.30000000,14.77000000,0.00000000,0.00000000,180.96000000); //
	CreateDynamicObject(1988,1165.07000000,-1435.31000000,14.79000000,0.00000000,0.00000000,540.44000000); //
	CreateDynamicObject(2536,1165.79000000,-1445.07000000,14.70000000,0.00000000,0.00000000,-1.20000000); //
	CreateDynamicObject(2536,1167.83000000,-1445.07000000,14.70000000,0.00000000,0.00000000,-0.06000000); //
	CreateDynamicObject(2871,1165.79000000,-1444.00000000,14.79000000,0.00000000,0.00000000,178.27000000); //
	CreateDynamicObject(2871,1166.81000000,-1444.03000000,14.79000000,0.00000000,0.00000000,179.35000000); //
	CreateDynamicObject(2871,1167.79000000,-1444.04000000,14.79000000,0.00000000,0.00000000,179.89000000); //
	CreateDynamicObject(2543,1168.13000000,-1435.36000000,14.79000000,0.00000000,0.00000000,180.05000000); //
	CreateDynamicObject(2543,1167.10000000,-1435.37000000,14.79000000,0.00000000,0.00000000,180.35000000); //
	CreateDynamicObject(2012,1170.63000000,-1440.67000000,14.75000000,0.00000000,0.00000000,359.50000000); //
	CreateDynamicObject(2012,1173.77000000,-1440.72000000,14.75000000,0.00000000,0.00000000,359.82000000); //
	CreateDynamicObject(2012,1177.30000000,-1445.31000000,14.75000000,0.00000000,0.00000000,359.93000000); //
	CreateDynamicObject(1996,1173.36000000,-1448.30000000,14.79000000,0.00000000,0.00000000,179.10000000); //
	CreateDynamicObject(1981,1174.33000000,-1448.32000000,14.79000000,0.00000000,0.00000000,-181.74000000); //
	CreateDynamicObject(1981,1175.32000000,-1448.35000000,14.79000000,0.00000000,0.00000000,-180.84000000); //
	CreateDynamicObject(1981,1176.30000000,-1448.37000000,14.79000000,0.00000000,0.00000000,-180.84000000); //
	CreateDynamicObject(1991,1177.28000000,-1448.37000000,14.79000000,0.00000000,0.00000000,179.47000000); //
	CreateDynamicObject(1996,1178.33000000,-1448.36000000,14.79000000,0.00000000,0.00000000,179.24000000); //
	CreateDynamicObject(1991,1179.33000000,-1448.37000000,14.79000000,0.00000000,0.00000000,179.57000000); //
	CreateDynamicObject(1994,1176.82000000,-1444.16000000,14.79000000,0.00000000,0.00000000,-0.84000000); //
	CreateDynamicObject(1995,1178.81000000,-1444.20000000,14.79000000,0.00000000,0.00000000,-1.26000000); //
	CreateDynamicObject(2543,1168.89000000,-1444.06000000,14.79000000,0.00000000,0.00000000,178.97000000); //
	CreateDynamicObject(2543,1169.91000000,-1444.07000000,14.79000000,0.00000000,0.00000000,179.69000000); //
	CreateDynamicObject(2543,1169.87000000,-1445.12000000,14.79000000,0.00000000,0.00000000,-0.06000000); //
	CreateDynamicObject(2543,1168.86000000,-1445.11000000,14.79000000,0.00000000,0.00000000,0.31000000); //
	CreateDynamicObject(2538,1167.02000000,-1431.87000000,14.79000000,0.00000000,0.00000000,0.42000000); //
	CreateDynamicObject(2539,1166.03000000,-1431.89000000,14.79000000,0.00000000,0.00000000,0.70000000); //
	CreateDynamicObject(2540,1164.04000000,-1431.91000000,14.79000000,0.00000000,0.00000000,0.60000000); //
	CreateDynamicObject(2539,1165.03000000,-1431.91000000,14.79000000,0.00000000,0.00000000,1.02000000); //
	CreateDynamicObject(2538,1176.17000000,-1436.38000000,14.79000000,0.00000000,0.00000000,0.24000000); //
	CreateDynamicObject(2539,1174.22000000,-1436.37000000,14.79000000,0.00000000,0.00000000,-0.06000000); //
	CreateDynamicObject(2540,1173.22000000,-1436.36000000,14.79000000,0.00000000,0.00000000,0.18000000); //
	CreateDynamicObject(2539,1175.20000000,-1436.38000000,14.79000000,0.00000000,0.00000000,-2.06000000); //
	CreateDynamicObject(2540,1173.26000000,-1435.31000000,14.79000000,0.00000000,0.00000000,180.17000000); //
	CreateDynamicObject(1991,1175.74000000,-1439.58000000,14.79000000,0.00000000,0.00000000,179.57000000); //
	CreateDynamicObject(1996,1174.74000000,-1439.57000000,14.79000000,0.00000000,0.00000000,179.24000000); //
	CreateDynamicObject(1996,1176.17000000,-1435.37000000,14.79000000,0.00000000,0.00000000,179.24000000); //
	CreateDynamicObject(1991,1177.16000000,-1435.38000000,14.79000000,0.00000000,0.00000000,179.57000000); //
	CreateDynamicObject(2540,1169.44000000,-1436.35000000,14.79000000,0.00000000,0.00000000,0.18000000); //
	CreateDynamicObject(2539,1170.43000000,-1436.35000000,14.79000000,0.00000000,0.00000000,0.90000000); //
	CreateDynamicObject(2539,1171.34000000,-1436.33000000,14.79000000,0.00000000,0.00000000,0.58000000); //
	CreateDynamicObject(2538,1172.22000000,-1436.32000000,14.79000000,0.00000000,0.00000000,0.30000000); //
	CreateDynamicObject(2871,1163.40000000,-1440.68000000,14.79000000,0.00000000,0.00000000,360.41000000); //
	CreateDynamicObject(2536,1164.49000000,-1440.73000000,14.70000000,0.00000000,0.00000000,-1.20000000); //
	CreateDynamicObject(2536,1165.49000000,-1440.75000000,14.70000000,0.00000000,0.00000000,-0.42000000); //
	CreateDynamicObject(2536,1166.50000000,-1440.75000000,14.70000000,0.00000000,0.00000000,-0.06000000); //
	CreateDynamicObject(2543,1167.61000000,-1440.64000000,14.79000000,0.00000000,0.00000000,0.31000000); //
	CreateDynamicObject(2543,1168.62000000,-1440.64000000,14.79000000,0.00000000,0.00000000,0.30000000); //
	CreateDynamicObject(2543,1168.64000000,-1439.60000000,14.79000000,0.00000000,0.00000000,180.05000000); //
	CreateDynamicObject(2543,1167.67000000,-1439.61000000,14.79000000,0.00000000,0.00000000,180.35000000); //
	CreateDynamicObject(2871,1163.65000000,-1439.67000000,14.79000000,0.00000000,0.00000000,180.61000000); //
	CreateDynamicObject(2871,1164.68000000,-1439.67000000,14.79000000,0.00000000,0.00000000,179.77000000); //
	CreateDynamicObject(2871,1165.68000000,-1439.68000000,14.79000000,0.00000000,0.00000000,180.61000000); //
	CreateDynamicObject(2871,1166.68000000,-1439.66000000,14.79000000,0.00000000,0.00000000,180.61000000); //
	CreateDynamicObject(1990,1175.09000000,-1444.97000000,14.79000000,0.00000000,0.00000000,-2.46000000); //
	CreateDynamicObject(1990,1181.63000000,-1431.73000000,14.79000000,0.00000000,0.00000000,3.30000000); //
	CreateDynamicObject(1990,1174.07000000,-1444.94000000,14.79000000,0.00000000,0.00000000,0.48000000); //
	CreateDynamicObject(1990,1173.09000000,-1444.94000000,14.79000000,0.00000000,0.00000000,-1.20000000); //
	CreateDynamicObject(1990,1172.11000000,-1444.92000000,14.79000000,0.00000000,0.00000000,-1.14000000); //
	CreateDynamicObject(1990,1171.12000000,-1444.91000000,14.79000000,0.00000000,0.00000000,-0.72000000); //
	CreateDynamicObject(2530,1168.54000000,-1448.31000000,14.79000000,0.00000000,0.00000000,-178.98000000); //
	CreateDynamicObject(2530,1169.60000000,-1448.29000000,14.79000000,0.00000000,0.00000000,-178.98000000); //
	CreateDynamicObject(2530,1170.67000000,-1448.30000000,14.79000000,0.00000000,0.00000000,-178.98000000); //
	CreateDynamicObject(2530,1171.72000000,-1448.32000000,14.79000000,0.00000000,0.00000000,-181.50000000); //
	CreateDynamicObject(2530,1175.13000000,-1443.91000000,14.79000000,0.00000000,0.00000000,-181.50000000); //
	CreateDynamicObject(2012,1176.82000000,-1440.75000000,14.75000000,0.00000000,0.00000000,359.93000000); //
	CreateDynamicObject(1995,1177.71000000,-1439.63000000,14.79000000,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(1994,1176.73000000,-1439.63000000,14.79000000,0.00000000,0.00000000,0.06000000); //
	CreateDynamicObject(1993,1177.83000000,-1444.15000000,14.79000000,0.00000000,0.00000000,179.46000000); //
	return 1;
}

stock firstPlayerSpawn(const playerid) {
	playerVariables[playerid][pTutorial] = 0;
	playerVariables[playerid][pFirstLogin] = 0;

	playerVariables[playerid][pInterior] = 0;
	playerVariables[playerid][pVirtualWorld] = 0;

	SetSpawnInfo(playerid, 0, playerVariables[playerid][pSkin], playerVariables[playerid][pPos][0], playerVariables[playerid][pPos][1], playerVariables[playerid][pPos][2], 0, 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);

	TextDrawHideForPlayer(playerid, textdrawVariables[3]);
	return 1;
}

function initiateTutorial(const playerid) {
	// Clear the dialog if it still exists from the quiz...
    hidePlayerDialog(playerid);
    
    // Clear the variable storing the timer handle if it still exists from the quiz...
    if(GetPVarType(playerid, "tutt") != 0)
        DeletePVar(playerid, "tutt");
    
	GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);

	format(szMessage, sizeof(szMessage), "Welcome to "SERVER_NAME", %s.", szPlayerName);

    SendClientMessage(playerid, COLOR_TEAL, "----------------------------------------------------------------------------");
	SendClientMessage(playerid, COLOR_YELLOW, szMessage);
	SendClientMessage(playerid, COLOR_WHITE, "Please select your style of clothing from the selection below.");

	playerVariables[playerid][pTutorial] = 1;

	playerVariables[playerid][pVirtualWorld] = playerid+50;

	SetSpawnInfo(playerid, 0, 0, 220.4862, 1822.8994, 7.5387, 268.3423, 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);
	SetPlayerPos(playerid, 220.4862, 1822.8994, 7.5387);
	SetPlayerFacingAngle(playerid, 268.3423);
	TogglePlayerControllable(playerid, false);

	TextDrawShowForPlayer(playerid, textdrawVariables[2]);
	return 1;
}

stock GetDistanceBetweenPlayers(playerid, playerid2) {
	new
	    Float:Floats[7];

	GetPlayerPos(playerid, Floats[0], Floats[1], Floats[2]);
	GetPlayerPos(playerid2, Floats[3], Floats[4], Floats[5]);
	Floats[6] = floatsqroot((Floats[3]-Floats[0])*(Floats[3]-Floats[0])+(Floats[4]-Floats[1])*(Floats[4]-Floats[1])+(Floats[5]-Floats[2])*(Floats[5]-Floats[2]));

	return floatround(Floats[6]);
}

stock GetDistancePlayerVeh(playerid, veh) {

	new
	    Float:Floats[7];

	GetPlayerPos(playerid, Floats[0], Floats[1], Floats[2]);
	GetVehiclePos(veh, Floats[3], Floats[4], Floats[5]);
	Floats[6] = floatsqroot((Floats[3]-Floats[0])*(Floats[3]-Floats[0])+(Floats[4]-Floats[1])*(Floats[4]-Floats[1])+(Floats[5]-Floats[2])*(Floats[5]-Floats[2]));

	return floatround(Floats[6]);
}

stock IsPlayerInRangeOfVehicle(playerid, vehicleid, Float: radius) {

	new
		Float:Floats[3];

	GetVehiclePos(vehicleid, Floats[0], Floats[1], Floats[2]);
	return IsPlayerInRangeOfPoint(playerid, radius, Floats[0], Floats[1], Floats[2]);
}

stock IsPlayerInRangeOfPlayer(playerid, playerid2, Float: radius) {

	new
		Float:Floats[3];

	GetPlayerPos(playerid2, Floats[0], Floats[1], Floats[2]);
	return IsPlayerInRangeOfPoint(playerid, radius, Floats[0], Floats[1], Floats[2]);
}

stock IsVehicleInRangeOfPoint(vehicleid, Float: radius, Float:x, Float:y, Float:z) {

	new
		Float:Floats[6];

	GetVehiclePos(vehicleid, Floats[0], Floats[1], Floats[2]);
	Floats[3] = (Floats[0] -x);
	Floats[4] = (Floats[1] -y);
	Floats[5] = (Floats[2] -z);
	if (((Floats[3] < radius) && (Floats[3] > -radius)) && ((Floats[4] < radius) && (Floats[4] > -radius)) && ((Floats[5] < radius) && (Floats[5] > -radius)))
		return 1;
	return 0;
}

stock GetPlayerSpeed(playerid, get3d) // Need this for fixcar
{
	new
		Float:Floats[3];

	if(IsPlayerInAnyVehicle(playerid))
	    GetVehicleVelocity(GetPlayerVehicleID(playerid), Floats[0], Floats[1], Floats[2]);
	else
	    GetPlayerVelocity(playerid, Floats[0], Floats[1], Floats[2]);

	return SpeedCheck(Floats[0], Floats[1], Floats[2], 100.0, get3d);
}

stock givePlayerWeapons(playerid) {
	new
	    x;

	while(x < 13) {
		GivePlayerWeapon(playerid, playerVariables[playerid][pWeapons][x], 99999);
		x++;
	}

	return 1;
}

//	Credits to Westie for explode, from his strlib include.
stock explode(aExplode[][], const sSource[], const sDelimiter[] = " ", iVertices = sizeof aExplode, iLength = sizeof aExplode[])
{
	new
		iNode,
		iPointer,
		iPrevious = -1,
		iDelimiter = strlen(sDelimiter);

	while(iNode < iVertices)
	{
		iPointer = strfind(sSource, sDelimiter, false, iPointer);

		if(iPointer == -1)
		{
			strmid(aExplode[iNode], sSource, iPrevious, strlen(sSource), iLength);
			break;
		}
		else
		{
			strmid(aExplode[iNode], sSource, iPrevious, iPointer, iLength);
		}

		iPrevious = (iPointer += iDelimiter);
		++iNode;
	}

	return iPrevious;
}

stock removePlayerWeapon(playerid, weapon) {
	playerVariables[playerid][pAnticheatExemption] = 6;

	switch(weapon) {
		case 0, 1: {
		    if(playerVariables[playerid][pTabbed] >= 1) {
		        playerVariables[playerid][pOutstandingWeaponRemovalSlot] = 0;
		    }
		    else {
			    ResetPlayerWeapons(playerid);
		        playerVariables[playerid][pWeapons][0] = 0;
				givePlayerWeapons(playerid);
			}
	    }
	    case 2, 3, 4, 5, 6, 7, 8, 9: {
		    if(playerVariables[playerid][pTabbed] >= 1) {
		        playerVariables[playerid][pOutstandingWeaponRemovalSlot] = 1;
		    }
		    else {
			    ResetPlayerWeapons(playerid);
		        playerVariables[playerid][pWeapons][1] = 0;
				givePlayerWeapons(playerid);
			}
	    }
	    case 22, 23, 24: {
		    if(playerVariables[playerid][pTabbed] >= 1) {
		        playerVariables[playerid][pOutstandingWeaponRemovalSlot] = 2;
		    }
		    else {
			    ResetPlayerWeapons(playerid);
		        playerVariables[playerid][pWeapons][2] = 0;
				givePlayerWeapons(playerid);
			}
	    }
	    case 25, 26, 27: {
		    if(playerVariables[playerid][pTabbed] >= 1) {
		        playerVariables[playerid][pOutstandingWeaponRemovalSlot] = 3;
		    }
		    else {
			    ResetPlayerWeapons(playerid);
		        playerVariables[playerid][pWeapons][3] = 0;
				givePlayerWeapons(playerid);
			}
	    }
	    case 28, 29, 32: {
		    if(playerVariables[playerid][pTabbed] >= 1) {
		        playerVariables[playerid][pOutstandingWeaponRemovalSlot] = 4;
		    }
		    else {
			    ResetPlayerWeapons(playerid);
		        playerVariables[playerid][pWeapons][4] = 0;
				givePlayerWeapons(playerid);
			}
	    }
	    case 30, 31: {
		    if(playerVariables[playerid][pTabbed] >= 1) {
		        playerVariables[playerid][pOutstandingWeaponRemovalSlot] = 5;
		    }
		    else {
			    ResetPlayerWeapons(playerid);
		        playerVariables[playerid][pWeapons][5] = 0;
				givePlayerWeapons(playerid);
			}
	    }
	    case 33, 34: {
		    if(playerVariables[playerid][pTabbed] >= 1) {
		        playerVariables[playerid][pOutstandingWeaponRemovalSlot] = 6;
		    }
		    else {
			    ResetPlayerWeapons(playerid);
		        playerVariables[playerid][pWeapons][6] = 0;
				givePlayerWeapons(playerid);
			}
	    }
	    case 35, 36, 37, 38: {
		    if(playerVariables[playerid][pTabbed] >= 1) {
		        playerVariables[playerid][pOutstandingWeaponRemovalSlot] = 7;
		    }
		    else {
			    ResetPlayerWeapons(playerid);
		        playerVariables[playerid][pWeapons][7] = 0;
				givePlayerWeapons(playerid);
			}
	    }
	    case 16, 17, 18, 39: {
		    if(playerVariables[playerid][pTabbed] >= 1) {
		        playerVariables[playerid][pOutstandingWeaponRemovalSlot] = 8;
		    }
		    else {
			    ResetPlayerWeapons(playerid);
		        playerVariables[playerid][pWeapons][8] = 0;
				givePlayerWeapons(playerid);
			}
	    }
	    case 41, 42, 43: {
		    if(playerVariables[playerid][pTabbed] >= 1) {
		        playerVariables[playerid][pOutstandingWeaponRemovalSlot] = 9;
		    }
		    else {
			    ResetPlayerWeapons(playerid);
		        playerVariables[playerid][pWeapons][9] = 0;
				givePlayerWeapons(playerid);
			}
	    }
	    case 10, 11, 12, 13, 14, 15: {
		    if(playerVariables[playerid][pTabbed] >= 1) {
		        playerVariables[playerid][pOutstandingWeaponRemovalSlot] = 10;
		    }
		    else {
			    ResetPlayerWeapons(playerid);
		        playerVariables[playerid][pWeapons][10] = 0;
				givePlayerWeapons(playerid);
			}
	    }
	    case 44, 45, 46: {
		    if(playerVariables[playerid][pTabbed] >= 1) {
		        playerVariables[playerid][pOutstandingWeaponRemovalSlot] = 11;
		    }
		    else {
			    ResetPlayerWeapons(playerid);
		        playerVariables[playerid][pWeapons][11] = 0;
				givePlayerWeapons(playerid);
			}
	    }
	    case 40: {
		    if(playerVariables[playerid][pTabbed] >= 1) {
		        playerVariables[playerid][pOutstandingWeaponRemovalSlot] = 12;
		    }
		    else {
			    ResetPlayerWeapons(playerid);
		        playerVariables[playerid][pWeapons][12] = 0;
				givePlayerWeapons(playerid);
			}
	    }
	}
	return 1;
}

function antiCheat() 
{
	foreach(Player, i) 
	{
		if(playerVariables[i][pStatus] == 1 && playerVariables[i][pAdminLevel] < 3)
		{
			if(GetPlayerSpecialAction(i) == SPECIAL_ACTION_USEJETPACK && playerVariables[i][pJetpack] == 0 && playerVariables[i][pAdminLevel] == 0)
			{
				scriptBan(i, "Hacking (jetpack)");
			}
			else if(playerVariables[i][pEvent] == 0 && playerVariables[i][pAnticheatExemption] == 0)
			{
				temp = GetPlayerWeapon(i);
				if(temp > 0 && GetPlayerState(i) == 1)
				{
					if(playerVariables[i][pWeapons][GetWeaponSlot(temp)] != temp)
						hackerTrigger(i);
				}
				// else if(eventVariables[eEventStat] != 0) // Event anticheat - check 5 event weapon slots, checks if the weapon is valid (in case of a bug).
				// {
				// 	// Valid weapon check (in case someone has admin weapons)
				// 	if(eventVariables[eEventWeapons][0] != temp && eventVariables[eEventWeapons][1] != temp && eventVariables[eEventWeapons][2] != temp && eventVariables[eEventWeapons][3] != temp && eventVariables[eEventWeapons][4] != temp) 
				// 	{ 
				// 		 if(playerVariables[i][pWeapons][GetWeaponSlot(temp)] != temp) hackerTrigger(i);
				// 	}
				// }
			}
		}
	}
	return 1;
}

stock hackerTrigger(playerid) {
	if(playerVariables[playerid][pTabbed] == 0) {
	    playerVariables[playerid][pHackWarnings]++;
	    playerVariables[playerid][pHackWarnTime] = 1;

	    printf("Hack Warning! Weapon %d (playerid: %d)", GetPlayerWeapon(playerid), playerid);

	    if(playerVariables[playerid][pHackWarnings] >= 3) {

			new
				wep = GetPlayerWeapon(playerid),
		        reason[94];

			GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);

			format(reason, sizeof(reason), "Warning: {FFFFFF}%s may possibly be weapon hacking (%s).", szPlayerName, WeaponNames[wep]);
			submitToAdmins(reason, COLOR_HOTORANGE);

		    if(playerVariables[playerid][pHackWarnings] >= MAX_WEAPON_HACK_WARNINGS) {
		        format(reason, sizeof(reason), "Weapon Hacking (%s).", WeaponNames[wep]);
		        scriptBan(playerid, reason);
		    }
		}
    }
	return 1;
}

stock scriptBan(playerid, reason[]) 
{
	new playerIP[32],
	    aString[240];

	GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
	GetPlayerIp(playerid, playerIP, sizeof(playerIP));

	playerVariables[playerid][pBanned] = 1;

   	format(aString, sizeof(aString), "Ban: %s has been banned, reason: %s", szPlayerName, reason);
   	SendClientMessageToAll(COLOR_LIGHTRED, aString);

    mysql_real_escape_string(aString, aString);
    adminLog(aString);

	Kick(playerid);

   	format(aString, sizeof(aString), "INSERT INTO bans(playerNameBanned,playerBanReason,IPBanned) VALUES('%s','%s','%s')", szPlayerName, reason, playerIP);
	mysql_query(aString);
	return 1;
}

stock IPBan(ip[], reason[], name[] = "Nobody") 
{
	new cleanReason[64],
	    querySz[150]; // To be on the safe side.

	mysql_real_escape_string(reason, cleanReason);
	format(querySz, sizeof(querySz), "INSERT INTO bans(playerNameBanned,playerBanReason,IPBanned) VALUES('%s','%s','%s')", name, reason, ip);
	mysql_query(querySz);
	return 1;
}
stock showStats(playerid, targetid) {
	new
		param1[32],
		date[3],
		param2[32],
		param4[32],
		param3[32]; // I'll add one or two more of these later, they'll be used to show things like sex (if sex = whatever, param1 = "Male";). And we can use them over and over again.

    SendClientMessage(playerid, COLOR_TEAL, "--------------------------------------------------------------------------------------------------------------------------------");

	getdate(date[0], date[1], date[2]);

	if(playerVariables[targetid][pJob] == 0) { param1 = "Unemployed"; }
	else { strcpy(param1, jobVariables[playerVariables[targetid][pJob]][jJobName], sizeof(param1)); } // dest, source, length format(param1, sizeof(param1),"%s",jobVariables[playerVariables[targetid][pJob]][jJobName]); }

	switch(playerVariables[targetid][pGender]) { //{ param2 = "Male"; } else { param2 = "Female"; }
		case 1: param2 = "Male";
		case 2: param2 = "Female";
		default: param2 = "Unknown";
	}

	if(playerVariables[targetid][pPhoneNumber] != -1) { format(param3,sizeof(param3),"%d",playerVariables[targetid][pPhoneNumber]); }
	else { param3 = "None"; }

	format(szMessage, sizeof(szMessage), "%s | Age: %d (born %d) | Gender: %s | Playing hours: %d | Phone number: %s | Job: %s", playerVariables[targetid][pNormalName], date[0]-playerVariables[targetid][pAge], playerVariables[targetid][pAge], param2, playerVariables[targetid][pPlayingHours], param3, param1, param4);
	SendClientMessage(playerid, COLOR_WHITE, szMessage);

	if(playerVariables[targetid][pGroup] < 1) {
		param1 = "None";
		param2 = "None";
	}
	else {
		format(param1, sizeof(param1), "%s", groupVariables[playerVariables[targetid][pGroup]][gGroupName]);

		switch(playerVariables[targetid][pGroupRank]) { // strcpy(dest, source, length);
			case 1: format(param2, sizeof(param2), "%s", groupVariables[playerVariables[targetid][pGroup]][gGroupRankName1]);
			case 2: format(param2, sizeof(param2), "%s", groupVariables[playerVariables[targetid][pGroup]][gGroupRankName2]);
			case 3: format(param2, sizeof(param2), "%s", groupVariables[playerVariables[targetid][pGroup]][gGroupRankName3]);
			case 4: format(param2, sizeof(param2), "%s", groupVariables[playerVariables[targetid][pGroup]][gGroupRankName4]);
			case 5: format(param2, sizeof(param2), "%s", groupVariables[playerVariables[targetid][pGroup]][gGroupRankName5]);
			case 6: format(param2, sizeof(param2), "%s", groupVariables[playerVariables[targetid][pGroup]][gGroupRankName6]);
		}
	}

	if(playerVariables[targetid][pWalkieTalkie] == -1) param3 = "None";
	else if(playerVariables[targetid][pWalkieTalkie] == 0) param3 = "Disabled";
	else format(param3, sizeof(param3), "#%d khz", playerVariables[targetid][pWalkieTalkie]);

	format(szMessage, sizeof(szMessage), "Group: %s | Rank: %s (%d) | Bank: $%d | Cash: $%d | Materials: %d | Radio: %s", param1, param2, playerVariables[targetid][pGroupRank], playerVariables[targetid][pBankMoney], playerVariables[targetid][pMoney], playerVariables[targetid][pMaterials], param3);
	SendClientMessage(playerid, COLOR_WHITE, szMessage);

	format(szMessage, sizeof(szMessage), "Rope: %d | Weapon skill: %d (%d weapons) | Tracking skill: %d (%d searches) | Arrests: %d | Crimes: %d | Credit: $%d", playerVariables[targetid][pRope], playerVariables[targetid][pJobSkill][0]/50, playerVariables[targetid][pJobSkill][0], playerVariables[targetid][pJobSkill][1]/50, playerVariables[targetid][pJobSkill][1], playerVariables[targetid][pArrests], playerVariables[targetid][pCrimes], playerVariables[targetid][pPhoneCredit] / 60);
	SendClientMessage(playerid, COLOR_WHITE, szMessage);

	if(playerVariables[playerid][pAdminLevel] >= 1) {
		new
			Float:HAFloats[2],
			country[MAX_COUNTRY_NAME];

		GetPlayerHealth(targetid,HAFloats[0]);
		GetPlayerArmour(targetid,HAFloats[1]);
		GetCountryName(playerVariables[targetid][pConnectionIP], country, sizeof(country));

		if(playerVariables[targetid][pCarModel] >= 400)
			format(param4, sizeof(param4), "%s (ID %d)", VehicleNames[playerVariables[targetid][pCarModel] - 400], playerVariables[targetid][pCarID]);
		else
			param4 = "None";

		param1 = (playerVariables[targetid][pStatus] != 1) ? ("Unauthenticated") : ("Authenticated");
			
		format(szMessage, sizeof(szMessage), "Status: %s | Admin Level: %d | Interior: %d | VW: %d | House: %d | Business: %d | Vehicle: %s", param1, playerVariables[targetid][pAdminLevel], playerVariables[targetid][pInterior], playerVariables[targetid][pVirtualWorld], getPlayerHouseID(targetid), getPlayerBusinessID(targetid), param4);
		SendClientMessage(playerid, COLOR_WHITE, szMessage);

		switch(playerVariables[targetid][pPrisonID]) {
			case 0: format(szMessage, sizeof(szMessage), "IP: %s | Country: %s | Admin Name: %s | Health: %.1f | Armour: %.1f", playerVariables[targetid][pConnectionIP], country, playerVariables[targetid][pAdminName], HAFloats[0], HAFloats[1]);
			case 1: format(szMessage, sizeof(szMessage), "IP: %s | Country: %s | Admin Name: %s | Health: %.1f | Armour: %.1f | Admin Prison Time: %d", playerVariables[targetid][pConnectionIP], country, playerVariables[targetid][pAdminName], HAFloats[0], HAFloats[1], playerVariables[targetid][pPrisonTime]);
			case 2: format(szMessage, sizeof(szMessage), "IP: %s | Country: %s | Admin Name: %s | Health: %.1f | Armour: %.1f | Admin Jail Time: %d", playerVariables[targetid][pConnectionIP], country, playerVariables[targetid][pAdminName], HAFloats[0], HAFloats[1], playerVariables[targetid][pPrisonTime]);
			case 3: format(szMessage, sizeof(szMessage), "IP: %s | Country: %s | Admin Name: %s | Health: %.1f | Armour: %.1f | Jail Time: %d", playerVariables[targetid][pConnectionIP], country, playerVariables[targetid][pAdminName], HAFloats[0], HAFloats[1], playerVariables[targetid][pPrisonTime]);
		}

		SendClientMessage(playerid, COLOR_WHITE, szMessage);
	}

	SendClientMessage(playerid, COLOR_TEAL, "--------------------------------------------------------------------------------------------------------------------------------");
	return 1;
}

stock invalidNameChange(playerid) {
	// Anti-spam mechanism to confirm the feature isn't being spammed
    if(gettime()-GetPVarInt(playerid, "namet") < 3) {
        if(GetPVarInt(playerid, "namett") != 0)
            KillTimer(GetPVarInt(playerid, "namett")); // Kill the timer if it already exists and let it create a new one
            
        // Call (self) again in 4 seconds to avoid clogging the server with useless requests
        SetPVarInt(playerid, "namett", SetTimerEx("invalidNameChange", 4000, false, "d", playerid));
        return 1;
    }
        
	format(playerVariables[playerid][pNormalName], MAX_PLAYER_NAME, "NONRPNAME[%d]", playerid);
	SetPlayerName(playerid, playerVariables[playerid][pNormalName]);
	
	SendClientMessage(playerid, COLOR_GREY, "You are being prompted to change your name. You can do this by following the instructions as they are written in the dialog.");
	ShowPlayerDialog(playerid, DIALOG_RP_NAME_CHANGE, DIALOG_STYLE_INPUT, "SERVER: Non RP name change", "This server has a strict name policy.\n\nYou must enter a valid roleplay name, the name must:\n- Be under 20 characters\n- Not contain numbers\n- Contain only two uppercase characters for the forename and surname\n- Be in the format of Forename_Surname", "OK", "Cancel");
	SetPVarInt(playerid, "namet", gettime());
	return 1;
}

/*stock despawnPlayersVehicles(playerid) {
	new
	    iIterator;

	for(;;) {
	    format(szSmallString, sizeof(szSmallString), "playerVehicle%d_RealID", iIterator);

	    if(GetPVarType(playerid, szSmallString) != 0)
	        DestroyVehicle(GetPVarInt(playerid, szSmallString));
		else
		    break;
		    
		iIterator++;
	}
	return 1;
}

stock getPlayerVehicleSlot(playerid, vehicleid) {
	new
	    iIterator;

	for(;;) {
	    format(szSmallString, sizeof(szSmallString), "playerVehicle%d_RealID", iIterator);

	    if(GetPVarInt(playerid, szSmallString) == vehicleid)
	        return iIterator;
		else
		    break;
		    
		iIterator++;
	}

	return -1;
}

stock getPlayerVehicleOwnerId(vehicleid) {
	new
	    iIterator;
	    
	foreach(Player, i) {
		for(;;) {
		    format(szSmallString, sizeof(szSmallString), "playerVehicle%d_RealID", iIterator);

		    if(GetPVarInt(playerid, szSmallString) == vehicleid)
		        return i;
			else
			    break;

			iIterator++;
		}
	}
	
	return INVALID_PLAYER_ID;
}

stock countPlayersVehicles(playerid) {
	new
	    iIterator,
	    iCount;
	    
	for(;;) {
	    format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Model", iIterator);
	    
	    if(GetPVarType(playerid, szSmallString) != 0)
	        iCount++;
		else
		    break;

		iIterator++;
	}
	
	return iCount;
}*/

stock suspensionCheck(playerid) {
	if(GetPVarType(playerid, "BSuspend") != 0) {
	    new
	        szReason[64],
			szSuspendee[MAX_PLAYER_NAME];

	    GetPVarString(playerid, "BSuspend", szReason, sizeof(szReason));
	    GetPVarString(playerid, "BSuspendee", szSuspendee, MAX_PLAYER_NAME);
	    format(szMessage, sizeof(szMessage), "Your bank account has been suspended by {FFFFFF}%s{CECECE}. Reason: {FFFFFF}%s{CECECE}.", szSuspendee, szReason);
	    SendClientMessage(playerid, COLOR_GREY, szMessage);
	    return 1;
	}

	return 0;
}

stock submitToAdmins(const string[], color) {
	foreach(Player, x) {
		if(playerVariables[x][pAdminLevel] >= 1) {
			SendClientMessage(x, color, string);
		}
	}
	return 1;
}

stock substr_count(substring[], string[]) {
	new
		tmpcount;

	for( new i = 0; i < strlen(string); i++)
	{
        if(strfind(string[i], substring, true))
        {
			tmpcount++;
        }
	}
	return tmpcount;
}
stock IsAPlane(vehicleid) {
	switch(GetVehicleModel(vehicleid)) {
		case 592, 577, 511, 512, 593, 520, 553, 476, 519, 460, 513, 548, 425, 417, 487, 488, 497, 563, 447, 469: return 1;
	}
	return 0;
}

stock IsABoat(vehicleid) {
	switch(GetVehicleModel(vehicleid)) {
		case 472, 473, 493, 595, 484, 430, 453, 452, 446, 454: return 1;
	}
	return 0;
}

stock SendToGroupType(type, colour, const szMessage2[]) {
	for(new iGroup; iGroup < MAX_GROUPS; iGroup++) {
	    if(groupVariables[iGroup][gGroupType] == type)
	        SendToGroup(iGroup, colour, szMessage2);
	}
	return 1;
}

stock IsACopCar(vehicleid) {
	switch(GetVehicleModel(vehicleid)) {
		case 596 .. 599: return 1;
	}
	return 0;
}

public OnPlayerStateChange(playerid, newstate, oldstate) {
	#if defined DEBUG
	    printf("[debug] OnPlayerStateChange(%d, %d, %d)", playerid, newstate, oldstate);
	#endif
	
	if(newstate == 3) {
		if(IsAPlane(GetPlayerVehicleID(playerid))) {
			givePlayerValidWeapon(playerid, 46);
		}
	}
	else if(newstate == 2) { // Removed the passenger check, as it caused weapons to bug.
		if(playerVariables[playerid][pEvent] == 0) {
			ResetPlayerWeapons(playerid);
			givePlayerWeapons(playerid);
		}
		if(IsAPlane(GetPlayerVehicleID(playerid))) {
			givePlayerValidWeapon(playerid, 46);
		}

		for(new i = 0; i < MAX_VEHICLES; i++) {
		    if(vehicleVariables[i][vVehicleScriptID] == GetPlayerVehicleID(playerid) && vehicleVariables[i][vVehicleGroup] != 0 && vehicleVariables[i][vVehicleGroup] != playerVariables[playerid][pGroup]) {

				if(playerVariables[playerid][pAdminLevel] >= 1 && playerVariables[playerid][pAdminDuty] >= 1) {
					format(szMessage, sizeof(szMessage), "This %s (model %d, ID %d) is locked to group %s (%d).", VehicleNames[GetVehicleModel(i) - 400], GetVehicleModel(i), i, groupVariables[vehicleVariables[i][vVehicleGroup]][gGroupName], vehicleVariables[i][vVehicleGroup]);
					SendClientMessage(playerid, COLOR_GREY, szMessage);
					return 1;
				}
				else {
					SendClientMessage(playerid, COLOR_GREY, "This vehicle is locked.");
					RemovePlayerFromVehicle(playerid);
					return 1;
				}
			}
        }
		foreach(Player, x) {
			if(playerVariables[x][pCarID] == GetPlayerVehicleID(playerid)) {
				if(playerVariables[playerid][pAdminLevel] >= 1 && playerVariables[playerid][pAdminDuty] >= 1) {

					GetPlayerName(x, szPlayerName, MAX_PLAYER_NAME);
					format(szMessage, sizeof(szMessage), "This %s (model %d, ID %d) is owned by %s.", VehicleNames[playerVariables[x][pCarModel] - 400], playerVariables[x][pCarModel], playerVariables[x][pCarID], szPlayerName);
					SendClientMessage(playerid, COLOR_GREY, szMessage);
				}
				else if(playerVariables[x][pCarLock] == 1) {
					RemovePlayerFromVehicle(playerid);
					SendClientMessage(playerid, COLOR_GREY, "This vehicle is locked.");
				}
			}
		}
		

		// Confirm the old state was on foot and if they should be frozen, then remove them
		if(oldstate == 1 && playerVariables[playerid][pFreezeType] != 0 && playerVariables[playerid][pFreezeTime] != 0)
  			RemovePlayerFromVehicle(playerid);
    }

	foreach(Player, x) {
		if(playerVariables[x][pSpectating] != INVALID_PLAYER_ID && playerVariables[x][pSpectating] == playerid) {
			if(newstate == 2 && oldstate == 1 || newstate == 3 && oldstate == 1) {
				PlayerSpectateVehicle(x, GetPlayerVehicleID(playerid));
			}
			else {
				PlayerSpectatePlayer(x, playerid);
			}
		}
	}
	
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid) {
	#if defined DEBUG
	    printf("[debug] OnVehicleStreamIn(%d, %d)", vehicleid, forplayerid);
	#endif
	
	foreach(Player, x) {
	    if(playerVariables[x][pCarID] == vehicleid && playerVariables[x][pCarLock] == 1) {
			SetVehicleParamsForPlayer(vehicleid, forplayerid, 0, 1);
	    }
	}
	return 1;
}

stock createRelevantItems(const businessid) {
	switch(businessVariables[businessid][bType]) {
		case 1: {
			format(szLargeString, sizeof(szLargeString), "INSERT INTO `businessitems` (`itemBusinessId`, `itemTypeId`, `itemPrice`, `itemName`) VALUES (%d, 1, 5, 'Rope'), (%d, 2, 15, 'Walkie Talkie'), (%d, 3, 10, 'Phone Book'),", businessid, businessid, businessid);
			format(szLargeString, sizeof(szLargeString), "%s(%d, 4, 10, 'Phone Credit'), (%d, 5, 10, 'Mobile Phone');", szLargeString, businessid, businessid);
			mysql_query(szLargeString);
		}
		case 2: {
 			format(szLargeString, sizeof(szLargeString), "INSERT INTO `businessitems` (`itemBusinessId`, `itemTypeId`, `itemPrice`, `itemName`) VALUES (%d, 18, 50, 'All Skins');", businessid);
			mysql_query(szLargeString);
		}
		case 3: {
 			format(szLargeString, sizeof(szLargeString), "INSERT INTO `businessitems` (`itemBusinessId`, `itemTypeId`, `itemPrice`, `itemName`) VALUES (%d, 14, 4, 'Cigar'), (%d, 15, 1, 'Sprunk'), (%d, 16, 10, 'Wine'), (%d, 17, 3, 'Beer');", businessid, businessid, businessid, businessid);
			mysql_query(szLargeString);
		}
		case 4: {
 			format(szLargeString, sizeof(szLargeString), "INSERT INTO `businessitems` (`itemBusinessId`, `itemTypeId`, `itemPrice`, `itemName`) VALUES (%d, 9, 10, 'Purple Dildo'), (%d, 10, 15, 'Small White Vibrator'), (%d, 11, 20, 'Large White Vibrator'),", businessid, businessid, businessid);
			format(szLargeString, sizeof(szLargeString), "%s(%d, 12, 15, 'Silver Vibrator'), (%d, 13, 10, 'Flowers');", szLargeString, businessid, businessid);
			mysql_query(szLargeString);
		}
		case 7: {
			format(szLargeString, sizeof(szLargeString), "INSERT INTO `businessitems` (`itemBusinessId`, `itemTypeId`, `itemPrice`, `itemName`) VALUES (%d, 6, 5, 'Box Meal 1'), (%d, 7, 10, 'Box Meal 2'), (%d, 8, 20, 'Box Meal 3');", businessid, businessid, businessid);
			mysql_query(szLargeString);
		}
	}
	
	mysql_query("SELECT * FROM businessitems", THREAD_INITIATE_BUSINESS_ITEMS);
	return 1;
}

stock getPlayerCheckpointReason(const playerid) {
    switch(playerVariables[playerid][pCheckpoint]) {
		case 1: {
		    format(szMessage, sizeof(szMessage), "Detective");
			return szMessage;
		}
		case 2: {
		    format(szMessage, sizeof(szMessage), "Matrun");
			return szMessage;
		}
		case 3: {
			format(szMessage, sizeof(szMessage), "Dropcar");
			return szMessage;
		}
		case 4: {
			format(szMessage, sizeof(szMessage), "Findcar");
			return szMessage;
		}
		case 5: {
			format(szMessage, sizeof(szMessage), "Backup");
			return szMessage;
		}
		case 6: {
			format(szMessage, sizeof(szMessage), "Home/Business");
			return szMessage;
		}
	}

	format(szMessage, sizeof(szMessage), "01x05");
	return szMessage;
}
stock forceAdminConfirmPIN(playerid, cmd[] = "", cmdparams[] = "") {
	if(GetPVarInt(playerid, "pAdminPIN") == 0)
		return 1;

    SetPVarInt(playerid, "pAdminFrozen", 1);
    
    if(strlen(cmd) != 0 || strlen(cmdparams) != 0) {
        SetPVarString(playerid, "doCmd", cmd);
        SetPVarString(playerid, "doCmdParams", cmdparams);
	}

    ShowPlayerDialog(playerid, DIALOG_ADMIN_PIN, DIALOG_STYLE_INPUT, "SERVER: Admin authentication verification", "This action requires you to enter your admin PIN in.\n\nPlease confirm your admin PIN to continue:", "OK", "Cancel");
	return 1;
}

stock saveBusiness(const id) {
	if(strlen(businessVariables[id][bOwner]) >= 1) {
		new
		    queryString[1424];

		format(queryString, sizeof(queryString), "UPDATE businesses SET businessExteriorX = '%f', businessExteriorY = '%f', businessExteriorZ = '%f', businessInteriorX = '%f', businessInteriorY = '%f', businessInteriorZ = '%f', businessInterior = '%d', businessType = '%d', businessName = '%s', businessOwner = '%s', businessPrice = '%d', businessVault = '%d', businessLock = '%d', businessMiscX = '%f', businessMiscY = '%f', businessMiscZ = '%f' WHERE businessID = '%d'", businessVariables[id][bExteriorPos][0],
		businessVariables[id][bExteriorPos][1],	businessVariables[id][bExteriorPos][2],	businessVariables[id][bInteriorPos][0], businessVariables[id][bInteriorPos][1],	businessVariables[id][bInteriorPos][2],	businessVariables[id][bInterior], businessVariables[id][bType], businessVariables[id][bName], businessVariables[id][bOwner], businessVariables[id][bPrice], businessVariables[id][bVault], businessVariables[id][bLocked], businessVariables[id][bMiscPos][0],
		businessVariables[id][bMiscPos][1], businessVariables[id][bMiscPos][2], id);
		mysql_query(queryString);
	}
	else {
	    return false;
	}

	return 1;
}

stock saveVehicle(const id) {
	if(vehicleVariables[id][vVehicleModelID] >= 1) {
	    new
	        queryString[255];

	    GetVehiclePos(vehicleVariables[id][vVehicleScriptID], vehicleVariables[id][vVehiclePosition][0], vehicleVariables[id][vVehiclePosition][1], vehicleVariables[id][vVehiclePosition][2]);
	    GetVehicleZAngle(vehicleVariables[id][vVehicleScriptID], vehicleVariables[id][vVehicleRotation]);

	    format(queryString, sizeof(queryString), "UPDATE vehicles SET vehicleModelID = '%d', vehiclePosX = '%f', vehiclePosY = '%f', vehiclePosZ = '%f', vehiclePosRotation = '%f', vehicleGroup = '%d', vehicleCol1 = '%d', vehicleCol2 = '%d' WHERE vehicleID = '%d'", vehicleVariables[id][vVehicleModelID],	vehicleVariables[id][vVehiclePosition][0],
		vehicleVariables[id][vVehiclePosition][1], vehicleVariables[id][vVehiclePosition][2], vehicleVariables[id][vVehicleRotation], vehicleVariables[id][vVehicleGroup], vehicleVariables[id][vVehicleColour][0], vehicleVariables[id][vVehicleColour][1], id);
		mysql_query(queryString);
	}
	return 1;
}

stock saveHouse(const id) {
	if(strlen(houseVariables[id][hHouseOwner]) >= 1) {
		format(szLargeString, sizeof(szLargeString), "UPDATE houses SET houseExteriorPosX = '%f', houseExteriorPosY = '%f', houseExteriorPosZ = '%f', houseInteriorPosX = '%f', houseInteriorPosY = '%f', houseInteriorPosZ = '%f'", houseVariables[id][hHouseExteriorPos][0], houseVariables[id][hHouseExteriorPos][1], houseVariables[id][hHouseExteriorPos][2], houseVariables[id][hHouseInteriorPos][0], houseVariables[id][hHouseInteriorPos][1], houseVariables[id][hHouseInteriorPos][2]);
		format(szLargeString, sizeof(szLargeString), "%s, housePrice = '%d', houseOwner = '%s', houseExteriorID = '%d', houseInteriorID = '%d', houseLocked = '%d', houseMoney = '%d', houseMaterials = '%d', houseWeapon1 = '%d', houseWeapon2 = '%d', houseWeapon3 = '%d', houseWeapon4 = '%d', houseWeapon5 = '%d'", szLargeString, houseVariables[id][hHousePrice], houseVariables[id][hHouseOwner], houseVariables[id][hHouseExteriorID],
		houseVariables[id][hHouseInteriorID], houseVariables[id][hHouseLocked],	houseVariables[id][hMoney], houseVariables[id][hMaterials], houseVariables[id][hWeapons][0], houseVariables[id][hWeapons][1], houseVariables[id][hWeapons][2], houseVariables[id][hWeapons][3], houseVariables[id][hWeapons][4]);
		format(szLargeString, sizeof(szLargeString), "%s, houseWardrobe1 = '%d', houseWardrobe2 = '%d', houseWardrobe3 = '%d', houseWardrobe4 = '%d', houseWardrobe5 = '%d' WHERE houseID = '%d'", szLargeString, houseVariables[id][hWardrobe][0], houseVariables[id][hWardrobe][1], houseVariables[id][hWardrobe][2], houseVariables[id][hWardrobe][3], houseVariables[id][hWardrobe][4], id);
		mysql_query(szLargeString);
	}
	else {
	    return false;
	}

	return 1;
}

stock saveAsset(const id) {
	if(strlen(assetVariables[id][aAssetName]) >= 1) {
		format(szQueryOutput, sizeof(szQueryOutput), "UPDATE assets SET assetName = '%s', assetValue = '%d' WHERE assetID = '%d'", assetVariables[id][aAssetName], assetVariables[id][aAssetValue]);
		mysql_query(szQueryOutput);
	}
	return 1;
}

stock saveGroup(const id) {
	if(strlen(groupVariables[id][gGroupName]) >= 1) {
		format(szLargeString, sizeof(szLargeString), "UPDATE groups SET groupName = '%s', groupHQExteriorPosX = '%f', groupHQExteriorPosY = '%f', groupHQExteriorPosZ = '%f'", groupVariables[id][gGroupName], groupVariables[id][gGroupExteriorPos][0], groupVariables[id][gGroupExteriorPos][1], groupVariables[id][gGroupExteriorPos][2]);
		format(szLargeString, sizeof(szLargeString), "%s, groupHQInteriorID = '%d', groupHQLockStatus = '%d', groupHQInteriorPosX = '%f', groupHQInteriorPosY = '%f', groupHQInteriorPosZ = '%f', groupSafeMoney = '%d', groupSafeMats = '%d', groupMOTD = '%s'", szLargeString, groupVariables[id][gGroupHQInteriorID],
		groupVariables[id][gGroupHQLockStatus], groupVariables[id][gGroupInteriorPos][0], groupVariables[id][gGroupInteriorPos][1], groupVariables[id][gGroupInteriorPos][2], groupVariables[id][gSafe][0], groupVariables[id][gSafe][1], groupVariables[id][gGroupMOTD]);
		format(szLargeString, sizeof(szLargeString), "%s, groupRankName1 = '%s', groupRankName2 = '%s', groupRankName3 = '%s', groupRankName4 = '%s', groupRankName5 = '%s', groupRankName6 = '%s'", szLargeString, groupVariables[id][gGroupRankName1], groupVariables[id][gGroupRankName2], groupVariables[id][gGroupRankName3], groupVariables[id][gGroupRankName4], groupVariables[id][gGroupRankName5], groupVariables[id][gGroupRankName6]);
		format(szLargeString, sizeof(szLargeString), "%s, groupSafePosX = '%f', groupSafePosY = '%f', groupSafePosZ = '%f', groupType = '%d' WHERE groupID = '%d'", szLargeString, groupVariables[id][gSafePos][0], groupVariables[id][gSafePos][1], groupVariables[id][gSafePos][2], groupVariables[id][gGroupType], id);
		mysql_query(szLargeString);
	}
	else {
		return 0;
	}

	return 1;

}

stock initiateJobs() {
    return mysql_query("SELECT * FROM jobs", THREAD_INITIATE_JOBS);
}

stock initiateBusinesses() {
	mysql_query("SELECT * FROM businessitems", THREAD_INITIATE_BUSINESS_ITEMS);
    return mysql_query("SELECT * FROM businesses", THREAD_INITIATE_BUSINESSES);
}

stock initiateAssets() {
	return mysql_query("SELECT * FROM assets", THREAD_INITIATE_ASSETS);
}

stock initiateHouseSpawns() {
	return mysql_query("SELECT * FROM houses", THREAD_INITIATE_HOUSES);
}

stock initiateVehicleSpawns() {
	return mysql_query("SELECT * FROM vehicles", THREAD_INITIATE_VEHICLES);
}

stock initiateGroups() {
	return mysql_query("SELECT * FROM groups", THREAD_INITIATE_GROUPS);
}

stock clearScreen(const playerid) {
    SendClientMessage(playerid, COLOR_WHITE, " ");
    SendClientMessage(playerid, COLOR_WHITE, " ");
    SendClientMessage(playerid, COLOR_WHITE, " ");
    SendClientMessage(playerid, COLOR_WHITE, " ");
    SendClientMessage(playerid, COLOR_WHITE, " ");
    SendClientMessage(playerid, COLOR_WHITE, " ");
    SendClientMessage(playerid, COLOR_WHITE, " ");
    SendClientMessage(playerid, COLOR_WHITE, " ");
    SendClientMessage(playerid, COLOR_WHITE, " ");
    SendClientMessage(playerid, COLOR_WHITE, " ");
    SendClientMessage(playerid, COLOR_WHITE, " ");
	return 1;
}

/*stock checkPlayerVehiclesForDesync(const playerid) {
    new
        x;
        
    for(;;) {
        x++;
        
        format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Model", x);
        format(szSmallString2, sizeof(szSmallString2), "playerVehicle%d_RealID", x);
        if(GetPVarInt(playerid, szSmallString) == GetVehicleModel(GetPVarInt(playerid, szSmallString2))) {
            despawnPlayersVehicles(playerid);
            respawnPlayerVehicles(playerid);
            SendClientMessage(playerid, COLOR_GREY, "Your player vehicles are suffering from a desync issue in SA-MP. They have been respawned to fix this issue.");
        }
	}
	return 1;
}

stock respawnPlayerVehicles(playerid) {
	new
		iModel,
		Float: fPos[3],
		Float: fAngle,
		iColours[2],
		iPaintjob,
		iComponents[14],
	    iCount = countPlayerVehicles(playerid);
	    
	for(new iVehicleID = 0; iVehicleID < iCount; i++) {
		format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Model", iVehicleID);
		iModel = GetPVarInt(playerid, szSmallString);

		format(szSmallString, sizeof(szSmallString), "playerVehicle%d_PosX", iVehicleID);
		fPos[0] = GetPVarFloat(playerid, szSmallString);

		format(szSmallString, sizeof(szSmallString), "playerVehicle%d_PosY", iVehicleID);
		fPos[1] = GetPVarFloat(playerid, szSmallString);

		format(szSmallString, sizeof(szSmallString), "playerVehicle%d_PosZ", iVehicleID);
		fPos[2] = GetPVarFloat(playerid, szSmallString);

		format(szSmallString, sizeof(szSmallString), "playerVehicle%d_PosZAngle", iVehicleID);
		fAngle = GetPVarFloat(playerid, szSmallString);

		format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Colour1", iVehicleID);
		iColours[0] = GetPVarInt(playerid, szSmallString);

		format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Colour2", iVehicleID);
		iColours[1] = GetPVarInt(playerid, szSmallString);

		format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Paintjob", iVehicleID);
		iPaintjob = GetPVarInt(playerid, szSmallString);

		format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Component0", iVehicleID);
		iComponents[0] = GetPVarInt(playerid, szSmallString);

		format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Component1", iVehicleID);
		iComponents[1] = GetPVarInt(playerid, szSmallString);

		format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Component2", iVehicleID);
		iComponents[2] = GetPVarInt(playerid, szSmallString);

		format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Component3", iVehicleID);
		iComponents[3] = GetPVarInt(playerid, szSmallString);

		format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Component4", iVehicleID);
		iComponents[4] = GetPVarInt(playerid, szSmallString);

		format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Component5", iVehicleID);
		iComponents[5] = GetPVarInt(playerid, szSmallString);

		format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Component6", iVehicleID);
		iComponents[6] = GetPVarInt(playerid, szSmallString);

		format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Component7", iVehicleID);
		iComponents[7] = GetPVarInt(playerid, szSmallString);

		format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Component8", iVehicleID);
		iComponents[8] = GetPVarInt(playerid, szSmallString);

		format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Component9", iVehicleID);
		iComponents[9] = GetPVarInt(playerid, szSmallString);

		format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Component10", iVehicleID);
		iComponents[10] = GetPVarInt(playerid, szSmallString);

		format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Component11", iVehicleID);
		iComponents[11] = GetPVarInt(playerid, szSmallString);

		format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Component12", iVehicleID);
		iComponents[12] = GetPVarInt(playerid, szSmallString);

		format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Component13", iVehicleID);
		iComponents[13] = GetPVarInt(playerid, szSmallString);

		format(szSmallString, sizeof(szSmallString), "playerVehicle%d_RealID", iVehicleID);
		SetPVarInt(extraid, szSmallString, CreateVehicle(iModel, fPos[0], fPos[1], fPos[2], fAngle, iColours[0], iColours[1], 0));

		for(new i = 0; i <= 13; i++)
			AddVehicleComponent(GetPVarInt(extraid, szSmallString), iComponents[i]);

		ChangeVehiclePaintjob(GetPVarInt(extraid, szSmallString), iPaintjob);
	}
	return 1;
}*/

stock initiateHospital(const playerid) {
	TogglePlayerControllable(playerid, false);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerInterior(playerid, 0);

	if(random(2) == 0) {
		SetPlayerPos(playerid, 1188.4574,-1309.2242,10.5625);
		SetPlayerCameraPos(playerid,1188.4574,-1309.2242,13.5625+6.0);
		SetPlayerCameraLookAt(playerid,1175.5581,-1324.7922,18.1610);

		SetPVarInt(playerid, "hosp", 1);
	} else {
		SetPlayerPos(playerid, 1999.5308,-1449.3281,10.5594);
		SetPlayerCameraPos(playerid,1999.5308,-1449.3281,13.5594+6.0);
		SetPlayerCameraLookAt(playerid,2036.2179,-1410.3223,17.1641);

	    SetPVarInt(playerid, "hosp", 2);
	}

	SendClientMessage(playerid, COLOR_LIGHTRED, "You must spend some time in the Hospital to recover from the injuries you recently sustained.");
	SendClientMessage(playerid, COLOR_LIGHTRED, "Before you are discharged, hospital staff will confiscate your weapons and you will be billed for the health care you received.");
	playerVariables[playerid][pHospitalized] = 2;
	SetPlayerHealth(playerid, 10);
	return 1;
}

stock PreloadAnimLib(playerid, animlib[]) {
	return ApplyAnimation(playerid,animlib,"null",0.0,0,0,0,0,0);
}
stock savePlayerData(const playerid) {
	if(playerVariables[playerid][pStatus] >= 1 || playerVariables[playerid][pStatus] == -1) {
		new
		    saveQuery[3500];

		if(playerVariables[playerid][pCarModel] >= 1 && doesVehicleExist(playerVariables[playerid][pCarID])) {
		    GetVehiclePos(playerVariables[playerid][pCarID], playerVariables[playerid][pCarPos][0], playerVariables[playerid][pCarPos][1], playerVariables[playerid][pCarPos][2]);
		    GetVehicleZAngle(playerVariables[playerid][pCarID], playerVariables[playerid][pCarPos][3]);

            for(new i = 0; i < 13; i++) {
                playerVariables[playerid][pCarMods][i] = GetVehicleComponentInSlot(playerVariables[playerid][pCarID], i);
            }
		}

		if(playerVariables[playerid][pAdminDuty] == 0 && playerVariables[playerid][pEvent] == 0) {
			GetPlayerHealth(playerid, playerVariables[playerid][pHealth]);
			GetPlayerArmour(playerid, playerVariables[playerid][pArmour]);
		}

		// If they're not in an event and not spectating, current pos is saved. Otherwise, they'll be set back to the pos they last used /joinevent or /spec.
		if(playerVariables[playerid][pSpectating] == INVALID_PLAYER_ID && playerVariables[playerid][pEvent] == 0) {
			GetPlayerPos(playerid, playerVariables[playerid][pPos][0], playerVariables[playerid][pPos][1], playerVariables[playerid][pPos][2]);
			playerVariables[playerid][pInterior] = GetPlayerInterior(playerid);
			playerVariables[playerid][pVirtualWorld] = GetPlayerVirtualWorld(playerid); // If someone disconnects while spectating.
		}

		format(saveQuery, sizeof(saveQuery), "UPDATE playeraccounts SET playerBanned = '%d', playerSeconds = '%d', playerSkin = '%d', playerMoney = '%d', playerBankMoney = '%d'", playerVariables[playerid][pBanned], playerVariables[playerid][pSeconds], playerVariables[playerid][pSkin], playerVariables[playerid][pMoney], playerVariables[playerid][pBankMoney]);

		format(saveQuery, sizeof(saveQuery), "%s, playerInterior = '%d', playerVirtualWorld = '%d', playerHealth = '%f', playerArmour = '%f', playerPosX = '%f', playerPosY = '%f', playerPosZ = '%f'", saveQuery, playerVariables[playerid][pInterior], playerVariables[playerid][pVirtualWorld], playerVariables[playerid][pHealth], playerVariables[playerid][pArmour], playerVariables[playerid][pPos][0], playerVariables[playerid][pPos][1], playerVariables[playerid][pPos][2]);

		format(saveQuery, sizeof(saveQuery), "%s, playerAccent = '%s', playerAdminLevel = '%d', playerJob = '%d', playerWeapon0 = '%d', playerWeapon1 = '%d', playerWeapon2 = '%d', playerWeapon3 = '%d'", saveQuery, playerVariables[playerid][pAccent], playerVariables[playerid][pAdminLevel], playerVariables[playerid][pJob], playerVariables[playerid][pWeapons][0], playerVariables[playerid][pWeapons][1], playerVariables[playerid][pWeapons][2], playerVariables[playerid][pWeapons][3]);

		format(saveQuery, sizeof(saveQuery), "%s, playerWeapon4 = '%d', playerWeapon5 = '%d', playerWeapon6 = '%d', playerWeapon7 = '%d', playerWeapon8 = '%d', playerWeapon9 = '%d', playerWeapon10 = '%d'", saveQuery, playerVariables[playerid][pWeapons][4], playerVariables[playerid][pWeapons][5], playerVariables[playerid][pWeapons][6], playerVariables[playerid][pWeapons][7], playerVariables[playerid][pWeapons][8], playerVariables[playerid][pWeapons][9], playerVariables[playerid][pWeapons][10]);

		format(saveQuery, sizeof(saveQuery), "%s, playerWeapon11 = '%d', playerWeapon12 = '%d', playerJobSkill1 = '%d', playerJobSkill2 = '%d', playerMaterials = '%d', playerHours = '%d', playerLevel = '%d'", saveQuery, playerVariables[playerid][pWeapons][11], playerVariables[playerid][pWeapons][12], playerVariables[playerid][pJobSkill][0], playerVariables[playerid][pJobSkill][1], playerVariables[playerid][pMaterials], playerVariables[playerid][pPlayingHours], playerVariables[playerid][pLevel]);

		format(saveQuery, sizeof(saveQuery), "%s, playerWarning1 = '%s', playerWarning2 = '%s', playerWarning3 = '%s', playerHospitalized = '%d', playerFirstLogin = '%d', playerAdminName = '%s', playerPrisonTime = '%d', playerPrisonID = '%d', playerPhoneNumber = '%d'", saveQuery, playerVariables[playerid][pWarning1], playerVariables[playerid][pWarning2], playerVariables[playerid][pWarning3], playerVariables[playerid][pHospitalized], playerVariables[playerid][pFirstLogin], playerVariables[playerid][pAdminName],
		playerVariables[playerid][pPrisonTime], playerVariables[playerid][pPrisonID], playerVariables[playerid][pPhoneNumber]);

		format(saveQuery, sizeof(saveQuery), "%s, playerCarPaintJob = '%d', playerCarLock = '%d', playerStatus = '%d', playerGender = '%d', playerFightStyle = '%d', playerCarWeapon1 = '%d', playerCarWeapon2 = '%d', playerCarWeapon3 = '%d', playerCarWeapon4 = '%d', playerCarWeapon5 = '%d', playerCarLicensePlate = '%s'", saveQuery, playerVariables[playerid][pCarPaintjob], playerVariables[playerid][pCarLock],
		playerVariables[playerid][pStatus], playerVariables[playerid][pGender], playerVariables[playerid][pFightStyle], playerVariables[playerid][pCarWeapons][0], playerVariables[playerid][pCarWeapons][1], playerVariables[playerid][pCarWeapons][2], playerVariables[playerid][pCarWeapons][3], playerVariables[playerid][pCarWeapons][4], playerVariables[playerid][pCarLicensePlate]);

		format(saveQuery, sizeof(saveQuery), "%s, playerCarModel = '%d', playerCarColour1 = '%d', playerCarColour2 = '%d', playerCarPosX = '%f', playerCarPosY = '%f', playerCarPosZ = '%f', playerCarPosZAngle = '%f', playerCarMod0 = '%d', playerCarMod1 = '%d', playerCarMod2 = '%d', playerCarMod3 = '%d', playerCarMod4 = '%d', playerCarMod5 = '%d', playerCarMod6 = '%d'", saveQuery, playerVariables[playerid][pCarModel], playerVariables[playerid][pCarColour][0], playerVariables[playerid][pCarColour][1],
		playerVariables[playerid][pCarPos][0], playerVariables[playerid][pCarPos][1], playerVariables[playerid][pCarPos][2], playerVariables[playerid][pCarPos][3], playerVariables[playerid][pCarMods][0], playerVariables[playerid][pCarMods][1], playerVariables[playerid][pCarMods][2], playerVariables[playerid][pCarMods][3], playerVariables[playerid][pCarMods][4], playerVariables[playerid][pCarMods][5], playerVariables[playerid][pCarMods][6]);

		format(saveQuery, sizeof(saveQuery), "%s, playerCarTrunk1 = '%d', playerCarTrunk2 = '%d', playerPhoneCredit = '%d', playerWalkieTalkie = '%d'", saveQuery, playerVariables[playerid][pCarTrunk][0], playerVariables[playerid][pCarTrunk][1], playerVariables[playerid][pPhoneCredit], playerVariables[playerid][pWalkieTalkie]);

		format(saveQuery, sizeof(saveQuery), "%s, playerPhoneBook = '%d', playerGroup = '%d', playerGroupRank = '%d', playerIP = '%s', playerDropCarTimeout = '%d', playerRope = '%d', playerAdminDuty = '%d', playerCrimes = '%d', playerArrests = '%d', playerWarrants = '%d', playerAge = '%d', playerCarMod7 = '%d', playerCarMod8 = '%d', playerCarMod9 = '%d', playerCarMod10 = '%d', playerCarMod11 = '%d', playerCarMod12 = '%d'", saveQuery, playerVariables[playerid][pPhoneBook],
		playerVariables[playerid][pGroup], playerVariables[playerid][pGroupRank], playerVariables[playerid][pConnectionIP], playerVariables[playerid][pDropCarTimeout], playerVariables[playerid][pRope], playerVariables[playerid][pAdminDuty], playerVariables[playerid][pCrimes], playerVariables[playerid][pArrests], playerVariables[playerid][pWarrants], playerVariables[playerid][pAge], playerVariables[playerid][pCarMods][7], playerVariables[playerid][pCarMods][8],
		playerVariables[playerid][pCarMods][9], playerVariables[playerid][pCarMods][10], playerVariables[playerid][pCarMods][11], playerVariables[playerid][pCarMods][12]);

		if(playerVariables[playerid][pHelper] > 0)
		    format(saveQuery, sizeof(saveQuery), "%s, playerHelperLevel = %d", saveQuery, playerVariables[playerid][pHelper]);
		    
		if(playerVariables[playerid][pAdminLevel] > 0)
		    format(saveQuery, sizeof(saveQuery), "%s, playerAdminPIN = %d", saveQuery, GetPVarInt(playerid, "pAdminPIN"));
		    
		format(saveQuery, sizeof(saveQuery), "%s WHERE playerID = '%d'", saveQuery, playerVariables[playerid][pInternalID]);
		mysql_query(saveQuery);
	}

	return 1;
}

stock doesVehicleExist(const vehicleid) {
    if(GetVehicleModel(vehicleid) >= 400) {
		return 1;
	}
	return 0;
}
stock businessTypeMessages(const businessid, const playerid) {
	switch(businessVariables[businessid][bType]) {
		case 1: {
			SendClientMessage(playerid, COLOR_WHITE, "Welcome! The commands of this business are as follows: /buy");
			if(playerVariables[playerid][pFish] != -1) {
				switch(playerVariables[playerid][pFish]) {
				    case 0: {
				        ShowPlayerDialog(playerid, DIALOG_SELL_FISH, DIALOG_STYLE_MSGBOX, "SERVER: Fishing", "You are currently carrying $1000 worth of fish.\n\nWould you like to sell your fish to this store for $1000?", "Yes", "No");
				    }
				    case 1: {
				        ShowPlayerDialog(playerid, DIALOG_SELL_FISH, DIALOG_STYLE_MSGBOX, "SERVER: Fishing", "You are currently carrying $750 worth of fish.\n\nWould you like to sell your fish to this store for $750?", "Yes", "No");
				    }
				    case 2: {
            			ShowPlayerDialog(playerid, DIALOG_SELL_FISH, DIALOG_STYLE_MSGBOX, "SERVER: Fishing", "You are currently carrying $250 worth of fish.\n\nWould you like to sell your fish to this store for $250?", "Yes", "No");
				    }
				    case 3: {
				        ShowPlayerDialog(playerid, DIALOG_SELL_FISH, DIALOG_STYLE_MSGBOX, "SERVER: Fishing", "You are currently carrying $900 worth of fish.\n\nWould you like to sell your fish to this store for $900?", "Yes", "No");
				    }
				    case 4: {
				        ShowPlayerDialog(playerid, DIALOG_SELL_FISH, DIALOG_STYLE_MSGBOX, "SERVER: Fishing", "You are currently carrying $500 worth of fish.\n\nWould you like to sell your fish to this store for $500?", "Yes", "No");
				    }
				}
			}
		}
		case 2: {
			SendClientMessage(playerid, COLOR_WHITE, "Welcome! The commands of this business are as follows: /buyclothes");
		}
		case 3, 4, 7: {
			SendClientMessage(playerid, COLOR_WHITE, "Welcome! The commands of this business are as follows: /buy");
		}
		case 5: {
			SendClientMessage(playerid, COLOR_WHITE, "Welcome! The commands of this business are as follows: /buyvehicle");
		}
		case 6: {
			SendClientMessage(playerid, COLOR_WHITE, "Welcome! The commands of this business are as follows: /buyfightstyle");
		}
	}
	
	return 1;
}

function VendDrink(playerid) {
    new
		Float:health;

	ApplyAnimation(playerid, "VENDING", "VEND_Drink_P", 1, 0, 0, 0, 0, 1750);
	GetPlayerHealth(playerid,health);
	if(health > 65.0) SetPlayerHealth(playerid,100.0); // This limits player health to 100 (as values over 100.0 could otherwise be achieved, which isn't good).
	else SetPlayerHealth(playerid,health+35.0); // A Sprunk machine gives exactly 35.0 HP per hit.
	return 1;
}
stock PurchaseVehicleFromDealer(playerid, model, price) { // This is going to stop so much code-rape. :3
	if(playerVariables[playerid][pMoney] >= price) {
		if(playerVariables[playerid][pCarModel] < 1) {

			new
				string[64],
				businessID = GetPlayerVirtualWorld(playerid)-BUSINESS_VIRTUAL_WORLD;

			playerVariables[playerid][pCarModel] = model; // Set the model.
			playerVariables[playerid][pCarPaintjob] = -1;

			playerVariables[playerid][pCarColour][0] = random(126);
			playerVariables[playerid][pCarColour][1] = random(126);

			playerVariables[playerid][pCarPos][0] = businessVariables[businessID][bMiscPos][0]; // Set the pos to the business misc pos.
			playerVariables[playerid][pCarPos][1] = businessVariables[businessID][bMiscPos][1];
			playerVariables[playerid][pCarPos][2] = businessVariables[businessID][bMiscPos][2];

			SpawnPlayerVehicle(playerid);

			playerVariables[playerid][pMoney] -= price;
			businessVariables[businessID][bVault] += price;

			format(string, sizeof(string), "Congratulations! You have purchased a %s for $%d.", VehicleNames[model - 400], price);
			SendClientMessage(playerid, COLOR_WHITE, string);

			ShowPlayerDialog(playerid, DIALOG_LICENSE_PLATE, DIALOG_STYLE_INPUT, "License plate registration", "Please enter a license plate for your vehicle. \n\nThere is only two conditions:\n- The license plate must be unique\n- The license plate can be alphanumerical, but it must consist of only 7 characters and include one space.", "Select", "");
		}
		else SendClientMessage(playerid, COLOR_GREY, "You already have a vehicle; sell it first.");
	}
	else SendClientMessage(playerid, COLOR_GREY, "You don't have enough money to purchase this vehicle.");
}

stock DestroyPlayerVehicle(playerid) { // This can be used for two things; resetting all vars, and completely destroying a player vehicle.

	playerVariables[playerid][pCarPos][0] = 0.0;
	playerVariables[playerid][pCarPos][1] = 0.0;
	playerVariables[playerid][pCarPos][2] = 0.0;
	playerVariables[playerid][pCarPos][3] = 0.0;
	playerVariables[playerid][pCarColour][0] = -1;
	playerVariables[playerid][pCarColour][1] = -1;
	playerVariables[playerid][pCarModel] = 0;
	playerVariables[playerid][pCarPaintjob] = -1; // 0 is a valid paintjob. D:
	playerVariables[playerid][pCarTrunk][0] = 0;
	playerVariables[playerid][pCarTrunk][1] = 0;

	new
		x;

	while(x < 13) {
		playerVariables[playerid][pCarMods][x] = 0;
		x++;
	}

	x = 0;

	while(x < 5) {
		playerVariables[playerid][pCarWeapons][x] = 0;
		x++;
	}

	if(doesVehicleExist(playerVariables[playerid][pCarID])) DestroyVehicle(playerVariables[playerid][pCarID]);

	playerVariables[playerid][pCarID] = -1;
	systemVariables[vehicleCounts][1]--;

	return 1;
}

stock SetAllVehiclesToRespawn() { // Doesn't bother looping through all cars/players, more efficient


	systemVariables[vehicleCounts][0] = 0;
	systemVariables[vehicleCounts][1] = 0;

	for(new x; x < MAX_VEHICLES; x++) {
		if(doesVehicleExist(vehicleVariables[x][vVehicleScriptID])) { // Saved
			DestroyVehicle(vehicleVariables[x][vVehicleScriptID]);
			vehicleVariables[x][vVehicleScriptID] = CreateVehicle(vehicleVariables[x][vVehicleModelID], vehicleVariables[x][vVehiclePosition][0], vehicleVariables[x][vVehiclePosition][1], vehicleVariables[x][vVehiclePosition][2], vehicleVariables[x][vVehicleRotation], vehicleVariables[x][vVehicleColour][0], vehicleVariables[x][vVehicleColour][1], 60000);
			systemVariables[vehicleCounts][0]++;
		}
		else if(doesVehicleExist(AdminSpawnedVehicles[x])) { // Admin
			SetVehicleToRespawn(AdminSpawnedVehicles[x]);
		}
	}
	foreach(Player, v) {  // Player.
		if(doesVehicleExist(playerVariables[v][pCarID]) && playerVariables[v][pCarModel] >= 1) {

			GetVehiclePos(playerVariables[v][pCarID], playerVariables[v][pCarPos][0], playerVariables[v][pCarPos][1], playerVariables[v][pCarPos][2]);
			GetVehicleZAngle(playerVariables[v][pCarID], playerVariables[v][pCarPos][3]);

			DestroyVehicle(playerVariables[v][pCarID]);
			playerVariables[v][pCarID] = CreateVehicle(playerVariables[v][pCarModel], playerVariables[v][pCarPos][0], playerVariables[v][pCarPos][1], playerVariables[v][pCarPos][2], playerVariables[v][pCarPos][3], playerVariables[v][pCarColour][0], playerVariables[v][pCarColour][1], -1);

			for(new i = 0; i < 13; i++) {
				if(playerVariables[v][pCarMods][i] >= 1) AddVehicleComponent(playerVariables[v][pCarID], playerVariables[v][pCarMods][i]);
			}
			if(playerVariables[v][pCarPaintjob] >= 0) ChangeVehiclePaintjob(playerVariables[v][pCarID], playerVariables[v][pCarPaintjob]);
			systemVariables[vehicleCounts][1]++;
		}
	}
	return 1;
}

stock SetVehicleToRespawnEx(vehicleid) { // Great for respawning any given type of vehicle (player/admin/saved).

	foreach(Player, v) {  // Player.
		if(vehicleid == playerVariables[v][pCarID] && playerVariables[v][pCarModel] >= 1) {

			GetVehiclePos(playerVariables[v][pCarID], playerVariables[v][pCarPos][0], playerVariables[v][pCarPos][1], playerVariables[v][pCarPos][2]);
			GetVehicleZAngle(playerVariables[v][pCarID], playerVariables[v][pCarPos][3]);

			DestroyVehicle(playerVariables[v][pCarID]);
			playerVariables[v][pCarID] = CreateVehicle(playerVariables[v][pCarModel], playerVariables[v][pCarPos][0], playerVariables[v][pCarPos][1], playerVariables[v][pCarPos][2], playerVariables[v][pCarPos][3], playerVariables[v][pCarColour][0], playerVariables[v][pCarColour][1], -1);

			for(new i = 0; i < 13; i++) {
				if(playerVariables[v][pCarMods][i] >= 1) AddVehicleComponent(playerVariables[v][pCarID], playerVariables[v][pCarMods][i]);
			}
			if(playerVariables[v][pCarPaintjob] >= 0) ChangeVehiclePaintjob(playerVariables[v][pCarID], playerVariables[v][pCarPaintjob]);
			return 1;
		}
	}

	for(new x; x < MAX_VEHICLES; x++) {
		if(vehicleVariables[x][vVehicleScriptID] == vehicleid) { // Saved
			DestroyVehicle(vehicleVariables[x][vVehicleScriptID]);
			vehicleVariables[x][vVehicleScriptID] = CreateVehicle(vehicleVariables[x][vVehicleModelID], vehicleVariables[x][vVehiclePosition][0], vehicleVariables[x][vVehiclePosition][1], vehicleVariables[x][vVehiclePosition][2], vehicleVariables[x][vVehicleRotation], vehicleVariables[x][vVehicleColour][0], vehicleVariables[x][vVehicleColour][1], 60000);
			return 1;
		}
		else if(AdminSpawnedVehicles[x] == vehicleid) { // Admin
			SetVehicleToRespawn(AdminSpawnedVehicles[x]);
			return 1;
		}
	}
	return 1;
}

stock SpawnPlayerVehicle(playerid) {
	if(playerVariables[playerid][pCarModel] >= 1) {
		if(systemVariables[vehicleCounts][0] + systemVariables[vehicleCounts][1] + systemVariables[vehicleCounts][2] < MAX_VEHICLES) {
			if(doesVehicleExist(playerVariables[playerid][pCarID])) DestroyVehicle(playerVariables[playerid][pCarID]); // In case the IDs decide to f*$^# up.
			playerVariables[playerid][pCarID] = CreateVehicle(playerVariables[playerid][pCarModel], playerVariables[playerid][pCarPos][0], playerVariables[playerid][pCarPos][1], playerVariables[playerid][pCarPos][2], playerVariables[playerid][pCarPos][3], playerVariables[playerid][pCarColour][0], playerVariables[playerid][pCarColour][1], -1);

			for(new i = 0; i < 13; i++) {
				if(playerVariables[playerid][pCarMods][i] >= 1) AddVehicleComponent(playerVariables[playerid][pCarID], playerVariables[playerid][pCarMods][i]);
			}

			systemVariables[vehicleCounts][1]++;
			if(playerVariables[playerid][pCarPaintjob] >= 0) ChangeVehiclePaintjob(playerVariables[playerid][pCarID], playerVariables[playerid][pCarPaintjob]);
	        SetVehicleNumberPlate(playerVariables[playerid][pCarID], playerVariables[playerid][pCarLicensePlate]);

	        // De-stream the vehicle
	        SetVehicleVirtualWorld(playerVariables[playerid][pCarID], GetVehicleVirtualWorld(playerVariables[playerid][pCarID])+1);
	        SetVehicleVirtualWorld(playerVariables[playerid][pCarID], GetVehicleVirtualWorld(playerVariables[playerid][pCarID])-1);
		}
		else printf("ERROR: Vehicle limit reached (MODEL %d, PLAYER %d, MAXIMUM %d, TYPE PLAYER) [01x08]", playerVariables[playerid][pCarModel], playerid, MAX_VEHICLES);
	}
	return 1;
}
stock nearByMessage(playerid, color, const string[], Float: Distance = 12.0) {
	new
	    Float: nbCoords[3];

	GetPlayerPos(playerid, nbCoords[0], nbCoords[1], nbCoords[2]);

	foreach(Player, i) {
	    if(playerVariables[i][pStatus] >= 1) {
	        if(IsPlayerInRangeOfPoint(i, Distance, nbCoords[0], nbCoords[1], nbCoords[2]) && (GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid))) {
				SendClientMessage(i, color, string);
			}
	    }
	}

	return 1;
}
getPlayerHouseID(playerid) {
	new
	    x;

    while(x < MAX_HOUSES) {
		if(strlen(houseVariables[x][hHouseOwner]) >= 1) {
	        if(!strcmp(houseVariables[x][hHouseOwner], playerVariables[playerid][pNormalName], true)) {
				return x;
			}
		}
		x++;
	}

    return 0;
}

getPlayerBusinessID(const playerid) {
	new
	    x;

    while(x < MAX_BUSINESSES) {
		if(strlen(businessVariables[x][bOwner]) >= 1) {
	        if(!strcmp(businessVariables[x][bOwner], playerVariables[playerid][pNormalName], true)) {
				return x;
			}
		}
		x++;
	}

    return 0;
}

stock resetPlayerVariables(const playerid) {
	playerVariables[playerid][pStatus] = 0; // Not authenticated, but connected
	playerVariables[playerid][pSeconds] = 0;
	playerVariables[playerid][pSkin] = 299;
	playerVariables[playerid][pSkinCount] = 0;
	playerVariables[playerid][pMoney] = 0;
	playerVariables[playerid][pTazer] = 0;
	playerVariables[playerid][pOnRequest] = INVALID_PLAYER_ID;
	playerVariables[playerid][pFish] = -1;
	playerVariables[playerid][pBankMoney] = 20000;
	playerVariables[playerid][pHealth] = 100;
	playerVariables[playerid][pFishing] = 0;
	playerVariables[playerid][pArmour] = 0;
	playerVariables[playerid][pPMStatus] = 0;
	playerVariables[playerid][pAnticheatExemption] = 0;
	playerVariables[playerid][pPos][0] = 0;
	playerVariables[playerid][pEvent] = 0;
	playerVariables[playerid][pJetpack] = 0;
	playerVariables[playerid][pWalkieTalkie] = -1;
	playerVariables[playerid][pLevel] = 0;
	playerVariables[playerid][pTabbed] = 0;
	playerVariables[playerid][pHackWarnTime] = 0;
	playerVariables[playerid][pCarPaintjob] = -1;
	playerVariables[playerid][pBackup] = -1;
	playerVariables[playerid][pRope] = 0;
	playerVariables[playerid][pCarID] = -1;
	playerVariables[playerid][pFightStyle] = 4;
	playerVariables[playerid][pVIP] = 0;
	playerVariables[playerid][pCarColour][0] = -1;
	playerVariables[playerid][pCarColour][1] = -1;
	playerVariables[playerid][pMatrunTime] = 0;
	playerVariables[playerid][pPhoneBook] = 0;
	playerVariables[playerid][pHelperDuty] = 0;
	playerVariables[playerid][pDropCarTimeout] = 0;
	playerVariables[playerid][pPos][1] = 0;
	playerVariables[playerid][pHelper] = 0;
	playerVariables[playerid][pPhoneNumber] = -1;
	playerVariables[playerid][pPos][2] = 0;
	playerVariables[playerid][pSkinSet] = 0;
	playerVariables[playerid][pTutorial] = 0;
	playerVariables[playerid][pCarModel] = 0;
	playerVariables[playerid][pGender] = 1;
	playerVariables[playerid][pPhoneStatus] = 1;
	playerVariables[playerid][pHackWarnings] = 0;
	playerVariables[playerid][pSeeOOC] = 1;
	playerVariables[playerid][pGroup] = 0;
	playerVariables[playerid][pGroupRank] = 0;
	playerVariables[playerid][pPrisonTime] = 0;
	playerVariables[playerid][pPrisonID] = 0;
	playerVariables[playerid][pHospitalized] = 0;
	playerVariables[playerid][pSpamCount] = 0;
	playerVariables[playerid][pNewbieEnabled] = 1;
	playerVariables[playerid][pMuted] = 0;
	playerVariables[playerid][pAdminLevel] = 0;
	playerVariables[playerid][pPhoneCall] = -1;
	playerVariables[playerid][pInternalID] = -1;
	playerVariables[playerid][pVirtualWorld] = 0;
	playerVariables[playerid][pSpectating] = INVALID_PLAYER_ID;
	playerVariables[playerid][pJob] = 0;
	playerVariables[playerid][pFirstLogin] = 0;
	playerVariables[playerid][pAdminDuty] = 0;
	playerVariables[playerid][pReport] = 0;
	playerVariables[playerid][pInterior] = 0;
	playerVariables[playerid][pPlayingHours] = 0;
	playerVariables[playerid][pJobDelay] = 0;
	playerVariables[playerid][pCheckpoint] = 0;
	playerVariables[playerid][pMaterials] = 0;
	playerVariables[playerid][pJobSkill][0] = 0;
	playerVariables[playerid][pJobSkill][1] = 0;
	playerVariables[playerid][pPhoneCall] = -1;
	playerVariables[playerid][pFreezeTime] = 0;
	playerVariables[playerid][pFreezeType] = 0;
	playerVariables[playerid][pOOCMuted] = 0;
	playerVariables[playerid][pNewbieTimeout] = 0;
	playerVariables[playerid][pDrag] = -1;
	playerVariables[playerid][pAge] = 0;
	playerVariables[playerid][pCarTrunk][0] = 0;
	playerVariables[playerid][pCarTrunk][1] = 0;
	playerVariables[playerid][pPhoneCredit] = 0;

	new
	    x;

	while(x < 13) {
		playerVariables[playerid][pWeapons][x] = 0;
		x++;
	}

	x = 0;

	while(x < 13) {
		playerVariables[playerid][pCarMods][x] = 0;
		x++;
	}

	x = 0;

	while(x < 5) {
		playerVariables[playerid][pCarWeapons][x] = 0;
		x++;
	}

	playerVariables[playerid][pWarning1][0] = '*';
	playerVariables[playerid][pWarning2][0] = '*';
	playerVariables[playerid][pWarning3][0] = '*';
	playerVariables[playerid][pEmail][0] = '*';
	playerVariables[playerid][pPassword][0] = '*';
	playerVariables[playerid][pAdminName][0] = '*';
	playerVariables[playerid][pConnectionIP][0] = '*';
	format(playerVariables[playerid][pAccent], 32, "American");
	format(playerVariables[playerid][pCarLicensePlate], 32, "3VFT W%d", 10+random(80));
	
	GetPlayerName(playerid, playerVariables[playerid][pNormalName], MAX_PLAYER_NAME);

	playerVariables[playerid][pConnectedSeconds] = 0;

	return true;
}

stock initiateConnections() {
	new
	    File: fhConnectionInfo = fopen("MySQL.txt", io_read);

	fread(fhConnectionInfo, szQueryOutput);
	fclose(fhConnectionInfo);

	sscanf(szQueryOutput, "p<|>e<s[32]s[32]s[32]s[64]>", connectionInfo);
	
	#if defined DEBUG
	printf("[debug] initiateConnections() '%s', '%s', '%s', '%s'", szQueryOutput, connectionInfo[szDatabaseHostname], connectionInfo[szDatabaseUsername], connectionInfo[szDatabaseName], connectionInfo[szDatabasePassword]);
	#endif
	
	databaseConnection = mysql_connect(connectionInfo[szDatabaseHostname], connectionInfo[szDatabaseUsername], connectionInfo[szDatabaseName], connectionInfo[szDatabasePassword]);
	return true;
}

stock validResetPlayerWeapons(const playerid) {
	playerVariables[playerid][pAnticheatExemption] = 6;

	new
	    xLoop;

	ResetPlayerWeapons(playerid);

	while(xLoop < 13) {
		playerVariables[playerid][pWeapons][xLoop] = 0;
		xLoop++;
	}

	if(playerVariables[playerid][pTabbed] >= 1) {
		playerVariables[playerid][pOutstandingWeaponRemovalSlot] = 40;
	}

	return 1;
}

stock adminLog(const string[]) {
	new
	    queryString[201],
	    cleanString[128];

	mysql_real_escape_string(string, cleanString);

	format(queryString, sizeof(queryString), "INSERT INTO adminlog (value, tickcount) VALUES('%s', '%d')", cleanString, GetTickCount());
	return mysql_query(queryString);
}

stock syncPlayerTime(const playerid) {
	if(!GetPlayerInterior(playerid)) {
		SetPlayerWeather(playerid, weatherVariables[0]);
	}
	else SetPlayerWeather(playerid, INTERIOR_WEATHER_ID);
	return SetPlayerTime(playerid, gTime[0], gTime[1]);
}

stock globalPlayerLoop() {
	pingTick++;
	if(pingTick >= 120) {
	    if(mysql_ping() == -1) {
			mysql_reconnect(); // After 120 seconds (2 minutes), we need to ensure the connection is still alive. MySQL sometimes plays up and forces the connection to timeout.
		}
		pingTick = 0;
	}

	if(adTick >= 1)
		adTick--;

	/* --------------------- WORLD TIME --------------------- */

	gettime(gTime[0], gTime[1], gTime[2]);

	if(gTime[1] >= 59 && gTime[2] >= 59) {

		weatherVariables[1] += random(3) + 1; // Weather changes aren't regular.

		SetWorldTime(gTime[0]); // Set the world time to keep the worldtime variable updated (and ensure it syncs instantly for connecting players).

		if(weatherVariables[1] >= MAX_WEATHER_POINTS) {
			weatherVariables[0] = validWeatherIDs[random(sizeof(validWeatherIDs))];
			foreach(Player, i) {
				if(!GetPlayerInterior(i)) {
					SetPlayerWeather(i, weatherVariables[0]);
				}
				else SetPlayerWeather(i, INTERIOR_WEATHER_ID);
			}
			weatherVariables[1] = 0;
		}
	}

	/* ------------------------------------------------------ */

	foreach(Player, x) {
	
	    playerVariables[x][pConnectedSeconds] += 1;

		if(gTime[2] >= 59) syncPlayerTime(x);

	    if(playerVariables[x][pStatus] == 1) {
		    playerVariables[x][pSeconds]++;

			if(playerVariables[x][pMuted] >= 1) {
			    playerVariables[x][pMuted]--; // We don't need two variables for muting - just use -1 to permamute (admin mute) and a positive var for a temp mute.

			    if(playerVariables[x][pMuted] == 0) {
			        SendClientMessage(x, COLOR_GREY, "You have now been automatically unmuted.");
			    }
			}

			if(playerVariables[x][pAnticheatExemption] >= 1) {
				playerVariables[x][pAnticheatExemption]--;
			}
			
			if(playerVariables[x][pAdminLevel] > 0) {
				if(GetPVarInt(x, "pAdminPINConfirmed") >= 1)
				    SetPVarInt(x, "pAdminPINConfirmed", GetPVarInt(x, "pAdminPINConfirmed")-1);
			}

			if(playerVariables[x][pPhoneCall] != -1) {

				playerVariables[x][pPhoneCredit]--;

				if(playerVariables[x][pPhoneCredit] == 60) {
					SendClientMessage(x, COLOR_HOTORANGE, "You're almost out of credit, you have 60 seconds left.");
				}
				
				else if(playerVariables[x][pPhoneCredit] < 1) {
					SendClientMessage(x, COLOR_WHITE, "Your phone has ran out of credit, visit a 24/7 to buy a top up voucher.");

					if(GetPlayerSpecialAction(x) == SPECIAL_ACTION_USECELLPHONE) {
						SetPlayerSpecialAction(x, SPECIAL_ACTION_STOPUSECELLPHONE);
					}
					if(playerVariables[x][pPhoneCall] != -1 && playerVariables[x][pPhoneCall] < MAX_PLAYERS) {

						SendClientMessage(playerVariables[x][pPhoneCall], COLOR_WHITE, "Your call has been terminated by the other party (ran out of credit).");

						if(GetPlayerSpecialAction(playerVariables[x][pPhoneCall]) == SPECIAL_ACTION_USECELLPHONE) {
							SetPlayerSpecialAction(playerVariables[x][pPhoneCall], SPECIAL_ACTION_STOPUSECELLPHONE);
						}
						playerVariables[playerVariables[x][pPhoneCall]][pPhoneCall] = -1;
					}
					playerVariables[x][pPhoneCall] = -1;
				}
			}

			if(playerVariables[x][pFishing] >= 1) {
			    playerVariables[x][pFishing]++;
			    /*SetProgressBarValue(playerVariables[x][pFishingBar], GetProgressBarValue(playerVariables[x][pFishingBar])+10);
			    UpdateProgressBar(playerVariables[x][pFishingBar], x);*/

			    if(playerVariables[x][pFishing] == 10) {
			        /*HideProgressBarForPlayer(x, playerVariables[x][pFishingBar]); // Refer to /fish for reason why this is commented out
			        DestroyProgressBar(playerVariables[x][pFishingBar]);*/

			        new
			            randFish = random(5);

			        playerVariables[x][pFish] = randFish;

					format(szMessage, sizeof(szMessage), "You have reeled in a %s.", fishNames[randFish]);
					SendClientMessage(x, COLOR_WHITE, szMessage);

					switch(randFish) {
					    case 0: SendClientMessage(x, COLOR_WHITE, "The fish that you collected is worth $1000. To sell your fish, please visit a 24/7.");
					    case 1: SendClientMessage(x, COLOR_WHITE, "The fish that you collected is worth $750. To sell your fish, please visit a 24/7.");
					    case 2: SendClientMessage(x, COLOR_WHITE, "The fish that you collected is worth $250. To sell your fish, please visit a 24/7.");
					    case 3: SendClientMessage(x, COLOR_WHITE, "The fish that you collected is worth $900. To sell your fish, please visit a 24/7.");
					    case 4: SendClientMessage(x, COLOR_WHITE, "The fish that you collected is worth $500. To sell your fish, please visit a 24/7.");
					}

					playerVariables[x][pJobDelay] = 900;
				}
			}

			if(playerVariables[x][pSpectating] != INVALID_PLAYER_ID) { // OnPlayerInteriorChange doesn't work properly when spectating.
				if(GetPlayerInterior(x) != GetPlayerInterior(playerVariables[x][pSpectating])){
					SetPlayerInterior(x, GetPlayerInterior(playerVariables[x][pSpectating]));
				}
				if(GetPlayerVirtualWorld(x) != GetPlayerVirtualWorld(playerVariables[x][pSpectating])){
					SetPlayerVirtualWorld(x, GetPlayerVirtualWorld(playerVariables[x][pSpectating]));
				}
			}
            if(playerVariables[x][pBackup] != -1) {
                if(IsPlayerAuthed(playerVariables[x][pBackup])) {
                    GetPlayerPos(playerVariables[x][pBackup], playerVariables[playerVariables[x][pBackup]][pPos][0], playerVariables[playerVariables[x][pBackup]][pPos][1], playerVariables[playerVariables[x][pBackup]][pPos][2]);
                    SetPlayerCheckpoint(x, playerVariables[playerVariables[x][pBackup]][pPos][0], playerVariables[playerVariables[x][pBackup]][pPos][1], playerVariables[playerVariables[x][pBackup]][pPos][2], 10.0);
                }
                else {
                    playerVariables[x][pBackup] = -1;
					playerVariables[x][pCheckpoint] = 0;

                    SendClientMessage(x, COLOR_GREY, "The player requesting for backup has disconnected.");
                    DisablePlayerCheckpoint(x);
                }
            }

			if(playerVariables[x][pDrag] != -1) { // Considering how slow SetPlayerPos works in practice, using a 1000ms timer in lieu of OnPlayerUpdate (the old script) is a better idea.
				if(IsPlayerAuthed(playerVariables[x][pDrag])) {
					switch(GetPlayerState(playerVariables[x][pDrag])) { // If they're not on foot, they're not gonna be dragging anything...
						case 1: { // on foot
							GetPlayerPos(playerVariables[x][pDrag], playerVariables[x][pPos][0], playerVariables[x][pPos][1], playerVariables[x][pPos][2]);
							SetPlayerPos(x, playerVariables[x][pPos][0], playerVariables[x][pPos][1], playerVariables[x][pPos][2]);

							SetPlayerVirtualWorld(x, GetPlayerVirtualWorld(playerVariables[x][pDrag]));
							SetPlayerInterior(x, GetPlayerInterior(playerVariables[x][pDrag]));
						}
						case 2, 3: {
							SendClientMessage(playerVariables[x][pDrag], COLOR_GREY, "You can't enter a vehicle while dragging someone (use /detain).");
							RemovePlayerFromVehicle(playerVariables[x][pDrag]);
						}
						case 7: { // Death
							SendClientMessage(x, COLOR_WHITE, "The person who was dragging you has been wasted.");
							playerVariables[x][pDrag] = -1;
						}
					}
				}
				else {

					SendClientMessage(x, COLOR_WHITE, "The person who was dragging you has disconnected.");
					playerVariables[x][pDrag] = -1; // Kills off any disconnections.
				}
			}

			if(playerVariables[x][pMatrunTime] >= 1) {
				playerVariables[x][pMatrunTime]++;
			}

	        if(playerVariables[x][pJobDelay] >= 1) {
	   	    	playerVariables[x][pJobDelay]--;
				if(playerVariables[x][pJobDelay] == 0) SendClientMessage(x, COLOR_WHITE, "Your job reload time is over.");
	        }

	        if(playerVariables[x][pNewbieTimeout] > 0) {
	            playerVariables[x][pNewbieTimeout]--;
	            if(playerVariables[x][pNewbieTimeout] == 0) SendClientMessage(x, COLOR_WHITE, "You may now speak in the newbie chat channel again.");
	        }

			if(playerVariables[x][pHackWarnings] >= 1) {
				playerVariables[x][pHackWarnTime]++;

				if(playerVariables[x][pHackWarnTime] >= 10) {
					playerVariables[x][pHackWarnings] = 0;
					playerVariables[x][pHackWarnTime] = 0;
				}
			}

			if(playerVariables[x][pDropCarTimeout] >= 1) {
                playerVariables[x][pDropCarTimeout]--;
                if(playerVariables[x][pDropCarTimeout] == 1) {
                    playerVariables[x][pDropCarTimeout] = 0;
                    SendClientMessage(x, COLOR_WHITE, "You can now drop vehicles again at the crane.");
				}
			}

			if(GetPVarInt(x, "tutTime") > 0) {
			    SetPVarInt(x, "tutTime", GetPVarInt(x, "tutTime")-1);
			    if(GetPVarInt(x, "tutTime") == 0) {
			        TextDrawHideForPlayer(x, textdrawVariables[8]);
			        TextDrawShowForPlayer(x, textdrawVariables[7]);
			    }
			}

			if(playerVariables[x][pHospitalized] >= 2) {
                playerVariables[x][pHospitalized]++;
                GetPlayerHealth(x, playerVariables[x][pHealth]);
                SetPlayerHealth(x, playerVariables[x][pHealth]+7.5);

                if(playerVariables[x][pHealth]+10 >= 100) {
                    SetPlayerHealth(x, 100);
                    playerVariables[x][pHospitalized] = 0;

                    switch(GetPVarInt(x, "hosp")) {
                   	 	case 1: {
	                        playerVariables[x][pPos][0] = 1172.359985;
							playerVariables[x][pPos][1] = -1323.313110;
							playerVariables[x][pPos][2] = 15.402919;
							playerVariables[x][pHealth] = 75;
							playerVariables[x][pArmour] = 0;
							playerVariables[x][pVirtualWorld] = 0;
							playerVariables[x][pInterior] = 0;
	                        SetSpawnInfo(x, 0, playerVariables[x][pSkin], 1172.359985, -1323.313110, 15.402919, 0, 0, 0, 0, 0, 0, 0);
	                        SpawnPlayer(x);
	                        SendClientMessage(x, COLOR_LIGHTRED, "You have been released from Hospital.");
	                        SendClientMessage(x, COLOR_LIGHTRED, "You have been charged $1,000 for your stay, and any weapons you had have been confiscated.");
	                        playerVariables[x][pMoney] -= 1000;
	                        validResetPlayerWeapons(x);
	                        DeletePVar(x, "hosp");
                        }
                        case 2: {
	                        playerVariables[x][pPos][0] = 2034.196166;
							playerVariables[x][pPos][1] = -1402.591430;
							playerVariables[x][pPos][2] = 17.295030;
							playerVariables[x][pHealth] = 75;
							playerVariables[x][pArmour] = 0;
							playerVariables[x][pVirtualWorld] = 0;
							playerVariables[x][pInterior] = 0;
	                        SetSpawnInfo(x, 0, playerVariables[x][pSkin], 2034.196166, -1402.591430, 17.295030, 0, 0, 0, 0, 0, 0, 0);
	                        SpawnPlayer(x);
	                        SendClientMessage(x, COLOR_LIGHTRED, "You have been released from Hospital.");
	                        SendClientMessage(x, COLOR_LIGHTRED, "You have been charged $1,000 for your stay, and any weapons you had have been confiscated.");
	                        playerVariables[x][pMoney] -= 1000;
	                        validResetPlayerWeapons(x);
	                        SetPlayerPos(x, 2034.196166, -1402.591430, 17.295030);
	                        DeletePVar(x, "hosp");
                        }
                    }
				}
			}

			if(playerVariables[x][pSkinSet] >= 1) {
			    playerVariables[x][pSkinSet]++;
			    if(playerVariables[x][pSkinSet] == 3 && GetPlayerSkin(x) != playerVariables[x][pSkin]) {
					SetPlayerSkin(x, playerVariables[x][pSkin]); // Set the skin first.
				}
				if(playerVariables[x][pSkinSet] == 4) {
                    givePlayerWeapons(x); // Then give the player their weapons. Seems like a SA-MP bug? Pain in the arse might I add!
                    playerVariables[x][pSkinSet] = 0;
					TogglePlayerControllable(x, true);
				}
			}

			if(playerVariables[x][pFreezeTime] != 0) {
				TogglePlayerControllable(x, 0);
				if(playerVariables[x][pFreezeType] == 5)
					ApplyAnimation(x, "FAT", "IDLE_TIRED", 4.1, 1, 1, 1, 1, 0, 1);
					
				if(playerVariables[x][pFreezeTime] > 0) {
					playerVariables[x][pFreezeTime]--;
					if(playerVariables[x][pFreezeTime] == 0) {
						if(playerVariables[x][pFreezeType] == 5) {
							SetPlayerDrunkLevel(x, 0);
							ClearAnimations(x);
						}
						playerVariables[x][pFreezeType] = 0;
						TogglePlayerControllable(x, true);
					}
				}

			}

			if(playerVariables[x][pPrisonID] > 0) {
                playerVariables[x][pPrisonTime]--;

                switch(playerVariables[x][pPrisonID]) {
					case 1: {
						format(szMessage, sizeof(szMessage), "~n~~n~~n~~n~~n~~n~~n~ ~r~Prisoned!~n~~w~%d seconds (%d minutes) left", playerVariables[x][pPrisonTime], playerVariables[x][pPrisonTime]/60);
					}
					case 2, 3: { // We're going to be using 3 for IC jail, so... yeah
						format(szMessage, sizeof(szMessage), "~n~~n~~n~~n~~n~~n~~n~ ~r~Jailed!~n~~w~%d seconds (%d minutes) left", playerVariables[x][pPrisonTime], playerVariables[x][pPrisonTime]/60);
					}
				}

				GameTextForPlayer(x, szMessage, 2000, 3); // Always specify the game text time longer than the intended time; it always fades out before it should, causing an annoying flash.

                if(playerVariables[x][pPrisonTime] == 1 && playerVariables[x][pPrisonID] >= 1) {
                    playerVariables[x][pPrisonID] = 0;
                    playerVariables[x][pPrisonTime] = 0;
                    SendClientMessage(x, COLOR_WHITE, "Your time is up! You have been released from jail/prison.");
					SetPlayerPos(x, 738.9963, -1417.2211, 13.5234);
					SetPlayerVirtualWorld(x, 0);
					SetPlayerInterior(x, 0);
				}
			}

			if(playerVariables[x][pSpamCount] >= 1)
				playerVariables[x][pSpamCount]--;

			if(playerVariables[x][pSpamCount] >= 5 && playerVariables[x][pAdminLevel] == 0) {
			    playerVariables[x][pMuted] = 10;
			    playerVariables[x][pSpamCount] = 0;
			    SendClientMessage(x, COLOR_GREY, "You have been auto-muted for spamming. You will be unmuted in 10 seconds.");
			}

		    if(playerVariables[x][pSeconds] >= 3600) {

		        playerVariables[x][pSeconds] = 0;
		        playerVariables[x][pPlayingHours]++;

		        new
		            BankInterest = playerVariables[x][pBankMoney] / 1000,
		            RandPay = (random(495) + 5) * (playerVariables[x][pPlayingHours]/60) + random(5000) + 500,
					TotalPay = BankInterest + RandPay;

				if(playerVariables[x][pBankMoney]+playerVariables[x][pMoney] > -5000000) {
		            SendClientMessage(x, COLOR_TEAL, "----------------------------------------------------------------------------");
					SendClientMessage(x, COLOR_WHITE, "Your paycheck has arrived; please visit the bank to withdraw your money.");
					playerVariables[x][pBankMoney] += TotalPay;
                    new taxamount = ((TotalPay/100) * assetVariables[1][aAssetValue]);
                    if(taxamount > 1) {
                        playerVariables[x][pBankMoney] -= taxamount;
                        groupVariables[GOVERNMENT_GROUP_ID][gSafe][0] += taxamount;
                        saveGroup(GOVERNMENT_GROUP_ID);
                    }
					format(szMessage, sizeof(szMessage), "Paycheck: $%d | Bank balance: $%d | Bank interest: $%d | Tax: $%d (%d percent) | Total earnings: $%d", RandPay, playerVariables[x][pBankMoney], BankInterest, taxamount, assetVariables[1][aAssetValue], TotalPay-taxamount);
		            SendClientMessage(x, COLOR_GREY, szMessage);
		            SendClientMessage(x, COLOR_TEAL, "----------------------------------------------------------------------------");

		            savePlayerData(x);
				}
				else {
				    SendClientMessage(x, COLOR_WHITE, "You're too poor to obtain a paycheck.");
				}
		    }

		    if(GetPlayerMoney(x) != playerVariables[x][pMoney]) {
				ResetPlayerMoney(x);
				GivePlayerMoney(x, playerVariables[x][pMoney]);
			}
	    }
	}

	return true;
}
stock PlayerFacePlayer(playerid, targetplayerid) { // Yeah, this'll fix the handshake headaches we had last time around (shaking air).
	new
		Float: Angle;

	GetPlayerFacingAngle(playerid, Angle);
	SetPlayerFacingAngle(targetplayerid, Angle+180);
	return 1;
}

stock GetXYInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance) { // And this'll keep the players close.

	new Float: a;

	GetPlayerPos(playerid, x, y, a);
	GetPlayerFacingAngle(playerid, a);

	if (GetPlayerVehicleID(playerid)) {
 		GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	}

	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
}

stock IsPlayerAimingAtPlayer(playerid, aimid) {

	new
		Float:Floats[7];

	GetPlayerPos(playerid, Floats[0], Floats[1], Floats[2]);
	GetPlayerPos(aimid, Floats[3], Floats[4], Floats[5]);
	new Float:Distance = floatsqroot(floatpower(floatabs(Floats[0]-Floats[3]), 2) + floatpower(floatabs(Floats[1]-Floats[4]), 2));
	if(Distance < 10.0) {
		GetPlayerFacingAngle(playerid, Floats[6]);
		Floats[0] += (Distance * floatsin(-Floats[6], degrees));
		Floats[1] += (Distance * floatcos(-Floats[6], degrees));
	    Distance = floatsqroot(floatpower(floatabs(Floats[0]-Floats[3]), 2) + floatpower(floatabs(Floats[1]-Floats[4]), 2));

  		if(Distance < 2.0) {
    		return true;
  		}
	}
	return false;
} 