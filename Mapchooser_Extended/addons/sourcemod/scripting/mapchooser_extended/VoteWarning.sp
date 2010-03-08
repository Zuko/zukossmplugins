#include <sourcemod>
#include <sdktools>
#include <sdktools_sound>

#pragma semicolon 1

new String:game_mod[32];
new g_WarningTimeStart;
new Handle:g_Cvar_WarningTime  = INVALID_HANDLE;
new Handle:g_WarningTimer = INVALID_HANDLE;
new Handle:g_Cvar_WarningSound = INVALID_HANDLE;
new Handle:g_Cvar_CounterSounds = INVALID_HANDLE;
new Handle:g_WarningSound_1 = INVALID_HANDLE;
new Handle:g_WarningSound_2 = INVALID_HANDLE;
new Handle:g_WarningSound_3 = INVALID_HANDLE;
new Handle:g_WarningSound_4 = INVALID_HANDLE;
new Handle:g_WarningSound_5 = INVALID_HANDLE;
new Handle:g_WarningSound_6 = INVALID_HANDLE;
new Handle:g_WarningSound_7 = INVALID_HANDLE;
new Handle:g_WarningSound_8 = INVALID_HANDLE;
new Handle:g_WarningSound_9 = INVALID_HANDLE;
new Handle:g_WarningSound_10 = INVALID_HANDLE;

public OnPluginStart_VoteWarning()
{
	g_Cvar_WarningTime = CreateConVar("sm_mapvote_warningtime", "15.0", "Warning time in seconds.", _, true, 0.0, true, 30.0);
	g_Cvar_CounterSounds = CreateConVar("sm_mapvote_enablewarningcountersounds", "1", "Enable sounds to be played during warning counter", _, true, 0.0, true, 1.0);
	
	GetGameFolderName(game_mod, sizeof(game_mod));
	if (strcmp(game_mod, "tf", false) == 0)
	{
		LogAction(0, -1, "Team Fortress 2 Sound Settings.");
		g_Cvar_WarningSound = CreateConVar("sm_mapvote_sound_warning", "vo/announcer_warning.wav", "Sound file for warning start. (relative to $basedir/sound/)");

		g_WarningSound_1 = CreateConVar("sm_mapvote_warningsound_one", "vo/announcer_ends_1sec.wav", "Sound file for warning counter: one. (relative to $basedir/sound/)");
		g_WarningSound_2 = CreateConVar("sm_mapvote_warningsound_two", "vo/announcer_ends_2sec.wav", "Sound file for warning counter: two. (relative to $basedir/sound/)");
		g_WarningSound_3 = CreateConVar("sm_mapvote_warningsound_three", "vo/announcer_ends_3sec.wav", "Sound file for warning counter: three. (relative to $basedir/sound/)");
		g_WarningSound_4 = CreateConVar("sm_mapvote_warningsound_four", "vo/announcer_ends_4sec.wav", "Sound file for warning counter: four. (relative to $basedir/sound/)");
		g_WarningSound_5 = CreateConVar("sm_mapvote_warningsound_five", "vo/announcer_ends_5sec.wav", "Sound file for warning counter: five. (relative to $basedir/sound/)");
		g_WarningSound_6 = CreateConVar("sm_mapvote_warningsound_six", "vo/announcer_ends_6sec.wav", "Sound file for warning counter: six. (relative to $basedir/sound/)");
		g_WarningSound_7 = CreateConVar("sm_mapvote_warningsound_seven", "vo/announcer_ends_7sec.wav", "Sound file for warning counter: seven. (relative to $basedir/sound/)");
		g_WarningSound_8 = CreateConVar("sm_mapvote_warningsound_eight", "vo/announcer_ends_8sec.wav", "Sound file for warning counter: eight. (relative to $basedir/sound/)");
		g_WarningSound_9 = CreateConVar("sm_mapvote_warningsound_nine", "vo/announcer_ends_9sec.wav", "Sound file for warning counter: nine. (relative to $basedir/sound/)");
		g_WarningSound_10 = CreateConVar("sm_mapvote_warningsound_ten", "", "Sound file for warning counter: ten. (relative to $basedir/sound/)");
	}	
	else
	{
		LogAction(0, -1, "Other Mods Sound Settings.");
		g_Cvar_WarningSound = CreateConVar("sm_mapvote_sound_warning", "sourcemod/mapchooser/cstrike/warning.wav", "Sound file for warning start. (relative to $basedir/sound/)");
		
		g_WarningSound_1 = CreateConVar("sm_mapvote_warningsound_one", "sourcemod/mapchooser/cstrike/one.wav", "Sound file for warning counter: one. (relative to $basedir/sound/)");
		g_WarningSound_2 = CreateConVar("sm_mapvote_warningsound_two", "sourcemod/mapchooser/cstrike/two.wav", "Sound file for warning counter: two. (relative to $basedir/sound/)");
		g_WarningSound_3 = CreateConVar("sm_mapvote_warningsound_three", "sourcemod/mapchooser/cstrike/three.wav", "Sound file for warning counter: three. (relative to $basedir/sound/)");
		g_WarningSound_4 = CreateConVar("sm_mapvote_warningsound_four", "sourcemod/mapchooser/cstrike/four.wav", "Sound file for warning counter: four. (relative to $basedir/sound/)");
		g_WarningSound_5 = CreateConVar("sm_mapvote_warningsound_five", "sourcemod/mapchooser/cstrike/five.wav", "Sound file for warning counter: five. (relative to $basedir/sound/)");
		g_WarningSound_6 = CreateConVar("sm_mapvote_warningsound_six", "sourcemod/mapchooser/cstrike/six.wav", "Sound file for warning counter: six. (relative to $basedir/sound/)");
		g_WarningSound_7 = CreateConVar("sm_mapvote_warningsound_seven", "sourcemod/mapchooser/cstrike/seven.wav", "Sound file for warning counter: seven. (relative to $basedir/sound/)");
		g_WarningSound_8 = CreateConVar("sm_mapvote_warningsound_eight", "sourcemod/mapchooser/cstrike/eight.wav", "Sound file for warning counter: eight. (relative to $basedir/sound/)");
		g_WarningSound_9 = CreateConVar("sm_mapvote_warningsound_nine", "sourcemod/mapchooser/cstrike/nine.wav", "Sound file for warning counter: nine. (relative to $basedir/sound/)");
		g_WarningSound_10 = CreateConVar("sm_mapvote_warningsound_ten", "sourcemod/mapchooser/cstrike/ten.wav", "Sound file for warning counter: ten. (relative to $basedir/sound/)");
	}
}

// LoadWarningSound
public OnConfigsExecuted_VoteWarning()
{
	decl String:sound[255], String:filePath[255];

	GetConVarString(g_Cvar_WarningSound, sound, sizeof(sound));
	if (strlen(sound) > 0)
	{
		Format(filePath, sizeof(filePath), "sound/%s", sound);
		AddFileToDownloadsTable(filePath);
		PrecacheSound(sound, true);

		if (!FileExists(filePath))
			LogError("sound file %s does not exist.", sound);
		else if (!IsSoundPrecached(filePath))
			LogError("failed to precache sound file %s", sound);
	}
	
	GetConVarString(g_WarningSound_1, sound, sizeof(sound));
	if (strlen(sound) > 0)
	{
		Format(filePath, sizeof(filePath), "sound/%s", sound);
		AddFileToDownloadsTable(filePath);
		PrecacheSound(sound, true);

		if (!FileExists(filePath))
			LogError("sound file %s does not exist.", sound);
		else if (!IsSoundPrecached(filePath))
			LogError("failed to precache sound file %s", sound);
	}

	GetConVarString(g_WarningSound_2, sound, sizeof(sound));
	if (strlen(sound) > 0)
	{
		Format(filePath, sizeof(filePath), "sound/%s", sound);
		AddFileToDownloadsTable(filePath);
		PrecacheSound(sound, true);

		if (!FileExists(filePath))
			LogError("sound file %s does not exist.", sound);
		else if (!IsSoundPrecached(filePath))
			LogError("failed to precache sound file %s", sound);
	}

	GetConVarString(g_WarningSound_3, sound, sizeof(sound));
	if (strlen(sound) > 0)
	{
		Format(filePath, sizeof(filePath), "sound/%s", sound);
		AddFileToDownloadsTable(filePath);
		PrecacheSound(sound, true);

		if (!FileExists(filePath))
			LogError("sound file %s does not exist.", sound);
		else if (!IsSoundPrecached(filePath))
			LogError("failed to precache sound file %s", sound);
	}

	GetConVarString(g_WarningSound_4, sound, sizeof(sound));
	if (strlen(sound) > 0)
	{
		Format(filePath, sizeof(filePath), "sound/%s", sound);
		AddFileToDownloadsTable(filePath);
		PrecacheSound(sound, true);

		if (!FileExists(filePath))
			LogError("sound file %s does not exist.", sound);
		else if (!IsSoundPrecached(filePath))
			LogError("failed to precache sound file %s", sound);
	}

	GetConVarString(g_WarningSound_5, sound, sizeof(sound));
	if (strlen(sound) > 0)
	{
		Format(filePath, sizeof(filePath), "sound/%s", sound);
		AddFileToDownloadsTable(filePath);
		PrecacheSound(sound, true);

		if (!FileExists(filePath))
			LogError("sound file %s does not exist.", sound);
		else if (!IsSoundPrecached(filePath))
			LogError("failed to precache sound file %s", sound);
	}

	GetConVarString(g_WarningSound_6, sound, sizeof(sound));
	if (strlen(sound) > 0)
	{
		Format(filePath, sizeof(filePath), "sound/%s", sound);
		AddFileToDownloadsTable(filePath);
		PrecacheSound(sound, true);

		if (!FileExists(filePath))
			LogError("sound file %s does not exist.", sound);
		else if (!IsSoundPrecached(filePath))
			LogError("failed to precache sound file %s", sound);
	}

	GetConVarString(g_WarningSound_7, sound, sizeof(sound));
	if (strlen(sound) > 0)
	{
		Format(filePath, sizeof(filePath), "sound/%s", sound);
		AddFileToDownloadsTable(filePath);
		PrecacheSound(sound, true);

		if (!FileExists(filePath))
			LogError("sound file %s does not exist.", sound);
		else if (!IsSoundPrecached(filePath))
			LogError("failed to precache sound file %s", sound);
	}

	GetConVarString(g_WarningSound_8, sound, sizeof(sound));
	if (strlen(sound) > 0)
	{
		Format(filePath, sizeof(filePath), "sound/%s", sound);
		AddFileToDownloadsTable(filePath);
		PrecacheSound(sound, true);

		if (!FileExists(filePath))
			LogError("sound file %s does not exist.", sound);
		else if (!IsSoundPrecached(filePath))
			LogError("failed to precache sound file %s", sound);
	}

	GetConVarString(g_WarningSound_9, sound, sizeof(sound));
	if (strlen(sound) > 0)
	{
		Format(filePath, sizeof(filePath), "sound/%s", sound);
		AddFileToDownloadsTable(filePath);
		PrecacheSound(sound, true);

		if (!FileExists(filePath))
			LogError("sound file %s does not exist.", sound);
		else if (!IsSoundPrecached(filePath))
			LogError("failed to precache sound file %s", sound);
	}

	GetConVarString(g_WarningSound_10, sound, sizeof(sound));
	if (strlen(sound) > 0)
	{
		Format(filePath, sizeof(filePath), "sound/%s", sound);
		AddFileToDownloadsTable(filePath);
		PrecacheSound(sound, true);

		if (!FileExists(filePath))
			LogError("sound file %s does not exist.", sound);
		else if (!IsSoundPrecached(filePath))
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
	g_WarningTimer = CreateTimer(1.0, WarningHintMsg, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	
	SoundVoteWarning();
}

public Action:WarningHintMsg(Handle:timer)
{
	decl String:hintboxText[512];
	Format(hintboxText, sizeof(hintboxText), "UWAGA!!! Głosowanie rozpocznie się za: %i sekund", WarningCountdown());
	PrintHintTextToAll(hintboxText);

	if (GetConVarInt(g_Cvar_CounterSounds))
	{
		CountdownSounds();
	}
	
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
		return WarningTime + 1;
	}
}

CountdownSounds()
{
	decl String:sound[255];
	switch(WarningCountdown())
	{
		case 0:
			return;
		case 1:
		{
			GetConVarString(g_WarningSound_1, sound, sizeof(sound));	
			if (strlen(sound) > 0)
			{
				EmitSoundToAll(sound);
			}
		}
		case 2:
		{
			GetConVarString(g_WarningSound_2, sound, sizeof(sound));	
			if (strlen(sound) > 0)
			{
				EmitSoundToAll(sound);
			}
		}
		case 3:
		{
			GetConVarString(g_WarningSound_3, sound, sizeof(sound));	
			if (strlen(sound) > 0)
			{
				EmitSoundToAll(sound);
			}
		}	
		case 4:
		{
			GetConVarString(g_WarningSound_4, sound, sizeof(sound));	
			if (strlen(sound) > 0)
			{
				EmitSoundToAll(sound);
			}
		}	
		case 5:
		{
			GetConVarString(g_WarningSound_5, sound, sizeof(sound));	
			if (strlen(sound) > 0)
			{
				EmitSoundToAll(sound);
			}
		}
		case 6:
		{
			GetConVarString(g_WarningSound_6, sound, sizeof(sound));	
			if (strlen(sound) > 0)
			{
				EmitSoundToAll(sound);
			}
		}
		case 7:
		{
			GetConVarString(g_WarningSound_7, sound, sizeof(sound));	
			if (strlen(sound) > 0)
			{
				EmitSoundToAll(sound);
			}
		}
		case 8:
		{
			GetConVarString(g_WarningSound_8, sound, sizeof(sound));	
			if (strlen(sound) > 0)
			{
				EmitSoundToAll(sound);
			}
		}
		case 9:
		{
			GetConVarString(g_WarningSound_9, sound, sizeof(sound));	
			if (strlen(sound) > 0)
			{
				EmitSoundToAll(sound);
			}
		}
		case 10:
		{
			GetConVarString(g_WarningSound_10, sound, sizeof(sound));	
			if (strlen(sound) > 0)
			{
				EmitSoundToAll(sound);
			}
		}
	}
}