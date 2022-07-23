#include <sourcemod>
#include <sdktools>
#include <openfortress>

#pragma newdecls required
#pragma semicolon 1

#define PL_VERSION "1.0.0"

#define TF_CLASS_DEMOMAN 4
#define TF_CLASS_ENGINEER 9
#define TF_CLASS_HEAVY 6
#define TF_CLASS_MEDIC 5
#define TF_CLASS_PYRO 7
#define TF_CLASS_SCOUT 1
#define TF_CLASS_SNIPER 2
#define TF_CLASS_SOLDIER 3
#define TF_CLASS_SPY 8
#define TF_CLASS_MERCENARY 10
#define TF_CLASS_CIVILIAN 11
#define TF_CLASS_UNKNOWN 0

#define TF_TEAM_BLU 3
#define TF_TEAM_RED 2

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
ConVar g_hFlags;
ConVar g_hImmunity;
ConVar g_hLimits[4][12];
char g_sSounds[12][24] = {
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
    "vo/mercenary_no02.wav" // Civilian does not have a no voiceline, just use the merc's
};

public void OnPluginStart()
{
    g_hTeamplay = FindConVar("mp_teamplay");
    g_hForceClass = FindConVar("of_forceclass");

    CreateConVar("sm_classrestrict_version", PL_VERSION, "Restrict classes in OF.", FCVAR_NOTIFY);
    g_hEnabled = CreateConVar("sm_classrestrict_enabled", "1",  "Enable/disable restricting classes in OF.");
    g_hFlags = CreateConVar("sm_classrestrict_flags", "", "Admin flags for restricted classes in OF.");
    g_hImmunity = CreateConVar("sm_classrestrict_immunity", "0", "Enable/disable admins being immune for restricted classes in OF.");

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

    HookEvent("player_changeclass", Event_PlayerClass);
    HookEvent("player_spawn", Event_PlayerSpawn);
    HookEvent("player_team", Event_PlayerTeam);
}

public bool IsEnabled()
{
    return g_hEnabled.BoolValue && g_hTeamplay.BoolValue && !g_hForceClass.BoolValue;
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

public void Event_PlayerClass(Event event, const char[] name, bool dontBroadcast)
{
    if (!IsEnabled())
    {
        return;
    }

    PrintToServer("In Event_PlayerClass");

    int iClient = GetClientOfUserId(event.GetInt("userid"));
    int iClass = event.GetInt("class");
    int iTeam = GetClientTeam(iClient);

    if (!(g_hImmunity.BoolValue && IsImmune(iClient)) && IsFull(iTeam, iClass))
    {
        ShowVGUIPanel(iClient, iTeam == TF_TEAM_BLU ? "class_blue" : "class_red");
        EmitSoundToClient(iClient, g_sSounds[iClass]);
        TF2_SetPlayerClass(iClient, view_as<TFClassType>(g_iClass[iClient]));
    }
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    if (!IsEnabled())
    {
        return;
    }

    PrintToServer("In Event_PlayerSpawn");

    int iClient = GetClientOfUserId(event.GetInt("userid"));
    int iTeam = GetClientTeam(iClient);

    if (!(g_hImmunity.BoolValue && IsImmune(iClient)) && IsFull(iTeam, (g_iClass[iClient] = view_as<int>(TF2_GetPlayerClass(iClient)))))
    {
        ShowVGUIPanel(iClient, iTeam == TF_TEAM_BLU ? "class_blue" : "class_red");
        EmitSoundToClient(iClient, g_sSounds[g_iClass[iClient]]);
        PickClass(iClient);
    }
}

public void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
    if (!IsEnabled())
    {
        return;
    }

    PrintToServer("In Event_PlayerTeam");

    int iClient = GetClientOfUserId(event.GetInt("userid"));
    int iTeam = event.GetInt("team");

    if (!(g_hImmunity.BoolValue && IsImmune(iClient)) && IsFull(iTeam, g_iClass[iClient]))
    {
        ShowVGUIPanel(iClient, iTeam == TF_TEAM_BLU ? "class_blue" : "class_red");
        EmitSoundToClient(iClient, g_sSounds[g_iClass[iClient]]);
        PickClass(iClient);
    }
}

bool IsFull(int iTeam, int iClass)
{
    // If plugin is disabled, or team or class is invalid, class is not full
    if (iTeam < TF_TEAM_RED || iClass < TF_CLASS_SCOUT)
    {
        return false;
    }

    PrintToServer("In IsFull");

    // Get team's class limit
    int iLimit;
    float flLimit = g_hLimits[iTeam][iClass].FloatValue;

    // If limit is a percentage, calculate real limit
    if (flLimit > 0.0 && flLimit < 1.0)
    {
        iLimit = RoundToNearest(flLimit * GetTeamClientCount(iTeam));
    }
    else
    {
        iLimit = RoundToNearest(flLimit);
    }

    // If limit is -1, class is not full
    if (iLimit == -1)
    {
        return false;
    }

    // If limit is 0, class is full
    if (iLimit == 0)
    {
        return true;
    }

    // Loop through all clients
    for (int i = 1, iCount = 0; i <= MaxClients; i++)
    {
        // If client is in game, on this team, has this class and limit has been reached, class is full
        if (IsClientInGame(i) && GetClientTeam(i) == iTeam && view_as<int>(TF2_GetPlayerClass(i)) == iClass && ++iCount > iLimit)
        {
            return true;
        }
    }

    return false;
}

bool IsImmune(int iClient)
{
    if (!iClient || !IsClientInGame(iClient))
    {
        return false;
    }

    PrintToServer("In IsImmune");

    char sFlags[32];
    g_hFlags.GetString(sFlags, sizeof(sFlags));

    // If flags are specified and client has generic or root flag, client is immune
    return !StrEqual(sFlags, "") && CheckCommandAccess(iClient, "classrestrict", ReadFlagString(sFlags));
}

void PickClass(int iClient)
{
    PrintToServer("In PickClass");

    // Loop through all classes, starting at random class
    for (int i = GetRandomInt(TF_CLASS_SCOUT, TF_CLASS_CIVILIAN), iClass = i, iTeam = GetClientTeam(iClient);;)
    {
        // If team's class is not full, set client's class
        if (!IsFull(iTeam, i))
        {
            TF2_SetPlayerClass(iClient, view_as<TFClassType>(i));
            TF2_RespawnPlayer(iClient);
            g_iClass[iClient] = i;
            break;
        }
        // If next class index is invalid, start at first class
        else if (++i > TF_CLASS_CIVILIAN)
        {
            i = TF_CLASS_SCOUT;
        }
        // If loop has finished, stop searching
        else if (i == iClass)
        {
            break;
        }
    }
}
