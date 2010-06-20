#pragma semicolon 1
#include <sourcemod>

public Plugin:myinfo =
{
        name = "Autorestart",
        author = "[FG] Silent",
        description = "Restarts server at 5:00 am everyday",
        version = "1.0.0",
        url = "www.finalgaming.co.uk",
}

public OnPluginStart()
{
        CreateTimer(60.0, CheckTime, 0, TIMER_REPEAT);
}

public Action:CheckTime(Handle:timer)
{
        decl String:sTime[16];
        new gettime = GetTime();

        FormatTime(sTime, sizeof(sTime), "%H%M", gettime);

        if(sTime == "0500")
        {
                Restart();
        }
        else
        {
                return Plugin_Continue;
        }
}

public Restart()
{
        ServerCommand("_restart"),
        LogAction(0, -1, "Gameserver was restarted successfully.");
}