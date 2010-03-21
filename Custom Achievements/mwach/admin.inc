new String:g_AchievementNameForClient[255];
new Boolean:g_AchievementClientAllOrNot;
new g_AchievementClient[MAXPLAYERS + 1];
new g_AchievementClientAchId[MAXPLAYERS + 1];
public Action:admin_part(client, args)
{
	new String:access[8];
	GetConVarString(g_FLAGADMIN,access,8);
	decl String:text[192];
	decl String:strText[192];
	if (!GetCmdArgString(text, sizeof(text)))
	{
		return Plugin_Continue;
	}
	new startidx = 0;
	if(text[strlen(text)-1] == '"')
	{
		text[strlen(text)-1] = '\0';
		startidx = 1;
	}
	TrimString(text);
	strcopy(strText,strlen("/admin_ach")+1,text[startidx]);
	TrimString(strText);
	if (StrEqual(strText, "/admin_ach", false))	
	{
		if (GetUserFlagBits(client) & ReadFlagString(access) > 0 || GetUserFlagBits(client) & ADMFLAG_ROOT > 0)
		{
			
			if(strlen(text[startidx]) > strlen("/admin_ach"))
			{
				startidx = strlen("/admin_ach") + 1;
				new String:NameOfNewAchievement[255];
				strcopy(NameOfNewAchievement,sizeof(NameOfNewAchievement),text[startidx]);
				TrimString(NameOfNewAchievement);
				Admin_Menu_New_Achievement(NameOfNewAchievement,client);
			}
			else
			{
				Admin_Menu_Give_Achievement(client);
			}
		}
		else
		{
			CPrintToChat(client, "%t", "Not Access Level");
			return Plugin_Handled;
		}
	}
	else
	{
		new ReplySource:old = SetCmdReplySource(SM_REPLY_TO_CHAT);
		SetCmdReplySource(old);
	}
	return Plugin_Continue;
}

/*---------------------------------------------------------------------------------
C U S T O M   A C H I E V E M E N T S
A D M I N  M E N U  A C H I E V E M E N T S
---------------------------------------------------------------------------------*/
Admin_Menu_Give_Achievement(any:argClient)
{
	new String:strMessageTitle[255];
	new String:strAch_Title[255];
	new String:strExit[255];
	new strNumberachievement;
	new strNumberachievementdone;
	new String:strSteamidofclient[100];
	new Handle:strPanel;
	GetClientAuthString(argClient, strSteamidofclient, sizeof(strSteamidofclient));
	strNumberachievement = g_MAXACHIEVEMENTS;
	
	//Number of achievements of the player
	Format(strMessageTitle, sizeof(strMessageTitle), "%T", "Choose achievement", LANG_SERVER);
	if (strNumberachievement == 0)
	{
		Format(strAch_Title, sizeof(strAch_Title), "%s", "No achievement in database");
		strPanel =  CreatePanel();
		DrawPanelText(strPanel,"                                    ");
		DrawPanelText(strPanel,"                                    ");
		DrawPanelText(strPanel,strAch_Title);
		DrawPanelText(strPanel,"                                    ");
		DrawPanelText(strPanel,"                                    ");
		Format(strExit, sizeof(strExit), "%T", "Back", LANG_SERVER);
		DrawPanelItem(strPanel, strExit);
		SetPanelTitle(strPanel, strMessageTitle);
		SendPanelToClient(strPanel, argClient, HandlerNULL, 20);
		MustCloseHandle(strPanel);
	}
	else
	{
		new Handle:strPanel = CreateMenu(PanelMenuAddAchievementHandler);
		new String:numAch[8];
		for(new i = 0; i < g_MAXACHIEVEMENTS; i++) 
		{
			GetArrayString	(g_LIST_ACHIEVEMENTS_NAME, i, strAch_Title, sizeof(strAch_Title));
			IntToString(GetArrayCell(g_LIST_ACHIEVEMENTS_ID,i),numAch,sizeof(numAch));
			AddMenuItem(strPanel,numAch,strAch_Title);
		}
		SetMenuTitle(strPanel, strMessageTitle);
		DisplayMenu(strPanel,argClient,20);
	}
}

public HandlerNULL(Handle:argMenu, MenuAction:argAction, argParam1, argParam2)
{
	if (argAction == MenuAction_Select)
	{
	}
}

public PanelMenuAddAchievementHandler(Handle:argMenu, MenuAction:argAction, argParam1, argParam2)
{
	if (argAction == MenuAction_Select)
	{
		new String:strInfo[100];
		GetMenuItem(argMenu, argParam2, strInfo, sizeof(strInfo));
		AddAnAchievementPartOne(strInfo,argParam1);
	}
	else if (argAction == MenuAction_End)
	{
		MustCloseHandle(argMenu);
	}
}

public PanelMenuAddAchievementHandler2(Handle:argMenu, MenuAction:argAction, argParam1, argParam2)
{
	if (argAction == MenuAction_Select)
	{
		new String:strInfo[100];
		GetMenuItem(argMenu, argParam2, strInfo, sizeof(strInfo));
		if(StrEqual(strInfo,"all",true))
		{
			g_AchievementClientAllOrNot = true;
		}
		else
		{
			g_AchievementClientAllOrNot = false;
			g_AchievementClient[argParam1] = StringToInt(strInfo);
		}
		AddAnAchievementPartTwo(argParam1);
	}
	else if (argAction == MenuAction_End)
	{
		MustCloseHandle(argMenu);
	}
}

public PanelMenuAddAchievementHandler3(Handle:argMenu, MenuAction:argAction, argParam1, argParam2)
{
	new String:strQuery[512];
	new String:strTablePrefix[128];
	new String:steamIdOfClient[64];
	new String:strId[512];
	GetConVarString(g_CVTABLEPREFIX, strTablePrefix, sizeof(strTablePrefix));
	new String:strAchName[255];
	new String:strAchDesc[255];
	
	for(new i = 0; i < g_MAXACHIEVEMENTS; i++) 
	{
		if(GetArrayCell(g_LIST_ACHIEVEMENTS_ID,i) ==  g_AchievementClientAchId[argParam1])
		{
			GetArrayString	(g_LIST_ACHIEVEMENTS_NAME, i, strAchName, sizeof(strAchName));
			GetArrayString	(g_LIST_ACHIEVEMENTS_DESCRIPTION, i, strAchDesc, sizeof(strAchDesc));
		}
	}
	if (argAction == MenuAction_Select)
	{
		new String:strInfo[100];
		GetMenuItem(argMenu, argParam2, strInfo, sizeof(strInfo));
		if(StrEqual(strInfo,"all",true))
		{
			if(g_AchievementClientAllOrNot)
			{
				for(new i = 1; i < MaxClients + 1; i++) 
				{
					if(IsValidClient(i))
					{
						GetClientAuthString(i, steamIdOfClient, sizeof(steamIdOfClient));
						Format(strId,sizeof(strId),"%s__%d",steamIdOfClient,g_AchievementClientAchId[argParam1]);
						Format(strQuery, sizeof(strQuery), "INSERT INTO `%susers_ach` (`id`, `steamid`, `achid`, `status`, `complete`) VALUES ('%s', '%s', '%d', '0', '1') ON DUPLICATE KEY UPDATE `complete` = 1", strTablePrefix, strId, steamIdOfClient, g_AchievementClientAchId[argParam1]);
						SQL_TQuery(g_HDATABASE, EmptyCallback, strQuery,  1, DBPrio_High);
						AchievementEffect(i,strAchName,strAchDesc);
					}
				}
			}
			else
			{
				if(IsValidClient(g_AchievementClient[argParam1]))
				{
					GetClientAuthString(g_AchievementClient[argParam1], steamIdOfClient, sizeof(steamIdOfClient));
					Format(strId,sizeof(strId),"%s__%d",steamIdOfClient,g_AchievementClientAchId[argParam1]);
					Format(strQuery, sizeof(strQuery), "INSERT INTO `%susers_ach` (`id`, `steamid`, `achid`, `status`, `complete`) VALUES ('%s', '%s', '%d', '0', '1') ON DUPLICATE KEY UPDATE `complete` = 1", strTablePrefix, strId, steamIdOfClient, g_AchievementClientAchId[argParam1]);
					SQL_TQuery(g_HDATABASE, EmptyCallback, strQuery,  1, DBPrio_High);
					AchievementEffect(g_AchievementClient[argParam1],strAchName,strAchDesc);
				}
			}	
		}
		else
		{
			if(g_AchievementClientAllOrNot)
			{
				for(new i = 1; i < MaxClients + 1; i++) 
				{
					if(IsValidClient(i))
					{
						AddToAchievement(i,g_AchievementClientAchId[argParam1],StringToInt(strInfo));
					}
				}
			}
			else
			{
				if(IsValidClient(g_AchievementClient[argParam1]))
				{
					AddToAchievement(g_AchievementClient[argParam1],g_AchievementClientAchId[argParam1],StringToInt(strInfo));
				}
			}
		}
	}
	else if (argAction == MenuAction_End)
	{
		MustCloseHandle(argMenu);
	}
}


AddAnAchievementPartOne(const String:argAch[],any:argAdmin)
{
	new String:strMessageTitle[255];
	new Handle:strPanel = CreateMenu(PanelMenuAddAchievementHandler2);
	new String:strClientName[255];
	new String:numClient[8];
	Format(strMessageTitle, sizeof(strMessageTitle), "%T", "All client", LANG_SERVER);
	AddMenuItem(strPanel,"all",strMessageTitle);
	for(new i = 1; i < MaxClients+1; i++) 
	{
		if(IsValidClient(i))
		{
			GetClientName(i,strClientName,sizeof(strClientName));
			IntToString(i,numClient,sizeof(numClient));
			AddMenuItem(strPanel,numClient,strClientName);
		}
	}
	Format(strMessageTitle, sizeof(strMessageTitle), "%T", "Who ?", LANG_SERVER);
	SetMenuTitle(strPanel, strMessageTitle);
	DisplayMenu(strPanel,argAdmin,20);
	g_AchievementClientAchId[argAdmin] = StringToInt(argAch);
}

AddAnAchievementPartTwo(any:argAdmin)
{
	new AmountOfAch = 0;
	for(new i = 0; i < g_MAXACHIEVEMENTS; i++) {
		if (GetArrayCell(g_LIST_ACHIEVEMENTS_ID, i) == g_AchievementClientAchId[argAdmin])
		{
			AmountOfAch = GetArrayCell(g_LIST_ACHIEVEMENTS_TRIGGERS, i);
		}
	}
	
	new Handle:strPanel = CreateMenu(PanelMenuAddAchievementHandler3);
	new String:strMessageTitle[255];
	Format(strMessageTitle, sizeof(strMessageTitle), "%T", "Give the achievement", LANG_SERVER);
	AddMenuItem(strPanel,"all",strMessageTitle);
	if(AmountOfAch != -1)
	{
		Format(strMessageTitle, sizeof(strMessageTitle), "+1 %T", "on the achievement", LANG_SERVER);
		if (AmountOfAch > 1)
			AddMenuItem(strPanel,"1",strMessageTitle);
		Format(strMessageTitle, sizeof(strMessageTitle), "+2 %T", "on the achievement", LANG_SERVER);
		if (AmountOfAch > 2)
			AddMenuItem(strPanel,"2",strMessageTitle);
		Format(strMessageTitle, sizeof(strMessageTitle), "+5 %T", "on the achievement", LANG_SERVER);
		if (AmountOfAch > 5)
			AddMenuItem(strPanel,"5",strMessageTitle);
		Format(strMessageTitle, sizeof(strMessageTitle), "+10 %T", "on the achievement", LANG_SERVER);
		if (AmountOfAch > 10)
			AddMenuItem(strPanel,"10",strMessageTitle);
		Format(strMessageTitle, sizeof(strMessageTitle), "+20 %T", "on the achievement", LANG_SERVER);
		if (AmountOfAch > 20)
			AddMenuItem(strPanel,"20",strMessageTitle);
		Format(strMessageTitle, sizeof(strMessageTitle), "+50 %T", "on the achievement", LANG_SERVER);
		if (AmountOfAch > 50)
			AddMenuItem(strPanel,"50",strMessageTitle);
		Format(strMessageTitle, sizeof(strMessageTitle), "+100 %T", "on the achievement", LANG_SERVER);
		if (AmountOfAch > 100)
			AddMenuItem(strPanel,"100",strMessageTitle);
		Format(strMessageTitle, sizeof(strMessageTitle), "+200 %T", "on the achievement", LANG_SERVER);
		if (AmountOfAch > 200)
			AddMenuItem(strPanel,"200",strMessageTitle);
		Format(strMessageTitle, sizeof(strMessageTitle), "+500 %T", "on the achievement", LANG_SERVER);
		if (AmountOfAch > 500)
			AddMenuItem(strPanel,"200",strMessageTitle);
	}
	Format(strMessageTitle, sizeof(strMessageTitle), "%T", "Decide to give", LANG_SERVER);
	SetMenuTitle(strPanel, strMessageTitle);
	DisplayMenu(strPanel,argAdmin,20);
}

/*---------------------------------------------------------------------------------
C U S T O M   A C H I E V E M E N T S
A D M I N  M E N U  N E W  A C H I E V E M E N T S
---------------------------------------------------------------------------------*/
Admin_Menu_New_Achievement(const String:argAch_name[],argClient)
{
	if(strlen(argAch_name) <= 0)
	{
		Admin_Menu_Give_Achievement(argClient);
		return;
	}
	new String:strMessageTitle[255];
	Format(strMessageTitle, sizeof(strMessageTitle), "%T", "Name of achievement", LANG_SERVER, argAch_name);
	new Handle:strPanel = CreateMenu(PanelMenuNewAchievementHandler);
	new String:strClientName[255];
	new String:numClient[8];
	AddMenuItem(strPanel,"all","All");
	for(new i = 1; i < MaxClients+1; i++) 
	{
		if(IsValidClient(i))
		{
			GetClientName(i,strClientName,sizeof(strClientName));
			IntToString(i,numClient,sizeof(numClient));
			AddMenuItem(strPanel,numClient,strClientName);
		}
	}
	SetMenuTitle(strPanel, strMessageTitle);
	DisplayMenu(strPanel,argClient,20);
	Format(g_AchievementNameForClient,sizeof(g_AchievementNameForClient), "%s", argAch_name);
	ReplaceString(g_AchievementNameForClient,sizeof(g_AchievementNameForClient),"'","''",true);
}

/*---------------------------------------------------------------------------------
PanelMenuNewAchievementHandler
---------------------------------------------------------------------------------*/
public PanelMenuNewAchievementHandler(Handle:argMenu, MenuAction:argAction, argParam1, argParam2)
{
	if (argAction == MenuAction_Select)
	{
		new String:strInfo[100];
		GetMenuItem(argMenu, argParam2, strInfo, sizeof(strInfo));
		if(StrEqual(strInfo,"all",true))
		{
			GiveAnAchievementOnAllClient(argParam1);
		}
		else
		{
			new argClientWhoWant = StringToInt(strInfo);
			GiveAnAchievementOnClient(argParam1,argClientWhoWant);
		}
	}
	else if (argAction == MenuAction_End)
	{
		MustCloseHandle(argMenu);
	}
}

/*---------------------------------------------------------------------------------
GiveAnAchievementOnClient
---------------------------------------------------------------------------------*/
public GiveAnAchievementOnClient(any:argAdmin,any:argClient)
{
	decl String:strQuery[500];
	new String:strSteamIDAdmin[64];
	new String:strSteamIDClient[64];
	new String:descriptionOfAch[255];
	new String:nameOfAdmin[125];
	new String:strTablePrefix[128];
	GetConVarString(g_CVTABLEPREFIX, strTablePrefix, sizeof(strTablePrefix));
	new timeNow = GetTime();
	
	GetClientAuthString	(argAdmin, strSteamIDAdmin, sizeof(strSteamIDAdmin));
	GetClientAuthString	(argClient, strSteamIDClient, sizeof(strSteamIDClient));
	GetClientName(argAdmin,nameOfAdmin,sizeof(nameOfAdmin));
	Format(descriptionOfAch, sizeof(descriptionOfAch), "%T", "Gived by an admin", LANG_SERVER, nameOfAdmin);
	
	Format(strQuery, sizeof(strQuery), "INSERT INTO `%susers_ach_spe` (`id`, `title`, `steamid`, `admin`, `time`) VALUES (NULL, '%s', '%s', '%s', %u)",strTablePrefix, g_AchievementNameForClient,argAdmin,argClient,timeNow);
	SQL_TQuery(g_HDATABASE, EmptyCallback, strQuery);
	
	AchievementEffect(argClient, g_AchievementNameForClient, descriptionOfAch);
}

/*---------------------------------------------------------------------------------
GiveAnAchievementOnAllClient
---------------------------------------------------------------------------------*/
public GiveAnAchievementOnAllClient(any:argAdmin)
{
	decl String:strQuery[500];
	new String:strSteamIDAdmin[64];
	new String:strSteamIDClient[64];
	new String:descriptionOfAch[255];
	new String:nameOfAdmin[125];
	new String:strTablePrefix[128];
	GetConVarString(g_CVTABLEPREFIX, strTablePrefix, sizeof(strTablePrefix));
	
	GetClientAuthString	(argAdmin, strSteamIDAdmin, sizeof(strSteamIDAdmin));
	GetClientName(argAdmin,nameOfAdmin,sizeof(nameOfAdmin));
	Format(descriptionOfAch, sizeof(descriptionOfAch), "%T", "Gived by an admin", LANG_SERVER, nameOfAdmin);
	for(new i = 1; i < MaxClients+1; i++) 
	{
		if(IsValidClient(i))
		{
			new timeNow = GetTime();
			GetClientAuthString	(i, strSteamIDClient, sizeof(strSteamIDClient));
			Format(strQuery, sizeof(strQuery), "INSERT INTO `%susers_ach_spe` (`id`, `title`, `steamid`, `admin`, `time`) VALUES (NULL, '%s', '%s', '%s', %u)",strTablePrefix, g_AchievementNameForClient,strSteamIDClient,strSteamIDAdmin,timeNow);
			SQL_TQuery(g_HDATABASE, EmptyCallback, strQuery);
			AchievementEffect(i, g_AchievementNameForClient, descriptionOfAch);
		}
	}	
}