local addonName, Expressive_Internal = ...;

local L = Expressive_Internal.Locale;
local EmoteList = EmoteList;
local TextEmoteSpeechList = TextEmoteSpeechList;

Expressive_Internal.Utils = {};

function Expressive_Internal.Utils.GetPageTitleFromPageType(pageType)
    local pageTypeName = Expressive_Internal.Constants.PAGE_TYPE_REV[pageType];
    return L["PAGE_TITLE_"..pageTypeName];
end

function Expressive_Internal.Utils.ConvertStringToTitleCase(str)
    return str:lower():gsub("^%l", string.upper);
end

function Expressive_Internal.Utils.GetAllEmotes()
    local allEmoteTokens = {};
    local numEmotesFound = 0;

    for i=1, Expressive_Internal.Constants.MAX_EMOTE_INDEX, 1 do
        local token = _G["EMOTE"..i.."_TOKEN"];
        if token then
            tinsert(allEmoteTokens, token);
            numEmotesFound = numEmotesFound + 1;
        end
    end

    print("Found " .. numEmotesFound .. " emotes.");
    return allEmoteTokens;
end

function Expressive_Internal.Utils.FormatEmoteToken(emoteToken)
    local customText = L["EMOTE_"..emoteToken];
    return customText or Expressive_Internal.Utils.ConvertStringToTitleCase(emoteToken);
end

local REQUIRES_TARGET = {
    "PROMISE"
};

local ANIMATION_EMOTES = {
    "ANGRY",
    "CLAP",
    "CHUCKLE",
    "BASHFUL",
    "BLUSH",
    "CACKLE",
    "COWER",
    "CURIOUS",
    "CURTSEY",
    "DRINK",
    "GASP",
    "GIGGLE",
    "GLOAT",
    "GREET",
    "GROVEL",
    "GUFFAW",
    "HAIL",
    "LAYDOWN",
    "MOURN",
    "PLEAD",
    "PRAY",
    "ROFL",
    "SHOUT",
    "SHRUG",
    "SURRENDER",
    "TALKEX",
    "TALKQ",
    "VICTORY",
    "BOGGLE",
    "INSULT",
    "LOST",
    "PONDER",
    "PUZZLE",
    "TAUNT",
    "VIOLIN",
    "GROWL",
    "SCARED",
    "COMMEND",
    "GOLFCLAP",
    "BLAME",
    "DISAGREE",
    "DOUBT",
    "MERCY",
    "SING",
    "OBJECT",
    "YW",
    "READ",
    "FORTHEALLIANCE",
    "WHOA",
    "OOPS",
    "BOOP",
    "HUZZAH",
    "IMPRESSED",
    "MAGNIFICENT",
    "QUACK"
};

local VOICE_EMOTES = {
    "APOLOGIZE",
    "BORED",
    "CHICKEN",
    "CHUCKLE",
    "CACKLE",
    "GIGGLE",
    "GLOAT",
    "MOURN",
    "ROFL",
    "SIGH",
    "THREATEN",
    "WHISTLE",
    "YAWN",
    "TAUNT",
    "VIOLIN",
    "WHOA",
    "OOPS"
};

-- /glower has had a spelling error since patch 3.0.1.8622, making this spelling error over 15 years old

function Expressive_Internal.Utils.IsAnimEmote(emoteToken)
    return tContains(EmoteList, emoteToken) or tContains(ANIMATION_EMOTES, emoteToken);
end

function Expressive_Internal.Utils.IsVoiceEmote(emoteToken)
    return tContains(TextEmoteSpeechList, emoteToken) or tContains(VOICE_EMOTES, emoteToken);
end