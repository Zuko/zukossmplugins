public ResetTimeForAClient(any:argClient)
{
	new timeNow = GetTime();
	for(new i = 0; i < g_MAXACHIEVEMENTS; i++) 
	{
		if(GetArrayCell(g_LIST_ACHIEVEMENTS_RESETTIME,i)!=-1)
		{
			g_TIMEACHIEVEMENT[argClient][i] = timeNow;
		}
		else
		{
			g_TIMEACHIEVEMENT[argClient][i] = 0;
		}
	}
}
