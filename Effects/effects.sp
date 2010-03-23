#pragma semicolon 1

#include <sourcemod>

#define PLUGIN_VERSION "1.2"

public Plugin:myinfo = {
	name = "Effects",
	author = "Asherkin",
	description = "Enables effects on a player.",
	version = PLUGIN_VERSION,
	url = "http://limetech.org"
}

public OnPluginStart() {
	RegAdminCmd("sm_uber", UberClient, ADMFLAG_ROOT, "Ubercharges a player");
	RegAdminCmd("sm_kritz", KritzClient, ADMFLAG_ROOT, "Ubercharges (Kritz) a player");
	RegAdminCmd("sm_jarate", JarateClient, ADMFLAG_ROOT, "Jarates a player");
}

public Action:UberClient(client, args) {
	new String:arg1[32];
	new String:arg2[32];
	new enable = 0;
 
	/* Get the first argument */
	GetCmdArg(1, arg1, sizeof(arg1));
 
	/* If there are 2 or more arguments, and the second argument fetch 
	 * is successful, convert it to an integer.
	 */
	if (args >= 2 && GetCmdArg(2, arg2, sizeof(arg2))) {
		enable = StringToInt(arg2);
	}
 
	/**
	 * target_name - stores the noun identifying the target(s)
	 * target_list - array to store clients
	 * target_count - variable to store number of clients
	 * tn_is_ml - stores whether the noun must be translated
	 */
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;
 
	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE, /* Only allow alive players */
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		/* This function replies to the admin with a failure message */
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
 
 	if (enable == 1) {
		for (new i = 0; i < target_count; i++)
		{
			AddCond(target_list[i], 5);
			LogAction(client, target_list[i], "\"%L\" enabled Ubercharge on \"%L\"", client, target_list[i]);
		}
	} else {
		for (new i = 0; i < target_count; i++) {
			RemoveCond(target_list[i], 5);
			LogAction(client, target_list[i], "\"%L\" removed Ubercharge on \"%L\"", client, target_list[i]);
		}
	}
 
	if (tn_is_ml) {
		if (enable == 1) {
			ShowActivity2(client, "[SM] ", "Enabled Ubercharge on %t!", target_name);
		} else {
			ShowActivity2(client, "[SM] ", "Removed Ubercharge on %t!", target_name);		
		}
	} else {
		if (enable == 1) {
			ShowActivity2(client, "[SM] ", "Enabled Ubercharge on %s!", target_name);
		} else {
			ShowActivity2(client, "[SM] ", "Removed Ubercharge on %s!", target_name);		
		}
	}
 
	return Plugin_Handled;
}

public Action:KritzClient(client, args) {
	new String:arg1[32];
	new String:arg2[32];
	new enable = 0;
 
	/* Get the first argument */
	GetCmdArg(1, arg1, sizeof(arg1));
 
	/* If there are 2 or more arguments, and the second argument fetch 
	 * is successful, convert it to an integer.
	 */
	if (args >= 2 && GetCmdArg(2, arg2, sizeof(arg2))) {
		enable = StringToInt(arg2);
	}
 
	/**
	 * target_name - stores the noun identifying the target(s)
	 * target_list - array to store clients
	 * target_count - variable to store number of clients
	 * tn_is_ml - stores whether the noun must be translated
	 */
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;
 
	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE, /* Only allow alive players */
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		/* This function replies to the admin with a failure message */
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
 
 	if (enable == 1) {
		for (new i = 0; i < target_count; i++)
		{
			AddCond(target_list[i], 11);
			LogAction(client, target_list[i], "\"%L\" enabled Kritz on \"%L\"", client, target_list[i]);
		}
	} else {
		for (new i = 0; i < target_count; i++) {
			RemoveCond(target_list[i], 11);
			LogAction(client, target_list[i], "\"%L\" removed Kritz on \"%L\"", client, target_list[i]);
		}
	}
 
	if (tn_is_ml) {
		if (enable == 1) {
			ShowActivity2(client, "[SM] ", "Enabled Kritz on %t!", target_name);
		} else {
			ShowActivity2(client, "[SM] ", "Removed Kritz on %t!", target_name);		
		}
	} else {
		if (enable == 1) {
			ShowActivity2(client, "[SM] ", "Enabled Kritz on %s!", target_name);
		} else {
			ShowActivity2(client, "[SM] ", "Removed Kritz on %s!", target_name);		
		}
	}
 
	return Plugin_Handled;
}

public Action:JarateClient(client, args) {
	new String:arg1[32];
	new String:arg2[32];
	new enable = 0;
 
	/* Get the first argument */
	GetCmdArg(1, arg1, sizeof(arg1));
 
	/* If there are 2 or more arguments, and the second argument fetch 
	 * is successful, convert it to an integer.
	 */
	if (args >= 2 && GetCmdArg(2, arg2, sizeof(arg2))) {
		enable = StringToInt(arg2);
	}
 
	/**
	 * target_name - stores the noun identifying the target(s)
	 * target_list - array to store clients
	 * target_count - variable to store number of clients
	 * tn_is_ml - stores whether the noun must be translated
	 */
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;
 
	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE, /* Only allow alive players */
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		/* This function replies to the admin with a failure message */
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
 
 	if (enable == 1) {
		for (new i = 0; i < target_count; i++)
		{
			AddCond(target_list[i], 22);
			LogAction(client, target_list[i], "\"%L\" enabled Jarate on \"%L\"", client, target_list[i]);
		}
	} else {
		for (new i = 0; i < target_count; i++) {
			RemoveCond(target_list[i], 22);
			LogAction(client, target_list[i], "\"%L\" removed Jarate on \"%L\"", client, target_list[i]);
		}
	}
 
	if (tn_is_ml) {
		if (enable == 1) {
			ShowActivity2(client, "[SM] ", "Enabled Jarate on %t!", target_name);
		} else {
			ShowActivity2(client, "[SM] ", "Removed Jarate on %t!", target_name);		
		}
	} else {
		if (enable == 1) {
			ShowActivity2(client, "[SM] ", "Enabled Jarate on %s!", target_name);
		} else {
			ShowActivity2(client, "[SM] ", "Removed Jarate on %s!", target_name);		
		}
	}
 
	return Plugin_Handled;
}

public AddCond(client, cond) {
    new Handle:cvar = FindConVar("sv_cheats"), bool:enabled = GetConVarBool(cvar), flags = GetConVarFlags(cvar);
    if(!enabled) {
        SetConVarFlags(cvar, flags^(FCVAR_NOTIFY|FCVAR_REPLICATED));
        SetConVarBool(cvar, true);
    }
    FakeClientCommand(client, "addcond %i", cond);
    if(!enabled) {
        SetConVarBool(cvar, false);
        SetConVarFlags(cvar, flags);
    }
}

public RemoveCond(client, cond) {
    new Handle:cvar = FindConVar("sv_cheats"), bool:enabled = GetConVarBool(cvar), flags = GetConVarFlags(cvar);
    if(!enabled) {
        SetConVarFlags(cvar, flags^(FCVAR_NOTIFY|FCVAR_REPLICATED));
        SetConVarBool(cvar, true);
    }
    FakeClientCommand(client, "removecond %i", cond);
    if(!enabled) {
        SetConVarBool(cvar, false);
        SetConVarFlags(cvar, flags);
    }
}