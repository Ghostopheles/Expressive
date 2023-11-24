local addonName, Expressive_Internal = ...;

local L = Expressive_Internal.Locale;

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
    if tContains(Expressive_Internal.Constants.SpecialTreatmentEmoteTokens, emoteToken) then
        return L["EMOTE_"..emoteToken];
    else
        return Expressive_Internal.Utils.ConvertStringToTitleCase(emoteToken);
    end
end

function Expressive_Internal.Utils.IsAnimEmote(emoteToken)
    return tContains(EmoteList, emoteToken);
end

function Expressive_Internal.Utils.IsVoiceEmote(emoteToken)
    return tContains(TextEmoteSpeechList, emoteToken);
end