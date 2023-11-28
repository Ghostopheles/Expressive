local addonName, Expressive_Internal = ...;

local L = Expressive_Internal.Locale;

Expressive_Internal.Settings = {};

local AllSettings = {};
local DefaultConfig = {
    DefaultPage = 1;
};

function Expressive_Internal.Settings.InitSavedVariables()
    if not ExpressiveFavorites then
        ExpressiveFavorites = {};
    end

    if not ExpressiveConfig then
        ExpressiveConfig = CopyTable(DefaultConfig);
    end

    for name, setting in pairs(AllSettings) do
        local var = ExpressiveConfig[name];

        if not var then
            ExpressiveConfig[name] = setting:GetValue();
        else
            setting:SetValue(ExpressiveConfig[name]);
        end
    end
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

function Expressive_Internal.Settings.WipeFavorites()
    ExpressiveFavorites = wipe(ExpressiveFavorites);

    ExpressiveFrame:TriggerEvent("FavoritesUpdated");
end

StaticPopupDialogs["EXPRESSIVE_WIPE_FAVORITES_CONFIRM"] = {
	text = L.FAVORITES_CONFIRM_WIPE,
	button1 = YES,
	button2 = NO,
	OnAccept = Expressive_Internal.Settings.WipeFavorites,
	hideOnEscape = true,
	timeout = 15,
	exclusive = true,
	showAlert = true,
};

function Expressive_Internal.Settings.GetDefaultPage()
    return ExpressiveConfig.DefaultPage or Expressive_Internal.Constants.PAGE_TYPE.FAVORITES;
end

local function OnSettingChanged(_, setting, value)
    local variable = setting:GetVariable();
    ExpressiveConfig[variable] = value;
end

local category, layout = Settings.RegisterVerticalLayoutCategory(addonName);
layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L.CONFIG_HEADER_BASE));

do
    local variable = "DefaultPage";
    local variableType = Settings.VarType.Number;
    local name = "Default page";
    local tooltip = "Default emote page for Expressive";
    local defaultValue = DefaultConfig[variable];

    local function GetOptions()
        local container = Settings.CreateControlTextContainer();
        for typeName, typeNumber in pairs(Expressive_Internal.Constants.PAGE_TYPE) do
            container:Add(typeNumber, L["PAGE_TITLE_"..typeName]);
        end

        return container:GetData();
    end

    local setting = Settings.RegisterAddOnSetting(category, name, variable, variableType, defaultValue);
    Settings.CreateDropDown(category, setting, GetOptions, tooltip);
    Settings.SetOnValueChangedCallback(variable, OnSettingChanged);

    AllSettings[variable] = setting;
end

Settings.RegisterAddOnCategory(category);