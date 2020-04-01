function Shits() {

    initiateConnections(); 
    
    scriptTimers[0] = SetTimer("globalPlayerLoop", 1000, true);
	scriptTimers[1] = SetTimer("antiCheat", 1000, true);
	scriptTimers[2] = SetTimer("playerTabbedLoop", 1000, true);
	scriptTimers[3] = SetTimer("AFKTimer", 600000, true);  

    mysql_query("UPDATE playeraccounts SET playerStatus = '0' WHERE playerStatus = '1'");

    initiateVehicleSpawns();
	initiateHouseSpawns();
	initiateJobs();
	initiateGroups();
	initiateAssets();
	initiateBusinesses();
	loadATMs();

	ShowPlayerMarkers(0);
	EnableStuntBonusForAll(0);
	DisableInteriorEnterExits();
	UsePlayerPedAnims(); 
	
	GetServerVarAsString("weburl", szServerWebsite, sizeof(szServerWebsite));

	SetGameModeText(SERVER_NAME" "SERVER_VERSION);

	weatherVariables[0] = validWeatherIDs[random(sizeof(validWeatherIDs))];
	SetWeather(weatherVariables[0]); 

    textdrawVariables[1] = TextDrawCreate(203.000000, 377.000000, "Press ~r~RIGHT~w~ to teleport to the player.~n~Press ~r~LEFT~w~ to disregard the request.");
	TextDrawBackgroundColor(textdrawVariables[1], 255);
	TextDrawFont(textdrawVariables[1], 2);
	TextDrawLetterSize(textdrawVariables[1], 0.190000, 1.200000);
	TextDrawColor(textdrawVariables[1], -1);
	TextDrawSetOutline(textdrawVariables[1], 1);
	TextDrawSetProportional(textdrawVariables[1], 1);
	TextDrawSetShadow(textdrawVariables[1], 1);

	textdrawVariables[7] = TextDrawCreate(149.000000, 370.000000, "~n~~n~~g~You can now continue to the next step.");
	TextDrawBackgroundColor(textdrawVariables[7], 255);
	TextDrawFont(textdrawVariables[7], 2);
	TextDrawLetterSize(textdrawVariables[7], 0.290000, 1.200000);
	TextDrawColor(textdrawVariables[7], -1);
	TextDrawSetOutline(textdrawVariables[7], 0);
	TextDrawSetProportional(textdrawVariables[7], 1);
	TextDrawSetShadow(textdrawVariables[7], 1);

	textdrawVariables[8] = TextDrawCreate(149.000000, 370.000000, "~n~~n~~r~You must wait a few seconds before continuing...");
	TextDrawBackgroundColor(textdrawVariables[8], 255);
	TextDrawFont(textdrawVariables[8], 2);
	TextDrawLetterSize(textdrawVariables[8], 0.290000, 1.200000);
	TextDrawColor(textdrawVariables[8], -1);
	TextDrawSetOutline(textdrawVariables[8], 0);
	TextDrawSetProportional(textdrawVariables[8], 1);
	TextDrawSetShadow(textdrawVariables[8], 1);

	textdrawVariables[2] = TextDrawCreate(149.000000, 370.000000, "Press ~r~left~w~ and ~n~Press ~r~right~w~ arrows to change skins.~n~Press ~r~~k~~VEHICLE_ENTER_EXIT~~w~ to select that skin.");
	TextDrawBackgroundColor(textdrawVariables[2], 255);
	TextDrawFont(textdrawVariables[2], 2);
	TextDrawLetterSize(textdrawVariables[2], 0.390000, 1.200000);
	TextDrawColor(textdrawVariables[2], -1);
	TextDrawSetOutline(textdrawVariables[2], 0);
	TextDrawSetProportional(textdrawVariables[2], 1);
	TextDrawSetShadow(textdrawVariables[2], 1);

	textdrawVariables[3] = TextDrawCreate(149.000000, 370.000000, "~w~Press ~r~left~w~ to go back a step~n~press ~r~right~w~ arrow to proceed");
	TextDrawBackgroundColor(textdrawVariables[3], 255);
	TextDrawFont(textdrawVariables[3], 2);
	TextDrawLetterSize(textdrawVariables[3], 0.390000, 1.200000);
	TextDrawColor(textdrawVariables[3], -1);
	TextDrawSetOutline(textdrawVariables[3], 0);
	TextDrawSetProportional(textdrawVariables[3], 1);
	TextDrawSetShadow(textdrawVariables[3], 1);

	textdrawVariables[4] = TextDrawCreate(149.000000, 420.000000, "Press ~r~~k~~SNEAK_ABOUT~~w~ to quit the spectator tool."); // Moved it down a little, it was actually fairly obtrusive.
	TextDrawBackgroundColor(textdrawVariables[4], 255);
	TextDrawFont(textdrawVariables[4], 2);
	TextDrawLetterSize(textdrawVariables[4], 0.390000, 1.200000);
	TextDrawColor(textdrawVariables[4], -1);
	TextDrawSetOutline(textdrawVariables[4], 0);
	TextDrawSetProportional(textdrawVariables[4], 1);
	TextDrawSetShadow(textdrawVariables[4], 1);

	textdrawVariables[5] = TextDrawCreate(610.0, 420.0, "Type ~r~/stopanim~w~ to stop your animation.");
	TextDrawUseBox(textdrawVariables[5], 0);
	TextDrawFont(textdrawVariables[5], 2);
	TextDrawSetShadow(textdrawVariables[5], 0);
    TextDrawSetOutline(textdrawVariables[5], 1);
    TextDrawBackgroundColor(textdrawVariables[5], 0x000000FF);
    TextDrawColor(textdrawVariables[5], 0xFFFFFFFF);
    TextDrawAlignment(textdrawVariables[5], 3);

    CreateDynamic3DTextLabel("Materials Pickup!\n\nType /getmats as an Arms Dealer \nto collect materials!", COLOR_YELLOW, 1423.9871, -1319.2954, 13.5547, 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 10.0);
	CreateDynamicPickup(1239, 23, 1423.9871, -1319.2954, 13.5547, 0, -1, -1, 50);

	/* -------------------------------------- Mapping (objects, static 3D texts, static pickups) -------------------------------------- */

	LSMall();
	GymMap();

	/* Bank */
	CreateDynamicPickup(1239, 23, 595.5443,-1250.3405,18.2836, 0, -1, -1, 50);
	CreateDynamic3DTextLabel("Bank of Los Santos\nPress ~k~~PED_DUCK~ to enter", COLOR_YELLOW, 595.5443,-1250.3405,18.2836, 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 10.0);
	/* /arrest */
	CreateDynamic3DTextLabel("Los Santos Police Department\nProcessing Entrance\n\n(/arrest)", COLOR_COOLBLUE, 1528.5240,-1678.2472,5.8906, 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 15.0);

	/* Exterior LSPD gates */
	LSPDGates[0][0] = CreateDynamicObject(968, 1544.681640625, -1630.8924560547, 13.15, 0.0, 90.0, 90.0, 0, 0, _, 200.0);
	LSPDGates[1][0] = CreateDynamicObject(10184,1589.19995117,-1637.98498535,14.69999981,0.00000000,0.00000000,270.00000000, 0, 0, _, 200.0);

	/* LSPD doors */
	LSPDObjs[0][0] = CreateDynamicObject(1569,232.89999390,107.57499695,1009.21179199,0.00000000,0.00000000,90.00000000, _, 10, _, 200.0); //commander south
	LSPDObjs[0][1] = CreateDynamicObject(1569,232.89941406,110.57499695,1009.21179199,0.00000000,0.00000000,270.00000000, _, 10, _, 200.0); //commander north
	LSPDObjs[1][0] = CreateDynamicObject(1569,275.75000000,118.89941406,1003.61718750,0.00000000,0.00000000,270.00000000, _, 10, _, 200.0); // interrogation north
	LSPDObjs[1][1] = CreateDynamicObject(1569,275.75000000,115.89941406,1003.61718750,0.00000000,0.00000000,90.00000000, _, 10, _, 200.0); // interrogation south
	LSPDObjs[2][0] = CreateDynamicObject(1569,253.20410156,107.59960938,1002.22070312,0.00000000,0.00000000,90.00000000, _,10, _, 200.0); // north west lobby door
	LSPDObjs[2][1] = CreateDynamicObject(1569,253.19921875,110.59960938,1002.22070312,0.00000000,0.00000000,270.00000000, _,10, _, 200.0); // north east lobby door
	LSPDObjs[3][0] = CreateDynamicObject(1569,239.56933594,116.09960938,1002.22070312,0.00000000,0.00000000,90.00000000, _,10, _, 200.0); // south west lobby door
	LSPDObjs[3][1] = CreateDynamicObject(1569,239.56445312,119.09960938,1002.22070312,0.00000000,0.00000000,269.98901367, _,10, _, 200.0); // south east lobby door
	LSPDObjs[4][0] = CreateDynamicObject(1569,264.45019531,115.82421875,1003.62286377,0.00000000,0.00000000,0.00000000, _,10, _, 200.0); //object(gen_doorext15) (3)
	LSPDObjs[4][1] = CreateDynamicObject(1569,267.45214844,115.82910156,1003.62286377,0.00000000,0.00000000,179.99450684, _,10, _, 200.0); //object(gen_doorext15) (8)
	LSPDObjs[5][0] = CreateDynamicObject(1569,267.32000732,112.53222656,1003.62286377,0.00000000,0.00000000,179.99450684, _,10, _, 200.0); //object(gen_doorext15) (4)
	LSPDObjs[5][1] = CreateDynamicObject(1569,264.32000732,112.52929688,1003.62286377,0.00000000,0.00000000,0.00000000, _,10, _, 200.0); //object(gen_doorext15) (5)
	LSPDObjs[6][0] = CreateDynamicObject(1569,229.59960938,119.52929688,1009.22442627,0.00000000,0.00000000,0.00000000, _,10, _, 200.0); //object(gen_doorext15) (9)
	LSPDObjs[6][1] = CreateDynamicObject(1569,232.59960938,119.53515625,1009.22442627,0.00000000,0.00000000,179.99450684, _,10, _, 200.0); //object(gen_doorext15) (10)
	LSPDObjs[7][0] = CreateDynamicObject(1569,219.30000305,116.52999878,998.01562500,0.00000000,0.00000000,180.00000000, _,10, _, 200.0); //cell east door
	LSPDObjs[7][1] = CreateDynamicObject(1569,216.30000305,116.52929688,998.01562500,0.00000000,0.00000000,0.00000000, _,10, _, 200.0); //cell west door

	/* LSPD interior objects (1st version) */
	CreateDynamicObject(1886,240.39999390,107.69999695,1010.70001221,35.00000000,0.00000000,135.00000000, _,10, _, 200.0); //object(nt_securecam1_01) (1)
	CreateDynamicObject(2058,262.23831177,107.09999847,1006.12506104,270.00000000,0.00000000,0.00000000, _,10, _, 200.0); //object(cj_gun_docs) (1)
	CreateDynamicObject(1491,222.17500305,119.45999908,1009.21502686,0.00000000,0.00000000,0.00000000, _,10, _, 200.0); //object(gen_doorint01) (1)
	CreateDynamicObject(1491,258.54980469,117.67968750,1007.82000732,0.00000000,0.00000000,0.00000000, _,10, _, 200.0); //object(gen_doorint01) (3)
	CreateDynamicObject(1491,260.73925781,117.67968750,1007.82000732,0.00000000,0.00000000,0.00000000, _,10, _, 200.0); //object(gen_doorint01) (4)
	CreateDynamicObject(2612,263.50000000,112.34960938,1005.50000000,0.00000000,0.00000000,0.00000000, _,10, _, 200.0); //object(police_nb2) (1)
	CreateDynamicObject(3857,233.04499817,124.00000000,1013.00000000,0.00000000,0.00000000,315.00000000, _,10, _, 200.0); //object(ottosmash3) (1)
	CreateDynamicObject(3857,232.73730469,124.00000000,1013.00000000,0.00000000,0.00000000,135.00012207, _,10, _, 200.0); //object(ottosmash3) (2)
	CreateDynamicObject(1491,225.05999756,115.94999695,1002.22998047,0.00000000,0.00000000,0.00000000, _,10, _, 200.0); //object(gen_doorint01) (2)
	CreateDynamicObject(1491,233.11000061,119.25000000,1002.22998047,0.00000000,0.00000000,0.00000000, _,10, _, 200.0); //object(gen_doorint01) (5)
	CreateDynamicObject(1491,236.80957031,119.25000000,1002.22998047,0.00000000,0.00000000,0.00000000, _,10, _, 200.0); //object(gen_doorint01) (6)
	CreateDynamicObject(3051,275.77499390,122.65599823,1004.97937012,0.00000000,0.00000000,46.00000000, _,10, _, 200.0); //object(lift_dr) (1)
	CreateDynamicObject(3051,275.75000000,121.50000000,1004.97937012,0.00000000,0.00000000,45.00000000, _,10, _, 200.0); //object(lift_dr) (2)
	CreateDynamicObject(1485,227.89999390,125.30000305,1010.21002197,50.00000000,10.00000000,2.00000000, _,10, _, 200.0); //object(cj_ciggy) (1)
	CreateDynamicObject(1510,228.07321167,125.27845001,1010.15997314,0.00000000,0.00000000,0.00000000, _,10, _, 200.0); //object(dyn_ashtry) (1)
	CreateDynamicObject(2196,228.40014648,125.53178406,1010.13958740,0.00000000,0.00000000,29.77478027, _,10, _, 200.0); //object(work_lamp1) (1)
	CreateDynamicObject(2063,262.95996094,107.40136719,1004.53997803,0.00000000,0.00000000,179.99450684, _,10, _, 200.0); //object(cj_greenshelves) (1)
	CreateDynamicObject(2043,262.29138184,107.46166229,1004.09997559,0.00000000,0.00000000,294.36035156, _,10, _, 200.0); //object(ammo_box_m4) (1)
	CreateDynamicObject(353,262.79998779297,107.68000030518,1004.9,91.9,89,240, _,10, _, 200.0); //object(cj_mp5k) (2)
	CreateDynamicObject(1672,262.62597656,107.59999847,1005.37500000,0.00000000,90.00000000,0.00000000, _,10, _, 200.0); //object(gasgrenade) (1)
	CreateDynamicObject(1672,262.81585693,107.48020935,1005.41998291,0.00000000,0.00000000,0.00000000, _,10, _, 200.0); //object(gasgrenade) (2)
	CreateDynamicObject(14782,267.76998901,109.30000305,1004.63323975,0.00000000,0.00000000,270.00000000, _,10, _, 200.0); //object(int3int_boxing30) (2)
	CreateDynamicObject(14782,260.79980469,108.75000000,1004.63323975,0.00000000,0.00000000,90.00000000, _,10, _, 200.0); //object(int3int_boxing30) (3)
	CreateDynamicObject(2359,263.54296875,107.39648438,1005.53002930,0.00000000,0.00000000,183.89465332, _,10, _, 200.0); //object(ammo_box_c5) (1)
	CreateDynamicObject(2038,263.47906494,107.32552338,1004.51000977,270.00000000,0.00000000,29.91000366, _,10, _, 200.0); //object(ammo_box_s2) (1)
	CreateDynamicObject(356,262.60000610352,107.30000305176,1004.4799804688,96, 90, 290, _,10, _, 200.0); //object(cj_m16) (1)
	CreateDynamicObject(2690,267.92782593,108.53081512,1003.97998047,0.00000000,0.00000000,312.13256836, _,10, _, 200.0); //object(cj_fire_ext) (1)
	CreateDynamicObject(2058,262.98568726,107.09528351,1005.36926270,90.00000000,180.00549316,359.98352051, _,10, _, 200.0); //object(cj_gun_docs) (1)
	CreateDynamicObject(11631,269.81250000,118.18945312,1004.86309814,0.00000000,0.00000000,270.00000000, _,10, _, 200.0); //object(ranch_desk) (1)
	CreateDynamicObject(2356,269.14312744,117.66873169,1003.61718750,0.00000000,0.00000000,294.49548340, _,10, _, 200.0); //object(police_off_chair) (1)
	CreateDynamicObject(2094,262.86523438,110.89941406,1003.60998535,0.00000000,0.00000000,0.00000000, _,10, _, 200.0); //object(swank_cabinet_4) (1)
	CreateDynamicObject(1886,267.73999023,107.50000000,1007.40002441,20.00000000,0.00000000,235.00000000, _,10, _, 200.0); //object(shop_sec_cam) (1)
	CreateDynamicObject(2606,267.36914062,120.50683594,1004.59997559,0.00000000,0.00000000,0.00000000, _,10, _, 200.0); //object(cj_police_counter2) (1)
	CreateDynamicObject(2606,267.36914062,120.50683594,1005.04998779,0.00000000,0.00000000,0.00000000, _,10, _, 200.0); //object(cj_police_counter2) (2)
	CreateDynamicObject(1738,270.29000854,120.00000000,1004.27178955,0.00000000,0.00000000,269.27026367, _,10, _, 200.0); //object(cj_radiator_old) (1)
	CreateDynamicObject(2180,265.50552368,120.27999878,1003.61718750,0.00000000,0.00000000,180.54052734, _,10, _, 200.0); //object(med_office5_desk_3) (1)
	CreateDynamicObject(1788,265.60000610,120.50000000,1004.48681641,0.00000000,0.00000000,0.00000000, _,10, _, 200.0); //object(swank_video_1) (1)
	CreateDynamicObject(1782,265.59960938,120.50000000,1004.65002441,0.00000000,0.00000000,0.00000000, _,10, _, 200.0); //object(med_video_2) (1)
	CreateDynamicObject(2595,264.21002197,120.37789154,1004.77404785,0.00000000,0.00000000,314.65002441, _,10, _, 200.0); //object(cj_shop_tv_video) (1)
	CreateDynamicObject(1785,265.59960938,120.50976562,1004.84997559,0.00000000,0.00000000,0.00000000, _,10, _, 200.0); //object(low_video_1) (1)
	CreateDynamicObject(1840,264.81204224,120.58029938,1004.41882324,0.00000000,0.00000000,105.60998535, _,10, _, 200.0); //object(speaker_2) (1)
	CreateDynamicObject(1840,265.70001221,120.55999756,1004.96264648,0.00000000,0.00000000,75.00000000, _,10, _, 200.0); //object(speaker_2) (2)
	CreateDynamicObject(2356,265.15481567,119.43829346,1003.61718750,0.00000000,0.00000000,34.19393921, _,10, _, 200.0); //object(police_off_chair) (2)
	CreateDynamicObject(1775,238.87988281,115.59960938,1010.32000732,0.00000000,0.00000000,270.26916504, _,10, _, 200.0); //object(vendmach) (1)
	CreateDynamicObject(4100,246.51953125,119.39941406,1005.40002441,0.00000000,179.99450684,219.99023438, _,10, _, 200.0); //object(meshfence1_lan) (1)
	CreateDynamicObject(4100,253.19999695,117.80000305,1010.50000000,320.00000000,90.00000000,90.00000000, _,10, _, 200.0); //object(pol_comp_gate) (1)
	CreateDynamicObject(2101,266.74893188,120.49598694,1005.28363037,0.00000000,0.00000000,0.00000000, _,10, _, 200.0); //object(med_hi_fi_3) (1)
	CreateDynamicObject(1886,264.25000000,116.55000305,1007.29998779,30.00000000,0.00000000,140.00000000, _,10, _, 200.0); //object(shop_sec_cam) (2)
	CreateDynamicObject(2611,268.47473145,116.05200195,1005.25000000,0.00000000,0.00000000,180.00000000, _,10, _, 200.0); //object(police_nb1) (1)
	CreateDynamicObject(4100,232.84960938,128.50000000,1011.91998291,0.00000000,0.00000000,49.99877930, _,10, _, 200.0); //object(meshfence1_lan) (4)
	CreateDynamicObject(2595,226.24514771,120.27544403,1011.28753662,0.00000000,0.00000000,77.72994995, _,10, _, 200.0); //object(cj_shop_tv_video) (2)
	CreateDynamicObject(3934,1563.90014648,-1700.00000000,27.40211487,0.00000000,0.00000000,0.00000000, 0, 0, _, 200.0); //object(helipad01) (2)
	CreateDynamicObject(1496,1564.14257812,-1667.36914062,27.39560699,0.00000000,0.00000000,0.00000000, 0, 0, _, 200.0); //object(gen_doorshop02) (1)
	CreateDynamicObject(2953,228.27796936,125.20470428,1010.14331055,0.00000000,0.00000000,143.45983887, _,10, _, 200.0); //object(kmb_paper_code) (1)
	CreateDynamicObject(4100,239.60000610,113.19999695,1010.50000000,319.99877930,90.00000000,90.00000000, _,10, _, 200.0); //object(pol_comp_gate) (1)
	CreateDynamicObject(2054,263.76342773,112.13343811,1004.64001465,0.00000000,0.00000000,36.00000000, _,10, _, 200.0); //object(cj_capt_hat) (1)
	CreateDynamicObject(2053,264.10845947,112.14072418,1004.66998291,0.00000000,0.00000000,0.00000000, _,10, _, 200.0); //object(cj_jerry_hat) (1)
	CreateDynamicObject(351,262.85000610352,111.90000152588,1004.6599731445,275,90,106, _,10, _, 200.0); //object(cj_m16) (2)
	CreateDynamicObject(2040,262.57006836,112.05036163,1004.72113037,0.00000000,0.00000000,342.13513184, _,10, _, 200.0); //object(ammo_box_m1) (1)
	CreateDynamicObject(2068,264.29998779,109.19999695,1007.00000000,0.00000000,0.00000000,90.00000000, _,10, _, 200.0); //object(cj_cammo_net) (1)
	CreateDynamicObject(1516,272.90374756,118.44168854,1003.79998779,0.00000000,0.00000000,0.00000000, _,10, _, 200.0); //object(dyn_table_03) (1)
	CreateDynamicObject(1810,272.74725342,117.44008636,1003.61718750,0.00000000,0.00000000,183.70996094, _,10, _, 200.0); //object(cj_foldchair) (1)
	CreateDynamicObject(1810,273.19308472,119.28445435,1003.61718750,0.00000000,0.00000000,2.00000000, _,10, _, 200.0); //object(cj_foldchair) (2)
	CreateDynamicObject(2953,272.84149170,118.41313934,1004.34997559,0.00000000,0.00000000,89.00000000, _,10, _, 200.0); //object(kmb_paper_code) (2)
	CreateDynamicObject(2953,272.89001465,118.30000305,1004.34997559,0.00000000,0.00000000,13.00000000, _,10, _, 200.0); //object(kmb_paper_code) (3)
	CreateDynamicObject(2196,273.04998779,118.69999695,1004.32000732,0.00000000,0.00000000,335.00000000, _,10, _, 200.0); //object(work_lamp1) (2)
	CreateDynamicObject(1886,228.80000305,116.00000000,1002.20001221,10.00000000,0.00000000,290.00000000, _,10, _, 200.0); //object(shop_sec_cam) (3)
	CreateDynamicObject(1491,265.17999268,112.68000031,1007.82000732,0.00000000,0.00000000,270.00000000, _,10, _, 200.0); //object(gen_doorint01) (4)
	CreateDynamicObject(2954,224.00000000,107.40000153,998.70062256,0.00000000,90.00000000,89.99993896, _,10, _, 200.0); //object(kmb_ot) (1)
	CreateDynamicObject(2954,228.19999695,107.39941406,998.70062256,0.00000000,90.00000000,90.00000000, _,10, _, 200.0); //object(kmb_ot) (2)
	CreateDynamicObject(2954,220.09960938,107.39941406,998.70062256,0.00000000,90.00000000,89.99996948, _,10, _, 200.0); //object(kmb_ot) (3)
	CreateDynamicObject(2954,216.10000610,107.39941406,998.70062256,0.00000000,90.00000000,90.00000000, _,10, _, 200.0); //object(kmb_ot) (4)
	CreateDynamicObject(1235,225.47909546,121.89310455,1009.72180176,0.00000000,0.00000000,0.00000000, _,10, _, 200.0); //object(wastebin) (1)
	CreateDynamicObject(2602,226.00000000,108.50000000,998.53906250,0.00000000,0.00000000,90.00000000, _,10, _, 200.0); //object(police_cell_toilet) (1)
	CreateDynamicObject(2602,214.00000000,108.50000000,998.53906250,0.00000000,0.00000000,90.00000000, _,10, _, 200.0); //object(police_cell_toilet) (2)
	CreateDynamicObject(2602,222.09960938,108.50000000,998.53906250,0.00000000,0.00000000,90.00000000, _,10, _, 200.0); //object(police_cell_toilet) (3)
	CreateDynamicObject(2602,218.10000610,108.50000000,998.53906250,0.00000000,0.00000000,90.00000000, _,10, _, 200.0); //object(police_cell_toilet) (4)
	CreateDynamicObject(8167,218.50000000,112.50000000,999.20001221,0.00000000,0.00000000,90.00000000, _,10, _, 200.0); //object(apgate1_vegs01) (1)
	CreateDynamicObject(8167,226.34960938,112.50000000,999.20001221,0.00000000,0.00000000,90.00000000, _,10, _, 200.0); //object(apgate1_vegs01) (2)
	CreateDynamicObject(3785,215.50000000,109.90000153,1001.40997314,0.00000000,90.00000000,0.00000000, _,10, _, 200.0); //object(bulkheadlight) (1)
	CreateDynamicObject(3785,219.50000000,109.89941406,1001.40997314,0.00000000,90.00000000,0.00000000, _,10, _, 200.0); //object(bulkheadlight) (2)
	CreateDynamicObject(3785,223.50000000,109.89941406,1001.40997314,0.00000000,90.00000000,0.00000000, _,10, _, 200.0); //object(bulkheadlight) (3)
	CreateDynamicObject(3785,227.50000000,109.89941406,1001.40997314,0.00000000,90.00000000,0.00000000, _,10, _, 200.0); //object(bulkheadlight) (4)

	/* Exterior LSPD objects */
	CreateDynamicObject(3934,1563.89941406,-1650.34277344,27.40211487,0.00000000,0.00000000,0.00000000, 0, 0, _, 200.0); //object(helipad01) (2)
	CreateDynamicObject(1496,1563.84997559,-1671.13000488,51.45027542,0.00000000,0.00000000,0.00000000, 0, 0, _, 200.0); //object(gen_doorshop02) (2)
	CreateDynamicObject(982,1577.75000000,-1701.50000000,28.07836533,0.00000000,0.00000000,0.00000000, 0, 0, _, 200.0); //object(fence) (1)
	CreateDynamicObject(982,1577.75000000,-1650.30004883,28.07836533,0.00000000,0.00000000,0.00000000, 0, 0, _, 200.0); //object(fence) (3)
	CreateDynamicObject(982,1565.00000000,-1637.50000000,28.07836533,0.00000000,0.00000000,90.00000000, 0, 0, _, 200.0); //object(fence) (4)
	CreateDynamicObject(984,1549.02502441,-1637.50000000,28.03879547,0.00000000,0.00000000,90.00000000, 0, 0, _, 200.0); //object(fence2) (1)
	CreateDynamicObject(982,1565.00000000,-1714.30004883,28.07836533,0.00000000,0.00000000,90.00000000, 0, 0, _, 200.0); //object(fencet) (5)
	CreateDynamicObject(982,1577.75000000,-1675.89941406,28.07836533,0.00000000,0.00000000,0.00000000, 0, 0, _, 200.0); //object(fencest) (6)
	CreateDynamicObject(984,1549.02441406,-1714.29980469,28.03879547,0.00000000,0.00000000,90.00000000, 0, 0, _, 200.0); //object(fenceshit2) (3)
	CreateDynamicObject(983,1550.59997559,-1701.50000000,28.07836533,0.00000000,0.00000000,90.00000000, 0, 0, _, 200.0); //object(fenceshit3) (2)
	CreateDynamicObject(984,1542.59960938,-1643.89941406,28.03879547,0.00000000,0.00000000,0.00000000, 0, 0, _, 200.0); //object(fenceshit2) (6)
	CreateDynamicObject(983,1545.79980469,-1701.50000000,28.07836533,0.00000000,0.00000000,90.00000000, 0, 0, _, 200.0); //object(fenceshit3) (3)
	CreateDynamicObject(983,1550.59997559,-1650.30004883,28.07836533,0.00000000,0.00000000,90.00000000, 0, 0, _, 200.0); //object(fenceshit3) (4)
	CreateDynamicObject(983,1545.79980469,-1650.30004883,28.07836533,0.00000000,0.00000000,90.00000000, 0, 0, _, 200.0); //object(fenceshit3) (5)
	CreateDynamicObject(984,1542.59960938,-1707.89941406,28.03879547,0.00000000,0.00000000,0.00000000, 0, 0, _, 200.0); //object(fenceshit2) (7)
	CreateDynamicObject(984,1553.80004883,-1695.09997559,28.03000069,0.00000000,0.00000000,0.00000000, 0, 0, _, 200.0); //object(fenceshit2) (8)
	CreateDynamicObject(984,1553.79980469,-1656.69995117,28.03000069,0.00000000,0.00000000,0.00000000, 0, 0, _, 200.0); //object(fenceshit2) (9)
	CreateDynamicObject(983,1544.69995117,-1620.58996582,13.02000046,0.00000000,0.00000000,0.00000000); //object(fenceshit3) (1)
	CreateDynamicObject(1331,1544.54602051,-1616.99133301,13.10000038,0.00000000,0.00000000,0.00000000); //object(binnt01_la) (1)
	CreateDynamicObject(2952,1582.00000000,-1637.88598633,12.39045906,0.00000000,0.00000000,90.00000000); //object(kmb_gimpdoor) (1)
	CreateDynamicObject(983,1544.69921875,-1636.00000000,13.02000046,0.00000000,0.00000000,0.00000000); //object(fenceshit3) (6)
	CreateDynamicObject(2952,1582.00000000,-1638.30004883,12.39045906,0.00000000,0.00000000,90.00000000); //object(kmb_gimpdoor) (2)

	/* Moar crap */
	CreateDynamicObject(2842,2320.79003906,-1021.39941406,1049.21093750,0.00000000,0.00000000,90.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(gb_bedrug04) (2)
	CreateDynamicObject(2842,2320.79003906,-1023.19921875,1049.21093750,0.00000000,0.00000000,90.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(gb_bedrug04) (3)
	CreateDynamicObject(2842,2320.79003906,-1025.00000000,1049.21093750,0.00000000,0.00000000,90.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(gb_bedrug04) (4)
	CreateDynamicObject(2842,2319.87500000,-1019.59997559,1049.21093750,0.00000000,0.00000000,90.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(gb_bedrug04) (5)
	CreateDynamicObject(2842,2319.87500000,-1017.79998779,1049.21093750,0.00000000,0.00000000,90.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(gb_bedrug04) (6)
	CreateDynamicObject(2842,2319.87500000,-1016.00000000,1049.21093750,0.00000000,0.00000000,90.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(gb_bedrug04) (7)
	CreateDynamicObject(2842,2319.87500000,-1014.20001221,1049.21093750,0.00000000,0.00000000,90.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(gb_bedrug04) (8)
	CreateDynamicObject(2842,2319.87500000,-1012.40002441,1049.21093750,0.00000000,0.00000000,90.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(gb_bedrug04) (9)
	CreateDynamicObject(2842,2319.87500000,-1010.59997559,1049.21093750,0.00000000,0.00000000,90.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(gb_bedrug04) (10)
	CreateDynamicObject(2842,2320.79003906,-1010.59960938,1049.21093750,0.00000000,0.00000000,90.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(gb_bedrug04) (11)
	CreateDynamicObject(2842,2320.79003906,-1012.39941406,1049.21093750,0.00000000,0.00000000,90.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(gb_bedrug04) (12)
	CreateDynamicObject(2842,2320.79003906,-1014.19921875,1049.21093750,0.00000000,0.00000000,90.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(gb_bedrug04) (13)
	CreateDynamicObject(2842,2320.79003906,-1016.00000000,1049.21093750,0.00000000,0.00000000,90.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(gb_bedrug04) (14)
	CreateDynamicObject(2842,2320.79003906,-1017.79980469,1049.21093750,0.00000000,0.00000000,90.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(gb_bedrug04) (15)
	CreateDynamicObject(2842,2320.79003906,-1019.59960938,1049.21093750,0.00000000,0.00000000,90.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(gb_bedrug04) (16)
	CreateDynamicObject(2842,2319.87500000,-1021.39941406,1049.21093750,0.00000000,0.00000000,90.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(gb_bedrug04) (17)
	CreateDynamicObject(2842,2319.87500000,-1023.19921875,1049.21093750,0.00000000,0.00000000,90.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(gb_bedrug04) (18)
	CreateDynamicObject(2842,2319.87500000,-1025.00000000,1049.21093750,0.00000000,0.00000000,90.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(gb_bedrug04) (19)
	CreateDynamicObject(2069,2322.39306641,-1007.62664795,1049.30004883,0.00000000,0.00000000,0.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(cj_mlight7) (1)
	CreateDynamicObject(2297,2322.41992188,-1018.77001953,1049.21997070,0.00000000,0.00000000,356.03002930, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(tv_unit_2) (1)
	CreateDynamicObject(2069,2322.28906250,-1021.15917969,1049.26501465,0.00000000,0.00000000,0.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(cj_mlight7) (2)
	CreateDynamicObject(2073,2319.97973633,-1013.20001221,1052.93005371,0.00000000,0.00000000,0.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(cj_mlight1) (1)
	CreateDynamicObject(2332,2328.48388672,-1016.84997559,1054.50000000,0.00000000,0.00000000,180.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(kev_safe) (1)
	CreateDynamicObject(2833,2325.89990234,-1010.70001221,1053.71875000,0.00000000,0.00000000,0.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(gb_livingrug02) (1)
	CreateDynamicObject(1210,2322.50390625,-1009.73980713,1054.77001953,90.00000000,0.00000000,23.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(briefcase) (1)
	CreateDynamicObject(1742,2323.39990234,-1006.62500000,1053.70996094,0.00000000,0.00000000,0.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(med_bookshelf) (1)
	CreateDynamicObject(2894,2322.46752930,-1009.14672852,1054.67187500,0.00000000,0.00000000,89.73001099, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(kmb_rhymesbook) (1)
	CreateDynamicObject(1502,2321.91992188,-1023.88201904,1049.21093750,0.00000000,0.00000000,90.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(gen_doorint04) (1)
	CreateDynamicObject(1502,2317.95996094,-1013.89001465,1049.21093750,0.00000000,0.00000000,90.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(gen_doorint04) (2)
	CreateDynamicObject(1502,2321.91992188,-1013.88964844,1049.21093750,0.00000000,0.00000000,90.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(gen_doorint04) (3)
	CreateDynamicObject(2069,2316.20019531,-1026.69848633,1049.25000000,0.00000000,0.00000000,0.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(cj_mlight7) (2)
	CreateDynamicObject(2267,2322.00000000,-1010.00000000,1051.36096191,0.00000000,0.00000000,90.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(frame_wood_3) (1)
	CreateDynamicObject(2813,2326.06225586,-1016.13732910,1050.25781250,0.00000000,0.00000000,308.25524902, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(gb_novels01) (1)
	CreateDynamicObject(1667,2324.96020508,-1011.50372314,1049.79870605,0.00000000,0.00000000,0.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(propwineglass1) (1)
	CreateDynamicObject(1667,2324.88867188,-1011.38964844,1049.79870605,0.00000000,0.00000000,0.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(propwineglass1) (2)
	CreateDynamicObject(1665,2324.96142578,-1011.71868896,1049.72058105,0.00000000,0.00000000,0.00000000, HOUSE_VIRTUAL_WORLD + 6, 9, _, 200.0); //object(propashtray1) (1)

	/* LSPD interior additions */
	CreateDynamicObject(1742,239.44921875,109.50000000,1009.21179199,0.00000000,0.00000000,270.26916504, _, 10, _, 200.0); //object(med_bookshelf) (1)
	CreateDynamicObject(2259,233.53700256,111.30000305,1010.52191162,0.00000000,0.00000000,90.00000000, _, 10, _, 200.0); //object(frame_clip_6) (1)
	CreateDynamicObject(1510,237.27488708,110.47866058,1010.05999756,0.00000000,0.00000000,0.00000000, _, 10, _, 200.0); //object(dyn_ashtry) (1)
	CreateDynamicObject(3044,237.19999695,110.61499786,1010.16998291,25.00000000,0.00000000,0.00000000, _, 10, _, 200.0); //object(cigar) (2)
	CreateDynamicObject(2894,237.23359680,109.39933777,1010.05700684,0.00000000,0.00000000,105.56491089, _, 10, _, 200.0); //object(kmb_rhymesbook) (1)
	CreateDynamicObject(16780,236.00000000,110.00000000,1012.85998535,0.00000000,0.00000000,0.00000000, _, 10, _, 200.0); //object(ufo_light03) (2)
	CreateDynamicObject(1744,237.30000305,113.25000000,1010.70001221,0.00000000,0.00000000,0.00000000, _, 10, _, 200.0); //object(med_shelf) (1)
	CreateDynamicObject(1235,238.86370850,112.72632599,1009.72180176,0.00000000,0.00000000,0.00000000, _, 10, _, 200.0); //object(wastebin) (1)
	CreateDynamicObject(1520,237.29576111,110.73871613,1010.05700684,0.00000000,0.00000000,0.00000000, _, 10, _, 200.0); //object(dyn_wine_bounce) (1)
	CreateDynamicObject(1742,239.44921875,108.06933594,1009.21179199,0.00000000,0.00000000,270.26916504, _, 10, _, 200.0); //object(med_bookshelf) (1)
	CreateDynamicObject(2833,238.00000000,109.40000153,1009.22998047,0.00000000,0.00000000,90.00000000, _, 10, _, 200.0); //object(gb_livingrug02) (1)
	CreateDynamicObject(2813,237.22207642,112.88127136,1011.04052734,0.00000000,0.00000000,0.00000000, _, 10, _, 200.0); //object(gb_novels01) (1)
	CreateDynamicObject(2332,239.60000610,111.50000000,1011.04998779,0.00000000,0.00000000,270.00000000, _, 10, _, 200.0); //object(kev_safe) (1)
	CreateDynamicObject(2558,238.82000732,112.00000000,1010.50000000,0.00000000,0.00000000,270.00000000, _, 10, _, 200.0); //object(curtain_1_closed) (1)
	CreateDynamicObject(2289,237.42500305,107.12000275,1011.24859619,0.00000000,0.00000000,179.99450684, _, 10, _, 200.0); //object(frame_2) (1)
	CreateDynamicObject(2267,231.40335083,128.39999390,1011.29760742,0.00000000,0.00000000,0.00000000, _, 10, _, 200.0); //object(frame_wood_3) (1)
	CreateDynamicObject(2894,229.15087891,125.28470612,1010.13958740,0.00000000,0.00000000,0.00000000, _, 10, _, 200.0); //object(kmb_rhymesbook) (2)

	/* LSPD 3D Text Labels */
	CreateDynamic3DTextLabel("Department building elevator\n(/elevator)", COLOR_YELLOW, 276.0980, 122.1232, 1004.6172, 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 10.0);
	CreateDynamic3DTextLabel("Upper roof elevator\n(/elevator)", COLOR_YELLOW, 1564.6584,-1670.2607,52.4503, 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 10.0);
	CreateDynamic3DTextLabel("Lower roof elevator\n(/elevator)", COLOR_YELLOW, 1564.8, -1666.2, 28.3, 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 10.0);
	CreateDynamic3DTextLabel("Police garage elevator\n(/elevator)", COLOR_YELLOW, 1568.6676, -1689.9708, 6.2188, 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 10.0);

}