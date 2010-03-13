/*
 * Version 1.0
 * - Initial release 
 *
 * Zuko / #hlds.pl @ Qnet / zuko.isports.pl /
 *
 */
 
#include <sourcemod>
#include <colors>

#define PLUGIN_VERSION "1.0"

new bool:anyplayerconnected = false

public Plugin:myinfo = 
{
	name = "Map Time Vote",
	author = "Zuko",
	description = "Jak dlugo ma trwac mapa",
	version = PLUGIN_VERSION,
	url = "http://zuko.isports.pl"
}

public OnPluginStart()
{
	CreateConVar("critbonusvote_version", PLUGIN_VERSION, "Map Time Vote Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	
	LoadTranslations("maptimevote.phrases");
}

public OnMapStart()
{
	anyplayerconnected = false
}

public OnClientPostAdminCheck()
{
	if (!anyplayerconnected)
	{
		CreateTimer(60.0, StartVote)
		anyplayerconnected = true
	}
}

public Action:StartVote(Handle:timer)
{
	if (IsVoteInProgress())
	{
		return;
	}
 
	new Handle:menu = CreateMenu(Handle_VoteMenu)
	
	decl String:title[100], String:menuitem1[100], String:menuitem2[100], String:menuitem3[100], String:menuitem4[100];
	Format(title, sizeof(title),"%t", "VoteMenuTitle", LANG_SERVER)
	SetMenuTitle(menu, title)
	AddMenuItem(menu, "nothing", "-----------------------------------", ITEMDRAW_DISABLED)
	Format(menuitem1, sizeof(menuitem1),"%t", "MenuItem01", LANG_SERVER)
	AddMenuItem(menu, "15", menuitem1)
	Format(menuitem2, sizeof(menuitem2),"%t", "MenuItem02", LANG_SERVER)
	AddMenuItem(menu, "25", menuitem2)
	Format(menuitem3, sizeof(menuitem3),"%t", "MenuItem03", LANG_SERVER)
	AddMenuItem(menu, "35", menuitem3)
	Format(menuitem4, sizeof(menuitem3),"%t", "MenuItem04", LANG_SERVER)
	AddMenuItem(menu, "45", menuitem4)
	SetMenuExitButton(menu, false)
	VoteMenuToAll(menu, 30);
}

public Handle_VoteMenu(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	} 
	else if (action == MenuAction_VoteEnd) 
	{
		switch(param1)
		{
			case 0:
			{
				ServerCommand("mp_timelimit 15");
				CPrintToChatAll("{lightgreen}[SM] %t", "VoteEnd01", LANG_SERVER);
			}
			case 1:
			{
				ServerCommand("mp_timelimit 25");
				CPrintToChatAll("{lightgreen}[SM] %t", "VoteEnd02", LANG_SERVER);
			}
			case 2:
			{
				ServerCommand("mp_timelimit 35");
				CPrintToChatAll("{lightgreen}[SM] %t", "VoteEnd03", LANG_SERVER);
			}
			case 4:
			{
				ServerCommand("mp_timelimit 45");
				CPrintToChatAll("{lightgreen}[SM] %t", "VoteEnd04", LANG_SERVER);
			}
		}
	}
}