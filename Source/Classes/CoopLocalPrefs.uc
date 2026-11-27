//=============================================================================
// CoopLocalPrefs
// The Nameless Mod 2.0 - Co-op Mod by bluehh (TM)
//
// Dedicated per-machine Co-op client/host preferences stored in TNMCoopPrefs.ini.
// Keeping LocalPlayerName and LastServerIP out of Trestkon's pawn config ensures
// that spawning a remote client's Trestkon on the Host server NEVER initializes
// that client's coopPlayerName to the Host's own saved name.
//=============================================================================
class CoopLocalPrefs extends Object config(TNMCoopPrefs);

var config string LocalPlayerName;
var config string LastServerIP;

static function string TrimText(string s)
{
	while (Len(s) > 0 && Left(s, 1) == " ")
		s = Mid(s, 1);
	while (Len(s) > 0 && Right(s, 1) == " ")
		s = Left(s, Len(s) - 1);
	return s;
}

static function string SanitizePlayerName(string rawName)
{
	local int i, code;
	local string outStr, ch;

	rawName = TrimText(rawName);
	for (i = 0; i < Len(rawName); i++)
	{
		ch = Mid(rawName, i, 1);
		code = Asc(ch);
		// Exclude URL/INI delimiters (?, #, =, &, ", |, control chars)
		if (code >= 32 && code <= 126 && ch != "?" && ch != "#" && ch != "=" && ch != "&" && ch != "\"" && ch != "|")
			outStr = outStr $ ch;
	}
	outStr = TrimText(outStr);
	if (Len(outStr) > 24)
		outStr = Left(outStr, 24);
	return outStr;
}

static function string EncodeURLName(string rawName)
{
	local int i;
	local string clean, outStr, ch;

	clean = SanitizePlayerName(rawName);
	if (clean == "")
		return "Player";

	for (i = 0; i < Len(clean); i++)
	{
		ch = Mid(clean, i, 1);
		if (ch == " ")
			outStr = outStr $ "_";
		else
			outStr = outStr $ ch;
	}
	return outStr;
}

static function string DecodeURLName(string urlName)
{
	return SanitizePlayerName(urlName);
}

static function string GetLocalPlayerName(optional string urlFallback)
{
	local string clean, fb;

	clean = SanitizePlayerName(default.LocalPlayerName);
	if (clean != "")
		return clean;

	fb = SanitizePlayerName(urlFallback);
	if (fb != "" && Caps(fb) != "PLAYER" && Caps(fb) != "HOST" && Caps(fb) != "PARTNER" && Caps(fb) != "TRESTKON")
	{
		default.LocalPlayerName = fb;
		StaticSaveConfig();
		return fb;
	}

	return "";
}

static function SetLocalPlayerName(string newName)
{
	local string clean;

	clean = SanitizePlayerName(newName);
	if (clean == "")
		return;

	default.LocalPlayerName = clean;
	StaticSaveConfig();
}

static function string GetLastServerIP(optional string fallbackIP)
{
	local string clean;

	clean = TrimText(default.LastServerIP);
	if (clean != "")
		return clean;
	clean = TrimText(fallbackIP);
	if (clean != "")
		return clean;
	return "127.0.0.1";
}

static function SetLastServerIP(string newIP)
{
	newIP = TrimText(newIP);
	if (newIP == "")
		return;
	default.LastServerIP = newIP;
	StaticSaveConfig();
}

defaultproperties
{
}
