Scriptname YACR4NConfigScript extends SKI_ConfigBase  

bool Property modEnabled = true Auto
bool Property debugLogFlag = false Auto
int Property updatePeriod = 15 Auto

bool Property enableEndlessRape = true Auto
int Property rapeChance = 100 Auto
int Property healthLimit = 100 Auto

int Property matchedSex = 0 Auto
bool Property enableDrippingWASupport = false Auto

Race[] Property DisableRaces  Auto  
Bool[] Property DisableRacesConfig  Auto  

int enableDisableID
int debugLogFlagID
int updatePeriodID

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
	Pages[1] = "$YACR4N_Status"
	
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

		AddEmptyOption()

		matchedSexID = AddMenuOption("$YACR4N_MatchedSex", matchedSexList[matchedSex])
		healthLimitID = AddSliderOption("$YACR4N_HealthLimit", healthLimit)
		rapeChanceID = AddSliderOption("$YACR4N_RapeChance", rapeChance)
		enableEndlessRapeID = AddToggleOption("$YACR4N_EndlessRape", enableEndlessRape)
		
		AddEmptyOption()
	
		enableDrippingWASupportID = AddToggleOption("$YACR4N_EnableDrippingWASupport", enableDrippingWASupport)
		debugLogFlagID = AddToggleOption("$YACR4N_OutputPapyrusLog", debugLogFlag)
		
		AddEmptyOption()
		
		SetCursorPosition(1)
		AddHeaderOption("$YACR4N_DisableEnemyRaces")
		
		int len = DisableRaces.Length
		int idx = 0
		string raceName
		while idx != len
			raceName = DisableRaces[idx].GetName()
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
		int len = MatchedAlias.Length
		
		while n != len
			ref = MatchedAlias[n]
			act = ref.GetActorRef()
			if (act)
				AddTextOption(n + 1 + ". " + act.GetActorBase().GetName(), "")
			endif
			n += 1
		endWhile

		SetCursorPosition(1)
		AddHeaderOption("$YACR4N_ActionNPC")
		
		n = 0
		len = YACR4NScript.Victims.Length
		
		while n != len
			ref = YACR4NScript.Victims[n]
			act = ref.GetActorRef()
			if (act)
				AddTextOption(n + 1 + ". " + act.GetActorBase().GetName(), "")
			endif
			n += 1
		endWhile
	endif
EndEvent

Event OnOptionHighlight(int option)
	if (option == healthLimitID)
		SetInfoText("$YACR4N_HealthLimitInfo")
	elseif (option == rapeChanceID)
		SetInfoText("$YACR4N_RapeChanceInfo")
	elseif (option == enableEndlessRapeID)
		SetInfoText("$YACR4N_EndlessRapeInfo")
	elseif (option == matchedSexID)
		SetInfoText("$YACR4N_MatchedSexInfo")
	elseif (option == enableDrippingWASupportID)
		SetInfoText("$YACR4N_EnableDrippingWASupportInfo")
	elseif (option == updatePeriodID)
		SetInfoText("$YACR4N_UpdatePeriodInfo")
	elseif (disableEnemyRacesIDS.Find(option) > -1)
		SetInfoText("$YACR4N_DisableEnemyRacesInfo")
	endif
EndEvent

Event OnOptionSelect(int option)
	if (option == enableEndlessRapeID)
		enableEndlessRape = ! enableEndlessRape
		SetToggleOptionValue(option, enableEndlessRape)
	elseif (option == enableDrippingWASupportID)
		enableDrippingWASupport = ! enableDrippingWASupport
		SetToggleOptionValue(option, enableDrippingWASupport)
	elseif (option == debugLogFlagID)
		debugLogFlag = ! debugLogFlag
		SetToggleOptionValue(option, debugLogFlag)
		
	elseif (disableEnemyRacesIDS.Find(option) > -1)
		int idx = disableEnemyRacesIDS.Find(option)
		bool opt = DisableRacesConfig[idx]
		DisableRacesConfig[idx] = !opt
		SetToggleOptionValue(option, !opt)
	endif
EndEvent

Event OnOptionSliderOpen(int option)
	if (option == healthLimitID)
		self._setSliderDialogWithPercentage(healthLimit)
	elseif (option == rapeChanceID)
		self._setSliderDialogWithPercentage(rapeChance)
	elseif (option == updatePeriodID)
		SetSliderDialogDefaultValue(15)
		SetSliderDialogRange(5, 240)
		SetSliderDialogInterval(1)
	endif
EndEvent

Function _setSliderDialogWithPercentage(int x)
	SetSliderDialogStartValue(x)
	SetSliderDialogDefaultValue(x)
	
	SetSliderDialogRange(0.0, 100.0)
	SetSliderDialogInterval(1.0)
EndFunction

Event OnOptionSliderAccept(int option, float value)
	if (option == healthLimitID)
		healthLimit = value as int
		SetSliderOptionValue(option, healthLimit)
	elseif (option == rapeChanceID)
		rapeChance = value as int
		SetSliderOptionValue(option, rapeChance)
	elseif (option == updatePeriodID)
		updatePeriod = value as int
		SetSliderOptionValue(option, updatePeriod)
	endif
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


YACR4NQuest Property YACR4NScript  Auto 
Quest Property YACR4NQuestManager  Auto
ReferenceAlias[] Property MatchedAlias  Auto  
