class tnmConPlay extends ConPlay;

const killedlabel = "Killed_";
const separatorlabel = "_and_";

var localized string strPass;

var localized string creditsText;

var Trestkon coopInitiator;

function Trestkon ResolveCoopPlayer()
{
	local Pawn P;
	local Trestkon T, BestT;
	local float bestDist, d;
	local Actor refActor;

	if (Level.NetMode == NM_Standalone)
		return Trestkon(player);

	if (coopInitiator != None && !coopInitiator.bDeleteMe && coopInitiator.Player != None)
		return coopInitiator;

	refActor = startActor;
	if (refActor == None)
		refActor = invokeActor;

	bestDist = 9999999.0;
	for (P = Level.PawnList; P != None; P = P.NextPawn)
	{
		T = Trestkon(P);
		if (T != None && !T.bDeleteMe && T.Player != None)
		{
			if (refActor != None)
			{
				d = VSize(T.Location - refActor.Location);
				if (d < bestDist)
				{
					bestDist = d;
					BestT = T;
				}
			}
			else if (BestT == None)
			{
				BestT = T;
			}
		}
	}

	if (BestT != None)
		return BestT;

	return Trestkon(player);
}

function RemoveItemFromPlayer(Inventory item)
{
	if (item != None && DeusExPlayer(item.Owner) != None)
		DeusExPlayer(item.Owner).RemoveItemDuringConversation(item);
	else if ((player != None) && (item != None))
		player.RemoveItemDuringConversation(item);
}

function EEventAction SetupEventCheckPersona( ConEventCheckPersona event, out String nextLabel )
{
	local EEventAction action;
	local int personaValue;
	local bool bPass;
	local Trestkon activePlayer;

	activePlayer = ResolveCoopPlayer();
	if (activePlayer == None)
		return Super.SetupEventCheckPersona(event, nextLabel);

	switch(event.personaType)
	{
		case EP_Credits:
			personaValue = activePlayer.Credits;
			break;

		case EP_Health:
			activePlayer.GenerateTotalHealth();
			personaValue = activePlayer.Health;
			break;

		case EP_SkillPoints:
			personaValue = activePlayer.SkillPointsAvail;
			break;
	}

	switch(event.condition)
	{
		case EC_Less:
			bPass = (personaValue < event.value);
			break;

		case EC_LessEqual:
			bPass = (personaValue <= event.value);
			break;

		case EC_Equal:
			bPass = (personaValue == event.Value);
			break;

		case EC_GreaterEqual:
			bPass = (personaValue >= event.Value);
			break;

		case EC_Greater:
			bPass = (personaValue > event.Value);
			break;
	}

	if (bPass)
	{
		nextLabel = event.jumpLabel;
		action = EA_JumpToLabel;
	}
	else
	{
		nextLabel = "";
		action = EA_NextEvent;
	}

	return action;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
// SetupEventAddCredits()
//
// Adds the specified number of credits to the player.  If the
// 'creditsToTransfer' variable is negative, this will cause
// the credits to get deducted from the player's credits total.
// Bjorn: Added to display Credits.
// ----------------------------------------------------------------------
function EEventAction SetupEventAddCredits( ConEventAddCredits event, out String nextLabel )
{
	local TNMConWindowActive window;
	local Credits creds;
	local Trestkon activePlayer;

	activePlayer = ResolveCoopPlayer();
	if (activePlayer == None)
		activePlayer = Trestkon(player);
	
	if (Pawn(invokeActor) != None && PlayerPawn(invokeActor) == None && event.creditsToAdd < 0)
	{
		creds = Spawn(class'Credits',invokeActor,,invokeActor.Location);
		
		if (creds != None)
		{
			creds.numCredits = event.creditsToAdd * -1;
			creds.GiveTo(Pawn(invokeActor));
		}
	}

	if (activePlayer != None)
	{
		activePlayer.credits += event.creditsToAdd;
		activePlayer.credits = Max(activePlayer.credits, 0);
		activePlayer.lastSyncedCredits = -1;
	}

	window = TNMConWindowActive(conWinThird);

	if (window != none)
	{
		if (!window.creditsWindow.IsVisible())
			window.creditsWindow.Show();
		if (activePlayer != None)
			window.creditsWindow.SetText(creditsText @ activePlayer.Credits);
		else
			window.creditsWindow.SetText(creditsText @ player.Credits);
	}
	else
		log("conWinThird could not cast to TNMConWindowActive! Unable to display credits!");

	nextLabel = "";
	return EA_NextEvent;
}

// ----------------------------------------------------------------------
// SetupEventChoice()
// Bjorn: Added to display CreditsWindow.
// ----------------------------------------------------------------------
function EEventAction SetupEventChoice( ConEventChoice event, out String nextLabel )
{
	local ConChoice choice;
	local ButtonWindow newButton;
	local int choiceCount;
	local EEventAction nextAction;
	local TNMConWindowActive window;
	local string choicesPayload;
	local Pawn P;
	local Trestkon TPlayer, activePlayer;

	activePlayer = ResolveCoopPlayer();
	if (activePlayer == None)
		activePlayer = Trestkon(player);

	// Notify the conversation window to ignore input until we're done
	// creating the choices (this is done to prevent the user from being
	// able to make a choice while drawing, only a problem on slow machines)

	if (conWinThird != None)
		conWinThird.RestrictInput(True);

	// For choices, the speaker is always the player.  The person being
	// spoken to, well, that's more complicated (unless I force that to be
	// set in ConEdit).  For now we'll assume that the owner of the
	// conversation is the person being spoken to.

	currentSpeaker    = player;
	currentSpeakingTo = startActor;

	// Update the Actors used by the camera
	SetCameraActors();
	
	// Rotate speakers when a conversation starts with a choice instead of speech
    TurnSpeakingActors(player, startActor);

	// Clear the screen if need be
	if (event.bClearScreen)
		conWinThird.Clear();

	// Okay, we want to create as many buttons as we have choices
	// and display them.  We'll then return and let conPlay get some
	// user input.

	choice = event.ChoiceList;
	choiceCount = 0;
	choicesPayload = "";

	while(choice != None)
	{
		// Before we blindly display this choice, we first need to check a
		// few things.  Specifically:
		//
		// 1.  Check to see if any flags are associated with this choice.
		// 2.  Check to see if this choice is skill-based.
		// 3.  If there are *NO* valid choices, skip to the next event
		//     as a failsafe
		//
		// If the above conditions are met, then display the choice.

		if (player.CheckFlagRefs(choice.flagRef))
		{
			// Now check the skills
			if (choice.skillNeeded != None)
			{
				// Does player have it?
				if ((activePlayer != None && activePlayer.SkillSystem != None && activePlayer.SkillSystem.IsSkilled(choice.skillNeeded, choice.skillLevelNeeded)) ||
				    (player.SkillSystem != None && player.SkillSystem.IsSkilled(choice.skillNeeded, choice.skillLevelNeeded)))
				{
					// Display the choice with some feedback!
					conWinThird.DisplaySkillChoice(choice);
					if (choicesPayload != "")
						choicesPayload = choicesPayload $ "|";
					choicesPayload = choicesPayload $ Left(choice.choiceText, 70);
					choiceCount++;
				}
			}
			else
			{
				// Plain old vanilla choice
				conWinThird.DisplayChoice(choice);
				if (choicesPayload != "")
					choicesPayload = choicesPayload $ "|";
				choicesPayload = choicesPayload $ Left(choice.choiceText, 70);
				choiceCount++;
			}
		}

		choice = choice.nextChoice;
	}

	nextLabel = "";

	if (choiceCount > 0)
	{
		nextAction = EA_WaitForInput;

		window = TNMConWindowActive(conWinThird);

		if (window != None)
		{
			if (!window.creditsWindow.IsVisible())
				window.creditsWindow.Show();
			if (activePlayer != None)
				window.creditsWindow.SetText(creditsText @ activePlayer.Credits);
			else
				window.creditsWindow.SetText(creditsText @ player.Credits);
		}
		else
		log("conWinThird could not cast to TNMConWindowActive! Unable to display credits!");

		if (Level.NetMode != NM_Standalone)
		{
			foreach AllActors(class'Trestkon', TPlayer)
			{
				if (TPlayer != player && NetConnection(TPlayer.Player) != None)
					TPlayer.ClientShowSubtitle("[Choices]|" $ choiceCount, Left(choicesPayload, 235), False);
			}
		}
	}
	else
		nextAction = EA_NextEvent;

	// Okay to accept user input again
	if (conWinThird != None)
		conWinThird.RestrictInput(False);

	return nextAction;
}

function SelectCoopChoice(int choiceIdx)
{
	local TNMConWindowActive win;
	local ConChoice choice;
	local Trestkon TPlayer;

	win = TNMConWindowActive(conWinThird);
	if (win != None && choiceIdx >= 0 && choiceIdx < win.numChoices && win.conChoices[choiceIdx] != None)
	{
		choice = ConChoice(win.conChoices[choiceIdx].GetUserObject());
		if (choice != None)
		{
			foreach AllActors(class'Trestkon', TPlayer)
			{
				if (TPlayer != player && NetConnection(TPlayer.Player) != None)
					TPlayer.ClientHideSubtitle();
			}
			win.RestrictInput(True);
			if (win.root != None)
				win.root.ShowCursor(False);
			PlayChoice(choice);
			if (conWinThird != None)
				conWinThird.Clear();
		}
	}
}

function AdvanceCoopSpeech()
{
	local TNMConWindowActive win;

	win = TNMConWindowActive(conWinThird);
	if (win != None && win.numChoices > 0)
		return;

	if (IsInState('WaitForInput') || IsInState('WaitForText') || IsInState('WaitForSpeech'))
	{
		StopSpeech();
		PlayNextEvent();
	}
}

function PostTerminateConversation()
{
	local name triggertag;
	local trigger t;
	local name interuptedflag;
	local Pawn P;
	local Trestkon TPlayer;

	if ( con != none && Trestkon(player) != None )
	{
		interuptedflag = Trestkon(player).SafeStringToName( con.conName $ "_Interrupted" );
		if ( !player.flagBase.GetBool(interuptedflag) )
		{
			triggertag = Trestkon(player).SafeStringToName(con.conName $ "_Stopped");
			if(triggertag!='') //can never be too safe
				foreach allactors(class'trigger', t, triggertag)
				{
					t.Trigger(none, none);
				}
		}
	}

	if (Level.NetMode != NM_Standalone)
	{
		foreach AllActors(class'Trestkon', TPlayer)
		{
			if (TPlayer.bClientInThirdPersonConvo)
			{
				TPlayer.bClientInThirdPersonConvo = False;
				TPlayer.clientConvoTarget = None;
				TPlayer.ConversationActor = None;
				TPlayer.MakePlayerIgnored(False);
			}
			if (TPlayer != player && NetConnection(TPlayer.Player) != None)
				TPlayer.ClientHideSubtitle();
		}
		if (tnmGameInfo(Level.Game) != None)
			tnmGameInfo(Level.Game).SyncCoopState();
	}

	super.PostTerminateConversation();
}

function TerminateConversation(optional bool bContinueSpeech, optional bool bNoPlayedFlag)
{
	if (!bEndingConversation && conWinThird != None && !conWinThird.IsVisible())
	{
		bSaveContinueSpeech = bContinueSpeech;
		bSaveNoPlayedFlag   = bNoPlayedFlag;
		bEndingConversation = True;
		ConWinFinished();
		return;
	}
	Super.TerminateConversation(bContinueSpeech, bNoPlayedFlag);

	// flags this conversation set reach the other player now, not on the next merge
	if (tnmGameInfo(Level.Game) != None)
		tnmGameInfo(Level.Game).CoopRequestFlagMerge();
}

function ConWinFinished()
{
	local HUDConWindowFirst oldWinFirst;
	local ConWindowActive oldWinThird;

	if (bDeleteMe)
		return;

	// Nuke the conversation window safely (nulling references before Destroy to prevent double SafeDestroy)
	if (conWinFirst != None)
	{
		oldWinFirst = conWinFirst;
		conWinFirst = None;
		oldWinFirst.Destroy();
	}
	if (conWinThird != None)
	{
		oldWinThird = conWinThird;
		conWinThird = None;
		oldWinThird.Destroy();
	}

	if (displayMode != DM_FirstPerson)
	{
		// Show the hud display if this was a third-person convo
		if (!bForcePlay && Trestkon(player) != None && !Trestkon(player).bCinematic && rootWindow != None && rootWindow.hud != None)
			rootWindow.hud.Show();
	}

	PostTerminateConversation();

	currentEvent = None;
	lastEvent = None;
	con = None;
	startCon = None;
	cameraInfo = None;
	history = None;
 
	// Now nuke ourself.
	Destroy();
}

//remove bForcePlay checks
function AddConActor(Actor newConActor, bool bFirstPerson)
{	
	if ((newConActor != None))
	{
		// Only do if we have space and this pawn isn't already speaking
		if ((!IsConActorInList(newConActor)) && (conActorCount < 9))
		{
			ConActors[conActorCount++] = newConActor;

			if (newConActor.IsA('ScriptedPawn'))
				ScriptedPawn(newConActor).EnterConversationState(bFirstPerson);
			else if (newConActor.IsA('DeusExDecoration'))
				DeusExDecoration(newConActor).EnterConversationState(bFirstPerson);
		}
	}
}

function TurnActor(Actor turnActor, Actor turnTowards)
{
	local Trestkon activePlayer;

	activePlayer = ResolveCoopPlayer();
	if (activePlayer != None)
	{
		if (DeusExPlayer(turnActor) != None)
			turnActor = activePlayer;
		if (DeusExPlayer(turnTowards) != None)
			turnTowards = activePlayer;
	}

	if (DeusExPlayer(turnActor) == None)
	{
		AddConActor(turnActor, con.bFirstPerson);

		if ((turnActor != None) && (turnActor.IsA('ScriptedPawn')) && turnTowards != turnActor)
			ScriptedPawn(turnActor).ConversationActor = turnTowards;
	}
	else
		DeusExPlayer(turnActor).ConversationActor = turnTowards;
}

function TurnSpeakingActors(Actor speaker, Actor speakingTo)
{
	local int i;
	local Trestkon activePlayer;

	activePlayer = ResolveCoopPlayer();
	if (activePlayer != None)
	{
		if (DeusExPlayer(speaker) != None)
			speaker = activePlayer;
		if (DeusExPlayer(speakingTo) != None)
			speakingTo = activePlayer;
	}
	
	TurnActor(speaker,    speakingTo);
	TurnActor(speakingTo, speaker);
	
	// In 3+ people conversations the player might not be talking or talked to
	// Thus the player's ConversationActor might be old, making them face some
	// other random NPC.
	// Fix this by always facing the talking person if we're not talking or
	// being talked to.
	if (DeusExPlayer(speaker) == None && DeusExPlayer(speakingTo) == None)
	{
		if (activePlayer != None)
		{
			activePlayer.ConversationActor = speaker;
		}
		else
		{
			for (i=0; i<ArrayCount(ConActorsBound); i++)
			{
				if (DeusExPlayer(ConActorsBound[i]) != None)
					DeusExPlayer(ConActorsBound[i]).ConversationActor = speaker;
			}
		}
	}

	if (activePlayer != None && activePlayer.bClientInThirdPersonConvo)
	{
		if (speaker != None && DeusExPlayer(speaker) == None)
		{
			activePlayer.clientConvoTarget = speaker;
			activePlayer.clientConvoTargetLoc = speaker.Location;
		}
		else if (speakingTo != None && DeusExPlayer(speakingTo) == None)
		{
			activePlayer.clientConvoTarget = speakingTo;
			activePlayer.clientConvoTargetLoc = speakingTo.Location;
		}
	}
}

function Bool StartConversation(DeusExPlayer newPlayer, optional Actor newInvokeActor, optional bool bForcePlay)
{
	local Trestkon T, activePlayer;

	if (Level.NetMode != NM_Standalone && newPlayer != None)
	{
		foreach AllActors(class'Trestkon', T)
		{
			if (T != newPlayer)
				T.BindName = "Partner";
		}
		newPlayer.BindName = "JCDenton";
	}

	if ( Super(ConPlayBase).StartConversation(newPlayer, newInvokeActor, bForcePlay) == False )
		return False;

	if (con != None && newPlayer != None)
		con.BindActorEvents(newPlayer);

	bEndingConversation = False;

	// Check to see if this conversation uses random camera placement
	randomCamera = con.bRandomCamera;

	// Based on whether we're in first-person or third-person mode, 
	// we need to derive our conversation window differently.  First-person
	// conversation mode is non-interactive and only allows speech, for
	// the most part.

	if ( con.bFirstPerson )
	{
		displayMode = DM_FirstPerson;

		conWinFirst = rootWindow.hud.CreateConWindowFirst();

		// Initialize Windowing System
		conWinFirst.conPlay = Self;
	}
	else
	{
		displayMode = DM_ThirdPerson;
		activePlayer = ResolveCoopPlayer();

		if (Level.NetMode != NM_Standalone && !bForcePlay && activePlayer != None && activePlayer != newPlayer)
		{
			conWinThird = ConWindowActive(rootWindow.NewChild(Class'tnmConWindowActive', False));
			conWinThird.SetForcePlay(bForcePlay);
			conWinThird.conPlay = Self;
			conWinThird.Hide();

			conWinFirst = rootWindow.hud.CreateConWindowFirst();
			if (conWinFirst != None)
				conWinFirst.conPlay = Self;

			activePlayer.bClientInThirdPersonConvo = True;
			activePlayer.clientConvoTarget = invokeActor;
			if (invokeActor != None)
			{
				activePlayer.clientConvoTargetLoc = invokeActor.Location;
				activePlayer.LookAtActor(invokeActor, true, false, true, 0, 0.5);
				activePlayer.SetRotation(activePlayer.DesiredRotation);
				activePlayer.ClientSetRotation(activePlayer.DesiredRotation);
			}
			activePlayer.Velocity = vect(0, 0, 0);
			activePlayer.Acceleration = vect(0, 0, 0);
			activePlayer.MakePlayerIgnored(True);
		}
		else
		{
			// Hide the hud display if this is a third-person convo
			rootWindow.hud.Hide();

			conWinThird = ConWindowActive(rootWindow.NewChild(Class'tnmConWindowActive', False));
			conWinThird.SetForcePlay(bForcePlay);

			// Setup default camera information, but only if bForcePlay is set to false
			if (!bForcePlay)
			{
				cameraInfo = con.CreateConCamera();
				cameraInfo.InitializeCameraValues(Self);

				if ( randomCamera )
					cameraInfo.SetupRandomCameraPosition();
			}

			// Initialize Windowing System
			conWinThird.conPlay = Self;

			// Align the conversation window
			conWinThird.SetWindowAlignments(HALIGN_Full, VALIGN_Full);
			conWinThird.Show();
		}
	}

	// Check to see if this is a passive or interactive conversation
	// Passive conversations are beyond the PC's control and do not have
	// things like Choices, etc. in them.

	if ( con.bNonInteractive )
		playMode = PM_Passive;
	else
		playMode = PM_Active;

	// Grab the first event!
	currentEvent = con.eventList;

	// Create a ConHistory object
	if (!bForcePlay)
		SetupHistory(player.GetDisplayName(startActor, True));

	// Play this event!
	GotoState('PlayEvent');

	return True;
}

function EEventAction SetupEventRandomLabel( ConEventRandomLabel event, out String nextLabel )
{
	local RandomEventInfoLink link;
	local int index;

	if (event.bCycleEvents)
	{
		nextLabel = trestkon(player).GetRandomEventLabel( event );
	}
	else
	{
		// Pick a random label
		nextLabel = event.GetRandomLabel();
	}

	return EA_JumpToLabel;
}

function EEventAction SetupEventAddSkillPoints( ConEventAddSkillPoints event, out String nextLabel )
{
	local Pawn P;
	local Trestkon T;

	if (Level.NetMode != NM_Standalone)
	{
		for (P = Level.PawnList; P != None; P = P.NextPawn)
		{
			T = Trestkon(P);
			if (T != None)
			{
				T.SkillPointsAdd(event.pointsToAdd);
				T.ClientMessage(event.awardMessage);
			}
		}
	}
	else
	{
		player.SkillPointsAdd(event.pointsToAdd);
		player.ClientMessage(event.awardMessage);
	}

	nextLabel = "";
	return EA_NextEvent;
}

function EEventAction SetupEventAddGoal( ConEventAddGoal event, out String nextLabel )
{
	local DeusExGoal goal;
	local Pawn P;
	local Trestkon T;

	if (Level.NetMode != NM_Standalone)
	{
		for (P = Level.PawnList; P != None; P = P.NextPawn)
		{
			T = Trestkon(P);
			if (T != None)
			{
				goal = T.AddGoal(event.goalName, event.bPrimaryGoal);
				if ( event.bGoalCompleted )
					T.GoalCompleted(event.goalName);
				else if (goal != None)
					goal.SetText(event.goalText);
				if (NetConnection(T.Player) != None)
					T.ClientSyncGoal(event.goalName, event.bPrimaryGoal, event.goalText, event.bGoalCompleted);
			}
		}
	}
	else
	{
		// First check to see if this goal exists
		goal = player.AddGoal(event.goalName, event.bPrimaryGoal);
	//	goal.SetText(event.goalText);
		if ( event.bGoalCompleted )
			player.GoalCompleted(event.goalName);
		else
			goal.SetText(event.goalText);
	}

	return EA_NextEvent;
}

function class<inventory> getitemclass(string item)
{
//	return class<inventory>( DynamicLoadObject( item, class'Class' ) );
	return class<inventory>(class'tnmUtil'.static.LookupClass(item));
}

function EEventAction SetupEventCheckObject( ConEventCheckObject event, out String nextLabel )
{
	local EEventAction nextAction;
	local Name keyName;
	local bool bHasObject;
	local Pawn P;
	local Trestkon T;

	// Okay this is some HackyHack stuff here.  We want the ability to 
	// check if the player has a particular nanokey.  Sooooooo.
	
	if ((event.checkObject == None) && (Left(event.objectName, 3) == "NK_"))
	{
		// Look for key
		keyName    = Trestkon(player).SafeStringToName(Right(event.ObjectName, Len(event.ObjectName) - 3));
		bHasObject = ((player.KeyRing != None) && (player.KeyRing.HasKey(keyName)));
	}
	else 
	{
		bHasObject = (player.FindInventoryType(getitemclass(event.objectname)) != None);
		if (!bHasObject && Level.NetMode != NM_Standalone)
		{
			for (P = Level.PawnList; P != None; P = P.NextPawn)
			{
				T = Trestkon(P);
				if (T != None && T.FindInventoryType(getitemclass(event.objectname)) != None)
				{
					bHasObject = True;
					break;
				}
			}
		}
	}

	// Now branch appropriately

	if (bHasObject)
	{
		nextAction = EA_NextEvent;
		nextLabel  = "";
	}
	else
	{
		nextAction = EA_JumpToLabel;
		nextLabel  = event.failLabel;
	}

	return nextAction;
}

function EEventAction SetupEventTransferObject( ConEventTransferObject event, out String nextLabel )
{
	local EEventAction nextAction;
	local Inventory invItemFrom;
	local Inventory invItemTo;
	local ammo AmmoType;
	local bool bSpawnedItem;
	local bool bSplitItem;
	local int itemsTransferred;
	local Trestkon activePlayer, T;
	local Pawn P;

/*
log("SetupEventTransferObject()------------------------------------------");
log("  event = " $ event);
log("  event.giveObject = " $ event.giveObject);
log("  event.fromActor  = " $ event.fromActor );
log("  event.toActor    = " $ event.toActor );
*/
	itemsTransferred = 1;

	if ( event.failLabel != "" )
	{
		nextAction = EA_JumpToLabel;
		nextLabel  = event.failLabel;
	}
	else
	{
		nextAction = EA_NextEvent;
		nextLabel = "";
	}

	// First verify that the receiver exists!
	if (event.toActor == None)
	{
		log("SetupEventTransferObject:  WARNING!  toActor does not exist!");
		log("  Conversation = " $ con.conName);
		return nextAction;
	}

	// First, check to see if the giver actually has the object.  If not, then we'll
	// fabricate it out of thin air.  (this is useful when we want to allow
	// repeat visits to the same NPC so the player can restock on items in some
	// scenarios).
	//
	// Also check to see if the item already exists in the recipient's inventory

	if (Level.NetMode != NM_Standalone)
	{
		activePlayer = ResolveCoopPlayer();
		if (activePlayer != None)
		{
			if (DeusExPlayer(event.toActor) != None)
				event.toActor = activePlayer;
			if (DeusExPlayer(event.fromActor) != None)
			{
				if (activePlayer.FindInventoryType(getitemclass(event.Objectname)) != None)
					event.fromActor = activePlayer;
				else
				{
					for (P = Level.PawnList; P != None; P = P.NextPawn)
					{
						T = Trestkon(P);
						if (T != None && T.FindInventoryType(getitemclass(event.Objectname)) != None)
						{
							event.fromActor = T;
							break;
						}
					}
				}
			}
		}
	}

	if (event.fromActor != None && Class<Ammo>(getitemclass(event.Objectname)) == None) // Don't do this for ammo, always spawn new to prevent the AI giving the player ALL of this ammo
		invItemFrom = Pawn(event.fromActor).FindInventoryType(getitemclass(event.Objectname));

	invItemTo   = Pawn(event.toActor).FindInventoryType(getitemclass(event.Objectname));

//log("  invItemFrom = " $ invItemFrom);
//log("  invItemTo   = " $ invItemTo);

	// If the player is doing the giving, make sure we remove it from 
	// the object belt.

	// If the giver doesn't have the item then we must spawn a copy of it
	if (invItemFrom == None)
	{
		if ( event.FromActor.IsA('trestkon') )
			return nextAction;

		invItemFrom = Spawn(getitemclass(event.Objectname));
		bSpawnedItem = True;
	}
	if (TNMItems(invItemFrom) != None)
		TNMItems(invItemFrom).bItemRefusalOverride = true;
	else if (TNMWeapon(invItemFrom) != None)
		TNMWeapon(invItemFrom).bItemRefusalOverride = true;

	// If we're giving this item to the player and he does NOT yet have it,
	// then make sure there's enough room in his inventory for the 
	// object!

	if ((invItemTo == None) &&
		(DeusExPlayer(event.toActor) != None) && 
	    (DeusExPlayer(event.toActor).FindInventorySlot(invItemFrom, True) == False))
	{
		// First destroy the object if we previously Spawned it
		if (bSpawnedItem)
			invItemFrom.Destroy();
				
		return nextAction;
	}

	// Okay, there's enough room in the player's inventory or we're not 
	// transferring to the player in which case it doesn't matter.
	//
	// Now check if the recipient already has the item.  If so, we are just
	// going to give it to him, with a few special cases.  Otherwise we
	// need to spawn a new object.

	if (invItemTo != None)
	{
		// Check if this item was in the player's hand, and if so, remove it
		RemoveItemFromPlayer(invItemFrom);

		// If this is ammo, then we want to just increment the ammo count
		// instead of adding another ammo to the inventory

		if (invItemTo.IsA('Ammo'))
		{
			// If this is Ammo and the player already has it, make sure the player isn't
			// already full of this ammo type! (UGH!)
			if (!Ammo(invItemTo).AddAmmo(Ammo(invItemFrom).AmmoAmount))
			{
				invItemFrom.Destroy();
				return nextAction;
			}

			// Destroy our From item
			invItemFrom.Destroy();		
		}

		// Pawn cannot have multiple weapons, but we do want to give the 
		// player any ammo from the weapon
		else if ((invItemTo.IsA('Weapon')) && (DeusExPlayer(event.ToActor) != None))
		{

			AmmoType = Ammo(DeusExPlayer(event.ToActor).FindInventoryType(Weapon(invItemTo).AmmoName));

			if ( AmmoType != None )
			{
				// Special case for Grenades and LAMs.  Blah.
				if ((AmmoType.IsA('AmmoEMPGrenade')) || 
				    (AmmoType.IsA('AmmoGasGrenade')) || 
					(AmmoType.IsA('AmmoNanoVirusGrenade')) ||
					(AmmoType.IsA('AmmoLAM')))
				{
					if (!AmmoType.AddAmmo(event.TransferCount))
					{
						invItemFrom.Destroy();
						return nextAction;
					}
				}
				else
				{
					if (!AmmoType.AddAmmo(Weapon(invItemTo).PickUpAmmoCount))
					{
						invItemFrom.Destroy();
						return nextAction;
					}

					event.TransferCount = Weapon(invItemTo).PickUpAmmoCount;
					itemsTransferred = event.TransferCount;
				}

				if (event.ToActor.IsA('DeusExPlayer'))
					DeusExPlayer(event.ToActor).UpdateAmmoBeltText(AmmoType);

				// Tell the player he just received some ammo!
				invItemTo = AmmoType;
			}
			else
			{
				// Don't want to show this as being received in a convo
				invItemTo = None;
			}

			// Destroy our From item
			invItemFrom.Destroy();
			invItemFrom = None;
		}

		// Otherwise check to see if we need to transfer more than 
		// one of the given item
		else
		{
			// If we're at max copies we can't take another, so destroy the spawned one
			if (DeusExPickup(invItemTo) != None && DeusExPickup(invItemTo).bCanHaveMultipleCopies && DeusExPickup(invItemTo).NumCopies >= DeusExPickup(invItemTo).MaxCopies)
			{
				invItemFrom.Destroy();
				invItemFrom = None;
				return nextAction;
			}
			
			itemsTransferred = AddTransferCount(invItemFrom, invItemTo, event, Pawn(event.toActor), False);

			// If no items were transferred, then the player's inventory is full or 
			// no more of these items can be stacked, so abort.
			/*if (itemsTransferred == 0)
				return nextAction;*/

			// Now destroy the originating object (which we either spawned
			// or is sitting in the giver's inventory), but check to see if this 
			// item still has any copies left first

			if (((invItemFrom.IsA('DeusExPickup')) && (DeusExPickup(invItemFrom).bCanHaveMultipleCopies) && (DeusExPickup(invItemFrom).NumCopies <= 0)) ||
			   ((invItemFrom.IsA('DeusExPickup')) && (!DeusExPickup(invItemFrom).bCanHaveMultipleCopies)) ||
			   (!invItemFrom.IsA('DeusExPickup')))
			{
				invItemFrom.Destroy();
				invItemFrom = None;
			}

			// If no items were transferred, then the player's inventory is full or 
			// no more of these items can be stacked, so abort.
			if (itemsTransferred == 0)
				return nextAction;
		}
	}

	// Okay, recipient does *NOT* have the item, so it must be give
	// to that pawn and the original destroyed
	else
	{
		// If the item being given is a stackable item and the 
		// recipient isn't receiving *ALL* the copies, then we 
		// need to spawn a *NEW* copy and give that to the recipient.
		// Otherwise just do a "SpawnCopy", which transfers ownership
		// of the object to the new owner.

		if ((invItemFrom.IsA('DeusExPickup')) && (DeusExPickup(invItemFrom).bCanHaveMultipleCopies) && 
		    (DeusExPickup(invItemFrom).NumCopies > event.transferCount))
		{
			itemsTransferred = event.TransferCount;
			invItemTo = Spawn(getitemclass(event.Objectname));
			invItemTo.GiveTo(Pawn(event.toActor));
			DeusExPickup(invItemFrom).NumCopies -= event.transferCount;
			bSplitItem   = True;
			bSpawnedItem = True;
		}
		else
		{
			invItemTo = invItemFrom.SpawnCopy(Pawn(event.toActor));
		}

//log("  invItemFrom = "$  invItemFrom);
//log("  invItemTo   = " $ invItemTo);

		if (DeusExPlayer(event.toActor) != None)
			DeusExPlayer(event.toActor).FindInventorySlot(invItemTo);

		// Check if this item was in the player's hand *AND* that the player is 
		// giving the item to someone else.
		if ((DeusExPlayer(event.fromActor) != None) && (!bSplitItem))
			RemoveItemFromPlayer(invItemFrom);

		// If this was a DataVaultImage, then the image needs to be 
		// properly added to the datavault
		if ((invItemTo.IsA('DataVaultImage')) && (event.toActor.IsA('DeusExPlayer')))
		{
			DeusExPlayer(event.toActor).AddImage(DataVaultImage(invItemTo));
			if (Level.NetMode != NM_Standalone && player != None && player != event.toActor)
				player.AddImage(DataVaultImage(invItemTo));
				
			if (conWinThird != None)
				conWinThird.ShowReceivedItem(invItemTo, 1);
			else
				DeusExRootWindow(player.rootWindow).hud.receivedItems.AddItem(invItemTo, 1);

			invItemFrom = None;
			invItemTo   = None;
		}

		// Special case for Credit Chits also
		else if ((invItemTo.IsA('Credits')) && (event.toActor.IsA('DeusExPlayer')))
		{
			if (conWinThird != None)
				conWinThird.ShowReceivedItem(invItemTo, Credits(invItemTo).numCredits);
			else
				DeusExRootWindow(player.rootWindow).hud.receivedItems.AddItem(invItemTo, Credits(invItemTo).numCredits);

			DeusExPlayer(event.toActor).Credits += Credits(invItemTo).numCredits;
			if (Trestkon(event.toActor) != None)
				Trestkon(event.toActor).lastSyncedCredits = -1;
			
			invItemTo.Destroy();

			invItemFrom = None;
			invItemTo   = None;
		}

		// Now check to see if the transfer event specified transferring
		// more than one copy of the object
		else
		{
			itemsTransferred = AddTransferCount(invItemFrom, invItemTo, event, Pawn(event.toActor), True);

			// If no items were transferred, then the player's inventory is full or 
			// no more of these items can be stacked, so abort.
			if (itemsTransferred == 0)
			{
				invItemTo.Destroy();
				return nextAction;
			}

			// Update the belt text
			if (invItemTo.IsA('Ammo'))
				DeusExPlayer(event.toActor).UpdateAmmoBeltText(Ammo(invItemTo));
			else
				DeusExPlayer(event.toActor).UpdateBeltText(invItemTo);
		}
	}

	// Show the player that he/she/it just received something!
	if ((DeusExPlayer(event.toActor) != None) && (conWinThird != None) && (invItemTo != None))
	{
		if (Nanokey(invItemTo) != None)
			invItemTo.beltDescription = strPass;
			
		if (conWinThird != None)
			conWinThird.ShowReceivedItem(invItemTo, itemsTransferred);
		else
			DeusExRootWindow(player.rootWindow).hud.receivedItems.AddItem(invItemTo, itemsTransferred);
	}

	nextAction = EA_NextEvent;
	nextLabel = "";

	return nextAction;
}

static function bool IsList(out string list)
{
  local bool result;
  result = Left(list,len(killedlabel)) ~= killedLabel;
  if (result)
    list = Right(list,len(list) - len(killedLabel));
  return result;
}

static function bool GetMap(out string list, out string map, out int kill)
{
  local string str;
  local int pos;
  pos = instr(list, separatorlabel);
  if ( pos == -1 )
  {
    for(pos=len(list)-1;pos>=0;pos--)
      if(mid(list,pos,1)=="_")
        break;
    map = left(list, pos);
    Log( "kill string: " $ mid(list, pos+1));
    kill = int(mid(list, pos+1));
    list = "";
    return false;
  }
  else
  {
    kill = 0;
    map = left( list, pos );
    list = right( list, len(list) - pos - len(separatorlabel) );
    return true;
  }
}

function EEventAction SetupEventCheckFlag( ConEventCheckFlag event, out String nextLabel )
{
	if (player != None)
		return class'tnmconplay'.static.g_SetupEventCheckFlag(player,event,nextLabel);
	return class'tnmconplay'.static.g_SetupEventCheckFlag(deusexplayer(GetPlayerPawn()),event,nextLabel);
}

static function bool g_FlagSet( name flagname, deusexplayer player )
{
	local string list;
	local int killed, basealive, kill, mapbasealive;
	local bool next;
	local string map;
	local bool check;
	local tnmmissionscript script;
	local Trestkon T;

	if ( left(string(flagName),11) == "Killed_M23_" )
	{
		// list="Killed_23_ABIExterior_and_23_ABIInterior_and_23_ABIRuins_and_23_ABILabs_"$mid(string(flagName), 11);
		// This seems to only be used by TNMConvos2\Mission23_Infolink\PM_Kylie02 which doesn't ask about the labs.
		list="Killed_23_ABIExterior_and_23_ABIInterior_and_23_ABIRuins_"$mid(string(flagName), 11);
	}
	else
	{
		list = string(flagName);
	}
	if ( IsList(list) )
	{
		killed = 0;
		basealive = 0;
		next=true;
		while(next)
		{
			next=class'tnmconplay'.static.GetMap(list, map, kill);
			mapbasealive = player.flagBase.GetInt(Trestkon(player).SafeStringToName(map $ "_startcount"));
			if ( mapbasealive > 0)
			{
				foreach player.allactors( class'tnmmissionscript', script, )
				{
					Log("mapbasealive:"@mapbasealive);
					Log("CountLiving:"@script.CountLiving(map));
					killed += mapbasealive - script.CountLiving(map);
					break;
				}
				basealive += mapbasealive;
			}
		}

		check= basealive == 0 || 100 * killed / basealive < kill || killed == 0;
	}
	else if ( flagName == 'HAS_LlamaHostageCorpse' )
	{
		check=player.inhand != none && player.inhand.isA( 'tnmpovcorpse' ) && tnmpovcorpse(player.inhand).givenbindname == "LlamaHostage";
		if (!check && player.Level.NetMode != NM_Standalone)
		{
			foreach player.AllActors(class'Trestkon', T)
			{
				if (T.inhand != None && T.inhand.IsA('tnmpovcorpse') && tnmpovcorpse(T.inhand).givenbindname == "LlamaHostage")
				{
					check = True;
					break;
				}
			}
		}
	}
	else if ( flagName == 'HAS_MasterKaleCorpse' )
	{
		check=player.inhand != none && player.inhand.isA( 'tnmpovcorpse' ) && tnmpovcorpse(player.inhand).givenbindname == "Master_Kale";
		if (!check && player.Level.NetMode != NM_Standalone)
		{
			foreach player.AllActors(class'Trestkon', T)
			{
				if (T.inhand != None && T.inhand.IsA('tnmpovcorpse') && tnmpovcorpse(T.inhand).givenbindname == "Master_Kale")
				{
					check = True;
					break;
				}
			}
		}
	}
	else
	{
		check=player.flagBase.GetBool(flagName);
	}

	return check;
}

static function EEventAction g_SetupEventCheckFlag( deusexplayer player, ConEventCheckFlag event, out String nextLabel )
{
	local ConFlagRef currentRef;
	local EEventAction action;
	local string list;
	local int kill;
	local int killed;
	local int basealive;
	local int mapbasealive;
	local string map;
	local bool check, next;
	local int i;

	// Default values if we actually make it all the way 
	// through the while loop below.

	nextLabel = event.setLabel;
	action = EA_JumpToLabel;
	
	// Loop through our list of FlagRef's, checking the value of each.
	// If we hit a bad match, then we'll stop right away since there's
	// no point of continuing.

	currentRef = event.flagRef;
	while( currentRef != None )
	{	
		if ( class'tnmconplay'.static.g_FlagSet(currentRef.flagName, player) != currentRef.value )
		{
			nextLabel = "";
			action = EA_NextEvent;
			break;
		}

		currentRef = currentRef.nextFlagRef;
	}
	
	return action;
}

state ConPlayAnim
{
 Begin:

	if ( ConEventAnimation(currentEvent).sequence == 'FinishPlayingAnim' )
		ConEventAnimation(currentEvent).eventOwner.FinishAnim();
	else if ( ConEventAnimation(currentEvent).playMode == AM_Loop )
		ConEventAnimation(currentEvent).eventOwner.LoopAnim( ConEventAnimation(currentEvent).sequence );
	else
		ConEventAnimation(currentEvent).eventOwner.PlayAnim( ConEventAnimation(currentEvent).sequence );

	if ( ConEventAnimation(currentEvent).playLength > 0 )
	{
		Sleep(Float(ConEventAnimation(currentEvent).playLength));
		ConEventAnimation(currentEvent).eventOwner.FinishAnim();
	}
	else if (ConEventAnimation(currentEvent).playMode == AM_Once && ConEventAnimation(currentEvent).bFinishAnim)
		ConEventAnimation(currentEvent).eventOwner.FinishAnim();

	if (Pawn(ConEventAnimation(currentEvent).eventOwner) == None)
		Pawn(ConEventAnimation(currentEvent).eventOwner).animTimer[2] = 0;
	currentEvent = currentEvent.nextEvent;
	GotoState('PlayEvent');
}

// ---------------------------------------------------------------------
// AddTransferCount()
// ----------------------------------------------------------------------

function int AddTransferCount(
	Inventory invItemFrom, 
	Inventory invItemTo, 
	ConEventTransferObject event, 
	pawn transferTo, 
	bool bSpawned)
{
	local ammo AmmoType;
	local int itemsTransferred;
	local DeusExPickup giveItem;

	itemsTransferred = 1;
/*
log("AddTransferCount()-------------------------------");
log("  invItemFrom = " $ invItemFrom);
log("  invItemTo   = " $ invItemTo);
log("  transferTo  = " $ transferTo);
log("  bSpawned    = " $ bSpawned);
log("  event.transferCount = " $ event.transferCount);
*/
	if (invItemTo == None)
		return 0;

	// If this is a Weapon, then we need to just add additional 
	// ammo.
	if (invItemTo.IsA('Weapon'))
	{
		if (event.transferCount > 1)
		{
			AmmoType = Ammo(transferTo.FindInventoryType(Weapon(invItemTo).AmmoName));

			if ( AmmoType != None )
			{
				itemsTransferred = Weapon(invItemTo).PickUpAmmoCount * (event.transferCount - 1);
				AmmoType.AddAmmo(itemsTransferred);

				// For count displayed
				itemsTransferred++;
			}
		}
	}

	// If this is a DeusExPickup and he already has it, just 
	// increment the count
	else if ((invItemTo.IsA('DeusExPickup')) && (DeusExPickup(invItemTo).bCanHaveMultipleCopies))
	{
		// If the item was spawned, then it will already have a copy count of 1, so we
		// only want to add to that if it was specified to transfer > 1 items.

		if (bSpawned)
		{
			itemsTransferred = event.transferCount;
			if (event.transferCount > 1)
			{
				DeusExPickup(invItemTo).NumCopies += event.transferCount - 1;

				if (DeusExPickup(invItemTo).NumCopies > DeusExPickup(invItemTo).maxCopies)
				{
					itemsTransferred = DeusExPickup(invItemTo).maxCopies;
					DeusExPickup(invItemTo).NumCopies = DeusExPickup(invItemTo).maxCopies;
				}
			}
		}

		// Wasn't spawned, so add the appropriate amount (if transferCount
		// isn't specified, just add one).

		else
		{
			if (event.transferCount > 0)
				itemsTransferred = event.transferCount;
			else
				itemsTransferred = 1;

			if ((DeusExPickup(invItemTo).NumCopies + itemsTransferred) > DeusExPickup(invItemTo).MaxCopies)
				itemsTransferred = DeusExPickup(invItemTo).MaxCopies - DeusExPickup(invItemTo).NumCopies;

			DeusExPickup(invItemTo).NumCopies += itemsTransferred;

			if ((DeusExPickup(invItemFrom) != None) && (invItemFrom != InvItemTo))
				DeusExPickup(invItemFrom).NumCopies -= itemsTransferred;
		}

		// Update the belt text
		DeusExPickup(invItemTo).UpdateBeltText();
	}
	else if ((invItemTo.IsA('DeusExPickup')) && (!bSpawned))
	{
		giveItem = DeusExPickup(Spawn(invItemTo.Class));
 
		// Just give the player another one of these fucking things
		if ((DeusExPlayer(transferTo) != None) && (DeusExPlayer(transferTo).FindInventorySlot(giveItem)))
		{
			itemsTransferred = 1;
			giveItem.GiveTo(transferTo);
		}
		else
		{
			itemsTransferred = 0;
			giveItem.Destroy();
		}
	}
	//== Y|y: Track ammo counts correctly
	else if(invItemTo.IsA('DeusExAmmo'))
	{
		itemsTransferred = Ammo(invItemTo).AmmoAmount;
	}

//log("  return itemsTransferred = " $ itemsTransferred);

	return itemsTransferred;
}

function PlaySpeech( int soundID, Actor speaker )
{
	local Sound speech;
	local Trestkon T;
	local float displayRadius;

	speech = con.GetSpeechAudio(soundID);

	if (speech != None)
	{
		displayRadius = FMax(1024.0, 2.0 * FMax(float(saveRadiusDistance), 400.0));
		if (bForcePlay || (con != None && (!con.bFirstPerson || con.bCannotBeInterrupted)))
		{
			if ((speaker == None) || (VSize(player.Location - speaker.Location) > 400))
				playingSoundID = player.PlaySound(speech, SLOT_Talk,,,65536.0);
			else
				playingSoundID = speaker.PlaySound(speech, SLOT_Talk,,,65536.0);

			if (Level.NetMode != NM_Standalone && Role == ROLE_Authority)
			{
				foreach AllActors(class'Trestkon', T)
				{
					if (T != player && NetConnection(T.Player) != None)
						T.ClientPlayConAudio(string(speech), True, True);
				}
			}
		}
		else if (speaker != None)
		{
			playingSoundID = speaker.PlaySound(speech, SLOT_Talk,,,displayRadius);
			if (Level.NetMode != NM_Standalone && Role == ROLE_Authority)
			{
				foreach AllActors(class'Trestkon', T)
				{
					if (T != player && NetConnection(T.Player) != None && VSize(T.Location - speaker.Location) <= displayRadius)
						T.ClientPlayConAudio(string(speech), True, True);
				}
			}
		}
	}

	StartSpeakingAnimation();
}

function EEventAction SetupEventSpeechPost( ConEventSpeech event, out String nextLabel )
{
	local EEventAction nextAction;
	local Pawn P;
	local Trestkon T;
	local string speakerLabel;
	local Actor refActor;
	local float displayRadius;

	nextAction = Super.SetupEventSpeechPost(event, nextLabel);

	if (Level.NetMode != NM_Standalone && nextAction == EA_WaitForInput)
		nextAction = EA_WaitForText;

	if (Level.NetMode != NM_Standalone && event != None && event.conSpeech != None)
	{
		refActor = event.speaker;
		if (refActor == None)
			refActor = startActor;
		if (refActor == None)
			refActor = invokeActor;

		displayRadius = FMax(800.0, 2.0 * FMax(float(saveRadiusDistance), 400.0));

		if (event.speaker != None && player != None)
			speakerLabel = player.GetDisplayName(event.speaker);
		if (speakerLabel == "" && event.speaker != None && event.speaker.FamiliarName != "")
			speakerLabel = event.speaker.FamiliarName;
		if (speakerLabel == "" && event.speakerName != "")
			speakerLabel = event.speakerName;
		if (speakerLabel == "")
			speakerLabel = "Dialogue";

		if (displayMode == DM_FirstPerson && !bForcePlay && refActor != None && player != None)
		{
			if (VSize(player.Location - refActor.Location) > displayRadius)
			{
				if (conWinFirst != None)
					conWinFirst.Hide();
			}
		}
		else if (displayMode == DM_ThirdPerson && conWinThird != None && !conWinThird.IsVisible() && conWinFirst != None && player != None)
		{
			if (bForcePlay || refActor == None || VSize(player.Location - refActor.Location) <= displayRadius)
			{
				conWinFirst.Show();
				if (event.bContinued)
				{
					conWinFirst.AppendText(event.conSpeech.speech);
				}
				else
				{
					conWinFirst.Clear();
					conWinFirst.DisplayName(speakerLabel);
					conWinFirst.DisplayText(event.conSpeech.speech, currentSpeaker);
				}
			}
			else
			{
				conWinFirst.Hide();
			}
		}

		foreach AllActors(class'Trestkon', T)
		{
			if (T != player && NetConnection(T.Player) != None)
			{
				if (displayMode != DM_FirstPerson || bForcePlay || refActor == None || VSize(T.Location - refActor.Location) <= displayRadius)
					T.ClientShowSubtitle(speakerLabel, Left(event.conSpeech.speech, 220), event.bContinued);
			}
		}
	}

	return nextAction;
}

function StartSpeakingAnimation()
{
	// Log(ConEventSpeech(currentEvent).conSpeech.Speech);
	
	Super.StartSpeakingAnimation();
	
	// Hack, don't do convo gestures when not talking
	if ( ConEventSpeech(currentEvent) != None && ConEventSpeech(currentEvent).conSpeech.Speech == "..." && Pawn(speakingActor) != None)
		Pawn(speakingActor).bIsSpeaking = False;
}

function Font GetCurrentSpeechFont()
{
	local int resWidth;

	resWidth = GetCurrentResolutionWidth();

	// if ((resWidth > 800)/* && (resWidth < 1280)*/)
	// if ((resWidth > 1280 && Int(player.GetPropertyText("ScaleMode")) == 1)/* && (resWidth < 1280)*/)
	if (resWidth > 1280 && Trestkon(player).bLargeFont)
		return ConversationSpeechFonts[1];
	else
		return ConversationSpeechFonts[0];
}

function Font GetCurrentNameFont()
{
	local int resWidth;

	resWidth = GetCurrentResolutionWidth();

	// if ((resWidth > 800)/* && (resWidth < 1280)*/)
	// if ((resWidth > 1280 && Int(player.GetPropertyText("ScaleMode")) == 1)/* && (resWidth < 1280)*/)
	if (resWidth > 1280 && Trestkon(player).bLargeFont)
		return ConversationNameFonts[1];
	else
		return ConversationNameFonts[0];
}

defaultproperties
{
     strPass="PASS"
     creditsText="Credits:"
}
