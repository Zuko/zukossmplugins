/////////////////////////////////////////////////////////////////////
//
// RMF�p�C���N���[�h�t�@�C��
//
/////////////////////////////////////////////////////////////////////
#if defined _tf2_events_included
#endinput
#endif
#define _tf2_events_included

/////////////////////////////////////////////////////////////////////
//
// �C���N���[�h
//
/////////////////////////////////////////////////////////////////////
#include "rmf/tf2_codes"

/////////////////////////////////////////////////////////////////////
//
// �萔
//
/////////////////////////////////////////////////////////////////////
#define EVENT_PLAYER_CONNECT		"player_activate"				// �v���C���[�ڑ�
#define EVENT_PLAYER_DISCONNECT		"player_disconnect"				// �v���C���[�ؒf
#define EVENT_PLAYER_DATA_RESET		"PlayerDataReset"				// �v���C���[�f�[�^���Z�b�g
#define EVENT_PLAYER_CHANGE_TEAM	"player_team"					// �v���C���[�`�[���ύX
#define EVENT_PLAYER_CHANGE_CLASS	"player_changeclass"			// �v���C���[�N���X�ύX
#define EVENT_PLAYER_DAMAGE			"player_hurt"					// �v���C���[�_���[�W
#define EVENT_PLAYER_SPAWN			"player_spawn"					// �v���C���[����
#define EVENT_PLAYER_SPAWN_DELAY	"PlayerSpawnDelay"				// �v���C���[����
#define EVENT_PLAYER_DEATH			"player_death"					// �v���C���[���S
#define EVENT_PLAYER_BUILT_OBJECT	"player_builtobject"			// �v���C���[�I�u�W�F�N�g����
#define EVENT_PLAYER_REMOVE_OBJECT	"object_removed"				// �v���C���[�I�u�W�F�N�g�j��(������)
#define EVENT_PLAYER_RESUPPLY		"Player_Resupply"				// �v���C���[���T�v���C
#define EVENT_PLAYER_STUNNED		"player_stunned"				// �v���C���[�X�^��

#define EVENT_OBJECT_DESTROYED		"object_destroyed"				// ���ݕ��j��
#define EVENT_CP_START_TOUCH		"controlpoint_starttouch"		// CP�^�b�`�J�n
#define EVENT_CP_END_TOUCH			"controlpoint_endtouch"			// CP�^�b�`�I��
#define EVENT_GAME_OVER				"tf_game_over"					// �Q�[���I��
#define EVENT_GAME_END				"teamplay_game_over"			// �Q�[���I��
#define EVENT_ROUND_START			"teamplay_round_start"			// ���E���h�J�n
#define EVENT_ROUND_ACTIVE			"teamplay_round_active"			// ���E���h�A�N�e�B�u
#define EVENT_ARENA_ROUND_ACTIVE	"arena_round_start"				// �A���[�i���E���h�A�N�e�B�u
#define EVENT_ROUND_WIN				"teamplay_round_win"			// ���E���h�I��
#define EVENT_WIN_PANEL				"teamplay_win_panel"			// �����X�R�A�{�[�h
#define EVENT_ARENA_WIN_PANEL		"arena_win_panel"				// �A���[�iWin�p�l��
#define EVENT_SUDDEN_DEATH_START	"teamplay_round_stalemate"		// �T�h���f�X�J�n
#define EVENT_WAIT_BEGIN			"teamplay_waiting_begins"		// �v���C���[��҂��Ă��܂��J�n
#define EVENT_WAIT_ABOUTTOEND		"teamplay_waiting_abouttoend"	// �v���C���[��҂��Ă��܂��I�����O
#define EVENT_WAIT_END				"teamplay_waiting_ends"			// �v���C���[��҂��Ă��܂��I��

#define EVENT_PLUGIN_START			"OnPluginStart"				// �v���O�C���J�n
#define EVENT_PLUGIN_INIT			"InitPluginData"			// �v���O�C��������
#define EVENT_PLUGIN_FINAL			"FinalPluginData"			// �v���O�C����n��
#define EVENT_PLUGIN_STATE_CHANGED	"PluginStateChanged"		// �v���O�C���̏�ԕω�
#define EVENT_GAME_FRAME			"OnGameFrame"				// �Q�[���t���[��
#define EVENT_MAP_START				"OnMapStart"				// �}�b�v�J�n
#define EVENT_CONFIG_EXECUTED		"OnConfigsExecuted"			// �S�Ẵ��[�h����
#define EVENT_MAP_END				"OnMapEnd"					// �}�b�v�I��

#define HintTextPages 4									// HintText�̃y�[�W��
#define HintTextMaxSize 256								// HintTex�ő�T�C�Y
#define HintTextInterval 8.0							// HintTex�y�[�W�ύX�C���^�[�o��

#define AbilityNameMaxSize 64							// �A�r���e�B���ő�T�C�Y

/////////////////////////////////////////////////////////////////////
//
// �O���[�o���ϐ�(�����܂��)
//
/////////////////////////////////////////////////////////////////////
new bool:g_IsRunning = true;
new Handle:g_IsPluginOn = INVALID_HANDLE;
//new Float:g_LastTime[MAXPLAYERS+1] = 0.0;			// �Ō�̃`�F�b�N����
new Float:g_LastKeyCheckTime[MAXPLAYERS+1] = 0.0;			// �Ō�̃`�F�b�N����

new String:g_PlayerHintText[MAXPLAYERS+1][HintTextPages][HintTextMaxSize];	// HintText�p
new Handle:g_HintTextTimer[MAXPLAYERS+1] = INVALID_HANDLE;	// �q���g�e�L�X�g�p�^�C�}�[
new g_PlayerHintPage[MAXPLAYERS+1] = 0;
new bool:g_PlayerReadyFeignDeath[MAXPLAYERS+1] = false;
new Handle:g_SpawnDelayTimer[MAXPLAYERS+1] = INVALID_HANDLE;	// �����f�B���C�^�C�}�[

new Handle:g_ResupplyTimer[MAXPLAYERS+1] = INVALID_HANDLE;	// ���T�v���C�^�C�}�[

new bool:g_AbilityUnlock[MAXPLAYERS+1] = true;		// �A�r���e�B���b�N
new String:g_AbilityName[AbilityNameMaxSize];		// �A�r���e�B��


/////////////////////////////////////////////////////////////////////
//
// �A�r���e�B��ON
//
/////////////////////////////////////////////////////////////////////
public Action:Command_AbilityStateChange(args)
{
	if(args < 3)
	{
		//ReplyToCommand(0, "Usage: rmf_ability <client> <ability name> <state(0/1)>");
		return Plugin_Handled;
	}

	new String:client_id[4];
	GetCmdArg(1, client_id, sizeof(client_id));
	new String:ability[AbilityNameMaxSize];
	GetCmdArg(2, ability, sizeof(ability));
	new String:var[2];
	GetCmdArg(3, var, sizeof(var));

	new client = StringToInt(client_id);
	if(client > 0 && IsClientInGame(client) && StrEqual(ability, g_AbilityName))
	{
		if(StringToInt(var) == 0)
		{
			g_AbilityUnlock[client] = false;
			PlayerDataReset( client );
			//PrintToChat(client, "%s:Reset", g_AbilityName);
		}
		else
		{
			g_AbilityUnlock[client] = true;
			PlayerDataReset(client);
			ClearTimer( g_SpawnDelayTimer[ client ] );
			g_SpawnDelayTimer[ client ] = CreateTimer(0.5, Timer_PlayerSpawnDelay, client);
		}
	}
	return Plugin_Handled;
}

/////////////////////////////////////////////////////////////////////
//
// MOD��On/Off��̋���
//
/////////////////////////////////////////////////////////////////////
public PluginStateChanged()
{
	if ( g_IsRunning  )
	{
		// �v���O�C���f�[�^������
		InitializePluginData()
	}
	else
	{
		// �v���O�C���f�[�^��n��
		FinalizePluginData()
	}
	
	Event_FiredUser(INVALID_HANDLE, EVENT_PLUGIN_STATE_CHANGED);
//	PluginStateChangedUser();
}

/////////////////////////////////////////////////////////////////////
//
// �v���O�C���J�n
//
/////////////////////////////////////////////////////////////////////
public OnPluginStart()
{
	// ����t�@�C���Ǎ�
	LoadTranslations("common.phrases");
	
	// �C�x���g�t�b�N
	HookEvent(EVENT_PLAYER_CONNECT,			Event_Fired);
	HookEvent(EVENT_PLAYER_DISCONNECT,		Event_Fired,			EventHookMode_Pre);
	HookEvent(EVENT_PLAYER_CHANGE_TEAM,		Event_Fired);
	HookEvent(EVENT_PLAYER_CHANGE_CLASS,	Event_Fired);
	HookEvent(EVENT_PLAYER_DAMAGE,			Event_Fired);
	HookEvent(EVENT_PLAYER_SPAWN,			Event_Fired,			EventHookMode_Pre);
	HookEvent(EVENT_PLAYER_DEATH,			Event_Fired,			EventHookMode_Pre);
	HookEvent(EVENT_PLAYER_BUILT_OBJECT,	Event_Fired);
	HookEvent(EVENT_PLAYER_REMOVE_OBJECT,	Event_Fired);
	HookEvent(EVENT_PLAYER_STUNNED,			Event_Fired);

	HookEvent(EVENT_OBJECT_DESTROYED,		Event_Fired);
	HookEvent(EVENT_CP_START_TOUCH,			Event_Fired);
	HookEvent(EVENT_CP_END_TOUCH,			Event_Fired);
	HookEvent(EVENT_GAME_OVER,				Event_Fired);
	HookEvent(EVENT_GAME_END,				Event_Fired);
	HookEvent(EVENT_ROUND_START,			Event_Fired);
	HookEvent(EVENT_ROUND_ACTIVE,			Event_Fired);
	HookEvent(EVENT_ARENA_ROUND_ACTIVE,		Event_Fired);
	HookEvent(EVENT_ROUND_WIN,				Event_Fired);
	HookEvent(EVENT_WIN_PANEL,				Event_Fired);
	HookEvent(EVENT_ARENA_WIN_PANEL,		Event_Fired);
	HookEvent(EVENT_SUDDEN_DEATH_START,		Event_Fired);
	HookEvent(EVENT_WAIT_BEGIN,				Event_Fired);
	HookEvent(EVENT_WAIT_ABOUTTOEND,		Event_Fired);
	HookEvent(EVENT_WAIT_END,				Event_Fired);

	Event_FiredUser(INVALID_HANDLE,			EVENT_PLUGIN_START);

	// �A�r���e�B�R�}���h�ݒ�
	RegServerCmd("rmf_ability", Command_AbilityStateChange, "Usage: rmf_ability <client> <ability name> <state(0/1)>");

		
	// �v���O�C���̃t�@�C�����擾
	GetPluginFilename(INVALID_HANDLE, g_AbilityName, sizeof(g_AbilityName));
	ReplaceString(g_AbilityName, sizeof(g_AbilityName), ".smx", "");

	// �T�E���h�t�b�N(���b�J�[) 
	AddNormalSoundHook( HookResupplySound );		

	// �e�v���O�C���̏���
//	OnPluginStartUser()
	
	// �v���O�C���f�[�^������
	InitializePluginData();
	
	// �Q�[���R���t�B�O������
	InitGameConf();
}

/////////////////////////////////////////////////////////////////////
//
// �v���O�C���I��
//
/////////////////////////////////////////////////////////////////////
public OnPluginEnd()
{
	// �v���O�C���f�[�^�㏈��
	FinalizePluginData();
	
	// �A�C�e���f�[�^�㏈��
	FinalItemData();
}

/////////////////////////////////////////////////////////////////////
//
// ������
//
/////////////////////////////////////////////////////////////////////
public InitializePluginData()
{

	new maxclients = GetMaxClients();
	for (new client = 1; client <= maxclients; client++)
	{
		// �v���C���[�f�[�^���Z�b�g
		PlayerDataReset( client );
		
		// �Ƃ肠�������b�N
		g_AbilityUnlock[client] = true;
	}
	
	// �e�v���O�C���̏���
	Event_FiredUser(INVALID_HANDLE, EVENT_PLUGIN_INIT);

//	InitPluginDataUser();
}

/////////////////////////////////////////////////////////////////////
//
// ��n��
//
/////////////////////////////////////////////////////////////////////
public FinalizePluginData()
{
	new maxclients = GetMaxClients();
	for (new client = 1; client <= maxclients; client++)
	{
		// �v���C���[�f�[�^���Z�b�g
		PlayerDataReset( client );
		
		// ���b�N
		//g_AbilityUnlock[client] = false;
	}
	
	Event_FiredUser(INVALID_HANDLE, EVENT_PLUGIN_FINAL);

	// �e�v���O�C���̏���
//	InitPluginDataUser();
}

/////////////////////////////////////////////////////////////////////
//
// �C�x���g����
//
/////////////////////////////////////////////////////////////////////
public Action:Event_Fired(Handle:event, const String:name[], bool:dontBroadcast)
{
	// MOD��ON�̎�����
	if( !g_IsRunning )
		return Plugin_Continue;	
	
	
	if( StrEqual(name, EVENT_PLAYER_SPAWN)
		|| StrEqual(name, EVENT_PLAYER_CHANGE_CLASS)
		|| StrEqual(name, EVENT_PLAYER_DEATH)
		|| StrEqual(name, EVENT_PLAYER_DAMAGE)
		|| StrEqual(name, EVENT_PLAYER_CHANGE_TEAM)
		|| StrEqual(name, EVENT_PLAYER_CONNECT)
		|| StrEqual(name, EVENT_PLAYER_DISCONNECT)
		|| StrEqual(name, EVENT_PLAYER_BUILT_OBJECT)
		|| StrEqual(name, EVENT_PLAYER_REMOVE_OBJECT)
		|| StrEqual(name, EVENT_OBJECT_DESTROYED)
		|| StrEqual(name, EVENT_PLAYER_STUNNED))
	{
		new client;
		
		if( StrEqual(name, EVENT_PLAYER_STUNNED) )
		{
			client = GetClientOfUserId(GetEventInt(event, "victim"));
			if( client <= 0 && !StrEqual(name, EVENT_PLAYER_DISCONNECT) )
				return Plugin_Continue;	
		}
		else
		{
			client = GetClientOfUserId(GetEventInt(event, "userid"));
			if( client <= 0 && !StrEqual(name, EVENT_PLAYER_DISCONNECT) )
				return Plugin_Continue;	
		}

		// �f�b�h�����K�[�p
		if(StrEqual(name, EVENT_PLAYER_DAMAGE))
		{
			if(TF2_IsReadyFeignDeath(client))
			{
				g_PlayerReadyFeignDeath[client] = true;
			}
		}
		
		new Action:result = Event_FiredUser(event, name, client);
 
		if(StrEqual(name, EVENT_PLAYER_SPAWN)
			|| StrEqual(name, EVENT_PLAYER_DEATH)
			|| StrEqual(name, EVENT_PLAYER_SPAWN)
			|| StrEqual(name, EVENT_PLAYER_CHANGE_TEAM))
		{
			if(!g_PlayerReadyFeignDeath[client])
			{
				// �v���C���[�f�[�^���Z�b�g
				PlayerDataReset( client );
			}
			else
			{
				g_PlayerReadyFeignDeath[client] = false;
			}
		}
		
		if(StrEqual(name, EVENT_PLAYER_SPAWN))
		{
			// �f�B���C
			ClearTimer( g_SpawnDelayTimer[ client ] );
			g_SpawnDelayTimer[ client ] = CreateTimer(0.15, Timer_PlayerSpawnDelay, client);
		}
		
		
		if(StrEqual(name, EVENT_PLAYER_DISCONNECT))
		{
			// �v���C���[�f�[�^���Z�b�g
			PlayerDataReset( client );
		}
		
		return result;
	}
	// ���E���h�J�n
	else if( StrEqual(name, EVENT_ROUND_START) )
	{
		new maxclients = GetMaxClients();
		for (new client = 1; client <= maxclients; client++)
		{
			// �v���C���[�f�[�^���Z�b�g
			PlayerDataReset( client );
		}
	}
	
	return Event_FiredUser(event, name);
}

/////////////////////////////////////////////////////////////////////
//
// �}�b�v�J�n
//
/////////////////////////////////////////////////////////////////////
public OnMapStart()
{
	// �v���O�C���f�[�^������
	InitItemData();
	
	new Handle:cvar = FindConVar("sm_rmf_tf_ability_menu");
	if( cvar == INVALID_HANDLE )
	{
		new maxclients = GetMaxClients();
		for (new client = 1; client <= maxclients; client++)
		{
			// ���b�N����
			g_AbilityUnlock[client] = true;
		}		
	}
	
	Event_FiredUser(INVALID_HANDLE, EVENT_MAP_START);

	// �e�v���O�C���̏���
	//OnMapStartUser();
}
/////////////////////////////////////////////////////////////////////
//
// �S�Ẵ��[�h�I��
//
/////////////////////////////////////////////////////////////////////
public OnConfigsExecuted()
{
	
	Event_FiredUser(INVALID_HANDLE, EVENT_CONFIG_EXECUTED);

	// �e�v���O�C���̏���
	//OnConfigsExecutedUser();
}

/////////////////////////////////////////////////////////////////////
//
// �}�b�v�I��
//
/////////////////////////////////////////////////////////////////////
public OnMapEnd()
{
	// �v���O�C���f�[�^������
//	InitPluginData();

	Event_FiredUser(INVALID_HANDLE, EVENT_MAP_END);

	// �e�v���O�C���̏���
	//OnMapEndUser();
}

/////////////////////////////////////////////////////////////////////
//
// �Q�[���t���[��
//
/////////////////////////////////////////////////////////////////////
public OnGameFrame()
{
	// MOD��ON�̎�����
	if( !g_IsRunning )
		return;	

	Event_FiredUser(INVALID_HANDLE, EVENT_GAME_FRAME);
	// �e�v���O�C���̏���
//	OnGameFrameUser();

}

/////////////////////////////////////////////////////////////////////
//
// �v���C���[�f�[�^���Z�b�g
//
/////////////////////////////////////////////////////////////////////
public PlayerDataReset( any:client )
{
    if ( client > 0  )
	{
		// �Q�[���ɓ����Ă���
		if( IsClientInGame(client) )
		{		
			// HintText������
			for(new i = 0; i < HintTextPages; i++)
			{
				Format(g_PlayerHintText[client][i], HintTextMaxSize , "");
			}
			g_PlayerHintPage[client] = 0;
			
			// �^�C�}�[�N���A
			ClearTimer(g_HintTextTimer[client]);
			ClearTimer(g_SpawnDelayTimer[client]);
			ClearTimer(g_ResupplyTimer[client]);
			
			// �L�[���͂������Ԃ�ۑ�
			SaveKeyTime(client);
			
			// �v���C���[�̌���ݒ�H
			//SetGlobalTransTarget(GetServerLanguage());

			Event_FiredUser(INVALID_HANDLE, EVENT_PLAYER_DATA_RESET, client);
//			PlayerDataResetUser( client );
		}

	}
}

/////////////////////////////////////////////////////////////////////
//
// �v���C���[�����f�B���C
//
/////////////////////////////////////////////////////////////////////
public Action:Timer_PlayerSpawnDelay(Handle:timer, any:client)
{
	g_SpawnDelayTimer[ client ] = INVALID_HANDLE;
	
	// �e�v���O�C���̏���
	Event_FiredUser(INVALID_HANDLE, EVENT_PLAYER_SPAWN_DELAY, client);
	
	new String:cmd[64];
	StringToLower(cmd, g_AbilityName);
	Format(cmd, sizeof(cmd), "sm_rmf_%s_class", cmd);
	new Handle:cvar = FindConVar(cmd);
	if( IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient( client ) && (g_AbilityUnlock[client] || !cvar))
	{
		g_PlayerHintPage[client] = 0;
		if(!StrEqual(g_PlayerHintText[client][g_PlayerHintPage[client]], ""))
		{
			PrintHintText(client, "%s", g_PlayerHintText[client][g_PlayerHintPage[client]]);
			g_PlayerHintPage[client] += 1;
			if(g_PlayerHintPage[client] < HintTextPages)
			{
				ClearTimer( g_HintTextTimer[ client ] );
				//PrintToChat(client, "%s", g_PlayerHintText[client][g_PlayerHintPage[client]]);
				g_HintTextTimer[client] = CreateTimer(HintTextInterval, Timer_ShowHintText, client);
			}
		}
	}
//	Timer_PlayerSpawnDelayUser(Handle:timer, any:client);

}


/////////////////////////////////////////////////////////////////////
//
// ���T�v���C�G���A��IN
//
/////////////////////////////////////////////////////////////////////
public Action:HookResupplySound( clients[64], &numClients, String:sample[PLATFORM_MAX_PATH], &entity, &channel, &Float:volume, &level, &pitch, &flags)
{
    if( !StrEqual( sample, "items/regenerate.wav", true ) )
	{
		return Plugin_Continue;
	}
	
	// ���b�J�[����Ȃ��Ȃ甲����
	new String:name[64];
	GetEdictClassname( entity, name, 64 );
	if( !StrEqual( name,  "player" ) )
	{
		return Plugin_Continue;
	}

	// �C�x���g����
	for( new i = 0; i < numClients + 1; i++ )
	{
		if( i == entity && i != 0 )
		{
			// ������ƒx��
			ClearTimer( g_ResupplyTimer[ i ] );
			g_ResupplyTimer[ i ] = CreateTimer( 0.1, Timer_Resupply, i );
			
		}
	}
	
	return Plugin_Continue;
}

/////////////////////////////////////////////////////////////////////
//
// ���T�v���C�C�x���g����
//
/////////////////////////////////////////////////////////////////////
public Action:Timer_Resupply(Handle:timer, any:client)
{
	g_ResupplyTimer[ client ] = INVALID_HANDLE;
	
	if( IsClientInGame( client ) && IsPlayerAlive( client) )
	{
		// �e�v���O�C���̏���
		Event_FiredUser( INVALID_HANDLE, EVENT_PLAYER_RESUPPLY, client );
	}
}

/////////////////////////////////////////////////////////////////////
//
// ��ڈȍ~�̐����^�C�}�[
//
/////////////////////////////////////////////////////////////////////
public Action:Timer_ShowHintText(Handle:timer, any:client)
{
	g_HintTextTimer[client] = INVALID_HANDLE;
	if(IsClientInGame(client) && IsPlayerAlive(client) && g_PlayerHintPage[client] < HintTextPages)
	{
		if(!StrEqual(g_PlayerHintText[client][g_PlayerHintPage[client]], ""))
		{
			PrintHintText(client, "%s", g_PlayerHintText[client][g_PlayerHintPage[client]]);
			g_PlayerHintPage[client] += 1;
			if(g_PlayerHintPage[client] < HintTextPages)
			{
				ClearTimer( g_HintTextTimer[ client ] );
				//PrintToChat(client, "%s", g_PlayerHintText[client][g_PlayerHintPage[client]]);
				g_HintTextTimer[client] = CreateTimer(HintTextInterval, Timer_ShowHintText, client);
				
			}
		}
	}
}


/////////////////////////////////////////////////////////////////////
//
// �L�[���͎��ԕۑ�
//
/////////////////////////////////////////////////////////////////////
stock SaveKeyTime(any:client)
{
	if( IsClientInGame(client) )
	{		
		g_LastKeyCheckTime[client] = GetGameTime();
	}
}

/////////////////////////////////////////////////////////////////////
//
// �L�[���͉\���`�F�b�N
//
/////////////////////////////////////////////////////////////////////
stock bool:CheckElapsedTime(any:client, Float:time)
{
	if( IsClientInGame(client) )
	{	
		if( GetGameTime() - g_LastKeyCheckTime[client] >= time)
		{
			return true;
		}
	}
	return false;
}



/////////////////////////////////////////////////////////////////////
//
// MOD��On/Off�ύX
//
/////////////////////////////////////////////////////////////////////
public ConVarChange_IsPluginOn(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if (StringToInt(newValue) > 0)
	{
		g_IsRunning = true
	}
	else
	{
		g_IsRunning = false;
	}
	PluginStateChanged();
}


/////////////////////////////////////////////////////////////////////
//
// �u�[���l
//
/////////////////////////////////////////////////////////////////////
public ConVarChange_Bool(Handle:convar, const String:oldValue[], const String:newValue[])
{
	// 0��1
	if (StringToInt(newValue) != 0 && StringToInt(newValue) != 1)
	{
		SetConVarInt(convar, StringToInt(oldValue), false, false);
		PrintToServer("Warning: Value has to be 0 or 1");
	}
}

/////////////////////////////////////////////////////////////////////
//
// �{��
//
/////////////////////////////////////////////////////////////////////
public ConVarChange_Magnification(Handle:convar, const String:oldValue[], const String:newValue[])
{
	// 0.1�`10.0�܂�
	if (StringToFloat(newValue) < 0.0 || StringToFloat(newValue) > 10.0)
	{
		SetConVarFloat(convar, StringToFloat(oldValue), false, false);
		PrintToServer("Warning: Value has to be between 0.0 and 10.0");
	}
}

/////////////////////////////////////////////////////////////////////
//
// ���a(���[�g��)
//
/////////////////////////////////////////////////////////////////////
public ConVarChange_Radius(Handle:convar, const String:oldValue[], const String:newValue[])
{
	// 0.0�`100.0�܂�
	if (StringToFloat(newValue) < 0.0 || StringToFloat(newValue) > 100.0)
	{
		SetConVarFloat(convar, StringToFloat(oldValue), false, false);
		PrintToServer("Warning: Value has to be between 0.0 and 100.0");
	}
}

/////////////////////////////////////////////////////////////////////
//
// ����
//
/////////////////////////////////////////////////////////////////////
public ConVarChange_Time(Handle:convar, const String:oldValue[], const String:newValue[])
{
	// 0.0�`120.0�܂�
	if (StringToFloat(newValue) < 0.0 || StringToFloat(newValue) > 120.0)
	{
		SetConVarFloat(convar, StringToFloat(oldValue), false, false);
		PrintToServer("Warning: Value has to be between 0.0 and 120.0");
	}
}

/////////////////////////////////////////////////////////////////////
//
// �e��
//
/////////////////////////////////////////////////////////////////////
public ConVarChange_Ammo(Handle:convar, const String:oldValue[], const String:newValue[])
{
	// 0�`200�܂�
	if (StringToInt(newValue) < 0 || StringToInt(newValue) > 200)
	{
		SetConVarInt(convar, StringToInt(oldValue), false, false);
		PrintToServer("Warning: Value has to be between 0 and 200");
	}
}

/////////////////////////////////////////////////////////////////////
//
// ���[�o�[
//
/////////////////////////////////////////////////////////////////////
public ConVarChange_Uber(Handle:convar, const String:oldValue[], const String:newValue[])
{
	// 0�`100�܂�
	if (StringToInt(newValue) < 0 || StringToInt(newValue) > 100)
	{
		SetConVarInt(convar, StringToInt(oldValue), false, false);
		PrintToServer("Warning: Value has to be between 0 and 100");
	}
}
/////////////////////////////////////////////////////////////////////
//
// �_���[�W
//
/////////////////////////////////////////////////////////////////////
public ConVarChange_Damage(Handle:convar, const String:oldValue[], const String:newValue[])
{
	// 0�`1000�܂�
	if (StringToInt(newValue) < 0 || StringToInt(newValue) > 1000)
	{
		SetConVarInt(convar, StringToInt(oldValue), false, false);
		PrintToServer("Warning: Value has to be between 0 and 1000");
	}
}

/////////////////////////////////////////////////////////////////////
//
// �w���X
//
/////////////////////////////////////////////////////////////////////
public ConVarChange_Health(Handle:convar, const String:oldValue[], const String:newValue[])
{
	// 0�`500�܂�
	if (StringToInt(newValue) < 0 || StringToInt(newValue) > 500)
	{
		SetConVarInt(convar, StringToInt(oldValue), false, false);
		PrintToServer("Warning: Value has to be between 0 and 500");
	}
}