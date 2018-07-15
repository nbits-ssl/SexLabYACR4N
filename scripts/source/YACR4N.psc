Scriptname YACR4N extends Quest  

YACR4NUtil Property AppUtil Auto

bool Function FillAlias(Actor act)
	string actName = act.GetActorBase().GetName()
	AppUtil.Log("### Try FillAlias() " + actName)
EndFunction

ReferenceAlias[] Property Victims  Auto  

