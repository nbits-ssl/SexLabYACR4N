Scriptname YACR4NQuest extends Quest  

YACR4NUtil Property AppUtil Auto

bool Function FillAlias(Actor act)
	string actName = act.GetActorBase().GetName()
	AppUtil.Log("Try FillAlias() " + actName)
	
	int i = Victims.Length
	
	while i > 0
		i -= 1
		if (Victims[i].ForceRefIfEmpty(act))
			AppUtil.Log("Filled main alias " + actName)
			return true
		endif
	endwhile
	
	AppUtil.Log("Failed to fill main alias " + actName)
	return false
EndFunction

ReferenceAlias[] Property Victims  Auto  