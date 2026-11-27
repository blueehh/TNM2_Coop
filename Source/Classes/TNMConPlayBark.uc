//=============================================================================
// TNMConPlayBark
//=============================================================================
class TNMConPlayBark extends ConPlayBark;

// ----------------------------------------------------------------------
// GetBarkSpeech()
// Bjorn: Added support for checking flags for barks.
// ----------------------------------------------------------------------
function ConSpeech GetBarkSpeech()
{
	local ConEvent event;
	local ConSpeech outSpeech;

	// Abort if we don't have a valid conversation
	if (con == None)
		return None;

	// Default return value
	outSpeech = None;

	// Loop through the events until we hit some speech
	event = con.eventList;

	while(event != None)
	{
		switch(event.eventType)
		{
			case ET_Speech:
				outSpeech = ConEventSpeech(event).conSpeech;
				event = None;
				break;

			case ET_Jump:
				event = ProcessEventJump(ConEventJump(event));
				break;

			case ET_CheckFlag:
				event = ProcessEventCheckFlag(ConEventCheckFlag(event));
				break;

			case ET_Random:
				event = ProcessEventRandomLabel(ConEventRandomLabel(event));
				break;

			case ET_End:
				event = None;
				break;

			default:
				event = event.nextEvent;
				break;
		}
	}

	return outSpeech;
}

// ----------------------------------------------------------------------
// ProcessEventJump()
// Bjorn: Added support for jumping to other convos for barks.
// ----------------------------------------------------------------------
function ConEvent ProcessEventJump(ConEventJump event)
{
	local ConEvent nextEvent;

	// Check to see if the jump label is empty.  If so, then we just want
	// to fall through to the next event.  This can happen when jump
	// events get inserted during the import process.  ConEdit will not
	// allow the user to create events like this.

	if (event.jumpLabel == "")
	{
		nextEvent = event.nextEvent;
	}
	else
	{
		if (event.jumpCon != None && event.jumpCon != con)
			con = event.jumpCon;

		nextEvent = con.GetEventFromLabel(event.jumpLabel);
	}

	if (nextEvent == None)
	{
		Log("  WARNING!  Label [" $ event.jumpLabel $ "] NOT FOUND in Conversation [" $ event.jumpCon.conName $ "]");
		nextEvent = con.eventList;
	}

	return nextEvent;
}

// ----------------------------------------------------------------------
// ProcessEventCheckFlag()
// Bjorn: Added support for checking flags for barks.
// ----------------------------------------------------------------------
function ConEvent ProcessEventCheckFlag(ConEventCheckFlag event)
{
	local ConFlagRef currentRef;
	local DeusExPlayer player;
	local ConEvent ret;

	player = DeusExPlayer(GetPlayerPawn());

	//If we can't get a hold of the player, just continue to the next event.
	if (player == None)
		return event.NextEvent;

	// Loop through our list of FlagRef's, checking the value of each.
	// If we hit a bad match, then we'll stop right away since there's
	// no point of continuing.
	for (currentRef = event.flagRef; currentRef != None; currentRef = currentRef.nextFlagRef)
	{
		if (player.flagBase.GetBool(currentRef.flagName) != currentRef.value)
			return event.nextEvent;
	}

	if (event.setLabel == "")
		return event.nextEvent;

	ret = con.GetEventFromLabel(event.setLabel);
	if (ret == None)
		ret = con.eventList;

	//If we've made it so far, it means all flags were checked successfully. Jump to the label.
	return ret;
}

defaultproperties
{
}
