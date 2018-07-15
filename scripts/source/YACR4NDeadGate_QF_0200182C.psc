;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname YACR4NDeadGate_QF_0200182C Extends Quest Hidden

;BEGIN ALIAS PROPERTY Player
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Player Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Killer
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Killer Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victim
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victim Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
string aggrName
string victimName
Actor aggr = Alias_Killer.GetActorRef()
Actor victim = Alias_Victim.GetActorRef()

if (aggr && victim)
	aggrName = aggr.GetLeveledActorBase().GetName()
	victimName = victim.GetLeveledActorBase().GetName()
	debug.trace("[yacr4n] #### " + aggrName + " killed " + victim)
endif

self.Stop()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
