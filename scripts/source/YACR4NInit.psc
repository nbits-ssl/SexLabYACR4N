Scriptname YACR4NInit extends Quest  

Event OnInit()
	if !(YACR4N.IsRunning())
		YACR4N.Start()
		YACR4NSearch.Start()
	endif
	; self.Stop()
	; this is the initializer AND Quest Reload Manager
EndEvent

Quest Property YACR4N  Auto  
Quest Property YACR4NSearch  Auto  