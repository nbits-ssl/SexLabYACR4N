Scriptname YACR4NMatchedVictim extends ReferenceAlias  

Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
	Actor vic = self.GetActorRef()
	
	if (aeCombatState == 1 && \
		vic != None && !vic.IsInFaction(YACR4NActiveFaction) && \
		akTarget != None && akTarget != Game.GetPlayer() && !akTarget.IsPlayerTeammate())
		
		(YACR4N as YACR4NQuest).FillAlias(vic)
	endif
EndEvent

Quest Property YACR4N  Auto  
Faction Property YACR4NActiveFaction  Auto  
