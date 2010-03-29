/*
 * TODO:
 * - Zabic timer jak ktos wyjdzie.
 * - Multi-Lang (może się kiedyś przyda | tylko jak zrobić multi-lang w buymenu...)
 */

#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>

new Handle:g_CountdownTimer = INVALID_HANDLE;
new Handle:cvNoiseLevel;
new Handle:HudCounter;
new g_CounterTimeStart;
new g_Time;

#define PLUGIN_VERSION "0.5"

public Plugin:myinfo = 
{
	name = "Fun package for Candy",
	author = "Zuko (earlier GachL)",
	description = "This plugin is a pack of functions that work well with Candy for TF2.",
	version = PLUGIN_VERSION,
	url = "http://HLDS.pl"
}

public OnPluginStart()
{
	RegAdminCmd("sm_candy_buy_cond", cBuyCrit, ADMFLAG_BAN, "Buy a Condition!");
	RegAdminCmd("sm_candy_buy_uber", cBuyUber, ADMFLAG_BAN, "Get instant uber (only  medic)");
	RegAdminCmd("sm_candy_buy_regen", cBuyRegen, ADMFLAG_BAN, "Fill health and ammo");
	RegAdminCmd("sm_candy_buy_powerplay", cBuyPowerPlay, ADMFLAG_BAN, "Robin Walker!");
	RegAdminCmd("sm_candy_buy_slay", cBuySlay, ADMFLAG_BAN, "Slay a player!");
	RegAdminCmd("sm_candy_countdown", cCountdown, ADMFLAG_BAN, "Countdown");

	HudCounter = CreateHudSynchronizer();
	cvNoiseLevel = CreateConVar("sm_candy_buy_noiselevel", "2", "1 = silent, 2 = buyer only, 3 = everyone", FCVAR_PLUGIN, true, 1.0, true, 3.0);
}

public Action:cBuyCrit(client, args)
{
	new String:sErrStr[] = "[candypack] Usage: sm_candy_buy_cond <#userid|name|@all|@red|@blue|@bots> <TFCond> <duration>";
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
				PrintToChat(target_list[i], "Towar zakupiony użyj go dobrze!");
			}
			else if (noise == 3)
			{
				new String:name[128];
				GetClientName(target_list[i], name, sizeof(name));
				PrintToChatAll("%s kupił sobie Ubera lub Kryty, uciekajcie!", name);
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

public Action:cBuyUber(client, args)
{
	new String:sErrStr[] = "[candypack] Usage: sm_candy_buy_uber <#userid|name|@all|@red|@blue|@bots> <amount>";
	if (args < 2)
	{
		PrintToServer(sErrStr);
		return Plugin_Handled;
	}
	
	decl String:target[MAXPLAYERS];
	decl String:amount[3];
	decl String:target_name[MAX_TARGET_LENGTH];
	decl target_list[MAXPLAYERS];
	decl target_count;
	decl bool:tn_is_ml;

	GetCmdArg(1, target, sizeof(target));
	GetCmdArg(2, amount, sizeof(amount));
	new iamount = StringToInt(amount);
	new noise = GetConVarInt(cvNoiseLevel);

	if (iamount > 0)
	{
		PrintToServer(sErrStr);
		return Plugin_Handled;
	}
	
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
			new TFClassType:class = TF2_GetPlayerClass(target_list[i]);
			if(class == TFClass_Medic)
			{
				new iSlot = GetPlayerWeaponSlot(client, 1);
				if (iSlot > 0)
				{
					SetEntPropFloat(iSlot, Prop_Send, "m_flChargeLevel", iamount*0.01);
				}
				if (noise == 2)
				{
					PrintToChat(target_list[i], "Kupiłeś sobie %i ubera!", iamount);
				}
				else if (noise == 3)
				{
					new String:name[128];
					GetClientName(target_list[i], name, sizeof(name));
					PrintToChatAll("%s kupił sobie %i ubera", name, iamount);
				}
			}
			return Plugin_Handled;
		}
	}
	return Plugin_Handled;
}

public Action:cBuyPowerPlay(client, args)
{
	new String:sErrStr[] = "[candypack] Usage: sm_candy_buy_powerplay <#userid|name|@all|@red|@blue|@bots> <1|0>";
	if (args < 2)
	{
		PrintToServer(sErrStr);
		return Plugin_Handled;
	}
	
	decl String:target[MAXPLAYERS];
	decl String:onoff[2];
	decl String:target_name[MAX_TARGET_LENGTH];
	decl target_list[MAXPLAYERS];
	decl target_count;
	decl bool:tn_is_ml;

	GetCmdArg(1, target, sizeof(target));
	GetCmdArg(2, onoff, sizeof(onoff));
	new i_onoff = StringToInt(onoff);
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
			TF2_SetPlayerPowerPlay(target_list[i], bool:i_onoff);
			
			if (noise == 2)
			{
				PrintToChat(target_list[i], "Poczuj się jak Robin Walker!");
			}
			else if (noise == 3)
			{
				new String:name[128];
				GetClientName(target_list[i], name, sizeof(name));
				PrintToChatAll("%s jest tak samo potężny jak Robin Walker!", name);
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

public Action:cCountdown(client, args)
{
	new String:sErrStr[] = "[candypack] Usage: sm_candy_countdown <#userid|name|@all|@red|@blue|@bots> [time]";
	if (args < 2)
	{
		PrintToServer(sErrStr);
		return Plugin_Handled;
	}

	g_CounterTimeStart = GetTime();
	
	decl String:target[MAXPLAYERS];
	decl String:time[3];
	decl String:target_name[MAX_TARGET_LENGTH];
	decl target_list[MAXPLAYERS];
	decl target_count;
	decl bool:tn_is_ml;

	GetCmdArg(1, target, sizeof(target));
	GetCmdArg(2, time, sizeof(time));
	g_Time = StringToInt(time);
	
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
		PerformCounter(target_list[i]);
	}	
	return Plugin_Handled;
}

PerformCounter(target)
{
	g_CountdownTimer = CreateTimer(1.0, Counter, target, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE)
}

public Action:Counter(Handle:timer, any:target)
{
	if (TimeRemaining() > 5)
	{
		SetHudTextParams(-1.0, 0.52, 1.0, 0, 0, 255, 150);
	}
	else if(TimeRemaining() <= 5)
	{
		SetHudTextParams(-1.0, 0.52, 1.0, 255, 0, 0, 150);
	}
	ShowSyncHudText(target, HudCounter, "%i s", TimeRemaining());

	if (TimeRemaining() == 0)
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

TimeRemaining()
{
	new RemainingTime = g_CounterTimeStart + g_Time - GetTime();
	if (RemainingTime < 0)
	{
		return 0;
	}
	else
	{
		return RemainingTime;
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