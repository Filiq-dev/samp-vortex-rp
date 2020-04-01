
public OnGameModeInit() {
    #if defined DEBUG
		mysql_debug(1);
		print("[debug] OnGameModeInit()");
	#endif 

	Shits(); 

	print("-----------------------------------------------------------------");
	print("Script: Vortex Roleplay 2 by Calgon and Brian.");
	print("Status: Loaded OnGameModeInit, running version "SERVER_VERSION);
	print("-----------------------------------------------------------------");
	
	if(strfind(SERVER_VERSION, "BETA", true) != -1) {
	    print("-----------------------------------------------------------------");
	    print("WARNING: You are running a BETA version of the script.");
	    print("WARNING: This script is not optimized (or specifically built) for public usage yet.");
	    print("-----------------------------------------------------------------");
	}
	
	return 1;
} 

public OnPlayerCommandReceived(playerid, cmdtext[]) {
	#if defined DEBUG
	    printf("[debug] OnPlayerCommandReceived(%d, %s)", playerid, cmdtext);
	#endif
	
	if(GetPVarInt(playerid, "pAdminFrozen") == 1)
	    Kick(playerid);
	
	GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);

	if(playerVariables[playerid][pStatus] != 1)
	    return 0;

	printf("[server] [cmd] %s (ID %d): %s", szPlayerName, playerid, cmdtext);

	if(playerVariables[playerid][pMuted] > 0) {
		SendClientMessage(playerid, COLOR_GREY, "You cannot submit any commands or text at the moment, as you have been muted.");
		return 0;
	}

	playerVariables[playerid][pSpamCount]++;

	new
		charCount[3];

	for(new i; i < strlen(cmdtext); i++) switch(cmdtext[i]) {
		case '0' .. '9': charCount[0]++;
		case '.': charCount[1]++;
		case ':': charCount[2]++;
	}

	if(charCount[0] > 8 && charCount[1] >= 3 && charCount[2] >= 1 && playerVariables[playerid][pAdminLevel] < 1) {
		format(szMessage, sizeof(szMessage),"Warning: {FFFFFF}%s may be server advertising: '%s'.", szPlayerName, cmdtext);
		submitToAdmins(szMessage, COLOR_HOTORANGE);
		return 0;
	}
	return 1;
}

public OnVehicleSpawn(vehicleid) {
	#if defined DEBUG
	    printf("[debug] OnVehicleSpawn(%d)", vehicleid);
	#endif
	
	switch(GetVehicleModel(vehicleid)) {
		case 427, 428, 432, 601, 528: SetVehicleHealth(vehicleid, 5000.0); // Enforcer, Securicar, Rhino, SWAT Tank, FBI truck - this is the armour plating dream come true.
	}
	return 1;
}

public OnVehicleDeath(vehicleid, killerid) {
	#if defined DEBUG
	    printf("[debug] OnVehicleDeath(%d, %d)", vehicleid, killerid);
	#endif
	
	return 1;
} 

public OnGameModeExit() {
	#if defined DEBUG
	    print("[debug] OnGameModeInit()");
	#endif
	
	new
	    x;

	while(x < MAX_TIMERS) {
	    KillTimer(scriptTimers[x]);
		x++;
	}

	mysql_close(databaseConnection);

	return 1;
} 

public OnPlayerConnect(playerid) {
	#if defined DEBUG
	    printf("[debug] OnPlayerConnect(%d)", playerid);
	#endif
	
	/*
	(a) Attempts must be made to protect players from access to explicit content. If your
	server contains elements that may be considered only suitable for adults, your server
	must state this fact to the player when they first join.
	*/
	SendClientMessage(playerid, COLOR_LIGHTRED, "WARNING: This server contains explicit content which requires you to be 18+ to play here.");
	
    SetPlayerColor(playerid, COLOR_WHITE);
    resetPlayerVariables(playerid);

    GetPlayerIp(playerid, playerVariables[playerid][pConnectionIP], 16);

	// Query if the player is banned or not, then continue with other auth code after the thread goes through
    format(szMessage, sizeof(szMessage), "SELECT `banID` FROM `bans` WHERE `IPBanned` = '%s'", playerVariables[playerid][pConnectionIP]);
    mysql_query(szMessage, THREAD_CHECK_BANS_LIST, playerid);
    
    SetTimerEx("loginCheck", 2000, false, "d", playerid);

    SetPlayerMapIcon(playerid, 10, 595.5443, -1250.3405, 18.2836, 52, 0);
	syncPlayerTime(playerid);
	SetPlayerWeather(playerid, weatherVariables[0]); // Keep it all in sync (weather bugged out sometimes until we fixed it this way).

	/* Mall object removal - 0.3d */
    // Remove the original mall mesh
	RemoveBuildingForPlayer(playerid, 6130, 1117.5859, -1490.0078, 32.7188, 10.0);

	// This is the mall mesh LOD
	RemoveBuildingForPlayer(playerid, 6255, 1117.5859, -1490.0078, 32.7188, 10.0);

	// There are some trees on the outside of the mall which poke through one of the interiors
	RemoveBuildingForPlayer(playerid, 762, 1175.3594, -1420.1875, 19.8828, 0.25);
	RemoveBuildingForPlayer(playerid, 615, 1166.3516, -1417.6953, 13.9531, 0.25);
	return 1;
} 

public OnQueryError(errorid, error[], resultid, extraid, callback[], query[], connectionHandle) {
	if(IsPlayerConnected(extraid) && resultid == THREAD_CHECK_BANS_LIST) 
	{
	    ShowPlayerDialog(extraid, 0, DIALOG_STYLE_MSGBOX, "MySQL problem!", "You missed a step! Here's a list of the potential causes:\n\n- the MySQL connection details are invalid\n- the database dump wasn't imported correctly\n- an unexpected error ocurred\n\nPlease revisit the installation instructions.", "OK", "");
	}
	
	return printf("errorid: %d | error: %s | resultid: %d | extraid: %d | callback: %s | query: %s", errorid, error, resultid, extraid, callback, query);
} 

public OnQueryFinish(query[], resultid, extraid, connectionHandle) {
	switch(resultid) {
	    case THREAD_UNBAN_IP: {
			SendClientMessage(extraid, COLOR_WHITE, "You have successfully unbanned the IP.");
		}
		case THREAD_CHANGE_BUSINESS_TYPE_ITEMS: {
			createRelevantItems(extraid);
		}
	    case THREAD_TIMESTAMP_CONNECT: {
			mysql_store_result();
			
			if(mysql_num_rows() == 0)
			    return SendClientMessage(extraid, COLOR_GENANNOUNCE, "SERVER:"EMBED_WHITE" Welcome to the server!");
			    
            GetPlayerName(extraid, szPlayerName, MAX_PLAYER_NAME);

			mysql_fetch_row_format(result);
			format(szMessage, sizeof(szMessage), "SERVER:"EMBED_WHITE" Welcome back %s, you last visited us on %s.", szPlayerName, result);
			SendClientMessage(extraid, COLOR_GENANNOUNCE, szMessage);
			
  			if(playerVariables[extraid][pGroup] >= 1) {
			    format(szMessage, sizeof(szMessage), "(Group) "EMBED_WHITE"%s from your group has just logged in.", szPlayerName);
			    SendToGroup(playerVariables[extraid][pGroup], COLOR_GENANNOUNCE, szMessage);

		        format(szMessage, sizeof(szMessage), "(Group) MOTD: "EMBED_WHITE"%s", groupVariables[playerVariables[extraid][pGroup]][gGroupMOTD]);
		        SendClientMessage(extraid, COLOR_GENANNOUNCE, szMessage);
         	}
         	
         	mysql_free_result();
		}
		case THREAD_ADMIN_SECURITY: {
			mysql_store_result();
			
			if(!mysql_num_rows()) {
			    if(GetPVarInt(extraid, "pAdminPIN") == 0)
					return 1;
					
			    SetPVarInt(extraid, "pAdminFrozen", 1);
			    
			    ShowPlayerDialog(extraid, DIALOG_ADMIN_PIN, DIALOG_STYLE_INPUT, "SERVER: Admin authentication verification", "The system has recognised that you have connected with an IP that you've never used before.\n\nPlease confirm your admin PIN to continue:", "OK", "Cancel");
			} else mysql_free_result();
		}
		
		case THREAD_LOAD_PLAYER_VEHICLES: {
			mysql_store_result();
			
			if(mysql_num_rows() == 0)
			    return 1;

			new
			    iModel,
			    Float: fPos[3],
			    Float: fAngle,
			    iColours[2],
			    iPaintjob,
			    iComponents[14],
			    iVehicleID;

			while(mysql_retrieve_row()) {
			    mysql_get_field("pvModel", result);
			    format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Model", iVehicleID);
			    SetPVarInt(extraid, szSmallString, strval(result));
			    iModel = strval(result);
			    
			    mysql_get_field("pvPosX", result);
			    format(szSmallString, sizeof(szSmallString), "playerVehicle%d_PosX", iVehicleID);
			    SetPVarFloat(extraid, szSmallString, floatstr(result));
			    fPos[0] = floatstr(result);
			    
			    mysql_get_field("pvPosY", result);
			    format(szSmallString, sizeof(szSmallString), "playerVehicle%d_PosY", iVehicleID);
			    SetPVarFloat(extraid, szSmallString, floatstr(result));
			    fPos[1] = floatstr(result);
			    
			    mysql_get_field("pvPosZ", result);
			    format(szSmallString, sizeof(szSmallString), "playerVehicle%d_PosZ", iVehicleID);
			    SetPVarFloat(extraid, szSmallString, floatstr(result));
			    fPos[2] = floatstr(result);
			    
			    mysql_get_field("pvPosZAngle", result);
			    format(szSmallString, sizeof(szSmallString), "playerVehicle%d_PosZAngle", iVehicleID);
			    SetPVarFloat(extraid, szSmallString, floatstr(result));
			    fAngle = floatstr(result);
			    
			    mysql_get_field("pvColour1", result);
			    format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Colour1", iVehicleID);
			    SetPVarInt(extraid, szSmallString, strval(result));
			    iColours[0] = strval(result);

			    mysql_get_field("pvColour1", result);
			    format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Colour2", iVehicleID);
			    SetPVarInt(extraid, szSmallString, strval(result));
			    iColours[1] = strval(result);
			    
			    mysql_get_field("pvPaintjob", result);
			    format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Paintjob", iVehicleID);
			    SetPVarInt(extraid, szSmallString, strval(result));
			    iPaintjob = strval(result);

			    mysql_get_field("pvStaticPrice", result);
			    format(szSmallString, sizeof(szSmallString), "playerVehicle%d_StaticPrice", iVehicleID);
			    SetPVarInt(extraid, szSmallString, strval(result));

			    mysql_get_field("pvComponent0", result);
			    format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Component0", iVehicleID);
			    SetPVarInt(extraid, szSmallString, strval(result));
			    iComponents[0] = strval(result);

			    mysql_get_field("pvComponent1", result);
			    format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Component1", iVehicleID);
			    SetPVarInt(extraid, szSmallString, strval(result));
			    iComponents[1] = strval(result);

				mysql_get_field("pvComponent2", result);
			    format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Component2", iVehicleID);
			    SetPVarInt(extraid, szSmallString, strval(result));
			    iComponents[2] = strval(result);

			    mysql_get_field("pvComponent3", result);
			    format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Component3", iVehicleID);
			    SetPVarInt(extraid, szSmallString, strval(result));
			    iComponents[3] = strval(result);

				mysql_get_field("pvComponent4", result);
			    format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Component4", iVehicleID);
			    SetPVarInt(extraid, szSmallString, strval(result));
			    iComponents[4] = strval(result);

			    mysql_get_field("pvComponent5", result);
			    format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Component5", iVehicleID);
			    SetPVarInt(extraid, szSmallString, strval(result));
			    iComponents[5] = strval(result);

				mysql_get_field("pvComponent6", result);
			    format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Component6", iVehicleID);
			    SetPVarInt(extraid, szSmallString, strval(result));
			    iComponents[6] = strval(result);

			    mysql_get_field("pvComponent7", result);
			    format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Component7", iVehicleID);
			    SetPVarInt(extraid, szSmallString, strval(result));
			    iComponents[7] = strval(result);

				mysql_get_field("pvComponent8", result);
			    format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Component8", iVehicleID);
			    SetPVarInt(extraid, szSmallString, strval(result));
			    iComponents[8] = strval(result);

			    mysql_get_field("pvComponent9", result);
			    format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Component9", iVehicleID);
			    SetPVarInt(extraid, szSmallString, strval(result));
			    iComponents[9] = strval(result);

				mysql_get_field("pvComponent10", result);
			    format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Component10", iVehicleID);
			    SetPVarInt(extraid, szSmallString, strval(result));
			    iComponents[10] = strval(result);

			    mysql_get_field("pvComponent11", result);
			    format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Component11", iVehicleID);
			    SetPVarInt(extraid, szSmallString, strval(result));
			    iComponents[11] = strval(result);

				mysql_get_field("pvComponent12", result);
			    format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Component12", iVehicleID);
			    SetPVarInt(extraid, szSmallString, strval(result));
			    iComponents[12] = strval(result);

			    mysql_get_field("pvComponent13", result);
			    format(szSmallString, sizeof(szSmallString), "playerVehicle%d_Component13", iVehicleID);
			    SetPVarInt(extraid, szSmallString, strval(result));
			    iComponents[13] = strval(result);
			    
			    format(szSmallString, sizeof(szSmallString), "playerVehicle%d_RealID", iVehicleID);
			    SetPVarInt(extraid, szSmallString, CreateVehicle(iModel, fPos[0], fPos[1], fPos[2], fAngle, iColours[0], iColours[1], 0));

				for(new i = 0; i <= 13; i++)
					AddVehicleComponent(GetPVarInt(extraid, szSmallString), iComponents[i]);

				ChangeVehiclePaintjob(GetPVarInt(extraid, szSmallString), iPaintjob);
				
                systemVariables[vehicleCounts][1]++;
			    iVehicleID++;
			}
			
			mysql_free_result();
		}
		
		case THREAD_INITIATE_BUSINESS_ITEMS: {
            mysql_store_result();

            new
				x;
            
			for(x = 0; x < MAX_BUSINESS_ITEMS; x++) {
				businessItems[x][bItemBusiness] = 0;
				businessItems[x][bItemType] = 0;
				businessItems[x][bItemPrice] = 0;
				format(businessItems[x][bItemName], 32, "");
			}
			
			x = 0;

			while(mysql_retrieve_row()) {
			    x++;
			    
			    mysql_get_field("itemBusinessId", result);
			    businessItems[x][bItemBusiness] = strval(result);

			    mysql_get_field("itemTypeId", result);
			    businessItems[x][bItemType] = strval(result);
			    
			    mysql_get_field("itemName", businessItems[x][bItemName]);
			    
			    mysql_get_field("itemPrice", result);
			    businessItems[x][bItemPrice] = strval(result);
			}
            
            mysql_free_result();
		}
		case THREAD_LAST_CONNECTIONS: 
		{
			mysql_store_result();
			
			if(mysql_num_rows() < 1)
			    return SendClientMessage(extraid, COLOR_GREY, "You haven't connected more than once yet.");

			szLargeString = "Last ~5 of your connections:";
			while(mysql_fetch_row_format(result, " ")) 
			{
				strcat(szLargeString, "\n");
				strcat(szLargeString, result);
			}
			
			ShowPlayerDialog(extraid, 0, DIALOG_STYLE_MSGBOX, "SERVER: Connection log", szLargeString, "OK", "");
			
			mysql_free_result();
		}
	    case THREAD_CHECK_PLAYER_NAMES: 
		{
	        mysql_store_result();

	        if(mysql_num_rows() == 0)
	            return SendClientMessage(extraid, COLOR_GREY, "There are no recorded name changes for this player.");

			new
			    iNCID,
			    szOldName[MAX_PLAYER_NAME],
			    szTime[20],
			    szNewName[MAX_PLAYER_NAME];

			szLargeString = "Name changes:";
            while(mysql_fetch_row_format(result)) 
			{
                sscanf(result, "p<|>ds[24]s[24]s[20]", iNCID, szOldName, szNewName, szTime);
				format(szMediumString, sizeof(szMediumString), "\n- (%d) From \"%s\" to \"%s\" (%s)", iNCID, szOldName, szNewName, szTime);
				strcat(szLargeString, szMediumString);
            }

            ShowPlayerDialog(extraid, 0, DIALOG_STYLE_MSGBOX, "SERVER: Name changes", szLargeString, "OK", "");

			mysql_free_result();
	    }
	    case THREAD_LOAD_ATMS: {
			mysql_store_result();
			
			new
			    x;
			
			while(mysql_retrieve_row()) {
			    mysql_get_field("atmId", result);
			    x = strval(result);
			    
				mysql_get_field("atmPosX", result);
				atmVariables[x][fATMPos][0] = floatstr(result);
				
				mysql_get_field("atmPosY", result);
				atmVariables[x][fATMPos][1] = floatstr(result);
				
				mysql_get_field("atmPosZ", result);
				atmVariables[x][fATMPos][2] = floatstr(result) - 0.7;
				
				mysql_get_field("atmPosRotX", result);
				atmVariables[x][fATMPosRot][0] = floatstr(result);

				mysql_get_field("atmPosRotY", result);
				atmVariables[x][fATMPosRot][1] = floatstr(result);

				mysql_get_field("atmPosRotZ", result);
				atmVariables[x][fATMPosRot][2] = floatstr(result);
				
				atmVariables[x][rObjectId] = CreateDynamicObject(2618, atmVariables[x][fATMPos][0], atmVariables[x][fATMPos][1], atmVariables[x][fATMPos][2], atmVariables[x][fATMPosRot][0], atmVariables[x][fATMPosRot][1], atmVariables[x][fATMPosRot][2], -1, -1, -1, 500.0);
				atmVariables[x][rTextLabel] = CreateDynamic3DTextLabel("ATM\n\nWithdraw your cash here!\n\nPress ~k~~PED_DUCK~ to use this ATM.", COLOR_YELLOW, atmVariables[x][fATMPos][0], atmVariables[x][fATMPos][1], atmVariables[x][fATMPos][2], 50.0);
			}
			
			mysql_free_result();
		}
	    case THREAD_CHANGE_SPAWN: {
			SendClientMessage(extraid, COLOR_WHITE, "You have successfully changed the newbie spawn and newbie skin.");
			GetPlayerName(extraid, szPlayerName, MAX_PLAYER_NAME);
			format(szMessage, sizeof(szMessage), "AdmWarn: %s has changed the newbie spawn & skin.", szPlayerName);
			submitToAdmins(szMessage, COLOR_HOTORANGE);
		}
	    case THREAD_CHECK_ACCOUNT_USERNAME: {
	    	mysql_store_result();
			if(mysql_num_rows() == 0) {

			    if(!IsPlayerConnected(extraid))
					return mysql_free_result(); // Incase they're disconnected since... Sometimes queries F*"!%$" up.

			    new
					charCounts[5];

				GetPlayerName(extraid, szPlayerName, MAX_PLAYER_NAME);

				for(new n; n < MAX_PLAYER_NAME; n++) {
					switch(szPlayerName[n]) {
						case '[', ']', '.', '$', '(', ')', '@', '=': charCounts[1]++;
						case '_': charCounts[0]++;
						case '0' .. '9': charCounts[2]++;
						case 'a' .. 'z': charCounts[3]++;
						case 'A' .. 'Z': charCounts[4]++;
					}
				}
				if(charCounts[0] == 0 || charCounts[0] >= 3) {
					SendClientMessage(extraid, COLOR_GREY, "Your name is not valid. {FFFFFF}Please use an underscore and a first/last name (i.e. Mark_Edwards).");
					invalidNameChange(extraid);
				}
				else if(charCounts[1] >= 1) {
					SendClientMessage(extraid, COLOR_GREY, "Your name is not valid, as it contains symbols. {FFFFFF}Please use a roleplay name.");
					invalidNameChange(extraid);
				}
				else if(charCounts[2] >= 1) {
					SendClientMessage(extraid, COLOR_GREY, "Your name is not valid, as it contains numbers. {FFFFFF}Please use a roleplay name.");
					invalidNameChange(extraid);
				}
				else if(charCounts[3] == strlen(szPlayerName) - 1) {
					SendClientMessage(extraid, COLOR_GREY, "Your name is not valid, as it is lower case. {FFFFFF}Please use a roleplay name (i.e. Dave_Meniketti).");
					invalidNameChange(extraid);
				}
				else if(charCounts[4] == strlen(szPlayerName) - 1) {
					SendClientMessage(extraid, COLOR_GREY, "Your name is not valid, as it is upper case. {FFFFFF}Please use a roleplay name (i.e. Dave_Jones).");
					invalidNameChange(extraid);
				}
				else {
				    SendClientMessage(extraid, COLOR_GENANNOUNCE, "SERVER: {FFFFFF}Welcome to "SERVER_NAME".");
				    SendClientMessage(extraid, COLOR_GENANNOUNCE, "SERVER: {FFFFFF}You aren't registered yet. Please enter your desired password in the dialog box to register.");

				    ShowPlayerDialog(extraid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "SERVER: Registration", "Welcome to the "SERVER_NAME" Server.\n\nPlease enter your desired password below!", "Register", "Cancel");
				}
			}
			else {
			    if(!IsPlayerConnected(extraid))
					return mysql_free_result(); 

				SendClientMessage(extraid, COLOR_GENANNOUNCE, "SERVER: {FFFFFF}Welcome to "SERVER_NAME".");
				SendClientMessage(extraid, COLOR_GENANNOUNCE, "SERVER: {FFFFFF}You already have a registered account, please enter your password into the dialog box.");

				ShowPlayerDialog(extraid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "SERVER: Login", "Welcome to the "SERVER_NAME" Server.\n\nPlease enter your password below!", "Login", "Cancel");
			}

			mysql_free_result();
		}
		case THREAD_MOBILE_HISTORY: {
			mysql_store_result();

			if(mysql_num_rows() > 0) {
			    new
			        iLoop;

				format(szMessage, sizeof(szMessage), "");
				format(szLargeString, sizeof(szLargeString), "");
       			while(mysql_retrieve_row()) {
			        if(iLoop == 0)
						format(szLargeString, sizeof(szLargeString), "\n");

					mysql_get_field("phoneAction", szMessage);
					format(szLargeString, sizeof(szLargeString), "%s%s\n", szLargeString, szMessage);
			        iLoop++;
			    }

			    mysql_free_result();
			    return ShowPlayerDialog(extraid, DIALOG_MOBILE_HISTORY, DIALOG_STYLE_LIST, "Mobile Phone: History", szLargeString, "Return", "");
			} else {
			    return ShowPlayerDialog(extraid, DIALOG_MOBILE_HISTORY, DIALOG_STYLE_LIST, "Mobile Phone: History", "There is no recorded history of your mobile phone usage.", "Return", "");
			}
		}
		case THREAD_MOBILE_LIST_CONTACTS: {
			mysql_store_result();

			if(mysql_num_rows() > 0) {
			    new
			        iLoop,
			        szGet[3][64],
			        iNum[2],
			        szCat[512];

			    while(mysql_retrieve_row()) {
			        if(iLoop == 0)
			            format(szCat, sizeof(szCat), "\n{FFFFFF}");

					mysql_get_field("contactName", szGet[0]);
					mysql_get_field("contactAdded", szGet[1]);
					mysql_get_field("contactAddee", szGet[2]);

					iNum[0] = strval(szGet[1]);
					iNum[1] = strval(szGet[2]);

					format(szCat, sizeof(szCat), "%s%s "EMBED_GREY"(#%d){FFFFFF}\n", szCat, szGet[0], iNum[0]);

			        iLoop++;
			    }

				mysql_free_result();
				return ShowPlayerDialog(extraid, DIALOG_MOBILE_HISTORY, DIALOG_STYLE_LIST, "Mobile Phone: List Contacts", szCat, "Return", "");
			} else {
			    return ShowPlayerDialog(extraid, DIALOG_MOBILE_HISTORY, DIALOG_STYLE_LIST, "Mobile Phone: List Contacts", "You don't have any contacts.", "Return", "");
			}
		}
		case THREAD_CHECK_PLATES: {
		    mysql_store_result();

		    mysql_retrieve_row();

		    if(mysql_num_rows() > 0) {
		        mysql_free_result();
			    return ShowPlayerDialog(extraid, DIALOG_LICENSE_PLATE, DIALOG_STYLE_INPUT, "License plate registration", "{FFFFFF}ERROR:"EMBED_GREY" The plate specified already exists. Pick another one.{FFFFFF}\n\nPlease enter a license plate for your vehicle. \n\nThere is only two conditions:\n- The license plate must be unique\n- The license plate can be alphanumerical, but it must consist of only 7 characters and include one space.", "Select", "");
		    }

		    GetPVarString(extraid, "plate", playerVariables[extraid][pCarLicensePlate], 32);
		    DeletePVar(extraid, "plate");

		    SendClientMessage(extraid, COLOR_WHITE, "The license plate you selected has been applied to your vehicle.");

		    SetVehicleNumberPlate(playerVariables[extraid][pCarID], playerVariables[extraid][pCarLicensePlate]);
		    SetVehicleVirtualWorld(playerVariables[extraid][pCarID], GetVehicleVirtualWorld(playerVariables[extraid][pCarID])+1);
		    SetVehicleVirtualWorld(playerVariables[extraid][pCarID], GetVehicleVirtualWorld(playerVariables[extraid][pCarID])-1);
		}
		case THREAD_CHECK_CREDENTIALS: {
		    mysql_store_result();

			if(!IsPlayerConnected(extraid)) return mysql_free_result(); // Incase they're disconnected since... Sometimes queries F*"!%$" up.

			if(mysql_num_rows() == 0) { // INCORRECT PASSWORD!1

				SetPVarInt(extraid, "LA", GetPVarInt(extraid, "LA") + 1);

				new
					playerIP[32];

				if(GetPVarInt(extraid, "LA") > MAX_LOGIN_ATTEMPTS) {
					SendClientMessage(extraid, COLOR_RED, "You have used all available login attempts.");
					GetPlayerIp(extraid, playerIP, sizeof(playerIP));

					GetPlayerName(extraid, szPlayerName, MAX_PLAYER_NAME);
					format(szMessage, sizeof(szMessage), "AdmWarn: {FFFFFF}IP %s has been banned (%d failed 3 attempts on account %s).", playerIP, MAX_LOGIN_ATTEMPTS, szPlayerName);
					submitToAdmins(szMessage, COLOR_HOTORANGE);

					IPBan(playerIP, "Exceeded maximum login attempts.");
					Kick(extraid);
					return 1;

				}
			    else {
					ShowPlayerDialog(extraid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "SERVER: Login", "Welcome to the "SERVER_NAME" Server.\n\nPlease enter your password below!", "Login", "Cancel");
					format(szMessage, sizeof(szMessage), "Incorrect password. You have %d remaining login attempts left.", MAX_LOGIN_ATTEMPTS - GetPVarInt(extraid, "LA"));
					SendClientMessage(extraid, COLOR_HOTORANGE, szMessage);
					return 1;
				}
			}
			else {
			    clearScreen(extraid);
			    DeletePVar(extraid, "LA");

				mysql_retrieve_row();

				mysql_get_field("playerBanned", result);

				if(strval(result) >= 1) {

					new
						playerIP[32];

				    SendClientMessage(extraid, COLOR_RED, "You are banned from this server.");

					GetPlayerIp(extraid, playerIP, sizeof(playerIP));
					GetPlayerName(extraid, szPlayerName, MAX_PLAYER_NAME);

					format(szMessage, sizeof(szMessage), "AdmWarn: {FFFFFF}%s has attempted to evade their account ban (using IP %s).", szPlayerName, playerIP);
					submitToAdmins(szMessage, COLOR_HOTORANGE);

					format(szMessage, sizeof(szMessage), "Attempted ban evasion (%s).", szPlayerName);

					IPBan(playerIP, szMessage);
					Kick(extraid);
				}

				playerVariables[extraid][pBanned] = strval(result);

				mysql_get_field("playerPassword", playerVariables[extraid][pPassword]);

                mysql_get_field("playerEmail", playerVariables[extraid][pEmail]);

                mysql_get_field("playerSkin", result);
                playerVariables[extraid][pSkin] = strval(result);

                mysql_get_field("playerMoney", result);
                playerVariables[extraid][pMoney] = strval(result);

                mysql_get_field("playerBankMoney", result);
                playerVariables[extraid][pBankMoney] = strval(result);

                mysql_get_field("playerPosX", result);
                playerVariables[extraid][pPos][0] = floatstr(result);

                mysql_get_field("playerPosY", result);
                playerVariables[extraid][pPos][1] = floatstr(result);

                mysql_get_field("playerPosZ", result);
                playerVariables[extraid][pPos][2] = floatstr(result);

                mysql_get_field("playerHealth", result);
                playerVariables[extraid][pHealth] = floatstr(result);

                mysql_get_field("playerArmour", result);
                playerVariables[extraid][pArmour] = floatstr(result);
                
				mysql_get_field("playerVIP", result);
                playerVariables[extraid][pVIP] = strval(result);

                mysql_get_field("playerSeconds", result);
                playerVariables[extraid][pSeconds] = strval(result);

                mysql_get_field("playerAdminLevel", result);
                playerVariables[extraid][pAdminLevel] = strval(result);
                
                if(playerVariables[extraid][pAdminLevel] > 0) {
                    mysql_get_field("playerAdminPIN", result);
                    SetPVarInt(extraid, "pAdminPIN", strval(result));
                }

                mysql_get_field("playerAccent", playerVariables[extraid][pAccent]);

	            mysql_get_field("playerInterior", result);
	            playerVariables[extraid][pInterior] = strval(result);

	            mysql_get_field("playerVirtualWorld", result);
	            playerVariables[extraid][pVirtualWorld] = strval(result);

                mysql_get_field("playerID", result);
                playerVariables[extraid][pInternalID] = strval(result);

				mysql_get_field("playerCarLicensePlate", playerVariables[extraid][pCarLicensePlate]);

                mysql_get_field("playerJob", result);
                playerVariables[extraid][pJob] = strval(result);

                mysql_get_field("playerWeapon0", result);
                playerVariables[extraid][pWeapons][0] = strval(result);

                mysql_get_field("playerWeapon1", result);
                playerVariables[extraid][pWeapons][1] = strval(result);

                mysql_get_field("playerWeapon2", result);
                playerVariables[extraid][pWeapons][2] = strval(result);

                mysql_get_field("playerWeapon3", result);
                playerVariables[extraid][pWeapons][3] = strval(result);

                mysql_get_field("playerWeapon4", result);
                playerVariables[extraid][pWeapons][4] = strval(result);

                mysql_get_field("playerWeapon5", result);
                playerVariables[extraid][pWeapons][5] = strval(result);

                mysql_get_field("playerWeapon6", result);
                playerVariables[extraid][pWeapons][6] = strval(result);

                mysql_get_field("playerWeapon7", result);
                playerVariables[extraid][pWeapons][7] = strval(result);

                mysql_get_field("playerWeapon8", result);
                playerVariables[extraid][pWeapons][8] = strval(result);

                mysql_get_field("playerWeapon9", result);
                playerVariables[extraid][pWeapons][9] = strval(result);

				mysql_get_field("playerWeapon10", result);
                playerVariables[extraid][pWeapons][10] = strval(result);

				mysql_get_field("playerWeapon11", result);
                playerVariables[extraid][pWeapons][11] = strval(result);

				mysql_get_field("playerWeapon12", result);
                playerVariables[extraid][pWeapons][12] = strval(result);

				mysql_get_field("playerJobSkill1", result);
                playerVariables[extraid][pJobSkill][0] = strval(result);

				mysql_get_field("playerJobSkill2", result);
                playerVariables[extraid][pJobSkill][1] = strval(result);

				mysql_get_field("playerMaterials", result);
                playerVariables[extraid][pMaterials] = strval(result);

				mysql_get_field("playerGroup", result);
                playerVariables[extraid][pGroup] = strval(result);

				mysql_get_field("playerGroupRank", result);
                playerVariables[extraid][pGroupRank] = strval(result);

				mysql_get_field("playerHours", result);
                playerVariables[extraid][pPlayingHours] = strval(result);

                mysql_get_field("playerWarning1", playerVariables[extraid][pWarning1]);
                mysql_get_field("playerWarning2", playerVariables[extraid][pWarning2]);
                mysql_get_field("playerWarning3", playerVariables[extraid][pWarning3]);

				mysql_get_field("playerHospitalized", result);
                playerVariables[extraid][pHospitalized] = strval(result);

				mysql_get_field("playerAdminName", playerVariables[extraid][pAdminName]);

				mysql_get_field("playerFirstLogin", result);
				playerVariables[extraid][pFirstLogin] = strval(result);

				mysql_get_field("playerGender", result);
				playerVariables[extraid][pGender] = strval(result);

				mysql_get_field("playerPrisonID", result);
                playerVariables[extraid][pPrisonID] = strval(result);

				mysql_get_field("playerPrisonTime", result);
                playerVariables[extraid][pPrisonTime] = strval(result);

                mysql_get_field("playerPhoneNumber", result);
                playerVariables[extraid][pPhoneNumber] = strval(result);

                mysql_get_field("playerPhoneBook", result);
                playerVariables[extraid][pPhoneBook] = strval(result);

                mysql_get_field("playerHelperLevel", result);
                playerVariables[extraid][pHelper] = strval(result);

                mysql_get_field("playerDropCarTimeout", result);
                playerVariables[extraid][pDropCarTimeout] = strval(result);

                mysql_get_field("playerRope", result);
                playerVariables[extraid][pRope] = strval(result);

                mysql_get_field("playerAdminDuty", result);
                playerVariables[extraid][pAdminDuty] = strval(result);

                mysql_get_field("playerCrimes", result);
                playerVariables[extraid][pCrimes] = strval(result);

                mysql_get_field("playerArrests", result);
                playerVariables[extraid][pArrests] = strval(result);

                mysql_get_field("playerWarrants", result);
                playerVariables[extraid][pWarrants] = strval(result);

                mysql_get_field("playerLevel", result);
                playerVariables[extraid][pLevel] = strval(result);

                mysql_get_field("playerAge", result);
                playerVariables[extraid][pAge] = strval(result);

                mysql_get_field("playerCarModel", result);
                playerVariables[extraid][pCarModel] = strval(result);

                mysql_get_field("playerCarMod0", result);
                playerVariables[extraid][pCarMods][0] = strval(result);

                mysql_get_field("playerCarMod1", result);
                playerVariables[extraid][pCarMods][1] = strval(result);

                mysql_get_field("playerCarMod2", result);
                playerVariables[extraid][pCarMods][2] = strval(result);

                mysql_get_field("playerCarMod3", result);
                playerVariables[extraid][pCarMods][3] = strval(result);

                mysql_get_field("playerCarMod4", result);
                playerVariables[extraid][pCarMods][4] = strval(result);

                mysql_get_field("playerCarMod5", result);
                playerVariables[extraid][pCarMods][5] = strval(result);

                mysql_get_field("playerCarMod6", result);
                playerVariables[extraid][pCarMods][6] = strval(result);

                mysql_get_field("playerCarMod7", result);
                playerVariables[extraid][pCarMods][7] = strval(result);

                mysql_get_field("playerCarMod8", result);
                playerVariables[extraid][pCarMods][8] = strval(result);

                mysql_get_field("playerCarMod9", result);
                playerVariables[extraid][pCarMods][9] = strval(result);

                mysql_get_field("playerCarMod10", result);
                playerVariables[extraid][pCarMods][10] = strval(result);

                mysql_get_field("playerCarMod11", result);
                playerVariables[extraid][pCarMods][11] = strval(result);

                mysql_get_field("playerCarMod12", result);
                playerVariables[extraid][pCarMods][12] = strval(result);

                mysql_get_field("playerCarPosX", result);
                playerVariables[extraid][pCarPos][0] = floatstr(result);

                mysql_get_field("playerCarPosY", result);
                playerVariables[extraid][pCarPos][1] = floatstr(result);

                mysql_get_field("playerCarPosZ", result);
                playerVariables[extraid][pCarPos][2] = floatstr(result);

                mysql_get_field("playerCarPosZAngle", result);
                playerVariables[extraid][pCarPos][3] = floatstr(result);

                mysql_get_field("playerCarColour1", result);
                playerVariables[extraid][pCarColour][0] = strval(result);

                mysql_get_field("playerCarColour2", result);
                playerVariables[extraid][pCarColour][1] = strval(result);

                mysql_get_field("playerCarPaintJob", result);
                playerVariables[extraid][pCarPaintjob] = strval(result);

                mysql_get_field("playerCarLock", result);
                playerVariables[extraid][pCarLock] = strval(result);

                mysql_get_field("playerFightStyle", result);
                playerVariables[extraid][pFightStyle] = strval(result);

                mysql_get_field("playerCarWeapon1", result);
                playerVariables[extraid][pCarWeapons][0] = strval(result);

                mysql_get_field("playerCarWeapon2", result);
                playerVariables[extraid][pCarWeapons][1] = strval(result);

                mysql_get_field("playerCarWeapon3", result);
                playerVariables[extraid][pCarWeapons][2] = strval(result);

                mysql_get_field("playerCarWeapon4", result);
                playerVariables[extraid][pCarWeapons][3] = strval(result);

                mysql_get_field("playerCarWeapon5", result);
                playerVariables[extraid][pCarWeapons][4] = strval(result);

                mysql_get_field("playerCarTrunk1", result);
                playerVariables[extraid][pCarTrunk][0] = strval(result);

                mysql_get_field("playerCarTrunk2", result);
                playerVariables[extraid][pCarTrunk][1] = strval(result);

                mysql_get_field("playerPhoneCredit", result);
                playerVariables[extraid][pPhoneCredit] = strval(result);

                mysql_get_field("playerWalkieTalkie", result);
                playerVariables[extraid][pWalkieTalkie] = strval(result);

				GetPlayerName(extraid, playerVariables[extraid][pNormalName], MAX_PLAYER_NAME);

				GetPlayerIp(extraid, playerVariables[extraid][pConnectionIP], 32);

				playerVariables[extraid][pStatus] = 1;
				
				if(playerVariables[extraid][pAdminLevel] > 0) {
					format(result, sizeof(result), "SELECT conIP from playerconnections WHERE conPlayerID = %d AND conIP = '%s'", playerVariables[extraid][pInternalID], playerVariables[extraid][pConnectionIP]);
					mysql_query(result, THREAD_ADMIN_SECURITY, extraid);
					
					if(GetPVarInt(extraid, "pAdminPIN") == 0)
				    	ShowPlayerDialog(extraid, DIALOG_SET_ADMIN_PIN, DIALOG_STYLE_INPUT, "SERVER: Admin PIN creation", "The system has detected you do not yet have an admin PIN set.\n\nThis is a new compulsory security measure.\n\nPlease set a four digit pin:", "OK", "");
				}
				
				format(result, sizeof(result), "SELECT `conTS` FROM `playerconnections` WHERE `conPlayerID` = '%d' ORDER BY `conId` DESC LIMIT 1", playerVariables[extraid][pInternalID]);
				mysql_query(result, THREAD_TIMESTAMP_CONNECT, extraid);

				format(result, sizeof(result), "INSERT INTO playerconnections (conName, conIP, conPlayerID) VALUES('%s', '%s', %d)", playerVariables[extraid][pNormalName], playerVariables[extraid][pConnectionIP], playerVariables[extraid][pInternalID]);
				mysql_query(result, THREAD_RANDOM);

				format(result, sizeof(result), "UPDATE playeraccounts SET playerStatus = '1' WHERE playerID = %d", playerVariables[extraid][pInternalID]);
				mysql_query(result, THREAD_RANDOM);
				
				format(result, sizeof(result), "SELECT * FROM playervehicles WHERE pvOwnerId = %d", playerVariables[extraid][pInternalID]);
				mysql_query(result, THREAD_LOAD_PLAYER_VEHICLES, extraid); 

				
				
				
				
				
				
				
				
				
			    if(playerVariables[extraid][pFirstLogin] >= 1) {
			        // Dialog to send player in to quiz and prevent any other code for the player from being executed, as they have to complete the quiz/tutorial first.
			        return ShowPlayerDialog(extraid, DIALOG_QUIZ, DIALOG_STYLE_LIST, "What is roleplay in SA-MP?", "A type of gamemode where you realistically act out a character\nAn STD\nA track by Jay-Z\nA type of gamemode where you just kill people", "Select", "");
				}

                SetSpawnInfo(extraid, 0, playerVariables[extraid][pSkin], playerVariables[extraid][pPos][0], playerVariables[extraid][pPos][1], playerVariables[extraid][pPos][2], 0, 0, 0, 0, 0, 0, 0);
				SpawnPlayer(extraid);

	         	if(playerVariables[extraid][pWarrants] > 0) {
	         	    SetPlayerWantedLevel(extraid, playerVariables[extraid][pWarrants]);
	         	    SendClientMessage(extraid, COLOR_HOTORANGE, "You're still a wanted man! Your criminal record has been reinstated.");
	         	}

	         	format(szQueryOutput, sizeof(szQueryOutput), "SELECT * FROM `banksuspensions` WHERE `playerID` = %d", playerVariables[extraid][pInternalID]);
				mysql_query(szQueryOutput, THREAD_BANK_SUSPENSION, extraid);

	         	if(playerVariables[extraid][pCarModel] > 0)
					SpawnPlayerVehicle(extraid);

				if(playerVariables[extraid][pLevel] > 0)
				    SetPlayerScore(extraid, playerVariables[extraid][pLevel]);

				if(playerVariables[extraid][pAdminDuty] == 1 && playerVariables[extraid][pAdminLevel] < 1) {
					playerVariables[extraid][pAdminLevel] = 0;
					playerVariables[extraid][pAdminDuty] = 0;
					playerVariables[extraid][pAdminName][0] = '*';
					SendClientMessage(extraid, COLOR_HOTORANGE, "You're no longer an administrator.");
				}

				if(playerVariables[extraid][pAdminLevel] > 0 && playerVariables[extraid][pAdminDuty] > 1)
				    SetPlayerName(extraid, playerVariables[extraid][pAdminName]);
			}

			mysql_free_result();
		}
		case THREAD_BANK_SUSPENSION: {
			mysql_store_result();

			if(mysql_num_rows() < 1)
			    return 1;

			mysql_retrieve_row();

			mysql_get_field("suspensionReason", result);
			SetPVarString(extraid, "BSuspend", result);

			mysql_get_field("suspendeeID", result);
			mysql_free_result();

			format(szQueryOutput, sizeof(szQueryOutput), "SELECT `playerName` FROM `playeraccounts` WHERE `playerID` = %d", strval(result));
			mysql_query(szQueryOutput);
			mysql_store_result();
			mysql_retrieve_row();

			mysql_get_field("playerName", result);
			SetPVarString(extraid, "BSuspendee", result);

			mysql_free_result();
		}
		case THREAD_CHECK_BANS_LIST: {
		    mysql_store_result();
		    
		    // The query worked. We know there's no (serious) MySQL problems, so we won't display the error dialog.
		    SetPVarInt(extraid, "bcs", 1);

			if(!IsPlayerConnected(extraid))
				return mysql_free_result(); // Incase they're disconnected since... Sometimes queries F*"!%$" up.

		    if(mysql_num_rows() >= 1) {
				SendClientMessage(extraid, COLOR_RED, "You're banned from this server.");
				Kick(extraid);
			}
		    else {
				new
			        playerEscapedName[MAX_PLAYER_NAME],
			        queryUsername[100];

			    GetPlayerName(extraid, szPlayerName, MAX_PLAYER_NAME);
			    mysql_real_escape_string(szPlayerName, playerEscapedName);

				// Continue with the rest of the auth code...
			    format(queryUsername, sizeof(queryUsername), "SELECT `playerName` FROM `playeraccounts` WHERE `playerName` = '%s'", playerEscapedName);
			    mysql_query(queryUsername, THREAD_CHECK_ACCOUNT_USERNAME, extraid);
		    }

		    mysql_free_result();
		}
		case THREAD_BAN_PLAYER: {
			format(szQueryOutput, sizeof(szQueryOutput), "UPDATE playeraccounts SET playerBanned = '1' WHERE playerID = '%d'", playerVariables[extraid][pInternalID]);
			mysql_query(szQueryOutput, THREAD_FINALIZE_BAN, extraid);
		}
		case THREAD_FINALIZE_BAN: return Kick(extraid);
		case THREAD_CHECK_PLAYER_NAME_BANNED: {
			mysql_store_result();

			if(mysql_num_rows() >= 1) {
			    GetPVarString(extraid, "playerNameUnban", szPlayerName, MAX_PLAYER_NAME);

				format(szQueryOutput, sizeof(szQueryOutput), "DELETE FROM bans WHERE playerNameBanned = '%s'", szPlayerName);
				mysql_query(szQueryOutput, THREAD_FINALIZE_UNBAN, extraid);
			}
			else {
			    SendClientMessage(extraid, COLOR_GREY, "The specified player name is not banned.");
			}

			mysql_free_result();
		}
		case THREAD_FINALIZE_UNBAN: {
		    new
		        szPlayerName2[MAX_PLAYER_NAME];

            GetPVarString(extraid, "playerNameUnban", szPlayerName2, MAX_PLAYER_NAME);
		    GetPlayerName(extraid, szPlayerName, MAX_PLAYER_NAME);
		    SendClientMessage(extraid, COLOR_WHITE, "The unban has been successful.");

			format(szMessage, sizeof(szMessage), "AdmWarn: {FFFFFF}%s has unbanned player %s.", szPlayerName, szPlayerName2);

			submitToAdmins(szMessage, COLOR_HOTORANGE);
		    adminLog(szMessage);

		    format(szMessage, sizeof(szMessage), "UPDATE playeraccounts SET playerBanned = '0' WHERE playerName = '%s'", szPlayerName2);
		    mysql_query(szMessage);
		}
		case THREAD_INITIATE_HOUSES: {
			mysql_store_result();

			new
			    x;

			while(mysql_retrieve_row()) {
				mysql_get_field("houseID", result);
				x = strval(result);

				mysql_get_field("houseExteriorPosX", result);
				houseVariables[x][hHouseExteriorPos][0] = floatstr(result);

				mysql_get_field("houseExteriorPosY", result);
				houseVariables[x][hHouseExteriorPos][1] = floatstr(result);

				mysql_get_field("houseExteriorPosZ", result);
				houseVariables[x][hHouseExteriorPos][2] = floatstr(result);

				mysql_get_field("houseInteriorPosX", result);
				houseVariables[x][hHouseInteriorPos][0] = floatstr(result);

				mysql_get_field("houseInteriorPosY", result);
				houseVariables[x][hHouseInteriorPos][1] = floatstr(result);

				mysql_get_field("houseInteriorPosZ", result);
				houseVariables[x][hHouseInteriorPos][2] = floatstr(result);

				mysql_get_field("houseInteriorID", result);
				houseVariables[x][hHouseInteriorID] = strval(result);

				mysql_get_field("houseExteriorID", result);
				houseVariables[x][hHouseExteriorID] = strval(result);

				mysql_get_field("houseOwner", houseVariables[x][hHouseOwner]);

				mysql_get_field("housePrice", result);
				houseVariables[x][hHousePrice] = strval(result);

				mysql_get_field("houseLocked", result);
				houseVariables[x][hHouseLocked] = strval(result);

				mysql_get_field("houseMoney", result);
				houseVariables[x][hMoney] = strval(result);

				mysql_get_field("houseWeapon1", result);
				houseVariables[x][hWeapons][0] = strval(result);

				mysql_get_field("houseWeapon2", result);
				houseVariables[x][hWeapons][1] = strval(result);

				mysql_get_field("houseWeapon3", result);
				houseVariables[x][hWeapons][2] = strval(result);

				mysql_get_field("houseWeapon4", result);
				houseVariables[x][hWeapons][3] = strval(result);

				mysql_get_field("houseWeapon5", result);
				houseVariables[x][hWeapons][4] = strval(result);

				mysql_get_field("houseWardrobe1", result);
				houseVariables[x][hWardrobe][0] = strval(result);

				mysql_get_field("houseWardrobe2", result);
				houseVariables[x][hWardrobe][1] = strval(result);

				mysql_get_field("houseWardrobe3", result);
				houseVariables[x][hWardrobe][2] = strval(result);

				mysql_get_field("houseWardrobe4", result);
				houseVariables[x][hWardrobe][3] = strval(result);

				mysql_get_field("houseWardrobe5", result);
				houseVariables[x][hWardrobe][4] = strval(result);

				mysql_get_field("houseMaterials", result);
				houseVariables[x][hMaterials] = strval(result);

				if(!strcmp(houseVariables[x][hHouseOwner], "Nobody", true) && strlen(houseVariables[x][hHouseOwner]) >= 1) {
				    new
				        labelString[96];

				    if(houseVariables[x][hHouseLocked] == 1) {
				    	format(labelString, sizeof(labelString), "House %d (un-owned - /buyhouse)\nPrice: $%d\n\n(locked)", x, houseVariables[x][hHousePrice]);
				    }
				    else {
				        format(labelString, sizeof(labelString), "House %d (un-owned - /buyhouse)\nPrice: $%d\n\nPress ~k~~PED_DUCK~ to enter.", x, houseVariables[x][hHousePrice]);
				    }

				    houseVariables[x][hLabelID] = CreateDynamic3DTextLabel(labelString, COLOR_YELLOW, houseVariables[x][hHouseExteriorPos][0], houseVariables[x][hHouseExteriorPos][1], houseVariables[x][hHouseExteriorPos][2], 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 10.0);
					houseVariables[x][hPickupID] = CreateDynamicPickup(1273, 23, houseVariables[x][hHouseExteriorPos][0], houseVariables[x][hHouseExteriorPos][1], houseVariables[x][hHouseExteriorPos][2], 0, houseVariables[x][hHouseExteriorID], -1, 250);
				}
				else {
				    new
				        labelString[96];

				    if(houseVariables[x][hHouseLocked] == 1) {
				    	format(labelString, sizeof(labelString), "House %d (owned)\nOwner: %s\n\n(locked)", x, houseVariables[x][hHouseOwner]);
				    }
				    else {
				        format(labelString, sizeof(labelString), "House %d (owned)\nOwner: %s\n\nPress ~k~~PED_DUCK~ to enter.", x, houseVariables[x][hHouseOwner]);
				    }

				    houseVariables[x][hLabelID] = CreateDynamic3DTextLabel(labelString, COLOR_YELLOW, houseVariables[x][hHouseExteriorPos][0], houseVariables[x][hHouseExteriorPos][1], houseVariables[x][hHouseExteriorPos][2], 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 10.0);
				    houseVariables[x][hPickupID] = CreateDynamicPickup(1272, 23, houseVariables[x][hHouseExteriorPos][0], houseVariables[x][hHouseExteriorPos][1], houseVariables[x][hHouseExteriorPos][2], 0, houseVariables[x][hHouseExteriorID], -1, 50);
				}

				systemVariables[houseCount]++;
			}

			printf("[script] %d houses loaded.", systemVariables[houseCount]);

			mysql_free_result();
		}
		case THREAD_INITIATE_BUSINESSES: {
			mysql_store_result();

			new
			    x;

			while(mysql_retrieve_row()) {
				mysql_get_field("businessID", result);
				x = strval(result);

				mysql_get_field("businessName", businessVariables[x][bName]);

				mysql_get_field("businessOwner", businessVariables[x][bOwner]);

				mysql_get_field("businessType", result);
				businessVariables[x][bType] = strval(result);

				mysql_get_field("businessExteriorX", result);
				businessVariables[x][bExteriorPos][0] = floatstr(result);

				mysql_get_field("businessExteriorY", result);
				businessVariables[x][bExteriorPos][1] = floatstr(result);

				mysql_get_field("businessExteriorZ", result);
				businessVariables[x][bExteriorPos][2] = floatstr(result);

				mysql_get_field("businessInteriorX", result);
				businessVariables[x][bInteriorPos][0] = floatstr(result);

				mysql_get_field("businessInteriorY", result);
				businessVariables[x][bInteriorPos][1] = floatstr(result);

				mysql_get_field("businessInteriorZ", result);
				businessVariables[x][bInteriorPos][2] = floatstr(result);

				mysql_get_field("businessInterior", result);
				businessVariables[x][bInterior] = strval(result);

				mysql_get_field("businessLock", result);
				businessVariables[x][bLocked] = strval(result);

				mysql_get_field("businessPrice", result);
				businessVariables[x][bPrice] = strval(result);

				mysql_get_field("businessVault", result);
				businessVariables[x][bVault] = strval(result);

				mysql_get_field("businessMiscX", result);
				businessVariables[x][bMiscPos][0] = floatstr(result);

				mysql_get_field("businessMiscY", result);
				businessVariables[x][bMiscPos][1] = floatstr(result);

				mysql_get_field("businessMiscZ", result);
				businessVariables[x][bMiscPos][2] = floatstr(result);

				switch(businessVariables[x][bLocked]) {
					case 1: {
					    if(!strcmp(businessVariables[x][bOwner], "Nobody", true)) {
							format(result, sizeof(result), "%s\n(Business %d - un-owned)\nPrice: $%d (/buybusiness)\n\n(locked)", businessVariables[x][bName], x, businessVariables[x][bPrice]);
						}
						else {
						    format(result, sizeof(result), "%s\n(Business %d - owned by %s)\n\n(locked)", businessVariables[x][bName], x, businessVariables[x][bOwner]);
						}
					}
					case 0: {
					    if(!strcmp(businessVariables[x][bOwner], "Nobody", true)) {
							format(result, sizeof(result), "%s\n(Business %d - un-owned)\nPrice: $%d (/buybusiness)\n\nPress ~k~~PED_DUCK~ to enter", businessVariables[x][bName], x, businessVariables[x][bPrice]);
						}
						else {
						    format(result, sizeof(result), "%s\n(Business %d - owned by %s)\n\nPress ~k~~PED_DUCK~ to enter", businessVariables[x][bName], x, businessVariables[x][bOwner]);
						}
					}
				}

				businessVariables[x][bLabelID] = CreateDynamic3DTextLabel(result, COLOR_YELLOW, businessVariables[x][bExteriorPos][0], businessVariables[x][bExteriorPos][1], businessVariables[x][bExteriorPos][2], 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 10.0);
				businessVariables[x][bPickupID] = CreateDynamicPickup(1239, 23, businessVariables[x][bExteriorPos][0], businessVariables[x][bExteriorPos][1], businessVariables[x][bExteriorPos][2], 0, 0, -1, 250);
				systemVariables[businessCount]++;
			}

			mysql_free_result();
		}
		case THREAD_INITIATE_VEHICLES: {
			mysql_store_result();

			new
			    x,
				bool: success = true;

			while(mysql_retrieve_row()) {
			    mysql_get_field("vehicleID", result);
			    x = strval(result);

				if(systemVariables[vehicleCounts][0] + systemVariables[vehicleCounts][1] + systemVariables[vehicleCounts][2] < MAX_VEHICLES) {
					mysql_get_field("vehicleModelID", result);
					vehicleVariables[x][vVehicleModelID] = strval(result);

					mysql_get_field("vehiclePosX", result);
					vehicleVariables[x][vVehiclePosition][0] = floatstr(result);

					mysql_get_field("vehiclePosY", result);
					vehicleVariables[x][vVehiclePosition][1] = floatstr(result);

					mysql_get_field("vehiclePosZ", result);
					vehicleVariables[x][vVehiclePosition][2] = floatstr(result);

					mysql_get_field("vehiclePosRotation", result);
					vehicleVariables[x][vVehicleRotation] = floatstr(result);

					mysql_get_field("vehicleGroup", result);
					vehicleVariables[x][vVehicleGroup] = strval(result);

					mysql_get_field("vehicleCol1", result);
					vehicleVariables[x][vVehicleColour][0] = strval(result);

					mysql_get_field("vehicleCol2", result);
					vehicleVariables[x][vVehicleColour][1] = strval(result);

					if(vehicleVariables[x][vVehicleColour][0] < 0) {
						vehicleVariables[x][vVehicleColour][0] = random(126);
					}
					if(vehicleVariables[x][vVehicleColour][1] < 0) {
						vehicleVariables[x][vVehicleColour][1] = random(126);
					}

					vehicleVariables[x][vVehicleScriptID] = CreateVehicle(vehicleVariables[x][vVehicleModelID], vehicleVariables[x][vVehiclePosition][0], vehicleVariables[x][vVehiclePosition][1], vehicleVariables[x][vVehiclePosition][2], vehicleVariables[x][vVehicleRotation], vehicleVariables[x][vVehicleColour][0], vehicleVariables[x][vVehicleColour][1], 60000);

					switch(vehicleVariables[x][vVehicleModelID]) { // OnVehicleSpawn has some annoying glitches with this!1. Should fix.
						case 427, 428, 432, 601, 528: SetVehicleHealth(vehicleVariables[x][vVehicleScriptID], 5000.0);
					}
					systemVariables[vehicleCounts][0]++;
				}
				else {
					success = false;
					printf("ERROR: Vehicle limit reached (MODEL %d, VEHICLEID %d, MAXIMUM %d, TYPE STATIC) [01x08]", vehicleVariables[x][vVehicleModelID], x, MAX_VEHICLES);
				}
			}
			if(success) printf("[script] %d vehicles loaded.", systemVariables[vehicleCounts][0]);
			mysql_free_result();
		}
		case THREAD_INITIATE_JOBS: {
			mysql_store_result();

			new
			    x;

			while(mysql_retrieve_row()) {

			    mysql_get_field("jobID", result);
			    x = strval(result);

			    mysql_get_field("jobType", result);
			    jobVariables[x][jJobType] = strval(result);

			    mysql_get_field("jobPositionX", result);
			    jobVariables[x][jJobPosition][0] = floatstr(result);

			    mysql_get_field("jobPositionY", result);
			    jobVariables[x][jJobPosition][1] = floatstr(result);

			    mysql_get_field("jobPositionZ", result);
			    jobVariables[x][jJobPosition][2] = floatstr(result);

			    mysql_get_field("jobName", jobVariables[x][jJobName]);

			    format(result, sizeof(result), "Job %s\nType /getjob", jobVariables[x][jJobName]);

			    jobVariables[x][jJobPickupID] = CreateDynamicPickup(1239, 23, jobVariables[x][jJobPosition][0], jobVariables[x][jJobPosition][1], jobVariables[x][jJobPosition][2], 0, -1, -1, 50);
				jobVariables[x][jJobLabelID] = CreateDynamic3DTextLabel(result, COLOR_YELLOW, jobVariables[x][jJobPosition][0], jobVariables[x][jJobPosition][1], jobVariables[x][jJobPosition][2], 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 50.0);
			}

			mysql_free_result();
		}
		case THREAD_INITIATE_GROUPS: {
		    mysql_store_result();

			new
			    x;

			while(mysql_retrieve_row()) {
			    mysql_get_field("groupID", result);
			    x = strval(result);

			    mysql_get_field("groupName", groupVariables[x][gGroupName]);

			    mysql_get_field("groupType", result);
			    groupVariables[x][gGroupType] = strval(result);

			    mysql_get_field("groupHQExteriorPosX", result);
			    groupVariables[x][gGroupExteriorPos][0] = floatstr(result);

			    mysql_get_field("groupHQExteriorPosY", result);
			    groupVariables[x][gGroupExteriorPos][1] = floatstr(result);

			    mysql_get_field("groupHQExteriorPosZ", result);
			    groupVariables[x][gGroupExteriorPos][2] = floatstr(result);

			    mysql_get_field("groupHQInteriorPosX", result);
			    groupVariables[x][gGroupInteriorPos][0] = floatstr(result);

			    mysql_get_field("groupHQInteriorPosY", result);
			    groupVariables[x][gGroupInteriorPos][1] = floatstr(result);

			    mysql_get_field("groupHQInteriorPosZ", result);
			    groupVariables[x][gGroupInteriorPos][2] = floatstr(result);

			    mysql_get_field("groupHQInteriorID", result);
			    groupVariables[x][gGroupHQInteriorID] = strval(result);

			    mysql_get_field("groupHQLockStatus", result);
			    groupVariables[x][gGroupHQLockStatus] = strval(result);

			    mysql_get_field("groupSafeMoney", result);
			    groupVariables[x][gSafe][0] = strval(result);

			    mysql_get_field("groupSafeMats", result);
			    groupVariables[x][gSafe][1] = strval(result);

			    mysql_get_field("groupSafePosX", result);
			    groupVariables[x][gSafePos][0] = floatstr(result);

			    mysql_get_field("groupSafePosY", result);
			    groupVariables[x][gSafePos][1] = floatstr(result);

			    mysql_get_field("groupSafePosZ", result);
			    groupVariables[x][gSafePos][2] = floatstr(result);

				// mysql_get_field("groupSafePot", result);
			    // groupVariables[x][gSafe][2] = strval(result);

			    // mysql_get_field("groupSafeCocaine", result);
			    // groupVariables[x][gSafe][3] = strval(result);
				
			    mysql_get_field("groupMOTD", groupVariables[x][gGroupMOTD]);

			    mysql_get_field("groupRankName1", groupVariables[x][gGroupRankName1]);
			    mysql_get_field("groupRankName2", groupVariables[x][gGroupRankName2]);
			    mysql_get_field("groupRankName3", groupVariables[x][gGroupRankName3]);
			    mysql_get_field("groupRankName4", groupVariables[x][gGroupRankName4]);
			    mysql_get_field("groupRankName5", groupVariables[x][gGroupRankName5]);
			    mysql_get_field("groupRankName6", groupVariables[x][gGroupRankName6]);

				switch(groupVariables[x][gGroupHQLockStatus]) {
			    	case 0: format(result, sizeof(result), "%s's HQ\n\nPress ~k~~PED_DUCK~ to enter.", groupVariables[x][gGroupName]);
			    	case 1: format(result, sizeof(result), "%s's HQ\n\n(locked)", groupVariables[x][gGroupName]);
			    }

				groupVariables[x][gGroupPickupID] = CreateDynamicPickup(1239, 23, groupVariables[x][gGroupExteriorPos][0], groupVariables[x][gGroupExteriorPos][1], groupVariables[x][gGroupExteriorPos][2], 0, -1, -1, 10);
				groupVariables[x][gGroupLabelID] = CreateDynamic3DTextLabel(result, COLOR_YELLOW, groupVariables[x][gGroupExteriorPos][0], groupVariables[x][gGroupExteriorPos][1], groupVariables[x][gGroupExteriorPos][2], 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 25.0);

				format(result, sizeof(result), "%s\nGroup Safe", groupVariables[x][gGroupName]);

				groupVariables[x][gSafePickupID] = CreateDynamicPickup(1239, 23, groupVariables[x][gSafePos][0], groupVariables[x][gSafePos][1], groupVariables[x][gSafePos][2], GROUP_VIRTUAL_WORLD+x, groupVariables[x][gGroupHQInteriorID], -1, 10);
				groupVariables[x][gSafeLabelID] = CreateDynamic3DTextLabel(result, COLOR_YELLOW, groupVariables[x][gSafePos][0], groupVariables[x][gSafePos][1], groupVariables[x][gSafePos][2], 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, GROUP_VIRTUAL_WORLD+x, groupVariables[x][gGroupHQInteriorID], -1, 20.0);
			}

		    mysql_free_result();
		}
		case THREAD_INITIATE_ASSETS: {
			mysql_store_result();

			new
			    x;

			while(mysql_retrieve_row()) {
			    mysql_get_field("assetID", result);
			    x = strval(result);

			    mysql_get_field("assetValue", result);
			    assetVariables[x][aAssetValue] = strval(result);

			    mysql_get_field("assetName", assetVariables[x][aAssetName]);
			}

			mysql_free_result();
		}
	}

	return 1;
}  

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid) {
	#if defined DEBUG
	    printf("[debug] OnPlayerInteriorChange(%d, %d, %d)", playerid, newinteriorid, oldinteriorid);
	#endif
	
	if(newinteriorid == 0) {
		SetPlayerWeather(playerid, weatherVariables[0]);
		SetPlayerVirtualWorld(playerid, 0); // Setting their virtual world in interior 0 keeps some annoying VW issues at bay.
	}
	else SetPlayerWeather(playerid, INTERIOR_WEATHER_ID);

	if(playerVariables[playerid][pSpectating] == INVALID_PLAYER_ID && playerVariables[playerid][pEvent] == 0) {
		playerVariables[playerid][pInterior] = newinteriorid;
		playerVariables[playerid][pVirtualWorld] = GetPlayerVirtualWorld(playerid);
	}
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid) {
	#if defined DEBUG
	    printf("[debug] OnPlayerExitVehicle(%d, %d)", playerid, vehicleid);
	#endif
	
	return SetPlayerArmedWeapon(playerid, 0);
} 

public OnPlayerEnterCheckpoint(playerid) {
	#if defined DEBUG
	    printf("[debug] OnPlayerEnterCheckpoint(%d)", playerid);
	#endif
	
	switch(playerVariables[playerid][pCheckpoint]) {
	    case 1: {
	        SendClientMessage(playerid, COLOR_WHITE, "You have reached your destination.");
	        DisablePlayerCheckpoint(playerid);

	        playerVariables[playerid][pCheckpoint] = 0;
	    }
		case 2: {
		    if(playerVariables[playerid][pMatrunTime] < 30) {
		        GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);

		        format(szMessage, sizeof(szMessage), "AdmWarn: {FFFFFF}%s may possibly be teleport matrunning (reached checkpoint in %d seconds).", szPlayerName, playerVariables[playerid][pMatrunTime]);
				submitToAdmins(szMessage, COLOR_HOTORANGE);
			}
		    else {
		        SendClientMessage(playerid, COLOR_WHITE, "You have collected 100 materials!");
		        DisablePlayerCheckpoint(playerid);

		        playerVariables[playerid][pCheckpoint] = 0;
		        playerVariables[playerid][pMaterials] += 100;
		        playerVariables[playerid][pMatrunTime] = 0;
	        }
	    }
	    case 3: {
			if(!IsPlayerInAnyVehicle(playerid))
				return SendClientMessage(playerid, COLOR_GREY, "You aren't in a vehicle; please get a vehicle to drop off at the crane.");

			else if(playerVariables[playerid][pCarID] == GetPlayerVehicleID(playerid)) return SendClientMessage(playerid, COLOR_GREY, "You can't sell your own vehicle here.");

			foreach(Player, v) {
				if(playerVariables[v][pCarID] == GetPlayerVehicleID(playerid)) {
					DestroyVehicle(GetPlayerVehicleID(playerid)); // If an owned car is destroyed... it'll be manually despawned...

					playerVariables[v][pCarPos][0] = 2157.5559; // ...moved to the LS junk yard...
					playerVariables[v][pCarPos][1] = -1977.6494;
					playerVariables[v][pCarPos][2] = 13.3835;
					playerVariables[v][pCarPos][3] = 177.3687; // have its Z angle set

					SpawnPlayerVehicle(v); // And spawned.

					SetVehicleHealth(playerVariables[v][pCarID], 400.0); // A wrecked car is a wrecked car.
				}
				else SetVehicleToRespawn(GetPlayerVehicleID(playerid));
			}

			new
				string[61],
				rand;

			switch(GetVehicleModel(GetPlayerVehicleID(playerid))) { // Thanks to Danny for these, lol
				case 405: rand = random(2000) + 2500;
				case 561: rand = random(2000) + 2750;
				case 535: rand = random(2000) + 2250;
				case 463: rand = random(2000) + 2000;
				case 461: rand = random(2000) + 2500;
				case 429: rand = random(2000) + 4500;
				case 451: rand = random(2000) + 4750;
				case 491: rand = random(2000) + 1800;
				case 492: rand = random(2000) + 1500;
				case 603: rand = random(2000) + 3800;
				case 502: rand = random(2000) + 5000;
				case 558: rand = random(2000) + 2500;
				case 554: rand = random(2000) + 1900;
				case 588: rand = random(2000) + 2300;
				case 518: rand = random(2000) + 2250;
				case 475: rand = random(2000) + 2300;
				case 542: rand = random(2000) + 2000;
				case 466: rand = random(2000) + 2400;
				case 462: rand = random(2000) + 500;
				case 596: rand = random(2000) + 3000;
				case 427: rand = random(2000) + 4500;
				case 528: rand = random(2000) + 4250;
				case 601: rand = random(2000) + 5000;
				case 523: rand = random(2000) + 3000;
				case 600: rand = random(2000) + 2250;
				case 468: rand = random(2000) + 2000;
				case 418: rand = random(2000) + 2100;
				case 482: rand = random(2000) + 2750;
				case 440: rand = random(2000) + 2250;
				case 587: rand = random(2000) + 3800;
				case 412: rand = random(2000) + 2500;
				case 534: rand = random(2000) + 2700;
				case 536: rand = random(2000) + 2600;
				case 567: rand = random(2000) + 2650;
				case 448: rand = random(2000) + 550;
				case 602: rand = random(2000) + 3100;
				case 586: rand = random(2000) + 2200;
				case 421: rand = random(2000) + 2900;
				case 581: rand = random(2000) + 2250;
				case 521: rand = random(2000) + 2750;
				case 598: rand = random(2000) + 3250;
				case 574: rand = random(2000) + 750;
				case 500: rand = random(2000) + 2700;
				case 579: rand = random(2000) + 3100;
				case 467: rand = random(2000) + 2000;
				case 426: rand = random(2000) + 2600;
				case 555: rand = random(2000) + 3250;
				case 437: rand = random(2000) + 4800;
				case 428: rand = random(2000) + 4750;
				case 442: rand = random(2000) + 2200;
				case 458: rand = random(2000) + 2000;
				case 527: rand = random(2000) + 1950;
				case 496: rand = random(2000) + 2100;
				case 400: rand = random(2000) + 3000;
				case 605: rand = random(2000) + 900;
				case 604: rand = random(2000) + 900;
				case 522: rand = random(2000) + 5000;
				case 438: rand = random(2000) + 2750;
				case 420: rand = random(2000) + 2600;
				case 404: rand = random(2000) + 1250;
				case 585: rand = random(2000) + 2400;
				case 543: rand = random(2000) + 2000;
				case 515: rand = random(2000) + 4500;
				case 560: rand = random(2000) + 3900;
				case 409: rand = random(2000) + 2950;
				case 402: rand = random(2000) + 3250;
				default: rand = random(2000) + 1000;
			}

			playerVariables[playerid][pDropCarTimeout] = 1800;
            playerVariables[playerid][pCheckpoint] = 0;
            DisablePlayerCheckpoint(playerid);
			playerVariables[playerid][pMoney] += rand;

			format(string, sizeof(string), "You have dropped your vehicle at the crane and earned $%d!", rand);
            SendClientMessage(playerid, COLOR_WHITE, string);
		}
		case 4: {

	        SendClientMessage(playerid, COLOR_WHITE, "You have reached your vehicle.");
	        DisablePlayerCheckpoint(playerid);

	        playerVariables[playerid][pCheckpoint] = 0;

		}
		case 5: {
			if(playerVariables[playerid][pBackup] != -1) {

				SendClientMessage(playerid, COLOR_WHITE, "You have reached the backup checkpoint.");
				DisablePlayerCheckpoint(playerid);

				playerVariables[playerid][pCheckpoint] = 0;
				playerVariables[playerid][pBackup] = -1;
			}
		}
    	default: {
			DisablePlayerCheckpoint(playerid);
			playerVariables[playerid][pCheckpoint] = 0;
		}
    }
	return 1;
}

public OnPlayerUpdate(playerid) {
	if(playerVariables[playerid][pTutorial] == 1) {
	    new
			Keys,
			ud,
			lr;

	    GetPlayerKeys(playerid, Keys, ud, lr);
	    if(lr > 0) {
	        if(playerVariables[playerid][pSkinCount]+1 >= sizeof(tutorialSkins)) {
	            SetPlayerSkin(playerid, 0);
	            playerVariables[playerid][pSkinCount] = 0;
	            PlayerPlaySound(playerid, 1055, 0.0, 0.0, 0.0);
	        }
	        else {
		        playerVariables[playerid][pSkinCount]++;
				SetPlayerSkin(playerid, tutorialSkins[playerVariables[playerid][pSkinCount]]);
			}
		}
	    else if(lr < 0) {
	        if(playerVariables[playerid][pSkinCount]-1 < 0) {
	            SetPlayerSkin(playerid, 0);
	            playerVariables[playerid][pSkinCount] = 0;
	            PlayerPlaySound(playerid, 1055, 0.0, 0.0, 0.0);
	        }
	        else {
		        playerVariables[playerid][pSkinCount]--;
				SetPlayerSkin(playerid, tutorialSkins[playerVariables[playerid][pSkinCount]]);
			}
		}
	}

	if(playerVariables[playerid][pOnRequest] != INVALID_PLAYER_ID) {
	    new
			Keys,
			ud,
			lr;

	    GetPlayerKeys(playerid, Keys, ud, lr);

	    if(lr > 0) {
	        GetPlayerPos(playerVariables[playerid][pOnRequest], playerVariables[playerVariables[playerid][pOnRequest]][pPos][0], playerVariables[playerVariables[playerid][pOnRequest]][pPos][1], playerVariables[playerVariables[playerid][pOnRequest]][pPos][2]);

	        SetPlayerPos(playerid, playerVariables[playerVariables[playerid][pOnRequest]][pPos][0], playerVariables[playerVariables[playerid][pOnRequest]][pPos][1], playerVariables[playerVariables[playerid][pOnRequest]][pPos][2]);
			TextDrawHideForPlayer(playerid, textdrawVariables[1]);

			SendClientMessage(playerid, COLOR_WHITE, "You have teleported to the player who has requested help.");

			playerVariables[playerid][pOnRequest] = INVALID_PLAYER_ID;
		}
	    else if(lr < 0) {
			TextDrawHideForPlayer(playerid, textdrawVariables[1]);
			playerVariables[playerid][pOnRequest] = INVALID_PLAYER_ID;
		}
	}

	if(playerVariables[playerid][pTabbed] == 1) {
		playerVariables[playerid][pTabbed] = 0;
		DestroyDynamic3DTextLabel(playerVariables[playerid][pAFKLabel]);
		if(playerVariables[playerid][pOutstandingWeaponRemovalSlot] >= 1) {
		    if(playerVariables[playerid][pOutstandingWeaponRemovalSlot] == 40) {
		        ResetPlayerWeapons(playerid);
		    }
		    else {
			    ResetPlayerWeapons(playerid);
				playerVariables[playerid][pWeapons][playerVariables[playerid][pOutstandingWeaponRemovalSlot]] = 0;
				givePlayerWeapons(playerid);
			}
			playerVariables[playerid][pAnticheatExemption] = 6;
		}
	}

    if(playerVariables[playerid][pTutorial] >= 4 && playerVariables[playerid][pTutorial] < 14 && GetPVarInt(playerid, "tutTime") > 0)
		TextDrawShowForPlayer(playerid, textdrawVariables[8]);

	if(playerVariables[playerid][pTutorial] >= 4 && playerVariables[playerid][pTutorial] < 14 && GetPVarInt(playerid, "tutTime") < 1) {
	    new
			Keys,
			ud,
			lr;

	    GetPlayerKeys(playerid, Keys, ud, lr);
	    if(lr > 0) {
	        playerVariables[playerid][pTutorial]++;
	        switch(playerVariables[playerid][pTutorial]) {
				case 5: {
					SendClientMessage(playerid, COLOR_YELLOW, "Overview");
					SendClientMessage(playerid, COLOR_WHITE, "This is a roleplay server, which means you act out a character as if it were real.");
					SendClientMessage(playerid, COLOR_WHITE, "Pressing the button to open the textbox (usually T) and simply typing a message,");
					SendClientMessage(playerid, COLOR_WHITE, "will broadcast what you've typed to the people around you as an 'IC' (in character) message.");
					SendClientMessage(playerid, COLOR_WHITE, " ");
					SendClientMessage(playerid, COLOR_WHITE, "Using /b and typing your message (e.g. /b hello) will enclose what you've written in double parenthesis.");
                    SendClientMessage(playerid, COLOR_WHITE, "This will broadcast your message to the people around you as an 'OOC' (out of character) message.");
                    SendClientMessage(playerid, COLOR_WHITE, " ");
                    SendClientMessage(playerid, COLOR_WHITE, "Similarly, using /o has the same purpose as /b, though this time the message will be broadcasted throughout the entire server.");

                    SetPVarInt(playerid, "tutTime", 10);
                    TextDrawHideForPlayer(playerid, textdrawVariables[7]);
                    SendClientMessage(playerid, COLOR_YELLOW, "");
				}
				case 6: {
				    clearScreen(playerid);
					SendClientMessage(playerid, COLOR_YELLOW, "Locations:");
					SendClientMessage(playerid, COLOR_YELLOW, "");

					SendClientMessage(playerid, COLOR_YELLOW, "The Bank");
					SendClientMessage(playerid, COLOR_WHITE, "This is the place you'll want to go to make your various monetary transactions.");
					SendClientMessage(playerid, COLOR_WHITE, "The following commands will be useful:");
					SendClientMessage(playerid, COLOR_WHITE, "/balance, /withdraw and /deposit");

					SetPlayerVirtualWorld(playerid, 0);
					SetPlayerInterior(playerid, 0);

					SetPlayerCameraPos(playerid, 608.430480, -1203.073608, 17.801227);
					SetPlayerCameraLookAt(playerid, 594.246276, -1237.907348, 17.801227);
					SetPlayerPos(playerid, 526.8502, -1261.1985, 16.2272-30);

					SetPVarInt(playerid, "tutTime", 4);
					TextDrawHideForPlayer(playerid, textdrawVariables[7]);
					SendClientMessage(playerid, COLOR_YELLOW, "");
				}
				case 7: {
					SendClientMessage(playerid, COLOR_YELLOW, "The Crane");
					SendClientMessage(playerid, COLOR_WHITE, "At the crane, you can drop off vehicles for money.");
					SendClientMessage(playerid, COLOR_WHITE, "Use the command /dropcar to drive the vehicle to the red marker.");

					SetPlayerCameraPos(playerid, 2637.447265, -2226.906738, 16.296875);
					SetPlayerCameraLookAt(playerid, 2651.442626, -2227.208496, 16.296875);
					SetPlayerPos(playerid, 2641.4473, -2226.9067, 16.2969-30);

					SetPVarInt(playerid, "tutTime", 5);
					TextDrawHideForPlayer(playerid, textdrawVariables[7]);
					SendClientMessage(playerid, COLOR_YELLOW, "");
				}
				case 8: {
					SendClientMessage(playerid, COLOR_YELLOW, "Los Santos Police Department");
					SendClientMessage(playerid, COLOR_WHITE, "This is the place where you'll find police officers.");
					SendClientMessage(playerid, COLOR_WHITE, "Inside, you should wait in lobby before being served.");
					SendClientMessage(playerid, COLOR_WHITE, "If you want to apply to the LSPD, please visit our forum.");

					SetPlayerCameraPos(playerid, 1495.273925, -1675.542358, 28.382812);
					SetPlayerCameraLookAt(playerid, 1535.268432, -1675.874023, 13.382812);
					SetPlayerPos(playerid, 2641.4473, -2226.9067, 16.2969-30);

					SetPVarInt(playerid, "tutTime", 6);
					TextDrawHideForPlayer(playerid, textdrawVariables[7]);
					SendClientMessage(playerid, COLOR_YELLOW, "");
				}
				case 9: {
				    clearScreen(playerid);
					SendClientMessage(playerid, COLOR_YELLOW, "Jobs:");
					SendClientMessage(playerid, COLOR_YELLOW, "");

					SendClientMessage(playerid, COLOR_WHITE, "Having a job gives you something to do. ");
					SendClientMessage(playerid, COLOR_WHITE, "Your job may also have a skill depending on the job you have.");
                    SendClientMessage(playerid, COLOR_WHITE, "All jobs are productive in some way.");

                    SetPVarInt(playerid, "tutTime", 2);
                    TextDrawHideForPlayer(playerid, textdrawVariables[7]);
                    SendClientMessage(playerid, COLOR_YELLOW, "");
				}
				case 10: {
					SendClientMessage(playerid, COLOR_YELLOW, "Mechanic Job");
					SendClientMessage(playerid, COLOR_WHITE, "You can find the Mechanic job near the crane at Ocean Docks.");
					SendClientMessage(playerid, COLOR_WHITE, "A mechanic can repair vehicles, add nitrous and even repaint vehicles.");

					SetPlayerCameraPos(playerid, 2314.167724, -2328.139892, 21.382812);
					SetPlayerCameraLookAt(playerid, 2323.291748, -2321.122314, 13.382812);
					SetPlayerPos(playerid, 2316.1677, -2328.1399, 13.3828-30);

					SetPVarInt(playerid, "tutTime", 5);
					TextDrawHideForPlayer(playerid, textdrawVariables[7]);
					SendClientMessage(playerid, COLOR_YELLOW, "");
				}
				case 11: {
					SendClientMessage(playerid, COLOR_YELLOW, "Arms Dealer Job");
					SendClientMessage(playerid, COLOR_WHITE, "You can find the Arms Dealer job at the front of LS Ammunation.");
					SendClientMessage(playerid, COLOR_WHITE, "An arms dealer goes on material runs to obtain materials.");
					SendClientMessage(playerid, COLOR_WHITE, "They can then use those materials to create weapons.");
					SendClientMessage(playerid, COLOR_WHITE, "There are ten weapon levels.");
					SendClientMessage(playerid, COLOR_WHITE, "Each level unlocks a new weapon. Every 50 weapons levels you up.");

					SetPlayerCameraPos(playerid, 1353.600097, -1301.909790, 19.382812);
					SetPlayerCameraLookAt(playerid, 1361.592285, -1285.515136, 13.382812);
					SetPlayerPos(playerid, 1351.6001, -1285.9098, 13.3828-30);

					SetPVarInt(playerid, "tutTime", 6);
					TextDrawHideForPlayer(playerid, textdrawVariables[7]);
					SendClientMessage(playerid, COLOR_YELLOW, "");
				}
				case 12: {
					SendClientMessage(playerid, COLOR_YELLOW, "Detective Job");
					SendClientMessage(playerid, COLOR_WHITE, "You can find the Detective job near the bank.");
					SendClientMessage(playerid, COLOR_WHITE, "A detective can track people, vehicles and houses");
					SendClientMessage(playerid, COLOR_WHITE, "To track vehicles and houses, however, you'll need to level up.");
					SendClientMessage(playerid, COLOR_WHITE, "As with the arms dealer job, there are 10 levels.");
					SendClientMessage(playerid, COLOR_WHITE, "Every 50 searches levels you up.");

					SetPlayerCameraPos(playerid, 622.514709, -1458.283691, 22.256816);
					SetPlayerCameraLookAt(playerid, 612.514709, -1458.298583, 14.256817);
					SetPlayerPos(playerid, 622.5147, -1458.2837, 14.2568-30);

					SetPVarInt(playerid, "tutTime", 10);
					TextDrawHideForPlayer(playerid, textdrawVariables[7]);
				}
				case 13: {
					SendClientMessage(playerid, COLOR_YELLOW, "Levels");
					SendClientMessage(playerid, COLOR_WHITE, "A very new feature to this script is a levels system.");
					SendClientMessage(playerid, COLOR_WHITE, "");
					SendClientMessage(playerid, COLOR_WHITE, "You can now gain OOC levels which will benefit you throughout the server.");
					SendClientMessage(playerid, COLOR_WHITE, "As of present, levels don't really do much - but future updates shall introduce a bunch of new features!");
                    SendClientMessage(playerid, COLOR_WHITE, "");
                    SendClientMessage(playerid, COLOR_WHITE, "You can only level up every X hours, and it costs money from your character's bank account.");

					SetPlayerCameraPos(playerid, 622.514709, -1458.283691, 22.256816);
					SetPlayerCameraLookAt(playerid, 612.514709, -1458.298583, 14.256817);
					SetPlayerPos(playerid, 622.5147, -1458.2837, 14.2568-30);

					SetPVarInt(playerid, "tutTime", 10);
					TextDrawHideForPlayer(playerid, textdrawVariables[7]);
				}
				case 14: {
					SendClientMessage(playerid, COLOR_YELLOW, "Conclusion");
					SendClientMessage(playerid, COLOR_WHITE, "Thanks for reading/watching the tutorial, your character will now spawn. ");
					SendClientMessage(playerid, COLOR_WHITE, "If you have any questions or concerns which relate to gameplay on our server, please use "EMBED_GREY"/n"EMBED_WHITE".");
                    SendClientMessage(playerid, COLOR_WHITE, "If you wish to obtain help from an official member of staff, please use "EMBED_GREY"/helpme"EMBED_WHITE".");
                    SendClientMessage(playerid, COLOR_WHITE, "If you see any players breaking rules, please use "EMBED_GREY"/report"EMBED_WHITE".");
                    
                    format(szMessage, sizeof(szMessage), "Last, but not least, please make sure that you register on our community forums: "EMBED_GREY"%s"EMBED_WHITE".", szServerWebsite);
                 	SendClientMessage(playerid, COLOR_WHITE, szMessage);
                 	
					firstPlayerSpawn(playerid);
					TextDrawHideForPlayer(playerid, textdrawVariables[7]);
				}
			}
		}
	    else if(lr < 0) {
	        playerVariables[playerid][pTutorial]--;

	        if(playerVariables[playerid][pTutorial] < 5) {
	            playerVariables[playerid][pTutorial] = 5;
	            PlayerPlaySound(playerid, 1055, 0.0, 0.0, 0.0);
	        }

	        switch(playerVariables[playerid][pTutorial]) {
				case 5: {
					SendClientMessage(playerid, COLOR_YELLOW, "Overview");
					SendClientMessage(playerid, COLOR_WHITE, "This is a roleplay server, which means you act out a character as if it were real.");
					SendClientMessage(playerid, COLOR_WHITE, "Pressing the button to open the textbox (usually T) and simply typing a message,");
					SendClientMessage(playerid, COLOR_WHITE, "will broadcast what you've typed to the people around you as an 'IC' (in character) message.");
					SendClientMessage(playerid, COLOR_WHITE, " ");
					SendClientMessage(playerid, COLOR_WHITE, "Using /b and typing your message (e.g. /b hello) will enclose what you've written in double parenthesis.");
                    SendClientMessage(playerid, COLOR_WHITE, "This will broadcast your message to the people around you as an 'OOC' (out of character) message.");
                    SendClientMessage(playerid, COLOR_WHITE, " ");
                    SendClientMessage(playerid, COLOR_WHITE, "Similarly, using /o has the same purpose as /b, though this time the message will be broadcasted throughout the entire server.");

                    SetPVarInt(playerid, "tutTime", 10);
                    TextDrawHideForPlayer(playerid, textdrawVariables[7]);
				}
				case 6: {
				    clearScreen(playerid);
					SendClientMessage(playerid, COLOR_YELLOW, "Locations:");
					SendClientMessage(playerid, COLOR_YELLOW, "");

					SendClientMessage(playerid, COLOR_YELLOW, "The Bank");
					SendClientMessage(playerid, COLOR_WHITE, "This is the place you'll want to go to make your various monetary transactions.");
					SendClientMessage(playerid, COLOR_WHITE, "The following commands will be useful:");
					SendClientMessage(playerid, COLOR_WHITE, "/balance, /withdraw and /deposit");

					SetPlayerVirtualWorld(playerid, 0);
					SetPlayerInterior(playerid, 0);

					SetPlayerCameraPos(playerid, 608.430480, -1203.073608, 17.801227);
					SetPlayerCameraLookAt(playerid, 594.246276, -1237.907348, 17.801227);
					SetPlayerPos(playerid, 526.8502, -1261.1985, 16.2272-30);

					SetPVarInt(playerid, "tutTime", 4);
					TextDrawHideForPlayer(playerid, textdrawVariables[7]);
				}
				case 7: {
					SendClientMessage(playerid, COLOR_YELLOW, "The Crane");
					SendClientMessage(playerid, COLOR_WHITE, "At the crane, you can drop off vehicles for money.");
					SendClientMessage(playerid, COLOR_WHITE, "Use the command /dropcar to drive the vehicle to the red marker.");

					SetPlayerCameraPos(playerid, 2637.447265, -2226.906738, 16.296875);
					SetPlayerCameraLookAt(playerid, 2651.442626, -2227.208496, 16.296875);
					SetPlayerPos(playerid, 2641.4473, -2226.9067, 16.2969-30);

					SetPVarInt(playerid, "tutTime", 5);
					TextDrawHideForPlayer(playerid, textdrawVariables[8]);
				}
				case 8: {
					SendClientMessage(playerid, COLOR_YELLOW, "Los Santos Police Department");
					SendClientMessage(playerid, COLOR_WHITE, "This is the place where you'll find police officers.");
					SendClientMessage(playerid, COLOR_WHITE, "Inside, you should wait in lobby before being served.");
					SendClientMessage(playerid, COLOR_WHITE, "If you want to apply to the LSPD, please visit our forum.");

					SetPlayerCameraPos(playerid, 1495.273925, -1675.542358, 28.382812);
					SetPlayerCameraLookAt(playerid, 1535.268432, -1675.874023, 13.382812);
					SetPlayerPos(playerid, 2641.4473, -2226.9067, 16.2969-30);

					SetPVarInt(playerid, "tutTime", 6);
					TextDrawHideForPlayer(playerid, textdrawVariables[7]);
				}
				case 9: {
				    clearScreen(playerid);
					SendClientMessage(playerid, COLOR_YELLOW, "Jobs:");
					SendClientMessage(playerid, COLOR_YELLOW, "");

					SendClientMessage(playerid, COLOR_WHITE, "Having a job gives you something to do. ");
					SendClientMessage(playerid, COLOR_WHITE, "Your job may also have a skill depending on the job you have.");
                    SendClientMessage(playerid, COLOR_WHITE, "All jobs are productive in some way.");

                    SetPVarInt(playerid, "tutTime", 5);
                    TextDrawHideForPlayer(playerid, textdrawVariables[7]);
				}
				case 10: {
					SendClientMessage(playerid, COLOR_YELLOW, "Mechanic Job");
					SendClientMessage(playerid, COLOR_WHITE, "You can find the Mechanic job near the crane at Ocean Docks.");
					SendClientMessage(playerid, COLOR_WHITE, "A mechanic can repair vehicles, add nitrous and even repaint vehicles.");

					SetPlayerCameraPos(playerid, 2314.167724, -2328.139892, 21.382812);
					SetPlayerCameraLookAt(playerid, 2323.291748, -2321.122314, 13.382812);
					SetPlayerPos(playerid, 2316.1677, -2328.1399, 13.3828-30);

					SetPVarInt(playerid, "tutTime", 5);
					TextDrawHideForPlayer(playerid, textdrawVariables[7]);
				}
				case 11: {
					SendClientMessage(playerid, COLOR_YELLOW, "Arms Dealer Job");
					SendClientMessage(playerid, COLOR_WHITE, "You can find the Arms Dealer job at the front of LS Ammunation.");
					SendClientMessage(playerid, COLOR_WHITE, "An arms dealer goes on material runs to obtain materials.");
					SendClientMessage(playerid, COLOR_WHITE, "They can then use those materials to create weapons.");
					SendClientMessage(playerid, COLOR_WHITE, "There are ten weapon levels.");
					SendClientMessage(playerid, COLOR_WHITE, "Each level unlocks a new weapon. Every 50 weapons levels you up.");

					SetPlayerCameraPos(playerid, 1353.600097, -1301.909790, 19.382812);
					SetPlayerCameraLookAt(playerid, 1361.592285, -1285.515136, 13.382812);
					SetPlayerPos(playerid, 1351.6001, -1285.9098, 13.3828-30);

					SetPVarInt(playerid, "tutTime", 10);
					TextDrawHideForPlayer(playerid, textdrawVariables[7]);
				}
				case 12: {
					SendClientMessage(playerid, COLOR_YELLOW, "Detective Job");
					SendClientMessage(playerid, COLOR_WHITE, "You can find the Detective job near the bank.");
					SendClientMessage(playerid, COLOR_WHITE, "A detective can track people, vehicles and houses");
					SendClientMessage(playerid, COLOR_WHITE, "To track vehicles and houses, however, you'll need to level up.");
					SendClientMessage(playerid, COLOR_WHITE, "As with the arms dealer job, there are 10 levels.");
					SendClientMessage(playerid, COLOR_WHITE, "Every 50 searches levels you up.");

					SetPlayerCameraPos(playerid, 622.514709, -1458.283691, 22.256816);
					SetPlayerCameraLookAt(playerid, 612.514709, -1458.298583, 14.256817);
					SetPlayerPos(playerid, 622.5147, -1458.2837, 14.2568-30);

					SetPVarInt(playerid, "tutTime", 10);
					TextDrawHideForPlayer(playerid, textdrawVariables[7]);
				}
				case 13: {
					SendClientMessage(playerid, COLOR_YELLOW, "Levels");
					SendClientMessage(playerid, COLOR_WHITE, "A very new feature to this script is a levels system.");
					SendClientMessage(playerid, COLOR_WHITE, "");
					SendClientMessage(playerid, COLOR_WHITE, "You can now gain OOC levels which will benefit you throughout the server.");
					SendClientMessage(playerid, COLOR_WHITE, "As of present, levels don't really do much - but future updates shall introduce a bunch of new features!");
                    SendClientMessage(playerid, COLOR_WHITE, "");
                    SendClientMessage(playerid, COLOR_WHITE, "You can only level up every X hours, and it costs money from your character's bank account.");

					SetPlayerCameraPos(playerid, 622.514709, -1458.283691, 22.256816);
					SetPlayerCameraLookAt(playerid, 612.514709, -1458.298583, 14.256817);
					SetPlayerPos(playerid, 622.5147, -1458.2837, 14.2568-30);

					SetPVarInt(playerid, "tutTime", 10);
					TextDrawHideForPlayer(playerid, textdrawVariables[7]);
				}
				case 14: {
					SendClientMessage(playerid, COLOR_YELLOW, "Conclusion");
					SendClientMessage(playerid, COLOR_WHITE, "Thanks for reading/watching the tutorial, your character will now spawn. ");
					SendClientMessage(playerid, COLOR_WHITE, "If you have any questions or concerns which relate to gameplay on our server, please use "EMBED_GREY"/n"EMBED_WHITE".");
                    SendClientMessage(playerid, COLOR_WHITE, "If you wish to obtain help from an official member of staff, please use "EMBED_GREY"/helpme"EMBED_WHITE".");
                    SendClientMessage(playerid, COLOR_WHITE, "If you see any players breaking rules, please use "EMBED_GREY"/report"EMBED_WHITE".");

                    format(szMessage, sizeof(szMessage), "Last, but not least, please make sure that you register on our community forums: "EMBED_GREY"%s"EMBED_WHITE".", szServerWebsite);
                 	SendClientMessage(playerid, COLOR_WHITE, szMessage);

					firstPlayerSpawn(playerid);
					TextDrawHideForPlayer(playerid, textdrawVariables[7]);
				}
			}
		}
	}

	if(GetPlayerState(playerid) == 2) {
		for(new v; v < MAX_SPIKES; v++) {
			if(spikeVariables[v][sPos][0] != 0 && spikeVariables[v][sPos][1] != 0 && spikeVariables[v][sPos][2] != 0) {
				if(IsVehicleInRangeOfPoint(GetPlayerVehicleID(playerid), 2.0, spikeVariables[v][sPos][0], spikeVariables[v][sPos][1], spikeVariables[v][sPos][2])) {

					new
						Damage[4];

					GetVehicleDamageStatus(GetPlayerVehicleID(playerid), Damage[0], Damage[1], Damage[2], Damage[3]); // Set tires to 15 and watch 'em pop.
					UpdateVehicleDamageStatus(GetPlayerVehicleID(playerid), Damage[0], Damage[1], Damage[2], 15);
				}
			}
		}
	}
	playerVariables[playerid][pConnectedSeconds] = gettime();
	return 1;
}

public OnPlayerRequestSpawn(playerid) {
	if(playerVariables[playerid][pFirstLogin] >= 1)
	    return 0;

	return 1;
}

public OnPlayerSpawn(playerid) {
	#if defined DEBUG
	    printf("[debug] OnPlayerSpawn(%d)", playerid);
	#endif
	
	PreloadAnimLib(playerid,"BOMBER");
	PreloadAnimLib(playerid,"RAPPING");
	PreloadAnimLib(playerid,"SHOP");
	PreloadAnimLib(playerid,"BEACH");
	PreloadAnimLib(playerid,"SMOKING");
	PreloadAnimLib(playerid,"ON_LOOKERS");
	PreloadAnimLib(playerid,"DEALER");
	PreloadAnimLib(playerid,"CRACK");
	PreloadAnimLib(playerid,"CARRY");
	PreloadAnimLib(playerid,"COP_AMBIENT");
	PreloadAnimLib(playerid,"PARK");
	PreloadAnimLib(playerid,"INT_HOUSE");
	PreloadAnimLib(playerid,"FOOD");
	PreloadAnimLib(playerid,"GANGS");
	PreloadAnimLib(playerid,"PED");
	PreloadAnimLib(playerid,"FAT");

	SetPlayerColor(playerid, COLOR_WHITE);
	SetPlayerFightingStyle(playerid, playerVariables[playerid][pFightStyle]);

    SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, 998);
    SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI, 998); // Skilled, but not dual-wield.

	if(playerVariables[playerid][pPrisonTime] >= 1) {
	    switch(playerVariables[playerid][pPrisonID]) {
			case 1: {
			    SetPlayerPos(playerid, -26.8721, 2320.9290, 24.3034);
				SetPlayerInterior(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
			}
			case 2: {
				SetPlayerPos(playerid, 264.58, 77.38, 1001.04);
				SetPlayerInterior(playerid, 6);
				SetPlayerVirtualWorld(playerid, 0);
			}
			case 3: {

				SetPlayerInterior(playerid, 10);
				SetPlayerVirtualWorld(playerid, GROUP_VIRTUAL_WORLD+1);

				new spawn = random(sizeof(JailSpawns));

				SetPlayerPos(playerid, JailSpawns[spawn][0], JailSpawns[spawn][1], JailSpawns[spawn][2]);
				SetPlayerFacingAngle(playerid, 0);
			}
		}
		return 1;
	}

	if(playerVariables[playerid][pTutorial] == 1) {
		SetPlayerInterior(playerid, 14);
		SetPlayerPos(playerid, 216.9770, -155.4791, 1000.5234);
		SetPlayerFacingAngle(playerid, 267.9681);
		TogglePlayerControllable(playerid, false);
		return 1;
	}

	if(playerVariables[playerid][pHospitalized] >= 1)
	    return initiateHospital(playerid);

	SetPlayerSkin(playerid, playerVariables[playerid][pSkin]);
	SetPlayerPos(playerid, playerVariables[playerid][pPos][0], playerVariables[playerid][pPos][1], playerVariables[playerid][pPos][2]);
	SetPlayerInterior(playerid, playerVariables[playerid][pInterior]);
	SetPlayerVirtualWorld(playerid, playerVariables[playerid][pVirtualWorld]);
	SetCameraBehindPlayer(playerid);

	playerVariables[playerid][pSkinSet] = 1;

	ResetPlayerWeapons(playerid);
	givePlayerWeapons(playerid);

	if(playerVariables[playerid][pEvent] >= 1)
		playerVariables[playerid][pEvent] = 0;

	if(playerVariables[playerid][pAdminDuty] == 1) {
		SetPlayerHealth(playerid, 500000.0);
	}
	else {
		SetPlayerHealth(playerid, playerVariables[playerid][pHealth]);
		SetPlayerArmour(playerid, playerVariables[playerid][pArmour]);
	}

	if(!GetPlayerInterior(playerid)) {
		SetPlayerWeather(playerid, weatherVariables[0]);
	}
	else {
		SetPlayerWeather(playerid, INTERIOR_WEATHER_ID);
	}

	syncPlayerTime(playerid);
	TogglePlayerControllable(playerid, true);

	return 1;
}

public OnPlayerDeath(playerid, killerid, reason) {
	#if defined DEBUG
	    printf("[debug] OnPlayerDeath(%d, %d, %d)", playerid, killerid, reason);
	#endif
	
	// new
	// 	playerNames[2][MAX_PLAYER_NAME];

	// if(playerVariables[playerid][pEvent] >= 1) {
	// 	GetPlayerName(killerid, playerNames[0], MAX_PLAYER_NAME);
	// 	GetPlayerName(playerid, playerNames[1], MAX_PLAYER_NAME);

	// 	// eventVariables[eEventCount]--;

    // 	if(eventVariables[eEventCount] <= 1) {
    // 	    format(szMessage, sizeof(szMessage), "%s has won the event, killing %s with a %s - congratulations!", playerNames[0], playerNames[1], WeaponNames[GetPlayerWeapon(killerid)]);
	// 		SendClientMessageToAll(COLOR_LIGHTRED, szMessage);

	// 		ResetPlayerWeapons(killerid);
	// 		givePlayerWeapons(killerid);

    // 	    SetPlayerPos(killerid, playerVariables[killerid][pPos][0], playerVariables[killerid][pPos][1], playerVariables[killerid][pPos][2]);
	// 		SetPlayerInterior(killerid, playerVariables[killerid][pInterior]);
	// 		SetPlayerVirtualWorld(killerid, playerVariables[killerid][pVirtualWorld]);
	// 		SetPlayerSkin(killerid, playerVariables[killerid][pSkin]);
	// 		SetCameraBehindPlayer(killerid);

	// 		SetPlayerHealth(killerid, playerVariables[killerid][pHealth]);
	// 		SetPlayerArmour(killerid, playerVariables[killerid][pArmour]);

    // 	    SendClientMessage(killerid, COLOR_WHITE, "Congratulations on winning the event!");

	// 		eventVariables[eEventCount] = 0;
	// 		eventVariables[eEventStat] = 0;
	// 		eventVariables[eEventSkin] = 0;
	// 		playerVariables[killerid][pEvent] = 0;
    // 	}
	// 	else {
    // 	    format(szMessage, sizeof(szMessage), "%s has left the event (killed by %s with a %s). %d participants remain.", playerNames[1], playerNames[0], WeaponNames[GetPlayerWeapon(killerid)], eventVariables[eEventCount]);
	// 		SendToEvent(COLOR_YELLOW, szMessage);
	// 	}
	// }
	// else {
	if(playerVariables[playerid][pAdminDuty] == 1) {
		GetPlayerPos(playerid, playerVariables[playerid][pPos][0], playerVariables[playerid][pPos][1], playerVariables[playerid][pPos][2]);
	}
	else playerVariables[playerid][pHospitalized] = 1;
	// }
	return 1;
} 

public OnPlayerDisconnect(playerid, reason) {
	#if defined DEBUG
	    printf("[debug] OnPlayerDisconnect(%d, %d)", playerid, reason);
	#endif
	
	if(playerVariables[playerid][pStatus] == 1) 
	{
        //despawnPlayersVehicles(playerid);
        
	    playerVariables[playerid][pStatus] = -1; // Reset state to disconnected
		foreach(Player, x) 
		{
			if(playerVariables[x][pSpectating] == playerid) 
			{
				playerVariables[x][pSpectating] = INVALID_PLAYER_ID;

				TogglePlayerSpectating(x, false);
				SetCameraBehindPlayer(x);

				SetPlayerPos(x, playerVariables[x][pPos][0], playerVariables[x][pPos][1], playerVariables[x][pPos][2]);
				SetPlayerInterior(x, playerVariables[x][pInterior]);
				SetPlayerVirtualWorld(x, playerVariables[x][pVirtualWorld]);

				TextDrawHideForPlayer(x, textdrawVariables[4]);

				SendClientMessage(x, COLOR_GREY, "The player you were spectating has disconnected.");
			}
		}

		if(playerVariables[playerid][pAdminDuty] >= 1) {
			SetPlayerName(playerid, playerVariables[playerid][pNormalName]);
		}

		if(playerVariables[playerid][pFreezeType] >= 1 && playerVariables[playerid][pFreezeType] <= 4) {
			playerVariables[playerid][pPrisonTime] = 900;
			playerVariables[playerid][pPrisonID] = 2;
		}

		if(playerVariables[playerid][pDrag] != -1) {
			SendClientMessage(playerVariables[playerid][pDrag], COLOR_WHITE, "The person you were dragging has disconnected.");
			playerVariables[playerVariables[playerid][pDrag]][pDrag] = -1; // Kills off any disconnections.
		}
		if(playerVariables[playerid][pPhoneCall] != -1 && playerVariables[playerid][pPhoneCall] < MAX_PLAYERS) {

			SendClientMessage(playerVariables[playerid][pPhoneCall], COLOR_WHITE, "Your call has been terminated by the other party.");

			if(GetPlayerSpecialAction(playerVariables[playerid][pPhoneCall]) == SPECIAL_ACTION_USECELLPHONE) {
				SetPlayerSpecialAction(playerVariables[playerid][pPhoneCall], SPECIAL_ACTION_STOPUSECELLPHONE);
			}

		    playerVariables[playerVariables[playerid][pPhoneCall]][pPhoneCall] = -1;
		}

		savePlayerData(playerid);

		if(playerVariables[playerid][pAdminLevel] < 1) {
			switch(reason) {
				case 1: format(szMessage, sizeof(szMessage), "%s has left the server.", playerVariables[playerid][pNormalName]);
				case 2:	format(szMessage, sizeof(szMessage), "%s has been kicked or banned from the server.", playerVariables[playerid][pNormalName]);
				default: format(szMessage, sizeof(szMessage), "%s has timed out from the server.", playerVariables[playerid][pNormalName]);
			}
			nearByMessage(playerid, COLOR_GENANNOUNCE, szMessage);
		}

		if(playerVariables[playerid][pGroup] >= 1) {
			switch(reason) {
				case 0: {
					format(szMessage, sizeof(szMessage), "%s from your group has disconnected (timeout).", playerVariables[playerid][pNormalName]);
				}
				case 1: {
					format(szMessage, sizeof(szMessage), "%s from your group has disconnected (quit).", playerVariables[playerid][pNormalName]);
				}
				case 2: {
					format(szMessage, sizeof(szMessage), "%s from your group has disconnected (banned/kicked).", playerVariables[playerid][pNormalName]);
				}
			}

			SendToGroup(playerVariables[playerid][pGroup], COLOR_GENANNOUNCE, szMessage);
		}

		// if(playerVariables[playerid][pEvent] >= 1) {
		// 	eventVariables[eEventCount]--;
		// 	playerVariables[playerid][pEvent] = 0;
		// 	ResetPlayerWeapons(playerid);

		// 	if(eventVariables[eEventCount] <= 1) {

		// 		new
		// 			iCount;

		// 		foreach(Player, i) {
		// 			if(playerVariables[i][pEvent] >= 1) {

		// 				TogglePlayerControllable(i, true);

		// 				ResetPlayerWeapons(i);
		// 				givePlayerWeapons(i);

		// 				SetPlayerPos(i, playerVariables[i][pPos][0], playerVariables[i][pPos][1], playerVariables[i][pPos][2]);
		// 				SetPlayerInterior(i, playerVariables[i][pInterior]);
		// 				SetPlayerVirtualWorld(i, playerVariables[i][pVirtualWorld]);
		// 				SetPlayerSkin(i, playerVariables[i][pSkin]);
		// 				SetCameraBehindPlayer(i);

		// 				iCount++;
		// 				GetPlayerName(i, szPlayerName, MAX_PLAYER_NAME);

		// 				SetPlayerHealth(i, playerVariables[i][pHealth]);
		// 				SetPlayerArmour(i, playerVariables[i][pArmour]);
		// 				playerVariables[i][pEvent] = 0;

		// 			}
		// 		}
		// 		if(iCount == 1) {
		// 			format(szMessage, sizeof(szMessage), "%s has won the event by default (after %s disconnected) - congratulations!", szPlayerName, playerVariables[playerid][pNormalName]);
		// 			SendClientMessageToAll(COLOR_LIGHTRED, szMessage);
		// 		}
		// 		else {
		// 			format(szMessage, sizeof(szMessage), "The event has ended (no participants left, %s disconnected).",playerVariables[playerid][pNormalName]);
		// 			SendClientMessageToAll(COLOR_LIGHTRED, szMessage);
		// 		}

		// 		eventVariables[eEventStat] = 0;
		// 		eventVariables[eEventCount] = 0;

		// 		eventVariables[eEventSkin] = 0;
		// 	}
		// 	else {
		// 		switch(reason) {
		// 			case 0: format(szMessage, sizeof(szMessage), "%s has disconnected from the event (timeout). %d participants remain.", playerVariables[playerid][pNormalName], eventVariables[eEventCount]);
		// 			case 1: format(szMessage, sizeof(szMessage), "%s has disconnected from the event (quit). %d participants remain.", playerVariables[playerid][pNormalName], eventVariables[eEventCount]);
		// 			case 2: format(szMessage, sizeof(szMessage), "%s has disconnected from the event (kicked/banned). %d participants remain.", playerVariables[playerid][pNormalName], eventVariables[eEventCount]);
		// 		}
		// 		SendToEvent(COLOR_YELLOW, szMessage);
		// 	}
		// }

		if(playerVariables[playerid][pCarModel] >= 1) {
			DestroyVehicle(playerVariables[playerid][pCarID]);
			systemVariables[vehicleCounts][1]--;
			playerVariables[playerid][pCarID] = -1;
		}
	}
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	#if defined DEBUG
	    printf("[debug] OnPlayerKeyStateChange(%d, %d, %d)", playerid, newkeys, oldkeys);
	#endif
	
	// Disregard any key state changes if the player is frozen and prevent any further code from being executed
	if(playerVariables[playerid][pFreezeType] != 0 && playerVariables[playerid][pFreezeTime] != 0)
	    return 0;
	
	if(IsKeyJustDown(KEY_SUBMISSION, newkeys, oldkeys)) {
	    if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 525) { // For impounding cars.

	        new
				playerTowTruck = GetPlayerVehicleID(playerid);

	        if(!IsTrailerAttachedToVehicle(playerTowTruck)) {
				new
					targetVehicle = GetClosestVehicle(playerid, playerTowTruck); // Exempt the player's own vehicle from the loop.

				if(!IsAPlane(targetVehicle) && IsPlayerInRangeOfVehicle(playerid, targetVehicle, 10.0)) {
					AttachTrailerToVehicle(targetVehicle, playerTowTruck);
				}
	        }
	        else DetachTrailerFromVehicle(playerTowTruck);
	    }
	}
	if(IsKeyJustDown(KEY_FIRE, newkeys, oldkeys)) {
		if(GetPlayerWeapon(playerid) == 17 && !IsPlayerInAnyVehicle(playerid) && playerVariables[playerid][pFreezeType] == 0) {
			foreach(Player, i) {
				if(playerid != i && !IsPlayerInAnyVehicle(i) && playerVariables[i][pFreezeType] == 0 && GetPlayerSkin(i) != 285) {
					if(IsPlayerAimingAtPlayer(playerid, i)) {

						playerVariables[i][pFreezeType] = 5; // Using 5 on FreezeType makes more sense
						playerVariables[i][pFreezeTime] = 10;
						TogglePlayerControllable(i, false);
						SetPlayerDrunkLevel(i, 50000);
						ApplyAnimation(i, "FAT", "IDLE_TIRED", 4.1, 1, 1, 1, 1, 0, 1);
					}
				}
			}
		}
	}
    if(IsKeyJustDown(KEY_WALK, newkeys, oldkeys)) {
		if(playerVariables[playerid][pSpectating] != INVALID_PLAYER_ID && playerVariables[playerid][pAdminLevel] >= 1) {

			playerVariables[playerid][pSpectating] = INVALID_PLAYER_ID;

		    TogglePlayerSpectating(playerid, false);
			SetCameraBehindPlayer(playerid);

		    SetPlayerPos(playerid, playerVariables[playerid][pPos][0], playerVariables[playerid][pPos][1], playerVariables[playerid][pPos][2]);
		    SetPlayerInterior(playerid, playerVariables[playerid][pInterior]);
		    SetPlayerVirtualWorld(playerid, playerVariables[playerid][pVirtualWorld]);

		    TextDrawHideForPlayer(playerid, textdrawVariables[4]);
			return 1;
		}
    }
	if(IsKeyJustDown(KEY_SECONDARY_ATTACK, newkeys, oldkeys)) {
        if(playerVariables[playerid][pTutorial] == 1) {
            playerVariables[playerid][pSkin] = GetPlayerSkin(playerid);

			SendClientMessage(playerid, COLOR_YELLOW, "Great. You've selected your clothes/skin.");

            playerVariables[playerid][pTutorial] = 2;

			SetTimerEx("genderSelection", 1000, false, "d", playerid);

            TextDrawHideForPlayer(playerid, textdrawVariables[2]);
			return 1;
		}
		
		if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] == 1) {
			if(IsPlayerInRangeOfPoint(playerid, 3.0, 232.899703, 109.074996, 1009.211791))
			{
				if(playerVariables[playerid][pGroup] == 1 && playerVariables[playerid][pGroupRank] >= 5) {
					MoveDynamicObject(LSPDObjs[0][0],232.89999390,105.57499695,1009.21179199, 3.5); //commander south
					MoveDynamicObject(LSPDObjs[0][1],232.89941406,112.57499695,1009.21179199, 3.5); //commander north
					LSPDObjs[0][2] = 1;
					PlayerPlaySoundEx(1083, 232.899703, 109.074996, 1009.211791);
					SetTimerEx("ShutUp",4000,false,"d",0);
				}
			}
			else if(IsPlayerInRangeOfPoint(playerid, 3.0, 275.750000, 117.399414, 1003.617187))
			{
				MoveDynamicObject(LSPDObjs[1][0],275.75000000,120.89941406,1003.61718750, 3.5); // interrogation north
				MoveDynamicObject(LSPDObjs[1][1],275.75000000,118.89941406,1003.61718750, 3.5); // interrogation south
				LSPDObjs[1][2] = 1;
				PlayerPlaySoundEx(1083, 275.750000, 117.399414, 1003.617187);
				SetTimerEx("ShutUp",4000,false,"d",1);
			}
			else if(IsPlayerInRangeOfPoint(playerid, 3.0, 253.201660, 109.099609, 1002.220703))
			{
				MoveDynamicObject(LSPDObjs[2][0],253.20410156,105.59960938,1002.22070312,3.5); // north west lobby door
				MoveDynamicObject(LSPDObjs[2][1],253.19921875,112.59960938,1002.22070312,3.5); // north east lobby door
				LSPDObjs[2][2] = 1;
				PlayerPlaySoundEx(1083, 253.201660, 109.099609, 1002.220703);
				SetTimerEx("ShutUp",4000,false,"d",2);
			}
			else if(IsPlayerInRangeOfPoint(playerid, 3.0, 239.566894, 117.599609, 1002.220703))
			{
				MoveDynamicObject(LSPDObjs[3][0],239.56933594,114.09960938,1002.22070312,3.5); // south west lobby door
				MoveDynamicObject(LSPDObjs[3][1],239.56445312,121.09960938,1002.22070312,3.5); // south east lobby door
				LSPDObjs[3][2] = 1;
				PlayerPlaySoundEx(1083, 239.566894, 117.599609, 1002.220703);
				SetTimerEx("ShutUp",4000,false,"d",3);
			}
			else if(IsPlayerInRangeOfPoint(playerid, 2.0, 265.951171, 115.826660, 1003.622863))
			{
				MoveDynamicObject(LSPDObjs[4][0],263.45,115.82421875,1003.62286377,3.5); // cam room
				MoveDynamicObject(LSPDObjs[4][1],268.75,115.82910156,1003.62286377, 3.5); // cam room
				LSPDObjs[4][2] = 1;
				PlayerPlaySoundEx(1083, 265.951171, 115.826660, 1003.622863);
				SetTimerEx("ShutUp",4000,false,"d",4);
			}
			else if(IsPlayerInRangeOfPoint(playerid, 2.0, 265.820007, 112.530761, 1003.622863))
			{
				MoveDynamicObject(LSPDObjs[5][0],268.8,112.53222656,1003.62286377, 3.5); // locker
				MoveDynamicObject(LSPDObjs[5][1],263.3,112.52929688,1003.62286377, 3.5); // locker
				LSPDObjs[5][2] = 1;
				PlayerPlaySoundEx(1083, 265.820007, 112.530761, 1003.622863);
				SetTimerEx("ShutUp",4000,false,"d",5);
			}
			else if(IsPlayerInRangeOfPoint(playerid, 3.0, 231.099609, 119.532226, 1009.224426)) // Chief of Police
			{
				if(playerVariables[playerid][pGroup] == 1 && playerVariables[playerid][pGroupRank] == 6) {
					MoveDynamicObject(LSPDObjs[6][0],227.0,119.52929688,1009.22442627, 3.5);
					MoveDynamicObject(LSPDObjs[6][1],229.75,119.53515625,1009.22442627, 3.5);
					LSPDObjs[6][2] = 1;
					PlayerPlaySoundEx(1083, 231.099609, 119.532226, 1009.224426);
					SetTimerEx("ShutUp",4000,false,"d",6);
				}
			}
			else if(IsPlayerInRangeOfPoint(playerid, 3.0, 217.800003, 116.529647, 998.015625)) // Cells
			{
				MoveDynamicObject(LSPDObjs[7][0],220.5,116.52999878,998.01562500,3.5);
				MoveDynamicObject(LSPDObjs[7][1],215.3,116.52929688,998.01562500,3.5);
				LSPDObjs[7][2] = 1;
				PlayerPlaySoundEx(1083, 217.800003, 116.529647, 998.015625);
				SetTimerEx("ShutUp",4000,false,"d",7);
			}
		}
		if(IsPlayerInRangeOfPoint(playerid,1.0,237.9,115.6,1010.2)) {
			SetPlayerPos(playerid,237.9,115.6,1010.2);
			SetPlayerFacingAngle(playerid, 270);
			ApplyAnimation(playerid, "VENDING", "VEND_Use", 1, 0, 0, 0, 0, 4000);
			SetTimerEx("VendDrink", 2500, false, "d", playerid);
		}
	}
	if(IsKeyJustDown(KEY_CROUCH, newkeys, oldkeys)) {
		for(new x = 0; x < MAX_HOUSES; x++) {
			if(IsPlayerInRangeOfPoint(playerid, 2.0, houseVariables[x][hHouseExteriorPos][0], houseVariables[x][hHouseExteriorPos][1], houseVariables[x][hHouseExteriorPos][2])) {
				if(houseVariables[x][hHouseLocked] == 1) {
					SendClientMessage(playerid, COLOR_GREY, "This house is locked.");
					if(playerVariables[playerid][pAdminLevel] >= 1 && playerVariables[playerid][pAdminDuty] >= 1) {
					    SetPVarInt(playerid, "hE", x); // I'd create a variable for this, but seeing as we'll only ever use this for one thing, this will be better for optimization.
					    ShowPlayerDialog(playerid, DIALOG_HOUSE_ENTER, DIALOG_STYLE_MSGBOX, "SERVER: Housing", "This house is locked.\r\nAs an administrator, you can breach this lock and enter. Would you like to do so?", "Yes", "No");
					}
					else if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] == 1 && playerVariables[playerid][pGroup] != 0) {
					    SetPVarInt(playerid, "hE", x);
					    ShowPlayerDialog(playerid, DIALOG_HOUSE_ENTER, DIALOG_STYLE_MSGBOX, "SERVER: Housing", "This house is locked.\r\nAs a law enforcement officer, you can breach this lock and enter. Would you like to do so?", "Yes", "No");
					}
				}
				else {
					SetPlayerPos(playerid, houseVariables[x][hHouseInteriorPos][0], houseVariables[x][hHouseInteriorPos][1], houseVariables[x][hHouseInteriorPos][2]);
					SetPlayerInterior(playerid, houseVariables[x][hHouseInteriorID]);
					SetPlayerVirtualWorld(playerid, HOUSE_VIRTUAL_WORLD+x);
				}
				return 1;
			}
			if(IsPlayerInRangeOfPoint(playerid, 2.0, houseVariables[x][hHouseInteriorPos][0], houseVariables[x][hHouseInteriorPos][1], houseVariables[x][hHouseInteriorPos][2]) && GetPlayerVirtualWorld(playerid) == HOUSE_VIRTUAL_WORLD+x) {
				SetPlayerPos(playerid, houseVariables[x][hHouseExteriorPos][0], houseVariables[x][hHouseExteriorPos][1], houseVariables[x][hHouseExteriorPos][2]);
				SetPlayerInterior(playerid, houseVariables[x][hHouseExteriorID]);
				SetPlayerVirtualWorld(playerid, 0);
				return 1;
			}
		}
		
		for(new x = 0; x < MAX_ATMS; x++) {
		    if(IsPlayerInRangeOfPoint(playerid, 2.0, atmVariables[x][fATMPos][0], atmVariables[x][fATMPos][1], atmVariables[x][fATMPos][2])) {
				ShowPlayerDialog(playerid, DIALOG_ATM_MENU, DIALOG_STYLE_LIST, "SERVER: Automated Teller Machine", "Check Balance\nWithdraw", "OK", "Cancel");
			}
		}
		
		/* BANK */
		if(IsPlayerInRangeOfPoint(playerid, 2.0, 595.5443,-1250.3405,18.2836)) {
			SetPlayerPos(playerid, 2306.8481,-16.0682,26.7496);
			SetPlayerVirtualWorld(playerid, 2);
		}
		else if(IsPlayerInRangeOfPoint(playerid, 2.0, 2306.8481,-16.0682,26.7496)) {
			SetPlayerPos(playerid, 595.5443,-1250.3405,18.2836);
			SetPlayerVirtualWorld(playerid, 0);
		}
		
		for(new x = 0; x < MAX_BUSINESSES; x++) {
			if(IsPlayerInRangeOfPoint(playerid, 2.0, businessVariables[x][bExteriorPos][0], businessVariables[x][bExteriorPos][1], businessVariables[x][bExteriorPos][2])) {
				if(businessVariables[x][bLocked] == 1) {
					SendClientMessage(playerid, COLOR_GREY, "This business is locked.");
					if(playerVariables[playerid][pAdminLevel] >= 1 && playerVariables[playerid][pAdminDuty] >= 1) {
					    SetPVarInt(playerid, "bE", x); // I'd create a variable for this, but seeing as we'll only ever use this for one thing, this will be better for optimization.
					    ShowPlayerDialog(playerid, DIALOG_BUSINESS_ENTER, DIALOG_STYLE_MSGBOX, "SERVER: Businesses", "{FFFFFF}This business is locked.\r\nAs an "EMBED_GREY"administrator{FFFFFF}, you can breach this lock and enter. Would you like to do so?", "Yes", "No");
					}
					else if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] == 1 && playerVariables[playerid][pGroup] != 0) {
					    SetPVarInt(playerid, "bE", x);
					    ShowPlayerDialog(playerid, DIALOG_BUSINESS_ENTER, DIALOG_STYLE_MSGBOX, "SERVER: Businesses", "{FFFFFF}This business is locked.\r\nAs a "EMBED_GREY"law enforcement officer{FFFFFF}, you can breach this lock and enter. Would you like to do so?", "Yes", "No");
					}
				}
				else {
					businessTypeMessages(x, playerid);

					SetPlayerPos(playerid, businessVariables[x][bInteriorPos][0], businessVariables[x][bInteriorPos][1], businessVariables[x][bInteriorPos][2]);
					SetPlayerInterior(playerid, businessVariables[x][bInterior]);
					SetPlayerVirtualWorld(playerid, BUSINESS_VIRTUAL_WORLD+x);
				}
				return 1;
			}
			if(IsPlayerInRangeOfPoint(playerid, 2.0, businessVariables[x][bInteriorPos][0], businessVariables[x][bInteriorPos][1], businessVariables[x][bInteriorPos][2]) && GetPlayerVirtualWorld(playerid) == BUSINESS_VIRTUAL_WORLD+x) {
				SetPlayerPos(playerid, businessVariables[x][bExteriorPos][0], businessVariables[x][bExteriorPos][1], businessVariables[x][bExteriorPos][2]);
				SetPlayerInterior(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
				return 1;
			}
		}
		for(new x = 0; x < MAX_GROUPS; x++) {
			if(IsPlayerInRangeOfPoint(playerid, 2.0, groupVariables[x][gGroupExteriorPos][0], groupVariables[x][gGroupExteriorPos][1], groupVariables[x][gGroupExteriorPos][2])) {
				if(groupVariables[x][gGroupHQLockStatus] == 1) {
					SendClientMessage(playerid, COLOR_GREY, "This HQ is locked.");
					if(playerVariables[playerid][pAdminLevel] >= 1 && playerVariables[playerid][pAdminDuty] >= 1) {
					    SetPVarInt(playerid, "gE", x); // I'd create a variable for this, but seeing as we'll only ever use this for one thing, this will be better for optimization.
					    ShowPlayerDialog(playerid, DIALOG_GROUP_ENTER, DIALOG_STYLE_MSGBOX, "SERVER: Group HQ", "This Group HQ is locked.\r\nAs an administrator, you can breach this lock and enter. Would you like to do so?", "Yes", "No");
					}
 					else if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] == 1 && playerVariables[playerid][pGroup] != 0) {
					    SetPVarInt(playerid, "gE", x);
					    ShowPlayerDialog(playerid, DIALOG_GROUP_ENTER, DIALOG_STYLE_MSGBOX, "SERVER: Group HQ", "This Group HQ is locked.\r\nAs a law enforcement officer, you can breach this lock and enter. Would you like to do so?", "Yes", "No");
					}
				}
				else {
					SetPlayerPos(playerid, groupVariables[x][gGroupInteriorPos][0], groupVariables[x][gGroupInteriorPos][1], groupVariables[x][gGroupInteriorPos][2]);
					SetPlayerInterior(playerid, groupVariables[x][gGroupHQInteriorID]);
					SetPlayerVirtualWorld(playerid, GROUP_VIRTUAL_WORLD+x);
				}
				return 1;
			}
			if(IsPlayerInRangeOfPoint(playerid, 2.0, groupVariables[x][gGroupInteriorPos][0], groupVariables[x][gGroupInteriorPos][1], groupVariables[x][gGroupInteriorPos][2]) && GetPlayerVirtualWorld(playerid) == GROUP_VIRTUAL_WORLD+x) {
				SetPlayerPos(playerid, groupVariables[x][gGroupExteriorPos][0], groupVariables[x][gGroupExteriorPos][1], groupVariables[x][gGroupExteriorPos][2]);
				SetPlayerInterior(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
				return 1;
			}
		}
	}
	return 1;
} 

public OnVehicleRespray(playerid, vehicleid, color1, color2) {
	#if defined DEBUG
	    printf("[debug] OnVehicleRespray(%d, %d, %d, %d)", playerid, vehicleid, color1, color2);
	#endif

	/* With modifications, we don't need to do this as there's already a GetVehicleComponentInSlot function.
	However, this will save paint if a player who doesn't own the car is driving. */
	SetPVarInt(playerid, "pC", 1);
	foreach(Player, v) {
		if(GetPlayerVehicleID(playerid) == playerVariables[v][pCarID]) {
			playerVariables[v][pCarColour][0] = color1;
			playerVariables[v][pCarColour][1] = color2;
		}
	}
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid) { // No need to deduct money; thanks to SA:MP, OnVehicleRespray is called when a paint job has been applied.
	#if defined DEBUG
	    printf("[debug] OnVehiclePaintjob(%d, %d, %d)", playerid, vehicleid, paintjobid);
	#endif
	
	SetPVarInt(playerid, "pC", 1);
	foreach(Player, v) {
		if(GetPlayerVehicleID(playerid) == playerVariables[v][pCarID]) {
			playerVariables[v][pCarPaintjob] = paintjobid;
		}
	}
}

public OnEnterExitModShop(playerid, enterexit, interiorid) {
	#if defined DEBUG
	    printf("[debug] OnEnterExitModShop(%d, %d, %d)", playerid, enterexit, interiorid);
	#endif

	if(enterexit == 0) {
		if(GetPVarInt(playerid, "pC") == 1) {
			playerVariables[playerid][pMoney] -= 500;
			DeletePVar(playerid, "pC");
		}
		foreach(Player, v) {
			if(GetPlayerVehicleID(playerid) == playerVariables[v][pCarID]) {
				for(new i = 0; i < 13; i++) {
					playerVariables[v][pCarMods][i] = GetVehicleComponentInSlot(playerVariables[v][pCarID], i);
				}
			}
		}
	}
}

public OnVehicleMod(playerid, vehicleid, componentid) {
	#if defined DEBUG
	    printf("[debug] OnVehicleMod(%d, %d, %d)", playerid, vehicleid, componentid);
	#endif
	
	if(GetPlayerInterior(playerid) < 1 && GetPlayerInterior(playerid) > 3 && playerVariables[playerid][pAdminLevel] < 3) {
		GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
		format(szMessage, sizeof(szMessage), "AdmWarn: {FFFFFF}%s may possibly be hacking vehicle mods (added component %d to their %s).", szPlayerName, componentid, VehicleNames[GetVehicleModel(vehicleid) - 400]);
		submitToAdmins(szMessage, COLOR_HOTORANGE);
	}

	else if(GetPlayerInterior(playerid) >= 1 && GetPlayerInterior(playerid) <= 3) {

		switch(componentid) { // Get the price for the vehicle component, only if they're in a mod garage.

			case 1024:												playerVariables[playerid][pMoney] -= 50;
			case 1006:  											playerVariables[playerid][pMoney] -= 80;
			case 1004, 1145, 1013, 1091, 1086:						playerVariables[playerid][pMoney] -= 100;
			case 1005, 1143, 1022, 1035, 1088:						playerVariables[playerid][pMoney] -= 150;
			case 1021, 1009, 1002, 1016, 1068, 1153:				playerVariables[playerid][pMoney] -= 200;
			case 1011:												playerVariables[playerid][pMoney] -= 220;
			case 1012, 1020, 1003, 1067:							playerVariables[playerid][pMoney] -= 250;
			case 1019:												playerVariables[playerid][pMoney] -= 300;
			case 1018, 1023, 1093:									playerVariables[playerid][pMoney] -= 350;
			case 1014, 1000:										playerVariables[playerid][pMoney] -= 400;
			case 1163, 1090, 1070:									playerVariables[playerid][pMoney] -= 450;
			case 1008, 1007, 1017, 1015, 1044, 1043, 1036:		   	playerVariables[playerid][pMoney] -= 500;
			case 1045:												playerVariables[playerid][pMoney] -= 510;
			case 1001, 1158, 1069, 1164:							playerVariables[playerid][pMoney] -= 550;
			case 1050, 1058, 1097:									playerVariables[playerid][pMoney] -= 620;
			case 1162, 1089:										playerVariables[playerid][pMoney] -= 650;
			case 1028, 1085:										playerVariables[playerid][pMoney] -= 770;
			case 1122, 1106, 1108, 1118:							playerVariables[playerid][pMoney] -= 780;
			case 1134:												playerVariables[playerid][pMoney] -= 800;
			case 1082:												playerVariables[playerid][pMoney] -= 820;
			case 1064, 1133:										playerVariables[playerid][pMoney] -= 830;
			case 1165, 1167, 1065:									playerVariables[playerid][pMoney] -= 850;
			case 1175, 1177, 1172, 1080:							playerVariables[playerid][pMoney] -= 900;
			case 1100, 1119, 1192:									playerVariables[playerid][pMoney] -= 940;
			case 1173, 1161, 1166, 1168:							playerVariables[playerid][pMoney] -= 950;
			case 1010, 1149, 1176, 1042, 1136, 1025, 1096, 1174:   	playerVariables[playerid][pMoney] -= 1000;
			case 1155, 1154:										playerVariables[playerid][pMoney] -= 1030;
			case 1160, 1159:										playerVariables[playerid][pMoney] -= 1050;
			case 1150:												playerVariables[playerid][pMoney] -= 1090;
			case 1193, 1073:										playerVariables[playerid][pMoney] -= 1100;
			case 1190, 1078:										playerVariables[playerid][pMoney] -= 1200;
			case 1135, 1087:										playerVariables[playerid][pMoney] -= 1500;
			case 1083, 1076:										playerVariables[playerid][pMoney] -= 1560;
			case 1179, 1184:										playerVariables[playerid][pMoney] -= 2150;
			case 1046:												playerVariables[playerid][pMoney] -= 710;
			case 1152:												playerVariables[playerid][pMoney] -= 910;
			case 1151:												playerVariables[playerid][pMoney] -= 840;
			case 1054:												playerVariables[playerid][pMoney] -= 210;
			case 1053:												playerVariables[playerid][pMoney] -= 130;
			case 1049:												playerVariables[playerid][pMoney] -= 810;
			case 1047:												playerVariables[playerid][pMoney] -= 670;
			case 1048:												playerVariables[playerid][pMoney] -= 530;
			case 1066:												playerVariables[playerid][pMoney] -= 750;
			case 1034:												playerVariables[playerid][pMoney] -= 790;
			case 1037:												playerVariables[playerid][pMoney] -= 690;
			case 1171:												playerVariables[playerid][pMoney] -= 990;
			case 1148:												playerVariables[playerid][pMoney] -= 890;
			case 1038:												playerVariables[playerid][pMoney] -= 190;
			case 1146:												playerVariables[playerid][pMoney] -= 490;
			case 1039:												playerVariables[playerid][pMoney] -= 390;
			case 1059:												playerVariables[playerid][pMoney] -= 720;
			case 1157:												playerVariables[playerid][pMoney] -= 930;
			case 1156:												playerVariables[playerid][pMoney] -= 920;
			case 1055:												playerVariables[playerid][pMoney] -= 230;
			case 1061:												playerVariables[playerid][pMoney] -= 180;
			case 1060:												playerVariables[playerid][pMoney] -= 530;
			case 1056:												playerVariables[playerid][pMoney] -= 520;
			case 1057:												playerVariables[playerid][pMoney] -= 430;
			case 1029:												playerVariables[playerid][pMoney] -= 680;
			case 1169:												playerVariables[playerid][pMoney] -= 970;
			case 1170:												playerVariables[playerid][pMoney] -= 880;
			case 1141:												playerVariables[playerid][pMoney] -= 980;
			case 1140:												playerVariables[playerid][pMoney] -= 870;
			case 1032:												playerVariables[playerid][pMoney] -= 170;
			case 1033:												playerVariables[playerid][pMoney] -= 120;
			case 1138:												playerVariables[playerid][pMoney] -= 580;
			case 1139:												playerVariables[playerid][pMoney] -= 470;
			case 1026:												playerVariables[playerid][pMoney] -= 480;
			case 1031:												playerVariables[playerid][pMoney] -= 370;
			case 1092:												playerVariables[playerid][pMoney] -= 750;
			case 1128:												playerVariables[playerid][pMoney] -= 3340;
			case 1103:												playerVariables[playerid][pMoney] -= 3250;
			case 1183:												playerVariables[playerid][pMoney] -= 2040;
			case 1182:												playerVariables[playerid][pMoney] -= 2130;
			case 1181:												playerVariables[playerid][pMoney] -= 2050;
			case 1104:												playerVariables[playerid][pMoney] -= 1610;
			case 1105:												playerVariables[playerid][pMoney] -= 1540;
			case 1126:												playerVariables[playerid][pMoney] -= 3340;
			case 1127:												playerVariables[playerid][pMoney] -= 3250;
			case 1185:												playerVariables[playerid][pMoney] -= 2040;
			case 1180:												playerVariables[playerid][pMoney] -= 2130;
			case 1178:												playerVariables[playerid][pMoney] -= 2050;
			case 1123:												playerVariables[playerid][pMoney] -= 860;
			case 1125:												playerVariables[playerid][pMoney] -= 1120;
			case 1130:												playerVariables[playerid][pMoney] -= 3380;
			case 1131:												playerVariables[playerid][pMoney] -= 3290;
			case 1189:												playerVariables[playerid][pMoney] -= 2200;
			case 1188:												playerVariables[playerid][pMoney] -= 2080;
			case 1187:												playerVariables[playerid][pMoney] -= 2175;
			case 1186:												playerVariables[playerid][pMoney] -= 2095;
			case 1129:												playerVariables[playerid][pMoney] -= 1650;
			case 1132:												playerVariables[playerid][pMoney] -= 1590;
			case 1113:												playerVariables[playerid][pMoney] -= 3340;
			case 1114:												playerVariables[playerid][pMoney] -= 3250;
			case 1117:												playerVariables[playerid][pMoney] -= 2040;
			case 1115:												playerVariables[playerid][pMoney] -= 2130;
			case 1116:												playerVariables[playerid][pMoney] -= 2050;
			case 1109:												playerVariables[playerid][pMoney] -= 1610;
			case 1110:												playerVariables[playerid][pMoney] -= 1540;
			case 1191:												playerVariables[playerid][pMoney] -= 1040;
			case 1079:												playerVariables[playerid][pMoney] -= 1030;
			case 1075:												playerVariables[playerid][pMoney] -= 980;
			case 1077:												playerVariables[playerid][pMoney] -= 1620;
			case 1074:												playerVariables[playerid][pMoney] -= 1030;
			case 1081:												playerVariables[playerid][pMoney] -= 1230;
			case 1084:												playerVariables[playerid][pMoney] -= 1350;
			case 1098:												playerVariables[playerid][pMoney] -= 1140;
		}
	}
	return 1;
}  

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
	#if defined DEBUG
	    printf("[debug] OnDialogResponse(%d, %d, %d, %d, %s)", playerid, dialogid, response, listitem, inputtext);
	#endif
	
	if(!isnull(inputtext))
		for(new strPos; inputtext[strPos] > 0; strPos++)
			if(inputtext[strPos] == '%')
				inputtext[strPos] = '\0'; // SA-MP placeholder exploit patch

	switch(dialogid) {
	    case DIALOG_GMX: {
	        if(playerVariables[playerid][pAdminLevel] >= 5) {
	            if(!response)
	                return SendClientMessage(playerid, COLOR_GREY, "Restart attempt canned.");

		        SendClientMessage(playerid, COLOR_YELLOW, "---- SERVER RESTART ----");

		        foreach(Player, x) {
					if(playerVariables[x][pAdminDuty] > 0) {
						playerVariables[x][pAdminDuty] = 0;
						SetPlayerName(x, playerVariables[x][pNormalName]);
						SendClientMessage(x, COLOR_WHITE, "A server restart has been initiated; you have been forced off administrative duty to prevent being automatically kicked.");
						SetPlayerHealth(x, 100);
					}

					savePlayerData(x);
				}
				SendClientMessage(playerid, COLOR_GREY, "- Player data saved.");

				for(new xh = 0; xh < MAX_HOUSES; xh++) {
		            saveHouse(xh);
				}
				SendClientMessage(playerid, COLOR_GREY, "- House data saved.");

				for(new xf = 0; xf < MAX_GROUPS; xf++) {
		            saveGroup(xf);
				}
				SendClientMessage(playerid, COLOR_GREY, "- Group data saved.");

				for(new xf = 0; xf < MAX_BUSINESSES; xf++) {
		            saveBusiness(xf);
				}
				SendClientMessage(playerid, COLOR_GREY, "- Business data saved.");

				for(new xf = 0; xf < MAX_ASSETS; xf++) {
		            saveAsset(xf);
				}
				SendClientMessage(playerid, COLOR_GREY, "- Server asset data saved."); 

				SendClientMessage(playerid, COLOR_WHITE, "Restarting timer activated.");

				iGMXTick = 6;
				iGMXTimer = SetTimer("restartTimer", 1000, true);

				SendClientMessage(playerid, COLOR_YELLOW, "---- SERVER RESTART ----");
	        }
	    }
	    case DIALOG_SET_ADMIN_PIN: {
			if(strlen(inputtext) != 4 && strval(inputtext) < 1000 || strval(inputtext) >= 10000)
   				return ShowPlayerDialog(playerid, DIALOG_SET_ADMIN_PIN, DIALOG_STYLE_INPUT, "SERVER: Admin PIN creation", "The system has detected you do not yet have an admin PIN set.\n\nThis is a new compulsory security measure.\n\nPlease set a **four digit** pin:", "OK", "");

			SetPVarInt(playerid, "pAdminPIN", strval(inputtext));
			
			SendClientMessage(playerid, COLOR_GENANNOUNCE, "SERVER:{FFFFFF} Your new admin PIN has been set. Thank you for helping keep the server secure!");
		}
	    case DIALOG_MOBILE_HISTORY: {
	        return cmd_mobile(playerid, "n");
	    }
	    case DIALOG_QUIZ: {
	        switch(listitem) {
				case 0: {
					SetPVarInt(playerid, "quiz", 1);
				    ShowPlayerDialog(playerid, DIALOG_DO_TUTORIAL, DIALOG_STYLE_MSGBOX, "Brilliant!", "You've answered the question successfully.\n\nYou'll be taken to set some character preferences in a few seconds, unless you press 'OK'.", "OK", "");
					SetPVarInt(playerid, "tutt", SetTimerEx("initiateTutorial", 3000, false, "d", playerid));
				}
				case 1, 2, 3: {
				    ShowPlayerDialog(playerid, DIALOG_DO_TUTORIAL, DIALOG_STYLE_MSGBOX, "Bad luck!", "You've unfortunately failed to answer the question correctly, therefore you're going to have to watch our basic tutorial. \n\nThis box will disappear and you will partake in the tutorial after choosing your character preferences in a few seconds, unless you press 'OK'.", "OK", "");
                    SetPVarInt(playerid, "tutt", SetTimerEx("initiateTutorial", 3000, false, "d", playerid));
				}
			}
	    }
	    case DIALOG_DO_TUTORIAL: {
	        if(playerVariables[playerid][pTutorial] == 0) {
		        KillTimer(GetPVarInt(playerid, "tutt"));
		        hidePlayerDialog(playerid);

				return initiateTutorial(playerid);
			}
		}
	    case DIALOG_ATM_MENU: {
		    if(!response)
		        return 1;

			// Reset the player's position to revoke the player crouching animation for convenience
			GetPlayerPos(playerid, playerVariables[playerid][pPos][0], playerVariables[playerid][pPos][1], playerVariables[playerid][pPos][2]);
			SetPlayerPos(playerid, playerVariables[playerid][pPos][0], playerVariables[playerid][pPos][1], playerVariables[playerid][pPos][2]);
			    
	        switch(listitem) {
	            case 0: {
					format(szMessage, sizeof(szMessage), "Your bank account balance is currently standing at $%d.", playerVariables[playerid][pBankMoney]);
					ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "SERVER: Automated Teller Machine", szMessage, "OK", "");
				}
	            case 1: {
	                ShowPlayerDialog(playerid, DIALOG_ATM_WITHDRAWAL, DIALOG_STYLE_INPUT, "SERVER: ATM", "Please specify the amount of money that you'd like to withdraw.\n\nYou can withdraw up to $10,000 from this ATM.\n\nNote: This ATM charges $2 from any withdrawals you make.", "OK", "Cancel");
				}
	        }
		}
		case DIALOG_ATM_WITHDRAWAL: {
		    if(!response)
		        return 1;
		        
			new
			    iWithdrawalAmount = strval(inputtext);

			if(playerVariables[playerid][pBankMoney] > iWithdrawalAmount && iWithdrawalAmount > 1 && iWithdrawalAmount < 10000) {
			    playerVariables[playerid][pBankMoney] -= iWithdrawalAmount - 2;
			    playerVariables[playerid][pMoney] += iWithdrawalAmount;
			    ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "SERVER: Automated Teller Machine", "Your money has been withdrawn. \n\nThank you for using our ATM today!", "OK", "");
			} else {
			    SendClientMessage(playerid, COLOR_GREY, "You do not have enough money to withdraw this amount.");
			    ShowPlayerDialog(playerid, DIALOG_ATM_WITHDRAWAL, DIALOG_STYLE_INPUT, "SERVER: ATM", "Please select a value of money that you currently have in your bank account.\n\nPlease specify the amount of money that you'd like to withdraw. \n\nYou can withdraw up to $10,000 from this ATM.\n\nNote: This ATM charges $2 from any withdrawals you make.", "OK", "Cancel");
			}
		}
	    case DIALOG_MOBILE_CONTACTS_MAIN: {
	        switch(listitem) {
				case 0: {
					new
					    szQuery[150];

					format(szQuery, sizeof(szQuery), "SELECT `contactName`, `contactAdded`, `contactAddee` FROM `phonecontacts` WHERE `contactAddee` = %d LIMIT 10", playerVariables[playerid][pPhoneNumber]);
					mysql_query(szQuery, THREAD_MOBILE_LIST_CONTACTS, playerid);
				}
				case 1: return 1;
				case 2: return 1;
			}
	    }
	    case DIALOG_PHONE_MENU: {
	        if(!response)
	            return 1;

	        switch(listitem) {
				case 0: { /* History */
					new
					    szQuery[99];

					format(szQuery, sizeof(szQuery), "SELECT `phoneNumber`, `phoneAction` FROM `phonelogs` WHERE `phoneNumber` = %d LIMIT 5", playerVariables[playerid][pPhoneNumber]);
					mysql_query(szQuery, THREAD_MOBILE_HISTORY, playerid);
				}
				case 1: { /* Contacts */
				    ShowPlayerDialog(playerid, DIALOG_MOBILE_CONTACTS_MAIN, DIALOG_STYLE_LIST, "Mobile Phone: Contacts", "List Contacts\nAdd Contact\nRemove Contact", "Proceed", "Return");
				}
			}
	    }
	    case DIALOG_RP_NAME_CHANGE: { 
	    	new
				charCounts[5];
				
			if(strlen(inputtext) > 20) {
			    SendClientMessage(playerid, COLOR_GREY, "Your name must be less than 20 characters.");
				invalidNameChange(playerid);
			    return 1;
			}
			
			format(szPlayerName, MAX_PLAYER_NAME, "%s", inputtext);

			for(new n; n < MAX_PLAYER_NAME; n++) {
				switch(szPlayerName[n]) {
					case '[', ']', '.', '$', '(', ')', '@', '=': charCounts[1]++;
					case '_': charCounts[0]++;
					case '0' .. '9': charCounts[2]++;
					case 'a' .. 'z': charCounts[3]++;
					case 'A' .. 'Z': charCounts[4]++;
				}
			}
			if(charCounts[0] == 0 || charCounts[0] >= 3) {
				SendClientMessage(playerid, COLOR_GREY, "Your name is not valid. {FFFFFF}Please use an underscore and a first/last name (i.e. Mark_Edwards).");
				invalidNameChange(playerid);
			}
			else if(charCounts[1] >= 1) {
				SendClientMessage(playerid, COLOR_GREY, "Your name is not valid, as it contains symbols. {FFFFFF}Please use a roleplay name.");
				invalidNameChange(playerid);
			}
			else if(charCounts[2] >= 1) {
				SendClientMessage(playerid, COLOR_GREY, "Your name is not valid, as it contains numbers. {FFFFFF}Please use a roleplay name.");
				invalidNameChange(playerid);
			}
			else if(charCounts[3] == strlen(inputtext) - 1) {
				SendClientMessage(playerid, COLOR_GREY, "Your name is not valid, as it is lower case. {FFFFFF}Please use a roleplay name (i.e. Dave_Meniketti).");
				invalidNameChange(playerid);
			}
			else if(charCounts[4] == strlen(inputtext) - 1) {
				SendClientMessage(playerid, COLOR_GREY, "Your name is not valid, as it is upper case. {FFFFFF}Please use a roleplay name (i.e. Dave_Jones).");
				invalidNameChange(playerid);
			}
			else {
			    mysql_real_escape_string(inputtext, playerVariables[playerid][pNormalName]);
			    SetPlayerName(playerid, playerVariables[playerid][pNormalName]);

				format(szQueryOutput, sizeof(szQueryOutput), "SELECT `playerName` FROM `playeraccounts` WHERE `playerName` = '%s'", playerVariables[playerid][pNormalName]);
			    mysql_query(szQueryOutput, THREAD_CHECK_ACCOUNT_USERNAME, playerid);
			}
		}
	    case DIALOG_LICENSE_PLATE: {
			if(strfind(inputtext, " ", true, 0) == -1)
			    return ShowPlayerDialog(playerid, DIALOG_LICENSE_PLATE, DIALOG_STYLE_INPUT, "License plate registration", "{FFFFFF}ERROR:"EMBED_GREY" Your license plate didn't contain a space.{FFFFFF}\n\nPlease enter a license plate for your vehicle. \n\nThere is only two conditions:\n- The license plate must be unique\n- The license plate can be alphanumerical, but it must consist of only 7 characters and include one space.", "Select", "");

			if(strfind(inputtext, "[", true, 0) != -1 || strfind(inputtext, "]", true, 0) != -1 || strfind(inputtext, ".", true, 0) != -1 || strfind(inputtext, "$", true, 0) != -1 || strfind(inputtext, "(", true, 0) != -1 || strfind(inputtext, ")", true, 0) != -1 || strfind(inputtext, "=", true, 0) != -1 || strfind(inputtext, "@", true, 0) != -1)
			return ShowPlayerDialog(playerid, DIALOG_LICENSE_PLATE, DIALOG_STYLE_INPUT, "License plate registration", "{FFFFFF}ERROR:"EMBED_GREY" Your license plate contained non-alphanumerical characters.{FFFFFF}\n\nPlease enter a license plate for your vehicle. \n\nThere is only two conditions:\n- The license plate must be unique\n- The license plate can be alphanumerical, but it must consist of only 7 characters and include one space.", "Select", "");

			if(strlen(inputtext) != 7)
			    return ShowPlayerDialog(playerid, DIALOG_LICENSE_PLATE, DIALOG_STYLE_INPUT, "License plate registration", "{FFFFFF}ERROR:"EMBED_GREY" Your license plate must be 7 characters in length.{FFFFFF}\n\nPlease enter a license plate for your vehicle. \n\nThere is only two conditions:\n- The license plate must be unique\n- The license plate can be alphanumerical, but it must consist of only 7 characters and include one space.", "Select", "");

			new
			    szEscapedPlate[32],
			    szQuery[122];

			mysql_real_escape_string(inputtext, szEscapedPlate);
			SetPVarString(playerid, "plate", szEscapedPlate);

			format(szQuery, sizeof(szQuery), "SELECT `playerCarLicensePlate` FROM `playeraccounts` WHERE `playerCarLicensePlate` = '%s'", szEscapedPlate);
			mysql_query(szQuery, THREAD_CHECK_PLATES, playerid);
	    }
		case DIALOG_FIGHTSTYLE: if(response) switch(listitem) {
			case 0: {
				if(playerVariables[playerid][pFightStyle] != FIGHT_STYLE_BOXING) {
					if(playerVariables[playerid][pMoney] >= 10000){

						new
							business = GetPlayerVirtualWorld(playerid) - BUSINESS_VIRTUAL_WORLD;

						playerVariables[playerid][pMoney] -= 10000;
						playerVariables[playerid][pFightStyle] = FIGHT_STYLE_BOXING;
						businessVariables[business][bVault] += 10000;
						SendClientMessage(playerid, COLOR_WHITE, "You have successfully purchased this style of fighting.");
						SetPlayerFightingStyle(playerid, playerVariables[playerid][pFightStyle]);
					}
					else SendClientMessage(playerid, COLOR_GREY, "You do not have enough money to purchase this.");
				}
				else SendClientMessage(playerid, COLOR_GREY, "You are already using this style.");
			}
			case 1: {
				if(playerVariables[playerid][pFightStyle] != FIGHT_STYLE_KUNGFU) {
					if(playerVariables[playerid][pMoney] >= 25000){

						new
							business = GetPlayerVirtualWorld(playerid) - BUSINESS_VIRTUAL_WORLD;

						playerVariables[playerid][pMoney] -= 25000;
						playerVariables[playerid][pFightStyle] = FIGHT_STYLE_KUNGFU;
						businessVariables[business][bVault] += 25000;
						SendClientMessage(playerid, COLOR_WHITE, "You have successfully purchased this style of fighting.");
						SetPlayerFightingStyle(playerid, playerVariables[playerid][pFightStyle]);
					}
					else SendClientMessage(playerid, COLOR_GREY, "You do not have enough money to purchase this.");
				}
				else SendClientMessage(playerid, COLOR_GREY, "You are already using this style.");
			}
			case 2: {
				if(playerVariables[playerid][pFightStyle] != FIGHT_STYLE_KNEEHEAD) {
					if(playerVariables[playerid][pMoney] >= 15000){

						new
							business = GetPlayerVirtualWorld(playerid) - BUSINESS_VIRTUAL_WORLD;

						playerVariables[playerid][pMoney] -= 15000;
						playerVariables[playerid][pFightStyle] = FIGHT_STYLE_KNEEHEAD;
						businessVariables[business][bVault] += 15000;
						SendClientMessage(playerid, COLOR_WHITE, "You have successfully purchased this style of fighting.");
						SetPlayerFightingStyle(playerid, playerVariables[playerid][pFightStyle]);
					}
					else SendClientMessage(playerid, COLOR_GREY, "You do not have enough money to purchase this.");
				}
				else SendClientMessage(playerid, COLOR_GREY, "You are already using this style.");
			}
			case 3: {
				if(playerVariables[playerid][pFightStyle] != FIGHT_STYLE_GRABKICK) {
					if(playerVariables[playerid][pMoney] >= 12000){

						new
							business = GetPlayerVirtualWorld(playerid) - BUSINESS_VIRTUAL_WORLD;

						playerVariables[playerid][pMoney] -= 12000;
						playerVariables[playerid][pFightStyle] = FIGHT_STYLE_GRABKICK;
						businessVariables[business][bVault] += 12000;
						SendClientMessage(playerid, COLOR_WHITE, "You have successfully purchased this style of fighting.");
						SetPlayerFightingStyle(playerid, playerVariables[playerid][pFightStyle]);
					}
					else SendClientMessage(playerid, COLOR_GREY, "You do not have enough money to purchase this.");
				}
				else SendClientMessage(playerid, COLOR_GREY, "You are already using this style.");
			}
			case 4: {
				if(playerVariables[playerid][pFightStyle] != FIGHT_STYLE_ELBOW) {
					if(playerVariables[playerid][pMoney] >= 10000){

						new
							business = GetPlayerVirtualWorld(playerid) - BUSINESS_VIRTUAL_WORLD;

						playerVariables[playerid][pMoney] -= 10000;
						playerVariables[playerid][pFightStyle] = FIGHT_STYLE_ELBOW;
						businessVariables[business][bVault] += 10000;
						SendClientMessage(playerid, COLOR_WHITE, "You have successfully purchased this style of fighting.");
						SetPlayerFightingStyle(playerid, playerVariables[playerid][pFightStyle]);
					}
					else SendClientMessage(playerid, COLOR_GREY, "You do not have enough money to purchase this.");
				}
				else SendClientMessage(playerid, COLOR_GREY, "You are already using this style.");
			}
			case 5: {
				if(playerVariables[playerid][pFightStyle] != FIGHT_STYLE_NORMAL) {
					if(playerVariables[playerid][pMoney] >= 5000){

						new
							business = GetPlayerVirtualWorld(playerid) - BUSINESS_VIRTUAL_WORLD;

						playerVariables[playerid][pMoney] -= 5000;
						playerVariables[playerid][pFightStyle] = FIGHT_STYLE_NORMAL;
						businessVariables[business][bVault] += 5000;
						SendClientMessage(playerid, COLOR_WHITE, "You have successfully purchased this style of fighting.");
						SetPlayerFightingStyle(playerid, playerVariables[playerid][pFightStyle]);
					}
					else SendClientMessage(playerid, COLOR_GREY, "You do not have enough money to purchase this.");
				}
				else SendClientMessage(playerid, COLOR_GREY, "You are already using this style.");
			}
		}
		case DIALOG_ADMIN_PIN: {
			if(strlen(inputtext) != 4)
			    return ShowPlayerDialog(playerid, DIALOG_ADMIN_PIN, DIALOG_STYLE_INPUT, "SERVER: Admin authentication verification", "Incorrect PIN!\n\nPlease confirm your admin PIN to continue:", "OK", "Cancel");

			if(strval(inputtext) == GetPVarInt(playerid, "pAdminPIN")) {
			    DeletePVar(playerid, "pAdminFrozen");
			    SendClientMessage(playerid, COLOR_GENANNOUNCE, "SERVER:{FFFFFF} You've entered the correct PIN.");
			    SetPVarInt(playerid, "pAdminPINConfirmed", ADMIN_PIN_TIMEOUT);
			    
			    if(GetPVarType(playerid, "doCmd") != 0 || GetPVarType(playerid, "doCmdParams") != 0) {
			        new
			            szCommand[28],
			            szCommandParams[100];
			            
					GetPVarString(playerid, "doCmd", szCommand, sizeof(szCommand));
					GetPVarString(playerid, "doCmdParams", szCommandParams, sizeof(szCommandParams));
					
					for(new i = 0; i < strlen(szCommand); i++) {
						tolower(szCommand[i]);
					}
					
					format(szMessage, sizeof(szMessage), "cmd_%s", szCommand);
					CallLocalFunction(szMessage, "ds", playerid, szCommandParams);

					DeletePVar(playerid, "doCmd");
					DeletePVar(playerid, "doCmdParams");
			    }
			} else {
				SetPVarInt(playerid, "LA", GetPVarInt(playerid, "LA") + 1);

				if(GetPVarInt(playerid, "LA") > MAX_LOGIN_ATTEMPTS) {
					SendClientMessage(playerid, COLOR_RED, "You have used all available login attempts.");

					GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
					format(szMessage, sizeof(szMessage), "AdmWarn: {FFFFFF}Admin %s has been banned (%d failed 3 admin PIN attempts).", szPlayerName, MAX_LOGIN_ATTEMPTS);
					submitToAdmins(szMessage, COLOR_HOTORANGE);

					scriptBan(playerid, "Maximum admin PIN attempts exceeded.");
					return 1;
				}
			    else {
			    	ShowPlayerDialog(playerid, DIALOG_ADMIN_PIN, DIALOG_STYLE_INPUT, "SERVER: Admin authentication verification", "Incorrect PIN!\n\nThe system has recognised that you have connected with an IP that you've never used before.\n\nPlease confirm your admin PIN to continue:", "OK", "Cancel");
					format(szMessage, sizeof(szMessage), "Incorrect admin PIN. You have %d remaining login attempts left.", MAX_LOGIN_ATTEMPTS - GetPVarInt(playerid, "LA"));
					SendClientMessage(playerid, COLOR_HOTORANGE, szMessage);
					return 1;
				}
			}
		}
		case DIALOG_SELL_FISH: {
		    switch(response) {
				case 1: {
					switch(playerVariables[playerid][pFish]) {
					    case 0: {
					        playerVariables[playerid][pMoney] += 1000;
							SendClientMessage(playerid, COLOR_WHITE, "Congratulations, you have sold your collected fish for $1000.");
					    }
					    case 1: {
					        playerVariables[playerid][pMoney] += 750;
							SendClientMessage(playerid, COLOR_WHITE, "Congratulations, you have sold your collected fish for $750.");
					    }
					    case 2: {
					        playerVariables[playerid][pMoney] += 250;
							SendClientMessage(playerid, COLOR_WHITE, "Congratulations, you have sold your collected fish for $250.");
					    }
					    case 3: {
					        playerVariables[playerid][pMoney] += 900;
							SendClientMessage(playerid, COLOR_WHITE, "Congratulations, you have sold your collected fish for $900.");
					    }
					    case 4: {
					        playerVariables[playerid][pMoney] += 500;
							SendClientMessage(playerid, COLOR_WHITE, "Congratulations, you have sold your collected fish for $500.");
					    }
					}

					playerVariables[playerid][pFish] = -1;
				}
			}
		}
		case DIALOG_BUYCAR: if(response) switch(listitem) {
			case 0: ShowPlayerDialog(playerid, DIALOG_BUYCAR_CRAP, DIALOG_STYLE_LIST, "Vehicle Dealership (Second Hand)", "Blista Compact ($8,000)\nClover ($4,300)\nStallion ($5,700)\nTampa ($3,800)", "Select", "Cancel");
			case 1: ShowPlayerDialog(playerid, DIALOG_BUYCAR_CLASSIC, DIALOG_STYLE_LIST, "Vehicle Dealership (Classic Autos)", "Blade ($22,000)\nRemington ($28,000)\nSavanna ($30,000)\nSlamvan ($32,000)\nTornado ($24,500)\nOceanic ($16,200)\nBroadway ($32,750)", "Select", "Cancel");
			case 2: ShowPlayerDialog(playerid, DIALOG_BUYCAR_SEDAN, DIALOG_STYLE_LIST, "Vehicle Dealership (Sedans)", "Elegant ($34,000)\nPremier ($30,000)\nSentinel ($45,000)\nStretch ($85,000)\nSunrise ($33,000)\nWashington ($38,000)\nMerit ($37,500)\nStafford($135,200)", "Select", "Cancel");
			case 3: ShowPlayerDialog(playerid, DIALOG_BUYCAR_SUV, DIALOG_STYLE_LIST, "Vehicle Dealership (SUVs/Trucks)", "Huntley ($48,000)\nLandstalker ($37,000)\nMesa ($35,000)\nRancher ($43,000)\nSandking ($60,000)\nYosemite ($10,000)", "Select", "Cancel");
			case 4: ShowPlayerDialog(playerid, DIALOG_BUYCAR_BIKE, DIALOG_STYLE_LIST, "Vehicle Dealership (Motorcycles)", "Wayfarer ($15,000)\nFCR-900 ($20,000)\nPCJ-600 ($20,000)\nFreeway ($21,000)", "Select", "Cancel");
			case 5: ShowPlayerDialog(playerid, DIALOG_BUYCAR_MUSCLE, DIALOG_STYLE_LIST, "Vehicle Dealership (Performance Vehicles)", "Banshee ($120,000)\nBuffalo ($57,000)\nComet ($80,000)\nPhoenix ($90,000)\nSultan ($85,000)\nElegy ($54,000)\nAlpha ($51,000)", "Select", "Cancel");
		}
		case DIALOG_BUYCAR_BIKE: if(response) switch (listitem) {

			case 0: PurchaseVehicleFromDealer(playerid, 586, 15000);
			case 1: PurchaseVehicleFromDealer(playerid, 521, 20000);
			case 2: PurchaseVehicleFromDealer(playerid, 461, 20000);
			case 3: PurchaseVehicleFromDealer(playerid, 463, 21000);
		}
		case DIALOG_BUYCAR_CRAP: if(response) switch (listitem) {

			case 0: PurchaseVehicleFromDealer(playerid, 496, 8000);
			case 1: PurchaseVehicleFromDealer(playerid, 542, 4300);
			case 2: PurchaseVehicleFromDealer(playerid, 439, 5700);
			case 3: PurchaseVehicleFromDealer(playerid, 549, 3800);

		}
		case DIALOG_BUYCAR_CLASSIC: if(response) switch (listitem) {

			case 0: PurchaseVehicleFromDealer(playerid, 536, 22000);
			case 1: PurchaseVehicleFromDealer(playerid, 534, 28000);
			case 2: PurchaseVehicleFromDealer(playerid, 567, 30000);
			case 3: PurchaseVehicleFromDealer(playerid, 535, 32000);
			case 4: PurchaseVehicleFromDealer(playerid, 576, 24500);
			case 5: PurchaseVehicleFromDealer(playerid, 467, 16200);
			case 6: PurchaseVehicleFromDealer(playerid, 575, 32750);
		}
		case DIALOG_BUYCAR_SEDAN: if(response) switch(listitem) {

			case 0: PurchaseVehicleFromDealer(playerid, 507, 34000);
			case 1: PurchaseVehicleFromDealer(playerid, 426, 30000);
			case 2: PurchaseVehicleFromDealer(playerid, 405, 45000);
			case 3: PurchaseVehicleFromDealer(playerid, 409, 85000);
			case 4: PurchaseVehicleFromDealer(playerid, 550, 33000);
			case 5: PurchaseVehicleFromDealer(playerid, 421, 38000);
			case 6: PurchaseVehicleFromDealer(playerid, 551, 37000);
			case 7: PurchaseVehicleFromDealer(playerid, 580, 135200);
		}
		case DIALOG_BUYCAR_SUV: if(response) switch(listitem) {

			case 0: PurchaseVehicleFromDealer(playerid, 579, 48000);
			case 1: PurchaseVehicleFromDealer(playerid, 400, 37000);
			case 2: PurchaseVehicleFromDealer(playerid, 500, 35000);
			case 3: PurchaseVehicleFromDealer(playerid, 489, 43000);
			case 4: PurchaseVehicleFromDealer(playerid, 495, 60000);
			case 5: PurchaseVehicleFromDealer(playerid, 554, 10000);
		}
		case DIALOG_BUYCAR_MUSCLE: if(response) switch(listitem) {

			case 0: PurchaseVehicleFromDealer(playerid, 429, 120000);
			case 1: PurchaseVehicleFromDealer(playerid, 402, 57000);
			case 2: PurchaseVehicleFromDealer(playerid, 480, 80000);
			case 3: PurchaseVehicleFromDealer(playerid, 603, 90000);
			case 4: PurchaseVehicleFromDealer(playerid, 560, 85000);
			case 5: PurchaseVehicleFromDealer(playerid, 562, 54000);
			case 6: PurchaseVehicleFromDealer(playerid, 602, 51000);
		}
		case DIALOG_DROPITEM: if(response) {

			new
				string[78];
			GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);

			switch(listitem) {
				case 0: {

					format(string, sizeof(string), "* %s has dropped their materials.", szPlayerName);
					nearByMessage(playerid, COLOR_PURPLE, string);
					SendClientMessage(playerid, COLOR_WHITE, "You have dropped your materials.");

					playerVariables[playerid][pMaterials] = 0;
				}
				case 1: {
					format(string, sizeof(string), "* %s has dropped their phone.", szPlayerName);
					nearByMessage(playerid, COLOR_PURPLE, string);
					SendClientMessage(playerid, COLOR_WHITE, "You have dropped your phone.");

					playerVariables[playerid][pPhoneNumber] = -1;
				}
				case 2: {
					format(string, sizeof(string), "* %s has dropped their walkie talkie.", szPlayerName);
					nearByMessage(playerid, COLOR_PURPLE, string);
					SendClientMessage(playerid, COLOR_WHITE, "You have dropped your walkie talkie.");

					playerVariables[playerid][pWalkieTalkie] = -1;
				}
				case 3: {
					new
						weapon = GetPlayerWeapon(playerid);

					format(string, sizeof(string), "* %s has dropped their %s.", szPlayerName, WeaponNames[weapon]);
					nearByMessage(playerid, COLOR_PURPLE, string);

					format(string, sizeof(string), "You have dropped your %s.", WeaponNames[weapon]);
					SendClientMessage(playerid, COLOR_WHITE, string);

					removePlayerWeapon(playerid, weapon);
				}
			}
		}
		case DIALOG_ELEVATOR3: if(response) switch (listitem) {
			case 0: {
				SetPlayerPos(playerid, 1564.6584,-1670.2607,52.4503);
				SetPlayerInterior(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
			}
			case 1: {
				SetPlayerPos(playerid, 1564.8, -1666.2, 28.3);
				SetPlayerInterior(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
			}
			case 2: {
				SetPlayerPos(playerid, 1568.6676, -1689.9708, 6.2188);
				SetPlayerInterior(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
			}
		}
		case DIALOG_ELEVATOR1: if(response) switch (listitem) {
			case 0: {
				SetPlayerPos(playerid, 1564.6584,-1670.2607,52.4503);
				SetPlayerInterior(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
			}
			case 1: {
				SetPlayerPos(playerid, 276.0980, 122.1232, 1004.6172);
				SetPlayerInterior(playerid, 10);
				SetPlayerVirtualWorld(playerid, GROUP_VIRTUAL_WORLD+1);
			}
			case 2: {
				SetPlayerPos(playerid, 1568.6676, -1689.9708, 6.2188);
				SetPlayerInterior(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
			}
		}
		case DIALOG_ELEVATOR2: if(response) switch (listitem) {
			case 0: {
				SetPlayerPos(playerid, 1564.6584,-1670.2607,52.4503);
				SetPlayerInterior(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
			}
			case 1: {
				SetPlayerPos(playerid, 1564.8, -1666.2, 28.3);
				SetPlayerInterior(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
			}
			case 2: {
				SetPlayerPos(playerid, 276.0980, 122.1232, 1004.6172);
				SetPlayerInterior(playerid, 10);
				SetPlayerVirtualWorld(playerid, GROUP_VIRTUAL_WORLD+1);
			}
		}
		case DIALOG_ELEVATOR4: if(response) switch (listitem) {
			case 0: {
				SetPlayerPos(playerid, 1564.8, -1666.2, 28.3);
				SetPlayerInterior(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
			}
			case 1: {
				SetPlayerPos(playerid, 276.0980, 122.1232, 1004.6172);
				SetPlayerInterior(playerid, 10);
				SetPlayerVirtualWorld(playerid, GROUP_VIRTUAL_WORLD+1);
			}
			case 2: {
				SetPlayerPos(playerid, 1568.6676, -1689.9708, 6.2188);
				SetPlayerInterior(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
			}
		}
		case DIALOG_GO6: {
		    if(response) switch(listitem) {
		        case 0: {
		            SetPlayerVirtualWorld(playerid, 0);
		            SetPlayerInterior(playerid, 5);
		            SetPlayerPos(playerid, 772.111999, -3.898649, 1000.728820);
		        }
		        case 1: {
           			SetPlayerVirtualWorld(playerid, 0);
		            SetPlayerInterior(playerid, 6);
		            SetPlayerPos(playerid, 774.213989, -48.924297, 1000.585937);
		        }
		        case 2: {
		            SetPlayerVirtualWorld(playerid, 0);
		            SetPlayerInterior(playerid, 7);
		            SetPlayerPos(playerid, 773.579956, -77.096694, 1000.655029);
		        }
		    }
		}
		case DIALOG_GO5: {
			if(response) switch(listitem) {
					case 0: {
					   	SetPlayerVirtualWorld(playerid, 0);
					    SetPlayerInterior(playerid, 10);
					    SetPlayerPos(playerid, -975.975708, 1060.983032, 1345.671875);
					}
					case 1: {
					   	SetPlayerVirtualWorld(playerid, 0);
					    SetPlayerInterior(playerid, 0);
						SetPlayerPos(playerid, 223.431976, 1872.400268, 13.734375);
					}
					case 2: {
						SetPlayerVirtualWorld(playerid, 0);
					    SetPlayerInterior(playerid, 1);
					    SetPlayerPos(playerid, 1412.639892, -1.787510, 1000.924377);
			     	}
					case 3: {
						SetPlayerVirtualWorld(playerid, 0);
					    SetPlayerInterior(playerid, 18);
					    SetPlayerPos(playerid, 1302.519897, -1.787510, 1001.028259);
					}
					case 4: {
						SetPlayerVirtualWorld(playerid, 0);
					    SetPlayerInterior(playerid, 1);
					    SetPlayerPos(playerid, 963.418762, 2108.292480, 1011.030273);
					}
					case 5: {
						SetPlayerVirtualWorld(playerid, 0);
					    SetPlayerInterior(playerid, 17);
					    SetPlayerPos(playerid, -959.564392, 1848.576782, 9.000000);
					}
				}
			}
			case DIALOG_GO4: {
			    if(response) switch(listitem) {
			        case 0: {
			            SetPlayerVirtualWorld(playerid, 0);
			            SetPlayerInterior(playerid, 0);
			            SetPlayerPos(playerid, 595.5443,-1250.3405,18.2836);
			        }
			        case 1: {
			            SetPlayerVirtualWorld(playerid, 0);
			            SetPlayerInterior(playerid, 0);
			            SetPlayerPos(playerid, 2222.6714, -1724.8436, 13.5625);
			        }
			        case 2: {
			            SetPlayerVirtualWorld(playerid, 0);
			            SetPlayerInterior(playerid, 0);
			            SetPlayerPos(playerid, 1172.359985, -1323.313110, 15.402919);
			        }
			        case 3: {
			            SetPlayerVirtualWorld(playerid, 0);
			            SetPlayerInterior(playerid, 0);
			            SetPlayerPos(playerid, 2034.196166, -1402.591430, 17.295030);
			        }
			        case 4: {
			            SetPlayerVirtualWorld(playerid, 0);
			            SetPlayerInterior(playerid, 0);
			            SetPlayerPos(playerid, 738.9963, -1417.2211, 13.5234);
			        }
			    }
			}
			case DIALOG_GO3: {
			    if(response) switch(listitem) {
			        case 0: {
			            SetPlayerVirtualWorld(playerid, 0);
			            SetPlayerInterior(playerid, 0);
			            SetPlayerPos(playerid, 1550.2311, -1675.4509, 15.3155);
			        }
			        case 1: {
			            SetPlayerVirtualWorld(playerid, 0);
			            SetPlayerInterior(playerid, 0);
			            SetPlayerPos(playerid, -1641.9742, 431.1623, 7.1102);
			        }
			        case 2: {
			            SetPlayerVirtualWorld(playerid, 0);
			            SetPlayerInterior(playerid, 0);
			            SetPlayerPos(playerid, 1699.2, 1435.1, 10.7);
			        }
			    }
			}
			case DIALOG_GO2: {
			    if(response) switch(listitem) {
			        case 0: {
			            SetPlayerVirtualWorld(playerid, 0);
			            SetPlayerInterior(playerid, 4);
			            SetPlayerPos(playerid, -1444.645507, -664.526000, 1053.572998);
			        }
			        case 1: {
			            SetPlayerVirtualWorld(playerid, 0);
			            SetPlayerInterior(playerid, 1);
			            SetPlayerPos(playerid, -1401.829956, 107.051300, 1032.273437);
			        }
			        case 2: {
			            SetPlayerVirtualWorld(playerid, 0);
			            SetPlayerInterior(playerid, 15);
			            SetPlayerPos(playerid, -1398.103515, 937.631164, 1036.479125);
			        }
			        case 3: {
			            SetPlayerVirtualWorld(playerid, 0);
			            SetPlayerInterior(playerid, 7);
			            SetPlayerPos(playerid, -1398.065307, -217.028900, 1051.115844);
			        }
			        case 4: {
			            SetPlayerVirtualWorld(playerid, 0);
			            SetPlayerInterior(playerid, 14);
			            SetPlayerPos(playerid, -1465.268676, 1557.868286, 1052.531250);
			        }
			    }
			}
			case DIALOG_GO1: {
			    if(response) switch(listitem) {
			        case 0: {
			            SetPlayerVirtualWorld(playerid, 0);
			            SetPlayerInterior(playerid, 5);
			            SetPlayerPos(playerid, 1267.663208, -781.323242, 1091.906250);
			        }
			        case 1: {
			            SetPlayerVirtualWorld(playerid, 0);
			            SetPlayerInterior(playerid, 3);
			            SetPlayerPos(playerid, 2496.049804, -1695.238159, 1014.742187);
			        }
			        case 2: {
			            SetPlayerVirtualWorld(playerid, 0);
			            SetPlayerInterior(playerid, 2);
			            SetPlayerPos(playerid, 2454.717041, -1700.871582, 1013.515197);
			        }
			        case 3: {
			            SetPlayerVirtualWorld(playerid, 0);
			            SetPlayerInterior(playerid, 3);
			            SetPlayerPos(playerid, 964.106994, -53.205497, 1001.124572);
			        }
			        case 4: {
			            SetPlayerVirtualWorld(playerid, 0);
			            SetPlayerInterior(playerid, 8);
			            SetPlayerPos(playerid, 2807.619873, -1171.899902, 1025.570312);
			        }
			        case 5: {
			            SetPlayerVirtualWorld(playerid, 0);
			            SetPlayerInterior(playerid, 5);
			            SetPlayerPos(playerid, 318.564971, 1118.209960, 1083.882812);
			        }
			        case 6: {
			            SetPlayerVirtualWorld(playerid, 0);
			            SetPlayerInterior(playerid, 1);
			            SetPlayerPos(playerid, 244.411987, 305.032989, 999.148437);
			        }
			        case 7: {
			            SetPlayerVirtualWorld(playerid, 0);
			            SetPlayerInterior(playerid, 2);
			            SetPlayerPos(playerid, 271.884979, 306.631988, 999.148437);
			        }
			    }
			}
			case DIALOG_GO: {
		        if(response) switch(listitem) {
		            case 0: ShowPlayerDialog(playerid, DIALOG_GO1, DIALOG_STYLE_LIST, "SERVER: House Interiors", "Madd Doggs'\nCJ's House\nRyder's House\nTiger Skin Brothel\nColonel Fuhrberger's\nCrack Den\nDenise's Room\nKatie's Room", "Select", "Cancel");
		            case 1: ShowPlayerDialog(playerid, DIALOG_GO2, DIALOG_STYLE_LIST, "SERVER: Race Tracks", "Dirt Track\nVice Stadium\nBloodbowl Stadium\n8-Track Stadium\nKickstart Stadium", "Select", "Cancel");
		            case 2: ShowPlayerDialog(playerid, DIALOG_GO3, DIALOG_STYLE_LIST, "SERVER: City Locations", "Los Santos\nSan Fierro\nLas Venturas", "Select", "Cancel");
		            case 3: ShowPlayerDialog(playerid, DIALOG_GO4, DIALOG_STYLE_LIST, "SERVER: Popular Locations", "Bank (exterior)\nGym (exterior)\nAll Saints Hospital\nCounty General Hospital\nNewbie Spawn\n", "Select", "Cancel");
		            case 4: ShowPlayerDialog(playerid, DIALOG_GO6, DIALOG_STYLE_LIST, "SERVER: Gym Interiors", "Ganton Gym (LS)\nCobra Martial Arts (SF)\nBelow the Belt Gym (LV)", "Select", "Cancel");
		            case 5: ShowPlayerDialog(playerid, DIALOG_GO5, DIALOG_STYLE_LIST, "SERVER: Other Locations", "RC Battlefield\nArea 69\nWarehouse 1\nWarehouse 2\nMeat Factory\nSherman Dam\n", "Select", "Cancel");
		        }
			}
			case DIALOG_HELP: {
				if(response) switch(listitem) {
					case 0: ShowPlayerDialog(playerid, DIALOG_HELP2, DIALOG_STYLE_MSGBOX, "SERVER: General Commands", "/stats /connections /pay /accept /drag /detain /eject /dropcar /killcheckpoint /give /eject /tie /helpme /ringbell /ad /seepms /kill \n/frisk /detain /admins /time /seeooc /seenewbie /giveweapon /givearmour /drop /joinevent /quitevent","Return","Exit");
					case 1: ShowPlayerDialog(playerid, DIALOG_HELP2, DIALOG_STYLE_MSGBOX, "SERVER: Chat Commands", "/o (global OOC message)\r\n/n (newbie chat message)\n/pm (OOCly PM another player)r\n/b (local OOC message)\r\n/w(hisper)\r\n/low (quiet message)\r\n/me (action)\r\n/do (action)\r\n/wt (walkie talkie)","Return","Exit");
					case 2: {
						if(playerVariables[playerid][pGroup] == 0) return ShowPlayerDialog(playerid, DIALOG_HELP2, DIALOG_STYLE_MSGBOX, "SERVER: Group Commands", "You're not in a group.","Return","Exit");
						switch(groupVariables[playerVariables[playerid][pGroup]][gGroupType]) {
							case 0: switch(playerVariables[playerid][pGroupRank]) {
									case 5: ShowPlayerDialog(playerid, DIALOG_HELP2, DIALOG_STYLE_MSGBOX, "SERVER: Group Commands", "/g /gdeposit /gwithdraw /showmotd /invite /uninvite /changerank /gwithdraw /gdeposit /gmotd /lockhq /listmygroup","Return","Exit");
									case 6: ShowPlayerDialog(playerid, DIALOG_HELP2, DIALOG_STYLE_MSGBOX, "SERVER: Group Commands", "/g /gdeposit /gwithdraw /showmotd /invite /uninvite /changerank /gwithdraw /gdeposit /gmotd /lockhq /listmygroup \n/granknames /gname /gsafepos","Return","Exit");
									default: ShowPlayerDialog(playerid, DIALOG_HELP2, DIALOG_STYLE_MSGBOX, "SERVER: Group Commands", "/g /gdeposit /showmotd","Return","Exit");
								}
							case 1: { // LSPD
								switch(playerVariables[playerid][pGroupRank]) {
									case 4: ShowPlayerDialog(playerid, DIALOG_HELP2, DIALOG_STYLE_MSGBOX, "SERVER: Group Commands", "/r /d /m /su /wanted /fingerprint /ticket /cuff /uncuff /tazer /lspd /showmotd /gdeposit /backup /cancelbackup /acceptbackup /confiscate /deployspike /destroyspike\n/listmygroup /swatinv /spikes","Return","Exit");
									case 5: ShowPlayerDialog(playerid, DIALOG_HELP2, DIALOG_STYLE_MSGBOX, "SERVER: Group Commands", "/r /d /m /su /wanted /fingerprint /ticket /cuff /uncuff /tazer /lspd /showmotd /gdeposit /backup /cancelbackup /acceptbackup /confiscate /deployspike /destroyspike\n/gwithdraw /listmygroup /swatinv /spikes /invite /uninvite /changerank /gwithdraw /gmotd /lockhq /gov","Return","Exit");
									case 6: ShowPlayerDialog(playerid, DIALOG_HELP2, DIALOG_STYLE_MSGBOX, "SERVER: Group Commands", "/r /d /m /su /wanted /fingerprint /ticket /cuff /uncuff /tazer /lspd /showmotd /gdeposit /backup /cancelbackup /acceptbackup /confiscate /deployspike /destroyspike\n/gwithdraw /listmygroup /swatinv /spikes /invite /uninvite /changerank /gwithdraw /gmotd /lockhq /gov /granknames /gname /gsafepos","Return","Exit");
									default: ShowPlayerDialog(playerid, DIALOG_HELP2, DIALOG_STYLE_MSGBOX, "SERVER: Group Commands", "/r /d /m /su /wanted /fingerprint /ticket /cuff /uncuff /tazer /lspd /showmotd /gdeposit /backup /cancelbackup /acceptbackup /confiscate /deployspike /destroyspike","Return","Exit");
								}
							}
							case 2: { // GOVERNMENT
								switch(playerVariables[playerid][pGroupRank]) {
									case 6: ShowPlayerDialog(playerid, DIALOG_HELP2, DIALOG_STYLE_MSGBOX, "SERVER: Group Commands", "/r /d /showmotd /gdeposit /gwithdraw /listmygroup /invite /uninvite /changerank /gmotd /granknames /gname /lockhq /taxrate /gsafepos","Return","Exit");
								}
							}
						}
					}
					case 3: {
						ShowPlayerDialog(playerid, DIALOG_HELP2, DIALOG_STYLE_MSGBOX, "SERVER: Animation Commands",
						"\
						/handsup /drunk /bomb /rob /laugh /lookout /robman /crossarms /sit /siteat /hide /vomit /eat\n\
						/wave /slapass /deal /taichi /crack /smoke /chat /dance /finger /taichi /drinkwater /pedmove /bat\n\
						/checktime /sleep /blob /opendoor /wavedown /reload /cpr /dive /showoff /box /tag /salute\n\
						/goggles /cry /dj /cheer /throw /robbed /hurt /nobreath /bar /getjiggy /fallover /rap /piss\n\
						/crabs /handwash /signal /stop /gesture /masturbate","Return","Exit");
					}
					case 4: ShowPlayerDialog(playerid, DIALOG_HELP2, DIALOG_STYLE_MSGBOX, "SERVER: House Commands", "/home /buyhouse /sellhouse /lockhouse /hgetweapon /hstoreweapon /hwithdraw /hdeposit /changeclothes", "Return","Exit");
					case 5: switch(jobVariables[playerVariables[playerid][pJob]][jJobType]) {
						case 1: ShowPlayerDialog(playerid, DIALOG_HELP2, DIALOG_STYLE_MSGBOX, "SERVER: Job Commands (Arms Dealer)", "/creategun /giveweapon /getmats","Return","Exit");
						case 2: ShowPlayerDialog(playerid, DIALOG_HELP2, DIALOG_STYLE_MSGBOX, "SERVER: Job Commands (Detective)", "/track /trackcar /trackplates /trackhouse /trackbusiness","Return","Exit");
						case 3: ShowPlayerDialog(playerid, DIALOG_HELP2, DIALOG_STYLE_MSGBOX, "SERVER: Job Commands (Mechanic)", "/fixcar /noscar /colourcar /hydcar","Return","Exit");
						case 4: ShowPlayerDialog(playerid, DIALOG_HELP2, DIALOG_STYLE_MSGBOX, "SERVER: Job Commands (Fisherman)", "/fish","Return","Exit");
						default: ShowPlayerDialog(playerid, DIALOG_HELP2, DIALOG_STYLE_MSGBOX, "SERVER: Job Commands", "You don't have a public job.","Return","Exit");
					}
					case 6: ShowPlayerDialog(playerid, DIALOG_HELP2, DIALOG_STYLE_MSGBOX, "SERVER: Business Commands", "/business /lockbusiness /buybusiness /bwithdraw /businessname /bbalance /buy /sellbusiness /bspawnpos", "Return","Exit");
					case 7: {
					    if(playerVariables[playerid][pHelper] >= 1) ShowPlayerDialog(playerid, DIALOG_HELP2, DIALOG_STYLE_MSGBOX, "SERVER: Helper Commands", "/he /nmute /helperduty /accepthelp /viewhelp", "Return","Exit");
						else SendClientMessage(playerid, COLOR_GREY, "You aren't an official helper.");
					}
					case 8: ShowPlayerDialog(playerid, DIALOG_HELP2, DIALOG_STYLE_MSGBOX, "SERVER: Vehicle Commands", "/findcar /abandoncar /lockcar /givecar /unmodcar /vbalance /vstoreweapon /vgetweapon /vdeposit /vwithdraw", "Return","Exit");
					case 9: ShowPlayerDialog(playerid, DIALOG_HELP2, DIALOG_STYLE_MSGBOX, "SERVER: Bank Commands", "/wiretransfer /deposit /balance /withdraw", "Return","Exit");
				}
			}
			case DIALOG_GENDER_SELECTION: {
				switch(response) {
					case 1: {
						SendClientMessage(playerid, COLOR_YELLOW, "Great. We now know that you're a man.");
						playerVariables[playerid][pGender] = 1;
						playerVariables[playerid][pTutorial] = 3;
					}
					case 0: {
					    SendClientMessage(playerid, COLOR_YELLOW, "Great. We now know that you're a woman.");
					    playerVariables[playerid][pGender] = 2;
					    playerVariables[playerid][pTutorial] = 3;
					}
				}

				ShowPlayerDialog(playerid, DIALOG_TUTORIAL_DOB, DIALOG_STYLE_INPUT, "SERVER: Character Age", "Please enter the age of your character.", "Proceed", "Cancel");
			}
			case DIALOG_SEX_SHOP: {
			    if(!response)
					return 1;

				listitem += 1;

			    new
			        i,
			        b,
			        businessID = GetPlayerVirtualWorld(playerid)-BUSINESS_VIRTUAL_WORLD;

		        for(new x = 0; x < MAX_BUSINESS_ITEMS; x++) {
		            b++;
		            format(szSmallString, sizeof(szSmallString), "menuItem%d", x);
		            if(GetPVarType(playerid, szSmallString) != 0)
		                i = GetPVarInt(playerid, szSmallString);

					if(b == listitem) {
					    for(new xf = 0; xf < MAX_BUSINESS_ITEMS; xf++) {
				            format(szSmallString, sizeof(szSmallString), "menuItem%d", xf);
				            if(GetPVarType(playerid, szSmallString) != 0)
				                DeletePVar(playerid, szSmallString);
							else
							    break;
					    }

					    break;
					}
				}

                switch(businessItems[i][bItemType]) {
	                case 9: {
						if(playerVariables[playerid][pMoney] >= businessItems[i][bItemPrice]) {
							playerVariables[playerid][pMoney] -= businessItems[i][bItemPrice];
	                        businessVariables[businessID][bVault] += businessItems[i][bItemPrice];

							givePlayerValidWeapon(playerid, 10);

							switch(random(4)) {
								case 0: format(szMessage, sizeof(szMessage), "You've purchased the %s. Don't get too wild.", businessItems[i][bItemName]);
								case 1: format(szMessage, sizeof(szMessage), "You've purchased the %s. Don't blame us if you get it stuck up there!", businessItems[i][bItemName]);
								case 2: format(szMessage, sizeof(szMessage), "You've purchased the %s. There's no warranty for this product!", businessItems[i][bItemName]);
								case 3: format(szMessage, sizeof(szMessage), "You've purchased the %s. Justin Bieber approves of this.", businessItems[i][bItemName]);
							}
							
                            SendClientMessage(playerid, COLOR_WHITE, szMessage);
                            return 1;
	                    } else return SendClientMessage(playerid, COLOR_GREY, "You don't have enough money to purchase this product.");
					}
	                case 10: {
						if(playerVariables[playerid][pMoney] >= businessItems[i][bItemPrice]) {
							playerVariables[playerid][pMoney] -= businessItems[i][bItemPrice];
	                        businessVariables[businessID][bVault] += businessItems[i][bItemPrice];

							givePlayerValidWeapon(playerid, 11);

							switch(random(4)) {
								case 0: format(szMessage, sizeof(szMessage), "You've purchased the %s. Don't get too wild.", businessItems[i][bItemName]);
								case 1: format(szMessage, sizeof(szMessage), "You've purchased the %s. Don't blame us if you get it stuck up there!", businessItems[i][bItemName]);
								case 2: format(szMessage, sizeof(szMessage), "You've purchased the %s. There's no warranty for this product!", businessItems[i][bItemName]);
								case 3: format(szMessage, sizeof(szMessage), "You've purchased the %s. Justin Bieber approves of this.", businessItems[i][bItemName]);
							}

                            SendClientMessage(playerid, COLOR_WHITE, szMessage);
                            return 1;
	                    } else return SendClientMessage(playerid, COLOR_GREY, "You don't have enough money to purchase this product.");
					}
	                case 11: {
						if(playerVariables[playerid][pMoney] >= businessItems[i][bItemPrice]) {
							playerVariables[playerid][pMoney] -= businessItems[i][bItemPrice];
	                        businessVariables[businessID][bVault] += businessItems[i][bItemPrice];

							givePlayerValidWeapon(playerid, 12);

							switch(random(4)) {
								case 0: format(szMessage, sizeof(szMessage), "You've purchased the %s. Don't get too wild.", businessItems[i][bItemName]);
								case 1: format(szMessage, sizeof(szMessage), "You've purchased the %s. Don't blame us if you get it stuck up there!", businessItems[i][bItemName]);
								case 2: format(szMessage, sizeof(szMessage), "You've purchased the %s. There's no warranty for this product!", businessItems[i][bItemName]);
								case 3: format(szMessage, sizeof(szMessage), "You've purchased the %s. Justin Bieber approves of this.", businessItems[i][bItemName]);
							}

                            SendClientMessage(playerid, COLOR_WHITE, szMessage);
                            return 1;
	                    } else return SendClientMessage(playerid, COLOR_GREY, "You don't have enough money to purchase this product.");
					}
	                case 12: {
						if(playerVariables[playerid][pMoney] >= businessItems[i][bItemPrice]) {
							playerVariables[playerid][pMoney] -= businessItems[i][bItemPrice];
	                        businessVariables[businessID][bVault] += businessItems[i][bItemPrice];

							givePlayerValidWeapon(playerid, 13);

							switch(random(4)) {
								case 0: format(szMessage, sizeof(szMessage), "You've purchased the %s. Don't get too wild.", businessItems[i][bItemName]);
								case 1: format(szMessage, sizeof(szMessage), "You've purchased the %s. Don't blame us if you get it stuck up there!", businessItems[i][bItemName]);
								case 2: format(szMessage, sizeof(szMessage), "You've purchased the %s. There's no warranty for this product!", businessItems[i][bItemName]);
								case 3: format(szMessage, sizeof(szMessage), "You've purchased the %s. Justin Bieber approves of this.", businessItems[i][bItemName]);
							}

                            SendClientMessage(playerid, COLOR_WHITE, szMessage);
                            return 1;
	                    } else return SendClientMessage(playerid, COLOR_GREY, "You don't have enough money to purchase this product.");
					}
	                case 13: {
						if(playerVariables[playerid][pMoney] >= businessItems[i][bItemPrice]) {
							playerVariables[playerid][pMoney] -= businessItems[i][bItemPrice];
	                        businessVariables[businessID][bVault] += businessItems[i][bItemPrice];

							givePlayerValidWeapon(playerid, 14);

							switch(random(4)) {
								case 0: format(szMessage, sizeof(szMessage), "You've purchased the %s. Don't get too wild.", businessItems[i][bItemName]);
								case 1: format(szMessage, sizeof(szMessage), "You've purchased the %s. Don't blame us if you get it stuck up there!", businessItems[i][bItemName]);
								case 2: format(szMessage, sizeof(szMessage), "You've purchased the %s. There's no warranty for this product!", businessItems[i][bItemName]);
								case 3: format(szMessage, sizeof(szMessage), "You've purchased the %s. Justin Bieber approves of this.", businessItems[i][bItemName]);
							}

                            SendClientMessage(playerid, COLOR_WHITE, szMessage);
                            return 1;
	                    } else return SendClientMessage(playerid, COLOR_GREY, "You don't have enough money to purchase this product.");
					}
				}
            }
			case DIALOG_FOOD: {
			    if(!response)
					return 1;

				listitem += 1;

			    new
			        i,
			        b,
			        businessID = GetPlayerVirtualWorld(playerid)-BUSINESS_VIRTUAL_WORLD;

		        for(new x = 0; x < MAX_BUSINESS_ITEMS; x++) {
		            b++;
		            format(szSmallString, sizeof(szSmallString), "menuItem%d", x);
		            if(GetPVarType(playerid, szSmallString) != 0)
		                i = GetPVarInt(playerid, szSmallString);

					if(b == listitem) {
					    for(new xf = 0; xf < MAX_BUSINESS_ITEMS; xf++) {
				            format(szSmallString, sizeof(szSmallString), "menuItem%d", xf);
				            if(GetPVarType(playerid, szSmallString) != 0)
				                DeletePVar(playerid, szSmallString);
							else
							    break;
					    }

					    break;
					}
				}

                switch(businessItems[i][bItemType]) {
	                case 6: {
						if(playerVariables[playerid][pMoney] >= businessItems[i][bItemPrice]) {
						    GetPlayerHealth(playerid, playerVariables[playerid][pHealth]);
						    
							if(playerVariables[playerid][pHealth] > 95.0)
								return SendClientMessage(playerid, COLOR_GREY, "You are unable to consume this product.");

							playerVariables[playerid][pMoney] -= businessItems[i][bItemPrice];
	                        businessVariables[businessID][bVault] += businessItems[i][bItemPrice];

							SetPlayerHealth(playerid, playerVariables[playerid][pHealth]+5);

							format(szMessage, sizeof(szMessage), "You've purchased and consumed the %s, which has increased your health by 5 percent.", businessItems[i][bItemName]);
                            SendClientMessage(playerid, COLOR_WHITE, szMessage);
                            return 1;
	                    } else return SendClientMessage(playerid, COLOR_GREY, "You don't have enough money to purchase this product.");
					}
					case 7: {
						if(playerVariables[playerid][pMoney] >= businessItems[i][bItemPrice]) {
						    GetPlayerHealth(playerid, playerVariables[playerid][pHealth]);

							if(playerVariables[playerid][pHealth] > 90.0)
								return SendClientMessage(playerid, COLOR_GREY, "You are unable to consume this product.");

							playerVariables[playerid][pMoney] -= businessItems[i][bItemPrice];
	                        businessVariables[businessID][bVault] += businessItems[i][bItemPrice];

							SetPlayerHealth(playerid, playerVariables[playerid][pHealth]+10);

							format(szMessage, sizeof(szMessage), "You've purchased and consumed the %s, which has increased your health by 10 percent.", businessItems[i][bItemName]);
                            SendClientMessage(playerid, COLOR_WHITE, szMessage);
                            return 1;
	                    } else return SendClientMessage(playerid, COLOR_GREY, "You don't have enough money to purchase this product.");
					}
					case 8: {
						if(playerVariables[playerid][pMoney] >= businessItems[i][bItemPrice]) {
						    GetPlayerHealth(playerid, playerVariables[playerid][pHealth]);

							if(playerVariables[playerid][pHealth] > 70.0)
								return SendClientMessage(playerid, COLOR_GREY, "You are unable to consume this product.");

							playerVariables[playerid][pMoney] -= businessItems[i][bItemPrice];
	                        businessVariables[businessID][bVault] += businessItems[i][bItemPrice];

							SetPlayerHealth(playerid, playerVariables[playerid][pHealth]+30);

							format(szMessage, sizeof(szMessage), "You've purchased and consumed the %s, which has increased your health by 30 percent.", businessItems[i][bItemName]);
                            SendClientMessage(playerid, COLOR_WHITE, szMessage);
                            return 1;
	                    } else return SendClientMessage(playerid, COLOR_GREY, "You don't have enough money to purchase this product.");
					}
				}
            }
			case DIALOG_TWENTYFOURSEVEN: {
			    if(!response)
					return 1;
					
				listitem += 1;

			    new
			        i,
			        b,
			        businessID = GetPlayerVirtualWorld(playerid)-BUSINESS_VIRTUAL_WORLD;
			        
		        for(new x = 0; x < MAX_BUSINESS_ITEMS; x++) {
		            b++;
		            format(szSmallString, sizeof(szSmallString), "menuItem%d", x);
		            if(GetPVarType(playerid, szSmallString) != 0)
		                i = GetPVarInt(playerid, szSmallString);

					if(b == listitem) {
					    for(new xf = 0; xf < MAX_BUSINESS_ITEMS; xf++) {
				            format(szSmallString, sizeof(szSmallString), "menuItem%d", xf);
				            if(GetPVarType(playerid, szSmallString) != 0)
				                DeletePVar(playerid, szSmallString);
							else
							    break;
					    }
					    
					    break;
					}
				}
				
                switch(businessItems[i][bItemType]) {
	                case 1: {
						if(playerVariables[playerid][pMoney] >= businessItems[i][bItemPrice]) {
							if(playerVariables[playerid][pRope] >= 30)
								return SendClientMessage(playerid, COLOR_GREY, "You are unable to purchase any more rope.");

							playerVariables[playerid][pMoney] -= businessItems[i][bItemPrice];
		                            	
	                        businessVariables[businessID][bVault] += businessItems[i][bItemPrice];
	                        playerVariables[playerid][pRope]++;

                            SendClientMessage(playerid, COLOR_WHITE, "You have purchased 1 line of Rope!");
                            return 1;
	                    } else return SendClientMessage(playerid, COLOR_GREY, "You don't have enough money to purchase this product.");
					}
					case 2: {
	    				if(playerVariables[playerid][pMoney] >= businessItems[i][bItemPrice]) {
							if(playerVariables[playerid][pWalkieTalkie] != -1)
							    return SendClientMessage(playerid, COLOR_GREY, "You are unable to purchase another walkie talkie.");

							playerVariables[playerid][pMoney] -= businessItems[i][bItemPrice];
							businessVariables[businessID][bVault] += businessItems[i][bItemPrice];
							playerVariables[playerid][pWalkieTalkie] = 0;

							SendClientMessage(playerid, COLOR_WHITE, "You have purchased a walkie talkie - use /setfrequency to tune it, and /wt to speak.");
							return 1;
						} else return SendClientMessage(playerid, COLOR_GREY, "You don't have enough money to purchase this product.");
					}
					case 3: {
						if(playerVariables[playerid][pMoney] >= businessItems[i][bItemPrice]) {
							if(playerVariables[playerid][pPhoneBook] != 1)
							    return SendClientMessage(playerid, COLOR_GREY, "You are unable to purchase another phonebook.");

							playerVariables[playerid][pMoney] -= businessItems[i][bItemPrice];
							businessVariables[businessID][bVault] += businessItems[i][bItemPrice];
							playerVariables[playerid][pPhoneBook] = 1;

							SendClientMessage(playerid, COLOR_WHITE, "You have purchased a phonebook. Use /number to trace a number down!");
							return 1;
						} else return SendClientMessage(playerid, COLOR_GREY, "You don't have enough money to purchase this product.");
					}
					case 4: {
						if(playerVariables[playerid][pPhoneNumber] == -1)
						    return SendClientMessage(playerid, COLOR_GREY, "You do not have a phone.");

	                    if(playerVariables[playerid][pMoney] >= businessItems[i][bItemPrice]) {
							playerVariables[playerid][pMoney] -= businessItems[i][bItemPrice];
							businessVariables[businessID][bVault] += businessItems[i][bItemPrice];
							playerVariables[playerid][pPhoneCredit] += businessItems[i][bItemPrice]*60;

							format(szMessage, sizeof(szMessage), "You have purchased a $%d credit voucher for your mobile phone which has been automatically applied.", businessItems[i][bItemPrice]);
							SendClientMessage(playerid, COLOR_WHITE, szMessage);
							return 1;
						} else return SendClientMessage(playerid, COLOR_GREY, "You don't have enough money to purchase this product.");
					}
					case 5: {
						if(playerVariables[playerid][pPhoneNumber] != -1)
						    SendClientMessage(playerid, COLOR_GREY, "You already had a phone, your phone will be replaced and your number will be changed.");

	                    if(playerVariables[playerid][pMoney] >= businessItems[i][bItemPrice]) {
							playerVariables[playerid][pMoney] -= businessItems[i][bItemPrice];
							businessVariables[businessID][bVault] += businessItems[i][bItemPrice];
					        playerVariables[playerid][pPhoneNumber] = random(89999999)+10000000; // Random eight digit phone number (which won't get crazy ones like 0, etc)

							format(szMessage, sizeof(szMessage), "You have purchased a %s! Your number is %d.", businessItems[i][bItemName], playerVariables[playerid][pPhoneNumber]);
						    SendClientMessage(playerid, COLOR_WHITE, szMessage);
							return 1;
						} else return SendClientMessage(playerid, COLOR_GREY, "You don't have enough money to purchase this product.");
					}
				}
            }
			case DIALOG_REPORT: if(response) {
				switch(listitem) {
					case 0: {
					    new
					        Float: playerPosC[3];

					    GetPlayerPos(GetPVarInt(playerid, "aRf"), playerPosC[0],  playerPosC[1],  playerPosC[2]);
					    SetPlayerPos(playerid, playerPosC[0], playerPosC[1], playerPosC[2]);

					    DeletePVar(playerid, "aR");
					    DeletePVar(playerid, "aRf");
					}
					case 1: {
						if(playerVariables[playerid][pSpectating] == INVALID_PLAYER_ID) {
							GetPlayerPos(playerid, playerVariables[playerid][pPos][0], playerVariables[playerid][pPos][1], playerVariables[playerid][pPos][2]);
							playerVariables[playerid][pInterior] = GetPlayerInterior(playerid);
							playerVariables[playerid][pVirtualWorld] = GetPlayerVirtualWorld(playerid);
							playerVariables[playerid][pSkin] = GetPlayerSkin(playerid);
						}

					    playerVariables[playerid][pSpectating] = GetPVarInt(playerid, "aRf");
					    TogglePlayerSpectating(playerid, true);

					    if(IsPlayerInAnyVehicle(GetPVarInt(playerid, "aRf"))) {
					        PlayerSpectateVehicle(playerid, GetPlayerVehicleID(GetPVarInt(playerid, "aRf")));
					    }
					    else {
							PlayerSpectatePlayer(playerid, GetPVarInt(playerid, "aRf"));
						}

						TextDrawShowForPlayer(playerid, textdrawVariables[4]);

					    DeletePVar(playerid, "aR");
					    DeletePVar(playerid, "aRf");
					}
				}
			}
			case DIALOG_TUTORIAL_DOB: {
				if(isnull(inputtext)) {
				    return ShowPlayerDialog(playerid, DIALOG_TUTORIAL_DOB, DIALOG_STYLE_INPUT, "SERVER: Character Age", "Please enter the age of your character.", "Proceed", "Cancel");
				}
				else {
					new
					    Age = strval(inputtext);

					if(Age >= 16 && Age < 122) {
					    new
							date[3];

						getdate(date[0], date[1], date[2]);

						playerVariables[playerid][pAge] = date[0] - Age;
					    format(szMessage, sizeof(szMessage), "You have set your character's age to %d (born in %d).", Age, playerVariables[playerid][pAge]);
						SendClientMessage(playerid, COLOR_YELLOW, szMessage);

						if(GetPVarInt(playerid, "quiz") == 1) {
							ShowPlayerDialog(playerid, DIALOG_TUTORIAL_CHOICE, DIALOG_STYLE_MSGBOX, "SERVER: Tutorial", "Do you wish to participate in our server tutorial? This is optional for you and will only take a few minutes.","Yes","No");
						} else {
							playerVariables[playerid][pTutorial] = 4;
							TextDrawShowForPlayer(playerid, textdrawVariables[3]);
							SendClientMessage(playerid, COLOR_WHITE, "You're now participating in our mandatory server tutorial. Please pay close attention to the screen. ");
							SendClientMessage(playerid, COLOR_WHITE, "Please press your RIGHT arrow to proceed through the tutorial.");
						}
					}
					else {
					    SendClientMessage(playerid, COLOR_WHITE, "Your character must be older than 16, and can't be older than 122 years old.");
						return ShowPlayerDialog(playerid, DIALOG_TUTORIAL_DOB, DIALOG_STYLE_INPUT, "SERVER: Character Age", "Please enter the age of your character.", "Proceed", "Cancel");
					}
				}
			}
			case DIALOG_TUTORIAL_CHOICE: {
			    if(!response) {
					SendClientMessage(playerid, COLOR_YELLOW, "Conclusion");
					SendClientMessage(playerid, COLOR_WHITE, "Your character will now spawn. Welcome to the server!");
					SendClientMessage(playerid, COLOR_WHITE, "If you have any questions or concerns which relate to gameplay on our server, please use "EMBED_GREY"/n"EMBED_WHITE".");
                    SendClientMessage(playerid, COLOR_WHITE, "If you wish to obtain help from an official member of staff, please use "EMBED_GREY"/helpme"EMBED_WHITE".");
                    SendClientMessage(playerid, COLOR_WHITE, "If you see any players breaking rules, please use "EMBED_GREY"/report"EMBED_WHITE".");

                    format(szMessage, sizeof(szMessage), "Last, but not least, please make sure that you register on our community forums: "EMBED_GREY"%s"EMBED_WHITE".", szServerWebsite);
                 	SendClientMessage(playerid, COLOR_WHITE, szMessage);
                 	
			        firstPlayerSpawn(playerid);
			    } else {
					playerVariables[playerid][pTutorial] = 4;
					TextDrawShowForPlayer(playerid, textdrawVariables[3]);
					SendClientMessage(playerid, COLOR_WHITE, "You're now participating in our mandatory server tutorial. Please pay close attention to the screen. ");
					SendClientMessage(playerid, COLOR_WHITE, "Please press your RIGHT arrow to proceed through the tutorial.");
				}
			}
			case DIALOG_HELP2: {
				if(response) return showHelp(playerid);
			}
			case DIALOG_BAR: { 
			    if(!response)
					return 1;

				listitem += 1;

			    new
			        i,
			        b,
			        businessID = GetPlayerVirtualWorld(playerid)-BUSINESS_VIRTUAL_WORLD;

		        for(new x = 0; x < MAX_BUSINESS_ITEMS; x++) {
		            b++;
		            format(szSmallString, sizeof(szSmallString), "menuItem%d", x);
		            if(GetPVarType(playerid, szSmallString) != 0)
		                i = GetPVarInt(playerid, szSmallString);

					if(b == listitem) {
					    for(new xf = 0; xf < MAX_BUSINESS_ITEMS; xf++) {
				            format(szSmallString, sizeof(szSmallString), "menuItem%d", xf);
				            if(GetPVarType(playerid, szSmallString) != 0)
				                DeletePVar(playerid, szSmallString);
							else
							    break;
					    }

					    break;
					}
				}

                switch(businessItems[i][bItemType]) {
	                case 14: {
						if(playerVariables[playerid][pMoney] >= businessItems[i][bItemPrice]) {
							playerVariables[playerid][pMoney] -= businessItems[i][bItemPrice];
	                        businessVariables[businessID][bVault] += businessItems[i][bItemPrice];

							SetPlayerSpecialAction(playerid, SPECIAL_ACTION_SMOKE_CIGGY);

							format(szMessage, sizeof(szMessage), "You've purchased %s.", businessItems[i][bItemName]);
                            SendClientMessage(playerid, COLOR_WHITE, szMessage);
                            return 1;
	                    } else return SendClientMessage(playerid, COLOR_GREY, "You don't have enough money to purchase this product.");
					}
	                case 15: {
						if(playerVariables[playerid][pMoney] >= businessItems[i][bItemPrice]) {
							playerVariables[playerid][pMoney] -= businessItems[i][bItemPrice];
	                        businessVariables[businessID][bVault] += businessItems[i][bItemPrice];

							SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DRINK_SPRUNK);

							format(szMessage, sizeof(szMessage), "You've purchased %s.", businessItems[i][bItemName]);
                            SendClientMessage(playerid, COLOR_WHITE, szMessage);
                            return 1;
	                    } else return SendClientMessage(playerid, COLOR_GREY, "You don't have enough money to purchase this product.");
					}
	                case 16: {
						if(playerVariables[playerid][pMoney] >= businessItems[i][bItemPrice]) {
							playerVariables[playerid][pMoney] -= businessItems[i][bItemPrice];
	                        businessVariables[businessID][bVault] += businessItems[i][bItemPrice];

							SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DRINK_BEER);

							format(szMessage, sizeof(szMessage), "You've purchased %s.", businessItems[i][bItemName]);
                            SendClientMessage(playerid, COLOR_WHITE, szMessage);
                            return 1;
	                    } else return SendClientMessage(playerid, COLOR_GREY, "You don't have enough money to purchase this product.");
					}
	                case 17: {
						if(playerVariables[playerid][pMoney] >= businessItems[i][bItemPrice]) {
							playerVariables[playerid][pMoney] -= businessItems[i][bItemPrice];
	                        businessVariables[businessID][bVault] += businessItems[i][bItemPrice];

							SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DRINK_WINE);

							format(szMessage, sizeof(szMessage), "You've purchased %s.", businessItems[i][bItemName]);
                            SendClientMessage(playerid, COLOR_WHITE, szMessage);
                            return 1;
	                    } else return SendClientMessage(playerid, COLOR_GREY, "You don't have enough money to purchase this product.");
					}
				}
			}
		    case DIALOG_LSPD_CLOTHING: {
		        if(response) switch(listitem) {
				    case 0: ShowPlayerDialog(playerid, DIALOG_LSPD_CLOTHING_OFFICIAL, DIALOG_STYLE_LIST, "Official Clothing", "Probationary Officer\nPatrol/Specialist Officer\nTRU Patrol\nMotorcycle/Aircraft\nAfrican American\nOverweight\nHispanic\nTactical Gear\nSergeant\nCommander\nChief", "Select", "Cancel");
				    case 1: ShowPlayerDialog(playerid, DIALOG_LSPD_CLOTHING_CUSTOM, DIALOG_STYLE_INPUT, "Custom Selection", "Enter a skin ID you wish to use.", "Select", "Cancel");
				}
		    }
		    case DIALOG_LSPD_CLOTHING_OFFICIAL: {
		        if(response) switch(listitem) {
		            case 0: {
				        SetPlayerSkin(playerid, 71);
				        playerVariables[playerid][pSkin] = 71;
		            }
		            case 1: {
				        SetPlayerSkin(playerid, 280);
				        playerVariables[playerid][pSkin] = 280;
		            }
		            case 2: {
				        SetPlayerSkin(playerid, 281);
				        playerVariables[playerid][pSkin] = 281;
		            }
		            case 3: {
				        SetPlayerSkin(playerid, 284);
				        playerVariables[playerid][pSkin] = 284;
		            }
		            case 4: {
				        SetPlayerSkin(playerid, 265);
				        playerVariables[playerid][pSkin] = 265;
		            }
		            case 5: {
				        SetPlayerSkin(playerid, 266);
				        playerVariables[playerid][pSkin] = 266;
		            }
		            case 6: {
				        SetPlayerSkin(playerid, 267);
				        playerVariables[playerid][pSkin] = 267;
		            }
		            case 7: {
				        SetPlayerSkin(playerid, 285);
				        playerVariables[playerid][pSkin] = 285;
		            }
		            case 8: {
		                if(playerVariables[playerid][pGroupRank] < 4) return SendClientMessage(playerid, COLOR_WHITE, "You're not a sergeant.");
				        SetPlayerSkin(playerid, 282);
				        playerVariables[playerid][pSkin] = 282;
		            }
		            case 9: {
		                if(playerVariables[playerid][pGroupRank] < 5) return SendClientMessage(playerid, COLOR_WHITE, "You're not a commander.");
				        SetPlayerSkin(playerid, 283);
				        playerVariables[playerid][pSkin] = 283;
		            }
		            case 10: {
		                if(playerVariables[playerid][pGroupRank] < 6) return SendClientMessage(playerid, COLOR_WHITE, "You're not the Chief of Police.");
				        SetPlayerSkin(playerid, 288);
				        playerVariables[playerid][pSkin] = 288;
		            }
		        }
		    }
		    case DIALOG_LSPD_CLOTHING_CUSTOM: {
				if(!response) return 1;
		        new skin;
		        if(sscanf(inputtext,"d",skin)) return ShowPlayerDialog(playerid, DIALOG_LSPD_CLOTHING_CUSTOM, DIALOG_STYLE_INPUT, "Custom Selection", "Invalid skin.\r\nEnter a skin ID you wish to use.", "Select", "Cancel"); {
					if(!IsValidSkin(skin)) return ShowPlayerDialog(playerid, DIALOG_LSPD_CLOTHING_CUSTOM, DIALOG_STYLE_INPUT, "Custom Selection", "Invalid skin.\r\nEnter a skin ID you wish to use.", "Select", "Cancel");
					switch(skin) {
					    case 282, 283, 286, 288: return ShowPlayerDialog(playerid, DIALOG_LSPD_CLOTHING_CUSTOM, DIALOG_STYLE_INPUT, "Custom Selection", "Invalid skin.\r\nEnter a skin ID you wish to use.", "Select", "Cancel");
						default: {
					        SetPlayerSkin(playerid, skin);
					        playerVariables[playerid][pSkin] = skin;
						}
					}
				}
		    }

		    case DIALOG_LSPD_RELEASE: {

		        new id;
            	if(sscanf(inputtext,"u",id)) {
            	    SendClientMessage(playerid, COLOR_GREY, "Invalid name specified (use a proper player name or ID).");
            	}
				else {
				    if(IsPlayerAuthed(id)) {
            			if(playerVariables[id][pPrisonTime] > 0 && playerVariables[id][pPrisonID] == 3) {
				            new
								Rstring[58],
								playerNames[2][MAX_PLAYER_NAME];

							playerVariables[id][pPrisonID] = 0;
							playerVariables[id][pPrisonTime] = 0;
							SetPlayerPos(id, 738.9963, -1417.2211, 13.5234);
							SetPlayerInterior(id, 0);
							SetPlayerVirtualWorld(id, 0);


							GetPlayerName(playerid, playerNames[0], MAX_PLAYER_NAME);
							GetPlayerName(id, playerNames[1], MAX_PLAYER_NAME);

							switch(playerVariables[playerid][pGroupRank]) {
								case 5:	format(Rstring, sizeof(Rstring), "Dispatch: %s %s has released %s from detainment.", groupVariables[playerVariables[playerid][pGroup]][gGroupRankName5], playerNames[0], playerNames[1]);
								case 6:	format(Rstring, sizeof(Rstring), "Dispatch: %s %s has released %s from detainment.", groupVariables[playerVariables[playerid][pGroup]][gGroupRankName6], playerNames[0], playerNames[1]);
							}
							SendToGroup(playerVariables[playerid][pGroup], COLOR_RADIOCHAT, Rstring);

							switch(playerVariables[playerid][pGroupRank]) {
								case 5:	format(Rstring, sizeof(Rstring), "%s %s has released you from jail.", groupVariables[playerVariables[playerid][pGroup]][gGroupRankName5], playerNames[0]);
								case 6:	format(Rstring, sizeof(Rstring), "%s %s has released you from jail.", groupVariables[playerVariables[playerid][pGroup]][gGroupRankName6], playerNames[0]);
							}
				            SendClientMessage(id, COLOR_WHITE, Rstring);

							format(Rstring, sizeof(Rstring), "You have successfully released %s from jail.", playerNames[1]);
							SendClientMessage(playerid, COLOR_WHITE, Rstring);
				        }
				        else {
				            SendClientMessage(playerid, COLOR_WHITE, "That player is not jailed (in character).");
				        }
				    }
				}
			}

		    case DIALOG_LSPD_CLEAR: {

		        new
					warrantid;

            	if(sscanf(inputtext,"u",warrantid))
					return SendClientMessage(playerid, COLOR_GREY, "Invalid name specified (use a proper player name or ID).");

				else if(IsPlayerAuthed(warrantid)) {
					new
						WarrantplayerNames[2][MAX_PLAYER_NAME];

					GetPlayerName(playerid, WarrantplayerNames[0], MAX_PLAYER_NAME);
					GetPlayerName(warrantid, WarrantplayerNames[1], MAX_PLAYER_NAME);

					switch(playerVariables[playerid][pGroupRank]) {
						case 5:	format(szMessage, sizeof(szMessage), "Dispatch: %s %s has cleared all warrants on %s.", groupVariables[playerVariables[playerid][pGroup]][gGroupRankName5], WarrantplayerNames[0], WarrantplayerNames[1]);
						case 6:	format(szMessage, sizeof(szMessage), "Dispatch: %s %s has cleared all warrants on %s.", groupVariables[playerVariables[playerid][pGroup]][gGroupRankName6], WarrantplayerNames[0], WarrantplayerNames[1]);
					}
					SendToGroup(playerVariables[playerid][pGroup], COLOR_RADIOCHAT, szMessage);
					playerVariables[warrantid][pWarrants] = 0;
				}
				else SendClientMessage(playerid, COLOR_GREY, "The specified player is not connected, or has not authenticated.");
		    }
		    case DIALOG_LSPD_EQUIPMENT: {
		        if(response) switch(listitem) {
		            case 0: ShowPlayerDialog(playerid, LSPD_DIALOG_EQUIPMENT1, DIALOG_STYLE_LIST, "Equipment", "Nitestick\nMace\nDesert Eagle\nMP5\nShotgun\nKevlar Vest", "Select", "Cancel");
		            case 1: {
		                if(groupVariables[playerVariables[playerid][pGroup]][gswatInv] == 1) {
		                    ShowPlayerDialog(playerid, LSPD_DIALOG_EQUIPMENT2, DIALOG_STYLE_LIST, "SWAT Equipment", "CS Gas ($500)\nM4A1 ($3,000)\nSPAS-12 ($5,000)\nSniper Rifle ($5,000)", "Select", "Cancel");
		                }
		                else {
		                    SendClientMessage(playerid, COLOR_WHITE, "The SWAT inventory is currently unavailable.");
		                }
		            }
		        }
		    }
		    case LSPD_DIALOG_EQUIPMENT2: {
		        if(response) switch(listitem) {
		            case 0: {
		                if(groupVariables[GOVERNMENT_GROUP_ID][gSafe][0] >= 500) {
		                    groupVariables[GOVERNMENT_GROUP_ID][gSafe][0] -= 500;
		                    SendClientMessage(playerid, COLOR_WHITE, "You have withdrawn CS gas. This has cost the government $500, so use it properly.");
							PlayerPlaySound(playerid, 1052, 0, 0, 0);
		                    givePlayerValidWeapon(playerid, 17);
		                }
		                else {
		                    SendClientMessage(playerid, COLOR_WHITE, "The government are unable to afford this weapon on your behalf.");
		                }
		            }
		            case 1: {
		                if(groupVariables[GOVERNMENT_GROUP_ID][gSafe][0] >= 3000)
		                {
		                    groupVariables[GOVERNMENT_GROUP_ID][gSafe][0] -= 3000;
		                    SendClientMessage(playerid, COLOR_WHITE, "You have withdrawn an M4A1. This has cost the government $3,000, so use it properly.");
		                    givePlayerValidWeapon(playerid, 31);
							PlayerPlaySound(playerid, 1052, 0, 0, 0);
		                }
		                else {
		                    SendClientMessage(playerid, COLOR_WHITE, "The government are unable to afford this weapon on your behalf.");
		                }
		            }
		            case 2: {
		                if(groupVariables[GOVERNMENT_GROUP_ID][gSafe][0] >= 5000)
		                {
		                    groupVariables[GOVERNMENT_GROUP_ID][gSafe][0] -= 5000;
		                    SendClientMessage(playerid, COLOR_WHITE, "You have withdrawn a SPAS12. This has cost the government $5,000, so use it properly.");
		                    givePlayerValidWeapon(playerid, 27);
							PlayerPlaySound(playerid, 1052, 0, 0, 0);
		                }
		                else {
		                    SendClientMessage(playerid, COLOR_WHITE, "The government are unable to afford this weapon on your behalf.");
		                }
		            }
		            case 3: {
		                if(groupVariables[GOVERNMENT_GROUP_ID][gSafe][0] >= 5000) {
		                    groupVariables[GOVERNMENT_GROUP_ID][gSafe][0] -= 5000;
		                    SendClientMessage(playerid, COLOR_WHITE, "You have withdrawn a sniper rifle. This has cost the government $5,000, so use it properly.");
		                    givePlayerValidWeapon(playerid, 34);
							PlayerPlaySound(playerid, 1052, 0, 0, 0);
		                }
		                else {
		                    SendClientMessage(playerid, COLOR_WHITE, "The government are unable to afford this weapon on your behalf.");
		                }
		            }
		        }
		    }
	  	case LSPD_DIALOG_EQUIPMENT1: {
      		if(response) switch(listitem) {
		       	case 0: givePlayerValidWeapon(playerid, 3) && PlayerPlaySound(playerid, 1052, 0, 0, 0);
		       	case 1: givePlayerValidWeapon(playerid, 41) && PlayerPlaySound(playerid, 1052, 0, 0, 0);
		       	case 2: givePlayerValidWeapon(playerid, 24) && PlayerPlaySound(playerid, 1052, 0, 0, 0);
	        	case 3: givePlayerValidWeapon(playerid, 29) && PlayerPlaySound(playerid, 1052, 0, 0, 0);
	        	case 4: givePlayerValidWeapon(playerid, 25) && PlayerPlaySound(playerid, 1052, 0, 0, 0);
				case 5: SetPlayerArmour(playerid, 100.0) && PlayerPlaySound(playerid, 1052, 0, 0, 0);
			}
    	}
 		case DIALOG_LSPD: {
   			if(response) switch(listitem) {
                    case 0: ShowPlayerDialog(playerid, DIALOG_LSPD_EQUIPMENT, DIALOG_STYLE_LIST, "Equipment", "Normal Equipment\nSWAT Equipment", "Select", "Cancel");
					case 1: {
						if(playerVariables[playerid][pGroupRank] >= 5) ShowPlayerDialog(playerid, DIALOG_LSPD_RELEASE, DIALOG_STYLE_INPUT, "Release Suspect", "Please enter the suspect's name.", "Proceed", "Cancel");
						else SendClientMessage(playerid, COLOR_GREY, "You do not have the authority to do this.");
					}
					case 2: ShowPlayerDialog(playerid, DIALOG_LSPD_CLOTHING, DIALOG_STYLE_LIST, "Clothing", "Official Clothing\nCustom Selection", "Select", "Cancel");
		            case 3: {
						if(playerVariables[playerid][pGroupRank] >= 5) ShowPlayerDialog(playerid, DIALOG_LSPD_CLEAR, DIALOG_STYLE_INPUT, "Clear Suspect", "Please enter the suspect's name.", "Proceed", "Cancel");
						else SendClientMessage(playerid, COLOR_GREY, "You do not have the authority to do this.");
					}
			}
		}
		case DIALOG_LOGIN: {
		    if(!response) return Kick(playerid);

		    new
		        query[300],
		        escapedName[MAX_PLAYER_NAME],
				escapedPassword[129];

			GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);

			WP_Hash(escapedPassword, sizeof(escapedPassword), inputtext);

			mysql_real_escape_string(szPlayerName, escapedName);

			format(query, sizeof(query), "SELECT * FROM `playeraccounts` WHERE playerName = '%s' AND playerPassword = '%s'", escapedName, escapedPassword);
			mysql_query(query, THREAD_CHECK_CREDENTIALS, playerid);
		}
		case DIALOG_GROUP_ENTER: {
			if(response == 1) {
			    new
			        x = GetPVarInt(playerid, "gE"); // So we don't have to access it each and every time.

                DeletePVar(playerid, "gE");

			    new
					name[MAX_PLAYER_NAME];

				GetPlayerName(playerid, name, MAX_PLAYER_NAME);
			    format(szMessage, sizeof(szMessage), "* %s breaks down the door and enters the building.", name);
                nearByMessage(playerid, COLOR_PURPLE, szMessage);

				if(playerVariables[playerid][pAdminDuty] < 1 && groupVariables[x][gGroupHQLockStatus] == 1) {
					groupVariables[x][gGroupHQLockStatus] = 0;
					format(szMessage, sizeof(szMessage), "%s's HQ\n\nPress ~k~~PED_DUCK~ to enter.", groupVariables[x][gGroupName]);
					UpdateDynamic3DTextLabelText(groupVariables[x][gGroupLabelID], COLOR_YELLOW, szMessage);
				}

				SetPlayerPos(playerid, groupVariables[x][gGroupInteriorPos][0], groupVariables[x][gGroupInteriorPos][1], groupVariables[x][gGroupInteriorPos][2]);
				SetPlayerInterior(playerid, groupVariables[x][gGroupHQInteriorID]);
				SetPlayerVirtualWorld(playerid, GROUP_VIRTUAL_WORLD+x);
			}
		}
		case DIALOG_REGISTER: {
			if(strlen(inputtext) < 1)
			    return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "SERVER: Registration", "Your password must exceed 1 character!\n\nWelcome to the "SERVER_NAME" Server.\n\nPlease enter your desired password below!", "Register", "Cancel");

			new
				wpHash[129];

			GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
			mysql_real_escape_string(szPlayerName, szPlayerName);

			WP_Hash(wpHash, sizeof(wpHash), inputtext);

			format(szLargeString, sizeof(szLargeString), "INSERT INTO playeraccounts (playerName, playerPassword) VALUES('%s', '%s')", szPlayerName, wpHash);
			mysql_query(szLargeString);

			SendClientMessage(playerid, COLOR_WHITE, "SERVER: Your account is now registered!");
			format(szLargeString, sizeof(szLargeString), "SELECT * FROM `playeraccounts` WHERE `playerName` = '%s' AND `playerPassword` = '%s'", szPlayerName, wpHash);
			mysql_query(szLargeString, THREAD_CHECK_CREDENTIALS, playerid);
		}
		case DIALOG_HOUSE_ENTER: {
			if(response == 1) {
			    new
			        x = GetPVarInt(playerid, "hE"); // So we don't have to access it each and every time.

                DeletePVar(playerid, "hE");

				GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
			    format(szMessage,sizeof(szMessage),"* %s breaks down the door and enters the house.", szPlayerName);
                nearByMessage(playerid, COLOR_PURPLE, szMessage);

                if(playerVariables[playerid][pAdminDuty] < 1 && houseVariables[x][hHouseLocked] == 1) { // Might seem redundant, but if many people break in at once this'll stop unnecessary code from being executed.
					houseVariables[x][hHouseLocked] = 0;
					if(!strcmp(houseVariables[x][hHouseOwner], "Nobody", true) && strlen(houseVariables[x][hHouseOwner]) >= 1)
						format(szMessage, sizeof(szMessage), "House %d (un-owned - /buyhouse)\nPrice: $%d\n\n(locked)", x, houseVariables[x][hHousePrice]);
					else
					    format(szMessage, sizeof(szMessage), "House %d (owned)\nOwner: %s\n\nPress ~k~~PED_DUCK~ to enter.", x, houseVariables[x][hHouseOwner]);
					    
					UpdateDynamic3DTextLabelText(houseVariables[x][hLabelID], COLOR_YELLOW, szMessage);
				}

				SetPlayerPos(playerid, houseVariables[x][hHouseInteriorPos][0], houseVariables[x][hHouseInteriorPos][1], houseVariables[x][hHouseInteriorPos][2]);
				SetPlayerInterior(playerid, houseVariables[x][hHouseInteriorID]);
				SetPlayerVirtualWorld(playerid, HOUSE_VIRTUAL_WORLD+x);
			}
		}
		case DIALOG_BUSINESS_ENTER: {
			if(response == 1) {
			    new
			        x = GetPVarInt(playerid, "bE"); // So we don't have to access it each and every time.

                DeletePVar(playerid, "bE");

				GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
			    format(szMessage, sizeof(szMessage),"* %s breaks down the door and enters the business.", szPlayerName);
                nearByMessage(playerid, COLOR_PURPLE, szMessage);

                if(playerVariables[playerid][pAdminDuty] < 1 && businessVariables[x][bLocked] == 1) {
					businessVariables[x][bLocked] = 0;
					
					if(!strcmp(businessVariables[x][bOwner], "Nobody"))
					    format(szMessage, sizeof(szMessage), "%s\n(Business %d - un-owned)\nPrice: $%d (/buybusiness)\n\n(locked)", businessVariables[x][bName], x, businessVariables[x][bPrice]);
					else
					    format(szMessage, sizeof(szMessage), "%s\n(Business %d - owned by %s)\n\nPress ~k~~PED_DUCK~ to enter", businessVariables[x][bName], x, businessVariables[x][bOwner]);
					
					UpdateDynamic3DTextLabelText(businessVariables[x][bLabelID], COLOR_YELLOW, szMessage);
				}

				SetPlayerPos(playerid, businessVariables[x][bInteriorPos][0], businessVariables[x][bInteriorPos][1], businessVariables[x][bInteriorPos][2]);
				SetPlayerInterior(playerid, businessVariables[x][bInterior]);
				SetPlayerVirtualWorld(playerid, BUSINESS_VIRTUAL_WORLD+x);
			}
		}
  		case DIALOG_CREATEGUN: {
			if(!response)
				return 1;
				
			GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
			
		    switch(listitem) {
				case 0: {
					if(playerVariables[playerid][pMaterials] >= 30) {
						givePlayerValidWeapon(playerid, 8);
				        playerVariables[playerid][pMaterials] -= 30;
				        SendClientMessage(playerid, COLOR_WHITE, "You have created a katana. Type /giveweapon [playerid] to pass the weapon on.");
				        format(szMessage, sizeof(szMessage), "* %s has created a katana from their materials.", szPlayerName);
				        nearByMessage(playerid, COLOR_PURPLE, szMessage);
						playerVariables[playerid][pJobDelay] = 30;
				        playerVariables[playerid][pJobSkill][0]++;
						switch(playerVariables[playerid][pJobSkill][0]) {
							case 50, 100, 150, 200, 250, 300, 350, 400, 450, 500: {
								format(szMessage,sizeof(szMessage),"Congratulations! Your weapon creation skill level is now %d. You can now create more powerful weapons.",playerVariables[playerid][pJobSkill][0]/50);
								SendClientMessage(playerid,COLOR_WHITE,szMessage);
							}
						}
				    }
					else {
						SendClientMessage(playerid, COLOR_GREY, "You do not have enough materials.");
					}
				}
				case 1: {
					if(playerVariables[playerid][pMaterials] >= 30) {

						givePlayerValidWeapon(playerid, 15);
						playerVariables[playerid][pMaterials] -= 30;
						SendClientMessage(playerid, COLOR_WHITE,"You have created a cane. Type /giveweapon [playerid] to pass the weapon on.");
						format(szMessage, sizeof(szMessage), "* %s has created a cane from their materials.", szPlayerName);
						nearByMessage(playerid, COLOR_PURPLE, szMessage);
						playerVariables[playerid][pJobSkill][0]++;
						playerVariables[playerid][pJobDelay] = 30;
						switch(playerVariables[playerid][pJobSkill][0]) {
							case 50, 100, 150, 200, 250, 300, 350, 400, 450, 500: {
								format(szMessage,sizeof(szMessage),"Congratulations! Your weapon creation skill level is now %d. You can now create more powerful weapons.",playerVariables[playerid][pJobSkill][0]/50);
								SendClientMessage(playerid,COLOR_WHITE,szMessage);
							}
						}
					}
					else {
						SendClientMessage(playerid, COLOR_GREY, "You do not have enough materials.");
					}
				}
				case 2: {
					if(playerVariables[playerid][pMaterials] >= 33) {

						givePlayerValidWeapon(playerid, 7);
						playerVariables[playerid][pMaterials] -= 33;
						SendClientMessage(playerid, COLOR_WHITE,"You have created a pool cue. Type /giveweapon [playerid] to pass the weapon on.");
						format(szMessage, sizeof(szMessage), "* %s has created a pool cue from their materials.", szPlayerName);
						nearByMessage(playerid, COLOR_PURPLE, szMessage);
						playerVariables[playerid][pJobSkill][0]++;
						playerVariables[playerid][pJobDelay] = 30;
						switch(playerVariables[playerid][pJobSkill][0]) {
							case 50, 100, 150, 200, 250, 300, 350, 400, 450, 500: {
								format(szMessage,sizeof(szMessage),"Congratulations! Your weapon creation skill level is now %d. You can now create more powerful weapons.",playerVariables[playerid][pJobSkill][0]/50);
								SendClientMessage(playerid,COLOR_WHITE,szMessage);
							}
						}
					}
					else {
						SendClientMessage(playerid, COLOR_GREY, "You do not have enough materials.");
					}
				}
				case 3: {
					if(playerVariables[playerid][pMaterials] >= 35) {

						givePlayerValidWeapon(playerid, 5);
						playerVariables[playerid][pMaterials] -= 35;
						SendClientMessage(playerid, COLOR_WHITE, "You have created a baseball bat. Type /giveweapon [playerid] to pass the weapon on.");
						format(szMessage, sizeof(szMessage), "* %s has created a baseball bat from their materials.", szPlayerName);
						nearByMessage( playerid, COLOR_PURPLE, szMessage);
						playerVariables[playerid][pJobSkill][0]++;
						playerVariables[playerid][pJobDelay] = 30;
						switch(playerVariables[playerid][pJobSkill][0]) {
							case 50, 100, 150, 200, 250, 300, 350, 400, 450, 500: {
								format(szMessage,sizeof(szMessage),"Congratulations! Your weapon creation skill level is now %d. You can now create more powerful weapons.",playerVariables[playerid][pJobSkill][0]/50);
								SendClientMessage(playerid,COLOR_WHITE,szMessage);
							}
						}
					}
					else {
						SendClientMessage(playerid, COLOR_GREY, "You do not have enough materials.");
					}
				}
				case 4: {
					if(playerVariables[playerid][pMaterials] >= 50) {

						givePlayerValidWeapon(playerid, 6);
						playerVariables[playerid][pMaterials] -= 50;
						SendClientMessage(playerid, COLOR_WHITE,"You have created a shovel. Type /giveweapon [playerid] to pass the weapon on.");
						format(szMessage, sizeof(szMessage), "* %s has created a shovel from their materials.", szPlayerName);
						nearByMessage( playerid, COLOR_PURPLE, szMessage);
						playerVariables[playerid][pJobSkill][0]++;
						playerVariables[playerid][pJobDelay] = 30;
						switch(playerVariables[playerid][pJobSkill][0]) {
							case 50, 100, 150, 200, 250, 300, 350, 400, 450, 500: {
								format(szMessage,sizeof(szMessage),"Congratulations! Your weapon creation skill level is now %d. You can now create more powerful weapons.",playerVariables[playerid][pJobSkill][0]/50);
								SendClientMessage(playerid,COLOR_WHITE,szMessage);
							}
						}
					}
					else {
						SendClientMessage(playerid, COLOR_GREY, "You do not have enough materials.");
					}
				}
				case 5: {
					if(playerVariables[playerid][pMaterials] >= 250) {

						givePlayerValidWeapon(playerid, 22);
						playerVariables[playerid][pMaterials] -= 250;
						SendClientMessage(playerid, COLOR_WHITE,"You have created a 9mm pistol. Type /giveweapon [playerid] to pass the weapon on.");
						format(szMessage, sizeof(szMessage), "* %s has created a 9mm pistol from their materials.", szPlayerName);
						nearByMessage( playerid, COLOR_PURPLE, szMessage);
						playerVariables[playerid][pJobSkill][0]++;
						playerVariables[playerid][pJobDelay] = 30;
						switch(playerVariables[playerid][pJobSkill][0]) {
							case 50, 100, 150, 200, 250, 300, 350, 400, 450, 500: {
								format(szMessage,sizeof(szMessage),"Congratulations! Your weapon creation skill level is now %d. You can now create more powerful weapons.",playerVariables[playerid][pJobSkill][0]/50);
								SendClientMessage(playerid,COLOR_WHITE,szMessage);
							}
						}
					}
					else {
						SendClientMessage(playerid, COLOR_GREY, "You do not have enough materials.");
					}
				}
				case 6: {
					if(playerVariables[playerid][pMaterials] >= 300) {

						givePlayerValidWeapon(playerid, 23);
						playerVariables[playerid][pMaterials] -= 300;
						SendClientMessage(playerid, COLOR_WHITE, "You have created a silenced pistol. Type /giveweapon [playerid] to pass the weapon on.");
						format(szMessage, sizeof(szMessage), "* %s has created a silenced pistol from their materials.", szPlayerName);
						nearByMessage( playerid, COLOR_PURPLE, szMessage);
						playerVariables[playerid][pJobSkill][0]++;
						playerVariables[playerid][pJobDelay] = 30;
						switch(playerVariables[playerid][pJobSkill][0]) {
							case 50, 100, 150, 200, 250, 300, 350, 400, 450, 500: {
								format(szMessage,sizeof(szMessage),"Congratulations! Your weapon creation skill level is now %d. You can now create more powerful weapons.",playerVariables[playerid][pJobSkill][0]/50);
								SendClientMessage(playerid,COLOR_WHITE,szMessage);
							}
						}
					}
					else {
						SendClientMessage(playerid, COLOR_GREY, "You do not have enough materials.");
					}
				}
				case 7: {
					if(playerVariables[playerid][pMaterials] >= 550) {

						givePlayerValidWeapon(playerid, 25);
						playerVariables[playerid][pMaterials] -= 550;
						SendClientMessage(playerid, COLOR_WHITE,"You have created a shotgun. Type /giveweapon [playerid] to pass the weapon on.");
						format(szMessage, sizeof(szMessage), "* %s has created a shotgun from their materials.", szPlayerName);
						nearByMessage( playerid, COLOR_PURPLE, szMessage);
						playerVariables[playerid][pJobSkill][0]++;
						playerVariables[playerid][pJobDelay] = 30;
						switch(playerVariables[playerid][pJobSkill][0]) {
							case 50, 100, 150, 200, 250, 300, 350, 400, 450, 500: {
								format(szMessage,sizeof(szMessage),"Congratulations! Your weapon creation skill level is now %d. You can now create more powerful weapons.",playerVariables[playerid][pJobSkill][0]/50);
								SendClientMessage(playerid,COLOR_WHITE,szMessage);
							}
						}
					}
					else {
						SendClientMessage(playerid, COLOR_GREY, "You do not have enough materials.");
					}
				}

				case 8: {
					if(playerVariables[playerid][pMaterials] >= 680) {

						givePlayerValidWeapon(playerid, 24);
						playerVariables[playerid][pMaterials] -= 680;
						SendClientMessage(playerid, COLOR_WHITE, "You have created a Desert Eagle. Type /giveweapon [playerid] to pass the weapon on.");
						format(szMessage, sizeof(szMessage), "* %s has created a Desert Eagle from their materials.", szPlayerName);
						nearByMessage(playerid, COLOR_PURPLE, szMessage);
						playerVariables[playerid][pJobSkill][0]++;
						playerVariables[playerid][pJobDelay] = 30;
						switch(playerVariables[playerid][pJobSkill][0]) {
							case 50, 100, 150, 200, 250, 300, 350, 400, 450, 500: {
								format(szMessage,sizeof(szMessage),"Congratulations! Your weapon creation skill level is now %d. You can now create more powerful weapons.",playerVariables[playerid][pJobSkill][0]/50);
								SendClientMessage(playerid,COLOR_WHITE,szMessage);
							}
						}
					}
					else {
						SendClientMessage(playerid, COLOR_GREY, "You do not have enough materials.");
					}
				}

				case 9: {
					if( playerVariables[playerid][pMaterials] >= 850 )
					{
						givePlayerValidWeapon(playerid, 29);
						playerVariables[playerid][pMaterials] -= 850;
						SendClientMessage(playerid, COLOR_WHITE, "You have created an MP5. Type /giveweapon [playerid] to pass the weapon on.");
						format(szMessage, sizeof(szMessage), "* %s has created a %s from their materials.", szPlayerName);
						nearByMessage( playerid, COLOR_PURPLE, szMessage);
						playerVariables[playerid][pJobSkill][0]++;
						playerVariables[playerid][pJobDelay] = 30;
						switch(playerVariables[playerid][pJobSkill][0]) {
							case 50, 100, 150, 200, 250, 300, 350, 400, 450, 500: {
								format(szMessage,sizeof(szMessage),"Congratulations! Your weapon creation skill level is now %d. You can now create more powerful weapons.",playerVariables[playerid][pJobSkill][0]/50);
								SendClientMessage(playerid,COLOR_WHITE,szMessage);
							}
						}
					}
					else {
						SendClientMessage(playerid, COLOR_GREY, "You do not have enough materials.");
					}
				}
				case 10: {
					if(playerVariables[playerid][pMaterials] >= 900 )
					{

						givePlayerValidWeapon(playerid, 28);
						playerVariables[playerid][pMaterials] -= 900;
						SendClientMessage(playerid, COLOR_WHITE, "You have created a Micro Uzi. Type /giveweapon [playerid] to pass the weapon on.");
						format(szMessage, sizeof(szMessage), "* %s has created a Micro Uzi from their materials.", szPlayerName);
						nearByMessage( playerid, COLOR_PURPLE, szMessage);
						playerVariables[playerid][pJobSkill][0]++;
						playerVariables[playerid][pJobDelay] = 30;
						switch(playerVariables[playerid][pJobSkill][0]) {
							case 50, 100, 150, 200, 250, 300, 350, 400, 450, 500: {
								format(szMessage,sizeof(szMessage),"Congratulations! Your weapon creation skill level is now %d. You can now create more powerful weapons.",playerVariables[playerid][pJobSkill][0]/50);
								SendClientMessage(playerid,COLOR_WHITE,szMessage);
							}
						}
					}
					else
					{
						SendClientMessage(playerid, COLOR_GREY, "You do not have enough materials.");
					}
				}
				case 11: {
					if(playerVariables[playerid][pMaterials] >= 1500) {

						givePlayerValidWeapon(playerid, 30);
						playerVariables[playerid][pMaterials] -= 1500;
						SendClientMessage(playerid, COLOR_WHITE, "You have created an AK-47. Type /giveweapon [playerid] to pass the weapon on.");
						format(szMessage, sizeof(szMessage), "* %s has created an AK-47 from their materials.", szPlayerName);
						nearByMessage( playerid, COLOR_PURPLE, szMessage);
						playerVariables[playerid][pJobSkill][0]++;
						playerVariables[playerid][pJobDelay] = 30;
						switch(playerVariables[playerid][pJobSkill][0]) {
							case 50, 100, 150, 200, 250, 300, 350, 400, 450, 500: {
								format(szMessage,sizeof(szMessage),"Congratulations! Your weapon creation skill level is now %d. You can now create more powerful weapons.",playerVariables[playerid][pJobSkill][0]/50);
								SendClientMessage(playerid,COLOR_WHITE,szMessage);
							}
						}
					}
					else {
						SendClientMessage(playerid, COLOR_GREY, "You do not have enough materials.");
					}
				}
				case 12: {
					if(playerVariables[playerid][pMaterials] >= 2000)
					{
						givePlayerValidWeapon(playerid, 31);
						playerVariables[playerid][pMaterials] -= 2000;
						SendClientMessage(playerid, COLOR_WHITE, "You have created an M4A1. Type /giveweapon [playerid] to pass the weapon on.");
						format(szMessage, sizeof(szMessage), "* %s has created an M4A1 from their materials.", szPlayerName);
						nearByMessage(playerid, COLOR_PURPLE, szMessage);
						playerVariables[playerid][pJobSkill][0]++;
						playerVariables[playerid][pJobDelay] = 30;
						switch(playerVariables[playerid][pJobSkill][0]) {
							case 50, 100, 150, 200, 250, 300, 350, 400, 450, 500: {
								format(szMessage,sizeof(szMessage),"Congratulations! Your weapon creation skill level is now %d. You can now create more powerful weapons.",playerVariables[playerid][pJobSkill][0]/50);
								SendClientMessage(playerid,COLOR_WHITE,szMessage);
							}
						}
					}
					else {
						SendClientMessage(playerid, COLOR_GREY, "You do not have enough materials.");
					}
				}
				case 13: {
					if(playerVariables[playerid][pMaterials] >= 2450) {

						givePlayerValidWeapon(playerid, 34);
						playerVariables[playerid][pMaterials] -= 2450;
						SendClientMessage(playerid, COLOR_WHITE,"You have created a sniper rifle. Type /giveweapon [playerid] to pass the weapon on.");
						format(szMessage, sizeof(szMessage), "* %s has created a sniper rifle from their materials.", szPlayerName);
						nearByMessage( playerid, COLOR_PURPLE, szMessage);
						playerVariables[playerid][pJobSkill][0]++;
						playerVariables[playerid][pJobDelay] = 30;
						switch(playerVariables[playerid][pJobSkill][0]) {
							case 50, 100, 150, 200, 250, 300, 350, 400, 450, 500: {
								format(szMessage,sizeof(szMessage),"Congratulations! Your weapon creation skill level is now %d. You can now create more powerful weapons.",playerVariables[playerid][pJobSkill][0]/50);
								SendClientMessage(playerid,COLOR_WHITE,szMessage);
							}
						}
					}
					else {
						SendClientMessage(playerid, COLOR_GREY, "You do not have enough materials.");
					}
				}
				case 14: {
					if(playerVariables[playerid][pMaterials] >= 2550) {
						givePlayerValidWeapon(playerid, 27);
						playerVariables[playerid][pMaterials] -= 2550;
						SendClientMessage(playerid, COLOR_WHITE, "You have created a SPAS12. Type /giveweapon [playerid] to pass the weapon on.");
						format(szMessage, sizeof(szMessage), "* %s has created a SPAS12 from their materials.", szPlayerName);
						nearByMessage(playerid, COLOR_PURPLE, szMessage);
						playerVariables[playerid][pJobSkill][0]++;
						playerVariables[playerid][pJobDelay] = 30;
						switch(playerVariables[playerid][pJobSkill][0]) {
							case 50, 100, 150, 200, 250, 300, 350, 400, 450, 500: {
								format(szMessage,sizeof(szMessage),"Congratulations! Your weapon creation skill level is now %d. You can now create more powerful weapons.",playerVariables[playerid][pJobSkill][0]/50);
								SendClientMessage(playerid,COLOR_WHITE,szMessage);
							}
						}
					}
					else {
						SendClientMessage(playerid, COLOR_GREY, "You do not have enough materials.");
					}
				}
				case 15: {
					if(playerVariables[playerid][pMaterials] >= 1750) {
						SetPlayerArmour(playerid, 100);
						playerVariables[playerid][pMaterials] -= 1750;
						SendClientMessage(playerid, COLOR_WHITE, "You have created a kevlar vest. Type /givearmour [playerid] to pass it on.");
						format(szMessage, sizeof(szMessage), "* %s has created a kevlar vest from their materials.", szPlayerName);
						nearByMessage(playerid, COLOR_PURPLE, szMessage);
						playerVariables[playerid][pJobSkill][0]++;
						playerVariables[playerid][pJobDelay] = 30;
						switch(playerVariables[playerid][pJobSkill][0]) {
							case 50, 100, 150, 200, 250, 300, 350, 400, 450, 500: {
								format(szMessage,sizeof(szMessage),"Congratulations! Your weapon creation skill level is now %d. You can now create more powerful weapons.",playerVariables[playerid][pJobSkill][0]/50);
								SendClientMessage(playerid,COLOR_WHITE,szMessage);
							}
						}
					}
					else SendClientMessage(playerid, COLOR_GREY, "You do not have enough materials.");
				}
			}
		}
	}
	return 1;
} 

public OnPlayerText(playerid, text[]) {
	#if defined DEBUG
	    printf("[debug] OnPlayerText(%d, %s)", playerid, text);
	#endif

	if(playerVariables[playerid][pStatus] >= 1 && playerVariables[playerid][pMuted] == 0) {
		new
		    iRetStr = strfind(text, "(", true, 0);

		GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
		for(new i = 0; i < strlen(szPlayerName); i++) {
			if(szPlayerName[i] == '_')
			    szPlayerName[i] = ' ';
		}

		if(iRetStr < 4 && iRetStr != -1 && playerVariables[playerid][pAdminDuty] == 0) {
			format(szMessage, sizeof(szMessage), "%s says: (( %s ))", szPlayerName, text);
			nearByMessage(playerid, COLOR_WHITE, szMessage);
			return 1;
		}

		if(playerVariables[playerid][pPhoneCall] != -1) {
			format(szMessage, sizeof(szMessage), "(cellphone) \"%s\"", text);
			SetPlayerChatBubble(playerid, szMessage, COLOR_CHATBUBBLE, 10.0, 10000);
			if(!strcmp(playerVariables[playerid][pAccent], "None", true))
				format(szMessage, sizeof(szMessage), "(cellphone) %s says: %s", szPlayerName, text);
			else
				format(szMessage, sizeof(szMessage), "(cellphone) (%s Accent)%s says: %s", playerVariables[playerid][pAccent], szPlayerName, text);

			nearByMessage(playerid, COLOR_WHITE, szMessage);

			switch (playerVariables[playerid][pPhoneCall]) {
				case 911: {
					if(!strcmp(text, "LSPD", true) || !strcmp(text, "police", true)) {
						SendClientMessage(playerid, COLOR_WHITE, "(cellphone) 911: You have reached the Los Santos Police emergency hotline; can you describe the crime?");
						playerVariables[playerid][pPhoneCall] = 912;
					}
					else if(!strcmp(text, "LSFMD", true) || !strcmp(text, "medic", true) || !strcmp(text, "ambulance", true)) {
						SendClientMessage(playerid, COLOR_WHITE, "(cellphone) 911: This is the Los Santos Fire & Medic Department emergency hotline; describe the emergency, please.");
						playerVariables[playerid][pPhoneCall] = 914;
					}
					else SendClientMessage(playerid, COLOR_WHITE, "(cellphone) 911: Sorry, I didn't quite understand that... speak again?");
				}
				case 912: {
					if(strlen(text) > 1) {
						new
							location[MAX_ZONE_NAME];

						GetPlayer2DZone(playerid, location, MAX_ZONE_NAME);
			            format(szMessage, sizeof(szMessage), "Dispatch: %s has reported: '%s' (10-20 %s)", szPlayerName, text, location);
						SendToGroup(1, COLOR_RADIOCHAT, szMessage);

						SendClientMessage(playerid, COLOR_WHITE, "(cellphone) 911: Thank you for reporting this incident; a patrol unit is now on its way.");

						SendClientMessage(playerid, COLOR_WHITE, "Your call has been terminated by the other party.");

						if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USECELLPHONE) {
							SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);
						}
						playerVariables[playerid][pPhoneCall] = -1;
					}
				}
				case 914: {
					if(strlen(text) > 1) {
						new
							location[MAX_ZONE_NAME];

						GetPlayer2DZone(playerid, location, MAX_ZONE_NAME);
			            format(szMessage, sizeof(szMessage), "Dispatch: %s has reported '%s' (10-20 %s)", szPlayerName, text, location);
						SendToGroupType(4, COLOR_RED, szMessage);

						SendClientMessage(playerid, COLOR_WHITE, "(cellphone) 911: Thank you for reporting this incident; we are on our way.");

						SendClientMessage(playerid, COLOR_WHITE, "Your call has been terminated by the other party.");

						if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USECELLPHONE)
							SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);

						playerVariables[playerid][pPhoneCall] = -1;
					}
				}
				default: { // If they're calling a player, this code is executed.
					SendClientMessage(playerVariables[playerid][pPhoneCall], COLOR_GREY, szMessage);
					mysql_real_escape_string(szMessage, szMessage);
					format(szLargeString, sizeof(szLargeString), "INSERT INTO chatlogs (value, playerinternalid) VALUES('%s', '%d')", szMessage, playerVariables[playerid][pInternalID]);
					mysql_query(szLargeString);
				}
			}
		}

		else {
            if(!strcmp(playerVariables[playerid][pAccent], "None", true))
		    	format(szMessage, sizeof(szMessage), "{FFFFFF}%s says: %s", szPlayerName, text);
			else
		    	format(szMessage, sizeof(szMessage), "(%s Accent) {FFFFFF}%s says: %s", playerVariables[playerid][pAccent], szPlayerName, text);

		    if(playerVariables[playerid][pAdminDuty] >= 1) format(szMessage, sizeof(szMessage), "%s says: (( %s ))", szPlayerName, text);
			nearByMessage(playerid, COLOR_GREY, szMessage);
			mysql_real_escape_string(szMessage, szMessage);
			format(szLargeString, sizeof(szLargeString), "INSERT INTO chatlogs (value, playerinternalid) VALUES('%s', '%d')", szMessage, playerVariables[playerid][pInternalID]);
			mysql_query(szLargeString);
			format(szMessage, sizeof(szMessage), "\"%s\"", text);
			SetPlayerChatBubble(playerid, szMessage, COLOR_CHATBUBBLE, 10.0, 10000);
		}

		playerVariables[playerid][pSpamCount]++;
	}
	return 0;
} 