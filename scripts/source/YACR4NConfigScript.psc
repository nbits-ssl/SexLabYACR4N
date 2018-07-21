Scriptname YACR4NConfigScript extends SKI_ConfigBase  

bool Property modEnabled = true Auto
bool Property debugLogFlag = false Auto

bool Property enableEndlessRape = true Auto
int Property rapeChance = 100 Auto
int Property healthLimit = 100 Auto

int Property matchedSex = 0 Auto
bool Property enableDrippingWASupport = false Auto

Race[] Property DisableRaces  Auto  
Bool[] Property DisableRacesConfig  Auto  

int enableDisableID
int debugLogFlagID

int enableEndlessRapeID
int rapeChanceID
int healthLimitID

int matchedSexID
int enableDrippingWASupportID

int[] disableEnemyRacesIDS
string[] matchedSexList

YACR4NUtil Property AppUtil Auto

int Function GetVersion()
	return AppUtil.GetVersion()
EndFunction

Event OnVersionUpdate(int a_version)
	if (CurrentVersion == 0) ; new game
		debug.notification("SexLab YACR for NPC [" + a_version + "] installed.")
	elseif (a_version != CurrentVersion)
		OnConfigInit()
		if (self.modEnabled)
			; (SSLYACRQuestManager as YACRInit).Reboot()
			debug.notification("SexLab YACR for NPC updated to [" + a_version + "], rebooted.")
		else
			debug.notification("SexLab YACR for NPC updated to [" + a_version + "], but disabled.")
		endif
	endif
EndEvent

Event OnConfigInit()
	Pages = new string[4]
	Pages[0] = "$YACR4N_General"
	Pages[1] = "$YACR4N_Debug"
EndEvent

Event OnPageReset(string page)
	if (page == "" || page == "$YACR4N_General")
	elseif (page == "$YACR4N_Debug")
	endif
EndEvent