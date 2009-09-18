/*
 * Rage Quitter  
 *
 * Someone kill you several times? You're upset? Use RAGE QUITTER^^
 *
 * Write "rage quit", "ragequit" on chat or "rage", "ragequit" in console to RAGE QUIT from server.
 * Normal player will be banned or kicked with "Rage Quitter" sound, but you are Root Admin^^ 
 * you also slay all players on server ;-)
 *
 * Version 1.0
 * - Initial release 
 * Version 1.1
 * - Total REWRITE ;-)
 *
 * Idea by _Kaszpir_
 *
 * Zuko / #hlds.pl @ Qnet / zuko.isports.pl /
 *
 */

#include <sourcemod>
#include <sdktools>
#include <sdktools_sound>

new Handle:g_Cvar_PluginEnable = INVALID_HANDLE;
new Handle:g_Cvar_BanTimeForROOT = INVALID_HANDLE;
new Handle:g_Cvar_BanTimeForUsers = INVALID_HANDLE;
new Handle:g_Cvar_WarningTime = INVALID_HANDLE;
new Handle:g_Cvar_BanOrKick = INVALID_HANDLE;
new Handle:g_Cvar_Punish = INVALID_HANDLE;
new bool:ragequitforroot = false;
new bool:ragequitforuser = false;
new g_PunishmentStart;
new String:logFile[256];

#define PLUGIN_VERSION	"1.1"
#define RAGE_QUITTER	"sound/misc/ragequit.mp3"
#define RAGE_QUITTER_PRECACHE	"misc/ragequit.mp3"

public Plugin:myinfo = 
{
	name = "Rage Quitter",
	author = "Zuko",
	description = "You're upset? Use RAGE QUITTER.",
	version = PLUGIN_VERSION,
	url = "http://zuko.isports.pl/"
}

public OnPluginStart()
{
	CreateConVar("ragequitter_version", PLUGIN_VERSION, "Rage Quitter Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY)
	g_Cvar_PluginEnable = CreateConVar("sm_ragequitter_enable", "1", "Enable/Disable Plugin", _, true, 0.0, true, 1.0);
	g_Cvar_BanOrKick = CreateConVar("sm_banorkick", "1", "Ban Or Kick? :: 0 - BAN / 1 - KICK", _, true, 0.0, false, 1.0);
	g_Cvar_BanTimeForROOT = CreateConVar("sm_bantimeforroot", "5", "Ban Time For Admin ROOT", _, true, 1.0, false, _);
	g_Cvar_BanTimeForUsers = CreateConVar("sm_bantimeforusers", "10", "Ban Time For Players", _, true, 1.0, false, _);
	g_Cvar_Punish = CreateConVar("sm_punish", "1", "Punish players?", _, true, 0.0, false, 1.0);
	g_Cvar_WarningTime = CreateConVar("sm_warningtimeforpunish", "10", "Warning Time Before PUNISH", _, true, 1.0, false, _);

	RegConsoleCmd("rage", Cmd_RageQuit, "Time to RAGE QUIT!");
	RegConsoleCmd("ragequit", Cmd_RageQuit, "Time to RAGE QUIT!");
	RegConsoleCmd("rquit", Cmd_RageQuit, "Time to RAGE QUIT!");
	RegConsoleCmd("say", Command_Say);
	RegConsoleCmd("say_team", Command_Say);
	
	BuildPath(Path_SM, logFile, sizeof(logFile), "logs/ragequitter.log");
	
	AutoExecConfig(true, "plugin.ragequitter");
	LoadTranslations("ragequitter.phrases");
}

public OnMapStart()
{
	AddFileToDownloadsTable(RAGE_QUITTER);
	PrecacheSound(RAGE_QUITTER_PRECACHE, true);
}

public Action:Command_Say(client, args) 
{
	decl String:text[192];
	if (GetCmdArgString(text, sizeof(text)) < 1)
	{
		return Plugin_Continue;
	}
	
	new startidx;
	if (text[strlen(text)-1] == '"') 
	{
		text[strlen(text)-1] = '\0';
		startidx = 1;
	}
	
	if (strcmp(text[startidx], "rage quit", false) == 0 || strcmp(text[startidx], "ragequit", false) == 0) 
	{
		Cmd_RageQuit(client, args);
	}
	return Plugin_Continue;	
}

public Action:Cmd_RageQuit(client, args)
{
	if (GetConVarInt(g_Cvar_PluginEnable) == 0) {
		ReplyToCommand(client, "%t", "PluginDisabled", LANG_SERVER);
		return Plugin_Stop;
	}
	if (IsClientConnected(client) && IsClientInGame(client)) {
		if (GetUserFlagBits(client) == ADMFLAG_ROOT) {
			ragequitforroot = true;
			ragequitforuser = false;
		}
		else {
			ragequitforroot = false;
			ragequitforuser = true;
		}
	
	}
}

public Action:WarningHintMsg(Handle:timer, any:client)
{
	if (IsClientConnected(client) && IsClientInGame(client))
	{
		decl String:hintboxText[512];
		//Format(hintboxText, sizeof(hintboxText), "You Will Be PUNISH in: %i s", WarningForPunishment());
		Format(hintboxText, sizeof(hintboxText), "%t" ,"PunishCountdown", LANG_SERVER, WarningForPunishment());
		PrintHintTextToAll(hintboxText);
		
		if (WarningForPunishment() == 0)
		{
			KillTimer(Handle:timer);
			PunishPlayer(client);
		}
	}
}

public PunishPlayer(any:client)
{
	if (IsClientConnected(client) && IsClientInGame(client))
	{
		if (!IsPlayerAlive(client))
		{
			ServerCommand("sm_slay @all")
			PrintHintText(client, "%t", "DIEDIEDIE", LANG_SERVER);
		}
		PrintHintText(client, "%t", "AlreadyDead", LANG_SERVER);
	}
}

WarningForPunishment()
{
	new WarningTime = g_PunishmentStart + GetConVarInt(g_Cvar_WarningTime) - GetTime();
	if(WarningTime < 0)
	{
		return 0;
	}
	else
	{
		return WarningTime;
	}
}