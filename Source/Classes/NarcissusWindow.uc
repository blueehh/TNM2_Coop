class NarcissusWindow extends ToolWindow;

var localized string title;
var localized string text1;
var localized string text2;
var localized string text3;

var ToolButtonWindow btnModeTrestkon;
var ToolButtonWindow btnModeCustom;
var ToolButtonWindow btnModeName;
var ToolButtonWindow btnSavePreset;
var ToolButtonWindow btnLoadPreset;
var ToolButtonWindow btnRandomize;
var ToolButtonWindow btnApply;
var ToolButtonWindow btnPreview;
var ToolButtonWindow btnOK;

var TextWindow lblLeftHeader;
var TextWindow lblRightHeader;
var ToolListWindow lstCategories;
var ToolListWindow lstOptions;
var ToolEditWindow editPlayerName;

var bool bIsCharSelector;
var bool bCustomMode;
var bool bNameMode;
var bool bIgnoreListChange;

var int curTrestkonIdx;
var int curCategoryIdx;
var int curBodyIdx;
var int curHeadIdx;
var int curTopIdx;
var int curBottomIdx;
var int curLegsIdx;
var int curGlassesIdx;

#EXEC OBJ LOAD FILE=TNMSounds

event InitWindow()
{
	local int curModel;
	local Trestkon T;

	Super.InitWindow();

	T = Trestkon(player);
	if (player != None && (player.GetLevelInfo() == None || player.GetLevelInfo().MissionNumber != 24))
	{
		bIsCharSelector = True;
		SetSize(380, 365);
		SetTitle("Character Model & Customizer");

		// Top Mode Switcher Buttons
		btnModeTrestkon = CreateToolButton(12,  28, "|&Trestkon");
		btnModeCustom   = CreateToolButton(90,  28, "C|&ustomize");
		btnModeName     = CreateToolButton(168, 28, "Set |&Name");
		btnSavePreset   = CreateSmallToolButton(247, 28, 20, "S");
		btnLoadPreset   = CreateSmallToolButton(269, 28, 20, "L");
		btnRandomize    = CreateToolButton(293, 28, "|&Randomize");

		lblLeftHeader  = CreateToolLabel(18,  56, "Category / Slot:");
		lblRightHeader = CreateToolLabel(172, 56, "Options:");

		lstCategories = CreateToolList(15,  72, 150, 235);
		lstCategories.EnableMultiSelect(False);
		lstCategories.EnableAutoExpandColumns(True);
		lstCategories.EnableAutoSort(False);
		lstCategories.SetColumns(2);
		lstCategories.HideColumn(1);

		lstOptions = CreateToolList(170, 72, 195, 235);
		lstOptions.EnableMultiSelect(False);
		lstOptions.EnableAutoExpandColumns(True);
		lstOptions.EnableAutoSort(False);
		lstOptions.SetColumns(2);
		lstOptions.HideColumn(1);

		editPlayerName = CreateToolEditWindow(170, 72, 195, 24, 22);
		if (T != None && editPlayerName != None)
		{
			editPlayerName.SetText(T.GetCoopPlayerName());
			SetTitle("Character & Name (" $ T.GetCoopPlayerName() $ ")");
		}
		if (editPlayerName != None && editPlayerName.GetParent() != None && editPlayerName.GetParent().GetParent() != None && editPlayerName.GetParent().GetParent().GetParent() != None)
			editPlayerName.GetParent().GetParent().GetParent().Hide();

		btnApply   = CreateToolButton(45,  318, "|&Apply");
		btnPreview = CreateToolButton(152, 318, "|&3rd Person");
		btnOK      = CreateToolButton(260, 318, "|&Close");

		if (T != None)
		{
			curModel = T.coopCharacterModel;
			if (curModel == 0 && T.default.coopCharacterModel != 0)
				curModel = T.default.coopCharacterModel;
		}

		if ((curModel & 134217728) != 0 && T != None)
		{
			bCustomMode = True;
			T.UnpackCustomCoopSkin(curModel, curBodyIdx, curHeadIdx, curTopIdx, curBottomIdx, curLegsIdx, curGlassesIdx);
		}
		else
		{
			bCustomMode = False;
			curTrestkonIdx = Clamp(curModel, 0, 6);
			if (T != None && (T.coopSavedCustomPreset & 134217728) != 0)
				T.UnpackCustomCoopSkin(T.coopSavedCustomPreset, curBodyIdx, curHeadIdx, curTopIdx, curBottomIdx, curLegsIdx, curGlassesIdx);
			else if (T != None && (T.default.coopSavedCustomPreset & 134217728) != 0)
				T.UnpackCustomCoopSkin(T.default.coopSavedCustomPreset, curBodyIdx, curHeadIdx, curTopIdx, curBottomIdx, curLegsIdx, curGlassesIdx);
		}

		curCategoryIdx = 0;
		RefreshModeUI();
		return;
	}

	SetSize(215, 125);
	SetTitle(title);

	CreateToolLabel(18,30,text1);
	CreateToolLabel(18,45,text2);
	CreateToolLabel(18,70,text3);
	btnOK = CreateToolButton(75,  90, "OK");

	PlaySound(sound'TNMSounds.OneShot.XPCriticalStop',2.0);
}

event DestroyWindow()
{
	if (!bIsCharSelector)
	{
		if (trestkon(player) != None && trestkon(player).b2009Maps)
			player.ClientTravel("TNMEndgame03_2009", TRAVEL_Relative, True);
		else
			player.ClientTravel("TNMEndgame03", TRAVEL_Relative, True);
	}
	Super.DestroyWindow();
}

function ToolButtonWindow CreateSmallToolButton(int posX, int posY, int btnW, String caption)
{
	local ToolButtonWindow btn;
	local BorderWindow bdr;

	btn = CreateToolButton(posX, posY, caption);
	if (btn != None)
	{
		btn.SetSize(btnW, 23);
		bdr = BorderWindow(btn.NewChild(Class'BorderWindow'));
		if (bdr != None)
		{
			bdr.SetWindowAlignments(HALIGN_Full, VALIGN_Full);
			bdr.SetBorders(Texture'ToolWindowBorder_TL', Texture'ToolWindowBorder_TR',
			               Texture'ToolWindowBorder_BL', Texture'ToolWindowBorder_BR',
			               Texture'ToolWindowBorder_L',  Texture'ToolWindowBorder_R',
			               Texture'ToolWindowBorder_T',  Texture'ToolWindowBorder_B');
			bdr.SetSensitivity(False);
		}
	}
	return btn;
}

function RefreshModeUI()
{
	local Window nameContainer, optScroll, optBorder;
	local String curName;

	if (!bIsCharSelector)
		return;

	if (btnRandomize != None)
		btnRandomize.SetSensitivity(bCustomMode && !bNameMode);

	if (editPlayerName != None && editPlayerName.GetParent() != None && editPlayerName.GetParent().GetParent() != None)
		nameContainer = editPlayerName.GetParent().GetParent().GetParent();
	if (lstOptions != None && lstOptions.GetParent() != None && lstOptions.GetParent().GetParent() != None && lstOptions.GetParent().GetParent().GetParent() != None)
	{
		optScroll = lstOptions.GetParent().GetParent();
		optBorder = optScroll.GetParent().GetParent();
	}

	if (bNameMode)
	{
		if (nameContainer != None)
			nameContainer.Show();
		if (optBorder != None && optScroll != None)
		{
			optBorder.SetPos(170, 98);
			optBorder.SetSize(195, 209);
			optScroll.SetSize(191, 205);
		}
		if (editPlayerName != None)
		{
			if (Trestkon(player) != None && editPlayerName.GetText() == "")
				editPlayerName.SetText(Trestkon(player).GetCoopPlayerName());
			curName = editPlayerName.GetText();
			editPlayerName.SetInsertionPoint(Len(curName));
			editPlayerName.SetSelectedArea(0, Len(curName));
			SetFocusWindow(editPlayerName);
		}
	}
	else
	{
		if (nameContainer != None)
			nameContainer.Hide();
		if (optBorder != None && optScroll != None)
		{
			optBorder.SetPos(170, 72);
			optBorder.SetSize(195, 235);
			optScroll.SetSize(191, 231);
		}
	}

	PopulateCategoriesList();
	PopulateOptionsList();
}

function PopulateCategoriesList()
{
	local int rowId;

	if (lstCategories == None)
		return;

	bIgnoreListChange = True;
	lstCategories.DeleteAllRows();

	if (bNameMode)
	{
		lblLeftHeader.SetText("Mode:");
		lblRightHeader.SetText("Type Name (or pick below):");
		lstCategories.AddRow("Player Name;0");
		rowId = lstCategories.IndexToRowId(0);
		if (rowId != 0)
			lstCategories.SelectRow(rowId);
		bIgnoreListChange = False;
		return;
	}

	if (!bCustomMode)
	{
		lblLeftHeader.SetText("Mode:");
		lblRightHeader.SetText("Trestkon Outfits:");
		lstCategories.AddRow("1. Trestkon Outfits;0");
		lstCategories.AddRow("2. Yuuka Plush;6");
		if (curCategoryIdx != 6)
			curCategoryIdx = 0;
		rowId = lstCategories.IndexToRowId(Clamp(curCategoryIdx, 0, 1));
		if (rowId != 0)
			lstCategories.SelectRow(rowId);
		bIgnoreListChange = False;
		return;
	}

	lblLeftHeader.SetText("Customize Slot:");

	lstCategories.AddRow("1. Base Outfit;0");

	if (curBodyIdx == 0)
	{
		// Female: Jacket & Skirt (GFM_Dress - Screenshot 1)
		lstCategories.AddRow("2. Head & Hair;1");
		lstCategories.AddRow("3. Inner Top / Shirt;2");
		lstCategories.AddRow("4. Jacket & Skirt;3");
		lstCategories.AddRow("5. Pantyhose / Tights;4");
		lstCategories.AddRow("6. Hair / Collar Trim;5");
	}
	else if (curBodyIdx == 1)
	{
		// Female: Top & Pants (GFM_TShirtPants - Screenshot 2)
		lstCategories.AddRow("2. Head & Hair;1");
		lstCategories.AddRow("3. Tank Top / Shirt;2");
		lstCategories.AddRow("4. Pants / Jeans;3");
		lstCategories.AddRow("5. Hair Attachment;4");
		lstCategories.AddRow("6. Glasses / Shades;5");
	}
	else if (curBodyIdx == 2)
	{
		// Female: Business Suit & Skirt (GFM_SuitSkirt)
		lstCategories.AddRow("2. Head & Hair;1");
		lstCategories.AddRow("3. Suit Jacket;2");
		lstCategories.AddRow("4. Skirt;3");
		lstCategories.AddRow("5. Pantyhose / Tights;4");
		lstCategories.AddRow("6. Glasses / Shades;5");
	}
	else if (curBodyIdx == 3)
	{
		// Female: Trenchcoat (GFM_Trench)
		lstCategories.AddRow("2. Head & Hair;1");
		lstCategories.AddRow("3. Inner Top;2");
		lstCategories.AddRow("4. Trenchcoat;3");
		lstCategories.AddRow("5. Pants & Boots;4");
		lstCategories.AddRow("6. Glasses / Shades;5");
	}
	else if (curBodyIdx == 4)
	{
		// Male: Shirt & Pants (GM_DressShirt)
		lstCategories.AddRow("2. Head & Face;1");
		lstCategories.AddRow("3. Shirt / Torso;2");
		lstCategories.AddRow("4. Pants / Jeans;3");
		lstCategories.AddRow("5. Sleeves & Cap;4");
		lstCategories.AddRow("6. Glasses / Shades;5");
	}
	else
	{
		// Male: Trenchcoat (GM_Trench)
		lstCategories.AddRow("2. Head & Face;1");
		lstCategories.AddRow("3. Inner Shirt / Vest;2");
		lstCategories.AddRow("4. Trenchcoat;3");
		lstCategories.AddRow("5. Pants;4");
		lstCategories.AddRow("6. Glasses / Shades;5");
	}

	lstCategories.AddRow("7. Yuuka Plush;6");

	curCategoryIdx = Clamp(curCategoryIdx, 0, 6);
	rowId = lstCategories.IndexToRowId(curCategoryIdx);
	if (rowId != 0)
		lstCategories.SelectRow(rowId);

	bIgnoreListChange = False;
}

function PopulateOptionsList()
{
	local int activeOptIdx, rowId;
	local Trestkon T;

	if (lstOptions == None)
		return;

	T = Trestkon(player);
	bIgnoreListChange = True;
	lstOptions.DeleteAllRows();

	if (bNameMode)
	{
		lstOptions.AddRow("Trestkon;Trestkon");
		lstOptions.AddRow("Phasmatis;Phasmatis");
		lstOptions.AddRow("ZeroPresence;ZeroPresence");
		lstOptions.AddRow("Skara;Skara");
		lstOptions.AddRow("Kylie;Kylie");
		lstOptions.AddRow("King Kashue;King Kashue");
		lstOptions.AddRow("Deus Diablo;Deus Diablo");
		lstOptions.AddRow("Endar;Endar");
		lstOptions.AddRow("Scary;Scary");
		lstOptions.AddRow("Host;Host");
		lstOptions.AddRow("Partner;Partner");
		bIgnoreListChange = False;
		return;
	}

	if (curCategoryIdx == 6)
	{
		lblRightHeader.SetText("Yuuka Head Companion:");
		lstOptions.AddRow("Head Companion: OFF;0");
		lstOptions.AddRow("Head Companion: ON (Yuuka Hat);1");
		if (T != None && T.bCoopYuukaHat)
			activeOptIdx = 1;
		else
			activeOptIdx = 0;
		rowId = lstOptions.IndexToRowId(activeOptIdx);
		if (rowId != 0)
			lstOptions.SelectRow(rowId);
		bIgnoreListChange = False;
		return;
	}

	if (!bCustomMode)
	{
		lblRightHeader.SetText("Trestkon Outfits:");
		lstOptions.AddRow("Trestkon (Story Default);0");
		lstOptions.AddRow("Trestkon (Trenchcoat);1");
		lstOptions.AddRow("Trestkon (PDX Coat);2");
		lstOptions.AddRow("Trestkon (WorldCorp Coat);3");
		lstOptions.AddRow("Trestkon (Goat Cult Coat);4");
		lstOptions.AddRow("Trestkon (Llama Cult Coat);5");
		lstOptions.AddRow("Trestkon (Gold Coat);6");

		rowId = lstOptions.IndexToRowId(Clamp(curTrestkonIdx, 0, 6));
		if (rowId != 0)
			lstOptions.SelectRow(rowId);
		bIgnoreListChange = False;
		return;
	}

	// Category 0: Base Outfit
	if (curCategoryIdx == 0)
	{
		lblRightHeader.SetText("Select Base Outfit:");
		lstOptions.AddRow("F: Jacket & Skirt;0");
		lstOptions.AddRow("F: Top & Pants;1");
		lstOptions.AddRow("F: Suit & Skirt;2");
		lstOptions.AddRow("F: Trenchcoat;3");
		lstOptions.AddRow("M: Shirt & Pants;4");
		lstOptions.AddRow("M: Trenchcoat;5");
		activeOptIdx = Clamp(curBodyIdx, 0, 5);
	}
	// Category 1: Head & Hair / Face
	else if (curCategoryIdx == 1)
	{
		lblRightHeader.SetText("Select Head / Hair:");
		if (curBodyIdx == 0)
		{
			lstOptions.AddRow("Dark Ponytail (Secretary);0");
			lstOptions.AddRow("Brunette Bob (Hooker);1");
			lstOptions.AddRow("Blonde (Sandra);2");
			lstOptions.AddRow("Redhead (Nurse);3");
			lstOptions.AddRow("Brown Ponytail (Female 1);4");
			lstOptions.AddRow("Auburn (Female 2);5");
			lstOptions.AddRow("Dark Short (Business);6");
			lstOptions.AddRow("Light Brown (Rachel);7");
			lstOptions.AddRow("Blonde Updo (Sarah);8");
			lstOptions.AddRow("Goth Brunette (Nicolette);9");
			lstOptions.AddRow("Kylie;10");
			lstOptions.AddRow("Jackie;11");
			lstOptions.AddRow("Goat Cultist;12");
			lstOptions.AddRow("Llama Cultist;13");
			activeOptIdx = Clamp(curHeadIdx, 0, 13);
		}
		else if (curBodyIdx == 1)
		{
			lstOptions.AddRow("Redhead (Nurse);0");
			lstOptions.AddRow("Blonde (Sandra);1");
			lstOptions.AddRow("Brown Ponytail (Female 1);2");
			lstOptions.AddRow("Dark Hair (LowerClass);3");
			lstOptions.AddRow("Green Punk (Tiffany);4");
			lstOptions.AddRow("Dark Bob (Jordan);5");
			lstOptions.AddRow("Pale Dark (Junkie);6");
			lstOptions.AddRow("Bandana (Street);7");
			lstOptions.AddRow("Brunette Bob (Hooker);8");
			lstOptions.AddRow("Dark Short (Business);9");
			lstOptions.AddRow("Dark Ponytail (Secretary);10");
			lstOptions.AddRow("Forum Citizen (Random);11");
			activeOptIdx = Clamp(curHeadIdx, 0, 11);
		}
		else if (curBodyIdx == 2)
		{
			lstOptions.AddRow("Auburn (Female 2);0");
			lstOptions.AddRow("Dark Ponytail (Secretary);1");
			lstOptions.AddRow("Dark Short (Business 1);2");
			lstOptions.AddRow("Blonde Bob (Business 2);3");
			lstOptions.AddRow("Light Brown (Rachel);4");
			lstOptions.AddRow("Redhead (Nurse);5");
			lstOptions.AddRow("Brunette (Maid);6");
			lstOptions.AddRow("Dark Hair (Female 3);7");
			lstOptions.AddRow("Mercedes;8");
			lstOptions.AddRow("Goat Cultist 1;9");
			lstOptions.AddRow("Goat Cultist 2;10");
			lstOptions.AddRow("Goat Cultist 3;11");
			lstOptions.AddRow("Llama Cultist 1;12");
			lstOptions.AddRow("Llama Cultist 2;13");
			activeOptIdx = Clamp(curHeadIdx, 0, 13);
		}
		else if (curBodyIdx == 3)
		{
			lstOptions.AddRow("Kylie;0");
			lstOptions.AddRow("Dark Hair (Female 4);1");
			lstOptions.AddRow("Blonde (Scientist);2");
			lstOptions.AddRow("Jackie;3");
			lstOptions.AddRow("Redhead (Nurse);4");
			lstOptions.AddRow("Blonde (Sandra);5");
			lstOptions.AddRow("Dark Ponytail (Secretary);6");
			lstOptions.AddRow("Brunette Bob (Hooker);7");
			lstOptions.AddRow("Goat Cultist;8");
			lstOptions.AddRow("Llama Cultist;9");
			activeOptIdx = Clamp(curHeadIdx, 0, 9);
		}
		else if (curBodyIdx == 4)
		{
			lstOptions.AddRow("Board Guest 1;0");
			lstOptions.AddRow("Board Guest 2;1");
			lstOptions.AddRow("Citizen 1 (Light);2");
			lstOptions.AddRow("Citizen 2 (Brown Hair);3");
			lstOptions.AddRow("Citizen 3 (Dark Hair);4");
			lstOptions.AddRow("Citizen 4 (Male 1);5");
			lstOptions.AddRow("Bartender (Beard);6");
			lstOptions.AddRow("Hamner;7");
			lstOptions.AddRow("Carter;8");
			lstOptions.AddRow("JoJo;9");
			lstOptions.AddRow("Strong;10");
			lstOptions.AddRow("Street Punk;11");
			lstOptions.AddRow("Goat Cultist 1;12");
			lstOptions.AddRow("Goat Cultist 2;13");
			lstOptions.AddRow("Llama Cultist;14");
			lstOptions.AddRow("Forum Citizen (Random);15");
			activeOptIdx = Clamp(curHeadIdx, 0, 15);
		}
		else
		{
			lstOptions.AddRow("Bogie;0");
			lstOptions.AddRow("Goat Cultist 1;1");
			lstOptions.AddRow("Goat Cultist 2;2");
			lstOptions.AddRow("Goat Cultist 3;3");
			lstOptions.AddRow("Llama Cultist 1;4");
			lstOptions.AddRow("Llama Cultist 2;5");
			lstOptions.AddRow("Llama Cultist 3;6");
			lstOptions.AddRow("Bartender (Beard);7");
			lstOptions.AddRow("Carter;8");
			lstOptions.AddRow("Dowd;9");
			lstOptions.AddRow("Renton;10");
			lstOptions.AddRow("Filben;11");
			lstOptions.AddRow("Drifter;12");
			lstOptions.AddRow("Citizen (Brown Hair);13");
			activeOptIdx = Clamp(curHeadIdx, 0, 13);
		}
	}
	// Category 2: Top / Shirt / Suit Jacket
	else if (curCategoryIdx == 2)
	{
		lblRightHeader.SetText("Select Top / Shirt:");
		if (curBodyIdx == 0)
		{
			lstOptions.AddRow("Grey Tank Top;0");
			lstOptions.AddRow("White Top (GP 1);1");
			lstOptions.AddRow("Black Tank Top (GP 2);2");
			lstOptions.AddRow("Red Top (GP 3);3");
			lstOptions.AddRow("Teal Top (GP 4);4");
			lstOptions.AddRow("Green Top (GP 5);5");
			lstOptions.AddRow("N00Bz Shirt;6");
			lstOptions.AddRow("Olive Tank Top;7");
			lstOptions.AddRow("Red Corset Top;8");
			lstOptions.AddRow("Black Corset Top;9");
			lstOptions.AddRow("Formal Blouse;10");
			lstOptions.AddRow("Dark Goth Top;11");
			activeOptIdx = Clamp(curTopIdx, 0, 11);
		}
		else if (curBodyIdx == 1)
		{
			lstOptions.AddRow("Black Tank Top (GP 2);0");
			lstOptions.AddRow("White Top (GP 1);1");
			lstOptions.AddRow("Red Top (GP 3);2");
			lstOptions.AddRow("Teal Top (GP 4);3");
			lstOptions.AddRow("Green Top (GP 5);4");
			lstOptions.AddRow("N00Bz Shirt;5");
			lstOptions.AddRow("Black Crop Top;6");
			lstOptions.AddRow("Grey Tank Top;7");
			lstOptions.AddRow("Olive Tank Top;8");
			lstOptions.AddRow("Punk Top (Tiffany);9");
			lstOptions.AddRow("Leather Top (Jordan);10");
			lstOptions.AddRow("ABI Guard Vest;11");
			activeOptIdx = Clamp(curTopIdx, 0, 11);
		}
		else if (curBodyIdx == 2)
		{
			lstOptions.AddRow("Green Suit Jacket;0");
			lstOptions.AddRow("Red Suit Jacket;1");
			lstOptions.AddRow("Grey Suit Jacket;2");
			lstOptions.AddRow("Blue Business Jacket;3");
			lstOptions.AddRow("Navy Suit Jacket;4");
			lstOptions.AddRow("Tan Suit Jacket;5");
			lstOptions.AddRow("White Nurse Top;6");
			lstOptions.AddRow("Maid Uniform Top;7");
			lstOptions.AddRow("Mercedes Jacket;8");
			lstOptions.AddRow("Goat Cult Jacket;9");
			lstOptions.AddRow("Llama Cult Jacket;10");
			lstOptions.AddRow("Brown Suit (GP 1);11");
			lstOptions.AddRow("Charcoal Suit (GP 2);12");
			activeOptIdx = Clamp(curTopIdx, 0, 12);
		}
		else if (curBodyIdx == 3)
		{
			lstOptions.AddRow("Kylie Tactical Top;0");
			lstOptions.AddRow("Dark Sweater;1");
			lstOptions.AddRow("White Blouse;2");
			lstOptions.AddRow("Dark Vest;3");
			lstOptions.AddRow("Plaid Shirt;4");
			lstOptions.AddRow("Jackie Top;5");
			lstOptions.AddRow("Smuggler Vest;6");
			lstOptions.AddRow("Grey Tank Top;7");
			activeOptIdx = Clamp(curTopIdx, 0, 7);
		}
		else if (curBodyIdx == 4)
		{
			lstOptions.AddRow("Forum Shirt 1;0");
			lstOptions.AddRow("Forum Shirt 2;1");
			lstOptions.AddRow("Forum Shirt 3;2");
			lstOptions.AddRow("Forum Shirt 4;3");
			lstOptions.AddRow("Forum Shirt 5;4");
			lstOptions.AddRow("Forum Shirt 6;5");
			lstOptions.AddRow("Forum Shirt 7;6");
			lstOptions.AddRow("Forum Shirt 8;7");
			lstOptions.AddRow("N00Bz Shirt;8");
			lstOptions.AddRow("Board Guest Shirt;9");
			lstOptions.AddRow("Larry Hawaiian Shirt;10");
			lstOptions.AddRow("MIB Suit Shirt;11");
			lstOptions.AddRow("Casual Shirt 1;12");
			lstOptions.AddRow("Casual Shirt 2;13");
			lstOptions.AddRow("Casual Shirt 3;14");
			lstOptions.AddRow("Leather Vest;15");
			activeOptIdx = Clamp(curTopIdx, 0, 15);
		}
		else
		{
			lstOptions.AddRow("Bogie Vest;0");
			lstOptions.AddRow("Dark Shirt;1");
			lstOptions.AddRow("Plaid Shirt;2");
			lstOptions.AddRow("White Dress Shirt;3");
			lstOptions.AddRow("Goat Cult Vest;4");
			lstOptions.AddRow("Llama Cult Vest;5");
			lstOptions.AddRow("Buttoned Vest;6");
			lstOptions.AddRow("Tactical Vest;7");
			activeOptIdx = Clamp(curTopIdx, 0, 7);
		}
	}
	// Category 3: Skirt / Pants / Trenchcoat
	else if (curCategoryIdx == 3)
	{
		if (curBodyIdx == 0)
		{
			lblRightHeader.SetText("Select Jacket & Skirt:");
			lstOptions.AddRow("Green Jacket & Skirt (GP 2);0");
			lstOptions.AddRow("Teal Jacket & Skirt (GP 1);1");
			lstOptions.AddRow("Denim Jacket & Skirt (GP 3);2");
			lstOptions.AddRow("Black Jacket & Skirt (GP 4);3");
			lstOptions.AddRow("Red Jacket & Black Skirt;4");
			lstOptions.AddRow("Leopard Jacket & Skirt;5");
			lstOptions.AddRow("Blue Dress & Jacket;6");
			lstOptions.AddRow("Dark Goth Dress & Jacket;7");
			activeOptIdx = Clamp(curBottomIdx, 0, 7);
		}
		else if (curBodyIdx == 1)
		{
			lblRightHeader.SetText("Select Pants / Jeans:");
			lstOptions.AddRow("Blue Jeans (Pants 6);0");
			lstOptions.AddRow("Dark Blue Jeans (Pants 5);1");
			lstOptions.AddRow("Black Slacks (Pants 2);2");
			lstOptions.AddRow("Brown Pants (Pants 4);3");
			lstOptions.AddRow("Camo Pants (Pants 9);4");
			lstOptions.AddRow("Faded Jeans (GP 5);5");
			lstOptions.AddRow("Grey Jeans (GP 1);6");
			lstOptions.AddRow("Dark Punk Pants;7");
			lstOptions.AddRow("Worn Jeans;8");
			lstOptions.AddRow("ABI Tactical Pants;9");
			activeOptIdx = Clamp(curBottomIdx, 0, 9);
		}
		else if (curBodyIdx == 2)
		{
			lblRightHeader.SetText("Select Skirt:");
			lstOptions.AddRow("Match Suit Jacket;0");
			lstOptions.AddRow("Green Skirt;1");
			lstOptions.AddRow("Red Skirt;2");
			lstOptions.AddRow("Grey Skirt;3");
			lstOptions.AddRow("Blue Business Skirt;4");
			lstOptions.AddRow("Navy Skirt;5");
			lstOptions.AddRow("Tan Skirt;6");
			lstOptions.AddRow("White Nurse Skirt;7");
			lstOptions.AddRow("Maid Skirt;8");
			lstOptions.AddRow("Mercedes Skirt;9");
			lstOptions.AddRow("Goat Cult Skirt;10");
			lstOptions.AddRow("Llama Cult Skirt;11");
			lstOptions.AddRow("Brown Skirt (GP 1);12");
			lstOptions.AddRow("Charcoal Skirt (GP 2);13");
			activeOptIdx = Clamp(curBottomIdx, 0, 13);
		}
		else if (curBodyIdx == 3)
		{
			lblRightHeader.SetText("Select Trenchcoat:");
			lstOptions.AddRow("Kylie Black Coat;0");
			lstOptions.AddRow("Brown Trenchcoat;1");
			lstOptions.AddRow("Scientist Labcoat;2");
			lstOptions.AddRow("Clean White Labcoat;3");
			lstOptions.AddRow("Dark Leather Coat;4");
			lstOptions.AddRow("Classic Black Trench;5");
			activeOptIdx = Clamp(curBottomIdx, 0, 5);
		}
		else if (curBodyIdx == 4)
		{
			lblRightHeader.SetText("Select Pants / Jeans:");
			lstOptions.AddRow("Forum Pants 1;0");
			lstOptions.AddRow("Forum Pants 2;1");
			lstOptions.AddRow("Forum Pants 3;2");
			lstOptions.AddRow("Forum Pants 4;3");
			lstOptions.AddRow("Forum Pants 5;4");
			lstOptions.AddRow("Forum Pants 6;5");
			lstOptions.AddRow("Forum Pants 7;6");
			lstOptions.AddRow("Khaki Pants;7");
			lstOptions.AddRow("Black Slacks;8");
			lstOptions.AddRow("Dark Blue Jeans;9");
			lstOptions.AddRow("Light Blue Jeans;10");
			lstOptions.AddRow("Dark Cargo Pants;11");
			lstOptions.AddRow("Goat Cult Pants;12");
			lstOptions.AddRow("Llama Cult Pants;13");
			activeOptIdx = Clamp(curBottomIdx, 0, 13);
		}
		else
		{
			lblRightHeader.SetText("Select Trenchcoat:");
			lstOptions.AddRow("Bogie Trenchcoat;0");
			lstOptions.AddRow("Classic Black Trench;1");
			lstOptions.AddRow("Goat Cult Trenchcoat;2");
			lstOptions.AddRow("Llama Cult Trenchcoat;3");
			lstOptions.AddRow("White Labcoat;4");
			lstOptions.AddRow("Brown Coat;5");
			lstOptions.AddRow("Tan Trenchcoat;6");
			lstOptions.AddRow("Dark Leather Coat;7");
			activeOptIdx = Clamp(curBottomIdx, 0, 7);
		}
	}
	// Category 4: Pantyhose / Tights / Legs / Hair / Sleeves
	else if (curCategoryIdx == 4)
	{
		if (curBodyIdx == 0)
		{
			lblRightHeader.SetText("Select Pantyhose / Tights:");
			lstOptions.AddRow("Dark Tights & Boots;0");
			lstOptions.AddRow("Sheer Stockings & Heels;1");
			lstOptions.AddRow("Black Pantyhose & Heels;2");
			lstOptions.AddRow("Forum Stockings (GP 1);3");
			lstOptions.AddRow("Tan Stockings & Heels;4");
			lstOptions.AddRow("Navy Stockings;5");
			lstOptions.AddRow("Light Stockings;6");
			lstOptions.AddRow("Black Thigh Boots;7");
			lstOptions.AddRow("Lace Stockings & Boots;8");
			lstOptions.AddRow("Formal Dark Heels;9");
			activeOptIdx = Clamp(curLegsIdx, 0, 9);
		}
		else if (curBodyIdx == 1)
		{
			lblRightHeader.SetText("Select Hair Attachment:");
			lstOptions.AddRow("Short / Clean (No Tail);0");
			lstOptions.AddRow("Ponytail;1");
			lstOptions.AddRow("Back Bun;2");
			lstOptions.AddRow("Full Hair (Bun + Tail);3");
			activeOptIdx = Clamp(curLegsIdx, 0, 3);
		}
		else if (curBodyIdx == 2)
		{
			lblRightHeader.SetText("Select Pantyhose / Tights:");
			lstOptions.AddRow("Sheer Stockings & Heels;0");
			lstOptions.AddRow("Black Pantyhose & Heels;1");
			lstOptions.AddRow("Dark Tights & Boots;2");
			lstOptions.AddRow("Tan Stockings & Heels;3");
			lstOptions.AddRow("Forum Stockings (GP 1);4");
			lstOptions.AddRow("Navy Stockings;5");
			lstOptions.AddRow("Light Stockings;6");
			lstOptions.AddRow("Goat Cult Stockings;7");
			lstOptions.AddRow("Llama Cult Stockings;8");
			activeOptIdx = Clamp(curLegsIdx, 0, 8);
		}
		else if (curBodyIdx == 3)
		{
			lblRightHeader.SetText("Select Pants & Boots:");
			lstOptions.AddRow("Kylie Boots & Pants;0");
			lstOptions.AddRow("Black Slacks & Boots;1");
			lstOptions.AddRow("White Slacks;2");
			lstOptions.AddRow("Athena Tactical Pants;3");
			lstOptions.AddRow("Dark Punk Pants;4");
			lstOptions.AddRow("Charcoal Pants;5");
			lstOptions.AddRow("Blue Jeans;6");
			activeOptIdx = Clamp(curLegsIdx, 0, 6);
		}
		else if (curBodyIdx == 4)
		{
			lblRightHeader.SetText("Select Sleeves & Cap:");
			lstOptions.AddRow("Rolled Sleeves;0");
			lstOptions.AddRow("Short Sleeves;1");
			lstOptions.AddRow("Long Sleeves;2");
			lstOptions.AddRow("Rolled Sleeves + Cap;3");
			activeOptIdx = Clamp(curLegsIdx, 0, 3);
		}
		else
		{
			lblRightHeader.SetText("Select Pants:");
			lstOptions.AddRow("Bogie Pants;0");
			lstOptions.AddRow("Khaki Pants;1");
			lstOptions.AddRow("Brown Pants;2");
			lstOptions.AddRow("Dark Blue Jeans;3");
			lstOptions.AddRow("Grey Slacks;4");
			lstOptions.AddRow("Dark Cargo Pants;5");
			lstOptions.AddRow("Goat Cult Pants;6");
			lstOptions.AddRow("Llama Cult Pants;7");
			activeOptIdx = Clamp(curLegsIdx, 0, 7);
		}
	}
	// Category 5: Glasses / Shades / Trim
	else
	{
		if (curBodyIdx == 0)
		{
			lblRightHeader.SetText("Select Hair / Collar Trim:");
			lstOptions.AddRow("Full Hair / Collar;0");
			lstOptions.AddRow("Trimmed / Hidden;1");
			activeOptIdx = Clamp(curGlassesIdx, 0, 1);
		}
		else
		{
			lblRightHeader.SetText("Select Glasses / Shades:");
			lstOptions.AddRow("No Glasses;0");
			lstOptions.AddRow("Silver Frames + Dark Lenses;1");
			lstOptions.AddRow("Black Frames + Dark Lenses;2");
			lstOptions.AddRow("Wire Frames + Amber Lenses;3");
			lstOptions.AddRow("Visor + Red Lenses;4");
			lstOptions.AddRow("Trestkon Shades;5");
			lstOptions.AddRow("WorldCorp Shades;6");
			activeOptIdx = Clamp(curGlassesIdx, 0, 6);
		}
	}

	rowId = lstOptions.IndexToRowId(activeOptIdx);
	if (rowId != 0)
		lstOptions.SelectRow(rowId);

	bIgnoreListChange = False;
}

function ApplyPlayerNameFromEdit(optional bool bShowMessage)
{
	local Trestkon T;
	local String newName;

	T = Trestkon(player);
	if (T == None || editPlayerName == None)
		return;

	newName = editPlayerName.GetText();
	if (newName != "" && newName != T.GetCoopPlayerName())
	{
		T.SetCoopPlayerName(newName);
		SetTitle("Character & Name (" $ T.GetCoopPlayerName() $ ")");
		if (bShowMessage)
			T.ClientMessage("Co-op Player Name set to: " $ newName);
	}
	else if (newName != "" && bShowMessage)
	{
		T.SetCoopPlayerName(newName);
		SetTitle("Character & Name (" $ T.GetCoopPlayerName() $ ")");
		T.ClientMessage("Co-op Player Name set to: " $ newName);
	}
}

function ApplyCurrentStateToPlayer()
{
	local Trestkon T;
	local int packedModel;

	T = Trestkon(player);
	if (T == None)
		return;

	ApplyPlayerNameFromEdit(bNameMode);
	if (bNameMode)
		return;

	if (!bCustomMode)
	{
		T.SetCoopModelSelection(Clamp(curTrestkonIdx, 0, 6));
	}
	else
	{
		packedModel = T.PackCustomCoopSkin(curBodyIdx, curHeadIdx, curTopIdx, curBottomIdx, curLegsIdx, curGlassesIdx);
		T.SetCoopModelSelection(packedModel);
	}
}

function RandomizeCustomCharacter()
{
	if (!bCustomMode)
		bCustomMode = True;

	if (curBodyIdx == 0)
	{
		curHeadIdx    = Rand(14);
		curTopIdx     = Rand(12);
		curBottomIdx  = Rand(8);
		curLegsIdx    = Rand(10);
		curGlassesIdx = Rand(2);
	}
	else if (curBodyIdx == 1)
	{
		curHeadIdx    = Rand(12);
		curTopIdx     = Rand(12);
		curBottomIdx  = Rand(10);
		curLegsIdx    = Rand(4);
		curGlassesIdx = Rand(7);
	}
	else if (curBodyIdx == 2)
	{
		curHeadIdx    = Rand(14);
		curTopIdx     = Rand(13);
		curBottomIdx  = Rand(14);
		curLegsIdx    = Rand(9);
		curGlassesIdx = Rand(7);
	}
	else if (curBodyIdx == 3)
	{
		curHeadIdx    = Rand(10);
		curTopIdx     = Rand(8);
		curBottomIdx  = Rand(6);
		curLegsIdx    = Rand(7);
		curGlassesIdx = Rand(7);
	}
	else if (curBodyIdx == 4)
	{
		curHeadIdx    = Rand(16);
		curTopIdx     = Rand(16);
		curBottomIdx  = Rand(14);
		curLegsIdx    = Rand(4);
		curGlassesIdx = Rand(7);
	}
	else
	{
		curHeadIdx    = Rand(14);
		curTopIdx     = Rand(8);
		curBottomIdx  = Rand(8);
		curLegsIdx    = Rand(8);
		curGlassesIdx = Rand(7);
	}

	PopulateOptionsList();
	ApplyCurrentStateToPlayer();
}

event bool ListSelectionChanged(Window list, int numSelections, int focusRowId)
{
	local int val;
	local String presetName;

	if (!bIsCharSelector || bIgnoreListChange || focusRowId == 0)
		return Super.ListSelectionChanged(list, numSelections, focusRowId);

	if (list == lstCategories)
	{
		val = int(lstCategories.GetField(focusRowId, 1));
		curCategoryIdx = val;
		PopulateOptionsList();
		return True;
	}

	if (list == lstOptions)
	{
		if (bNameMode)
		{
			presetName = lstOptions.GetField(focusRowId, 1);
			if (presetName != "" && editPlayerName != None)
			{
				editPlayerName.SetText(presetName);
				editPlayerName.SetInsertionPoint(Len(presetName));
				ApplyPlayerNameFromEdit(True);
			}
			return True;
		}

		val = int(lstOptions.GetField(focusRowId, 1));
		if (curCategoryIdx == 6)
		{
			if (Trestkon(player) != None)
			{
				if (val == 0)
					Trestkon(player).SetCoopYuukaHat(False);
				else if (val == 1)
					Trestkon(player).SetCoopYuukaHat(True);
			}
			return True;
		}

		if (!bCustomMode)
		{
			curTrestkonIdx = val;
			ApplyCurrentStateToPlayer();
			return True;
		}

		if (curCategoryIdx == 0)
		{
			if (curBodyIdx != val)
			{
				curBodyIdx    = val;
				curHeadIdx    = 0;
				curTopIdx     = 0;
				curBottomIdx  = 0;
				curLegsIdx    = 0;
				curGlassesIdx = 0;
				PopulateCategoriesList();
				PopulateOptionsList();
			}
		}
		else if (curCategoryIdx == 1)
			curHeadIdx = val;
		else if (curCategoryIdx == 2)
			curTopIdx = val;
		else if (curCategoryIdx == 3)
			curBottomIdx = val;
		else if (curCategoryIdx == 4)
			curLegsIdx = val;
		else if (curCategoryIdx == 5)
			curGlassesIdx = val;

		ApplyCurrentStateToPlayer();
		return True;
	}

	return Super.ListSelectionChanged(list, numSelections, focusRowId);
}

event bool EditActivated(Window edit, bool bModified)
{
	if (bIsCharSelector && edit == editPlayerName)
	{
		ApplyPlayerNameFromEdit(True);
		return True;
	}
	return Super.EditActivated(edit, bModified);
}

event bool ListRowActivated(Window list, int rowId)
{
	if (bIsCharSelector && list == lstOptions)
	{
		ApplyCurrentStateToPlayer();
		return True;
	}
	return Super.ListRowActivated(list, rowId);
}

function SaveCustomOutfitPreset()
{
	local Trestkon T;
	local int packedPreset;

	T = Trestkon(player);
	if (T == None)
		return;

	packedPreset = T.PackCustomCoopSkin(curBodyIdx, curHeadIdx, curTopIdx, curBottomIdx, curLegsIdx, curGlassesIdx);
	T.SaveCoopCustomPreset(packedPreset);
	T.ClientMessage("Saved custom outfit preset!");
}

function LoadCustomOutfitPreset()
{
	local Trestkon T;
	local int savedPreset;

	T = Trestkon(player);
	if (T == None)
		return;

	savedPreset = T.coopSavedCustomPreset;
	if ((savedPreset & 134217728) == 0)
		savedPreset = T.default.coopSavedCustomPreset;

	if ((savedPreset & 134217728) == 0)
	{
		T.ClientMessage("No saved outfit preset found yet (click S to save one).");
		return;
	}

	T.UnpackCustomCoopSkin(savedPreset, curBodyIdx, curHeadIdx, curTopIdx, curBottomIdx, curLegsIdx, curGlassesIdx);
	bNameMode = False;
	bCustomMode = True;
	RefreshModeUI();
	ApplyCurrentStateToPlayer();
	T.ClientMessage("Loaded saved custom outfit preset!");
}

function bool ButtonActivated( Window pressed )
{
	if (bIsCharSelector)
	{
		if (pressed == btnModeTrestkon)
		{
			ApplyPlayerNameFromEdit(False);
			bNameMode = False;
			bCustomMode = False;
			curCategoryIdx = 0;
			RefreshModeUI();
			ApplyCurrentStateToPlayer();
			return True;
		}
		if (pressed == btnModeCustom)
		{
			ApplyPlayerNameFromEdit(False);
			bNameMode = False;
			bCustomMode = True;
			RefreshModeUI();
			ApplyCurrentStateToPlayer();
			return True;
		}
		if (pressed == btnModeName)
		{
			if (bNameMode)
			{
				ApplyPlayerNameFromEdit(True);
			}
			else
			{
				bNameMode = True;
				RefreshModeUI();
			}
			return True;
		}
		if (pressed == btnSavePreset)
		{
			SaveCustomOutfitPreset();
			return True;
		}
		if (pressed == btnLoadPreset)
		{
			LoadCustomOutfitPreset();
			return True;
		}
		if (pressed == btnRandomize)
		{
			bNameMode = False;
			bCustomMode = True;
			RefreshModeUI();
			RandomizeCustomCharacter();
			return True;
		}
		if (pressed == btnApply)
		{
			ApplyCurrentStateToPlayer();
			return True;
		}
		if (pressed == btnPreview)
		{
			if (player != None)
				player.bBehindView = !player.bBehindView;
			return True;
		}
		if (pressed == btnOK)
		{
			ApplyPlayerNameFromEdit(False);
			if (root != None)
				root.ClearWindowStack();
			return True;
		}
	}
	if(pressed==btnOK)
	{
		root.PopWindow();
		return true;
	}
	return super.buttonactivated(pressed);
}

defaultproperties
{
     Title="General Protection Fault"
     text1="Runaway loop detected (over 1000000"
     text2="iterations)."
     text3="(That's a lot)"
}
