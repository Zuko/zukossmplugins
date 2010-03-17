#pragma semicolon 1
#include <sourcemod>
#if !defined FCVAR_DEVELOPMENTONLY
#define FCVAR_DEVELOPMENTONLY (1<<1)
#endif
public OnPluginStart() {
    RegAdminCmd("sm_cvarlist", Command_cvars, ADMFLAG_CONVARS);
    RegAdminCmd("sm_cmdlist", Command_cmds, ADMFLAG_CONVARS);
}
public Action:Command_cvars(client, args) {
    decl String:name[64], String:value[64];
    new Handle:cvar, bool:isCommand, flags;
    cvar = FindFirstConCommand(name, sizeof(name), isCommand, flags);
    if(cvar==INVALID_HANDLE) {
        PrintToConsole(client, "Could not load cvar list");
        return Plugin_Handled;
    }
    do {
        if(isCommand || !(flags & FCVAR_DEVELOPMENTONLY)) {
            continue;
        }
        // GetConVarString(FindConVar(name), value, sizeof(value));
        PrintToConsole(client, "%s", name);
    } while(FindNextConCommand(cvar, name, sizeof(name), isCommand, flags));
    return Plugin_Handled;
}
public Action:Command_cmds(client, args) {
    decl String:name[64];
    new Handle:cvar, bool:isCommand, flags;
    cvar = FindFirstConCommand(name, sizeof(name), isCommand, flags);
    if(cvar==INVALID_HANDLE) {
        PrintToConsole(client, "Could not load cvar list");
        return Plugin_Handled;
    }
    do {
        if(!isCommand || !(flags & FCVAR_DEVELOPMENTONLY)) {
            continue;
        }
        PrintToConsole(client, "%s", name);
        flags &= ~FCVAR_DEVELOPMENTONLY;
        SetCommandFlags(name, flags);
    } while(FindNextConCommand(cvar, name, sizeof(name), isCommand, flags));
    return Plugin_Handled;
}  