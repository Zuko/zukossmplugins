//----------------------------------------DATA PACK--------------------------------------------
//Heavy possibility
new Handle:g_LIST_BLOCKS_STEALSANDWICH_ID    		= INVALID_HANDLE; // Heavy list
new Handle:g_LIST_BLOCKS_STEALSANDWICH_WINNER     	= INVALID_HANDLE; // Heavy list
RC_Blocks_stealsandvitch() {
	decl String:strQuery[255];
	new String:strTablePrefix[128];
	GetConVarString(g_CVTABLEPREFIX, strTablePrefix, sizeof(strTablePrefix));
	Format(strQuery, sizeof(strQuery), "SELECT * FROM `%sblocks_stealsandwich`",strTablePrefix);
	SQL_TQuery		(g_HDATABASE, RC_Blocks_stealsandvitch_After_Query, strQuery);
}

public RC_Blocks_stealsandvitch_After_Query(Handle:owner, Handle:strHQuery, const String:error[], any:data) 
{
	if (strHQuery == INVALID_HANDLE)
	{
		LogMessage("Failed to retrieve 'steak sandvitch' list from the database, %s",error);
		return;
	}
	g_BLOCKS_STEALSANDWICH = SQL_GetRowCount(strHQuery);
	ClearAndResize(g_LIST_BLOCKS_STEALSANDWICH_ID,g_BLOCKS_STEALSANDWICH+1);
	ClearAndResize(g_LIST_BLOCKS_STEALSANDWICH_WINNER,g_BLOCKS_STEALSANDWICH+1);
	
	new i = 0;
	while (SQL_FetchRow(strHQuery)) {
		//0 - id
		SetArrayCell(g_LIST_BLOCKS_STEALSANDWICH_ID, i, SQL_FetchInt(strHQuery, 0));
		SetArrayCell(g_LIST_BLOCKS_STEALSANDWICH_WINNER, i, SQL_FetchInt(strHQuery, 1));
		
		if (g_LIST_BLOCKS_STEALSANDWICH_ID == INVALID_HANDLE) {
			LogError("Invalid array!");
		}
		
		i++;
	}
}

new Handle:g_LIST_BLOCKS_EATSANDWICH_ID    		= INVALID_HANDLE; // Heavy list
RC_Blocks_eatsandwich() {
	decl String:strQuery[255];
	new String:strTablePrefix[128];
	GetConVarString(g_CVTABLEPREFIX, strTablePrefix, sizeof(strTablePrefix));
	Format(strQuery, sizeof(strQuery), "SELECT * FROM `%sblocks_eatsandwich`",strTablePrefix);
	SQL_TQuery		(g_HDATABASE, RC_Blocks_eatsandwich_After_Query, strQuery);
}

public RC_Blocks_eatsandwich_After_Query(Handle:owner, Handle:strHQuery, const String:error[], any:data) 
{
	if (strHQuery == INVALID_HANDLE)
	{
		LogMessage("Failed to retrieve 'eat sandwitch' list from the database, %s",error);
		return;
	}    
	g_BLOCKS_EATSANDWICH = SQL_GetRowCount(strHQuery);
	ClearAndResize(g_LIST_BLOCKS_EATSANDWICH_ID,g_BLOCKS_EATSANDWICH+1);
	new i = 0;
	while (SQL_FetchRow(strHQuery)) {
		//0 - id
		SetArrayCell(g_LIST_BLOCKS_EATSANDWICH_ID, i, SQL_FetchInt(strHQuery, 0));
		
		if (g_LIST_BLOCKS_EATSANDWICH_ID == INVALID_HANDLE) {
			LogError("Invalid array!");
		}
		
		//Put our datapack into one of the main datapacks
		i++;
	}
}


public blocks_heavy_steal(Handle:argEvent, const String:argName[], bool:dontBroadcast)
{
	new strTargetUserid = GetEventInt(argEvent, "target");
	new strOwnerUserid = GetEventInt(argEvent, "owner");
	new strTarget = GetClientOfUserId(strTargetUserid);
	new strOwner = GetClientOfUserId(strOwnerUserid);
	
	new q_id;
	new q_winner;
	new Boolean:valid = true;
	new focusclient;
	for (new i = 0; i < g_BLOCKS_STEALSANDWICH; i++)
	{	
		valid = true;
		q_id 		= GetArrayCell(g_LIST_BLOCKS_STEALSANDWICH_ID, i);
		q_winner 	= GetArrayCell(g_LIST_BLOCKS_STEALSANDWICH_WINNER, i);
		if (valid) {
			
			if (q_winner == 1 && strTarget) {
				focusclient = strTarget;
			}
			if (q_winner == 0 && strOwner) {
				focusclient = strOwner;
			}
			if (!focusclient || IsFakeClient(focusclient))
				valid = false;
			
			if (valid) {            
				UpdateBlockStatus(focusclient, "stealsandwich", q_id, 1);
				AchievementCheckCompletion(focusclient,"stealsandwich", q_id, strTarget, strOwner, strTarget);
			}
		}
	}
}

public Action:HookSound_HeavyEat(Clients[64], &NumClients, String:StrSample[PLATFORM_MAX_PATH], &Entity)
{
	if (StrContains(StrSample, "sandwicheat", false) == -1)    
		return Plugin_Continue;
	else
	{
		new q_id;
		new Boolean:valid = true;
		new focusclient;
		for (new i = 0; i < g_BLOCKS_EATSANDWICH; i++)
		{			
			valid = true;
			q_id = GetArrayCell(g_LIST_BLOCKS_EATSANDWICH_ID, i);
			
			if (Entity != 0)
			{
				focusclient = Entity;
			}
			if (!focusclient || IsFakeClient(focusclient))
				valid = false;
			
			if (valid) {            
				UpdateBlockStatus(focusclient, "eatsandwich", q_id, 1);
				AchievementCheckCompletion(focusclient,"eatsandwich", q_id, focusclient, focusclient, focusclient);
			}
		}
	}
	return Plugin_Continue;}
