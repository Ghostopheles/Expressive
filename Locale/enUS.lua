local addonName, Expressive_Internal = ...;

local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "enUS", true);

-- BEGIN LOCALIZATION

L["PAGE_TITLE_FAVORITES"] = "Favorites";
L["PAGE_TITLE_EMOTES"] = "All Emotes";
L["PAGE_TITLE_ANIM"] = "Animation Emotes";
L["PAGE_TITLE_VOICE"] = "Voice Emotes";

--- CUSTOM EMOTE NAMES

L["EMOTE_BRB"] = "BRB";
L["EMOTE_ATTACKMYTARGET"] = "Attack my Target";
L["EMOTE_HEALME"] = "Heal me";
L["EMOTE_HELPME"] = "Help me";
L["EMOTE_OPENFIRE"] = "Open fire";
L["EMOTE_GOLFCLAP"] = "Golf Clap";
L["EMOTE_MOUNTSPECIAL"] = "MountSpecial";
L["EMOTE_FORTHEALLIANCE"] = "For the Alliance";
L["EMOTE_FORTHEHORDE"] = "For the Horde";
L["EMOTE_CROSSARMS"] = "Cross arms";
L["EMOTE_COVEREARS"] = "Cover ears";

-- END LOCALIZATION


Expressive_Internal.Locale = L;