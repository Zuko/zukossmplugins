/*
 * TODO:
 * - Multi-Lang (może się kiedyś przyda | tylko jak zrobić multi-lang w buymenu...)
 */

#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>

new Handle:cvNoiseLevel;
new Handle:HudCounter;
new Handle:dataPack[MAXPLAYERS];
new Handle:dataPackstun[MAXPLAYERS];
new Handle:CountdownTimer[MAXPLAYERS];
new g_CounterTimeStart[MAXPLAYERS];
new g_Time[MAXPLAYERS];

#define PLUGIN_VERSION "0.6"

public Plugin:myinfo = 
{
	name = "Fun package for Candy",
	author = "Zuko (based on GachL version)",
	description = "This plugin is a pack of functions that work well with Candy for TF2.",
	version = PLUGIN_VERSION,
	url = "http://HLDS.pl"
}

public OnPluginStart()
{
	RegAdminCmd("sm_candy_buy_cond", cBuyCond, ADMFLAG_BAN, "Buy a Condition!");
	RegAdminCmd("sm_candy_buy_condplayer", cBuyCondPlayer, ADMFLAG_BAN, "Buy a Condition against another player!");
	RegAdminCmd("sm_candy_buy_stunplayer", cBuyStunPlayer, ADMFLAG_BAN, "Stun another player!");
	RegAdminCmd("sm_candy_buy_uber", cBuyUber, ADMFLAG_BAN, "Get instant uber (only  medic)");
	RegAdminCmd("sm_candy_buy_regen", cBuyRegen, ADMFLAG_BAN, "Fill health and ammo");
	RegAdminCmd("sm_candy_buy_powerplay", cBuyPowerPlay, ADMFLAG_BAN, "Robin Walker!");
	RegAdminCmd("sm_candy_give_candy", cBuyCandyToPlayer, ADMFLAG_BAN, "Give candy to a player!");
	RegAdminCmd("sm_candy_buy_slay", cBuySlay, ADMFLAG_BAN, "Slay a player!");
	RegAdminCmd("sm_candy_ignite", cBuyIgnite, ADMFLAG_BAN, "Ignite Player!");
	RegAdminCmd("sm_candy_countdown", cCountdown, ADMFLAG_BAN, "Countdown");

	LoadTranslations("common.phrases");
	HookEvent("player_death", EventPlayerDeath);

	HudCounter = CreateHudSynchronizer();
	cvNoiseLevel = CreateConVar("sm_candy_buy_noiselevel", "2", "1 = silent, 2 = buyer only, 3 = everyone", FCVAR_PLUGIN, true, 1.0, true, 3.0);
}

public OnClientDisconnect(client)
{
	if (CountdownTimer[client] != INVALID_HANDLE)
	{
		KillTimer(CountdownTimer[client]);
		CountdownTimer[client] = INVALID_HANDLE;
	}
}

public Action:cBuyCond(client, args)
{
	new String:sErrStr[] = "[candypack] Usage: sm_candy_buy_cond <#userid|name|@all|@red|@blue|@bots> <TFCond> <duration>";
	if (args < 3)
	{
		PrintToServer(sErrStr);
		return Plugin_Handled;
	}
	
	decl String:target[MAXPLAYERS];
	decl String:cond[3];
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
	new i_duration = StringToInt(duration);
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
			if (CountdownTimer[target_list[i]] == INVALID_HANDLE)
			{
				g_Time[target_list[i]] = i_duration;
				g_CounterTimeStart[target_list[i]] = GetTime();
				PerformCounter(target_list[i]);
			}
			
			if (noise == 2)
			{
				PrintToChat(target_list[i], "\x04Towar zakupiony użyj go dobrze!");
			}
			else if (noise == 3)
			{
				new String:name[128];
				GetClientName(target_list[i], name, sizeof(name));
				PrintToChatAll("\x04%s kupił sobie Ubera lub Kryty, uciekajcie!", name);
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
				PrintToChat(target_list[i], "\x04Zostałeś zregenerowany!");
			}
			else if (noise == 3)
			{
				new String:name[128];
				GetClientName(target_list[i], name, sizeof(name));
				PrintToChatAll("\x04%s kupił sobie regeneracje", name);
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
					PrintToChat(target_list[i], "\x04Kupiłeś sobie %i ubera!", iamount);
				}
				else if (noise == 3)
				{
					new String:name[128];
					GetClientName(target_list[i], name, sizeof(name));
					PrintToChatAll("\x04%s kupił sobie %i ubera", name, iamount);
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
			
			if (i_onoff == 1)
			{
				if (noise == 2)
				{
					PrintToChat(target_list[i], "Poczuj się jak Robin Walker!");
				}
				else if (noise == 3)
				{
					new String:name[128];
					GetClientName(target_list[i], name, sizeof(name));
					PrintToChatAll("\x04%s jest tak samo potężny jak Robin Walker!", name);
				}
			}
			else
			{
				if (noise == 2)
				{
					PrintToChat(target_list[i], "\x04Fajnie było ale się skończyło ;-)");
				}
				else if (noise == 3)
				{
					new String:name[128];
					GetClientName(target_list[i], name, sizeof(name));
					PrintToChatAll("\x04%s jest znowu zwykłym n00bem!", name);
				}
			}
		}
	}
	return Plugin_Handled;
}

public Action:cBuySlay(cclient, args)
{
	new String:sErrStr[] = "[candypack] Usage: sm_candy_buy_slay <#userid>";
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
	SetMenuTitle(hMenu, "Kogo zgładzić?");
	for (new i = 1; i <= GetClientCount(); i++)
	{
		if (IsClientConnected(i) && IsClientInGame(i))
		{
			new String:sName[255], String:sInfo[4];
			GetClientName(i, sName, sizeof(sName));
			IntToString(i, sInfo, sizeof(sInfo));
			AddMenuItem(hMenu, sInfo, sName);
		}
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
			PrintToChat(client, "\x04Zgładziłeś %s", sVName);
			PrintToChat(hTarget, "\x04%s cię zgładził! Chyba mu podpadłeś ;P", sAName);
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu)
	}
}

public Action:cBuyCandyToPlayer(cclient, args)
{
	new String:sErrStr[] = "[candypack] Usage: sm_candy_give_candy <#userid>";
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
	
	new Handle:hMenu = CreateMenu(cGiveCandy);
	SetMenuTitle(hMenu, "Komu chcesz podarować cukierki?");
	for (new i = 1; i <= GetClientCount(); i++)
	{
		if (IsClientConnected(i) && IsClientInGame(i))
		{
			new String:sName[255], String:sInfo[4];
			GetClientName(i, sName, sizeof(sName));
			IntToString(i, sInfo, sizeof(sInfo));
			AddMenuItem(hMenu, sInfo, sName);
		}
	}
	DisplayMenu(hMenu, client, 20);
	return Plugin_Handled;
}

public cGiveCandy(Handle:menu, MenuAction:action, client, result)
{
	if (action == MenuAction_Select)
	{
		new String:info[32], String:sAName[255], String:sVName[255];
		GetMenuItem(menu, result, info, sizeof(info))
		new hTarget = StringToInt(info);
		GetClientName(client, sAName, sizeof(sAName));
		GetClientName(hTarget, sVName, sizeof(sVName));

		ServerCommand("sm_candy_add \"%s\" 250", sVName);
		new noise = GetConVarInt(cvNoiseLevel);
		if (noise > 1)
		{		
			PrintToChat(client, "\x04Podarowałeś %s 250 cukierków.", sVName);
			PrintToChat(hTarget, "\x04%s podarował ci 250 cukierków ;P", sAName);
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu)
	}
}

public Action:cBuyIgnite(cclient, args)
{
	new String:sErrStr[] = "[candypack] Usage: sm_candy_ignite <#userid>";
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
	
	new Handle:hMenu = CreateMenu(cIgnite);
	SetMenuTitle(hMenu, "Kogo chcesz podpalić?");
	for (new i = 1; i <= GetClientCount(); i++)
	{
		if (IsClientConnected(i) && IsClientInGame(i))
		{
			new String:sName[255], String:sInfo[4];
			GetClientName(i, sName, sizeof(sName));
			IntToString(i, sInfo, sizeof(sInfo));
			AddMenuItem(hMenu, sInfo, sName);
		}
	}
	DisplayMenu(hMenu, client, 20);
	return Plugin_Handled;
}

public cIgnite(Handle:menu, MenuAction:action, client, result)
{
	if (action == MenuAction_Select)
	{
		new String:info[32], String:sAName[255], String:sVName[255];
		GetMenuItem(menu, result, info, sizeof(info))
		new hTarget = StringToInt(info);
		GetClientName(client, sAName, sizeof(sAName));
		GetClientName(hTarget, sVName, sizeof(sVName));

		TF2_IgnitePlayer(client, hTarget);
		new noise = GetConVarInt(cvNoiseLevel);
		if (noise > 1)
		{		
			PrintToChat(client, "\x04Podpaliłeś %s.", sVName);
			PrintToChat(hTarget, "\x04Zostałeś podpalony przez %s", sAName);
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu)
	}
}

public Action:cBuyCondPlayer(cclient, args)
{
	new String:sErrStr[] = "[candypack] Usage: sm_candy_buy_condplayer <#userid> <TFCond> <duration>";
	if (args < 3)
	{
		PrintToServer(sErrStr);
		return Plugin_Handled;
	}
	
	decl String:cond[3];
	decl String:duration[3];
	new String:sclient[32];
	GetCmdArg(1, sclient, sizeof(sclient));
	GetCmdArg(2, cond, sizeof(cond));
	GetCmdArg(3, duration, sizeof(duration));
	
	new client = GetClientOfUserId(StringToInt(sclient));
	if (!FullCheckClient(client))
	{
		PrintToServer(sErrStr);
		return Plugin_Handled;
	}

	new Handle:hMenu = CreateMenu(cCondPlayer);
	SetMenuTitle(hMenu, "Wybierz swoją ofiarę!");
	for (new i = 1; i <= GetClientCount(); i++)
	{
		if (IsClientConnected(i) && IsClientInGame(i))
		{
			new String:sName[255], String:sInfo[4];
			GetClientName(i, sName, sizeof(sName));
			IntToString(i, sInfo, sizeof(sInfo));
			AddMenuItem(hMenu, sInfo, sName);
		}
	}

	dataPack[client] = CreateDataPack();
	WritePackString(dataPack[client], cond);
	WritePackString(dataPack[client], duration);
	
	DisplayMenu(hMenu, client, 20);
	return Plugin_Handled;
}

public cCondPlayer(Handle:menu, MenuAction:action, client, result)
{
	if (action == MenuAction_Select)
	{
		decl String:cond[3];
		decl String:duration[3];
		ResetPack(dataPack[client]);
		ReadPackString(dataPack[client], cond, sizeof(cond));
		ReadPackString(dataPack[client], duration, sizeof(duration));
		CloseHandle(dataPack[client]);
		new i_cond = StringToInt(cond);
		new Float:f_duration = StringToFloat(duration);
		new i_duration = StringToInt(duration);

		new String:info[32], String:sAName[255], String:sVName[255];
		GetMenuItem(menu, result, info, sizeof(info))
		new hTarget = StringToInt(info);
		GetClientName(client, sAName, sizeof(sAName));
		GetClientName(hTarget, sVName, sizeof(sVName));

		TF2_AddCondition(hTarget, TFCond:i_cond, f_duration);
		if (CountdownTimer[hTarget] == INVALID_HANDLE)
		{
			g_Time[hTarget] = i_duration;
			g_CounterTimeStart[hTarget] = GetTime();
			PerformCounter(hTarget);
		}
		new noise = GetConVarInt(cvNoiseLevel);
		if (noise > 1)
		{		
			PrintToChat(client, "\x04Wkurzyłeś %s w wybrany przez siebie sposób!", sVName);
			PrintToChat(hTarget, "\x04%s stara się cię wkurzyć! Chyba mu podpadłeś ;P\nAle pamiętaj że możesz się zemścić.", sAName);
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu)
	}
}

public Action:cBuyStunPlayer(cclient, args)
{
	new String:sErrStr[] = "[candypack] Usage: sm_candy_buy_stunplayer <#userid> <STUNFlags:0=LOSERSTATE|1=GHOSTSCARE|2=SMALLBONK|3=NORMALBONK|4=BIGBONK> <duration>";
	
	if (args < 3)
	{
		PrintToServer(sErrStr);
		return Plugin_Handled;
	}
	
	decl String:stunflag[3];
	decl String:duration[3];
	new String:sclient[32];
	GetCmdArg(1, sclient, sizeof(sclient));
	GetCmdArg(2, stunflag, sizeof(stunflag));
	GetCmdArg(3, duration, sizeof(duration));
	
	if (StringToInt(stunflag) > 4)
	{
		PrintToServer(sErrStr);
		return Plugin_Handled;
	}

	new client = GetClientOfUserId(StringToInt(sclient));
	if (!FullCheckClient(client))
	{
		PrintToServer(sErrStr);
		return Plugin_Handled;
	}

	new Handle:hMenu = CreateMenu(cStunPlayer);
	SetMenuTitle(hMenu, "Wybierz swoją ofiarę!");
	for (new i = 1; i <= GetClientCount(); i++)
	{
		if (IsClientConnected(i) && IsClientInGame(i))
		{
			new String:sName[255], String:sInfo[4];
			GetClientName(i, sName, sizeof(sName));
			IntToString(i, sInfo, sizeof(sInfo));
			AddMenuItem(hMenu, sInfo, sName);
		}
	}

	dataPackstun[client] = CreateDataPack();
	WritePackString(dataPackstun[client], stunflag);
	WritePackString(dataPackstun[client], duration);
	
	DisplayMenu(hMenu, client, 20);
	return Plugin_Handled;
}

public cStunPlayer(Handle:menu, MenuAction:action, client, result)
{
	if (action == MenuAction_Select)
	{
		decl String:stunflag[3];
		decl String:duration[3];
		ResetPack(dataPackstun[client]);
		ReadPackString(dataPackstun[client], stunflag, sizeof(stunflag));
		ReadPackString(dataPackstun[client], duration, sizeof(duration));
		CloseHandle(dataPackstun[client]);
		new Float:f_duration = StringToFloat(duration);
		new i_duration = StringToInt(duration);

		new String:info[32], String:sAName[255], String:sVName[255];
		GetMenuItem(menu, result, info, sizeof(info))
		new hTarget = StringToInt(info);
		GetClientName(client, sAName, sizeof(sAName));
		GetClientName(hTarget, sVName, sizeof(sVName));

		switch(StringToInt(stunflag))
		{
			case 0:
				TF2_StunPlayer(hTarget, f_duration, Float:0.5, TF_STUNFLAGS_LOSERSTATE);
			case 1:
				TF2_StunPlayer(hTarget, f_duration, Float:0.5, TF_STUNFLAGS_GHOSTSCARE);
			case 2:
				TF2_StunPlayer(hTarget, f_duration, Float:0.5, TF_STUNFLAGS_SMALLBONK);
			case 3:
				TF2_StunPlayer(hTarget, f_duration, Float:0.5, TF_STUNFLAGS_NORMALBONK);
			case 4:
				TF2_StunPlayer(hTarget, f_duration, Float:0.5, TF_STUNFLAGS_BIGBONK);
		}

		if (CountdownTimer[hTarget] == INVALID_HANDLE)
		{
			g_Time[hTarget] = i_duration;
			g_CounterTimeStart[hTarget] = GetTime();
			PerformCounter(hTarget);
		}
		new noise = GetConVarInt(cvNoiseLevel);
		if (noise > 1)
		{		
			PrintToChat(client, "\x04Ogłuszyłeś %s w wybrany przez siebie sposób!", sVName);
			PrintToChat(hTarget, "\x04%s cię ogłuszył! Chyba mu podpadłeś ;P\nAle pamiętaj że możesz się zemścić.", sAName);
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu)
	}
}

public Action:cCountdown(client, args)
{
	new String:sErrStr[] = "[candypack] Usage: sm_candy_countdown <#userid|name|@all|@red|@blue|@bots> <time>";
	if (args < 2)
	{
		PrintToServer(sErrStr);
		return Plugin_Handled;
	}

	decl String:target[MAXPLAYERS];
	decl String:time[3];
	decl String:target_name[MAX_TARGET_LENGTH];
	decl target_list[MAXPLAYERS];
	decl target_count;
	decl bool:tn_is_ml;

	GetCmdArg(1, target, sizeof(target));
	GetCmdArg(2, time, sizeof(time));
	
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
		g_Time[target_list[i]] = StringToInt(time);
		g_CounterTimeStart[target_list[i]] = GetTime();
		PerformCounter(target_list[i]);
	}	
	return Plugin_Handled;
}

PerformCounter(target)
{
	CountdownTimer[target] = CreateTimer(1.0, Counter, target, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE)
}

public Action:Counter(Handle:timer, any:target)
{
	if (TimeRemaining(target) > 5)
	{
		SetHudTextParams(-1.0, 0.52, 1.0, 0, 0, 255, 150);
	}
	else if(TimeRemaining(target) <= 5)
	{
		SetHudTextParams(-1.0, 0.52, 1.0, 255, 0, 0, 150);
	}
	if (FullCheckClient(target))
	{
		ShowSyncHudText(target, HudCounter, "%i s", TimeRemaining(target));
	}

	if ((TimeRemaining(target) == 0) && (CountdownTimer[target] != INVALID_HANDLE))
	{
		KillTimer(CountdownTimer[target]);
		CountdownTimer[target] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

TimeRemaining(target)
{
	new RemainingTime = g_CounterTimeStart[target] + g_Time[target] - GetTime();
	if (RemainingTime < 0)
	{
		return 0;
	}
	else
	{
		return RemainingTime + 1;
	}
}

public Action:EventPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (CountdownTimer[client] != INVALID_HANDLE)
	{
		KillTimer(CountdownTimer[client]);
		CountdownTimer[client] = INVALID_HANDLE;
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