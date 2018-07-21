Scriptname YACR4NQuest extends Quest  

YACR4NUtil Property AppUtil Auto

bool Function FillAlias(Actor act)
	string actName = act.GetActorBase().GetName()
	AppUtil.Log("Try FillAlias() " + actName)
	
	int i = 0
	int len = Victims.Length
	
	while (i < len)
		if (Victims[i].ForceRefIfEmpty(act))
			AppUtil.Log("Filled main alias " + actName)
			return true
		endif
		i += 1
	endwhile
	
	AppUtil.Log("Failed to fill main alias " + actName)
	return false
EndFunction

ReferenceAlias[] Property Victims  Auto  