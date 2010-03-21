new Handle:g_LIST_BLOCKS_STICKYJUMP_ID       = INVALID_HANDLE;   // Medic list

RC_Blocks_stickyjump() {
	decl String:strQuery[255];
	new Handle:strHQuery;
	new String:strTablePrefix[128];
	GetConVarString(g_CVTABLEPREFIX, strTablePrefix, sizeof(strTablePrefix));
	Format(strQuery, sizeof(strQuery), "SELECT * FROM `%sblocks_stickyjump`",strTablePrefix);
	SQL_TQuery		(g_HDATABASE, RC_Blocks_StickyJump_After_Query, strQuery);
}

public RC_Blocks_StickyJump_After_Query(Handle:owner, Handle:strHQuery, const String:error[], any:data) 
{
	if (strHQuery == INVALID_HANDLE)
	{
		LogMessage("Failed to retrieve 'RocketJump' list from the database, %s",error);
		return;
	}
	g_BLOCKS_STICKYJUMP = SQL_GetRowCount(strHQuery);
	ClearAndResize(g_LIST_BLOCKS_STICKYJUMP_ID,g_BLOCKS_STICKYJUMP+1);
	
	new i = 0;
	while (SQL_FetchRow(strHQuery)) {
		//0 - id
		SetArrayCell(g_LIST_BLOCKS_STICKYJUMP_ID, i, SQL_FetchInt(strHQuery, 0));   
		if (g_BLOCKS_STICKYJUMP == INVALID_HANDLE) {
			LogError("Invalid array!");
		}
		
		//Put our datapack into one of the main datapacks
		i++;
	}
}

public blocks_stickyjump(Handle:argEvent, const String:name[], bool:noBroadcast)
{
	new strClientId = GetEventInt(argEvent, "userid");
	new strClient = GetClientOfUserId(strClientId);
	new q_id = 0;
	new Boolean:valid = true;
	new focusclient;
	for(new i = 0; i < g_BLOCKS_STICKYJUMP; i++) {
		valid = true;
		
		q_id 		= GetArrayCell(g_LIST_BLOCKS_STICKYJUMP_ID, i);
		if (valid) {
			
			focusclient = strClient;
			if (!focusclient || IsFakeClient(focusclient))
				valid = false;
			
			if (valid) { 
				
				UpdateBlockStatus(focusclient, "stickyjump", q_id, 1);
				AchievementCheckCompletion(focusclient, "stickyjump", q_id, focusclient, focusclient, focusclient);
			}
		}
	}
}
