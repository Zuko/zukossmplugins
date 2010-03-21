new Handle:g_LIST_BLOCKS_HURT_ID 		= INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_HURT_WINNER 	= INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_HURT_ATTACKERID = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_HURT_VICTIMID	 = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_HURT_CRIT 		 = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_HURT_DMGMIN 	 = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_HURT_DMGMAX 	 = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_HURT_SELFDMG 	 = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_HURT_MAP 		 = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_HURT_ATTACKCLASS= INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_HURT_VICTIMCLASS = INVALID_HANDLE;


//----------------------------------------DATA PACK--------------------------------------------
RC_Blocks_Hurt() {
	decl String:strQuery[255];
	new String:sTablePrefix[128];
	GetConVarString(g_CVTABLEPREFIX, sTablePrefix, sizeof(sTablePrefix));
	Format(strQuery, sizeof(strQuery), "SELECT * FROM `%sblocks_hurt`",sTablePrefix);
	SQL_TQuery		(g_HDATABASE, RC_Blocks_Hurt_After_Query, strQuery);
}

public RC_Blocks_Hurt_After_Query(Handle:owner, Handle:strHQuery, const String:error[], any:data) 
{
	if (strHQuery == INVALID_HANDLE)
	{
		LogMessage("Failed to retrieve 'hurt' list from the database, %s",error);
		return;
	}
	g_BLOCKS_HURT = SQL_GetRowCount(strHQuery);
	ClearAndResize(g_LIST_BLOCKS_HURT_ID,g_BLOCKS_HURT+1);
	ClearAndResize(g_LIST_BLOCKS_HURT_WINNER,g_BLOCKS_HURT+1);
	ClearAndResize(g_LIST_BLOCKS_HURT_ATTACKERID,g_BLOCKS_HURT+1);
	ClearAndResize(g_LIST_BLOCKS_HURT_VICTIMID,g_BLOCKS_HURT+1);
	ClearAndResize(g_LIST_BLOCKS_HURT_CRIT,g_BLOCKS_HURT+1);
	ClearAndResize(g_LIST_BLOCKS_HURT_DMGMIN,g_BLOCKS_HURT+1);
	ClearAndResize(g_LIST_BLOCKS_HURT_DMGMAX,g_BLOCKS_HURT+1);
	ClearAndResize(g_LIST_BLOCKS_HURT_SELFDMG,g_BLOCKS_HURT+1);
	ClearAndResize(g_LIST_BLOCKS_HURT_MAP,g_BLOCKS_HURT+1);
	ClearAndResize(g_LIST_BLOCKS_HURT_ATTACKCLASS,g_BLOCKS_HURT+1);
	ClearAndResize(g_LIST_BLOCKS_HURT_VICTIMCLASS,g_BLOCKS_HURT+1);
	
	new i = 0;
	new string[512];
	while (SQL_FetchRow(strHQuery)) {
		
		SetArrayCell(g_LIST_BLOCKS_HURT_ID, i, SQL_FetchInt(strHQuery, 0));
		
		//1 - winner
		SetArrayCell(g_LIST_BLOCKS_HURT_WINNER, i, SQL_FetchInt(strHQuery, 1));
		
		//2 - attacker id
		SQL_FetchString(strHQuery, 2,string,sizeof(string));
		SetArrayString(g_LIST_BLOCKS_HURT_ATTACKERID, i, string);
		
		//3 - victim id
		SQL_FetchString(strHQuery, 3,string,sizeof(string));
		SetArrayString(g_LIST_BLOCKS_HURT_VICTIMID, i, string);
		
		//4 - crit
		SetArrayCell(g_LIST_BLOCKS_HURT_CRIT, i, SQL_FetchInt(strHQuery, 4));
		
		//5 - dmg min
		SetArrayCell(g_LIST_BLOCKS_HURT_DMGMIN, i, SQL_FetchInt(strHQuery, 5));
		
		//6 - dmg max
		SetArrayCell(g_LIST_BLOCKS_HURT_DMGMAX, i, SQL_FetchInt(strHQuery, 6));
		
		//7 - selfdmg
		SetArrayCell(g_LIST_BLOCKS_HURT_SELFDMG, i, SQL_FetchInt(strHQuery, 7));
		
		//8 - attacker class
		SQL_FetchString(strHQuery, 8,string,sizeof(string));
		SetArrayString(g_LIST_BLOCKS_HURT_MAP, i, string);
		
		//9 - attacker class
		SQL_FetchString(strHQuery, 9,string,sizeof(string));
		SetArrayString(g_LIST_BLOCKS_HURT_ATTACKCLASS, i, string);
		
		//10 - attacker class
		SQL_FetchString(strHQuery, 10,string,sizeof(string));
		SetArrayString(g_LIST_BLOCKS_HURT_VICTIMCLASS, i, string);
		
		if (g_LIST_BLOCKS_HURT_ID == INVALID_HANDLE) {
			LogError("Invalid array!");
		}
		
		//Put our datapack into one of the main datapacks
		i++;
	}
}

//----------------------------------------HURT BLOCKS----------------------------------------
public Action:blocks_hurt(Handle:event, const String:name[], bool:noBroadcast)
{
	//data
	new g_attackerid = 0;
	new g_victimid = 0;
	new g_damage = 0;
	new boolean:g_crit = false;
	g_attackerid = GetEventInt(event, "attacker");
	g_victimid = GetEventInt(event, "userid");
	g_crit = GetEventBool(event, "crit");
	g_damage = GetEventInt(event, "damageamount");
	
	//find correct blocks
	new g_selfdmg = 0;
	new String:g_map[128];
	new g_attacker = GetClientOfUserId(g_attackerid);
	new g_victim = GetClientOfUserId(g_victimid);
	new String:g_attackerSteam[128];
	if (g_attacker && !IsFakeClient(g_attacker)) GetClientAuthString(g_attacker, g_attackerSteam, sizeof(g_attackerSteam));
	new String:g_victimSteam[128];
	if (g_victim && !IsFakeClient(g_victim)) GetClientAuthString(g_victim, g_victimSteam, sizeof(g_victimSteam));
	if (g_victim == g_attacker) g_selfdmg = 1;
	GetCurrentMap(g_map,sizeof(g_map));
	new q_id = 0;
	new q_winner = 0;
	new q_crit = -1;
	new q_dmgmin = -1;
	new q_dmgmax = -1;
	new q_selfdmg = 0;
	new String:q_attackerid[128];
	new String:q_victimid[128];
	new String:q_map[128];
	new focusclient = 0;
	new String:q_attackerclass[128];
	new String:q_victimclass[128];
	
	new Boolean:valid = true;
	
	for(new i = 0; i < g_BLOCKS_HURT; i++) {
		valid = true;
		
		q_id			= 	GetArrayCell(g_LIST_BLOCKS_HURT_ID, i);
		q_winner		=	GetArrayCell(g_LIST_BLOCKS_HURT_WINNER, i);
		q_crit			=	GetArrayCell(g_LIST_BLOCKS_HURT_CRIT, i);
		q_dmgmin		=	GetArrayCell(g_LIST_BLOCKS_HURT_DMGMIN, i);
		q_dmgmax		=	GetArrayCell(g_LIST_BLOCKS_HURT_DMGMAX, i);
		
		GetArrayString(g_LIST_BLOCKS_HURT_ATTACKERID, i, q_attackerid, sizeof(q_attackerid));
		GetArrayString(g_LIST_BLOCKS_HURT_VICTIMID, i, q_victimid, sizeof(q_victimid));
		GetArrayString(g_LIST_BLOCKS_HURT_MAP, i, q_map, sizeof(q_map));
		GetArrayString(g_LIST_BLOCKS_HURT_ATTACKCLASS, i, q_attackerclass, sizeof(q_attackerclass));
		GetArrayString(g_LIST_BLOCKS_HURT_VICTIMCLASS, i, q_victimclass, sizeof(q_victimclass));
		
		if (!StrEqual(q_attackerid,"") && !StrEqual(q_attackerid,g_attackerSteam)) valid = false;
		if (!StrEqual(q_victimid,"") && !StrEqual(q_victimid,g_victimSteam)) valid = false;
		if (!StrEqual(q_map,"") && !StrEqual(q_map,g_map)) valid = false;
		if (!StrEqual(q_attackerclass,"") && g_attacker && (TF2_GetPlayerClass(g_attacker) != TF2_GetClass(q_attackerclass))) valid = false;
		if (!StrEqual(q_victimclass,"") && g_victim && (TF2_GetPlayerClass(g_victim) != TF2_GetClass(q_victimclass))) valid = false;
		if (q_selfdmg >= 0 && (q_selfdmg != g_selfdmg)) valid = false;
		if (q_crit >= 0 && (g_crit == true && q_crit == 0)) valid = false;
		if (q_crit >= 0 && (g_crit == false && q_crit == 1)) valid = false;
		if (q_dmgmin >= 0 && (g_damage < q_dmgmin)) valid = false;
		if (q_dmgmax >= 0 && (g_damage > q_dmgmax)) valid = false;
		
		
		if (valid) {
			
			if (q_winner == 1 && g_attacker) {
				focusclient = g_attacker;
			}
			if (q_winner == 0 && g_victim) {
				focusclient = g_victim;
			}
			if (!focusclient || IsFakeClient(focusclient))
				valid = false;
			
			if (valid) {            
				UpdateBlockStatus(focusclient, "hurt", q_id, 1);
				AchievementCheckCompletion(focusclient,"hurt", q_id, g_attacker, g_victim, g_attacker);
			}
		}
	}
}