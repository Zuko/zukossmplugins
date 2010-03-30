/////////////////////////////////////////////////////////////////////
// Changelog
/////////////////////////////////////////////////////////////////////
// 2010/03/01 - 0.1.0
// E1.3.1‚ÅƒRƒ“ƒpƒCƒ‹
// Esm_rmf_ability_menu_admin_only‚ğ’Ç‰Á
// 2009/09/20 - 0.0.8
// Eƒƒjƒ…[•\¦ƒRƒ}ƒ“ƒh‚Ì–â‘è‚ğC³
// 2009/09/20 - 0.0.7
// EƒVƒ‡[ƒgƒRƒ}ƒ“ƒh“‹ÚB"!r"‚Å‚àƒƒjƒ…[‚ª•\¦‰Â”\‚É‚È‚Á‚½B
// 2009/09/05 - 0.0.6
// EŠÏíE‚Ü‚½‚Íƒ`[ƒ€‚ğ‘I‚ñ‚Å‚¢‚È‚¢ê‡‚Íƒƒjƒ…[‚ğ•\¦‚µ‚È‚¢‚æ‚¤‚É‚µ‚½B
// 2009/08/24 - 0.0.5
// EƒŠƒXƒ|ƒ“ƒ‹[ƒ€“à‚È‚ç‚·‚®‚É‘•”õ•ÏX‚Å‚«‚é‚æ‚¤‚É‚µ‚½B
// EƒAƒŠ[ƒiƒ‚[ƒhEƒTƒhƒ“ƒfƒXƒ‚[ƒh‚Ìê‡‚Íƒ‰ƒEƒ“ƒhŠJn‚©‚ç”•b‚ªŒo‰ß‚·‚é‚Æ•ÏX•s‰Â
// E1.2.3‚ÅƒRƒ“ƒpƒCƒ‹
// 2009/08/14 - 0.0.2
// EƒNƒ‰ƒXƒŒƒXƒAƒbƒvƒf[ƒg‚É‘Î‰(1.2.2‚ÅƒRƒ“ƒpƒCƒ‹)
// Esm_rmf_allow_ability_menu‚ğ0‚É‚µ‚Ä‚àƒƒjƒ…[‚ª•\¦‚³‚ê‚Ä‚¢‚½‚Ì‚ğC³


/////////////////////////////////////////////////////////////////////
//
// ƒCƒ“ƒNƒ‹[ƒh
//
/////////////////////////////////////////////////////////////////////
#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>
#include "rmf/tf2_codes"
#include "rmf/tf2_events"

/////////////////////////////////////////////////////////////////////
//
// ’è”
//
/////////////////////////////////////////////////////////////////////
#define PL_NAME "RMF Ability Menu"
#define PL_DESC "RMF Ability Menu"
#define PL_VERSION "0.1.0"

#define MAX_PLUGINS 64
#define MAX_PLUGIN_NAME 64

/////////////////////////////////////////////////////////////////////
//
// MODî•ñ
//
/////////////////////////////////////////////////////////////////////
public Plugin:myinfo = 
{
	name = PL_NAME,
	author = "RIKUSYO",
	description = PL_DESC,
	version = PL_VERSION,
	url = "http://ameblo.jp/rikusyo/"
}

/////////////////////////////////////////////////////////////////////
//
// ƒOƒ[ƒoƒ‹•Ï”
//
/////////////////////////////////////////////////////////////////////
new Handle:g_ConVarAdminOnly = INVALID_HANDLE;				// ConVarAdminOnly

new String:g_RMFPlugins[MAX_PLUGINS][MAX_PLUGIN_NAME];	// ƒvƒ‰ƒOƒCƒ“–¼
new g_PluginNum = 0;									// ƒvƒ‰ƒOƒCƒ“”

new Handle:g_MenuTimer = INVALID_HANDLE;				// ƒƒjƒ…[I—¹ƒ^ƒCƒ}[
new bool:g_AbilityLock = false;							// ƒAƒŠ[ƒiŠJnÏ‚İH
new bool:g_SelectedAbility[MAXPLAYERS+1] = false;		// ƒAƒrƒŠƒeƒB[‘I‘ğÏ‚İH
new String:g_NextAbilityName[MAXPLAYERS+1][128];
new String:g_NowAbilityName[MAXPLAYERS+1][128];

new bool:g_InRespawnRoom[MAXPLAYERS+1] = false;			// ƒŠƒXƒ|ƒ“ƒ‹[ƒ€‚É‚¢‚éH

new String:sSQLName[3] = "rmf";
new String:sTablePrefix[5] = "rmf_";

new Handle:Database = INVALID_HANDLE;

public ConnectToDatabase()
{
	if (Database != INVALID_HANDLE)
	{
		return;
	}
	
	Database = SQL_TConnect(TSql, sSQLName);
	
}

public TSql(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogError("RMF Database failure: %s", error);
	} else {
		Database = hndl;
	}
}

/////////////////////////////////////////////////////////////////////
//
// ƒCƒxƒ“ƒg”­“®
//
/////////////////////////////////////////////////////////////////////
stock Action:Event_FiredUser(Handle:event, const String:name[], any:client=0)
{

	// ƒvƒ‰ƒOƒCƒ“ŠJn
	if(StrEqual(name, EVENT_PLUGIN_START))
	{
		// Œ¾Œêƒtƒ@ƒCƒ‹“Ç
		LoadTranslations("rmf_abilitymenu.phrases");

		// ƒRƒ}ƒ“ƒhì¬
		CreateConVar("sm_rmf_tf_ability_menu", PL_VERSION, PL_NAME, FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
		g_IsPluginOn = CreateConVar("sm_rmf_allow_ability_menu","1","Ability menu Enable/Disable (0 = disabled | 1 = enabled)");

		// ConVarƒtƒbƒN
		HookConVarChange(g_IsPluginOn, ConVarChange_IsPluginOn);
		
		RegConsoleCmd("say", Command_Say);
		RegConsoleCmd("say_team", Command_Say);
		
		RegAdminCmd("sm_rmf_give_licence", cGiveLicence, ADMFLAG_ROOT, "Give ability licence");

		// ƒŠƒXƒ|ƒ“ƒ‹[ƒ€‚Ì‘Şo‚È‚Ç‚ğƒtƒbƒN
		HookEntityOutput("func_respawnroom",  "OnStartTouch",    EntityOutput_StartTouch);
		HookEntityOutput("func_respawnroom", "OnEndTouch",    EntityOutput_EndTouch);
		
		g_ConVarAdminOnly = CreateConVar("sm_rmf_ability_menu_admin_only",	"0",	"Admin Only Enable/Disable (0 = disabled | 1 = enabled)");
		HookConVarChange(g_ConVarAdminOnly,		ConVarChange_Bool);	
		
		ConnectToDatabase();
		
		// RMFƒvƒ‰ƒOƒCƒ“ƒŠƒXƒgæ“¾
		new String:file[256];
		BuildPath(Path_SM, file, 255, "configs/RMFPlugins.txt");
		
		// ƒtƒ@ƒCƒ‹‚©‚çæ“¾
		new Handle:fileh = OpenFile(file, "r");
		if(fileh != INVALID_HANDLE)
		{
			new String:buffer[256];
			new String:smxName[128];
			while (ReadFileLine(fileh, buffer, sizeof(buffer)))
			{
				// ‰üsƒR[ƒh‚ğC³
				//new len = strlen(buffer)
				//if(buffer[len-1] == '\n')
				//{
				//	PrintToServer("%s", buffer);
		   		//	buffer[len-1] = '\0';
				//}
				
				// ƒgƒŠƒ€
				TrimString(buffer);
				
				// SMXƒtƒ@ƒCƒ‹‚ª‚ ‚é‚©ƒ`ƒFƒbƒN
				Format(smxName, sizeof(smxName), "addons/sourcemod/plugins/%s.smx", buffer)
				//PrintToServer("%s %d", smxName, FileExists(smxName));
				if(FileExists(smxName))
				{
					new String:phrasesPath[256];
					new String:phrasesName[256];
					// ‘¶İ‚µ‚½‚çƒvƒ‰ƒOƒCƒ“–¼‚ğ(—áFAfterBurner)ƒŠƒXƒg‚É•Û‘¶
					strcopy(g_RMFPlugins[g_PluginNum], MAX_PLUGIN_NAME, buffer);
					
					// Œ¾Œêƒtƒ@ƒCƒ‹–¼İ’è
					StringToLower(phrasesName, buffer);	// ‘å•¶š‚ğ¬•¶š‚É
					Format(phrasesName, sizeof(phrasesName), "%s.phrases", phrasesName)
					Format(phrasesPath, sizeof(phrasesPath), "addons/sourcemod/translations/%s.txt", phrasesName)
					//PrintToServer("%s", phrasesPath);
					
					// ƒtƒ@ƒCƒ‹‚ª‘¶İ‚µ‚½‚çŒ¾Œêƒtƒ@ƒCƒ‹“Ç‚İ‚İ
					if(FileExists(phrasesPath))
					{
						LoadTranslations(phrasesName);
					}
					
					// ƒvƒ‰ƒOƒCƒ“”‚ğ•Û‘¶
					g_PluginNum += 1;
				}
				
				if(IsEndOfFile(fileh))
					break;
			}		
		}
		else
		{
			// “Ç‚ß‚Ü‚¹‚ñ‚Å‚µ‚½
			LogMessage("configs/RMFPlugins.txt was not able to be read.");
		}
			
		g_AbilityLock = false;
	}

	// ƒvƒ‰ƒOƒCƒ“ó‘Ô•ÏX
	if(StrEqual(name, EVENT_PLUGIN_STATE_CHANGED))
	{
		// ‘Sˆõ‰ğœİ’è
		new maxclients = GetMaxClients();
		for (new i = 1; i <= maxclients; i++)
		{
			if( IsClientInGame(i) )
			{
				// ƒAƒrƒŠƒeƒB‘S•”g—p•s‰Â‚ÉB
				for(new j = 0; j < g_PluginNum; j++)
				{
					ServerCommand("rmf_ability %d %s 0", i, g_RMFPlugins[j]);
				}		
				g_SelectedAbility[i] = false;
				g_NextAbilityName[i] = "";
				g_NowAbilityName[i] = "";
			}
		}
		
	}

	
	
	// ƒ}ƒbƒvƒXƒ^[ƒg
	if(StrEqual(name, EVENT_MAP_START))
	{
		new maxclients = GetMaxClients();
		for (new i = 1; i <= maxclients; i++)
		{
			g_SelectedAbility[client] = false;
			g_NextAbilityName[client] = "";
			g_NowAbilityName[client] = "";
		}
		
		
	}
	// ƒ}ƒbƒvƒGƒ“ƒh
	if(StrEqual(name, EVENT_MAP_END))
	{
		new maxclients = GetMaxClients();
		for (new i = 1; i <= maxclients; i++)
		{
			g_SelectedAbility[client] = false;
			g_NextAbilityName[client] = "";
			g_NowAbilityName[client] = "";
		}
		// ƒ^ƒCƒ}[ƒNƒŠƒA
		if(g_MenuTimer != INVALID_HANDLE)
		{
			KillTimer(g_MenuTimer);
			g_MenuTimer = INVALID_HANDLE;
		}
		// ƒ‰ƒEƒ“ƒhI—¹
		g_AbilityLock = false;		
	}	
	// ƒAƒŠ[ƒiƒ‰ƒEƒ“ƒhƒAƒNƒeƒBƒu
	if(StrEqual(name, EVENT_ARENA_ROUND_ACTIVE))
	{

		// ƒ^ƒCƒ}[ƒNƒŠƒA
		if(g_MenuTimer != INVALID_HANDLE)
		{
			KillTimer(g_MenuTimer);
			g_MenuTimer = INVALID_HANDLE;
		}
		g_MenuTimer = CreateTimer(5.0, Timer_MenuEnd, 0);
		// ƒ‰ƒEƒ“ƒhŠJn
		g_AbilityLock = true;
	
	}
	// ƒTƒhƒ“ƒfƒXŠJn
	if(StrEqual(name, EVENT_SUDDEN_DEATH_START))
	{

		// ƒ^ƒCƒ}[ƒNƒŠƒA
		if(g_MenuTimer != INVALID_HANDLE)
		{
			KillTimer(g_MenuTimer);
			g_MenuTimer = INVALID_HANDLE;
		}
		g_MenuTimer = CreateTimer(10.0, Timer_MenuEnd, 0);
		// ƒ‰ƒEƒ“ƒhŠJn
		g_AbilityLock = true;
	}
	
	// ƒAƒŠ[ƒiWinƒpƒlƒ‹
	if(StrEqual(name, EVENT_ARENA_WIN_PANEL))
	{
		// ƒ^ƒCƒ}[ƒNƒŠƒA
		if(g_MenuTimer != INVALID_HANDLE)
		{
			KillTimer(g_MenuTimer);
			g_MenuTimer = INVALID_HANDLE;
		}
		// ƒ‰ƒEƒ“ƒhI—¹
		g_AbilityLock = false;
	
	}
	// Winƒpƒlƒ‹
	if(StrEqual(name, EVENT_WIN_PANEL))
	{
		// ƒ^ƒCƒ}[ƒNƒŠƒA
		if(g_MenuTimer != INVALID_HANDLE)
		{
			KillTimer(g_MenuTimer);
			g_MenuTimer = INVALID_HANDLE;
		}
		// ƒ‰ƒEƒ“ƒhI—¹
		g_AbilityLock = false;
	
	}
	
	// ƒvƒŒƒCƒ„[ƒNƒ‰ƒX•ÏX
	if(StrEqual(name, EVENT_PLAYER_CHANGE_CLASS))
	{
		
		if( IsClientInGame(client) && !IsPlayerAlive(client))
		{
			// æ‚è‡‚¦‚¸ƒAƒrƒŠƒeƒB‘S•”g—p•s‰Â‚ÉB
			for(new i = 0; i < g_PluginNum; i++)
			{
				ServerCommand("rmf_ability %d %s 0", client, g_RMFPlugins[i]);
			}		
			g_SelectedAbility[client] = false;
			g_NextAbilityName[client] = "";
			g_NowAbilityName[client] = "";
		}

	}
	// ƒvƒŒƒCƒ„[•œŠˆ
	if(StrEqual(name, EVENT_PLAYER_SPAWN))
	{
	
		// ƒ^ƒCƒ}[ƒNƒŠƒA
//		if(g_MenuTimer[client] != INVALID_HANDLE)
//		{
//			KillTimer(g_MenuTimer[client]);
//			g_MenuTimer[client] = INVALID_HANDLE;
//		}
//		g_MenuTimer[client] = CreateTimer(10.0, Timer_MenuEnd, client);

		if(!StrEqual(g_NowAbilityName[client], "") || !StrEqual(g_NextAbilityName[client], ""))
		{
			new bool:otherClass = false;
			new String:lowerName[64];
			new String:buffer[128];
			new Handle:cvar;

			// Ÿ‚ÌƒAƒrƒŠƒeƒB
			StringToLower(lowerName, g_NextAbilityName[client]);	// ‘å•¶š‚ğ¬•¶š‚É
			// ƒNƒ‰ƒXCVARæ“¾
			Format(buffer, sizeof(buffer), "sm_rmf_%s_class", lowerName);
			cvar = FindConVar(buffer);
			if(cvar != INVALID_HANDLE && TFClassType:GetConVarInt(cvar) != TF2_GetPlayerClass( client ))
			{
				otherClass = true;
			}
			
			lowerName = "";
			buffer = "";
			
			// ¡‚ÌƒAƒrƒŠƒeƒB
			StringToLower(lowerName, g_NowAbilityName[client]);	// ‘å•¶š‚ğ¬•¶š‚É
			// ƒNƒ‰ƒXCVARæ“¾
			Format(buffer, sizeof(buffer), "sm_rmf_%s_class", lowerName);
			
			cvar = FindConVar(buffer);
			if(cvar != INVALID_HANDLE && TFClassType:GetConVarInt(cvar) != TF2_GetPlayerClass( client ))
			{
				otherClass = true;
			}
			
			if(otherClass)
			{
				// ƒAƒrƒŠƒeƒB‘S•”g—p•s‰Â‚ÉB
				for(new i = 0; i < g_PluginNum; i++)
				{
					ServerCommand("rmf_ability %d %s 0", client, g_RMFPlugins[i]);
				}	
				
				g_SelectedAbility[client] = false;
				g_NextAbilityName[client] = "";
				g_NowAbilityName[client] = "";
				
			}
			
		}

		
		
		// ƒAƒrƒŠƒeƒB•ÏX
		if(!StrEqual(g_NextAbilityName[client], ""))
		{
			if(!StrEqual(g_NextAbilityName[client], "Unequipped"))
			{

				g_NowAbilityName[client] = g_NextAbilityName[client];
				
				// ‘å•¶šæ“¾
				new String:upperName[32];
				StringToUpper(upperName, g_NextAbilityName[client]);	// ¬•¶š‚ğ‘å•¶š‚É
				
				// æ‚è‡‚¦‚¸ƒAƒrƒŠƒeƒB‘S•”g—p•s‰Â‚ÉB
				for(new i = 0; i < g_PluginNum; i++)
				{
					ServerCommand("rmf_ability %d %s 0", client, g_RMFPlugins[i]);
				}		

				// ‘I‘ğ‚µ‚½ƒAƒrƒŠƒeƒB‚ğ—LŒø
				ServerCommand("rmf_ability %d %s 1", client, g_NextAbilityName[client]);

				// ƒvƒ‰ƒOƒCƒ“–¼æ“¾
				new String:pluginName[64];
				Format(pluginName, sizeof(pluginName), "ABILITYNAME_%s", upperName);
				Format(pluginName, sizeof(pluginName), "%T", pluginName, client);
				PrintToChat(client, "\x04%T", "ABILITYMENU_EQUIPPED", client, pluginName);
				
				g_SelectedAbility[client] = true;
				g_NextAbilityName[client] = "";
			
			}
			else
			{
				// ƒAƒrƒŠƒeƒB‘S•”g—p•s‰Â‚ÉB
				for(new i = 0; i < g_PluginNum; i++)
				{
					ServerCommand("rmf_ability %d %s 0", client, g_RMFPlugins[i]);
				}	
				
				if(g_SelectedAbility[client])
				{
					PrintToChat(client, "\x04%T", "ABILITYMENU_UNEQUIPPED", client);
				}
				g_SelectedAbility[client] = false;
				g_NextAbilityName[client] = "";
				g_NowAbilityName[client] = "";
			}
		}
				
	}

	// ƒvƒŒƒCƒ„[ƒŠƒZƒbƒg
	if(StrEqual(name, EVENT_PLAYER_DATA_RESET))
	{
		if(g_IsRunning)
		{
			if(!g_SelectedAbility[client] && g_PluginNum > 0)
			{
				Format(g_PlayerHintText[client][0], HintTextMaxSize , "%T", "DESCRIPTION_MENU", client);
			}
		}

		
	}
	// ƒvƒŒƒCƒ„[•œŠˆƒfƒBƒŒƒC
	if(StrEqual(name, EVENT_PLAYER_SPAWN_DELAY))
	{

	}
	
	// ƒvƒŒƒCƒ„[Ø’f
	if(StrEqual(name, EVENT_PLAYER_DISCONNECT))
	{
		// æ‚è‡‚¦‚¸ƒAƒrƒŠƒeƒB‘S•”g—p•s‰Â‚ÉB
		for(new i = 0; i < g_PluginNum; i++)
		{
			ServerCommand("rmf_ability %d %s 0", client, g_RMFPlugins[i]);
		}		
		g_SelectedAbility[client] = false;
		g_NextAbilityName[client] = "";
		g_NowAbilityName[client] = "";

	}	
	return Plugin_Continue;
}

/////////////////////////////////////////////////////////////////////
//
// ƒƒjƒ…[I—¹ƒ^ƒCƒ}[[
//
/////////////////////////////////////////////////////////////////////
public Action:Timer_MenuEnd(Handle:timer, any:client)
{
	g_MenuTimer = INVALID_HANDLE;

}

/////////////////////////////////////////////////////////////////////
//
// ƒƒjƒ…[•\¦ƒRƒ}ƒ“ƒh
//
/////////////////////////////////////////////////////////////////////
public Action:Command_Say(client, args)
{
	if(g_IsRunning)
	{
		// AdminƒIƒ“ƒŠ[H
		if( GetConVarBool( g_ConVarAdminOnly ) == true )
		{
			if( GetUserAdmin( client ) == INVALID_ADMIN_ID )
			{
				PrintToChat( client, "\x04%T", "MESSAGE_ADMIN_ONLY", client );
				return Plugin_Handled;
			}
		}
		
		decl String:originalstring[191];
		GetCmdArgString(originalstring, sizeof(originalstring));
		ReplaceString( originalstring, sizeof(originalstring), "\"", "" );
		//PrintToChat(client, "%d", strlen(originalstring));
		//PrintToChat(client, "%s", originalstring);
		if( ( StrContains(originalstring, "rmf_menu") != -1 && strlen(originalstring) == 8 )
		|| ( StrContains(originalstring, "!r") != -1 && strlen(originalstring) == 2 ) )
		{

			//PrintToChat(client, "%d", GetEntProp(g_RoundTimer, Prop_Send, "m_nState"));
				//GetEntProp(g_RoundTimer, Prop_Send, "m_iRoundState"));
		
			//PrintToChat(client, "%d", g_InRespawnRoom[client]);
		
			
			if( client > 0 && ( GetClientTeam(client) == _:TFTeam_Red || GetClientTeam(client) == _:TFTeam_Blue ) )
			{
				// ƒƒjƒ…[‚ğŠJ‚­
				AbilityMenu(client);
				
			}

		
				
			/*
			if(g_MenuTimer[client] != INVALID_HANDLE)
			{
			}
			else
			{
				if(g_SelectedAbility[client])
				{
					PrintToChat(client, "\x03%T", "ABILITYMENU_CANTCHANGE", client);
				}
				else
				{
					PrintToChat(client, "\x03%T", "ABILITYMENU_TIMEOVER", client);
				}
			}		*/
			return Plugin_Handled;
		}

	}
	return Plugin_Continue;
}

/////////////////////////////////////////////////////////////////////
//
// ƒƒjƒ…[‘I‘ğ
//
/////////////////////////////////////////////////////////////////////
public Action:cGiveLicence(client, args)
{
	new String:arg1[32], String:arg2[32], String:arg3[32];

	if (args != 3)
	{
		ReplyToCommand(client, "[SM] Usage: sm_rmf_give_licence <steamid> <ability name> <time>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	GetCmdArg(3, arg3, sizeof(arg3));
	
	GiveLicence(arg1, arg2, StringToInt(arg3));
	
	return Plugin_Handled;
}

GiveLicence(String:licSID[], String:PluginName[], time)
{
	if (Database == INVALID_HANDLE)
	{
		return false;
	}
	new String:Query[255];
	Format(Query, sizeof(Query), "SELECT * FROM `%slicences` WHERE `steamid` = '%s' AND `ability` = '%s';", sTablePrefix, licSID, PluginName);
	
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, time);
	WritePackString(pack, licSID);
	WritePackString(pack, PluginName);
	SQL_TQuery(Database, TGiveLicence, Query, pack);
}

public TGiveLicence(Handle: owner, Handle:hndl, const String:error[], const any:pack)
{
	if(hndl == INVALID_HANDLE)
	{
		return;
	}
	else
	{
		new String:licSID[255];
		new String:PluginName[255];
		ResetPack(pack);	
		new time = ReadPackCell(pack);
		ReadPackString(pack, licSID, sizeof(licSID));
		ReadPackString(pack, PluginName, sizeof(PluginName));
		CloseHandle(pack);
		
		if(SQL_GetRowCount(hndl) == 0)
		{
			new String:Query[255];
			Format(Query, sizeof(Query), "INSERT INTO `%slicences` (`steamid`, `ability`, `expires`) VALUES ('%s', '%s', '%i');", sTablePrefix, licSID, PluginName, GetTime() + time);
			SQL_TQuery(Database, TNoCallback, Query);
		}
		else
		{
			new String:Query[255];
			Format(Query, sizeof(Query), "UPDATE `%slicences` SET `expires` = `expires` + '%i' WHERE `steamid` = '%s' AND `ability` = '%s';", sTablePrefix, time, licSID, PluginName);
			SQL_TQuery(Database, TNoCallback, Query);
		}
	}
}

public TNoCallback(Handle: owner, Handle:hndl, const String:error[], any:data)
{
	return;
}

public AbilityMenu(client)
{
	if (Database == INVALID_HANDLE)
	{
		return false;
	}
	new String:Query[255];
	new String:licSID[255];
	GetClientAuthString(client, licSID, sizeof(licSID));
	Format(Query, sizeof(Query), "SELECT `ability`, `expires` FROM `%slicences` WHERE `steamid` = '%s';", sTablePrefix, licSID);
	SQL_TQuery(Database, TAbilityMenu, Query, client);
}

bool:IsInDArray(const Handle:arr, String:field[])
{
	for(new i = 1; i < GetArraySize(arr); i++)
	{
		new String:buff[255];
		GetArrayString(arr, i, buff, sizeof(buff));
		if (strcmp(field, buff, false) == 0)
		{
			return true;
		}
	}
	return false;
}

public TAbilityMenu(Handle: owner, Handle:hndl, const String:error[], any:client)
{
	new Handle:plyAbilities = CreateArray(255, 0);
	new String:licSID[255];
	GetClientAuthString(client, licSID, sizeof(licSID));
	while(SQL_FetchRow(hndl))
	{
		new String:buff[255];
		SQL_FetchString(hndl, 0, buff, sizeof(buff));
		if (SQL_FetchInt(hndl, 1) < GetTime())
		{
			new String:Query[255];
			Format(Query, sizeof(Query), "DELETE FROM `%slicences` WHERE `steamid` = '%s' AND `ability` = '%s' LIMIT 1;", sTablePrefix, licSID, buff);
			SQL_FastQuery(Database, Query);
		}
		else
		{
			ResizeArray(plyAbilities, GetArraySize(plyAbilities) + 1);
			PushArrayString(plyAbilities, buff);
		}
	}

	new Handle:menu = CreateMenu(AbilityMenuHandler);
	
	// ƒƒjƒ…[ƒ^ƒCƒgƒ‹
	new String:title[64];
	Format(title, sizeof(title), "%T", "ABILITYMENU_TITLE", client);
	SetMenuTitle(menu, title);
	
	new allowCount = 0;
	for(new i = 0; i < g_PluginNum; i++)
	{
		// •¶š‚ª“ü‚Á‚Ä‚¢‚é
		if(!StrEqual(g_RMFPlugins[i], ""))
		{
			
			// ‘å•¶š¬•¶š—pˆÓ
			new String:lowerName[64];
			new String:upperName[64];
			new String:buffer[128];
			new Handle:cvar;
			
			StringToLower(lowerName, g_RMFPlugins[i]);	// ‘å•¶š‚ğ¬•¶š‚É
			StringToUpper(upperName, g_RMFPlugins[i]);	// ¬•¶š‚ğ‘å•¶š‚É
			
			// ON/OFF‚ÌCVARæ“¾
			Format(buffer, sizeof(buffer), "sm_rmf_allow_%s", lowerName);
			cvar = FindConVar(buffer);
			// ƒvƒ‰ƒOƒCƒ“‚ªON‚©ƒIƒt‚©ƒ`ƒFƒbƒN
			if(cvar != INVALID_HANDLE && GetConVarInt(cvar))
			{
				// ƒNƒ‰ƒXCVARæ“¾
				Format(buffer, sizeof(buffer), "sm_rmf_%s_class", lowerName);
				cvar = FindConVar(buffer);
				//PrintToServer("%d, %d", GetConVarInt(cvar), TF2_GetPlayerClass( client ));
				// ƒNƒ‰ƒX‚ª“¯‚¶‚©ƒ`ƒFƒbƒN
				if(cvar != INVALID_HANDLE && TFClassType:GetConVarInt(cvar) == TF2_GetPlayerClass( client ))
				{
					// ƒgƒ‰ƒ“ƒXƒŒ[ƒVƒ‡ƒ“æ“¾
				
					if(IsInDArray(plyAbilities, lowerName))
					{
					
						new String:pluginName[128];
						Format(pluginName, sizeof(pluginName), "ABILITYNAME_%s", upperName);
						Format(pluginName, sizeof(pluginName), "%T", pluginName, client);
						
						// ƒƒjƒ…[‚É’Ç‰Á
						AddMenuItem(menu, g_RMFPlugins[i], pluginName);
						
						// ƒJƒEƒ“ƒgƒAƒbƒv
						allowCount += 1;
					}
				}
			}
		}
		
	}
	// g—p‚µ‚È‚¢ƒƒjƒ…[
	new String:notuse[128];
	if(g_SelectedAbility[client])
	{
		Format(notuse, sizeof(notuse), "%T", "ABILITYMENU_CANCEL", client);
		AddMenuItem(menu, "NOTUSE", notuse);
	}
	//else
	//{
	//	Format(notuse, sizeof(notuse), "%T", "ABILITYMENU_NOTUSE", client);
	//}
	SetMenuExitButton(menu, true);
	
	CloseHandle(plyAbilities);
	
	if(allowCount > 0)
	{
		DisplayMenu(menu, client, 10);
	}
	else
	{
		PrintToChat(client, "Nie mo¿esz niczego u¿yæ.");
	}
}

/////////////////////////////////////////////////////////////////////
//
// ƒƒjƒ…[‘I‘ğ
//
/////////////////////////////////////////////////////////////////////
public AbilityMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	
	// ƒAƒCƒeƒ€‘I‘ğ‚µ‚½
	if (action == MenuAction_Select)
	{
		new String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));

		// ƒAƒrƒŠƒeƒBg‚¤
		if(!StrEqual(info, "NOTUSE"))
		{
			// ‚Ü‚¾‘I‚ñ‚Å‚È‚¢
			if(!g_SelectedAbility[param1] && g_InRespawnRoom[param1]/* && g_MenuTimer[param1] != INVALID_HANDLE*/)
			{
				// ‘å•¶šæ“¾
				new String:upperName[32];
				StringToUpper(upperName, info);	// ¬•¶š‚ğ‘å•¶š‚É
				new String:lowerName[64];
				StringToLower(lowerName, info);	// ‘å•¶š‚ğ¬•¶š‚É
					
				// æ‚è‡‚¦‚¸ƒAƒrƒŠƒeƒB‘S•”g—p•s‰Â‚ÉB
				for(new i = 0; i < g_PluginNum; i++)
				{
					ServerCommand("rmf_ability %d %s 0", param1, g_RMFPlugins[i]);
				}		

				// ƒNƒ‰ƒXCVARæ“¾
				new String:buffer[128];
				Format(buffer, sizeof(buffer), "sm_rmf_%s_class", lowerName);
				new Handle:cvar = FindConVar(buffer);
				// ƒNƒ‰ƒX‚ª“¯‚¶‚©ƒ`ƒFƒbƒN
				if(TFClassType:GetConVarInt(cvar) == TF2_GetPlayerClass( param1 ))
				
				{				// ‘I‘ğ‚µ‚½ƒAƒrƒŠƒeƒB‚ğ—LŒø
					ServerCommand("rmf_ability %d %s 1", param1, info);

					// ƒvƒ‰ƒOƒCƒ“–¼æ“¾
					new String:pluginName[64];
					Format(pluginName, sizeof(pluginName), "ABILITYNAME_%s", upperName);
					Format(pluginName, sizeof(pluginName), "%T", pluginName, param1);
					PrintToChat(param1, "\x04%T", "ABILITYMENU_EQUIPPED", param1, pluginName);
					
					g_SelectedAbility[param1] = true;
					g_NowAbilityName[param1] = info;
				}
			}
			// ‘I‚ñ‚Å‚é
			else
			{
				g_NextAbilityName[param1] = info;
				
				// ‘O‚Æˆá‚¤‚â‚Â‚È‚ç•Û‘¶
				if(!StrEqual(g_NextAbilityName[param1], g_NowAbilityName[param1]))
				{
					// ƒƒbƒZ[ƒW
					//PrintToChat(param1, "henkou");
					// ƒAƒŠ[ƒi‚¨‚æ‚ÑƒTƒhƒ“ƒfƒX‚Ìê‡‚Í§ŒÀŠÔ“à
					if(!g_AbilityLock || g_MenuTimer != INVALID_HANDLE)
					{
						// ƒŠƒXƒ|ƒ“ƒ‹[ƒ€“à‚È‚ç‚·‚®Ø‚è‘Ö‚¦
						if(g_InRespawnRoom[param1])
						{
							TF2_RespawnPlayer(param1);
						}
						else
						{
							PrintToChat(param1, "\x04%T", "ABILITYMENU_CANT_CHANGE", param1);
						}
					}
					else
					{
						// ¡‚Í•ÏX‚Å‚«‚È‚¢ƒƒbƒZ[ƒW
						PrintToChat(param1, "\x04%T", "ABILITYMENU_CANT_CHANGE_NOW", param1);
					}
					
				}

			}
		}
		else
		{
			g_NextAbilityName[param1] = "Unequipped";
			// ƒAƒŠ[ƒi‚¨‚æ‚ÑƒTƒhƒ“ƒfƒX‚Ìê‡‚Í§ŒÀŠÔ“à
			if(!g_AbilityLock || g_MenuTimer != INVALID_HANDLE)
			{
				// ƒŠƒXƒ|ƒ“ƒ‹[ƒ€“à‚È‚ç‚·‚®Ø‚è‘Ö‚¦
				if(g_InRespawnRoom[param1])
				{
					TF2_RespawnPlayer(param1);
				}
				else
				{
					PrintToChat(param1, "\x04%T", "ABILITYMENU_CANT_CHANGE", param1);
				}
			}
			else
			{
				// ¡‚Í•ÏX‚Å‚«‚È‚¢ƒƒbƒZ[ƒW
				PrintToChat(param1, "\x04%T", "ABILITYMENU_CANT_CHANGE_NOW", param1);
			}			
	
			// ƒAƒrƒŠƒeƒB‘S•”g—p•s‰Â‚ÉB
			/*
			for(new i = 0; i < g_PluginNum; i++)
			{
				ServerCommand("rmf_ability %d %s 0", param1, g_RMFPlugins[i]);
			}	
			
			if(g_SelectedAbility[param1])
			{
				PrintToChat(param1, "%T", "ABILITYMENU_CANCELED", param1);
			}
			g_SelectedAbility[param1] = false;
			g_NextAbilityName[param1] = "";
			g_NowAbilityName[param1] = "";*/
		}
	}
	// ƒLƒƒƒ“ƒZƒ‹
	else if (action == MenuAction_Cancel)
	{
		// ƒAƒrƒŠƒeƒBg—p•s‰Â‚É
	}
	// ƒƒjƒ…[•Â‚¶‚½
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
			
		

}

/////////////////////////////////////////////////////////////////////
//
// ƒŠƒXƒ|ƒ“ƒ‹[ƒ€o‚é“ü‚é
//
/////////////////////////////////////////////////////////////////////
public EntityOutput_StartTouch( const String:output[], caller, activator, Float:delay )
{
//	PrintToChat(activator, "Touch");
	if(TF2_EdictNameEqual(activator, "player"))
	{
		g_InRespawnRoom[activator] = true;
	}
}
public EntityOutput_EndTouch( const String:output[], caller, activator, Float:delay )
{
//	PrintToChat(activator, "NoTouch");
	if(TF2_EdictNameEqual(activator, "player"))
	{
		g_InRespawnRoom[activator] = false;
	}

}

