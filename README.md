# Open Fortress Class Restrictions

Open Fortress port of TF2 Class Restrictions plugin by Tsunami: https://forums.alliedmods.net/showthread.php?p=642353

Only supports TDM for now, FFA support to come later/by request.

## Configuration

Enable/disable restricting classes in OF.  
`sm_classrestrict_enabled` (0/1, default 1)

Admin flags for restricted classes in OF.  
`sm_classrestrict_flags` (default "")

Enable/disable admins being immune for restricted classes in OF.  
`sm_classrestrict_immunity` (0/1, default 0)

Limits for Blu classes in OF. (-1 for no limit, anything higher will be the limit for that class. Default -1)
`sm_classrestrict_blu_demomen`  
`sm_classrestrict_blu_engineers`  
`sm_classrestrict_blu_heavies`  
`sm_classrestrict_blu_medics`  
`sm_classrestrict_blu_pyros`  
`sm_classrestrict_blu_scouts`  
`sm_classrestrict_blu_snipers`  
`sm_classrestrict_blu_soldiers`  
`sm_classrestrict_blu_spies`  
`sm_classrestrict_blu_mercenaries`  
`sm_classrestrict_blu_civilians`  

Limits for Red classes in OF.  
`sm_classrestrict_red_demomen`  
`sm_classrestrict_red_engineers`  
`sm_classrestrict_red_heavies`  
`sm_classrestrict_red_medics`  
`sm_classrestrict_red_pyros`  
`sm_classrestrict_red_scouts`  
`sm_classrestrict_red_snipers`  
`sm_classrestrict_red_soldiers`  
`sm_classrestrict_red_spies`  
`sm_classrestrict_red_mercenaries`  
`sm_classrestrict_red_civilians`  

You can put any of these cvars in server.cfg or sourcemod.cfg, and then if you want map specific cvars you can make a file called mapname.cfg (for example cp_dustbowl.cfg) and put those cvars in there.