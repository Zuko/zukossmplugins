new Handle:g_LIST_BLOCKS_DEPLOYBANNER_ID       = INVALID_HANDLE;   // Medic list

RC_Blocks_DeployBanner() {
	decl String:strQuery[255];
	new Handle:strHQuery;
	new String:strTablePrefix[128];
	GetConVarString(g_CVTABLEPREFIX, strTablePrefix, sizeof(strTablePrefix));
	Format(strQuery, sizeof(strQuery), "SELECT * FROM `%sblocks_banner`",strTablePrefix);
	SQL_TQuery		(g_HDATABASE, RC_Blocks_DeployBanner_After_Query, strQuery);
}

public RC_Blocks_DeployBanner_After_Query(Handle:owner, Handle:strHQuery, const String:error[], any:data) 
{
	if (strHQuery == INVALID_HANDLE)
	{
		LogMessage("Failed to retrieve 'BuffBanner' list from the database, %s",error);
		return;
	}
	g_BLOCKS_DEPLOYBANNER = SQL_GetRowCount(strHQuery);
	ClearAndResize(g_LIST_BLOCKS_DEPLOYBANNER_ID,g_BLOCKS_DEPLOYBANNER+1);
	
	new i = 0;
	while (SQL_FetchRow(strHQuery)) {
		//0 - id
		SetArrayCell(g_LIST_BLOCKS_DEPLOYBANNER_ID, i, SQL_FetchInt(strHQuery, 0));   
		if (g_BLOCKS_DEPLOYBANNER == INVALID_HANDLE) {
			LogError("Invalid array!");
		}
		
		//Put our datapack into one of the main datapacks
		i++;
	}
}

public blocks_deployBanner(Handle:argEvent, const String:name[], bool:noBroadcast)
{
	new strClientId = GetEventInt(argEvent, "buff_owner");
	new strClient = GetClientOfUserId(strClientId);
	new q_id = 0;
	new Boolean:valid = true;
	new focusclient;
	for(new i = 0; i < g_BLOCKS_DEPLOYBANNER; i++) {
		valid = true;
		
		q_id 		= GetArrayCell(g_LIST_BLOCKS_DEPLOYBANNER_ID, i);
		if (valid) {
			
			focusclient = strClient;
			if (!focusclient || IsFakeClient(focusclient))
				valid = false;
			
			if (valid) { 
				
				UpdateBlockStatus(focusclient, "banner", q_id, 1);
				AchievementCheckCompletion(focusclient, "banner", q_id, focusclient, focusclient, focusclient);
			}
		}
}
}

new Handle:g_LIST_BLOCKS_ROCKETJUMP_ID       = INVALID_HANDLE;   // Medic list

RC_Blocks_rocketjump() {
	decl String:strQuery[255];
	new Handle:strHQuery;
	new String:strTablePrefix[128];
	GetConVarString(g_CVTABLEPREFIX, strTablePrefix, sizeof(strTablePrefix));
	Format(strQuery, sizeof(strQuery), "SELECT * FROM `%sblocks_rocketjump`",strTablePrefix);
	SQL_TQuery		(g_HDATABASE, RC_Blocks_RocketJump_After_Query, strQuery);
}

public RC_Blocks_RocketJump_After_Query(Handle:owner, Handle:strHQuery, const String:error[], any:data) 
{
	if (strHQuery == INVALID_HANDLE)
	{
		LogMessage("Failed to retrieve 'RocketJump' list from the database, %s",error);
		return;
	}
	g_BLOCKS_ROCKETJUMP = SQL_GetRowCount(strHQuery);
	ClearAndResize(g_LIST_BLOCKS_ROCKETJUMP_ID,g_BLOCKS_ROCKETJUMP+1);
	
	new i = 0;
	while (SQL_FetchRow(strHQuery)) {
		//0 - id
		SetArrayCell(g_LIST_BLOCKS_ROCKETJUMP_ID, i, SQL_FetchInt(strHQuery, 0));   
		if (g_BLOCKS_ROCKETJUMP == INVALID_HANDLE) {
			LogError("Invalid array!");
		}
		
		//Put our datapack into one of the main datapacks
		i++;
	}
}

public blocks_rocketjump(Handle:argEvent, const String:name[], bool:noBroadcast)
{
	new strClientId = GetEventInt(argEvent, "userid");
	new strClient = GetClientOfUserId(strClientId);
	new q_id = 0;
	new Boolean:valid = true;
	new focusclient;
	for(new i = 0; i < g_BLOCKS_ROCKETJUMP; i++) {
		valid = true;
		
		q_id 		= GetArrayCell(g_LIST_BLOCKS_ROCKETJUMP_ID, i);
		if (valid) {
			
			focusclient = strClient;
			if (!focusclient || IsFakeClient(focusclient))
				valid = false;
			
			if (valid) { 
				
				UpdateBlockStatus(focusclient, "rocketjump", q_id, 1);
				AchievementCheckCompletion(focusclient, "rocketjump", q_id, focusclient, focusclient, focusclient);
			}
		}
	}
}