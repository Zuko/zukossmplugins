//----------------------------------------DATA PACK--------------------------------------------
//Sniper possibility
new Handle:g_LIST_BLOCKS_JARATE_ID           = INVALID_HANDLE;  
new Handle:g_LIST_BLOCKS_JARATE_WINNER       = INVALID_HANDLE;  
new Handle:g_LIST_BLOCKS_JARATE_STEAM_ID     = INVALID_HANDLE; 

RC_Blocks_Jarate() {
	decl String:strQuery[255];
	new String:strTablePrefix[128];
	GetConVarString(g_CVTABLEPREFIX, strTablePrefix, sizeof(strTablePrefix));
	Format(strQuery, sizeof(strQuery), "SELECT * FROM `%sblocks_jarate`",strTablePrefix);
	SQL_TQuery		(g_HDATABASE, RC_Blocks_Jarate_After_Query, strQuery);
}

public RC_Blocks_Jarate_After_Query(Handle:owner, Handle:strHQuery, const String:error[], any:data) 
{
	if (strHQuery == INVALID_HANDLE)
	{
		LogMessage("Failed to retrieve 'Jarate' list from the database, %s",error);
		return;
	}
	g_BLOCKS_JARATE = SQL_GetRowCount(strHQuery);
	ClearAndResize(g_LIST_BLOCKS_JARATE_ID,g_BLOCKS_JARATE+1);
	ClearAndResize(g_LIST_BLOCKS_JARATE_WINNER,g_BLOCKS_JARATE+1);
	ClearAndResize(g_LIST_BLOCKS_JARATE_STEAM_ID,g_BLOCKS_JARATE+1);
	new i = 0;
	new strString[64];
	while (SQL_FetchRow(strHQuery)) {
		//0 - id
		SetArrayCell(g_LIST_BLOCKS_JARATE_ID, i, SQL_FetchInt(strHQuery, 0));
		
		SetArrayCell(g_LIST_BLOCKS_JARATE_WINNER, i, SQL_FetchInt(strHQuery, 1));
		//1 - content
		
		SQL_FetchString(strHQuery, 2,strString,sizeof(strString));
		SetArrayString(g_LIST_BLOCKS_JARATE_STEAM_ID, i, strString);
		
		if (g_LIST_BLOCKS_JARATE_ID == INVALID_HANDLE) {
			LogError("Invalid array!");
		}
		
		//Put our datapack into one of the main datapacks
		i++;
	}
}

public Action:blocks_sniper_jarate(UserMsg:msg_id, Handle:bf, const players[], playersNum, bool:reliable, bool:init)
{
	CreateTimer(0.1, DelaySniperExpire, bf);
	return Plugin_Continue;
}

public Action:DelaySniperExpire(Handle:hTimer, Handle:buffer)
{
	new strClient = BfReadByte(buffer);
	new strVictim = BfReadByte(buffer);
	
	new String:g_victimSteam[64];
	GetClientAuthString(strVictim, g_victimSteam, sizeof(g_victimSteam));
	new q_id = 0;
	new q_winner = 0;
	new Boolean:valid = true;
	new focusclient;
	new String:q_steamID[64];
	//lets get our specific datapack from the main datapack.
	
	for (new i = 0; i < g_BLOCKS_JARATE; i++)
	{
		valid = true;
		q_id 		= GetArrayCell(g_LIST_BLOCKS_JARATE_ID, i);
		q_winner 	= GetArrayCell(g_LIST_BLOCKS_JARATE_WINNER, i);
		GetArrayString(g_LIST_BLOCKS_JARATE_STEAM_ID, i, q_steamID, sizeof(q_steamID));
		
		if (valid) {
			
			if (q_winner == 1 && strClient) {
				focusclient = strClient;
			}
			if (q_winner == 0 && strVictim) {
				focusclient = strVictim;
			}
			if (!focusclient || IsFakeClient(focusclient))
				valid = false;
			
			if (!StrEqual(q_steamID,"") && !StrEqual(q_steamID,g_victimSteam))                                          	valid = false;
			if (valid) {            
				UpdateBlockStatus(focusclient, "jarate", q_id, 1);
				AchievementCheckCompletion(focusclient,"jarate", q_id, strClient, strVictim, strClient);
			}
		}
	}
	return Plugin_Continue;
}