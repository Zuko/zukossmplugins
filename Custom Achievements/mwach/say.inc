new Handle:g_LIST_BLOCKS_SAY_ID = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_SAY_METHOD = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_SAY_CONTENT = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_SAY_MAP = INVALID_HANDLE;

//----------------------------------------DATA PACK--------------------------------------------
RC_Blocks_Say() {
	decl String:strQuery[255];
	new String:strTablePrefix[128];
	GetConVarString(g_CVTABLEPREFIX, strTablePrefix, sizeof(strTablePrefix));
	Format(strQuery, sizeof(strQuery), "SELECT * FROM `%sblocks_say`",strTablePrefix);
	SQL_TQuery		(g_HDATABASE, RC_Blocks_Say_After_Query, strQuery);
}

public RC_Blocks_Say_After_Query(Handle:owner, Handle:strHQuery, const String:error[], any:data) 
{
	if (strHQuery == INVALID_HANDLE)
	{
		LogMessage("Failed to retrieve 'Say' list from the database, %s",error);
		return;
	}
	g_BLOCKS_SAY = SQL_GetRowCount(strHQuery);
	ClearAndResize(g_LIST_BLOCKS_SAY_ID,g_BLOCKS_SAY+1);
	ClearAndResize(g_LIST_BLOCKS_SAY_METHOD,g_BLOCKS_SAY+1);
	ClearAndResize(g_LIST_BLOCKS_SAY_CONTENT,g_BLOCKS_SAY+1);
	ClearAndResize(g_LIST_BLOCKS_SAY_MAP,g_BLOCKS_SAY+1);
	
	new i = 0;
	new String:strString[255];
	while (SQL_FetchRow(strHQuery)) 
	{
		//0 - id
		SetArrayCell(g_LIST_BLOCKS_SAY_ID, i, SQL_FetchInt(strHQuery, 0));
		
		//1 - method
		SetArrayCell(g_LIST_BLOCKS_SAY_METHOD, i ,SQL_FetchInt(strHQuery, 1));
		
		//2 - content
		SQL_FetchString(strHQuery, 2,strString,sizeof(strString));
		SetArrayString(g_LIST_BLOCKS_SAY_CONTENT, i, strString);
		
		//3 - map
		SQL_FetchString(strHQuery, 3,strString,sizeof(strString));
		SetArrayString(g_LIST_BLOCKS_SAY_MAP, i, strString);
		
		if (g_LIST_BLOCKS_SAY_ID == INVALID_HANDLE) {
			LogError("Invalid array!");
		}
		
		i++;
	}
}

//----------------------------------------SAY BLOCKS----------------------------------------
public Action:blocks_say(client, args)
{
	decl String:text[192];
	if (!GetCmdArgString(text, sizeof(text)))
	{
		return Plugin_Continue;
	}
	new startidx = 0;
	if(text[strlen(text)-1] == '"')
	{
		text[strlen(text)-1] = '\0';
		startidx = 1;
	}
	
	new ReplySource:old = SetCmdReplySource(SM_REPLY_TO_CHAT);
	SetCmdReplySource(old);
	//find correct blocks
	new q_method = 0;
	new String:q_content[512];
	new String:q_map[128];
	new q_id = 0;
	new Boolean:valid = true;
	
	new String:g_map[128];
	GetCurrentMap(g_map,sizeof(g_map));
	
	for(new i = 0; i < g_BLOCKS_SAY; i++) {
		valid = true;
		
		q_id 		= GetArrayCell(g_LIST_BLOCKS_SAY_ID,i);
		q_method 	= GetArrayCell(g_LIST_BLOCKS_SAY_METHOD, i);
		GetArrayString(g_LIST_BLOCKS_SAY_CONTENT, i, q_content, sizeof(q_content));
		GetArrayString(g_LIST_BLOCKS_SAY_MAP, i, q_map, sizeof(q_map));
		
		
		if (!StrEqual(q_content,"") && (q_method == 0) && !StrEqual(q_content,text[startidx])) valid = false;
		if (!StrEqual(q_content,"") && (q_method == 1) && (StrContains(text[startidx],q_content) == -1)) valid = false;
		if (!StrEqual(q_map,"") && !StrEqual(q_map,g_map)) valid = false;
		
		
		if (valid) {
			if (!client || IsFakeClient(client))
				valid = false;
			
			if (valid) {
				UpdateBlockStatus(client, "say", q_id, 1);
				AchievementCheckCompletion(client,"say",q_id,client,client,client);
			}
			
		}
	}
	return Plugin_Continue;
}