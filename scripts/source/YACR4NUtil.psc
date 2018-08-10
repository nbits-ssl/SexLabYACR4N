Scriptname YACR4NUtil extends Quest  

int Function GetVersion()
	return 20180809
EndFunction

Function Log(String msg)
	; bool debugflag = true
	; bool debugflag = false

	if (Config.debugLogFlag)
		debug.trace("[yacr4n] " + msg)
	endif
EndFunction

int Function GetArousal(Actor act)
	return act.GetFactionRank(sla_Arousal)
EndFunction

bool Function _validateSex(Actor victim, Actor aggr, int cfg, int aggrsex = -1)
	; check gender
	; 0 is straight, 1 is both, 2 is homo
	if (cfg == 1)
		return true
	else
		int vsex = victim.GetLeveledActorBase().GetSex()
		int asex
		if (aggrsex == -1)
			asex = aggr.GetLeveledActorBase().GetSex()
		else
			asex = aggrsex
		endif
		if (cfg == 0 && vsex != asex)
			return true
		elseif (cfg == 2 && vsex == asex)
			return true
		endif
	endif
	
	return false
EndFunction

int Function _validateCreature(Actor ActorRef)  ; from ActorLib.ValidateActor
	ActorBase BaseRef = ActorRef.GetLeveledActorBase()
	
	if !SexLab.Config.AllowCreatures
		return -17
	elseIf !sslCreatureAnimationSlots.HasCreatureType(ActorRef)
		return -18
	elseIf !SexLab.CreatureSlots.HasAnimation(BaseRef.GetRace(), SexLab.GetGender(ActorRef))
		return -19
	endIf
	
	return 1
EndFunction

bool Function ValidateAggr(Actor victim, Actor aggr, int cfg)
	string SelfName = victim.GetLeveledActorBase().GetName()
	
	if (aggr.HasKeyWord(ActorTypeNPC))
		return self._validateSex(victim, aggr, cfg)
	else
		; check race
		if (self._validateCreature(aggr) < -16) ; not support(or none anime) creature
			self.Log("aggr creature not supported or no valid animation " + SelfName)
			return false
		elseif (aggr.IsInFaction(SprigganFaction) || aggr.IsInFaction(HagravenFaction)) ; fuck spriggan, spriggan fuck
			return self._validateSex(victim, aggr, cfg, 1) ; female
		else
			Race aggrRace = aggr.GetLeveledActorBase().GetRace()
			int idx = Config.DisableRaces.Find(aggrRace)
			if (idx > -1 && Config.DisableRacesConfig[idx])
				self.Log("aggr creature disabled by yacr config " + SelfName)
				return false
			endif
		endif
		
		return true
	endif
	
	return false
EndFunction

Function CleanFlyingDeadBody(Actor act)
	if (act && act.IsDead())
		ObjectReference wobj = act as ObjectReference
		wobj.SetPosition(wobj.GetPositionX(), wobj.GetPositionY() + 10.0, wobj.GetPositionZ())
		debug.sendAnimationEvent(wobj, "ragdoll")
	endif
EndFunction

bool Function GetHelperSearcherLock(Actor aggr)
	Quest searcherQuest = self._getSearcherQuest(aggr)
	
	if (searcherQuest.IsRunning())
		self.Log("GetHelperSearcherLock(): failed")
		return false
	else
		self.Log("GetHelperSearcherLock(): success")
		searcherQuest.Start()
		return true
	endif
EndFunction

Function ReleaseHelperSearcherLock(Actor aggr)
	self.Log("ReleaseHelperSearcherLock()")
	self._getSearcherQuest(aggr).Stop()
EndFunction

Actor[] Function GetHelpersCombined(Actor victim, Actor aggr)
	YACR4NHelperMainAggr.ForceRefTo(aggr)
	Quest searcherQuest = self._getSearcherQuest(aggr)
	
	return self._getHelpersCombined(victim, aggr, searcherQuest)
EndFunction

Quest Function _getSearcherQuest(Actor aggr)
	if (aggr.HasKeyWord(ActorTypeNPC))
		return YACR4NHelperHumanSearcher
	else
		return YACR4NHelperCreatureSearcher
	endif
EndFunction

Actor[] Function _getHelpersCombined(Actor victim, Actor aggr, Quest qst)
	Actor[] tmpArray
	Actor[] actors
	sslBaseAnimation[] anims
	int idx = 0

	; qst.IsRunning by QuestLock
	
	tmpArray = (qst as YACR4NHelperSearch).Gather()
	ArraySort(tmpArray)
	idx = ArrayCount(tmpArray)
	
	if (idx == 3)
		actors = new Actor[5]
		actors[4] = tmpArray[2]
		actors[3] = tmpArray[1]
		actors[2] = tmpArray[0]
		actors[1] = aggr
		actors[0] = victim
		anims = self._pickAnimationsByActors(actors)
		self.Log("###3### " + anims)
		if !(anims)
			idx = 2
		endif
	endif
		
	if (idx == 2)
		actors = new Actor[4]
		actors[3] = tmpArray[1]
		actors[2] = tmpArray[0]
		actors[1] = aggr
		actors[0] = victim
		anims = self._pickAnimationsByActors(actors)
		self.Log("###2### " + anims)
		if !(anims)
			idx = 1
		endif
	endif

	if (idx == 1)
		actors = new Actor[3]
		actors[2] = tmpArray[0]
		actors[1] = aggr
		actors[0] = victim
		anims = self._pickAnimationsByActors(actors, Aggressive = true)
		self.Log("###1### " + anims)
		if !(anims)
			idx = 0
		endif
	endif

	if (idx == 0)
		actors = new Actor[2]
		actors[1] = aggr
		actors[0] = victim
	endif
	
	return actors
EndFunction

sslBaseAnimation[] Function _pickAnimationsByActors(Actor[] actors, bool aggressive = false)
	sslBaseAnimation[] anims
	Actor act = actors[1]
	
	if (act.HasKeyWord(ActorTypeNPC))
		anims = SexLab.PickAnimationsByActors(actors, Aggressive = aggressive)
	else
		Race actRace = act.GetRace()
		anims = SexLab.GetCreatureAnimationsByRace(actors.Length, actRace)
	endif
	
	return anims
EndFunction

sslBaseAnimation[] Function BuildAnimation(Actor[] actors)
	Actor victim = actors[0]
	Actor aggr = actors[1]

	sslBaseAnimation[] anims
	string tag = SexLab.MakeAnimationGenderTag(actors)
	string tagsuppress = ""
	bool requireall = true
	
	if (aggr.HasKeyWord(ActorTypeNPC))
		if (actors.Length == 2)
			tag = "fm" ; workaround
			tag += ",aggressive"
			tagsuppress = "cowgirl"
		elseif (actors.Length == 3)
			tag += ",aggressive"
		endif
	endif
	self.Log("BuildAnimation(): " + tag)
	
	return SexLab.GetAnimationsByTags(actors.Length, tag, tagsuppress, requireall)
EndFunction

; from creationkit.com, author is Chesko || Form[] => Actor[]
bool function ArraySort(Actor[] myArray, int i = 0)
	bool bFirstNoneFound = false
	int iFirstNonePos = i
	while i < myArray.Length
		if myArray[i] == none
			if bFirstNoneFound == false
				bFirstNoneFound = true
				iFirstNonePos = i
				i += 1
			else
				i += 1
			endif
		else
			if bFirstNoneFound == true
			;check to see if it's a couple of blank entries in a row
				if !(myArray[i] == none)
					;notification("Moving element " + i + " to index " + iFirstNonePos)
					myArray[iFirstNonePos] = myArray[i]
					myArray[i] = none
					;Call this function recursively until it returns
					ArraySort(myArray, iFirstNonePos + 1)
					return true
				else
					i += 1
				endif
			else
				i += 1
			endif
		endif
	endWhile
	return false
endFunction

; from creationkit.com, author is Chesko
int Function ArrayCount(Actor[] myArray)
	int i = 0
	int myCount = 0
	while i < myArray.Length
		if myArray[i] != none
			myCount += 1
			i += 1
		else
			i += 1
		endif
	endwhile
	return myCount
EndFunction


SexLabFramework Property SexLab  Auto
YACR4NConfigScript Property Config Auto

Keyword Property ActorTypeNPC  Auto  
Faction Property SprigganFaction  Auto  
Faction Property HagravenFaction  Auto  

ReferenceAlias  Property YACR4NHelperMainAggr Auto
Quest Property YACR4NHelperHumanSearcher Auto
Quest Property YACR4NHelperCreatureSearcher Auto

Faction Property sla_Arousal  Auto  
