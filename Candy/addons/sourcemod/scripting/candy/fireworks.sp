#define ACHIEVEMENT_SOUND	"misc/achievement_earned.wav"

new g_Target			[MAXPLAYERS + 1];
new g_Ent				[MAXPLAYERS + 1]; 

public OnMapStart()
{
	InitPrecache();
}

InitPrecache()
{
	PrecacheSound(ACHIEVEMENT_SOUND, true);
}

StartLooper(client)
{
	if (IsPlayerAlive(client) && IsClientConnected(client) && IsClientInGame(client))
	{
		
		if (TF2_GetPlayerClass(client) == TF2_GetClass("spy"))
		{
			//Do a more advanced check to see if the spy is cloaked or disguised.
			return;
		}
		
		CreateTimer(0.01, Timer_Particles, client, TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(0.5, Timer_Trophy, client, TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(2.0, Timer_Particles, client, TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(10.0, Timer_Delete, client, TIMER_FLAG_NO_MAPCHANGE);
		
	}
	return;
}

public Action:Timer_Particles(Handle:timer, any:client)
{
	if (IsPlayerAlive(client) && IsClientConnected(client) && IsClientInGame(client))
	{
		AttachParticle(client, "mini_fireworks");
	}
	return Plugin_Handled;
}

public Action:Timer_Trophy(Handle:timer, any:client)
{
	if (IsPlayerAlive(client) && IsClientConnected(client) && IsClientInGame(client))
	{
		AttachParticle(client, "achieved");
	}
	return Plugin_Handled;
}

public Action:Timer_Delete(Handle:timer, any:client)
{
	DeleteParticle(g_Ent[client]);
	g_Ent[client] = 0;
	g_Target[client] = 0;
}

AttachParticle(ent, String:particleType[])
{
	new particle = CreateEntityByName("info_particle_system");
	
	new String:tName[128];
	
	if (IsValidEdict(particle))
	{
		new Float:pos[3] ;
		
		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
		pos[2] += 74
		TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
		
		Format(tName, sizeof(tName), "target%i", ent);
		
		DispatchKeyValue(ent, "targetname", tName);
		DispatchKeyValue(particle, "targetname", "tf2particle");
		DispatchKeyValue(particle, "parentname", tName);
		DispatchKeyValue(particle, "effect_name", particleType);
		DispatchSpawn(particle);
		
		SetVariantString(tName);
		AcceptEntityInput(particle, "SetParent", particle, particle, 0);
		SetVariantString("flag");
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		
		g_Ent[ent] = particle;
		g_Target[ent] = 1;
	}
}

DeleteParticle(any:particle)
{
    if (IsValidEntity(particle))
    {
        new String:classname[256];
        GetEdictClassname(particle, classname, sizeof(classname));
		
        if (StrEqual(classname, "info_particle_system", false))
        {
            RemoveEdict(particle);
        }
    }
}