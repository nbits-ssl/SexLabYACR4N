Scriptname YACR4NConfigScript extends SKI_ConfigBase  

bool Property modEnabled = true Auto
bool Property markerEnabled = false Auto
bool Property debugLogFlag = false Auto
int Property updatePeriod = 15 Auto

bool Property enableEndlessRape = true Auto
int Property rapeChance = 100 Auto
int Property healthLimit = 100 Auto

int Property rapeChanceFollower = 50 Auto
int Property healthLimitFollower = 50 Auto
bool Property linkArousal = true Auto

int Property matchedSex = 0 Auto
bool Property enableDrippingWASupport = false Auto ; not use from 1.1

Race[] Property DisableRaces  Auto  
Bool[] Property DisableRacesConfig  Auto  

int modEnabledID
int markerEnabledID

int debugLogFlagID
int updatePeriodID
int searchDistanceID

int enableEndlessRapeID
int rapeChanceID
int healthLimitID

int rapeChanceFollowerID
int healthLimitFollowerID
int linkArousalID

int matchedSexID
int enableDrippingWASupportID ; not use from 1.1

int configSaveID
int configLoadID

string configFileName = "../SexLabYACR4NPCConfig.json"


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
			(YACR4NQuestManager as YACR4NInit).Reboot()
			debug.notification("SexLab YACR for NPC updated to [" + a_version + "], rebooted.")
		else
			debug.notification("SexLab YACR for NPC updated to [" + a_version + "], but disabled.")
		endif
	endif
EndEvent

Event OnConfigInit()
	Pages = new string[4]
	Pages[0] = "$YACR4N_General"
	Pages[1] = "$YACR4N_Enemy"
	Pages[2] = "$YACR4N_Status"
	Pages[3] = "$YACR4N_Profile"
	
	matchedSexList = new string[3]
	matchedSexList[0] = "$YACR4N_SexStraight"
	matchedSexList[1] = "$YACR4N_SexBoth"
	matchedSexList[2] = "$YACR4N_SexHomo"
	
	disableEnemyRacesIDS = new int[20]
EndEvent

Event OnPageReset(string page)
	if (page == "" || page == "$YACR4N_General")
		SetCursorFillMode(TOP_TO_BOTTOM)
		SetCursorPosition(0)
		AddHeaderOption("$YACR4N_GeneralConfig")

		updatePeriodID = AddSliderOption("$YACR4N_UpdatePeriod", updatePeriod)
		searchDistanceID = AddSliderOption("$YACR4N_SearchDistance", YACR4NDistance.GetValue() as int)
		matchedSexID = AddMenuOption("$YACR4N_MatchedSex", matchedSexList[matchedSex])

		AddEmptyOption()
		AddEmptyOption()
		AddHeaderOption("$YACR4N_NpcToNpc")

		healthLimitID = AddSliderOption("$YACR4N_HealthLimit", healthLimit)
		rapeChanceID = AddSliderOption("$YACR4N_RapeChance", rapeChance)
		enableEndlessRapeID = AddToggleOption("$YACR4N_EndlessRape", enableEndlessRape)
		
		SetCursorPosition(1)
		AddHeaderOption("$YACR4N_System")
		
		modEnabledID = AddToggleOption("$YACR4N_ModEnabled", modEnabled)
		markerEnabledID = AddToggleOption("$YACR4N_MarkerEnabled", markerEnabled)
		; enableDrippingWASupportID = AddToggleOption("$YACR4N_EnableDrippingWASupport", enableDrippingWASupport)
		debugLogFlagID = AddToggleOption("$YACR4N_OutputPapyrusLog", debugLogFlag)
		
		AddEmptyOption()
		AddHeaderOption("$YACR4N_FollowerToNpc")
		healthLimitFollowerID = AddSliderOption("$YACR4N_HealthLimit", healthLimitFollower)
		rapeChanceFollowerID = AddSliderOption("$YACR4N_RapeChance", rapeChanceFollower)
		linkArousalID = AddToggleOption("$YACR4N_LinkArousal", linkArousal)
		
	elseif (page == "$YACR4N_Enemy")
		SetCursorFillMode(TOP_TO_BOTTOM)
		SetCursorPosition(0)
		AddHeaderOption("$YACR4N_DisableEnemyRaces")
		
		int len = DisableRaces.Length
		int idx = 0
		string raceName
		while idx != len
			raceName = self.getRaceName(DisableRaces[idx])
			disableEnemyRacesIDS[idx] = AddToggleOption(raceName, DisableRacesConfig[idx])
			idx += 1
		endwhile
	elseif (page == "$YACR4N_Status")
		SetCursorFillMode(TOP_TO_BOTTOM)
		SetCursorPosition(0)
		AddHeaderOption("$YACR4N_MatchedNPC")
		
		Actor act
		ReferenceAlias ref
		int n = 0
		int idx = 1
		int len = MatchedAlias.Length
		
		while n != len
			ref = MatchedAlias[n]
			act = ref.GetActorRef()
			if (act)
				AddTextOption(idx + ". " + act.GetLeveledActorBase().GetName(), "")
				idx += 1
			endif
			n += 1
		endWhile

		SetCursorPosition(1)
		AddHeaderOption("$YACR4N_ActionNPC")
		
		n = 0
		idx = 1
		len = YACR4NScript.Victims.Length
		
		while n != len
			ref = YACR4NScript.Victims[n]
			act = ref.GetActorRef()
			if (act)
				AddTextOption(idx + ". " + act.GetLeveledActorBase().GetName(), "")
				idx += 1
			endif
			n += 1
		endWhile
	elseif (page == "$YACR4N_Profile")
		SetCursorFillMode(TOP_TO_BOTTOM)

		SetCursorPosition(0)
		AddHeaderOption("$YACR4N_Config")
		configSaveID = AddTextOption("$YACR4N_ConfigSave", "$YACR4N_DoIt")
		if (JsonUtil.JsonExists(configFileName))
			configLoadID = AddTextOption("$YACR4N_ConfigLoad", "$YACR4N_DoIt")
		else
			configLoadID = AddTextOption("$YACR4N_ConfigLoad", "$YACR4N_DoIt", OPTION_FLAG_DISABLED)
		endif
	endif
EndEvent

string Function getRaceName(Race srace)
	if (srace == DragonRace)
		return "$YACR4N_DragonRaceName"
	elseif (srace == DLC1VampireBeastRace)
		return "$YACR4N_VampireLoadRaceName"
	elseif (srace == AlduinRace)
		return "$YACR4N_AlduinRaceName"
	endif

	return srace.GetName()
EndFunction

Event OnOptionHighlight(int option)
	if (option == healthLimitID || option == healthLimitFollowerID)
		SetInfoText("$YACR4N_HealthLimitInfo")
	elseif (option == rapeChanceID || option == rapeChanceFollowerID)
		SetInfoText("$YACR4N_RapeChanceInfo")
	elseif (option == enableEndlessRapeID)
		SetInfoText("$YACR4N_EndlessRapeInfo")
	elseif (option == linkArousalID)
		SetInfoText("$YACR4N_LinkArousalInfo")
	elseif (option == matchedSexID)
		SetInfoText("$YACR4N_MatchedSexInfo")
	; elseif (option == enableDrippingWASupportID)
	;	SetInfoText("$YACR4N_EnableDrippingWASupportInfo")
	elseif (option == updatePeriodID)
		SetInfoText("$YACR4N_UpdatePeriodInfo")
	elseif (option == searchDistanceID)
		SetInfoText("$YACR4N_SearchDistanceInfo")
	elseif (option == modEnabledID)
		SetInfoText("$YACR4N_ModEnabledInfo")
	elseif (disableEnemyRacesIDS.Find(option) > -1)
		SetInfoText("$YACR4N_DisableEnemyRacesInfo")

	elseif (option == configSaveID)
		SetInfoText("$YACR4N_ConfigSaveInfo")
	elseif (option == configLoadID)
		SetInfoText("$YACR4N_ConfigLoadInfo")

	endif
EndEvent

Event OnOptionSelect(int option)
	if (option == enableEndlessRapeID)
		enableEndlessRape = !enableEndlessRape
		SetToggleOptionValue(option, enableEndlessRape)
	elseif (option == linkArousalID)
		linkArousal = !linkArousal
		SetToggleOptionValue(option, linkArousal)
	; elseif (option == enableDrippingWASupportID)
	;	enableDrippingWASupport = !enableDrippingWASupport
	;	SetToggleOptionValue(option, enableDrippingWASupport)
	elseif (option == debugLogFlagID)
		debugLogFlag = !debugLogFlag
		SetToggleOptionValue(option, debugLogFlag)
	elseif (option == modEnabledID)
		modEnabled = !modEnabled
		SetToggleOptionValue(option, modEnabled)
		(YACR4NQuestManager as YACR4NInit).Toggle(modEnabled)
		
	elseif (option == markerEnabledID)
		markerEnabled = !markerEnabled
		SetToggleOptionValue(option, markerEnabled)
		YACR4NMarkerQuestScript.Toggle(markerEnabled)
		
	elseif (disableEnemyRacesIDS.Find(option) > -1)
		int idx = disableEnemyRacesIDS.Find(option)
		bool opt = DisableRacesConfig[idx]
		DisableRacesConfig[idx] = !opt
		SetToggleOptionValue(option, !opt)

	elseif (option == configSaveID)
		self.saveConfig(configFileName)
		SetTextOptionValue(option, "$YACR4N_Done")
	elseif (option == configLoadID)
		self.loadConfig(configFileName)
		SetTextOptionValue(option, "$YACR4N_Done")

	endif
EndEvent

Event OnOptionSliderOpen(int option)
	if (option == healthLimitID)
		self._setSliderDialogWithPercentage(healthLimit)
	elseif (option == rapeChanceID)
		self._setSliderDialogWithPercentage(rapeChance)
	elseif (option == rapeChanceFollowerID)
		self._setSliderDialogWithPercentage(rapeChanceFollower)
	elseif (option == healthLimitFollowerID)
		self._setSliderDialogWithPercentage(healthLimitFollower)
	elseif (option == updatePeriodID)
		SetSliderDialogStartValue(updatePeriod)
		SetSliderDialogDefaultValue(15)
		SetSliderDialogRange(5, 240)
		SetSliderDialogInterval(1)
	elseif (option == searchDistanceID)
		SetSliderDialogStartValue(YACR4NDistance.GetValue())
		SetSliderDialogDefaultValue(20000)
		SetSliderDialogRange(1000, 60000)
		SetSliderDialogInterval(500)
	endif
EndEvent

Function _setSliderDialogWithPercentage(int x)
	SetSliderDialogStartValue(x)
	SetSliderDialogRange(0.0, 100.0)
	SetSliderDialogInterval(1.0)
EndFunction

Event OnOptionSliderAccept(int option, float value)
	int ivalue = value as int
	
	if (option == healthLimitID)
		healthLimit = ivalue
	elseif (option == rapeChanceID)
		rapeChance = ivalue
	elseif (option == healthLimitFollowerID)
		healthLimitFollower = ivalue
	elseif (option == rapeChanceFollowerID)
		rapeChanceFollower = ivalue
	elseif (option == updatePeriodID)
		updatePeriod = ivalue
	elseif (option == searchDistanceID)
		YACR4NDistance.SetValue(ivalue)
	endif
	
	SetSliderOptionValue(option, ivalue)
EndEvent

event OnOptionMenuOpen(int option)
	if (option == matchedSexID)
		SetMenuDialogStartIndex(matchedSex)
	endif
	
	SetMenuDialogDefaultIndex(0)
	SetMenuDialogOptions(matchedSexList)
endEvent

event OnOptionMenuAccept(int option, int index)
	if (option == matchedSexID)
		matchedSex = index
		SetMenuOptionValue(option, matchedSexList[matchedSex])
	endif
endEvent

; Profile

Function saveConfig(string configFile)
	JsonUtil.SetIntValue(configFile, "modEnabled", modEnabled as int)
	JsonUtil.SetIntValue(configFile, "markerEnabled", markerEnabled as int)
	JsonUtil.SetIntValue(configFile, "debugLogFlag", debugLogFlag as int)
	JsonUtil.SetIntValue(configFile, "updatePeriod", updatePeriod)

	JsonUtil.SetIntValue(configFile, "enableEndlessRape", enableEndlessRape as int)
	JsonUtil.SetIntValue(configFile, "rapeChance", rapeChance)
	JsonUtil.SetIntValue(configFile, "healthLimit", healthLimit)

	JsonUtil.SetIntValue(configFile, "rapeChanceFollower", rapeChanceFollower)
	JsonUtil.SetIntValue(configFile, "healthLimitFollower", healthLimitFollower)
	JsonUtil.SetIntValue(configFile, "linkArousal", linkArousal as int)

	JsonUtil.SetIntValue(configFile, "matchedSex", matchedSex)
	; JsonUtil.SetIntValue(configFile, "enableDrippingWASupport", enableDrippingWASupport as int)
	
	JsonUtil.SetIntValue(configFile, "YACR4NDistance", YACR4NDistance.GetValue() as int)
	ExportBoolList(configFile, "DisableRacesConfig", DisableRacesConfig, DisableRacesConfig.Length)
	JsonUtil.Save(configFile)
EndFunction

Function loadConfig(string configFile)
	modEnabled = JsonUtil.GetIntValue(configFile, "modEnabled")
	markerEnabled = JsonUtil.GetIntValue(configFile, "markerEnabled")
	debugLogFlag = JsonUtil.GetIntValue(configFile, "debugLogFlag")
	updatePeriod = JsonUtil.GetIntValue(configFile, "updatePeriod")

	enableEndlessRape = JsonUtil.GetIntValue(configFile, "enableEndlessRape")
	rapeChance = JsonUtil.GetIntValue(configFile, "rapeChance")
	healthLimit = JsonUtil.GetIntValue(configFile, "healthLimit")

	rapeChanceFollower = JsonUtil.GetIntValue(configFile, "rapeChanceFollower")
	healthLimitFollower = JsonUtil.GetIntValue(configFile, "healthLimitFollower")
	linkArousal = JsonUtil.GetIntValue(configFile, "linkArousal")

	matchedSex = JsonUtil.GetIntValue(configFile, "matchedSex")
	; enableDrippingWASupport = JsonUtil.GetIntValue(configFile, "enableDrippingWASupport")

	YACR4NDistance.SetValue(JsonUtil.GetIntValue(configFile, "YACR4NDistance"))
	ImportBoolList(configFile, "DisableRacesConfig", DisableRacesConfig, DisableRacesConfig.Length)
EndFunction

; Boolean Arrays from SexLab
function ExportBoolList(string FileName, string Name, bool[] Values, int len)
	JsonUtil.IntListClear(FileName, Name)
	int i
	while i < len
		JsonUtil.IntListAdd(FileName, Name, Values[i] as int)
		i += 1
	endWhile
endFunction
bool[] function ImportBoolList(string FileName, string Name, bool[] Values, int len)
	if JsonUtil.IntListCount(FileName, Name) == len
		if Values.Length != len
			Values = Utility.CreateBoolArray(len)
		endIf
		int i
		while i < len
			Values[i] = JsonUtil.IntListGet(FileName, Name, i) as bool
			i += 1
		endWhile
	endIf
	return Values
endFunction


YACR4NQuest Property YACR4NScript  Auto 
YACR4NMarkerScript Property YACR4NMarkerQuestScript  Auto 
Quest Property YACR4NQuestManager  Auto
ReferenceAlias[] Property MatchedAlias  Auto  
GlobalVariable Property YACR4NDistance  Auto  

Race Property DragonRace  Auto  
Race Property DLC1VampireBeastRace  Auto  
Race Property AlduinRace  Auto  

