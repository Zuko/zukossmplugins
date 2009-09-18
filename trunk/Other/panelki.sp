/*
 * Panelki 
 * Specjalnie dla Mariano
 * Plugin napisany na szybko, bo nie będzie nigdzie publikowany
 * 
 * Zuko / hlds.pl @ Qnet / zuko.isports.pl
 */

#include <sourcemod>

#define PLUGIN_VERSION	"1.0"

new Handle:g_Cvar_PluginEnable = INVALID_HANDLE;

public Plugin:myinfo = 
{
	name = "Panelki",
	author = "Zuko",
	description = "Plugin wyświetla panele z info.",
	version = PLUGIN_VERSION,
	url = "http://zuko.isports.pl"
}

public OnPluginStart()
{
	CreateConVar("panelki_version", PLUGIN_VERSION, "Wersja Panelków", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	g_Cvar_PluginEnable = CreateConVar("sm_panelki_enable", "1", "Włącz/Wyłącz Panelki", _, true, 0.0, true, 1.0);
	
	RegConsoleCmd("admini", Cmd_PanelzAdminami, "Wyświetla panel z listą adminów");
	RegConsoleCmd("mapy", Cmd_PanelzMapami, "Wyświetla panel z listą map");
	RegConsoleCmd("cos", Cmd_PanelzCzymstamZapomnialem, "Wyświetla panel z listą, ale nie wiem czego?");
}

public Action:Cmd_PanelzAdminami(client, args) 
{
	if (GetConVarInt(g_Cvar_PluginEnable) == 0)
	{
		ReplyToCommand(client, "Czego chcesz? Plugin jest wyłączony");
		return Plugin_Stop;
	}
	
	new Handle:adminpanel = CreatePanel(INVALID_HANDLE);

	SetPanelTitle(adminpanel, "Lista Adminów");
	DrawPanelText(adminpanel, " ");
	DrawPanelText(adminpanel, "Zuko");
	DrawPanelText(adminpanel, "Mariano");
	DrawPanelText(adminpanel, "i ktoś tam jeszcze");
	DrawPanelText(adminpanel, "ale to nie ważne");
	DrawPanelText(adminpanel, " ");
	DrawPanelText(adminpanel, "0. Zamknij");
	SendPanelToClient(adminpanel, client, PusteMenu, 60);
	CloseHandle(adminpanel);
	return Plugin_Handled;
}

public Action:Cmd_PanelzMapami(client, args) 
{
	if (GetConVarInt(g_Cvar_PluginEnable) == 0)
	{
		ReplyToCommand(client, "Czego chcesz? Plugin jest wyłączony");
		return Plugin_Stop;
	}
	new Handle:mappanel = CreatePanel(INVALID_HANDLE);

	SetPanelTitle(mappanel, "Lista Map");
	DrawPanelText(mappanel, " ");
	DrawPanelText(mappanel, "cp_spambowl");
	DrawPanelText(mappanel, "pl_goldshit");
	DrawPanelText(mappanel, "i inne zjebane mapy");
	DrawPanelText(mappanel, "a może jeszcze");
	DrawPanelText(mappanel, "cp_nedzary");
	DrawPanelText(mappanel, " ");
	DrawPanelText(mappanel, "0. Zamknij");
	SendPanelToClient(mappanel, client, PusteMenu, 60);
	CloseHandle(mappanel);
	return Plugin_Handled;
}

public Action:Cmd_PanelzCzymstamZapomnialem(client, args) 
{
	if (GetConVarInt(g_Cvar_PluginEnable) == 0)
	{
		ReplyToCommand(client, "Czego chcesz? Plugin jest wyłączony");
		return Plugin_Stop;
	}
	new Handle:cospanel = CreatePanel(INVALID_HANDLE);

	SetPanelTitle(cospanel, "Lista Bzdur");
	DrawPanelText(cospanel, " ");
	DrawPanelText(cospanel, "ajajajajajajajajaj");
	DrawPanelText(cospanel, "hujhujhujhujhujhuj");
	DrawPanelText(cospanel, "afsfsfs");
	DrawPanelText(cospanel, "sdfsdnd");
	DrawPanelText(cospanel, "co miało być w tym panelu?");
	DrawPanelText(cospanel, " ");
	DrawPanelText(cospanel, "0. Zamknij");
	SendPanelToClient(cospanel, client, PusteMenu, 60);
	CloseHandle(cospanel);
	return Plugin_Handled;
}

public PusteMenu(Handle:menu, MenuAction:action, param1, param2)
{
}