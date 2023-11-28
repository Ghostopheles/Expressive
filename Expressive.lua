local addonName, Expressive_Internal = ...;

local L = Expressive_Internal.Locale;
local Utils = Expressive_Internal.Utils;
local Settings = Expressive_Internal.Settings;
local Constants = Expressive_Internal.Constants;
local PAGE_TYPE = Constants.PAGE_TYPE;
local ALL_EMOTE_TOKENS = Utils.GetAllEmotes();

-----------------

ExpressiveFrameEmoteEntryButtonMixin = {};

function ExpressiveFrameEmoteEntryButtonMixin:GetEmoteToken()
    return self:GetParent().Emote;
end

function ExpressiveFrameEmoteEntryButtonMixin:ToggleFavorite()
    local emoteToken = self:GetEmoteToken();
    if Settings.IsFavorited(emoteToken) then
        Settings.RemoveFavorite(emoteToken);
    else
        Settings.AddFavorite(emoteToken);
    end

    self:GetParent():UpdateFavoriteIconVisibility();
end

function ExpressiveFrameEmoteEntryButtonMixin:OnClick()
    local emoteToken = self:GetEmoteToken();
    if IsShiftKeyDown() then
        self:ToggleFavorite();
    else
        DoEmote(emoteToken);
    end
end

function ExpressiveFrameEmoteEntryButtonMixin:OnEnter()
    self.HighlightTexture:Show();
end

function ExpressiveFrameEmoteEntryButtonMixin:OnLeave()
    self.HighlightTexture:Hide();
end

function ExpressiveFrameEmoteEntryButtonMixin:SetIcon(icon)
    self.icon:SetTexture(icon);
end

-----------------

ExpressiveFrameEmoteEntryMixin = {};

function ExpressiveFrameEmoteEntryMixin:Init(data)
    local height = 45;
    local width = self:GetParent():GetWidth() / 2;
    self:SetSize(width, height);

    self.Emote = data.emote;
    self.IsFavorite = data.isFavorite;
    self.IsAnimEmote = data.isAnimEmote;
    self.IsVoiceEmote = data.isVoiceEmote;

    self.Label:SetText(data.name);
    self.Button:SetIcon(data.icon);

    self:UpdateSpecialIconVisibility();
    self:RegisterHelpIconScripts();

    ExpressiveFrame:RegisterCallback("FavoritesUpdated", self.UpdateFavoriteIconVisibility, self);
end

function ExpressiveFrameEmoteEntryMixin:UpdateSpecialIconVisibility()
    self:UpdateFavoriteIconVisibility();

    local animIcon, voiceIcon = self.Button.AnimIcon, self.Button.VoiceIcon;
    animIcon:SetShown(self.IsAnimEmote);
    voiceIcon:SetShown(self.IsVoiceEmote);
end

function ExpressiveFrameEmoteEntryMixin:UpdateFavoriteIconVisibility()
    self.IsFavorite = Settings.IsFavorited(self.Emote);
    self.Button.FavoriteIcon:SetShown(self.IsFavorite);
end

function ExpressiveFrameEmoteEntryMixin:RegisterHelpIconScripts()
    local animIcon = self.Button.AnimIcon;
    local voiceIcon = self.Button.VoiceIcon;

    animIcon:SetScript("OnEnter", self.OnHelpTextureEnter);
    voiceIcon:SetScript("OnEnter", self.OnHelpTextureEnter);

    animIcon:SetScript("OnLeave", self.OnHelpTextureLeave);
    voiceIcon:SetScript("OnLeave", self.OnHelpTextureLeave);
end

--- takes in the above helpIcon as self
function ExpressiveFrameEmoteEntryMixin:OnHelpTextureEnter()
    if not self:IsShown() then
        return;
    end

    local tooltipText = L.HELP_ICON_TOOLTIP_TEXT;
    local parentEntry = self:GetParent():GetParent();
    local isAnim, isVoice = parentEntry.IsAnimEmote, parentEntry.IsVoiceEmote;

    if isAnim and isVoice then
        tooltipText = format(tooltipText, L.HELP_ICON_TOOLTIP_BOTH);
    elseif isAnim then
        tooltipText = format(tooltipText, L.HELP_ICON_TOOLTIP_ANIM_ONLY);
    elseif isVoice then
        tooltipText = format(tooltipText, L.HELP_ICON_TOOLTIP_VOICE_ONLY);
    else
        return;
    end

    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
    GameTooltip:SetText(tooltipText, 1, 1, 1);
    GameTooltip:Show();
end

--- takes in the icon texture as self
function ExpressiveFrameEmoteEntryMixin:OnHelpTextureLeave()
    if not self:IsShown() then
        return;
    end

    GameTooltip:Hide();
end

-----------------

ExpressiveFrameConfigBoxMixin = {};

function ExpressiveFrameConfigBoxMixin:OnLoad()
    if 1 == 1 then
        do -- create automation section
            self.AutomationHeader = self:CreateFontString(nil, nil, "GameFontHighlight");
            self.AutomationHeader:SetPoint("TOPLEFT");
            self.AutomationHeader:SetPoint("TOPRIGHT");
            self.AutomationHeader:SetHeight(20);
            self.AutomationHeader:SetJustifyH("CENTER");
            self.AutomationHeader:SetScale(1.2);
            self.AutomationHeader:SetText(L.CONFIG_HEADER_AUTOMATION);
        end

        do -- TRP3 automation
            self.AutomationToggle = CreateFrame("CheckButton", nil, self, "UICheckButtonTemplate");
            self.AutomationToggle:SetPoint("TOPLEFT", self.AutomationHeader, "BOTTOMLEFT", 20, -8);
            self.AutomationToggle:SetSize(35, 35);

            self.AutomationToggle.Text:SetText(L.CONFIG_TRP3_ENABLE_AUTOMATION);
            self.AutomationToggle.Text:SetTextColor(1, 1, 1);
        end
    end
end

-----------------

ExpressiveFrameEmoteBoxMixin = {};

function ExpressiveFrameEmoteBoxMixin:OnLoad()
    self.DataProvider = CreateDataProvider();

    local stride = 2;
    self.ScrollView = CreateScrollBoxListGridView(stride);
    self.ScrollView:SetDataProvider(self.DataProvider);
    self.ScrollView:SetElementInitializer("ExpressiveFrameEmoteEntryTemplate", function(frame, data)
        frame:Init(data);
    end);

    local paddingTop = 8;
    local paddingBottom = 0;
    local paddingLeft = 10;
    local paddingRight = 10;
    local spacing = 5;

    self.ScrollView:SetPadding(paddingTop, paddingBottom, paddingLeft, paddingRight, spacing);

    self.ScrollBox:SetInterpolateScroll(true);
    self.ScrollBar:SetInterpolateScroll(true);
    self.ScrollBar:SetHideIfUnscrollable(true);

    ScrollUtil.InitScrollBoxWithScrollBar(self.ScrollBox, self.ScrollBar, self.ScrollView);
end

function ExpressiveFrameEmoteBoxMixin:RefreshDataProvider()
    self.ScrollView:FlushDataProvider();
end

function ExpressiveFrameEmoteBoxMixin:AddEmote(data)
    self.DataProvider:Insert(data);
end

-----------------

local ExpressiveFramePageMixin = {};

function ExpressiveFramePageMixin:Init(pageType)
    self.PageType = pageType;

    -- anchoring
    do
        local menuBar = ExpressiveFrameMenuBar;
        self:SetPoint("TOPLEFT", menuBar, "BOTTOMLEFT");
        self:SetPoint("TOPRIGHT", menuBar, "BOTTOMRIGHT");
        self:SetPoint("BOTTOMLEFT");
        self:SetPoint("BOTTOMRIGHT");
    end

    -- setup the header
    do
        self.Header = CreateFrame("Frame", nil, self);
        self.Header:SetPoint("TOPLEFT");
        self.Header:SetPoint("TOPRIGHT");
        self.Header:SetHeight(35);

        self.Header.Text = self.Header:CreateFontString(nil, nil, "GameFontHighlight");
        self.Header.Text:SetAllPoints();
        self.Header.Text:SetJustifyH("CENTER");
        self.Header.Text:SetScale(1.5);
        self.Header.Text:SetText(Expressive_Internal.Utils.GetPageTitleFromPageType(self.PageType));

        self.Header.Banner = self.Header:CreateTexture(nil, "BACKGROUND");
        self.Header.Banner:SetAtlas("Adventures_MissionList");
        self.Header.Banner:SetPoint("TOPLEFT", 10, 0);
        self.Header.Banner:SetPoint("BOTTOMRIGHT", -10, 0);

        if self.PageType == PAGE_TYPE.FAVORITES then
            self.Header.WipeButton = CreateFrame("Button", nil, self.Header, "RefreshButtonTemplate");
            self.Header.WipeButton:SetPoint("RIGHT", -15, 0);
            self.Header.WipeButton:SetWidth(35);
            self.Header.WipeButton:HookScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOP");
                GameTooltip:SetText(L.FAVORITES_WIPE_BUTTON_TOOLTIP, 1, 1, 1);
                GameTooltip:Show();
            end);
            self.Header.WipeButton:HookScript("OnLeave", function()
                GameTooltip:Hide();
            end);
            self.Header.WipeButton:HookScript("OnClick", function()
                StaticPopup_Show("EXPRESSIVE_WIPE_FAVORITES_CONFIRM");
            end);
        end
    end

    -- setup page background
    do
        self.Background = self:CreateTexture(nil, "BACKGROUND");
        self.Background:SetAtlas("Adventures-CombatLog-BG");
        self.Background:SetPoint("TOPLEFT", self.Header, 5, 3);
        self.Background:SetPoint("BOTTOMRIGHT", -5, 3);
    end

    if self.PageType ~= PAGE_TYPE.CONFIG then
        -- setup page 'working' area
        self.EmoteBox = CreateFrame("Frame", self:GetName().."EmoteBox", self, "ExpressiveFrameEmoteBoxTemplate");
        self.EmoteBox:SetPoint("TOPLEFT", self.Header, "BOTTOMLEFT", 0, -3);
        self.EmoteBox:SetPoint("BOTTOMRIGHT", self.Background, "BOTTOMRIGHT");
    else
        self.ConfigBox = CreateFrame("Frame", self:GetName().."ConfigBox", self, "ExpressiveFrameConfigBoxTemplate");
        self.ConfigBox:SetPoint("TOPLEFT", self.Header, "BOTTOMLEFT", 0, -3);
        self.ConfigBox:SetPoint("BOTTOMRIGHT", self.Background, "BOTTOMRIGHT");
    end

    self.Initialized = false;

    self:Hide();
end

function ExpressiveFramePageMixin:AddEmote(data)
    self.EmoteBox:AddEmote(data);
end

function ExpressiveFramePageMixin:AddEmoteDataset(dataset)
    for _, data in ipairs(dataset) do
        self:AddEmote(data);
    end

    self.Initialized = true;
end

local function CreatePage(parent, pageType, pageName)
    local f = CreateFrame("Frame", pageName, parent);
    Mixin(f, ExpressiveFramePageMixin);

    f:Init(pageType);
    return f;
end

-----------------

ExpressiveFrameMenuBarButtonMixin = {};

function ExpressiveFrameMenuBarButtonMixin:UpdateActiveTexture(pageType)
    if pageType == self.PageType then
        self.ActiveTexture:Show();
    else
        self.ActiveTexture:Hide();
    end
end

-----------------

ExpressiveFrameMixin = CreateFromMixins(CallbackRegistryMixin);
ExpressiveFrameMixin:OnLoad();
ExpressiveFrameMixin:GenerateCallbackEvents(
    {
        "PageChanged",
        "FavoritesUpdated"
    }
);

function ExpressiveFrameMixin:OnLoad()
    self:SetTitle(addonName);
    self:SetMovable(true);
    self:SetClampedToScreen(true);

    self.Initialized = false;

    do
        self.TitleContainer:SetMouseClickEnabled(true);
        self.TitleContainer:RegisterForDrag("LeftButton");
        self.TitleContainer:SetScript("OnMouseDown", function()
            self:StartMoving();
        end);
        self.TitleContainer:SetScript("OnMouseUp", function()
            self:StopMovingOrSizing();
        end);
        self.TitleContainer:SetHitRectInsets(0, self.CloseButton:GetWidth(), 0, 0);
    end

    ButtonFrameTemplate_HidePortrait(self);

    do
        local menuBar = self.MenuBar;
        menuBar.Buttons = {};

        local favoritesButton = CreateFrame("Button", menuBar:GetName().."FavoritesButton", menuBar, "ExpressiveFrameMenuBarButtonTemplate");
        favoritesButton:SetPoint("LEFT", 5, 0);
        favoritesButton.PageType = PAGE_TYPE.FAVORITES;
        favoritesButton.TooltipText = L.PAGE_TITLE_FAVORITES;
        tinsert(menuBar.Buttons, favoritesButton);

        local emotesButton = CreateFrame("Button", menuBar:GetName().."EmotesButton", menuBar, "ExpressiveFrameMenuBarButtonTemplate");
        emotesButton:SetPoint("LEFT", favoritesButton, "RIGHT", 5);
        emotesButton.PageType = PAGE_TYPE.EMOTES;
        emotesButton.TooltipText = L.PAGE_TITLE_EMOTES;
        tinsert(menuBar.Buttons, emotesButton);

        local animButton = CreateFrame("Button", menuBar:GetName().."AnimEmotesButton", menuBar, "ExpressiveFrameMenuBarButtonTemplate");
        animButton:SetPoint("LEFT", emotesButton, "RIGHT", 5);
        animButton.PageType = PAGE_TYPE.ANIM;
        animButton.TooltipText = L.PAGE_TITLE_ANIM;
        tinsert(menuBar.Buttons, animButton);

        local voiceButton = CreateFrame("Button", menuBar:GetName().."VoiceEmotesButton", menuBar, "ExpressiveFrameMenuBarButtonTemplate");
        voiceButton:SetPoint("LEFT", animButton, "RIGHT", 5);
        voiceButton.PageType = PAGE_TYPE.VOICE;
        voiceButton.TooltipText = L.PAGE_TITLE_VOICE;
        tinsert(menuBar.Buttons, voiceButton);

        local configButton = CreateFrame("Button", menuBar:GetName().."ConfigButton", menuBar, "ExpressiveFrameMenuBarButtonTemplate");
        configButton:SetPoint("TOPRIGHT", -15, -5);
        configButton.PageType = PAGE_TYPE.CONFIG;
        configButton.TooltipText = L.PAGE_TITLE_CONFIG;
        tinsert(menuBar.Buttons, configButton);

        self:RegisterCallback("PageChanged", function(_, newPageType)
            for _, button in ipairs(menuBar.Buttons) do
                button:UpdateActiveTexture(newPageType);
            end
        end);
    end

    do
        self.Pages = {};

        local favoritesPage = CreatePage(self.Bg, PAGE_TYPE.FAVORITES, self:GetName().."FavoritesPage");
        tinsert(self.Pages, PAGE_TYPE.FAVORITES, favoritesPage);

        local emotesPage = CreatePage(self.Bg, PAGE_TYPE.EMOTES, self:GetName().."EmotesPage");
        tinsert(self.Pages, PAGE_TYPE.EMOTES, emotesPage);

        local animPage = CreatePage(self.Bg, PAGE_TYPE.ANIM, self:GetName().."AnimPage");
        tinsert(self.Pages, PAGE_TYPE.ANIM, animPage);

        local voicePage = CreatePage(self.Bg, PAGE_TYPE.VOICE, self:GetName().."VoicePage");
        tinsert(self.Pages, PAGE_TYPE.VOICE, voicePage);

        local configPage = CreatePage(self.Bg, PAGE_TYPE.CONFIG, self:GetName().."ConfigPage");
        tinsert(self.Pages, PAGE_TYPE.CONFIG, configPage);
    end

    self:RegisterCallback("FavoritesUpdated", self.OnFavoritesUpdated, self);

    self:Show();
end

function ExpressiveFrameMixin:OnShow()
    if not Settings.IsInitialized() then
        EventUtil.ContinueOnAddOnLoaded(addonName, function() self:Populate(); end);
    elseif self.Initialized then
        self:RefreshFavorites();
    else
        self:Populate();
    end
end

function ExpressiveFrameMixin:Toggle()
    if not self:IsShown() then
        self:Show();
    else
        self:Hide();
    end
end

function ExpressiveFrameMixin:OnFavoritesUpdated()
    self:RefreshFavorites();
end

function ExpressiveFrameMixin:ChangePage(pageType)
    local newPage = self.Pages[pageType];
    assert(newPage, format("Requested page (%d) does not exist.", pageType));

    if self.CurrentPage then
        self.CurrentPage:Hide();
    end

    self.CurrentPage = newPage;
    self.CurrentPage:Show();

    self:TriggerEvent("PageChanged", pageType);
end

-----------------

local function CreateDataFromEmoteToken(emoteToken)
    local data = {
        name = Utils.FormatEmoteToken(emoteToken),
        icon = Constants.PH_ICON,
        emote = emoteToken,
        isFavorite = Settings.IsFavorited(emoteToken),
        isAnimEmote = Utils.IsAnimEmote(emoteToken),
        isVoiceEmote = Utils.IsVoiceEmote(emoteToken)
    };

    return data;
end

local function CreateDataset(emoteTokens)
    local dataset = {};

    for _, emoteToken in pairs(emoteTokens) do
        tinsert(dataset, CreateDataFromEmoteToken(emoteToken));
    end

    return dataset;
end

local function CreateFavoritesDataset()
    local favorites = Settings.GetFavorites();
    return CreateDataset(favorites);
end

-----------------

function ExpressiveFrameMixin:RefreshFavorites()
    print("REFRESHFAVORITES")
    local page = self.Pages[PAGE_TYPE.FAVORITES];
    local favorites = CreateFavoritesDataset();

    page.EmoteBox:RefreshDataProvider();
    page:AddEmoteDataset(favorites);
end

function ExpressiveFrameMixin:Populate()
    if self.Initialized then
        return;
    end

    local allEmotes = CreateDataset(ALL_EMOTE_TOKENS);
    local animEmotes = {};
    local voiceEmotes = {};
    local favoriteEmotes = {};

    ALL_EMOTES_DATA = allEmotes;

    -- distribute the buttons into their appropriate tables
    for _, d in pairs(allEmotes) do
        if d.isAnimEmote then
            tinsert(animEmotes, d);
        end
        if d.isVoiceEmote then
            tinsert(voiceEmotes, d);
        end
        if d.isFavorite then
            tinsert(favoriteEmotes, d);
        end
    end

    ALL_ANIM = animEmotes;
    ALL_VOICE = voiceEmotes;
    ALL_FAVORITE = favoriteEmotes;

    local favoritesPage = self.Pages[PAGE_TYPE.FAVORITES];
    local emotesPage = self.Pages[PAGE_TYPE.EMOTES];
    local animPage = self.Pages[PAGE_TYPE.ANIM];
    local voicePage = self.Pages[PAGE_TYPE.VOICE];

    favoritesPage:AddEmoteDataset(favoriteEmotes);
    emotesPage:AddEmoteDataset(allEmotes);
    animPage:AddEmoteDataset(animEmotes);
    voicePage:AddEmoteDataset(voiceEmotes);

    self:ChangePage(Settings.GetDefaultPage());

    self.Initialized = true;
end

-----------------

