Scriptname YACR4NCheckOnCombatEffect extends activemagiceffect  

Event OnEffectStart(Actor akTarget, Actor akCaster) 
	Actor target = akCaster.GetCombatTarget()
	
	if (akCaster.GetCombatState() == 1 && \
		!akCaster.IsInFaction(YACR4NActiveFaction) && \
		target != None && target != Game.GetPlayer() && !target.IsPlayerTeammate())
		
		(YACR4N as YACR4NQuest).FillAlias(akCaster)
	endif
EndEvent

Quest Property YACR4N  Auto  
Faction Property YACR4NActiveFaction  Auto  
