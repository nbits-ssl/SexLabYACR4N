Scriptname YACR4NInit extends Quest  

Event OnInit()
	if !(YACR4N.IsRunning())
		YACR4N.Start()
		YACR4NSearch.Start()
	endif
	; self.Stop()
	; this is the initializer AND Quest Reload Manager
EndEvent

Function Reboot()
	if (YACR4N.IsRunning())
		YACR4N.Stop()
	endif
	YACR4N.Start()
	if (YACR4NSearch.IsRunning())
		YACR4NSearch.Stop()
	endif
	YACR4NSearch.Start()
EndFunction

Quest Property YACR4N  Auto  
Quest Property YACR4NSearch  Auto  