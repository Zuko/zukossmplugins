//----------------------------------------DATA PACK--------------------------------------------
//Medic possibility
new Handle:g_LIST_BLOCKS_UBERCHARGE_ID      		= INVALID_HANDLE; 
new Handle:g_LIST_BLOCKS_UBERCHARGE_WINNER   		= INVALID_HANDLE; 
new Handle:g_LIST_BLOCKS_UBERCHARGE_WEAPONS_UBER   	= INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_UBERCHARGE_STEAM_ID   		= INVALID_HANDLE;

RC_Blocks_Ubercharge() {
	decl String:strQuery[255];
	new String:strTablePrefix[128];
	GetConVarString(g_CVTABLEPREFIX, strTablePrefix, sizeof(strTablePrefix));
	Format(strQuery, sizeof(strQuery), "SELECT * FROM `%sblocks_ubercharge`",strTablePrefix);
	SQL_TQuery		(g_HDATABASE, RC_Blocks_Ubercharge_After_Query, strQuery);
}

public RC_Blocks_Ubercharge_After_Query(Handle:owner, Handle:strHQuery, const String:error[], any:data) 
{
	if (strHQuery == INVALID_HANDLE)
	{
		LogMessage("Failed to retrieve 'Ubercharge' list from the database, %s",error);
		return;
	}
	g_BLOCKS_UBERCHARGE = SQL_GetRowCount(strHQuery);
	ClearAndResize(g_LIST_BLOCKS_UBERCHARGE_ID,g_BLOCKS_UBERCHARGE+1);
	ClearAndResize(g_LIST_BLOCKS_UBERCHARGE_WINNER,g_BLOCKS_UBERCHARGE+1);
	ClearAndResize(g_LIST_BLOCKS_UBERCHARGE_WEAPONS_UBER,g_BLOCKS_UBERCHARGE+1);
	ClearAndResize(g_LIST_BLOCKS_UBERCHARGE_STEAM_ID,g_BLOCKS_UBERCHARGE+1);
	new i = 0;
	new strString[512];
	while (SQL_FetchRow(strHQuery)) {
		//0 - id
		SetArrayCell(g_LIST_BLOCKS_UBERCHARGE_ID, i, SQL_FetchInt(strHQuery, 0));
		SetArrayCell(g_LIST_BLOCKS_UBERCHARGE_WINNER, i, SQL_FetchInt(strHQuery, 1));
		//1 - content
		SQL_FetchString(strHQuery, 2,strString,sizeof(strString));
		SetArrayString(g_LIST_BLOCKS_UBERCHARGE_WEAPONS_UBER, i, strString);
		
		SQL_FetchString(strHQuery, 3,strString,sizeof(strString));
		SetArrayString(g_LIST_BLOCKS_UBERCHARGE_STEAM_ID, i, strString);
		
		if (g_LIST_BLOCKS_UBERCHARGE_ID == INVALID_HANDLE) {
			LogError("Invalid array!");
		}
		
		//Put our datapack into one of the main datapacks
		i++;
	}
}
new Handle:g_LIST_BLOCKS_CALLMEDIC_ID       = INVALID_HANDLE;   // Medic list

RC_Blocks_CallMedic() {
	decl String:strQuery[255];
	new Handle:strHQuery;
	new String:strTablePrefix[128];
	GetConVarString(g_CVTABLEPREFIX, strTablePrefix, sizeof(strTablePrefix));
	Format(strQuery, sizeof(strQuery), "SELECT * FROM `%sblocks_callmedic`",strTablePrefix);
	SQL_TQuery		(g_HDATABASE, RC_Blocks_CallMedic_After_Query, strQuery);
}

public RC_Blocks_CallMedic_After_Query(Handle:owner, Handle:strHQuery, const String:error[], any:data) 
{
	if (strHQuery == INVALID_HANDLE)
	{
		LogMessage("Failed to retrieve 'CallMedic' list from the database, %s",error);
		return;
	}
	g_BLOCKS_CALLMEDIC = SQL_GetRowCount(strHQuery);
	ClearAndResize(g_LIST_BLOCKS_CALLMEDIC_ID,g_BLOCKS_CALLMEDIC+1);
	
	new i = 0;
	while (SQL_FetchRow(strHQuery)) {
		//0 - id
		SetArrayCell(g_LIST_BLOCKS_CALLMEDIC_ID, i, SQL_FetchInt(strHQuery, 0));   
		if (g_LIST_BLOCKS_CALLMEDIC_ID == INVALID_HANDLE) {
			LogError("Invalid array!");
		}
		
		//Put our datapack into one of the main datapacks
		i++;
	}
}

//----------------------------------------UBERCHARGED----------------------------------------
public blocks_medic_uber(Handle:event, const String:name[], bool:noBroadcast) {
	//data
	new g_victimid = 0;
	new g_targetid = 0;
	g_victimid = GetEventInt(event, "userid");
	g_targetid = GetEventInt(event, "targetid");
	new g_victim = GetClientOfUserId(g_victimid);
	new g_target = GetClientOfUserId(g_targetid);
	new String:g_attackerSteam[64];
	GetClientAuthString(g_targetid, g_attackerSteam, sizeof(g_attackerSteam));
	
	new q_id = 0;
	new q_winner = 0;
	new String:q_weapons[128];
	new String:q_steamID[64];
	new Boolean:valid = true;
	new focusclient;
	for(new i = 0; i < g_BLOCKS_UBERCHARGE; i++) {
		valid = true;
		
		//lets get our specific datapack from the main datapack.
		q_id 				=	GetArrayCell(g_LIST_BLOCKS_UBERCHARGE_ID, i );
		GetArrayString(g_LIST_BLOCKS_UBERCHARGE_WEAPONS_UBER, i, q_weapons, sizeof(q_weapons));
		GetArrayString(g_LIST_BLOCKS_UBERCHARGE_STEAM_ID, i, q_steamID, sizeof(q_steamID));
		
		if(GetEntProp(GetPlayerWeaponSlot(g_victim, 1), Prop_Send, "m_iItemDefinitionIndex") != 35)
		{
			if(StrEqual(q_weapons,"Medigun",true)) valid = false;
		}
		else
		{
			if(StrEqual(q_weapons,"Kritz",true)) valid = false;
		}
		
		if (!StrEqual(q_steamID,"") && !StrEqual(q_steamID,g_attackerSteam))                                          	valid = false;
		if (valid) {
			
			if (q_winner == 1 && g_target) {
				focusclient = g_target;
			}
			if (q_winner == 0 && g_victim) {
				focusclient = g_victim;
			}
			if (!focusclient || IsFakeClient(focusclient))
				valid = false;
			
			if (valid) {            
				UpdateBlockStatus(focusclient, "ubercharge", q_id, 1);
				AchievementCheckCompletion(focusclient, "ubercharge", q_id, g_target, g_victim, g_target);
			}
			
		}
	}	
}

public Action:blocks_callmedic(UserMsg:msg_id, Handle:bf, const players[], playersNum, bool:reliable, bool:init)
{
	new strClient =  BfReadByte(bf);
	new voicemenu1 = BfReadByte(bf);
	new voicemenu2 = BfReadByte(bf);
	if(voicemenu1 == 0 && voicemenu2 == 0 && IsValidClient(strClient))
	{
		CreateTimer(0.1, DelayPrintExpire, strClient);
	}
} 

public Action:DelayPrintExpire(Handle:hTimer, any:argClient)
{
	new strClient = argClient;
	new q_id = 0;
	new Boolean:valid = true;
	new focusclient;
	for(new i = 0; i < g_BLOCKS_CALLMEDIC; i++) {
		valid = true;
		
		q_id 		= GetArrayCell(g_LIST_BLOCKS_CALLMEDIC_ID, i);
		if (valid) {
			
			focusclient = strClient;
			if (!focusclient || IsFakeClient(focusclient))
				valid = false;
			
			if (valid) { 
				
				UpdateBlockStatus(focusclient, "callmedic", q_id, 1);
				AchievementCheckCompletion(focusclient, "callmedic", q_id, focusclient, focusclient, focusclient);
			}
		}
	}
}