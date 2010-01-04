/*
 * "Simple" plugin which you can spawn any weapon or special zombie where you are looking also you can give weapon to players.
 *
 * ####
 * Commands:
 * 	-	sm_spawnweapon [weapon_name] or sm_sw [weapon_name] 
 *		(eg. sm_sw weapon_chainsaw)
 *	-	sm_giveweapon <#userid|name> [weapon_name] or sm_gw <#userid|name> [weapon_name] 
 *		(eg. sm_gw @me chainsaw)
 *		Targeting: http://wiki.alliedmods.net/Admin_Commands_%28SourceMod%29#How_to_Target
 *	-	sm_zspawn [special infeted name] 
 *		(eg. sm_zspawn tank)
 *	-	sm_spawnminigun or sm_smg
 *
 * ####
 * Weapon List: 
 * weapon_adrenaline; weapon_autoshotgun; weapon_chainsaw; weapon_defibrillator; weapon_fireworkcrate; 
 * weapon_first_aid_kit; weapon_gascan; weapon_gnome; weapon_grenade_launcher; weapon_hunting_rifle; 
 * weapon_molotov; weapon_oxygentank; weapon_pain_pills; weapon_pipe_bomb; weapon_pistol; 
 * weapon_pistol_magnum; weapon_propanetank; weapon_pumpshotgun; weapon_rifle; weapon_rifle_ak47; 
 * weapon_rifle_desert; weapon_rifle_sg552; weapon_shotgun_chrome; weapon_shotgun_spas; weapon_smg; 
 * weapon_smg_mp5; weapon_smg_silenced; weapon_sniper_awp; weapon_sniper_military; weapon_sniper_scout; 
 * weapon_vomitjar; weapon_ammo_spawn; weapon_upgradepack_explosive; weapon_upgradepack_incendiary;
 *
 * ####
 * Melee Weapons List:
 * baseball_bat; cricket_bat; crowbar; electric_guitar; fireaxe; frying_pan; katana; machete; tonfa;
 *
 * #### 
 * Special Zombie List: 
 * boomer; hunter; smoker; tank; spitter; jockey; charger; zombie; witch
 * *
 * ####
 * Changelog:
 * v0.6
 *	o Added ammo to spawned weapons (yey!)
 *	o Added max ammo cvars
 *	o Automatically adding "weapon_" for sm_sw (eg. sm_sw rifle)
 *	o Added multi-language support
 *	o Added knife to Melee weapons menu (works only when you play with germans)
 *	o Added command to remove minigun
 * v0.5 - Beta
 *	o Added MagineGun spawning
 *	o Added missing witch and vomitjar
 * 	o Minor fixes
 * v0.4
 *	o Menu now use own category on Admin Menu
 *	o Added menu for "Give Weapons"
 *	o Added menu for "Spawn Special Zombie"
 *	o Added Laser Sights, Explosive Ammo, Incendiary Ammo, Health, Ammo Stack
 *	o Rewrite menu "Spawn Weapon"
 *	o Fix for: http://forums.alliedmods.net/showpost.php?p=998601&postcount=33 (now you can use your nick in binds)
 *	o Rename sm_spawn to sm_zspawn
 *	o Code optimizations
 * v0.3a
 *	o Fix for: http://forums.alliedmods.net/showpost.php?p=997445&postcount=21
 * v0.3
 *	o Added Menu (in admin menu - Server Commands)
 *	o Added sm_spawn
 * v0.2
 *	o Added sm_gw
 * v0.1
 *	o Initial Release
 *
 * Zuko / #hlds.pl @ Qnet #sourcemod @ GameSurge / zuko.isports.pl / hlds.pl /
 *
 * ####
 * Credits:
 * pheadxdll for [TF2] Pumpkins code
 * antihacker for [L4D] Spawn Minigun code
 */
 
#include <sourcemod>
#include <sdktools>
#undef REQUIRE_PLUGIN
#include <adminmenu>

#define VERSION "0.6"

/* TopMenu Handle */
new Handle:hAdminMenu = INVALID_HANDLE;

/* ConVar Handle */
new Handle:AssaultMaxAmmo = INVALID_HANDLE;
new Handle:SMGMaxAmmo = INVALID_HANDLE;
new Handle:ShotgunMaxAmmo = INVALID_HANDLE;
new Handle:AutoShotgunMaxAmmo = INVALID_HANDLE;
new Handle:HRMaxAmmo = INVALID_HANDLE;
new Handle:SniperRifleMaxAmmo = INVALID_HANDLE;
new Handle:GrenadeLauncherMaxAmmo = INVALID_HANDLE;

new String:ChoosedWeapon[MAXPLAYERS+1][56]
new String:ChoosedMenuSpawn[MAXPLAYERS+1][56]
new String:ChoosedMenuGive[MAXPLAYERS+1][56]
new Float:g_pos[3];

public Plugin:myinfo = 
{
	name = "[L4D2] Weapon/Zombie Spawner",
	author = "Zuko",
	description = "Spawns weapons/zombies where your looking or give weapon to player.",
	version = VERSION,
	url = "http://zuko.isports.pl"
}

public OnPluginStart()
{
	/* ConVars */
	CreateConVar("sm_weaponspawner_version", VERSION, "Plugin Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);

	/* Admin Commands */
	RegAdminCmd("sm_spawnweapon", Command_SpawnWeapon, ADMFLAG_SLAY, "Spawn weapon where you are looking.");
	RegAdminCmd("sm_sw", Command_SpawnWeapon, ADMFLAG_SLAY, "Spawn weapon where you are looking.");
	RegAdminCmd("sm_giveweapon", Command_GiveWeapon, ADMFLAG_SLAY, "Gives weapon to player.");
	RegAdminCmd("sm_gw", Command_GiveWeapon, ADMFLAG_SLAY, "Gives weapon to player.");
	RegAdminCmd("sm_zspawn", Command_SpawnZombie, ADMFLAG_SLAY, "Spawns special zombie where you are looking.");

	/* Minugun Commands */
	RegAdminCmd("sm_spawnminigun", Command_SpawnMinigun, ADMFLAG_SLAY, "Spawns minigun.");
	RegAdminCmd("sm_smg", Command_SpawnMinigun, ADMFLAG_SLAY, "Spawns minigun.");
	RegAdminCmd("sm_removeminigun", Command_RemoveMinigun, ADMFLAG_SLAY, "Remove minigun.");
	RegAdminCmd("sm_rmg", Command_RemoveMinigun, ADMFLAG_SLAY, "Remove minigun.");

	/* Max Ammo ConVars */
	AssaultMaxAmmo = CreateConVar("sm_spawnweapon_assaultammo", "360", " How much Ammo for AK74, M4A1 and Desert Rifle ", FCVAR_PLUGIN|FCVAR_NOTIFY);
	SMGMaxAmmo = CreateConVar("sm_spawnweapon_smgammo", "650", " How much Ammo for SMG and Silenced SMG ", FCVAR_PLUGIN|FCVAR_NOTIFY);
	ShotgunMaxAmmo = CreateConVar("sm_spawnweapon_shotgunammo", "56", " How much Ammo for Shotgun and Chrome Shotgun ", FCVAR_PLUGIN|FCVAR_NOTIFY);
	AutoShotgunMaxAmmo = CreateConVar("sm_spawnweapon_autoshotgunammo", "90", " How much Ammo for Autoshottie and SPAS ", FCVAR_PLUGIN|FCVAR_NOTIFY);
	HRMaxAmmo = CreateConVar("sm_spawnweapon_huntingrifleammo", "150", " How much Ammo for the Hunting Rifle ", FCVAR_PLUGIN|FCVAR_NOTIFY);
	SniperRifleMaxAmmo = CreateConVar("sm_spawnweapon_sniperrifleammo", "180", " How much Ammo for the Military Sniper Rifle ", FCVAR_PLUGIN|FCVAR_NOTIFY);	
	GrenadeLauncherMaxAmmo = CreateConVar("sm_spawnweapon_grenadelauncherammo", "30", " How much Ammo for the Grenade Launcher ", FCVAR_PLUGIN|FCVAR_NOTIFY);	

	AutoExecConfig(true, "l4d2_weaponspawner");
	
	/*Menu Handler */
	new Handle:topmenu
	if (LibraryExists("adminmenu") && ((topmenu = GetAdminTopMenu()) != INVALID_HANDLE))
	{
		OnAdminMenuReady(topmenu)
	}

	/* Load translations */
	LoadTranslations("common.phrases");
	LoadTranslations("weaponspawner.phrases");
}

/* Spawn Weapon */
public Action:Command_SpawnWeapon(client, args)
{
	decl String:weapon[56];
	decl String:arg1[56];
	decl maxammo;
	
	if (client == 0)
	{
		ReplyToCommand(client, "%t", "Command is in-game only", LANG_SERVER);
		return Plugin_Handled;
	}
	
	if (args != 1)
	{
		ReplyToCommand(client, "%t", "SpawnWeaponUsage", LANG_SERVER);
		return Plugin_Handled;
	}
	else
	{
		GetCmdArg(1, arg1, sizeof(arg1));
		Format(weapon, sizeof(weapon), "weapon_%s", arg1);
	}
	
	if(!SetTeleportEndPoint(client))
	{
		ReplyToCommand(client, "[SM] %t", "SpawnError", LANG_SERVER);
		return Plugin_Handled;
	}
	
	if (StrEqual(weapon, "weapon_rifle", false) || StrEqual(weapon, "weapon_rifle_ak47", false) || StrEqual(weapon, "weapon_rifle_desert", false))
	{
		maxammo = GetConVarInt(AssaultMaxAmmo);
	}
	else if (StrEqual(weapon, "weapon_smg", false) || StrEqual(weapon, "weapon_smg_silenced", false))
	{
		maxammo = GetConVarInt(SMGMaxAmmo);
	}		
	else if (StrEqual(weapon, "weapon_pumpshotgun", false) || StrEqual(weapon, "weapon_shotgun_chrome", false))
	{
		maxammo = GetConVarInt(ShotgunMaxAmmo);
	}
	else if (StrEqual(weapon, "weapon_autoshotgun", false) || StrEqual(weapon, "weapon_shotgun_spas", false))
	{
		maxammo = GetConVarInt(AutoShotgunMaxAmmo);
	}
	else if (StrEqual(weapon, "weapon_hunting_rifle", false))
	{
		maxammo = GetConVarInt(HRMaxAmmo);
	}
	else if (StrEqual(weapon, "weapon_sniper_military", false))
	{
		maxammo = GetConVarInt(SniperRifleMaxAmmo);
	}
	if (StrEqual(weapon, "weapon_grenade_launcher", false))
	{
		maxammo = GetConVarInt(GrenadeLauncherMaxAmmo);
	}
	else
	{
		ReplyToCommand(client, "%t", "WrongWeaponName", LANG_SERVER);
		return Plugin_Handled;
	}
	
	new iWeapon = CreateEntityByName(weapon);
	
	if(IsValidEntity(iWeapon))
	{		
		DispatchSpawn(iWeapon); //Spawn weapon (entity)
		SetEntProp(iWeapon, Prop_Send, "m_iExtraPrimaryAmmo", maxammo ,4); //Adds max ammo for weapon
		g_pos[2] -= 10.0;
		TeleportEntity(iWeapon, g_pos, NULL_VECTOR, NULL_VECTOR); //Teleport spawned weapon
	}
	return Plugin_Handled;
}
/* >>> end of Spawn Weapon */

/* Give Weapon */
public Action:Command_GiveWeapon(client, args)
{
	if (args < 2)
	{
		ReplyToCommand(client, "%t", "GiveWeaponUsage", LANG_SERVER)
		return Plugin_Handled;
	}

	decl String:arg[65];
	GetCmdArg(1, arg, sizeof(arg));

	decl String:weapon[65];
	GetCmdArg(2, weapon, sizeof(weapon));

	decl String:target_name[MAX_TARGET_LENGTH];
	decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;

	if ((target_count = ProcessTargetString(
			arg,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (new i = 0; i < target_count; i++)
	{
		if ((strcmp(weapon, "laser_sight") == 0) || (strcmp(weapon, "explosive_ammo") == 0) || (strcmp(weapon, "incendiary_ammo") == 0))
		{
			new flagsupgrade_add = GetCommandFlags("upgrade_add");
			SetCommandFlags("upgrade_add", flagsupgrade_add & ~FCVAR_CHEAT);
			if (IsClientInGame(target_list[i])) FakeClientCommand(target_list[i], "upgrade_add %s", weapon);
			SetCommandFlags("upgrade_add", flagsupgrade_add|FCVAR_CHEAT);
		}
		else
		{
			new flagsgive = GetCommandFlags("give");
			SetCommandFlags("give", flagsgive & ~FCVAR_CHEAT);
			if (IsClientInGame(target_list[i])) FakeClientCommand(target_list[i], "give %s", weapon);
			SetCommandFlags("give", flagsgive|FCVAR_CHEAT);
		}
	}
	return Plugin_Handled;
}
/* >>> end of Give Weapon */

/* Spawn Zombie */
public Action:Command_SpawnZombie(client, args)
{
	decl String:zombie[56];

	if (client == 0)
	{
		ReplyToCommand(client, "%t", "Command is in-game only", LANG_SERVER);
		return Plugin_Handled;
	}

	if (args != 1)
	{
		ReplyToCommand(client, "%t", "SpawnZombieUsage", LANG_SERVER)
		return Plugin_Handled;
	}
	else
	{
		GetCmdArg(1, zombie, sizeof(zombie));
	}
	if (IsClientConnected(client) && IsClientInGame(client))
	{
		new flags = GetCommandFlags("z_spawn");
		SetCommandFlags("z_spawn", flags & ~FCVAR_CHEAT);
		FakeClientCommand(client, "z_spawn %s", zombie);
		SetCommandFlags("z_spawn", flags|FCVAR_CHEAT);
	}
	return Plugin_Handled;
}
/* >>> end of Spawn Zombie */

/* Minigun */
public Action:Command_SpawnMinigun(client, args)
{
	if( !client )
	{
		ReplyToCommand(client, "%t", "Command is in-game only", LANG_SERVER);
		return Plugin_Handled;	
	}

	SpawnMiniGun(client);
	return Plugin_Handled;
}

public SpawnMiniGun(client)
{
	decl Float:VecOrigin[3], Float:VecAngles[3], Float:VecDirection[3];

	new minigun = CreateEntityByName("prop_minigun");

	if (minigun == -1)
	{
		ReplyToCommand(client, "[SM] %t", "MinigunFailed", LANG_SERVER);
	}

	DispatchKeyValue(minigun, "model", "Minigun_1");
	DispatchKeyValueFloat (minigun, "MaxPitch", 360.00);
	DispatchKeyValueFloat (minigun, "MinPitch", -360.00);
	DispatchKeyValueFloat (minigun, "MaxYaw", 90.00);
	DispatchSpawn(minigun);

	GetClientAbsOrigin(client, VecOrigin);
	GetClientEyeAngles(client, VecAngles);
	GetAngleVectors(VecAngles, VecDirection, NULL_VECTOR, NULL_VECTOR);
	VecOrigin[0] += VecDirection[0] * 32;
	VecOrigin[1] += VecDirection[1] * 32;
	VecOrigin[2] += VecDirection[2] * 1;   
	VecAngles[0] = 0.0;
	VecAngles[2] = 0.0;
	DispatchKeyValueVector(minigun, "Angles", VecAngles);
	DispatchSpawn(minigun);
	TeleportEntity(minigun, VecOrigin, NULL_VECTOR, NULL_VECTOR);
}

public Action:Command_RemoveMinigun(client, args)
{
	if( !client )
	{
		ReplyToCommand(client, "%t", "Command is in-game only", LANG_SERVER);
		return Plugin_Handled;	
	}

	RemoveMiniGun(client);
	return Plugin_Handled;
}

public RemoveMiniGun(client)
{
	decl String:Classname[128];
	new minigun = GetClientAimTarget (client, false);

	if ((minigun == -1) || (!IsValidEntity (minigun)))
	{
		ReplyToCommand (client, "[SM] %t","RemoveMinigunError_01");
	}

	GetEdictClassname(minigun, Classname, sizeof(Classname));
	if(!StrEqual(Classname, "prop_minigun"))
	{
		ReplyToCommand (client, "[SM] %t", "RemoveMinigunError_02");
	}

	RemoveEdict (minigun);
}
/* >>> end of Minigun */

/* Menu */
public OnAdminMenuReady(Handle:topmenu)
{
	if (topmenu == hAdminMenu)
	{
		return;
	}

	hAdminMenu = topmenu

	new TopMenuObject:menu_category = AddToTopMenu(hAdminMenu, "sm_ws_topmenu", TopMenuObject_Category, Handle_Category, INVALID_TOPMENUOBJECT);

	if (menu_category != INVALID_TOPMENUOBJECT)
	{
		AddToTopMenu(hAdminMenu, "sm_sw_menu", TopMenuObject_Item, AdminMenu_WeaponSpawner, menu_category, "sm_sw_menu", ADMFLAG_SLAY);
		AddToTopMenu(hAdminMenu, "sm_gw_menu", TopMenuObject_Item, AdminMenu_WeaponGive, menu_category, "sm_gw_menu", ADMFLAG_SLAY);
		AddToTopMenu(hAdminMenu, "sm_spawn_menu", TopMenuObject_Item, AdminMenu_ZombieSpawnMenu, menu_category, "sm_spawn_menu", ADMFLAG_SLAY);
		AddToTopMenu(hAdminMenu, "sm_smg_menu", TopMenuObject_Item, AdminMenu_MachineGunSpawnMenu, menu_category, "sm_smg_menu", ADMFLAG_SLAY);
	}
}

public Handle_Category(Handle:topmenu, TopMenuAction:action, TopMenuObject:object_id, param, String:buffer[], maxlength)
{
	switch(action)
	{
		case TopMenuAction_DisplayTitle:
			Format(buffer, maxlength, "What do you want?");
		case TopMenuAction_DisplayOption:
			Format(buffer, maxlength, "%T", "WeaponSpawner", LANG_SERVER)
	}
}

/* Weapon Spawn Menu */
public AdminMenu_WeaponSpawner(Handle:topmenu, TopMenuAction:action, TopMenuObject:object_id, param, String:buffer[], maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "%T", "SpawnWeapon", LANG_SERVER)
	}
	else if( action == TopMenuAction_SelectOption)
	{
		DisplayWeaponMenu(param)
	}
}

DisplayWeaponMenu(client)
{
	decl String:bulletbased[100], String:shellbased[100], String:explosivebased[100], String:healthrelated[100], String:misc[100], String:title[100];

	new Handle:menu = CreateMenu(MenuHandler_Weapons)

	SetMenuExitBackButton(menu, true)
	Format(bulletbased, sizeof(bulletbased),"%T", "BulletBased", LANG_SERVER)
	AddMenuItem(menu, "g_BulletBasedMenu", bulletbased)
	Format(shellbased, sizeof(shellbased),"%T", "ShellBased", LANG_SERVER)
	AddMenuItem(menu, "g_ShellBasedMenu", shellbased)
	Format(explosivebased, sizeof(explosivebased),"%T", "ExplosiveBased", LANG_SERVER)
	AddMenuItem(menu, "g_ExplosiveBasedMenu", explosivebased)
	Format(healthrelated, sizeof(healthrelated),"%T", "HealthRelated", LANG_SERVER)
	AddMenuItem(menu, "g_HealthMenu", healthrelated)
	Format(misc, sizeof(misc),"%T", "Misc", LANG_SERVER)
	AddMenuItem(menu, "g_MiscMenu", misc)
	Format(title, sizeof(title),"%T", "DisplayWeaponMenuTitle", LANG_SERVER)
	SetMenuTitle(menu, title)

	DisplayMenu(menu, client, MENU_TIME_FOREVER)
}

public MenuHandler_Weapons(Handle:menu, MenuAction:action, param1, param2)
{
	switch(action)
	{
		case MenuAction_End:
			CloseHandle(menu);
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack && hAdminMenu != INVALID_HANDLE)
			{
				DisplayTopMenu(hAdminMenu, param1, TopMenuPosition_LastCategory);
			}
		}
		case MenuAction_Select:
		{
			switch(param2)
			{
				case 0:
					BuildBulletBasedMenu(param1);
				case 1:
					BuildShellBasedMenu(param1);
				case 2:
					BuildExplosiveBasedMenu(param1);
				case 3:
					BuildHealthMenu(param1);
				case 4:
					BuildMiscMenu(param1);
			}
		}
	}
}

BuildBulletBasedMenu(client)
{
	decl String:hunting_rifle[100], String:pistol[100], String:pistol_magnum[100], String:rifle[100], String:rifle_desert[100];
	decl String:smg[100], String:smg_silenced[100], String:sniper_military[100], String:rifle_ak47[100], String:rifle_sg552[100];
	decl String:smg_mp5[100], String:sniper_awp[100], String:sniper_scout[100], String:title[100];

	new Handle:menu = CreateMenu(MenuHandler_SpawnWeapon);
	
	Format(hunting_rifle, sizeof(hunting_rifle),"%T", "HuntingRifle", LANG_SERVER)
	AddMenuItem(menu, "weapon_hunting_rifle", hunting_rifle)
	Format(pistol, sizeof(pistol),"%T", "Pistol", LANG_SERVER)
	AddMenuItem(menu, "weapon_pistol", pistol)
	Format(pistol_magnum, sizeof(pistol_magnum),"%T", "DesertEagle", LANG_SERVER)
	AddMenuItem(menu, "weapon_pistol_magnum", pistol_magnum)
	Format(rifle, sizeof(rifle),"%T", "Rifle", LANG_SERVER)
	AddMenuItem(menu, "weapon_rifle", rifle)
	Format(rifle_desert, sizeof(rifle_desert),"%T", "DesertRifle", LANG_SERVER)
	AddMenuItem(menu, "weapon_rifle_desert", rifle_desert)
	Format(smg, sizeof(smg),"%T", "SubmachineGun", LANG_SERVER)
	AddMenuItem(menu, "weapon_smg", smg)
	Format(smg_silenced, sizeof(smg_silenced),"%T", "SilencedSubmachineGun", LANG_SERVER)
	AddMenuItem(menu, "weapon_smg_silenced", smg_silenced)
	Format(sniper_military, sizeof(sniper_military),"%T", "MilitarySniper", LANG_SERVER)
	AddMenuItem(menu, "weapon_sniper_military", sniper_military)
	Format(rifle_ak47, sizeof(rifle_ak47),"%T", "AvtomatKalashnikova", LANG_SERVER)
	AddMenuItem(menu, "weapon_rifle_ak47", rifle_ak47)
	Format(rifle_sg552, sizeof(rifle_sg552),"%T", "SIGSG550", LANG_SERVER)
	AddMenuItem(menu, "weapon_rifle_sg552", rifle_sg552)
	Format(smg_mp5, sizeof(smg_mp5),"%T", "SubmachineGunMP5", LANG_SERVER)
	AddMenuItem(menu, "weapon_smg_mp5", smg_mp5)
	Format(sniper_awp, sizeof(sniper_awp),"%T", "AccuracyInternationaLArcticWarfare", LANG_SERVER)
	AddMenuItem(menu, "weapon_sniper_awp", sniper_awp)
	Format(sniper_scout, sizeof(sniper_scout),"%T", "ScoutSniper", LANG_SERVER)
	AddMenuItem(menu, "weapon_sniper_scout", sniper_scout)
	Format(title, sizeof(title),"%T", "BulletBasedMenuTitle", LANG_SERVER)
	SetMenuTitle(menu, title);
	SetMenuExitBackButton(menu, true)

	ChoosedMenuSpawn[client] = "BulletBasedSpawnMenu";
	DisplayMenu(menu, client, MENU_TIME_FOREVER)
}

BuildShellBasedMenu(client)
{
	decl String:autoshotgun[100], String:shotgun_chrome[100], String:shotgun_spas[100], String:pumpshotgun[100], String:title[100]; 
	
	new Handle:menu = CreateMenu(MenuHandler_SpawnWeapon);
	
	Format(autoshotgun, sizeof(autoshotgun),"%T", "AutoShotgun", LANG_SERVER)
	AddMenuItem(menu, "weapon_autoshotgun", autoshotgun)
	Format(shotgun_chrome, sizeof(shotgun_chrome),"%T", "ChromeShotgun", LANG_SERVER)
	AddMenuItem(menu, "weapon_shotgun_chrome", shotgun_chrome)
	Format(shotgun_spas, sizeof(shotgun_spas),"%T", "SpasShotgun", LANG_SERVER)
	AddMenuItem(menu, "weapon_shotgun_spas", shotgun_spas)
	Format(pumpshotgun, sizeof(pumpshotgun),"%T", "PumpShotgun", LANG_SERVER)
	AddMenuItem(menu, "weapon_pumpshotgun", pumpshotgun)
	Format(title, sizeof(title),"%T", "ShellBasedMenuTitle", LANG_SERVER)
	SetMenuTitle(menu, title);
	SetMenuExitBackButton(menu, true)

	ChoosedMenuSpawn[client] = "ShellBasedSpawnMenu";
	DisplayMenu(menu, client, MENU_TIME_FOREVER)
}

BuildExplosiveBasedMenu(client)
{
	decl String:grenade_launcher[100], String:fireworkcrate[100], String:gascan[100], String:molotov[100], String:oxygentank[100];
	decl String:pipe_bomb[100], String:propanetank[100], String:title[100];

	new Handle:menu = CreateMenu(MenuHandler_SpawnWeapon);
	
	Format(grenade_launcher, sizeof(grenade_launcher),"%T", "GranadeLuncher", LANG_SERVER)
	AddMenuItem(menu, "weapon_grenade_launcher", grenade_launcher)
	Format(fireworkcrate, sizeof(fireworkcrate),"%T", "FireWorksCrate", LANG_SERVER)
	AddMenuItem(menu, "weapon_fireworkcrate", fireworkcrate)
	Format(gascan, sizeof(gascan),"%T", "Gascan", LANG_SERVER)
	AddMenuItem(menu, "weapon_gascan", gascan)
	Format(molotov, sizeof(molotov),"%T", "Molotov", LANG_SERVER)
	AddMenuItem(menu, "weapon_molotov", molotov)
	Format(oxygentank, sizeof(oxygentank),"%T", "OxygenTank", LANG_SERVER)
	AddMenuItem(menu, "weapon_oxygentank", oxygentank)
	Format(pipe_bomb, sizeof(pipe_bomb),"%T", "PipeBomb", LANG_SERVER)
	AddMenuItem(menu, "weapon_pipe_bomb", pipe_bomb)
	Format(propanetank, sizeof(propanetank),"%T", "PropaneTank", LANG_SERVER)
	AddMenuItem(menu, "weapon_propanetank", propanetank)
	Format(title, sizeof(title),"%T", "ExplosiveBasedMenuTitle", LANG_SERVER)
	SetMenuTitle(menu, title);
	SetMenuExitBackButton(menu, true)

	ChoosedMenuSpawn[client] = "ExplosiveBasedSpawnMenu";
	DisplayMenu(menu, client, MENU_TIME_FOREVER)
}

BuildHealthMenu(client)
{
	decl String:adrenaline[100], String:defibrillator[100], String:first_aid_kit[100], String:pain_pills[100], String:title[100]; 

	new Handle:menu = CreateMenu(MenuHandler_SpawnWeapon);
	
	Format(adrenaline, sizeof(adrenaline),"%T", "Adrenaline", LANG_SERVER)
	AddMenuItem(menu, "weapon_adrenaline", adrenaline)
	Format(defibrillator, sizeof(defibrillator),"%T", "Defibrillator", LANG_SERVER)
	AddMenuItem(menu, "weapon_defibrillator", defibrillator)
	Format(first_aid_kit, sizeof(first_aid_kit),"%T", "FirstAidKit", LANG_SERVER)
	AddMenuItem(menu, "weapon_first_aid_kit", first_aid_kit)
	Format(pain_pills, sizeof(pain_pills),"%T", "PainPills", LANG_SERVER)
	AddMenuItem(menu, "weapon_pain_pills", "Pain Pills")
	Format(title, sizeof(title),"%T", "HealthMenuTitle", LANG_SERVER)
	SetMenuTitle(menu, title);
	SetMenuExitBackButton(menu, true)

	ChoosedMenuSpawn[client] = "HealthSpawnMenu";
	DisplayMenu(menu, client, MENU_TIME_FOREVER)
}

BuildMiscMenu(client)
{
	decl String:chainsaw[100], String:ammo_spawn[100], String:upgradepack_explosive[100], String:upgradepack_incendiary[100];
	decl String:vomitjar[100], String:gnome[100], String:title[100];
	
	new Handle:menu = CreateMenu(MenuHandler_SpawnWeapon);
	
	Format(chainsaw, sizeof(chainsaw),"%T", "ChainSaw", LANG_SERVER)
	AddMenuItem(menu, "weapon_chainsaw", chainsaw)
	Format(ammo_spawn, sizeof(ammo_spawn),"%T", "AmmoStack", LANG_SERVER)
	AddMenuItem(menu, "weapon_ammo_spawn", ammo_spawn)
	Format(upgradepack_explosive, sizeof(upgradepack_explosive),"%T", "ExplosiveAmmoPack", LANG_SERVER)
	AddMenuItem(menu, "weapon_upgradepack_explosive", upgradepack_explosive)
	Format(upgradepack_incendiary, sizeof(upgradepack_incendiary),"%T", "IncendiaryAmmoPack", LANG_SERVER)
	AddMenuItem(menu, "weapon_upgradepack_incendiary", upgradepack_incendiary)
	Format(vomitjar, sizeof(vomitjar),"%T", "VomitJar", LANG_SERVER)
	AddMenuItem(menu, "weapon_vomitjar", vomitjar)
	Format(gnome, sizeof(gnome),"%T", "Gnome", LANG_SERVER)
	AddMenuItem(menu, "weapon_gnome", gnome)
	Format(title, sizeof(title),"%T", "MiscMenuTitle", LANG_SERVER)
	SetMenuTitle(menu, title);
	SetMenuExitBackButton(menu, true)

	ChoosedMenuSpawn[client] = "MiscSpawnMenu";
	DisplayMenu(menu, client, MENU_TIME_FOREVER)
}

public MenuHandler_SpawnWeapon(Handle:menu, MenuAction:action, param1, param2)
{
switch(action)
	{
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack)
			{
				DisplayWeaponMenu(param1)
			}
		}
		case MenuAction_Select:
		{
			new String:weapon[32];
			decl maxammo;

			GetMenuItem(menu, param2, weapon, sizeof(weapon));

			if(!SetTeleportEndPoint(param1))
			{
				PrintToChat(param1, "[SM] %T", "SpawnError", LANG_SERVER);
			}
			
			if (StrEqual(weapon, "weapon_rifle", false) || StrEqual(weapon, "weapon_rifle_ak47", false) || StrEqual(weapon, "weapon_rifle_desert", false))
			{
				maxammo = GetConVarInt(AssaultMaxAmmo);
			}
			else if (StrEqual(weapon, "weapon_smg", false) || StrEqual(weapon, "weapon_smg_silenced", false))
			{
				maxammo = GetConVarInt(SMGMaxAmmo);
			}		
			else if (StrEqual(weapon, "weapon_pumpshotgun", false) || StrEqual(weapon, "weapon_shotgun_chrome", false))
			{
				maxammo = GetConVarInt(ShotgunMaxAmmo);
			}
			else if (StrEqual(weapon, "weapon_autoshotgun", false) || StrEqual(weapon, "weapon_shotgun_spas", false))
			{
				maxammo = GetConVarInt(AutoShotgunMaxAmmo);
			}
			else if (StrEqual(weapon, "weapon_hunting_rifle", false))
			{
				maxammo = GetConVarInt(HRMaxAmmo);
			}
			else if (StrEqual(weapon, "weapon_sniper_military", false))
			{
				maxammo = GetConVarInt(SniperRifleMaxAmmo);
			}
			if (StrEqual(weapon, "weapon_grenade_launcher", false))
			{
				maxammo = GetConVarInt(GrenadeLauncherMaxAmmo);
			}
			else
			{
				PrintToChat(param1, "%T", "WrongWeaponName", LANG_SERVER);
			}

			new iWeapon = CreateEntityByName(weapon);

			if(IsValidEntity(iWeapon))
			{
				DispatchSpawn(iWeapon); //Spawn weapon (entity)
				SetEntProp(iWeapon, Prop_Send, "m_iExtraPrimaryAmmo", maxammo ,4); //Adds max ammo for weapon
				g_pos[2] -= 10.0;
				TeleportEntity(iWeapon, g_pos, NULL_VECTOR, NULL_VECTOR); //Teleport spawned weapon
			}
			ChoosedSpawnMenuHistory(param1); //Redraw menu after item selection
		}
	}
}

stock ChoosedSpawnMenuHistory(param1)
{
	if (strcmp(ChoosedMenuSpawn[param1], "BulletBasedSpawnMenu") == 0)
	{
		BuildBulletBasedMenu(param1);
	}
	else if (strcmp(ChoosedMenuSpawn[param1], "ShellBasedSpawnMenu") == 0)
	{
		BuildShellBasedMenu(param1);
	}
	else if (strcmp(ChoosedMenuSpawn[param1], "ExplosiveBasedSpawnMenu") == 0)
	{
		BuildExplosiveBasedMenu(param1);
	}
	else if (strcmp(ChoosedMenuSpawn[param1], "HealthSpawnMenu") == 0)
	{
		BuildHealthMenu(param1);
	}
	else if (strcmp(ChoosedMenuSpawn[param1], "MiscSpawnMenu") == 0)
	{
		BuildMiscMenu(param1);
	}
}
/* >>> end of Weapon Spawn Menu */

/* Weapon Give Menu */
public AdminMenu_WeaponGive(Handle:topmenu, TopMenuAction:action, TopMenuObject:object_id, param, String:buffer[], maxlength)
{
	switch(action)
	{
		case MenuAction_End:
			CloseHandle(topmenu);
		case TopMenuAction_DisplayOption:
			Format(buffer, maxlength, "Give Weapon");
		case TopMenuAction_SelectOption:
			DisplayWeaponGiveMenu(param);
	}
}

DisplayWeaponGiveMenu(client)
{
	decl String:MeleeGiveMenu[100], String:BulletBasedGiveMenu[100], String:ShellBasedGiveMenu[100];
	decl String:ExplosiveBasedGiveMenu[100], String:HealthGiveMenu[100], String:MiscGiveMenu[100], String:title[100]; 
	
	new Handle:menu = CreateMenu(MenuHandler_GiveWeapons)
	
	Format(MeleeGiveMenu, sizeof(MeleeGiveMenu),"%T", "MeleeWeapons", LANG_SERVER)
	AddMenuItem(menu, "g_MeleeGiveMenu", MeleeGiveMenu)
	Format(BulletBasedGiveMenu, sizeof(BulletBasedGiveMenu),"%T", "BulletBased", LANG_SERVER)
	AddMenuItem(menu, "g_BulletBasedGiveMenu", BulletBasedGiveMenu)
	Format(ShellBasedGiveMenu, sizeof(ShellBasedGiveMenu),"%T", "ShellBased", LANG_SERVER)
	AddMenuItem(menu, "g_ShellBasedGiveMenu", ShellBasedGiveMenu)
	Format(ExplosiveBasedGiveMenu, sizeof(ExplosiveBasedGiveMenu),"%T", "ExplosiveBased", LANG_SERVER)
	AddMenuItem(menu, "g_ExplosiveBasedGiveMenu", ExplosiveBasedGiveMenu)
	Format(HealthGiveMenu, sizeof(HealthGiveMenu),"%T", "HealthRelated", LANG_SERVER)
	AddMenuItem(menu, "g_HealthGiveMenu", HealthGiveMenu)
	Format(MiscGiveMenu, sizeof(MiscGiveMenu),"%T", "Misc", LANG_SERVER)
	AddMenuItem(menu, "g_MiscGiveMenu", MiscGiveMenu)
	Format(title, sizeof(title),"%T", "WeaponGiveMenuTitle", LANG_SERVER)
	SetMenuTitle(menu, title)
	SetMenuExitBackButton(menu, true)

	DisplayMenu(menu, client, MENU_TIME_FOREVER)
}

public MenuHandler_GiveWeapons(Handle:menu, MenuAction:action, param1, param2)
{
	switch(action)
	{
		case MenuAction_End:
			CloseHandle(menu);
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack && hAdminMenu != INVALID_HANDLE)
			{
				DisplayTopMenu(hAdminMenu, param1, TopMenuPosition_LastCategory);
			}
		}
		case MenuAction_Select:
		{
			switch(param2)
			{
				case 0:
					BuildMeleeGiveMenu(param1);
				case 1:
					BuildBulletBasedGiveMenu(param1);
				case 2:
					BuildShellBasedGiveMenu(param1);
				case 3:
					BuildExplosiveBasedGiveMenu(param1);
				case 4:
					BuildHealthGiveMenu(param1);
				case 5:
					BuildMiscGiveMenu(param1);
			}
		}
	}
}

BuildMeleeGiveMenu(client)
{
	decl String:baseball_bat[100], String:cricket_bat[100], String:crowbar[100], String:electric_guitar[100], String:fireaxe[100];
	decl String:frying_pan[100], String:katana[100], String:machete[100], String:tonfa[100], String:knife[100], String:title[100]
	
	new Handle:menu = CreateMenu(MenuHandler_GiveWeapon);

	Format(baseball_bat, sizeof(baseball_bat),"%T", "BaseballBat", LANG_SERVER)
	AddMenuItem(menu, "baseball_bat", baseball_bat)
	Format(cricket_bat, sizeof(cricket_bat),"%T", "CricketBat", LANG_SERVER)
	AddMenuItem(menu, "cricket_bat", "Cricket Bat")
	Format(crowbar, sizeof(crowbar),"%T", "Crowbar", LANG_SERVER)
	AddMenuItem(menu, "crowbar", crowbar)
	Format(electric_guitar, sizeof(electric_guitar),"%T", "ElectricGuitar", LANG_SERVER)
	AddMenuItem(menu, "electric_guitar", electric_guitar)
	Format(fireaxe, sizeof(fireaxe),"%T", "FireAxe", LANG_SERVER)
	AddMenuItem(menu, "fireaxe", fireaxe)
	Format(frying_pan, sizeof(frying_pan),"%T", "Frying Pan", LANG_SERVER)
	AddMenuItem(menu, "frying_pan", frying_pan)
	Format(katana, sizeof(katana),"%T", "Katana", LANG_SERVER)
	AddMenuItem(menu, "katana", katana)
	Format(machete, sizeof(machete),"%T", "Machete", LANG_SERVER)
	AddMenuItem(menu, "machete", machete)
	Format(tonfa, sizeof(tonfa),"%T", "Tonfa", LANG_SERVER)
	AddMenuItem(menu, "tonfa", tonfa)
	Format(knife, sizeof(knife),"%T", "Knife", LANG_SERVER)
	AddMenuItem(menu, "knife", knife)
	Format(title, sizeof(title),"%T", "MeleeMenuTitle", LANG_SERVER)
	SetMenuTitle(menu, title);
	SetMenuExitBackButton(menu, true)

	ChoosedMenuGive[client] = "MeleeGiveMenu";
	DisplayMenu(menu, client, MENU_TIME_FOREVER)
}

BuildBulletBasedGiveMenu(client)
{
	decl String:hunting_rifle[100], String:pistol[100], String:pistol_magnum[100], String:rifle[100], String:rifle_desert[100];
	decl String:smg[100], String:smg_silenced[100], String:sniper_military[100], String:rifle_ak47[100], String:rifle_sg552[100];
	decl String:smg_mp5[100], String:sniper_awp[100], String:sniper_scout[100], String:title[100];

	new Handle:menu = CreateMenu(MenuHandler_GiveWeapon);
	
	Format(hunting_rifle, sizeof(hunting_rifle),"%T", "HuntingRifle", LANG_SERVER)
	AddMenuItem(menu, "hunting_rifle", hunting_rifle)
	Format(pistol, sizeof(pistol),"%T", "Pistol", LANG_SERVER)
	AddMenuItem(menu, "pistol", pistol)
	Format(pistol_magnum, sizeof(pistol_magnum),"%T", "DesertEagle", LANG_SERVER)
	AddMenuItem(menu, "pistol_magnum", pistol_magnum)
	Format(rifle, sizeof(rifle),"%T", "Rifle", LANG_SERVER)
	AddMenuItem(menu, "rifle", rifle)
	Format(rifle_desert, sizeof(rifle_desert),"%T", "DesertRifle", LANG_SERVER)
	AddMenuItem(menu, "rifle_desert", rifle_desert)
	Format(smg, sizeof(smg),"%T", "SubmachineGun", LANG_SERVER)
	AddMenuItem(menu, "smg", smg)
	Format(smg_silenced, sizeof(smg_silenced),"%T", "SilencedSubmachineGun", LANG_SERVER)
	AddMenuItem(menu, "smg_silenced", smg_silenced)
	Format(sniper_military, sizeof(sniper_military),"%T", "MilitarySniper", LANG_SERVER)
	AddMenuItem(menu, "sniper_military", sniper_military)
	Format(rifle_ak47, sizeof(rifle_ak47),"%T", "AvtomatKalashnikova", LANG_SERVER)
	AddMenuItem(menu, "rifle_ak47", rifle_ak47)
	Format(rifle_sg552, sizeof(rifle_sg552),"%T", "SIGSG550", LANG_SERVER)
	AddMenuItem(menu, "rifle_sg552", rifle_sg552)
	Format(smg_mp5, sizeof(smg_mp5),"%T", "SubmachineGunMP5", LANG_SERVER)
	AddMenuItem(menu, "smg_mp5", smg_mp5)
	Format(sniper_awp, sizeof(sniper_awp),"%T", "AccuracyInternationaLArcticWarfare", LANG_SERVER)
	AddMenuItem(menu, "sniper_awp", sniper_awp)
	Format(sniper_scout, sizeof(sniper_scout),"%T", "ScoutSniper", LANG_SERVER)
	AddMenuItem(menu, "sniper_scout", sniper_scout)
	Format(title, sizeof(title),"%T", "BulletBasedMenuTitle", LANG_SERVER)
	SetMenuTitle(menu, title);
	SetMenuExitBackButton(menu, true)

	ChoosedMenuGive[client] = "BulletBasedGiveMenu";
	DisplayMenu(menu, client, MENU_TIME_FOREVER)
}

BuildShellBasedGiveMenu(client)
{
	decl String:autoshotgun[100], String:shotgun_chrome[100], String:shotgun_spas[100], String:pumpshotgun[100], String:title[100]; 
	
	new Handle:menu = CreateMenu(MenuHandler_GiveWeapon);
	
	Format(autoshotgun, sizeof(autoshotgun),"%T", "AutoShotgun", LANG_SERVER)
	AddMenuItem(menu, "autoshotgun", autoshotgun)
	Format(shotgun_chrome, sizeof(shotgun_chrome),"%T", "ChromeShotgun", LANG_SERVER)
	AddMenuItem(menu, "shotgun_chrome", shotgun_chrome)
	Format(shotgun_spas, sizeof(shotgun_spas),"%T", "SpasShotgun", LANG_SERVER)
	AddMenuItem(menu, "shotgun_spas", shotgun_spas)
	Format(pumpshotgun, sizeof(pumpshotgun),"%T", "PumpShotgun", LANG_SERVER)
	AddMenuItem(menu, "pumpshotgun", pumpshotgun)
	Format(title, sizeof(title),"%T", "ShellBasedMenuTitle", LANG_SERVER)
	SetMenuTitle(menu, title);
	SetMenuExitBackButton(menu, true)
	
	ChoosedMenuGive[client] = "ShellBasedGiveMenu";
	DisplayMenu(menu, client, MENU_TIME_FOREVER)
}

BuildExplosiveBasedGiveMenu(client)
{
	decl String:grenade_launcher[100], String:fireworkcrate[100], String:gascan[100], String:molotov[100], String:oxygentank[100];
	decl String:pipe_bomb[100], String:propanetank[100], String:title[100];

	new Handle:menu = CreateMenu(MenuHandler_GiveWeapon);
	
	Format(grenade_launcher, sizeof(grenade_launcher),"%T", "GranadeLuncher", LANG_SERVER)
	AddMenuItem(menu, "grenade_launcher", grenade_launcher)
	Format(fireworkcrate, sizeof(fireworkcrate),"%T", "FireWorksCrate", LANG_SERVER)
	AddMenuItem(menu, "fireworkcrate", fireworkcrate)
	Format(gascan, sizeof(gascan),"%T", "Gascan", LANG_SERVER)
	AddMenuItem(menu, "gascan", gascan)
	Format(molotov, sizeof(molotov),"%T", "Molotov", LANG_SERVER)
	AddMenuItem(menu, "molotov", molotov)
	Format(oxygentank, sizeof(oxygentank),"%T", "OxygenTank", LANG_SERVER)
	AddMenuItem(menu, "oxygentank", oxygentank)
	Format(pipe_bomb, sizeof(pipe_bomb),"%T", "PipeBomb", LANG_SERVER)
	AddMenuItem(menu, "pipe_bomb", pipe_bomb)
	Format(propanetank, sizeof(propanetank),"%T", "PropaneTank", LANG_SERVER)
	AddMenuItem(menu, "propanetank", propanetank)
	Format(title, sizeof(title),"%T", "ExplosiveBasedMenuTitle", LANG_SERVER)
	SetMenuTitle(menu, title);
	SetMenuExitBackButton(menu, true)
	
	ChoosedMenuGive[client] = "ExplosiveBasedGiveMenu";
	DisplayMenu(menu, client, MENU_TIME_FOREVER)
}

BuildHealthGiveMenu(client)
{
	decl String:adrenaline[100], String:defibrillator[100], String:first_aid_kit[100], String:pain_pills[100], String:title[100]; 

	new Handle:menu = CreateMenu(MenuHandler_GiveWeapon);
	
	Format(adrenaline, sizeof(adrenaline),"%T", "Adrenaline", LANG_SERVER)
	AddMenuItem(menu, "adrenaline", adrenaline)
	Format(defibrillator, sizeof(defibrillator),"%T", "Defibrillator", LANG_SERVER)
	AddMenuItem(menu, "defibrillator", defibrillator)
	Format(first_aid_kit, sizeof(first_aid_kit),"%T", "FirstAidKit", LANG_SERVER)
	AddMenuItem(menu, "first_aid_kit", first_aid_kit)
	Format(pain_pills, sizeof(pain_pills),"%T", "PainPills", LANG_SERVER)
	AddMenuItem(menu, "pain_pills", "Pain Pills")
	Format(title, sizeof(title),"%T", "HealthMenuTitle", LANG_SERVER)
	SetMenuTitle(menu, title);
	SetMenuExitBackButton(menu, true)
	
	ChoosedMenuGive[client] = "HealthGiveMenu";
	DisplayMenu(menu, client, MENU_TIME_FOREVER)
}

BuildMiscGiveMenu(client)
{
	decl String:chainsaw[100], String:ammo[100], String:upgradepack_explosive[100], String:upgradepack_incendiary[100];
	decl String:vomitjar[100], String:gnome[100], String:title[100];
	
	new Handle:menu = CreateMenu(MenuHandler_GiveWeapon);
	
	Format(chainsaw, sizeof(chainsaw),"%T", "ChainSaw", LANG_SERVER)
	AddMenuItem(menu, "chainsaw", chainsaw)
	Format(ammo, sizeof(ammo),"%T", "Ammo", LANG_SERVER)
	AddMenuItem(menu, "ammo", ammo)
	Format(upgradepack_explosive, sizeof(upgradepack_explosive),"%T", "ExplosiveAmmoPack", LANG_SERVER)
	AddMenuItem(menu, "upgradepack_explosive", upgradepack_explosive)
	Format(upgradepack_incendiary, sizeof(upgradepack_incendiary),"%T", "IncendiaryAmmoPack", LANG_SERVER)
	AddMenuItem(menu, "upgradepack_incendiary", upgradepack_incendiary)
	Format(vomitjar, sizeof(vomitjar),"%T", "VomitJar", LANG_SERVER)
	AddMenuItem(menu, "vomitjar", vomitjar)
	Format(gnome, sizeof(gnome),"%T", "Gnome", LANG_SERVER)
	AddMenuItem(menu, "gnome", gnome)
	Format(title, sizeof(title),"%T", "MiscMenuTitle", LANG_SERVER)
	SetMenuTitle(menu, title);
	SetMenuExitBackButton(menu, true)
	
	ChoosedMenuGive[client] = "MiscGiveMenu";
	DisplayMenu(menu, client, MENU_TIME_FOREVER)
}

public MenuHandler_GiveWeapon(Handle:menu, MenuAction:action, param1, param2)
{
switch(action)
	{
		case MenuAction_End:
			CloseHandle(menu);
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack)
			{
				DisplayWeaponGiveMenu(param1);
			}
		}
		case MenuAction_Select:
		{
			decl String:info[32];
			GetMenuItem(menu, param2, info, sizeof(info));
			/* Save choosed weapon */
			ChoosedWeapon[param1] = info;
			DisplaySelectPlayerMenu(param1);
		}
	}
}

DisplaySelectPlayerMenu(client)
{
	new Handle:menu = CreateMenu(MenuHandler_PlayerSelect)

	SetMenuTitle(menu, "Select Player")
	SetMenuExitBackButton(menu, true)

	AddTargetsToMenu2(menu, client, COMMAND_FILTER_NO_BOTS)

	DisplayMenu(menu, client, MENU_TIME_FOREVER)
}

public MenuHandler_PlayerSelect(Handle:menu, MenuAction:action, param1, param2)
{
	switch(action)
	{
		case MenuAction_End:
			CloseHandle(menu);
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack)
			{	
				ChoosedGiveMenuHistory(param1);
			}
		}
		case MenuAction_Select:
		{
			new String:info[56];
			GetMenuItem(menu, param2, info, sizeof(info));

			new target = GetClientOfUserId(StringToInt(info));

			if ((target) == 0)
			{
				PrintToChat(param1, "Player no longer available");
			}
			else if (!CanUserTarget(param1, target))
			{
				PrintToChat(param1, "Unable to target");
			}

			if ((strcmp(ChoosedWeapon[param1], "laser_sight") == 0) || (strcmp(ChoosedWeapon[param1], "explosive_ammo") == 0) || (strcmp(ChoosedWeapon[param1], "incendiary_ammo") == 0))
			{
				new flagsupgrade_add = GetCommandFlags("upgrade_add");
				SetCommandFlags("upgrade_add", flagsupgrade_add & ~FCVAR_CHEAT);
				if (IsClientInGame(target)) FakeClientCommand(target, "upgrade_add %s", ChoosedWeapon[param1]);
				SetCommandFlags("upgrade_add", flagsupgrade_add|FCVAR_CHEAT);
				ChoosedGiveMenuHistory(param1);
			}
			else
			{
				new flagsgive = GetCommandFlags("give");
				SetCommandFlags("give", flagsgive & ~FCVAR_CHEAT);
				if (IsClientInGame(target)) FakeClientCommand(target, "give %s", ChoosedWeapon[param1]);
				SetCommandFlags("give", flagsgive|FCVAR_CHEAT);
				ChoosedGiveMenuHistory(param1);
			}
		}
	}
}

stock ChoosedGiveMenuHistory(param1)
{
	if (strcmp(ChoosedMenuGive[param1], "MeleeGiveMenu") == 0)
	{
		BuildMeleeGiveMenu(param1);
	}
	else if (strcmp(ChoosedMenuGive[param1], "BulletBasedGiveMenu") == 0)
	{
		BuildBulletBasedGiveMenu(param1);
	}
	else if (strcmp(ChoosedMenuGive[param1], "ShellBasedGiveMenu") == 0)
	{
		BuildShellBasedGiveMenu(param1);
	}
	else if (strcmp(ChoosedMenuGive[param1], "ExplosiveBasedGiveMenu") == 0)
	{
		BuildExplosiveBasedGiveMenu(param1);
	}
	else if (strcmp(ChoosedMenuGive[param1], "HealthGiveMenu") == 0)
	{
		BuildHealthGiveMenu(param1);
	}
	else if (strcmp(ChoosedMenuGive[param1], "MiscGiveMenu") == 0)
	{
		BuildMiscGiveMenu(param1);
	}
}
/* >>> end of Weapon Give Menu */

/* Spawn Special Zombie Menu */
public AdminMenu_ZombieSpawnMenu(Handle:topmenu, TopMenuAction:action, TopMenuObject:object_id, param, String:buffer[], maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Spawn Special Zombie")
	}
	else if( action == TopMenuAction_SelectOption)
	{
		DisplaySpecialZombieMenu(param)
	}
}

DisplaySpecialZombieMenu(client)
{
	new Handle:menu = CreateMenu(MenuHandler_SpecialZombie)
	
	SetMenuExitBackButton(menu, true)
	AddMenuItem(menu, "boomer", "Boomer")
	AddMenuItem(menu, "charger", "Charger")
	AddMenuItem(menu, "hunter", "Hunter")
	AddMenuItem(menu, "smoker", "Smoker")
	AddMenuItem(menu, "spitter", "Spitter")
	AddMenuItem(menu, "tank", "Tank")
	AddMenuItem(menu, "jockey", "Jockey")
	AddMenuItem(menu, "witch", "Witch")
	AddMenuItem(menu, "zombie", "One Zombie ;-)")
	SetMenuTitle(menu, "Spawn Special Zombie")
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER)
}

public MenuHandler_SpecialZombie(Handle:menu, MenuAction:action, param1, param2)
{
	switch(action)
	{
		case MenuAction_End:
			CloseHandle(menu);
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack && hAdminMenu != INVALID_HANDLE)
			{
				DisplayTopMenu(hAdminMenu, param1, TopMenuPosition_LastCategory);
			}
		}
		case MenuAction_Select:
		{
			decl String:info[32];
			GetMenuItem(menu, param2, info, sizeof(info));
			
			if (IsClientConnected(param1) && IsClientInGame(param1))
			{
				new flagszspawn = GetCommandFlags("z_spawn");	
				SetCommandFlags("z_spawn", flagszspawn & ~FCVAR_CHEAT);	
				FakeClientCommand(param1, "z_spawn %s", info);
				SetCommandFlags("z_spawn", flagszspawn|FCVAR_CHEAT);
				
				DisplaySpecialZombieMenu(param1)
			}
		}
	}
}
/* >>> end of Spawn Special Zombie Menu */

/* Minigun Menu */

public AdminMenu_MachineGunSpawnMenu (Handle:topmenu, TopMenuAction:action, TopMenuObject:object_id, param, String:buffer[], maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "MiniGun Menu")
	}
	else if( action == TopMenuAction_SelectOption)
	{
		DisplayMinigunMenu(param)
	}
}

DisplayMinigunMenu(client)
{
	new Handle:menu = CreateMenu(MenuHandler_MiniGun)

	SetMenuExitBackButton(menu, true)
	AddMenuItem(menu, "prop_minigun", "Spawn MiniGun")
	SetMenuTitle(menu, "MiniGun Menu")

	DisplayMenu(menu, client, MENU_TIME_FOREVER)
}

public MenuHandler_MiniGun(Handle:menu, MenuAction:action, param1, param2)
{
	switch(action)
	{
		case MenuAction_End:
			CloseHandle(menu);
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack && hAdminMenu != INVALID_HANDLE)
			{
				DisplayTopMenu(hAdminMenu, param1, TopMenuPosition_LastCategory);
			}
		}
		case MenuAction_Select:
		{
			SpawnMiniGun(param1)
			DisplayMinigunMenu(param1)
		}
	}
}
/* >>> end of Minigun */

public Action:Command_DisplayMenu(client, args)
{
	if (!client)
	{
		ReplyToCommand(client, "[SM] %t", "Command is in-game only");
		return Plugin_Handled;
	}
	
	DisplayTopMenu(hAdminMenu, client, TopMenuPosition_Start);
	
	return Plugin_Handled;
}
/* >>> end of Menu */

/* Teleport Entity */
SetTeleportEndPoint(client)
{
	decl Float:vAngles[3];
	decl Float:vOrigin[3];
	decl Float:vBuffer[3];
	decl Float:vStart[3];
	decl Float:Distance;
	
	GetClientEyePosition(client,vOrigin);
	GetClientEyeAngles(client, vAngles);
	
    //get endpoint for teleport
	new Handle:trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);

	if(TR_DidHit(trace))
	{
		TR_GetEndPosition(vStart, trace);
		GetVectorDistance(vOrigin, vStart, false);
		Distance = -35.0;
		GetAngleVectors(vAngles, vBuffer, NULL_VECTOR, NULL_VECTOR);
		g_pos[0] = vStart[0] + (vBuffer[0]*Distance);
		g_pos[1] = vStart[1] + (vBuffer[1]*Distance);
		g_pos[2] = vStart[2] + (vBuffer[2]*Distance);
	}
	else
	{
		CloseHandle(trace);
		return false;
	}
	CloseHandle(trace);
	return true;
}

public bool:TraceEntityFilterPlayer(entity, contentsMask)
{
	return entity > GetMaxClients() || !entity;
}
/* >>> end of Teleport Entity */