//----------------------------------------DATA PACK--------------------------------------------
//Engineer possibility
new Handle:g_LIST_BLOCKS_ENGI_PDA_ID = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_ENGI_PDA_OBJECT = INVALID_HANDLE;

RC_Blocks_Engineer_Pda() {
	decl String:strQuery[255];
	new String:strTablePrefix[128];
	GetConVarString(g_CVTABLEPREFIX, strTablePrefix, sizeof(strTablePrefix));
	Format(strQuery, sizeof(strQuery), "SELECT * FROM `%sblocks_engineer_pda`",strTablePrefix);
	SQL_TQuery		(g_HDATABASE, RC_Blocks_Engineer_Pda_After_Query, strQuery);
}

public RC_Blocks_Engineer_Pda_After_Query(Handle:owner, Handle:strHQuery, const String:error[], any:data) 
{
	if (strHQuery == INVALID_HANDLE)
	{
		LogMessage("Failed to retrieve user achievements list from the database, %s",error);
		return;
	}
	
	g_BLOCKS_ENGINEER_PDA = SQL_GetRowCount(strHQuery);
	ClearAndResize(g_LIST_BLOCKS_ENGI_PDA_ID,g_BLOCKS_ENGINEER_PDA+1);
	ClearAndResize(g_LIST_BLOCKS_ENGI_PDA_OBJECT,g_BLOCKS_ENGINEER_PDA+1);
	
	new i = 0;
	new strString[512];
	while (SQL_FetchRow(strHQuery)) {
		//0 - id
		SetArrayCell(g_LIST_BLOCKS_ENGI_PDA_ID, i, SQL_FetchInt(strHQuery, 0));
		SetArrayCell(g_LIST_BLOCKS_ENGI_PDA_OBJECT, i, SQL_FetchInt(strHQuery, 2));
		if (g_LIST_BLOCKS_ENGI_PDA_ID == INVALID_HANDLE) {
			LogError("Invalid array!");
		}
		
		//Put our datapack into one of the main datapacks
		i++;
	}
}

new Handle:g_LIST_BLOCKS_ENGI_TELE_ID = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_ENGI_TELE_WINNER = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_ENGI_TELE_OWNERID = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_ENGI_TELE_USERID = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_ENGI_TELE_USERCLASS = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_ENGI_TELE_SELFUSE = INVALID_HANDLE;

RC_Blocks_Engineer_Teleport() {
	decl String:strQuery[255];
	new String:strTablePrefix[128];
	GetConVarString(g_CVTABLEPREFIX, strTablePrefix, sizeof(strTablePrefix));
	Format(strQuery, sizeof(strQuery), "SELECT * FROM `%sblocks_engineer_teleport`",strTablePrefix);
	SQL_TQuery		(g_HDATABASE, RC_Blocks_Engineer_Teleport_After_Query, strQuery);
}

public RC_Blocks_Engineer_Teleport_After_Query(Handle:owner, Handle:strHQuery, const String:error[], any:data) 
{
	if (strHQuery == INVALID_HANDLE)
	{
		LogMessage("Failed to retrieve 'engineer teleport' list from the database, %s",error);
		return;
	}
	g_BLOCKS_ENGINEER_TELEPORT = SQL_GetRowCount(strHQuery);
	ClearAndResize(g_LIST_BLOCKS_ENGI_TELE_ID,g_BLOCKS_ENGINEER_TELEPORT+1);
	ClearAndResize(g_LIST_BLOCKS_ENGI_TELE_WINNER,g_BLOCKS_ENGINEER_TELEPORT+1);
	ClearAndResize(g_LIST_BLOCKS_ENGI_TELE_OWNERID,g_BLOCKS_ENGINEER_TELEPORT+1);
	ClearAndResize(g_LIST_BLOCKS_ENGI_TELE_USERID,g_BLOCKS_ENGINEER_TELEPORT+1);
	ClearAndResize(g_LIST_BLOCKS_ENGI_TELE_USERCLASS,g_BLOCKS_ENGINEER_TELEPORT+1);
	ClearAndResize(g_LIST_BLOCKS_ENGI_TELE_SELFUSE,g_BLOCKS_ENGINEER_TELEPORT+1);
	new i = 0;
	new strString[512];
	while (SQL_FetchRow(strHQuery)) {
		//0 - id
		SetArrayCell(g_LIST_BLOCKS_ENGI_TELE_ID, i, SQL_FetchInt(strHQuery, 0));
		SetArrayCell(g_LIST_BLOCKS_ENGI_TELE_WINNER, i, SQL_FetchInt(strHQuery, 1));
		
		SQL_FetchString(strHQuery, 2,strString,sizeof(strString));
		SetArrayString(g_LIST_BLOCKS_ENGI_TELE_OWNERID, i, strString);
		SQL_FetchString(strHQuery, 3,strString,sizeof(strString));
		SetArrayString(g_LIST_BLOCKS_ENGI_TELE_USERID, i, strString);
		SQL_FetchString(strHQuery, 4,strString,sizeof(strString));
		SetArrayString(g_LIST_BLOCKS_ENGI_TELE_USERCLASS, i, strString);
		SetArrayCell(g_LIST_BLOCKS_ENGI_TELE_SELFUSE, i, SQL_FetchInt(strHQuery, 5));
		
		if (g_LIST_BLOCKS_ENGI_TELE_ID == INVALID_HANDLE) {
			LogError("Invalid array!");
		}
		
		//Put our datapack into one of the main datapacks
		i++;
	}
}

//----------------------------------------ENGINEER BLOCKS----------------------------------------
public blocks_engineer_construction(Handle:argEvent, const String:name[], bool:noBroadcast) {
	//data
	new g_victimid = GetEventInt(argEvent, "userid");
	new g_object = GetEventInt(argEvent, "object");
	new g_victim = GetClientOfUserId(g_victimid);
	
	new String:g_victimSteam[128];
	if (g_victim && !IsFakeClient(g_victim)) GetClientAuthString(g_victim, g_victimSteam, sizeof(g_victimSteam));
	
	new q_id = 0;
	new q_winner = 0;
	new q_object = 0;
	new String:q_victimid[512];
	new valid = true;
	new focusclient;
	
	for(new i = 0; i < g_BLOCKS_ENGINEER_PDA; i++) {
		valid = true;
		
		//lets get our specific datapack from the main datapack.
		q_id = GetArrayCell(g_LIST_BLOCKS_ENGI_PDA_ID, i);
		q_object = GetArrayCell(g_LIST_BLOCKS_ENGI_PDA_OBJECT, i);
		
		if(q_object >= 0 && g_object >= 0 && q_object != g_object)                                                              valid = false;
		if (valid) {
			focusclient = g_victim;
			if (!focusclient || IsFakeClient(focusclient))
				valid = false;
			
			if (valid) {            
				UpdateBlockStatus(focusclient, "engineer_pda", q_id, 1);
				AchievementCheckCompletion(focusclient,"engineer_pda", q_id, g_victim, g_victim, g_victim);
			}
		}
	}	
}

public blocks_engineer_teleport(Handle:argEvent, const String:argName[], bool:dontBroadcast) {
	new g_ownerid = GetEventInt(argEvent, "builderid");
	new g_owner = GetClientOfUserId(g_ownerid);
	new g_userid = GetEventInt(argEvent, "userid");
	new g_user = GetClientOfUserId(g_userid);
	new g_selfuse = 0;
	
	new String:g_ownerSteam[128];
	if (g_owner && !IsFakeClient(g_owner)) GetClientAuthString(g_owner, g_ownerSteam, sizeof(g_ownerSteam));
	new String:g_userSteam[128];
	if (g_user && !IsFakeClient(g_user)) GetClientAuthString(g_user, g_userSteam, sizeof(g_userSteam));
	
	if (g_owner == g_user) g_selfuse = 1;
	
	new q_id = 0;
	new q_winner = 0;
	new q_class[128];
	new q_selfuse = -1;
	new q_ownerid[512];
	new q_userid[512];
	new valid = true;
	new focusclient;
	
	for(new i = 0; i < g_BLOCKS_ENGINEER_TELEPORT; i++) {
		valid = true;
		
		//lets get our specific datapack from the main datapack.
		q_id = GetArrayCell(g_LIST_BLOCKS_ENGI_TELE_ID, i);
		q_winner = GetArrayCell(g_LIST_BLOCKS_ENGI_TELE_WINNER, i);
		GetArrayString(g_LIST_BLOCKS_ENGI_TELE_OWNERID, i, q_ownerid, sizeof(q_ownerid));
		GetArrayString(g_LIST_BLOCKS_ENGI_TELE_USERID, i, q_userid, sizeof(q_userid));
		GetArrayString(g_LIST_BLOCKS_ENGI_TELE_USERCLASS, i, q_class, sizeof(q_class));
		q_selfuse = GetArrayCell(g_LIST_BLOCKS_ENGI_TELE_SELFUSE, i);
		
		
		if (!StrEqual(q_ownerid,"") && !StrEqual(q_ownerid,g_ownerSteam))                                                       valid = false;
		if (!StrEqual(q_userid,"") && !StrEqual(q_userid,g_userSteam))                                                          valid = false;
		if (!StrEqual(q_class,"") && g_user && (TF2_GetPlayerClass(g_user) != TF2_GetClass(q_class)))                           valid = false;
		if (q_selfuse >= 0 && q_selfuse != g_selfuse)                                                                           valid = false;
		
		if (!StrEqual(q_ownerid,"") && !g_owner)                                                                                valid = false;
		if ((!StrEqual(q_class,"") || !StrEqual(q_userid,"")) && !g_user)                                                       valid = false;
		
		if (valid) {
			
			if (q_winner == 0 && g_owner) {
				focusclient = g_owner;
			}
			if (q_winner == 1 && g_user) {
				focusclient = g_user;
			}
			if (!focusclient || IsFakeClient(focusclient))
				valid = false;
			
			if (valid) {            
				UpdateBlockStatus(focusclient, "engineer_teleport", q_id, 1);
				AchievementCheckCompletion(focusclient,"engineer_teleport", q_id, g_owner, g_user, g_user);
			}
		}
	}
}