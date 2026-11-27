class TNMOggMusicManager extends DXOggMusicManager;

var(DXOggMusicManager) string Ambient2IntroOggFile;
var(DXOggMusicManager) string Ambient2OggFile;
var(DXOggMusicManager) string Ambient1IntroOggFile;
var(DXOggMusicManager) string Ambient1OggFile;

var(DXOggMusicManager) name FlagName;

var() string AltAmbient1IntroOggFile;
var() string AltAmbient1OggFile;
var() string AltAmbient2IntroOggFile;
var() string AltAmbient2OggFile;
var() string AltCombatIntroOggFile;
var() string AltCombatOggFile;
var() string AltConversationIntroOggFile;
var() string AltConversationOggFile;
var() string AltOutroOggFile;
var() string AltDeathOggFile;

var bool bShouldPlayStereo;
var bool bPlayingStereo;

var string stereoTrack;
var TNMDecoration stereo;

var int soundPauses;

var transient bool binited;

var bool bPlayOutro;
var bool bReversed;
var bool bServerCombat;
var bool bServerBoss;
var bool bServerAftermath;
var bool bServerUberAlles;
var string RepAmbient1IntroOggFile;
var string RepAmbient1OggFile;
var string RepAmbient2IntroOggFile;
var string RepAmbient2OggFile;
var string RepCombatIntroOggFile;
var string RepCombatOggFile;
var string RepConversationIntroOggFile;
var string RepConversationOggFile;
var string RepOutroOggFile;
var string RepDeathOggFile;
var string RepActiveIntroOgg;
var string RepActiveLoopOgg;
var EMusicTransition RepActiveTransition;
var string ClientLastIntroOgg;
var string ClientLastLoopOgg;

replication
{
	reliable if (Role == ROLE_Authority)
		Ambient1IntroOggFile, Ambient1OggFile,
		Ambient2IntroOggFile, Ambient2OggFile,
		RepAmbient1IntroOggFile, RepAmbient1OggFile,
		RepAmbient2IntroOggFile, RepAmbient2OggFile,
		RepCombatIntroOggFile, RepCombatOggFile,
		RepConversationIntroOggFile, RepConversationOggFile,
		RepOutroOggFile, RepDeathOggFile,
		RepActiveIntroOgg, RepActiveLoopOgg, RepActiveTransition,
		AltAmbient1IntroOggFile, AltAmbient1OggFile,
		AltAmbient2IntroOggFile, AltAmbient2OggFile,
		AltCombatIntroOggFile, AltCombatOggFile,
		AltConversationIntroOggFile, AltConversationOggFile,
		AltOutroOggFile, AltDeathOggFile,
		FlagName, bPlayOutro, soundPauses,
		bServerCombat, bServerBoss, bServerAftermath, bServerUberAlles;
}

// DXOgg's natives only act when Role == ROLE_Authority (they were written for
// singleplayer). Client-side managers are proxies, so every native call made on
// a client goes through these and borrows Authority for the call. Calling
// SetCurrentOgg directly on a client silently does nothing.
simulated function CoopNativeSetCurrentOgg(string oggFileIntro, string oggFileLoop, int playPos, EMusicTransition transition)
{
	local ENetRole oldRole;

	oldRole = Role;
	if (Level.NetMode == NM_Client)
		Role = ROLE_Authority;
	SetCurrentOgg(oggFileIntro, oggFileLoop, playPos, transition);
	Role = oldRole;
}

simulated function float CoopNativeGetPosition()
{
	local ENetRole oldRole;
	local float pos;

	oldRole = Role;
	if (Level.NetMode == NM_Client)
		Role = ROLE_Authority;
	pos = GetCurrentSongPosition();
	Role = oldRole;
	return pos;
}

simulated function string CoopNativeNextLoop()
{
	local ENetRole oldRole;
	local string loop;

	oldRole = Role;
	if (Level.NetMode == NM_Client)
		Role = ROLE_Authority;
	loop = GetNextOggFileLoop();
	Role = oldRole;
	return loop;
}

simulated function CoopNativeStop()
{
	local ENetRole oldRole;

	oldRole = Role;
	if (Level.NetMode == NM_Client)
		Role = ROLE_Authority;
	StopPlayback();
	Role = oldRole;
}

simulated function SyncSetCurrentOgg(string oggFileIntro, string oggFileLoop, float playPos, EMusicTransition transition)
{
	local Pawn P;
	local Trestkon T;

	CoopNativeSetCurrentOgg(oggFileIntro, oggFileLoop, int(playPos), transition);
	if (Level.NetMode != NM_Client)
	{
		RepActiveIntroOgg = oggFileIntro;
		RepActiveLoopOgg = oggFileLoop;
		RepActiveTransition = transition;
		for (P = Level.PawnList; P != None; P = P.NextPawn)
		{
			T = Trestkon(P);
			if (T != None && NetConnection(T.Player) != None)
				T.ClientPlayOgg(oggFileIntro, oggFileLoop, bShouldPlayStereo);
		}
		ClientLastIntroOgg = oggFileIntro;
		ClientLastLoopOgg = oggFileLoop;
	}
}

simulated function Pause()
{
	soundPauses++;
	if (soundPauses == 1)
	{
		savedSongPos = CoopNativeGetPosition();
		SyncSetCurrentOgg( "Blank.ogg" , "Blank.ogg" , 0.0 , MTRAN_Instant);
		MusicMode = MUS_None;
	}
}

simulated function UnPause()
{
	soundPauses--;
	if (soundPauses < 0)
		soundpauses = 0;
	if (soundPauses == 0)
	{
		tick(0.0); //this has the potential to do dodgy things (e.g. div 0) but hopefully will be ok.    
	}	
}

simulated function PostPostBeginPlay()
{
}

simulated function init()
{
	local FlagBase flags;
	local Trestkon P;

	if (Level.NetMode != NM_Client)
	{
		RepAmbient1IntroOggFile = Ambient1IntroOggFile;
		RepAmbient1OggFile = Ambient1OggFile;
		RepAmbient2IntroOggFile = Ambient2IntroOggFile;
		RepAmbient2OggFile = Ambient2OggFile;
		RepCombatIntroOggFile = CombatIntroOggFile;
		RepCombatOggFile = CombatOggFile;
		RepConversationIntroOggFile = ConversationIntroOggFile;
		RepConversationOggFile = ConversationOggFile;
		RepOutroOggFile = OutroOggFile;
		RepDeathOggFile = DeathOggFile;
	}
	else
	{
		if (Ambient1IntroOggFile == "" && RepAmbient1IntroOggFile != "")
			Ambient1IntroOggFile = RepAmbient1IntroOggFile;
		if (Ambient1OggFile == "" && RepAmbient1OggFile != "")
			Ambient1OggFile = RepAmbient1OggFile;
		if (Ambient2IntroOggFile == "" && RepAmbient2IntroOggFile != "")
			Ambient2IntroOggFile = RepAmbient2IntroOggFile;
		if (Ambient2OggFile == "" && RepAmbient2OggFile != "")
			Ambient2OggFile = RepAmbient2OggFile;
		if (CombatIntroOggFile == "" && RepCombatIntroOggFile != "")
			CombatIntroOggFile = RepCombatIntroOggFile;
		if (CombatOggFile == "" && RepCombatOggFile != "")
			CombatOggFile = RepCombatOggFile;
		if (ConversationIntroOggFile == "" && RepConversationIntroOggFile != "")
			ConversationIntroOggFile = RepConversationIntroOggFile;
		if (ConversationOggFile == "" && RepConversationOggFile != "")
			ConversationOggFile = RepConversationOggFile;
		if (OutroOggFile == "" && RepOutroOggFile != "")
			OutroOggFile = RepOutroOggFile;
		if (DeathOggFile == "" && RepDeathOggFile != "")
			DeathOggFile = RepDeathOggFile;
	}

	P = Trestkon(GetPlayerPawn());
	if (P == None || P.Outer.Name == 'Entry' || (P.Outer.Name == 'DX' && P.PlayerReplicationInfo != None && P.PlayerReplicationInfo.PlayerName ~= "Partner"))
		return;
	if (P != None)
		flags = P.FlagBase;

	if (FlagName != '' && FlagName != 'None' && flags != None && flags.GetBool(FlagName))
	{
		AmbientIntroOggFile = Ambient2IntroOggFile;
		AmbientOggFile = Ambient2OggFile;
		if (Len(AltAmbient2OggFile) > 0 && P != None && P.bAltSoundtrack)
		{
			AmbientIntroOggFile = AltAmbient2IntroOggFile;
			AmbientOggFile = AltAmbient2OggFile;
		}
	}
	else
	{
		AmbientIntroOggFile = Ambient1IntroOggFile;
		AmbientOggFile = Ambient1OggFile;
		if (Len(AltAmbient1OggFile) > 0 && P != None && P.bAltSoundtrack)
		{
			AmbientIntroOggFile = AltAmbient1IntroOggFile;
			AmbientOggFile = AltAmbient1OggFile;
		}
	}

	if (Len(AmbientOggFile) > 0 && (Level.NetMode != NM_Client || ClientLastLoopOgg == ""))
		SyncSetCurrentOgg(AmbientIntroOggFile, AmbientOggFile, 0.0, MTran_Instant);
	musicMode = MUS_Ambient;
}


simulated function PlayStereoSong(string inStereoTrack, tnmDecoration inStereo, optional string inStereoIntroTrack)
{
	if ((bShouldPlayStereo == true) && (stereoTrack == inStereoTrack) && (stereo == inStereo))
		return;

	if((Len(inStereoTrack) > 0) && (inStereo != none))
	{
		stereo = inStereo;
		stereoTrack = inStereoTrack;
		bShouldPlayStereo = true;
		bPlayingStereo = true;
		musicMode = MUS_Ambient;
		musicChangeTimer = 0.0;
		SyncSetCurrentOgg(inStereoIntroTrack, stereoTrack, 0.0, MTRAN_FastFade);
	}
	else
	{
		bShouldPlayStereo = false;
		bPlayingStereo = false;
		stereoTrack = "";
		if ( musicMode == MUS_Ambient )
			SyncSetCurrentOgg(AmbientIntroOggFile, AmbientOggFile, 0.0, MTRAN_Fade);
	}
}

simulated function Tick(float deltaTime)
{
	local trestkon player;
	local DeusExLevelInfo info;

	local bool bCombat;
	local bool bBoss;
	local bool bAftermath;
	local bool bUberAlles;
	local bool bAnyInConvo;
	local ScriptedPawn npc;
	local Pawn CurPawn;
	
	local string outroTrack;
	local string deathTrack;
	local string convoIntroTrack, convoTrack;
	local string ambientIntroTrack, ambientTrack;
	local string combatIntroTrack, combatTrack;
	local TNMOggMusicManager otherOgg, primaryOgg;

	player = trestkon(GetPlayerPawn());
	if (player == None || player.Outer.Name == 'Entry' || (player.Outer.Name == 'DX' && player.PlayerReplicationInfo != None && player.PlayerReplicationInfo.PlayerName ~= "Partner"))
		return;

	if (Level.NetMode == NM_Client)
	{
		foreach AllActors(class'TNMOggMusicManager', otherOgg)
		{
			if (primaryOgg == None)
				primaryOgg = otherOgg;
		}
		if (primaryOgg == None)
			primaryOgg = Self;

		if (RepActiveLoopOgg != "" && (ClientLastLoopOgg != RepActiveLoopOgg || ClientLastIntroOgg != RepActiveIntroOgg))
		{
			primaryOgg.CoopNativeSetCurrentOgg(RepActiveIntroOgg, RepActiveLoopOgg, 0, MTRAN_Instant);
			primaryOgg.CoopNativeGetPosition();
			foreach AllActors(class'TNMOggMusicManager', otherOgg)
			{
				otherOgg.Role = ROLE_SimulatedProxy;
				otherOgg.RepActiveIntroOgg = RepActiveIntroOgg;
				otherOgg.RepActiveLoopOgg = RepActiveLoopOgg;
				otherOgg.ClientLastIntroOgg = RepActiveIntroOgg;
				otherOgg.ClientLastLoopOgg = RepActiveLoopOgg;
				otherOgg.AmbientIntroOggFile = RepActiveIntroOgg;
				otherOgg.AmbientOggFile = RepActiveLoopOgg;
				otherOgg.binited = true;
			}
			log("CoopMod TNMOggMusicManager.Tick Client Sync: intro=" $ RepActiveIntroOgg $ " loop=" $ RepActiveLoopOgg);
		}
		else if (!binited && ClientLastLoopOgg == "" && (Ambient1OggFile != "" || RepAmbient1OggFile != ""))
		{
			init();
			if (Len(AmbientOggFile) > 0)
			{
				primaryOgg.CoopNativeSetCurrentOgg(AmbientIntroOggFile, AmbientOggFile, 0, MTRAN_Instant);
				primaryOgg.CoopNativeGetPosition();
				foreach AllActors(class'TNMOggMusicManager', otherOgg)
				{
					otherOgg.Role = ROLE_SimulatedProxy;
					otherOgg.ClientLastIntroOgg = AmbientIntroOggFile;
					otherOgg.ClientLastLoopOgg = AmbientOggFile;
					otherOgg.AmbientIntroOggFile = AmbientIntroOggFile;
					otherOgg.AmbientOggFile = AmbientOggFile;
					otherOgg.binited = true;
				}
			}
		}
		return;
	}

	if ( !binited )
	{
		init();
		binited = true;
	}

	if (FlagName != '' && FlagName != 'None' && player.FlagBase != None)
	{
		if (player.FlagBase.GetBool(FlagName) && AmbientOggFile != Ambient2OggFile && AmbientOggFile != AltAmbient2OggFile)
		{
			AmbientIntroOggFile = Ambient2IntroOggFile;
			AmbientOggFile = Ambient2OggFile;
			if (Len(AltAmbient2OggFile) > 0 && player.bAltSoundtrack)
			{
				AmbientIntroOggFile = AltAmbient2IntroOggFile;
				AmbientOggFile = AltAmbient2OggFile;
			}
			if (musicMode == MUS_Ambient && Len(AmbientOggFile) > 0)
				SyncSetCurrentOgg(AmbientIntroOggFile, AmbientOggFile, 0.0, MTRAN_Fade);
		}
	}

	if (soundPauses == 0)
	{
		if (musicMode == MUS_Outro)
			return;

		if (!player.PlayerIsClient() && (musicMode == MUS_Dying))
			return;

		if (bPlayOutro)
		{
			if(Len(OutroOggFile) > 0)
			{
				outroTrack = OutroOggFile;
				if (Len(AltOutroOggFile) > 0 && player.bAltSoundtrack)
					outroTrack = AltOutroOggFile;
				SyncSetCurrentOgg(outroTrack, "blank.ogg", 0.0, MTRAN_FastFade);
				musicMode = MUS_Outro;
			}
			else if (Len(AltOutroOggFile) > 0 && player.bAltSoundtrack)
			{
				outroTrack = AltOutroOggFile;
				SyncSetCurrentOgg(outroTrack, "blank.ogg", 0.0, MTRAN_FastFade);
				musicMode = MUS_Outro;
			}
		}
		else if (player.IsInState('Interpolating'))
		{
			// don't mess with the music on any of the intro maps
			info = player.GetLevelInfo();
			if ((info != None) && (info.MissionNumber < 0))
			{
				musicMode = MUS_Outro;
				return;
			}

			if (musicMode != MUS_Outro)
			{
				if(Len(OutroOggFile) > 0)
				{
					outroTrack = OutroOggFile;
					if (Len(AltOutroOggFile) > 0 && player.bAltSoundtrack)
						outroTrack = AltOutroOggFile;
					SyncSetCurrentOgg(outroTrack, "blank.ogg", 0.0, MTRAN_FastFade);
					musicMode = MUS_Outro;
				}
				else if (Len(AltOutroOggFile) > 0 && player.bAltSoundtrack)
				{
					outroTrack = AltOutroOggFile;
					SyncSetCurrentOgg(outroTrack, "blank.ogg", 0.0, MTRAN_FastFade);
					musicMode = MUS_Outro;
				}
			}
		}
		else if (player.IsInState('Dying'))
		{
			if (musicMode != MUS_Dying)
			{
				if(Len(DeathOggFile) > 0)
				{
					deathTrack = DeathOggFile;
					if (Len(AltDeathOggFile) > 0 && player.bAltSoundtrack)
						deathTrack = AltDeathOggFile;
					SyncSetCurrentOgg(deathTrack, "blank.ogg", 0.0, MTRAN_Fade);
					musicMode = MUS_Dying;
				}
				else if (Len(AltDeathOggFile) > 0 && player.bAltSoundtrack)
				{
					deathTrack = AltDeathOggFile;
					SyncSetCurrentOgg(deathTrack, "blank.ogg", 0.0, MTRAN_Fade);
					musicMode = MUS_Dying;
				}
			}
		}
		else if ( player.bCinematic && player.bCinematicInterruptMusic)
		{
			if (musicMode != MUS_Ambient)
			{
				if(Len(AmbientOggFile) > 0)
				{
					// fade slower for combat transitions
					SyncSetCurrentOgg(AmbientIntroOggFile, AmbientOggFile, savedSongPos, MTRAN_SlowFade);
					savedSongPos = 0.0;
					musicMode = MUS_Ambient;
					musicChangeTimer = 0.0;
				}
			}
		}
		else
		{
			// Super.Tick(deltaTime);
			Super(DXOgg).Tick(deltaTime);
			
			if (!player.PlayerIsClient())
			{
				if ((musicMode == MUS_Dying) || (musicMode == MUS_Outro))
					return;
			}
			else
			{
				if (musicMode == MUS_Outro)
					return;
			}
			  
			musicCheckTimer += deltaTime;
			musicChangeTimer += deltaTime;

			bAnyInConvo = player.IsInState('Conversation');
			if (!bAnyInConvo && Level.NetMode == NM_Client && DeusExRootWindow(player.rootWindow) != None && DeusExRootWindow(player.rootWindow).hud != None && DeusExRootWindow(player.rootWindow).hud.conWindow != None)
				bAnyInConvo = True;
			if (!bAnyInConvo)
			{
				for (CurPawn = Level.PawnList; CurPawn != None; CurPawn = CurPawn.NextPawn)
				{
					if (Trestkon(CurPawn) != None && CurPawn.IsInState('Conversation'))
					{
						bAnyInConvo = True;
						break;
					}
				}
			}

			if (player.IsInState('Interpolating'))
			{
				// don't mess with the music on any of the intro maps
				info = player.GetLevelInfo();
				if ((info != None) && (info.MissionNumber < 0))
				{
					musicMode = MUS_Outro;
					return;
				}

				if (musicMode != MUS_Outro)
				{
					if(Len(OutroOggFile) > 0)
					{
						outroTrack = OutroOggFile;
						if (Len(AltOutroOggFile) > 0 && player.bAltSoundtrack)
							outroTrack = AltOutroOggFile;
						SyncSetCurrentOgg("", outroTrack, 0.0, MTRAN_FastFade);
						musicMode = MUS_Outro;
					}
					else if (Len(AltOutroOggFile) > 0 && player.bAltSoundtrack)
					{
						outroTrack = AltOutroOggFile;
						SyncSetCurrentOgg("", outroTrack, 0.0, MTRAN_FastFade);
						musicMode = MUS_Outro;
					}
				}
			}
			else if (bAnyInConvo)
			{
				if (musicMode != MUS_Conversation)
				{
					if(Len(ConversationOggFile) > 0)
					{
						// save our place in the ambient track
						if (musicMode == MUS_Ambient)
							savedSongPos = CoopNativeGetPosition();
						else
							savedSongPos = 0.0;

						convoTrack = ConversationOggFile;
						convoIntroTrack = ConversationIntroOggFile;
						if (Len(AltConversationOggFile) > 0 && player.bAltSoundtrack)
						{
							convoTrack = AltConversationOggFile;
							convoIntroTrack = AltConversationIntroOggFile;
						}
						SyncSetCurrentOgg(convoIntroTrack, convoTrack, 0.0, MTRAN_Fade);
						musicMode = MUS_Conversation;
					}
					else if (Len(AltConversationOggFile) > 0 && player.bAltSoundtrack)
					{
						convoTrack = AltConversationOggFile;
						convoIntroTrack = AltConversationIntroOggFile;
						SyncSetCurrentOgg(convoIntroTrack, convoTrack, 0.0, MTRAN_Fade);
						musicMode = MUS_Conversation;
					}
				}
			}
			else if (player.IsInState('Dying'))
			{
				if (musicMode != MUS_Dying)
				{
					if(Len(DeathOggFile) > 0)
					{
						deathTrack = DeathOggFile;
						if (Len(AltDeathOggFile) > 0 && player.bAltSoundtrack)
							deathTrack = AltDeathOggFile;
						SyncSetCurrentOgg("", deathTrack, 0.0, MTRAN_Fade);
						musicMode = MUS_Dying;
					}
					else if (Len(AltDeathOggFile) > 0 && player.bAltSoundtrack)
					{
						deathTrack = AltDeathOggFile;
						SyncSetCurrentOgg("", deathTrack, 0.0, MTRAN_Fade);
						musicMode = MUS_Dying;
					}
				}
			}
			else
			{
				// only check for combat music every second
				if (musicCheckTimer >= 1.0)
				{
					musicCheckTimer = 0.0;
					bCombat = False;
					bUberAlles = False;

					if (Level.NetMode != NM_Client)
					{
						for (CurPawn = Level.PawnList; CurPawn != None; CurPawn = CurPawn.NextPawn)
						{
							npc = ScriptedPawn(CurPawn);
							if ((npc != None) && (Trestkon(npc.Enemy) != None) && (VSize(npc.Location - npc.Enemy.Location) < 1600 + npc.CollisionRadius))
							{
								if ((npc.GetStateName() == 'Attacking') || npc.GetStateName() == 'Stunned' || npc.GetStateName() == 'Burning' || npc.GetStateName() == 'TakingHit')
								{
									bCombat = True;
									if (npc.IsA('UberAlles'))
										bUberAlles = True;
									else if (npc.Owner != None && npc.owner.IsA('UberAlles'))
										bUberAlles = True;
									break;
								}
							}
						}

						if (player.MapInfo == None)
							player.GetLevelInfo();

						if (player.FlagBase != None && player.FlagBase.GetBool('MS_TurbinesStopped'))
							bCombat = True;
						else if (player.FlagBase != None && player.FlagBase.GetBool('Citadel_LavaRaised'))
							if (player.MapInfo != None && player.MapInfo.MapName ~= "22_Citadel")
								bCombat = True;

						if (player.FlagBase != None && player.FlagBase.GetBool('FirewallAlpha_Meet_Played') && !player.FlagBase.GetBool('Alpha_Defeated'))
							if (player.MapInfo != None && player.MapInfo.MapName ~= "22_FCRegistration")
								bBoss = True;

						if (player.FlagBase != None && player.FlagBase.GetBool('Alpha_Defeated'))
							if (player.MapInfo != None && player.MapInfo.MapName ~= "22_FCRegistration")
								bAftermath = True;

						bServerCombat = bCombat;
						bServerBoss = bBoss;
						bServerAftermath = bAftermath;
						bServerUberAlles = bUberAlles;
					}
					else
					{
						bCombat = bServerCombat;
						bBoss = bServerBoss;
						bAftermath = bServerAftermath;
						bUberAlles = bServerUberAlles;
					}

					if (bUberAlles)
					{
						musicChangeTimer = 0.0;

						if (musicMode != MUS_Combat)
						{
							// save our place in the ambient track
							if (musicMode == MUS_Ambient)
								savedSongPos = CoopNativeGetPosition();
							else
								savedSongPos = 0.0;
							SyncSetCurrentOgg("", "Stereo_Nevermore.ogg", 0.0, MTRAN_FastFade);
							musicMode = MUS_Combat;
						}
					}
					else if (bBoss)
					{
						musicChangeTimer = 0.0;

						if (musicMode != MUS_Combat)
						{
							// save our place in the ambient track
							if (musicMode == MUS_Ambient)
								savedSongPos = CoopNativeGetPosition();
							else
								savedSongPos = 0.0;
							SyncSetCurrentOgg("", "FCRegistration_Boss.ogg", 0.0, MTRAN_FastFade);
							musicMode = MUS_Combat;
						}
					}
					else if (bCombat)
					{
						musicChangeTimer = 0.0;

						if (musicMode != MUS_Combat)
						{
							if(Len(CombatOggFile) > 0)
							{
								// save our place in the ambient track
								if (musicMode == MUS_Ambient)
									savedSongPos = CoopNativeGetPosition();
								else
									savedSongPos = 0.0;
									
								combatIntroTrack = CombatIntroOggFile;
								combatTrack = CombatOggFile;
								if (Len(AltCombatOggFile) > 0 && player.bAltSoundtrack)
								{
									combatIntroTrack = AltCombatIntroOggFile;
									combatTrack = AltCombatOggFile;
								}
								SyncSetCurrentOgg(combatIntroTrack, combatTrack, 0.0, MTRAN_FastFade);
								musicMode = MUS_Combat;
							}
							else if (Len(AltCombatOggFile) > 0 && player.bAltSoundtrack)
							{
								// save our place in the ambient track
								if (musicMode == MUS_Ambient)
									savedSongPos = CoopNativeGetPosition();
								else
									savedSongPos = 0.0;
								
								combatIntroTrack = AltCombatIntroOggFile;
								combatTrack = AltCombatOggFile;
								SyncSetCurrentOgg(combatIntroTrack, combatTrack, 0.0, MTRAN_FastFade);
								musicMode = MUS_Combat;
							}
						}
					}
					else if (bAftermath)
					{
						if (musicChangeTimer >= 5.0)
						{
							// save our place in the ambient track
							SyncSetCurrentOgg("", "FCRegistration_Aftermath.ogg", 0.0, MTRAN_FastFade);
							savedSongPos = 0.0;
							musicMode = MUS_Ambient;
							musicChangeTimer = 0.0;
						}
					}
					else if (musicMode != MUS_Ambient)
					{
						// wait until we've been out of combat for 5 seconds before switching music
						if (musicChangeTimer >= 5.0)
						{
							if (bShouldPlayStereo && Len(stereoTrack) > 0)
							{
								SyncSetCurrentOgg("", stereoTrack, 0.0, MTRAN_Fade);
								savedSongPos = 0.0;
								musicMode = MUS_Ambient;
								musicChangeTimer = 0.0;
							}
							else if(Len(AmbientOggFile) > 0)
							{
								ambientIntroTrack = AmbientIntroOggFile;
								ambientTrack = AmbientOggFile;
								
								// fade slower for combat transitions
								if (musicMode == MUS_Combat)
									SyncSetCurrentOgg(ambientIntroTrack, ambientTrack, savedSongPos, MTRAN_SlowFade);
								else
									SyncSetCurrentOgg(ambientIntroTrack, ambientTrack, savedSongPos, MTRAN_Fade);

								savedSongPos = 0.0;
								musicMode = MUS_Ambient;
								musicChangeTimer = 0.0;
							}
						}
					}
				}
			}
		}
	}
}

defaultproperties
{
     bNoDelete=True
     RemoteRole=ROLE_SimulatedProxy
     bAlwaysRelevant=True
     bAlwaysTick=True
}
