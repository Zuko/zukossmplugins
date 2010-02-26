/*
 * 
 *
 * Zuko / #hlds.pl @ Qnet #sourcemod @ GameSurge / zuko.isports.pl / hlds.pl /
 *
 */
 
#include <sourcemod>

new Handle:g_Cvar_Delay = INVALID_HANDLE;

new Float:ratio = 0;
new Float:iloscgraczyktorzywybralitak = 0;
new bool:jeszczesienierespil[MAXPLAYERS+1] = true;

#define VERSION "1.0"

public Plugin:myinfo = 
{
	name = "[TF2] Extended Crit Vote",
	author = "Zuko",
	description = "Makes extended crit vote.",
	version = VERSION,
	url = "http://zuko.isports.pl"
}

public OnPluginStart()
{
	/* ConVars */
	CreateConVar("extendedcritvote_version", VERSION, "Plugin Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);

	g_Cvar_Delay = CreateConVar("sm_ecv_delay", "5", "Delay for Vote", _, true, 0.0);
	
	/* Hook Events */
	HookEvent("player_spawn", EventPlayerSpawn);

	/* Load translations */
	LoadTranslations("common.phrases");
	LoadTranslations("extendedcritvote.phrases");
}

/* Events */
public Action:EventPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (jeszczesienierespil[client] == true)
	{
		new Delay = (GetConVarInt(g_Cvar_Delay))
		CreateTimer(Delay, StartVote, client, TIMER_FLAG_NO_MAPCHANGE)
		jeszczesienierespil[client] == false
	}
	return Plugin_Continue;
}

public Action:StartVote(Handle:timer)
{
	CritVote()
}

CritVote()
{
	if (IsVoteInProgress())
	{
		return;
	}
 
	new Handle:menu = CreateMenu(Handle_VoteMenu)
	
	decl String:title[20], String:menuitem1[20], String:menuitem2[20];
	
	Format(title, sizeof(title),"%t", "VoteMenuTitle", LANG_SERVER)
	SetMenuTitle(menu, title)
	Format(menuitem1, sizeof(menuitem1),"%t", "MenuItem01", LANG_SERVER)
	AddMenuItem(menu, "no", menuitem1)
	Format(menuitem2, sizeof(menuitem2),"%t", "MenuItem02", LANG_SERVER)
	AddMenuItem(menu, "yes", menuitem2)
	SetMenuExitButton(menu, false)
	VoteMenuToAll(menu, 20);
}

public Handle_VoteMenu(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		//say do niego ze zaglosowal na nie
		//say do wszystkich ze zaglosowal na nie
		CPrintToChat("{lightgreen}[SM] %t", "VoteEnd_No", LANG_SERVER);
		CloseHandle(menu);
	} 
	else if (action == MenuAction_VoteEnd) 
	{
		switch(param1)
		{
			case 0:
			{
				//zaglosowal na nie
				CPrintToChat("{lightgreen}[SM] %t", "VoteEnd_No", LANG_SERVER);
				//nic nie liczymy, ratio liczymy tylko dla glosow na tak
			}
			case 1:
			{
				//glosowal na tak
				CPrintToChat("{lightgreen}[SM] %t", "VoteEnd_Yes", LANG_SERVER);
				iloscgraczyktorzywybralitak = iloscgraczyktorzywybralitak+1;
				//odwolanie do funkcji liczacej srednia z glosow
			}
		}
	}
}

RatioCalculation()
{
	ratio = (iloscgraczyktorzywybralitak*100)/[MAXPLAYERS] //to jest zle, ale tak ma liczyc ;D musze jakos pobrac maxplayers
	return ratio
}