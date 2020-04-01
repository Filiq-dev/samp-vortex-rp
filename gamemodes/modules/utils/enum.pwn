enum systemE {
	houseCount,
	businessCount,
	vehicleCounts[3],
	reportSystem,
	OOCStatus,
}

enum assetsE {
	aAssetName[32],
	aAssetValue,
}

enum connectionE {
	szDatabaseName[32],
	szDatabaseHostname[32],
	szDatabaseUsername[32],
	szDatabasePassword[64],
}

enum jobsE {
    jJobType,
    Float: jJobPosition[3],
    jJobName[32],
    jJobPickupID,
    Text3D:jJobLabelID,
}

enum atmE {
	Float: fATMPos[3],
	Float: fATMPosRot[3],
	rObjectId,
	Text3D: rTextLabel,
}

enum businessE {
	bType,
	bOwner[MAX_PLAYER_NAME],
	bName[32],
	Float: bExteriorPos[3],
	Float: bInteriorPos[3],
	bInterior,
	bLocked,
	Float: bMiscPos[3],
	bVault,
	Text3D: bLabelID,
	bPickupID,
	bPrice,
}

enum spikeE {
	sObjID,
	Float:sPos[4],
	sDeployer[MAX_PLAYER_NAME],
}

enum vehicleE {
	vVehicleModelID,
	Float: vVehiclePosition[3],
	Float: vVehicleRotation,
	vVehicleGroup,
	vVehicleColour[2],
	vVehicleScriptID,
}

enum houseE {
	Float: hHouseExteriorPos[3],
	Float: hHouseInteriorPos[3],
	hHouseInteriorID,
	hHouseLocked,
	hHouseExteriorID,
	hHousePrice,
	hPickupID,
	Text3D:hLabelID,
	hHouseOwner[MAX_PLAYER_NAME],
	hMoney,
	hWeapons[5],
	hWardrobe[5],
	hMaterials,
}

enum groupE {
	gGroupName[64],
	gGroupType,
	Float: gGroupExteriorPos[3],
	Float: gGroupInteriorPos[3],
	gGroupHQInteriorID,
	gGroupPickupID,
	Float: gSafePos[3],
	gSafePickupID,
	Text3D: gSafeLabelID,
	Text3D: gGroupLabelID,
	gGroupHQLockStatus,
	gSafe[2], // 0-1: Money, mats. pot, cocaine out for now
	gswatInv,
	gGroupMOTD[128],
	gGroupRankName1[32], // 4d arrays aren't supported in pawn, so I'll have to continue it like this...
	gGroupRankName2[32],
	gGroupRankName3[32],
	gGroupRankName4[32],
	gGroupRankName5[32],
	gGroupRankName6[32],
}

enum businessItemsE {
	bItemBusiness,
	bItemType,
	bItemName[32],
	bItemPrice,
}

enum playervEnum {
	Float: pHealth,
	Float: pArmour,
	Float: pPos[3],
	pPassword[129],
	pStatus, // -1: not connected | 0: connected, not authed | 1: connected, authed
	pAge,
	pMoney,
	pAdminLevel,
	pInterior,
	pLevel,
	pSkinSet,
	pCarID,
	pAnticheatExemption,
	pTabbed,
	pCarWeapons[5],
	pCarLicensePlate[32],
	pCarTrunk[2], // Cash & mats
	pPhoneCredit, // Will be done in seconds.
	pWalkieTalkie, // -1 = no walkie, 0 = switched off
	pSpectating,
	pSpecSession,
	pConnectedSeconds,
	pSpamCount,
	pFishing,
	pMuted,
	pVirtualWorld,
	pFish,
	pBanned,
	pTazer,
	pEvent,
	Float: pCarPos[4],
	pReport,
	pPrisonTime,
	pPrisonID, // 3 = IN CHARACTER JAIL! (future reference)
	pHackWarnTime,
	pHelperDuty,
	pReportMessage[64],
	pPlayingHours,
	pSkin,
	pJob,
	pRope,
	pAccent[40],
	pWarning1[32],
	pWarning2[32],
	pWarning3[32],
	pPhoneNumber,
	pSkinCount,
	pSeeOOC,
	pOOCMuted,
	pNewbieTimeout,
	pTutorial,
	pWeapons[13],
	pOutstandingWeaponRemovalSlot,
	pJetpack,
	pBankMoney,
	pHackWarnings,
	pEmail[255], // because this is the max length for a valid email.
	pSeconds,
	pFightStyle,
	pInternalID,
	pJobDelay,
	pGender,
	pNewbieEnabled,
	pFirstLogin,
	pAdminDuty,
	pHelper,
	pCarColour[2],
	pMatrunTime,
	pAdminName[MAX_PLAYER_NAME],
	pNormalName[MAX_PLAYER_NAME],
	pPhoneBook,
	pCheckpoint,
	pPMStatus,
	pOnRequest,
	Text3D: pAFKLabel,
	pGroup,
	pCarModel,
	pCarMods[13],
	pCarPaintjob,
	pCarLock,
	pVIP,
	pGroupRank,
	pDropCarTimeout,
	pMaterials,
	pJobSkill[2],
	pHospitalized,
	pFreezeTime, // Seconds. Set it to -1 if you want to permafreeze.
	pFreezeType, // 0 = not frozen (obviously), 1 = tazed, 2 = cuffed, 3 = admin frozen, 4 = tied
	pDrag,
	pAnimation,
	pPhoneStatus, // togged on/off
	pPhoneCall,
	pConnectionIP[32],
	pSeeWhisper,
	pCrimes,
	pArrests,
    pWarrants,
	pBackup,
}
