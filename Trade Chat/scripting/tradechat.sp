#include <sourcemod>
#include <clientprefs>
#include <colors>

public Plugin:myinfo = 
{
	name = "Trade Chat",
	author = "Luki",
	description = "",
	version = "1.0",
	url = "http://luki.net.pl"
};

new Handle:hCookie = INVALID_HANDLE;
new HideTradeChat[MAXPLAYERS + 1];
new String:logfile[255];

public OnPluginStart()
{
	RegConsoleCmd("sm_trade", Command_TradeChat);
	RegConsoleCmd("sm_hidechat", Command_HideChat);
	
	BuildPath(Path_SM, logfile, sizeof(logfile), "logs/tradechat.log");
	
	CreateTimer(120.0, AdTimer, _, TIMER_REPEAT);
}

public OnAllPluginsLoaded()
{
	new Handle:Plugin_ClientPrefs = FindPluginByFile("clientprefs.smx");
	new PluginStatus:Plugin_ClientPrefs_Status = GetPluginStatus(Plugin_ClientPrefs);
	if ((Plugin_ClientPrefs == INVALID_HANDLE) || (Plugin_ClientPrefs_Status != Plugin_Running))
		LogError("This plugin require clientprefs plugin to allow users to disable trade chat.");
	else
		hCookie = RegClientCookie("tradechat", "Hide trade chat", CookieAccess_Protected);
}

public OnClientPostAdminCheck(client)
{
	if (hCookie != INVALID_HANDLE)
	{
		new String:cookie[4];
		if (AreClientCookiesCached(client))
		{
			GetClientCookie(client, hCookie, cookie, sizeof(cookie));
			if (StrEqual(cookie, "on"))
			{
				HideTradeChat[client] = 1;
				return;
			}
			if (StrEqual(cookie, "off"))
			{
				HideTradeChat[client] = 0;
				return;
			}
		}
		SetClientCookie(client, hCookie, "off");
		HideTradeChat[client] = 0;
	}
	else
	{
		HideTradeChat[client] = 0;
	}
}

public Action:Command_TradeChat(client, args)
{
	new String:text[512], String:name[MAX_NAME_LENGTH], String:steamID[32];
	GetCmdArgString(text, sizeof(text));
	GetClientName(client, name, sizeof(name));
	GetClientAuthString(client, steamID, sizeof(steamID));
	
	if (HideTradeChat[client])
	{
		CPrintToChat(client, "{green}[Trade Chat] {lightgreen}Nie możesz używać {green}/trade {lightgreen}gdy wyłączyłeś widok wiadomości na temat wymiany przedmiotów.");
		return Plugin_Handled;
	}
	
	for (new i = 1; i <= GetMaxClients(); i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
			if (!HideTradeChat[i])
				CPrintToChat(i, "{green}[Trade Chat] {lightgreen}%s: {default}%s", name, text);
	}
	
	LogToFile(logfile, "\"%s<%d><%s><>\" say \"%s\"", name, GetClientUserId(client), steamID, text);
	
	return Plugin_Handled;
}

public Action:Command_HideChat(client, args)
{
	if (hCookie != INVALID_HANDLE)
	{
		new String:name[MAX_NAME_LENGTH], String:steamID[32];
		GetClientName(client, name, sizeof(name));
		GetClientAuthString(client, steamID, sizeof(steamID));
		if (!HideTradeChat[client])
		{
			SetClientCookie(client, hCookie, "on");
			HideTradeChat[client] = 1;
			CPrintToChat(client, "{green}[Trade Chat] {lightgreen}Od teraz {green}nie będziesz {lightgreen}widział wiadomości dotyczących wymiany przedmiotów.");
			LogToFile(logfile, "\"%s<%d><%s><>\" wyłączył widok wiadomości na temat wymiany przedmiotów.", name, GetClientUserId(client), steamID);
		}
		else
		{
			SetClientCookie(client, hCookie, "off");
			HideTradeChat[client] = 0;
			CPrintToChat(client, "{green}[Trade Chat] {lightgreen}Od teraz {green}będziesz {lightgreen}widział wiadomości dotyczących wymiany przedmiotów.");
			LogToFile(logfile, "\"%s<%d><%s><>\" włączył widok wiadomości na temat wymiany przedmiotów.", name, GetClientUserId(client), steamID);
		}
	}
	
	return Plugin_Handled;
}

public Action:AdTimer(Handle:timer)
{
	CPrintToChatAll("{green}[Trade Chat] {default}Pamiętaj, by wszelkie wiadomości na temat wymiany przedmiotów poprzedzać {lightgreen}/trade{default}!");
	CPrintToChatAll("{green}[Trade Chat] {default}Jeśli nie chcesz widzieć wiadomości na temat wymiany, wpisz {lightgreen}/hidechat{default}!");
	return Plugin_Continue;
}