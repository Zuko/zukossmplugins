new Handle:g_MENU_ACH_DONE 		= INVALID_HANDLE;
new Handle:g_MENU_ACH_NOT_DONE	= INVALID_HANDLE;
new Handle:g_MENU_DELETE_ACH	= INVALID_HANDLE;

/*---------------------------------------------------------------------------------
C U S T O M   A C H I E V E M E N T S
P R I N C I P A L   M E N U   
---------------------------------------------------------------------------------*/
//MENU TO CHOOSE OPTION 
public Action:Panel_Menu(argClient, args)
{
	new Handle:g_panel_menu;
	new String:strMessageTitle[255];
	new String:strMessageOption1[255];
	new String:strMessageOption2[255];
	new String:strMessageOption3[255];
	new String:strMessageOption4[255];
	new String:strYesorNot[20];
	new String:strExit[255];
	new String:strName[32];
	new strNumberachievement;
	new strNumberachievementdone;
	new String:strSteamidofclient[100];
	GetClientName(argClient, strName, sizeof(strName));
	GetClientAuthString(argClient, strSteamidofclient, sizeof(strSteamidofclient));
	strNumberachievement = g_MAXACHIEVEMENTS;
	strNumberachievementdone = CountAchievementDone(argClient);
	Format(strMessageTitle, sizeof(strMessageTitle), "%T", "Menu Panel Title", LANG_SERVER, strName,strNumberachievementdone,strNumberachievement);
	Format(strMessageOption1, sizeof(strMessageOption1), "%T", "Menu Panel show achievements done", LANG_SERVER);
	Format(strMessageOption2, sizeof(strMessageOption2), "%T", "Menu Panel show achievements not done", LANG_SERVER);
	
	if(g_CONFIGPROGRESSION[argClient] == 0)
	{
		Format(strYesorNot,sizeof(strYesorNot),"%T","Desactivate", LANG_SERVER);
	}
	else
	{
		Format(strYesorNot,sizeof(strYesorNot),"%T","Activate", LANG_SERVER);
	}
	Format(strMessageOption3, sizeof(strMessageOption3), "%T %s", "Show Progression of achievements", LANG_SERVER, strYesorNot);
	Format(strMessageOption4, sizeof(strMessageOption4), "%T", "Delete achievement", LANG_SERVER);
	Format(strExit, sizeof(strExit), "%T", "Exit", LANG_SERVER);
	g_panel_menu = CreatePanel();
	SetPanelTitle(g_panel_menu, strMessageTitle);
	DrawPanelItem(g_panel_menu, strMessageOption1);
	DrawPanelItem(g_panel_menu, strMessageOption2);
	DrawPanelItem(g_panel_menu, strMessageOption3);
	DrawPanelItem(g_panel_menu, strMessageOption4);
	DrawPanelItem(g_panel_menu, strExit);
	SendPanelToClient(g_panel_menu, argClient, PanelHandler1, 20);
	MustCloseHandle(g_panel_menu);
	return Plugin_Handled;
}


/*---------------------------------------------------------------------------------
PanelHandler1
---------------------------------------------------------------------------------*/
//To create a panel with your achievements done and others.
public PanelHandler1(Handle:argMenu, MenuAction:argAction, argParam1, argParam2)
{
	if (argAction == MenuAction_Select)
	{
		if (argParam2 == 1)
		{
			g_MENU_ACH_DONE = Panel_Menu_Option1(argParam1);
		}
		if (argParam2 == 2)
		{
			g_MENU_ACH_NOT_DONE = Panel_Menu_Option2(argParam1);
		}
		if (argParam2 == 3)
		{
			if(g_CONFIGPROGRESSION[argParam1] == 0)
				g_CONFIGPROGRESSION[argParam1] = 1;
			else
			g_CONFIGPROGRESSION[argParam1] = 0;
			Panel_Menu(argParam1,0);
		}
		if (argParam2 == 4)
		{
			g_MENU_DELETE_ACH = Panel_Menu_Option4(argParam1);
		}
		if (argParam2 == 5)
		{
		}
	}
	else if (argAction == MenuAction_End)
	{
		MustCloseHandle(g_MENU_ACH_DONE);
		MustCloseHandle(g_MENU_ACH_NOT_DONE);
		MustCloseHandle(g_MENU_DELETE_ACH);
	}
}

public PanelHandler2(Handle:argMenu, MenuAction:argAction, argParam1, argParam2)
{
	if (argAction == MenuAction_Select)
	{
		new String:strInfo[100];
		GetMenuItem(argMenu, argParam2, strInfo, sizeof(strInfo));
		SayAchievementCaracteristic(strInfo, argParam1);
	}
	else if (argAction == MenuAction_Cancel)
	{
		Panel_Menu(argParam1,0);
	}
	else if (argAction == MenuAction_End)
	{
		MustCloseHandle(argMenu);
	}
}


public SayAchievementCaracteristic(const String:argEvent_name[], argClient)
{
	new String:strSteamidofclient[100];
	decl String:strQuery[500];
	new String:strTablePrefix[128];
	GetConVarString	 (g_CVTABLEPREFIX, strTablePrefix, sizeof(strTablePrefix));
	GetClientAuthString(argClient, strSteamidofclient, sizeof(strSteamidofclient));
	
	Format(g_NameOfAchievement, sizeof(g_NameOfAchievement), "%s", argEvent_name);
	//Number of achievements
	Format(strQuery, sizeof(strQuery), "SELECT `b`.`amount`, `a`.`status`, `b`.`description`, `b`.`ResetBlocksOnDeath` FROM `%sachievements` b ,`%susers_ach` a WHERE `b`.`name` = \"%s\" and `a`.`steamid`='%s' and `b`.`id` = `a`.`achid`;", strTablePrefix,strTablePrefix, argEvent_name, strSteamidofclient);	
	SQL_TQuery		(g_HDATABASE, SayAchCarac_Af_Qu, strQuery,argClient);
}

public SayAchCarac_Af_Qu(Handle:owner, Handle:strhQuery, const String:error[], any:argClient) 
{
	if (strhQuery == INVALID_HANDLE)
	{
		LogMessage("Failed to retrieve 'SayAchievementCaracteristic' list from the database, %s",error);
		return;
	}
	decl String:strQuery[500];
	new String:strMessageToSay[500];
	new String:strExplicationSQL[200];
	new String:strExplication[200];
	new String:strNameOfAchievement[150];
	new String:strTablePrefix[128];
	new String:strInOneLife[200];
	new String:strInOneRound[200];
	GetConVarString	 (g_CVTABLEPREFIX, strTablePrefix, sizeof(strTablePrefix))
	if (SQL_GetRowCount(strhQuery) > 0)
	{
		while (SQL_FetchRow(strhQuery))
		{
			Format(strInOneLife, sizeof(strInOneLife), "%T", "In one life", LANG_SERVER);
			Format(strInOneRound, sizeof(strInOneRound), "%T", "In one round", LANG_SERVER);
			if(SQL_FetchInt(strhQuery, 3)== 1)
			{
				Format(strMessageToSay, sizeof(strMessageToSay), "\x05%s  - \x01(%s) : ", g_NameOfAchievement, strInOneLife);
			}
			else
			{
				if(SQL_FetchInt(strhQuery, 3)== 2)
				{
					if(SQL_FetchInt(strhQuery, 0) == 1)
					{
						Format(strMessageToSay, sizeof(strMessageToSay), "\x05%s  - \x01(%s) : ", g_NameOfAchievement, strInOneRound );
					}
					else
					{
						Format(strMessageToSay, sizeof(strMessageToSay), "\x05%s  - \x01(%i/%i - %s) : ", g_NameOfAchievement, SQL_FetchInt(strhQuery, 1),SQL_FetchInt(strhQuery, 0),strInOneRound);
					}
				}
				else
				{
					Format(strMessageToSay, sizeof(strMessageToSay), "\x05%s  - \x01(%i/%i) : ", g_NameOfAchievement, SQL_FetchInt(strhQuery, 1),SQL_FetchInt(strhQuery, 0));
				}
			}
			SayText2One(argClient, argClient, strMessageToSay);
			SQL_FetchString(strhQuery, 2, strExplicationSQL, sizeof(strExplicationSQL));
			Format(strExplication, sizeof(strExplication), "%T", "Explication", LANG_SERVER);
			Format(strMessageToSay, sizeof(strMessageToSay), "%s : \x03%s", strExplication,strExplicationSQL);
			SayText2One(argClient, argClient, strMessageToSay);
		}
	}
	else
	{ 
		Format(strQuery, sizeof(strQuery), "SELECT `amount`, `description`, `ResetBlocksOnDeath` FROM `%sachievements` b WHERE `name` = \"%s\";",strTablePrefix, g_NameOfAchievement);
		SQL_TQuery		(g_HDATABASE, SayAchCarac_Af_Qu2, strQuery,argClient);
	}
}
public SayAchCarac_Af_Qu2(Handle:owner, Handle:strhQuery, const String:error[], any:argClient) 
{
	new String:strNameOfAchievement[150];
	new String:strMessageToSay[500];
	new String:strInOneLife[200];
	new String:strInOneRound[200];
	new String:strExplicationSQL[200];
	new String:strExplication[200];
	while (SQL_FetchRow(strhQuery))
	{
		Format(strInOneLife, sizeof(strInOneLife), "%T", "In one life", LANG_SERVER);
		Format(strInOneRound, sizeof(strInOneRound), "%T", "In one round", LANG_SERVER);
		if(SQL_FetchInt(strhQuery, 2) == 0)
			Format(strMessageToSay, sizeof(strMessageToSay), "\x05%s  - \x01(0/%i) : ", g_NameOfAchievement, SQL_FetchInt(strhQuery, 0));
		else
		{
			if(SQL_FetchInt(strhQuery, 2) == 1)
			{
				Format(strMessageToSay, sizeof(strMessageToSay), "\x05%s  - \x01(%s) : ", g_NameOfAchievement, strInOneLife);
			}
			else
			{
				Format(strMessageToSay, sizeof(strMessageToSay), "\x05%s  - \x01(%s) : ", g_NameOfAchievement, strInOneRound);
			}
		}
		SayText2One(argClient, argClient, strMessageToSay);
		SQL_FetchString(strhQuery, 1, strExplicationSQL, sizeof(strExplicationSQL));
		Format(strExplication, sizeof(strExplication), "%T", "Explication", LANG_SERVER);
		Format(strMessageToSay, sizeof(strMessageToSay), "%s : \x03%s", strExplication,strExplicationSQL);
		SayText2One(argClient, argClient, strMessageToSay);
	}
}

public any:CountAchievementDone(argClient)
{
	new String:strSteamidofclient[100];
	new String:strSteamidOnTable[100];
	new count = 0;
	GetClientAuthString(argClient, strSteamidofclient, sizeof(strSteamidofclient));
	for(new i = 0; i < g_USERS_ACH; i++) 
	{
		GetArrayString	(g_LIST_USERS_ACH_STEAMID, i, strSteamidOnTable, sizeof(strSteamidOnTable));
		if(StrEqual(strSteamidOnTable,strSteamidofclient))
		{
			if(GetArrayCell(g_LIST_USERS_ACH_COMPLETE,i) == 1)
				count++;
		}
	}
	return count;
}

public any:IsClientAchDone(argClient, argAchId)
{
	new String:strSteamidofclient[100];
	new String:strSteamidOnTable[100];
	new count = 0;
	GetClientAuthString(argClient, strSteamidofclient, sizeof(strSteamidofclient));
	for(new i = 0; i < g_USERS_ACH; i++) 
	{
		GetArrayString	(g_LIST_USERS_ACH_STEAMID, i, strSteamidOnTable, sizeof(strSteamidOnTable));
		if(GetArrayCell(g_LIST_USERS_ACH_ACHID,i) == argAchId)
		{
			if(StrEqual(strSteamidOnTable,strSteamidofclient))
			{
				if(GetArrayCell(g_LIST_USERS_ACH_COMPLETE,i) == 1)
					return true;
			}
		}
	}
	return false;
}



/*---------------------------------------------------------------------------------
C U S T O M   A C H I E V E M E N T S
O P T I O N 1  :  S H O W   C U S T O M S 
A C H I E V E M E N T S       D O N E 
---------------------------------------------------------------------------------*/
Handle:Panel_Menu_Option1(argClient)
{
	new String:strMessageTitle[255];
	new String:strAch_Title[255];
	new String:strName[32];
	new String:strExit[255];
	new strNumberachievement;
	new strNumberachievementdone;
	new String:strSteamidofclient[100];
	GetClientName(argClient, strName, sizeof(strName));
	GetClientAuthString(argClient, strSteamidofclient, sizeof(strSteamidofclient));
	strNumberachievement = g_MAXACHIEVEMENTS;
	//Number of achievements of the player
	strNumberachievementdone = CountAchievementDone(argClient);
	Format(strMessageTitle, sizeof(strMessageTitle), "%T", "Option show achievements of Menu", LANG_SERVER, strNumberachievementdone,strNumberachievement);
	if (strNumberachievementdone == 0)
	{
		new Handle:strPanel =  CreatePanel();
		DrawPanelText(strPanel,"                                    ");
		DrawPanelText(strPanel,"                                    ");
		Format(strAch_Title, sizeof(strAch_Title), "%T", "No achievement done", LANG_SERVER);
		DrawPanelText(strPanel,strAch_Title);
		DrawPanelText(strPanel,"                                    ");
		DrawPanelText(strPanel,"                                    ");
		Format(strExit, sizeof(strExit), "%T", "Back", LANG_SERVER);
		DrawPanelItem(strPanel, strExit);
		SetPanelTitle(strPanel, strMessageTitle);
		SendPanelToClient(strPanel, argClient, PanelHandlerNULL, 20);
		MustCloseHandle(strPanel);
	}
	else
	{
		new Handle:strPanel = CreateMenu(PanelHandler2);
		for(new i = 0; i < g_MAXACHIEVEMENTS; i++) 
		{
			if(IsClientAchDone(argClient,GetArrayCell(g_LIST_ACHIEVEMENTS_ID,i)))
			{
				GetArrayString	(g_LIST_ACHIEVEMENTS_NAME, i, strAch_Title, sizeof(strAch_Title));
				AddMenuItem(strPanel,strAch_Title,strAch_Title);
			}
		}
		SetMenuTitle(strPanel, strMessageTitle);
		DisplayMenu(strPanel,argClient,20);
		return strPanel;
	}
	return INVALID_HANDLE;
}

/*---------------------------------------------------------------------------------
C U S T O M   A C H I E V E M E N T S
R E T U R N  T O  M A I N   M E N U
---------------------------------------------------------------------------------*/
public PanelHandlerNULL(Handle:argMenu, MenuAction:argAction, argParam1, argParam2)
{
	if (argAction == MenuAction_Select)
	{
		Panel_Menu(argParam1,0);
	}
}

/*---------------------------------------------------------------------------------
C U S T O M   A C H I E V E M E N T S
D E L E T E   A C H I E V E M E N T S  B E F O R E 
---------------------------------------------------------------------------------*/
public PanelHandler3 (Handle:argMenu, MenuAction:argAction, argParam1, argParam2)
{
	if (argAction == MenuAction_Select)
	{
		new String:info[100];
		GetMenuItem(argMenu, argParam2, info, sizeof(info));
		DeleteConfirmationAchievement(info, argParam1);
	} 
	else if (argAction == MenuAction_Cancel) {
		
		Panel_Menu(argParam1,0);
	}
	else if (argAction == MenuAction_End)
	{
		MustCloseHandle(argMenu);
	}
	
}

/*---------------------------------------------------------------------------------
C U S T O M   A C H I E V E M E N T S
D E L E T E   A C H I E V E M E N T S   A F T E R
---------------------------------------------------------------------------------*/
public PanelHandler31 (Handle:argMenu, MenuAction:argAction, argParam1, argParam2)
{
	if (argAction == MenuAction_Select)
	{
		if (argParam2 == 1)
		{
			DeleteAchievement(g_DELETEACHIEVEMENT[argParam1], argParam1);
		}
		if (argParam2 == 3)
		{
			Panel_Menu(argParam1,0);
		}
	}
	else if (argAction == MenuAction_Cancel) {
		Panel_Menu(argParam1,0);
	}
}


/*---------------------------------------------------------------------------------
C U S T O M   A C H I E V E M E N T S
D E L E T E   A C H I E V E M E N T   C O N F 
---------------------------------------------------------------------------------*/
public DeleteConfirmationAchievement(const String:argEvent_name[], argClient)
{
	new String:strMessageTitle[255];
	new String:strYes[255];
	new String:strNo[255];
	new String:strReturn[255];
	new String:strAchName[300];
	
	Format(strAchName,sizeof(strAchName),"%s",argEvent_name);
	Format(strMessageTitle,sizeof(strMessageTitle),"%T","Delete confirmation", LANG_SERVER);
	Format(strYes,sizeof(strYes),"%T","Yes", LANG_SERVER);
	Format(strNo,sizeof(strNo),"%T","No", LANG_SERVER);
	Format(strReturn, sizeof(strReturn), "%T", "Back", LANG_SERVER);
	
	new Handle: strPanel_confirm = CreatePanel();
	SetPanelTitle(strPanel_confirm, strMessageTitle);
	DrawPanelItem(strPanel_confirm, strYes);
	DrawPanelItem(strPanel_confirm, strNo);
	DrawPanelItem(strPanel_confirm, strReturn);
	SendPanelToClient(strPanel_confirm, argClient, PanelHandler31, 20);
	MustCloseHandle(strPanel_confirm);
	
	g_DELETEACHIEVEMENT[argClient] = strAchName;
}


/*---------------------------------------------------------------------------------
C U S T O M   A C H I E V E M E N T S
D E L E T E   A C H I E V E M E N T 
---------------------------------------------------------------------------------*/
public DeleteAchievement(const String:argEvent_name[], argclient)
{
	decl String:strQuery[500];
	new String:strTablePrefix[128];
	new String:strSteamidofclient[100];
	GetClientAuthString(argclient, strSteamidofclient, sizeof(strSteamidofclient));
	GetConVarString	 (g_CVTABLEPREFIX, strTablePrefix, sizeof(strTablePrefix));
	//Number of achievements
	Format(strQuery, sizeof(strQuery), "SELECT * FROM `%sachievements` b ,`%susers_ach` a WHERE `b`.`name` = \"%s\" and `a`.`steamid`='%s' and `b`.`id` = `a`.`achid`;",strTablePrefix,strTablePrefix, argEvent_name, strSteamidofclient);
	SQL_TQuery		(g_HDATABASE, DeleteAchievement_After_Query, strQuery, argclient);
}

public DeleteAchievement_After_Query(Handle:owner, Handle:strhQuery, const String:error[], any:argclient) 
{
	new String:strSteamidofclient[100];
	decl String:strQuery[500];
	new String:strTablePrefix[128];
	new String:strMessage[500];
	new String:strMessageToSay[500];
	new String:strNameAch[150];
	
	GetConVarString	 (g_CVTABLEPREFIX, strTablePrefix, sizeof(strTablePrefix));
	GetClientAuthString(argclient, strSteamidofclient, sizeof(strSteamidofclient));
	if (strhQuery == INVALID_HANDLE)
	{
		LogMessage("Failed to delete an achievement to a player, %s",error);
		return;
	}
	if (SQL_GetRowCount(strhQuery) > 0)
	{
		while (SQL_FetchRow(strhQuery))
		{
			new strIdofachievement = SQL_FetchInt(strhQuery, 0);
			new idofBlock1 = SQL_FetchInt(strhQuery, 10);
			new idofBlock2 = SQL_FetchInt(strhQuery, 13);
			new idofBlock3 = SQL_FetchInt(strhQuery, 16);
			new idofBlock4 = SQL_FetchInt(strhQuery, 19);
			new idofBlock5 = SQL_FetchInt(strhQuery, 22);
			new String:typeofblock1[100];
			SQL_FetchString(strhQuery, 9,typeofblock1,sizeof(typeofblock1));
			new String:typeofblock2[100]; 
			SQL_FetchString(strhQuery, 12,typeofblock2,sizeof(typeofblock2));
			new String:typeofblock3[100];
			SQL_FetchString(strhQuery, 15,typeofblock3,sizeof(typeofblock3));
			new String:typeofblock4[100];
			SQL_FetchString(strhQuery, 18,typeofblock4,sizeof(typeofblock4));
			new String:typeofblock5[100]; 
			SQL_FetchString(strhQuery, 21,typeofblock5,sizeof(typeofblock5));
			
			SQL_FetchString(strhQuery, 1, strNameAch, sizeof(strNameAch));
			Format(strQuery, sizeof(strQuery), "DELETE FROM `%susers_ach` WHERE `achid` = %i and steamid = '%s';",strTablePrefix,strIdofachievement,strSteamidofclient);
			SQL_TQuery(g_HDATABASE, EmptyCallback, strQuery);
			//----------------------------------BLOCKS-------------------------------------------
			if(!StrEqual(typeofblock1, "none"))
			{
				Format(strQuery, sizeof(strQuery), "DELETE FROM `%susers_blocks` WHERE `block_id` = %i and `steamid` = '%s' and `block_typ` = '%s';",strTablePrefix,idofBlock1,strSteamidofclient,typeofblock1);
				SQL_TQuery(g_HDATABASE, EmptyCallback, strQuery);
			}
			if(!StrEqual(typeofblock2, "none"))
			{
				Format(strQuery, sizeof(strQuery), "DELETE FROM `%susers_blocks` WHERE `block_id` = %i and `steamid` = '%s' and `block_typ` = '%s';",strTablePrefix,idofBlock3,strSteamidofclient,typeofblock3);
				SQL_TQuery(g_HDATABASE, EmptyCallback, strQuery);
			}
			if(!StrEqual(typeofblock4, "none"))
			{
				Format(strQuery, sizeof(strQuery), "DELETE FROM `%susers_blocks` WHERE `block_id` = %i and `steamid` = '%s' and `block_typ` = '%s';",strTablePrefix,idofBlock4,strSteamidofclient,typeofblock4);
				SQL_TQuery(g_HDATABASE, EmptyCallback, strQuery);
			}
			if(!StrEqual(typeofblock5, "none"))
			{
				Format(strQuery, sizeof(strQuery), "DELETE FROM `%susers_blocks` WHERE `block_id` = %i and `steamid` = '%s' and `block_typ` = '%s';",strTablePrefix,idofBlock5,strSteamidofclient,typeofblock5);
				SQL_TQuery(g_HDATABASE, EmptyCallback, strQuery);
			}
			
			Format(strMessage, sizeof(strMessage), "%T", "Deleting ok", LANG_SERVER);
			Format(strMessageToSay, sizeof(strMessageToSay), "\x01%s \x05%s",strMessage,strNameAch);
			SayText2One(argclient, argclient, strMessage);
			SayText2One(argclient, argclient, strMessageToSay);
		}
	}
	RC_Users_Ach();
	RC_Users_Blocks();
}

/*---------------------------------------------------------------------------------
C U S T O M   A C H I E V E M E N T S
O P T I O N 2  :  S H O W   C U S T O M S 
A C H I E V E M E N T S  N O T  D O N E 
---------------------------------------------------------------------------------*/
Handle:Panel_Menu_Option2(argclient)
{
	new String:strMessageTitle[255];
	new String:strAch_Title[255];
	new String:strExit[255];
	new strNumberachievement;
	new strNumberachievementdone;
	new String:strSteamidofclient[100];
	new Handle:strPanel;
	GetClientAuthString(argclient, strSteamidofclient, sizeof(strSteamidofclient));
	strNumberachievement = g_MAXACHIEVEMENTS;
	
	//Number of achievements of the player
	strNumberachievementdone = CountAchievementDone(argclient);
	Format(strMessageTitle, sizeof(strMessageTitle), "%T", "Option show achievements no done of Menu", LANG_SERVER, strNumberachievementdone,strNumberachievement);
	if (strNumberachievementdone == strNumberachievement)
	{
		Format(strAch_Title, sizeof(strAch_Title), "%T", "All achievements done", LANG_SERVER);
		strPanel =  CreatePanel();
		DrawPanelText(strPanel,"                                    ");
		DrawPanelText(strPanel,"                                    ");
		DrawPanelText(strPanel,strAch_Title);
		DrawPanelText(strPanel,"                                    ");
		DrawPanelText(strPanel,"                                    ");
		Format(strExit, sizeof(strExit), "%T", "Back", LANG_SERVER);
		DrawPanelItem(strPanel, strExit);
		SetPanelTitle(strPanel, strMessageTitle);
		SendPanelToClient(strPanel, argclient, PanelHandlerNULL, 20);
		MustCloseHandle(strPanel);
	}
	else
	{
		new Handle:strPanel = CreateMenu(PanelHandler2);
		for(new i = 0; i < g_MAXACHIEVEMENTS; i++) 
		{
			if(!IsClientAchDone(argclient,GetArrayCell(g_LIST_ACHIEVEMENTS_ID,i)))
			{
				GetArrayString	(g_LIST_ACHIEVEMENTS_NAME, i, strAch_Title, sizeof(strAch_Title));
				AddMenuItem(strPanel,strAch_Title,strAch_Title);
			}
		}
		SetMenuTitle(strPanel, strMessageTitle);
		DisplayMenu(strPanel,argclient,20);
		return strPanel;
	}
	return INVALID_HANDLE;
}

/*---------------------------------------------------------------------------------
C U S T O M   A C H I E V E M E N T S
V 0 . 6           O P T I O N 3 
D E L E T E    A C H I E V E M E N T 
---------------------------------------------------------------------------------*/
Handke:Panel_Menu_Option4(argClient)
{
	new String:strMessageTitle[255];
	new String:strAch_Title[255];
	new String:strName[32];
	new String:strExit[255];
	new strNumberachievement;
	new strNumberachievementdone;
	new String:strSteamidofclient[100];
	GetClientName(argClient, strName, sizeof(strName));
	GetClientAuthString(argClient, strSteamidofclient, sizeof(strSteamidofclient));
	strNumberachievement = g_MAXACHIEVEMENTS;
	strNumberachievementdone = CountAchievementDone(argClient);
	
	Format(strMessageTitle, sizeof(strMessageTitle), "%T", "Option delete achievements", LANG_SERVER, strNumberachievementdone,strNumberachievement);
	if (strNumberachievementdone == 0)
	{
		new Handle:strPanel =  CreatePanel();
		Format(strAch_Title, sizeof(strAch_Title), "%T", "No achievement done", LANG_SERVER);
		DrawPanelText(strPanel, "                                    ");
		DrawPanelText(strPanel, "                                    ");
		DrawPanelText(strPanel,strAch_Title);
		DrawPanelText(strPanel, "                                    ");
		DrawPanelText(strPanel, "                                    ");
		Format(strExit, sizeof(strExit), "%T", "Back", LANG_SERVER);
		DrawPanelItem(strPanel, strExit);
		SetPanelTitle(strPanel, strMessageTitle);
		SendPanelToClient(strPanel, argClient, PanelHandlerNULL, 20);
		MustCloseHandle(strPanel);
	}
	else
	{
		new Handle:strPanel = CreateMenu(PanelHandler3);
		for(new i = 0; i < g_MAXACHIEVEMENTS; i++) 
		{
			if(IsClientAchDone(argClient,GetArrayCell(g_LIST_ACHIEVEMENTS_ID,i)))
			{
				GetArrayString	(g_LIST_ACHIEVEMENTS_NAME, i, strAch_Title, sizeof(strAch_Title));
				AddMenuItem(strPanel,strAch_Title,strAch_Title);
			}
		}
		SetMenuTitle(strPanel, strMessageTitle);
		DisplayMenu(strPanel,argClient,20);
		return strPanel;
	}
	return INVALID_HANDLE;
}



public Action:menu_say(argClient, args) {
	decl String:strText[192];
	new strShow;
	if (!GetCmdArgString(strText, sizeof(strText)))
	{
		return Plugin_Continue;
	}
	new startidx = 0;
	if(strText[strlen(strText)-1] == '"')
	{
		strText[strlen(strText)-1] = '\0';
		startidx = 1;
	}
	
	new ReplySource:old = SetCmdReplySource(SM_REPLY_TO_CHAT);
	SetCmdReplySource(old);
	
	new String:strMenuCvar[255];
	GetConVarString(g_CVCHATMENU, strMenuCvar, sizeof(strMenuCvar));
	
	strShow = GetConVarInt(g_CVMENU);
	if(strShow == 1)
	{
		if (StrEqual(strText[startidx], strMenuCvar, false) || StrEqual(strText[startidx], "/achievement", false) || StrEqual(strText[startidx], "/show_achievements", false))	
		{
			RC_Users_Ach();
			RC_Users_Blocks();
			Panel_Menu(argClient,0);
			return Plugin_Continue;	
		}
	}
	return Plugin_Continue;	
}