class tnmdatalinkplay extends datalinkplay;


struct S_newInfoLinkNames 
{
	var String BindName;
	var localized String DisplayName;
	var string portrait;
};

var localized S_newInfoLinkNames newinfolinknames[40];
var DataLinkTrigger queuedTriggers[8];
var int lastQueuedIndex;
var string activeSpeakerName;
var string activeSpeechText;

function bool SetConversation(Conversation newCon)
{
	local bool bConSet;

	bConSet = False;
	if (newCon == None)
		return False;

	if ((con == None) && (dataLink == None) && (!bEndTransmission))
	{
		startCon = newCon;
		con      = newCon;
		lastQueuedIndex = -1;
		bConSet  = True;
	}
	else
	{
		if (PushDataLink(newCon))
		{
			if (dataLink != None)
				dataLink.MessageQueued(True);
			bConSet = True;
		}
	}

	return bConSet;
}

function SetTrigger(DataLinkTrigger newDatalinkTrigger)
{
	if (lastQueuedIndex >= 0 && lastQueuedIndex < 8)
	{
		queuedTriggers[lastQueuedIndex] = newDatalinkTrigger;
		lastQueuedIndex = -1;
	}
	else
	{
		datalinkTrigger = newDatalinkTrigger;
	}
}

function InsertDataLink(Conversation insertCon)
{
	local int queueIndex;

	if (insertCon == None)
		return;

	for (queueIndex = 7; queueIndex > 0; queueIndex--)
	{
		dataLinkQueue[queueIndex] = dataLinkQueue[queueIndex - 1];
		queuedTriggers[queueIndex] = queuedTriggers[queueIndex - 1];
	}

	dataLinkQueue[0] = insertCon;
	queuedTriggers[0] = datalinkTrigger;
	datalinkTrigger = None;
}

function bool PushDataLink(Conversation queueCon)
{
	local int queueIndex;
	local bool bPushed;

	bPushed = False;
	lastQueuedIndex = -1;

	if (queueCon == None || (queueCon == startCon && !bEndTransmission))
		return False;

	for (queueIndex = 0; queueIndex < 8; queueIndex++)
	{
		if (dataLinkQueue[queueIndex] == queueCon)
			break;

		if (dataLinkQueue[queueIndex] == None)
		{
			dataLinkQueue[queueIndex] = queueCon;
			queuedTriggers[queueIndex] = None;
			lastQueuedIndex = queueIndex;
			bPushed = True;
			break;
		}
	}

	return bPushed;
}

function Conversation PopDataLink()
{
	local Conversation conResult;
	local int queueIndex;

	conResult = None;

	if (dataLinkQueue[0] != None)
	{
		conResult = dataLinkQueue[0];
		datalinkTrigger = queuedTriggers[0];

		for (queueIndex = 0; queueIndex < 7; queueIndex++)
		{
			dataLinkQueue[queueIndex] = dataLinkQueue[queueIndex + 1];
			queuedTriggers[queueIndex] = queuedTriggers[queueIndex + 1];
		}

		dataLinkQueue[7] = None;
		queuedTriggers[7] = None;
	}

	return conResult;
}

function TerminateConversation(optional bool bContinueSpeech, optional bool bNoPlayedFlag)
{
	activeSpeakerName = "";
	activeSpeechText = "";
	Super.TerminateConversation(bContinueSpeech, bNoPlayedFlag);
	datalinkTrigger = None;

	// flags this datalink set reach the other player now, not on the next merge
	if (tnmGameInfo(Level.Game) != None)
		tnmGameInfo(Level.Game).CoopRequestFlagMerge();
}

function AbortDataLink()
{
	local Trestkon T;

	activeSpeakerName = "";
	activeSpeechText = "";
	if (Level.NetMode != NM_Standalone && Role == ROLE_Authority)
	{
		foreach AllActors(class'Trestkon', T)
		{
			if (T != player && NetConnection(T.Player) != None)
			{
				T.ClientPlayConAudio("", True, True);
				T.ClientShowSubtitle("[EndInfoLink]", "", False);
			}
		}
	}
	Super.AbortDataLink();
}

function Bool FireNextDataLink()
{
	local Bool bResult;
	local Trestkon T;

	bResult = False;
	con      = PopDataLink();
	startCon = con;
	lastQueuedIndex = -1;

	if (con != None)
	{
		if (Level.NetMode != NM_Standalone && Role == ROLE_Authority)
		{
			foreach AllActors(class'Trestkon', T)
			{
				if (T != player && NetConnection(T.Player) != None)
					T.ClientPlayDataLink(string(con.conName));
			}
		}
		StartConversation(player, invokeActor);
		bResult = True;
	}

	return bResult;
}

function ResumeDataLinks()
{
	local Trestkon T;

	if (dataLink != None)
		return;

	if (con == None)
	{
		con = PopDataLink();
		startCon = con;
		lastQueuedIndex = -1;
	}

	if (con != None)
	{
		if (Level.NetMode != NM_Standalone && Role == ROLE_Authority)
		{
			foreach AllActors(class'Trestkon', T)
			{
				if (T != player && NetConnection(T.Player) != None)
					T.ClientPlayDataLink(string(con.conName));
			}
		}
		StartConversation(player, invokeActor);
	}
	else
	{
		if (dataLink != None)
		{
			rootWindow.hud.DestroyInfoLinkWindow();
			dataLink = None;
		}
		if (player != None)
			player.dataLinkPlay = None;
		Destroy();
	}
}

function EEventAction SetupEventCheckFlag( ConEventCheckFlag event, out String nextLabel )
{
	if (player != None)
		return class'tnmconplay'.static.g_SetupEventCheckFlag(player,event,nextLabel);
	return class'tnmconplay'.static.g_SetupEventCheckFlag(deusexplayer(GetPlayerPawn()),event,nextLabel);
}

// ----------------------------------------------------------------------
// GetDisplayName()
// ----------------------------------------------------------------------

function String GetDisplayName(String bindName)
{
	local int nameIndex;
	local string displayName;

	displayName = "";

	for(nameIndex=0; nameIndex<arrayCount(newinfoLinkNames); nameIndex++)
	{
		if (newinfoLinkNames[nameIndex].BindName == bindName)
		{
			displayName = newinfoLinkNames[nameIndex].DisplayName;
			break;
		}
	}
	return displayName;
}

static simulated function GetInfoLinkSpeakerInfo(String bindName, out String displayName, out String portraitPath)
{
	local int nameIndex;

	for (nameIndex = 0; nameIndex < ArrayCount(default.newinfolinknames); nameIndex++)
	{
		if (default.newinfolinknames[nameIndex].BindName == bindName)
		{
			if (displayName == "")
				displayName = default.newinfolinknames[nameIndex].DisplayName;
			if (portraitPath == "")
				portraitPath = default.newinfolinknames[nameIndex].portrait;
			break;
		}
	}
	if (displayName == "")
		displayName = bindName;
}

function EEventAction SetupEventAddGoal( ConEventAddGoal event, out String nextLabel )
{

	local DeusExGoal goal;
	local Pawn P;
	local Trestkon T;

	if (Level.NetMode != NM_Standalone && Role == ROLE_Authority)
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


function EEventAction SetupEventSpeech( ConEventSpeech event, out String nextLabel )
{
	local EEventAction nextAction;
	local ConEvent checkEvent;
	local String speech;
	local int nameIndex;
	local string portrait;
	local Pawn P;
	local Trestkon T;


	// Keep track of the last speaker
	lastActor = event.speaker;

	// Display the first speech chunk.
	speech = event.conSpeech.speech;

	if (!bSilent)
	{
		// If we're continuing from the last speech, then we want to Append 
		// and not Display the first chunk.
		if ( event.bContinued == True )
		{
			datalink.AppendText(speech);
		}
		else
		{
			// Clear the window, set the name of the currently speaking
			// actor and then start displaying the speech.

			datalink.ClearScreen();
			datalink.SetSpeaker(event.speakerName, GetDisplayName(event.speakerName));

			portrait = "";

			for(nameIndex=0; nameIndex<arrayCount(newinfoLinkNames); nameIndex++)
			{
				if (newinfoLinkNames[nameIndex].BindName == event.speakername)
				{
					portrait = newinfoLinknames[nameIndex].portrait;
					break;
				}
			}
			if (portrait != "")
			{
				tnmhudinfolinkdisplay(datalink).tnmsetportrait(Texture(DynamicLoadObject(portrait, class'Texture')));
				datalink.ShowPortrait();
				datalink.winText.SetPos(94, 36);
				datalink.winText.SetTextSize(42, 6);
				datalink.winName.SetSize(293, 15);
				datalink.winName.SetPos(94, 15);
				datalink.winLine.SetSize(293, 1);
				datalink.winLine.SetPos(94, 32);
			}
			else
			{
				datalink.winName.SetSize(367, 15);
				datalink.winName.SetPos(20, 15);
				datalink.winLine.SetSize(367, 1);
				datalink.winLine.SetPos(20, 32);
				datalink.winText.SetPos(20, 36);
				datalink.winText.SetTextSize(52, 6);
			}
			datalink.DisplayText(speech);

			lastSpeechTextLength = len(speech);
		}

		activeSpeakerName = event.speakerName;
		if (event.bContinued && activeSpeechText != "")
			activeSpeechText = Left(activeSpeechText @ speech, 220);
		else
			activeSpeechText = Left(speech, 220);

		if (Level.NetMode != NM_Standalone && Role == ROLE_Authority)
		{
			foreach AllActors(class'Trestkon', T)
			{
				if (T != player && NetConnection(T.Player) != None)
					T.ClientShowSubtitle("[InfoLink]|" $ event.speakerName, Left(speech, 220), event.bContinued);
			}
		}
	}

	// Save this event in the history
	AddHistoryEvent(GetDisplayName(event.speakerName), event.conSpeech );

	nextAction = EA_WaitForSpeech;
	nextLabel = "";
	return nextAction;
}

function class<inventory> getitemclass(string item)
{
return class<inventory>( DynamicLoadObject( item, class'Class' ) );
}

function EEventAction SetupEventCheckObject( ConEventCheckObject event, out String nextLabel )
{
	local EEventAction nextAction;
	local Name keyName;
	local bool bHasObject;
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
			foreach AllActors(class'Trestkon', T)
			{
				if (T.FindInventoryType(getitemclass(event.objectname)) != None)
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

// ----------------------------------------------------------------------
// Timer()
//
// Used to provide some flash at the beginning and end of the 
// transmission
// ----------------------------------------------------------------------

function Timer()
{
	local Pawn P;
	local Trestkon T;

	eventTimer += blinkRate;

	if ((!bEndTransmission) && (bStartTransmission))
	{
		datalink.ShowDatalinkIcon(!datalink.winPortrait.IsVisible());

		if ( eventTimer > startDelay )
		{
			bStartTransmission = False;
			eventTimer = 0.0;
			SetTimer(0.0, False);

			datalink.ShowTextCursor(True);
			datalink.ShowDatalinkIcon(false); // Ensure it's gone when no portrait

			// Play this event!
			GotoState('PlayEvent');
		}
	}
	else if (bEndTransmission)
	{
		datalink.winName.Show(!datalink.winName.IsVisible());

		if ( eventTimer > endDelay )
		{
			SetTimer(0.0, False);
			bEndTransmission = False;
			rootWindow.hud.DestroyInfoLinkWindow();
			dataLink = None;
			con = None;
			startCon = None;
			GotoState('');

			activeSpeakerName = "";
			activeSpeechText = "";

			if (Level.NetMode != NM_Standalone && Role == ROLE_Authority)
			{
				foreach AllActors(class'Trestkon', T)
				{
					if (T != player && NetConnection(T.Player) != None)
						T.ClientShowSubtitle("[EndInfoLink]", "", False);
				}
			}

			// Check to see if there's another DataLink to trigger
			if ( FireNextDataLink() == False )
			{
				if (Level.NetMode != NM_Standalone && Role == ROLE_Authority)
				{
					if (tnmGameInfo(Level.Game) != None)
						tnmGameInfo(Level.Game).SyncCoopState();
				}
				player.dataLinkPlay = None;
				Destroy();
			}
			else if (Level.NetMode != NM_Standalone && Role == ROLE_Authority && tnmGameInfo(Level.Game) != None)
			{
				tnmGameInfo(Level.Game).SyncCoopState();
			}
		}
	}
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
		return nextAction;
	}

	// First, check to see if the giver actually has the object.  If not, then we'll
	// fabricate it out of thin air.  (this is useful when we want to allow
	// repeat visits to the same NPC so the player can restock on items in some
	// scenarios).
	//
	// Also check to see if the item already exists in the recipient's inventory

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
		invItemFrom = Spawn(getitemclass(event.Objectname));
		bSpawnedItem = True;
	}

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
			itemsTransferred = AddTransferCount(invItemFrom, invItemTo, event, Pawn(event.toActor), False);

			// If no items were transferred, then the player's inventory is full or 
			// no more of these items can be stacked, so abort.
			if (itemsTransferred == 0)
				return nextAction;

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

			player.Credits += Credits(invItemTo).numCredits;
			
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
				player.UpdateAmmoBeltText(Ammo(invItemTo));
			else
				player.UpdateBeltText(invItemTo);
		}
	}

	// Show the player that he/she/it just received something!
	if ((DeusExPlayer(event.toActor) != None) && (conWinThird != None) && (invItemTo != None))
	{
		if (conWinThird != None)
			conWinThird.ShowReceivedItem(invItemTo, itemsTransferred);
		else
			DeusExRootWindow(player.rootWindow).hud.receivedItems.AddItem(invItemTo, itemsTransferred);
	}

	nextAction = EA_NextEvent;
	nextLabel = "";

	return nextAction;
}

function AbortAndSaveHistory()
{
	local Pawn P;
	local Trestkon T;

	bSilent = True;

	// Make sure no sound playing
	if (player != None)
		player.StopSound(playingSoundId);

	bStartTransmission = False;
	SetTimer(0.0, False);

	AbortDataLink();
	bEndTransmission = False;
	bSilent = False;

	if (Level.NetMode != NM_Standalone && Role == ROLE_Authority)
	{
		for (P = Level.PawnList; P != None; P = P.NextPawn)
		{
			T = Trestkon(P);
			if (T != None && T != player && NetConnection(T.Player) != None)
			{
				T.ClientPlayConAudio("", True, True);
				T.ClientHideSubtitle();
			}
		}
	}

	if (dataLinkQueue[0] == None)
	{
		if (player != None)
			player.dataLinkPlay = None;
		Destroy();
	}
}


function ProcessAction( EEventAction nextAction, string nextLabel )
{
	lastEvent = currentEvent;

	switch( nextAction ) 
	{
		case EA_NextEvent:
			// Proceed to the next event.
			if (currentEvent != None && currentEvent.nextEvent != None)
				currentEvent = currentEvent.nextEvent;
			else
				currentEvent = None;
			GotoState('PlayEvent');
			break;

		case EA_JumpToLabel:
			// Use the label passed back and jump to it
			if (con != None)
			{
				currentEvent = con.GetEventFromLabel( nextLabel );
				GotoState('PlayEvent');
			}
			else
			{
				currentEvent = None;
				TerminateConversation();
			}
			break;

		case EA_JumpToConversation:
			if (ConEventJump(currentEvent).jumpCon != None)
			{
				JumpToConversation( ConEventJump(currentEvent).jumpCon, nextLabel );
			}
			else
			{
				currentEvent = None;
				TerminateConversation();
			}
			break;

		case EA_WaitForSpeech:
			if (!bSilent)
			{
				// Wait for a piece of audio to finish playing
				GotoState('WaitForSpeech');
			}
			else
			{
				PlayNextEvent();
			}
			break;

		case EA_End:
			// End the Transmission
			currentEvent = None;
			TerminateConversation();
			break;
	}
}

function Bool StartConversation(DeusExPlayer newPlayer, optional Actor newInvokeActor, optional bool bForcePlay)
{
	local Actor tempActor;
	local Trestkon T;

	// If a DataLink is already active or ending, SetConversation already queued the new one in dataLinkQueue!
	// Return True before Super(ConPlayBase).StartConversation so we don't fail on con == None during bEndTransmission
	// or re-bind actors mid-transmission.
	if (dataLink != None)
		return True;

	if ( Super(ConPlayBase).StartConversation(newPlayer, newInvokeActor, bForcePlay) == False )
		return False;

	// Create the DataLink display if necessary.  If it already exists,
	// then we're presently in a DataLink and need to queue this one up
	// for play after the current DataLink is finished.
	//
	// Don't play the DataLink if 
	//
	// 1.  A First-person conversation is currently playing 
	// 2.  Player is rooting around inside a computer
	//
	// In these cases we'll just queue it up instead

	if ( ( dataLink == None ) && 
	    ((player.conPlay == None || Level.NetMode != NM_Standalone) && (NetworkTerminal(rootWindow.GetTopWindow()) == None)))
	{
		lastSpeechTextLength = 0;
		bEndTransmission = False;
		eventTimer = 0;

		datalink = rootWindow.hud.CreateInfoLinkWindow();

		if ( dataLinkQueue[0] != None )
			dataLink.MessageQueued(True);
	}
	else
	{
		return True;
	}

	// Grab the first event!
	currentEvent = con.eventList;

	// Create the history object.  Passing in True means
	// this is an InfoLink conversation.
	SetupHistory(GetDisplayName(con.GetFirstSpeakerDisplayName()), True);

	// Play a sound and wait a few seconds before starting
	datalink.ShowTextCursor(False);
	player.PlaySound(startSound, SLOT_None,,, 65536.0);
	if (Level.NetMode != NM_Standalone && Role == ROLE_Authority && startSound != None)
	{
		foreach AllActors(class'Trestkon', T)
		{
			if (T != player && NetConnection(T.Player) != None)
				T.ClientPlayConAudio(string(startSound), False, False);
		}
	}
	bStartTransmission = True;
	if (Trestkon(player).bAllowSavesDuringInfolinks)
		startDelay = 0.25;
	SetTimer(blinkRate, True);
	return True;
}

function PlaySpeech( int soundID )
{
	local Sound speech;
	local Trestkon T;

	speech = con.GetSpeechAudio(soundID);

	if (speech != None)
	{
		playingSoundID = player.PlaySound(speech, SLOT_Talk,,, 65536.0);
		if (Level.NetMode != NM_Standalone && Role == ROLE_Authority)
		{
			foreach AllActors(class'Trestkon', T)
			{
				if (T != player && NetConnection(T.Player) != None)
					T.ClientPlayConAudio(string(speech), True, True);
			}
		}
	}
}

function SetupEvent()
{
}


// ----------------------------------------------------------------------
// state WaitForSpeech
//
// Waiting for a sound to finish playing
// ----------------------------------------------------------------------

state WaitForSpeech
{
	// We get here when the timer we set when playing the sound
	// has finished.  We want to play the next event.
	function Timer()
	{
		GotoState( 'WaitForSpeech', 'SpeechFinished' );
	}

SpeechFinished:

	// Sleep for a second before continuing
	Sleep(0.5);

	// Fire the next event
	PlayNextEvent();
	Stop;

Idle:
	Sleep(0.5);
	Goto('Idle');

Begin:
	// Play the sound, set the timer and go to sleep until the sound
	// has finished playing.
	
	// First Stop any sound that was playing
	StopSpeech();

	// Check to see if there's speech to play.  If so, play it and set a 
	// timer that should complete after the speech finishes.  Otherwise 
	// we'll just display the datalink message for a set amount of time
	// and continue.

	if (ConEventSpeech(currentEvent).conSpeech.soundID != -1 )
	{
		PlaySpeech( ConEventSpeech(currentEvent).conSpeech.soundID ); 

		// Add two seconds to the sound since there seems to be a slight lag
		// Wait for all text to display
		SetTimer( FMax(lastSpeechTextLength * perCharDelay, con.GetSpeechLength(ConEventSpeech(currentEvent).conSpeech.soundID)), False );
	}
	else
	{
		SetTimer( lastSpeechTextLength * perCharDelay, False );
	}

	Goto('Idle');
}

defaultproperties
{
     newinfolinknames(0)=(BindName="Abomination",displayName="Abomination",portrait="TNM_Core_Tex.InfoPortraits.Info_Abom")
     newinfolinknames(1)=(BindName="Athena",displayName="Athena",portrait="TNM_Core_Tex.InfoPortraits.Info_Athena")
     newinfolinknames(2)=(BindName="Beeblequix",displayName="Beeblequix",portrait="TNM_Core_Tex.InfoPortraits.Info_Beeblequix")
     newinfolinknames(3)=(BindName="Beefman",displayName="Beefman",portrait="TNM_Core_Tex.InfoPortraits.Info_Beefman")
     newinfolinknames(4)=(BindName="BlackICE",displayName="Black ICE",portrait="TNM_Core_Tex.InfoPortraits.Info_BlackIce")
     newinfolinknames(5)=(BindName="DarkTemplar",displayName="Dark Templar",portrait="TNM_Core_Tex.InfoPortraits.Info_DT")
     newinfolinknames(6)=(BindName="Despot",displayName="Despot")
     newinfolinknames(7)=(BindName="DeusDiablo",displayName="Deus Diablo",portrait="TNM_Core_Tex.InfoPortraits.Info_DeusDiablo")
     newinfolinknames(8)=(BindName="Evil",displayName="Evil Invasion",portrait="TNM_Core_Tex.InfoPortraits.Info_Evil")
     newinfolinknames(9)=(BindName="Fender2k1",displayName="Fender2k1",portrait="TNM_Core_Tex.InfoPortraits.Info_Fender")
     newinfolinknames(10)=(BindName="FirewallAgent",displayName="Firewall Agent",portrait="TNM_Core_Tex.InfoPortraits.Info_Firewall")
     newinfolinknames(11)=(BindName="Hao",displayName="Hao Niu-rou",portrait="TNM_Core_Tex.InfoPortraits.Info_Hao")
     newinfolinknames(12)=(BindName="HelpSystem",displayName="Help System",portrait="TNM_Core_Tex.InfoPortraits.Info_Narcissus")
     newinfolinknames(13)=(BindName="Jackie",displayName="Jackie",portrait="TNM_Core_Tex.InfoPortraits.Info_Jackie")
     newinfolinknames(14)=(BindName="Jonas",displayName="Jonas",portrait="TNM_Core_Tex.InfoPortraits.Info_Jonas")
     newinfolinknames(15)=(BindName="Kevo",displayName="Kevo-sama",portrait="TNM_Core_Tex.InfoPortraits.Info_Critical")
     newinfolinknames(16)=(BindName="KingKashue",displayName="King Kashue",portrait="TNM_Core_Tex.InfoPortraits.Info_KingKashue")
     newinfolinknames(17)=(BindName="Kylie",displayName="Kylie",portrait="TNM_Core_Tex.InfoPortraits.Info_Kylie")
     newinfolinknames(18)=(BindName="Midashand",displayName="Midashand",portrait="TNM_Core_Tex.InfoPortraits.Info_Midashand")
     newinfolinknames(19)=(BindName="Narcissus",displayName="The Narcissus Entity",portrait="TNM_Core_Tex.InfoPortraits.Info_Narcissus")
     newinfolinknames(20)=(BindName="NVShacker",displayName="NVShacker",portrait="TNM_Core_Tex.InfoPortraits.Info_NVShacker")
     newinfolinknames(21)=(BindName="Phasmatis",displayName="Phasmatis",portrait="TNM_Support_Tex.InfoPortraits.Info_Phasmatis")
     newinfolinknames(22)=(BindName="PJ",displayName="Pimp Jojo",portrait="TNM_Core_Tex.InfoPortraits.Info_PimpJojo")
     newinfolinknames(23)=(BindName="Ricemanu",displayName="Ricemanu",portrait="TNM_Core_Tex.InfoPortraits.Info_Ricemanu")
     newinfolinknames(24)=(BindName="Ryan",displayName="Ryan",portrait="TNM_Core_Tex.InfoPortraits.Info_Ryan")
     newinfolinknames(25)=(BindName="Scara",displayName="Scara B. King",portrait="TNM_Support_Tex.InfoPortraits.Info_Scara")
     newinfolinknames(26)=(BindName="ShadowCode",displayName="ShadowCode",portrait="TNM_Core_Tex.InfoPortraits.Info_ShadowCode")
     newinfolinknames(27)=(BindName="Silver",displayName="Silver Dragon",portrait="TNM_Core_Tex.InfoPortraits.Info_Silver")
     newinfolinknames(28)=(BindName="Slicer",displayName="Slicer",portrait="TNM_Core_Tex.InfoPortraits.Info_Slicer")
     newinfolinknames(29)=(BindName="ThatGuy",displayName="That Guy",portrait="TNM_Core_Tex.InfoPortraits.Info_ThatGuy")
     newinfolinknames(30)=(BindName="TRM",displayName="TheRenegadeMaster",portrait="TNM_Core_Tex.InfoPortraits.Info_TRM")
     newinfolinknames(31)=(BindName="Winquman",displayName="Winquman",portrait="TNM_Core_Tex.InfoPortraits.Info_Winquman")
     newinfolinknames(32)=(BindName="Wolfy",displayName="Wolfy",portrait="TNM_Core_Tex.InfoPortraits.Info_Wolfy")
     newinfolinknames(33)=(BindName="Yardbomb",displayName="Yardbomb",portrait="TNM_Core_Tex.InfoPortraits.Info_Yardbomb")
     newinfolinknames(34)=(BindName="Zero",displayName="ZeroPresence",portrait="TNM_Core_Tex.InfoPortraits.Info_Zero")
     newinfolinknames(35)=(BindName="Hoover",displayName="Hoover",portrait="TNM_Support_Tex.InfoPortraits.Info_Cleaner")
     newinfolinknames(36)=(BindName="ZeroReal",displayName="Zer0Presence",portrait="TNM_Support_Tex.InfoPortraits.Info_ZeroReal")
     newinfolinknames(37)=(BindName="Granger",displayName="Granger",portrait="TNM_Support_Tex.InfoPortraits.Info_Granger")
     newinfolinknames(38)=(BindName="FirewallAlpha",displayName="Firewall Alpha",portrait="TNM_Support_Tex.InfoPortraits.Info_FirewallAlpha")
     perCharDelay=0.050000
     EndTransmission="MARKING PM AS READ..."
}
