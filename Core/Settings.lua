local addonName, Expressive_Internal = ...;

Expressive_Internal.Settings = {};

function Expressive_Internal.Settings.InitSavedVariables()
    if not ExpressiveFavorites then
        ExpressiveFavorites = {};
    end

    Expressive_Internal.Settings.AddFavorite("FLIRT");
end

EventUtil.ContinueOnAddOnLoaded(addonName, Expressive_Internal.Settings.InitSavedVariables);

function Expressive_Internal.Settings.IsInitialized()
    local loadingOrLoaded, loaded = C_AddOns.IsAddOnLoaded(addonName);
    return loadingOrLoaded and loaded;
end

function Expressive_Internal.Settings.GetFavorites()
    return ExpressiveFavorites;
end

function Expressive_Internal.Settings.IsFavorited(emoteToken)
    return tContains(ExpressiveFavorites, emoteToken);
end

function Expressive_Internal.Settings.AddFavorite(emoteToken)
    if Expressive_Internal.Settings.IsFavorited(emoteToken) then
        return;
    end

    tinsert(ExpressiveFavorites, emoteToken);
    ExpressiveFrame:TriggerEvent("FavoritesUpdated");
end

function Expressive_Internal.Settings.RemoveFavorite(emoteToken)
    local index = tIndexOf(ExpressiveFavorites, emoteToken);
    if index then
        tremove(ExpressiveFavorites, index);
    end

    ExpressiveFrame:TriggerEvent("FavoritesUpdated");
end