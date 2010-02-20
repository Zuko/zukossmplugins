#include <sourcemod>
#include <sdktools>
#include <sdktools_sound>

#pragma semicolon 1

new g_WarningTimeStart;
new Handle:g_Cvar_WarningTime  = INVALID_HANDLE;
new Handle:g_WarningTimer = INVALID_HANDLE;
//new Handle:g_WarningTimerForTimeVote = INVALID_HANDLE;
new Handle:g_Cvar_WarningSound = INVALID_HANDLE;
new String:g_WarningSound[PLATFORM_MAX_PATH];

public OnPluginStart_VoteWarning()
{
	g_Cvar_WarningTime = CreateConVar("sm_mapvote_warningtime", "15.0", "Warning time in seconds.", _, true, 0.0, true, 30.0);
	g_Cvar_WarningSound = CreateConVar("sm_mapvote_warningsound", "sourcemod/mapchooser/klaxon1.mp3", "Sound file for warning start.");
}

// LoadWarningSound
public OnConfigsExecuted_VoteWarning()
{
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
	g_WarningTimeStart = GetTime();
	g_WarningTimer = CreateTimer(GetConVarFloat(g_Cvar_WarningTime), WarningHintMsg, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
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

/*
public Action:WarningHintMsgForTimeVote(Handle:timer)
{
	decl String:hintboxText[512];
	Format(hintboxText, sizeof(hintboxText), "WARNING! Vote will start in: %i s", WarningCountdown());
	PrintHintTextToAll(hintboxText);

	if (WarningCountdown() == 0)
	{
		KillTimer(g_WarningTimerForTimeVote);
	}
}
*/
/**
 * @return        timeleft (remaining) of warning.
 */
WarningCountdown()
{
	//LogMessage("g_WarningTimeStart: %i", g_WarningTimeStart);
	//new one = GetConVarInt(g_Cvar_WarningTime);
	//new two = GetTime();
	//new three = g_WarningTimeStart - two;
	//new dupa = g_WarningTimeStart + one;
	//LogMessage("g_WarningTimeStart + g_Cvar_WarningTime: %i", dupa);
	//LogMessage("g_Cvar_WarningTime: %i", one);
	//LogMessage("Time from loop: %i", two);
	//LogMessage("g_WarningTimeStart - Time from loop: %i", three);

	new WarningTime = g_WarningTimeStart + GetConVarInt(g_Cvar_WarningTime) - GetTime();
	LogMessage("WarningTime: %i", WarningTime);
	if (WarningTime < 0)
	{
		return 0;
	}
	else
	{
		return WarningTime;
	}
}