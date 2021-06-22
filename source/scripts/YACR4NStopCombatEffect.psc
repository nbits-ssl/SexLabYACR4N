Scriptname YACR4NStopCombatEffect extends activemagiceffect  

Event OnEffectStart(Actor akTarget, Actor akCaster) 
	akCaster.SetGhost(true)
	akCaster.StopCombat()
	; akCaster.StopCombatAlarm()
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	akCaster.SetGhost(false)
EndEvent
