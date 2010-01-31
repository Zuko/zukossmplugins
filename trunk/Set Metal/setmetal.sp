/*
 * Set Engineer Metal Amount
 * 
 * Plugin allows admins to set engineer metal amount.
 *
 * Commands:
 * sm_setmetal	- Usage: <#userid|name> <amount>	Set metal amount for given player
 * sm_smme		- Usage: <amount>					Set metal for you
 * sm_autometal	- Usage: <#userid|name> <amount>	Set auto-metal for given player
 *
 * ConVars:
 * setmetal_version 			- Plugin Version
 * sm_setmetal_enable 		- Enable/Disable Plugin				(0 = Off | 1 = On)					Default: "1"
 * sm_setmetal_chat_notify 	- Chat Notifications 				(0 = Off | 1 = Target | 2 = All) 	Default: "1"
 * sm_autometal_chat_notify 	- Chat Notifications for Auto-Metal 	(0 = Off | 1 = Target | 2 = All) 	Default: "1"
 *
 * Changelog:
 * Version 1.0 (22.01.2010)
 * - Initial Release
 *
 * Zuko / #hlds.pl @ Qnet / zuko.isports.pl /
 */

#include <sourcemod>
#include <colors>
#include <sdktools>

new Handle:g_Cvar_PluginEnable = INVALID_HANDLE;
new Handle:g_Cvar_ChatNotify = INVALID_HANDLE;
new Handle:g_Cvar_ChatNotify_AutoMetal = INVALID_HANDLE;

new bool:autometal_enabled[MAXPLAYERS+1] = false;
new metal_amount[MAXPLAYERS+1] = 0;

/* Choose your access flag */
#define _ADMIN_FLAG_ ADMFLAG_KICK
/* * */

#define PLUGIN_VERSION		"1.0"

public Plugin:myinfo = 
{
	name = "[TF2] Set Engineer Metal Amount",
	author = "Zuko",
	description = "Set Engineer Metal Amount.",
	version = PLUGIN_VERSION,
	url = "http://zuko.isports.pl"
}

public OnPluginStart()
{
	CreateConVar("setmetal_version", PLUGIN_VERSION, "Set Engineer Metal Plugin Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	g_Cvar_PluginEnable = CreateConVar("sm_setmetal_enable", "1", "Enable/Disable Plugin", _, true, 0.0, true, 1.0);
	g_Cvar_ChatNotify = CreateConVar("sm_setmetal_chat_notify", "1", "Chat Notifications", _, true, 0.0, true, 2.0);
	g_Cvar_ChatNotify_AutoMetal = CreateConVar("sm_autometal_chat_notify", "1", "Chat Notifications For Auto-Metal",	_, true, 0.0, true, 2.0);
	
	RegAdminCmd("sm_setmetal", Command_SetMetal, _ADMIN_FLAG_, "sm_setmetal <#userid|name> <amount>");
	RegAdminCmd("sm_smme", Command_SetMetalMe, _ADMIN_FLAG_, "sm_smme <amount>");
	RegAdminCmd("sm_autometal", Command_AutoMetal, _ADMIN_FLAG_, "sm_autometal <#userid|name> <amount>");
	
	
	LoadTranslations("common.phrases");
	LoadTranslations("setmetal.phrases");
	
	AutoExecConfig(true, "plugin.setmetal");
	
	/* Hook Events */
	HookEvent("player_spawn", EventPlayerSpawn);
}

public OnClientPostAdminCheck(client)
{
	autometal_enabled[client] = false;
	metal_amount[client] = 0;
}

public OnClientDisconnect(client)
{
	autometal_enabled[client] = false;
	metal_amount[client] = 0;
}

 /* SetMetal on Me */
public Action:Command_SetMetalMe(client, args)
{
	new nMetal;
	
	decl String:amount[10]
	
	if (GetConVarInt(g_Cvar_PluginEnable) == 0)
	{
		ReplyToCommand(client, "[SM] %T", "PluginDisabled", LANG_SERVER);
		return Plugin_Stop;
	}
	
	if (args != 1)
	{
		ReplyToCommand(client, "[SM] %T", "PluginUsage_SetMetal_Me", LANG_SERVER);
		return Plugin_Handled;	
	}
	else
	{
		GetCmdArg(1, amount, sizeof(amount));
		nMetal = StringToInt(amount);
	}
	
	if (nMetal < 0)
	{
		nMetal = 0;
		ReplyToCommand(client, "[SM] %T", "MetalAmount1", LANG_SERVER);
	}
	
	if (nMetal > 200)
	{
		nMetal = 200;
		ReplyToCommand(client, "[SM] %T", "MetalAmount2", LANG_SERVER);
	}
	
	if (IsClientConnected(client) && IsClientInGame(client))
	{
		if (GetEntProp(client, Prop_Send, "m_iClass") == 9)
		{
			TF_SetMetalAmount(client, nMetal);
			ReplyToCommand(client, "[SM] %T", "MetalSetOnMe", LANG_SERVER, nMetal);
		}
		else
			ReplyToCommand(client, "[SM] %T", "MustBeEngineer2", LANG_SERVER);
	}
	return Plugin_Handled;
}
/* >>> end of SetMetal on Me */

/* SetMetal */
public Action:Command_SetMetal(client, args)
{
	new nMetal;
	
	if (GetConVarInt(g_Cvar_PluginEnable) == 0)
	{
		ReplyToCommand(client, "[SM] %T", "PluginDisabled", LANG_SERVER);
		return Plugin_Stop;
	}
		
	decl String:target[MAXPLAYERS], String:amount[10], String:target_name[MAX_TARGET_LENGTH];
	decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
	
	if (args < 2)
	{
		ReplyToCommand(client, "[SM] %T", "PluginUsage", LANG_SERVER);
		return Plugin_Handled;
	}
	else
	{
		GetCmdArg(1, target, sizeof(target));
		GetCmdArg(2, amount, sizeof(amount));
		nMetal = StringToInt(amount);
	}

	if (nMetal < 0)
	{
		nMetal = 0;
		ReplyToCommand(client, "[SM] %T", "MetalAmount1", LANG_SERVER);
	}
	
	if (nMetal > 200)
	{
		nMetal = 200;
		ReplyToCommand(client, "[SM] %T", "MetalAmount2", LANG_SERVER);
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
		if (GetEntProp(target_list[i], Prop_Send, "m_iClass") == 9)
		{
			TF_SetMetalAmount(target_list[i], nMetal);
		
			switch(GetConVarInt(g_Cvar_ChatNotify))
			{
				case 0:
					return Plugin_Continue;
				case 1:
					CPrintToChat(target_list[i], "{lightgreen} [SM] %T", "MetalPhrase1", LANG_SERVER, client, nMetal);
				case 2:
					CPrintToChatAll("{lightgreen}[SM] %T", "MetalPhrase2", LANG_SERVER, client, target_list[i], nMetal);
			}
			ReplyToCommand(client, "[SM] %T", "MetalPhrase3", LANG_SERVER, target_list[i], nMetal);
		}
		else
			ReplyToCommand(client, "[SM] %T", "MustBeEngineer", LANG_SERVER)
	}	
	return Plugin_Handled;
}
/* >>> end of SetMetal */

/* AutoSetMetal */
public Action:Command_AutoMetal(client, args)
{
	new nMetal;

	if (GetConVarInt(g_Cvar_PluginEnable) == 0)
	{
		ReplyToCommand(client, "[SM] %T", "PluginDisabled", LANG_SERVER);
		return Plugin_Stop;
	}
		
	decl String:target[MAXPLAYERS], String:amount[10], String:target_name[MAX_TARGET_LENGTH];
	decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
	
	if (args < 2)
	{
		ReplyToCommand(client, "[SM] %T", "PluginUsage_AutoMetal", LANG_SERVER);
		return Plugin_Handled;
	}
	else
	{
		GetCmdArg(1, target, sizeof(target));
		GetCmdArg(2, amount, sizeof(amount));
		nMetal = StringToInt(amount);
	}

	if (nMetal < 0)
	{
		nMetal = 0;
		ReplyToCommand(client, "[SM] %T", "MetalAmount1", LANG_SERVER);
	}
	
	if (nMetal > 200)
	{
		nMetal = 200;
		ReplyToCommand(client, "[SM] %T", "MetalAmount2", LANG_SERVER);
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
			MAX_TARGET_LENGTH,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (new i = 0; i < target_count; i++)
	{
		if (GetEntProp(target_list[i], Prop_Send, "m_iClass") == 9)
		{
			if (IsClientConnected(target_list[i]) && IsClientInGame(target_list[i]))
			{
				autometal_enabled[target_list[i]] = true;
				metal_amount[target_list[i]] = nMetal;
				
				if (IsPlayerAlive(target_list[i]))
				{
					TF_SetMetalAmount(target_list[i], nMetal);
				}
				if (client == target_list[i])
				{
					if (nMetal == 0)
					{
						ReplyToCommand(client, "[SM] %T", "AutoMetalReply1", LANG_SERVER);
					}
					else
					ReplyToCommand(client, "[SM] %T", "AutoMetalReply2", LANG_SERVER, nMetal);
				}
				else if (nMetal == 0)
				{
					ReplyToCommand(client, "[SM] %T", "AutoMetalReply3", LANG_SERVER, target_list[i]);
				}
				else
				ReplyToCommand(client, "[SM] %T", "AutoMetalReply4", LANG_SERVER, target_list[i], nMetal);
					
				switch(GetConVarInt(g_Cvar_ChatNotify_AutoMetal))
				{
					case 0:
						return Plugin_Continue;
					case 1:
					{
						if (client == target_list[i])
						{	
							if (nMetal == 0)
							{
								CPrintToChat(target_list[i], "{lightgreen}[SM] %T", "AutoMetalPhrase4", LANG_SERVER);
							}
							else
							{
								CPrintToChat(target_list[i], "{lightgreen}[SM] %T", "AutoMetalPhrase3", LANG_SERVER);
								CPrintToChat(target_list[i], "{lightgreen}[SM] %T", "AutoMetalPhrase3a", LANG_SERVER, nMetal);
							}
						}
						else
						{
							CPrintToChat(target_list[i], "{lightgreen}[SM] %T", "AutoMetalPhrase1", LANG_SERVER, client);
							CPrintToChat(target_list[i], "{lightgreen}[SM] %T", "AutoMetalPhrase1a", LANG_SERVER, nMetal);
						}
					}
					case 2:
					{
						if (nMetal == 0)
						{
							CPrintToChatAll("{lightgreen}[SM] %T", "AutoMetalPhrase5", LANG_SERVER, client, target_list[i]);
						}
						else
						{
							CPrintToChatAll("{lightgreen}[SM] %T", "AutoMetalPhrase2", LANG_SERVER, client, target_list[i]);
							CPrintToChatAll("{lightgreen}[SM] %T", "AutoMetalPhrase2a", LANG_SERVER, nMetal);
						}
					}
				}
			}
		}
		else
		{
			ReplyToCommand(client, "[SM] %T", "MustBeEngineer", LANG_SERVER);
		}
	}	
	return Plugin_Handled;
}
/* >>> end of AutoSetMetal */

/* Events */
public Action:EventPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new MetalAmount = 0;
	
	if (GetEntProp(client, Prop_Send, "m_iClass") == 9)
	{
		if (autometal_enabled[client] == true)
		{
			MetalAmount = metal_amount[client];
			if (MetalAmount == 0)
			{
				autometal_enabled[client] = false;
				return Plugin_Handled;
			}
			else
			{
				TF_SetMetalAmount(client, MetalAmount)
			}
		}
	}
	else
	{
		autometal_enabled[client] = false;
		metal_amount[client] = 0;
	}
	return Plugin_Continue;
}
/* >>> end of Events */

stock TF_SetMetalAmount(client, metalamount)
{
	SetEntData(client, FindDataMapOffs(client, "m_iAmmo") + (3 * 4), metalamount, 4, true);
}