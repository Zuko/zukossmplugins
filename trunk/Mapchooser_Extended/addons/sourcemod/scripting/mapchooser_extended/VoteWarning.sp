#include <sourcemod>
#include <sdktools>
#include <sdktools_sound>

#pragma semicolon 1

#define NUMSOUNDS 9

new String:game_mod[32];
new g_WarningTimeStart;
new Handle:g_Cvar_WarningTime  = INVALID_HANDLE;
new Handle:g_WarningTimer = INVALID_HANDLE;
new Handle:g_Cvar_WarningSound = INVALID_HANDLE;
new Handle:g_WarningSound_1 = INVALID_HANDLE;
new Handle:g_WarningSound_2 = INVALID_HANDLE;
new Handle:g_WarningSound_3 = INVALID_HANDLE;
new Handle:g_WarningSound_4 = INVALID_HANDLE;
new Handle:g_WarningSound_5 = INVALID_HANDLE;
new Handle:g_WarningSound_6 = INVALID_HANDLE;
new Handle:g_WarningSound_7 = INVALID_HANDLE;
new Handle:g_WarningSound_8 = INVALID_HANDLE;
new Handle:g_WarningSound_9 = INVALID_HANDLE;

public OnPluginStart_VoteWarning()
{
	g_Cvar_WarningTime = CreateConVar("sm_mapvote_warningtime", "16.0", "Warning time in seconds.", _, true, 0.0, true, 30.0);
	g_Cvar_CounterSounds = CreateConVar("sm_mapvote_enablewarningcountersounds", "1", "Enable sounds to be played during warning counter", _, true, 0.0, true, 1.0);
}

// LoadWarningSound
public OnConfigsExecuted_VoteWarning()
{
	GetGameFolderName(game_mod, sizeof(game_mod));
	if (strcmp(game_mod, "tf", false) == 0)
	{
		LogAction(0, -1, "Team Fortress 2 Sound Settings.");
		g_Cvar_WarningSound = CreateConVar("sm_mapvote_warningsound", "vo/announcer_warning.wav", "Sound file for warning start. (relative to $basedir/sound/)");
		
		g_WarningSound_1 = CreateConVar("sm_mapvote_warningsound_one", "vo/announcer_ends_1sec.wav", "Sound file for warning counter: one. (relative to $basedir/sound/)");
		g_WarningSound_2 = CreateConVar("sm_mapvote_warningsound_two", "vo/announcer_ends_2sec.wav", "Sound file for warning counter: one. (relative to $basedir/sound/)");
		g_WarningSound_3 = CreateConVar("sm_mapvote_warningsound_three", "vo/announcer_ends_3sec.wav", "Sound file for warning counter: one. (relative to $basedir/sound/)");
		g_WarningSound_4 = CreateConVar("sm_mapvote_warningsound_four", "vo/announcer_ends_4sec.wav", "Sound file for warning counter: one. (relative to $basedir/sound/)");
		g_WarningSound_5 = CreateConVar("sm_mapvote_warningsound_five", "vo/announcer_ends_5sec.wav", "Sound file for warning counter: one. (relative to $basedir/sound/)");
		g_WarningSound_6 = CreateConVar("sm_mapvote_warningsound_six", "vo/announcer_ends_6sec.wav", "Sound file for warning counter: one. (relative to $basedir/sound/)");
		g_WarningSound_7 = CreateConVar("sm_mapvote_warningsound_seven", "vo/announcer_ends_7sec.wav", "Sound file for warning counter: one. (relative to $basedir/sound/)");
		g_WarningSound_8 = CreateConVar("sm_mapvote_warningsound_eight", "vo/announcer_ends_8sec.wav", "Sound file for warning counter: one. (relative to $basedir/sound/)");
		g_WarningSound_9 = CreateConVar("sm_mapvote_warningsound_nine", "vo/announcer_ends_9sec.wav", "Sound file for warning counter: one. (relative to $basedir/sound/)");
	}	
	else
	{
		LogAction(0, -1, "Other Mods Sound Settings.");
		g_Cvar_WarningSound = CreateConVar("sm_mapvote_warningsound", "sourcemod/mapchooser/cstrike/warning.wav", "Sound file for warning start. (relative to $basedir/sound/)");
		g_WarningSound_1 = CreateConVar("sm_mapvote_warningsound_one", "vo/announcer_ends_1sec.wav", "Sound file for warning counter: one. (relative to $basedir/sound/)");
		g_WarningSound_2 = CreateConVar("sm_mapvote_warningsound_two", "vo/announcer_ends_2sec.wav", "Sound file for warning counter: one. (relative to $basedir/sound/)");
		g_WarningSound_3 = CreateConVar("sm_mapvote_warningsound_three", "vo/announcer_ends_3sec.wav", "Sound file for warning counter: one. (relative to $basedir/sound/)");
		g_WarningSound_4 = CreateConVar("sm_mapvote_warningsound_four", "vo/announcer_ends_4sec.wav", "Sound file for warning counter: one. (relative to $basedir/sound/)");
		g_WarningSound_5 = CreateConVar("sm_mapvote_warningsound_five", "vo/announcer_ends_5sec.wav", "Sound file for warning counter: one. (relative to $basedir/sound/)");
		g_WarningSound_6 = CreateConVar("sm_mapvote_warningsound_six", "vo/announcer_ends_6sec.wav", "Sound file for warning counter: one. (relative to $basedir/sound/)");
		g_WarningSound_7 = CreateConVar("sm_mapvote_warningsound_seven", "vo/announcer_ends_7sec.wav", "Sound file for warning counter: one. (relative to $basedir/sound/)");
		g_WarningSound_8 = CreateConVar("sm_mapvote_warningsound_eight", "vo/announcer_ends_8sec.wav", "Sound file for warning counter: one. (relative to $basedir/sound/)");
		g_WarningSound_9 = CreateConVar("sm_mapvote_warningsound_nine", "vo/announcer_ends_9sec.wav", "Sound file for warning counter: one. (relative to $basedir/sound/)");
	}

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
	
	decl String:counter_sound[64], String:counterfilePath[255];
	for (new i = 1; i<= NUMSOUNDS; i++)
	{
		new String:buffer[64];
		Format(buffer, sizeof(buffer), "g_WarningSound_%i", i);
		GetConVarString(buffer, sound, sizeof(sound));
		Format(filePath, sizeof(filePath), "sound/%s", sound);
		AddFileToDownloadsTable(filePath);
		PrecacheSound(sound, true);
		LogMessage("Precache: %s", sound);
		
		if(!FileExists(filePath))
			LogError("sound file %s does not exist.", sound);
		else if(!IsSoundPrecached(filePath))
			LogError("failed to precache sound file %s", sound);
	}
}

public SoundVoteWarning()
{
	decl String:sound[255];
	
	GetConVarString(g_Cvar_WarningSound, sound, sizeof(sound));	
	EmitSoundToAll(sound);
}

SetupWarningTimer()
{
	g_WarningTimeStart = GetTime();
	g_WarningTimer = CreateTimer(0.95, WarningHintMsg, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	
	SoundVoteWarning();
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

/**
 * @return        timeleft (remaining) of warning.
 */
WarningCountdown()
{

	new WarningTime = g_WarningTimeStart + GetConVarInt(g_Cvar_WarningTime) - GetTime();
	if (WarningTime < 0)
	{
		return 0;
	}
	else
	{
		return WarningTime;
		CountdownSounds()
	}
}

CountdownSounds()
{
	switch(WarningTime)
	{
		case 0:
			return;
		case 1:
		{
			decl String:sound[255];
			GetConVarString(g_WarningSound_One, sound, sizeof(sound));	
			EmitSoundToAll(sound);
		}
		case 2:
		{
			decl String:sound[255];
			GetConVarString(g_WarningSound_Two, sound, sizeof(sound));	
			EmitSoundToAll(sound);
		}
		case 3:
		{
			decl String:sound[255];
			GetConVarString(g_WarningSound_Three, sound, sizeof(sound));	
			EmitSoundToAll(sound);
		}	
		case 4:
		{
			decl String:sound[255];
			GetConVarString(g_WarningSound_Four, sound, sizeof(sound));	
			EmitSoundToAll(sound);
		}	
		case 5:
		{
			decl String:sound[255];
			GetConVarString(g_WarningSound_, sound, sizeof(sound));	
			EmitSoundToAll(sound);
		}
		case 6:
		{
			decl String:sound[255];
			GetConVarString(g_WarningSound_Two, sound, sizeof(sound));	
			EmitSoundToAll(sound);
		}
		case 7:
		{
			decl String:sound[255];
			GetConVarString(g_WarningSound_Two, sound, sizeof(sound));	
			EmitSoundToAll(sound);
		}
		case 8:
		{
			decl String:sound[255];
			GetConVarString(g_WarningSound_Two, sound, sizeof(sound));	
			EmitSoundToAll(sound);
		}
		case 9:
		{
			decl String:sound[255];
			GetConVarString(g_WarningSound_Two, sound, sizeof(sound));	
			EmitSoundToAll(sound);
		}
}