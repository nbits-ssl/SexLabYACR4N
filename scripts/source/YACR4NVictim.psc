Scriptname YACR4NVictim extends ReferenceAlias  

Form PreSource = None
string SelfName
bool EndlessSexLoop = false
float ForceUpdatePeriod = 30.0
float BleedOutUpdatePeriod = 10.0
sslThreadController UpdateController

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)

	Actor selfact = self.GetActorRef()
	SelfName = selfact.GetLeveledActorBase().GetName()
	
	if (akAggressor == None || akProjectile || PreSource ==  akSource)
		return
	endif
	
	GotoState("Busy")
	PreSource = akSource
	Actor akAggr = akAggressor as Actor
	Weapon wpn = akSource as Weapon
	
	if (!wpn || selfact.IsGhost() || selfact.IsDead() || akAggr.IsPlayerTeammate() || akAggr == PlayerActor || \
		selfact.IsInKillMove() || akAggr.IsInKillMove() || (wpn == Unarmed && selfact.GetDistance(akAggr) > 150.0))
		
		; do nothing & not return for state
	elseif (!abHitBlocked && wpn.GetWeaponType() < 7) ; exclude Bow/Staff/Crossbow
		AppUtil.Log("onhit success " + SelfName)
		float healthper = selfact.GetAVPercentage("health") * 100
		
		if (selfact.IsInFaction(SSLAnimatingFaction)) ; first check
			if selfact.HasKeyWordString("SexLabActive")  ; other sexlab's sex
				AppUtil.Log("detect other SexLab's Sex, EndAnimation " + SelfName)
				sslThreadController controller = SexLab.GetActorController(selfact)
				controller.EndAnimation()
			else  ; not animating, this is yacr's bug
				AppUtil.Log("detect invalid SSLAnimatingFaction, delete " + SelfName)
				selfact.RemoveFromFaction(SSLAnimatingFaction)
				; ##FIXME## Instead ActorLib.ValidateActor ?
			endif
		elseif (healthper < Config.healthLimit && Utility.RandomInt() < Config.rapeChance)
			AppUtil.Log("doSex " + SelfName)
			self.doSex(akAggr)
		endif
	endif
	
	Utility.Wait(0.5)
	PreSource = None
	GotoState("")
EndEvent

State Busy
	Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
		AppUtil.Log("busy " + SelfName)
		; do nothing
	EndEvent
EndState

Function _readySexVictim()
	VictimAlias.ForceRefTo(self.GetActorRef())
EndFunction

Function _endSexVictim()
	AppUtil.Log("_endSexVictim() " + HookName)
	
	self._clearAudience()
	VictimAlias.Clear()
	
	RegisterForSingleUpdate(0.5) ; for Unregist ForceUpdateController
EndFunction

Function _stopCombatOneMore(Actor aggr, Actor victim)
	aggr.StopCombat()
	aggr.StopCombatAlarm()
	victim.StopCombat()
	victim.StopCombatAlarm()
EndFunction

; _readySexAggr / _endSexAggr to StopCombatEffect.psc

Function doSex(Actor aggr)
	Actor victim = self.GetActorRef()
	SelfName = victim.GetLeveledActorBase().GetName()
	
	if (victim.IsGhost() || aggr.IsGhost())
		AppUtil.Log("ghosted Actor found, pass doSex " + SelfName)
		aggr.RemoveFromFaction(YACR4NActionFaction) ; from OnEnterBleedOut
		return
	elseif (Aggressor.GetActorRef() || aggr.IsDead() || !aggr.Is3DLoaded() || aggr.IsDisabled() || \
			victim.IsDead() || !victim.Is3DLoaded() || victim.IsDisabled())
			
		AppUtil.Log("already filled ref, dead actor, or not loaded, pass doSex " + SelfName)
		aggr.RemoveFromFaction(YACR4NActionFaction) ; from OnEnterBleedOut
		return
	elseif (victim.IsInFaction(SSLAnimatingFaction)) ; second check
		AppUtil.Log("victim already animating, pass doSex " + SelfName)
		aggr.RemoveFromFaction(YACR4NActionFaction) ; from OnEnterBleedOut
		return
	elseif (!AppUtil.ValidateAggr(victim, aggr, Config.matchedSex))
		return
	endif
	
	if (Aggressor.ForceRefIfEmpty(aggr))
		self._readySexVictim()
		
		actor[] sexActors = new actor[2]
		sexActors[0] = victim
		sexActors[1] = aggr
		sslBaseAnimation[] anims = AppUtil.BuildAnimation(sexActors)
		
		AppUtil.Log("run SexLab " + SelfName)
		
		int tid = self._quickSex(sexActors, anims, victim = victim)
		sslThreadController controller = SexLab.GetController(tid)
		AppUtil.Log("run SexLab [" + tid + "] " + SelfName)
		
		if (controller)
			; wait for sync, max 12 sec.
			self._waitSetup(controller)
			self._waitSetup(controller)
			self._waitSetup(controller)
			self._waitSetup(controller)
			
			Utility.Wait(1.0)
			; self._endSexAggr(aggr)
			aggr.SetGhost(false) ; _endSexAggr()
			AppUtil.Log("aggr setghost disable " + SelfName)
			MarkerQuest.Track(HookName, victim, aggr)
		else
			AppUtil.Log("###FIXME### controller not found, recover setup " + SelfName)
			self.EndSexEvent(aggr)
		endif
	else
		AppUtil.Log("already filled aggr reference, pass doSex " + SelfName)
	endif
EndFunction

Function doSexLoop()
	Actor aggr = Aggressor.GetActorRef()
	Actor victim = self.GetActorRef()
	
	Actor[] actors = AppUtil.GetHelpersCombined(victim, aggr)
	self._forceRefHelpers(actors)
	int helpersCount = actors.Length - 2
	
	AppUtil.Log("LOOPING run SexLab aggr " + aggr + ", helpers count " + helpersCount)
	
	sslBaseAnimation[] anims = AppUtil.BuildAnimation(actors)
	int tid = self._quickSex(actors, anims, victim = victim, CenterOn = aggr)
	sslThreadController controller = SexLab.GetController(tid)
	
	AppUtil.Log("LOOPING run SexLab [" + tid + "] " + SelfName)
	
	if (controller)
		; wait for sync, max 12 sec.
		self._waitSetup(controller)
		self._waitSetup(controller)
		self._waitSetup(controller)
		self._waitSetup(controller)
		
		self._stopCombatOneMore(aggr, victim)
		Utility.Wait(1.0)
		
		int idx = actors.Length
		while idx != 1 ; actors[0] is victim
			idx -= 1
			actors[idx].SetGhost(false)
		endwhile
			
		AppUtil.Log("LOOPING aggr setghost disable " + SelfName)
	else
		AppUtil.Log("LOOPING ###FIXME### controller not found, recover setup " + SelfName)
		self.EndSexEvent(aggr)
	endif
EndFunction

int Function _forceRefHelpers(Actor[] sppt)
	self._clearHelpers()
	int len = AppUtil.ArrayCount(sppt)
	
	if (len == 5)
		Helper1.ForceRefTo(sppt[2])
		Helper2.ForceRefTo(sppt[3])
		Helper3.ForceRefTo(sppt[4])
	elseif (len == 4)
		Helper1.ForceRefTo(sppt[2])
		Helper2.ForceRefTo(sppt[3])
	elseif (len == 3)
		Helper1.ForceRefTo(sppt[2])
	endif
	
	return len
EndFunction

; code from SexLab's StartSex with disable beduse, disable leadin, SortActors for fm, and YACR Hook
int function _quickSex(Actor[] Positions, sslBaseAnimation[] Anims, Actor Victim = None, Actor CenterOn = None)
	sslThreadModel Thread = SexLab.NewThread()
	if !Thread
		return -1
	elseIf !Thread.AddActors(SexLab.SortActors(Positions), Victim)
		return -1
	endif
	Thread.SetAnimations(Anims)
	Thread.DisableBedUse(true)
	Thread.DisableLeadIn()
	Thread.CenterOnObject(CenterOn)
	
	Thread.SetHook("YACR4N" + HookName)
	RegisterForModEvent("HookStageStart_YACR4N" + HookName, "StageStartEventYACR")
	RegisterForModEvent("HookAnimationEnd_YACR4N" + HookName, "EndSexEventYACR")
	
	if Thread.StartThread()
		return Thread.tid
	endif
	return -1
EndFunction

Function _waitSetup(sslThreadController controller)
	if (controller)
		string threadstate = controller.GetState()
		
		if (threadstate == "Ending")
			AppUtil.Log("###FIXME### state already ended, pass " + SelfName)
		elseif (threadstate != "animating")
			AppUtil.Log("wait setup " + SelfName + ", current state " + threadstate)
			Utility.Wait(3.0)
		else
			AppUtil.Log("wait setup " + SelfName + ", break, go ahead.")
		endif
	else
		AppUtil.Log("###FIXME### wait setup, no controller " + SelfName)
	endif
EndFunction

Event StageStartEventYACR(int tid, bool HasPlayer)
	AppUtil.Log("StageStartEvent: " + SelfName)
	Actor selfact = self.GetActorRef()
	Actor aggr = Aggressor.GetActorRef()
	
	if (selfact.GetAV("health") <= 0)
		AppUtil.Log("StageStartEvent stop, already victim is dead : " + SelfName)
		self.EndSexEvent(aggr)
	elseif (!selfact || !aggr)
		AppUtil.Log("##FIXME## StageStartEvent stop, none victim or none aggr : " + SelfName)
		self.EndSexEvent(aggr)
	endif
	
	UnregisterForUpdate()
	self._getAudience()
	UpdateController = SexLab.GetController(tid)
	sslThreadController controller = UpdateController
	int stagecnt = controller.Animation.StageCount
	int cumid = controller.Animation.GetCum(0)

	if (Config.enableDrippingWASupport)
		if (controller.Stage >= stagecnt - 1)
			selfact.SetGhost(false)
		else
			selfact.SetGhost(true)
		endif
	endif
	
	; for Onhit missing de-ghost
	if (controller.Stage > 1 && aggr.IsGhost())
		aggr.SetGhost(false)
		AppUtil.Log("###FIXME### Onhit missing de-ghost " + SelfName)
	endif
	
	if (controller.Stage == stagecnt && Config.enableEndlessRape)
		AppUtil.Log("endless sex loop... " + SelfName)
		int rndint = Utility.RandomInt()
		
		selfact.SetGhost(false)
		SexLab.ActorLib.ApplyCum(controller.Positions[0], cumid)
		if (!Config.enableDrippingWASupport)
			selfact.SetGhost(true)
		endif
		
		controller.UnregisterForUpdate()
		float laststagewait = SexLab.Config.StageTimerAggr[4]
		if (laststagewait > 1)
			Utility.Wait(laststagewait - 1.5) 
		endif
		if !(Aggressor.GetActorRef())  ; already escape because some reason 
			return
		endif
		
		if (rndint < 5) ; 20%
			AppUtil.Log("endless sex loop...one more " + SelfName)
			controller.AdvanceStage(true) ; has self controller.onUpdate
		elseif (rndint < 10) ; 25%
			AppUtil.Log("endless sex loop...one more from 2nd " + SelfName)
			controller.GoToStage(stagecnt - 2) ; has self controller.onUpdate
			RegisterForSingleUpdate(ForceUpdatePeriod)
		else
			bool multiplayLimit = false
			int origLength = controller.Positions.Length
			Actor[] actors = AppUtil.GetHelpersCombined(selfact, aggr)
			AppUtil.Log("endless sex loop... actors are " + actors)
			
			if (origLength == 5 || origLength == actors.Length)
				multiplayLimit = true
			endif
			
			if (!multiplayLimit && rndint < 90 && (AppUtil.ArrayCount(actors) - 2) > 0) ; 30%
				AppUtil.Log("endless sex loop...change to Multiplay " + SelfName)
				EndlessSexLoop = true
				controller.RegisterForSingleUpdate(0.2)
			else ; 25%
				AppUtil.Log("endless sex loop...change anim " + SelfName)
				controller.ChangeAnimation() ; has self controller.onUpdate
				controller.Stage = 2
				controller.Action("Advancing")
				RegisterForSingleUpdate(ForceUpdatePeriod)
			endif
		endif
		; thank you obachan
		; GetHelpersCombined() is heavy, when test with 40 npcs sometimes 1.5sec is too short time.
	endif
EndEvent

; from rapespell, genius!
Event OnUpdate()
	AppUtil.Log("# OnUpdate YACR4NVictim " + SelfName)
	if (UpdateController && UpdateController.GetState() == "animating")
		AppUtil.Log("OnUpdate, UpdateController is alive " + SelfName)
		UpdateController.OnUpdate()
		RegisterForSingleUpdate(ForceUpdatePeriod)
	else
		AppUtil.Log("OnUpdate, Unregister for single update loop " + SelfName)
		UnregisterForUpdate() ; for ForceUpdateController
	endif
EndEvent

Function _getAudience()
	AppUtil.Log("get audience " + SelfName)
	if (AudienceQuest.IsRunning())
		AudienceQuest.Stop()
	endif
	AudienceQuest.Start()
EndFunction

Function _clearAudience()
	AppUtil.Log("clear audience " + SelfName)
	if (AudienceQuest.IsRunning())
		AudienceQuest.Stop()
	endif
EndFunction

Function _clearHelpers()
	Helper1.Clear()
	Helper2.Clear()
	Helper3.Clear()
EndFunction

Event EndSexEventYACR(int tid, bool HasPlayer)
	AppUtil.Log("EndSexEvent " + SelfName)
	self.EndSexEvent(Aggressor.GetActorRef())
EndEvent

Function EndSexEvent(Actor aggr)
	Actor selfact = self.GetActorRef()
	if (EndlessSexLoop)
		AppUtil.Log("EndSexEvent, Goto to loop " + SelfName)
		EndlessSexLoop = false
		self._clearHelpers()
		
		self.doSexLoop()
	else ; Aggr's OnHit or Not EndlessRape
		AppUtil.Log("EndSexEvent, truely end " + SelfName)
		self._endSexVictim()
		
		AppUtil.CleanFlyingDeadBody(aggr)
		self._cleanDeadBody(Helper1)
		self._cleanDeadBody(Helper2)
		self._cleanDeadBody(Helper3)
		
		MarkerQuest.Clear(HookName)
		Aggressor.Clear()
		self._clearHelpers()
		
		GotoState("Busy")
		Utility.Wait(2.0)
		PreSource = None
		GotoState("")
	endif
EndFunction

Function _cleanDeadBody(ReferenceAlias enemy)
	Actor act = enemy.GetActorRef()
	if (act)
		AppUtil.CleanFlyingDeadBody(act)
	endif
EndFunction

Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
	Actor victim = self.GetActorRef()
	
	if (aeCombatState == 0 && !victim.HasKeyWordString("SexLabActive"))
		victim.EnableAI(false)
		victim.EnableAI()
		AppUtil.Log("OnCombatStateChanged, reset ai " + SelfName)
	endif
EndEvent

;Event OnCellDetach()
;	 EndSexEvent is runned by OnCellDetach() by SexLab, leave it to SexLab (Not Original YACR)
;EndEvent

Event OnDeath(Actor akKiller)
	AppUtil.Log("### OnDeath, clear aliases " + SelfName)
	self._endSexVictim()
	MarkerQuest.Clear(HookName)
	Aggressor.Clear()
	self._clearHelpers()
	self.Clear()
EndEvent


YACR4NConfigScript Property Config Auto
YACR4NUtil Property AppUtil Auto
YACR4NMarkerScript Property MarkerQuest Auto
SexLabFramework Property SexLab  Auto

Faction property SSLAnimatingFaction Auto
Faction property YACR4NActionFaction Auto
Actor Property PlayerActor  Auto
String Property HookName  Auto

ReferenceAlias Property Aggressor  Auto
ReferenceAlias Property VictimAlias  Auto  
ReferenceAlias Property Helper1  Auto  
ReferenceAlias Property Helper2  Auto  
ReferenceAlias Property Helper3  Auto  

Keyword Property ActorTypeNPC  Auto  
WEAPON Property Unarmed  Auto  
Quest Property AudienceQuest Auto
