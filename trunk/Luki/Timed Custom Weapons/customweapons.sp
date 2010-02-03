#include <sourcemod>
#define REQUIRE_EXTENSIONS
#include <tf2items>
#include <sdktools>

#define PLUGIN_VERSION "1.0"

public Plugin:myinfo =
{
	name = "Timed Custom Weapons",
	author = "Luki",
	description = "Plugin allows admins to give to a player timed custom weapons",
	version = PLUGIN_VERSION,
	url = "none"
}

public OnPluginStart()
{
	RegAdminCmd("sm_candy_buy_weapon", cBuyWeapon, ADMFLAG_ROOT, "sm_candy_buy_weapon <#userid|name> <weaponID> <time>");
	
	CheckWeapons();
}

public CheckWeapons()
{
	new Handle:kv = CreateKeyValues("custom_weapons_v2");
	new String:Path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, Path, sizeof(Path), "data/customweps.txt");
	FileToKeyValues(kv, Path);
	
	if (!KvGotoFirstSubKey(kv))
	{
		CloseHandle(kv);
		return;
	}
	
	new String:buffer[255];
	new iExpires;
	do
	{
		if (!KvGotoFirstSubKey(kv))
		{
			continue;
		}
		do
		{
			KvGetString(kv, "expires", buffer, sizeof(buffer), "0");
			iExpires = StringToInt(buffer);
			if (iExpires < GetTime() && iExpires != 0)
			{
				KvGetSectionName(kv, buffer, sizeof(buffer));
				KvDeleteThis(kv);
			}
		} while (KvGotoNextKey(kv));
		KvGoBack(kv);
	} while (KvGotoNextKey(kv));
	KvRewind(kv);
	KeyValuesToFile(kv, Path);
	
	CloseHandle(kv);
}

//sm_candy_buy_weapon <#userid|name> <weaponID> <time>
public Action:cBuyWeapon(client, args)
{
	new String:arg1[32], String:arg2[32], String:arg3[32];

	if (args != 3)
	{
		ReplyToCommand(client, "Bad arguments!");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	GetCmdArg(3, arg3, sizeof(arg3));
	
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;
	
	if ((target_count = ProcessTargetString(
				arg1,
				client,
				target_list,
				MAXPLAYERS,
				COMMAND_FILTER_CONNECTED,
				target_name,
				sizeof(target_name),
				tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	new String:Path[PLATFORM_MAX_PATH];
	
	new Handle:kv2 = CreateKeyValues("custom_weapons");
	BuildPath(Path_SM, Path, sizeof(Path), "configs/customweapons.txt");
	FileToKeyValues(kv2, Path);
	
	if (!KvJumpToKey(kv2, arg2))
	{
		ReplyToCommand(client, "Weapon doesn't exists!");
		CloseHandle(kv2);
		CheckWeapons();
		return Plugin_Handled;
	}
	
	new Handle:kv = CreateKeyValues("custom_weapons_v2");
	BuildPath(Path_SM, Path, sizeof(Path), "data/customweps.txt");
	FileToKeyValues(kv, Path);	
	
	new String:steamid[128];

	for (new i = 0; i < target_count; i++)
	{
		PrintToServer("Processing %i", target_list[i]);
		
		GetClientAuthString(target_list[i], steamid, sizeof(steamid));

		KvJumpToKey(kv, steamid, true);
		KvJumpToKey(kv, arg2, true);
	
		KvCopySubkeys(kv2, kv);

		if (StringToInt(arg3) == 0)
		{
			KvSetNum(kv, "expires", 0);
		}
		else
		{
			new iExpires = KvGetNum(kv, "expires");
			if (iExpires < GetTime())
			{
				iExpires = GetTime() + StringToInt(arg3);
				KvSetNum(kv, "expires", iExpires);
			}
			else
			{
				iExpires += StringToInt(arg3);
				KvSetNum(kv, "expires", iExpires);
			}
		}
		
		KvGoBack(kv);
		KvGoBack(kv);
	} 
	
	KeyValuesToFile(kv, Path);
	
	CloseHandle(kv);
	CloseHandle(kv2);
	
	return Plugin_Handled;
}