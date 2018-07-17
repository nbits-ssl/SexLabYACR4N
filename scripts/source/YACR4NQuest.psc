Scriptname YACR4NQuest extends Quest  

YACR4NUtil Property AppUtil Auto

bool Function FillAlias(Actor act)
	string actName = act.GetActorBase().GetName()
	AppUtil.Log("Try FillAlias() " + actName)
	
	int i = Victims.Length
	bool filled
	Actor tmpact
	while i > 0
		i -= 1
		tmpact = Victims[i].GetActorRef()
		if (!tmpact)
			filled = Victims[i].ForceRefIfEmpty(act)
			if (filled)
				i = -1
			endif
		endif
	endwhile
EndFunction

ReferenceAlias[] Property Victims  Auto  