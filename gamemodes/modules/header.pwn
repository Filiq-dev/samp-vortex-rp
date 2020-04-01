/*
						Copyright 2010-2011 Frederick Wright

		   Licensed under the Apache License, Version 2.0 (the "License");
		   you may not use this file except in compliance with the License.
		   You may obtain a copy of the License at

		     		http://www.apache.org/licenses/LICENSE-2.0

		   Unless required by applicable law or agreed to in writing, software
		   distributed under the License is distributed on an "AS IS" BASIS,
		   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
		   See the License for the specific language governing permissions and
		   limitations under the License.

		SCRIPT:
		    Vortex Roleplay 2 Script

		AUTHOR:
			Frederick Wright [mrfrederickwright@gmail.com]
			Stefan Rosic [streetfire68@hotmail.com]

		ADDITIONAL CREDITS:
		    All other unmentioned mapping: JamesC [http://forum.sa-mp.com/member.php?u=97617]
			Gym Map: Marcel_Collins [http://forum.sa-mp.com/showthread.php?p=1537421]
			LS Mall: cessil [http://forum.sa-mp.com/member.php?u=50597]

		MISC INFO:
			gGroupType listing:
				0 - Gangs
				1 - Police
				2 - Government
				3 - Hitmen
				4 - LSFMD

				Reserved group slots
				1 - LSPD
				3 - Government
				4 - LSFMD

				Job Types
				1 - Arms Dealer
				2 - Detective
				3 - Mechanic
				4 - Fisherman
				
				Business Item Types:
				1 - Rope
				2 - Walkie Talkie
				3 - Phonebook
				4 - Mobile Phone Credit
				5 - Mobile Phone
				6 - 5% health increase (food)
				7 - 10% health increase (food)
				8 - 30% health increase (food)
				9 - Purple Dildo
				10 - Small White Vibrator
				11 - Large White Vibrator
				12 - Silver Vibrator
				13 - Flowers
				14 - Cigar(s)
				15 - Sprunk
				16 - Wine
				17 - Beer
				18 - All Skins

			Error Codes:
				01x01 - Attempted to deposit an invalid (negative) amount of money to a house safe.
				01x02 - Attempted to deposit an invalid (negative) amount of materials to a house safe.
				01x03 - Attempted to withdraw an invalid (negative) amount of money from a house safe.
				01x04 - Attempted to withdraw an invalid (negative) amount of materials from a house safe.
				01x05 - No checkpoint reason. The checkpoint handle hasn't had a string defined in getPlayerCheckpointReason()
				01x08 - Too many vehicles spawned (in danger of exceeding MAX_VEHICLES).

			Business Types:
			    0 - None
			    1 - 24/7
				2 - Clothing Store
				3 - Bar
				4 - Sex Shop
				5 - Car Dealership
				6 - Gym
				7 - Restaurant
*/

#include                <a_samp>
#include                <a_mysql>
#include                <zcmd>
#include                <foreach>
#include                <GeoIP_Plugin>
#include                <streamer>
#include                <OPSP>
#include				<a_zones>
#include                <sscanf2>

#include "modules/utils/defines.pwn"
#include "modules/utils/dialogs.pwn"
#include "modules/utils/variables.pwn"


main() {
	print("main() has been called.");
}

#include "modules/utils/publics.pwn"
#include "modules/utils/functions.pwn"
#include "modules/utils/shits.pwn"
#include "modules/admin/vx-admin.pwn"
#include "modules/player/vx-anims.pwn"
#include "modules/player/commands.pwn"
