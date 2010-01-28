/*
 * Plugin turns "normal" server into idle server. ;-)
 *
 * ConVars:
 * idle_version 			- Plugin Version
 *
 * Changelog:
 * Version 1.0 (18.01.2010)
 * - Initial Release
 *
 * Zuko / #hlds.pl @ Qnet / zuko.isports.pl /
 */
 
#include <sourcemod>
//#include <colors>

#define PLUGIN_VERSION "1.0"

new Handle:g_Cvar_StartIdlingTime = INVALID_HANDLE;
new Handle:g_Cvar_EndIdlingTime = INVALID_HANDLE;
new Handle:g_Cvar_IdleMap = INVALID_HANDLE;
new Handle:g_Cvar_NormalMap = INVALID_HANDLE;

new Handle:g_Cvar_IdleHostName = INVALID_HANDLE;
new Handle:g_Cvar_NormalHostName = INVALID_HANDLE;

public Plugin:myinfo = 
{
	name = "[TF2] Idle",
	author = "Zuko",
	description = "Turns server into idle server.",
	version = PLUGIN_VERSION,
	url = "http://zuko.isports.pl"
}

public OnPluginStart()
{
	CreateConVar("idle_version", PLUGIN_VERSION, "Plugin Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);

	g_Cvar_StartIdlingTime = CreateConVar("sm_idle_startidlingtime", "0200", "Start Idling Time");
	g_Cvar_EndIdlingTime = CreateConVar("sm_idle_endidlingtime", "0900", "End Idling Time");
	g_Cvar_IdleMap = CreateConVar("sm_idle_idlemap", "idle_dupa", "Idle Map.");
	g_Cvar_NormalMap = CreateConVar("sm_idle_normalmap", "pl_goldrush", "Normal Map.");

	g_Cvar_IdleHostName = CreateConVar("sm_idle_idlehostname", "Night Idle Server", "Idle HostName.");
	g_Cvar_NormalHostName = CreateConVar("sm_idle_normalhostname", "Welcome!", "Normal HostName.");

	//LoadTranslations("idle.phrases");
	CreateTimer(60.0, CheckTime, 0, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	
	AutoExecConfig(true, "plugin.idle");
}

public Action:CheckTime(Handle:timer)
{
	decl String:sTime[16];
	new CurrentTime = GetTime();
	
	FormatTime(sTime, sizeof(sTime), "%H%M", CurrentTime);
	new ServerTime = StringToInt(sTime);	

	if ((ServerTime > GetConVarInt(g_Cvar_StartIdlingTime)) && (ServerTime < GetConVarInt(g_Cvar_EndIdlingTime)))
	{
		if (!IdleMap())
		{
			if (GetRealClientCount() == 0)
			{
				new String:map[128];
				GetConVarString(g_Cvar_IdleMap, map, sizeof(map));
				ServerCommand("changelevel %s", map);
			}
		}
		else
		{
			SetIdleCfg()
		}
	}
	else
	{
		if (!IdleMap())
		{
			new String:map[128];
			GetConVarString(g_Cvar_NormalMap, map, sizeof(map));
			ServerCommand("changelevel %s", map);
		}
		else
		{
			SetNormalCfg()
		}
	}
}

SetIdleCfg()
{
	new String:hname[128];
	GetConVarString(g_Cvar_IdleHostName, hname, sizeof(hname));
	ServerCommand("hostname %s", hname);
	ServerCommand("mp_timelimit 0");
}

SetNormalCfg()
{
	new String:hname[128];
	GetConVarString(g_Cvar_NormalHostName, hname, sizeof(hname));
	ServerCommand("hostname %s", hname);
	ServerCommand("mp_timelimit 30");
}

stock IdleMap()
{
	decl String:MapName[128];
	GetCurrentMap(MapName, sizeof(MapName));
	
	new String:map[128];
	GetConVarString(g_Cvar_IdleMap, map, sizeof(map));	

	if (StrEqual(MapName, map, false))
	{
		return true;
	}
	else
	{
		return false;
	}
}

stock GetRealClientCount(bool:inGameOnly = true)
{
	new clients = 0;
	for(new i = 1; i <= GetMaxClients(); i++)
	{
		if (((inGameOnly) ? IsClientInGame(i): IsClientConnected(i)) && !IsFakeClient(i))
			{
				clients++;
			}
	}
	return clients;
}