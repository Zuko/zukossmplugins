//----------------------------------------EVENTS FOR HATS--------------------------------------------
public eventPlayerSpawn(Handle:argEvent, const String:name[], bool:noBroadcast) 
{
	new g_userid = GetEventInt(argEvent, "userid");
	new g_user   = GetClientOfUserId(g_userid);
	new edict;
	new itemOwner = -1;
	g_CLIENTHATS[g_user] = 0;
	
	edict = MaxClients+1;
	while((edict = FindEntityByClassname(edict, "tf_wearable_item")) != -1)
	{
		if (numHatAccepted(GetEntProp(edict, Prop_Send, "m_iItemDefinitionIndex")))
		{
			if (IsValidEntity(edict) && IsValidEdict(edict))
			{
				itemOwner = GetEntPropEnt(edict, Prop_Send, "m_hOwnerEntity");
				if (itemOwner == g_user) 
				{
					g_CLIENTHATS[g_user] = GetEntProp(edict, Prop_Send, "m_iItemDefinitionIndex");
				}
			}
		}
	}
	ResetTimeForAClient(g_user);
}

public Boolean:numHatAccepted(any:argNum)
{
	switch (argNum)
	{
		//Demoman's 'Fro
		case 47: return true;
		//Mining Light
		case 48: return true;
		//Football Helmet
		case 49: return true;
		//Prussian Pickelhaube
		case 50: return true;
		//Pyro's Beanie
		case 51: return true;
		//Batter's Helmet
		case 52: return true;
		//Trophy Hat
		case 53: return true;
		//Soldier's Stash
		case 54: return true;
		//Fancy Fedora
		case 55: return true;
		
		//Texas Ten Gallon
		case 94: return true;
		//Engineer's Cap
		case 95: return true;
		//Officer's Ushanka
		case 96: return true;
		//Tough Guy's Tuque
		case 97: return true;
		//Stainless Pot
		case 98: return true;
		//Tyrant's Helm
		case 99: return true;
		
		//Glengarry Bonnet
		case 100: return true;
		//Vintage Tyrolean
		case 101: return true;
		//Respectless Rubber Glove
		case 102: return true;
		//Camera Beard
		case 103: return true;
		//Otolaryngologist's Mirror
		case 104: return true;
		//Brigade Helm
		case 105: return true;
		//Bonk Helm
		case 106: return true;
		//Ye Olde Baker Boy
		case 107: return true;
		//Backbiter's Billycock
		case 108: return true;
		//Professional's Panama
		case 109: return true;
		//Master's Yellow Belt
		case 110: return true;
		//Baseball Bill's Sports Shine (Hatless Scout)
		case 111: return true;
		
		//Halloween Hat (Only appears on Halloween)
		case 115: return true;
		//Ghastly Gibus
		case 116: return true;
		//Ritzy Rick's Hair Fixative (Hatless Sniper)
		case 117: return true;
		//Texas Slim's Dome Shine (Hatless Engineer)
		case 118: return true;
		//Scottsman's Stove Pipe
		case 120: return true;
		//Service Medal
		case 121: return true;
		//Cheater's Lament
		case 125: return true;
		//Bill's Hat
		case 126: return true;
	}
	return false;
}


public eventInventChange(Handle:argEvent, const String:name[], bool:noBroadcast) 
{
	new g_userid = GetEventInt(argEvent, "userid");
	new g_user   = GetClientOfUserId(g_userid);
	new edict = -1;
	new itemOwner = -1;
	g_CLIENTHATS[g_user] = 0;
	edict = MaxClients+1;
	while((edict = FindEntityByClassname(edict, "tf_wearable_item")) != -1)
	{
		if (numHatAccepted(GetEntProp(edict, Prop_Send, "m_iItemDefinitionIndex")))
		{
			if (IsValidEntity(edict) && IsValidEdict(edict))
			{
				itemOwner = GetEntPropEnt(edict, Prop_Send, "m_hOwnerEntity");
				if (itemOwner == g_user) 
				{
					g_CLIENTHATS[g_user] = GetEntProp(edict, Prop_Send, "m_iItemDefinitionIndex");
				}
			}
		}
	}
}

public eventDisconnect(argClient) 
{
	g_CLIENTHATS[argClient] = 0;
}