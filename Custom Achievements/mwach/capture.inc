//----------------------------------------strData PACK--------------------------------------------
new Handle:g_LIST_BLOCKS_CAP_ID 			= INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_CAP_WINNER 		= INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_CAP_CAPTURETEAM 	= INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_CAP_MAP 			= INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_CAP_CAPTUREID 		= INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_CAP_CPID 			= INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_CAP_MINCAPPERS 	= INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_CAP_MAXCAPPERS 	= INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_CAP_CAPTURERCLASS 	= INVALID_HANDLE;

RC_Blocks_Capture() {
	decl String:strQuery[255];
	new String:strTablePrefix[128];
	GetConVarString(g_CVTABLEPREFIX, strTablePrefix, sizeof(strTablePrefix));
	Format(strQuery, sizeof(strQuery), "SELECT * FROM `%sblocks_capture`",strTablePrefix);
	SQL_TQuery		(g_HDATABASE, RC_Blocks_Capture_After_Query, strQuery);
}

public RC_Blocks_Capture_After_Query(Handle:owner, Handle:strHQuery, const String:error[], any:data) 
{
	if (strHQuery == INVALID_HANDLE)
	{
		LogMessage("Failed to retrieve 'capture' list from the database, %s",error);
		return;
	}
	g_BLOCKS_CAPTURE = SQL_GetRowCount(strHQuery);
	ClearAndResize(g_LIST_BLOCKS_CAP_ID,g_BLOCKS_CAPTURE+1);
	ClearAndResize(g_LIST_BLOCKS_CAP_MAP,g_BLOCKS_CAPTURE+1);
	ClearAndResize(g_LIST_BLOCKS_CAP_CAPTUREID,g_BLOCKS_CAPTURE+1);
	ClearAndResize(g_LIST_BLOCKS_CAP_CAPTURETEAM,g_BLOCKS_CAPTURE+1);
	ClearAndResize(g_LIST_BLOCKS_CAP_WINNER,g_BLOCKS_CAPTURE+1);
	ClearAndResize(g_LIST_BLOCKS_CAP_CPID,g_BLOCKS_CAPTURE+1);
	ClearAndResize(g_LIST_BLOCKS_CAP_MINCAPPERS,g_BLOCKS_CAPTURE+1);
	ClearAndResize(g_LIST_BLOCKS_CAP_MAXCAPPERS,g_BLOCKS_CAPTURE+1);
	ClearAndResize(g_LIST_BLOCKS_CAP_CAPTURERCLASS,g_BLOCKS_CAPTURE+1);
	
	new i = 0;
	new stString[512];
	while (SQL_FetchRow(strHQuery)) {
		
		//0 - id
		SetArrayCell(g_LIST_BLOCKS_CAP_ID, i, SQL_FetchInt(strHQuery, 0));
		
		//1 - winner
		SetArrayCell(g_LIST_BLOCKS_CAP_WINNER, i, SQL_FetchInt(strHQuery, 1));
		
		//2 - captureteam
		SetArrayCell(g_LIST_BLOCKS_CAP_CAPTURETEAM, i, SQL_FetchInt(strHQuery,2));
		
		//3 - map
		SQL_FetchString(strHQuery, 3,stString,sizeof(stString));
		SetArrayString(g_LIST_BLOCKS_CAP_MAP, i, stString);
		
		//4 - capturer id
		SQL_FetchString(strHQuery, 4,stString,sizeof(stString));
		SetArrayString(g_LIST_BLOCKS_CAP_CAPTUREID, i, stString);
		
		//5 - cp id
		SetArrayCell(g_LIST_BLOCKS_CAP_CPID, i, SQL_FetchInt(strHQuery, 5));
		
		//6 - min cappers
		SetArrayCell(g_LIST_BLOCKS_CAP_MINCAPPERS, i, SQL_FetchInt(strHQuery, 6));
		
		//7 - max cappers
		SetArrayCell(g_LIST_BLOCKS_CAP_MAXCAPPERS, i, SQL_FetchInt(strHQuery, 7));
		
		//8 - capturer class
		SQL_FetchString(strHQuery, 8,stString,sizeof(stString));
		SetArrayString(g_LIST_BLOCKS_CAP_CAPTURERCLASS, i, stString);
		
		if (g_LIST_BLOCKS_CAP_ID == INVALID_HANDLE) {
			LogError("Invalid strData Handle Saved!");
		}
		
		i++;
	}
}


//------------------------------------------CAPTURE BLOCKS-----------------------------------
public blocks_capture(Handle:event, const String:name[], bool:noBroadcast)
{
	decl String:cappers[MAXPLAYERS+1] = "";
	if (GetEventString(event,"cappers", cappers, MAXPLAYERS)>0) {
		
		new len = strlen(cappers);
		
		for(new i=0;i<len;i++)
		{
			new index  = cappers{i};
			new g_capteam = GetEventInt(event,"team")
			new g_cpid = GetEventInt(event,"cp")
			new q_id = 0;
			new q_capteam = 0;
			new q_capid = 0;
			new q_mincappers = -1;
			new q_maxcappers = -1;
			new String:q_capturer[128];
			new String:q_map[128];
			new Boolean:valid = false;
			new String:q_class[128];
			new String:sSteamId[128];
			GetClientAuthString(index, sSteamId, sizeof(sSteamId));
			new String:g_map[128];
			GetCurrentMap(g_map,sizeof(g_map));
			
			for (new i2 = 0; i2 < g_BLOCKS_CAPTURE; i2++) 
			{
				valid = true;
				q_id 		= GetArrayCell(g_LIST_BLOCKS_CAP_ID, i2);
				q_capteam 	= GetArrayCell(g_LIST_BLOCKS_CAP_CAPTURETEAM, i2);
				q_capid 	= GetArrayCell(g_LIST_BLOCKS_CAP_CPID, i2);
				GetArrayString(g_LIST_BLOCKS_CAP_MAP, i2, q_map, sizeof(q_map));
				GetArrayString(g_LIST_BLOCKS_CAP_CAPTUREID, i2, q_capturer, sizeof(q_capturer));
				q_mincappers = GetArrayCell(g_LIST_BLOCKS_CAP_MINCAPPERS, i2);
				q_maxcappers = GetArrayCell(g_LIST_BLOCKS_CAP_MAXCAPPERS, i2);
				GetArrayString(g_LIST_BLOCKS_CAP_CAPTURERCLASS, i2, q_class, sizeof(q_class));
				if ((q_mincappers >= 0) && (len < q_mincappers)) valid = false; 
				if ((q_maxcappers >= 0) && (len > q_maxcappers)) valid = false;
				if ((q_capteam >= 0) && (q_capteam != g_capteam)) valid = false; 
				if ((q_capid >= 0) && (q_capid != g_cpid)) valid = false; 
				if (!StrEqual(q_capturer,"") && !StrEqual(q_capturer,sSteamId)) valid = false;
				if (!StrEqual(q_map,"") && !StrEqual(q_map,g_map)) valid = false;
				if (!StrEqual(q_class,"") && (TF2_GetPlayerClass(index) != TF2_GetClass(q_class))) valid = false;
				if (!index || IsFakeClient(index)) valid = false;
				
				if (valid) {
					if (!index || IsFakeClient(index))
						valid = false;
					
					if (valid) {
						UpdateBlockStatus(index, "capture", q_id, 1);
						AchievementCheckCompletion(index,"capture",q_id,index,index,index);
					}
					
				}
			}
			
		}
	}
	return Plugin_Handled;
}