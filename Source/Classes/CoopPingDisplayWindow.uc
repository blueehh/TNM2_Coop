//=============================================================================
// CoopPingDisplayWindow
// The Nameless Mod 2.0 - Co-op Mod by bluehh (TM)
//
// Renders a 2D projected HUD marker for Co-op Pings and downed teammates.
//=============================================================================
class CoopPingDisplayWindow extends Window;

var Trestkon ownerPlayer;

function InitWindow()
{
	Super.InitWindow();
	SetWindowAlignments(HALIGN_Full, VALIGN_Full);
	AskParentForReconfigure();
	ownerPlayer = Trestkon(GetPlayerPawn());
}

function DrawWindow(GC gc)
{
	local Trestkon P, OtherP;
	local Vector targetLoc;
	local float distMeters;
	local String pingTitle, distStr;
	local Color markerColor;

	Super.DrawWindow(gc);

	P = Trestkon(GetPlayerPawn());
	if (P == None)
		return;

	// 1. Draw Active Ping if within duration
	if (P.activePingDuration > 0.0 && P.Level.TimeSeconds < P.activePingTime + P.activePingDuration)
	{
		if (P.activePingActor != None && !P.activePingActor.bDeleteMe)
			targetLoc = P.activePingActor.Location + vect(0, 0, 1) * (P.activePingActor.CollisionHeight * 0.5);
		else
			targetLoc = P.activePingLoc;

		// Select color by ping type: 0 = Waypoint (Cyan), 1 = Hostile (Red), 2 = Item/Object (Gold), 3 = Revive/Player (Green)
		if (P.activePingType == 1)
		{
			markerColor.R = 255; markerColor.G = 64; markerColor.B = 64;
		}
		else if (P.activePingType == 2)
		{
			markerColor.R = 255; markerColor.G = 215; markerColor.B = 64;
		}
		else if (P.activePingType == 3)
		{
			markerColor.R = 80; markerColor.G = 255; markerColor.B = 120;
		}
		else
		{
			markerColor.R = 64; markerColor.G = 220; markerColor.B = 255;
		}

		distMeters = VSize(targetLoc - P.Location) / 52.5;
		distStr = int(distMeters) $ "m";
		if (P.activePingOwnerName != "")
			pingTitle = "[" $ P.activePingOwnerName $ "] " $ P.activePingLabel $ " (" $ distStr $ ")";
		else
			pingTitle = P.activePingLabel $ " (" $ distStr $ ")";

		DrawProjectedMarker(gc, P, targetLoc, pingTitle, markerColor);
	}

	// 2. Also draw a revive indicator if a co-op teammate is currently dead/waiting for Medkit revival
	if (P.Level.NetMode != NM_Standalone)
	{
		foreach P.AllActors(class'Trestkon', OtherP)
		{
			if (OtherP != P && OtherP.IsInState('Dying'))
			{
				if (OtherP.MoveTarget != None && !OtherP.MoveTarget.bDeleteMe)
					targetLoc = OtherP.MoveTarget.Location + vect(0, 0, 24);
				else
					targetLoc = OtherP.Location + vect(0, 0, 24);

				// Avoid overlapping text if the active ping is already pointing right at this body
				if (P.activePingDuration > 0.0 && P.Level.TimeSeconds < P.activePingTime + P.activePingDuration && VSize(targetLoc - P.activePingLoc) < 64.0)
					continue;

				markerColor.R = 255; markerColor.G = 90; markerColor.B = 90;
				distMeters = VSize(targetLoc - P.Location) / 52.5;
				pingTitle = "REVIVE " $ OtherP.GetCoopPlayerName() $ " [Medkit] (" $ int(distMeters) $ "m)";
				DrawProjectedMarker(gc, P, targetLoc, pingTitle, markerColor);
			}
		}
	}
}

function DrawProjectedMarker(GC gc, Trestkon P, Vector worldLoc, coerce String labelText, Color col)
{
	local Vector camLoc, diff, X, Y, Z;
	local Rotator camRot;
	local float dotX, dotY, dotZ, fovAngle, halfW, halfH, tanFov, screenX, screenY;
	local float textW, textH, boxW, boxH;

	camLoc = P.Location;
	camLoc.Z += P.BaseEyeHeight;
	camRot = P.ViewRotation;
	GetAxes(camRot, X, Y, Z);

	diff = worldLoc - camLoc;
	dotX = diff Dot X;
	dotY = diff Dot Y;
	dotZ = diff Dot Z;

	halfW = width * 0.5;
	halfH = height * 0.5;
	fovAngle = P.FovAngle;
	if (fovAngle <= 10.0)
		fovAngle = 75.0;
	tanFov = Tan(fovAngle * 0.5 * 3.14159265 / 180.0);
	if (tanFov <= 0.01)
		tanFov = 0.767;

	if (dotX > 1.0)
	{
		screenX = halfW + (dotY / (dotX * tanFov)) * halfW;
		screenY = halfH - (dotZ / (dotX * tanFov)) * halfW;
	}
	else
	{
		// Behind camera: clamp to screen edge in direction of target
		if (dotY >= 0.0)
			screenX = width - 32.0;
		else
			screenX = 32.0;
		screenY = halfH;
	}

	// Clamp within visible HUD margins
	screenX = FClamp(screenX, 48.0, width - 48.0);
	screenY = FClamp(screenY, 48.0, height - 48.0);

	gc.SetFont(Font'FontMenuSmall_DS');
	gc.GetTextExtent(0, textW, textH, labelText);

	// Draw diamond/crosshair reticle at screenX, screenY
	gc.SetStyle(DSTY_Normal);
	gc.SetTileColor(col);
	gc.DrawBox(screenX - 5, screenY - 5, 10, 10, 0, 0, 1, Texture'Solid');
	gc.DrawPattern(screenX - 3, screenY - 3, 6, 6, 0, 0, Texture'Solid');

	// Draw dark backing plate for text readability
	boxW = textW + 8;
	boxH = textH + 4;
	gc.SetTileColorRGB(12, 16, 22);
	gc.DrawPattern(screenX - (boxW * 0.5), screenY - boxH - 8, boxW, boxH, 0, 0, Texture'Solid');
	gc.SetTileColor(col);
	gc.DrawBox(screenX - (boxW * 0.5), screenY - boxH - 8, boxW, boxH, 0, 0, 1, Texture'Solid');

	// Draw label text
	gc.SetStyle(DSTY_Normal);
	gc.SetTextColor(col);
	gc.DrawText(screenX - (textW * 0.5), screenY - boxH - 6, textW + 4, textH + 2, labelText);
}

defaultproperties
{
}
