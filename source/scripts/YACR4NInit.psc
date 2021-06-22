Scriptname YACR4NInit extends Quest  

Event OnInit()
	self.Boot()
	; self.Stop()
	; this is the initializer AND Quest Reload Manager
EndEvent

Function Reboot()
	self.Shutdown()
	self.Boot()
EndFunction

Function Boot()
	YACR4NSearch.Start()
	YACR4N.Start()
EndFunction

Function Shutdown()
	if (YACR4NSearch.IsRunning())
		YACR4NSearch.Stop()
	endif
	if (YACR4N.IsRunning())
		YACR4N.Stop()
	endif
EndFunction

Function Toggle(bool enabled)
	if (enabled)
		self.Boot()
	else
		self.Shutdown()
	endif
EndFunction

Quest Property YACR4N  Auto  
Quest Property YACR4NSearch  Auto  