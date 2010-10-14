/*
 * Zuko / #hlds.pl @ Qnet / zuko.steamunpowered.eu /
 */

#include <sourcemod>
#include <sdktools>
#include <colors>

#define ITEM_MAX_LENGTH 128
#define CLIENT_MAX_LENGTH	32
#define PLUGIN_VERSION "1.4"

new Handle:g_Cvar_PrintVotes = INVALID_HANDLE;
new Handle:g_Cvar_ShowVotes = INVALID_HANDLE;
new Handle:g_AllowedVoters = INVALID_HANDLE;
new Handle:g_timer_ShowVotes = INVALID_HANDLE;
new Handle:g_Cvar_Average = INVALID_HANDLE;
new Handle:g_Cvar_A = INVALID_HANDLE;

new g_VoteTimeStart2;
new g_PlayerVotes[MAXPLAYERS+1];
new bool:anyplayerconnected = false

public Plugin:myinfo = 
{
	name = "Map Time Vote",
	author = "Zuko",
	description = "How long map should be played. Enable or disable crits?",
	version = PLUGIN_VERSION,
	url = "http://zuko.steamunpowered.eu"
}

public OnPluginStart()
{
	CreateConVar("critbonusvote_version", PLUGIN_VERSION, "Map Time Vote Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	
	LoadTranslations("maptimevote.phrases");
	LoadTranslations("common.phrases");
	LoadTranslations("basetriggers.phrases");

	g_Cvar_PrintVotes = CreateConVar("sm_maptimevote_printvotes", "0", "Should the option that a player vote on get printed (1 - yes print player votes, 0 - don't print).", _, true, 0.0, true, 1.0);
	g_Cvar_ShowVotes = CreateConVar("sm_maptimevote_showvotes", "3", "How many vote options the hint box should show. 0 will disable it", _, true, 0.0, true, 3.0);
	g_Cvar_Average = CreateConVar("sm_maptimevote_average", "1", "Count average map time from all votes.", _, true, 0.0, true, 1.0);
	g_Cvar_A = CreateConVar("sm_maptimevote_aa", "30", "", _, true, 0.0); //Kiedy startowac glosowanie
	g_AllowedVoters = CreateArray(1);
}

public OnMapStart()
{
	anyplayerconnected = false
}

public OnMapEnd()
{
	g_timer_ShowVotes = INVALID_HANDLE;
}

public OnClientDisconnect(client)
{
	g_PlayerVotes[client] = -1;

	new index = FindValueInArray(g_AllowedVoters, client);
	if (index > -1)
	{
		RemoveFromArray(g_AllowedVoters, index);
	}

	if (GetConVarBool(g_Cvar_ShowVotes) && g_timer_ShowVotes != INVALID_HANDLE)
	{
		TriggerTimer(g_timer_ShowVotes);
	}
}

public OnClientPostAdminCheck()
{
	if (!anyplayerconnected)
	{
		CreateTimer(GetConVarFloat(g_Cvar_A), StartVote)
		anyplayerconnected = true
	}
}

public Action:StartVote(Handle:timer)
{
	if (GetRealClientCount() > 1)
	{
		if (IsVoteInProgress())
		{
			return;
		}
	 
		new Handle:menu = CreateMenu(Handle_VoteMenu);
		SetVoteResultCallback(menu, Handler_MapVoteFinished);
		SetMenuPagination(menu, MENU_NO_PAGINATION);
		
		decl String:lineone[128], String:linetwo[128];
		decl String:title[100], String:menuitem1[100], String:menuitem2[100], String:menuitem3[100], String:menuitem4[100];
		Format(title, sizeof(title),"%t", "VoteMenuTitle", LANG_SERVER);
		SetMenuTitle(menu, title);
		AddMenuItem(menu, "nothing", " ", ITEMDRAW_SPACER);
		Format(lineone, sizeof(lineone),"%T", "Line One", LANG_SERVER);
		AddMenuItem(menu, "nothing", lineone, ITEMDRAW_DISABLED);
		Format(linetwo, sizeof(linetwo),"%T", "Line Two", LANG_SERVER);
		AddMenuItem(menu, "nothing", linetwo, ITEMDRAW_DISABLED);
		AddMenuItem(menu, "nothing", " ", ITEMDRAW_SPACER);
		AddMenuItem(menu, "nothing", " ", ITEMDRAW_SPACER);
		Format(menuitem1, sizeof(menuitem1),"%T", "MenuItem01", LANG_SERVER);
		AddMenuItem(menu, "15", menuitem1);
		Format(menuitem2, sizeof(menuitem2),"%T", "MenuItem02", LANG_SERVER);
		AddMenuItem(menu, "25", menuitem2);
		Format(menuitem3, sizeof(menuitem3),"%T", "MenuItem03", LANG_SERVER);
		AddMenuItem(menu, "35", menuitem3);
		Format(menuitem4, sizeof(menuitem4),"%T", "MenuItem04", LANG_SERVER);
		AddMenuItem(menu, "45", menuitem4);
		SetMenuExitButton(menu, false)
		VoteMenuToAll(menu, 30);
	}
	else
	{
		anyplayerconnected = false;
		KillTimer(Handle:timer);
	}
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
		case MenuAction_VoteCancel:
		{
			if (param1 == VoteCancel_NoVotes)
			{
				decl String:buffer[128];
				Format(buffer, sizeof(buffer), "%T", "No_Votes", LANG_SERVER);
				CPrintToChatAll("%T", "No_Votes", LANG_SERVER);
				VoteEnded(buffer);
			}
			else
			{
				decl String:buffer[128];
				Format(buffer, sizeof(buffer), "%T", "Cancelled Vote", param1);
				VoteEnded(buffer);
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
	
	if ((num_votes > 1) && GetConVarBool(g_Cvar_Average))
	{
		decl String:option[128], String:option2[128], String:option3[128], String:option4[128];
		decl String:buffer[128], String:buffer2[128];
		GetMenuItem(menu, item_info[0][VOTEINFO_ITEM_INDEX], option, sizeof(option));
		GetMenuItem(menu, item_info[1][VOTEINFO_ITEM_INDEX], option2, sizeof(option2));
		GetMenuItem(menu, item_info[2][VOTEINFO_ITEM_INDEX], option3, sizeof(option3));
		GetMenuItem(menu, item_info[3][VOTEINFO_ITEM_INDEX], option4, sizeof(option4));

		new result;
		
		if (num_items == 1)
		{
			new ivotes = RoundToFloor(float(item_info[0][VOTEINFO_ITEM_VOTES]));
			
			new ioption = StringToInt(option);
			
			result = (((ioption*ivotes))/num_votes)
		}
		if (num_items == 2)
		{
			new ivotes = RoundToFloor(float(item_info[0][VOTEINFO_ITEM_VOTES]));
			new ivotes2 = RoundToFloor(float(item_info[1][VOTEINFO_ITEM_VOTES]));
			
			new ioption = StringToInt(option);
			new ioption2 = StringToInt(option2);
			
			result = (((ioption*ivotes)+(ioption2*ivotes2))/num_votes)
		}
		if (num_items == 3)
		{
			new ivotes = RoundToFloor(float(item_info[0][VOTEINFO_ITEM_VOTES]));
			new ivotes2 = RoundToFloor(float(item_info[1][VOTEINFO_ITEM_VOTES]));
			new ivotes3 = RoundToFloor(float(item_info[2][VOTEINFO_ITEM_VOTES]));
			
			new ioption = StringToInt(option);
			new ioption2 = StringToInt(option2);
			new ioption3 = StringToInt(option3);

			result = (((ioption*ivotes)+(ioption2*ivotes2)+(ioption3*ivotes3))/num_votes)
		}
		if (num_items == 4)
		{
			new ivotes = RoundToFloor(float(item_info[0][VOTEINFO_ITEM_VOTES]));
			new ivotes2 = RoundToFloor(float(item_info[1][VOTEINFO_ITEM_VOTES]));
			new ivotes3 = RoundToFloor(float(item_info[2][VOTEINFO_ITEM_VOTES]));
			new ivotes4 = RoundToFloor(float(item_info[3][VOTEINFO_ITEM_VOTES]));
			
			new ioption = StringToInt(option);
			new ioption2 = StringToInt(option2);
			new ioption3 = StringToInt(option3);
			new ioption4 = StringToInt(option4);

			result = (((ioption*ivotes)+(ioption2*ivotes2)+(ioption3*ivotes3)+(ioption4*ivotes4))/num_votes)
		}

		Format(buffer2, sizeof(buffer2), "mp_timelimit %i", result);
		new Handle:H_mp_timelimit = FindConVar("mp_timelimit");
		new flags = GetConVarFlags(H_mp_timelimit);
		SetConVarFlags(H_mp_timelimit, flags & ~FCVAR_NOTIFY);
		ServerCommand(buffer2);
		SetConVarFlags(H_mp_timelimit, flags|FCVAR_NOTIFY);
		
		CPrintToChatAll("%T", "VoteEnd_Average", LANG_SERVER, result);
		Format(buffer, sizeof(buffer), "%T", "VoteEnd_Hintbox_Average", LANG_SERVER, result);
		VoteEnded(buffer);

		CreateTimer(5.0, StartVote2);
	}
	else
	{	
		decl String:option[128], String:buffer[128], String:buffer2[128];
		GetMenuItem(menu, item_info[0][VOTEINFO_ITEM_INDEX], option, sizeof(option));

		Format(buffer2, sizeof(buffer2), "mp_timelimit %s", option);
		new Handle:H_mp_timelimit = FindConVar("mp_timelimit");
		new flags = GetConVarFlags(H_mp_timelimit);
		SetConVarFlags(H_mp_timelimit, flags & ~FCVAR_NOTIFY);
		ServerCommand(buffer2);
		SetConVarFlags(H_mp_timelimit, flags|FCVAR_NOTIFY);

		CPrintToChatAll("%T", "VoteEnd", LANG_SERVER, option);
		Format(buffer, sizeof(buffer), "%T", "VoteEnd_Hintbox", LANG_SERVER, option);
		VoteEnded(buffer);
		
		CreateTimer(5.0, StartVote2);
	}
}

public Action:StartVote2(Handle:timer)
{
	if (IsVoteInProgress())
	{
		return;
	}
 
	new Handle:menu2 = CreateMenu(Handle_VoteMenu2);
	SetVoteResultCallback(menu2, Handler_MapVoteFinished2);
	SetMenuPagination(menu2, MENU_NO_PAGINATION);
	
	decl String:lineone[128], String:linetwo[128];
	decl String:title[100], String:menuitem1[100], String:menuitem2[100];
	Format(title, sizeof(title),"%t", "VoteMenuTitle2", LANG_SERVER);
	SetMenuTitle(menu2, title);
	AddMenuItem(menu2, "nothing", " ", ITEMDRAW_SPACER);
	Format(lineone, sizeof(lineone),"%T", "Line Three", LANG_SERVER);
	AddMenuItem(menu2, "nothing", lineone, ITEMDRAW_DISABLED);
	Format(linetwo, sizeof(linetwo),"%T", "Line Four", LANG_SERVER);
	AddMenuItem(menu2, "nothing", linetwo, ITEMDRAW_DISABLED);
	AddMenuItem(menu2, "nothing", " ", ITEMDRAW_SPACER);
	Format(menuitem1, sizeof(menuitem1),"%T", "MenuItem05", LANG_SERVER);
	AddMenuItem(menu2, "1", menuitem1);
	Format(menuitem2, sizeof(menuitem2),"%T", "MenuItem06", LANG_SERVER);
	AddMenuItem(menu2, "0", menuitem2);
	SetMenuExitButton(menu2, false)
	VoteMenuToAll(menu2, 30);
}

public Handle_VoteMenu2(Handle:menu2, MenuAction:action, param1, param2)
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
					g_timer_ShowVotes = CreateTimer(0.95, ShowVoteProgress, menu2, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
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
				GetMenuItem(menu2, param2, option, 0, _, option, sizeof(option));

				PrintToChatAll("[SM] %t", "Vote Select", name, option);
			}
			if (GetConVarBool(g_Cvar_ShowVotes))
			{
				g_PlayerVotes[param1] = param2;
				TriggerTimer(g_timer_ShowVotes);
			}
		}
		case MenuAction_VoteCancel:
		{
			if (param1 == VoteCancel_NoVotes)
			{
				decl String:buffer[128];
				Format(buffer, sizeof(buffer), "%T", "No_Votes", LANG_SERVER);
				CPrintToChatAll("%T", "No_Votes", LANG_SERVER);
				VoteEnded(buffer);
			}
			else
			{
				decl String:buffer[128];
				Format(buffer, sizeof(buffer), "%T", "Cancelled Vote", param1);
				VoteEnded(buffer);
			}
		}
	}
}

public Handler_MapVoteFinished2(Handle:menu2,
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
	
	decl String:option[128], String:buffer[128], String:buffer2[128], String:buffer3[128];
	GetMenuItem(menu2, item_info[0][VOTEINFO_ITEM_INDEX], option, sizeof(option));

	Format(buffer2, sizeof(buffer2), "tf_weapon_criticals %s", option);
	
	new Handle:H_tf_weapon_criticals = FindConVar("tf_weapon_criticals");
	new Handle:H_sv_tags = FindConVar("sv_tags");
	new flags = GetConVarFlags(H_tf_weapon_criticals);
	new flags2 = GetConVarFlags(H_sv_tags);
	SetConVarFlags(H_tf_weapon_criticals, flags & ~FCVAR_NOTIFY);
	SetConVarFlags(H_sv_tags, flags2 & ~FCVAR_NOTIFY);
	ServerCommand(buffer2);
	SetConVarFlags(H_tf_weapon_criticals, flags|FCVAR_NOTIFY);
	SetConVarFlags(H_sv_tags, flags2|FCVAR_NOTIFY);

	if (strcmp(option, "1") == 0)
	{
		Format(buffer3, sizeof(buffer3), "%T", "Enabled", LANG_SERVER);
	}
	else
	{
		Format(buffer3, sizeof(buffer3), "%T", "Disabled", LANG_SERVER);
	}
	
	CPrintToChatAll("%T", "VoteEnd2", LANG_SERVER, buffer3);
	Format(buffer, sizeof(buffer), "%T", "VoteEnd_Hintbox2", LANG_SERVER, buffer3);
	VoteEnded(buffer);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
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

			Format(formatBuffer, sizeof(formatBuffer), "%T", "Vote Progress", LANG_SERVER, i, option, itemVotes[i-1], percent);
			StrCat(hintboxText, sizeof(hintboxText), formatBuffer);
		}
		else
			break;
	}

	PrintHintTextToAll("%s", hintboxText);

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

stock GetRealClientCount( bool:inGameOnly = true ) {
	new clients = 0;
	for( new i = 1; i <= GetMaxClients(); i++ ) {
		if( ( ( inGameOnly ) ? IsClientInGame( i ) : IsClientConnected( i ) ) && !IsFakeClient( i ) ) {
			clients++;
		}
	}
	return clients;
}