CMD:elevator(playerid, params[]) {
	if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] == 1) {
		if(IsPlayerInRangeOfPoint(playerid, 1, 276.0980, 122.1232, 1004.6172)) { // Interior
			ShowPlayerDialog(playerid, DIALOG_ELEVATOR3, DIALOG_STYLE_LIST, "Elevator", "Upper Roof\nLower Roof\nGarage", "Select", "Cancel");
		}
		else if(IsPlayerInRangeOfPoint(playerid, 1, 1568.6676, -1689.9708, 6.2188)) { // Garage
			ShowPlayerDialog(playerid, DIALOG_ELEVATOR2, DIALOG_STYLE_LIST, "Elevator", "Upper Roof\nLower Roof\nInterior", "Select", "Cancel");
		}
		else if(IsPlayerInRangeOfPoint(playerid, 1, 1564.8, -1666.2, 28.3)) { // Lower roof
			ShowPlayerDialog(playerid, DIALOG_ELEVATOR1, DIALOG_STYLE_LIST, "Elevator", "Upper Roof\nInterior\nGarage", "Select", "Cancel");
		}
		else if(IsPlayerInRangeOfPoint(playerid, 1, 1564.6584,-1670.2607,52.4503)) { // Upper roof
			ShowPlayerDialog(playerid, DIALOG_ELEVATOR4, DIALOG_STYLE_LIST, "Elevator", "Lower Roof\nInterior\nGarage", "Select", "Cancel");
		}
	}
	return 1;
}

CMD:gate(playerid, params[]) {
	if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] == 1) {
		if(IsPlayerInRangeOfPoint(playerid, 15.0, 1544.6, -1630.8, 13.0)) switch(LSPDGates[0][1]) {
			case 0: {
				SetDynamicObjectRot(LSPDGates[0][0],0.0, 0, 90.0);
				LSPDGates[0][1] = 1;
			}
			case 1: {
				SetDynamicObjectRot(LSPDGates[0][0],0.0, 90.0, 90.0);
				LSPDGates[0][1] = 0;
			}
		}
		else if(IsPlayerInRangeOfPoint(playerid, 15.0, 1589.19995117,-1637.98498535,14.69999981)) switch (LSPDGates[1][1]) {
			case 0: {
				MoveDynamicObject(LSPDGates[1][0] ,1589.19995117,-1637.98498535,9.69999981, 1.0);
				LSPDGates[1][1] = 1;
				PlayerPlaySoundEx(1035, 1589.19995117,-1637.98498535,14.69999981);
			}
			case 1: {
				MoveDynamicObject(LSPDGates[1][0],1589.19995117,-1637.98498535,14.69999981, 1.0);
				LSPDGates[1][1] = 0;
				PlayerPlaySoundEx(1035, 1589.19995117,-1637.98498535,14.69999981);
			}
		}
	}
	return 1;
}

CMD:shakehand(playerid, params[]) {
	new
	    style,
		id;

    if(GetPlayerState(playerid) != 1)
		return SendClientMessage(playerid, COLOR_GREY, "You can only shake hands while on foot.");
		
    if(playerVariables[playerid][pFreezeTime] != 0)
		return SendClientMessage(playerid, COLOR_GREY, "You can't shake hands while cuffed, tazed, or frozen.");
		
	if(sscanf(params, "ud", id, style))
		return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/shakehand [playerid] [1-9]");
		
 	if(id != INVALID_PLAYER_ID) {
   		if(IsPlayerInRangeOfPlayer(playerid, id, 1.5)) {
     		if(style > 0 && style < 9) {
              	GetPlayerName(id, szPlayerName, MAX_PLAYER_NAME);

	            SetPVarInt(id,"hs",style); // DYNAMICALLY ALLOCATED MEMORY!!11. Nah, this won't be accessed regularly
				SetPVarInt(id,"hsID",playerid); // and won't stay in memory for very long.

	            format(szMessage, sizeof(szMessage), "You have requested to shake hands with %s.", szPlayerName);
	            SendClientMessage(playerid, COLOR_WHITE, szMessage);

           		GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
	            format(szMessage, sizeof(szMessage), "%s is requesting to shake hands with you - type /accept handshake to do so.", szPlayerName);
	            SendClientMessage(id, COLOR_NICESKY, szMessage);
	        }
         	else {
           		SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/shakehand [playerid] [1-8]");
           	}
       	}
       	else {
       		SendClientMessage(playerid, COLOR_GREY, "Please stand closer to them.");
	    }
  	}
    else {
	    SendClientMessage(playerid, COLOR_GREY, "That player is not connected or is not logged in.");
    }
	return 1;
}

CMD:time(playerid, params[]) {
	new
	    time[3];

	gettime(time[0], time[1], time[2]);

	if(time[1] < 10) format(szMessage, sizeof(szMessage), "The current time is %d:0%d (%d seconds).", time[0], time[1], time[2]);
	else format(szMessage, sizeof(szMessage), "The current time is %d:%d (%d seconds).", time[0], time[1], time[2]);

	SendClientMessage(playerid, COLOR_WHITE, szMessage);

	format(szMessage, sizeof(szMessage), "Your next paycheck is due in %d minutes (%d seconds).", (3600-playerVariables[playerid][pSeconds])/60, (3600-playerVariables[playerid][pSeconds]));
	SendClientMessage(playerid, COLOR_WHITE, szMessage);

	if(playerVariables[playerid][pDropCarTimeout] >= 1) {
		format(szMessage, sizeof(szMessage), "You will be able to drop vehicles at the crane again in %d seconds (%d minutes).", playerVariables[playerid][pDropCarTimeout], playerVariables[playerid][pDropCarTimeout]/60);
		SendClientMessage(playerid, COLOR_WHITE, szMessage);
	}
	return 1;
}

CMD:cancelbackup(playerid, params[]) {
	if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] == 1) {
	    DeletePVar(playerid, "rB");
	    SendClientMessage(playerid, COLOR_WHITE, "You have canceled your backup request.");
	}
	return 1;
}

CMD:backup(playerid, params[]) {
	if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] == 1) {
		new
			string[113];

		GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);

	    format(string, sizeof(string), "Dispatch: %s is requesting for immediate backup (( '/acceptbackup %d' to take the call )).", szPlayerName, playerid);
	    SendToGroup(playerVariables[playerid][pGroup], COLOR_RADIOCHAT, string);

	    SetPVarInt(playerid, "rB", 1); // Unlike the backup var (which will be called repeatedly) this will only be looked up when someone uses /acceptbackup.
	}
	return 1;
}

CMD:acceptbackup(playerid, params[]) {
	if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] == 1) {
		if(sscanf(params, "u", iTarget))
			SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/acceptbackup [playerid]");

		else if(playerVariables[iTarget][pStatus] == 1) {
			if(playerVariables[playerid][pCheckpoint] == 0 || playerVariables[playerid][pCheckpoint] == 5) {
				if(GetPVarInt(iTarget, "rB") == 1) {

					GetPlayerName(iTarget, szPlayerName, MAX_PLAYER_NAME);
					format(szMessage, sizeof(szMessage), "You have responded to %s's backup call.", szPlayerName);
					SendClientMessage(playerid, COLOR_WHITE, szMessage);

					playerVariables[playerid][pCheckpoint] = 5;
					playerVariables[playerid][pBackup] = iTarget;

                    GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
					format(szMessage, sizeof(szMessage), "%s has responded to your backup call.", szPlayerName);
					SendClientMessage(iTarget, COLOR_WHITE, szMessage);
				}
				else SendClientMessage(playerid, COLOR_GREY, "Invalid backup call specified.");
			}
			else {
				format(szMessage, sizeof(szMessage), "You already have an active checkpoint (%s), reach it first, or /killcheckpoint.", getPlayerCheckpointReason(playerid));
				SendClientMessage(playerid, COLOR_GREY, szMessage);
			}
		}
		else SendClientMessage(playerid, COLOR_GREY, "Invalid backup call specified.");
	}
	return 1;
}

CMD:wt(playerid, params[]) {
    if(isnull(params))
        return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/wt [message]");

	else if(playerVariables[playerid][pFreezeType] > 0) {
		return SendClientMessage(playerid, COLOR_GREY, "You can't use this command while cuffed, tazed, or frozen.");
	}
    else switch(playerVariables[playerid][pWalkieTalkie]) {
		case -1: SendClientMessage(playerid, COLOR_GREY, "You don't have a walkie talkie.");
		case 0: SendClientMessage(playerid, COLOR_GREY, "You need to set a broadcast frequency first (using /setfrequency).");
		default: {
			GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
			format(szMessage, sizeof(szMessage), "(Walkie Talkie) %s: %s", szPlayerName, params);
			SendToFrequency(playerVariables[playerid][pWalkieTalkie], COLOR_SMS, szMessage);
			format(szMessage ,sizeof(szMessage),"(radio) ''%s''", params);
			SetPlayerChatBubble(playerid, szMessage, COLOR_CHATBUBBLE, 10.0, 10000);
	    }
	}
	return 1;
}

CMD:setfrequency(playerid, params[]) {
	if(isnull(params))
		return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/setfrequency [frequency] (0 to switch off).");

	else if(playerVariables[playerid][pWalkieTalkie] == -1) {
		return SendClientMessage(playerid, COLOR_GREY, "You don't have a walkie talkie.");
	}

	new
		walkieFreq = strval(params);

	if(walkieFreq < 0)
		return SendClientMessage(playerid, COLOR_GREY, "Invalid frequency specified.");

	else switch(walkieFreq) {
		case 0: {
			SendClientMessage(playerid, COLOR_GREY, "You have switched off your walkie talkie.");
			playerVariables[playerid][pWalkieTalkie] = 0;
		}
		default: {
			format(szMessage, sizeof(szMessage), "You are now broadcasting at the frequency of #%d khz.", walkieFreq);
			SendClientMessage(playerid, COLOR_WHITE, szMessage);
			playerVariables[playerid][pWalkieTalkie] = walkieFreq;
		}
	}
	return 1;
}

CMD:g(playerid, params[]) {
	return cmd_group(playerid, params);
}

CMD:group(playerid, params[]) {
	if(playerVariables[playerid][pStatus] != 1 || playerVariables[playerid][pGroup] < 1)
		return SendClientMessage(playerid, COLOR_GREY, "Your group data is invalid.");

	if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] == 1 || groupVariables[playerVariables[playerid][pGroup]][gGroupType] == 2)
	    return SendClientMessage(playerid, COLOR_GREY, "This group does not have an OOC chat.");

	if(isnull(params))
		return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/g(roup) [message]");

	if(playerVariables[playerid][pFreezeType] > 0)
		return SendClientMessage(playerid, COLOR_GREY, "You can't use this command while cuffed, tazed, or frozen.");

 	GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);

	switch(playerVariables[playerid][pGroupRank]) {
		case 1:	format(szMessage, sizeof(szMessage), "(Group Chat) %s %s: %s", groupVariables[playerVariables[playerid][pGroup]][gGroupRankName1], szPlayerName, params);
		case 2:	format(szMessage, sizeof(szMessage), "(Group Chat) %s %s: %s", groupVariables[playerVariables[playerid][pGroup]][gGroupRankName2], szPlayerName, params);
		case 3:	format(szMessage, sizeof(szMessage), "(Group Chat) %s %s: %s", groupVariables[playerVariables[playerid][pGroup]][gGroupRankName3], szPlayerName, params);
		case 4:	format(szMessage, sizeof(szMessage), "(Group Chat) %s %s: %s", groupVariables[playerVariables[playerid][pGroup]][gGroupRankName4], szPlayerName, params);
		case 5:	format(szMessage, sizeof(szMessage), "(Group Chat) %s %s: %s", groupVariables[playerVariables[playerid][pGroup]][gGroupRankName5], szPlayerName, params);
		case 6:	format(szMessage, sizeof(szMessage), "(Group Chat) %s %s: %s", groupVariables[playerVariables[playerid][pGroup]][gGroupRankName6], szPlayerName, params);
		default: format(szMessage, sizeof(szMessage), "(Group Chat) %s %s: %s", groupVariables[playerVariables[playerid][pGroup]][gGroupRankName1], szPlayerName, params);
	}

    SendToGroup(playerVariables[playerid][pGroup], COLOR_DCHAT, szMessage);
	return 1;
}

CMD:r(playerid, params[]) return cmd_radio(playerid, params);
CMD:radio(playerid, params[]) 
{
	if(playerVariables[playerid][pStatus] != 1 || playerVariables[playerid][pGroup] < 1)
		return SendClientMessage(playerid, COLOR_GREY, "Your group data is invalid.");

	if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] != 1 && groupVariables[playerVariables[playerid][pGroup]][gGroupType] != 2) {
	    return SendClientMessage(playerid, COLOR_GREY, "This group does not have an official radio frequency.");
	}

	if(isnull(params))
		return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/g(roup) [message]");

	if(playerVariables[playerid][pFreezeType] > 0)
		return SendClientMessage(playerid, COLOR_GREY, "You can't use this command while cuffed, tazed, or frozen.");

	GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);

	switch(playerVariables[playerid][pGroupRank]) {
		case 1:	format(szMessage, sizeof(szMessage), "** %s %s: %s, over.", groupVariables[playerVariables[playerid][pGroup]][gGroupRankName1], szPlayerName, params);
		case 2:	format(szMessage, sizeof(szMessage), "** %s %s: %s, over.", groupVariables[playerVariables[playerid][pGroup]][gGroupRankName2], szPlayerName, params);
		case 3:	format(szMessage, sizeof(szMessage), "** %s %s: %s, over.", groupVariables[playerVariables[playerid][pGroup]][gGroupRankName3], szPlayerName, params);
		case 4:	format(szMessage, sizeof(szMessage), "** %s %s: %s, over.", groupVariables[playerVariables[playerid][pGroup]][gGroupRankName4], szPlayerName, params);
		case 5:	format(szMessage, sizeof(szMessage), "** %s %s: %s, over.", groupVariables[playerVariables[playerid][pGroup]][gGroupRankName5], szPlayerName, params);
		case 6:	format(szMessage, sizeof(szMessage), "** %s %s: %s, over.", groupVariables[playerVariables[playerid][pGroup]][gGroupRankName6], szPlayerName, params);
		default: format(szMessage, sizeof(szMessage), "** %s %s: %s, over.", groupVariables[playerVariables[playerid][pGroup]][gGroupRankName1], szPlayerName, params);
	}

    SendToGroup(playerVariables[playerid][pGroup], COLOR_RADIOCHAT, szMessage);
    format(szMessage, sizeof(szMessage),"(radio) ''%s''", params);
    SetPlayerChatBubble(playerid, szMessage, COLOR_CHATBUBBLE, 10.0, 10000);
	return 1;
}

CMD:d(playerid, params[]) return cmd_department(playerid, params);
CMD:department(playerid, params[]) 
{
	if(playerVariables[playerid][pStatus] != 1 || playerVariables[playerid][pGroup] < 1)
		return SendClientMessage(playerid, COLOR_GREY, "Your group data is invalid.");

	if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] != 1 && groupVariables[playerVariables[playerid][pGroup]][gGroupType] != 2) {
	    return SendClientMessage(playerid, COLOR_GREY, "This group does not have an official radio frequency.");
	}

	if(playerVariables[playerid][pFreezeType] > 0) {
		return SendClientMessage(playerid, COLOR_GREY, "You can't use this command while cuffed, tazed, or frozen.");
	}

	if(isnull(params))
		return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/d(epartment) [message]");

 	GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);

	switch(playerVariables[playerid][pGroupRank]) {
		case 1:	format(szMessage, sizeof(szMessage), "*** %s %s: %s, over.", groupVariables[playerVariables[playerid][pGroup]][gGroupRankName1], szPlayerName, params);
		case 2:	format(szMessage, sizeof(szMessage), "*** %s %s: %s, over.", groupVariables[playerVariables[playerid][pGroup]][gGroupRankName2], szPlayerName, params);
		case 3:	format(szMessage, sizeof(szMessage), "*** %s %s: %s, over.", groupVariables[playerVariables[playerid][pGroup]][gGroupRankName3], szPlayerName, params);
		case 4:	format(szMessage, sizeof(szMessage), "*** %s %s: %s, over.", groupVariables[playerVariables[playerid][pGroup]][gGroupRankName4], szPlayerName, params);
		case 5:	format(szMessage, sizeof(szMessage), "*** %s %s: %s, over.", groupVariables[playerVariables[playerid][pGroup]][gGroupRankName5], szPlayerName, params);
		case 6:	format(szMessage, sizeof(szMessage), "*** %s %s: %s, over.", groupVariables[playerVariables[playerid][pGroup]][gGroupRankName6], szPlayerName, params);
		default: format(szMessage, sizeof(szMessage), "*** %s %s: %s, over.", groupVariables[playerVariables[playerid][pGroup]][gGroupRankName1], szPlayerName, params);
	}

    sendDepartmentMessage(COLOR_DCHAT, szMessage);
    format(szMessage, sizeof(szMessage), "(radio) ''%s''",params);
    SetPlayerChatBubble(playerid, szMessage, COLOR_CHATBUBBLE, 10.0, 10000);
	return 1;
}

CMD:unsuspendbank(playerid, params[]) {
	if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] == 2 && playerVariables[playerid][pGroup] != 0) {
		if(playerVariables[playerid][pGroupRank] > 4) {
		    if(isnull(params))
		        return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/unsuspendbank [player name]");

			strcpy(szPlayerName, params, MAX_PLAYER_NAME);
			mysql_real_escape_string(szPlayerName, szPlayerName);

		    iTarget = getIdFromName(szPlayerName);

			if(iTarget == -1)
				return SendClientMessage(playerid, COLOR_GREY, "Error attempting to retrieve an ID from the name.");

			format(szQueryOutput, sizeof(szQueryOutput), "DELETE FROM `banksuspensions` WHERE `playerID` = %d", iTarget);
			mysql_query(szQueryOutput);

			foreach(Player, x) {
				if(playerVariables[x][pInternalID] == iTarget) {
					DeletePVar(x, "BSuspend");
					DeletePVar(x, "BSuspendee");
				}
			}

			format(szMessage, sizeof(szMessage), "You've unsuspended %s's account.", szPlayerName);
			SendClientMessage(playerid, COLOR_WHITE, szMessage);
		}
	}
	return 1;
}

CMD:suspendbank(playerid, params[]) {
	if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] == 2 && playerVariables[playerid][pGroup] != 0) {
		if(playerVariables[playerid][pGroupRank] > 4) {
		    new
		        szReason[64];

		    if(sscanf(params, "us[64]", iTarget, szReason))
		        return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/suspendbank [playerid] [reason]");

            if(playerVariables[iTarget][pGroupRank] > 4 && groupVariables[playerVariables[iTarget][pGroup]][gGroupType] != 0)
                return SendClientMessage(playerid, COLOR_GREY, "Clearance failure.");

			mysql_real_escape_string(szReason, szReason);
			format(szQueryOutput, sizeof(szQueryOutput), "INSERT INTO `banksuspensions` (`suspendeeID`, `playerID`, `suspensionReason`) VALUES(%d, %d, '%e')", playerVariables[playerid][pInternalID], playerVariables[iTarget][pInternalID], szReason);
			mysql_query(szQueryOutput);

			SetPVarString(iTarget, "BSuspend", szReason);

			GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
			SetPVarString(iTarget, "BSuspendee", szPlayerName);

			GetPlayerName(iTarget, szPlayerName, MAX_PLAYER_NAME);
			format(szMessage, sizeof(szMessage), "You have successfully suspended the bank account of %s.", szPlayerName);
			SendClientMessage(playerid, COLOR_WHITE, szMessage);
		}
	}

	return 1;
}

CMD:taxrate(playerid, params[]) {
	if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] == 2 && playerVariables[playerid][pGroup] != 0) {
		if(playerVariables[playerid][pGroupRank] > 4) {
			if(!isnull(params)) {

			    new rate = strval(params);

			    if(rate > 0 && rate <= 50) {

				    new string[41];
				    format(string,sizeof(string),"You have set the tax rate to %d percent.",rate);
					SendClientMessage(playerid, COLOR_WHITE, string);
				    assetVariables[1][aAssetValue] = rate;

					saveAsset(1);
			    }
			    else SendClientMessage(playerid, COLOR_GREY, "The tax rate must be between 1 and 50 percent.");
			}
			else SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/taxrate [percentage]");
		}
		else SendClientMessage(playerid, COLOR_GREY, "You're not authorised to do this.");
	}
	return 1;
}

CMD:gov(playerid, params[]) {

	new
		string[128];

	if(isnull(params)) SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/gov [message]");

	else if((groupVariables[playerVariables[playerid][pGroup]][gGroupType] == 1 || groupVariables[playerVariables[playerid][pGroup]][gGroupType] == 2) && playerVariables[playerid][pGroupRank] > 4)
	{
		format(string, sizeof(string), "------ Government Announcement (%s) ------", groupVariables[playerVariables[playerid][pGroup]][gGroupName]);
		SendClientMessageToAll(COLOR_TEAL, string);

		GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
		switch(playerVariables[playerid][pGroupRank]) {
			case 5: format(string, sizeof(string), "* %s %s: %s", groupVariables[playerVariables[playerid][pGroup]][gGroupRankName5], szPlayerName, params);
			case 6: format(string, sizeof(string), "* %s %s: %s", groupVariables[playerVariables[playerid][pGroup]][gGroupRankName6], szPlayerName, params);
		}
		SendClientMessageToAll(COLOR_WHITE, string);
		format(string, sizeof(string), "------ Government Announcement (%s) ------", groupVariables[playerVariables[playerid][pGroup]][gGroupName]);
		SendClientMessageToAll(COLOR_TEAL, string);
	}
	return 1;
}

CMD:bbalance(playerid, params[]) {
	if(getPlayerBusinessID(playerid) >= 1) {
	    new
	        businessID = getPlayerBusinessID(playerid);

	    format(szMessage, sizeof(szMessage), "Business Vault Balance: $%d.", businessVariables[businessID][bVault]);
	    SendClientMessage(playerid, COLOR_WHITE, szMessage);
	}
	return 1;
}

CMD:gdeposit(playerid, params[])
{
    if(playerVariables[playerid][pStatus] != 1) return 1;
    if(playerVariables[playerid][pGroup] != 0) {

		new
			item[9],
			string[64],
			amount;

		if(sscanf(params, "sd", item, amount)) {
			SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/gdeposit [money/materials] [amount]");

			format(string, sizeof(string), "Safe balance: $%d, %d materials.", groupVariables[playerVariables[playerid][pGroup]][gSafe][0], groupVariables[playerVariables[playerid][pGroup]][gSafe][1]);
			SendClientMessage(playerid, COLOR_GREY, string);
		}
		else {
		    if(amount > 0) {
			    if(IsPlayerInRangeOfPoint(playerid, 5.0, groupVariables[playerVariables[playerid][pGroup]][gSafePos][0], groupVariables[playerVariables[playerid][pGroup]][gSafePos][1], groupVariables[playerVariables[playerid][pGroup]][gSafePos][2])) {
			        if(strcmp(item, "money", true) == 0) {
						if(playerVariables[playerid][pMoney] >= amount) {
					    	playerVariables[playerid][pMoney] -= amount;
					    	groupVariables[playerVariables[playerid][pGroup]][gSafe][0] += amount;
					    	format(string, sizeof(string), "You have deposited $%d in your group safe.", amount);
				    		SendClientMessage(playerid, COLOR_WHITE, string);
				    		saveGroup(playerVariables[playerid][pGroup]);

							GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
							format(string, sizeof(string), "* %s deposits $%d in their group safe.", szPlayerName, amount);
							nearByMessage(playerid, COLOR_PURPLE, string);
						}
						else {
					    	SendClientMessage(playerid, COLOR_WHITE, "You don't have that amount of money.");
						}
					}
					else if(strcmp(item, "materials", true) == 0 ) {
						if(playerVariables[playerid][pMaterials] >= amount) {
					    	playerVariables[playerid][pMaterials] -= amount;
					    	groupVariables[playerVariables[playerid][pGroup]][gSafe][1] += amount;
					    	format(string, sizeof(string), "You have deposited %d materials in your group safe.", amount);
				    		SendClientMessage(playerid, COLOR_WHITE, string);
				    		saveGroup(playerVariables[playerid][pGroup]);

							GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
							format(string, sizeof(string), "* %s deposits %d materials in their group safe.", szPlayerName, amount);
							nearByMessage(playerid, COLOR_PURPLE, string);
						}
						else {
					    	SendClientMessage(playerid, COLOR_WHITE, "You don't have that amount of materials.");
						}
					}
				}
				else {
				    SendClientMessage(playerid, COLOR_WHITE, "You must be at your group safe to do this.");
				}
			}
		}
	}
	return 1;
}

CMD:accepthelp(playerid, params[]) {
    if(playerVariables[playerid][pHelper] >= 1) {
        if(sscanf(params, "u", iTarget))
            return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/accepthelp [playerid]");

        else {
            if(iTarget == INVALID_PLAYER_ID)
				return SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");

            if(GetPVarType(iTarget, "hR") == 0)
				return SendClientMessage(playerid, COLOR_GREY, "The specified playerid/name does not have an active help request.");

            new
                helpString[64];

            GetPVarString(iTarget, "hR", helpString, sizeof(helpString));

            GetPlayerName(iTarget, szPlayerName, MAX_PLAYER_NAME);

            format(szMessage, sizeof(szMessage), "You have accepted %s's help request (%s).", szPlayerName, helpString);
            SendClientMessage(playerid, COLOR_WHITE, szMessage);

            playerVariables[playerid][pOnRequest] = iTarget; // PVar lookup time is slower, better to use a variable for this.

            TextDrawShowForPlayer(playerid, textdrawVariables[1]);

            DeletePVar(iTarget, "hR");

            GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
            format(szMessage, sizeof(szMessage), "%s has accepted your help request.", szPlayerName);
            SendClientMessage(iTarget, COLOR_NEWBIE, szMessage);
        }
    }
	return 1;
}

CMD:viewhelp(playerid, params[]) {
    if(playerVariables[playerid][pHelper] >= 1) {
        SendClientMessage(playerid, COLOR_TEAL, "---------------------------------------------------------------------------------------------------------------------------------");
        foreach(Player, x) {
			if(GetPVarType(x, "hR") != 0) {
			    GetPVarString(x, "hR", szMediumString, sizeof(szMediumString));
				format(szMessage, sizeof(szMessage), "Requested by: %s | Problem: %s", playerVariables[x][pNormalName], szMediumString);
				SendClientMessage(playerid, COLOR_WHITE, szMessage);
			}
		}
        SendClientMessage(playerid, COLOR_TEAL, "---------------------------------------------------------------------------------------------------------------------------------");
	}
	return 1;
}

CMD:helpme(playerid, params[]) {
	if(playerVariables[playerid][pPlayingHours] < 20) {
	    if(isnull(params))
			return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/helpme [subject]");
			
	    if(strlen(params) >= 63) {
			return SendClientMessage(playerid, COLOR_GREY, "Your message was too long. 62 characters or lower, only.");
		} else {
			SetPVarString(playerid, "hR", params);
			SendClientMessage(playerid, COLOR_WHITE, "Your request has been sent. Please wait a few minutes, our helpers have a lot to deal with!");

			new
			    string[128];

			GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);

			format(string, sizeof(string), "A new help request from %s (ID: %d) has been submitted.", szPlayerName);

			foreach(Player, x) {
				if(playerVariables[x][pHelperDuty] >= 1 && playerVariables[x][pHelper] >= 1) {
					SendClientMessage(x, COLOR_NEWBIE, string);
				}
			}
		}
	}
	else {
		return SendClientMessage(playerid, COLOR_GREY, "You already have 20+ playing hours. You are unable to get help from a helper, please use /n for your questions.");
	}

	return 1;
}

CMD:helperduty(playerid, params[]) {
	if(playerVariables[playerid][pHelper] >= 1) {
	    switch(playerVariables[playerid][pHelperDuty]) {
			case 0: {
				playerVariables[playerid][pHelperDuty] = 1;
				SendClientMessage(playerid, COLOR_WHITE, "You are now on duty as a Helper.");
			}
			case 1: {
				playerVariables[playerid][pHelperDuty] = 0;
				SendClientMessage(playerid, COLOR_WHITE, "You are now off duty as a Helper.");
			}
		}
	}
	return 1; //
}

CMD:vgroup(playerid, params[]) {
	if(playerVariables[playerid][pAdminLevel] >= 4) {
	    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_GREY, "You must be inside the vehicle that you wish to alter the group requirement of.");

		new
			string[96],
		    groupParam = strval(params);

		if(groupParam < 0 || groupParam > MAX_GROUPS) return SendClientMessage(playerid, COLOR_GREY, "Invalid group ID.");

        for(new x = 0; x < MAX_VEHICLES; x++) {
            if(vehicleVariables[x][vVehicleScriptID] == GetPlayerVehicleID(playerid)) {
                vehicleVariables[x][vVehicleGroup] = groupParam;

                saveVehicle(x);

                switch(groupParam) {

					case 0: format(string, sizeof(string), "You have removed group restrictions from this vehicle (%d).", x);
					default: format(string, sizeof(string), "You have changed this vehicle's group to %s (vehicle %d).", groupVariables[groupParam][gGroupName], x);
				}
				SendClientMessage(playerid, COLOR_WHITE, string);
				return 1;
			}
        }
	}
	return 1;
}

CMD:vcolour(playerid, params[]) {
	if(playerVariables[playerid][pAdminLevel] >= 4) {
	    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_GREY, "You must be inside the vehicle that you wish to alter the colour of.");

		new
			string[80],
		    colour1,
			colour2;

		if(sscanf(params,"dd", colour1, colour2)) return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/vcolour [colour 1] [colour 2]");

        for(new x = 0; x < MAX_VEHICLES; x++) {
            if(vehicleVariables[x][vVehicleScriptID] == GetPlayerVehicleID(playerid)) {
                vehicleVariables[x][vVehicleColour][0] = colour1;
				vehicleVariables[x][vVehicleColour][1] = colour2;

				ChangeVehicleColor(vehicleVariables[x][vVehicleScriptID], vehicleVariables[x][vVehicleColour][0], vehicleVariables[x][vVehicleColour][1]);

                saveVehicle(x);

				format(string, sizeof(string), "You have changed this vehicle's colour combination to %d, %d (vehicle %d).", colour1, colour2, x);
				SendClientMessage(playerid, COLOR_WHITE, string);
				return 1;
			}
        }
	}
	return 1;
}

CMD:vrespawn(playerid, params[]) {
	if(playerVariables[playerid][pAdminLevel] >= 1 && IsPlayerInAnyVehicle(playerid)) SetVehicleToRespawnEx(GetPlayerVehicleID(playerid));
	return 1;
}

CMD:vmassrespawn(playerid, params[]) {
	if(playerVariables[playerid][pAdminLevel] >= 4) {
		SetAllVehiclesToRespawn();
		SendClientMessage(playerid, COLOR_WHITE, "All vehicles have been respawned.");
	}
	return 1;
}

CMD:vmodel(playerid, params[]) {
	if(playerVariables[playerid][pAdminLevel] >= 4) {
		if(isnull(params)) return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/vmodel [modelid]");
		else if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_GREY, "You must be inside the vehicle that you wish to change the model of.");
		else if(strval(params) < 400 || strval(params) > 611) return SendClientMessage(playerid, COLOR_WHITE, "Valid car IDs start at 400, and end at 611.");

		new
			string[64];

        for(new x = 0; x < MAX_VEHICLES; x++) {
            if(vehicleVariables[x][vVehicleScriptID] == GetPlayerVehicleID(playerid)) {

				vehicleVariables[x][vVehicleModelID] = strval(params);

				DestroyVehicle(vehicleVariables[x][vVehicleScriptID]);
				vehicleVariables[x][vVehicleScriptID] = CreateVehicle(vehicleVariables[x][vVehicleModelID], vehicleVariables[x][vVehiclePosition][0], vehicleVariables[x][vVehiclePosition][1], vehicleVariables[x][vVehiclePosition][2], vehicleVariables[x][vVehicleRotation], vehicleVariables[x][vVehicleColour][0], vehicleVariables[x][vVehicleColour][1], 60000);
				PutPlayerInVehicle(playerid, vehicleVariables[x][vVehicleScriptID], 0);

                saveVehicle(x);

				format(string, sizeof(string), "You have successfully changed vehicle %d to a %s.", x, VehicleNames[vehicleVariables[x][vVehicleModelID] - 400]);
				SendClientMessage(playerid, COLOR_WHITE, string);
				return 1;
			}
        }
	}
	return 1;
}

CMD:vmove(playerid, params[]) {
	if(playerVariables[playerid][pAdminLevel] >= 4) {
	    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_GREY, "You must be inside the vehicle that you wish to move.");

		new
			string[42];

        for(new x = 0; x < MAX_VEHICLES; x++) {
            if(vehicleVariables[x][vVehicleScriptID] == GetPlayerVehicleID(playerid)) {

                GetVehiclePos(x, vehicleVariables[x][vVehiclePosition][0], vehicleVariables[x][vVehiclePosition][1], vehicleVariables[x][vVehiclePosition][2]);
				GetVehicleZAngle(x, vehicleVariables[x][vVehicleRotation]);

				DestroyVehicle(vehicleVariables[x][vVehicleScriptID]);
				vehicleVariables[x][vVehicleScriptID] = CreateVehicle(vehicleVariables[x][vVehicleModelID], vehicleVariables[x][vVehiclePosition][0], vehicleVariables[x][vVehiclePosition][1], vehicleVariables[x][vVehiclePosition][2], vehicleVariables[x][vVehicleRotation], vehicleVariables[x][vVehicleColour][0], vehicleVariables[x][vVehicleColour][1], 60000);
				PutPlayerInVehicle(playerid, vehicleVariables[x][vVehicleScriptID], 0);

                saveVehicle(x);

				format(string, sizeof(string), "You have successfully moved vehicle %d.", x);
				SendClientMessage(playerid, COLOR_WHITE, string);
				return 1;
			}
        }
	}
	return 1;
}

CMD:ad(playerid, params[]) {
	if(!isnull(params)) {
		if(playerVariables[playerid][pPhoneNumber] != -1) {
		    if(adTick == 0) {
				if(playerVariables[playerid][pMoney] >= 1000) {
					new
						adText[128],
						queryString[255];

					mysql_real_escape_string(params, adText);
					format(queryString, sizeof(queryString), "INSERT INTO playeradvertisements (playerID, advertisementText, Time2) VALUES('%d', '%s', '%d')", playerVariables[playerid][pInternalID], adText, gettime());
					mysql_query(queryString);

					GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
					format(queryString, sizeof(queryString), "Advertisement: %s (by %s).", params, szPlayerName);
					SendClientMessageToAll(COLOR_GREEN, queryString);
					playerVariables[playerid][pMoney] -= 1000;
					adTick = 60;
				}
				else SendClientMessage(playerid, COLOR_GREY, "You don't have enough money for this.");
		    }
		    else {
				return SendClientMessage(playerid, COLOR_GREY, "You must wait 60 seconds to post a global advertisement.");
			}
		}
		else {
			return SendClientMessage(playerid, COLOR_GREY, "You don't have a phone, so you're unable to submit an advertisement.");
		}
	}
	else {
		return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/ad [advertisement text]");
	}
	return 1;
}

CMD:deployspike(playerid, params[]) { // Same method as old VX script, though recoded.
	if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] == 1) {
		if(GetPlayerState(playerid) == 1) {

			new
				x = -1,
				string[76];

			for(new i; i < MAX_SPIKES; i++) {
				if(spikeVariables[i][sPos][0] == 0 && spikeVariables[i][sPos][1] == 0 && spikeVariables[i][sPos][2] == 0) {
					x = i;
					break;
				}
			}

			if(x != -1) {

				GetPlayerPos(playerid, spikeVariables[x][sPos][0], spikeVariables[x][sPos][1], spikeVariables[x][sPos][2]);
				GetPlayerFacingAngle(playerid, spikeVariables[x][sPos][3]);

				spikeVariables[x][sObjID] = CreateDynamicObject(2899, spikeVariables[x][sPos][0], spikeVariables[x][sPos][1], spikeVariables[x][sPos][2] - 0.8, 0.0, 0.0, spikeVariables[x][sPos][3], GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), -1, 200.0);
				GetPlayerName(playerid, spikeVariables[x][sDeployer], MAX_PLAYER_NAME);

				format(string, sizeof(string),"You have successfully deployed a spike (ID %d).", x);
				SendClientMessage(playerid, COLOR_WHITE, string);
			}
			else {

				format(string, sizeof(string), "No more spike strips can be deployed (the limit is %d). Destroy some first.", MAX_SPIKES);
				SendClientMessage(playerid, COLOR_GREY, string);
			}
		}
		else SendClientMessage(playerid, COLOR_GREY, "You can only deploy spikes while on foot.");
	}
	return 1;
}

CMD:destroyspike(playerid, params[]) {
	if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] == 1) {

		new
			targetID,
			string[75];

		if(!isnull(params)) {

			targetID = strval(params);

			if(spikeVariables[targetID][sPos][0] != 0 && spikeVariables[targetID][sPos][1] != 0 && spikeVariables[targetID][sPos][2] != 0) {

				DestroyDynamicObject(spikeVariables[targetID][sObjID]);

				for(new i; i < 4; i++) spikeVariables[targetID][sPos][i] = 0;

				spikeVariables[targetID][sObjID] = INVALID_OBJECT_ID;

				format(string, sizeof(string), "You have successfully destroyed spike ID %d.", targetID);
				SendClientMessage(playerid, COLOR_WHITE, string);
			}
			else SendClientMessage(playerid, COLOR_GREY, "Invalid spike specified.");
		}
		else SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/destroyspike [spike]");
	}
	return 1;
}

CMD:spikes(playerid, params[]) {

	if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] == 1 && playerVariables[playerid][pGroupRank] >= 4) {

		new
			dString[128],
			sZone[MAX_ZONE_NAME],
			x,
			y;

		SendClientMessage(playerid, COLOR_TEAL, "---------------------------------------------------------------------------------------------------------------------------------");
		SendClientMessage(playerid, COLOR_WHITE, "Deployed spike strips:");
		for(new i; i < MAX_SPIKES; i++) {
			if(spikeVariables[i][sPos][0] != 0 && spikeVariables[i][sPos][1] != 0 && spikeVariables[i][sPos][2] != 0) {

				Get2DPosZone(spikeVariables[i][sPos][0], spikeVariables[i][sPos][1], sZone, MAX_ZONE_NAME); // Edited a_zones function (GET INCLUDE FROM SVN!!1)
				y++;
				if(x == 0) format(dString, sizeof(dString), "ID %d (%s, deployed by %s)", i, sZone, spikeVariables[i][sDeployer]);
				else format(dString, sizeof(dString), "%s | ID %d (%s, deployed by %s)", dString, i, sZone, spikeVariables[i][sDeployer]);
				x++;

				if(x == 2) {
					SendClientMessage(playerid, COLOR_WHITE, dString);
					x = 0;
				}
			}
		}
		if(x == 1) SendClientMessage(playerid, COLOR_WHITE, dString);
		if(y == 0) SendClientMessage(playerid, COLOR_WHITE, "No spike strips are currently deployed.");
		SendClientMessage(playerid, COLOR_TEAL, "---------------------------------------------------------------------------------------------------------------------------------");
	}
	return 1;
}

CMD:confiscate(playerid, params[])
{
	if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] == 1) {
		new
			targetID,
			string[128],
			item[12],
			playerNames[2][MAX_PLAYER_NAME];

		if(sscanf(params, "us[12]", targetID, item)) {
			SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/confiscate [playerid] [item]");
			SendClientMessage(playerid, COLOR_GREY, "Items: Materials, Phone, Weapons");
		}
		else if(IsPlayerAuthed(targetID)){
			if(IsPlayerInRangeOfPlayer(playerid, targetID, 3.0)) {
				if(playerVariables[targetID][pFreezeType] == 2 || playerVariables[targetID][pFreezeType] == 4 || (GetPlayerSpecialAction(targetID) == SPECIAL_ACTION_HANDSUP && playerVariables[targetID][pFreezeType] == 0)) {
					if(!strcmp(item, "materials", true)) {
						if(playerVariables[targetID][pMaterials] >= 1) {

							GetPlayerName(playerid, playerNames[0], MAX_PLAYER_NAME);
							GetPlayerName(targetID, playerNames[1], MAX_PLAYER_NAME);

							format(string, sizeof(string), "* %s has confiscated %d materials from %s.", playerNames[0], playerVariables[targetID][pMaterials], playerNames[1]);
							nearByMessage(playerid, COLOR_PURPLE, string);

							format(string, sizeof(string), "%s has confiscated your materials.", playerNames[0]);
							SendClientMessage(targetID, COLOR_WHITE, string);

							format(string, sizeof(string), "You have confiscated %s's materials (%d).", playerNames[1], playerVariables[targetID][pMaterials]);
							SendClientMessage(playerid, COLOR_WHITE, string);

							playerVariables[playerid][pMaterials] += playerVariables[targetID][pMaterials];
							playerVariables[targetID][pMaterials] = 0;
						}
						else SendClientMessage(playerid, COLOR_GREY, "This player has no materials to confiscate.");

					}
					else if(!strcmp(item, "weapons", true)) {

						GetPlayerName(playerid, playerNames[0], MAX_PLAYER_NAME);
						GetPlayerName(targetID, playerNames[1], MAX_PLAYER_NAME);

						format(string, sizeof(string), "* %s has confiscated %s's weapons.", playerNames[0], playerNames[1]);
						nearByMessage(playerid, COLOR_PURPLE, string);

						format(string, sizeof(string), "%s has confiscated your weapons.", playerNames[0]);
						SendClientMessage(targetID, COLOR_WHITE, string);

						format(string, sizeof(string), "You have confiscated %s's weapons.", playerNames[1]);
						SendClientMessage(playerid, COLOR_WHITE, string);

						validResetPlayerWeapons(targetID);
					}
					else if(!strcmp(item, "phone", true)) {
						if(playerVariables[targetID][pPhoneNumber] != -1) {

							GetPlayerName(playerid, playerNames[0], MAX_PLAYER_NAME);
							GetPlayerName(targetID, playerNames[1], MAX_PLAYER_NAME);

							format(string, sizeof(string), "* %s has confiscated %s's phone.", playerNames[0], playerNames[1]);
							nearByMessage(playerid, COLOR_PURPLE, string);

							format(string, sizeof(string), "%s has confiscated your phone.", playerNames[0]);
							SendClientMessage(targetID, COLOR_WHITE, string);

							format(string, sizeof(string), "You have confiscated %s's phone.", playerNames[1]);
							SendClientMessage(playerid, COLOR_WHITE, string);

							playerVariables[targetID][pPhoneNumber] = -1;
						}
						else SendClientMessage(playerid, COLOR_GREY, "This player has no phone to confiscate.");
					}
					else SendClientMessage(playerid, COLOR_GREY, "Invalid item specified.");
				}
				else SendClientMessage(playerid, COLOR_GREY, "That person must first be subdued, or have their hands up.");
			}
			else SendClientMessage(playerid, COLOR_GREY, "You're too far away.");
		}
		else SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");
	}
	return 1;
}

CMD:gwithdraw(playerid, params[]) {
    if(playerVariables[playerid][pStatus] != 1) return 1;
    if(playerVariables[playerid][pGroup] != 0 && playerVariables[playerid][pGroupRank] >= 5) {

		new
			item[9],
			string[64],
			amount;

		if(sscanf(params, "sd", item, amount)) {
			SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/gwithdraw [money/materials] [amount]");

			format(string, sizeof(string), "Safe balance: $%d, %d materials.", groupVariables[playerVariables[playerid][pGroup]][gSafe][0], groupVariables[playerVariables[playerid][pGroup]][gSafe][1]);
			SendClientMessage(playerid, COLOR_GREY, string);
		}
		else {
		    if(amount > 0) {
			    if(IsPlayerInRangeOfPoint(playerid, 5.0, groupVariables[playerVariables[playerid][pGroup]][gSafePos][0], groupVariables[playerVariables[playerid][pGroup]][gSafePos][1], groupVariables[playerVariables[playerid][pGroup]][gSafePos][2])) {
			        if(strcmp(item, "money", true) == 0) {
						if(groupVariables[playerVariables[playerid][pGroup]][gSafe][0] >= amount) {
					    	playerVariables[playerid][pMoney] += amount;
					    	groupVariables[playerVariables[playerid][pGroup]][gSafe][0] -= amount;
					    	format(string, sizeof(string), "You have withdrawn $%d from your group safe.", amount);
				    		SendClientMessage(playerid, COLOR_WHITE, string);
				    		saveGroup(playerVariables[playerid][pGroup]);

							GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
							format(string, sizeof(string), "* %s withdraws $%d from their group safe.", szPlayerName, amount);
							nearByMessage(playerid, COLOR_PURPLE, string);
						}
						else {
					    	SendClientMessage(playerid, COLOR_WHITE, "You don't have that amount of money in your group safe.");
						}
					}
					else if(strcmp(item, "materials", true) == 0 ) {
						if(groupVariables[playerVariables[playerid][pGroup]][gSafe][1] >= amount) {
					    	playerVariables[playerid][pMaterials] += amount;
					    	groupVariables[playerVariables[playerid][pGroup]][gSafe][1] -= amount;
					    	format(string, sizeof(string), "You have withdrawn %d materials from your group safe.", amount);
				    		SendClientMessage(playerid, COLOR_WHITE, string);
				    		saveGroup(playerVariables[playerid][pGroup]);

							GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
							format(string, sizeof(string), "* %s withdraws %d materials from their group safe.", szPlayerName, amount);
							nearByMessage(playerid, COLOR_PURPLE, string);
						}
						else {
					    	SendClientMessage(playerid, COLOR_WHITE, "Your don't have that amount of materials in your group safe.");
						}
					}
				}
				else {
				    SendClientMessage(playerid, COLOR_WHITE, "You must be at your group safe to do this.");
				}
			}
		}
	}
	return 1;
}

CMD:killcheckpoint(playerid, params[]) {
	DisablePlayerCheckpoint(playerid);
	playerVariables[playerid][pCheckpoint] = 0;
	playerVariables[playerid][pBackup] = -1;
	SendClientMessage(playerid, COLOR_WHITE,"You have disabled your current checkpoint.");
	return 1;
}

CMD:swatinv(playerid,params[]) {
	if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] == 1 && playerVariables[playerid][pGroup] != 0) {

		if(playerVariables[playerid][pGroupRank] > 3) {
			new string[64];
			GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
			if(groupVariables[playerVariables[playerid][pGroup]][gswatInv] == 0) {
				groupVariables[playerVariables[playerid][pGroup]][gswatInv] = 1;
				format(string, sizeof(string), "The SWAT inventory has been enabled by %s.", szPlayerName);
				SendToGroup(playerVariables[playerid][pGroup], COLOR_HOTORANGE, string);
			}
			else {
				groupVariables[playerVariables[playerid][pGroup]][gswatInv] = 0;
				format(string, sizeof(string), "The SWAT inventory has been disabled by %s.", szPlayerName);
				SendToGroup(playerVariables[playerid][pGroup], COLOR_HOTORANGE, string);
			}
		}
	}
	return 1;
}

CMD:tazer(playerid, params[]) {
	if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] == 1 && playerVariables[playerid][pGroup] != 0) {
	    switch(playerVariables[playerid][pTazer]) {
			case 0: {
			    givePlayerValidWeapon(playerid, 22);
			    playerVariables[playerid][pTazer] = 1;
			}
			case 1: {
			    removePlayerWeapon(playerid, 22);
			    playerVariables[playerid][pTazer] = 0;
			}
		}
	}
	return 1;
}

CMD:taser(playerid, params[]) {
	return cmd_tazer(playerid, params);
}

CMD:setplayervehicle(playerid, params[]) {
	if(playerVariables[playerid][pAdminLevel] >= 3) {
		new
			string[64],
		    carModelID,
		    targetID;

		if(sscanf(params, "ud", targetID, carModelID)) return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/setplayervehicle [playerid] [model id]");
		if(targetID == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");

		if((carModelID < 400 || carModelID > 611) && carModelID != 0) return SendClientMessage(playerid, COLOR_GREY, "Invalid model ID (valid IDs are between 400 and 611). Specify model 0 to delete a player vehicle.");

		GetPlayerName(targetID, szPlayerName, MAX_PLAYER_NAME);

		if(carModelID == 0) { // Basically, specifying 0 in the command will delete the vehicle (which was pretty useful in the past).
			if(playerVariables[targetID][pCarModel] >= 1) {
				DestroyPlayerVehicle(targetID);
				format(string, sizeof(string), "You have deleted %s (ID: %d)'s vehicle.", szPlayerName, targetID);
				SendClientMessage(playerid, COLOR_WHITE, string);
			}
			else return SendClientMessage(playerid, COLOR_GREY, "This player does not own a vehicle.");
		}
		else {

			DestroyPlayerVehicle(targetID);

			GetPlayerPos(playerid, playerVariables[targetID][pCarPos][0], playerVariables[targetID][pCarPos][1], playerVariables[targetID][pCarPos][2]);
			GetPlayerFacingAngle(playerid, playerVariables[targetID][pCarPos][3]);

			playerVariables[targetID][pCarModel] = carModelID;

			SpawnPlayerVehicle(targetID);
			format(string, sizeof(string), "You have set %s (ID: %d)'s vehicle to a %s.", szPlayerName, targetID, VehicleNames[playerVariables[targetID][pCarModel] - 400]);
			SendClientMessage(playerid, COLOR_WHITE, string);
		}
	}
	return 1;
}

CMD:listguns(playerid, params[]) {
	if(playerVariables[playerid][pAdminLevel] >= 1) {
	    new
	        targetid;

		if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/listguns [playerid]");
		if(targetid == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");

		SendClientMessage(playerid, COLOR_TEAL, "--------------------------------------------------------------");

		for(new i = 0; i < 13; i++) {
		    if(playerVariables[targetid][pWeapons][i] >= 1) {
			    format(szMessage, sizeof(szMessage), "Weapon: %s (%d) | Slot: %d", WeaponNames[playerVariables[targetid][pWeapons][i]], playerVariables[targetid][pWeapons][i], i);
			    SendClientMessage(playerid, COLOR_WHITE, szMessage);
		    }
		}

		SendClientMessage(playerid, COLOR_TEAL, "--------------------------------------------------------------");
	}
	return 1;
}

CMD:eject(playerid, params[]) {
	new
		targetID;

	if(sscanf(params, "u", targetID))
		return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/eject [playerid]");

	if(GetPlayerState(playerid) == 2) {
		if(GetPlayerVehicleID(playerid) == GetPlayerVehicleID(targetID)) {

			new
				string[128],
				playerName[2][MAX_PLAYER_NAME];

			GetPlayerName(playerid, playerName[0], MAX_PLAYER_NAME);
			GetPlayerName(targetID, playerName[1], MAX_PLAYER_NAME);

			format(string, sizeof(string), "* %s has thrown %s out of their vehicle.", playerName[0], playerName[1]);
			nearByMessage(playerid, COLOR_PURPLE, string);

			RemovePlayerFromVehicle(targetID);
		}
		else SendClientMessage(playerid, COLOR_GREY, "That person is not in your vehicle.");
	}
	else SendClientMessage(playerid, COLOR_GREY, "You're not driving a vehicle.");
	return 1;
}

CMD:detain(playerid, params[]) {
	new
		seat,
		targetID;

	if(sscanf(params, "ud", targetID, seat))
		return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/detain [playerid] [seat (1-3)]");

	if(playerVariables[targetID][pFreezeType] == 2 || playerVariables[targetID][pFreezeType] == 4) {
		if(seat > 0 && seat < 4) {
			if(IsPlayerInRangeOfPlayer(playerid, targetID, 5.0) && IsPlayerInRangeOfVehicle(playerid, GetClosestVehicle(playerid), 5.0)) {

				new
					detaintarget = GetClosestVehicle(playerid);

				if(checkVehicleSeat(detaintarget, seat) != 0) SendClientMessage(playerid, COLOR_GREY, "That seat ID is occupied.");

				else {

					new
						playerName[2][MAX_PLAYER_NAME],
						string[92];

					GetPlayerName(playerid, playerName[0], MAX_PLAYER_NAME);
					GetPlayerName(targetID, playerName[1], MAX_PLAYER_NAME);

					format(string, sizeof(string), "* %s has been detained into the vehicle by %s.", playerName[1], playerName[0]);
					nearByMessage(playerid, COLOR_PURPLE, string);

					PutPlayerInVehicle(targetID, detaintarget, seat);
				}
			}
			else SendClientMessage(playerid, COLOR_GREY, "You must be closer to the player you wish to detain, and the vehicle you wish to detain into.");
	    }
	}
	return 1;
}

CMD:drag(playerid, params[]) {

	new
		targetID,
		string[99],
		playerName[2][MAX_PLAYER_NAME];

	foreach(Player, x) {
		if(playerVariables[x][pDrag] == playerid) {

			GetPlayerName(playerid, playerName[0], MAX_PLAYER_NAME);
			GetPlayerName(x, playerName[1], MAX_PLAYER_NAME);

			playerVariables[x][pDrag] = -1;

			format(string, sizeof(string), "You have stopped dragging %s.", playerName[1]);
			SendClientMessage(playerid, COLOR_WHITE, string);

			format(string, sizeof(string), "* %s has stopped dragging %s, releasing their grip.", playerName[0], playerName[1]);

			return nearByMessage(playerid, COLOR_PURPLE, string);
		}
	}

	if(sscanf(params, "u", targetID))
		SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/drag [playerid] (use again to stop).");

	else if(playerVariables[targetID][pFreezeType] == 2 || playerVariables[targetID][pFreezeType] == 4) {
		if(IsPlayerInRangeOfPlayer(playerid, targetID, 2.0)) {
			if(!IsPlayerInAnyVehicle(targetID) && !IsPlayerInAnyVehicle(playerid)) {

				GetPlayerName(playerid, playerName[0], MAX_PLAYER_NAME);
				GetPlayerName(targetID, playerName[1], MAX_PLAYER_NAME);

				playerVariables[targetID][pDrag] = playerid;
				format(string, sizeof(string), "You are now dragging %s.", playerName[1]);
				SendClientMessage(playerid, COLOR_WHITE, string);

				format(string, sizeof(string), "* %s grabs %s by the arm, and starts dragging them.", playerName[0], playerName[1]);
				nearByMessage(playerid, COLOR_PURPLE, string);
			}
			else SendClientMessage(playerid, COLOR_GREY, "Neither you, nor the person you wish to drag, can be in a vehicle.");
		}
		else SendClientMessage(playerid, COLOR_GREY, "You're too far away.");
	}
	else SendClientMessage(playerid, COLOR_GREY, "The person you wish to drag must be restrained first (cuffed, or tied).");
	return 1;
}

CMD:fingerprint(playerid, params[]) {

	new
		targetID,
		string[106],
		dates[3],
		playerNames[2][MAX_PLAYER_NAME];

	if(sscanf(params, "u", targetID)) return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/fingerprint [playerid]");

	else if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] == 1) {
		if(IsPlayerAuthed(targetID)) {
			if(playerVariables[targetID][pFreezeType] == 2 || playerVariables[targetID][pFreezeType] == 4 || (GetPlayerSpecialAction(targetID) == SPECIAL_ACTION_HANDSUP && playerVariables[targetID][pFreezeType] == 0)) {
				if(IsPlayerInRangeOfPlayer(playerid, targetID, 2.0)) {

					GetPlayerName(targetID, playerNames[0], MAX_PLAYER_NAME);
					GetPlayerName(playerid, playerNames[1], MAX_PLAYER_NAME);

					getdate(dates[0], dates[1], dates[2]);

					format(string, sizeof(string), "* %s grabs ahold of %s's finger, and places it on the scanner.", playerNames[1], playerNames[0]);
					nearByMessage(playerid, COLOR_PURPLE, string);

					SendClientMessage(playerid, COLOR_TEAL, "----------------------------------------------------------------");

					if(playerVariables[targetID][pCrimes] > 0 || playerVariables[targetID][pArrests] > 0 || playerVariables[targetID][pWarrants] > 0) {

						format(string, sizeof(string), "Citizen's registered name: %s", playerNames[0]);
						SendClientMessage(playerid, COLOR_WHITE, string);
						format(string, sizeof(string), "Citizen's age: %d (born %d)", dates[0] - playerVariables[targetID][pAge], playerVariables[targetID][pAge]);
						SendClientMessage(playerid, COLOR_WHITE, string);

						switch(playerVariables[targetID][pGender]) {
							case 1: SendClientMessage(playerid, COLOR_WHITE, "Citizen's gender: Male");
							case 2: SendClientMessage(playerid, COLOR_WHITE, "Citizen's gender: Female");
							default: SendClientMessage(playerid, COLOR_WHITE, "Citizen's gender: Unknown");
						}
						if(playerVariables[targetID][pPhoneNumber] == -1) {
							SendClientMessage(playerid, COLOR_WHITE, "Citizen's phone number: None");
						}
						else {
							format(string, sizeof(string), "Citizen's phone number: %d", playerVariables[targetID][pPhoneNumber]);
							SendClientMessage(playerid, COLOR_WHITE, string);
						}
					}
					else SendClientMessage(playerid, COLOR_WHITE, "No results found.");

					SendClientMessage(playerid, COLOR_TEAL, "----------------------------------------------------------------");
				}
				else SendClientMessage(playerid, COLOR_GREY, "You're too far away.");
			}
			else SendClientMessage(playerid, COLOR_GREY, "The person you wish to fingerprint must be restrained first (cuffed, or tied).");
		}
		else SendClientMessage(playerid, COLOR_GREY, "The specified player is either not connected or has not authenticated.");
	}
	return 1;
}

CMD:wanted(playerid, params[]) {
	if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] == 1) {

		new
			dString[128],
			x;

		SendClientMessage(playerid, COLOR_TEAL, "---------------------------------------------------------------------------------------------------------------------------------");
		SendClientMessage(playerid, COLOR_WHITE, "Active Felons:");
		foreach(Player, i) {
			if(playerVariables[i][pWarrants] >= 1) {

				GetPlayerName(i, szPlayerName, MAX_PLAYER_NAME);

				if(x == 0)
					format(dString, sizeof(dString), "%s (%d)", szPlayerName, playerVariables[i][pWarrants]);
				else
					format(dString, sizeof(dString), "%s | %s (%d)", dString, szPlayerName, playerVariables[i][pWarrants]);

				if(x == 3) {
					SendClientMessage(playerid, COLOR_WHITE, dString);
					x = 0;
				}

				else x++;
			}
		}

		if(x < 3 && x > 0)
			SendClientMessage(playerid, COLOR_WHITE, dString);

		if(x == 0)
			SendClientMessage(playerid, COLOR_WHITE, "No active felons found.");

		SendClientMessage(playerid, COLOR_TEAL, "---------------------------------------------------------------------------------------------------------------------------------");
	}

	return 1;
}

CMD:ticket(playerid, params[]) {

	new
		targetID,
		price,
		string[96],
		playerName[2][MAX_PLAYER_NAME];

	if(sscanf(params, "ud", targetID, price)) return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/ticket [playerid] [price]");

	else if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] == 1) {
		if(IsPlayerAuthed(targetID)) {
			if(playerid != targetID) {
				if(IsPlayerInRangeOfPlayer(playerid, targetID, 3.0)) {
					if(price >= 1 && price <= 100000) {

						GetPlayerName(playerid, playerName[0], MAX_PLAYER_NAME);
						GetPlayerName(targetID, playerName[1], MAX_PLAYER_NAME);

						format(string, sizeof(string), "* %s writes up a ticket, and hands it to %s.", playerName[0], playerName[1]);
						nearByMessage(playerid, COLOR_PURPLE, string);

						format(string, sizeof(string), "You have issued %s a ticket costing $%d.", playerName[1], price);
						SendClientMessage(playerid, COLOR_WHITE, string);

						format(string, sizeof(string), "%s has issued you a ticket costing $%d - /accept ticket to pay the fine.", playerName[0], price);
						SendClientMessage(targetID, COLOR_GENANNOUNCE, string);

						SetPVarInt(targetID, "tP", price);
						SetPVarInt(targetID, "tID", playerid + 1);
					}
					else SendClientMessage(playerid, COLOR_GREY, "Invalid price specified (must be between $1 and $100,000).");
				}
				else SendClientMessage(playerid, COLOR_GREY, "You're too far away.");
			}
			else SendClientMessage(playerid, COLOR_GREY, "You can't ticket yourself.");
		}
		else SendClientMessage(playerid, COLOR_GREY, "The specified player is either not connected or has not authenticated.");
	}
	return 1;
}

CMD:suspect(playerid, params[]) {
	return cmd_su(playerid, params);
}

CMD:su(playerid, params[]) {

	new
		targetID,
		string[128],
		crime[96],
		playerName[2][MAX_PLAYER_NAME];

	if(sscanf(params, "us", targetID, crime))
		return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/su [playerid] [offence]");

	else if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] == 1) {
		if(IsPlayerAuthed(targetID)) {
			if(groupVariables[playerVariables[targetID][pGroup]][gGroupType] != 1) {

				GetPlayerName(playerid, playerName[0], MAX_PLAYER_NAME);
				GetPlayerName(targetID, playerName[1], MAX_PLAYER_NAME);

				format(string, sizeof(string), "Dispatch: %s has issued an arrest warrant on %s (%s).", playerName[0], playerName[1], crime);
				SendToGroup(playerVariables[playerid][pGroup], COLOR_RADIOCHAT, string);

				playerVariables[targetID][pWarrants]++;
				if(playerVariables[targetID][pWarrants] < 7)
					SetPlayerWantedLevel(targetID, playerVariables[targetID][pWarrants]);
			}
			else SendClientMessage(playerid, COLOR_GREY, "You can't place an arrest warrant on this person.");
		}
		else SendClientMessage(playerid, COLOR_GREY, "The specified player is either not connected or has not authenticated.");
	}
	return 1;
}

CMD:arrest(playerid, params[]) {

	new
		string[128],
		playerName[2][MAX_PLAYER_NAME],
		targetID,
		arrestInfo[3];

	if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] != 1) return SendClientMessage(playerid, COLOR_GREY, "You're not a law enforcement officer.");

	else if(sscanf(params, "udd", targetID, arrestInfo[0], arrestInfo[1])) return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/arrest [playerid] [time] [price]");

	else if(targetID == playerid) return SendClientMessage(playerid, COLOR_GREY, "You can't arrest yourself.");

	else if((IsPlayerInRangeOfPoint(playerid,5, 1528.5240,-1678.2472,5.8906) && IsPlayerInRangeOfPoint(targetID,5, 1528.5240,-1678.2472,5.8906)) || (IsPlayerInRangeOfPoint(playerid, 20.0, 221.25, 110.0, 999.02) && IsPlayerInRangeOfPoint(targetID, 20.0, 221.25, 110.0, 999.02))) {
		if(playerVariables[targetID][pFreezeType] == 2) {
			if(arrestInfo[0] <= 60 && arrestInfo[0] > 0 && arrestInfo[1] <= 30000 && arrestInfo[1] >= 0) {

				GetPlayerName(playerid, playerName[0], MAX_PLAYER_NAME);
				GetPlayerName(targetID, playerName[1], MAX_PLAYER_NAME);

				validResetPlayerWeapons(targetID);

				playerVariables[targetID][pMoney] -= arrestInfo[1];
				playerVariables[targetID][pFreezeTime] = 0;
				playerVariables[targetID][pFreezeType] = 0;
				playerVariables[targetID][pPrisonID] = 3;
				playerVariables[targetID][pPrisonTime] = arrestInfo[0] * 60;
				playerVariables[targetID][pArmour] = 0;
				playerVariables[targetID][pArrests]++;
				playerVariables[targetID][pCrimes] += playerVariables[targetID][pWarrants];
				playerVariables[targetID][pWarrants] = 0;

				SetPlayerArmour(targetID, 0);
				TogglePlayerControllable(targetID, true);

				groupVariables[playerVariables[playerid][pGroup]][gSafe][0] += arrestInfo[1];

				format(string, sizeof(string),"You have been arrested by %s for %d minutes, and issued a fine of $%d.", playerName[0], arrestInfo[0], arrestInfo[1]);
				SendClientMessage(targetID, COLOR_NICESKY, string);

				format(string, sizeof(string),"Dispatch: %s has processed suspect %s, issuing a fine of $%d with a sentence of %d minutes.", playerName[0], playerName[1], arrestInfo[1], arrestInfo[0]);
				SendToGroup(playerVariables[playerid][pGroup], COLOR_RADIOCHAT, string);

				SetPlayerInterior(targetID, 10);
				SetPlayerVirtualWorld(targetID, GROUP_VIRTUAL_WORLD+1);

				arrestInfo[2] = random(sizeof(JailSpawns));

				SetPlayerPos(targetID, JailSpawns[arrestInfo[2]][0], JailSpawns[arrestInfo[2]][1], JailSpawns[arrestInfo[2]][2]);
				SetPlayerFacingAngle(targetID, 0);
			}
			else SendClientMessage(playerid, COLOR_GREY, "Fine price must be between $0 and $30,000; time must be 60 minutes or less.");
		}
		else SendClientMessage(playerid, COLOR_GREY, "The person you wish to arrest must be restrained first (cuffed).");
	}
	else SendClientMessage(playerid, COLOR_GREY, "Both you and the person you wish to arrest must be at the arrest point.");
	return 1;
}

CMD:frisk(playerid, params[]) {

	new
		targetID,
		string[128],
		playerNames[2][MAX_PLAYER_NAME],
		count;

	if(sscanf(params, "u", targetID)) return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/frisk [playerid]");

	else if(IsPlayerInRangeOfPlayer(playerid, targetID, 2.0)) {
		if(playerVariables[targetID][pFreezeType] == 2 || (GetPlayerSpecialAction(targetID) == SPECIAL_ACTION_HANDSUP && playerVariables[targetID][pFreezeType] == 0) || playerVariables[targetID][pFreezeType] == 4) {

			GetPlayerName(playerid, playerNames[0], MAX_PLAYER_NAME);
			GetPlayerName(targetID, playerNames[1], MAX_PLAYER_NAME);

			format(string, sizeof(string), "* %s has frisked %s.", playerNames[0], playerNames[1]);
			nearByMessage(playerid, COLOR_PURPLE, string);

			SendClientMessage(playerid, COLOR_TEAL, "----------------------------------------------------------------");

			for(new x; x < 13; x++) { // Retrieve all weapons in slots, get their names, shove them into one string.
				if(playerVariables[targetID][pWeapons][x] > 0) {
					if(count == 0) format(string, sizeof(string), "* Weapons: %s", WeaponNames[playerVariables[targetID][pWeapons][x]]);
					else format(string, sizeof(string), "%s, %s", string, WeaponNames[playerVariables[targetID][pWeapons][x]]);
					count++;
				}
			}
			if(count >= 1) SendClientMessage(playerid, COLOR_GREY, string);

			if(playerVariables[targetID][pMaterials] >= 1) {
				format(string, sizeof(string), "* Materials: %d", playerVariables[targetID][pMaterials]);
				SendClientMessage(playerid, COLOR_GREY, string);
				count++;
			}
			if(playerVariables[targetID][pPhoneNumber] != -1) {
				SendClientMessage(playerid, COLOR_GREY, "Phone");
			}
			if(count == 0) SendClientMessage(playerid, COLOR_GREY, "No items found.");

			SendClientMessage(playerid, COLOR_TEAL, "----------------------------------------------------------------");
	    }
		else SendClientMessage(playerid, COLOR_GREY, "That person must first be subdued, or have their hands up.");
	}
	else SendClientMessage(playerid, COLOR_GREY, "You're too far away.");
	return 1;
}

CMD:cuff(playerid, params[]) {

	new
		string[128],
		playerName[2][MAX_PLAYER_NAME],
		target,
		Float:Pos[3];

    if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] != 1) return SendClientMessage(playerid, COLOR_GREY, "You're not a law enforcement officer.");

	else if(sscanf(params, "u", target)) return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/cuff [playerid]");

	else if(target == playerid) return SendClientMessage(playerid, COLOR_GREY, "You can't cuff yourself.");

    else {
	    if(IsPlayerInRangeOfPlayer(playerid, target, 3.0)) {
            if(playerVariables[target][pFreezeType] == 5 || playerVariables[target][pFreezeType] == 1 || (GetPlayerSpecialAction(target) == SPECIAL_ACTION_HANDSUP && playerVariables[target][pFreezeType] == 0) || playerVariables[target][pFreezeType] == 4) { // CAN NEVAR BE EXPLOITED!1 Means admin-frozen people can't be exploited out with cuffs.

				GetPlayerName(playerid, playerName[0], MAX_PLAYER_NAME);
				GetPlayerName(target, playerName[1], MAX_PLAYER_NAME);

				TogglePlayerControllable(target, 0);
				playerVariables[target][pFreezeTime] = 900;
				playerVariables[target][pFreezeType] = 2;
				GameTextForPlayer(target,"~n~~r~Handcuffed!",4000,4);

				GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);

				format(string, sizeof(string), "* %s has handcuffed %s.", playerName[0], playerName[1]);
				nearByMessage(playerid, COLOR_PURPLE, string);
				format(string, sizeof(string),"You have handcuffed %s.", playerName[1]);
				SendClientMessage(playerid, COLOR_NICESKY, string);

				PlayerPlaySoundEx(1145, Pos[0], Pos[1], Pos[2]);
				ApplyAnimation(target, "PED", "cower", 1, 1, 0, 0, 0, 0, 1);
    	    }
    	    else SendClientMessage(playerid, COLOR_GREY, "That person must first be subdued, or have their hands up.");
		}
		else SendClientMessage(playerid, COLOR_GREY, "You're too far away.");
	}
	return 1;
}

CMD:unfreeze(playerid, params[]) {
	return cmd_freeze(playerid, params);
}

CMD:freeze(playerid, params[]) {
	if(playerVariables[playerid][pAdminLevel] >= 2) {
		new
			string[128],
			target;

		if(sscanf(params, "u", target)) return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/freeze [playerid]");

		else if(playerVariables[playerid][pAdminLevel] >= playerVariables[target][pAdminLevel]) {

			GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);

			switch(playerVariables[target][pFreezeType]) {
				case 3: {

					playerVariables[target][pFreezeTime] = 0;
					playerVariables[target][pFreezeType] = 0;
					TogglePlayerControllable(target, 1);

					format(string, sizeof(string), "You have been unfrozen by Administrator %s.", szPlayerName);
					SendClientMessage(target, COLOR_WHITE, string);

					GetPlayerName(target, szPlayerName, MAX_PLAYER_NAME);
					format(string, sizeof(string), "You have unfrozen %s.", szPlayerName);
					SendClientMessage(playerid, COLOR_WHITE, string);
				}
				default: {

					TogglePlayerControllable(target, 0);
					playerVariables[target][pFreezeTime] = -1;
					playerVariables[target][pFreezeType] = 3;

					format(string, sizeof(string), "You have been frozen by Administrator %s.", szPlayerName);
					SendClientMessage(target, COLOR_WHITE, string);

					GetPlayerName(target, szPlayerName, MAX_PLAYER_NAME);
					format(string, sizeof(string), "You have frozen %s.", szPlayerName);
					SendClientMessage(playerid, COLOR_WHITE, string);
				}
			}
		}
		else SendClientMessage(playerid, COLOR_GREY, "You can't freeze a higher level administrator.");
	}
	return 1;
}

CMD:uncuff(playerid, params[]) {
	new
		string[128],
		playerName[2][MAX_PLAYER_NAME],
		target;

	if(sscanf(params, "u", target)) return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/uncuff [playerid]");

    if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] != 1) {
        SendClientMessage(playerid, COLOR_GREY, "You're not a law enforcement officer.");
    }

	else if(target == playerid) SendClientMessage(playerid, COLOR_GREY, "You can't uncuff yourself.");

    else {
	    if(IsPlayerInRangeOfPlayer(playerid, target, 4.0)) {
            if(playerVariables[target][pFreezeType] == 2) {

				GetPlayerName(playerid, playerName[0], MAX_PLAYER_NAME);
				GetPlayerName(target, playerName[1], MAX_PLAYER_NAME);

				playerVariables[target][pFreezeTime] = 0;
				playerVariables[target][pFreezeType] = 0;

				TogglePlayerControllable(target, 1);
				PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
				ClearAnimations(target);
				ApplyAnimation(target, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0);
				GameTextForPlayer(target,"~n~~g~Uncuffed!",4000,4);

				format(string, sizeof(string), "* %s has uncuffed %s.", playerName[0], playerName[1]);
				nearByMessage(playerid, COLOR_PURPLE, string);
				format(string, sizeof(string),"You have uncuffed %s.", playerName[1]);
				SendClientMessage(playerid, COLOR_NICESKY, string);
				PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);

				if(playerVariables[target][pDrag] != -1) {
					format(string, sizeof(string), "You have stopped dragging %s.", playerName[1]);
					SendClientMessage(playerid, COLOR_WHITE, string);

					playerVariables[target][pDrag] = -1;

					format(string, sizeof(string), "* %s has stopped dragging %s, releasing their grip.", playerName[0], playerName[1]);

					return nearByMessage(playerid, COLOR_PURPLE, string);
				}
    	    }
    	    else SendClientMessage(playerid, COLOR_GREY, "That person is not cuffed.");
		}
	}
	return 1;
}

CMD:deposit(playerid, params[]) {

	new
		cash,
		string[128];

	if(sscanf(params, "d", cash)) return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/deposit [amount]");
	else if(cash <= 0) return SendClientMessage(playerid, COLOR_GREY, "Invalid amount specified.");
	else {
		if(IsPlayerInRangeOfPoint(playerid, 15.0, 2306.8481,-16.0682,26.7496) && GetPlayerVirtualWorld(playerid) == 2) {
			if(playerVariables[playerid][pMoney] < cash) SendClientMessage(playerid, COLOR_GREY, "You don't have enough money for this transaction.");
			else if(cash >= 1) {
				playerVariables[playerid][pBankMoney] += cash;
				playerVariables[playerid][pMoney] -= cash;
				format(string, sizeof(string), "You have deposited $%d into your bank account. Your account balance is now $%d.", cash, playerVariables[playerid][pBankMoney]);
				SendClientMessage(playerid, COLOR_DCHAT, string);
			}
			else SendClientMessage(playerid, COLOR_GREY, "Invalid amount specified.");
		}
		else {
			SendClientMessage(playerid, COLOR_GREY, "You're not at the bank.");
		}
	}
	return 1;
}

CMD:wiretransfer(playerid, params[]) {

	new
		cash,
		targetID,
		string[128];

	if(sscanf(params, "ud", targetID, cash)) SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/wiretransfer [playerid] [amount]");
	else if(cash <= 0) return SendClientMessage(playerid, COLOR_GREY, "Invalid amount specified.");
	else if(IsPlayerInRangeOfPoint(playerid, 15.0, 2306.8481,-16.0682,26.7496) && GetPlayerVirtualWorld(playerid) == 2) {
	    if(suspensionCheck(playerid) == 1)
	        return 1;

		if(playerVariables[playerid][pPlayingHours] >= 10) {
			if(IsPlayerAuthed(targetID)) {
				if(playerVariables[playerid][pBankMoney] >= cash) {
					if(cash >= 1) {

						playerVariables[playerid][pBankMoney] -= cash;
						playerVariables[targetID][pBankMoney] += cash;

						GetPlayerName(targetID, szPlayerName, MAX_PLAYER_NAME);
						format(string, sizeof(string), "You have transferred $%d into %s's account. Your account balance is now $%d.", cash, szPlayerName, playerVariables[playerid][pBankMoney]);
						SendClientMessage(playerid, COLOR_DCHAT, string);

						GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
						format(string, sizeof(string), "%s has transferred $%d into your account. Your account balance is now $%d.", szPlayerName, cash, playerVariables[playerid][pBankMoney]);
						SendClientMessage(targetID, COLOR_DCHAT, string);
					}
					else SendClientMessage(playerid, COLOR_GREY, "Invalid amount specified.");
				}
				else SendClientMessage(playerid, COLOR_GREY, "Your account balance is insufficient for this transaction.");
			}
			else SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");
		}
		else SendClientMessage(playerid, COLOR_GREY, "You must have at least ten playing hours to use this command.");
	}
	else SendClientMessage(playerid, COLOR_GREY, "You're not at the bank.");
	return 1;
}

CMD:withdraw(playerid, params[]) {

	new
		cash,
		string[128];

	if(sscanf(params, "d", cash)) return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/withdraw [amount]");
	else if(cash <= 0) return SendClientMessage(playerid, COLOR_GREY, "Invalid amount specified.");
	else {
		if(IsPlayerInRangeOfPoint(playerid, 15.0, 2306.8481,-16.0682,26.7496) && GetPlayerVirtualWorld(playerid) == 2) {
	    	if(suspensionCheck(playerid) == 1)
	        	return 1;

			if(playerVariables[playerid][pBankMoney] < cash) SendClientMessage(playerid, COLOR_GREY, "Your account balance is insufficient for this transaction.");
			else if(cash >= 1) {
				playerVariables[playerid][pMoney] += cash;
				playerVariables[playerid][pBankMoney] -= cash;
				format(string, sizeof(string), "You have withdrawn $%d from your bank account. Your account balance is now $%d.", cash, playerVariables[playerid][pBankMoney]);
				SendClientMessage(playerid, COLOR_DCHAT, string);
			}
			else SendClientMessage(playerid, COLOR_GREY, "Invalid amount specified.");
		}
		else {
			SendClientMessage(playerid, COLOR_GREY, "You're not at the bank.");
		}
	}
	return 1;
}

CMD:balance(playerid, params[]) {
    if(IsPlayerInRangeOfPoint(playerid, 15.0, 2306.8481,-16.0682,26.7496) && GetPlayerVirtualWorld(playerid) == 2) {
	    if(suspensionCheck(playerid) == 1)
	        return 1;

        format(szMessage, sizeof(szMessage), "Your current bank account balance is: $%d", playerVariables[playerid][pBankMoney]);
        SendClientMessage(playerid, COLOR_DCHAT, szMessage);
    } else SendClientMessage(playerid, COLOR_GREY, "You're not at the bank.");
	return 1;
}

CMD:go(playerid, params[]) {
	if(playerVariables[playerid][pAdminLevel] > 0) {
		ShowPlayerDialog(playerid, DIALOG_GO, DIALOG_STYLE_LIST, "SERVER: Teleport Locations", "House Interiors\nRace Tracks\nCity Locations\nPopular Locations\nGym Interiors\nOther", "Select", "Cancel");
	}
	return 1;
}

CMD:lspd(playerid,params[]) {
    if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] == 1 && playerVariables[playerid][pGroup] != 0) {
	    new string[64];
	 	if(IsPlayerInRangeOfPoint(playerid, 5, 264.1055,109.8094,1004.6172) && GetPlayerInterior(playerid) == 10) {
   			format(string, sizeof(string), "%s Menu", groupVariables[playerVariables[playerid][pGroup]][gGroupName]);
	    	ShowPlayerDialog(playerid, DIALOG_LSPD, DIALOG_STYLE_LIST, string, "Equipment\nRelease Suspect\nClothing\nClear Suspect", "Select", "Cancel");
		}
    }
	return 1;
}

CMD:fixcar(playerid, params[]) {
	if(jobVariables[playerVariables[playerid][pJob]][jJobType] == 3 || playerVariables[playerid][pAdminDuty] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) {

			new
				vehString[72],
				Float: soPos[3],
				vehicleID = GetPlayerVehicleID(playerid);

		    if(playerVariables[playerid][pJobDelay] == 0) { // DELAY!1
			    if(GetPlayerSpeed(playerid, 0) == 0) {

					GetVehiclePos(vehicleID, soPos[0], soPos[1], soPos[2]);
					PlayerPlaySoundEx(1133, soPos[0], soPos[1], soPos[2]);

				    RepairVehicle(vehicleID);
					format(vehString, sizeof(vehString), "You have repaired your %s.", VehicleNames[GetVehicleModel(vehicleID) - 400]);
					SendClientMessage(playerid, COLOR_WHITE, vehString);
				    playerVariables[playerid][pJobDelay] = 60;
			    }
			    else SendClientMessage(playerid, COLOR_WHITE, "You must stop your vehicle first.");
		    }
		    else {
				format(vehString, sizeof(vehString), "You need to wait %d seconds until you can use a mechanic command again.",playerVariables[playerid][pJobDelay]);
		        SendClientMessage(playerid, COLOR_GREY, vehString);
			}
		}
	}
	return 1;
}

CMD:colourcar(playerid, params[]) {
	if(jobVariables[playerVariables[playerid][pJob]][jJobType] == 3) {

		new
			colors[2],
			Float: soPos[3],
			vehicleID = GetPlayerVehicleID(playerid);

		if(sscanf(params, "dd", colors[0], colors[1])) {
			return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/colourcar [colour 1] [colour 2]");
		}
		else if(vehicleID) {
			if(playerVariables[playerid][pJobDelay] == 0) { // DELAY!1
				if(GetPlayerSpeed(playerid, 0) == 0) {
					if(colors[0] >= 0 && colors[0] < 256 && colors[1] >= 0 && colors[1] < 256) {

						GetVehiclePos(vehicleID, soPos[0], soPos[1], soPos[2]);
						PlayerPlaySoundEx(1134, soPos[0], soPos[1], soPos[2]);

						ChangeVehicleColor(vehicleID, colors[0], colors[1]);

						foreach(Player, v) {
							if(playerVariables[v][pCarID] == vehicleID) {
								playerVariables[v][pCarColour][0] = colors[0];
								playerVariables[v][pCarColour][1] = colors[1];
							}
						}
						SendClientMessage(playerid, COLOR_WHITE, "You have resprayed your vehicle.");
						playerVariables[playerid][pJobDelay] = 60;
					}
					else SendClientMessage(playerid, COLOR_WHITE, "Valid vehicle colours are 0 to 255.");
				}
				else SendClientMessage(playerid, COLOR_WHITE, "You must stop your vehicle first.");
			}
			else SendClientMessage(playerid, COLOR_WHITE, "Please wait your job reload time.");
		}
	}
	return 1;
}

CMD:trackplates(playerid, params[]) {
	if(isnull(params))
	    return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/trackplates [plate]");

	if(jobVariables[playerVariables[playerid][pJob]][jJobType] != 2 && groupVariables[playerVariables[playerid][pGroup]][gGroupType] != 1)
	    return SendClientMessage(playerid, COLOR_GREY, "You are not a Detective or a LEO.");

 	if(playerVariables[playerid][pJobSkill][1] < 500 && groupVariables[playerVariables[playerid][pGroup]][gGroupType] != 1)
  		return SendClientMessage(playerid, COLOR_GREY, "You are not a Level 5 detective.");

	foreach(Player, x) {
		if(strcmp(playerVariables[x][pCarLicensePlate], params, true) == 0) {
			GetPlayerName(x, szPlayerName, MAX_PLAYER_NAME);
			format(szMessage, sizeof(szMessage), "Plate: "EMBED_GREY"%s{FFFFFF} | Vehicle Owner: "EMBED_GREY"%s", playerVariables[x][pCarLicensePlate], szPlayerName);
			SendClientMessage(playerid, COLOR_WHITE, szMessage);
		    return 1;
		}
	}
	return 1;
}

CMD:trackhouse(playerid, params[]) {
	new
		id,
		string[128],
		house;

	if(sscanf(params, "u", id))
		return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/trackhouse [playerid]");

	else if(jobVariables[playerVariables[playerid][pJob]][jJobType] == 2) {
	    if(playerVariables[playerid][pJobSkill][1] >= 400) {
	        if(IsPlayerAuthed(id)) {

				if(id == playerid)
					return SendClientMessage(playerid, COLOR_GREY, "Use /home to set a checkpoint to your house.");

	            if(playerVariables[playerid][pJobDelay] >= 1) {
	                format(string,sizeof(string),"You need to wait %d seconds until you can use a detective command again.",playerVariables[playerid][pJobDelay]);
	                SendClientMessage(playerid, COLOR_GREY, string);
	            }
	            else if(playerVariables[playerid][pCheckpoint] >= 2) {
					format(string, sizeof(string), "You already have an active checkpoint (%s), reach it first, or /killcheckpoint.", getPlayerCheckpointReason(playerid));
					SendClientMessage(playerid, COLOR_GREY,string);
				}
				else if(playerVariables[id][pAdminDuty] >= 1) SendClientMessage(playerid, COLOR_GREY, "You can't track this person's house at the moment.");
				else {

					house = getPlayerHouseID(id);
					if(house >= 1) {

						SetPlayerCheckpoint(playerid, houseVariables[house][hHouseExteriorPos][0], houseVariables[house][hHouseExteriorPos][1], houseVariables[house][hHouseExteriorPos][2], 5.0);

						format(string, sizeof(string), "A checkpoint has been set to %s's house.", playerVariables[id][pNormalName]);
						SendClientMessage(playerid, COLOR_WHITE, string);

						switch(playerVariables[playerid][pJobSkill][1]) {
							case 400 .. 449: playerVariables[playerid][pJobDelay] = 40;
							case 450 .. 499: playerVariables[playerid][pJobDelay] = 30;
							default: playerVariables[playerid][pJobDelay] = 20;
						}

						playerVariables[playerid][pJobSkill][1]++;
						playerVariables[playerid][pCheckpoint] = 1;
					}
					else SendClientMessage(playerid, COLOR_GREY, "This person does not own a house.");
	            }
	        }
			else SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");
	    }
		else SendClientMessage(playerid, COLOR_GREY, "Your detective skill must be at least level 8 to use this.");
	}
	return 1;
}

CMD:business(playerid, params[]) {

	new
		business = getPlayerBusinessID(playerid);

	if(business >= 1) {
		if(playerVariables[playerid][pCheckpoint] >= 1) {
			new string[96];
			format(string, sizeof(string), "You already have an active checkpoint (%s), reach it first, or /killcheckpoint.", getPlayerCheckpointReason(playerid));
			return SendClientMessage(playerid, COLOR_GREY,string);
		}
		SetPlayerCheckpoint(playerid, businessVariables[business][bExteriorPos][0], businessVariables[business][bExteriorPos][1], businessVariables[business][bExteriorPos][2], 5.0);
		SendClientMessage(playerid, COLOR_WHITE, "A checkpoint has been set to your business.");
		playerVariables[playerid][pCheckpoint] = 6;
	}
	else SendClientMessage(playerid, COLOR_GREY, "You don't own a business.");
	return 1;
}

CMD:home(playerid, params[]) {

	new
		house = getPlayerHouseID(playerid);

	if(house >= 1) {
		if(playerVariables[playerid][pCheckpoint] >= 1) {
			new string[96];
			format(string, sizeof(string), "You already have an active checkpoint (%s), reach it first, or /killcheckpoint.", getPlayerCheckpointReason(playerid));
			return SendClientMessage(playerid, COLOR_GREY,string);
		}
		SetPlayerCheckpoint(playerid, houseVariables[house][hHouseExteriorPos][0], houseVariables[house][hHouseExteriorPos][1], houseVariables[house][hHouseExteriorPos][2], 5.0);
		SendClientMessage(playerid, COLOR_WHITE, "A checkpoint has been set to your house.");
		playerVariables[playerid][pCheckpoint] = 6;
	}
	else SendClientMessage(playerid, COLOR_GREY, "You don't own a house.");
	return 1;
}

CMD:trackbusiness(playerid, params[]) {
	new
		id,
		string[128],
		house;

	if(sscanf(params, "u", id))
		return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/trackbusiness [playerid]");

	else if(jobVariables[playerVariables[playerid][pJob]][jJobType] == 2) {
	    if(playerVariables[playerid][pJobSkill][1] >= 400) {
	        if(IsPlayerAuthed(id)) {

				if(id == playerid) return SendClientMessage(playerid, COLOR_GREY, "Use /business to set a checkpoint to your business.");

	            if(playerVariables[playerid][pJobDelay] >= 1) {
	                format(string,sizeof(string),"You need to wait %d seconds until you can use a detective command again.",playerVariables[playerid][pJobDelay]);
	                SendClientMessage(playerid, COLOR_GREY, string);
	            }
	            else if(playerVariables[playerid][pCheckpoint] >= 2) {
					format(string, sizeof(string), "You already have an active checkpoint (%s), reach it first, or /killcheckpoint.", getPlayerCheckpointReason(playerid));
					SendClientMessage(playerid, COLOR_GREY,string);
				}
				else if(playerVariables[id][pAdminDuty] >= 1) SendClientMessage(playerid, COLOR_GREY, "You can't track this person's business at the moment.");
				else {

					house = getPlayerBusinessID(id);
					if(house >= 1) {

						SetPlayerCheckpoint(playerid, businessVariables[house][bExteriorPos][0], businessVariables[house][bExteriorPos][1], businessVariables[house][bExteriorPos][2], 5.0);

						format(string, sizeof(string), "A checkpoint has been set to %s's business.", playerVariables[id][pNormalName]);
						SendClientMessage(playerid, COLOR_WHITE, string);

						switch(playerVariables[playerid][pJobSkill][1]) {
							case 400 .. 449: playerVariables[playerid][pJobDelay] = 40;
							case 450 .. 499: playerVariables[playerid][pJobDelay] = 30;
							default: playerVariables[playerid][pJobDelay] = 20;
						}

						playerVariables[playerid][pJobSkill][1]++;
						playerVariables[playerid][pCheckpoint] = 1;
					}
					else SendClientMessage(playerid, COLOR_GREY, "This person does not own a business.");
	            }
	        }
			else SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");
	    }
		else SendClientMessage(playerid, COLOR_GREY, "Your detective skill must be at least level 8 to use this.");
	}
	return 1;
}

CMD:trackcar(playerid, params[]) {

	new
		id,
		string[128];

	if(sscanf(params, "u", id))
		return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/trackcar [playerid]");

	else if(jobVariables[playerVariables[playerid][pJob]][jJobType] == 2)
	{
	    if(playerVariables[playerid][pJobSkill][1] >= 250) {
	        if(IsPlayerAuthed(id)) {

				if(id == playerid) return SendClientMessage(playerid, COLOR_GREY, "Use /findcar to track your own vehicle.");

	            if(playerVariables[playerid][pJobDelay] >= 1) {
	                format(string,sizeof(string),"You need to wait %d seconds until you can use a detective command again.",playerVariables[playerid][pJobDelay]);
	                SendClientMessage(playerid, COLOR_GREY, string);
	            }
	            else if(playerVariables[playerid][pCheckpoint] >= 2) {
					format(string, sizeof(string), "You already have an active checkpoint (%s), reach it first, or /killcheckpoint.", getPlayerCheckpointReason(playerid));
					SendClientMessage(playerid, COLOR_GREY,string);
				}
				else if(playerVariables[id][pAdminDuty] >= 1) SendClientMessage(playerid, COLOR_GREY, "You can't track this person's vehicle at the moment.");
				else {

					GetVehiclePos(playerVariables[id][pCarID], playerVariables[id][pCarPos][0], playerVariables[id][pCarPos][1], playerVariables[id][pCarPos][2]);
					SetPlayerCheckpoint(playerid, playerVariables[id][pCarPos][0], playerVariables[id][pCarPos][1], playerVariables[id][pCarPos][2], 10.0);

					format(string, sizeof(string), "A checkpoint has been set, %s's %s was last seen at the marked area.", playerVariables[id][pNormalName], VehicleNames[playerVariables[id][pCarModel] - 400]);
					SendClientMessage(playerid, COLOR_WHITE, string);

					switch(playerVariables[playerid][pJobSkill][1]) {
						case 250 .. 299: playerVariables[playerid][pJobDelay] = 70;
						case 300 .. 349: playerVariables[playerid][pJobDelay] = 60;
						case 350 .. 399: playerVariables[playerid][pJobDelay] = 50;
						case 400 .. 449: playerVariables[playerid][pJobDelay] = 40;
						case 450 .. 499: playerVariables[playerid][pJobDelay] = 30;
						default: playerVariables[playerid][pJobDelay] = 20;
					}

					playerVariables[playerid][pJobSkill][1]++;
					playerVariables[playerid][pCheckpoint] = 1;
	            }
	        }
			else SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");
	    }
		else SendClientMessage(playerid, COLOR_GREY, "Your detective skill must be at least level 5 to use this.");
	}
	return 1;
}

CMD:track(playerid, params[]) 
{
	new string[128];
	if(playerVariables[playerid][pJobDelay] >= 1)
	{
		format(string,sizeof(string),"You need to wait %d seconds until you can use a detective command again.",playerVariables[playerid][pJobDelay]);
		SendClientMessage(playerid, COLOR_GREY, string);
	}
	if(playerVariables[playerid][pCheckpoint] >= 2) 
	{ 
		// Having to reach the first find checkpoint is pretty annoying. Let's make it hassle-free.
		format(string, sizeof(string), "You already have an active checkpoint (%s), reach it first, or /killcheckpoint.", getPlayerCheckpointReason(playerid));
		SendClientMessage(playerid, COLOR_GREY,string);
	}
	
	new id, Float:FindFloats[3];

	if(sscanf(params, "u", id))
		return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/track [playerid]");
	else if(id == playerid)
		return SendClientMessage(playerid, COLOR_GREY, "You can't track yourself.");
	else if(playerVariables[id][pStatus] != 1)
		return SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");
	else if(jobVariables[playerVariables[playerid][pJob]][jJobType] == 2)
	{
	    if(GetPlayerInterior(id) >= 1 || GetPlayerVirtualWorld(id) >= 1 || playerVariables[id][pSpectating] != INVALID_PLAYER_ID)
			SendClientMessage(playerid, COLOR_GREY, "That player is an alternate interior or virtual world.");
		else if(playerVariables[id][pAdminDuty] >= 1)
			SendClientMessage(playerid, COLOR_GREY, "You can't track this person at the moment.");
		else 
		{
			GetPlayerPos(id, FindFloats[0], FindFloats[1], FindFloats[2]);
			SetPlayerCheckpoint(playerid, FindFloats[0], FindFloats[1], FindFloats[2], 5.0);

			format(string, sizeof(string), "A checkpoint has been set, %s was last seen at the marked area.", playerVariables[id][pNormalName]);
			SendClientMessage(playerid, COLOR_WHITE, string);

			playerVariables[playerid][pCheckpoint] = 1;

			switch(playerVariables[playerid][pJobSkill][1]) {
				case 0 .. 49: playerVariables[playerid][pJobDelay] = 120;
				case 50 .. 99: playerVariables[playerid][pJobDelay] = 110;
				case 100 .. 149: playerVariables[playerid][pJobDelay] = 100;
				case 150 .. 199: playerVariables[playerid][pJobDelay] = 90;
				case 200 .. 249: playerVariables[playerid][pJobDelay] = 80;
				case 250 .. 299: playerVariables[playerid][pJobDelay] = 70;
				case 300 .. 349: playerVariables[playerid][pJobDelay] = 60;
				case 350 .. 399: playerVariables[playerid][pJobDelay] = 50;
				case 400 .. 449: playerVariables[playerid][pJobDelay] = 40;
				case 450 .. 499: playerVariables[playerid][pJobDelay] = 30;
				default: playerVariables[playerid][pJobDelay] = 20;
			}

			playerVariables[playerid][pJobSkill][1] ++;

			switch(playerVariables[playerid][pJobSkill][1]) 
			{
				case 50, 100, 150, 200, 250, 300, 350, 400, 450, 500: 
				{
					format(string,sizeof(string),"Congratulations! Your detective skill level is now %d. You will now have a lower delay between each track attempt.",playerVariables[playerid][pJobSkill][1]/50);
					SendClientMessage(playerid,COLOR_WHITE,string);
				}
			}
		}
	}
	return 1;
}

CMD:kill(playerid, params[]) {
    if(playerVariables[playerid][pEvent] != 0) {
		return SendClientMessage(playerid, COLOR_GREY, "You can't use this command while in an event.");
	}
    else if(playerVariables[playerid][pFreezeType] != 0) {
		return SendClientMessage(playerid, COLOR_GREY, "You can't use this command while cuffed, tazed, or frozen.");
	}
    else {
		return SetPlayerHealth(playerid, -1);
	}
}

CMD:untie(playerid, params[]) {
	if(sscanf(params, "u", iTarget)) {
    	return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/untie [playerid]");
    }
    else {
		if(iTarget == INVALID_PLAYER_ID)
			return SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");

		if(iTarget == playerid)
			return SendClientMessage(playerid, COLOR_GREY, "You can't untie yourself.");

		if(IsPlayerInRangeOfPlayer(playerid, iTarget, 2.0)) {
			new
				playerName[2][MAX_PLAYER_NAME];

			GetPlayerName(playerid, playerName[0], MAX_PLAYER_NAME);
			GetPlayerName(iTarget, playerName[1], MAX_PLAYER_NAME);

			if(random(6) < 3) {
				if(playerVariables[iTarget][pFreezeType] != 4) {
					return SendClientMessage(playerid, COLOR_GREY, "This player is not tied.");
				}
				else {
					format(szMessage, sizeof(szMessage), "* %s has attempted to untie %s and has succeeded.", playerName[0], playerName[1]);
					nearByMessage(playerid, COLOR_PURPLE, szMessage);

					playerVariables[iTarget][pFreezeType] = 0;
					playerVariables[iTarget][pFreezeTime] = 0;

					TogglePlayerControllable(iTarget, true);

					return SendClientMessage(playerid, COLOR_WHITE, "Attempt successful!");
				}
			}
			else {
				format(szMessage, sizeof(szMessage), "* %s has attempted to untie %s and has failed.", playerName[0], playerName[1]);
				nearByMessage(playerid, COLOR_PURPLE, szMessage);

				return SendClientMessage(playerid, COLOR_GREY, "Attempt failed!");
			}
		}
		else SendClientMessage(playerid, COLOR_GREY, "You're too far away.");
	}
	return 1;
}

CMD:tie(playerid, params[]) {
	new
	    targetID;

	if(sscanf(params, "u", targetID)) { // Using sscanf instead of isnull because we're handling a playerid/name.
    	return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/tie [playerid]");
    }
    else {
		if(targetID == INVALID_PLAYER_ID)
			return SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");
			
		if(targetID == playerid)
			return SendClientMessage(playerid, COLOR_GREY, "You can't tie yourself.");
			
		if(IsPlayerInRangeOfPlayer(playerid, targetID, 2.0)) {

			new
				playerName[2][MAX_PLAYER_NAME],
				msgSz[128];

			GetPlayerName(playerid, playerName[0], MAX_PLAYER_NAME);
			GetPlayerName(targetID, playerName[1], MAX_PLAYER_NAME);

			if(playerVariables[playerid][pRope] >= 1) {
				if(random(6) < 3) {
					if(playerVariables[targetID][pFreezeType] > 0 && playerVariables[targetID][pFreezeType] < 5) {
						return SendClientMessage(playerid, COLOR_GREY, "Attempt failed: player is already frozen.");
					}
					else {
						playerVariables[playerid][pRope]--;

						format(msgSz, sizeof(msgSz), "* %s has attempted to tie %s and has succeeded.", playerName[0], playerName[1]);
						nearByMessage(playerid, COLOR_PURPLE, msgSz);

						TogglePlayerControllable(targetID, false);

						playerVariables[targetID][pFreezeType] = 4;
						playerVariables[targetID][pFreezeTime] = 180;

						return SendClientMessage(playerid, COLOR_WHITE, "Attempt successful!");
					}
				}
				else {
					format(msgSz, sizeof(msgSz), "* %s has attempted to tie %s and has failed.", playerName[0], playerName[1]);
					nearByMessage(playerid, COLOR_PURPLE, msgSz);

					return SendClientMessage(playerid, COLOR_GREY, "Attempt failed!");
				}
			}
			else {
				return SendClientMessage(playerid, COLOR_GREY, "You don't have any rope.");
			}
		}
		else SendClientMessage(playerid, COLOR_GREY, "You're too far away.");
	}
	return 1;
}

CMD:setadminname(playerid, params[]) {
    if(playerVariables[playerid][pAdminLevel] >= 4) {
        new
            userID,
            playerNameString[MAX_PLAYER_NAME];

        if(sscanf(params, "us[24]", userID, playerNameString)) {
            return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/setadminname [playerid] [adminname]");
        }
        else {
            if(!IsPlayerConnected(userID))
				return SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");

            if(playerVariables[userID][pAdminLevel] >= 1) {
                if(playerVariables[userID][pAdminLevel] > playerVariables[playerid][pAdminLevel]) {
                    return SendClientMessage(playerid, COLOR_GREY, "You can't change the admin name of a higher level administrator.");
                }
                else {
                    new
                        messageString[128];

                    format(messageString, sizeof(messageString), "You have changed %s's admin name to %s.", playerVariables[userID][pAdminName], playerNameString);
                    SendClientMessage(playerid, COLOR_WHITE, messageString);

                    format(messageString, sizeof(messageString), "%s has changed your admin name to %s.", playerVariables[playerid][pAdminName], playerNameString);
                    SendClientMessage(userID, COLOR_WHITE, messageString);

                    format(playerVariables[userID][pAdminName], MAX_PLAYER_NAME, "%s", playerNameString);
                    
                    if(playerVariables[userID][pAdminDuty] >= 1)
						SetPlayerName(userID, playerNameString);
						
                    return 1;
                }
            }
            else {
                return SendClientMessage(playerid, COLOR_GREY, "You can't change a non-admin's admin name.");
            }
        }
	}
	return 1;
}

CMD:setnewbiespawn(playerid, params[]) {
    if(playerVariables[playerid][pAdminLevel] >= 5) {
        if(GetPVarInt(playerid, "pAdminPINConfirmed") >= 1) {
	        GetPlayerPos(playerid, playerVariables[playerid][pPos][0], playerVariables[playerid][pPos][1], playerVariables[playerid][pPos][2]);
	        format(szLargeString, sizeof(szLargeString), "ALTER TABLE `playeraccounts` CHANGE `playerPosX` `playerPosX` VARCHAR( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '%f',", playerVariables[playerid][pPos][0]);
	        format(szLargeString, sizeof(szLargeString), "%s CHANGE `playerPosY` `playerPosY` VARCHAR( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '%f',", szLargeString, playerVariables[playerid][pPos][1]);
	        format(szLargeString, sizeof(szLargeString), "%s CHANGE `playerPosZ` `playerPosZ` VARCHAR( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '%f',", szLargeString, playerVariables[playerid][pPos][2]);
	        format(szLargeString, sizeof(szLargeString), "%s CHANGE `playerInterior` `playerInterior` INT( 6 ) NOT NULL DEFAULT '%d',", szLargeString, GetPlayerInterior(playerid));
	        format(szLargeString, sizeof(szLargeString), "%s CHANGE `playerSkin` `playerSkin` INT( 6 ) NOT NULL DEFAULT '%d',", szLargeString, GetPlayerSkin(playerid));
	        format(szLargeString, sizeof(szLargeString), "%s CHANGE `playerVirtualWorld` `playerVirtualWorld` INT( 6 ) NOT NULL DEFAULT '%d'", szLargeString, GetPlayerVirtualWorld(playerid));
	        mysql_query(szLargeString, THREAD_CHANGE_SPAWN, playerid);
	        SendClientMessage(playerid, COLOR_GENANNOUNCE, "SERVER:{FFFFFF} You've successfully changed the newbie spawn position.");
        } else {
            forceAdminConfirmPIN(playerid, "setnewbiespawn", params);
        }
    }
	return 1;
}

CMD:setadminlevel(playerid, params[]) {
    if(playerVariables[playerid][pAdminLevel] < 5)
        return 0;

	if(GetPVarInt(playerid, "pAdminPINConfirmed") >= 1) {
		new
		    iLevel;

		if(sscanf(params, "ud", iTarget, iLevel))
		    return SendClientMessage(playerid, COLOR_GREY, "Syntax: /setadminlevel [playerid] [admin level]");

		if(iTarget == INVALID_PLAYER_ID)
		    return SendClientMessage(playerid, COLOR_GREY, "The specified player is not connected, or has not authenticated.");

		if(playerVariables[iTarget][pAdminLevel] > playerVariables[playerid][pAdminLevel] || iTarget == playerid)
		    return SendClientMessage(playerid, COLOR_GREY, "You can't modify the admin level of someone who retains a higher level of admin.");

		if(playerVariables[iTarget][pAdminLevel] < iLevel) {
		    format(szMessage, sizeof(szMessage), "You've been promoted to level %d admin, by %s.", iLevel, playerVariables[playerid][pNormalName]);
		    SendClientMessage(iTarget, COLOR_YELLOW, szMessage);

		    format(szMessage, sizeof(szMessage), "You've promoted %s to level %d admin.", playerVariables[iTarget][pNormalName], iLevel);
		    SendClientMessage(playerid, COLOR_YELLOW, szMessage);
		} else {
		    format(szMessage, sizeof(szMessage), "You've been demoted to level %d admin, by %s.", iLevel, playerVariables[playerid][pNormalName]);
		    SendClientMessage(iTarget, COLOR_YELLOW, szMessage);

		    format(szMessage, sizeof(szMessage), "You've demoted %s to level %d admin.", playerVariables[iTarget][pNormalName], iLevel);
		    SendClientMessage(playerid, COLOR_YELLOW, szMessage);
		}

	    playerVariables[iTarget][pAdminLevel] = iLevel;
	    
	    
    } else forceAdminConfirmPIN(playerid, "setadminlevel", params);
    
	return 1;
}

CMD:adminduty(playerid, params[]) 
{
	if(playerVariables[playerid][pAdminLevel] >= 1) 
	{
		if(playerVariables[playerid][pAdminName][0] == '*')
		{
			SendClientMessage(playerid, COLOR_GREY, "You don't have an admin name set. Contact a Head Admin (or higher) first.");
		}
		else 
		{
		    switch(playerVariables[playerid][pAdminDuty]) 
			{
				case 0: 
				{
				    playerVariables[playerid][pAdminDuty] = 1;
					GetPlayerHealth(playerid, playerVariables[playerid][pHealth]);
					GetPlayerArmour(playerid, playerVariables[playerid][pArmour]);
					SetPlayerName(playerid, playerVariables[playerid][pAdminName]);
					SetPlayerHealth(playerid, 500000.0);
					format(szMessage, sizeof(szMessage), "Notice: {FFFFFF}Admin %s (%s) is now on administrative duty.", playerVariables[playerid][pAdminName], playerVariables[playerid][pNormalName]);
				}
				case 1: 
				{
				    playerVariables[playerid][pAdminDuty] = 0;
					SetPlayerName(playerid, playerVariables[playerid][pNormalName]);
					SetPlayerHealth(playerid, playerVariables[playerid][pHealth]);
					SetPlayerArmour(playerid, playerVariables[playerid][pArmour]);
					format(szMessage, sizeof(szMessage), "Notice: {FFFFFF}Admin %s (%s) is now off administrative duty.", playerVariables[playerid][pAdminName], playerVariables[playerid][pNormalName]);
				}
			}
			submitToAdmins(szMessage, COLOR_HOTORANGE);
		}
	}
	return 1;
}

CMD:admins(playerid, params[]) {
    SendClientMessage(playerid, COLOR_TEAL, "----------------------------------------------------------------------------");

	foreach(Player, x) {
		if(playerVariables[x][pAdminLevel] >= 1 && playerVariables[x][pAdminDuty] >= 1) {
			format(szMessage, sizeof(szMessage), "Administrator %s is on duty (level %d).", playerVariables[x][pAdminName], playerVariables[x][pAdminLevel]);
			SendClientMessage(playerid, COLOR_GREEN, szMessage);
		}
		if(playerVariables[x][pAdminLevel] >= 1 && playerVariables[playerid][pAdminLevel] >= 1 && playerVariables[x][pAdminDuty] < 1) {
			format(szMessage, sizeof(szMessage), "Administrator %s (%s) is off duty (level %d).", playerVariables[x][pAdminName], playerVariables[x][pNormalName], playerVariables[x][pAdminLevel]);
			SendClientMessage(playerid, COLOR_GREY, szMessage);
		}
	}

    SendClientMessage(playerid, COLOR_TEAL, "----------------------------------------------------------------------------");
	return 1;
}

CMD:give(playerid, params[]) {
	new
	    giveSz[12],
		amount,
		targetID;

	if(sscanf(params, "us[12]d", targetID, giveSz, amount)) {
	    SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/give [playerid] [item] [amount]");
	    return SendClientMessage(playerid, COLOR_GREY, "Items: Materials");
	}
	else {
	    if(targetID == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");
	    if(!IsPlayerInRangeOfPlayer(playerid, targetID, 5.0)) return SendClientMessage(playerid, COLOR_GREY, "You're too far away.");

	    if(strcmp(giveSz, "materials", true) == 0) {
	        new
	            playerName[2][MAX_PLAYER_NAME];

	        GetPlayerName(playerid, playerName[0], MAX_PLAYER_NAME);
	        GetPlayerName(targetID, playerName[1], MAX_PLAYER_NAME);

			if(playerVariables[playerid][pMaterials] >= amount) {
			    if(amount < 1)
					return 1;

                playerVariables[playerid][pMaterials] -= amount;
                playerVariables[targetID][pMaterials] += amount;

                format(szMessage, sizeof(szMessage), "You have given %d materials to %s.", amount, playerName[1]);
                SendClientMessage(playerid, COLOR_WHITE, szMessage);

                format(szMessage, sizeof(szMessage), "%s has given you %d materials.", playerName[0], amount);
                SendClientMessage(targetID, COLOR_WHITE, szMessage);

                format(szMessage, sizeof(szMessage), "* %s has given %d materials to %s.", playerName[0], amount, playerName[1]);
                nearByMessage(playerid, COLOR_PURPLE, szMessage);
			}
			else {
				format(szMessage, sizeof(szMessage), "You don't have enough materials to complete this trade. You need %d more materials.", playerVariables[playerid][pMaterials]-amount);
				SendClientMessage(playerid, COLOR_WHITE, szMessage);
			}
		}
	}
	return 1;
}

CMD:giveweapon(playerid, params[]) {
	new
		id,
		weapon;

	if(sscanf(params, "u", id))
		return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/giveweapon [playerid]");
		
	else if(playerVariables[playerid][pFreezeType] == 0) {
		if(id != INVALID_PLAYER_ID) {
	   	    if(IsPlayerInRangeOfPlayer(playerid, id, 4.0) && !IsPlayerInAnyVehicle(playerid)) {

				weapon = GetPlayerWeapon(playerid);

				switch(weapon) {
					case 16, 18, 35, 36, 37, 38, 39, 40, 44, 45, 46, 0: SendClientMessage(playerid, COLOR_GREY, "Invalid weapon.");
					default: {

						GetPlayerName(id, szPlayerName, MAX_PLAYER_NAME);
						format(szMessage, sizeof(szMessage), "You have offered to give %s your %s.", szPlayerName, WeaponNames[weapon]);
						SendClientMessage(playerid, COLOR_WHITE, szMessage);

						GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
						format(szMessage, sizeof(szMessage), "%s has offered to give you their %s - type /accept weapon to receive it.", szPlayerName, WeaponNames[weapon]);
						SendClientMessage(id, COLOR_NICESKY, szMessage);

						SetPVarInt(id,"gunID",playerid);
						SetPVarInt(playerid,"gun",weapon);
						SetPVarInt(playerid,"slot",GetWeaponSlot(weapon));
					}
				}
	    	}
	    	else SendClientMessage(playerid, COLOR_GREY, "You're too far away or in a vehicle.");
	    }
		else SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");
	}
	else SendClientMessage(playerid, COLOR_GREY, "You can't do this while cuffed, tazed, or frozen.");
	return 1;
}

CMD:givearmour(playerid, params[]) {
	new
		id;

	if(sscanf(params, "u", id))
		return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/givearmour [playerid]");

	else if(playerVariables[playerid][pFreezeType] == 0) {
		if(id != INVALID_PLAYER_ID) {
	   	    if(IsPlayerInRangeOfPlayer(playerid, id, 4.0)) {

				new
					Float:fArmour;

				GetPlayerArmour(playerid, fArmour);

				if(fArmour > 0) {
					GetPlayerName(id, szPlayerName, MAX_PLAYER_NAME);
					format(szMessage, sizeof(szMessage), "You have offered to give %s your kevlar vest (%.1f percent).", szPlayerName, fArmour);
					SendClientMessage(playerid, COLOR_WHITE, szMessage);

					GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
					format(szMessage, sizeof(szMessage), "%s has offered to give you their kevlar vest (%.1f percent) - type /accept armour to receive it.", szPlayerName, fArmour);
					SendClientMessage(id, COLOR_NICESKY, szMessage);

					SetPVarInt(id, "aID", playerid + 1);
				}
				else SendClientMessage(playerid, COLOR_GREY, "You have no armour to give.");
	    	}
	    	else SendClientMessage(playerid, COLOR_GREY, "You're too far away.");
	    }
		else SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");
	}
	else SendClientMessage(playerid, COLOR_GREY, "You can't do this while cuffed, tazed, or frozen.");
	return 1;
}

CMD:noscar(playerid, params[]) 
{
	if(jobVariables[playerVariables[playerid][pJob]][jJobType] == 3) 
	{
		new vehicleID = GetPlayerVehicleID(playerid);
		if(vehicleID != 0) 
		{
			new Float:soPos[3], vehicleModel = GetVehicleModel(vehicleID);

			if(IsInvalidNOSVehicle(vehicleModel)) 
			{
				format(szMessage, sizeof(szMessage), "You can't modify this %s.", VehicleNames[vehicleModel - 400]);
		        SendClientMessage(playerid, COLOR_GREY, szMessage);
		    }
		    else if(playerVariables[playerid][pJobDelay] == 0) 
			{

				GetVehiclePos(vehicleID, soPos[0], soPos[1], soPos[2]);
				PlayerPlaySoundEx(1133, soPos[0], soPos[1], soPos[2]);

				AddVehicleComponent(vehicleID, 1010);
				format(szMessage, sizeof(szMessage), "You have applied nitrous to your %s for $1,000.", VehicleNames[vehicleModel - 400]);
				SendClientMessage(playerid, COLOR_WHITE, szMessage);
				playerVariables[playerid][pMoney] -= 1000;
				playerVariables[playerid][pJobDelay] = 60;
		    }
		    else 
			{
				format(szMessage, sizeof(szMessage), "You need to wait %d seconds until you can use a mechanic command again.",playerVariables[playerid][pJobDelay]);
		        SendClientMessage(playerid, COLOR_GREY, szMessage);
			}
		}
		else
			SendClientMessage(playerid, COLOR_GREY, "You're not in any vehicle.");
	}
	return 1;
}

CMD:hydcar(playerid, params[]) 
{
	if(jobVariables[playerVariables[playerid][pJob]][jJobType] == 3) 
	{
		new vehicleID = GetPlayerVehicleID(playerid);
		if(vehicleID != 0) 
		{
			new Float:soPos[3], vehicleModel = GetVehicleModel(vehicleID);

			if(IsInvalidNOSVehicle(vehicleModel)) 
			{
				format(szMessage, sizeof(szMessage), "You can't modify this %s.", VehicleNames[vehicleModel - 400]);
		        SendClientMessage(playerid, COLOR_GREY, szMessage);
		    }
		    else if(playerVariables[playerid][pJobDelay] == 0) 
			{
				GetVehiclePos(vehicleID, soPos[0], soPos[1], soPos[2]);
				PlayerPlaySoundEx(1133, soPos[0], soPos[1], soPos[2]);

				AddVehicleComponent(vehicleID, 1087);
				format(szMessage, sizeof(szMessage), "You have applied hydraulics to your %s for $1,000.", VehicleNames[vehicleModel - 400]);
				SendClientMessage(playerid, COLOR_WHITE, szMessage);
				playerVariables[playerid][pMoney] -= 1000;
				playerVariables[playerid][pJobDelay] = 60;
		    }
		    else 
			{
				format(szMessage, sizeof(szMessage), "You need to wait %d seconds until you can use a mechanic command again.",playerVariables[playerid][pJobDelay]);
		        SendClientMessage(playerid, COLOR_GREY, szMessage);
			}
		}
		else 
			SendClientMessage(playerid, COLOR_GREY, "You're not in any vehicle.");
	}
	return 1;
}


CMD:seenewbie(playerid, params[]) {
	if(playerVariables[playerid][pNewbieEnabled] == 1) {
	    playerVariables[playerid][pNewbieEnabled] = 0;
	    SendClientMessage(playerid, COLOR_WHITE, "You will no longer see newbie chat.");
	}
	else {
	    playerVariables[playerid][pNewbieEnabled] = 1;
	    SendClientMessage(playerid, COLOR_WHITE, "You will now see newbie chat.");
	}
	return 1;
}

CMD:getmats(playerid, params[]) {
    if(jobVariables[playerVariables[playerid][pJob]][jJobType] != 1) return 1;

	if(IsPlayerInRangeOfPoint(playerid, 5, 1423.9871, -1319.2954, 13.5547)) {
	    if(playerVariables[playerid][pCheckpoint] == 0) {
	        if(playerVariables[playerid][pMoney] >= 1000) {
		        SetPlayerCheckpoint(playerid, 2166.6870, -2272.5073, 13.3623, 10);
		        SendClientMessage(playerid, COLOR_WHITE, "Reach the checkpoint to collect your materials.");
		        playerVariables[playerid][pCheckpoint] = 2;
		        playerVariables[playerid][pMoney] -= 1000;
		        playerVariables[playerid][pMatrunTime] = 1;
	        }
	        else {
				return SendClientMessage(playerid, COLOR_GREY, "You need to pay $1000 to collect materials.");
			}
	    }
	    else {
	        format(szMessage, sizeof(szMessage), "You already have an active checkpoint (%s), reach it first, or /killcheckpoint.", getPlayerCheckpointReason(playerid));
			SendClientMessage(playerid, COLOR_WHITE, szMessage);
		}
	}

	return 1;
}

CMD:dropcar(playerid, params[]) {
	if(playerVariables[playerid][pCheckpoint] >= 1) {
        format(szMessage, sizeof(szMessage), "You already have an active checkpoint (%s), reach it first, or /killcheckpoint.", getPlayerCheckpointReason(playerid));
		SendClientMessage(playerid, COLOR_WHITE, szMessage);
	}
	else {
	    if(playerVariables[playerid][pDropCarTimeout] >= 1)
			return SendClientMessage(playerid, COLOR_GREY, "You can't drop a vehicle as you still have time to wait. Check /time.");
			
	    playerVariables[playerid][pCheckpoint] = 3;
	    SendClientMessage(playerid, COLOR_WHITE, "Reach the checkpoint to drop your vehicle off at the crane.");
		SetPlayerCheckpoint(playerid, 2699.2781, -2225.4299, 13.5501, 10);
	}
	return 1;
}

CMD:newbie(playerid, params[]) {
	if(playerVariables[playerid][pNewbieTimeout] > 0 && playerVariables[playerid][pAdminLevel] < 1) {
		SendClientMessage(playerid,COLOR_GREY, "You must wait until you can speak again in the newbie chat channel.");
		return 1;
	}
	if(!isnull(params)) {
	    GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);

		if(playerVariables[playerid][pAdminLevel] > 0 && playerVariables[playerid][pAdminDuty] != 0) {
			format(szMessage, sizeof(szMessage), "** Admin %s: %s", szPlayerName, params);
		}
		else if(playerVariables[playerid][pHelper] >= 1 && playerVariables[playerid][pHelperDuty] >= 1) {
		    format(szMessage, sizeof(szMessage), "** Helper %s: %s", szPlayerName, params);
			playerVariables[playerid][pNewbieTimeout] = 5;
		}
		else if(playerVariables[playerid][pAdminLevel] > 0 && playerVariables[playerid][pAdminDuty] == 0) {
			format(szMessage, sizeof(szMessage), "** Player %s: %s", szPlayerName, params);
		}
		else if(playerVariables[playerid][pPlayingHours] >= 100) {
			format(szMessage, sizeof(szMessage), "** Player %s: %s", szPlayerName, params);
			playerVariables[playerid][pNewbieTimeout] = 30;
		}
		else {
			format(szMessage, sizeof(szMessage), "** Newbie %s: %s", szPlayerName, params);
			playerVariables[playerid][pNewbieTimeout] = 30;
		}
		foreach(Player, x) {
			if(playerVariables[x][pStatus] == 1 && playerVariables[x][pNewbieEnabled] == 1) {
				SendClientMessage(x, COLOR_NEWBIE, szMessage);
			}
		}
	}
	else {
	    return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/(n)ewbie [question]");
	}
	return 1;
}

CMD:listassets(playerid, params[]) {
    if(playerVariables[playerid][pAdminLevel] >= 5) {
        for(new x = 0; x < MAX_ASSETS; x++) {
			if(strlen(assetVariables[x][aAssetName]) >= 1) {
				format(szMessage, sizeof(szMessage), "Asset Name: %s | Asset ID: %d | Value: %d", assetVariables[x][aAssetName], x, assetVariables[x][aAssetValue]);
				SendClientMessage(playerid, COLOR_WHITE, szMessage);
			}
		}
	}
	return 1;
}

CMD:listmygroup(playerid, params[]) {
	if(playerVariables[playerid][pGroup] >= 1 && playerVariables[playerid][pGroupRank] >= 4) {
		SendClientMessage(playerid, COLOR_TEAL, "----------------------------------------------------------------");

		foreach(Player, i) {
	        if(IsPlayerAuthed(i) && playerVariables[i][pGroup] == playerVariables[playerid][pGroup] && playerVariables[i][pAdminDuty] < 1) {

				switch(playerVariables[i][pGroupRank]) {
					case 1: format(szMessage, sizeof(szMessage), "* (%d) %s %s", playerVariables[i][pGroupRank], groupVariables[playerVariables[i][pGroup]][gGroupRankName1], playerVariables[i][pNormalName]);
					case 2: format(szMessage, sizeof(szMessage), "* (%d) %s %s", playerVariables[i][pGroupRank], groupVariables[playerVariables[i][pGroup]][gGroupRankName2], playerVariables[i][pNormalName]);
					case 3: format(szMessage, sizeof(szMessage), "* (%d) %s %s", playerVariables[i][pGroupRank], groupVariables[playerVariables[i][pGroup]][gGroupRankName3], playerVariables[i][pNormalName]);
					case 4: format(szMessage, sizeof(szMessage), "* (%d) %s %s", playerVariables[i][pGroupRank], groupVariables[playerVariables[i][pGroup]][gGroupRankName4], playerVariables[i][pNormalName]);
					case 5: format(szMessage, sizeof(szMessage), "* (%d) %s %s", playerVariables[i][pGroupRank], groupVariables[playerVariables[i][pGroup]][gGroupRankName5], playerVariables[i][pNormalName]);
					case 6: format(szMessage, sizeof(szMessage), "* (%d) %s %s", playerVariables[i][pGroupRank], groupVariables[playerVariables[i][pGroup]][gGroupRankName6], playerVariables[i][pNormalName]);

				}
				SendClientMessage(playerid, COLOR_WHITE, szMessage);
	        }
	    }
	    SendClientMessage(playerid, COLOR_TEAL, "----------------------------------------------------------------");
	}
	return 1;
}

CMD:n(playerid, params[]) {
	return cmd_newbie(playerid, params);
}

CMD:set(playerid, params[]) {
    if(playerVariables[playerid][pAdminLevel] >= 3) {
        new
            item[32],
            userID,
            amount;

        if(sscanf(params, "us[32]d", userID, item, amount)) {
			SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/set [playerid] [item] [amount]");
			SendClientMessage(playerid, COLOR_GREY, "Items: Health, Armour, Money, BankMoney, Skin, Interior, VirtualWorld, Job, JobSkill1, JobSkill2,");
			SendClientMessage(playerid, COLOR_GREY, "Phone, Materials, Group, GroupRank, Age, Gender");
		}
        else if(IsPlayerAuthed(userID)) {
            if(playerVariables[playerid][pAdminLevel] >= playerVariables[userID][pAdminLevel]) {
				GetPlayerName(userID, szPlayerName, MAX_PLAYER_NAME);

				if(strcmp(item, "health", true) == 0) {
					format(szMessage, sizeof(szMessage), "You have set %s (ID: %d)'s health to %d.", szPlayerName, userID, amount);
					SendClientMessage(playerid, COLOR_WHITE, szMessage);
					SetPlayerHealth(userID, amount);
				}
				else if(strcmp(item, "jobskill2", true) == 0) {
					format(szMessage, sizeof(szMessage), "You have set %s (ID: %d)'s JobSkill2 to %d.", szPlayerName, userID, amount);
					SendClientMessage(playerid, COLOR_WHITE, szMessage);
					playerVariables[userID][pJobSkill][1] = amount;
				}
				else if(strcmp(item, "jobskill1", true) == 0) {
					format(szMessage, sizeof(szMessage), "You have set %s (ID: %d)'s JobSkill1 to %d.", szPlayerName, userID, amount);
					SendClientMessage(playerid, COLOR_WHITE, szMessage);
					playerVariables[userID][pJobSkill][0] = amount;
				}
				else if(strcmp(item, "virtualworld", true) == 0) {
					format(szMessage, sizeof(szMessage), "You have set %s (ID: %d)'s virtual world to %d.", szPlayerName, userID, amount);
					SendClientMessage(playerid, COLOR_WHITE, szMessage);
					SetPlayerVirtualWorld(userID, amount);
					playerVariables[userID][pVirtualWorld] = amount;
				}
				else if(strcmp(item, "interior", true) == 0) {
					format(szMessage, sizeof(szMessage), "You have set %s (ID: %d)'s interior to %d.", szPlayerName, userID, amount);
					SendClientMessage(playerid, COLOR_WHITE, szMessage);
					SetPlayerInterior(userID, amount);
					playerVariables[userID][pInterior] = amount;
				}
				else if(strcmp(item, "job", true) == 0) {
					if(amount >= 0 && amount <= MAX_JOBS) {
						format(szMessage, sizeof(szMessage), "You have set %s (ID: %d)'s job to %d.", szPlayerName, userID, amount);
						SendClientMessage(playerid, COLOR_WHITE, szMessage);
						playerVariables[userID][pJob] = amount;
						playerVariables[userID][pJobDelay] = 0;
					}
					else SendClientMessage(playerid, COLOR_GREY, "Invalid job specified.");
				}
				else if(strcmp(item, "armour", true) == 0) {
					format(szMessage, sizeof(szMessage), "You have set %s (ID: %d)'s armour to %d.", szPlayerName, userID, amount);
					SendClientMessage(playerid, COLOR_WHITE, szMessage);
					SetPlayerArmour(userID, amount);
				}
				else if(strcmp(item, "bankmoney", true) == 0) {
					format(szMessage, sizeof(szMessage), "You have set %s (ID: %d)'s bank balance to %d.", szPlayerName, userID, amount);
					SendClientMessage(playerid, COLOR_WHITE, szMessage);
					playerVariables[userID][pBankMoney] = amount;
				}
				else if(strcmp(item, "money", true) == 0) {
					format(szMessage, sizeof(szMessage), "You have set %s (ID: %d)'s money to %d.", szPlayerName, userID, amount);
					SendClientMessage(playerid, COLOR_WHITE, szMessage);
					playerVariables[userID][pMoney] = amount;
				}
				else if(strcmp(item, "materials", true) == 0) {
					format(szMessage, sizeof(szMessage), "You have set %s (ID: %d)'s materials to %d.", szPlayerName, userID, amount);
					SendClientMessage(playerid, COLOR_WHITE, szMessage);
					playerVariables[userID][pMaterials] = amount;
				}
				else if(strcmp(item, "skin", true) == 0) {
					if(IsValidSkin(amount)) {
						format(szMessage, sizeof(szMessage), "You have set %s (ID: %d)'s skin to %d.", szPlayerName, userID, amount);
						SendClientMessage(playerid, COLOR_WHITE, szMessage);
						SetPlayerSkin(userID, amount);
						if(playerVariables[userID][pEvent] == 1) SendClientMessage(playerid, COLOR_WHITE, "As this player is participating in an event, their original skin will be restored once it has ended.");
						else playerVariables[userID][pSkin] = amount;
					}
					else SendClientMessage(playerid, COLOR_GREY, "Invalid skin specified.");
				}
				else if(strcmp(item, "phone", true) == 0) {
					format(szMessage, sizeof(szMessage), "You have set %s (ID: %d)'s phone number to %d.", szPlayerName, userID, amount);
					SendClientMessage(playerid, COLOR_WHITE, szMessage);
					playerVariables[userID][pPhoneNumber] = amount;
				}
				else if(strcmp(item, "group", true) == 0) {
					if(amount >= 0 && amount <= MAX_GROUPS) {

						format(szMessage, sizeof(szMessage), "You have set %s (ID: %d)'s group to %d.", szPlayerName, userID, amount);
						SendClientMessage(playerid, COLOR_WHITE, szMessage);

						format(szMessage, sizeof(szMessage), "%s has left the group (admin-set).", szPlayerName);
						SendToGroup(playerVariables[userID][pGroup], COLOR_GENANNOUNCE, szMessage);

						playerVariables[userID][pGroup] = amount;

						format(szMessage, sizeof(szMessage), "%s has joined the group (admin-set).", szPlayerName);
						SendToGroup(playerVariables[userID][pGroup], COLOR_GENANNOUNCE, szMessage);
					}
					else SendClientMessage(playerid, COLOR_GREY, "Invalid group specified.");
				}
				else if(strcmp(item, "grouprank", true) == 0) {
					if(amount >= 1 && amount <= 6) {
						format(szMessage, sizeof(szMessage), "You have set %s (ID: %d)'s group rank to %d.", szPlayerName, userID, amount);
						SendClientMessage(playerid, COLOR_WHITE, szMessage);
						playerVariables[userID][pGroupRank] = amount;
					}
					else SendClientMessage(playerid, COLOR_GREY, "Invalid rank specified.");
				}
				else if(strcmp(item, "age", true) == 0) {
					if(amount >= 16 && amount <= 122) {

						new
							dates[3];

						getdate(dates[0], dates[1], dates[2]);
						playerVariables[userID][pAge] = dates[0] - amount;

						format(szMessage, sizeof(szMessage), "You have set %s (ID: %d)'s age to %d (birth year %d).", szPlayerName, userID, amount, playerVariables[userID][pAge]);
						SendClientMessage(playerid, COLOR_WHITE, szMessage);
					}
					else SendClientMessage(playerid, COLOR_GREY, "Invalid age specified (must be between 16 and 122 years old).");
				}
				else if(strcmp(item, "gender", true) == 0) {
					if(amount >= 1 && amount <= 2) {

						playerVariables[userID][pGender] = amount;

						switch(playerVariables[userID][pGender]) {
							case 1: format(szMessage, sizeof(szMessage), "You have set %s (ID: %d)'s gender to male.", szPlayerName, userID);
							case 2: format(szMessage, sizeof(szMessage), "You have set %s (ID: %d)'s gender to female.", szPlayerName, userID);
						}
						SendClientMessage(playerid, COLOR_WHITE, szMessage);
					}
					else SendClientMessage(playerid, COLOR_GREY, "Invalid gender specified; must be 1 (male) or 2 (female).");
				}
			}
			else SendClientMessage(playerid, COLOR_GREY, "You can't set a higher level administrator's statistics.");
        }
		else SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");
    }
	return 1;
}

CMD:gmotd(playerid, params[]) {
	if(playerVariables[playerid][pGroup] >= 1 && playerVariables[playerid][pGroupRank] >= 5) {
	    if(!isnull(params)) {
			format(szMessage, sizeof(szMessage), "You have changed the group MOTD to %s.", params);
			SendClientMessage(playerid, COLOR_WHITE, szMessage);

			GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
			format(szMessage, sizeof(szMessage), "%s has changed the group MOTD to '%s'.", szPlayerName, params);
			SendToGroup(playerVariables[playerid][pGroup], COLOR_GENANNOUNCE, szMessage);

			mysql_real_escape_string(params, szMessage);

			strcpy(groupVariables[playerVariables[playerid][pGroup]][gGroupMOTD], szMessage, 128);
		}
		else {
			return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/gmotd [text]");
		}
	}
	return 1;
}

CMD:gsafepos(playerid, params[]) {
	if(playerVariables[playerid][pGroup] >= 1 && playerVariables[playerid][pGroupRank] >= 6) {

		GetPlayerPos(playerid, groupVariables[playerVariables[playerid][pGroup]][gSafePos][0], groupVariables[playerVariables[playerid][pGroup]][gSafePos][1], groupVariables[playerVariables[playerid][pGroup]][gSafePos][2]);

		DestroyDynamicPickup(groupVariables[playerVariables[playerid][pGroup]][gSafePickupID]);
		DestroyDynamic3DTextLabel(groupVariables[playerVariables[playerid][pGroup]][gSafeLabelID]);

		format(szMessage, sizeof(szMessage), "%s\nGroup Safe", groupVariables[playerVariables[playerid][pGroup]][gGroupName]);

		groupVariables[playerVariables[playerid][pGroup]][gSafePickupID] = CreateDynamicPickup(1239, 23, groupVariables[playerVariables[playerid][pGroup]][gSafePos][0], groupVariables[playerVariables[playerid][pGroup]][gSafePos][1], groupVariables[playerVariables[playerid][pGroup]][gSafePos][2], GROUP_VIRTUAL_WORLD+playerVariables[playerid][pGroup], groupVariables[playerVariables[playerid][pGroup]][gGroupHQInteriorID], -1, 50);
		groupVariables[playerVariables[playerid][pGroup]][gSafeLabelID] = CreateDynamic3DTextLabel(szMessage, COLOR_YELLOW, groupVariables[playerVariables[playerid][pGroup]][gSafePos][0], groupVariables[playerVariables[playerid][pGroup]][gSafePos][1], groupVariables[playerVariables[playerid][pGroup]][gSafePos][2], 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, GROUP_VIRTUAL_WORLD+playerVariables[playerid][pGroup], groupVariables[playerVariables[playerid][pGroup]][gGroupHQInteriorID], -1, 50.0);

		SendClientMessage(playerid, COLOR_WHITE, "You have adjusted the position of your group's safe.");
	}
	return 1;
}

CMD:gname(playerid, params[]) {
	if(playerVariables[playerid][pGroup] >= 1 && playerVariables[playerid][pGroupRank] >= 6) {
	    if(!isnull(params)) {

			new
				safeString[102];

			format(safeString, sizeof(safeString), "You have changed the group name to %s.", params);
			SendClientMessage(playerid, COLOR_WHITE, safeString);

			mysql_real_escape_string(params, safeString);

			strcpy(groupVariables[playerVariables[playerid][pGroup]][gGroupName], safeString, 64);

			switch(groupVariables[playerVariables[playerid][pGroup]][gGroupHQLockStatus]) {
				case 0: format(safeString, sizeof(safeString), "%s's HQ\n\nPress ~k~~PED_DUCK~ to enter.", groupVariables[playerVariables[playerid][pGroup]][gGroupName]);
				case 1: format(safeString, sizeof(safeString), "%s's HQ\n\n(locked)", groupVariables[playerVariables[playerid][pGroup]][gGroupName]);
			}

			UpdateDynamic3DTextLabelText(groupVariables[playerVariables[playerid][pGroup]][gGroupLabelID], COLOR_YELLOW, safeString);

			format(safeString, sizeof(safeString), "%s\nGroup Safe", groupVariables[playerVariables[playerid][pGroup]][gGroupName]);

			UpdateDynamic3DTextLabelText(groupVariables[playerVariables[playerid][pGroup]][gSafeLabelID], COLOR_YELLOW, safeString);

		}
		else SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/gname [group name]");
	}
	return 1;
}

CMD:showmotd(playerid, params[]) {
	if(playerVariables[playerid][pGroup] >= 1) {

		new string[128];
		format(string, sizeof(string), "Group MOTD: {FFFFFF}%s", groupVariables[playerVariables[playerid][pGroup]][gGroupMOTD]);
		SendClientMessage(playerid, COLOR_GENANNOUNCE, string);
	}
	return 1;
}

CMD:upgradelevel(playerid, params[]) {
	/* 1 level costs Level x min_level_upgrade_cost */
	if(playerVariables[playerid][pBankMoney] >= playerVariables[playerid][pLevel] + 1 * assetVariables[3][aAssetValue] && playerVariables[playerid][pBankMoney] > 0) {
	    if(playerVariables[playerid][pLevel] >= 10)
	        return SendClientMessage(playerid, COLOR_GREY, "You're at the maximum level.");

		if(FetchLevelFromHours(playerVariables[playerid][pPlayingHours]) == playerVariables[playerid][pLevel])
		    return SendClientMessage(playerid, COLOR_GREY, "You can't upgrade your level yet.");

        playerVariables[playerid][pLevel] += 1;
        playerVariables[playerid][pBankMoney] -= playerVariables[playerid][pLevel] + 1 * assetVariables[3][aAssetValue];

        SetPlayerScore(playerid, playerVariables[playerid][pLevel]);
	}
	return 1;
}

CMD:invite(playerid, params[]) {
    if(playerVariables[playerid][pGroup] >= 1 && playerVariables[playerid][pGroupRank] >= 5) {
        new
            userID;

        if(sscanf(params, "u", userID)) {
            return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/invite [playerid]");
        }
        else {
            if(!IsPlayerConnected(userID)) return SendClientMessage(playerid, COLOR_GREY, "The specified userID/name is not connected.");
			else if(playerVariables[userID][pGroup] > 0) return SendClientMessage(playerid, COLOR_GREY, "That player is already in a group.");

			if(playerVariables[userID][pLevel] < assetVariables[2][aAssetValue]) {
			    format(szMessage, sizeof(szMessage), "You can't invite a player below level %d.", assetVariables[2][aAssetValue]);
			    SendClientMessage(playerid, COLOR_GREY, szMessage);

			    format(szMessage, sizeof(szMessage), "You have been invited to a group, but you can't accept the invite. You must be at least level %d, you've got %d levels to go!", assetVariables[2][aAssetValue], assetVariables[2][aAssetValue]-playerVariables[userID][pLevel]);
			    return SendClientMessage(playerid, COLOR_GREY, szMessage);
			}

			GetPlayerName(userID, szPlayerName, MAX_PLAYER_NAME);
			format(szMessage, sizeof(szMessage), "You have invited %s to join your group.", szPlayerName);
			SendClientMessage(playerid, COLOR_WHITE, szMessage);

			GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
			format(szMessage, sizeof(szMessage), "%s has invited you to join group %s (to accept the invitation, type '/accept invite').", szPlayerName, groupVariables[playerVariables[playerid][pGroup]][gGroupName]);
			SendClientMessage(userID, COLOR_NICESKY, szMessage);

			SetPVarInt(userID, "invID", playerVariables[playerid][pGroup]); // Storing in a PVar as it's something that won't be used frequently, saving memory. Also, keeping the variable names short, as they're stored in memory and literally kill!!1
		}
    }

    return 1;
}

CMD:uninvite(playerid, params[]) {
	if(playerVariables[playerid][pGroup] >= 1 && playerVariables[playerid][pGroupRank] >= 5) {
	    new
	        userID;

        if(sscanf(params, "u", userID)) {
            return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/uninvite [playerid]");
        }
        else {
            if(!IsPlayerConnected(userID)) return SendClientMessage(playerid, COLOR_GREY, "The specified userID/name is not connected.");
			else if(playerVariables[playerid][pGroup] != playerVariables[userID][pGroup]) return SendClientMessage(playerid, COLOR_GREY, "That player isn't in your group.");
			else if(playerVariables[playerid][pGroupRank] <= playerVariables[userID][pGroupRank]) return SendClientMessage(playerid, COLOR_GREY, "You can't uninvite this person.");

			new
				messageString[119];

			GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
			format(messageString, sizeof(messageString), "%s has removed you from the %s.", szPlayerName, groupVariables[playerVariables[userID][pGroup]][gGroupName]);
			SendClientMessage(userID, COLOR_NICESKY, messageString);

			GetPlayerName(userID, szPlayerName, MAX_PLAYER_NAME);
			format(messageString, sizeof(messageString), "You have removed %s from your group.", szPlayerName);
			SendClientMessage(playerid, COLOR_WHITE, messageString);

			format(messageString, sizeof(messageString), "%s has left the group (uninvited).", szPlayerName);
			SendToGroup(playerVariables[playerid][pGroup], COLOR_GENANNOUNCE, messageString);

			playerVariables[userID][pGroup] = 0;
			playerVariables[userID][pGroupRank] = 0;
        }
	}
	return 1;
}
CMD:lockhq(playerid, params[]) {
	if(playerVariables[playerid][pGroup] >= 1 && playerVariables[playerid][pGroupRank] >= 5) {
		switch(groupVariables[playerVariables[playerid][pGroup]][gGroupHQLockStatus]) {
			case 1: {
			    SendClientMessage(playerid, COLOR_WHITE, "HQ unlocked.");
				groupVariables[playerVariables[playerid][pGroup]][gGroupHQLockStatus] = 0;
				format(szMessage, sizeof(szMessage), "%s's HQ\n\nPress ~k~~PED_DUCK~ to enter.", groupVariables[playerVariables[playerid][pGroup]][gGroupName]);
			}
			case 0: {
			    SendClientMessage(playerid, COLOR_WHITE, "HQ locked.");
				groupVariables[playerVariables[playerid][pGroup]][gGroupHQLockStatus] = 1;
			    format(szMessage, sizeof(szMessage), "%s's HQ\n\n(locked)", groupVariables[playerVariables[playerid][pGroup]][gGroupName]);
			}
		}

		UpdateDynamic3DTextLabelText(groupVariables[playerVariables[playerid][pGroup]][gGroupLabelID], COLOR_YELLOW, szMessage);
	}
	return 1;
}
CMD:changerank(playerid, params[]) {
	if(playerVariables[playerid][pGroup] >= 1 && playerVariables[playerid][pGroupRank] >= 5) {
	    new
			rank,
	        userID;

        if(sscanf(params, "ud", userID, rank)) {
            SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/changerank [playerid] [rank]");
        }
        else {
            if(!IsPlayerConnected(userID)) return SendClientMessage(playerid, COLOR_GREY, "The specified userID/name is not connected.");
			else if(rank < 1 || rank > 6) return SendClientMessage(playerid, COLOR_GREY, "Invalid rank specified.");
			else if(playerVariables[playerid][pGroup] != playerVariables[userID][pGroup]) return SendClientMessage(playerid, COLOR_GREY, "That player isn't in your group.");
			else if(playerVariables[playerid][pGroupRank] <= rank) return SendClientMessage(playerid, COLOR_GREY, "You can't promote to this rank.");
			else if(playerVariables[playerid][pGroupRank] <= playerVariables[userID][pGroupRank]) return SendClientMessage(playerid, COLOR_GREY, "You can't alter this person's rank.");
			else if(playerVariables[userID][pGroupRank] == rank) return SendClientMessage(playerid, COLOR_GREY, "That person is already of that rank.");
			else {

				new
					messageString[128];

				GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
				if(rank > playerVariables[userID][pGroupRank]) switch(rank) {

					case 1: format(messageString, sizeof(messageString), "%s has promoted you to the rank of %s (1).", szPlayerName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName1]);
					case 2: format(messageString, sizeof(messageString), "%s has promoted you to the rank of %s (2).", szPlayerName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName2]);
					case 3: format(messageString, sizeof(messageString), "%s has promoted you to the rank of %s (3).", szPlayerName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName3]);
					case 4: format(messageString, sizeof(messageString), "%s has promoted you to the rank of %s (4).", szPlayerName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName4]);
					case 5: format(messageString, sizeof(messageString), "%s has promoted you to the rank of %s (5).", szPlayerName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName5]);
					case 6: format(messageString, sizeof(messageString), "%s has promoted you to the rank of %s (6).", szPlayerName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName6]);

				}
				else switch(rank) {

					case 1: format(messageString, sizeof(messageString), "%s has demoted you to the rank of %s (1).", szPlayerName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName1]);
					case 2: format(messageString, sizeof(messageString), "%s has demoted you to the rank of %s (2).", szPlayerName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName2]);
					case 3: format(messageString, sizeof(messageString), "%s has demoted you to the rank of %s (3).", szPlayerName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName3]);
					case 4: format(messageString, sizeof(messageString), "%s has demoted you to the rank of %s (4).", szPlayerName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName4]);
					case 5: format(messageString, sizeof(messageString), "%s has demoted you to the rank of %s (5).", szPlayerName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName5]);
					case 6: format(messageString, sizeof(messageString), "%s has demoted you to the rank of %s (6).", szPlayerName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName6]);
				}
				SendClientMessage(userID, COLOR_NICESKY, messageString);

				GetPlayerName(userID, szPlayerName, MAX_PLAYER_NAME);

				if(rank > playerVariables[userID][pGroupRank]) switch(rank) {

					case 1: format(messageString, sizeof(messageString), "You have promoted %s to the rank of %s (1).", szPlayerName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName1]);
					case 2: format(messageString, sizeof(messageString), "You have promoted %s to the rank of %s (2).", szPlayerName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName2]);
					case 3: format(messageString, sizeof(messageString), "You have promoted %s to the rank of %s (3).", szPlayerName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName3]);
					case 4: format(messageString, sizeof(messageString), "You have promoted %s to the rank of %s (4).", szPlayerName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName4]);
					case 5: format(messageString, sizeof(messageString), "You have promoted %s to the rank of %s (5).", szPlayerName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName5]);
					case 6: format(messageString, sizeof(messageString), "You have promoted %s to the rank of %s (6).", szPlayerName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName6]);

				}
				else switch(rank) {

					case 1: format(messageString, sizeof(messageString), "You have demoted %s to the rank of %s (1).", szPlayerName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName1]);
					case 2: format(messageString, sizeof(messageString), "You have demoted %s to the rank of %s (2).", szPlayerName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName2]);
					case 3: format(messageString, sizeof(messageString), "You have demoted %s to the rank of %s (3).", szPlayerName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName3]);
					case 4: format(messageString, sizeof(messageString), "You have demoted %s to the rank of %s (4).", szPlayerName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName4]);
					case 5: format(messageString, sizeof(messageString), "You have demoted %s to the rank of %s (5).", szPlayerName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName5]);
					case 6: format(messageString, sizeof(messageString), "You have demoted %s to the rank of %s (6).", szPlayerName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName6]);
				}
				SendClientMessage(playerid, COLOR_WHITE, messageString);

				playerVariables[userID][pGroupRank] = rank;
			}
        }
	}
	return 1;
}

CMD:granknames(playerid, params[]) {
    if(playerVariables[playerid][pGroup] >= 1 && playerVariables[playerid][pGroupRank] >= 6) {
		new
		    rankName[32],
		    rankID;

	    if(sscanf(params, "ds[32]", rankID, rankName)) {
			return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/granknames [rankid (1-6)] [rank title]");
		}
	    else {
	        new
				messageString[128];

	        switch(rankID) {
				case 1: {
				    mysql_real_escape_string(rankName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName1]);

				    format(messageString, sizeof(messageString), "You have changed the title of Rank 1 to '%s'.", rankName);
				    SendClientMessage(playerid, COLOR_WHITE, messageString);
				}
				case 2: {
				    mysql_real_escape_string(rankName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName2]);

				    format(messageString, sizeof(messageString), "You have changed the title of Rank 2 to '%s'.", rankName);
				    SendClientMessage(playerid, COLOR_WHITE, messageString);
				}
				case 3: {
				    mysql_real_escape_string(rankName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName3]);

				    format(messageString, sizeof(messageString), "You have changed the title of Rank 3 to '%s'.", rankName);
				    SendClientMessage(playerid, COLOR_WHITE, messageString);
				}
				case 4: {
				    mysql_real_escape_string(rankName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName4]);

				    format(messageString, sizeof(messageString), "You have changed the title of Rank 4 to '%s'.", rankName);
				    SendClientMessage(playerid, COLOR_WHITE, messageString);
				}
				case 5: {
				    mysql_real_escape_string(rankName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName5]);

				    format(messageString, sizeof(messageString), "You have changed the title of Rank 5 to '%s'.", rankName);
				    SendClientMessage(playerid, COLOR_WHITE, messageString);
				}
				case 6: {
				    mysql_real_escape_string(rankName, groupVariables[playerVariables[playerid][pGroup]][gGroupRankName6]);

				    format(messageString, sizeof(messageString), "You have changed the title of Rank 6 to '%s'.", rankName);
				    SendClientMessage(playerid, COLOR_WHITE, messageString);
				}
			}
	    }
    }
	return 1;
}

CMD:accept(playerid, params[]) {
	if(!isnull(params)) {
		if(strcmp(params, "ticket", true) == 0) {

			new
				ticketer = GetPVarInt(playerid, "tID") - 1,
				ticketPrice = GetPVarInt(playerid, "tP"),
				ticketString[128],
				ticketNames[2][MAX_PLAYER_NAME];

			if(ticketer != -1 && ticketPrice > 0) {
				if(IsPlayerAuthed(ticketer)) {
					if(IsPlayerInRangeOfPlayer(playerid, ticketer, 3.0)) {
						if(playerVariables[playerid][pMoney] >= ticketPrice) {

							GetPlayerName(playerid, ticketNames[0], MAX_PLAYER_NAME);
							GetPlayerName(ticketer, ticketNames[1], MAX_PLAYER_NAME);

							format(ticketString, sizeof(ticketString), "* %s takes out $%d in cash, and hands it to %s.", ticketNames[0], ticketPrice, ticketNames[1]);
							nearByMessage(playerid, COLOR_PURPLE, ticketString);

							format(ticketString, sizeof(ticketString), "%s has accepted the $%d ticket you issued them - you have received $%d.", ticketNames[0], ticketPrice, ticketPrice / 2);
							SendClientMessage(ticketer, COLOR_WHITE, ticketString);

							format(ticketString, sizeof(ticketString), "You have paid the $%d ticket %s issued you.", ticketPrice, ticketNames[1]);
							SendClientMessage(playerid, COLOR_WHITE, ticketString);

							playerVariables[playerid][pMoney] -= ticketPrice;
							playerVariables[ticketer][pMoney] += ticketPrice / 2;

							groupVariables[playerVariables[ticketer][pGroup]][gSafe][0] += ticketPrice / 2;

							DeletePVar(playerid, "tID");
							DeletePVar(playerid, "tP");

						}
						else {

							format(ticketString, sizeof(ticketString), "You can't afford to pay this ticket of $%d - you need another $%d to do so.", ticketPrice, ticketPrice - playerVariables[playerid][pMoney]);
							SendClientMessage(playerid, COLOR_GREY, ticketString);
						}
					}
					else SendClientMessage(playerid, COLOR_GREY, "You're too far away.");
				}
				else {
					SendClientMessage(playerid, COLOR_GREY, "The person issuing the ticket has disconnected.");
					DeletePVar(playerid, "tID");
					DeletePVar(playerid, "tP");
				}
			}
			else SendClientMessage(playerid, COLOR_GREY, "Nobody has issued you a ticket.");
		}
		else if(strcmp(params, "givecar", true) == 0) {

			new
				playerCarOffer = GetPVarInt(playerid, "gC") - 1, // <Divide by zero here>
				giveCarString[128],
				x,
				giveCarPlayerName[2][MAX_PLAYER_NAME];

		    if(playerCarOffer != -1) {
		        if(IsPlayerAuthed(playerCarOffer)) {
					if(playerVariables[playerid][pCarModel] < 1) {
						if(IsPlayerInRangeOfPlayer(playerid, playerCarOffer, 5.0)) {
							GetVehiclePos(playerVariables[playerCarOffer][pCarID], playerVariables[playerid][pCarPos][0], playerVariables[playerid][pCarPos][1], playerVariables[playerid][pCarPos][2]);
							GetVehicleZAngle(playerVariables[playerCarOffer][pCarID], playerVariables[playerid][pCarPos][3]); // Get pos and Z angle, save 'em to the accepting player

							playerVariables[playerid][pCarModel] = playerVariables[playerCarOffer][pCarModel]; // Transfer the car model

							playerVariables[playerid][pCarColour][0] = playerVariables[playerCarOffer][pCarColour][0]; // And the colours, and paint job
							playerVariables[playerid][pCarColour][1] = playerVariables[playerCarOffer][pCarColour][1];
							playerVariables[playerid][pCarPaintjob] = playerVariables[playerCarOffer][pCarPaintjob];

							playerVariables[playerid][pCarTrunk][0] = playerVariables[playerCarOffer][pCarTrunk][0];
							playerVariables[playerid][pCarTrunk][1] = playerVariables[playerCarOffer][pCarTrunk][1];

							while(x < 13) {
								playerVariables[playerid][pCarMods][x] = GetVehicleComponentInSlot(playerVariables[playerCarOffer][pCarID], x); // Mods, too.
								x++;
							}

							x = 0;

							while(x < 5) {
								playerVariables[playerid][pCarWeapons][x] = playerVariables[playerCarOffer][pCarWeapons][x];
								x++;
							}

							GetPlayerName(playerCarOffer, giveCarPlayerName[1], MAX_PLAYER_NAME);
							GetPlayerName(playerid, giveCarPlayerName[0], MAX_PLAYER_NAME);

							format(giveCarString, sizeof(giveCarString), "%s has accepted your offer, and is now the owner of this %s.", giveCarPlayerName[0], VehicleNames[playerVariables[playerid][pCarModel] - 400]);
							SendClientMessage(playerCarOffer, COLOR_WHITE, giveCarString);

							format(giveCarString, sizeof(giveCarString), "You have accepted %s's offer, and are now the owner of this %s.", giveCarPlayerName[1], VehicleNames[playerVariables[playerid][pCarModel] - 400]);
							SendClientMessage(playerid, COLOR_WHITE, giveCarString);

							format(giveCarString, sizeof(giveCarString), "* %s has given their car keys to %s.", giveCarPlayerName[1], giveCarPlayerName[0]);
							nearByMessage(playerid, COLOR_PURPLE, giveCarString);

							DestroyPlayerVehicle(playerCarOffer);
							SpawnPlayerVehicle(playerid);
							DeletePVar(playerid, "gC");
							
							ShowPlayerDialog(playerid, DIALOG_LICENSE_PLATE, DIALOG_STYLE_INPUT, "License plate registration", "Please enter a license plate for your vehicle. \n\nThere is only two conditions:\n- The license plate must be unique\n- The license plate can be alphanumerical, but it must consist of only 7 characters and include one space.", "Select", "");
						}
						else SendClientMessage(playerid, COLOR_GREY, "You're too far away.");
					}
					else SendClientMessage(playerid, COLOR_GREY, "You already own a vehicle.");
		        }
		        else { // Offering player disconnects.
		            DeletePVar(playerid, "gC");
		            SendClientMessage(playerid, COLOR_GREY, "The person offering the vehicle has disconnected.");
		        }
		    }
		    else SendClientMessage(playerid, COLOR_GREY, "Nobody has offered you a vehicle.");
		}
	    else if(strcmp(params, "invite", true) == 0) {
	        if(GetPVarInt(playerid, "invID") >= 1) {
	            new
	                messageString[64];

	            playerVariables[playerid][pGroup] = GetPVarInt(playerid, "invID");
				playerVariables[playerid][pGroupRank] = 1;

				DeletePVar(playerid, "invID");

				format(messageString, sizeof(messageString), "You are now a member of the %s.", groupVariables[playerVariables[playerid][pGroup]][gGroupName]);
				SendClientMessage(playerid, COLOR_NICESKY, messageString);

				GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
				format(messageString, sizeof(messageString), "%s has joined the group (invitation).", szPlayerName);
				SendToGroup(playerVariables[playerid][pGroup], COLOR_GENANNOUNCE, messageString);

	        }
	        else {
				return SendClientMessage(playerid, COLOR_GREY, "You don't have an active group invite request.");
			}
	    }

		else if(strcmp(params, "handshake", true) == 0) {
		    if(GetPVarInt(playerid,"hs") != 0) {
		        if(GetPlayerState(playerid) != 1) return SendClientMessage(playerid, COLOR_GREY, "You can only do this while on foot.");
		        if(IsPlayerInRangeOfPlayer(playerid, GetPVarInt(playerid,"hsID"), 1.5)) {

		            new
						Float: PosFloats[3],
						string[73],
						playerNames[2][MAX_PLAYER_NAME],
						shakeOffer = GetPVarInt(playerid,"hsID"),
						shakeStyle = GetPVarInt(playerid,"hs");

					if(!IsPlayerAuthed(shakeOffer)) return 1;

					PlayerFacePlayer(playerid, shakeOffer);
		            GetPlayerPos(shakeOffer, PosFloats[0], PosFloats[1], PosFloats[2]);
		            GetXYInFrontOfPlayer(shakeOffer, PosFloats[0], PosFloats[1], 0.5);
		            SetPlayerPos(playerid, PosFloats[0], PosFloats[1], PosFloats[2]); // Ensures that the players are in perfect position for it to happen.

					switch(shakeStyle) {
			            case 1: {
			                ApplyAnimation(playerid, "GANGS", "hndshkaa", 3.0, 1, 1, 1, 0, 1500, 1);
			                ApplyAnimation(shakeOffer, "GANGS", "hndshkaa", 3.0, 1, 1, 1, 0, 1500, 1);
			                ApplyAnimation(playerid, "GANGS", "hndshkaa", 3.0, 1, 1, 1, 0, 1500, 1);
			                ApplyAnimation(shakeOffer, "GANGS", "hndshkaa", 3.0, 1, 1, 1, 0, 1500, 1);
						}
			            case 2: {
			                ApplyAnimation(playerid, "GANGS", "hndshkba", 3.0, 1, 1, 1, 0, 1500, 1 );
			                ApplyAnimation(shakeOffer, "GANGS", "hndshkba", 3.0, 1, 1, 1, 0, 1500, 1);
			                ApplyAnimation(playerid, "GANGS", "hndshkba", 3.0, 1, 1, 1, 0, 1500, 1 );
			                ApplyAnimation(shakeOffer, "GANGS", "hndshkba", 3.0, 1, 1, 1, 0, 1500, 1);
			            }
			            case 3: {
			                ApplyAnimation(playerid, "GANGS", "hndshkca", 3.0, 1, 1, 1, 0, 1500, 1 );
			                ApplyAnimation(shakeOffer, "GANGS", "hndshkcb", 3.0, 1, 1, 1, 0, 1500, 1);
			                ApplyAnimation(playerid, "GANGS", "hndshkca", 3.0, 1, 1, 1, 0, 1500, 1 );
			                ApplyAnimation(shakeOffer, "GANGS", "hndshkcb", 3.0, 1, 1, 1, 0, 1500, 1);
			            }
			            case 4: {
			                ApplyAnimation(playerid, "GANGS", "hndshkda",3.0, 1, 1, 1, 0, 1500, 1);
			                ApplyAnimation(shakeOffer, "GANGS", "hndshkda", 3.0, 1, 1, 1, 0, 1500, 1);
			                ApplyAnimation(playerid, "GANGS", "hndshkda",3.0, 1, 1, 1, 0, 1500, 1);
			                ApplyAnimation(shakeOffer, "GANGS", "hndshkda", 3.0, 1, 1, 1, 0, 1500, 1);
			            }
			            case 5: {
			                ApplyAnimation(playerid, "GANGS", "hndshkea", 3.0, 1, 1, 1, 0, 1500, 1);
			                ApplyAnimation(shakeOffer, "GANGS", "hndshkea", 3.0, 1, 1, 1, 0, 1500, 1);
			                ApplyAnimation(playerid, "GANGS", "hndshkea", 3.0, 1, 1, 1, 0, 1500, 1);
			                ApplyAnimation(shakeOffer, "GANGS", "hndshkea", 3.0, 1, 1, 1, 0, 1500, 1);
			            }
			            case 6: {
			                ApplyAnimation(playerid, "GANGS", "hndshkfa", 3.0, 1, 1, 1, 0, 1500, 1 );
			                ApplyAnimation(shakeOffer, "GANGS", "hndshkfa", 3.0, 1, 1, 1, 0, 1500, 1);
			                ApplyAnimation(playerid, "GANGS", "hndshkfa", 3.0, 1, 1, 1, 0, 1500, 1 );
			                ApplyAnimation(shakeOffer, "GANGS", "hndshkfa", 3.0, 1, 1, 1, 0, 1500, 1);
			            }
			            case 7: {
			                ApplyAnimation(playerid, "GANGS", "prtial_hndshk_01", 3.0, 1, 1, 1, 0, 1500, 1);
			                ApplyAnimation(shakeOffer, "GANGS", "prtial_hndshk_01", 3.0, 1, 1, 1, 0, 1500, 1);
			                ApplyAnimation(playerid, "GANGS", "prtial_hndshk_01", 3.0, 1, 1, 1, 0, 1500, 1);
			                ApplyAnimation(shakeOffer, "GANGS", "prtial_hndshk_01", 3.0, 1, 1, 1, 0, 1500, 1);
			            }
			            case 8: {
							ApplyAnimation(playerid, "GANGS", "prtial_hndshk_biz_01", 3.7, 1, 1, 1, 0, 2200, 1);
							ApplyAnimation(shakeOffer, "GANGS", "prtial_hndshk_biz_01", 3.5, 1, 1, 1, 0, 2200, 1);
							ApplyAnimation(playerid, "GANGS", "prtial_hndshk_biz_01", 3.7, 1, 1, 1, 0, 2200, 1);
							ApplyAnimation(shakeOffer, "GANGS", "prtial_hndshk_biz_01", 3.5, 1, 1, 1, 0, 2200, 1);
			            }
					}
					GetPlayerName(playerid, playerNames[0], MAX_PLAYER_NAME);
					GetPlayerName(shakeOffer, playerNames[1], MAX_PLAYER_NAME);
					DeletePVar(playerid,"hs");
					DeletePVar(playerid,"hsID");
					format(string, sizeof(string), "* %s has shaken hands with %s.", playerNames[1], playerNames[0]);
					nearByMessage(playerid, COLOR_PURPLE, string);
				}
				else {
				    SendClientMessage( playerid, COLOR_GREY, "You're too far away.");
				}
		    }
		    else {
		        SendClientMessage(playerid, COLOR_GREY, "You don't have a pending handshake request.");
		    }
		}
		else if(strcmp(params, "weapon", true) == 0) {

			new
				playerOffering = GetPVarInt(playerid,"gunID"),
				weaponOffering = GetPVarInt(GetPVarInt(playerid,"gunID"),"gun"),
				slotOffering = GetPVarInt(GetPVarInt(playerid,"gunID"),"slot"),
				WplayerName[2][MAX_PLAYER_NAME],
				wstring[128];

	   		if(weaponOffering != 0 && slotOffering != 0) {
				if(IsPlayerInRangeOfPlayer(playerid, playerOffering, 5.0) && !IsPlayerInAnyVehicle(playerid) && !IsPlayerInAnyVehicle(playerOffering)) {

					if(playerVariables[playerOffering][pWeapons][slotOffering] != weaponOffering) {
						return SendClientMessage(playerid, COLOR_GREY, "The player offering you a weapon no longer has it.");
					}
					else if(playerVariables[playerOffering][pFreezeType] > 0) {
						return SendClientMessage(playerid, COLOR_GREY, "That person is cuffed, tazed, or frozen - they can't do this.");
					}
					else if(playerVariables[playerid][pFreezeType] > 0) {
						return SendClientMessage(playerid, COLOR_GREY, "You can't do this while cuffed, tazed, or frozen.");
					}
					else {

						givePlayerValidWeapon(playerid, weaponOffering);
						removePlayerWeapon(playerOffering, weaponOffering);

						GetPlayerName(playerOffering, WplayerName[0], MAX_PLAYER_NAME);
						GetPlayerName(playerid, WplayerName[1], MAX_PLAYER_NAME);

						format(wstring, sizeof(wstring), "You have accepted the %s from %s.", WeaponNames[weaponOffering], WplayerName[0]);
						SendClientMessage(playerid, COLOR_WHITE, wstring);

						format(wstring, sizeof(wstring), "%s has accepted the %s you offered them.", WplayerName[1], WeaponNames[weaponOffering]);
						SendClientMessage(playerOffering, COLOR_WHITE, wstring);

						format(wstring, sizeof(wstring), "* %s has given their %s to %s.", WplayerName[0], WeaponNames[weaponOffering], WplayerName[1]);
						nearByMessage(playerid, COLOR_PURPLE, wstring);

						DeletePVar(playerOffering,"gun");
						DeletePVar(playerid,"gunID");
						DeletePVar(playerOffering,"slot");
					}
		    	}
		    	else SendClientMessage(playerid, COLOR_GREY, "You're too far away from the person offering, or either of you are in a vehicle.");
		    }
	    	else SendClientMessage(playerid, COLOR_GREY, "Nobody offered you a weapon.");
		}
		else if(strcmp(params, "armour", true) == 0) {

			new
				aplayerOffering = GetPVarInt(playerid,"aID") - 1,
				AplayerName[2][MAX_PLAYER_NAME],
				astring[128];

	   		if(aplayerOffering != INVALID_PLAYER_ID) {
				if(IsPlayerInRangeOfPlayer(playerid, aplayerOffering, 5.0)) {

					if(playerVariables[aplayerOffering][pFreezeType] > 0) {
						return SendClientMessage(playerid, COLOR_GREY, "That person is cuffed, tazed, or frozen - they can't do this.");
					}
					else if(playerVariables[playerid][pFreezeType] > 0) {
						return SendClientMessage(playerid, COLOR_GREY, "You can't do this while cuffed, tazed, or frozen.");
					}
					else {

						new
							Float:ArmourFloats[2];

						GetPlayerArmour(aplayerOffering, ArmourFloats[0]);
						GetPlayerArmour(playerid, ArmourFloats[1]);

						if(ArmourFloats[1] + ArmourFloats[0] >= 100) SetPlayerArmour(playerid, 100);
						else SetPlayerArmour(playerid, ArmourFloats[1] + ArmourFloats[0]);

						SetPlayerArmour(aplayerOffering, 0.0);

						GetPlayerName(aplayerOffering, AplayerName[0], MAX_PLAYER_NAME);
						GetPlayerName(playerid, AplayerName[1], MAX_PLAYER_NAME);
						format(astring, sizeof(astring), "You have accepted the kevlar vest from %s.", AplayerName[0]);
						SendClientMessage(playerid, COLOR_WHITE, astring);

						format(astring, sizeof(astring), "%s has accepted the kevlar vest you offered them.", AplayerName[1]);
						SendClientMessage(aplayerOffering, COLOR_WHITE, astring);

						format(astring, sizeof(astring), "* %s has given their kevlar vest to %s.", AplayerName[0], AplayerName[1]);
						nearByMessage(playerid, COLOR_PURPLE, astring);

						DeletePVar(playerid,"aID");
					}
		    	}
		    	else SendClientMessage(playerid, COLOR_GREY, "You're too far away from the person offering.");
		    }
	    	else SendClientMessage(playerid, COLOR_GREY, "Nobody offered you armour.");
		}
		else SendClientMessage(playerid, COLOR_GREY, "Invalid item specified.");
    }
    else {
		SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/accept [item]");
		SendClientMessage(playerid, COLOR_GREY, "Items: Invite, Handshake, Weapon, Givecar, Ticket, Armour");
	}
	return 1;
}

CMD:a(playerid, params[]) {
	if(playerVariables[playerid][pAdminLevel] >= 1) {
		if(!isnull(params)) {
		    new
		        messageString[128];

		    format(messageString, sizeof(messageString), "* Admin %s (%d) says: %s", playerVariables[playerid][pAdminName], playerVariables[playerid][pAdminLevel], params);
		    submitToAdmins(messageString, COLOR_YELLOW);
		}
		else {
			SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/a [message]");
		}
	}
	return 1;
}

CMD:seepms(playerid, params[]) {
	switch(playerVariables[playerid][pPMStatus]) {
		case 0: {
		    playerVariables[playerid][pPMStatus] = 1;
			return SendClientMessage(playerid, COLOR_WHITE, "You have disabled your PMs.");
		}
		case 1: {
		    playerVariables[playerid][pPMStatus] = 0;
			return SendClientMessage(playerid, COLOR_WHITE, "You have enabled your PMs.");
		}
	}
	return 1;
}

CMD:pm(playerid, params[])
{
	new
		message[128],
		id;

	if(sscanf(params, "us[128]", id, message))
		SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/pm [playerid] [message]");
	else if(playerVariables[id][pStatus] != 1)
		SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");
	else if(playerVariables[id][pPMStatus] != 0)
		SendClientMessage(playerid, COLOR_GREY, "That player's PMs aren't enabled.");
	else
	{
		GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);

		format(szMessage, sizeof(szMessage), "(( PM from %s: %s ))", szPlayerName, message);
		SendClientMessage(id, COLOR_YELLOW, szMessage);

		GetPlayerName(id, szPlayerName, MAX_PLAYER_NAME);

		format(szMessage, sizeof(szMessage), "(( PM sent to %s: %s ))", szPlayerName, message);
		SendClientMessage(playerid, COLOR_GREY, szMessage);
    }
	return 1;
}

CMD:w(playerid, params[]) {
	return cmd_whisper(playerid, params);
}

CMD:whisper(playerid, params[]) {
	new
		message[128],
		id;

	if(sscanf(params, "us[128]", id, message)) {
		SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/whisper [playerid] [message]");
	}
	else if(playerVariables[id][pStatus] != 1)
	{
		SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");
	}
	else if(playerVariables[id][pSeeWhisper] != 0) 
	{
		SendClientMessage(playerid, COLOR_GREY, "That player's whispers aren't enabled.");
	}
	else if(!IsPlayerInRangeOfPlayer(playerid, id, 2.0))
	{
		SendClientMessage(playerid, COLOR_GREY, "You're too far away.");
	}
	{
		new
			giveplayerName[MAX_PLAYER_NAME];
		GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
		format(szMessage, sizeof(szMessage), "%s whispers: %s", szPlayerName, message);
		SendClientMessage(id, COLOR_NICESKY, szMessage);

		GetPlayerName(id, giveplayerName, MAX_PLAYER_NAME);

		format(szMessage, sizeof(szMessage), "You whisper to %s: %s", giveplayerName, message);
		SendClientMessage(playerid, COLOR_NICESKY, szMessage);

		format(szMessage, sizeof(szMessage), "* %s whispers something to %s.", szPlayerName, giveplayerName);
		nearByMessage(playerid, COLOR_PURPLE, szMessage, 2.0);
    }
	return 1;
}

CMD:adminchat(playerid, params[]) {
	return cmd_a(playerid, params);
}

CMD:commands(playerid, params[]) {
	return showHelp(playerid);
}

stock showHelp(playerid) {
	return ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_LIST, "SERVER: Commands", "General\nChat\nGroups\nAnimations\nHouses\nJobs\n\nBusinesses\nHelpers\nVehicles\nBank", "Select", "Exit");
}

CMD:asellbusiness(playerid, params[]) {
    if(playerVariables[playerid][pAdminLevel] >= 3) {
        new
            houseID = strval(params);

		if(!isnull(params)) {
		    if(houseID < 1 || houseID > MAX_BUSINESSES) return SendClientMessage(playerid, COLOR_GREY, "Invalid business ID.");

	        new
	            labelString[96];

	        format(businessVariables[houseID][bOwner], MAX_PLAYER_NAME, "Nobody");

	        DestroyDynamicPickup(businessVariables[houseID][bPickupID]);
	        DestroyDynamic3DTextLabel(businessVariables[houseID][bLabelID]);

			format(labelString, sizeof(labelString), "%s\n(Business %d - un-owned)\nPrice: $%d (/buybusiness)\n\n(locked)", businessVariables[houseID][bName], houseID, businessVariables[houseID][bPrice]);

			businessVariables[houseID][bLabelID] = CreateDynamic3DTextLabel(labelString, COLOR_YELLOW, businessVariables[houseID][bExteriorPos][0], businessVariables[houseID][bExteriorPos][1], businessVariables[houseID][bExteriorPos][2], 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 10.0);
			businessVariables[houseID][bPickupID] = CreateDynamicPickup(1239, 23, businessVariables[houseID][bExteriorPos][0], businessVariables[houseID][bExteriorPos][1], businessVariables[houseID][bExteriorPos][2], 0, 0, -1, 250);

			businessVariables[houseID][bLocked] = 1;

			format(labelString, sizeof(labelString), "You have admin-sold business ID %d.", houseID);
			SendClientMessage(playerid, COLOR_WHITE, labelString);

		    saveHouse(houseID);
		}
		else {
		    return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/asellbusiness [businessid]");
		}
    }

    return 1;
}

CMD:he(playerid, params[]) {
	if(playerVariables[playerid][pHelper] >= 1 || playerVariables[playerid][pAdminLevel] >= 1) {
		if(!isnull(params)) {
		    new
		        msgSz[128];

			if(playerVariables[playerid][pAdminLevel] >= 1)
				format(msgSz, sizeof(msgSz), "* Administrator %s (%d): %s", playerVariables[playerid][pAdminName], playerVariables[playerid][pAdminLevel], params);

			if(playerVariables[playerid][pHelper] >= 1)
				format(msgSz, sizeof(msgSz), "* Helper %s (%d): %s", playerVariables[playerid][pNormalName], playerVariables[playerid][pHelper], params);


			foreach(Player, x) {
			    if(playerVariables[x][pHelper] >= 1 || playerVariables[x][pAdminLevel] >= 1) {
                    SendClientMessage(x, COLOR_GENANNOUNCE, msgSz);
				}
			}
		}
		else {
			return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/he [message]");
		}
	}
	return 1;
}

CMD:asellhouse(playerid, params[]) {
    if(playerVariables[playerid][pAdminLevel] >= 3) {
        new
            houseID = strval(params);

		if(!isnull(params)) {
		    if(houseID < 1 || houseID > MAX_HOUSES) return SendClientMessage(playerid, COLOR_GREY, "Invalid house ID.");

	        new
	            labelString[96];

	        format(houseVariables[houseID][hHouseOwner], MAX_PLAYER_NAME, "Nobody");
	        format(labelString, sizeof(labelString), "House %d (un-owned - /buyhouse)\nPrice: $%d\n\n(locked)", houseID, houseVariables[houseID][hHousePrice]);

	        DestroyDynamicPickup(houseVariables[houseID][hPickupID]);
	        DestroyDynamic3DTextLabel(houseVariables[houseID][hLabelID]);

	        houseVariables[houseID][hLabelID] = CreateDynamic3DTextLabel(labelString, COLOR_YELLOW, houseVariables[houseID][hHouseExteriorPos][0], houseVariables[houseID][hHouseExteriorPos][1], houseVariables[houseID][hHouseExteriorPos][2], 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 10.0);
			houseVariables[houseID][hPickupID] = CreateDynamicPickup(1273, 23, houseVariables[houseID][hHouseExteriorPos][0], houseVariables[houseID][hHouseExteriorPos][1], houseVariables[houseID][hHouseExteriorPos][2], 0, houseVariables[houseID][hHouseExteriorID], -1, 250);

			houseVariables[houseID][hHouseLocked] = 1;

			format(labelString, sizeof(labelString), "You have admin-sold house ID %d.", houseID);
			SendClientMessage(playerid, COLOR_WHITE, labelString);

		    saveHouse(houseID);
		}
		else {
		    return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/asellhouse [houseid]");
		}
    }

    return 1;
}

CMD:sellbusiness(playerid, params[]) {
	if(playerVariables[playerid][pStatus] >= 1) {
	    new
	        businessID = getPlayerBusinessID(playerid);

	    if(businessID < 1)
	        return 1;

	    new
	    	labelString[96];

		playerVariables[playerid][pMoney] += businessVariables[businessID][bPrice];

        format(businessVariables[businessID][bOwner], MAX_PLAYER_NAME, "Nobody");
        format(labelString, sizeof(labelString), "%s\n(Business %d - un-owned)\nPrice: $%d (/buybusiness)\n\nPress ~k~~PED_DUCK~ to enter", businessVariables[businessID][bName], businessID, businessVariables[businessID][bPrice]);

        DestroyDynamicPickup(businessVariables[businessID][bPickupID]);
        DestroyDynamic3DTextLabel(businessVariables[businessID][bLabelID]);

		businessVariables[businessID][bLabelID] = CreateDynamic3DTextLabel(labelString, COLOR_YELLOW, businessVariables[businessID][bExteriorPos][0], businessVariables[businessID][bExteriorPos][1], businessVariables[businessID][bExteriorPos][2], 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 10.0);
		businessVariables[businessID][bPickupID] = CreateDynamicPickup(1239, 23, businessVariables[businessID][bExteriorPos][0], businessVariables[businessID][bExteriorPos][1], businessVariables[businessID][bExteriorPos][2], 0, 0, -1, 250);

		businessVariables[businessID][bLocked] = 1;

		format(labelString, sizeof(labelString), "Business sold! You have been given back $%d for the business.", businessVariables[businessID][bPrice]);
		SendClientMessage(playerid, COLOR_WHITE, labelString);

		saveBusiness(businessID);
	}
	return 1;
}

CMD:sellhouse(playerid, params[]) {
	if(playerVariables[playerid][pStatus] >= 1) {
	    new
	        houseID = getPlayerHouseID(playerid);

	    if(houseID < 1)
	        return 1;

		new
	    	labelString[96];

        playerVariables[playerid][pMoney] += houseVariables[houseID][hHousePrice];

        format(houseVariables[houseID][hHouseOwner], MAX_PLAYER_NAME, "Nobody");
        format(labelString, sizeof(labelString), "House %d (un-owned - /buyhouse)\nPrice: $%d\n\n(locked)", houseID, houseVariables[houseID][hHousePrice]);

        DestroyDynamicPickup(houseVariables[houseID][hPickupID]);
        DestroyDynamic3DTextLabel(houseVariables[houseID][hLabelID]);

        houseVariables[houseID][hLabelID] = CreateDynamic3DTextLabel(labelString, COLOR_YELLOW, houseVariables[houseID][hHouseExteriorPos][0], houseVariables[houseID][hHouseExteriorPos][1], houseVariables[houseID][hHouseExteriorPos][2], 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 10.0);
		houseVariables[houseID][hPickupID] = CreateDynamicPickup(1273, 23, houseVariables[houseID][hHouseExteriorPos][0], houseVariables[houseID][hHouseExteriorPos][1], houseVariables[houseID][hHouseExteriorPos][2], 0, houseVariables[houseID][hHouseExteriorID], -1, 250);

		houseVariables[houseID][hHouseLocked] = 1;

		format(labelString, sizeof(labelString), "House sold! You have been given back $%d for the house.", houseVariables[houseID][hHousePrice]);
		SendClientMessage(playerid, COLOR_WHITE, labelString);

		saveHouse(houseID);
	}
	return 1;
}

CMD:ringbell(playerid, params[]) {
	if(GetPlayerState(playerid) == 1) {
		for(new x = 0; x < MAX_HOUSES; x++) {
			if(IsPlayerInRangeOfPoint(playerid, 2.0, houseVariables[x][hHouseExteriorPos][0], houseVariables[x][hHouseExteriorPos][1], houseVariables[x][hHouseExteriorPos][2])) {

				new
					string[80];

				GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
				format(string, sizeof(string), "* %s presses a button, ringing the doorbell of the house.", szPlayerName);
				nearByMessage(playerid, COLOR_PURPLE, string);

				foreach(Player, i) {
					if(GetPlayerVirtualWorld(i) == x + HOUSE_VIRTUAL_WORLD) {
						SendClientMessage(i, COLOR_PURPLE, "* The doorbell rings.");
					}
				}
			}
		}
	}
	return 1;
}

CMD:lockhouse(playerid, params[]) {
	if(playerVariables[playerid][pStatus] >= 1) {
	    new
	        houseID = getPlayerHouseID(playerid);

	    if(houseID >= 1) {
			if(IsPlayerInRangeOfPoint(playerid, 2.0, houseVariables[houseID][hHouseExteriorPos][0], houseVariables[houseID][hHouseExteriorPos][1], houseVariables[houseID][hHouseExteriorPos][2]) || IsPlayerInRangeOfPoint(playerid, 2.0, houseVariables[houseID][hHouseInteriorPos][0], houseVariables[houseID][hHouseInteriorPos][1], houseVariables[houseID][hHouseInteriorPos][2])) {

				new
					labelString[96];

				switch(houseVariables[houseID][hHouseLocked]) {
					case 1: {
						houseVariables[houseID][hHouseLocked] = 0;
						SendClientMessage(playerid, COLOR_WHITE, "House unlocked.");
						format(labelString, sizeof(labelString), "House %d (owned)\nOwner: %s\n\nPress ~k~~PED_DUCK~ to enter.", houseID, houseVariables[houseID][hHouseOwner]);
					}
					case 0: {
						houseVariables[houseID][hHouseLocked] = 1;
						SendClientMessage(playerid, COLOR_WHITE, "House locked.");
						format(labelString, sizeof(labelString), "House %d (owned)\nOwner: %s\n\n(locked)", houseID, houseVariables[houseID][hHouseOwner]);
					}
				}

				UpdateDynamic3DTextLabelText(houseVariables[houseID][hLabelID], COLOR_YELLOW, labelString);
				PlayerPlaySoundEx(1145, houseVariables[houseID][hHouseExteriorPos][0], houseVariables[houseID][hHouseExteriorPos][1], houseVariables[houseID][hHouseExteriorPos][2]);
				PlayerPlaySoundEx(1145, houseVariables[houseID][hHouseInteriorPos][0], houseVariables[houseID][hHouseInteriorPos][1], houseVariables[houseID][hHouseInteriorPos][2]);
			}
			else SendClientMessage(playerid, COLOR_GREY, "You're not at your house.");
	    }
	    else  SendClientMessage(playerid, COLOR_GREY, "You don't own a house.");
	}

	return 1;
}

CMD:listgroups(playerid, params[]) {
    if(playerVariables[playerid][pAdminLevel] >= 1) {
        for(new xf = 0; xf < MAX_GROUPS; xf++) {
			if(strlen(groupVariables[xf][gGroupName]) >= 1 && strcmp(groupVariables[xf][gGroupName], "None", true)) {
				format(szMessage, sizeof(szMessage), "ID: %d | Group Name: %s | Group Type: %d", xf, groupVariables[xf][gGroupName], groupVariables[xf][gGroupType]);
				SendClientMessage(playerid, COLOR_WHITE, szMessage);
			}
		}
	}
	return 1;
}

CMD:do(playerid, params[]) {
    if(playerVariables[playerid][pStatus] >= 1) {
        if(!isnull(params)) {
			GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);

			format(szMessage, sizeof(szMessage), "* %s (( %s )) ", params, szPlayerName);
			nearByMessage(playerid, COLOR_PURPLE, szMessage);
		}
		else {
			return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/do [action]");
		}
	}
	return 1;
}

CMD:bwithdraw(playerid, params[]) {
	if(getPlayerBusinessID(playerid) >= 1) {
	    if(!isnull(params)) {
			new
			    amount = strval(params),
			    businessID = getPlayerBusinessID(playerid);

        	if(amount < 1 || amount >= 5000000)
				return SendClientMessage(playerid, COLOR_GREY, "Withdrawal attempt failed.");

			if(businessVariables[businessID][bVault] >= amount) {
				format(szMessage, sizeof(szMessage), "You have withdrawn $%d from your business.", amount);
				SendClientMessage(playerid, COLOR_WHITE, szMessage);

				businessVariables[businessID][bVault] -= amount;
				playerVariables[playerid][pMoney] += amount;
			}
		}
		else {
			return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/bwithdraw [amount]");
		}
	}
	return 1;
}

CMD:charity(playerid, params[]) {
    if(playerVariables[playerid][pStatus] >= 1) {
        new
            value = strval(params);

        if(value < 1 || value >= 5000000)
			return SendClientMessage(playerid, COLOR_GREY, "The charity declined your donation.");

        if(playerVariables[playerid][pMoney] < 1)
			return SendClientMessage(playerid, COLOR_GREY, "The charity declined your donation.");

	    playerVariables[playerid][pMoney] -= value;

        if(playerVariables[playerid][pMoney] < 1)
			playerVariables[playerid][pMoney] = 0;

		format(szMessage, sizeof(szMessage), "The charity accepted your donation of $%d.", value);
        SendClientMessage(playerid, COLOR_YELLOW, szMessage);
    }

    return 1;
}

CMD:flipcoin(playerid, params[]) { // HAHAHAHAHAHAH OH WOW
    if(playerVariables[playerid][pStatus] >= 1) {
		GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);

		if(playerVariables[playerid][pMoney] < 1)
			return SendClientMessage(playerid, COLOR_GREY, "You have no coins to flip.");

		if(random(5) < 3) {
			format(szMessage, sizeof(szMessage), "* %s has flipped their coin. The coin lands on the 'heads' side.", szPlayerName);
			nearByMessage(playerid, COLOR_PURPLE, szMessage);
		}
		else {
			format(szMessage, sizeof(szMessage), "* %s has flipped their coin. The coin lands on the 'tails' side.", szPlayerName);
			nearByMessage(playerid, COLOR_PURPLE, szMessage);
		}
	}
	return 1;
}

CMD:creategun(playerid, params[]) {
	if(jobVariables[playerVariables[playerid][pJob]][jJobType] == 1) {
		if(playerVariables[playerid][pFreezeType] == 0) {
			if(playerVariables[playerid][pJobDelay] == 0) {
				switch(playerVariables[playerid][pJobSkill][0]) {
					case 0 .. 49: ShowPlayerDialog(playerid, DIALOG_CREATEGUN, DIALOG_STYLE_LIST, "Weapon Selection", "Katana (30)\nCane (30)\nPool Cue (33)\nBaseball Bat (35)\nShovel (50)","Select", "Cancel");
					case 50 .. 99: ShowPlayerDialog(playerid, DIALOG_CREATEGUN, DIALOG_STYLE_LIST, "Weapon Selection", "Katana (30)\nCane (30)\nPool Cue (33)\nBaseball Bat (35)\nShovel (50)\n9mm pistol (250)","Select", "Cancel");
					case 100 .. 149: ShowPlayerDialog(playerid, DIALOG_CREATEGUN, DIALOG_STYLE_LIST, "Weapon Selection", "Katana (30)\nCane (30)\nPool Cue (33)\nBaseball Bat (35)\nShovel (50)\n9mm Pistol (250)\nSilenced Pistol (300)","Select", "Cancel");
					case 150 .. 199: ShowPlayerDialog(playerid, DIALOG_CREATEGUN, DIALOG_STYLE_LIST, "Weapon Selection", "Katana (30)\nCane (30)\nPool Cue (33)\nBaseball Bat (35)\nShovel (50)\n9mm Pistol (250)\nSilenced Pistol (300)\nShotgun (550)","Select", "Cancel");
					case 200 .. 249: ShowPlayerDialog(playerid, DIALOG_CREATEGUN, DIALOG_STYLE_LIST, "Weapon Selection", "Katana (30)\nCane (30)\nPool Cue (33)\nBaseball Bat (35)\nShovel (50)\n9mm Pistol (250)\nSilenced Pistol (300)\nShotgun (550)\nDesert Eagle (680)","Select", "Cancel");
					case 250 .. 299: ShowPlayerDialog(playerid, DIALOG_CREATEGUN, DIALOG_STYLE_LIST, "Weapon Selection", "Katana (30)\nCane (30)\nPool Cue (33)\nBaseball Bat (35)\nShovel (50)\n9mm Pistol (250)\nSilenced Pistol (300)\nShotgun (550)\nDesert Eagle (680)\nMP5 (850)","Select", "Cancel");
					case 300 .. 349: ShowPlayerDialog(playerid, DIALOG_CREATEGUN, DIALOG_STYLE_LIST, "Weapon Selection", "Katana (30)\nCane (30)\nPool Cue (33)\nBaseball Bat (35)\nShovel (50)\n9mm Pistol (250)\nSilenced Pistol (300)\nShotgun (550)\nDesert Eagle (680)\nMP5 (850)\nMicro Uzi (900)","Select", "Cancel");
					case 350 .. 399: ShowPlayerDialog(playerid, DIALOG_CREATEGUN, DIALOG_STYLE_LIST, "Weapon Selection", "Katana (30)\nCane (30)\nPool Cue (33)\nBaseball Bat (35)\nShovel (50)\n9mm Pistol (250)\nSilenced Pistol (300)\nShotgun (550)\nDesert Eagle (680)\nMP5 (850)\nMicro Uzi (900)\nAK-47 (1500)","Select", "Cancel");
					case 400 .. 449: ShowPlayerDialog(playerid, DIALOG_CREATEGUN, DIALOG_STYLE_LIST, "Weapon Selection", "Katana (30)\nCane (30)\nPool Cue (33)\nBaseball Bat (35)\nShovel (50)\n9mm Pistol (250)\nSilenced Pistol (300)\nShotgun (550)\nDesert Eagle (680)\nMP5 (850)\nMicro Uzi (900)\nAK-47 (1500)\nM4A1 (2000)","Select", "Cancel");
					case 450 .. 499: ShowPlayerDialog(playerid, DIALOG_CREATEGUN, DIALOG_STYLE_LIST, "Weapon Selection", "Katana (30)\nCane (30)\nPool Cue (33)\nBaseball Bat (35)\nShovel (50)\n9mm Pistol (250)\nSilenced Pistol (300)\nShotgun (550)\nDesert Eagle (680)\nMP5 (850)\nMicro Uzi (900)\nAK-47 (1500)\nM4A1 (2000)\nSniper (2450)","Select", "Cancel");
					default: ShowPlayerDialog(playerid, DIALOG_CREATEGUN, DIALOG_STYLE_LIST, "Weapon Selection", "Katana (30)\nCane (30)\nPool Cue (33)\nBaseball Bat (35)\nShovel (50)\n9mm Pistol (250)\nSilenced Pistol (300)\nShotgun (550)\nDesert Eagle (680)\nMP5 (850)\nMicro Uzi (900)\nAK-47 (1500)\nM4A1 (2000)\nSniper (2450)\nSPAS12 (2550)\nKevlar Vest (1750)","Select", "Cancel");
				}
			}
			else SendClientMessage(playerid, COLOR_GREY, "You must wait your reload time (30 seconds).");
		}
		else SendClientMessage(playerid, COLOR_GREY, "You can't do this while cuffed, tazed, or frozen.");
	}
	return 1;
}

CMD:me(playerid, params[]) {
    if(playerVariables[playerid][pStatus] >= 1) {
        if(!isnull(params)) {
			GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);

			format(szMessage, sizeof(szMessage), "* %s %s", szPlayerName, params);
			nearByMessage(playerid, COLOR_PURPLE, szMessage);
		}
		else {
			return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/me [action]");
		}
	}
	return 1;
}

CMD:low(playerid, params[]) {
	if(playerVariables[playerid][pStatus] >= 1) {

		if(isnull(params)) return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/low [message]");

		new
			queryString[255],
		    textString[128];

		GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
		format(textString, sizeof(textString), "%s says quietly [%s Accent]: %s", szPlayerName, playerVariables[playerid][pAccent], params);
		nearByMessage(playerid, COLOR_WHITE, textString, 2.0);
		format(textString, sizeof(textString), "(quietly) \"%s\"", params);
		SetPlayerChatBubble(playerid, textString, COLOR_CHATBUBBLE, 3.0, 10000);
		mysql_real_escape_string(textString, textString);

		format(queryString, sizeof(queryString), "INSERT INTO chatlogs (value, playerinternalid) VALUES('%s', '%d')", textString, playerVariables[playerid][pInternalID]);
		mysql_query(queryString);
	}
	return 1;
}

CMD:l(playerid, params[]) {
	return cmd_low(playerid, params);
}

CMD:shout(playerid, params[]) {
	if(playerVariables[playerid][pStatus] >= 1) {

		if(isnull(params)) return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/shout [message]");
		new

			queryString[255],
		    textString[128];

		GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
		format(textString, sizeof(textString), "(shouts) \"%s!\"", params);
		SetPlayerChatBubble(playerid, textString, COLOR_CHATBUBBLE, 30.0, 10000);
		format(textString, sizeof(textString), "%s shouts [%s Accent]: %s!", szPlayerName, playerVariables[playerid][pAccent], params);
		nearByMessage(playerid, COLOR_WHITE, textString, 20.0);
		mysql_real_escape_string(textString, textString);

		format(queryString, sizeof(queryString), "INSERT INTO chatlogs (value, playerinternalid) VALUES('%s', '%d')", textString, playerVariables[playerid][pInternalID]);
		mysql_query(queryString);
	}
	return 1;
}

CMD:m(playerid, params[]) {
	return cmd_megaphone(playerid, params);
}

CMD:megaphone(playerid, params[]) {
	if(playerVariables[playerid][pStatus] >= 1) {
		if(groupVariables[playerVariables[playerid][pGroup]][gGroupType] == 1) {
			if(isnull(params)) return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/megaphone [message]");
			else if (!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_GREY, "You're not in a vehicle.");

			new

				queryString[255],
				textString[128];

			GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
			format(textString, sizeof(textString), "(megaphone) %s says: %s", szPlayerName, params);
			nearByMessage(playerid, COLOR_HOTORANGE, textString, 50.0);


			mysql_real_escape_string(textString, textString);

			format(queryString, sizeof(queryString), "INSERT INTO chatlogs (value, playerinternalid) VALUES('%s', '%d')", textString, playerVariables[playerid][pInternalID]);
			mysql_query(queryString);
		}
		else SendClientMessage(playerid, COLOR_GREY, "You're not a law enforcement officer.");
	}
	return 1;
}

CMD:s(playerid, params[]) {
	return cmd_shout(playerid, params);
}

CMD:b(playerid, params[]) {
	if(playerVariables[playerid][pStatus] >= 1) {

		if(isnull(params)) return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/b [message]");
		new

			queryString[255],
		    textString[128];

		GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
		format(textString, sizeof(textString), "%s says: (( %s ))", szPlayerName, params);
		nearByMessage(playerid, COLOR_WHITE, textString, 5.0);
		mysql_real_escape_string(textString, textString);

		format(queryString, sizeof(queryString), "INSERT INTO chatlogs (value, playerinternalid) VALUES('%s', '%d')", textString, playerVariables[playerid][pInternalID]);
		mysql_query(queryString);
	}
	return 1;
}

CMD:report(playerid, params[]) {
	if(systemVariables[reportSystem] == 0) {
		if(isnull(params)) {
		    SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/report [message]");
		}
		else {
		    if(playerVariables[playerid][pReport] >= 1) {
		        SendClientMessage(playerid, COLOR_WHITE, "You already have an active report within our system, please wait for it to be answered.");
		    }
		    else {
		        if(strlen(params) >= 64) {
		            return SendClientMessage(playerid, COLOR_GREY, "Your report message was too long. Keep it under 64 characters.");
		        }
		        else {
				    SendClientMessage(playerid, COLOR_YELLOW, "Your report has been submitted and queued.");

        			strcpy(playerVariables[playerid][pReportMessage], params, 64);
				    playerVariables[playerid][pReport] = 1;

				    submitToAdmins("A new report has been submitted, check '/reports list'", COLOR_YELLOW);
			    }
		    }
		}
	}
	else {
	    SendClientMessage(playerid, COLOR_WHITE, "The report system is disabled right now. Please try again later.");
	}

	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source) {
	#if defined DEBUG
	    printf("[debug] OnPlayerClickPlayer(%d, %d, %d)", playerid, clickedplayerid, source);
	#endif
	
    if(playerVariables[playerid][pAdminLevel] >= 1) {

		    if(!IsPlayerAuthed(clickedplayerid))
				return SendClientMessage(playerid, COLOR_GREY, "The specified player is not connected, or has not authenticated.");

			if(playerVariables[playerid][pSpectating] == INVALID_PLAYER_ID) {
				GetPlayerPos(playerid, playerVariables[playerid][pPos][0], playerVariables[playerid][pPos][1], playerVariables[playerid][pPos][2]);
				playerVariables[playerid][pInterior] = GetPlayerInterior(playerid);
				playerVariables[playerid][pVirtualWorld] = GetPlayerVirtualWorld(playerid);
				playerVariables[playerid][pSkin] = GetPlayerSkin(playerid);

				if(playerVariables[playerid][pAdminDuty] == 0) {
					GetPlayerHealth(playerid, playerVariables[playerid][pHealth]);
					GetPlayerArmour(playerid, playerVariables[playerid][pArmour]);
				}
		    }
		    playerVariables[playerid][pSpectating] = clickedplayerid;
		    TogglePlayerSpectating(playerid, true);

			SetPlayerInterior(playerid, GetPlayerInterior(clickedplayerid));
			SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(clickedplayerid));

		    if(IsPlayerInAnyVehicle(clickedplayerid)) {
		        PlayerSpectateVehicle(playerid, GetPlayerVehicleID(clickedplayerid));
		    }
		    else {
				PlayerSpectatePlayer(playerid, clickedplayerid);
			}

			TextDrawShowForPlayer(playerid, textdrawVariables[4]);
	}
	return 1;
}

CMD:spec(playerid, params[]) {
    if(playerVariables[playerid][pAdminLevel] >= 1) {
        new
            userID;

		if(sscanf(params, "u", userID)) {
		    return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/spec [playerid]");
		}
		else if(!IsPlayerAuthed(userID)) {
		    return SendClientMessage(playerid, COLOR_GREY, "The specified player is not connected, or has not authenticated.");
		}
		else {
			if(playerVariables[playerid][pSpectating] == INVALID_PLAYER_ID) { // Will only save pos/etc if they're NOT spectating. This will stop the annoying death/pos/int/VW/crash bugs everyone's experiencing...
				GetPlayerPos(playerid, playerVariables[playerid][pPos][0], playerVariables[playerid][pPos][1], playerVariables[playerid][pPos][2]);
				playerVariables[playerid][pInterior] = GetPlayerInterior(playerid);
				playerVariables[playerid][pVirtualWorld] = GetPlayerVirtualWorld(playerid);
				playerVariables[playerid][pSkin] = GetPlayerSkin(playerid);

				if(playerVariables[playerid][pAdminDuty] == 0) {
					GetPlayerHealth(playerid, playerVariables[playerid][pHealth]);
					GetPlayerArmour(playerid, playerVariables[playerid][pArmour]);
				}
		    }
		    playerVariables[playerid][pSpectating] = userID;
		    TogglePlayerSpectating(playerid, true);

			SetPlayerInterior(playerid, GetPlayerInterior(userID));
			SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(userID));

		    if(IsPlayerInAnyVehicle(userID)) {
		        PlayerSpectateVehicle(playerid, GetPlayerVehicleID(userID));
		    }
		    else {
				PlayerSpectatePlayer(playerid, userID);
			}
			if(playerVariables[userID][pTutorial] >= 1) {
				SendClientMessage(playerid, COLOR_GREY, "This player is currently in the tutorial.");
			}

			TextDrawShowForPlayer(playerid, textdrawVariables[4]);
		}
	}
	return 1;
}

CMD:buyclothes(playerid, params[]) {
	if(GetPlayerVirtualWorld(playerid)-BUSINESS_VIRTUAL_WORLD >= 1) {

		new
			skinID,
			slotID,
			iPrice,
			houseID = getPlayerHouseID(playerid),
			businessID = GetPlayerVirtualWorld(playerid) - BUSINESS_VIRTUAL_WORLD;
			
		if(businessID > 0) {
			for(new i = 0; i < MAX_BUSINESS_ITEMS; i++) {
				if(businessItems[i][bItemType] == 18 && businessItems[i][bItemBusiness] == businessID)
				    iPrice = businessItems[i][bItemPrice];
			}
		}

		if(businessVariables[businessID][bType] == 2) {
			if(houseID >= 1) {
				if(sscanf(params, "dd", skinID, slotID)) {
					return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/buyclothes [skinid] [house slot]");
				}
				else if(!IsValidSkin(skinID)) {
					return SendClientMessage(playerid, COLOR_GREY, "Invalid skin ID.");
				}
				else if(!IsPublicSkin(skinID) && playerVariables[playerid][pGroup] != 1) {
					return SendClientMessage(playerid, COLOR_GREY, "You can't purchase this skin.");
				}
				else if(slotID < 1 || slotID > 5) {
					return SendClientMessage(playerid, COLOR_GREY, "Invalid slot specified.");
				}
				else if(playerVariables[playerid][pMoney] >= 500) {
					playerVariables[playerid][pMoney] -= 500;
					businessVariables[businessID][bVault] += 500;
					playerVariables[playerid][pSkin] = skinID;
					houseVariables[houseID][hWardrobe][slotID - 1] = skinID;
					return SetPlayerSkin(playerid, skinID);
				}
				else {
				    format(szMessage, sizeof(szMessage), "You don't have $%d available.", iPrice);
					SendClientMessage(playerid, COLOR_GREY, szMessage);
				}
			}
			else if(!isnull(params)) {
				skinID = strval(params);

				if(!IsValidSkin(skinID)) {
					return SendClientMessage(playerid, COLOR_GREY, "Invalid skin ID.");
				}
				else if(!IsPublicSkin(skinID) && playerVariables[playerid][pGroup] != 1) {
					return SendClientMessage(playerid, COLOR_GREY, "You can't purchase this skin.");
				}
				else {
				    if(playerVariables[playerid][pMoney] >= iPrice) {
						playerVariables[playerid][pMoney] -= iPrice;
						businessVariables[businessID][bVault] += iPrice;
						playerVariables[playerid][pSkin] = skinID;
						return SetPlayerSkin(playerid, skinID);
					} else {
					    format(szMessage, sizeof(szMessage), "You don't have $%d available.", iPrice);
						SendClientMessage(playerid, COLOR_GREY, szMessage);
					}
				}
			}
			else {
   				format(szMessage, sizeof(szMessage), "Skins here cost $%d", iPrice);
				SendClientMessage(playerid, COLOR_GREY, szMessage);
				SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/buyclothes [skinid] (Skins cost $500.)");
			}
		}
	}
	return 1;
}

CMD:buy(playerid, params[]) {
	if(GetPlayerVirtualWorld(playerid)-BUSINESS_VIRTUAL_WORLD >= 1) {
	    new
	        businessID = GetPlayerVirtualWorld(playerid)-BUSINESS_VIRTUAL_WORLD;

	    if(businessVariables[businessID][bType] == 0)
	        return 1;
	        
		format(result, sizeof(result), "");
		
		new
		    iCount;

	    for(new i = 0; i < MAX_BUSINESS_ITEMS; i++) {
	    	if(businessItems[i][bItemBusiness] == businessID) {
	    	    format(szSmallString, sizeof(szSmallString), "menuItem%d", iCount);
	    	    SetPVarInt(playerid, szSmallString, i);
	    	    
	    	    if(businessItems[i][bItemType] == 4)
	        		format(result, sizeof(result), "%s\n$%d phone credit voucher", result, businessItems[i][bItemPrice]);
	        	else
	        		format(result, sizeof(result), "%s\n%s ($%d)", result, businessItems[i][bItemName], businessItems[i][bItemPrice]);

				iCount++;
      		}
	    }

		switch(businessVariables[businessID][bType]) {
			case 1: ShowPlayerDialog(playerid, DIALOG_TWENTYFOURSEVEN, DIALOG_STYLE_LIST, "SERVER: 24/7", result, "Select", "Exit");
			case 3: ShowPlayerDialog(playerid, DIALOG_BAR, DIALOG_STYLE_LIST, "SERVER: Bar", result, "Select", "Exit");
			case 4: ShowPlayerDialog(playerid, DIALOG_SEX_SHOP, DIALOG_STYLE_LIST, "SERVER: Sex Shop", result, "Select", "Exit");
			case 7: ShowPlayerDialog(playerid, DIALOG_FOOD, DIALOG_STYLE_LIST, "SERVER: Restaurant", result, "Select", "Exit");
		}
	}
	return 1;
}

CMD:buyvehicle(playerid, params[]) {
	if(GetPlayerVirtualWorld(playerid)-BUSINESS_VIRTUAL_WORLD >= 1) {
	    new
	        businessID = GetPlayerVirtualWorld(playerid) - BUSINESS_VIRTUAL_WORLD;

		if(businessVariables[businessID][bMiscPos][0] == 0.0 && businessVariables[businessID][bMiscPos][1] == 0.0 && businessVariables[businessID][bMiscPos][2] == 0.0) {
			return SendClientMessage(playerid, COLOR_GREY, "No spawn position has been set by the business owner - until one is set, the business will not operate.");
		}
	    switch(businessVariables[businessID][bType]) {
			case 5: {
				ShowPlayerDialog(playerid, DIALOG_BUYCAR, DIALOG_STYLE_LIST, "SERVER: Vehicle Dealership", "Second Hand\nClassic Autos\nSedans\nSUVs/Trucks\nMotorcycles\nPerformance Vehicles", "Select", "Cancel");
			}
		}
	}
	return 1;
}

CMD:buyfightstyle(playerid, params[]) {
	if(GetPlayerVirtualWorld(playerid)-BUSINESS_VIRTUAL_WORLD >= 1) {
	    new
	        businessID = GetPlayerVirtualWorld(playerid) - BUSINESS_VIRTUAL_WORLD;

	    switch(businessVariables[businessID][bType]) {
			case 6: ShowPlayerDialog(playerid, DIALOG_FIGHTSTYLE, DIALOG_STYLE_LIST, "SERVER: Fighting Styles", "Boxing ($10,000)\nKung Fu ($25,000)\nKnee Head ($15,000)\nGrab & Kick ($12,000)\nElbow ($10,000)\nGhetto ($5,000)", "Select", "Cancel");
		}
	}
	return 1;
}

CMD:vdeposit(playerid, params[]) {
	if(playerVariables[playerid][pCarModel] >= 1) {
	    if(IsPlayerInRangeOfVehicle(playerid, playerVariables[playerid][pCarID], 6.0)) {
			new
			    amount,

			    houseOperation[64];

			if(sscanf(params, "s[32]d", houseOperation, amount)) {
			    return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/vdeposit [money/materials] [amount]");
			}
			else if(!strcmp(houseOperation, "money", true)) {
				if(playerVariables[playerid][pMoney] >= amount) {
					if(amount >= 1 && amount < 60000000) {
						playerVariables[playerid][pCarTrunk][0] += amount;
						playerVariables[playerid][pMoney] -= amount;

						if(playerVariables[playerid][pCarTrunk][0] < 1)
							playerVariables[playerid][pCarTrunk][0] = 0;

						if(playerVariables[playerid][pMoney] < 1)
							playerVariables[playerid][pMoney] = 0;

						format(houseOperation, sizeof(houseOperation), "You have deposited $%d in your vehicle.", amount);
						SendClientMessage(playerid, COLOR_WHITE, houseOperation);

						GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
						format(houseOperation, sizeof(houseOperation), "* %s deposits $%d in their vehicle.", szPlayerName, amount);
						nearByMessage(playerid, COLOR_PURPLE, houseOperation);
					}
					else {
						SendClientMessage(playerid, COLOR_GREY, "You can't deposit a negative amount into a house safe. (01x01)");
						printf("[error] 01x01, %d", playerid);
					}
				}
			}
			else if(!strcmp(houseOperation, "materials", true)) {
				if(playerVariables[playerid][pMaterials] >= amount) {
					if(amount >= 1 && amount < 60000000) {
						playerVariables[playerid][pCarTrunk][1] += amount;
						playerVariables[playerid][pMaterials] -= amount;

						if(playerVariables[playerid][pCarTrunk][1] < 1) playerVariables[playerid][pCarTrunk][1] = 0;
						if(playerVariables[playerid][pMaterials] < 1) playerVariables[playerid][pMaterials] = 0;

						format(houseOperation, sizeof(houseOperation), "You have deposited %d materials in your vehicle.", amount);
						SendClientMessage(playerid, COLOR_WHITE, houseOperation);

						GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
						format(houseOperation, sizeof(houseOperation), "* %s deposits %d materials in their vehicle.", szPlayerName, amount);
						nearByMessage(playerid, COLOR_PURPLE, houseOperation);
					}
					else {
						SendClientMessage(playerid, COLOR_GREY, "You can't deposit a negative amount into a house safe. (01x01)");
						printf("[error] 01x01, %d", playerid);
					}
				}
			}
			else SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/vdeposit [money/materials] [amount]");
	    }
	    else SendClientMessage(playerid, COLOR_GREY, "You're too far away from your vehicle.");
	}
	else SendClientMessage(playerid, COLOR_GREY, "You don't own a vehicle.");
	return 1;
}

CMD:vwithdraw(playerid, params[]) {
	if(playerVariables[playerid][pCarModel] >= 1) {
	    if(IsPlayerInRangeOfVehicle(playerid, playerVariables[playerid][pCarID], 6.0)) {
			new
			    amount,

			    houseOperation[72]; // For formatting afterwards.

			if(sscanf(params, "s[32]d", houseOperation, amount))
			    return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/vwithdraw [money/materials] [amount]");

			if(!strcmp(houseOperation, "money", true)) {
				if(playerVariables[playerid][pCarTrunk][0] >= amount) {
					if(amount >= 1 && amount < 60000000) {
						playerVariables[playerid][pCarTrunk][0] -= amount;
						playerVariables[playerid][pMoney] += amount;

						if(playerVariables[playerid][pCarTrunk][0] < 1) playerVariables[playerid][pCarTrunk][0] = 0;
						if(playerVariables[playerid][pMoney] < 1) playerVariables[playerid][pMoney] = 0;

						format(houseOperation, sizeof(houseOperation), "You have withdrawn $%d from your vehicle.", amount);
						SendClientMessage(playerid, COLOR_WHITE, houseOperation);

						GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
						format(houseOperation, sizeof(houseOperation), "* %s withdraws $%d from their vehicle.", szPlayerName, amount);
						nearByMessage(playerid, COLOR_PURPLE, houseOperation);
					}
					else SendClientMessage(playerid, COLOR_GREY, "(error) 01x04");
				}
			}
			else if(!strcmp(houseOperation, "materials", true)) {
				if(playerVariables[playerid][pCarTrunk][1] >= amount) {
					if(amount >= 1 && amount < 60000000) {
						playerVariables[playerid][pCarTrunk][1] -= amount;
						playerVariables[playerid][pMaterials] += amount;

						if(playerVariables[playerid][pCarTrunk][1] < 1) playerVariables[playerid][pCarTrunk][1] = 0;
						if(playerVariables[playerid][pMaterials] < 1) playerVariables[playerid][pMaterials] = 0;

						format(houseOperation, sizeof(houseOperation), "You have withdrawn %d materials from your vehicle.", amount);
						SendClientMessage(playerid, COLOR_WHITE, houseOperation);

						GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
						format(houseOperation, sizeof(houseOperation), "* %s withdraws %d materials from their vehicle.", szPlayerName, amount);
						nearByMessage(playerid, COLOR_PURPLE, houseOperation);
					}
					else SendClientMessage(playerid, COLOR_GREY, "(error) 01x04");
				}
			}
			else SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/vwithdraw [money/materials] [amount]");
	    }
	    else SendClientMessage(playerid, COLOR_GREY, "You're too far away from your vehicle.");
	}
	else SendClientMessage(playerid, COLOR_GREY, "You don't own a vehicle.");
	return 1;
}

CMD:vbalance(playerid, params[]) {
	new
		x;

	if(playerVariables[playerid][pCarModel] >= 1) {
		if(IsPlayerInRangeOfVehicle(playerid, playerVariables[playerid][pCarID], 6.0)) {

			new
				messageString[128];

			format(messageString, sizeof(messageString), "Money: $%d | Materials: %d", playerVariables[playerid][pCarTrunk][0], playerVariables[playerid][pCarTrunk][1]);

			for(new i; i < 5; i++) {
				if(playerVariables[playerid][pCarWeapons][i] > 0) {
					if(x == 0) format(messageString, sizeof(messageString),"%s | Weapons: %s (slot %d)", messageString, WeaponNames[playerVariables[playerid][pCarWeapons][i]], i);
					else format(messageString, sizeof(messageString),"%s, %s (slot %d)", messageString, WeaponNames[playerVariables[playerid][pCarWeapons][i]], i);
					x++;
				}
			}
			SendClientMessage(playerid, COLOR_WHITE, messageString);
		}
		else SendClientMessage(playerid, COLOR_GREY, "You're too far away from your vehicle.");
	}
	else SendClientMessage(playerid, COLOR_GREY, "You don't own a vehicle.");
	return 1;
}

CMD:vstoreweapon(playerid, params[]) {

	new
		slot = strval(params);

	if(isnull(params))
		return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/vstoreweapon [slot 1-5]");

	else if(playerVariables[playerid][pCarModel] >= 1) {
	    if(IsPlayerInRangeOfVehicle(playerid, playerVariables[playerid][pCarID], 6.0)) {
			if(slot >= 1 && slot <= 5) {
				if(playerVariables[playerid][pCarWeapons][slot - 1] == 0) {

					new
						string[86],
						weapon;

					GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
					weapon = GetPlayerWeapon(playerid);

					switch(weapon) {
						case 16, 18, 35, 36, 37, 38, 39, 40, 44, 45, 46, 0: SendClientMessage(playerid, COLOR_GREY, "Invalid weapon.");
						default: {
							playerVariables[playerid][pCarWeapons][slot - 1] = weapon;
							removePlayerWeapon(playerid, weapon);

							format(string, sizeof(string), "* %s places their %s in their vehicle.", szPlayerName, WeaponNames[weapon]);
							nearByMessage(playerid, COLOR_PURPLE, string);

							format(string, sizeof(string), "You have stored your %s in slot %d.", WeaponNames[weapon], slot);
							SendClientMessage(playerid, COLOR_WHITE, string);

						}
					}
				}
				else SendClientMessage(playerid, COLOR_GREY, "That slot is already occupied.");
			}
			else SendClientMessage(playerid, COLOR_GREY, "Invalid slot specified.");
		}
		else SendClientMessage(playerid, COLOR_GREY, "You're too far away from your vehicle.");
	}
	else SendClientMessage(playerid, COLOR_GREY, "You don't own a vehicle.");
	return 1;
}

CMD:vgetweapon(playerid, params[]) {

	new
		slot = strval(params);

	if(isnull(params))
		return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/vgetweapon [slot 1-5]");

	else if(playerVariables[playerid][pCarModel] >= 1) {
	    if(IsPlayerInRangeOfVehicle(playerid, playerVariables[playerid][pCarID], 6.0)) {
			if(slot >= 1 && slot <= 5) {
				if(playerVariables[playerid][pCarWeapons][slot - 1] != 0) {
					if(playerVariables[playerid][pWeapons][GetWeaponSlot(playerVariables[playerid][pCarWeapons][slot - 1])] == 0) {

						new
							string[86];

						GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
						givePlayerValidWeapon(playerid, playerVariables[playerid][pCarWeapons][slot - 1]);

						format(string, sizeof(string), "* %s retrieves their %s from their vehicle.", szPlayerName, WeaponNames[playerVariables[playerid][pCarWeapons][slot - 1]]);
						nearByMessage(playerid, COLOR_PURPLE, string);

						format(string, sizeof(string), "You have withdrawn your %s from slot %d.", WeaponNames[playerVariables[playerid][pCarWeapons][slot - 1]], slot);
						SendClientMessage(playerid, COLOR_WHITE, string);
						playerVariables[playerid][pCarWeapons][slot - 1] = 0;
					}
					else SendClientMessage(playerid, COLOR_GREY, "You already have a weapon of this type on you - drop it first.");
				}
				else SendClientMessage(playerid, COLOR_GREY, "There is no weapon stored in that slot.");
			}
			else SendClientMessage(playerid, COLOR_GREY, "Invalid slot specified.");
		}
		else SendClientMessage(playerid, COLOR_GREY, "You're too far away from your vehicle.");
	}
	else SendClientMessage(playerid, COLOR_GREY, "You don't own a vehicle.");
	return 1;
}

CMD:changeclothes(playerid, params[]) {

	new
		slot = strval(params),
		houseID = getPlayerHouseID(playerid),
		string[64];

	if(isnull(params))
		return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/changeclothes [slot 1-5]");

	if(getPlayerHouseID(playerid) >= 1) {
	    if(GetPlayerVirtualWorld(playerid) == HOUSE_VIRTUAL_WORLD + houseID) {
			if(slot >= 1 && slot <= 5) {
				if(houseVariables[houseID][hWardrobe][slot - 1] != 0) {

					SetPlayerSkin(playerid, houseVariables[houseID][hWardrobe][slot - 1]);
					playerVariables[playerid][pSkin] = houseVariables[houseID][hWardrobe][slot - 1];

					format(string, sizeof(string), "You have changed your clothing (skin %d, slot %d).", houseVariables[houseID][hWardrobe][slot - 1], slot);
					SendClientMessage(playerid, COLOR_WHITE, string);

					GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
					format(string, sizeof(string), "* %s dresses in their new clothing.", szPlayerName);
					nearByMessage(playerid, COLOR_PURPLE, string);
				}
				else SendClientMessage(playerid, COLOR_GREY, "You don't have any clothing in that slot.");
		    }
		    else SendClientMessage(playerid, COLOR_GREY, "Invalid slot specified.");
	    }
	    else SendClientMessage(playerid, COLOR_GREY, "You're not inside your house.");
	}
	else SendClientMessage(playerid, COLOR_GREY, "You don't have a house.");
	return 1;
}

CMD:hgetweapon(playerid, params[]) {

	new
		slot = strval(params),
		houseID = getPlayerHouseID(playerid);

	if(isnull(params))
		return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/hgetweapon [slot 1-5]");

	else if(getPlayerHouseID(playerid) >= 1) {
	    if(GetPlayerVirtualWorld(playerid) == HOUSE_VIRTUAL_WORLD + houseID) {
			if(slot >= 1 && slot <= 5) {
				if(houseVariables[houseID][hWeapons][slot - 1] != 0) {
					if(playerVariables[playerid][pWeapons][GetWeaponSlot(houseVariables[houseID][hWeapons][slot - 1])] == 0) {

						new
							string[86];

						GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
						givePlayerValidWeapon(playerid, houseVariables[houseID][hWeapons][slot - 1]);

						format(string, sizeof(string), "* %s retrieves their %s from their safe.", szPlayerName, WeaponNames[houseVariables[houseID][hWeapons][slot - 1]]);
						nearByMessage(playerid, COLOR_PURPLE, string);

						format(string, sizeof(string), "You have withdrawn your %s from slot %d.", WeaponNames[houseVariables[houseID][hWeapons][slot - 1]], slot);
						SendClientMessage(playerid, COLOR_WHITE, string);
						houseVariables[houseID][hWeapons][slot - 1] = 0;
						saveHouse(houseID);
					}
					else SendClientMessage(playerid, COLOR_GREY, "You already have a weapon of this type on you - drop it first.");
				}
				else SendClientMessage(playerid, COLOR_GREY, "There is no weapon stored in that slot.");
			}
			else SendClientMessage(playerid, COLOR_GREY, "Invalid slot specified.");
		}
		else SendClientMessage(playerid, COLOR_GREY, "You're not inside your house.");
	}
	else SendClientMessage(playerid, COLOR_GREY, "You don't have a house.");
	return 1;
}

CMD:hstoreweapon(playerid, params[]) {

	new
		slot = strval(params),
		houseID = getPlayerHouseID(playerid);

	if(isnull(params))
		return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/hstoreweapon [slot 1-5]");

	else if(getPlayerHouseID(playerid) >= 1) {
	    if(GetPlayerVirtualWorld(playerid) == HOUSE_VIRTUAL_WORLD + houseID) {
			if(slot >= 1 && slot <= 5) {
				if(houseVariables[houseID][hWeapons][slot - 1] == 0) {

					new
						string[86],
						weapon;

					GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
					weapon = GetPlayerWeapon(playerid);

					switch(weapon) {
						case 16, 18, 35, 36, 37, 38, 39, 40, 44, 45, 46, 0: SendClientMessage(playerid, COLOR_GREY, "Invalid weapon.");
						default: {
							houseVariables[houseID][hWeapons][slot - 1] = weapon;
							removePlayerWeapon(playerid, weapon);

							format(string, sizeof(string), "* %s places their %s in their safe.", szPlayerName, WeaponNames[weapon]);
							nearByMessage(playerid, COLOR_PURPLE, string);

							format(string, sizeof(string), "You have stored your %s in slot %d.", WeaponNames[weapon], slot);
							SendClientMessage(playerid, COLOR_WHITE, string);

							saveHouse(houseID);
						}
					}
				}
				else SendClientMessage(playerid, COLOR_GREY, "That slot is already occupied.");
			}
			else SendClientMessage(playerid, COLOR_GREY, "Invalid slot specified.");
		}
		else SendClientMessage(playerid, COLOR_GREY, "You're not inside your house.");
	}
	else SendClientMessage(playerid, COLOR_GREY, "You don't have a house.");
	return 1;
}

CMD:hbalance(playerid, params[]) {
	new
	    houseID = getPlayerHouseID(playerid), // So we don't have to loop every single time... It's worth the 4 bytes!
		x;

	if(getPlayerHouseID(playerid) >= 1) {
	    new
	        messageString[128];

		format(messageString, sizeof(messageString), "Money: $%d | Materials: %d", houseVariables[houseID][hMoney], houseVariables[houseID][hMaterials]);

		for(new i; i < 5; i++) {
			if(houseVariables[houseID][hWeapons][i] > 0) {
				if(x == 0) format(messageString, sizeof(messageString),"%s | Weapons: %s (slot %d)", messageString, WeaponNames[houseVariables[houseID][hWeapons][i]], i);
				else format(messageString, sizeof(messageString),"%s, %s (slot %d)", messageString, WeaponNames[houseVariables[houseID][hWeapons][i]], i);
				x++;
			}
		}
		SendClientMessage(playerid, COLOR_WHITE, messageString);
	}
	else {
		return SendClientMessage(playerid, COLOR_GREY, "You don't have a house.");
	}
	return 1;
}

CMD:hwithdraw(playerid, params[]) {
	new
	    houseID = getPlayerHouseID(playerid); // So we don't have to loop every single time... It's worth the 4 bytes!

	if(getPlayerHouseID(playerid) >= 1) {
	    if(GetPlayerVirtualWorld(playerid) == HOUSE_VIRTUAL_WORLD+houseID) {
			new
			    amount,

			    houseOperation[72]; // For formatting afterwards.

			if(sscanf(params, "s[32]d", houseOperation, amount))
			    return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/hwithdraw [money/materials] [amount]");

		    if(!strcmp(houseOperation, "money", true)) {
		        if(houseVariables[houseID][hMoney] >= amount) {
		            if(amount >= 1 && amount < 60000000) {
		                houseVariables[houseID][hMoney] -= amount;
		                playerVariables[playerid][pMoney] += amount;

		                if(houseVariables[houseID][hMoney] < 1)
							houseVariables[houseID][hMoney] = 0;

		                if(playerVariables[playerid][pMoney] < 1)
							playerVariables[playerid][pMoney] = 0;

		                format(houseOperation, sizeof(houseOperation), "You have withdrawn $%d from your safe.", amount);
		                SendClientMessage(playerid, COLOR_WHITE, houseOperation);

						GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
						format(houseOperation, sizeof(houseOperation), "* %s withdraws $%d from their safe.", szPlayerName, amount);
						nearByMessage(playerid, COLOR_PURPLE, houseOperation);
		            }
					else {
						SendClientMessage(playerid, COLOR_GREY, "You can't withdraw a negative amount from a house safe. (01x03)");
						printf("[error] 01x03, %d", playerid);
					}
		        }
		    }
		    else if(!strcmp(houseOperation, "materials", true)) {
		        if(houseVariables[houseID][hMaterials] >= amount) {
		            if(amount >= 1 && amount < 60000000) {
		                houseVariables[houseID][hMaterials] -= amount;
		                playerVariables[playerid][pMaterials] += amount;

		                if(houseVariables[houseID][hMaterials] < 1)
							houseVariables[houseID][hMaterials] = 0;

						if(playerVariables[playerid][pMaterials] < 1)
							playerVariables[playerid][pMaterials] = 0;

		                format(houseOperation, sizeof(houseOperation), "You have withdrawn %d materials from your safe.", amount);
		                SendClientMessage(playerid, COLOR_WHITE, houseOperation);

						GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
						format(houseOperation, sizeof(houseOperation), "* %s withdraws %d materials from their safe.", szPlayerName, amount);
						nearByMessage(playerid, COLOR_PURPLE, houseOperation);
		            }
					else {
						SendClientMessage(playerid, COLOR_GREY, "You can't withdraw a negative amount from a house safe. (01x03)");
						printf("[error] 01x03, %d", playerid);
					}
		        }
		    }
		    else {
				return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/hwithdraw [money/materials] [amount]");
			}
		}
    }
    else {
		return SendClientMessage(playerid, COLOR_GREY, "You're not inside your house.");
	}
	return 1;
}

CMD:hdeposit(playerid, params[]) {
	new
	    houseID = getPlayerHouseID(playerid); // So we don't have to loop every single time... It's worth the 4 bytes!

	if(getPlayerHouseID(playerid) >= 1) {
	    if(GetPlayerVirtualWorld(playerid) == HOUSE_VIRTUAL_WORLD+houseID) {
			new
			    amount,
			    houseOperation[72]; // For formatting afterwards.

			if(sscanf(params, "s[32]d", houseOperation, amount)) {
			    return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/hdeposit [money/materials] [amount]");
			}
			else {
			    if(!strcmp(houseOperation, "money", true)) {
			        if(playerVariables[playerid][pMoney] >= amount) {
			            if(amount >= 1 && amount < 60000000) {
			                houseVariables[houseID][hMoney] += amount;
			                playerVariables[playerid][pMoney] -= amount;

			                if(houseVariables[houseID][hMoney] < 1) houseVariables[houseID][hMoney] = 0;
			                if(playerVariables[playerid][pMoney] < 1) playerVariables[playerid][pMoney] = 0;

			                format(houseOperation, sizeof(houseOperation), "You have deposited $%d in your safe.", amount);
			                SendClientMessage(playerid, COLOR_WHITE, houseOperation);

							GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
							format(houseOperation, sizeof(houseOperation), "* %s deposits $%d in their safe.", szPlayerName, amount);
							nearByMessage(playerid, COLOR_PURPLE, houseOperation);

			            }
					}
					else {
						SendClientMessage(playerid, COLOR_GREY, "You can't deposit a negative amountfrom a house safe. (01x01)");
						printf("[error] 01x01, %d", playerid);
			        }
			    }
			    else if(!strcmp(houseOperation, "materials", true)) {
			        if(playerVariables[playerid][pMaterials] >= amount) {
			            if(amount >= 1 && amount < 60000000) {
			                houseVariables[houseID][hMaterials] += amount;
			                playerVariables[playerid][pMaterials] -= amount;

			                if(houseVariables[houseID][hMaterials] < 1) houseVariables[houseID][hMaterials] = 0;
							if(playerVariables[playerid][pMaterials] < 1) playerVariables[playerid][pMaterials] = 0;

			                format(houseOperation, sizeof(houseOperation), "You have deposited %d materials in your safe.", amount);
			                SendClientMessage(playerid, COLOR_WHITE, houseOperation);

							GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
							format(houseOperation, sizeof(houseOperation), "* %s deposits %d materials in their safe.", szPlayerName, amount);
							nearByMessage(playerid, COLOR_PURPLE, houseOperation);
			            }
						else {
							SendClientMessage(playerid, COLOR_GREY, "You can't deposit a negative amountfrom a house safe. (01x01)");
							printf("[error] 01x01, %d", playerid);
				        }
			        }
			    }
			    else {
					return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/hdeposit [money/materials] [amount]");
				}
			}
	    }
	    else {
			return SendClientMessage(playerid, COLOR_GREY, "You're not inside your house.");
		}
	}
	return 1;
}

CMD:btype(playerid, params[]) {
    if(playerVariables[playerid][pAdminLevel] >= 4) {
        new
            bCID,
            bCType;

		if(sscanf(params, "dd", bCID, bCType)) {
		    SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/btype [businessid] [type]");
            SendClientMessage(playerid, COLOR_GREY, "Types: 0 - None, 1 - 24/7, 2 - Clothing, 3 - Bar, 4 - Sex Shop, 5 - Vehicle Dealership, 6 - Gym");
			SendClientMessage(playerid, COLOR_GREY, "Types: 7 - Restaurant");
			return 1;
		}

		if(!isnull(businessVariables[bCID][bOwner])) {
		    format(szMessage, sizeof(szMessage), "You have changed business ID %d to type %d.", bCID, bCType);
		    SendClientMessage(playerid, COLOR_WHITE, szMessage);
		    
		    if(businessVariables[bCID][bType] != bCType) {
		    	format(szQueryOutput, sizeof(szQueryOutput), "DELETE FROM `businessitems` WHERE `itemBusinessId` = %d;", bCID);
		    	mysql_query(szQueryOutput, THREAD_CHANGE_BUSINESS_TYPE_ITEMS, bCID);
		    }

		    businessVariables[bCID][bType] = bCType;
		    saveBusiness(bCID);
		    
		    foreach(Player, x) {
		        if(GetPlayerVirtualWorld(playerid)-BUSINESS_VIRTUAL_WORLD == bCID)
					businessTypeMessages(bCID, x);
		    }
		} else return SendClientMessage(playerid, COLOR_GREY, "Invalid business ID.");
	}
	return 1;
}

CMD:createbusiness(playerid, params[]) {
    if(playerVariables[playerid][pAdminLevel] >= 4) {
    	new
          	Float: floatPos[3];

		if(!strcmp(params, "exterior", true)) {
	        GetPlayerPos(playerid, floatPos[0], floatPos[1], floatPos[2]);

            SetPVarFloat(playerid, "pBeX", floatPos[0]);
            SetPVarFloat(playerid, "pBeY", floatPos[1]);
            SetPVarFloat(playerid, "pBeZ", floatPos[2]);

            SetPVarInt(playerid, "bExt", 1);

            SendClientMessage(playerid, COLOR_WHITE, "Business exterior position configured.");
		}
        else if(!strcmp(params, "interior", true)) {
        	GetPlayerPos(playerid, floatPos[0], floatPos[1], floatPos[2]);

            SetPVarFloat(playerid, "pBiX", floatPos[0]);
            SetPVarFloat(playerid, "pBiY", floatPos[1]);
            SetPVarFloat(playerid, "pBiZ", floatPos[2]);

			SetPVarInt(playerid, "pBiID", GetPlayerInterior(playerid));
            SetPVarInt(playerid, "bInt", 1);

            SendClientMessage(playerid, COLOR_WHITE, "Business interior position configured.");
		}
        else if(!strcmp(params, "Complete", true)) {
        	if(GetPVarInt(playerid, "bExt") != 1 || GetPVarInt(playerid, "bInt") != 1)
            	return SendClientMessage(playerid, COLOR_GREY, "You haven't configured either the business exterior or interior. Creation attempt failed.");

			new
			    i,
	       		labelString[128];

			mysql_query("INSERT INTO businesses (businessOwner, businessName) VALUES('Nobody', 'New Business')");
			i = mysql_insert_id();

			if(isnull(businessVariables[i][bOwner])) {
				businessVariables[i][bExteriorPos][0] = GetPVarFloat(playerid, "pBeX");
			    businessVariables[i][bExteriorPos][1] = GetPVarFloat(playerid, "pBeY");
			    businessVariables[i][bExteriorPos][2] = GetPVarFloat(playerid, "pBeZ");

			    businessVariables[i][bInteriorPos][0] = GetPVarFloat(playerid, "pBiX");
			    businessVariables[i][bInteriorPos][1] = GetPVarFloat(playerid, "pBiY");
			    businessVariables[i][bInteriorPos][2] = GetPVarFloat(playerid, "pBiZ");

			    businessVariables[i][bInterior] = GetPVarInt(playerid, "pBiID");

 		        format(businessVariables[i][bOwner], MAX_PLAYER_NAME, "Nobody");
 		        format(businessVariables[i][bName], 32, "Nothing");

 		        businessVariables[i][bLocked] = 1;

		        format(labelString, sizeof(labelString), "%s\n(Business %d - un-owned)\nPrice: $%d (/buybusiness)\n\n(locked)", businessVariables[i][bName], i, businessVariables[i][bPrice]);

		        businessVariables[i][bLabelID] = CreateDynamic3DTextLabel(labelString, COLOR_YELLOW, businessVariables[i][bExteriorPos][0], businessVariables[i][bExteriorPos][1], businessVariables[i][bExteriorPos][2], 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 10.0);
				businessVariables[i][bPickupID] = CreateDynamicPickup(1239, 23, businessVariables[i][bExteriorPos][0], businessVariables[i][bExteriorPos][1], businessVariables[i][bExteriorPos][2], 0, 0, -1, 250);

				saveBusiness(i);

			    DeletePVar(playerid, "pBeX");
			    DeletePVar(playerid, "pBeY");
			    DeletePVar(playerid, "pBeZ");
			    DeletePVar(playerid, "pBiX");
			    DeletePVar(playerid, "pBeY");
			    DeletePVar(playerid, "pBeZ");
			    DeletePVar(playerid, "pBiID");

			    SetPlayerInterior(playerid, 0);
			    SetPlayerPos(playerid, businessVariables[i][bExteriorPos][0], businessVariables[i][bExteriorPos][1], businessVariables[i][bExteriorPos][2]);
				systemVariables[businessCount]++;
				
				createRelevantItems(i);
		        return SendClientMessage(playerid, COLOR_WHITE, "Business created!");
			} else
				return SendClientMessage(playerid, COLOR_WHITE, "There are no available business slots left.");

		} else
        	return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/createbusiness [interior/exit/complete]");
	}
	return 1;
}

CMD:drop(playerid, params[]) {
	new
		string[64];

	if(GetPlayerWeapon(playerid) == 0 || playerVariables[playerid][pEvent] != 0) format(string, sizeof(string),"Materials (%d)\nPhone\nWalkie Talkie", playerVariables[playerid][pMaterials]);
	else format(string, sizeof(string),"Materials (%d)\nPhone\nWalkie Talkie\nCurrent weapon (%s)", playerVariables[playerid][pMaterials], WeaponNames[GetPlayerWeapon(playerid)]);

    ShowPlayerDialog(playerid, DIALOG_DROPITEM, DIALOG_STYLE_LIST, "Inventory", string, "Select", "Cancel");
	return 1;
}

CMD:savevehicle(playerid, params[]) {
    if(playerVariables[playerid][pAdminLevel] >= 4) {
		if(!IsPlayerInAnyVehicle(playerid))
			return SendClientMessage(playerid, COLOR_GREY, "You need to be in a vehicle to save it.");

		if(GetPVarInt(playerid, "sCc") == 1) {

		    new
		        i,
		        queryString[255],
		        Float: vPos[4]; // x, y, z + z angle

		    GetVehiclePos(GetPlayerVehicleID(playerid), vPos[0], vPos[1], vPos[2]);
		    GetVehicleZAngle(GetPlayerVehicleID(playerid), vPos[3]);

		    format(queryString, sizeof(queryString), "INSERT INTO vehicles (vehicleModelID, vehiclePosX, vehiclePosY, vehiclePosZ, vehiclePosRotation) VALUES('%d', '%f', '%f', '%f', '%f')", GetVehicleModel(GetPlayerVehicleID(playerid)), vPos[0], vPos[1], vPos[2], vPos[3]);
		    mysql_query(queryString);

		    i = mysql_insert_id();

		    SendClientMessage(playerid, COLOR_WHITE, "Vehicle saved!");

		    vehicleVariables[i][vVehicleModelID] = GetVehicleModel(GetPlayerVehicleID(playerid));
		    vehicleVariables[i][vVehiclePosition][0] = vPos[0];
		    vehicleVariables[i][vVehiclePosition][1] = vPos[1];
		    vehicleVariables[i][vVehiclePosition][2] = vPos[2];

		    vehicleVariables[i][vVehicleRotation] = vPos[3];
		    vehicleVariables[i][vVehicleGroup] = 0;

		    vehicleVariables[i][vVehicleScriptID] = GetPlayerVehicleID(playerid);

		    for(new x = 0; x < MAX_VEHICLES; x++) {
		    	if(AdminSpawnedVehicles[x] == GetPlayerVehicleID(playerid)) {
		    	    AdminSpawnedVehicles[x] = 0; // If the vehicle is admin-spawned, we can remove it from the array and move it to the vehicle script enum/arrays.
		    	}
		    }

			systemVariables[vehicleCounts][2]--;
			systemVariables[vehicleCounts][0]++;
			DeletePVar(playerid, "sCc");
		}
		else {
		    SetPVarInt(playerid, "sCc", 1);
		    return SendClientMessage(playerid, COLOR_GREY, "Are you sure you wish to save this vehicle? Re-type the command to verify your action is legitimate.");
		}
	}
	return 1;
}

CMD:businessname(playerid, params[]) {
	if(getPlayerBusinessID(playerid) >= 1) {
	    if(isnull(params))
			 return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/businessname [businessname]");

	    if(strlen(params) >= 43 || strlen(params) < 1)
			return SendClientMessage(playerid, COLOR_GREY, "Invalid name length (1-42).");

	    new
	        x = getPlayerBusinessID(playerid);

	    format(result, sizeof(result), "You have changed the name of your business to '%s'.", params);
	    SendClientMessage(playerid, COLOR_WHITE, result);

		mysql_real_escape_string(params, params);
		strcpy(businessVariables[x][bName], params, 20);

	    switch(businessVariables[x][bLocked]) {
			case 1: {
				format(result, sizeof(result), "%s\n(Business %d - owned by %s)\n\n(locked)", businessVariables[x][bName], x, businessVariables[x][bOwner]);
			}
			case 0: {
				format(result, sizeof(result), "%s\n(Business %d - owned by %s)\n\nPress ~k~~PED_DUCK~ to enter", businessVariables[x][bName], x, businessVariables[x][bOwner]);
			}
		}

		UpdateDynamic3DTextLabelText(businessVariables[x][bLabelID], COLOR_YELLOW, result);
	}
	return 1;
}

CMD:createhouse(playerid, params[]) {
    if(playerVariables[playerid][pAdminLevel] >= 4) {
		new
	   		Float: floatPos[3];
	   		
		if(!strcmp(params, "Exterior", true)) {
	        GetPlayerPos(playerid, floatPos[0], floatPos[1], floatPos[2]);

	        SetPVarFloat(playerid, "pHeX", floatPos[0]);
	        SetPVarFloat(playerid, "pHeY", floatPos[1]);
	        SetPVarFloat(playerid, "pHeZ", floatPos[2]);

	        SetPVarInt(playerid, "hExt", 1);

	        SendClientMessage(playerid, COLOR_WHITE, "House exterior position configured.");
		} else if(!strcmp(params, "Interior", true)) {
            GetPlayerPos(playerid, floatPos[0], floatPos[1], floatPos[2]);

            SetPVarFloat(playerid, "pHiX", floatPos[0]);
            SetPVarFloat(playerid, "pHiY", floatPos[1]);
            SetPVarFloat(playerid, "pHiZ", floatPos[2]);

			SetPVarInt(playerid, "pHiID", GetPlayerInterior(playerid));
            SetPVarInt(playerid, "hInt", 1);

            SendClientMessage(playerid, COLOR_WHITE, "House interior position configured.");
		} else if(!strcmp(params, "Complete", true)) {
        	if(GetPVarInt(playerid, "hExt") != 1 || GetPVarInt(playerid, "hInt") != 1)
				return SendClientMessage(playerid, COLOR_GREY, "You haven't configured either the house exterior or interior. Creation attempt failed.");

			new
			    i,
           		labelString[96];

			mysql_query("INSERT INTO houses (houseOwner, houseLocked) VALUES('Nobody', '1')");
			i = mysql_insert_id();

			if(isnull(houseVariables[i][hHouseOwner])) {
				houseVariables[i][hHouseExteriorPos][0] = GetPVarFloat(playerid, "pHeX");
				houseVariables[i][hHouseExteriorPos][1] = GetPVarFloat(playerid, "pHeY");
				houseVariables[i][hHouseExteriorPos][2] = GetPVarFloat(playerid, "pHeZ");

			    houseVariables[i][hHouseInteriorPos][0] = GetPVarFloat(playerid, "pHiX");
			    houseVariables[i][hHouseInteriorPos][1] = GetPVarFloat(playerid, "pHiY");
			    houseVariables[i][hHouseInteriorPos][2] = GetPVarFloat(playerid, "pHiZ");

			    houseVariables[i][hHouseExteriorID] = 0;
			    houseVariables[i][hHouseInteriorID] = GetPVarInt(playerid, "pHiID");

			    houseVariables[i][hHouseLocked] = 1;

 		        format(houseVariables[i][hHouseOwner], MAX_PLAYER_NAME, "Nobody");
		        format(labelString, sizeof(labelString), "House %d (un-owned - /buyhouse)\nPrice: $%d\n\n(locked)", i, houseVariables[i][hHousePrice]);

		        houseVariables[i][hLabelID] = CreateDynamic3DTextLabel(labelString, COLOR_YELLOW, houseVariables[i][hHouseExteriorPos][0], houseVariables[i][hHouseExteriorPos][1], houseVariables[i][hHouseExteriorPos][2], 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 10.0);
				houseVariables[i][hPickupID] = CreateDynamicPickup(1273, 23, houseVariables[i][hHouseExteriorPos][0], houseVariables[i][hHouseExteriorPos][1], houseVariables[i][hHouseExteriorPos][2], 0, 0, -1, 250);

				saveHouse(i);

			    DeletePVar(playerid, "pHeX");
			    DeletePVar(playerid, "pHeY");
			    DeletePVar(playerid, "pHeZ");
			    DeletePVar(playerid, "pHiX");
			    DeletePVar(playerid, "pHeY");
			    DeletePVar(playerid, "pHeZ");
			    DeletePVar(playerid, "pHiID");

			    SetPlayerInterior(playerid, 0);
			    SetPlayerPos(playerid, houseVariables[i][hHouseExteriorPos][0], houseVariables[i][hHouseExteriorPos][1], houseVariables[i][hHouseExteriorPos][2]);

				systemVariables[houseCount]++;
		        return SendClientMessage(playerid, COLOR_WHITE, "House created!");
			} else
				return SendClientMessage(playerid, COLOR_WHITE, "There are no available house slots left, sorry!");
		} else
		    return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/createhouse [exterior/interior/complete]");
	}
	return 1;
}

CMD:getvehicle(playerid, params[]) {
    if(playerVariables[playerid][pAdminLevel] >= 1) {
		new
		    iVehicleID = strval(params);

		if(doesVehicleExist(iVehicleID)) {
	        GetPlayerPos(playerid, playerVariables[playerid][pPos][0], playerVariables[playerid][pPos][1], playerVariables[playerid][pPos][2]);
	        SetVehiclePos(iVehicleID, playerVariables[playerid][pPos][0], playerVariables[playerid][pPos][1], playerVariables[playerid][pPos][2]);
	        
	        format(szMessage, sizeof(szMessage), "Vehicle %d has been teleported to your location", iVehicleID);
	        SendClientMessage(playerid, COLOR_WHITE, szMessage);
        }
    }
	return 1;
}

CMD:flipvehicle(playerid, params[]) {
    if(playerVariables[playerid][pAdminLevel] >= 1) {
        if(!IsPlayerInAnyVehicle(playerid))
            return SendClientMessage(playerid, COLOR_GREY, "You're not in a vehicle.");

        GetVehiclePos(GetPlayerVehicleID(playerid), playerVariables[playerid][pPos][0], playerVariables[playerid][pPos][1], playerVariables[playerid][pPos][2]);
        SetVehiclePos(GetPlayerVehicleID(playerid), playerVariables[playerid][pPos][0], playerVariables[playerid][pPos][1], playerVariables[playerid][pPos][2]);
        SendClientMessage(playerid, COLOR_WHITE, "Your vehicle has been flipped back over.");
    }
	return 1;
}

CMD:spawnweapon(playerid, params[]) {
    if(playerVariables[playerid][pAdminLevel] >= 3) {
        new
            weaponID,
            userID;

		if(sscanf(params, "ud", userID, weaponID))
			return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/spawnweapon [playerid] [weaponid]");

        if(userID != INVALID_PLAYER_ID) {
			new
				string[63];

			GetPlayerName(userID, szPlayerName, MAX_PLAYER_NAME);
			
			if(weaponID < 1 && weaponID > 48)
			    return SendClientMessage(playerid, COLOR_GREY, "Invalid weapon ID.");

			if(weaponID == 19) {
				if(GetPlayerState(userID) != 1) {
					return SendClientMessage(playerid, COLOR_GREY, "The specified player must be on foot.");
				}
				else {
					format(string, sizeof(string), "You have given %s a jetpack.", szPlayerName);
					SendClientMessage(playerid, COLOR_WHITE, string);
					playerVariables[userID][pJetpack] = 1;
					return SetPlayerSpecialAction(userID, SPECIAL_ACTION_USEJETPACK);
				}
			}
			else {
				format(string, sizeof(string), "You have given %s a %s.", szPlayerName, WeaponNames[weaponID]);
				SendClientMessage(playerid, COLOR_WHITE, string);
				return givePlayerValidWeapon(userID, weaponID);
			}
		}
		else SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");
    }
    return 1;
}

CMD:get(playerid, params[]) {
    if(playerVariables[playerid][pAdminLevel] >= 1) {
        new
            userID;

		if(sscanf(params, "u", userID)) {
			return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/get [playerid]");
		}
        else {
            if(userID == INVALID_PLAYER_ID)
				return SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");

			if(playerVariables[playerid][pAdminLevel] >= playerVariables[userID][pAdminLevel]) {
				new
					messageString[64],

					Float: fPos[3];

				GetPlayerPos(playerid, fPos[0], fPos[1], fPos[2]);
				if(GetPlayerState(userID) == 2) {

					SetVehiclePos(GetPlayerVehicleID(userID), fPos[0], fPos[1]+2, fPos[2]);
					LinkVehicleToInterior(GetPlayerVehicleID(userID), GetPlayerInterior(playerid));
					SetVehicleVirtualWorld(GetPlayerVehicleID(userID), GetPlayerVirtualWorld(playerid));
				}

				else SetPlayerPos(userID, fPos[0], fPos[1]+2, fPos[2]); // If they're driving a vehicle, it gets the vehicle; otherwise, it warps them only.

				SetPlayerInterior(userID, GetPlayerInterior(playerid));
				SetPlayerVirtualWorld(userID, GetPlayerVirtualWorld(playerid));

				GetPlayerName(userID, szPlayerName, MAX_PLAYER_NAME);
				format(messageString, sizeof(messageString), "You have teleported %s to you.", szPlayerName);
				SendClientMessage(playerid, COLOR_WHITE, messageString);
			}
			else SendClientMessage(playerid, COLOR_GREY, "You can't teleport a higher level administrator - request them to teleport to you.");
		}
    }

    return 1;
}

CMD:bprice(playerid, params[]) {
	if(playerVariables[playerid][pAdminLevel] >= 3) {
	    new
	        businessID,
	        businessPrice;

		if(sscanf(params, "dd", businessID, businessPrice)) {
			return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/bprice [businessid] [price]");
		}
		else {
		    if(businessID < 1 || businessID > MAX_BUSINESSES) {
				return SendClientMessage(playerid, COLOR_GREY, "Invalid business ID.");
			}
		    else {
				format(szMessage, sizeof(szMessage), "You have set business %d's price to $%d.", businessID, businessPrice);
				SendClientMessage(playerid, COLOR_WHITE, szMessage);

				businessVariables[businessID][bPrice] = businessPrice;

				if(!strcmp(businessVariables[businessID][bOwner], "Nobody", true) && strlen(businessVariables[businessID][bOwner]) >= 1) {
					switch(businessVariables[businessID][bLocked]) {
						case 1: format(szMessage, sizeof(szMessage), "%s\n(Business %d - un-owned)\nPrice: $%d (/buybusiness)\n\n(locked)", businessVariables[businessID][bName], businessID, businessVariables[businessID][bPrice]);
						default: format(szMessage, sizeof(szMessage), "%s\n(Business %d - un-owned)\nPrice: $%d (/buybusiness)\n\nPress ~k~~PED_DUCK~ to enter.", businessVariables[businessID][bName], businessID, businessVariables[businessID][bPrice]);
					}

					UpdateDynamic3DTextLabelText(businessVariables[businessID][bLabelID], COLOR_YELLOW, szMessage);
				}
			}
		}
	}
	return 1;
}

CMD:hprice(playerid, params[]) {
	if(playerVariables[playerid][pAdminLevel] >= 3) {
	    new
	        houseID,
	        housePrice;

		if(sscanf(params, "dd", houseID, housePrice))
			return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/hprice [houseid] [price]");

	    if(houseID < 1 || houseID > MAX_HOUSES)
			return SendClientMessage(playerid, COLOR_GREY, "Invalid house ID.");

		format(szMessage, sizeof(szMessage), "You have set house %d's price to $%d.", houseID, housePrice);
		SendClientMessage(playerid, COLOR_WHITE, szMessage);

		houseVariables[houseID][hHousePrice] = housePrice;

		if(!strcmp(houseVariables[houseID][hHouseOwner], "Nobody", true) && strlen(houseVariables[houseID][hHouseOwner]) >= 1) {
			switch(houseVariables[houseID][hHouseLocked]) {
				case 0: format(szMessage, sizeof(szMessage), "House %d (un-owned - /buyhouse)\nPrice: $%d\n\n(locked)", houseID, houseVariables[houseID][hHousePrice]);
				default: format(szMessage, sizeof(szMessage), "House %d (un-owned - /buyhouse)\nPrice: $%d\n\nPress ~k~~PED_DUCK~ to enter.", houseID, houseVariables[houseID][hHousePrice]);
			}

			UpdateDynamic3DTextLabelText(houseVariables[houseID][hLabelID], COLOR_YELLOW, szMessage);
		}
	}
	return 1;
}

CMD:gotoplayervehicle(playerid, params[]) {
    if(playerVariables[playerid][pAdminLevel] >= 2) {
        new
            userID;

		if(sscanf(params, "u", userID))
			return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/gotoplayervehicle [playerid]");

        if(userID == INVALID_PLAYER_ID)
			return SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");

		if(playerVariables[userID][pCarModel] < 1)
			return SendClientMessage(playerid, COLOR_GREY, "That player does not own a vehicle.");

		new
		    messageString[64];

		GetVehiclePos(playerVariables[userID][pCarID], playerVariables[userID][pCarPos][0], playerVariables[userID][pCarPos][1], playerVariables[userID][pCarPos][2]);

		if(GetPlayerState(playerid) == 2) {
			SetVehiclePos(GetPlayerVehicleID(playerid), playerVariables[userID][pCarPos][0], playerVariables[userID][pCarPos][1]+2, playerVariables[userID][pCarPos][2]);
			SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), GetVehicleVirtualWorld(playerVariables[userID][pCarID]));
			LinkVehicleToInterior(GetPlayerVehicleID(playerid), 0);
		}
		else SetPlayerPos(playerid, playerVariables[userID][pCarPos][0], playerVariables[userID][pCarPos][1]+2, playerVariables[userID][pCarPos][2]);

		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, GetVehicleVirtualWorld(playerVariables[userID][pCarID]));

		GetPlayerName(userID, szPlayerName, MAX_PLAYER_NAME);

		format(messageString, sizeof(messageString), "You have teleported to %s's %s.", szPlayerName, VehicleNames[playerVariables[userID][pCarModel] - 400]);
		SendClientMessage(playerid, COLOR_WHITE, messageString);
    }
    return 1;
}

CMD:goto(playerid, params[]) {
    if(playerVariables[playerid][pAdminLevel] >= 1) {
        new
            userID;

		if(sscanf(params, "u", userID)) {
			return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/goto [playerid]");
		}
        else {
            if(!IsPlayerConnected(userID)) return SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");

			new
			    messageString[64],

			    Float: fPos[3];

			GetPlayerPos(userID, fPos[0], fPos[1], fPos[2]);

			if(GetPlayerState(playerid) == 2) {

				SetVehiclePos(GetPlayerVehicleID(playerid), fPos[0], fPos[1]+2, fPos[2]);

				LinkVehicleToInterior(GetPlayerVehicleID(playerid), GetPlayerInterior(userID));
				SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), GetPlayerVirtualWorld(userID));
			}

			else SetPlayerPos(playerid, fPos[0], fPos[1]+2, fPos[2]);

			SetPlayerInterior(playerid, GetPlayerInterior(userID));
			SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(userID));

			GetPlayerName(userID, szPlayerName, MAX_PLAYER_NAME);

			format(messageString, sizeof(messageString), "You have teleported to %s.", szPlayerName);
			SendClientMessage(playerid, COLOR_WHITE, messageString);
		}
    }

    return 1;
}

CMD:setleader(playerid, params[]) {
    if(playerVariables[playerid][pAdminLevel] >= 3) {
        new
            groupID,
            userID;

		if(sscanf(params, "ud", userID, groupID)) {
			return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/setleader [playerid] [groupid]");
		}
        else {
			if(groupID < 1 || groupID > MAX_GROUPS) return SendClientMessage(playerid, COLOR_GREY, "Invalid group ID.");

			playerVariables[userID][pGroup] = groupID;
			playerVariables[userID][pGroupRank] = 6;

			new

			    string[128];

			GetPlayerName(userID, szPlayerName, MAX_PLAYER_NAME);

			format(string, sizeof(string), "You have set %s to lead group %s.", szPlayerName, groupVariables[groupID][gGroupName]);
			SendClientMessage(playerid, COLOR_WHITE, string);

			GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);

			format(string, sizeof(string), "Administrator %s has set you to lead group %s.", szPlayerName, groupVariables[groupID][gGroupName]);
			SendClientMessage(userID, COLOR_WHITE, string);
		}
    }

    return 1;
}

CMD:buybusiness(playerid, params[]) {
    if(playerVariables[playerid][pStatus] >= 1) {
        for(new x = 0; x < MAX_BUSINESSES; x++) {
			if(IsPlayerInRangeOfPoint(playerid, 5, businessVariables[x][bExteriorPos][0], businessVariables[x][bExteriorPos][1], businessVariables[x][bExteriorPos][2])) {
				if(!strcmp(businessVariables[x][bOwner], "Nobody", true)) {
				    if(businessVariables[x][bPrice] == -1) return SendClientMessage(playerid, COLOR_GREY, "This business was blocked from being purchased by an administrator.");
					if(getPlayerBusinessID(playerid) >= 1) return SendClientMessage(playerid, COLOR_GREY, "You already own a business.");
					if(playerVariables[playerid][pMoney] >= businessVariables[x][bPrice]) {
						playerVariables[playerid][pMoney] -= businessVariables[x][bPrice];

						new
						    labelString[96];

						strcpy(businessVariables[x][bOwner], playerVariables[playerid][pNormalName], MAX_PLAYER_NAME);

						DestroyDynamicPickup(businessVariables[x][bPickupID]);

					    if(businessVariables[x][bLocked] == 1) {
					    	format(labelString, sizeof(labelString), "%s\n(Business %d - owned by %s)\n\n(locked)", businessVariables[x][bName], x, businessVariables[x][bOwner]);
					    }
					    else {
					        format(labelString, sizeof(labelString), "%s\n(Business %d - owned by %s)\n\nPress ~k~~PED_DUCK~ to enter", businessVariables[x][bName], x, businessVariables[x][bOwner]);
					    }
						UpdateDynamic3DTextLabelText(businessVariables[x][bLabelID], COLOR_YELLOW, labelString);
						businessVariables[x][bPickupID] = CreateDynamicPickup(1239, 23, businessVariables[x][bExteriorPos][0], businessVariables[x][bExteriorPos][1], businessVariables[x][bExteriorPos][2], 0, 0, -1, 250);

						SendClientMessage(playerid, COLOR_WHITE, "Congratulations on your purchase!");

						saveBusiness(x);
					}
					else SendClientMessage(playerid, COLOR_GREY, "You don't have enough money to purchase this business.");
				}
				else {
					return SendClientMessage(playerid, COLOR_GREY, "You can't purchase an owned business.");
				}
			}
		}
    }
	return 1;
}

CMD:bspawnpos(playerid, params[]) {

	if(getPlayerBusinessID(playerid) >= 1) {

		new
			businessID = getPlayerBusinessID(playerid);

		if(businessVariables[businessID][bType] == 5) {
			if(IsPlayerInRangeOfPoint(playerid, 30.0, businessVariables[businessID][bExteriorPos][0], businessVariables[businessID][bExteriorPos][1], businessVariables[businessID][bExteriorPos][2])) {
				GetPlayerPos(playerid, businessVariables[businessID][bMiscPos][0], businessVariables[businessID][bMiscPos][1], businessVariables[businessID][bMiscPos][2]);
				SendClientMessage(playerid, COLOR_WHITE, "You have successfully altered the spawn position of your vehicle dealership business.");
			}
			else SendClientMessage(playerid, COLOR_GREY, "You must be within thirty metres of the exterior of your business.");
		}
		else SendClientMessage(playerid, COLOR_GREY, "You don't own a vehicle dealership.");
	}
	return 1;
}

CMD:movebusiness(playerid, params[]) {
	if(playerVariables[playerid][pAdminLevel] >= 3) {
	    new
	        houseID,
	        subject[32];

		if(sscanf(params, "ds[32]", houseID, subject)) {
		    SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/movebusiness [businessid] [exterior/interior]");
		}
		else {
		    if(houseID < 1 || houseID > MAX_BUSINESSES) return SendClientMessage(playerid, COLOR_GREY, "Invalid business ID.");

            if(strcmp(subject, "exterior", true) == 0) {
			    GetPlayerPos(playerid, businessVariables[houseID][bExteriorPos][0], businessVariables[houseID][bExteriorPos][1], businessVariables[houseID][bExteriorPos][2]);

			    DestroyDynamic3DTextLabel(businessVariables[houseID][bLabelID]);
			    DestroyDynamicPickup(businessVariables[houseID][bPickupID]);

				if(!strcmp(businessVariables[houseID][bOwner], "Nobody", true) && strlen(businessVariables[houseID][bOwner]) >= 1) {
				    new
				        labelString[96];

				    if(businessVariables[houseID][bLocked] == 1) {
				    	format(labelString, sizeof(labelString), "%s\n(Business %d - un-owned)\nPrice: $%d (/buybusiness)\n\n(locked)", businessVariables[houseID][bName], houseID, businessVariables[houseID][bPrice]);
				    }
				    else {
				        format(labelString, sizeof(labelString), "%s\n(Business %d - un-owned)\nPrice: $%d (/buybusiness)\n\nPress ~k~~PED_DUCK~ to enter.", businessVariables[houseID][bName], houseID, businessVariables[houseID][bPrice]);
				    }

				    businessVariables[houseID][bLabelID] = CreateDynamic3DTextLabel(labelString, COLOR_YELLOW, businessVariables[houseID][bExteriorPos][0], businessVariables[houseID][bExteriorPos][1], businessVariables[houseID][bExteriorPos][2], 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 10.0);
					businessVariables[houseID][bPickupID] = CreateDynamicPickup(1239, 23, businessVariables[houseID][bExteriorPos][0], businessVariables[houseID][bExteriorPos][1], businessVariables[houseID][bExteriorPos][2], 0, 0, -1, 250);

				}
				else {
				    new
				        labelString[96];

				    if(businessVariables[houseID][bLocked] == 1) {
				    	format(labelString, sizeof(labelString), "%s\n(Business %d - owned by %s)\n\n(locked)", businessVariables[houseID][bName], houseID, businessVariables[houseID][bOwner]);
				    }
				    else {
				        format(labelString, sizeof(labelString), "%s\n(Business %d - owned by %s)\n\nPress ~k~~PED_DUCK~ to enter", businessVariables[houseID][bName], houseID, businessVariables[houseID][bOwner]);
				    }

				    businessVariables[houseID][bLabelID] = CreateDynamic3DTextLabel(labelString, COLOR_YELLOW, businessVariables[houseID][bExteriorPos][0], businessVariables[houseID][bExteriorPos][1], businessVariables[houseID][bExteriorPos][2], 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 10.0);
					businessVariables[houseID][bPickupID] = CreateDynamicPickup(1239, 23, businessVariables[houseID][bExteriorPos][0], businessVariables[houseID][bExteriorPos][1], businessVariables[houseID][bExteriorPos][2], 0, 0, -1, 250);
				}

				SendClientMessage(playerid, COLOR_WHITE, "The business exterior has successfully been changed.");
			}
			else if(strcmp(subject, "interior", true) == 0) {
			    GetPlayerPos(playerid, businessVariables[houseID][bInteriorPos][0], businessVariables[houseID][bInteriorPos][1], businessVariables[houseID][bInteriorPos][2]);
			    businessVariables[houseID][bInterior] = GetPlayerInterior(playerid);
			    SendClientMessage(playerid, COLOR_WHITE, "The business interior has successfully been changed.");
			}
			saveBusiness(houseID);
		}
	}

	return 1;
}

CMD:movehq(playerid, params[]) {
	if(playerVariables[playerid][pAdminLevel] >= 3) {
	    new
	        ID,
	        subject[32],
			string[128];

		if(sscanf(params, "ds[32]", ID, subject)) {
		    SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/movehq [group ID] [exterior/interior]");
		}
		else {
		    if(ID < 1 || ID > MAX_GROUPS) return SendClientMessage(playerid, COLOR_GREY, "Invalid group ID.");

            if(strcmp(subject, "exterior", true) == 0) {
			    GetPlayerPos(playerid, groupVariables[ID][gGroupExteriorPos][0], groupVariables[ID][gGroupExteriorPos][1], groupVariables[ID][gGroupExteriorPos][2]);

			    DestroyDynamic3DTextLabel(groupVariables[ID][gGroupLabelID]);
			    DestroyDynamicPickup(groupVariables[ID][gGroupPickupID]);

				new
    				labelString[96];

				switch(groupVariables[ID][gGroupHQLockStatus]) {
			    	case 0: format(labelString, sizeof(labelString), "%s's HQ\n\nPress ~k~~PED_DUCK~ to enter.", groupVariables[ID][gGroupName]);
			    	case 1: format(labelString, sizeof(labelString), "%s's HQ\n\n(locked)", groupVariables[ID][gGroupName]);
			    }

				groupVariables[ID][gGroupLabelID] = CreateDynamic3DTextLabel(labelString, COLOR_YELLOW, groupVariables[ID][gGroupExteriorPos][0], groupVariables[ID][gGroupExteriorPos][1], groupVariables[ID][gGroupExteriorPos][2], 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 50.0);
				groupVariables[ID][gGroupPickupID] = CreateDynamicPickup(1239, 23, groupVariables[ID][gGroupExteriorPos][0], groupVariables[ID][gGroupExteriorPos][1], groupVariables[ID][gGroupExteriorPos][2], 0, -1, -1, 50);
			}
			else if(strcmp(subject, "interior", true) == 0){
			    GetPlayerPos(playerid, groupVariables[ID][gGroupInteriorPos][0], groupVariables[ID][gGroupInteriorPos][1], groupVariables[ID][gGroupInteriorPos][2]);
			    groupVariables[ID][gGroupHQInteriorID] = GetPlayerInterior(playerid);

			}
			format(string,sizeof(string),"You have successfully moved the %s of the %s group (ID %d).",subject,groupVariables[ID][gGroupName],ID);
			SendClientMessage(playerid, COLOR_WHITE, string);
		}
	}

	return 1;
}

CMD:movehouse(playerid, params[]) {
	if(playerVariables[playerid][pAdminLevel] >= 3) {
	    new
	        houseID,
	        subject[32];

		if(sscanf(params, "ds[32]", houseID, subject)) {
		    SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/movehouse [houseid] [exterior/interior]");
		}
		else {
		    if(houseID < 1 || houseID > MAX_HOUSES) return SendClientMessage(playerid, COLOR_GREY, "Invalid house ID.");

            if(strcmp(subject, "exterior", true) == 0) {
			    GetPlayerPos(playerid, houseVariables[houseID][hHouseExteriorPos][0], houseVariables[houseID][hHouseExteriorPos][1], houseVariables[houseID][hHouseExteriorPos][2]);

			    DestroyDynamic3DTextLabel(houseVariables[houseID][hLabelID]);
			    DestroyDynamicPickup(houseVariables[houseID][hPickupID]);

				if(!strcmp(houseVariables[houseID][hHouseOwner], "Nobody", true) && strlen(houseVariables[houseID][hHouseOwner]) >= 1) {
				    new
				        labelString[96];

				    if(houseVariables[houseID][hHouseLocked] == 1) {
				    	format(labelString, sizeof(labelString), "House %d (un-owned - /buyhouse)\nPrice: $%d\n\n(locked)", houseID, houseVariables[houseID][hHousePrice]);
				    }
				    else {
				        format(labelString, sizeof(labelString), "House %d (un-owned - /buyhouse)\nPrice: $%d\n\nPress ~k~~PED_DUCK~ to enter.", houseID, houseVariables[houseID][hHousePrice]);
				    }

				    houseVariables[houseID][hLabelID] = CreateDynamic3DTextLabel(labelString, COLOR_YELLOW, houseVariables[houseID][hHouseExteriorPos][0], houseVariables[houseID][hHouseExteriorPos][1], houseVariables[houseID][hHouseExteriorPos][2], 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 10.0);
					houseVariables[houseID][hPickupID] = CreateDynamicPickup(1273, 23, houseVariables[houseID][hHouseExteriorPos][0], houseVariables[houseID][hHouseExteriorPos][1], houseVariables[houseID][hHouseExteriorPos][2], 0, houseVariables[houseID][hHouseExteriorID], -1, 250);

				}
				else {
				    new
				        labelString[96];

				    if(houseVariables[houseID][hHouseLocked] == 1) {
				    	format(labelString, sizeof(labelString), "House %d (owned)\nOwner: %s\n\n(locked)", houseID, houseVariables[houseID][hHouseOwner]);
				    }
				    else {
				        format(labelString, sizeof(labelString), "House %d (owned)\nOwner: %s\n\nPress ~k~~PED_DUCK~ to enter.", houseID, houseVariables[houseID][hHouseOwner]);
				    }

				    houseVariables[houseID][hLabelID] = CreateDynamic3DTextLabel(labelString, COLOR_YELLOW, houseVariables[houseID][hHouseExteriorPos][0], houseVariables[houseID][hHouseExteriorPos][1], houseVariables[houseID][hHouseExteriorPos][2], 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 10.0);
				    houseVariables[houseID][hPickupID] = CreateDynamicPickup(1272, 23, houseVariables[houseID][hHouseExteriorPos][0], houseVariables[houseID][hHouseExteriorPos][1], houseVariables[houseID][hHouseExteriorPos][2], 0, houseVariables[houseID][hHouseExteriorID], -1, 50);
				}

				SendClientMessage(playerid, COLOR_WHITE, "The house exterior has successfully been changed.");
			}
			else if(strcmp(subject, "interior", true) == 0) {
			    GetPlayerPos(playerid, houseVariables[houseID][hHouseInteriorPos][0], houseVariables[houseID][hHouseInteriorPos][1], houseVariables[houseID][hHouseInteriorPos][2]);
			    houseVariables[houseID][hHouseInteriorID] = GetPlayerInterior(playerid);
			    SendClientMessage(playerid, COLOR_WHITE, "The house interior has successfully been changed.");
			}

			saveHouse(houseID);
		}
	}

	return 1;
}

CMD:gotohouse(playerid, params[]) {
	if(playerVariables[playerid][pAdminLevel] >= 3) {

		if(isnull(params)) return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/gotohouse [houseid]");
	    new
	        houseID = strval(params);

		if(houseID < 1 || houseID > MAX_HOUSES) return SendClientMessage(playerid, COLOR_GREY, "Invalid house ID.");

		SetPlayerPos(playerid, houseVariables[houseID][hHouseExteriorPos][0], houseVariables[houseID][hHouseExteriorPos][1], houseVariables[houseID][hHouseExteriorPos][2]);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);

	}
	return 1;
}

CMD:gotobusiness(playerid, params[]) {
	if(playerVariables[playerid][pAdminLevel] >= 3) {

		if(isnull(params)) return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/gotobusiness [businessid]");
	    new
	        houseID = strval(params);

		if(houseID < 1 || houseID > MAX_BUSINESSES) return SendClientMessage(playerid, COLOR_GREY, "Invalid business ID.");

		SetPlayerPos(playerid, businessVariables[houseID][bExteriorPos][0],businessVariables[houseID][bExteriorPos][1], businessVariables[houseID][bExteriorPos][2]);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);

	}
	return 1;
}

CMD:fish(playerid, params[]) {
	if(playerVariables[playerid][pJob] == 4 && IsPlayerInAnyVehicle(playerid) && playerVariables[playerid][pFishing] == 0) {
		if(playerVariables[playerid][pJobDelay] > 0) {

			new
				string[57];

			format(string, sizeof(string), "You must wait %d minutes (%d seconds) until you can go fishing again.", playerVariables[playerid][pJobDelay] / 60, playerVariables[playerid][pJobDelay]);
			return SendClientMessage(playerid, COLOR_GREY, string);
		}
		else if(IsABoat(GetPlayerVehicleID(playerid))) {
            playerVariables[playerid][pFishing] = 1;
			/*playerVariables[playerid][pFishingBar] = CreateProgressBar(258.00, 137.00, 131.50, 3.19, COLOR_LIGHT, 100.0); // There's a bug people have noticed which I've not been able to fix; other players often see the textdraws when people are fishing
			ShowProgressBarForPlayer(playerid, playerVariables[playerid][pFishingBar]);*/
			SendClientMessage(playerid, COLOR_WHITE, "You're now fishing. It will take a few seconds to reel your fish in.");
		}
		else SendClientMessage(playerid, COLOR_GREY, "This vehicle cannot be used for fishing.");
    } else {
		SendClientMessage(playerid, COLOR_GREY, "You're required to be in a boat, have the fisherman's job and not to actively be fishing.");
	}
	return 1;
}

CMD:gotopoint(playerid, params[]) {
	if(playerVariables[playerid][pAdminLevel] >= 3) {
	    new
	        interiorID,
	        Float: coordinates[3];

		if(sscanf(params, "fffd", coordinates[0], coordinates[1], coordinates[2], interiorID)) {
		    SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/gotopoint [x] [y] [z] [interior id]");
		}
		else {
		    SetPlayerInterior(playerid, interiorID);
		    SetPlayerPos(playerid, coordinates[0], coordinates[1], coordinates[2]);
		}
	}

	return 1;
}

CMD:connections(playerid, params[]) {
	format(szQueryOutput, sizeof(szQueryOutput), "SELECT playeraccounts.playerName, playerconnections.conTS FROM playerconnections INNER JOIN playeraccounts ON playerconnections.conPlayerID = playeraccounts.playerID WHERE playeraccounts.playerID = '%d' LIMIT 5", playerVariables[playerid][pInternalID]);
	mysql_query(szQueryOutput, THREAD_LAST_CONNECTIONS, playerid);
	return 1;
}

CMD:reports(playerid, params[]) {
	if(playerVariables[playerid][pAdminLevel] >= 1) {
		new
			tool[16]; 

		if(sscanf(params, "s[16] ", tool)) {
		    SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/reports [tool]");
		    SendClientMessage(playerid, COLOR_GREY, "Tools: List, Accept, Disregard, Status");
		}
		else {
		    if(strcmp(tool, "List", true) == 0) {
				SendClientMessage(playerid, COLOR_WHITE, "-------------------------------------------------------------------------------------------------------------------------------");

		        new
					string[128],
					reportCount;

		        foreach(Player, i) {
		            if(playerVariables[i][pReport] >= 1) {
		                GetPlayerName(i, szPlayerName, MAX_PLAYER_NAME);
		                format(string, sizeof(string), "[ACTIVE] %s [%d] has reported: %s", szPlayerName, i, playerVariables[i][pReportMessage]);
		                SendClientMessage(playerid, COLOR_YELLOW, string);
		                reportCount++;
		            }
		        }

		        format(string, sizeof(string), "ACTIVE REPORTS: %d.", reportCount);
		        SendClientMessage(playerid, COLOR_WHITE, string);

				SendClientMessage(playerid, COLOR_WHITE, "-------------------------------------------------------------------------------------------------------------------------------");
		    }
		    else if(strcmp(tool, "Accept", true) == 0)
		    {
		        new
					userID;

		        if(sscanf(params, "s[16]u", tool, userID)) {
		            SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/reports accept [playerid]");
		        }
				else if(playerVariables[userID][pStatus] != 1)
		        {
					SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");
		        }
		        else if(playerVariables[userID][pReport] == 0)
		        {
					SendClientMessage(playerid, COLOR_GREY, "That player doesn't have an active report.");
				}
				else
				{
					new
						string[128];

					GetPlayerName(userID, szPlayerName, MAX_PLAYER_NAME);

		            format(string, sizeof(string), "You have accepted %s's report (%s)", szPlayerName, playerVariables[userID][pReportMessage]);
		            SendClientMessage(playerid, COLOR_WHITE, string);

		            playerVariables[userID][pReport] = 0;
					
		            GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);

		            format(string, sizeof(string), "Thank you for your report! Administrator %s is now reviewing your report.", szPlayerName);
		            SendClientMessage(userID, COLOR_YELLOW, string);

		            SetPVarInt(playerid, "aR", 1);
		            SetPVarInt(playerid, "aRf", userID);
					
					ShowPlayerDialog(playerid, DIALOG_REPORT, DIALOG_STYLE_LIST, "Report System", "Teleport\nSpectate\nTake no action", "Select", "Exit");
		        }
		    }
		    else if(strcmp(tool, "Disregard", true) == 0) {
		        new
					userID,
					string[128];

		        if(sscanf(params, "s[16]u", tool, userID)) {
		            SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/reports disregard [playerid]");
		        }
				else if(playerVariables[userID][pStatus] != 1)
		        {
					SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");
		        }
				else if(playerVariables[userID][pReport] == 0)
		        {
					SendClientMessage(playerid, COLOR_GREY, "That player doesn't have an active report.");
				}
		        else 
				{
					GetPlayerName(userID, szPlayerName, MAX_PLAYER_NAME);

		            playerVariables[userID][pReport] = 0;

		            format(string, sizeof(string), "You have disregarded %s's report.", szPlayerName);
		            SendClientMessage(playerid, COLOR_WHITE, string);
		        }
		    }
		    else if(strcmp(tool, "Status", true) == 0) {
		        if(playerVariables[playerid][pAdminLevel] >= 4) {
			        if(systemVariables[reportSystem] == 0) {
			            systemVariables[reportSystem] = 1;
			            SendClientMessage(playerid, COLOR_WHITE, "You have disabled the report system.");
			            SendClientMessageToAll(COLOR_YELLOW, "The report system has been temporarily disabled.");
			        }
			        else {
			            systemVariables[reportSystem] = 0;
			            SendClientMessage(playerid, COLOR_WHITE, "You have enabled the report system.");
			            SendClientMessageToAll(COLOR_YELLOW, "The report system has been re-enabled.");
			        }
		        }
		        else {
					return SendClientMessage(playerid, COLOR_GREY, "You need to be a Head Administrator or above to use this command.");
				}
 		    }
		    else {
			    SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/reports [tool]");
			    SendClientMessage(playerid, COLOR_GREY, "TOOLS: List, Accept, Disregard, Status");
		    }
		}
	}

	return 1;
}

CMD:announce(playerid, params[]) {
    if(playerVariables[playerid][pAdminLevel] >= 1) {
        if(!isnull(params)) {
			GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
			format(szMessage, sizeof(szMessage), "(( Announcement from %s: %s ))", szPlayerName, params);
			SendClientMessageToAll(COLOR_LIGHTRED, szMessage);
		}
		else {
		    return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/announce [text]");
		}
	}
	return 1;
}

CMD:o(playerid, params[]) {
	return cmd_ooc(playerid, params);
}

CMD:ooc(playerid, params[]) {
    if(systemVariables[OOCStatus] == 1)
		return SendClientMessage(playerid, COLOR_GREY, "The OOC chat channel is currently disabled.");

	if(playerVariables[playerid][pOOCMuted] == 1)
		return SendClientMessage(playerid, COLOR_GREY, "You have been muted from the OOC chat channel.");

    if(!isnull(params)) {
    	new
			playerName2[MAX_PLAYER_NAME];

	    GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);

	    format(szMessage, sizeof(szMessage), "(( %s says: %s ))", szPlayerName, params);

		foreach(Player, x) {
			if(playerVariables[x][pSeeOOC] == 1) {
			    GetPlayerName(x, playerName2, MAX_PLAYER_NAME);
			    if(strfind(szMessage, playerName2, true) == -1) {
			        format(szMessage, sizeof(szMessage), "(( %s says: %s ))", szPlayerName, params);
	  				SendClientMessage(x, COLOR_LIGHT, szMessage);
  				} else {
  				    if(strfind(playerName2, szPlayerName, true) != -1) {
				        format(szMessage, sizeof(szMessage), "(( %s says: %s ))", szPlayerName, params);
		  				SendClientMessage(x, COLOR_LIGHT, szMessage);
  				    } else {
						format(szMessage, sizeof(szMessage), "(( %s says: "EMBED_LIGHTRED"%s "EMBED_OOC"))", szPlayerName, params);
		  				SendClientMessage(x, COLOR_LIGHT, szMessage);
		  				PlayerPlaySound(x, 1057, 0, 0, 0);
	  				}
  				}
			}
		} 
		return 1;
	}
	else
		return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/(o)oc [message]");
}

CMD:seeooc(playerid, params[]) 
{
    if(playerVariables[playerid][pStatus] == 1) 
	{
		if(playerVariables[playerid][pSeeOOC] == 1) {
		    playerVariables[playerid][pSeeOOC] = 0;
		    SendClientMessage(playerid, COLOR_WHITE, "You will no longer see any chat submitted to the public OOC channel.");
		}
		else {
		    playerVariables[playerid][pSeeOOC] = 1;
		    SendClientMessage(playerid, COLOR_WHITE, "You will now see any chat submitted to the public OOC channel.");
		}
	}
	return 1;
}

CMD:disableooc(playerid, params[]) 
{
    if(playerVariables[playerid][pAdminLevel] >= 2) 
	{
        if(systemVariables[OOCStatus] == 0) 
		{
		    systemVariables[OOCStatus] = 1;
		    SendClientMessageToAll(COLOR_LIGHTRED, "The OOC chat channel has been disabled.");
        }
        else 
		{
			SendClientMessage(playerid, COLOR_GREY, "OOC is already disbled.");
		}
    }
	return 1;
}

CMD:enableooc(playerid, params[]) 
{
    if(playerVariables[playerid][pAdminLevel] >= 2) 
	{
        if(systemVariables[OOCStatus] == 1) 
		{
		    systemVariables[OOCStatus] = 0;
		    SendClientMessageToAll(COLOR_LIGHTRED, "The OOC chat channel has been enabled.");
        }
        else 
		{
			SendClientMessage(playerid, COLOR_GREY, "OOC is already enabled.");
		}
    }
	return 1;
}

CMD:namechanges(playerid, params[]) {
    if(playerVariables[playerid][pAdminLevel] >= 1) {
        if(sscanf(params, "u", iTarget))
            return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/namechanges [playerid]");

		if(iTarget == INVALID_PLAYER_ID || playerVariables[playerid][pStatus] < 1)
		    return SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");

		format(szQueryOutput, sizeof(szQueryOutput), "SELECT namechangeid, oldname, newname, time FROM namechanges WHERE userid = %d ORDER BY namechangeid ASC", playerVariables[iTarget][pInternalID]);
		mysql_query(szQueryOutput, THREAD_CHECK_PLAYER_NAMES, playerid);
    }
	return 1;
}

CMD:changename(playerid, params[]) 
{
	if(playerVariables[playerid][pAdminLevel] >= 4) 
	{
		new
			newName[MAX_PLAYER_NAME];

		if(sscanf(params, "us[24]", iTarget, newName)) 
		{
			SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/changename [playerid] [newname]");
		}
		else if(playerVariables[iTarget][pStatus] != 1)
		{
			SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");
		}
		else 
		{
			if(getPlayerBusinessID(iTarget) >= 1)
				strcpy(businessVariables[getPlayerBusinessID(iTarget)][bOwner], newName, MAX_PLAYER_NAME);

			if(getPlayerHouseID(iTarget) >= 1)
				strcpy(houseVariables[getPlayerHouseID(iTarget)][hHouseOwner], newName, MAX_PLAYER_NAME);

			new
				playerName[2][MAX_PLAYER_NAME],
				querySz[150];

			format(querySz, sizeof(querySz), "SELECT playerName FROM playeraccounts WHERE playerName = '%s'", newName);
			mysql_query(querySz);
			mysql_store_result();

			if(mysql_num_rows() > 0) {
			    SendClientMessage(playerid, COLOR_GREY, "That name is already taken.");
			    mysql_free_result();
			    return 1;
			}

			mysql_real_escape_string(newName, newName);

			GetPlayerName(playerid, playerName[0], MAX_PLAYER_NAME);
			GetPlayerName(iTarget, playerName[1], MAX_PLAYER_NAME);

			format(querySz, sizeof(querySz), "UPDATE playeraccounts SET playerName = '%s' WHERE playerID = '%d'", newName, playerVariables[iTarget][pInternalID]);
			mysql_query(querySz); // No point in threading a simple response...

			format(querySz, sizeof(querySz), "INSERT INTO namechanges (userid, oldname, newname, adminid) VALUES(%d, '%s', '%s', %d)", playerVariables[iTarget][pInternalID], playerName[1], newName, playerVariables[playerid][pInternalID]);
			mysql_query(querySz);

			format(querySz, sizeof(querySz), "Administrator %s has changed your name to %s.", playerName[0], newName); // Might as well re-use the string...
			SendClientMessage(iTarget, COLOR_WHITE, querySz);

			format(querySz, sizeof(querySz), "You have changed %s (ID: %d)'s name to %s.", playerName[1], iTarget, newName);
			SendClientMessage(playerid, COLOR_WHITE, querySz);

			SetPlayerName(iTarget, newName);

			strcpy(playerVariables[iTarget][pNormalName], newName, MAX_PLAYER_NAME);
		}
	}
	return 1;
}

CMD:ahelp(playerid, params[]) {
	if(playerVariables[playerid][pAdminLevel] >= 1) {
        SendClientMessage(playerid, COLOR_TEAL, "--------------------------------------------------------------------------------------------------------------------------------");

	    SendClientMessage(playerid, COLOR_WHITE, "Level 1: /ban, /kick, /check, /reports, /announce, /warn, /listgroups, /a, /adminduty, /vrespawn, /fixcar, /flipvehicle");
		SendClientMessage(playerid, COLOR_WHITE, "Level 1: /go, /get, /goto, /spec, /slap, /listguns, /gotoplayervehicle, /serverstats, /closestcar, /namechanges, /getvehicle");

	    if(playerVariables[playerid][pAdminLevel] >= 2) {
	        SendClientMessage(playerid, COLOR_GREY, "Level 2: /enableooc, /disableooc, /prison, /jail, /release, /mute, /omute, /fine, /unfreeze, /freeze, /forcelogout");
	    }

	    if(playerVariables[playerid][pAdminLevel] >= 3) {
	        SendClientMessage(playerid, COLOR_WHITE, "Level 3: /unban, /unbanip, /veh, /despawnavehicles, /spawnweapon, /gotopoint, /setleader, /movehouse, /asellhouse");
	        SendClientMessage(playerid, COLOR_WHITE, "Level 3: /set, /hprice, /bprice, /vehname, /gunname, /explode, /gotohouse, /gotobusiness");
			SendClientMessage(playerid, COLOR_WHITE, "Level 3: /eventproperties, /startevent, /endevent, /setplayervehicle, /setweather, /vdespawn");
	    }

	    if(playerVariables[playerid][pAdminLevel] >= 4) {
	        SendClientMessage(playerid, COLOR_GREY, "Level 4: /setadminname, /createhouse, /createbusiness, /btype, /gtype");
			SendClientMessage(playerid, COLOR_GREY, "Level 4: /savevehicle, /vgroup, /vcolour, /vmove, /vmodel, /vmassrespawn, /changename");
	    }

	    if(playerVariables[playerid][pAdminLevel] >= 5) {
	        SendClientMessage(playerid, COLOR_WHITE, "Level 5: /savedata, /gmx, /sethelper, /listassets, /setnewbiespawn, /setadminlevel");
	    }

		SendClientMessage(playerid, COLOR_TEAL, "--------------------------------------------------------------------------------------------------------------------------------");
	}

	return 1;
}

CMD:ah(playerid, params[]) {
	return cmd_ahelp(playerid, params);
}

CMD:jail(playerid, params[]) 
{
    if(playerVariables[playerid][pAdminLevel] >= 2) 
	{
        new
            minutes,
            userID,
            reason[64];

        if(sscanf(params, "uds[64]", userID, minutes, reason)) 
		{
			SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/jail [playerid] [minutes] [reason]");
		}
		else if(playerVariables[playerid][pStatus] != 1)
		{
			SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");
		}
		else 
		{
			if(minutes == 0) 
			{
	            GetPlayerName(userID, szPlayerName, MAX_PLAYER_NAME);

	            format(szMessage, sizeof(szMessage), "Release: %s has been released from prison by %s, reason: %s", szPlayerName, playerVariables[playerid][pAdminName], reason);
	            SendClientMessageToAll(COLOR_LIGHTRED, szMessage);

	            playerVariables[userID][pPrisonID] = 0;
	            playerVariables[userID][pPrisonTime] = 0;

	            SendClientMessage(userID, COLOR_WHITE, "Your time is up! You have been released from jail/prison.");
				SetPlayerPos(userID, 738.9963, -1417.2211, 13.5234);
				SetPlayerInterior(userID, 0);
				SetPlayerVirtualWorld(userID, 0);
			}

			if(playerVariables[playerid][pAdminLevel] >= playerVariables[userID][pAdminLevel])
			{
				GetPlayerName(userID, szPlayerName, MAX_PLAYER_NAME);
			    format(szMessage, sizeof(szMessage), "Jail: %s has been jailed by %s, reason: %s (%d minutes).", szPlayerName, playerVariables[playerid][pAdminName], reason, minutes);
				SendClientMessageToAll(COLOR_LIGHTRED, szMessage);

				playerVariables[userID][pPrisonTime] = minutes * 60;
				playerVariables[userID][pPrisonID] = 2;

				SetPlayerPos(userID, 264.58, 77.38, 1001.04);
				SetPlayerInterior(userID, 6);
				SetPlayerVirtualWorld(userID, 0);
			}
			else 
			{
				SendClientMessage(playerid, COLOR_GREY, "You can't jail a higher level administrator.");
			}
		}
	}
	return 1;
}

CMD:release(playerid, params[]) {
    if(playerVariables[playerid][pAdminLevel] >= 2) {
        new
            reason[64],
            targetid;

        if(sscanf(params, "us[64]", targetid, reason))
		{
            SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/release [playerid] [reason]");
        }
		else if(playerVariables[targetid][pStatus] != 1)
        {
			SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");
		}
		else
		{
            GetPlayerName(targetid, szPlayerName, MAX_PLAYER_NAME);

            format(szMessage, sizeof(szMessage), "Release: %s has been released from prison by %s, reason: %s", szPlayerName, playerVariables[playerid][pAdminName], reason);
            SendClientMessageToAll(COLOR_LIGHTRED, szMessage);

            playerVariables[targetid][pPrisonID] = 0;
            playerVariables[targetid][pPrisonTime] = 0;

            SendClientMessage(targetid, COLOR_WHITE, "Your time is up! You have been released from jail/prison.");
			SetPlayerPos(targetid, 738.9963, -1417.2211, 13.5234);
			SetPlayerInterior(targetid, 0);
			SetPlayerVirtualWorld(targetid, 0);

			return 1;
		}
	}
	return 1;
}

CMD:prison(playerid, params[]) {
    if(playerVariables[playerid][pAdminLevel] >= 2) {
        new
            minutes,
            userID,
            reason[64];

        if(sscanf(params, "uds[64]", userID, minutes, reason)) {
			return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/prison [playerid] [minutes] [reason]");
		}
		else {
			if(!IsPlayerConnected(userID)) return SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");
			
			if(minutes == 0) {
	            GetPlayerName(userID, szPlayerName, MAX_PLAYER_NAME);

	            format(szMessage, sizeof(szMessage), "Release: %s has been released from prison by %s, reason: %s", szPlayerName, playerVariables[playerid][pAdminName], reason);
	            SendClientMessageToAll(COLOR_LIGHTRED, szMessage);

	            playerVariables[userID][pPrisonID] = 0;
	            playerVariables[userID][pPrisonTime] = 0;

	            SendClientMessage(userID, COLOR_WHITE, "Your time is up! You have been released from jail/prison.");
				SetPlayerPos(userID, 738.9963, -1417.2211, 13.5234);
				SetPlayerInterior(userID, 0);
				SetPlayerVirtualWorld(userID, 0);
			}
			
			if(playerVariables[playerid][pAdminLevel] >= playerVariables[userID][pAdminLevel]) {
				GetPlayerName(userID, szPlayerName, MAX_PLAYER_NAME);
			    format(szMessage, sizeof(szMessage), "Prison: %s has been prisoned by %s, reason: %s (%d minutes).", szPlayerName, playerVariables[playerid][pAdminName], reason, minutes);
				SendClientMessageToAll(COLOR_LIGHTRED, szMessage);

				playerVariables[userID][pPrisonTime] = minutes*60;
				playerVariables[userID][pPrisonID] = 1;

				SetPlayerPos(userID, -26.8721, 2320.9290, 24.3034);
				SetPlayerInterior(userID, 0);
				SetPlayerVirtualWorld(userID, 0);
			}
			else {
				return SendClientMessage(playerid, COLOR_GREY, "You can't prison a higher level administrator.");
			}
		}
	}
	return 1;
}

CMD:lockbusiness(playerid, params[]) {
	if(getPlayerBusinessID(playerid) >= 1) {
	    new
	        x = getPlayerBusinessID(playerid);

	    switch(businessVariables[x][bLocked]) {
			case 0: {
				format(result, sizeof(result), "%s\n(Business %d - owned by %s)\n\n(locked)", businessVariables[x][bName], x, businessVariables[x][bOwner]);

				businessVariables[x][bLocked] = 1;
				SendClientMessage(playerid, COLOR_WHITE, "Business locked.");
			}
			case 1: {
				format(result, sizeof(result), "%s\n(Business %d - owned by %s)\n\nPress ~k~~PED_DUCK~ to enter", businessVariables[x][bName], x, businessVariables[x][bOwner]);

			    businessVariables[x][bLocked] = 0;
			    SendClientMessage(playerid, COLOR_WHITE, "Business unlocked.");
			}
		}
		UpdateDynamic3DTextLabelText(businessVariables[x][bLabelID], COLOR_YELLOW, result);
	}

	return 1;
}

CMD:number(playerid, params[]) {
	if(playerVariables[playerid][pPhoneBook] >= 1) {
	    new
	        userID;

		if(sscanf(params, "u", userID)) {
		    return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/number [playerid]");
		}
		else {
		    if(!IsPlayerConnected(userID)) {
		        return SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");
		    }
		    else {
				GetPlayerName(userID, szPlayerName, MAX_PLAYER_NAME);

				if(playerVariables[userID][pPhoneNumber] == -1) {
				    format(szMessage, sizeof(szMessage), "Name: "EMBED_GREY"%s{FFFFFF} | Number: "EMBED_GREY"None", szPlayerName);
				    SendClientMessage(playerid, COLOR_WHITE, szMessage);
				}
				else {
					format(szMessage, sizeof(szMessage), "Name: "EMBED_GREY"%s{FFFFFF} | Number: "EMBED_GREY"%d", szPlayerName, playerVariables[userID][pPhoneNumber]);
					SendClientMessage(playerid, COLOR_WHITE, szMessage);
				}
			}
		}
	}
	else SendClientMessage(playerid, COLOR_GREY, "You don't have a phonebook.");
	return 1;
}

CMD:slap(playerid,params[])
{
	if(playerVariables[playerid][pAdminLevel] >= 1) 
	{
	    new
	        userID;

		if(sscanf(params, "u", userID))
			SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/slap [playerid]");
		else if(playerVariables[userID][pStatus] != 1)
			SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");
	    else if(playerVariables[playerid][pAdminLevel] >= playerVariables[userID][pAdminLevel]) 
		{
            new
                string[64],

                Float: playerHealth,
                Float: fPos[3];

            GetPlayerName(userID, szPlayerName, MAX_PLAYER_NAME);

			GetPlayerPos(userID, fPos[0], fPos[1], fPos[2]);
			PlayerPlaySoundEx(1190, fPos[0], fPos[1], fPos[2]);
			SetPlayerPos(userID, fPos[0], fPos[1], fPos[2]+5);

			GetPlayerHealth(userID, playerHealth);
	    	SetPlayerHealth(userID, playerHealth-5);

		    format(string, sizeof(string), "You have slapped %s.", szPlayerName);
		    SendClientMessage(playerid, COLOR_WHITE, string);
		}
	}
	return 1;
}

CMD:help(playerid, params[]) {
	return showHelp(playerid);
}

CMD:check(playerid,params[]) {
	if(playerVariables[playerid][pAdminLevel] >= 1) {

	    new
	        targetid;

		if(sscanf(params, "u", targetid))
			return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/check [playerid]");

		if(playerVariables[targetid][pStatus] != 1)
			return SendClientMessage(playerid, COLOR_GREY, "The specified player ID is either not connected or has not authenticated.");

		if(playerVariables[playerid][pAdminLevel] < playerVariables[targetid][pAdminLevel])
			return SendClientMessage(playerid, COLOR_GREY, "You can't check a higher level administrator.");

		showStats(playerid, targetid);
	}
	return 1;
}

CMD:statistics(playerid, params[]) {
	return showStats(playerid,playerid);
}

CMD:gtype(playerid, params[]) {
	if(playerVariables[playerid][pAdminLevel] >= 4) {
	    new
	        groupID,
	        groupType;

        if(sscanf(params, "dd", groupID, groupType))
			return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/gtype [groupid] [grouptypeid]");

		if(groupID > 0 && groupID < MAX_GROUPS) {
            format(szMessage, sizeof(szMessage), "You have set group %s's group type to %d.", groupVariables[groupID][gGroupName], groupType);
            SendClientMessage(playerid, COLOR_WHITE, szMessage);

            groupVariables[groupID][gGroupType] = groupType;
  		} else return SendClientMessage(playerid, COLOR_GREY, "Invalid Group ID!");
	}
	return 1;
}

CMD:quitgroup(playerid, params[]) {
	if(playerVariables[playerid][pGroup] != 0) {
		format(szMessage, sizeof(szMessage), "%s has left the group (quit).", szPlayerName);
	   	SendToGroup(playerVariables[playerid][pGroup], COLOR_GENANNOUNCE, szMessage);
	   	format(szMessage,sizeof(szMessage), "You have left the %s.",groupVariables[playerVariables[playerid][pGroup]][gGroupName]);
	   	SendClientMessage(playerid,COLOR_WHITE,szMessage);
	   	playerVariables[playerid][pGroup] = 0;
	   	playerVariables[playerid][pGroupRank] = 0;
   	}
   	else return SendClientMessage(playerid, COLOR_WHITE, "You don't have a group to quit.");
	return 1;
}

CMD:veh(playerid, params[]) {
    if(playerVariables[playerid][pAdminLevel] >= 3) {
        if(!isnull(params)) {

			new
				carid = strval(params),
				Float: carSpawnPos[4], // 3 for the usual dimensions, +1 for the rotation/angle.
				messageString[64];

			if(carid < 400 || carid > 611)
				return SendClientMessage(playerid, COLOR_WHITE, "Valid car IDs start at 400, and end at 611.");

			if(systemVariables[vehicleCounts][0] + systemVariables[vehicleCounts][1] + systemVariables[vehicleCounts][2] < MAX_VEHICLES) {
				GetPlayerPos(playerid, carSpawnPos[0], carSpawnPos[1], carSpawnPos[2]);
				GetPlayerFacingAngle(playerid, carSpawnPos[3]);

				AdminSpawnedVehicles[vehCount] = CreateVehicle(carid, carSpawnPos[0], carSpawnPos[1], carSpawnPos[2], carSpawnPos[3], -1, -1, -1);
				systemVariables[vehicleCounts][2]++;

				LinkVehicleToInterior(AdminSpawnedVehicles[vehCount], GetPlayerInterior(playerid));
				SetVehicleVirtualWorld(AdminSpawnedVehicles[vehCount], GetPlayerVirtualWorld(playerid));

				PutPlayerInVehicle(playerid, AdminSpawnedVehicles[vehCount], 0);

				switch(carid) {
					case 427, 428, 432, 601, 528: SetVehicleHealth(AdminSpawnedVehicles[vehCount], 5000.0);
				}

				format(messageString, sizeof(messageString), "You have spawned a %s (vehicle ID %d).", VehicleNames[carid - 400], AdminSpawnedVehicles[vehCount]);
				SendClientMessage(playerid, COLOR_WHITE, messageString);

				vehCount++;
			}
			else {
				SendClientMessage(playerid, COLOR_GREY, "(error) 01x08");
				printf("ERROR: Vehicle limit reached (MODEL %d, MAXIMUM %d, TYPE ADMIN) [01x08]", carid, MAX_VEHICLES);
			}
        }
        else {
            return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/veh [vehicleid]");
        }
    }
	return 1;
}

CMD:despawnavehicles(playerid, params[]) {
    if(playerVariables[playerid][pAdminLevel] >= 3) {
        new
			x;

        for(new i = 0; i < MAX_VEHICLES; i++) {
			if(AdminSpawnedVehicles[i] >= 1) {
			    DestroyVehicle(AdminSpawnedVehicles[i]);
			    AdminSpawnedVehicles[i] = 0;
			    x++;
				systemVariables[vehicleCounts][2]--;
			}
		}

		format(szMessage, sizeof(szMessage), "%d admin-spawned vehicles have been automatically destroyed.", x);
		SendClientMessage(playerid, COLOR_WHITE, szMessage);
    }
	return 1;
}

CMD:vdespawn(playerid, params[]) {
    if(playerVariables[playerid][pAdminLevel] >= 3) {

        for(new i = 0; i < MAX_VEHICLES; i++) {
			if(AdminSpawnedVehicles[i] == GetPlayerVehicleID(playerid)) {
				format(szMessage, sizeof(szMessage), "You have successfully despawned vehicle %d.", AdminSpawnedVehicles[i]);
				DestroyVehicle(AdminSpawnedVehicles[i]);
				AdminSpawnedVehicles[i] = 0;
				systemVariables[vehicleCounts][2]--;
				SendClientMessage(playerid, COLOR_WHITE, szMessage);
				return 1;
			}
		}
		SendClientMessage(playerid, COLOR_WHITE, "You are not in an admin spawned vehicle.");
    }
	return 1;
}

CMD:serverstats(playerid, params[]) {
	if(playerVariables[playerid][pAdminLevel] >= 1) {

	    new
			statString[128];

		SendClientMessage(playerid, COLOR_TEAL, "----------------------------------------------------------------------------");
        SendClientMessage(playerid, COLOR_WHITE, "System variables (current):");
        format(statString, sizeof(statString), "Objects: %d | Pickups: %d | 3D Text Labels: %d | Static vehicles: %d | Player vehicles: %d | Admin vehicles: %d", CountDynamicObjects(), CountDynamicPickups(), CountDynamic3DTextLabels(), systemVariables[vehicleCounts][0], systemVariables[vehicleCounts][1], systemVariables[vehicleCounts][2]);
		SendClientMessage(playerid, COLOR_WHITE, statString);
        format(statString, sizeof(statString), "Houses: %d | Businesses: %d | Total vehicle count: %d/%d | Weather: %d | Pending weather change: %d/%d", systemVariables[houseCount], systemVariables[businessCount], systemVariables[vehicleCounts][0] + systemVariables[vehicleCounts][1] + systemVariables[vehicleCounts][2], MAX_VEHICLES, weatherVariables[0], weatherVariables[1], MAX_WEATHER_POINTS);
		SendClientMessage(playerid, COLOR_WHITE, statString);
		SendClientMessage(playerid, COLOR_TEAL, "----------------------------------------------------------------------------");
	}
	return 1;
}

CMD:accent(playerid, params[]) {
	if(playerVariables[playerid][pStatus] >= 1) {
        if(!isnull(params)) {
            if(strlen(params) >= 19) {
                SendClientMessage(playerid, COLOR_GREY, "Invalid accent length. Accents can only consist of 1-19 characters.");
            }
            else {
				mysql_real_escape_string(params, playerVariables[playerid][pAccent]);

				format(szMessage, sizeof(szMessage), "You are now speaking in a '%s' accent.", params);
				SendClientMessage(playerid, COLOR_WHITE, szMessage);
			}
        }
        else {
            return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/accent [accent] ('none' to disable)");
        }
	}

	return 1;
}

CMD:stats(playerid, params[]) {
	return cmd_statistics(playerid, params);
}

CMD:buyhouse(playerid, params[]) {
    if(playerVariables[playerid][pStatus] >= 1) {
        for(new x = 0; x < MAX_HOUSES; x++) {
			if(IsPlayerInRangeOfPoint(playerid, 5, houseVariables[x][hHouseExteriorPos][0], houseVariables[x][hHouseExteriorPos][1], houseVariables[x][hHouseExteriorPos][2])) {
				if(!strcmp(houseVariables[x][hHouseOwner], "Nobody", true)) {
				    if(houseVariables[x][hHousePrice] == -1) return SendClientMessage(playerid, COLOR_GREY, "This house was blocked from being purchased by an administrator.");
					if(getPlayerHouseID(playerid) >= 1) return SendClientMessage(playerid, COLOR_GREY, "You can't own 2 houses.");
					if(playerVariables[playerid][pMoney] >= houseVariables[x][hHousePrice]) {
						playerVariables[playerid][pMoney] -= houseVariables[x][hHousePrice];

						new
						    labelString[96];

						strcpy(houseVariables[x][hHouseOwner], playerVariables[playerid][pNormalName], MAX_PLAYER_NAME);

						DestroyDynamicPickup(houseVariables[x][hPickupID]);
						DestroyDynamic3DTextLabel(houseVariables[x][hLabelID]);

					    if(houseVariables[x][hHouseLocked] == 1) {
					    	format(labelString, sizeof(labelString), "House %d (owned)\nOwner: %s\n\n(locked)", x, houseVariables[x][hHouseOwner]);
					    }
					    else {
					        format(labelString, sizeof(labelString), "House %d (owned)\nOwner: %s\n\nPress ~k~~PED_DUCK~ to enter.", x, houseVariables[x][hHouseOwner]);
					    }

					    houseVariables[x][hLabelID] = CreateDynamic3DTextLabel(labelString, COLOR_YELLOW, houseVariables[x][hHouseExteriorPos][0], houseVariables[x][hHouseExteriorPos][1], houseVariables[x][hHouseExteriorPos][2], 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 10.0);
					    houseVariables[x][hPickupID] = CreateDynamicPickup(1272, 23, houseVariables[x][hHouseExteriorPos][0], houseVariables[x][hHouseExteriorPos][1], houseVariables[x][hHouseExteriorPos][2], 0, houseVariables[x][hHouseExteriorID], -1, 50);

						SendClientMessage(playerid, COLOR_WHITE, "Congratulations on your purchase - you are now the proud owner of this house!");

						saveHouse(x);
					}
					else SendClientMessage(playerid, COLOR_GREY, "You don't have enough money to purchase this house.");
				}
				else {
					return SendClientMessage(playerid, COLOR_GREY, "You can't purchase an owned house.");
				}
			}
		}
    }
	return 1;
}

CMD:pay(playerid, params[]) {
	new
		id,
		cash,
		string[128],
		ip1[32],
		ip2[32],
		giveplayerName[MAX_PLAYER_NAME];

	if(sscanf(params, "ud", id, cash))
		return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/pay [playerid] [amount]");

	if(playerVariables[playerid][pMoney] >= cash) {
		if(id != playerid && IsPlayerAuthed(id)) {
			if(cash > 0 && ((playerVariables[playerid][pPlayingHours] < 10 && cash < 5000) || playerVariables[playerid][pPlayingHours] >= 10)) {
				if(playerVariables[playerid][pAdminDuty] != 0 && playerVariables[playerid][pAdminLevel] > 0 || (IsPlayerInRangeOfPlayer(playerid, id, 4.0) && playerVariables[id][pSpectating] == INVALID_PLAYER_ID)) {

					GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
					GetPlayerName(id, giveplayerName, MAX_PLAYER_NAME);

					playerVariables[playerid][pMoney] -= cash;
					playerVariables[id][pMoney] += cash;

					PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
					PlayerPlaySound(id, 1052, 0.0, 0.0, 0.0);

					format(string, sizeof(string), "You have paid $%d to %s.", cash, giveplayerName);
					SendClientMessage(playerid, COLOR_WHITE, string);

					format(string, sizeof(string), "* %s takes out $%d in cash, and hands it to %s.", szPlayerName, cash, giveplayerName);
					nearByMessage(playerid, COLOR_PURPLE, string);

					GetPlayerIp(playerid, ip1, 32);
					GetPlayerIp(id, ip2, 32);

					format(string, sizeof(string), "%s has paid you $%d.", szPlayerName, cash);
					SendClientMessage(id, COLOR_WHITE, string);

					if(playerVariables[playerid][pSpamCount] >= 3)
					{
						if(!strcmp(ip1, ip2,true))
						{
							format(string, sizeof(string), "Warning: {FFFFFF}%s has attempted to repeatedly pay $%d to %s (sharing IP address %s).", szPlayerName, cash, giveplayerName, ip1);
							submitToAdmins(string, COLOR_HOTORANGE);
						}
						else if(playerVariables[playerid][pPlayingHours] < 2) {
							format(string, sizeof(string), "Warning: {FFFFFF}%s has attempted to repeatedly pay $%d to %s (with less than two playing hours).", szPlayerName, cash, giveplayerName);
							submitToAdmins(string, COLOR_HOTORANGE);
						}
					}
				}
				else SendClientMessage(playerid, COLOR_GREY, "You're too far away from this person.");
			}
			else SendClientMessage(playerid, COLOR_GREY, "Invalid amount specified (too high, or too low).");
		}
		else SendClientMessage(playerid, COLOR_GREY, "Invalid player specified (either yourself, or not connected).");
	}
	return 1;
}

CMD:getjob(playerid, params[]) {
    if(playerVariables[playerid][pStatus] >= 1) {
		new string[72];
		if(playerVariables[playerid][pJob] < 1) {
			for(new h = 0; h < sizeof(jobVariables); h++) {
			    if(IsPlayerInRangeOfPoint(playerid, 5, jobVariables[h][jJobPosition][0], jobVariables[h][jJobPosition][1], jobVariables[h][jJobPosition][2])) {
			        format(string, sizeof(string), "Congratulations. You have now become a %s.", jobVariables[h][jJobName]);
			        SendClientMessage(playerid, COLOR_WHITE, string);
			        playerVariables[playerid][pJob] = h;
				}
			}
		}
		else {
		    SendClientMessage(playerid, COLOR_WHITE, "You already have a job (type /quitjob first).");
		}
	}
	return 1;
}

CMD:quitjob(playerid, params[]) {
    if(playerVariables[playerid][pStatus] >= 1) {
		new string[128];
		if(playerVariables[playerid][pJob] >= 1) {
		    format(string, sizeof(string), "You have quit your job (%s).", jobVariables[playerVariables[playerid][pJob]][jJobName]);
		    SendClientMessage(playerid, COLOR_WHITE, string);
		    playerVariables[playerid][pJob] = 0;
			playerVariables[playerid][pJobDelay] = 0;
		}
	}
	return 1;
}

CMD:mobile(playerid, params[]) {
    if(playerVariables[playerid][pPhoneNumber] == -1)
        return SendClientMessage(playerid, COLOR_GREY, "You do not have a mobile phone.");

    if(playerVariables[playerid][pPhoneStatus] != 1)
        return SendClientMessage(playerid, COLOR_GREY, "Your phone is not switched on.");

	ShowPlayerDialog(playerid, DIALOG_PHONE_MENU, DIALOG_STYLE_LIST, "Mobile Phone: Menu", "History\nContacts\nWidgets\nOrganiser\nMessaging\nApplications\nSettings", "Select", "Cancel");
	return 1;
}

CMD:sms(playerid, params[]) {
	new
	    number,
	    szQuery[256],
	    szClearMsg[94],
	    count,
	    message[94];

    if(sscanf(params, "ds[94]", number, message))
		return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/sms [number] [message]");

    if(number == -1)
		return SendClientMessage(playerid, COLOR_GREY, "Invalid number.");

    if(playerVariables[playerid][pPhoneStatus] != 1)
        return SendClientMessage(playerid, COLOR_GREY, "Your phone is not switched on.");

	if(playerVariables[playerid][pPhoneCredit] < 1)
		return SendClientMessage(playerid, COLOR_GREY, "You have no remaining phone credit - visit a 24/7 to top it up.");

    foreach(Player, x) {
		if(playerVariables[x][pPhoneNumber] == number) {
		    if(playerVariables[x][pPhoneStatus] == 1 && playerVariables[x][pPrisonID] != 3) {
		        GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);

		        format(szMessage, sizeof(szMessage), "SMS from %s (%d): %s", szPlayerName, playerVariables[playerid][pPhoneNumber], message);
		        SendClientMessage(x, COLOR_SMS, szMessage);

		        GetPlayerName(x, szPlayerName, MAX_PLAYER_NAME);

		        format(szMessage, sizeof(szMessage), "SMS sent to %s (%d): %s", szPlayerName, playerVariables[x][pPhoneNumber], message);
		        SendClientMessage(playerid, COLOR_SMS, szMessage);
				playerVariables[playerid][pPhoneCredit] -= 3;

				mysql_real_escape_string(message, szClearMsg);
				format(szQuery, sizeof(szQuery), "INSERT INTO `phonelogs` (`phoneNumber`, `phoneAction`) VALUES('%d', 'SMS to %s: %s')", playerVariables[playerid][pPhoneNumber], szPlayerName, message);
				mysql_query(szQuery);
		        return 1;
		    }
		    else {
				return SendClientMessage(playerid, COLOR_GREY, "The cellphone that you're trying to SMS is currently unavailable.");
			}
		}
		count++;
	}

	if(count < 1) return SendClientMessage(playerid, COLOR_GREY, "Invalid number.");
	return 1;
}

CMD:t(playerid, params[]) {
	return cmd_sms(playerid, params);
}

CMD:call(playerid, params[]) {
	new
		number,

		string[128];

 	if(isnull(params))
		return SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/call [number]");

 	number = strval(params);

	if(playerVariables[playerid][pPhoneNumber] == -1) {
		SendClientMessage(playerid, COLOR_GREY, "You don't have a phone.");
	}
	else if(playerVariables[playerid][pPhoneNumber] == number) {
		SendClientMessage(playerid, COLOR_GREY, "You're trying to call yourself.");
	}
	else {
		if(playerVariables[playerid][pPhoneStatus] == 1) {
			if(playerVariables[playerid][pPhoneCredit] >= 1) {
				if(playerVariables[playerid][pPhoneCall] == -1) {
					if(number == 911) {
						SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
						playerVariables[playerid][pPhoneCall] = 911;
						SendClientMessage(playerid, COLOR_WHITE, "You've called Emergency services, please select the department you desire (i.e: LSPD, LSFMD).");
					}
					else if(number != -1) {
						GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);
						format(string, sizeof(string), "* %s takes out their cellphone, and dials in a number.", szPlayerName, number);
						SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
						nearByMessage(playerid, COLOR_PURPLE, string);

						foreach(Player, i) {
							if(playerVariables[i][pPhoneNumber] == number)  {
								if(playerVariables[i][pStatus] == 1 && playerVariables[i][pSpectating] == INVALID_PLAYER_ID && playerVariables[i][pPhoneStatus] == 1 && playerVariables[i][pPhoneCall] == -1 && playerVariables[i][pPrisonID] != 3) {

									GetPlayerName(i, szPlayerName, MAX_PLAYER_NAME);
									format(string, sizeof(string), "* %s's cellphone starts to ring...", szPlayerName);
									nearByMessage(i, COLOR_PURPLE, string);
									SendClientMessage(i, COLOR_WHITE, "Use /p(ickup) to answer your phone.");

									SendClientMessage(playerid, COLOR_WHITE, "You can use the 'T' chat to proceed to talk.");
									playerVariables[playerid][pPhoneCall] = i;
									return 1;
								}
								else {
									SendClientMessage(playerid, COLOR_GREY, "(cellphone) *busy tone*");
									return 1;
								}
							}
						}
						if(playerVariables[playerid][pPhoneCall] == -1) SendClientMessage(playerid, COLOR_GREY, "(cellphone) *busy tone*");
					}
					else SendClientMessage(playerid, COLOR_GREY, "Invalid number.");
				}
				else SendClientMessage(playerid, COLOR_GREY, "You are currently in a call.");
			}
			else SendClientMessage(playerid, COLOR_GREY, "You have no remaining phone credit - visit a 24/7 to top it up.");
		}
		else SendClientMessage(playerid, COLOR_GREY, "You must switch your phone on first (/togphone).");
	}
	return 1;
}

CMD:p(playerid) return cmd_pickup(playerid);
CMD:pickup(playerid) 
{
	foreach(Player, i) 
	{
		// Setting the current-call var to the ID of the person calling.
		if(playerVariables[i][pPhoneCall] == playerid) 
		{
			playerVariables[playerid][pPhoneCall] = i;
			SendClientMessage(playerid, COLOR_WHITE, "You have answered your phone.");
			SendClientMessage(playerVariables[playerid][pPhoneCall], COLOR_WHITE, "The other person has answered the call.");
			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
		}
	}
	return 1;
}

CMD:togphone(playerid, params[]) 
{
	if(playerVariables[playerid][pPhoneNumber] == -1)
	{
		SendClientMessage(playerid, COLOR_GREY, "You don't have a phone.");
	}
	else if(playerVariables[playerid][pPhoneStatus] == 1)
	{
		playerVariables[playerid][pPhoneStatus] = 0;
		SendClientMessage(playerid, COLOR_WHITE, "Your phone is now switched off.");
	}
	else if(playerVariables[playerid][pPhoneStatus] == 0)
	{
		playerVariables[playerid][pPhoneStatus] = 1;
		SendClientMessage(playerid, COLOR_WHITE, "Your phone is now switched on.");
	}
	return 1;
}

CMD:h(playerid) return cmd_hangup(playerid);
CMD:hangup(playerid) 
{
	if(playerVariables[playerid][pPhoneCall] != -1)
		SendClientMessage(playerid, COLOR_WHITE, "You have terminated the current call.");

	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USECELLPHONE)
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);

	temp = playerVariables[playerid][pPhoneCall];
	if(-1 < temp < MAX_PLAYERS) // Valid values: 0 - MAX_PLAYERS (911 and such are used for special calls)
	{
		SendClientMessage(temp, COLOR_WHITE, "Your call has been terminated by the other party.");
		
		if(GetPlayerSpecialAction(temp) == SPECIAL_ACTION_USECELLPHONE)
			SetPlayerSpecialAction(temp, SPECIAL_ACTION_STOPUSECELLPHONE);
			
		playerVariables[temp][pPhoneCall] = -1;
	}
	
	playerVariables[playerid][pPhoneCall] = -1;
	return 1;
} 
CMD:abandoncar(playerid, params[]) {
	if(playerVariables[playerid][pCarModel] >= 1) {
		if(IsPlayerInRangeOfVehicle(playerid, playerVariables[playerid][pCarID], 5.0)) {
			DestroyPlayerVehicle(playerid);
			SendClientMessage(playerid, COLOR_GREY, "You have abandoned your vehicle.");

			if(playerVariables[playerid][pCheckpoint] == 4) {
				DisablePlayerCheckpoint(playerid);
				playerVariables[playerid][pCheckpoint] = 0;
			}
		}
		else SendClientMessage(playerid, COLOR_GREY, "You're too far away from your vehicle.");
	}
	return 1;
}

CMD:givecar(playerid, params[]) {
	if(sscanf(params, "u", iTarget))
		SendClientMessage(playerid, COLOR_GREY, SYNTAX_MESSAGE"/givecar [playerid]");
	else if(!IsPlayerAuthed(iTarget))
		SendClientMessage(playerid, COLOR_GREY, "The specified player is not connected, or has not authenticated.");
	else
	{
		if(playerVariables[playerid][pCarModel] >= 1) 
		{
			if(IsPlayerInRangeOfPlayer(playerid, iTarget, 5.0)) 
			{
				SetPVarInt(iTarget, "gC", playerid + 1);
				// The usual culprit - barely accessed, barely used. As PVars return 0 if they don't exist, adding +1 ensures they return a valid playerid.

				GetPlayerName(iTarget, szPlayerName, MAX_PLAYER_NAME);

				format(szMessage, sizeof(szMessage), "You have offered %s the keys to your %s.", szPlayerName, VehicleNames[playerVariables[playerid][pCarModel] - 400]);
				SendClientMessage(playerid, COLOR_WHITE, szMessage);

				GetPlayerName(playerid, szPlayerName, MAX_PLAYER_NAME);

				format(szMessage, sizeof(szMessage), "%s is offering you the keys to their %s (type /accept givecar).", szPlayerName, VehicleNames[playerVariables[playerid][pCarModel] - 400]);
				SendClientMessage(iTarget, COLOR_NICESKY, szMessage);
			}
			else SendClientMessage(playerid, COLOR_GREY, "You're too far away from that person.");
		}
		else SendClientMessage(playerid, COLOR_GREY, "You don't own a vehicle.");
	}
	return 1;
}

CMD:lockcar(playerid, params[]) {
	if(doesVehicleExist(playerVariables[playerid][pCarID]) && playerVariables[playerid][pCarModel] >= 1) {
		if(IsPlayerInRangeOfVehicle(playerid, playerVariables[playerid][pCarID], 10.0)) {

			GetVehiclePos(playerVariables[playerid][pCarID], playerVariables[playerid][pCarPos][0], playerVariables[playerid][pCarPos][1], playerVariables[playerid][pCarPos][2]);
			PlayerPlaySoundEx(1145, playerVariables[playerid][pCarPos][0], playerVariables[playerid][pCarPos][1], playerVariables[playerid][pCarPos][2]);

			switch(playerVariables[playerid][pCarLock]) {
				case 0: {
					playerVariables[playerid][pCarLock] = 1;
					SendClientMessage(playerid, COLOR_WHITE, "You have locked your vehicle.");

					foreach(Player, x) {
						SetVehicleParamsForPlayer(playerVariables[playerid][pCarID], x, 0, 1);
					}
				}
				default: {
					playerVariables[playerid][pCarLock] = 0;
					SendClientMessage(playerid, COLOR_WHITE, "You have unlocked your vehicle.");

					foreach(Player, x) {
						SetVehicleParamsForPlayer(playerVariables[playerid][pCarID], x, 0, 0);
					}
				}
			}
		}
		else SendClientMessage(playerid, COLOR_GREY, "You're too far away from your vehicle.");
	}
	else SendClientMessage(playerid, COLOR_GREY, "You don't own a vehicle.");
	return 1;
}

CMD:findcar(playerid, params[]) {
	if(playerVariables[playerid][pCarModel] >= 1) {
		if(playerVariables[playerid][pCheckpoint] == 0 && playerVariables[playerid][pCheckpoint] != 4) {
			GetVehiclePos(playerVariables[playerid][pCarID], playerVariables[playerid][pCarPos][0], playerVariables[playerid][pCarPos][1], playerVariables[playerid][pCarPos][2]);
			SetPlayerCheckpoint(playerid, playerVariables[playerid][pCarPos][0], playerVariables[playerid][pCarPos][1], playerVariables[playerid][pCarPos][2], 10.0);
			playerVariables[playerid][pCheckpoint] = 4;

			format(szMessage, sizeof(szMessage), "A checkpoint has been set to your %s.", VehicleNames[playerVariables[playerid][pCarModel] - 400]);
			SendClientMessage(playerid, COLOR_WHITE, szMessage);
		}
		else {
			format(szMessage, sizeof(szMessage), "You already have an active checkpoint (%s), reach it first, or /killcheckpoint.", getPlayerCheckpointReason(playerid));
			SendClientMessage(playerid, COLOR_GREY, szMessage);
		}
	}
	else SendClientMessage(playerid, COLOR_GREY, "You don't own a vehicle.");
	return 1;
}

CMD:unmodcar(playerid, params[]) {
	if(playerVariables[playerid][pCarModel] >= 1) {
		if(IsPlayerInRangeOfVehicle(playerid, playerVariables[playerid][pCarID], 5.0)) {

			new
				Float: vHealth,
				Damage[4];

			GetVehicleDamageStatus(playerVariables[playerid][pCarID], Damage[0], Damage[1], Damage[2], Damage[3]);
			GetVehiclePos(playerVariables[playerid][pCarID], playerVariables[playerid][pCarPos][0], playerVariables[playerid][pCarPos][1], playerVariables[playerid][pCarPos][2]);
			GetVehicleZAngle(playerVariables[playerid][pCarID], playerVariables[playerid][pCarPos][3]);
			GetVehicleHealth(playerVariables[playerid][pCarID], vHealth);

			for(new i = 0; i < 13; i++) {
				playerVariables[playerid][pCarMods][i] = 0;
			}

			playerVariables[playerid][pCarPaintjob] = -1;

			if(IsPlayerInVehicle(playerid, playerVariables[playerid][pCarID]) && GetPlayerState(playerid) == 2) {
				DestroyVehicle(playerVariables[playerid][pCarID]);
				systemVariables[vehicleCounts][1]--;
				playerVariables[playerid][pCarID] = -1;
				SpawnPlayerVehicle(playerid);
				PutPlayerInVehicle(playerid, playerVariables[playerid][pCarID], 0);
			}
			else {
				DestroyVehicle(playerVariables[playerid][pCarID]);
				playerVariables[playerid][pCarID] = -1;
				systemVariables[vehicleCounts][1]--;
				SpawnPlayerVehicle(playerid);
			}
			SetVehicleHealth(playerVariables[playerid][pCarID], vHealth);
			UpdateVehicleDamageStatus(playerVariables[playerid][pCarID], Damage[0], Damage[1], Damage[2], Damage[3]);
		}
		else SendClientMessage(playerid, COLOR_GREY, "You're too far away from your vehicle.");
	}
	else SendClientMessage(playerid, COLOR_GREY, "You don't own a vehicle.");
	return 1;
}
