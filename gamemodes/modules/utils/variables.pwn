#include "modules/utils/enum.pwn"

new
	LSPDObjs[8][3], // 8 sets of doors. 0 = door1, 1 = door2, 2 = status (closed/open)
	LSPDGates[2][2]; // Boom gate, garage (1 = status, closed/open).

new tutorialSkins[73] = {
	0, 1, 2, 7, 9, 10, 11, 12, 13, 14, 15, 16, 17,
	18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
	30, 31, 32, 33,	34, 35, 36, 37, 38, 39, 40, 41,
	43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 52, 53,
	54, 55, 56, 57, 58, 59, 60, 61,	62, 63, 64,	66,
	67, 68, 69, 70, 72, 73, 75, 76, 77, 78, 79, 299
};

new Float:JailSpawns[4][3] = {

	{ 227.46, 110.0, 999.02 },
	{ 223.15, 110.0, 999.02 },
	{ 219.25, 110.0, 999.02 },
	{ 216.39, 110.0, 999.02 }
};

new validWeatherIDs[17] = { 1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13, 14, 15, 17, 18, 20 };

new WeaponNames[47][] = // As below
{
	"punch","brass knuckles","golf club","nitestick","knife","baseball bat","shovel","pool cue","katana","chainsaw","purple dildo","small white vibrator","large white vibrator","silver vibrator",
	"bouquet of flowers","cane","grenade","tear gas grenade","molotov cocktail","jetpack"," "," ","Colt .45","silenced Colt .45","Desert Eagle","12-gauge shotgun","sawn-off shotgun","SPAS-12",
	"Micro Uzi","MP5","AK-47","M4A1","TEC-9","rifle","sniper rifle","rocket launcher","heatseeker","flamethrower","minigun","satchel charge","detonator","spray can","fire extinguisher",
	"camera","nightvision goggles", "thermal goggles","parachute"
};

new fishNames[5][] = {
	"Carp", "Bass", "Cod", "Plaice", "Tuna"
};

new VehicleNames[212][] = // Keeping unnecessary bits out (easily calculated integers, etc) for the win
{
	"Landstalker","Bravura","Buffalo","Linerunner","Perennial","Sentinel","Dumper","Firetruck","Trashmaster","Stretch",
	"Manana","Infernus","Voodoo","Pony","Mule","Cheetah","Ambulance","Leviathan","Moonbeam","Esperanto","Taxi",
	"Washington","Bobcat","Mr Whoopee","BF Injection","Hunter","Premier","Enforcer","Securicar","Banshee","Predator",
	"Bus","Rhino","Barracks","Hotknife","Trailer","Previon","Coach","Cabbie","Stallion","Rumpo","RC Bandit", "Romero",
	"Packer","Monster","Admiral","Squalo","Seasparrow","Pizzaboy","Tram","Trailer","Turismo","Speeder","Reefer","Tropic","Flatbed",
	"Yankee","Caddy","Solair","Berkley's RC Van","Skimmer","PCJ-600","Faggio","Freeway","RC Baron","RC Raider",
	"Glendale","Oceanic","Sanchez","Sparrow","Patriot","Quad","Coastguard","Dinghy","Hermes","Sabre","Rustler",
	"ZR-350","Walton","Regina","Comet","BMX","Burrito","Camper","Marquis","Baggage","Dozer","Maverick","News Chopper",
	"Rancher","FBI Rancher","Virgo","Greenwood","Jetmax","Hotring Racer","Sandking","Blista Compact","Police Maverick",
	"Boxville","Benson","Mesa","RC Goblin","Hotring Racer A","Hotring Racer B","Bloodring Banger","Rancher","Super GT",
	"Elegant","Journey","Bike","Mountain Bike","Beagle","Cropduster","Stuntplane","Tanker","Road Train","Nebula","Majestic",
	"Buccaneer","Shamal","Hydra","FCR-900","NRG-500","HPV-1000","Cement Truck","Tow Truck","Fortune","Cadrona","FBI Truck",
	"Willard","Forklift","Tractor","Combine","Feltzer","Remington","Slamvan","Blade","Freight","Streak","Vortex","Vincent",
	"Bullet","Clover","Sadler","Firetruck","Hustler","Intruder","Primo","Cargobob","Tampa","Sunrise","Merit","Utility",
	"Nevada","Yosemite","Windsor","Monster A","Monster B","Uranus","Jester","Sultan","Stratum","Elegy","Raindance","RC Tiger",
	"Flash","Tahoma","Savanna","Bandito","Freight","Trailer","Kart","Mower","Duneride","Sweeper","Broadway",
	"Tornado","AT-400","DFT-30","Huntley","Stafford","BF-400","Newsvan","Tug","Trailer","Emperor","Wayfarer",
	"Euros","Hotdog","Club","Trailer","Trailer","Andromada","Dodo","RCCam","Launch","Police Car (LSPD)","Police Car (SFPD)",
	"Police Car (LVPD)","Police Ranger","Picador","S.W.A.T. Van","Alpha","Phoenix","Glendale","Sadler","Luggage Trailer A",
	"Luggage Trailer B","Stair Trailer","Boxville","Farm Plow","Utility Trailer"
};

new
	temp,
	databaseConnection,
	pingTick,
	adTick,
	vehCount,
	weatherVariables[2],
	gTime[3],
	iGMXTimer,
	iTarget,
	iGMXTick,
	systemVariables[systemE],
	connectionInfo[connectionE],
	houseVariables[MAX_HOUSES][houseE],
	Text:textdrawVariables[MAX_TEXTDRAWS],
	jobVariables[MAX_JOBS][jobsE],
 	AdminSpawnedVehicles[MAX_VEHICLES],
 	assetVariables[MAX_ASSETS][assetsE],
 	szQueryOutput[256],
 	szMessage[128],
 	szSmallString[32],
 	atmVariables[MAX_ATMS][atmE],
 	result[256],
 	szServerWebsite[32],
	szMediumString[512],
 	szLargeString[1024],
 	szPlayerName[MAX_PLAYER_NAME],
 	businessVariables[MAX_BUSINESSES][businessE],
 	Float:PlayerPos[MAX_PLAYERS][6],
	vehicleVariables[MAX_VEHICLES][vehicleE],
	groupVariables[MAX_GROUPS][groupE],
	businessItems[MAX_BUSINESS_ITEMS][businessItemsE],
	playerVariables[MAX_PLAYERS][playervEnum],
	spikeVariables[MAX_SPIKES][spikeE],
	scriptTimers[MAX_TIMERS];