#include <sourcemod>
#include <sdktools>
#include <openfortress>

#pragma newdecls required
#pragma semicolon 1

#define PL_VERSION "1.2.0"

#define TF_CLASS_SCOUT 1
#define TF_CLASS_SNIPER 2
#define TF_CLASS_SOLDIER 3
#define TF_CLASS_DEMOMAN 4
#define TF_CLASS_MEDIC 5
#define TF_CLASS_HEAVY 6
#define TF_CLASS_PYRO 7
#define TF_CLASS_SPY 8
#define TF_CLASS_ENGINEER 9
#define TF_CLASS_MERCENARY 10
#define TF_CLASS_CIVILIAN 11
#define TF_CLASS_JUGGERNAUT 12
#define TF_CLASS_UNKNOWN 0

#define FIRST_CLASS TF_CLASS_SCOUT
#define LAST_CLASS TF_CLASS_JUGGERNAUT

#define TF_TEAM_UNASSIGNED 0
#define TF_TEAM_SPEC 1
#define TF_TEAM_RED 2
#define TF_TEAM_BLU 3

public Plugin myinfo =
{
    name = "OF Class Restrictions",
    author = "Tsunami (Original), Fraeven (OF Conversion)",
    description = "Restrict classes in OF.",
    version = PL_VERSION,
    url = "https://scg.wtf"
}

int g_iClass[MAXPLAYERS + 1];
ConVar g_hEnabled;
ConVar g_hTeamplay;
ConVar g_hForceClass;
ConVar g_hLimits[4][13];
char g_sSounds[13][36] = {
    "",
    "vo/scout_no03.mp3",
    "vo/sniper_no04.mp3",
    "vo/soldier_no01.mp3",
    "vo/demoman_no03.mp3",
    "vo/medic_no03.mp3",
    "vo/heavy_no02.mp3",
    "vo/pyro_no01.mp3",
    "vo/spy_no02.mp3",
    "vo/engineer_no03.mp3",
    "vo/mercenary_no02.wav",
    "vo/civilian_painsevere06.wav",
    "vo/civilian_painsevere06.wav"
};
char g_sClassNames[13][24] = {
    "",
    "Scout",
    "Sniper",
    "Soldier",
    "Demoman",
    "Medic",
    "Heavy",
    "Pyro",
    "Spy",
    "Engineer",
    "Mercenary",
    "Civilian",
    "Juggernaut"
};

public void OnPluginStart()
{
    g_hTeamplay = FindConVar("mp_teamplay");
    g_hForceClass = FindConVar("of_forceclass");

    CreateConVar("sm_classrestrict_version", PL_VERSION, "Restrict classes in OF.", FCVAR_NOTIFY);
    g_hEnabled = CreateConVar("sm_classrestrict_enabled", "1",  "Enable/disable restricting classes in OF.");

    // Any team limits
    g_hLimits[TF_TEAM_UNASSIGNED][TF_CLASS_DEMOMAN] = CreateConVar("sm_classrestrict_demomen", "-1", "Limit for demomen in OF.");
    g_hLimits[TF_TEAM_UNASSIGNED][TF_CLASS_ENGINEER] = CreateConVar("sm_classrestrict_engineers", "-1", "Limit for engineers in OF.");
    g_hLimits[TF_TEAM_UNASSIGNED][TF_CLASS_HEAVY] = CreateConVar("sm_classrestrict_heavies", "-1", "Limit for heavies in OF.");
    g_hLimits[TF_TEAM_UNASSIGNED][TF_CLASS_MEDIC] = CreateConVar("sm_classrestrict_medics", "-1", "Limit for medics in OF.");
    g_hLimits[TF_TEAM_UNASSIGNED][TF_CLASS_PYRO] = CreateConVar("sm_classrestrict_pyros", "-1", "Limit for pyros in OF.");
    g_hLimits[TF_TEAM_UNASSIGNED][TF_CLASS_SCOUT] = CreateConVar("sm_classrestrict_scouts", "-1", "Limit for scouts in OF.");
    g_hLimits[TF_TEAM_UNASSIGNED][TF_CLASS_SNIPER] = CreateConVar("sm_classrestrict_snipers", "-1", "Limit for snipers in OF.");
    g_hLimits[TF_TEAM_UNASSIGNED][TF_CLASS_SOLDIER] = CreateConVar("sm_classrestrict_soldiers", "-1", "Limit for soldiers in OF.");
    g_hLimits[TF_TEAM_UNASSIGNED][TF_CLASS_SPY] = CreateConVar("sm_classrestrict_spies", "-1", "Limit for spies in OF.");
    g_hLimits[TF_TEAM_UNASSIGNED][TF_CLASS_MERCENARY] = CreateConVar("sm_classrestrict_mercenaries", "-1", "Limit for mercenaries in OF.");
    g_hLimits[TF_TEAM_UNASSIGNED][TF_CLASS_CIVILIAN] = CreateConVar("sm_classrestrict_civilians", "-1", "Limit for civilians in OF.");
    g_hLimits[TF_TEAM_UNASSIGNED][TF_CLASS_JUGGERNAUT] = CreateConVar("sm_classrestrict_juggernauts", "-1", "Limit for juggernauts in OF.");

    // Team-specific overrides
    g_hLimits[TF_TEAM_BLU][TF_CLASS_DEMOMAN] = CreateConVar("sm_classrestrict_blu_demomen", "-1", "Limit for Blu demomen in OF.");
    g_hLimits[TF_TEAM_BLU][TF_CLASS_ENGINEER] = CreateConVar("sm_classrestrict_blu_engineers", "-1", "Limit for Blu engineers in OF.");
    g_hLimits[TF_TEAM_BLU][TF_CLASS_HEAVY] = CreateConVar("sm_classrestrict_blu_heavies", "-1", "Limit for Blu heavies in OF.");
    g_hLimits[TF_TEAM_BLU][TF_CLASS_MEDIC] = CreateConVar("sm_classrestrict_blu_medics", "-1", "Limit for Blu medics in OF.");
    g_hLimits[TF_TEAM_BLU][TF_CLASS_PYRO] = CreateConVar("sm_classrestrict_blu_pyros", "-1", "Limit for Blu pyros in OF.");
    g_hLimits[TF_TEAM_BLU][TF_CLASS_SCOUT] = CreateConVar("sm_classrestrict_blu_scouts", "-1", "Limit for Blu scouts in OF.");
    g_hLimits[TF_TEAM_BLU][TF_CLASS_SNIPER] = CreateConVar("sm_classrestrict_blu_snipers", "-1", "Limit for Blu snipers in OF.");
    g_hLimits[TF_TEAM_BLU][TF_CLASS_SOLDIER] = CreateConVar("sm_classrestrict_blu_soldiers", "-1", "Limit for Blu soldiers in OF.");
    g_hLimits[TF_TEAM_BLU][TF_CLASS_SPY] = CreateConVar("sm_classrestrict_blu_spies", "-1", "Limit for Blu spies in OF.");
    g_hLimits[TF_TEAM_BLU][TF_CLASS_MERCENARY] = CreateConVar("sm_classrestrict_blu_mercenaries", "-1", "Limit for Blu mercenaries in OF.");
    g_hLimits[TF_TEAM_BLU][TF_CLASS_CIVILIAN] = CreateConVar("sm_classrestrict_blu_civilians", "-1", "Limit for Blu civilians in OF.");
    g_hLimits[TF_TEAM_BLU][TF_CLASS_JUGGERNAUT] = CreateConVar("sm_classrestrict_blu_juggernauts", "-1", "Limit for Blu juggernauts in OF.");

    g_hLimits[TF_TEAM_RED][TF_CLASS_DEMOMAN] = CreateConVar("sm_classrestrict_red_demomen", "-1", "Limit for Red demomen in OF.");
    g_hLimits[TF_TEAM_RED][TF_CLASS_ENGINEER] = CreateConVar("sm_classrestrict_red_engineers", "-1", "Limit for Red engineers in OF.");
    g_hLimits[TF_TEAM_RED][TF_CLASS_HEAVY] = CreateConVar("sm_classrestrict_red_heavies", "-1", "Limit for Red heavies in OF.");
    g_hLimits[TF_TEAM_RED][TF_CLASS_MEDIC] = CreateConVar("sm_classrestrict_red_medics", "-1", "Limit for Red medics in OF.");
    g_hLimits[TF_TEAM_RED][TF_CLASS_PYRO] = CreateConVar("sm_classrestrict_red_pyros", "-1", "Limit for Red pyros in OF.");
    g_hLimits[TF_TEAM_RED][TF_CLASS_SCOUT] = CreateConVar("sm_classrestrict_red_scouts", "-1", "Limit for Red scouts in OF.");
    g_hLimits[TF_TEAM_RED][TF_CLASS_SNIPER] = CreateConVar("sm_classrestrict_red_snipers", "-1", "Limit for Red snipers in OF.");
    g_hLimits[TF_TEAM_RED][TF_CLASS_SOLDIER] = CreateConVar("sm_classrestrict_red_soldiers", "-1", "Limit for Red soldiers in OF.");
    g_hLimits[TF_TEAM_RED][TF_CLASS_SPY] = CreateConVar("sm_classrestrict_red_spies", "-1", "Limit for Red spies in OF.");
    g_hLimits[TF_TEAM_RED][TF_CLASS_MERCENARY] = CreateConVar("sm_classrestrict_red_mercenaries", "-1", "Limit for Red mercenaries in OF.");
    g_hLimits[TF_TEAM_RED][TF_CLASS_CIVILIAN] = CreateConVar("sm_classrestrict_red_civilians", "-1", "Limit for Red civilians in OF.");
    g_hLimits[TF_TEAM_RED][TF_CLASS_JUGGERNAUT] = CreateConVar("sm_classrestrict_red_juggernauts", "-1", "Limit for Red juggernauts in OF.");

    HookEvent("player_team", Event_PlayerTeam);
    AddCommandListener(Command_JoinClass, "joinclass");

    for (int client = 1; client <= MaxClients; client++)
    {
        // If client is in game, on this team, has this class and limit has been reached, class is full
        if (IsValidClient(client))
        {
            g_iClass[client] = view_as<int>(TF2_GetPlayerClass(client));
        }
    }
}

public bool IsEnabled()
{
    return g_hEnabled.BoolValue && !g_hForceClass.BoolValue;
}

public bool IsTeamplay()
{
    return g_hTeamplay.BoolValue;
}

bool IsValidClient(int client)
{
    if (!client || client > MaxClients || client < 1)
    {
        return false;
    }

    if (!IsClientInGame(client))
    {
        return false;
    }

    return true;
}

public void OnMapStart()
{
    char sSound[32];
    for (int i = 1; i < sizeof(g_sSounds); i++)
    {
        Format(sSound, sizeof(sSound), "sound/%s", g_sSounds[i]);
        PrecacheSound(g_sSounds[i]);
    }
}

public void OnClientPutInServer(int client)
{
    g_iClass[client] = TF_CLASS_UNKNOWN;
}

public int GetLimit(int team, int class)
{
    // If plugin is disabled, or team or class is invalid, class is not full
    if (team < TF_TEAM_RED || class < FIRST_CLASS || class > LAST_CLASS)
    {
        return -1;
    }

    // Get team's class limit
    int iLimit;
    float flLimit = g_hLimits[TF_TEAM_UNASSIGNED][class].FloatValue;

    // Use team-specific limit if it is set
    if (team == TF_TEAM_RED || team == TF_TEAM_BLU)
    {
        float flTeamLimit = g_hLimits[team][class].FloatValue;
        flLimit = flTeamLimit == -1.0 ? flLimit : flTeamLimit;
    }

    // If limit is a percentage, calculate real limit
    if (flLimit > 0.0 && flLimit < 1.0)
    {
        iLimit = RoundToNearest(flLimit * GetTeamClientCount(team));
    }
    else
    {
        iLimit = RoundToNearest(flLimit);
    }

    return iLimit;
}

public int GetCurrent(int team, int class)
{
    int current = 0;
    // Loop through all clients
    for (int i = 1; i <= MaxClients; i++)
    {
        // If client is in game, on this team, has this class and limit has been reached, class is full
        if (IsValidClient(i) && GetClientTeam(i) == team && view_as<int>(TF2_GetPlayerClass(i)) == class)
        {
            current++;
        }
    }

    return current;
}

public Action Command_JoinClass(int client, const char[] command, int argc)
{
    if (!IsEnabled())
    {
        return Plugin_Continue;
    }

    char class_string[64];
    GetCmdArg(1, class_string, 64);

    int class = TF_CLASS_UNKNOWN;
    if (StrEqual(class_string, "scout"))
    {
        class = TF_CLASS_SCOUT;
    }
    else if (StrEqual(class_string, "sniper"))
    {
        class = TF_CLASS_SNIPER;
    }
    else if (StrEqual(class_string, "soldier"))
    {
        class = TF_CLASS_SOLDIER;
    }
    else if (StrEqual(class_string, "demoman"))
    {
        class = TF_CLASS_DEMOMAN;
    }
    else if (StrEqual(class_string, "medic"))
    {
        class = TF_CLASS_MEDIC;
    }
    else if (StrEqual(class_string, "heavyweapons"))
    {
        class = TF_CLASS_HEAVY;
    }
    else if (StrEqual(class_string, "pyro"))
    {
        class = TF_CLASS_PYRO;
    }
    else if (StrEqual(class_string, "spy"))
    {
        class = TF_CLASS_SPY;
    }
    else if (StrEqual(class_string, "engineer"))
    {
        class = TF_CLASS_ENGINEER;
    }
    else if (StrEqual(class_string, "mercenary"))
    {
        class = TF_CLASS_MERCENARY;
    }
    else if (StrEqual(class_string, "civilian"))
    {
        class = TF_CLASS_CIVILIAN;
    }
    else if (StrEqual(class_string, "juggernaut"))
    {
        class = TF_CLASS_JUGGERNAUT;
    }
    else
    {
        return Plugin_Continue;
    }

    if (IsPlayerAlive(client) && class == view_as<int>(TF2_GetPlayerClass(client)))
    {
        return Plugin_Continue;
    }

    int team = GetClientTeam(client);
    int limit = GetLimit(team, class);
    int current = GetCurrent(team, class);

    if (IsFull(current, limit))
    {
        ShowVGUIPanel(client, "class");
        EmitSoundToClient(client, g_sSounds[class]);
        TF2_SetPlayerClass(client, view_as<TFClassType>(g_iClass[client]));
        PrintRestrictedMessage(client, current, limit, class);
        return Plugin_Handled;
    }

    return Plugin_Continue;
}

public void PrintRestrictedMessage(int client, int current, int limit, int class)
{
    if (limit == 0)
    {
        PrintCenterText(client, "Cannot switch to %s, this class is restricted.", g_sClassNames[class]);
    }
    else
    {
        PrintCenterText(client, "Cannot switch to %s, class limit %i/%i reached.", g_sClassNames[class], current, limit);
    }

}

public void OF_OnPlayerSpawned(int client)
{
    if (!IsEnabled())
    {
        return;
    }

    int team = GetClientTeam(client);
    int class = view_as<int>(TF2_GetPlayerClass(client));
    g_iClass[client] = class;
    int limit = GetLimit(team, class);
    int current = GetCurrent(team, class) - 1; // subtract after spawning to not count yourself

    if (IsFull(current, limit))
    {
        ShowVGUIPanel(client, "class");
        EmitSoundToClient(client, g_sSounds[g_iClass[client]]);
        PickClass(client);
        PrintRestrictedMessage(client, current, limit, class);
    }
}

public void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
    if (!IsEnabled())
    {
        return;
    }

    int client = GetClientOfUserId(event.GetInt("userid"));
    int team = event.GetInt("team");
    int class = g_iClass[client];
    int limit = GetLimit(team, class);
    int current = GetCurrent(team, class);

    if (IsFull(current, limit))
    {
        ShowVGUIPanel(client, "class");
        EmitSoundToClient(client, g_sSounds[g_iClass[client]]);
        PickClass(client);
        PrintRestrictedMessage(client, current, limit, class);
    }
}

bool IsFull(int current, int limit)
{
    if (limit == -1)
    {
        return false;
    }

    if (limit == 0)
    {
        return true;
    }

    if (current >= limit)
    {
        return true;
    }

    return false;
}

void PickClass(int iClient)
{
    // Loop through all classes, starting at random class
    for (int i = GetRandomInt(FIRST_CLASS, LAST_CLASS), iClass = i, iTeam = GetClientTeam(iClient);;)
    {
        int limit = GetLimit(iTeam, i);
        int current = GetCurrent(iTeam, i);
        // If team's class is not full, set client's class
        if (!IsFull(current, limit))
        {
            TF2_SetPlayerClass(iClient, view_as<TFClassType>(i));
            TF2_RespawnPlayer(iClient);
            g_iClass[iClient] = i;
            break;
        }
        // If next class index is invalid, start at first class
        else if (++i > LAST_CLASS)
        {
            i = FIRST_CLASS;
        }
        // If loop has finished, stop searching
        else if (i == iClass)
        {
            break;
        }
    }
}