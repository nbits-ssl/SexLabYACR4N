Scriptname YACR4NQuest extends Quest  

YACR4NUtil Property AppUtil Auto

bool Function FillAlias(Actor act)
	int yacrDistance = YACR4NDistance.GetValue() as int
	string actName = act.GetActorBase().GetName()
	AppUtil.Log("Try FillAlias() " + actName)
	
	int i = 0
	int len = Victims.Length
	
	Actor victim
	while (i < len)
		if (Victims[i].ForceRefIfEmpty(act))
			AppUtil.Log("Filled main alias " + actName)
			return true
		else
			victim = Victims[i].GetActorRef()
			if (victim.GetDistance(Player) > yacrDistance && \
				!victim.IsInFaction(YACR4NActionFaction) && \
				victim.IsInCombat())
				
				Victims[i].Clear()
				Victims[i].ForceRefTo(act)
				
				AppUtil.Log("Force filled main alias " + actName)
				return true
			endif
		endif
		i += 1
	endwhile
	
	AppUtil.Log("Failed to fill main alias " + actName)
	return false
EndFunction

Actor Property Player  Auto  
ReferenceAlias[] Property Victims  Auto  
GlobalVariable Property YACR4NDistance  Auto  
Faction Property YACR4NActionFaction  Auto  
