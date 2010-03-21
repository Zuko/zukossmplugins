//----------------------------------------DATA PACK--------------------------------------------
new Handle:g_LIST_BLOCKS_KILL_ID = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_KILL_WINNER = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_KILL_ATTACKERID = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_KILL_VICTIMID = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_KILL_ASSISTERID = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_KILL_WEAPONS = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_KILL_MAP = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_KILL_ATTACKCLASS = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_KILL_VICTIMCLASS = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_KILL_ASSISTCLASS = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_KILL_SELFDMG = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_KILL_CRIT = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_KILL_DOMINATION = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_KILL_REVENGE = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_KILL_HEADSHOT = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_KILL_BACKSTAB = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_KILL_DEADRINGER = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_KILL_OBJECT = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_KILL_WASBUILD = INVALID_HANDLE;

RC_Blocks_Kill() {
	decl String:strQuery[255];
	new String:strTablePrefix[128];
	GetConVarString(g_CVTABLEPREFIX, strTablePrefix, sizeof(strTablePrefix));
	Format(strQuery, sizeof(strQuery), "SELECT * FROM `%sblocks_kill`",strTablePrefix);
	SQL_TQuery		(g_HDATABASE, RC_Blocks_Kill_After_Query, strQuery);
}

public RC_Blocks_Kill_After_Query(Handle:owner, Handle:strHQuery, const String:error[], any:data) 
{
	if (strHQuery == INVALID_HANDLE)
	{
		LogMessage("Failed to retrieve 'kill' list from the database, %s",error);
		return;
	}
	g_BLOCKS_KILL = SQL_GetRowCount(strHQuery);
	ClearAndResize(g_LIST_BLOCKS_KILL_ID,g_BLOCKS_KILL+1);
	ClearAndResize(g_LIST_BLOCKS_KILL_WINNER,g_BLOCKS_KILL+1);
	ClearAndResize(g_LIST_BLOCKS_KILL_ATTACKERID,g_BLOCKS_KILL+1);
	ClearAndResize(g_LIST_BLOCKS_KILL_VICTIMID,g_BLOCKS_KILL+1);
	ClearAndResize(g_LIST_BLOCKS_KILL_ASSISTERID,g_BLOCKS_KILL+1);
	ClearAndResize(g_LIST_BLOCKS_KILL_WEAPONS,g_BLOCKS_KILL+1);
	ClearAndResize(g_LIST_BLOCKS_KILL_MAP,g_BLOCKS_KILL+1);
	ClearAndResize(g_LIST_BLOCKS_KILL_ATTACKCLASS,g_BLOCKS_KILL+1);
	ClearAndResize(g_LIST_BLOCKS_KILL_VICTIMCLASS,g_BLOCKS_KILL+1);
	ClearAndResize(g_LIST_BLOCKS_KILL_ASSISTCLASS,g_BLOCKS_KILL+1);
	ClearAndResize(g_LIST_BLOCKS_KILL_SELFDMG,g_BLOCKS_KILL+1);
	ClearAndResize(g_LIST_BLOCKS_KILL_CRIT,g_BLOCKS_KILL+1);
	ClearAndResize(g_LIST_BLOCKS_KILL_DOMINATION,g_BLOCKS_KILL+1);
	ClearAndResize(g_LIST_BLOCKS_KILL_REVENGE,g_BLOCKS_KILL+1);
	ClearAndResize(g_LIST_BLOCKS_KILL_HEADSHOT,g_BLOCKS_KILL+1);
	ClearAndResize(g_LIST_BLOCKS_KILL_BACKSTAB,g_BLOCKS_KILL+1);
	ClearAndResize(g_LIST_BLOCKS_KILL_DEADRINGER,g_BLOCKS_KILL+1);
	ClearAndResize(g_LIST_BLOCKS_KILL_OBJECT,g_BLOCKS_KILL+1);
	ClearAndResize(g_LIST_BLOCKS_KILL_WASBUILD,g_BLOCKS_KILL+1);
	
	new i = 0;
	new strString[512];
	while (SQL_FetchRow(strHQuery)) {
		//0 - id
		SetArrayCell(g_LIST_BLOCKS_KILL_ID, i,SQL_FetchInt(strHQuery, 0));
		
		//1 - winner
		SetArrayCell(g_LIST_BLOCKS_KILL_WINNER, i,SQL_FetchInt(strHQuery, 1));
		
		//2 - attacker id
		SQL_FetchString(strHQuery, 2,strString,sizeof(strString));
		SetArrayString(g_LIST_BLOCKS_KILL_ATTACKERID, i, strString);
		
		//3 - victim id
		SQL_FetchString(strHQuery, 3,strString,sizeof(strString));
		SetArrayString(g_LIST_BLOCKS_KILL_VICTIMID, i, strString);
		
		//4 - assister id
		SQL_FetchString(strHQuery, 4,strString,sizeof(strString));
		SetArrayString(g_LIST_BLOCKS_KILL_ASSISTERID, i, strString);
		
		//5 - kill weapon
		SQL_FetchString(strHQuery, 5,strString,sizeof(strString));
		SetArrayString(g_LIST_BLOCKS_KILL_WEAPONS, i, strString);
		
		//6 - map
		SQL_FetchString(strHQuery, 6,strString,sizeof(strString));
		SetArrayString(g_LIST_BLOCKS_KILL_MAP, i, strString);
		
		//7 - attacker class
		SQL_FetchString(strHQuery, 7,strString,sizeof(strString));
		SetArrayString(g_LIST_BLOCKS_KILL_ATTACKCLASS, i, strString);
		
		//8 - victim class
		SQL_FetchString(strHQuery, 8,strString,sizeof(strString));
		SetArrayString(g_LIST_BLOCKS_KILL_VICTIMCLASS, i, strString);
		
		//9 - assister class
		SQL_FetchString(strHQuery, 9,strString,sizeof(strString));
		SetArrayString(g_LIST_BLOCKS_KILL_ASSISTCLASS, i, strString);
		
		//10 - selfdmg
		SetArrayCell(g_LIST_BLOCKS_KILL_SELFDMG, i, SQL_FetchInt(strHQuery, 10));
		
		//11 - crit
		SetArrayCell(g_LIST_BLOCKS_KILL_CRIT, i, SQL_FetchInt(strHQuery, 11));
		
		//12 - domination
		SetArrayCell(g_LIST_BLOCKS_KILL_DOMINATION, i, SQL_FetchInt(strHQuery, 12));
		
		//13 - revenge
		SetArrayCell(g_LIST_BLOCKS_KILL_REVENGE, i, SQL_FetchInt(strHQuery, 13));
		
		//14 - headshot
		SetArrayCell(g_LIST_BLOCKS_KILL_HEADSHOT, i, SQL_FetchInt(strHQuery, 14));
		
		//15 - backstab
		SetArrayCell(g_LIST_BLOCKS_KILL_BACKSTAB, i, SQL_FetchInt(strHQuery, 15));
		
		//16 - deadringer
		SetArrayCell(g_LIST_BLOCKS_KILL_DEADRINGER, i, SQL_FetchInt(strHQuery, 16));
		
		//17 - object
		SetArrayCell(g_LIST_BLOCKS_KILL_OBJECT, i, SQL_FetchInt(strHQuery, 17));
		
		//18 - wasbuild
		SetArrayCell(g_LIST_BLOCKS_KILL_WASBUILD, i, SQL_FetchInt(strHQuery, 18));
		
		if (g_LIST_BLOCKS_KILL_ID == INVALID_HANDLE) {
			LogError("Invalid array!");
		}
		
		//Put our datapack into one of the main datapacks
		i++
	}
}

//----------------------------------------KILL BLOCKS----------------------------------------
public blocks_kill_pre(Handle:argEvent, const String:name[], bool:noBroadcast) {
	blocks_kill(argEvent, -1, -1);
	new g_victimid = GetEventInt(argEvent, "userid");
	new g_victim = GetClientOfUserId(g_victimid);
	CreateTimer(2.0, blocks_ResetOnDeath, g_victim);
}

public blocks_kill_object(Handle:argEvent, const String:name[], bool:noBroadcast) {
	new g_object = GetEventInt(argEvent, "objecttype");
	new g_wasbuild = GetEventInt(argEvent, "was_building");
	blocks_kill(argEvent, g_object,g_wasbuild)
}

public blocks_kill(Handle:argEvent, any:g_object, any:g_wasbuild) {
	//data
	new g_attackerid = 0;
	new g_victimid = 0;
	new g_assisterid = 0;
	new String:g_weapon[128];
	new g_selfdmg = 0;
	new String:g_map[128];
	new g_crit = 0;
	new g_damagebits = GetEventInt(argEvent, "damagebits");
	new g_customkill = GetEventInt(argEvent, "customkill");
	new g_flagdeath = GetEventInt(argEvent, "death_flags");
	new g_domination = -1;
	new g_revenge = -1;
	new g_deadringer = -1;
	new g_headshot = -1;
	new g_backstab = -1;
	
	if((g_flagdeath & 1) || (g_flagdeath & 2))
		g_domination = 1;
	else
		g_domination = 0;
	
	if((g_flagdeath & 4) || (g_flagdeath & 8))
		g_revenge = 1;
	else
		g_revenge = 0;
	
	if (g_flagdeath & 32)
		g_deadringer = 1;	
	else
		g_deadringer = 0;	
	
	if(g_customkill == 1)
		g_headshot = 1;
	else
		g_headshot = 0;
	
	if (g_customkill == 2)
		g_backstab = 1;
	else
		g_backstab = 0;
	
	g_attackerid = GetEventInt(argEvent, "attacker");
	g_victimid = GetEventInt(argEvent, "userid");
	g_assisterid = GetEventBool(argEvent, "assister");
	
	GetEventString(argEvent, "weapon_logclassname", g_weapon, sizeof(g_weapon));
	GetCurrentMap(g_map,sizeof(g_map));
	
	new g_attacker = GetClientOfUserId(g_attackerid);
	new g_victim = GetClientOfUserId(g_victimid);
	new g_assister = GetClientOfUserId(g_assisterid);
	
	if (g_victim == g_attacker || g_victim == 0 && g_assister == 0 ) g_selfdmg = 1;
	if (g_damagebits & DMG_NERVEGAS || g_damagebits & DMG_VEHICLE || g_damagebits & DMG_FALL) g_selfdmg = 1;
	
	if (g_damagebits & DF_CRITS)
	{
		new iAttackerCond 	= g_CLIENTCONDITION[g_attacker];
		new iVictimCond 	= g_CLIENTCONDITION[g_victim];
		
		if (iAttackerCond & DF_CRITS_BUFFBANNER)
			g_crit = 3;
		else if (iVictimCond & DF_CRITS_JARATE)
			g_crit = 2;
		else
		g_crit = 1;
	}
	new Boolean:valid = true;
	new q_id = 0;
	new q_winner = 0;
	new String:q_attackerid[128];
	new String:q_victimid[128];
	new String:q_assisterid[128];
	new String:q_map[128];
	new q_selfdmg = 0;
	new focusclient = 0;
	new q_crit = -1;
	new q_domination = -1;
	new q_revenge = -1;
	new q_headshot = -1;
	new q_backstab = -1;
	new q_deadringer = -1;
	new q_object = -1;
	new q_wasbuild = -1;
	new String:q_weapon[512];
	new String:q_attackerclass[128];
	new String:q_victimclass[128];
	new String:q_assisterclass[128];
	
	new String:g_attackerSteam[128];
	if (g_attacker && !IsFakeClient(g_attacker)) GetClientAuthString(g_attacker, g_attackerSteam, sizeof(g_attackerSteam));
	new String:g_victimSteam[128];
	if (g_victim && !IsFakeClient(g_victim)) GetClientAuthString(g_victim, g_victimSteam, sizeof(g_victimSteam));
	new String:g_assisterSteam[128];
	if (g_assister && !IsFakeClient(g_assister)) GetClientAuthString(g_assister, g_assisterSteam, sizeof(g_assisterSteam));
	
	for(new i = 0; i < g_BLOCKS_KILL; i++) {
		valid = true;
		
		//lets get our specific datapack from the main datapack.
		q_id 		= GetArrayCell(g_LIST_BLOCKS_KILL_ID, i);
		q_winner 	= GetArrayCell(g_LIST_BLOCKS_KILL_WINNER, i);
		q_selfdmg 	= GetArrayCell(g_LIST_BLOCKS_KILL_SELFDMG, i);
		q_crit 		= GetArrayCell(g_LIST_BLOCKS_KILL_CRIT, i);
		GetArrayString(g_LIST_BLOCKS_KILL_ATTACKERID, i, q_attackerid, sizeof(q_attackerid));
		GetArrayString(g_LIST_BLOCKS_KILL_VICTIMID, i, q_victimid, sizeof(q_victimid));
		GetArrayString(g_LIST_BLOCKS_KILL_ASSISTERID, i, q_assisterid, sizeof(q_assisterid));
		GetArrayString(g_LIST_BLOCKS_KILL_WEAPONS, i, q_weapon, sizeof(q_weapon));
		GetArrayString(g_LIST_BLOCKS_KILL_MAP, i, q_map, sizeof(q_map));
		GetArrayString(g_LIST_BLOCKS_KILL_ATTACKCLASS, i, q_attackerclass, sizeof(q_attackerclass));
		GetArrayString(g_LIST_BLOCKS_KILL_VICTIMCLASS, i, q_victimclass, sizeof(q_victimclass));
		GetArrayString(g_LIST_BLOCKS_KILL_ASSISTCLASS, i, q_assisterclass, sizeof(q_assisterclass));
		q_domination 	= GetArrayCell(g_LIST_BLOCKS_KILL_DOMINATION, i);
		q_revenge 		= GetArrayCell(g_LIST_BLOCKS_KILL_REVENGE, i);
		q_headshot 		= GetArrayCell(g_LIST_BLOCKS_KILL_HEADSHOT, i);
		q_backstab 		= GetArrayCell(g_LIST_BLOCKS_KILL_BACKSTAB, i);
		q_deadringer 	= GetArrayCell(g_LIST_BLOCKS_KILL_DEADRINGER, i);
		q_object		= GetArrayCell(g_LIST_BLOCKS_KILL_OBJECT, i);
		q_wasbuild		= GetArrayCell(g_LIST_BLOCKS_KILL_WASBUILD, i);
		
		if (q_deadringer > -1 && q_deadringer != g_deadringer)                                                             	valid = false;
		if (q_deadringer == -1 && g_deadringer == 1)                                                         				valid = false;
		if (q_backstab > -1 && q_backstab != g_backstab)                                                             		valid = false;
		if (q_headshot > -1 && q_headshot != g_headshot)                                                             		valid = false;
		if (q_revenge > -1 && q_revenge != g_revenge)                                                                 		valid = false;
		if (q_domination > -1 && q_domination != g_domination)                                                              valid = false;
		if (q_wasbuild > -1 && q_wasbuild != g_wasbuild)                                                                    valid = false;
		
		if (q_object > -1 && q_object != g_object)					                                                        valid = false;
		if (q_object == -1 && g_object > 0)							                                                        valid = false;
		if (q_selfdmg >= 0 && (q_selfdmg != g_selfdmg))                                                                     valid = false;
		//If suicide, we must three things.
		if (q_selfdmg >= 0 && (q_selfdmg == g_selfdmg))
		{
			if (StrEqual(q_weapon,"saw", false) && !(g_damagebits & DMG_NERVEGAS))                                          valid = false;
			if (StrEqual(q_weapon,"train", false) && !(g_damagebits & DMG_VEHICLE))     									valid = false;
			
			if (!StrEqual(q_weapon,"saw", false) && !StrEqual(q_weapon,"train", false))
				if (!StrEqual(q_weapon,"") && !StrEqual(q_weapon,g_weapon))                                   					valid = false;
		}
		else
		{
			if (!StrEqual(q_weapon,"") && !StrEqual(q_weapon,g_weapon))                                   					    valid = false;
		}
		if (!StrEqual(q_attackerid,"") && !StrEqual(q_attackerid,g_attackerSteam))                                          	valid = false;
		if (!StrEqual(q_victimid,"") && !StrEqual(q_victimid,g_victimSteam))                                                 	valid = false;
		if (!StrEqual(q_assisterid,"") && !StrEqual(q_assisterid,g_assisterSteam))                                        		valid = false;
		if (!StrEqual(q_map,"") && !StrEqual(q_map,g_map))                                                                 		valid = false;
		if (!StrEqual(q_attackerclass,"") && g_attacker && (TF2_GetPlayerClass(g_attacker) != TF2_GetClass(q_attackerclass)))   valid = false;
		if (!StrEqual(q_victimclass,"") && g_victim && (TF2_GetPlayerClass(g_victim) != TF2_GetClass(q_victimclass)))           valid = false;
		if (!StrEqual(q_assisterclass,"") && g_assister && (TF2_GetPlayerClass(g_assister) != TF2_GetClass(q_assisterclass)))   valid = false;
		if (q_crit >= 0 && (q_crit != g_crit))                                                                                  valid = false;
		if ((!StrEqual(q_attackerclass,"") || !StrEqual(q_attackerid,"")) && g_attacker == 0)                                   valid = false;
		if ((!StrEqual(q_victimclass,"") || !StrEqual(q_victimid,"")) && g_victim == 0)                                         valid = false;  
		if ((!StrEqual(q_assisterclass,"") || !StrEqual(q_assisterid,"")) && g_assister == 0)                                   valid = false;  
		if (valid) {
			
			if (q_winner == 0 && g_attacker) {
				focusclient = g_victim;
			}
			if (q_winner == 1 && g_victim) {
				focusclient = g_attacker;
			}
			if (q_winner == 2 && g_assister) {
				focusclient = g_assister;
			}
			if(q_selfdmg==1){
				focusclient = g_victim;
			}
			
			if (!focusclient || IsFakeClient(focusclient))
				valid = false;
			
			if (valid) {
				UpdateBlockStatus(focusclient, "kill", q_id, 1);
				AchievementCheckCompletion(focusclient, "kill", q_id, g_attacker, g_victim, g_assister);
			}
		}
	}
}

public Action:blocks_ResetOnDeath(Handle:hTimer, any:g_victim)
{
	ResetAllOneLifeForOneClient(g_victim);
}
	