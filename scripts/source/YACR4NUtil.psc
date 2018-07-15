Scriptname YACR4NUtil extends Quest  

int Function GetVersion()
	return 20180715
EndFunction

Function Log(String msg)
	bool debugflag = true
	; bool debugflag = false

	if (debugflag)
		debug.trace("[yacr4n] " + msg)
	endif
EndFunction
