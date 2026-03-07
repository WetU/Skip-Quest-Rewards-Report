local _G = _G;

local type = _G.type;

local sdk = _G.sdk;
local find_type_definition = sdk.find_type_definition;
local get_managed_singleton = sdk.get_managed_singleton;
local hook = sdk.hook;
local to_int64 = sdk.to_int64;
local PreHookResult = sdk.PreHookResult;
local SKIP_ORIGINAL = PreHookResult.SKIP_ORIGINAL;
local CALL_ORIGINAL = PreHookResult.CALL_ORIGINAL;

local get_hook_storage = _G.thread.get_hook_storage;

local json = _G.json;
local load_file = json.load_file;
local dump_file = json.dump_file;

local re = _G.re;

local imgui = _G.imgui;
local tree_node = imgui.tree_node;
local tree_pop = imgui.tree_pop;
local checkbox = imgui.checkbox;
local begin_disabled = imgui.begin_disabled;
local end_disabled = imgui.end_disabled;
local is_item_hovered = imgui.is_item_hovered;
local set_tooltip = imgui.set_tooltip;

local defaults = {
    enable = true, 
    autoSellRewards = false,
    autoSellArtian = false,
    autoSellGogma = false,
    autoSellJewel = false,
    haltNewItem = true,
    showWish = true,
    autoCloseConfirm = true,
    enableSkipAmulet = false,
    autoSellAmulet = false,
    autoSkipSeamless = true,
    autoSellRewardsSeamless = false,
    autoSellArtianSeamless = false,
    autoSellJewelSeamless = false,
    autoSellAmuletSeamless = false,
    openAmuletJudgeBox = false,
    openNew = true,
    openWish = true
};

local config = load_file("SkipQuestRewardReport.json") or defaults;

for k, v in _G.pairs(config) do
    if v == nil or type(v) ~= "boolean" then
        v = defaults[k];
    end
end

local function saveConfig()
    dump_file("SkipQuestRewardReport.json", config);
end

local isItemRequiredForWishlist_method = find_type_definition("app.WishlistUtil"):get_method("isItemRequiredForWishlist(app.ItemDef.ID)");
--<< GUI070000 Fix Quest Result >>--
local UI070000 = find_type_definition("app.GUIID.ID"):get_field("UI070000"):get_data(nil);

local get_IDInt_method = find_type_definition("ace.GUIBase`2<app.GUIID.ID,app.GUIFunc.TYPE>"):get_method("get_IDInt");

local GUIPartsReward_type_def = find_type_definition("app.cGUIPartsReward");
local set__WaitAnimationTime_method = GUIPartsReward_type_def:get_method("set__WaitAnimationTime(System.Single)");
local set__WaitControlTime_method = GUIPartsReward_type_def:get_method("set__WaitControlTime(System.Single)");
local receiveAll_method = GUIPartsReward_type_def:get_method("receiveAll");
local sellAll_method = GUIPartsReward_type_def:get_method("sellAll");
local GUIPartsReward_InputCtrl_field = GUIPartsReward_type_def:get_field("_InputCtrl");
local ItemGridParts_field = GUIPartsReward_type_def:get_field("_ItemGridParts");

local get_Owner_method = GUIPartsReward_type_def:get_parent_type():get_method("get_Owner");

local GUIPartsReward_MODE_type_def = find_type_definition("app.cGUIPartsReward.MODE");
local GUIPartsReward_REWARD = GUIPartsReward_MODE_type_def:get_field("REWARD"):get_data(nil);
local GUIPartsReward_JUDGE = GUIPartsReward_MODE_type_def:get_field("JUDGE"):get_data(nil);

local GUIPartsRewardInfo_get_RewardItems_method = find_type_definition("app.cGUIPartsRewardInfo"):get_method("get_RewardItems");

local GUIRewardItems_type_def = find_type_definition("app.cGUIRewardItems");
local get_ItemInfoSize_method = GUIRewardItems_type_def:get_method("get_ItemInfoSize");
local getItemInfo_method = GUIRewardItems_type_def:get_method("getItemInfo(System.Int32)");

local SendItemInfo_type_def = getItemInfo_method:get_return_type();
local getReward_method = SendItemInfo_type_def:get_method("getReward(System.Boolean, System.Boolean)");
local sellReward_method = SendItemInfo_type_def:get_method("sellReward(System.Boolean)");

local ReceiveItemInfo_type_def = SendItemInfo_type_def:get_parent_type();
local get_ArtianPartsData_method = ReceiveItemInfo_type_def:get_method("get_ArtianPartsData");
local get_AccessoryId_method = ReceiveItemInfo_type_def:get_method("get_AccessoryId");
local get_RandomAmuletData_method = ReceiveItemInfo_type_def:get_method("get_RandomAmuletData");
local get_ItemId_method = ReceiveItemInfo_type_def:get_method("get_ItemId");

local get_IsEm0078_ArtianParts_method = get_ArtianPartsData_method:get_return_type():get_method("get_IsEm0078_ArtianParts");

local ACCESSORY_ID_type_def = get_AccessoryId_method:get_return_type();
local ACCESSORY_INVALID = ACCESSORY_ID_type_def:get_field("INVALID"):get_data(nil);
local ACCESSORY_MAX = ACCESSORY_ID_type_def:get_field("MAX"):get_data(nil);

local GenericList_type_def = ItemGridParts_field:get_type();
local GenericList_get_Count_method = GenericList_type_def:get_method("get_Count");
local GenericList_get_Item_method = GenericList_type_def:get_method("get_Item(System.Int32)");

local GUIItemGridPartsFluent_type_def = find_type_definition("app.cGUIItemGridPartsFluent");
local get_SelectItem_method = GUIItemGridPartsFluent_type_def:get_method("get_SelectItem");
local get__PanelNewMark_method = GUIItemGridPartsFluent_type_def:get_parent_type():get_parent_type():get_method("get__PanelNewMark");

local get_Enabled_method = get_SelectItem_method:get_return_type():get_method("get_Enabled");

local get_ActualVisible_method = get__PanelNewMark_method:get_return_type():get_parent_type():get_parent_type():get_parent_type():get_parent_type():get_method("get_ActualVisible");

local InputCtrl_type_def = GUIPartsReward_InputCtrl_field:get_type();
local get_InputPriority_method = InputCtrl_type_def:get_method("get_InputPriority");
local requestCallTrigger_method = InputCtrl_type_def:get_method("requestCallTrigger(app.GUIFunc.TYPE)");

local GUI070001_type_def = find_type_definition("app.GUI070001");
local get_IsViewMode_method = GUI070001_type_def:get_method("get_IsViewMode");
local skipAnimation_method = GUI070001_type_def:get_method("skipAnimation");

local shouldSellConfirm = false;

local function hasNewItem(ItemGridParts, isFix)
    if isFix then
        for i = 0, GenericList_get_Count_method:call(ItemGridParts) - 1 do
            local GUIItemGridPartsFluent = GenericList_get_Item_method:call(ItemGridParts, i);
            if get_Enabled_method:call(get_SelectItem_method:call(GUIItemGridPartsFluent)) and get_ActualVisible_method:call(get__PanelNewMark_method:call(GUIItemGridPartsFluent)) then
                return true;
            end
        end
    else
        for i = 0, GenericList_get_Count_method:call(ItemGridParts) - 1 do
            if get_ActualVisible_method:call(get__PanelNewMark_method:call(GenericList_get_Item_method:call(ItemGridParts, i))) then
                return true;
            end
        end
    end
    return false;
end

local function hasWishItem(RewardItems_list)
    for i = 0, GenericList_get_Count_method:call(RewardItems_list) - 1 do
        local RewardItems = GenericList_get_Item_method:call(RewardItems_list, i);
        for j = 0, get_ItemInfoSize_method:call(RewardItems) - 1 do
            if isItemRequiredForWishlist_method:call(nil, get_ItemId_method:call(getItemInfo_method:call(RewardItems, j))) then
                return true;
            end
        end
    end
    return false;
end

local function auto_sell(obj)
    sellAll_method:call(obj);
    shouldSellConfirm = true;
end

local isFixQuestResult = nil;
hook(GUIPartsReward_type_def:get_method("start(app.cGUIPartsRewardInfo, app.cGUIPartsReward.MODE, System.Boolean, System.Boolean)"), function(args)
    if config.enable and (to_int64(args[5]) & 1) == 0 then
        local this_ptr = args[2];
        if get_IDInt_method:call(get_Owner_method:call(this_ptr)) == UI070000 then
            local Mode = to_int64(args[4]) & 0xFFFFFFFF;
            local storage = get_hook_storage();
            storage.this_ptr = this_ptr;
            storage.Mode = (to_int64(args[6]) & 1) == 1 and 2 or Mode;
            if Mode == GUIPartsReward_REWARD then
                if config.showWish then
                    storage.GUIPartsRewardInfo = args[3];
                end
            elseif Mode == GUIPartsReward_JUDGE then
                if config.autoSellRewards == false and (config.autoSellArtian or config.autoSellGogma or config.autoSellJewel) then
                    local GUIRewardItems_list = GUIPartsRewardInfo_get_RewardItems_method:call(args[3]);
                    for i = 0, GenericList_get_Count_method:call(GUIRewardItems_list) - 1 do
                        local GUIRewardItems = GenericList_get_Item_method:call(GUIRewardItems_list, i);
                        for j = 0, get_ItemInfoSize_method:call(GUIRewardItems) - 1 do
                            local ItemInfo = getItemInfo_method:call(GUIRewardItems, j);
                            if config.autoSellArtian or config.autoSellGogma then
                                local ArtianPartsData = get_ArtianPartsData_method:call(ItemInfo);
                                if ArtianPartsData ~= nil then
                                    if (config.autoSellGogma and get_IsEm0078_ArtianParts_method:call(ArtianPartsData)) or config.autoSellArtian then
                                        sellReward_method:call(ItemInfo, true);
                                        goto continue;
                                    end
                                end
                            end
                            if config.autoSellJewel then
                                local AccessoryId = get_AccessoryId_method:call(ItemInfo);
                                if AccessoryId > ACCESSORY_INVALID and AccessoryId < ACCESSORY_MAX then
                                    sellReward_method:call(ItemInfo, true);
                                end
                            end
                            ::continue::
                        end
                    end
                end
            end
            isFixQuestResult = true;
        end
    end
end, function()
    if isFixQuestResult then
        isFixQuestResult = nil;
        local storage = get_hook_storage();
        local this_ptr = storage.this_ptr;
        set__WaitControlTime_method:call(this_ptr, 0.0);
        local Mode = storage.Mode;
        if Mode == GUIPartsReward_REWARD then
            if (config.haltNewItem == false or hasNewItem(ItemGridParts_field:get_data(this_ptr), true) == false)
            and (config.showWish == false or hasWishItem(GUIPartsRewardInfo_get_RewardItems_method:call(storage.GUIPartsRewardInfo)) == false)
            and get_InputPriority_method:call(GUIPartsReward_InputCtrl_field:get_data(this_ptr)) == 0 then
                if config.autoSellRewards then
                    auto_sell(this_ptr);
                else
                    receiveAll_method:call(this_ptr);
                end
            end
        elseif Mode == GUIPartsReward_JUDGE then
            if (config.haltNewItem and hasNewItem(ItemGridParts_field:get_data(this_ptr), true)) or get_InputPriority_method:call(GUIPartsReward_InputCtrl_field:get_data(this_ptr)) ~= 0 then
                set__WaitAnimationTime_method:call(this_ptr, 0.01);
            else
                if config.autoSellRewards then
                    auto_sell(this_ptr);
                else
                    receiveAll_method:call(this_ptr);
                end
            end
        else
            if config.autoSellRewards or config.autoSellAmulet then
                if get_InputPriority_method:call(GUIPartsReward_InputCtrl_field:get_data(this_ptr)) == 0 then
                    auto_sell(this_ptr);
                end
            elseif config.enableSkipAmulet then
                if get_InputPriority_method:call(GUIPartsReward_InputCtrl_field:get_data(this_ptr)) == 0 then
                    receiveAll_method:call(this_ptr);
                end
            else
                set__WaitAnimationTime_method:call(this_ptr, 0.01);
            end
        end
    end
end);

hook(GUI070001_type_def:get_method("onOpen"), function(args)
    if config.enable then
        get_hook_storage().this_ptr = args[2];
    end
end, function()
    if config.enable then
        local this_ptr = get_hook_storage().this_ptr;
        if get_IsViewMode_method:call(this_ptr) == false then
            skipAnimation_method:call(this_ptr);
        end
    end
end);
--<< GUI000003 Skip Confirm Dialogue >>--
local GUI000003_type_def = find_type_definition("app.GUI000003");
local NotifyWindowApp_field = GUI000003_type_def:get_field("_NotifyWindowApp");

local GUISystemModuleNotifyWindowApp_type_def = NotifyWindowApp_field:get_type();
local get__CurInfoApp_method = GUISystemModuleNotifyWindowApp_type_def:get_method("get__CurInfoApp");
local closeGUI_method = GUISystemModuleNotifyWindowApp_type_def:get_method("closeGUI");

local GUINotifyWindowInfo_type_def = get__CurInfoApp_method:get_return_type();
local get_NotifyWindowId_method = GUINotifyWindowInfo_type_def:get_method("get_NotifyWindowId");
local endWindow_method = GUINotifyWindowInfo_type_def:get_method("endWindow(System.Int32)");
local executeWindowEndFunc_method = GUINotifyWindowInfo_type_def:get_method("executeWindowEndFunc");

local NotifyWindowID_type_def = get_NotifyWindowId_method:get_return_type();
local NotifyWindowID = {
    GUI070000_DLG00 = NotifyWindowID_type_def:get_field("GUI070000_DLG00"):get_data(nil),
    GUI070000_DLG01 = NotifyWindowID_type_def:get_field("GUI070000_DLG01"):get_data(nil),
    GUI070000_DLG02 = NotifyWindowID_type_def:get_field("GUI070000_DLG02"):get_data(nil)
};

local function closeDLG(notifyWindowApp, infoApp)
    endWindow_method:call(infoApp, 0);
    executeWindowEndFunc_method:call(infoApp);
    closeGUI_method:call(notifyWindowApp);
end

hook(GUI000003_type_def:get_method("guiOpenUpdate"), function(args)
    if config.autoCloseConfirm then
        get_hook_storage().this_ptr = args[2];
    end
end, function()
    if config.autoCloseConfirm then
        local NotifyWindowApp = NotifyWindowApp_field:get_data(get_hook_storage().this_ptr);
        local CurInfoApp = get__CurInfoApp_method:call(NotifyWindowApp);
        if CurInfoApp ~= nil then
            local Id = get_NotifyWindowId_method:call(CurInfoApp);
            if Id == NotifyWindowID.GUI070000_DLG00 then
                if shouldSellConfirm then
                    shouldSellConfirm = false;
                    closeDLG(NotifyWindowApp, CurInfoApp);
                end
            elseif Id == NotifyWindowID.GUI070000_DLG01 or Id == NotifyWindowID.GUI070000_DLG02 then
                closeDLG(NotifyWindowApp, CurInfoApp);
            end
        end
    end
end);
--<< GUI020100 Seamless Quest Result >>--
local GUI020100_type_def = find_type_definition("app.GUI020100");
local get__PartsQuestRewardItem_method = GUI020100_type_def:get_method("get__PartsQuestRewardItem");
local GUI020100_InputCtrl_field = GUI020100_type_def:get_field("_InputCtrl");

local GUI020100PanelQuestRewardItem_type_def = get__PartsQuestRewardItem_method:get_return_type();
local get__PartsQuestRewardItems_method = GUI020100PanelQuestRewardItem_type_def:get_method("get__PartsQuestRewardItems");

local GUIPartsRewardItems_type_def = get__PartsQuestRewardItems_method:get_return_type();
local get__Mode_method = GUIPartsRewardItems_type_def:get_method("get__Mode");
local GUIPartsRewardItems_get_RewardItems_method = GUIPartsRewardItems_type_def:get_method("get_RewardItems");
local GUIPartsRewardItems_ItemGridParts_field = GUIPartsRewardItems_type_def:get_field("_ItemGridParts");

local get_FixControl_method = GUI020100PanelQuestRewardItem_type_def:get_parent_type():get_parent_type():get_method("get_FixControl");

local finish_method = get_FixControl_method:get_return_type():get_method("finish");

local terminateQuestResult_method = find_type_definition("app.GUIManager"):get_method("terminateQuestResult");

local JUST_TIMING_SHORTCUT = find_type_definition("app.GUIFunc.TYPE"):get_field("JUST_TIMING_SHORTCUT"):get_data(nil);

local GUIPartsRewardItems_MODE_type_def = get__Mode_method:get_return_type();
local GUIPartsRewardItems_REWARD = GUIPartsRewardItems_MODE_type_def:get_field("REWARD"):get_data(nil);
local GUIPartsRewardItems_JUDGE = GUIPartsRewardItems_MODE_type_def:get_field("JUDGE"):get_data(nil);

local ZERO_float_ptr = sdk.float_to_ptr(0.0);

local function preHook(args)
    if config.autoSkipSeamless then
        get_hook_storage().this_ptr = args[2];
    end
end

hook(GUIPartsRewardItems_type_def:get_method("allReceive"), function(args)
    if config.autoSkipSeamless and (config.autoSellRewardsSeamless or config.autoSellArtianSeamless or config.autoSellJewelSeamless or config.autoSellAmuletSeamless) then
        local this_ptr = args[2];
        local MODE = get__Mode_method:call(this_ptr);
        if MODE == GUIPartsRewardItems_REWARD then
            if config.autoSellRewardsSeamless then
                local GUIRewardItems_list = GUIPartsRewardItems_get_RewardItems_method:call(this_ptr);
                for i = 0, GenericList_get_Count_method:call(GUIRewardItems_list) - 1 do
                    local GUIRewardItems = GenericList_get_Item_method:call(GUIRewardItems_list, i);
                    for j = 0, get_ItemInfoSize_method:call(GUIRewardItems) - 1 do
                        sellReward_method:call(getItemInfo_method:call(GUIRewardItems, j), true);
                    end
                end
                return SKIP_ORIGINAL;
            end
        elseif MODE == GUIPartsRewardItems_JUDGE then
            if config.autoSellArtianSeamless or config.autoSellJewelSeamless or config.autoSellAmuletSeamless then
                local GUIRewardItems_list = GUIPartsRewardItems_get_RewardItems_method:call(this_ptr);
                for i = 0, GenericList_get_Count_method:call(GUIRewardItems_list) - 1 do
                    local GUIRewardItems = GenericList_get_Item_method:call(GUIRewardItems_list, i);
                    for j = 0, get_ItemInfoSize_method:call(GUIRewardItems) - 1 do
                        local ItemInfo = getItemInfo_method:call(GUIRewardItems, j);
                        if get_ArtianPartsData_method:call(ItemInfo) ~= nil then
                            if config.autoSellArtianSeamless then
                                sellReward_method:call(ItemInfo, true);
                            else
                                getReward_method:call(ItemInfo, true, false);
                            end
                        elseif get_RandomAmuletData_method:call(ItemInfo) ~= nil then
                            if config.autoSellAmuletSeamless then
                                sellReward_method:call(ItemInfo, true);
                            else
                                getReward_method:call(ItemInfo, true, false);
                            end
                        else
                            local AccessoryId = get_AccessoryId_method:call(ItemInfo);
                            if AccessoryId > ACCESSORY_INVALID and AccessoryId < ACCESSORY_MAX then
                                if config.autoSellJewelSeamless then
                                    sellReward_method:call(ItemInfo, true);
                                else
                                    getReward_method:call(ItemInfo, false, false);
                                end
                            end
                        end
                    end
                end
                return SKIP_ORIGINAL;
            end
        end
    end
end);

hook(GUI020100_type_def:get_method("toQuestReward"), preHook, function()
    if config.autoSkipSeamless then
        local this_ptr = get_hook_storage().this_ptr;
        local GUI020100PanelQuestRewardItem = get__PartsQuestRewardItem_method:call(this_ptr);
        if config.openNew or config.openWish then
            local GUIPartsRewardItems = get__PartsQuestRewardItems_method:call(GUI020100PanelQuestRewardItem);
            if (config.openNew and hasNewItem(GUIPartsRewardItems_ItemGridParts_field:get_data(GUIPartsRewardItems), false))
            or (config.openWish and hasWishItem(GUIPartsRewardItems_get_RewardItems_method:call(GUIPartsRewardItems))) then
                requestCallTrigger_method:call(GUI020100_InputCtrl_field:get_data(this_ptr), JUST_TIMING_SHORTCUT);
            else
                finish_method:call(get_FixControl_method:call(GUI020100PanelQuestRewardItem));
            end
        else
            finish_method:call(get_FixControl_method:call(GUI020100PanelQuestRewardItem));
        end
    end
end);

hook(GUI020100_type_def:get_method("toQuestJudge"), preHook, function()
    if config.autoSkipSeamless then
        finish_method:call(get_FixControl_method:call(get__PartsQuestRewardItem_method:call(get_hook_storage().this_ptr)));
    end
end);

hook(GUI020100_type_def:get_method("toRandomAmuletJudge"), preHook, function()
    if config.autoSkipSeamless then
        local this_ptr = get_hook_storage().this_ptr;
        if config.autoSellAmuletSeamless == false and config.openAmuletJudgeBox then
            requestCallTrigger_method:call(GUI020100_InputCtrl_field:get_data(this_ptr), JUST_TIMING_SHORTCUT);
        else
            finish_method:call(get_FixControl_method:call(get__PartsQuestRewardItem_method:call(this_ptr)));
        end
    end
end);

hook(find_type_definition("app.cGUI020100PanelQuestResultList"):get_method("start"), nil, function()
    if config.autoSkipSeamless then
        terminateQuestResult_method:call(get_managed_singleton("app.GUIManager"));
    end
end);

hook(find_type_definition("app.cGUIQuestResultInfo"):get_method("getSeamlesResultListDispTime"), function()
    return config.autoSkipSeamless and SKIP_ORIGINAL or CALL_ORIGINAL;
end, function(retval)
    return config.autoSkipSeamless and ZERO_float_ptr or retval;
end);

hook(getReward_method, function(args)
    local this_ptr = args[2];
    local ArtianData = get_ArtianPartsData_method:call(this_ptr);
    local AccessoryId = get_AccessoryId_method:call(this_ptr);
    log.debug("This item is " .. get_RandomAmuletData_method:call(this_ptr) ~= nil and "RandomAmulet" or AccessoryId > ACCESSORY_INVALID and AccessoryId < ACCESSORY_MAX and "Jewel" or ArtianData ~= nil and get_IsEm0078_ArtianParts_method:call(ArtianData) and "Gogma Material" or "Artian part");
    log.debug("args3 : " .. tostring(to_int64(args[3]) & 1));
    log.debug("args4 : " .. tostring(to_int64(args[4]) & 1));
end);

re.on_config_save(saveConfig);

re.on_draw_ui(function()
    if tree_node("Skip Quest Rewards Report") then
		local changed, reqSave = false, false;
        if tree_node("Full-screen quest result options") then
            changed, config.enable = checkbox("Enable skip", config.enable);
            if changed and not reqSave then
                reqSave = true;
            end
            begin_disabled(not config.enable);
            changed, config.autoSellRewards = checkbox("Auto sell *ALL* Rewards", config.autoSellRewards);
            if changed and not reqSave then
                reqSave = true;
            end
            begin_disabled(config.autoSellRewards);
            changed, config.autoSellArtian = checkbox("Auto sell *ALL* Artian parts (Excluding Gogma materials)", config.autoSellArtian);
            if changed and not reqSave then
                reqSave = true;
            end
            changed, config.autoSellGogma = checkbox("Auto sell *ALL* Gogma materials", config.autoSellGogma);
            if changed and not reqSave then
                reqSave = true;
            end
            changed, config.autoSellJewel = checkbox("Auto sell *ALL* Decoration Jewels", config.autoSellJewel);
            if changed and not reqSave then
                reqSave = true;
            end
            changed, config.autoSellAmulet = checkbox("Auto sell *ALL* Appraised Talismans", config.autoSellAmulet);
            if changed and not reqSave then
                reqSave = true;
            end
            begin_disabled(config.autoSellAmulet);
            changed, config.enableSkipAmulet = checkbox("Enable skip for Appraised Talismans info", config.enableSkipAmulet);
            if changed and not reqSave then
                reqSave = true;
            end
            end_disabled();
            end_disabled();
            changed, config.haltNewItem = checkbox("Disable skip if new item is exist", config.haltNewItem);
            if changed and not reqSave then
                reqSave = true;
            end
            if is_item_hovered() then
                set_tooltip("If there is an item that you obtain for the first time as a quest reward, skipping is disabled.");
            end
            changed, config.showWish = checkbox("Disable skip if wishlist item is exist", config.showWish);
            if changed and not reqSave then
                reqSave = true;
            end
            if is_item_hovered() then
                set_tooltip("If receive a reward for an item registered on your wishlist, skipping is disabled.");
            end
            end_disabled();
            changed, config.autoCloseConfirm = checkbox("Auto-close confirmation dialog box", config.autoCloseConfirm);
            if changed and not reqSave then
                reqSave = true;
            end
            tree_pop();
        end
        if tree_node("Quest result notification options") then
            changed, config.autoSkipSeamless = checkbox("Enable skip", config.autoSkipSeamless);
            if changed and not reqSave then
                reqSave = true;
            end
            begin_disabled(not config.autoSkipSeamless);
            changed, config.autoSellRewardsSeamless = checkbox("Auto sell *ALL* Rewards", config.autoSellRewardsSeamless);
            if changed and not reqSave then
                reqSave = true;
            end
            begin_disabled(config.autoSellRewardsSeamless);
            changed, config.autoSellArtianSeamless = checkbox("Auto sell *ALL* Artian Parts", config.autoSellArtianSeamless);
            if changed and not reqSave then
                reqSave = true;
            end
            changed, config.autoSellJewelSeamless = checkbox("Auto sell *ALL* Decoration Jewels", config.autoSellJewelSeamless);
            if changed and not reqSave then
                reqSave = true;
            end
            changed, config.autoSellAmuletSeamless = checkbox("Auto sell *ALL* Appraised Talismans", config.autoSellAmuletSeamless);
            if changed and not reqSave then
                reqSave = true;
            end
            begin_disabled(config.autoSellAmuletSeamless);
            changed, config.openAmuletJudgeBox = checkbox("Auto-open details for Appraised Talismans", config.openAmuletJudgeBox);
            if changed and not reqSave then
                reqSave = true;
            end
            end_disabled();
            changed, config.openNew = checkbox("Auto-open datails for new items", config.openNew);
            if changed and not reqSave then
                reqSave = true;
            end
            changed, config.openWish = checkbox("Auto-open details for wishlist items", config.openWish);
            if changed and not reqSave then
                reqSave = true;
            end
            end_disabled();
            end_disabled();
            tree_pop();
        end
		if reqSave then
			saveConfig();
		end
		tree_pop();
	end
end);