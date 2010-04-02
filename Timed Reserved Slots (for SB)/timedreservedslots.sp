#include <sourcemod>

public Plugin:myinfo = 
{
	name = "Timed reserved slot for SourceBans",
	author = "Luki",
	description = "Add a timed reserved slot",
	version = "1.0",
	url = ""
}

new Handle:Database;
new Handle:hServerID;

public OnPluginStart()
{
	RegAdminCmd("sm_addtimedreserved", cAddTimedReserved, ADMFLAG_ROOT, "Add timed reserved slot to player (sm_addtimedreserved <userid> <time>)");
	
	hServerID = CreateConVar("sm_timedreserved_serverid", "-1", "Server ID in SourceBans");
	
	ConnectToDatabase();
	
	CheckReservations();
}

public OnConfigsExecuted()
{
	CheckReservations();
}

public ConnectToDatabase()
{
	new String:error[255];
	
	Database = SQL_Connect("sourcebans", true, error, sizeof(error));
	
	if (Database == INVALID_HANDLE)
	{
		PrintToServer("Could not connect: %s", error)
	}
}

public Action:cAddTimedReserved(client, args)
{
	new String:sTarget[32], String:sAmount[32];
	new iTarget, iAmount;
	
	if (!GetCmdArg(1, sTarget, sizeof(sTarget)))
	{
		PrintToChat(client, "Usage: sm_addtimedreserved userid time");
		return Plugin_Handled;
	}
	
	if (!GetCmdArg(2, sAmount, sizeof(sAmount)))
	{
		PrintToChat(client, "Usage: sm_addtimedreserved userid time");
		return Plugin_Handled;
	}
	
	iTarget = GetClientOfUserId(StringToInt(sTarget));
	iAmount = StringToInt(sAmount);
	
	if (!FullCheckClient(iTarget))
	{
		PrintToChat(client, "No such user (%s)", sTarget);
		return Plugin_Handled;
	}
	
	AddReservedSlotTime(iTarget, iAmount);
	
	return Plugin_Handled;
}

public bool:FullCheckClient(client)
{
	if (client < 1)
		return false;
	
	if (!IsClientConnected(client))
		return false;
	
	if (!IsClientInGame(client))
		return false;
	
	if (IsFakeClient(client))
		return false;
	
	return true;
}

public CheckReservations()
{
	new Handle:query = SQL_Query(Database, "SELECT `aid`, `expires` FROM `sb_admins` WHERE `user` LIKE 'loyal_%';");
	if(query == INVALID_HANDLE)
	{
		return;
	}
	
	if (SQL_GetRowCount(query) != 0)
	{
		for (new i = 1; i <= SQL_GetRowCount(query); i++)
		{
			SQL_FetchRow(query);
			new expires = SQL_FetchInt(query, 1);
			if (expires != 0 && expires < GetTime())
			{
				new String:querydelete[255];
				Format(querydelete, sizeof(querydelete), "DELETE FROM `sb_admins` WHERE `aid` = '%i';", SQL_FetchInt(query, 0));
				SQL_FastQuery(Database, querydelete);
				Format(querydelete, sizeof(querydelete), "DELETE FROM `sb_admins_servers_groups` WHERE `admin_id` = '%i';", SQL_FetchInt(query, 0));
				SQL_FastQuery(Database, querydelete);
			}
		}
	}
	CloseHandle(query);

	ServerCommand("sm_rehash");
}

AddReservedSlotTime(client, time)
{
	new String:qQuery[512];
	new String:SID[32];
	new AID;
	
	GetClientAuthString(client, SID, sizeof(SID));
	
	Format(qQuery, sizeof(qQuery), "SELECT `expires` FROM `sb_admins` WHERE `user` = 'loyal_%s'", SID, SID);
	
	new Handle:query = SQL_Query(Database, qQuery);
	if(query == INVALID_HANDLE)
	{
		return;
	}
	
	new expires;
	
	if (SQL_GetRowCount(query) == 0)
	{
		CloseHandle(query);
		expires = GetTime() + time;
		
		Format(qQuery, sizeof(qQuery), "INSERT INTO `sb_admins` (`aid`, `user`, `authid`, `password`, `gid`, `email`, `validate`, `extraflags`, `immunity`, `srv_group`, `srv_flags`, `srv_password`, `lastvisit`, `expires`) VALUES (NULL, 'loyal_%s', '%s', '0', '-1', '', '', '0', '0', NULL, 'a', NULL, NULL, '%i');", SID, SID, expires);
		query = SQL_Query(Database, qQuery);
		if(query == INVALID_HANDLE)
		{
			return;
		}
		CloseHandle(query);		
		
		Format(qQuery, sizeof(qQuery), "SELECT `aid` FROM `sb_admins` WHERE `user` = 'loyal_%s';", SID);
		query = SQL_Query(Database, qQuery);
		if(query == INVALID_HANDLE)
		{
			return;
		}
	
		SQL_FetchRow(query);
		AID = SQL_FetchInt(query, 0);
		CloseHandle(query);
		
		Format(qQuery, sizeof(qQuery), "INSERT INTO `sb_admins_servers_groups` (`admin_id`, `group_id`, `srv_group_id`, `server_id`) VALUES ('%i', '0', '-1', '%i');", AID, GetConVarInt(hServerID));
	
		query = SQL_Query(Database, qQuery);
	
		if(query == INVALID_HANDLE)
		{
			return;
		}
		CloseHandle(query);
	}
	else
	{
		SQL_FetchRow(query);
		expires = SQL_FetchInt(query, 0) + time;
		Format(qQuery, sizeof(qQuery), "UPDATE `sb_admins` SET `expires` = '%i' WHERE `user` = 'loyal_%s';", expires, SID);
		CloseHandle(query);
		query = SQL_Query(Database, qQuery);
		if(query == INVALID_HANDLE)
		{
			return;
		}
		CloseHandle(query);
	}
		
	new String:duration[32];
	expires = (expires-GetTime())/60;
	if(expires<60) {
		Format(duration, sizeof(duration), "%i min%s", expires, expires==1?"":"s");
	} else {
		new hours = expires/60;
		expires = expires%60;
		if(hours<24) {
			Format(duration, sizeof(duration), "%i hr%s %i min%s", hours, hours==1?"":"s", expires, expires==1?"":"s");
		} else {
			new days = hours/24;
			hours = hours%24;
			Format(duration, sizeof(duration), "%i day%s %i hr%s %i min%s", days, days==1?"":"s", hours, hours==1?"":"s", expires, expires==1?"":"s");
		}
	}

	ServerCommand("sm_rehash");
	PrintToChat(client, "\x01You have \x04%s\x01 remaining on your reserved slot.", duration);
}