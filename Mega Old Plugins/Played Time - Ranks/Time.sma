/* Plugin generated by AMXX-Studio */
/* TimePlayed with levels v1.0*/

#include <amxmodx>
#include <amxmisc>
#include <fvault>
#include <colorchat>

#define PLUGIN "Time"
#define VERSION "1.1"
#define AUTHOR "StarMazter"

#define MAXPLAYERS 32
#define MAX_BUFFER_LENGTH 2047

new szVault[] = "Time";

new iTotalLevels = 5;

new szLevels[][64] = {
	"Level 1, Noob, 1 Day (24 hours) Playtime.",
	"Level 2, Getting started, 3 Days (72 hours) Playtime.",
	"Level 3, Going up, 1 week (168 hours) Playtime.",
	"Level 4, Hero, 1 weeks and 3 days (240 hours) Playtime.",
	"Level 5, Legend, 2 weeks and 4 days (432 hours) playtime."
};

new szTimes[][64] = {
	"24",
	"72",
	"168",
	"240",
	"432"
};

new Trie:SaveTime;
new Trie:Rank;
new Trie:Name;

new TotalRanks;

new iCurrentTime[MAXPLAYERS+1];

new sBuffer[MAX_BUFFER_LENGTH + 1]  

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_clcmd("say /time", "CmdTimeTop"); // Register Commands.
	register_clcmd("say /mytime", "CmdTime");
	register_clcmd("say /levels", "CmdLevels");
}

public plugin_cfg()
{
	SaveTime = TrieCreate();
	Rank = TrieCreate()
	Name = TrieCreate()
	LoadData();
}

public plugin_end()
{
	TrieDestroy(SaveTime); // Delete Trie to prevent bugs
	TrieDestroy(Rank);
}

LoadData()
{
	new iTotal = fvault_size(szVault);

	new szSteamId[32], szName[32], szTime[32], szData[64], szKey[32];
	for( new i = 0; i < iTotal; i++ )
	{
		fvault_get_keyname(szVault, i, szSteamId, sizeof(szSteamId) - 1); // Return Saved Values.
		fvault_get_data(szVault, szSteamId, szData, sizeof(szData) - 1);
		
		parse(szData, szName, sizeof(szName) - 1, szTime, sizeof(szTime) - 1)
		
		TrieSetCell(SaveTime, szSteamId, str_to_num(szTime)) // Set the players new time to the Cell.
		
		num_to_str(TotalRanks, szKey, sizeof(szKey) - 1)
		
		TrieSetString(Name, szKey, szName)
		TrieSetCell(Rank, szKey, str_to_num(szTime))
		TotalRanks++
	}
}

SaveData(id)
{
	new szSteamId[32], szName[32], szTime[32], szData[64];
	get_user_authid(id, szSteamId, 31) // Retrieve Steamid.
	get_user_name(id, szName, 31)
	
	TrieSetCell(SaveTime, szSteamId, iCurrentTime[id]) // Set the players new time to the Cell.
	
	num_to_str(iCurrentTime[id], szTime, sizeof(szTime) - 1) // Set the num to a string
	formatex(szData, sizeof(szData) - 1, "^"%s^" %s", szName, szTime)
	
	fvault_set_data(szVault, szSteamId, szData) // Set data to the vault.
}

public client_authorized(id)
{
	new szSteamId[32];
	get_user_authid(id, szSteamId, sizeof(szSteamId) - 1) // Retrieve Steamid.
	
	TrieGetCell(SaveTime, szSteamId, iCurrentTime[id]); // Load user's old time.
}

public client_disconnect(id)
{
	new iAddTime = get_user_time(id); // Getting the user's hes current time.
	
	iCurrentTime[id] += iAddTime; // Adding  hes new time to hes old time.
	
	SaveData(id)
}

public CmdTimeTop(id)
{
	new iRanks[10], iRanking[10], szKey[5], iTemp, z
	
	for(new x; x < 10; x++)
	{
		for(new i=0; i <= TotalRanks; i++)
		{
			num_to_str(i, szKey, sizeof(szKey) - 1)
			TrieGetCell(Rank, szKey, iTemp)
			
			if(x == 0)
			{
				if(iRanks[x] < iTemp)
				{
					iRanks[x] = iTemp
					iRanking[x] = i
					
					if(z<x)
						z=x
				}
			}
			else
			{
				if(iRanks[x] < iTemp && iRanks[x-1] > iTemp)
				{
					iRanks[x] = iTemp
					iRanking[x] = i
					
					if(z<x)
						z=x
				}
			}
		}
	}
		
	new szName[32]
	new iLen
	
	iLen = format(sBuffer, MAX_BUFFER_LENGTH, "<body bgcolor=#000000><font color=#FFB000><pre>")
	iLen += format(sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, "#%s             %s              %s^n", "Rank", "Nick", "PlayedTime")
	
	for(new y; y <= z; y++)
	{
		num_to_str(iRanking[y], szKey, sizeof(szKey) - 1)
		TrieGetCell(Rank, szKey, iTemp)
		TrieGetString(Name, szKey, szName, sizeof(szName) - 1)
	
		iLen += format(sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, "#%i              %s                              %i ^n", y + 1, szName, iTemp)
	}
	
	show_motd(id, sBuffer, "Top 10 PlayedTime")
}



public CmdTime(id)
{
	new iSecTempTime, iLevel, iRank, iTime, szKey[5];
	
	iSecTempTime = (iCurrentTime[id] + get_user_time(id)) // Get user's current time
	
	for(new i; i < iTotalLevels; i++)
	{
		if((iSecTempTime/3600) >= str_to_num(szTimes[i])) // Compare with presseted levels.
		{
			iLevel++ // Add a level
		}
	}
	
	iRank=1
	
	for(new i; i < TotalRanks + 1; i++)
	{
		num_to_str(i, szKey, sizeof(szKey) - 1)
		TrieGetCell(Rank, szKey, iTime)
		
		if(iCurrentTime[id] < iTime)
		{
			iRank++
		}
	}
	
	ColorChat(id,RED,"^x01[^x04Time^x01]^x01 Your playing time is^x03 %i ^x01Houres, Rank :^x03 %i/%i ^x01[^x04%i Seconds^x01].", iSecTempTime/3600, iRank, TotalRanks, iSecTempTime);
	ColorChat(id,RED,"^x01[^x04Time^x01]^x01 %s", szLevels[iLevel])
}

public CmdLevels(id)
{
	ColorChat(id,RED,"^x01[^x04Time^x01]^x01 Please look into ur console.");
	
	for(new i; i < iTotalLevels; i++) 
	{
		console_print(id, "%s", szLevels[i]) // Print all levels in user's console
	}
}
	
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1053\\ f0\\ fs16 \n\\ par }
*/