#include <sourcemod>
#include <sdktools>
#include <sdktools_sound>

#pragma semicolon 1

new g_WarningTimeStart;
new Handle:g_Cvar_WarningTime  = INVALID_HANDLE;
new Handle:g_WarningTimer = INVALID_HANDLE;
new Handle:g_Cvar_WarningSound = INVALID_HANDLE;
new String:g_WarningSound[PLATFORM_MAX_PATH];

public OnPluginStart_VoteWarning()
{
	g_Cvar_WarningTime = CreateConVar("sm_mapvote_warningtime", "15.0", "Warning time in seconds.", _, true, 0.0, true, 30.0);
	g_Cvar_WarningSound = CreateConVar("sm_mapvote_warningsound", "ambient/alarms/klaxon1.wav", "Sound file for warning start.");
}

// LoadWarningSound
public OnConfigsExecuted_VoteWarning()
{
	//GetConVarString(g_Cvar_WarningSound, g_WarningSound, PLATFORM_MAX_PATH);
	//GetConVarString(g_cvars_sound[Sound_VoteStart], sound, sizeof(sound));
	//native GetConVarString(Handle:convar, String:value[], maxlength);
	
	decl String:sound[255], String:filePath[255];
	
	GetConVarString(g_Cvar_WarningSound, sound, sizeof(sound));
	if(strlen(sound) > 0)
	{
		Format(filePath, sizeof(filePath), "sound/%s", sound);
		AddFileToDownloadsTable(filePath);
		PrecacheSound(sound, true);
		
		if(!FileExists(filePath))
			LogError("sound file %s does not exist.", sound);
		else if(!IsSoundPrecached(filePath))
			LogError("failed to precache sound file %s", sound);
	}
	
	
}

SetupWarningTimer()
{
	//pobieram aktualny czas na serwerze
	g_WarningTimeStart = GetTime();
	//robie zapetlonego timera ktory odlicza czas ostrzezenia, po jego zakonczeniu inicjalizuje glosowanie
	//native Handle:CreateTimer(Float:interval, Timer:func, any:data=INVALID_HANDLE, flags=0);
	g_WarningTimer = CreateTimer(GetConVarFloat(g_Cvar_WarningTime), WarningHintMsg, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	//dzwiek ostrzegajacy o glosowaniu
	EmitSoundToAll(g_WarningSound);
}

public Action:WarningHintMsg(Handle:timer)
{
	decl String:hintboxText[512];
	Format(hintboxText, sizeof(hintboxText), "WARNING! Vote will start in: %i s", WarningCountdown());
	PrintHintTextToAll(hintboxText);

	if (WarningCountdown() == 0)
	{
		KillTimer(g_WarningTimer);
		InitiateVote(MapChange_MapEnd, INVALID_HANDLE);
	}
}

SetupWarningTimer2(data)
{
	//pobieram aktualny czas na serwerze
	g_WarningTimeStart = GetTime();
	//robie zapetlonego timera ktory odlicza czas ostrzezenia, po jego zakonczeniu inicjalizuje glosowanie
	//native Handle:CreateTimer(Float:interval, Timer:func, any:data=INVALID_HANDLE, flags=0);
	g_WarningTimer = CreateTimer(GetConVarFloat(g_Cvar_WarningTime), WarningHintMsg2, data, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	//dzwiek ostrzegajacy o glosowaniu
	EmitSoundToAll(g_WarningSound);
}

public Action:WarningHintMsg2(Handle:timer, data)
{
	decl String:hintboxText[512];
	Format(hintboxText, sizeof(hintboxText), "WARNING! Vote will start in: %i s", WarningCountdown());
	PrintHintTextToAll(hintboxText);

	if (WarningCountdown() == 0)
	{
		KillTimer(g_WarningTimer);
		
		new MapChange:mapChange = MapChange:ReadPackCell(data);
		new Handle:hndl = Handle:ReadPackCell(data);

		InitiateVote(mapChange, hndl);
	}
}

/**
 * @return        timeleft (remaining) of warning.
 */
WarningCountdown()
{
	new WarningTime = g_WarningTimeStart + GetConVarInt(g_Cvar_WarningTime) - GetTime();
	if(WarningTime < 0)
	{
		return 0;
	}
	else
	{
		return WarningTime;
	}
}