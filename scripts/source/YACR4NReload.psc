Scriptname YACR4NReload extends ReferenceAlias  

bool cellreload = false

Event OnCellLoad()
	UnRegisterForUpdate()
	cellreload = true
	RegisterForSingleUpdate(3)
EndEvent

Event OnUpdate()
	if (Config.modEnabled)
		self._reload()
		AppUtil.Log("# Quest Reload done")
	endif
	RegisterForSingleUpdate(Config.updatePeriod)
EndEvent

Function _reload()
	if (cellreload)
		YACR4N.Stop()
		YACR4N.Start()
		AppUtil.Log("# Main Quest Reload done")
		cellreload = false
		Utility.Wait(0.5)
	endif
	YACR4NSearch.Stop()
	YACR4NSearch.Start()
EndFunction

YACR4NUtil Property AppUtil Auto
YACR4NConfigScript Property Config Auto

Quest Property YACR4N  Auto  
Quest Property YACR4NSearch  Auto  
