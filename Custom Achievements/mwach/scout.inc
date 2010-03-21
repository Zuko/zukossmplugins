//----------------------------------------DATA PACK--------------------------------------------
//Scout possibility
new Handle:g_LIST_BLOCKS_BONK_ID 		= INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_STUNNER_ID 	= INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_STUNNER_WINNER = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_STUN_STEAM_ID  = INVALID_HANDLE;

RC_Blocks_Stunner() {
	decl String:strQuery[255];
	new String:strTablePrefix[128];
	GetConVarString(g_CVTABLEPREFIX, strTablePrefix, sizeof(strTablePrefix));
	Format(strQuery, sizeof(strQuery), "SELECT * FROM `%sblocks_stunner`",strTablePrefix);
	SQL_TQuery		(g_HDATABASE, RC_Blocks_Stunner_After_Query, strQuery);
}

public RC_Blocks_Stunner_After_Query(Handle:owner, Handle:strHQuery, const String:error[], any:data) 
{
	if (strHQuery == INVALID_HANDLE)
	{
		LogMessage("Failed to retrieve 'Stunner' list from the database, %s",error);
		return;
	}
	g_BLOCKS_STUNNER = SQL_GetRowCount(strHQuery);
	ClearAndResize(g_LIST_BLOCKS_STUNNER_ID,g_BLOCKS_STUNNER+1);
	ClearAndResize(g_LIST_BLOCKS_STUNNER_WINNER,g_BLOCKS_STUNNER+1);
	ClearAndResize(g_LIST_BLOCKS_STUN_STEAM_ID,g_BLOCKS_STUNNER+1);
	new i = 0;
	new strString[64];
	while (SQL_FetchRow(strHQuery)) {
		//0 - id
		SetArrayCell(g_LIST_BLOCKS_STUNNER_ID, i, SQL_FetchInt(strHQuery, 0));
		SetArrayCell(g_LIST_BLOCKS_STUNNER_WINNER, i, SQL_FetchInt(strHQuery, 1));
		
		SQL_FetchString(strHQuery, 2,strString,sizeof(strString));
		SetArrayString(g_LIST_BLOCKS_STUN_STEAM_ID, i, strString);
		
		if (g_LIST_BLOCKS_STUNNER_ID == INVALID_HANDLE) {
			LogError("Invalid array!");
		}
		
		//Put our datapack into one of the main datapacks
		i++;
	}
}

RC_Blocks_Bonk() {
	decl String:strQuery[255];
	new String:strTablePrefix[128];
	GetConVarString(g_CVTABLEPREFIX, strTablePrefix, sizeof(strTablePrefix));
	Format(strQuery, sizeof(strQuery), "SELECT * FROM `%sblocks_bonk`",strTablePrefix);
	SQL_TQuery		(g_HDATABASE, RC_Blocks_Bonk_After_Query, strQuery);
}

public RC_Blocks_Bonk_After_Query(Handle:owner, Handle:strHQuery, const String:error[], any:data) 
{
	if (strHQuery == INVALID_HANDLE)
	{
		LogMessage("Failed to retrieve 'Say' list from the database, %s",error);
		return;
	}
	g_BLOCKS_BONK = SQL_GetRowCount(strHQuery);
	ClearAndResize(g_LIST_BLOCKS_BONK_ID,g_BLOCKS_BONK+1);
	new i = 0;
	while (SQL_FetchRow(strHQuery)) {
		//0 - id
		SetArrayCell(g_LIST_BLOCKS_BONK_ID, i, SQL_FetchInt(strHQuery, 0));
		
		if (g_LIST_BLOCKS_BONK_ID == INVALID_HANDLE) {
			LogError("Invalid array!");
		}
		i++;
	}
}

//Scout Stunt
public Action:blocks_stunner(Handle:argEvent, const String:argName[], bool:argNoBroadcast)
{
	new strStunnerUserId = GetEventInt(argEvent, "stunner");
	new strStunner = GetClientOfUserId(strStunnerUserId);
	new strVictimUserId = GetEventInt(argEvent, "victim");
	new strVictim = GetClientOfUserId(strVictimUserId);
	
	new String:g_victimSteam[64];
	GetClientAuthString(strVictim, g_victimSteam, sizeof(g_victimSteam));
	new q_id = 0;
	new q_winner = 0;
	new Boolean:valid = true;
	new focusclient;
	new String:q_steamID[64];
	//lets get our specific datapack from the main datapack.
	for (new i = 0; i < g_BLOCKS_STUNNER; i++)
	{
		valid = true;
		q_id = GetArrayCell(g_LIST_BLOCKS_STUNNER_ID, i );
		q_winner = GetArrayCell(g_LIST_BLOCKS_STUNNER_WINNER, i);
		GetArrayString(g_LIST_BLOCKS_STUN_STEAM_ID, i, q_steamID, sizeof(q_steamID));
		if (valid) {
			
			if (q_winner == 1 && strStunner) {
				focusclient = strStunner;
			}
			if (q_winner == 0 && strVictim) {
				focusclient = strVictim;
			}
			if (!focusclient || IsFakeClient(focusclient))
				valid = false;
			if (!StrEqual(q_steamID,"") && !StrEqual(q_steamID,g_victimSteam)) valid = false;
			
			if (valid) {            
				UpdateBlockStatus(focusclient, "stunner", q_id, 1);
				AchievementCheckCompletion(focusclient, "stunner", q_id, strStunner, strVictim, strStunner);
			}
		}
	}
	return Plugin_Continue;
}

public Action:block_drinkbonk(argClient)
{
	new q_id;
	new Boolean:valid;
	new focusclient = argClient;
	for (new i = 0; i < g_BLOCKS_BONK ; i++)
	{			
		valid = true;
		q_id = GetArrayCell(g_LIST_BLOCKS_BONK_ID, i);
		
		if (!focusclient || IsFakeClient(focusclient))
			valid = false;
		
		if (valid) {            
			UpdateBlockStatus(focusclient, "bonk", q_id, 1);
			AchievementCheckCompletion(focusclient,"bonk", q_id, focusclient, focusclient, focusclient);
		}
	}
	return Plugin_Continue;}
