local addonName, Expressive_Internal = ...;

Expressive_Internal.Constants = {};

Expressive_Internal.Locale = LibStub("AceLocale-3.0"):GetLocale(addonName, true);

Expressive_Internal.Constants.PH_ICON = 2061724;
Expressive_Internal.Constants.MAX_EMOTE_INDEX = 627;
Expressive_Internal.Constants.PAGE_TYPE = {
    FAVORITES = 1,
    EMOTES = 2,
    ANIM = 3,
    VOICE = 4,
    CONFIG = 5,
};
Expressive_Internal.Constants.PAGE_TYPE_REV = tInvert(Expressive_Internal.Constants.PAGE_TYPE);

SLASH_GEXPR1, SLASH_GEXPR2 = "/expr", "/expressive";

SlashCmdList.GEXPR = function() ExpressiveFrame:Toggle(); end;

function Expressive_OnAddonCompartmentClick()
    ExpressiveFrame:Toggle();
end