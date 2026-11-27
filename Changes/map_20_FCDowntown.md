# Co-op map analysis: 20_FCDowntown

9777 actors placed.

## Proximity (radius) conversations

Stock `ScriptedPawn.Tick` / `DeusExDecoration.Tick` start these only for `GetPlayerPawn()` (the host). A client walking up alone does not trigger them.

- `DTThug1` (Thug01) — **DTThugs** radius 192, first-person=True, once=True
- `DowntownMale05` (GPMale2) — **DeusDiablo** radius 256, first-person=True, once=True
- `DowntownFirewall` (Firewall) — **DowntownFirewall_Mission** radius 192, first-person=False, once=True
- `DowntownFirewall` (Firewall) — **DowntownFirewall_DeliveredKale** radius 256, first-person=False, once=True
- `DowntownFirewall` (Firewall) — **DowntownFirewall_ArrestedKale1** radius 192, first-person=False, once=True
- `DowntownFirewall` (Firewall) — **DowntownFirewall_ArrestedKale2** radius 192, first-person=False, once=True
- `DowntownMale01` (GPMale2) — **DespotRumours** radius 128, first-person=True, once=True
- `DowntownFemale06` (GPBusinesswoman2) — **DowntownFemale06** radius 192, first-person=True, once=False
- `DowntownMale04` (GPMale2) — **Arcadia** radius 384, first-person=True, once=True

## Skill award triggers

Stock `SkillAwardTrigger` gives points only to the toucher/instigator. Once-only ones then switch off, so the other player never gets them (670 points across once-only awards here).

- `SkillAwardTrigger2` 40 pts, once=True, radius=default
- `SkillAwardTrigger0` 40 pts, once=True, radius=default
- `SkillAwardTrigger5` 60 pts, once=True, radius=128.000000
- `SkillAwardTrigger3` 40 pts, once=True, radius=192.000000
- `SkillAwardTrigger1` 50 pts, once=True, radius=128.000000
- `SkillAwardTrigger4` 50 pts, once=True, radius=64.000000
- `SkillAwardTrigger6` 20 pts, once=True, radius=64.000000
- `SkillAwardTrigger7` 150 pts, once=True, radius=64.000000
- `SkillAwardTrigger8` 75 pts, once=True, radius=64.000000
- `SkillAwardTrigger9` 75 pts, once=True, radius=64.000000
- `SkillAwardTrigger10` 50 pts, once=True, radius=128.000000
- `SkillAwardTrigger11` 20 pts, once=True, radius=64.000000

## Triggers wired to movers

`Trigger.Touch` has no occupancy count and `UnTouch` fires when either player leaves. Risky for non-once triggers driving TriggerToggle (opens then closes when both players enter) or TriggerControl (closes on the partner when one leaves).

- `FlagTrigger0` (FlagTrigger, once=False) -> `DeusExMover55` TriggerOpenTimed
- `FlagTrigger0` (FlagTrigger, once=False) -> `DeusExMover56` TriggerOpenTimed
- `FlagTrigger4` (FlagTrigger, once=False) -> `DeusExMover11` TriggerOpenTimed
- `FlagTrigger4` (FlagTrigger, once=False) -> `DeusExMover12` TriggerOpenTimed
- `FlagTrigger5` (FlagTrigger, once=False) -> `DeusExMover13` TriggerOpenTimed
- `FlagTrigger5` (FlagTrigger, once=False) -> `DeusExMover14` TriggerOpenTimed
- `FlagTrigger2` (FlagTrigger, once=False) -> `DeusExMover104` TriggerOpenTimed
- `FlagTrigger2` (FlagTrigger, once=False) -> `DeusExMover105` TriggerOpenTimed

## Logic actors and inherited co-op hazards

| Class | Placed | Warnings | Chain |
|---|---|---|---|
| FireWall2 | 18 | 3 | FireWall2 < GenericFirewall < GenericAggressive < GenericPawn < TNMPawn < ScriptedPawn |
| GPLowerClassMale1 | 5 | 3 | GPLowerClassMale1 < GenericCivilian < GenericPawn < TNMPawn < ScriptedPawn < Pawn |
| TNMRat | 5 | 3 | TNMRat < TNMAnimal < TNMPawn < ScriptedPawn < Pawn < Actor |
| GPFemale5 | 4 | 3 | GPFemale5 < GenericCivilian < GenericPawn < TNMPawn < ScriptedPawn < Pawn |
| GPMale2 | 4 | 3 | GPMale2 < GenericCivilian < GenericPawn < TNMPawn < ScriptedPawn < Pawn |
| TNMCat | 4 | 3 | TNMCat < TNMAnimal < TNMPawn < ScriptedPawn < Pawn < Actor |
| GPFemale3 | 2 | 3 | GPFemale3 < GenericCivilian < GenericPawn < TNMPawn < ScriptedPawn < Pawn |
| GPLowerClassFemale | 2 | 3 | GPLowerClassFemale < GenericCivilian < GenericPawn < TNMPawn < ScriptedPawn < Pawn |
| GPMale1 | 2 | 3 | GPMale1 < GenericCivilian < GenericPawn < TNMPawn < ScriptedPawn < Pawn |
| GPMale3 | 2 | 3 | GPMale3 < GenericCivilian < GenericPawn < TNMPawn < ScriptedPawn < Pawn |
| Goat1 | 2 | 3 | Goat1 < GenericGoat < GenericAggressive < GenericPawn < TNMPawn < ScriptedPawn |
| Abomnation | 1 | 3 | Abomnation < TNMAggressive < TNMPawn < ScriptedPawn < Pawn < Actor |
| Aemer | 1 | 3 | Aemer < TNMCivilian < TNMPawn < ScriptedPawn < Pawn < Actor |
| BoardGuest1 | 1 | 3 | BoardGuest1 < GenericCivilian < GenericPawn < TNMPawn < ScriptedPawn < Pawn |
| Chris | 1 | 3 | Chris < TNMCivilian < TNMPawn < ScriptedPawn < Pawn < Actor |
| Firewall | 1 | 3 | Firewall < GenericFirewall < GenericAggressive < GenericPawn < TNMPawn < ScriptedPawn |
| GPBusinessman2 | 1 | 3 | GPBusinessman2 < GenericCivilian < GenericPawn < TNMPawn < ScriptedPawn < Pawn |
| GPBusinessman3 | 1 | 3 | GPBusinessman3 < GenericCivilian < GenericPawn < TNMPawn < ScriptedPawn < Pawn |
| GPBusinesswoman2 | 1 | 3 | GPBusinesswoman2 < GenericCivilian < GenericPawn < TNMPawn < ScriptedPawn < Pawn |
| GPFemale1 | 1 | 3 | GPFemale1 < GenericCivilian < GenericPawn < TNMPawn < ScriptedPawn < Pawn |
| GPFemale2 | 1 | 3 | GPFemale2 < GenericCivilian < GenericPawn < TNMPawn < ScriptedPawn < Pawn |
| GPHooker1 | 1 | 3 | GPHooker1 < GenericCivilian < GenericPawn < TNMPawn < ScriptedPawn < Pawn |
| GPLowerClassMale2 | 1 | 3 | GPLowerClassMale2 < GenericCivilian < GenericPawn < TNMPawn < ScriptedPawn < Pawn |
| Goat2 | 1 | 3 | Goat2 < GenericGoat < GenericAggressive < GenericPawn < TNMPawn < ScriptedPawn |
| GoatTemplar2 | 1 | 3 | GoatTemplar2 < GenericGoat < GenericAggressive < GenericPawn < TNMPawn < ScriptedPawn |
| GoatTemplar3 | 1 | 3 | GoatTemplar3 < GenericGoat < GenericAggressive < GenericPawn < TNMPawn < ScriptedPawn |
| Kylie | 1 | 3 | Kylie < TNMAggressive < TNMPawn < ScriptedPawn < Pawn < Actor |
| Llama1 | 1 | 3 | Llama1 < GenericLlama < GenericAggressive < GenericPawn < TNMPawn < ScriptedPawn |
| Llama3 | 1 | 3 | Llama3 < GenericLlama < GenericAggressive < GenericPawn < TNMPawn < ScriptedPawn |
| LlamaFemale | 1 | 3 | LlamaFemale < GenericLlama < GenericAggressive < GenericPawn < TNMPawn < ScriptedPawn |
| Master_Kale | 1 | 3 | Master_Kale < TNMAggressive < TNMPawn < ScriptedPawn < Pawn < Actor |
| MilitaryBotPDX | 1 | 3 | MilitaryBotPDX < TNMMilitaryBot < TNMRobot < Robot < ScriptedPawn < Pawn |
| SecurityBot2PDX | 1 | 3 | SecurityBot2PDX < TNMRobot < Robot < ScriptedPawn < Pawn < Actor |
| SymGeosis | 1 | 3 | SymGeosis < TNMCivilian < TNMPawn < ScriptedPawn < Pawn < Actor |
| TNMMutt | 1 | 3 | TNMMutt < TNMDog < TNMAnimal < TNMPawn < ScriptedPawn < Pawn |
| Thug01 | 1 | 3 | Thug01 < GenericThug < GenericAggressive < GenericPawn < TNMPawn < ScriptedPawn |
| Thug02 | 1 | 3 | Thug02 < GenericThug < GenericAggressive < GenericPawn < TNMPawn < ScriptedPawn |
| Walton | 1 | 3 | Walton < TNMCivilian < TNMPawn < ScriptedPawn < Pawn < Actor |
| jimmycracker | 1 | 3 | jimmycracker < TNMCivilian < TNMPawn < ScriptedPawn < Pawn < Actor |
| FlagTrigger | 19 | 2 | FlagTrigger < Trigger < Triggers < Actor < object |
| TNM_Medbot | 1 | 2 | TNM_Medbot < MedicalBot < Robot < ScriptedPawn < Pawn < Actor |
| tnmComputerPublic | 14 | 1 | tnmComputerPublic < tnmComputers < Computers < ElectronicDevices < DeusExDecoration < Decoration |
| tnmPhone | 9 | 1 | tnmPhone < ElectronicDevices < DeusExDecoration < Decoration < Actor < object |
| CashRegister | 8 | 1 | CashRegister < ElectronicDevices < DeusExDecoration < Decoration < Actor < object |
| Fish2 | 6 | 1 | Fish2 < Fishes < Animal < ScriptedPawn < Pawn < Actor |
| ComputerOffline | 3 | 1 | ComputerOffline < ElectronicDevices < DeusExDecoration < Decoration < Actor < object |
| TNMMonitor_FS | 3 | 1 | TNMMonitor_FS < tnmComputers < Computers < ElectronicDevices < DeusExDecoration < Decoration |
| AlarmUnit | 2 | 1 | AlarmUnit < HackableDevices < ElectronicDevices < DeusExDecoration < Decoration < Actor |
| tnmATM | 2 | 1 | tnmATM < ATM < ElectronicDevices < DeusExDecoration < Decoration < Actor |
| CreditReader | 1 | 1 | CreditReader < HackableDevices < ElectronicDevices < DeusExDecoration < Decoration < Actor |
| RepairBot | 1 | 1 | RepairBot < Robot < ScriptedPawn < Pawn < Actor < object |
| SubwayMachine | 1 | 1 | SubwayMachine < CigaretteMachine < ElectronicDevices < DeusExDecoration < Decoration < Actor |
| TNMDrinkMachine | 1 | 1 | TNMDrinkMachine < TNMVendingMachine < tnmComputers < Computers < ElectronicDevices < DeusExDecoration |
| TNMFoodMachine | 1 | 1 | TNMFoodMachine < TNMVendingMachine < tnmComputers < Computers < ElectronicDevices < DeusExDecoration |
| TNMTAD | 1 | 1 | TNMTAD < ElectronicDevices < DeusExDecoration < Decoration < Actor < object |
| TNMTV | 1 | 1 | TNMTV < ElectronicDevices < DeusExDecoration < Decoration < Actor < object |
| tnmComputerPersonal | 1 | 1 | tnmComputerPersonal < tnmComputers < Computers < ElectronicDevices < DeusExDecoration < Decoration |
| BlockAll | 93 | 0 | BlockAll < Keypoint < Actor < object |
| BlockPlayer | 76 | 0 | BlockPlayer < Keypoint < Actor < object |
| BlockMonsters | 32 | 0 | BlockMonsters < Keypoint < Actor < object |
| PatrolPoint | 27 | 0 | PatrolPoint < NavigationPoint < Actor < object |
| WanderPoint | 27 | 0 | WanderPoint < NavigationPoint < Actor < object |
| Teleporter | 23 | 0 | Teleporter < NavigationPoint < Actor < object |
| SkillAwardTrigger | 12 | 0 | SkillAwardTrigger < Trigger < Triggers < Actor < object |
| HidePoint | 8 | 0 | HidePoint < NavigationPoint < Actor < object |
| decalspawner | 8 | 0 | decalspawner < Keypoint < Actor < object |
| AllianceToggleTrigger | 7 | 0 | AllianceToggleTrigger < Trigger < Triggers < Actor < object |
| TNMBindNameTrigger | 6 | 0 | TNMBindNameTrigger < Trigger < Triggers < Actor < object |
| WarpZoneMarker | 6 | 0 | WarpZoneMarker < NavigationPoint < Actor < object |
| AchievementTrigger | 5 | 0 | AchievementTrigger < Trigger < Triggers < Actor < object |
| GuardPoint | 5 | 0 | GuardPoint < PatrolPoint < NavigationPoint < Actor < object |
| AllianceTrigger | 4 | 0 | AllianceTrigger < Trigger < Triggers < Actor < object |
| GoalAddTrigger | 4 | 0 | GoalAddTrigger < Trigger < Triggers < Actor < object |
| HomeBase | 4 | 0 | HomeBase < NavigationPoint < Actor < object |
| OrdersTrigger | 4 | 0 | OrdersTrigger < Trigger < Triggers < Actor < object |
| DirectionalTrigger | 2 | 0 | DirectionalTrigger < Trigger < Triggers < Actor < object |
| MSCallbackTrigger | 2 | 0 | MSCallbackTrigger < Trigger < Triggers < Actor < object |
| RandomSounds | 2 | 0 | RandomSounds < Keypoint < Actor < object |
| SpecialEvent | 2 | 0 | SpecialEvent < Triggers < Actor < object |
| ConversationForceTrigger | 1 | 0 | ConversationForceTrigger < MoreTriggers < Trigger < Triggers < Actor < object |
| ConversationTrigger | 1 | 0 | ConversationTrigger < Trigger < Triggers < Actor < object |
| DeusExLevelInfo | 1 | 0 | DeusExLevelInfo < Info < Actor < object |
| PickupDistributor | 1 | 0 | PickupDistributor < Keypoint < Actor < object |
| PlayerStart | 1 | 0 | PlayerStart < NavigationPoint < Actor < object |
| SpawnPoint | 1 | 0 | SpawnPoint < NavigationPoint < Actor < object |
| Trigger | 1 | 0 | Trigger < Triggers < Actor < object |

## FireWall2 (18 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `FireWall5` Tag=Firewall, Alliance=Firewall, Orders=Patrolling, OrderTag=Firewall01Patrol01
- `FireWall10` Tag=Firewall, Alliance=Firewall, Orders=Standing
- `Firewall15` Tag=Firewall, Alliance=Firewall, Orders=Patrolling, OrderTag=Firewall04Patrol01
- `FireWall16` Tag=Firewall, Alliance=Firewall, Orders=Patrolling, OrderTag=Firewall05Patrol01
- `FireWall7` Tag=Firewall, Alliance=Firewall, Orders=Standing
- `FireWall8` Tag=Firewall, Alliance=Firewall, Orders=Standing
- `Firewall13` Tag=Firewall, Alliance=Firewall, Orders=Patrolling, OrderTag=Firewall03Patrol01
- `Firewall1` Tag=Firewall, Alliance=Firewall, Orders=Standing
- `FireWall2` Tag=Firewall, Alliance=Firewall, Orders=Standing
- `FireWall17` Tag=Firewall, Alliance=Firewall, Orders=Patrolling, OrderTag=Firewall06Guard
- `FireWall22` Tag=Firewall, Alliance=Firewall, Orders=Patrolling, OrderTag=Firewall09Patrol01
- `FireWall24` Tag=Firewall, Alliance=Firewall, Orders=Patrolling, OrderTag=Firewall10Guard
- ... 6 more

## GPLowerClassMale1 (5 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `GPLowerClassMale1` Tag=DowntownMale02, BindName="DowntownMale02", Orders=Standing
- `GPLowerClassMale5` Tag=GPLowerClassMale1, BindName="DowntownMaleB"
- `GPLowerClassMale2` Tag=N00B, BindName="N00BMale", Alliance=N00Bz, Orders=Standing
- `GPLowerClassMale3` Tag=N00B, BindName="N00BMale", Alliance=N00Bz, Orders=Standing
- `GPLowerClassMale4` Tag=N00B, BindName="N00BMale", Alliance=N00Bz, Orders=Standing

## TNMRat (5 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `TNMRat1` Tag=Rat
- `TNMRat2` Tag=Rat
- `TNMRat3` Tag=Rat
- `TNMRat4` Tag=Rat
- `TNMRat5` Tag=Rat

## GPFemale5 (4 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `GPFemale4` Tag=GPFemale5, BindName="DowntownFemale03", Alliance=Civilians, Orders=Standing
- `GPFemale2` Tag=FanFicCustomer, BindName="DowntownFemaleA", Alliance=FanFic
- `GPFemale11` Tag=GPFemale5, BindName="DowntownFemale04", Alliance=Civilians, Orders=Standing
- `GPFemale10` Tag=GPFemale5, BindName="DowntownFemaleA", Alliance=Civilians

## GPMale2 (4 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `GPMale6` Tag=DowntownMale05, BindName="DowntownMale05", Alliance=Civilians, Orders=Standing
- `GPMale7` Tag=DowntownMale01, BindName="DowntownMale01", Orders=Standing
- `GPMale3` Tag=N00B, BindName="N00BMale", Alliance=N00Bz, Orders=Standing
- `GPMale0` Tag=DowntownMale04, BindName="DowntownMale04", Alliance=Civilians, Orders=Standing

## TNMCat (4 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `tnmCat2` Tag=TNMCat, BindName="Blues"
- `tnmCat0` Tag=TNMCat
- `tnmCat1` Tag=TNMCat
- `tnmCat3` Tag=TNMCat

## GPFemale3 (2 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `GPFemale3` Tag=GPFemale3, BindName="DowntownFemaleB", Alliance=Civilians
- `GPFemale5` Tag=GPFemale3, BindName="DowntownFemaleB", Alliance=Civilians

## GPLowerClassFemale (2 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `GPLowerClassFemale0` Tag=N00B, BindName="N00BFemale", Alliance=N00Bz, Orders=Standing
- `GPLowerClassFemale1` Tag=N00B, BindName="N00BFemale", Alliance=N00Bz, Orders=Standing

## GPMale1 (2 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `GPMale4` Tag=GPMale1, BindName="DowntownMaleA", Alliance=Civilians
- `GPMale2` Tag=N00B, BindName="N00BMale", Alliance=N00Bz, Orders=Standing

## GPMale3 (2 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `GPMale1` Tag=GPMale3, BindName="DowntownMaleC", Alliance=Civilians
- `GPMale5` Tag=GPMale3, BindName="DowntownMaleA", Alliance=Civilians, Orders=Standing

## Goat1 (2 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `Goat0` Tag=GoatKidnapper, BindName="GoatKidnapper02", Alliance=Goats, Orders=Standing
- `Goat6` Tag=GoatKidnapper, BindName="", Alliance=Goats, Orders=Patrolling, OrderTag=GoatKidnapperPatrol01

## Abomnation (1 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `Abomnation0` Tag=Abomnation, Alliance=Llamas, Orders=Standing, OrderTag=AbomGuardPoint

## Aemer (1 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `Aemer0` Tag=Aemer

## BoardGuest1 (1 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `BoardGuest0` Tag=AbomBG, BindName="BoardGuestA"

## Chris (1 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `Chris0` Tag=Chris, Alliance=FanFic, Orders=Standing

## Firewall (1 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `FireWall3` Tag=Firewall, BindName="DowntownFirewall", Alliance=Firewall, Orders=Standing

## GPBusinessman2 (1 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `GPBusinessman4` Tag=GPBusinessman2, BindName="Whoever", Alliance=Civilians, Orders=Standing

## GPBusinessman3 (1 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `GPBusinessman1` Tag=FanFicCustomer, BindName="DowntownMaleB", Alliance=FanFic

## GPBusinesswoman2 (1 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `GPBusinesswoman0` Tag=GPBusinesswoman2, BindName="DowntownFemale06", Orders=Standing

## GPFemale1 (1 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `GPFemale0` Tag=DowntownFemale01, BindName="DowntownFemale01", Alliance=Civilians, Orders=Standing

## GPFemale2 (1 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `GPFemale1` Tag=DowntownFemale02, BindName="DowntownFemale02", Alliance=Civilians, Orders=Standing

## GPHooker1 (1 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `GPHooker0` Tag=GPHooker1, BindName="DowntownFemaleB", Alliance=Civilians

## GPLowerClassMale2 (1 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `GPLowerClassMale0` Tag=GPLowerClassMale2, BindName="DowntownMale06", Alliance=Civilians, Orders=Standing

## Goat2 (1 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `Goat5` Tag=GoatKidnapper, BindName="", Alliance=Goats, Orders=Standing

## GoatTemplar2 (1 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `GoatTemplar4` Tag=GoatKidnapper, BindName="", Alliance=Goats

## GoatTemplar3 (1 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `GoatTemplar2` Tag=GoatKidnapper, BindName="GoatKidnapper01", Alliance=Goats, Orders=Standing

## Kylie (1 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `Kylie0` Tag=Kylie, Alliance=WC, Orders=Standing

## Llama1 (1 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `Llama2` Tag=LlamaGuard, BindName="LlamaMaleExterior", Orders=Standing

## Llama3 (1 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `Llama4` Tag=LlamaGuard, BindName="LlamaMaleExterior", Alliance=Llamas, Orders=Standing

## LlamaFemale (1 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `LlamaFemale0` Tag=LlamaGuard, Alliance=Llamas, Orders=Patrolling, OrderTag=Llama02Patrol01

## Master_Kale (1 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `Master_Kale0` Tag=Master_Kale, Orders=Standing

## MilitaryBotPDX (1 placed, TNMCharacters)
- **INFO** HOST_ONLY `TNMRobot.Disabled.BeginState` line 416: `player=Trestkon(GetPlayerPawn());`
- **INFO** HOST_ONLY `TNMRobot.Disabled.BeginState` line 426: `player = Trestkon(GetPlayerPawn());`
- **WARNING** HOST_ONLY `TNMRobot.StunnedTemporal.Tick` line 2323: `flagName = DeusExPlayer(GetPlayerPawn()).rootWindow.StringToName(BindName$"_Dead");`
- **INFO** HOST_ONLY_FLAGS `TNMRobot.StunnedTemporal.Tick` line 2324: `DeusExPlayer(GetPlayerPawn()).flagBase.SetBool(flagName, True);`
- **INFO** HOST_ONLY_FLAGS `TNMRobot.StunnedTemporal.Tick` line 2327: `DeusExPlayer(GetPlayerPawn()).flagBase.SetExpiration(flagName, FLAG_Bool, 0);`
- **WARNING** HOST_ONLY `TNMRobot.StunnedTemporal.Tick` line 2329: `Killed(DeusExPlayer(GetPlayerPawn()), Self, 'Banned');`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `MilitaryBotPDX0` Tag=MilitaryBotPDX, Alliance=Firewall, Orders=Standing

## SecurityBot2PDX (1 placed, TNMCharacters)
- **INFO** HOST_ONLY `TNMRobot.Disabled.BeginState` line 416: `player=Trestkon(GetPlayerPawn());`
- **INFO** HOST_ONLY `TNMRobot.Disabled.BeginState` line 426: `player = Trestkon(GetPlayerPawn());`
- **WARNING** HOST_ONLY `TNMRobot.StunnedTemporal.Tick` line 2323: `flagName = DeusExPlayer(GetPlayerPawn()).rootWindow.StringToName(BindName$"_Dead");`
- **INFO** HOST_ONLY_FLAGS `TNMRobot.StunnedTemporal.Tick` line 2324: `DeusExPlayer(GetPlayerPawn()).flagBase.SetBool(flagName, True);`
- **INFO** HOST_ONLY_FLAGS `TNMRobot.StunnedTemporal.Tick` line 2327: `DeusExPlayer(GetPlayerPawn()).flagBase.SetExpiration(flagName, FLAG_Bool, 0);`
- **WARNING** HOST_ONLY `TNMRobot.StunnedTemporal.Tick` line 2329: `Killed(DeusExPlayer(GetPlayerPawn()), Self, 'Banned');`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `SecurityBot2PDX0` Tag=SecurityBot2PDX, Alliance=Firewall, Orders=Patrolling, OrderTag=PDXBotMovie

## SymGeosis (1 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `SymGeosis0` Tag=SymGeosis, Alliance=Civilians, Orders=Standing

## TNMMutt (1 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `TNMMutt0` Tag=TNMMutt, BindName="CentralDog"

## Thug01 (1 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `Thug0` Tag=CanalThug1, BindName="DTThug1", Orders=Standing

## Thug02 (1 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `Thug1` Tag=CanalThug2, BindName="DTThug2", Orders=Standing

## Walton (1 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `Walton0` Tag=Walton, Alliance=FanFic, Orders=Patrolling, OrderTag=WaltonDownstairs

## jimmycracker (1 placed, TNMCharacters)
- **WARNING** HOST_ONLY `TNMPawn.HandleDamage` line 2214: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`
- **INFO** HOST_ONLY `TNMPawn.StunnedTaser.EndState` line 4204: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`
- **WARNING** HOST_ONLY `TNMPawn.AlphaFirewallDeath.BeginState` line 4373: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`
- **INFO** HOST_ONLY_FLAGS `TNMPawn.AlphaFirewallDeathLong.BeginState` line 4470: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `jimmycracker0` Tag=jimmycracker, Alliance=FanFic, Orders=Sitting, OrderTag=jimmycrackerchair

## FlagTrigger (19 placed, DeusEx)
- **WARNING** HOST_ONLY `FlagTrigger.Touch` line 19: `player = DeusExPlayer(GetPlayerPawn());`
- **WARNING** HOST_ONLY `FlagTrigger.UnTouch` line 45: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `FlagTrigger.Trigger` line 69: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `FlagTrigger.UnTrigger` line 99: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `FlagTrigger0` Tag=SubwayDoor_Trigger03, Event=SubwayDoor_03, bTriggerOnceOnly=False, FlagName=HAS_SubwayPass
- `FlagTrigger8` Tag=SubwayDoor_Trigger05, Event=NoTicketMessage, bTriggerOnceOnly=False, FlagName=HAS_SubwayPass, flagValue=False
- `FlagTrigger4` Tag=SubwayDoor_Trigger01, Event=SubwayDoor_01, bTriggerOnceOnly=False, FlagName=HAS_SubwayPass
- `FlagTrigger5` Tag=SubwayDoor_Trigger02, Event=SubwayDoor_02, bTriggerOnceOnly=False, FlagName=HAS_SubwayPass
- `FlagTrigger12` Tag=SubwayDoor_Trigger01, Event=NoTicketMessage, bTriggerOnceOnly=False, FlagName=HAS_SubwayPass, flagValue=False
- `FlagTrigger13` Tag=SubwayDoor_Trigger02, Event=NoTicketMessage, bTriggerOnceOnly=False, FlagName=HAS_SubwayPass, flagValue=False
- `FlagTrigger2` Tag=SubwayDoor_Trigger04, Event=SubwayDoor_04, bTriggerOnceOnly=False, FlagName=HAS_SubwayPass
- `FlagTrigger10` Tag=SubwayDoor_Trigger04, Event=NoTicketMessage, bTriggerOnceOnly=False, FlagName=HAS_SubwayPass, flagValue=False
- `FlagTrigger18` Tag=FlagTrigger, Event=GangStashGoalComplete, FlagName=QR_SUB_GangStash, CollisionRadius=128.000000
- `FlagTrigger19` Tag=GangStashFlag, FlagName=DT_FoundGangStashFirst, flagExpiration=21
- `FlagTrigger20` Tag=FlagTrigger, Event=GangStashFlag, FlagName=QR_SUB_GangStash, flagValue=False, CollisionRadius=128.000000
- `FlagTrigger21` Tag=GangStashGoalComplete, FlagName=QC_SUB_GangStash, flagExpiration=21
- ... 7 more

## TNM_Medbot (1 placed, TNMCharacters)
- **WARNING** VAR_CLIENT_TO_SERVER `MedicalBot.?` line 18: `lastHealTime, healRefreshTime`
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `TNM_Medbot0` Tag=TNM_Medbot, Orders=Standing

## tnmComputerPublic (14 placed, TNMDeco)
- **WARNING** HOST_ONLY `DeusExDecoration.Tick` line 350: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `tnmComputerPublic12` Tag=tnmComputerPublic
- `tnmComputerPublic1` Tag=tnmComputerPublic
- `tnmComputerPublic2` Tag=tnmComputerPublic
- `tnmComputerPublic3` Tag=tnmComputerPublic
- `tnmComputerPublic4` Tag=tnmComputerPublic
- `tnmComputerPublic5` Tag=tnmComputerPublic
- `tnmComputerPublic6` Tag=tnmComputerPublic
- `tnmComputerPublic7` Tag=tnmComputerPublic
- `tnmComputerPublic8` Tag=tnmComputerPublic
- `tnmComputerPublic9` Tag=tnmComputerPublic
- `tnmComputerPublic11` Tag=tnmComputerPublic
- `tnmComputerPublic10` Tag=tnmComputerPublic
- ... 2 more

## tnmPhone (9 placed, TNMDeco)
- **INFO** HOST_ONLY_FLAGS `tnmPhone.Frob` line 42: `flags = playerpawnext(getplayerpawn()).flagbase;`
- **WARNING** HOST_ONLY `DeusExDecoration.Tick` line 350: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `tnmPhone2` Tag=tnmPhone
- `tnmPhone0` Tag=tnmPhone
- `tnmPhone1` Tag=tnmPhone
- `tnmPhone3` Tag=tnmPhone
- `tnmPhone4` Tag=tnmPhone, CollisionRadius=8.000000
- `tnmPhone5` Tag=tnmPhone
- `tnmPhone6` Tag=tnmPhone
- `tnmPhone7` Tag=tnmPhone
- `tnmPhone8` Tag=tnmPhone

## CashRegister (8 placed, TNMDeco)
- **WARNING** HOST_ONLY `DeusExDecoration.Tick` line 350: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `CashRegister0` Tag=CashRegister
- `CashRegister1` Tag=CashRegister
- `CashRegister3` Tag=CashRegister
- `CashRegister2` Tag=CashRegister
- `CashRegister4` Tag=CashRegister
- `CashRegister5` Tag=CashRegister
- `CashRegister6` Tag=CashRegister
- `CashRegister7` Tag=CashRegister

## Fish2 (6 placed, DeusEx)
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `Fish58` Tag=Fish2
- `Fish59` Tag=Fish2
- `Fish60` Tag=Fish2
- `Fish61` Tag=Fish2
- `Fish62` Tag=Fish2
- `Fish63` Tag=Fish2

## ComputerOffline (3 placed, TNMDeco)
- **WARNING** HOST_ONLY `DeusExDecoration.Tick` line 350: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `ComputerOffline0` Tag=ComputerOffline
- `ComputerOffline1` Tag=ComputerOffline
- `ComputerOffline2` Tag=ComputerOffline

## TNMMonitor_FS (3 placed, TNMDeco)
- **WARNING** HOST_ONLY `DeusExDecoration.Tick` line 350: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `TNMMonitor_FS1` Tag=FanFicPC
- `TNMMonitor_FS0` Tag=TNMMonitor_FS
- `TNMMonitor_FS2` Tag=AemerPC

## AlarmUnit (2 placed, DeusEx)
- **WARNING** HOST_ONLY `DeusExDecoration.Tick` line 350: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `AlarmUnit1` Tag=BoomersAlarm, Event=CoffeeshopTurret
- `AlarmUnit3` Tag=FanFicAlarm

## tnmATM (2 placed, TNM)
- **WARNING** HOST_ONLY `DeusExDecoration.Tick` line 350: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `tnmATM0` Tag=tnmATM
- `tnmATM1` Tag=tnmATM

## CreditReader (1 placed, TNM)
- **WARNING** HOST_ONLY `DeusExDecoration.Tick` line 350: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `CreditReader0` Tag=CreditReader

## RepairBot (1 placed, DeusEx)
- **WARNING** HOST_ONLY `ScriptedPawn.Tick` line 7183: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.BeginState` line 8758: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.Conversation.EndState` line 8798: `player = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.BeginState` line 8892: `dxPlayer = DeusExPlayer(GetPlayerPawn());`
- **INFO** HOST_ONLY `ScriptedPawn.FirstPersonConversation.EndState` line 8938: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `RepairBot0` Tag=RepairBot, Orders=Standing

## SubwayMachine (1 placed, TNMDeco)
- **WARNING** HOST_ONLY `DeusExDecoration.Tick` line 350: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `SubwayMachine0` Tag=SubwayMachine

## TNMDrinkMachine (1 placed, TNMDeco)
- **WARNING** HOST_ONLY `DeusExDecoration.Tick` line 350: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `TNMDrinkMachine0` Tag=TNMDrinkMachine

## TNMFoodMachine (1 placed, TNMDeco)
- **WARNING** HOST_ONLY `DeusExDecoration.Tick` line 350: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `TNMFoodMachine0` Tag=TNMFoodMachine

## TNMTAD (1 placed, TNMDeco)
- **INFO** HOST_ONLY `TNMTAD.Timer` line 19: `player = DeusExPlayer(GetPlayerPawn());`
- **WARNING** HOST_ONLY `DeusExDecoration.Tick` line 350: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `TNMTAD0` Tag=TNMTAD

## TNMTV (1 placed, TNMDeco)
- **WARNING** HOST_ONLY `DeusExDecoration.Tick` line 350: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `TNMTV0` Tag=TNMTV

## tnmComputerPersonal (1 placed, TNMDeco)
- **WARNING** HOST_ONLY `DeusExDecoration.Tick` line 350: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `tnmComputerPersonal0` Tag=tnmComputerPersonal

## TNMBindNameTrigger (6 placed, TNM)
- **INFO** HOST_ONLY `TNMBindNameTrigger.trigger` line 21: `player = DeusExPlayer(GetPlayerPawn());`

Placed instances:
- `TNMBindNameTrigger0` Tag=DeusDiablo_Stopped, Event=DowntownMale05
- `TNMBindNameTrigger1` Tag=DeusDiabloInterrupted_Stopped, Event=DowntownMale05
- `TNMBindNameTrigger6` Tag=DespotRumours_Stopped, Event=DowntownMale02
- `TNMBindNameTrigger7` Tag=DespotRumours_Stopped, Event=DowntownMale01
- `TNMBindNameTrigger2` Tag=Arcadia_Stopped, Event=DowntownMale04
- `TNMBindNameTrigger3` Tag=Arcadia_Stopped, Event=DowntownFemale01

## GoalAddTrigger (4 placed, TNM)
- **INFO** HOST_ONLY `GoalAddTrigger.Trigger` line 14: `player = trestkon(getplayerpawn());`

Placed instances:
- `GoalAddTrigger2` Tag=GangDatacubeAddGoal, goalName=GangStash
- `GoalAddTrigger3` Tag=GangDatacubeCompleteGoal, goalName=GangStash
- `GoalAddTrigger4` Tag=LlamaHostageGoalUpdate, goalName=LlamaRescue
- `GoalAddTrigger0` Tag=GangStashGoalComplete, goalName=GangStash
