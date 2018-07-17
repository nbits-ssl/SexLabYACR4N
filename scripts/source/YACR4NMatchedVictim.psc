Scriptname YACR4NMatchedVictim extends ReferenceAlias  

YACR4N Property mainScript  Auto  

Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
	Actor victim = self.GetActorRef()
	if (!victim)
		return
	endif
	
	if (aeCombatState == 1 && !victim.IsInFaction(YACR4NActiveFaction) && \
		akTarget != Game.GetPlayer() && !akTarget.IsPlayerTeammate())
		
		mainScript.FillAlias(victim)
	endif
EndEvent

Faction Property YACR4NActiveFaction  Auto  
