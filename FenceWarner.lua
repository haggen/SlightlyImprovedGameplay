-- Slightly Improved™ Gameplay 1.1.0 (Feb 15 2016)
-- Licensed under CC BY-NC-SA 4.0

local FenceWarner = ZO_Object:Subclass()

local AUTO_WARN_WAIT_TIME = 60 * 10
local TRIGGERED_WARN_WAIT_TIME = 60 * 10

function FenceWarner:New()
    local warner = ZO_Object.New(self)
    warner:Initialize()
    return warner
end

function FenceWarner:Initialize()
    self.lastWarning = nil

    local function OnInventoryFullUpdate()
        if self:ShouldWarn(TRIGGERED_WARN_WAIT_TIME) then
            self:Warn()
        end
    end
    EVENT_MANAGER:RegisterForEvent("FenceWarner", EVENT_INVENTORY_FULL_UPDATE, OnInventoryFullUpdate)

    local function OnInventorySingleSlotUpdate(eventCode, bagId, slotId)
        if (bagId == BAG_BACKPACK) and self:ShouldWarn(TRIGGERED_WARN_WAIT_TIME) then
            self:Warn()
        end
    end
    EVENT_MANAGER:RegisterForEvent("FenceWarner", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventorySingleSlotUpdate)

    local function OnUpdate()
        if self:ShouldWarn(AUTO_WARN_WAIT_TIME) then
            self:Warn()
        end
    end
    EVENT_MANAGER:RegisterForUpdate("FenceWarner", 60 * 1000, OnUpdate)
end

function FenceWarner:ShouldWarn(waitTime)
    local shouldWarn = AreAnyItemsStolen(BAG_BACKPACK)
    local notInCombat = not IsUnitInCombat("player")
    local waitTimeElapsed = (not self.lastWarning or self.lastWarning + waitTime < GetFrameTimeSeconds())
    local notInPvp = not IsPlayerInAvAWorld()

    return self:IsEnabled() and shouldWarn and notInCombat and waitTimeElapsed and notInPvp
end

function FenceWarner:Warn(waitTime)
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.FENCE_ITEM_LAUNDERED, SI_HAS_STOLEN_ITEM)
    self.lastWarning = GetFrameTimeSeconds()
end

CALLBACK_MANAGER:RegisterCallback("SlightlyImprovedGameplay_OnAddOnLoaded", function(savedVars)
    function FenceWarner:IsEnabled()
        return savedVars.settings.isFenceWarnerEnabled
    end

    FENCE_WARNER = FenceWarner:New()
end)
