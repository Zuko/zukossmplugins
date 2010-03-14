/*
 * Version 1.0
 * - Initial release 
 *
 * Zuko / #hlds.pl @ Qnet / zuko.isports.pl /
 *
 */
 
#include <sourcemod>
#include <sdktools>
#include <colors>

#define ITEM_MAX_LENGTH		128
#define CLIENT_MAX_LENGTH	32
#define PLUGIN_VERSION "1.1"

new g_PlayerVotes[MAXPLAYERS+1];

new Handle:g_Cvar_PrintVotes = INVALID_HANDLE;
new Handle:g_Cvar_ShowVotes = INVALID_HANDLE;
new Handle:g_AllowedVoters = INVALID_HANDLE;

new Handle:g_timer_ShowVotes = INVALID_HANDLE;

new g_VoteTimeStart2;
 
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
	LoadTranslations("common.phrases");
	LoadTranslations("basetriggers.phrases");

	g_Cvar_PrintVotes = CreateConVar("sm_maptimevote_printvotes", "0", "Should the option that a player vote on get printed (1 - yes print player votes, 0 - don't print).", _, true, 0.0, true, 1.0);
	g_Cvar_ShowVotes = CreateConVar("sm_maptimevote_showvotes", "3", "How many vote options the hint box should show. 0 will disable it", _, true, 0.0, true, 3.0);

	g_AllowedVoters = CreateArray(1);
}

public OnMapStart()
{
	anyplayerconnected = false
}

public OnMapEnd()
{
	g_timer_ShowVotes = INVALID_HANDLE; // Being closed on mapchange: TIMER_FLAG_NO_MAPCHANGE
}

public OnClientDisconnect(client)
{
	// reset the clients vote
	g_PlayerVotes[client] = -1;

	// if client is allowed to vote then remove him (to fix max number of voters)
	new index = FindValueInArray(g_AllowedVoters, client);
	if (index > -1)
	{
		RemoveFromArray(g_AllowedVoters, index);
	}

	// if we display vote then update it
	if (GetConVarBool(g_Cvar_ShowVotes) && g_timer_ShowVotes != INVALID_HANDLE)
	{
		TriggerTimer(g_timer_ShowVotes);
	}
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
 
	new Handle:menu = CreateMenu(Handle_VoteMenu)//, MenuAction:MENU_ACTIONS_ALL);
	SetVoteResultCallback(menu, Handler_MapVoteFinished);
	
	decl String:title[100], String:menuitem1[100], String:menuitem2[100], String:menuitem3[100], String:menuitem4[100];
	Format(title, sizeof(title),"%t", "VoteMenuTitle", LANG_SERVER)
	SetMenuTitle(menu, title);
	AddMenuItem(menu, "nothing", "Nie wciskaj bezmyślnie jedynki ;-)", ITEMDRAW_DISABLED)
	AddMenuItem(menu, "nothing", " ", ITEMDRAW_SPACER)
	Format(menuitem1, sizeof(menuitem1),"%t", "MenuItem01", LANG_SERVER)
	AddMenuItem(menu, "15", menuitem1)
	Format(menuitem2, sizeof(menuitem2),"%t", "MenuItem02", LANG_SERVER)
	AddMenuItem(menu, "25", menuitem2)
	Format(menuitem3, sizeof(menuitem3),"%t", "MenuItem03", LANG_SERVER)
	AddMenuItem(menu, "35", menuitem3)
	Format(menuitem4, sizeof(menuitem4),"%t", "MenuItem04", LANG_SERVER)
	AddMenuItem(menu, "45", menuitem4)
	SetMenuExitButton(menu, false)
	VoteMenuToAll(menu, 30);
}

public Handle_VoteMenu(Handle:menu, MenuAction:action, param1, param2)
{
	switch(action)
	{
		case MenuAction_VoteStart:
		{
			VoteStarted();
			if (GetConVarBool(g_Cvar_ShowVotes))
			{
				if (g_timer_ShowVotes == INVALID_HANDLE)
				{
					g_timer_ShowVotes = CreateTimer(0.95, ShowVoteProgress, menu, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
				}
				TriggerTimer(g_timer_ShowVotes);
			}
		}

		case MenuAction_Select:
		{
			if (GetConVarBool(g_Cvar_PrintVotes))
			{
				decl String:name[CLIENT_MAX_LENGTH], String:option[ITEM_MAX_LENGTH];
				GetClientName(param1, name, sizeof(name));
				GetMenuItem(menu, param2, option, 0, _, option, sizeof(option));

				PrintToChatAll("[SM] %t", "Vote Select", name, option);
			}
			if (GetConVarBool(g_Cvar_ShowVotes))
			{
				g_PlayerVotes[param1] = param2;
				TriggerTimer(g_timer_ShowVotes);
			}
		}
	}
}

public Handler_MapVoteFinished(Handle:menu,
						   num_votes,
						   num_clients,
						   const client_info[][2],
						   num_items,
						   const item_info[][2])
{

	if (num_votes == 0)
	{
		LogError("No Votes recorded yet Advanced callback fired - Tell nobody! to fix this");
		return;
	}

	decl String:option[128], String:buffer[128], String:buffer2[128];
	GetMenuItem(menu, item_info[0][VOTEINFO_ITEM_INDEX], option, sizeof(option));

	Format(buffer2, sizeof(buffer2), "mp_timelimit %s", option);
	ServerCommand(buffer2);
	
	CPrintToChatAll("%T", "VoteEnd", LANG_SERVER, option);
	Format(buffer, sizeof(buffer), "%T", "VoteEnd_Hintbox", LANG_SERVER, option);
	VoteEnded(buffer);
}

VoteStarted()
{
	// reset all votes
	for (new i = 0; i <= MAXPLAYERS ; i++)
	{
		g_PlayerVotes[i] = -1;
	}

	// set clients allowed to vote
	ClearArray(g_AllowedVoters);
	for (new i = GetMaxClients(); i > 0; i--)
		if (IsClientInGame(i) && !IsFakeClient(i))
			PushArrayCell(g_AllowedVoters, i);

	g_VoteTimeStart2 = GetTime();
}

public VoteEnded(const String:voteEndInfo[])
{
	if (g_timer_ShowVotes != INVALID_HANDLE)
	{
		KillTimer(g_timer_ShowVotes);
		g_timer_ShowVotes = INVALID_HANDLE;
	}
	PrintHintTextToAll(voteEndInfo);
}

/**
 * Show/updates the hintbox with current vote status
 * ex.
 */
public Action:ShowVoteProgress(Handle:timer, Handle:menu)
{
	if (menu == INVALID_HANDLE) return Plugin_Continue;

	decl String:hintboxText[1024];
	decl String:option[ITEM_MAX_LENGTH];
	decl String:formatBuffer[256];
	decl String:translation_buffer[256];

	// <title> - <timeleft>
	//GetMenuTitle(menu, hintboxText, sizeof(hintboxText));
	Format(translation_buffer, sizeof(translation_buffer),"%T", "Number Of Votes", LANG_SERVER);
	Format(hintboxText, sizeof(hintboxText), "%s (%i/%i) - %is", translation_buffer, GetNrReceivedVotes(), GetArraySize(g_AllowedVoters), VoteTimeRemaining());

	// <X>. <option>
	new nrItems = GetMenuItemCount(menu);
	new itemIndex[nrItems];
	new itemVotes[nrItems];
	GetItemsSortedByVotes(itemIndex, itemVotes, nrItems);

	new displayNrOptions = GetConVarInt(g_Cvar_ShowVotes) >= nrItems ? nrItems : GetConVarInt(g_Cvar_ShowVotes);
	for (new i = 1; i <= displayNrOptions; i++)
	{
		if (itemVotes[i-1] > 0)
		{
			GetMenuItem(menu, itemIndex[i-1], option, 0, _, option, sizeof(option));

			new percent = ((itemVotes[i-1] * 100) / GetNrReceivedVotes());

			Format(formatBuffer, sizeof(formatBuffer), "\n%i. %s - %i (%i%%)", i, option, itemVotes[i-1], percent);
			StrCat(hintboxText, sizeof(hintboxText), formatBuffer);
		}
		else
			break;
	}

	PrintHintTextToAll(hintboxText);

	return Plugin_Continue;
}

/**
 * @return        timeleft (remaining) of vote.
 */
VoteTimeRemaining()
{
	new remainingTime = g_VoteTimeStart2 + 30 - GetTime();
	if (remainingTime < 0)
	{
		return 0;
	}
	else
	{
		return remainingTime;
	}
}

/**
 * Returns a list of all items (their index) and number of votes on each, ordered by nr of received votes in descending order
 */
GetItemsSortedByVotes(itemIndex[], itemVotes[], nrOfItems)
{
	// Get nr of votes on each item
	new votesOnItem[nrOfItems+1];		// simplify by increasing by one and having index 0 being "not voted"
	for (new i = 0; i <= MAXPLAYERS; i++)
	{
		votesOnItem[g_PlayerVotes[i]+1]++;
	}

	// simple insertion sort
	new mostVotes, index;
	for (new i = 0; i < nrOfItems; i++)
	{
		mostVotes = -1;
		for (new j = 1; j <= nrOfItems; j++)
		{
			if (votesOnItem[j] > mostVotes)
			{
				mostVotes = votesOnItem[j];
				index = j;
			}
		}

		itemIndex[i] = index-1;
		itemVotes[i] = mostVotes;

		// make sure it will not be selected again
		votesOnItem[index] = -1;
	}
}

/**
 * @return        return the total nr of votes received
 */
GetNrReceivedVotes()
{
	new nrVotes = 0;
	for (new i = GetMaxClients(); i > 0; i--)
	{
		if(g_PlayerVotes[i] > -1)
			nrVotes++;
	}
	return nrVotes;
}