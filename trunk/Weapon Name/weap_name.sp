#include <sourcemod>

public Plugin:myinfo = 
{
	name = "bron",
	author = "Zuko",
	description = "daje nazwy broni",
	version = "1",
	url = "http://zuko.isports.pl"
}

public OnPluginStart()
{
	RegAdminCmd("sm_a", Command_A, ADMFLAG_KICK, "peda");
}

public Action:Command_A(client, args)
{
	decl String:nazwa_broni[100];
	
	GetClientWeapon(client, nazwa_broni, 100)
	PrintToChatAll("Nazwa broni: %s", nazwa_broni)
}