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

    self:UpdateFavoriteState();
end

function ExpressiveFrameEmoteEntryButtonMixin:UpdateFavoriteState()
    self:GetParent().isFavorite = Settings.IsFavorited(self:GetEmoteToken());
end

function ExpressiveFrameEmoteEntryButtonMixin:OnClick()
    local emoteToken = self:GetEmoteToken();
    if IsShiftKeyDown() then
        self:ToggleFavorite();
    else
        DoEmote(emoteToken);
    end
end

function ExpressiveFrameEmoteEntryButtonMixin:SetIcon(icon)
    self.icon:SetTexture(icon);
end

function ExpressiveFrameEmoteEntryButtonMixin:SetVoiceIconVisibility(state)
    self.VoiceIcon:SetShown(state);
end

function ExpressiveFrameEmoteEntryButtonMixin:SetFavoriteIconVisibility(state)
    self.FavoriteIcon:SetShown(state);
end

-----------------

ExpressiveFrameEmoteEntryMixin = {};

--TODO: remove these after debugging 
NUM_EMOTES_ADDED = 0;
EMOTES_ADDED = {};

function ExpressiveFrameEmoteEntryMixin:Init(data)
    if data.left then
        local d = data.left;
        self.Left.Emote = d.emote;
        self.Left.Button:SetIcon(d.icon);
        self.Left.Label:SetText(d.name);
        self.Left:Show();

        self.Left.Button:SetVoiceIconVisibility(data.left.isVoiceEmote);
        self.Left.Button:SetFavoriteIconVisibility(data.left.isFavorite);
    else
        self.Left:Hide();
    end

    if data.right then
        local d = data.right;
        self.Right.Emote = d.emote;
        self.Right.Button:SetIcon(d.icon);
        self.Right.Label:SetText(d.name);
        self.Right:Show();

        self.Right.Button:SetVoiceIconVisibility(data.right.isVoiceEmote);
        self.Right.Button:SetFavoriteIconVisibility(data.right.isFavorite);
    else
        self.Right:Hide();
    end
end

-----------------

ExpressiveFrameEmoteBoxMixin = {};

function ExpressiveFrameEmoteBoxMixin:OnLoad()
    self.DataProvider = CreateDataProvider();

    local elementExtent = 35;

    self.ScrollView = CreateScrollBoxListLinearView();
    self.ScrollView:SetDataProvider(self.DataProvider);
    self.ScrollView:SetElementExtent(elementExtent);
    self.ScrollView:SetElementInitializer("ExpressiveFrameEmoteEntryTemplate", function(frame, data)
        frame:Init(data);
    end);

    local paddingTop = 8;
    local paddingBottom = 10;
    local paddingLeft = 10;
    local paddingRight = 0;
    local spacing = 5;

    self.ScrollView:SetPadding(paddingTop, paddingBottom, paddingLeft, paddingRight, spacing);

    self.ScrollBox:SetInterpolateScroll(true);
    self.ScrollBar:SetInterpolateScroll(true);
    self.ScrollBar:SetHideIfUnscrollable(true);

    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, self.ScrollView);
end

function ExpressiveFrameEmoteBoxMixin:RefreshDataProvider()
    self.ScrollView:FlushDataProvider();
end

function ExpressiveFrameEmoteBoxMixin:AddEmotePair(data)
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
    end

    -- setup page background
    do
        self.Background = self:CreateTexture(nil, "BACKGROUND");
        self.Background:SetAtlas("Adventures-CombatLog-BG");
        self.Background:SetPoint("TOPLEFT", self.Header, 5, 3);
        self.Background:SetPoint("BOTTOMRIGHT", -5, 3);
    end

    -- setup page 'working' area
    do
        self.EmoteBox = CreateFrame("Frame", self:GetName().."EmoteBox", self, "ExpressiveFrameEmoteBoxTemplate");
        self.EmoteBox:SetPoint("TOPLEFT", self.Header, "BOTTOMLEFT", 0, -3);
        self.EmoteBox:SetPoint("BOTTOMRIGHT", self.Background, "BOTTOMRIGHT");
    end

    self:Hide();
end

function ExpressiveFramePageMixin:AddEmotePair(data)
    self.EmoteBox:AddEmotePair(data);
end

function ExpressiveFramePageMixin:AddEmoteDataset(dataset)
    for _, tbl in ipairs(dataset) do
        self.EmoteBox:AddEmotePair(tbl);
    end
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
        "FavoriteAdded",
        "FavoriteRemoved",
        "FavoritesUpdated"
    }
);

function ExpressiveFrameMixin:OnLoad()
    self:SetTitle(addonName);
    self:SetMovable(true);

    do
        self.TitleContainer:EnableMouse(true);
        self.TitleContainer:RegisterForDrag("LeftButton");
        self.TitleContainer:SetScript("OnMouseDown", function()
            self:StartMoving();
        end);
        self.TitleContainer:SetScript("OnMouseUp", function()
            self:StopMovingOrSizing();
        end);
    end

    ButtonFrameTemplate_HidePortrait(self);

    do
        local menuBar = self.MenuBar;
        menuBar.Buttons = {};

        local favoritesButton = CreateFrame("Button", menuBar:GetName().."FavoritesButton", menuBar, "ExpressiveFrameMenuBarButtonTemplate");
        favoritesButton:SetPoint("LEFT", 5, 0);
        favoritesButton.PageType = PAGE_TYPE.FAVORITES;
        favoritesButton.TooltipText = L["PAGE_TITLE_FAVORITES"];
        tinsert(menuBar.Buttons, favoritesButton);

        local emotesButton = CreateFrame("Button", menuBar:GetName().."EmotesButton", menuBar, "ExpressiveFrameMenuBarButtonTemplate");
        emotesButton:SetPoint("LEFT", favoritesButton, "RIGHT", 5);
        emotesButton.PageType = PAGE_TYPE.EMOTES;
        emotesButton.TooltipText = L["PAGE_TITLE_EMOTES"];
        tinsert(menuBar.Buttons, emotesButton);

        local animButton = CreateFrame("Button", menuBar:GetName().."AnimEmotesButton", menuBar, "ExpressiveFrameMenuBarButtonTemplate");
        animButton:SetPoint("LEFT", emotesButton, "RIGHT", 5);
        animButton.PageType = PAGE_TYPE.ANIM;
        animButton.TooltipText = L["PAGE_TITLE_ANIM"];
        tinsert(menuBar.Buttons, animButton);

        local voiceButton = CreateFrame("Button", menuBar:GetName().."VoiceEmotesButton", menuBar, "ExpressiveFrameMenuBarButtonTemplate");
        voiceButton:SetPoint("LEFT", animButton, "RIGHT", 5);
        voiceButton.PageType = PAGE_TYPE.VOICE;
        voiceButton.TooltipText = L["PAGE_TITLE_VOICE"];
        tinsert(menuBar.Buttons, voiceButton);

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

        self:ChangePage(PAGE_TYPE.FAVORITES);
    end

    self:RegisterCallback("PageChanged", self.OnPageChanged, self);
    self:RegisterCallback("FavoritesUpdated", self.OnFavoritesUpdated, self);
end

function ExpressiveFrameMixin:OnShow()
    if not Settings.IsInitialized() then
        EventUtil.ContinueOnAddOnLoaded(addonName, function() self:Populate(); end);
    else
        self:Populate();
    end
end

function ExpressiveFrameMixin:OnHide()
    for _, page in ipairs(self.Pages) do
        page.EmoteBox.DataProvider:Flush();
    end
end

function ExpressiveFrameMixin:Toggle()
    if not self:IsShown() then
        self:Show();
    else
        self:Hide();
    end
end

function ExpressiveFrameMixin:Refresh()
    for _, page in ipairs(self.Pages) do
        page.EmoteBox:RefreshDataProvider();
    end
    self:Populate();
end

function ExpressiveFrameMixin:OnPageChanged(newPageType)
end

local function Profile(func, ...)
    local startTime = debugprofilestop();
    local results = {func(...);}
    local endTime = debugprofilestop();
    print("Execution took " .. endTime - startTime .. "ms");
    return unpack(results);
end

function ExpressiveFrameMixin:OnFavoritesUpdated()
    print("FavoritesUpdated");
    Profile(function() self:Refresh(); end);
    --self:Refresh();
end

function ExpressiveFrameMixin:ChangePage(pageType)
    local newPage = self.Pages[pageType];
    assert(newPage, "Requested page does not exist.");

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

local function CreateDataPairs(emoteTokens)
    local dataset = {};
    local deferred = {};

    for i=1, #emoteTokens, 2 do
        local tokenLeft = emoteTokens[i];
        local tokenRight = emoteTokens[i+1];

        local data = {};

        if tokenLeft and tokenRight then
            data.left = CreateDataFromEmoteToken(tokenLeft);
            data.right = CreateDataFromEmoteToken(tokenRight);

            tinsert(dataset, data);
        elseif tokenLeft and not tokenRight then
            tinsert(deferred, tokenLeft);
        elseif tokenRight and not tokenLeft then
            tinsert(deferred, tokenRight);
        end
    end

    if #deferred > 0 then
        for i=1, #deferred, 2 do
            local tokenLeft = deferred[i];
            local tokenRight = deferred[i+1];

            local data = {};

            if tokenLeft then
                data.left = CreateDataFromEmoteToken(tokenLeft);
            end

            if tokenRight then
                data.right = CreateDataFromEmoteToken(tokenRight);
            end

            if data.left then
                tinsert(dataset, data);
            end
        end
    end

    return dataset;
end

function ExpressiveFrameMixin:Populate()
    local allEmotes = CreateDataPairs(ALL_EMOTE_TOKENS);
    local animEmotes = {};
    local voiceEmotes = {};
    local favoriteEmotes = {};

    -- distribute the buttons into their appropriate tables
    for _, dataPair in pairs(allEmotes) do
        for _, d in pairs(dataPair) do
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
    end

    -- need to reassemble the buttons into pairs since the above loop splits them up
    local function ReassemblePairsAndAddDataToPage(dataset, targetPage)
        for i=1, #dataset, 2 do
            local dataLeft = dataset[i];
            local dataRight = dataset[i+1];

            local d = {};

            if dataLeft then
                d.left = dataLeft;
            end

            if dataRight then
                d.right = dataRight;
            end

            targetPage:AddEmotePair(d);
        end
    end

    local emotesPage = self.Pages[PAGE_TYPE.EMOTES];
    local favoritesPage = self.Pages[PAGE_TYPE.FAVORITES];
    local animPage = self.Pages[PAGE_TYPE.ANIM];
    local voicePage = self.Pages[PAGE_TYPE.VOICE];

    emotesPage:AddEmoteDataset(allEmotes);

    ReassemblePairsAndAddDataToPage(favoriteEmotes, favoritesPage);
    ReassemblePairsAndAddDataToPage(animEmotes, animPage);
    ReassemblePairsAndAddDataToPage(voiceEmotes, voicePage);
end



