Scriptname YACR4NReload extends ReferenceAlias  

YACR4NUtil Property AppUtil Auto

Event OnCellLoad()
	UnRegisterForUpdate()
	RegisterForSingleUpdate(3)
EndEvent

Event OnUpdate()
	; AppUtil.Log("#### Quest Reload start")
	self._reload()
	RegisterForSingleUpdate(10)
	AppUtil.Log("#### Quest Reload done")
EndEvent

Function _reload()
	YACR4NSearch.Stop()
	YACR4NSearch.Start()
EndFunction

Quest Property YACR4NSearch  Auto  
