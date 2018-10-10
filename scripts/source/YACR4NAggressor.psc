Scriptname YACR4NAggressor extends ReferenceAlias  

Form PreSource = None
string SelfName

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, Bool abPowerAttack, Bool abSneakAttack, Bool abBashAttack, Bool abHitBlocked) 
	
	Actor selfact = self.GetActorRef()
	if (selfact)
		SelfName = selfact.GetLeveledActorBase().GetName()
	endif
	
	Spell spl = akSource as Spell
	
	if (PreSource == akSource)
		return
	elseif (spl && !spl.IsHostile())
		AppUtil.Log("enemy onhit pass, not hostile spell " + SelfName)
		return
	elseif (selfact.IsGhost())
		AppUtil.Log("enemy onhit pass, isghost " + SelfName)
		return
	endif
	
	GotoState("Busy")
	PreSource = akSource
	AppUtil.Log("enemy onhit success " + SelfName)
	
	if (selfact)
		if selfact.HasKeyWordString("SexLabActive")
			AppUtil.Log("enemy OnHit, Stop " + SelfName)
			selfact.SetGhost(true)
			sslThreadController controller = SexLab.GetActorController(selfact)
			controller.EndAnimation()
		endif
		selfact.SetGhost(false) ; in Alias's spell YACRStopCombatEffect etc.., but 3rd check
	endif
	
	Utility.Wait(0.5)
	PreSource = None
	GotoState("")
EndEvent

State Busy
	Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
		AppUtil.Log("enemy busy " + SelfName) ; not happen maybe
		; do nothing
	EndEvent
EndState

;Event OnPackageChange(Package akOldPackage)
;	Actor selfact = self.GetActorRef()
;	
;	if (selfact.HasKeyWordString("SexLabActive"))
;		AppUtil.Log("### OnPackageChange " + akOldPackage)
;	endif
;EndEvent

Event OnDying(Actor akKiller)
	ObjectReference wobj = self.GetActorRef() as ObjectReference
	wobj.SetPosition(wobj.GetPositionX(), wobj.GetPositionY() + 10.0, wobj.GetPositionZ())
	debug.sendAnimationEvent(wobj, "ragdoll")
	AppUtil.Log("enemy OnDying, sendAnimationEvent " + self.GetActorRef().GetLeveledActorBase().GetName())
EndEvent

Event OnDeath(Actor akKiller)
	AppUtil.Log("enemy OnDeath, Clear " + self.GetActorRef().GetLeveledActorBase().GetName())
	self.Clear()
EndEvent

;Event OnCellDetach()
;	self.Clear()
	; EndSexEvent is runned by OnCellDetach() by SexLab, leave it to SexLab & Victim
;EndEvent


SexLabFramework Property SexLab  Auto 
YACR4NUtil Property AppUtil Auto