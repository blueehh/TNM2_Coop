class TNMAugmentationDisplayWindow extends augmentationdisplaywindow;

var crosshair cross;
var localized String msgRebooting;
var localized String msgAimbotTracking;
var localized String OutOfAmmoStringAlt;
var bool bAimbotActive;
var ScriptedPawn aimbotTarget;
var localized String msgEMPHealth;
var localized String msgEnergy;

// ----------------------------------------------------------------------
// IsHeatSource()
// ----------------------------------------------------------------------

function bool IsHeatSource(Actor A)
{
	local TNMPawn TNMP;

	if ((A.bHidden) && (Player.Level.NetMode != NM_Standalone))
		return False;

	if (A.IsA('Pawn'))
	{
		TNMP = TNMPawn(A);

		if (A.IsA('ScriptedPawn'))
		{
			if (RespawnInfo(A) != None)
				return False;
			if (TNMP != none && TNMP.TNMPAM != none && TNMP.TNMPAM.findaug(class'tnmaugradartrans')!=none)
				return !TNMP.TNMPAM.findaug(class'tnmaugradartrans').bisactive;
			else
				return True;
		}
		else if ( (A.IsA('DeusExPlayer')) && (A != Player) )//DEUS_EX AMSD For multiplayer.
			return True;
		return False;
	}
	else if (A.IsA('DeusExCarcass'))
		return True;   
	else if (A.IsA('FleshFragment'))
		return True;
	else if (A.IsA('tnmThrownProjectile'))
		return tnmThrownProjectile(A).bHeatsource;
	else
		return False;
}

simulated function bool CanTarget(DeusExDecoration act)
{
	return !act.bStatic && act.bCollideWorld &&
		act.ItemName!="DEFAULT DECORATION NAME - REPORT THIS AS A BUG";
}

// ----------------------------------------------------------------------
// DrawTargetAugmentation()
// ----------------------------------------------------------------------

function DrawTargetAugmentation(GC gc)
{
	local String str, str2;
	local Actor target;
	local float boxCX, boxCY, boxTLX, boxTLY, boxBRX, boxBRY, boxW, boxH;
	local float x, y, w, h, mult, w2, h2;
	local Vector v1, v2;
	local int i, j, k;
	local DeusExWeapon weapon;
	local bool bUseOldTarget;
	local Color crossColor;
	local DeusExPlayer own;
	local vector AimLocation;
	local int AimBodyPart;local int db;


	crossColor.R = 255; crossColor.G = 255; crossColor.B = 255;

	// check 3125 feet in front of the player (was 500)
	target = TraceLOS(50000,AimLocation);

   targetplayerhealthstring = "";
   targetplayerlocationstring = "";

	if ( target != None )
	{
		GetTargetReticleColor( target, crossColor );

		if ((DeusExPlayer(target) != None) && (bTargetActive))
		{
			AimBodyPart = DeusExPlayer(target).GetMPHitLocation(AimLocation);
			if (AimBodyPart == 1)
				TargetPlayerLocationString = "("$msgHead$")";
			else if ((AimBodyPart == 2) || (AimBodyPart == 5) || (AimBodyPart == 6))
				TargetPlayerLocationString = "("$msgTorso$")";
			else if ((AimBodyPart == 3) || (AimBodyPart == 4))
				TargetPlayerLocationString = "("$msgLegs$")";
		}

		weapon = DeusExWeapon(Player.Weapon);
		if ((weapon != None) && !weapon.bHandToHand && !bUseOldTarget)
		{
			// if the target is out of range, don't draw the reticle
			if (weapon.MaxRange >= VSize(target.Location - Player.Location))
			{
				if (cross.bIsVisible)
				{
					w = width;
					h = height;
					x = int(w * 0.5)-1;
					y = int(h * 0.5)-1;

					// scale based on screen resolution - default is 640x480
					mult = FClamp(weapon.currentAccuracy * 80.0 * (width/640.0), corner, 80.0);

					// make sure it's not too close to the center unless you have a perfect accuracy
					mult = FMax(mult, corner+4.0);
					if (weapon.currentAccuracy == 0.0)
						mult = corner;

					// draw the drop shadowed reticle
					gc.SetTileColorRGB(0,0,0);
					for (i=1; i>=0; i--)
					{
						gc.DrawBox(x+i             , y-mult+i       , 1       , corner   , 0  , 0  , 1          , Texture'Solid'); //verticle//top & bottom
						gc.DrawBox(x+i             , y+mult-corner+i, 1       , corner   , 0  , 0  , 1          , Texture'Solid'); //verticle
						gc.DrawBox(x-mult+i       , y+i             , corner  , 1        , 0  , 0  , 1          , Texture'Solid'); //horizontal//left & right
						gc.DrawBox(x+mult-corner+i, y+i             , corner  , 1        , 0  , 0  , 1          , Texture'Solid'); //horizontal
						gc.SetTileColorRGB(255,255,255);
					}
				}
			}
		}
		// movers are invalid targets for the aug
		if (target.IsA('DeusExMover'))
			target = None;
		//some decorations are invalid targets for the aug
		if (target!=None && target.IsA('DeusExDecoration') && !CanTarget(DeusExDecoration(target)))
			target = None;
	}

	// let there be a 0.5 second delay before losing a target
	if (target == None)
	{
		if ((Player.Level.TimeSeconds - lastTargetTime < 0.5) && IsActorValid(lastTarget))
		{
			target = lastTarget;
			bUseOldTarget = True;
		}
		else
		{
			RemoveActorRef(lastTarget);
			lastTarget = None;
		}
	}
	else
	{
		lastTargetTime = Player.Level.TimeSeconds;
		bUseOldTarget = False;
		if (lastTarget != target)
		{
			RemoveActorRef(lastTarget);
			lastTarget = target;
			AddActorRef(lastTarget);
		}
	}

	if (target != None)
	{
		// draw a cornered targetting box
		v1.X = target.CollisionRadius;
		v1.Y = target.CollisionRadius;
		v1.Z = target.CollisionHeight;

		if (ConvertVectorToCoordinates(target.Location, boxCX, boxCY))
		{
			boxTLX = boxCX;
			boxTLY = boxCY;
			boxBRX = boxCX;
			boxBRY = boxCY;

			// get the smallest box to enclose actor
			// modified from Scott's ActorDisplayWindow
			for (i=-1; i<=1; i+=2)
			{
				for (j=-1; j<=1; j+=2)
				{
					for (k=-1; k<=1; k+=2)
					{
						v2 = v1;
						v2.X *= i;
						v2.Y *= j;
						v2.Z *= k;
						v2.X += target.Location.X;
						v2.Y += target.Location.Y;
						v2.Z += target.Location.Z;

						if (ConvertVectorToCoordinates(v2, x, y))
						{
							boxTLX = FMin(boxTLX, x);
							boxTLY = FMin(boxTLY, y);
							boxBRX = FMax(boxBRX, x);
							boxBRY = FMax(boxBRY, y);
						}
					}
				}
			}

			boxTLX = FClamp(boxTLX, margin, width-margin);
			boxTLY = FClamp(boxTLY, margin, height-margin);
			boxBRX = FClamp(boxBRX, margin, width-margin);
			boxBRY = FClamp(boxBRY, margin, height-margin);

			boxW = boxBRX - boxTLX;
			boxH = boxBRY - boxTLY;

			if ((bTargetActive) && (Player.Level.Netmode == NM_Standalone))
			{
				// set the coords of the zoom window, and draw the box
				// even if we don't have a zoom window
				x = width/8 + margin;
				y = height/2;
				w = width/4;
				h = height/4;

				DrawDropShadowBox(gc, x-w/2, y-h/2, w, h);

				boxCX = width/8 + margin;
				boxCY = height/2;
				boxTLX = boxCX - width/8;
				boxTLY = boxCY - height/8;
				boxBRX = boxCX + width/8;
				boxBRY = boxCY + height/8;

				if (targetLevel > 2)
				{
					if (winZoom != None)
					{
						mult = (target.CollisionRadius + target.CollisionHeight);
						v1 = Player.Location;
						v1.Z += Player.BaseEyeHeight;
						v2 = 1.5 * Player.Normal(target.Location - v1);
						winZoom.SetViewportLocation(target.Location - mult * v2);
						winZoom.SetWatchActor(target);
					}
					// window construction now happens in Tick()
				}
				else
				{
					// black out the zoom window and draw a "no image" message
					gc.SetStyle(DSTY_Normal);
					gc.SetTileColorRGB(0,0,0);
					gc.DrawPattern(boxTLX, boxTLY, w, h, 0, 0, Texture'Solid');

					gc.SetTextColorRGB(255,255,255);
					gc.GetTextExtent(0, w, h, msgNoImage);
					x = boxCX - w/2;
					y = boxCY - h/2;
					gc.DrawText(x, y, w, h, msgNoImage);
				}

				// print the name of the target above the box
				if (target.IsA('Pawn'))
					str = target.FamiliarName;
				else if (target.IsA('DeusExDecoration'))
					str = DeusExDecoration(target).itemName;
				else if (target.IsA('DeusExProjectile'))
					str = DeusExProjectile(target).itemName;
				else
					str = target.GetItemName(String(target.Class));

				// print disabled robot info
				if (target.IsA('Robot') && (Robot(target).EMPHitPoints == 0))
					str = str $ " (" $ msgDisabled $ ")";
				else if (target.IsA('TNMRobot') && (TNMRobot(target).RebootTimer > 0))
					str = str $ " (" $ msgRebooting $ ")";
				gc.SetTextColor(crossColor);

				// print the range to target
				mult = VSize(target.Location - Player.Location);
				str = str $ CR() $ msgRange @ Int(mult/16) @ msgRangeUnits;

				gc.GetTextExtent(0, w, h, str);
				x = boxTLX + margin;
				y = boxTLY - h - margin;
				gc.DrawText(x, y, w, h, str);

				// level zero gives very basic health info
				if (target.IsA('Pawn'))
					mult = Float(Pawn(target).Health) / Float(Pawn(target).Default.Health);
				else if (target.IsA('DeusExDecoration'))
					mult = Float(DeusExDecoration(target).HitPoints) / Float(DeusExDecoration(target).Default.HitPoints);
				else
					mult = 1.0;

				if (targetLevel == 0)
				{
					// level zero only gives us general health readings
					if (mult >= 0.66)
					{
						str = msgHigh;
						mult = 1.0;
					}
					else if (mult >= 0.33)
					{
						str = msgMedium;
						mult = 0.5;
					}
					else
					{
						str = msgLow;
						mult = 0.05;
					}

					str = str @ msgHealth;
				}
				else
				{
					// level one gives exact health readings
					str = Int(mult * 100.0) $ msgPercent;
					if (target.IsA('Pawn') && !target.IsA('Robot') && !target.IsA('TNMRobot') && !target.IsA('Animal') && !target.IsA('TNMAnimal'))
					{
						x = mult;		// save this for color calc
						str = str @ msgOverall;
						mult = Float(Pawn(target).HealthHead) / Float(Pawn(target).Default.HealthHead);
						str = str $ CR() $ Int(mult * 100.0) $ msgPercent @ msgHead;
						mult = Float(Pawn(target).HealthTorso) / Float(Pawn(target).Default.HealthTorso);
						str = str $ CR() $ Int(mult * 100.0) $ msgPercent @ msgTorso;
						mult = Float(Pawn(target).HealthArmLeft) / Float(Pawn(target).Default.HealthArmLeft);
						str = str $ CR() $ Int(mult * 100.0) $ msgPercent @ msgLeftArm;
						mult = Float(Pawn(target).HealthArmRight) / Float(Pawn(target).Default.HealthArmRight);
						str = str $ CR() $ Int(mult * 100.0) $ msgPercent @ msgRightArm;
						mult = Float(Pawn(target).HealthLegLeft) / Float(Pawn(target).Default.HealthLegLeft);
						str = str $ CR() $ Int(mult * 100.0) $ msgPercent @ msgLeftLeg;
						mult = Float(Pawn(target).HealthLegRight) / Float(Pawn(target).Default.HealthLegRight);
						str = str $ CR() $ Int(mult * 100.0) $ msgPercent @ msgRightLeg;
						if (TNMPawn(target) != None && TNMPawn(target).bAugmented)
						{
							mult = (TNMPawn(target).Energy) / (TNMPawn(target).Default.Energy);
							str = str $ CR() $ Max(0,Int(mult * 100.0)) $ msgPercent @ msgEnergy;
						}
						mult = x;
					}
					else
					{
						str = str @ msgHealth;
						if (target.IsA('Robot'))
						{
							mult = Float(Robot(target).EMPHitPoints) / Float(Robot(target).Default.EMPHitPoints);
							str = str $ CR() $ Int(mult * 100.0) $ msgPercent @ msgEMPHealth;
						}
					}
				}

				gc.GetTextExtent(0, w, h, str);
				x = boxTLX + margin;
				y = boxTLY + margin;
				gc.SetTextColor(GetColorScaled(mult));
				gc.DrawText(x, y, w, h, str);
				gc.SetTextColor(colHeaderText);

				if (targetLevel > 1)
				{
					// level two gives us weapon info as well
					if (target.IsA('Pawn'))
					{
						str = msgWeapon;
	
						if (Pawn(target).Weapon != None)
						{
							str = str @ Trestkon(Player).GetVanillaWeaponName(Pawn(target).Weapon);
						}
						else
							str = str @ msgNone;

						gc.GetTextExtent(0, w, h, str);
						x = boxTLX + margin;
						y = boxBRY - h - margin;
						gc.DrawText(x, y, w, h, str);
					}
				}
				if (targetLevel > 2) //added
				{
					if (target.IsA('TNMPawn'))
					{
						if (TNMPawn(target).TNMPAM != None)
						{
							TNMPawn(target).TNMPAM.drawaugtext(gc,boxBRX,boxTLY,margin);
						}
					}
/*					if (target.IsA('TNMPawn'))
					{
						str = "";
						str2 = "";
						if (TNMPawn(target).TNMPAM != None) //assumes that if bauged is false then there wont be a TNMPAM
						{
							str2 = str2 $ TNMPawn(target).TNMPAM.getaugstring(false);
							str = str $ TNMPawn(target).TNMPAM.getaugstring(true);
						}

						gc.GetTextExtent(0, w, h, str);
						gc.GetTextExtent(0, w2, h, str2);
						if (w < w2)
							w = w2;
						x = boxBRX - w - margin;
						y = boxTLY + margin;

						gc.SetTextColorRGB(255,255,255);
						gc.DrawText(x, y, w, h, str);
						gc.SetTextColorRGB(50,50,50);
//						gc.SetTextColor(colHeaderText); //should use this instead
						gc.DrawText(x, y, w, h, str2);
					}*/
				}
			}
			else
			{
				// display disabled robots
				if (target.IsA('Robot') && (Robot(target).EMPHitPoints == 0))
				{
					str = msgDisabled;
					gc.SetTextColor(crossColor);
					gc.GetTextExtent(0, w, h, str);
					x = boxCX - w/2;
					y = boxTLY - h - margin;
					gc.DrawText(x, y, w, h, str);
				}
				else if (target.IsA('TNMRobot') && (TNMRobot(target).RebootTimer > 0))
				{
					str = msgRebooting;
					gc.SetTextColor(crossColor);
					gc.GetTextExtent(0, w, h, str);
					x = boxCX - w/2;
					y = boxTLY - h - margin;
					gc.DrawText(x, y, w, h, str);
				}
			}
		}
	}
	else if ((bTargetActive) && (Player.Level.NetMode == NM_Standalone))
	{
		if (Player.Level.TimeSeconds % 1.5 > 0.75)
			str = msgScanning1;
		else
			str = msgScanning2;
		gc.GetTextExtent(0, w, h, str);
		x = width/2 - w/2;
		y = (height/2 - h) - 20;
		gc.DrawText(x, y, w, h, str);
	}

	// set the crosshair colors
	DeusExRootWindow(player.rootWindow).hud.cross.SetCrosshairColor(crossColor);
}

// ----------------------------------------------------------------------
// DrawAimbotAugmentation()
// ----------------------------------------------------------------------

function DrawAimbotAugmentation(GC gc)
{
	local String str;
	local float boxCX, boxCY;
	local float x, y, w, h, mult;
	local bool bDrawLine;

	if (aimbotTarget != None)
	{
		str = msgAimbotTracking;
		bDrawLine = True;

		mult = VSize(aimbotTarget.Location - Player.Location);
		str = str $ CR() $ aimbotTarget.UnfamiliarName;
		str = str $ CR() $ msgRange @ Int(mult/16) @ msgRangeUnits;
		if (Player.Weapon != None && (mult > DeusExWeapon(Player.Weapon).MaxRange))
			str = str $ CR() $ OutOfRangeString;
		if (Player.Weapon != None && DeusExWeapon(Player.Weapon).AmmoType != None && DeusExWeapon(Player.Weapon).AmmoType.AmmoAmount == 0)
			str = str $ CR() $ OutOfAmmoStringAlt;

		if (!ConvertVectorToCoordinates(aimbotTarget.Location, boxCX, boxCY))
			str = str $ CR() @ msgBehind;

		gc.GetTextExtent(0, w, h, str);
		x = boxCX - w/2;
		y = boxCY - h;
		gc.SetTextColorRGB(255,0,0);
		gc.DrawText(x, y, w, h, str);
		gc.SetTextColor(colHeaderText);

		if (bDrawLine)
		{
			gc.SetTileColorRGB(255,0,0);
			Interpolate(gc, width/2, height/2, boxCX, boxCY, 64);
			gc.SetTileColor(colHeaderText);
		}
	}
}

function RuleOfThirds(GC gc)
{	
	gc.SetStyle(DSTY_Masked);
	gc.DrawTexture(width * 0.33 - 32 / 2, height * 0.33 - 32 / 2, 32, 32, 0, 0, Texture'TNM.UserInterface.RevAugIconAimbot_Small');
	gc.DrawTexture(width * 0.33 - 32 / 2, height * 0.66 - 32 / 2, 32, 32, 0, 0, Texture'TNM.UserInterface.RevAugIconAimbot_Small');
	gc.DrawTexture(width * 0.66 - 32 / 2, height * 0.33 - 32 / 2, 32, 32, 0, 0, Texture'TNM.UserInterface.RevAugIconAimbot_Small');
	gc.DrawTexture(width * 0.66 - 32 / 2, height * 0.66 - 32 / 2, 32, 32, 0, 0, Texture'TNM.UserInterface.RevAugIconAimbot_Small');
	gc.SetStyle(DSTY_Normal);
}

function DrawInsanity(GC gc)
{
	local float mult, fov;
	local Rotator rot;
	local int				i, j, k, offset;
	local inventory inv;
	local float boxCX, boxCY, boxTLX, boxTLY, boxBRX, boxBRY, boxW, boxH;
	local float x, y, w, h, w2, h2;
	local Vector v1, v2;
	
	foreach player.AllActors(class'Inventory', inv)
	{
		if (inv.Owner == None && inv.LastRendered() < 0.15 && inv.DistanceFromPlayer > 160)
		{
			offset = 24;
			// draw a cornered targetting box
			v1.X = inv.CollisionRadius;
			v1.Y = inv.CollisionRadius;
			v1.Z = inv.CollisionHeight;
			if (ConvertVectorToCoordinates(inv.Location, boxCX, boxCY))
			{
				boxTLX = boxCX;
				boxTLY = boxCY;
				boxBRX = boxCX;
				boxBRY = boxCY;
				
				for (i=-1; i<=1; i+=2)
				{
					for (j=-1; j<=1; j+=2)
					{
						for (k=-1; k<=1; k+=2)
						{
							v2 = v1;
							v2.X *= i;
							v2.Y *= j;
							v2.Z *= k;
							v2.X += inv.Location.X;
							v2.Y += inv.Location.Y;
							v2.Z += inv.Location.Z;

							if (ConvertVectorToCoordinates(v2, x, y))
							{
								boxTLX = FMin(boxTLX, x);
								boxTLY = FMin(boxTLY, y);
								boxBRX = FMax(boxBRX, x);
								boxBRY = FMax(boxBRY, y);
							}
						}
					}
				}

				boxTLX += inv.CollisionRadius / 4.0;
				boxTLY += inv.CollisionHeight / 4.0;
				boxBRX -= inv.CollisionRadius / 4.0;
				boxBRY -= inv.CollisionHeight / 4.0;

				boxTLX = FClamp(boxTLX, margin, width-margin);
				boxTLY = FClamp(boxTLY, margin, height-margin);
				boxBRX = FClamp(boxBRX, margin, width-margin);
				boxBRY = FClamp(boxBRY, margin, height-margin);

				boxW = boxBRX - boxTLX;
				boxH = boxBRY - boxTLY;

				// scale the corner based on the size of the box
				corner = FClamp((boxW + boxH) * 0.1, 4.0, 40.0);

				// make sure the box doesn't invert itself
				if (boxBRX - boxTLX < corner)
				{
					boxTLX -= (corner+4);
					boxBRX += (corner+4);
				}
				if (boxBRY - boxTLY < corner)
				{
					boxTLY -= (corner+4);
					boxBRY += (corner+4);
				}

				// draw the drop shadow first, then normal
			
				// gc.DrawPattern(boxTLX, boxTLY, boxW, boxH, 0, 0, Texture'TNM_Misc_Tex.Misc.SCAnim_A00');/*
				gc.DrawStretchedTexture(boxTLX, boxTLY, boxW, boxH, 0, 0, 256, 256, Texture'TNM_Support_Tex.Misc.X');/*
				gc.SetTileColorRGB(0,0,0);
				for (i=1; i>=0; i--)
				{
					gc.DrawBox(boxTLX+i+offset, boxTLY+i+offset, corner, 1, 0, 0, 1, Texture'Solid');
					gc.DrawBox(boxTLX+i+offset, boxTLY+i+offset, 1, corner, 0, 0, 1, Texture'Solid');

					gc.DrawBox(boxBRX+i-corner-offset, boxTLY+i+offset, corner, 1, 0, 0, 1, Texture'Solid');
					gc.DrawBox(boxBRX+i-offset, boxTLY+i+offset, 1, corner, 0, 0, 1, Texture'Solid');

					gc.DrawBox(boxTLX+i+offset, boxBRY+i-offset, corner, 1, 0, 0, 1, Texture'Solid');
					gc.DrawBox(boxTLX+i+offset, boxBRY+i-corner-offset, 1, corner, 0, 0, 1, Texture'Solid');

					gc.DrawBox(boxBRX+i-corner+1-offset, boxBRY+i-offset, corner, 1, 0, 0, 1, Texture'Solid');
					gc.DrawBox(boxBRX+i-offset, boxBRY+i-corner-offset, 1, corner, 0, 0, 1, Texture'Solid');

					// gc.SetTileColor(colText);
				}*/
			}
		}
	}
}

function PostDrawWindow(GC gc)
{	
	if (bAimbotActive)
		DrawAimbotAugmentation(gc);
	if (Trestkon(Player).bInsane)
		DrawInsanity(gc);
	Show();
	if (Trestkon(Player).bRuleofThirds)
		RuleOfThirds(gc);
		
	Super.PostDrawWindow(gc);
}

function Tick(float deltaTime)
{
	// check for the drone ViewportWindow being constructed
	if (Player.bSpyDroneActive && (Player.aDrone != None) && (winDrone == None) && 
		(Player.PlayerIsClient() || (Player.Level.NetMode==NM_Standalone)) )
	{
		winDrone = ViewportWindow(NewChild(class'ViewportWindow'));
		if (winDrone != None)
		{
			winDrone.AskParentForReconfigure();
			winDrone.Lower();
			if (Trestkon(Player).bAltSpyDroneView)
				winDrone.SetViewportActor(Player); // New mode, player view is spydrone view while small window is player view.
			else
				winDrone.SetViewportActor(Player.aDrone); // Original mode, small window is the spydrone view.
		}
	}

	// check for the target ViewportWindow being constructed
	if (bTargetActive && (targetLevel > 2) && (winZoom == None) && (lastTarget != None) && (Player.Level.NetMode == NM_Standalone))
	{
		winZoom = ViewportWindow(NewChild(class'ViewportWindow'));
		if (winZoom != None)
		{
			winZoom.AskParentForReconfigure();
			winZoom.Lower();
		}
	}

	// handle Destroy() in Tick() since they can't be in DrawWindow()
	if (!Player.bSpyDroneActive)
	{
		if (winDrone != None)
		{
			winDrone.Destroy();
			winDrone = None;
		}
		if ((Player.aDrone != None) && IsActorValid(Player.aDrone))
		{
			RemoveActorRef(Player.aDrone);
			bDroneReferenced = false;
		}
		bDroneCreated = false;
	}

	if (winZoom != None)
	{
		if ((bTargetActive && (lastTarget == None)) || !bTargetActive)
		{
			winZoom.Destroy();
			winZoom = None;
		}
	}
}

function UpdateWinDrone()
{
	if (winDrone != None)
	{
		if (Trestkon(Player).bAltSpyDroneView)
			winDrone.SetViewportActor(Player); // New mode, player view is spydrone view while small window is player view.
		else
			winDrone.SetViewportActor(Player.aDrone); // Original mode, small window is the spydrone view.
	}
}

function GetTargetReticleColor(Actor target, out Color xcolor)
{
	if (target != None && target.IsA('DeusExPlayer') && target != Player && (Player == None || Player.DXGame == None))
	{
		xcolor = colGreen;
		targetPlayerColor = colGreen;
		if (DeusExPlayer(target).PlayerReplicationInfo != None)
			targetPlayerName = DeusExPlayer(target).PlayerReplicationInfo.PlayerName;
		else if (Trestkon(target) != None && Trestkon(target).TruePlayerName != "")
			targetPlayerName = Trestkon(target).TruePlayerName;
		else
			targetPlayerName = "Partner";
		if (bTargetActive && DeusExPlayer(target).Default.Health > 0)
			TargetPlayerHealthString = "(" $ int(100 * (DeusExPlayer(target).Health / Float(DeusExPlayer(target).Default.Health))) $ "%)";
		targetOutOfRange = False;
		targetPlayerTime = Player.Level.TimeSeconds + targetPlayerDelay;
		return;
	}
	if (Player != None && Player.Alliance == '')
		Player.Alliance = 'Player';
	if (ScriptedPawn(target) != None && !ScriptedPawn(target).bInitialized)
	{
		ScriptedPawn(target).InitializeAlliances();
		if (ScriptedPawn(target).Alliance != '')
			ScriptedPawn(target).ChangeAlly(ScriptedPawn(target).Alliance, 1.0, True);
		ScriptedPawn(target).bInitialized = True;
	}
	Super.GetTargetReticleColor(target, xcolor);
}

function Color GetColorScaled(float percent)
{
    local float mult;
    local Color col;

    if (percent > 0.80)
    {
        col.r = 0;
        col.g = 255;
        col.b = 0;
    }
    else if (percent > 0.40)
    {
        mult = (percent-0.40)/(0.80-0.40);
        col.r = 255 + (0-255)*mult;
        col.g = 255;
        col.b = 0;
    }
    else if (percent > 0.10)
    {
        mult = (percent-0.10)/(0.40-0.10);
        col.r = 255;
        col.g = 0 + (255-0)*mult;
        col.b = 0;
    }
    else if (percent > 0)
    {
        col.r = 255;
        col.g = 0;
        col.b = 0;
    }
    else
    {
        // col.r = 0;
        // col.g = 0;
        // col.b = 0;
        col.r = 92;
        col.g = 92;
        col.b = 92;
    }

    return col;

}

defaultproperties
{
     msgRebooting="Rebooting"
     msgAimbotTracking="* Enemy Detected *"
     OutOfAmmoStringAlt="(Out of ammo)"
     msgEMPHealth="EMP strength"
     msgEnergy="Energy"
     msgTeamNsf="You're on Team Finders!"
     msgTeamUnatco="You're on Team Hiders!"
}
