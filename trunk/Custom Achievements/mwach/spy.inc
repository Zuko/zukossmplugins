//----------------------------------------DATA PACK--------------------------------------------
//Spy possibility
new Handle:g_LIST_BLOCKS_RAZORBACK_ID           = INVALID_HANDLE;  
new Handle:g_LIST_BLOCKS_RAZORBACK_WINNER       = INVALID_HANDLE;  
RC_Blocks_Razorback() {
	decl String:strQuery[255];
	new String:strTablePrefix[128];
	GetConVarString(g_CVTABLEPREFIX, strTablePrefix, sizeof(strTablePrefix));
	Format(strQuery, sizeof(strQuery), "SELECT * FROM `%sblocks_razorback`",strTablePrefix);
	SQL_TQuery		(g_HDATABASE, RC_Blocks_Razorback_After_Query, strQuery);
}

public RC_Blocks_Razorback_After_Query(Handle:owner, Handle:strHQuery, const String:error[], any:data) 
{
	if (strHQuery == INVALID_HANDLE)
	{
		LogMessage("Failed to retrieve 'Razorback' list from the database, %s",error);
		return;
	}   
	g_BLOCKS_RAZORBACK = SQL_GetRowCount(strHQuery);
	ClearAndResize(g_LIST_BLOCKS_RAZORBACK_ID,g_BLOCKS_RAZORBACK+1);
	ClearAndResize(g_LIST_BLOCKS_RAZORBACK_WINNER,g_BLOCKS_RAZORBACK+1);
	new i = 0;
	while (SQL_FetchRow(strHQuery)) {
		SetArrayCell(g_LIST_BLOCKS_RAZORBACK_ID, i, SQL_FetchInt(strHQuery, 0));
		SetArrayCell(g_LIST_BLOCKS_RAZORBACK_WINNER, i, SQL_FetchInt(strHQuery, 1));
		
		if (g_LIST_BLOCKS_RAZORBACK_ID == INVALID_HANDLE) {
			LogError("Invalid array!");
		}
		
		//Put our datapack into one of the main datapacks
		i++;
	}
}


new Handle:g_LIST_BLOCKS_SAPPED_ID           = INVALID_HANDLE;  
new Handle:g_LIST_BLOCKS_SAPPED_WINNER       = INVALID_HANDLE; 
new Handle:g_LIST_BLOCKS_SAPPED_OBJECT       = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_SAPPED_STEAM_ID     = INVALID_HANDLE; 
RC_Blocks_Sapped() {
	decl String:strQuery[255];
	new String:strTablePrefix[128];
	GetConVarString(g_CVTABLEPREFIX, strTablePrefix, sizeof(strTablePrefix));
	Format(strQuery, sizeof(strQuery), "SELECT * FROM `%sblocks_sapped`",strTablePrefix);
	SQL_TQuery		(g_HDATABASE, RC_Blocks_Sapped_After_Query, strQuery);
}

public RC_Blocks_Sapped_After_Query(Handle:owner, Handle:strHQuery, const String:error[], any:data) 
{
	if (strHQuery == INVALID_HANDLE)
	{
		LogMessage("Failed to retrieve 'Sapped' list from the database, %s",error);
		return;
	}   
	g_BLOCKS_SAPPED = SQL_GetRowCount(strHQuery);
	ClearAndResize(g_LIST_BLOCKS_SAPPED_ID,g_BLOCKS_RAZORBACK+1);
	ClearAndResize(g_LIST_BLOCKS_SAPPED_WINNER,g_BLOCKS_RAZORBACK+1);
	ClearAndResize(g_LIST_BLOCKS_SAPPED_OBJECT,g_BLOCKS_RAZORBACK+1);
	ClearAndResize(g_LIST_BLOCKS_SAPPED_STEAM_ID,g_BLOCKS_RAZORBACK+1);
	new i = 0;
	new strString[512];
	while (SQL_FetchRow(strHQuery)) {
		SetArrayCell(g_LIST_BLOCKS_SAPPED_ID, i, SQL_FetchInt(strHQuery, 0));
		SetArrayCell(g_LIST_BLOCKS_SAPPED_WINNER, i, SQL_FetchInt(strHQuery, 1));
		SetArrayCell(g_LIST_BLOCKS_SAPPED_OBJECT, i, SQL_FetchInt(strHQuery, 2));
		SQL_FetchString(strHQuery, 3,strString,sizeof(strString));
		SetArrayString(g_LIST_BLOCKS_SAPPED_STEAM_ID, i, strString);
		
		if (g_LIST_BLOCKS_SAPPED_ID == INVALID_HANDLE) {
			LogError("Invalid array!");
		}
		
		//Put our datapack into one of the main datapacks
		i++;
	}
}

public blocks_spy_sapped(Handle:argEvent, const String:argName[], bool:dontBroadcast)
{
	new strTargetUserid 	= GetEventInt(argEvent, "userid");
	new strOwnerUserid 		= GetEventInt(argEvent, "ownerid");
	new strObjectSapped	 	= GetEventInt(argEvent, "object");
	new strTarget = GetClientOfUserId(strTargetUserid);
	new strOwner = GetClientOfUserId(strOwnerUserid);
	new String:strSteamIDOwner[64];
	if (strOwner && !IsFakeClient(strOwner)) GetClientAuthString(strOwner, strSteamIDOwner, sizeof(strSteamIDOwner));
	
	new q_id;
	new q_winner;
	new Boolean:valid = true;
	new focusclient;
	new focusobject;
	new String:q_steamId[64];
	for (new i = 0; i < g_BLOCKS_SAPPED; i++)
	{	
		valid = true;
		q_id 		= GetArrayCell(g_LIST_BLOCKS_SAPPED_ID, i);
		q_winner 	= GetArrayCell(g_LIST_BLOCKS_SAPPED_WINNER, i);
		focusobject	= GetArrayCell(g_LIST_BLOCKS_SAPPED_OBJECT, i);
		GetArrayString(g_LIST_BLOCKS_SAPPED_STEAM_ID, i, q_steamId, sizeof(q_steamId));
		
		if (!StrEqual(q_steamId,"") && !StrEqual(q_steamId,strSteamIDOwner))                                                          valid = false;
		if (focusobject > -1 && focusobject != strObjectSapped)                                                                		  valid = false;
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
				UpdateBlockStatus(focusclient, "sapped", q_id, 1);
				AchievementCheckCompletion(focusclient,"sapped", q_id, strTarget, strOwner, strTarget);
			}
		}
	}
}

public Action:blocks_razorback(UserMsg:msg_id, Handle:bf, const players[], playersNum, bool:reliable, bool:init)
{
	CreateTimer(0.1, DelaySpyExpire, bf);
	return Plugin_Continue;
}

public Action:DelaySpyExpire(Handle:hTimer, Handle:buffer)
{
	new strClient = BfReadByte(buffer);
	new strVictim = BfReadByte(buffer);
	
	new q_id = 0;
	new q_winner = 0;
	new Boolean:valid;
	new focusclient;
	//lets get our specific datapack from the main datapack.
	for (new i = 0; i < g_BLOCKS_RAZORBACK; i++)
	{
		valid = true;
		q_id = GetArrayCell(g_LIST_BLOCKS_RAZORBACK_ID, i );
		q_winner = GetArrayCell(g_LIST_BLOCKS_RAZORBACK_WINNER, i);
		if (valid) {
			
			if (q_winner == 1 && strClient) {
				focusclient = strClient;
			}
			if (q_winner == 0 && strVictim) {
				focusclient = strVictim;
			}
			if (!focusclient || IsFakeClient(focusclient))
				valid = false;
			
			if (valid) {            
				UpdateBlockStatus(focusclient, "razorback", q_id, 1);
				AchievementCheckCompletion(focusclient,"razorback", q_id, strClient, strVictim, strClient);
			}
		}
	}
	return Plugin_Continue;
}