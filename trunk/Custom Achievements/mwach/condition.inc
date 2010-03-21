//----------------------------------------DATA PACK--------------------------------------------
new Handle:g_LIST_BLOCKS_CONDITION_ID = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_CONDITION_TYPE = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_CONDITION_TARGET = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_CONDITION_INT1 = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_CONDITION_INT2 = INVALID_HANDLE;
new Handle:g_LIST_BLOCKS_CONDITION_INT3 = INVALID_HANDLE;

RC_Blocks_Condition() {
	decl String:strQuery[255];
	new Handle:strHQuery;
	new String:strTablePrefix[128];
	GetConVarString(g_CVTABLEPREFIX, strTablePrefix, sizeof(strTablePrefix));
	Format(strQuery, sizeof(strQuery), "SELECT * FROM `%sblocks_condition`",strTablePrefix);
	SQL_TQuery		(g_HDATABASE, RC_Blocks_Condition_After_Query, strQuery);
}

public RC_Blocks_Condition_After_Query(Handle:owner, Handle:strHQuery, const String:error[], any:data) 
{
	if (strHQuery == INVALID_HANDLE)
	{
		LogMessage("Failed to retrieve 'condition' list from the database, %s",error);
		return;
	}
	g_BLOCKS_CONDITION = SQL_GetRowCount(strHQuery);
	
	ClearAndResize(g_LIST_BLOCKS_CONDITION_ID,g_BLOCKS_CONDITION+1);
	ClearAndResize(g_LIST_BLOCKS_CONDITION_TYPE,g_BLOCKS_CONDITION+1);
	ClearAndResize(g_LIST_BLOCKS_CONDITION_TARGET,g_BLOCKS_CONDITION+1);
	ClearAndResize(g_LIST_BLOCKS_CONDITION_INT1,g_BLOCKS_CONDITION+1);
	ClearAndResize(g_LIST_BLOCKS_CONDITION_INT2,g_BLOCKS_CONDITION+1);
	ClearAndResize(g_LIST_BLOCKS_CONDITION_INT3,g_BLOCKS_CONDITION+1);
	
	new i = 0;
	while (SQL_FetchRow(strHQuery)) {
		//0 - id
		SetArrayCell(g_LIST_BLOCKS_CONDITION_ID, i, SQL_FetchInt(strHQuery, 0));
		
		//1 - type
		SetArrayCell(g_LIST_BLOCKS_CONDITION_TYPE, i, SQL_FetchInt(strHQuery, 1));
		
		//2 - target
		SetArrayCell(g_LIST_BLOCKS_CONDITION_TARGET, i, SQL_FetchInt(strHQuery, 2));
		
		//3 - int1
		SetArrayCell(g_LIST_BLOCKS_CONDITION_INT1, i, SQL_FetchInt(strHQuery, 3));
		
		//4 - int2
		SetArrayCell(g_LIST_BLOCKS_CONDITION_INT2, i, SQL_FetchInt(strHQuery, 4));
		
		//5 - int3
		SetArrayCell(g_LIST_BLOCKS_CONDITION_INT2, i, SQL_FetchInt(strHQuery, 5));
		
		if (g_LIST_BLOCKS_CONDITION_ID == INVALID_HANDLE) {
			LogError("Invalid array!");
		}
		
		i++;
	}
}

//----------------------------------------CONDITION BLOCK----------------------------------------
// Types:
// 1 - Health is between in1 and int2
// 2 - Is wearing hat
// 3 - Is on fire
// 4 - Is disguised
// 5 - Is taunting
// 6 - Is bonked (fast)
// 7 - Is bonked (slow)
// 8 - Has Achievement
// 9 - Rifle Zoomed
// 10 - Has Teleport Trail
// 11 - Spy Cloaked
// 12 - Covered in Jarate

#define TF2_PLAYER_SLOWED       (1 << 0)    // 1		Heavy Firing
#define TF2_PLAYER_ZOOMED       (1 << 1)    // 2		Sniper Zoom
#define TF2_PLAYER_DISGUISING   (1 << 2)    // 4		Undergoing Disguise
#define TF2_PLAYER_DISGUISED	(1 << 3)    // 8		Is disguised
#define TF2_PLAYER_CLOAKED      (1 << 4)    // 16		Is invisible
#define TF2_PLAYER_INVULN       (1 << 5)    // 32		Ubercharge
#define TF2_PLAYER_GLOWING	    (1 << 6)    // 64		Teleport Trail
#define TF2_PLAYER_TAUNTING	    (1 << 7)    // 128		Taunting
#define TF2_PLAYER_TELEPORT		(1 << 10)   // 1024		Is in teleporter
#define TF2_PLAYER_CRITS	    (1 << 11)   // 2048		Kritzkrieg
#define TF2_PLAYER_FEIGNDEATH	(1 << 13)   // 8192		Dead Ringer
#define TF2_PLAYER_BLUR		    (1 << 14)   // 16384	Bonk (Fast)
#define TF2_PLAYER_STUN			(1 << 15)   // 32768 	Bonk (Slow)
#define TF2_PLAYER_HEALING      (1 << 19)   // 65536 	Medic healing
#define TF2_PLAYER_ONFIRE		(1 << 20)   // 131072 	On fire
#define TF2_PLAYER_OVERHEALING  (1 << 21)   // 262144	Is overhealed
#define TF2_PLAYER_JAR	  		(1 << 22)   // 524288	Is jarate'd

blocks_getCondition(id, attacker, victim, assister) {
	new valid = 0;
	new q_type = 0;
	new q_target = 0;
	new q_int1 = 0;
	new q_int2 = 0;
	new q_int3 = 0;
	new g_int1 = 0;
	new g_int2 = 0;
	new g_int3 = 0;
	new q_id = 0;
	new target;
	new Float:vLoc[3], Float:aLoc[3], Float:distanceFloat;
	new distance;
	new String:DistanceVrai[50];
	new pass = 0;
	
	for(new i = 0; i < g_BLOCKS_CONDITION; i++) {
		q_id 			= GetArrayCell(g_LIST_BLOCKS_CONDITION_ID, i);
		
		if (q_id == id) {
			valid = 0;
			q_type 		= GetArrayCell(g_LIST_BLOCKS_CONDITION_TYPE, i);
			q_target 	= GetArrayCell(g_LIST_BLOCKS_CONDITION_TARGET, i);
			q_int1 		= GetArrayCell(g_LIST_BLOCKS_CONDITION_INT1, i);
			q_int2 		= GetArrayCell(g_LIST_BLOCKS_CONDITION_INT2, i);
			q_int3 		= GetArrayCell(g_LIST_BLOCKS_CONDITION_INT3, i);
			pass = 0;
			
			if (q_target == 0) target = victim;
			if (q_target == 1) target = attacker;
			if (q_target == 2) target = assister;
			
			if (target == 0) {
				q_type = 0;
			}
			if (q_type == 1 && target) {
				g_int1 = GetClientHealth(target);
				pass = 1;
			}
			
			if(q_type == 2)
			{
				GetClientAbsOrigin(victim,vLoc);
				GetClientAbsOrigin(target,aLoc);				
				distanceFloat= FloatDiv(calcDistance(vLoc[0],aLoc[0], vLoc[1],aLoc[1], vLoc[2],aLoc[2]), 32.0);
				distanceFloat = distanceFloat * 0.305; //1ft = .305 meters
				Format(DistanceVrai, sizeof(DistanceVrai), "%.1f", distanceFloat);
				g_int1  = StringToInt(DistanceVrai);
				pass = 1;
			}
			
			if (q_type == 3) {
				g_int1 = g_CLIENTHATS[target];
				pass = 1;
			}
			
			if ((q_type == 4) && (g_CLIENTCONDITION[target] & TF2_PLAYER_ONFIRE) != 0) {
				g_int1 = 0;
				pass = 1;
			}
			else
			{
				if(pass == 0)
					g_int1 = 1;
			}
			
			if ((q_type == 5) && (g_CLIENTCONDITION[target] & TF2_PLAYER_DISGUISED) != 0) {
				g_int1 = 0;
				pass = 1;
			}
			else
			{
				if(pass == 0)
					g_int1 = 1;
			}
			
			if ((q_type == 6) && (g_CLIENTCONDITION[target] & TF2_PLAYER_TAUNTING) != 0) {
				g_int1 = 1;
				pass = 1;
			}
			else
			{
				if(pass == 0)
					g_int1 = 0;
			}
			
			if ((q_type == 7) && (g_CLIENTCONDITION[target] & TF2_PLAYER_BLUR) != 0) {
				g_int1 = 0;
				pass = 1;
			}
			else
			{
				if(pass == 0)
					g_int1 = 1;
			}
			
			if ((q_type == 8) && (g_CLIENTCONDITION[target] & TF2_PLAYER_STUN) != 0){
				g_int1 = 0;
				pass = 1;
			}
			else
			{
				if(pass == 0)
					g_int1 = 1;
			}
			
			if (q_type == 9) {
				new p_sId[512];
				new sId[512];
				new sSteamId[512];
				GetClientAuthString(target, sSteamId, sizeof(sSteamId));
				Format(sId,sizeof(sId),"%s__%d",sSteamId,q_int1);
				
				for(new i2 = 0; i2 < g_USERS_ACH; i2++) {
					GetArrayString(g_LIST_USERS_ACH_ID, i2, p_sId, sizeof(p_sId));
					if (StrEqual(p_sId, sId)) {
						g_int1 = GetArrayCell(g_LIST_USERS_ACH_COMPLETE,i2);
					}
				}
				pass = 1;
			}
			
			if ((q_type == 10) && (g_CLIENTCONDITION[target] & TF2_PLAYER_ZOOMED) != 0) {
				g_int1 = 0;
				pass = 1;
			}
			else
			{
				if(pass == 0)
					g_int1 = 1;
			}
			
			if ((q_type == 11) && (g_CLIENTCONDITION[target] & TF2_PLAYER_GLOWING) != 0) {
				g_int1 = 0;
				pass = 1;
			}
			else
			{
				if(pass == 0)
					g_int1 = 1;
			}
			
			if ((q_type == 12) && (g_CLIENTCONDITION[target] & TF2_PLAYER_CLOAKED) != 0){
				g_int1 = 0;
				pass = 1;
			}
			else
			{
				if(pass == 0)
					g_int1 = 1;
			}
			
			if ((q_type == 13) && (g_CLIENTCONDITION[target] & TF2_PLAYER_JAR) != 0) {
				g_int1 = 0;
				pass = 1;
			}
			else
			{
				if(pass == 0)
					g_int1 = 1;
			}
			
			if (q_type == 1 && (g_int1 >= q_int1) && (g_int1 <= q_int2)) valid = 1;
			if (q_type == 2 && (g_int1 >= q_int1) && (g_int1 <= q_int2)) valid = 1;
			if ((q_type >= 3) && (q_type <=8) && (g_int1 == q_int1)) valid = 1;
			if ((q_type == 9) && (g_int1 == q_int2)) valid = 1;
			if ((q_type >= 10) && (q_type <=99) && (g_int1 == q_int1)) valid = 1;
			
			
		}
	}
	
	return valid;
}

Float:calcDistance(Float:x1,Float:x2,Float:y1,Float:y2,Float:z1,Float:z2){ 
	new Float:dx = x1-x2;
	new Float:dy = y1-y2;
	new Float:dz = z1-z2;
	return(SquareRoot(dx*dx + dy*dy + dz*dz));
}
	