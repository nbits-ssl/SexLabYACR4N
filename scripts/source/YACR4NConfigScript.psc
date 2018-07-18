Scriptname YACR4NConfigScript extends SKI_ConfigBase  

bool Property modEnabled = true Auto
bool Property debugLogFlag = false Auto

bool Property enableEndlessRape = true Auto
int Property rapeChance = 50 Auto
int Property healthLimit = 50 Auto

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

YACRUtil Property AppUtil Auto

int Function GetVersion()
	return AppUtil.GetVersion()
EndFunction 