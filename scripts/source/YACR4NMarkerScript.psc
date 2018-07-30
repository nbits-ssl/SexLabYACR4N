Scriptname YACR4NMarkerScript extends Quest  

string[] HookNameList

Event OnInit() ; ugly
	HookNameList = new string[10]
	HookNameList[0] = "Victim1"
	HookNameList[1] = "Victim2"
	HookNameList[2] = "Victim3"
	HookNameList[3] = "Victim4"
	HookNameList[4] = "Victim5"
	HookNameList[5] = "Victim6"
	HookNameList[6] = "Victim7"
	HookNameList[7] = "Victim8"
	HookNameList[8] = "Victim9"
	HookNameList[9] = "Victim10"
	self.SetObjectiveDisplayed(0, true)
EndEvent

Function Track(string hookName, Actor victim, Actor aggr)
	int idx = HookNameList.Find(hookName)
	AppUtil.Log("Track marker id: " + idx)
	
	if (idx >= 0 && victim && aggr)
		Aggrs[idx].ForceRefTo(aggr)
		Victims[idx].ForceRefTo(victim)
		self.SetObjectiveDisplayed(idx + 999, true)
	endif
EndFunction

Function Clear(string hookName)
	int idx = HookNameList.Find(hookName)
	AppUtil.Log("Clear marker id: " + idx)
	
	if (idx >= 0)
		Aggrs[idx].Clear()
		Victims[idx].Clear()
		self.SetObjectiveDisplayed(idx + 999, false)
	endif
EndFunction


YACR4NUtil Property AppUtil Auto

ReferenceAlias[] Property Aggrs  Auto  
ReferenceAlias[] Property Victims  Auto  
