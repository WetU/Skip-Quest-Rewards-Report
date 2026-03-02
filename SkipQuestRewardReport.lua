local _G = _G;

local type = _G.type;

local sdk = _G.sdk;
local find_type_definition = sdk.find_type_definition;
local get_managed_singleton = sdk.get_managed_singleton;
local set_native_field = sdk.set_native_field;
local hook = sdk.hook;
local to_int64 = sdk.to_int64;

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

local config = load_file("SkipQuestRewardReport.json") or {enable = true, autoSellRewards = false, autoSellArtian = false, autoSellJewel = false, haltNewItem = true, autoCloseConfirm = true, enableSkipAmulet = false, autoSellAmulet = false, autoSkipSeamless = true, openAmuletJudgeBox = false};
if config.enable == nil or type(config.enable) ~= "boolean" then
    config.enable = true;
end
if config.autoSellRewards == nil or type(config.autoSellRewards) ~= "boolean" then
    config.autoSellRewards = false;
end
if config.autoSellArtian == nil or type(config.autoSellArtian) ~= "boolean" then
    config.autoSellArtian = false;
end
if config.autoSellJewel == nil or type(config.autoSellJewel) ~= "boolean" then
    config.autoSellJewel = false;
end
if config.haltNewItem == nil or type(config.haltNewItem) ~= "boolean" then
    config.haltNewItem = true;
end
if config.autoCloseConfirm == nil or type(config.autoCloseConfirm) ~= "boolean" then
    config.autoCloseConfirm = true;
end
if config.enableSkipAmulet == nil or type(config.enableSkipAmulet) ~= "boolean" then
    config.enableSkipAmulet = false;
end
if config.autoSellAmulet == nil or type(config.autoSellAmulet) ~= "boolean" then
    config.autoSellAmulet = false;
end
if config.autoSkipSeamless == nil or type(config.autoSkipSeamless) ~= "boolean" then
    config.autoSkipSeamless = true;
end
if config.openAmuletJudgeBox == nil or type(config.openAmuletJudgeBox) ~= "boolean" then
    config.openAmuletJudgeBox = false;
end

local function saveConfig()
    dump_file("SkipQuestRewardReport.json", config);
end
--<< GUI070000 Fix Quest Result >>--
local UI070000 = find_type_definition("app.GUIID.ID"):get_field("UI070000"):get_data(nil);

local GUI070000_type_def = find_type_definition("app.GUI070000");
local get_IDInt_method = GUI070000_type_def:get_method("get_IDInt");

local GUIPartsReward_type_def = find_type_definition("app.cGUIPartsReward");
local get__Info_method = GUIPartsReward_type_def:get_method("get__Info");
local set__WaitAnimationTime_method = GUIPartsReward_type_def:get_method("set__WaitAnimationTime(System.Single)");
local set__WaitControlTime_method = GUIPartsReward_type_def:get_method("set__WaitControlTime(System.Single)");
local receiveAll_method = GUIPartsReward_type_def:get_method("receiveAll");
local sellAll_method = GUIPartsReward_type_def:get_method("sellAll");
local get_Owner_method = GUIPartsReward_type_def:get_method("get_Owner");
local ItemGridParts_field = GUIPartsReward_type_def:get_field("_ItemGridParts");
local GUIPartsReward_InputCtrl_field = GUIPartsReward_type_def:get_field("_InputCtrl");

local JUDGE = find_type_definition("app.cGUIPartsReward.MODE"):get_field("JUDGE"):get_data(nil);

local get_RewardItems_method = get__Info_method:get_return_type():get_method("get_RewardItems");

local RewardItems_get_Item_method = get_RewardItems_method:get_return_type():get_method("get_Item(System.Int32)");

local getItemInfo_method = RewardItems_get_Item_method:get_return_type():get_method("getItemInfo(System.Int32)");

local SendItemInfo_type_def = getItemInfo_method:get_return_type();
local get_ArtianPartsData_method = SendItemInfo_type_def:get_method("get_ArtianPartsData");
local get_AccessoryId_method = SendItemInfo_type_def:get_method("get_AccessoryId");

local ItemGridParts_type_def = ItemGridParts_field:get_type();
local ItemGridParts_get_Count_method = ItemGridParts_type_def:get_method("get_Count");
local ItemGridParts_get_Item_method = ItemGridParts_type_def:get_method("get_Item(System.Int32)");

local GUIItemGridPartsFluent_type_def = ItemGridParts_get_Item_method:get_return_type();
local get_SelectItem_method = GUIItemGridPartsFluent_type_def:get_method("get_SelectItem");
local get__PanelNewMark_method = GUIItemGridPartsFluent_type_def:get_method("get__PanelNewMark");

local get_Enabled_method = get_SelectItem_method:get_return_type():get_method("get_Enabled");

local get_ActualVisible_method = get__PanelNewMark_method:get_return_type():get_method("get_ActualVisible");

local InputCtrl_type_def = GUIPartsReward_InputCtrl_field:get_type();
local get_InputPriority_method = InputCtrl_type_def:get_method("get_InputPriority");
local requestCallTrigger_method = InputCtrl_type_def:get_method("requestCallTrigger(app.GUIFunc.TYPE)");

local GUI070001_type_def = find_type_definition("app.GUI070001");
local get_IsViewMode_method = GUI070001_type_def:get_method("get_IsViewMode");
local skipAnimation_method = GUI070001_type_def:get_method("skipAnimation");

local shouldSellConfirm = false;

local function GUIPartsReward_getMode(mode_ptr, isRandomAmulet_ptr)
    local mode = to_int64(mode_ptr) & 0xFFFFFFFF;
    if mode == JUDGE and (to_int64(isRandomAmulet_ptr) & 1) == 1 then
        mode = 2;
    end
    return mode;
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
            local storage = get_hook_storage();
            storage.this_ptr = this_ptr;
            storage.Mode = GUIPartsReward_getMode(args[4], args[6]);
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
        if Mode ~= 2 then
            if config.haltNewItem then
                local ItemGridParts = ItemGridParts_field:get_data(this_ptr);
                for i = 0, ItemGridParts_get_Count_method:call(ItemGridParts) - 1 do
                    local GUIItemGridPartsFluent = ItemGridParts_get_Item_method:call(ItemGridParts, i);
                    if get_Enabled_method:call(get_SelectItem_method:call(GUIItemGridPartsFluent)) and get_ActualVisible_method:call(get__PanelNewMark_method:call(GUIItemGridPartsFluent)) then
                        if Mode == JUDGE then
                            set__WaitAnimationTime_method:call(this_ptr, 0.01);
                        end
                        return;
                    end
                end
            end
            if get_InputPriority_method:call(GUIPartsReward_InputCtrl_field:get_data(this_ptr)) == 0 then
                if Mode == JUDGE then
                    local autoSellCategory = 0;
                    if config.autoSellArtian then
                        autoSellCategory = autoSellCategory + 1;
                    end
                    if config.autoSellJewel then
                        autoSellCategory = autoSellCategory + 2;
                    end
                    if autoSellCategory == 3 then
                        auto_sell(this_ptr);
                        return;
                    elseif autoSellCategory > 0 then
                        local SendItemInfo = getItemInfo_method:call(RewardItems_get_Item_method:call(get_RewardItems_method:call(get__Info_method:call(this_ptr)), 0), 0);
                        if autoSellCategory == 1 then
                            if get_ArtianPartsData_method:call(SendItemInfo) ~= nil then
                                auto_sell(this_ptr);
                                return;
                            end
                        elseif get_AccessoryId_method:call(SendItemInfo) ~= nil then
                            auto_sell(this_ptr);
                            return;
                        end
                    end
                    receiveAll_method:call(this_ptr);
                else
                    if config.autoSellRewards then
                        auto_sell(this_ptr);
                    else
                        receiveAll_method:call(this_ptr);
                    end
                end
            end
        else
            if config.enableSkipAmulet then
                if get_InputPriority_method:call(GUIPartsReward_InputCtrl_field:get_data(this_ptr)) == 0 then
                    if config.autoSellAmulet then
                        auto_sell(this_ptr);
                    else
                        receiveAll_method:call(this_ptr);
                    end
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

local get_FixControl_method = get__PartsQuestRewardItem_method:get_return_type():get_parent_type():get_parent_type():get_method("get_FixControl");

local finish_method = get_FixControl_method:get_return_type():get_method("finish");

local terminateQuestResult_method = find_type_definition("app.GUIManager"):get_method("terminateQuestResult");

local JUST_TIMING_SHORTCUT = find_type_definition("app.GUIFunc.TYPE"):get_field("JUST_TIMING_SHORTCUT"):get_data(nil);

local SMALL_float_ptr = sdk.float_to_ptr(0.0);

local function preHook(args)
    if config.autoSkipSeamless then
        get_hook_storage().this_ptr = args[2];
    end
end

local function postHook_SeamlessReward()
    if config.autoSkipSeamless then
        finish_method:call(get_FixControl_method:call(get__PartsQuestRewardItem_method:call(get_hook_storage().this_ptr)));
    end
end

hook(GUI020100_type_def:get_method("toQuestReward"), preHook, postHook_SeamlessReward);

hook(GUI020100_type_def:get_method("toQuestJudge"), preHook, postHook_SeamlessReward);

hook(GUI020100_type_def:get_method("toRandomAmuletJudge"), preHook, function()
    if config.autoSkipSeamless then
        local this_ptr = get_hook_storage().this_ptr;
        if config.openAmuletJudgeBox then
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

hook(find_type_definition("app.cGUIQuestResultInfo"):get_method("getSeamlesResultListDispTime"), nil, function(retval)
    return config.autoSkipSeamless and SMALL_float_ptr or retval;
end);

re.on_config_save(saveConfig);

re.on_draw_ui(function()
    if tree_node("Skip Quest Rewards Report") then
		local changed = false;
        local reqSave = false;
        if tree_node("Full-screen quest result options") then
            changed, config.enable = checkbox("Enable skip", config.enable);
            if changed and not reqSave then
                reqSave = true;
            end
            begin_disabled(config.enable == false);
            changed, config.autoSellRewards = checkbox("Auto sell *ALL* Rewards", config.autoSellRewards);
            if changed and not reqSave then
                reqSave = true;
            end
            if config.autoSellRewards ~= true then
                changed, config.autoSellArtian = checkbox("Auto sell *ALL* Artian parts", config.autoSellArtian);
                if changed and not reqSave then
                    reqSave = true;
                end
                changed, config.autoSellJewel = checkbox("Auto sell *ALL* decoration jewels", config.autoSellJewel);
                if changed and not reqSave then
                    reqSave = true;
                end
            end
            changed, config.enableSkipAmulet = checkbox("Enable skip for Appraised Talismans info", config.enableSkipAmulet);
            if changed and not reqSave then
                reqSave = true;
            end
            if config.autoSellRewards ~= true and config.enableSkipAmulet then
                changed, config.autoSellAmulet = checkbox("Auto sell *ALL* Appraised Talismans", config.autoSellAmulet);
                if changed and not reqSave then
                    reqSave = true;
                end
            end
            changed, config.haltNewItem = checkbox("Disable skip when new item is exist", config.haltNewItem);
            if changed and not reqSave then
                reqSave = true;
            end
            if is_item_hovered() then
                set_tooltip("If there is an item that you obtain for the first time as a quest reward, skipping is disabled.");
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
            changed, config.openAmuletJudgeBox = checkbox("Auto-open details for Appraised Talismans", config.openAmuletJudgeBox);
            if changed and not reqSave then
                reqSave = true;
            end
            tree_pop();
        end
		if reqSave then
			saveConfig();
		end
		tree_pop();
	end
end);