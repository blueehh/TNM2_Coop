class TNMBarkManager extends BarkManager;

// ----------------------------------------------------------------------
// CheckRadius()
// ----------------------------------------------------------------------
function bool CheckRadius(ScriptedPawn invokePawn)
{
	local Trestkon T;

	if (invokePawn == None)
		return False;

	if (Level.NetMode != NM_Standalone)
	{
		foreach AllActors(class'Trestkon', T)
		{
			if (T.Health > 0 && VSize(T.Location - invokePawn.Location) <= maxAllowableRadius)
				return True;
		}
		return False;
	}

	return Super.CheckRadius(invokePawn);
}

// ----------------------------------------------------------------------
// CheckHeightDifference()
// ----------------------------------------------------------------------
function bool CheckHeightDifference(ScriptedPawn invokePawn)
{
	local Trestkon T;
	local bool bHeightOk;

	if (invokePawn == None)
		return False;

	if (Level.NetMode != NM_Standalone)
	{
		foreach AllActors(class'Trestkon', T)
		{
			if (T.Health > 0 && VSize(T.Location - invokePawn.Location) <= maxAllowableRadius)
			{
				if (T.FastTrace(invokePawn.Location))
					bHeightOk = (Abs(T.Location.Z - invokePawn.Location.Z) <= maxVisibleHeightDifference);
				else
					bHeightOk = (Abs(T.Location.Z - invokePawn.Location.Z) <= maxHiddenHeightDifference);
				if (bHeightOk)
					return True;
			}
		}
		return False;
	}

	return Super.CheckHeightDifference(invokePawn);
}

// ----------------------------------------------------------------------
// StartBark()
// ----------------------------------------------------------------------
function bool StartBark(DeusExRootWindow newRoot, ScriptedPawn newBarkPawn, EBarkModes newBarkMode)
{
	local Name         conName;
	local Conversation con;
	local int          barkIndex;
	local Float        barkDuration;
	local bool         bBarkStarted;
	local ConPlayBark  conPlayBark;
	local String       conSpeechString;
	local ConSpeech    conSpeech;
	local Sound        speechAudio;
	local bool         bHaveSpeechAudio;
	local int          playingSoundID;
	local Trestkon     T;
	local float        displayRadius;

	bBarkStarted = False;

	// Store away the root window
	rootWindow = newRoot;
	if (rootWindow == None)
		SetRootWindow();

	// Don't even go any further if the actor is too far away
	// from the player
	if (!CheckRadius(newBarkPawn))
		return False;

	// Now check the height difference
	if (!CheckHeightDifference(newBarkPawn))
		return False;

	// First attempt to find this conversation
	conName = BuildBarkName(newBarkPawn, newBarkMode);

	// Okay, we have the name of the bark, now attempt to find a
	// conversation based on this name.
	con = ConListItem(newBarkPawn.conListItems).FindConversationByName(conName);

	if (con != None)
	{
		barkIndex = GetAvailableCurrentBarkSlot(newBarkPawn, newBarkMode);

		// Abort if we don't get a valid barkIndex back
		if (barkIndex == -1)
			return False;

		// Make sure that another NPC isn't already playing this
		// particular bark.
		if (IsBarkPlaying(conName))
			return False;

		// Now check to see if the same kind of bark has already been
		// played by this NPC within a certain range of time.
		if (HasBarkTypePlayedRecently(newBarkPawn, newBarkMode))
			return False;

		// Summon a 'ConPlayBark' object, which will process
		// the conversation and play the bark.
		// Found an active conversation, so start it
		conPlayBark = Spawn(class'TNMConPlayBark');
		conPlayBark.SetConversation(con);

		conSpeech = conPlayBark.GetBarkSpeech();

		bHaveSpeechAudio = False;

		// Nuke conPlayBark
		conPlayBark.Destroy();

		displayRadius = FMax(1024.0, 2.0 * float(maxAllowableRadius));

		// Play the audio (if we have audio)
		if ((conSpeech != None) && (conSpeech.soundID != -1))
		{
			speechAudio = con.GetSpeechAudio(conSpeech.soundID);

			if (speechAudio != None)
			{
				bHaveSpeechAudio = True;
				if(DeusExPlayer(GetPlayerPawn()).DrugEffectTimer < 0)
					playingSoundID = newBarkPawn.PlaySound(speechAudio, SLOT_Talk,,,displayRadius, 0.5);
				else if (bool(newBarkPawn.GetPropertyText("bCustomBarkPitch")))
					playingSoundID = newBarkPawn.PlaySound(speechAudio, SLOT_Talk,,,displayRadius, float(newBarkPawn.GetPropertyText("barkPitch")));
				else
					playingSoundID = newBarkPawn.PlaySound(speechAudio, SLOT_Talk,,,displayRadius);
				barkDuration = con.GetSpeechLength(conSpeech.soundID);
				StartSpeakingAnimation(newBarkPawn);
			}
		}

		// If we don't have any audio, then calculate the timer based on the
		// length of the speech text.

		if ((conSpeech != None) && (!bHaveSpeechAudio))
			barkDuration = FMax(Len(conSpeech.speech) * perCharDelay, minimumTextPause);

		// Show the speech if Subtitles are on (within 2x trigger radius in Co-op)
		if ((DeusExPlayer(Owner) != None) && (DeusExPlayer(Owner).bSubtitles) && (conSpeech != None) && (conSpeech.speech != ""))
		{
			if (Level.NetMode == NM_Standalone || VSize(DeusExPlayer(Owner).Location - newBarkPawn.Location) <= displayRadius)
			{
				if (rootWindow != None && rootWindow.hud != None && rootWindow.hud.barkDisplay != None)
					rootWindow.hud.barkDisplay.AddBark(conSpeech.speech, barkDuration, newBarkPawn);
			}
		}

		if (Level.NetMode != NM_Standalone && conSpeech != None && conSpeech.speech != "")
		{
			foreach AllActors(class'Trestkon', T)
			{
				if (T != DeusExPlayer(Owner) && NetConnection(T.Player) != None && VSize(T.Location - newBarkPawn.Location) <= displayRadius)
					T.ClientAddBark(conSpeech.speech, barkDuration, newBarkPawn, newBarkPawn.UnfamiliarName);
			}
		}

		// Keep track of the bark
		SetBarkInfo(barkIndex, conName, newBarkPawn, newBarkMode, barkDuration, playingSoundID);

		bBarkStarted = True;
	}

	return bBarkStarted;
}

// ----------------------------------------------------------------------
// StartSpeakingAnimation()
//
// Start the speaking animation.  We only have animations for Pawns, so if a
// decoration is speaking there's nothing to animate (this may change).
//
// If this is a speech event, then grab ahold of the speaker.  Otherwise,
// if it's a choice event that's playing the selected choice, the PC
// is speaking.
// ----------------------------------------------------------------------
function StartSpeakingAnimation(ScriptedPawn speakingActor)
{
	if ( speakingActor != None )
	{
		speakingActor.bIsSpeaking = True;
		speakingActor.bWasSpeaking = True;
	}
}

// ----------------------------------------------------------------------
// StopSpeakingAnimation()
//
// Stop the speaking animation
// ----------------------------------------------------------------------
function StopSpeakingAnimation(ScriptedPawn speakingActor)
{
	if ( speakingActor != None )
	{
		speakingActor.bIsSpeaking = False;
		speakingActor = None;
	}
}

function RemoveCurrentBark(int barkIndex)
{
	// First add to the RecentBarkList
	MoveCurrentBarkToRecent(barkIndex);

	StopSpeakingAnimation(currentBarks[barkIndex].barkPawn);

	currentBarks[barkIndex].barkPawn       = None;
	currentBarks[barkIndex].conName        = '';
	currentBarks[barkIndex].barkDuration   = 0.0;
	currentBarks[barkIndex].barkTimer      = 0.0;
	currentBarks[barkIndex].barkMode       = BM_Idle;
	currentBarks[barkIndex].barkPriority   = 0;
	currentBarks[barkIndex].playingSoundID = 0;
}

defaultproperties
{
}
