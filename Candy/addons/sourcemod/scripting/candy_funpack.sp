#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>

#define PLUGIN_VERSION "0.5"

public Plugin:myinfo = 
{
	name = "Fun package for Candy",
	author = "Zuko (earlier Gahl)",
	description = "This plugin is a pack of functions that work well with Candy for TF2.",
	version = PLUGIN_VERSION,
	url = "http://HLDS.pl"
}

new Handle:cvNoiseLevel;

public OnPluginStart()
{
	RegAdminCmd("sm_candy_buy_cond", cBuyCrit, ADMFLAG_BAN, "Buy a Condition!");
	RegAdminCmd("sm_candy_buy_regen", cBuyRegen, ADMFLAG_BAN, "Fill health and ammo");
	RegAdminCmd("sm_candy_buy_slay", cBuySlay, ADMFLAG_BAN, "Slay a player!");

	cvNoiseLevel = CreateConVar("sm_candy_buy_noiselevel", "2", "1 = silent, 2 = buyer only, 3 = everyone", FCVAR_PLUGIN, true, 1.0, true, 3.0);
}

public Action:cBuyCrit(client, args)
{
	new String:sErrStr[] = "[candypack] Usage: sm_candy_buy_cond <#userid|name|@all|@red|@blue|@bots> <TFCond> [duration]";
	if (args < 3)
	{
		PrintToServer(sErrStr);
		return Plugin_Handled;
	}
	
	decl String:target[MAXPLAYERS];
	decl String:cond[25];
	decl String:duration[3];
	decl String:target_name[MAX_TARGET_LENGTH];
	decl target_list[MAXPLAYERS];
	decl target_count;
	decl bool:tn_is_ml;

	GetCmdArg(1, target, sizeof(target));
	GetCmdArg(2, cond, sizeof(cond));
	new i_cond = StringToInt(cond);
	GetCmdArg(3, duration, sizeof(duration));
	new Float:f_duration = StringToFloat(duration);
	new noise = GetConVarInt(cvNoiseLevel);

	if (target[client] == -1)
	{
		return Plugin_Handled;
	}

	if ((target_count = ProcessTargetString(
			target,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (new i = 0; i < target_count; i++)
	{
		if (IsClientConnected(target_list[i]) && IsClientInGame(target_list[i]))
		{
			TF2_AddCondition(target_list[i], TFCond:i_cond, f_duration);
			
			if (noise == 2)
			{
				PrintToChat(target_list[i], "Kupiłeś sobie cos użyj tego dobrze!");
			}
			else if (noise == 3)
			{
				new String:name[128];
				GetClientName(target_list[i], name, sizeof(name));
				PrintToChatAll("%s cos sobie kupil", name);
			}
		}
	}
	return Plugin_Handled;
}

public Action:cBuyRegen(client, args)
{
	new String:sErrStr[] = "[candypack] Usage: sm_candy_buy_regenerate <#userid|name|@all|@red|@blue|@bots>";
	if (args < 1)
	{
		PrintToServer(sErrStr);
		return Plugin_Handled;
	}
	
	decl String:target[MAXPLAYERS];
	decl String:target_name[MAX_TARGET_LENGTH];
	decl target_list[MAXPLAYERS];
	decl target_count;
	decl bool:tn_is_ml;

	GetCmdArg(1, target, sizeof(target));
	new noise = GetConVarInt(cvNoiseLevel);

	if (target[client] == -1)
	{
		return Plugin_Handled;
	}

	if ((target_count = ProcessTargetString(
			target,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (new i = 0; i < target_count; i++)
	{
		if (IsClientConnected(target_list[i]) && IsClientInGame(target_list[i]))
		{
			TF2_RegeneratePlayer(target_list[i]);
			
			if (noise == 2)
			{
				PrintToChat(target_list[i], "Kupiłeś sobie Regenerację!");
			}
			else if (noise == 3)
			{
				new String:name[128];
				GetClientName(target_list[i], name, sizeof(name));
				PrintToChatAll("%s kupił sobie regeneracje", name);
			}
		}
	}
	return Plugin_Handled;
}

public Action:cBuySlay(cclient, args)
{
	new String:sErrStr[] = "[candypack] Usage: sm_candy_buy_slay <userid>";
	if (args < 1)
	{
		PrintToServer(sErrStr);
		return Plugin_Handled;
	}
	new String:sclient[32];
	GetCmdArg(1, sclient, sizeof(sclient));
	new client = GetClientOfUserId(StringToInt(sclient));
	if (!FullCheckClient(client))
	{
		PrintToServer(sErrStr);
		return Plugin_Handled;
	}
	
	new Handle:hMenu = CreateMenu(cSlayPlayer);
	SetMenuTitle(hMenu, "Kto ci podpadł?");
	for (new i = 1; i <= GetClientCount(); i++)
	{
		new String:sName[255], String:sInfo[4];
		GetClientName(i, sName, sizeof(sName));
		IntToString(i, sInfo, sizeof(sInfo));
		AddMenuItem(hMenu, sInfo, sName);
	}
	DisplayMenu(hMenu, client, 20);
	
	return Plugin_Handled;
}

public cSlayPlayer(Handle:menu, MenuAction:action, client, result)
{
	if (action == MenuAction_Select)
	{
		new String:info[32], String:sAName[255], String:sVName[255];
		GetMenuItem(menu, result, info, sizeof(info))
		new hTarget = StringToInt(info);
		GetClientName(client, sAName, sizeof(sAName));
		GetClientName(hTarget, sVName, sizeof(sVName));
		
		SlapPlayer(hTarget, GetClientHealth(hTarget) + 10, false); // +10 just to be sure
		new noise = GetConVarInt(cvNoiseLevel);
		if (noise > 1)
		{
			PrintToChat(client, "Zgładziłeś %s", sVName);
			PrintToChat(hTarget, "%s cię zgładził! Chyba mu podpadłeś ;P", sAName);
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu)
	}
}

public bool:FullCheckClient(client)
{
	if (client < 1)
		return false;
	
	if (!IsClientConnected(client))
		return false;
	
	if (!IsClientInGame(client))
		return false;
	
	if (IsFakeClient(client))
		return false;
	
	return true;
}

