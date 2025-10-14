local _player = nil
local _bodyparts = nil
local _playerModData = nil
CONFIG_DedaultBandage_4_Duration = 50 -- 默认绷带持续时间
CONFIG_DedaultBandage_5_Duration = 50 -- 默认绷带持续时间
CONFIG_DefaultBandage_4_ConsumptionRate = 1 -- 绷带消耗速度倍率
CONFIG_DefaultBandage_5_ConsumptionRate = 1 -- 绷带消耗速度倍率
local isPlayerCreated = false


CONFIG_my_bodyParts = {
    "Hand_L", "Hand_R", "ForeArm_L", "ForeArm_R", "UpperArm_L", "UpperArm_R",
    "Torso_Upper", "Torso_Lower", "Head", "Neck", "Groin",
    "UpperLeg_L", "UpperLeg_R", "LowerLeg_L", "LowerLeg_R", "Foot_L", "Foot_R"
}
CONFIG_my_bandageTypes = {
    My_Bandaid_3 = "My_Bandaid_3",
    My_Bandaid_4 = "My_Bandaid_4",
    My_Bandaid_5 = "My_Bandaid_5"
}
CONFIG_my_Base_bandageTypes = {
    My_Bandaid_3 = "Base.My_Bandaid_3",
    My_Bandaid_4 = "Base.My_Bandaid_4",
    My_Bandaid_5 = "Base.My_Bandaid_5"
}

local currentBodyPart = nil
local isApplying = false
local isRemoving = false
local bandagingProgress = 0


---@return boolean
---@param bodyPart BodyPart
function GetIsBodyPartBandaing(bodyPart)
    return bodyPart == currentBodyPart and isApplying
end

function GetIsRemoving()
    return isRemoving
end

---@return number
function GetBandagingProgress()
    return bandagingProgress
end

local function initMyBandageSystem()
    local system = {}

    for _, part in ipairs(CONFIG_my_bodyParts) do
        system[part] = {}
        for _, bandageType in pairs(CONFIG_my_bandageTypes) do
            system[part][bandageType] = {bandaged = false, timeLeft = 0}
        end
    end

    return system
end

Events.OnCreatePlayer.Add(function(playerNum,player)
    _player = player
    _playerModData = _player:getModData()
    -- _playerModData.MyBandageSystem = initMyBandageSystem()

    if not _playerModData.MyBandageSystem then
        _playerModData.MyBandageSystem = initMyBandageSystem()
    end

    -- for _, v in pairs(_playerModData.MyBandageSystem) do
    --     if type(v) == "table" and (v.bandaged ~= nil or v.timeLeft ~= nil) then
    --         _playerModData.MyBandageSystem = initMyBandageSystem()
    --         break
    --     end
    -- end
    isPlayerCreated = true
end)


---@param bodyPart BodyPart
---@param character IsoPlayer
---@param targetPlayer IsoPlayer
---@param itemType string
---@param isUseBandage boolean
function ApplyMyBandageAction(character, targetPlayer, bodyPart , itemType , isUseBandage)
    local action = ISApplyMyBandage:new(
        character,          -- 使用绷带的玩家
        targetPlayer,    -- 目标玩家
        itemType,     -- 绷带物品
        bodyPart,        -- 身体部位
        true,        -- 是否立即执行
        isUseBandage
    )
    
    -- 添加到动作队列
    if action:isValid() then
        ISTimedActionQueue.add(action)
    end
end

-- ---@param bodyPart BodyPart
-- ---@param character IsoPlayer
-- ---@param targetPlayer IsoPlayer
-- ---@param itemType string
-- ---@param isUseBandage boolean
-- function RemoveMyBandageAction(character, targetPlayer, bodyPart , itemType , isUseBandage)
--     local action = ISApplyMyBandage:new(
--         character,          -- 使用绷带的玩家
--         targetPlayer,    -- 目标玩家
--         itemType,     -- 绷带物品
--         bodyPart,        -- 身体部位
--         true,        -- 是否立即执行
--         isUseBandage
--     )
    
--     -- 添加到动作队列
--     if action:isValid() then
--         ISTimedActionQueue.add(action)
--     end
-- end



---@param playerObj IsoPlayer
---@param bandageType string -- no base
function RemoveMyBandageFromInv(playerObj , bandageType)
   playerObj:getInventory():Remove(bandageType)
end
---@param playerObj IsoPlayer
---@param bandageType string -- no base
function AddMyBandageToInv(playerObj , bandageType)
   playerObj:getInventory():AddItem(bandageType)
end

---@param playerObj IsoPlayer
---@return InventoryItem?
---@param bandageType string -- no base
function GetMyBandageFromInv(playerObj , bandageType)
    local plInv = playerObj:getInventory()
    local bandageItem = plInv:FindAndReturn("Base."..bandageType)

    return bandageItem
end



---@param bodyPart BodyPart
---@param bandaged boolean
---@param defaultDuration number
---@param bandageType string
---@param doctorLevel integer
function SetMyBandaged(bodyPart,bandageType, bandaged , doctorLevel)
    local bodyPartType = tostring(bodyPart:getType())
    if not _playerModData then
        print("no player moddata1")
        return
    end
    -- 确保 ModData 存在
    if not _playerModData.MyBandageSystem then
        _playerModData.MyBandageSystem = {}
        print("no modData mybandagesystem")
    end
    local defaultDuration = 0

    if bandageType == CONFIG_my_bandageTypes.My_Bandaid_4 then
        defaultDuration = CONFIG_DedaultBandage_4_Duration
    elseif bandageType == CONFIG_my_bandageTypes.My_Bandaid_5 then
        defaultDuration = CONFIG_DedaultBandage_5_Duration
    end

    local duration = defaultDuration * (1 + doctorLevel * 0.1)

    -- 保存到 ModData
    if bandaged then
        _playerModData.MyBandageSystem[bodyPartType][bandageType] = {
            bandaged = true,
            timeLeft = duration
        }
    else
        _playerModData.MyBandageSystem[bodyPartType][bandageType] = {
            bandaged = false,
            timeLeft = 0
        }
    end

end



-- 设置绷带剩余时间
---@param bodyPart BodyPart
---@param timeLeft number
---@param bandageType string
function SetMyBandageTimeLeft(bodyPart, bandageType,timeLeft)
    local bodyPartType = tostring(bodyPart:getType())
    if not _playerModData then
        print("no player moddata2")
        return
    end
    
    if _playerModData.MyBandageSystem and _playerModData.MyBandageSystem[bodyPartType] then
        _playerModData.MyBandageSystem[bodyPartType][bandageType].timeLeft = timeLeft
    end
end

-- 获取绷带状态和剩余时间
---@param bodyPart BodyPart
---@return number
---@param bandageType string
function GetMyBandageTimeLeft(bodyPart,bandageType)
    local bodyPartType = tostring(bodyPart:getType())

    if not _playerModData then
        print("no player moddata3")
        return 0
    end
    
    if not _playerModData.MyBandageSystem or not _playerModData.MyBandageSystem[bodyPartType] then
        return  0
    end
    
    return _playerModData.MyBandageSystem[bodyPartType][bandageType].timeLeft
end


-- 添加一个获取状态的函数
---@param bodyPart BodyPart
---@return boolean
---@param BandageType string
function IsMyBandaged(bodyPart,BandageType)
    local bodyPartType = tostring(bodyPart:getType())
    if not _playerModData then
        print("no player moddata4")
        return false
    end

    if not isPlayerCreated then
        print("error1")
        return false
    end
    
    if not _playerModData.MyBandageSystem then
        print("error2")
        return  false
    end

    if not _playerModData.MyBandageSystem[bodyPartType] then
        print("error3")
        return  false
    end
    
    return _playerModData.MyBandageSystem[bodyPartType][BandageType].bandaged
end



ISApplyMyBandage = ISBaseTimedAction:derive("ISApplyMyBandage")
function ISApplyMyBandage:new(character, otherPlayer, itemType, bodyPart, doIt , isUseBandage)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    
    -- 基础属性设置
    o.character = character
    o.otherPlayer = otherPlayer
    o.itemType = itemType
    o.item = character:getInventory():FindAndReturn(itemType)
    o.bodyPart = bodyPart
    o.doIt = doIt
    o.isUseBandage = isUseBandage


    local doctorLevel = character:getPerkLevel(Perks.Doctor)
    o.maxTime = self:getDuration(doctorLevel)

    o.stopOnWalk = false
    o.stopOnRun = true
    o.bandagedPlayerX = otherPlayer:getX()
    o.bandagedPlayerY = otherPlayer:getY()
    
    return o
end

function ISApplyMyBandage:isValid()
    -- 自定义验证逻辑
    if not self.isUseBandage then return true end -- 如果是移除绷带的动作

    local t = self.character:getInventory():contains(self.itemType)
    if not t then
        print("no bandage available")
    end
    return t
end

function ISApplyMyBandage:start()
    -- 动作开始时的逻辑
    self.character:setHideWeaponModel(true)

    currentBodyPart = self.bodyPart
    isApplying = true
    --使用时的物品栏绿色进度条
    if self.isUseBandage then
        self.item:setJobType("Bandaging")
        self.item:setJobDelta(0.0)
    else
        isRemoving = true
    end
    
    -- 设置动画
    self:setActionAnim(CharacterActionAnims.Bandage)
    self:setAnimVariable("BandageType", ISHealthPanel.getBandageType(self.bodyPart))
    self.sound = self.character:playSound("Bandage")  --TO DO 不生效 需修改
end

function ISApplyMyBandage:update()
    -- 更新进度
    if self.isUseBandage then
        self.item:setJobDelta(self:getJobDelta())

    end
    bandagingProgress = self:getJobDelta()
end

function ISApplyMyBandage:stop()
    -- 动作停止时的逻辑
    self.character:setHideWeaponModel(false)
    if self.item then
        self.item:setJobDelta(0.0)
    end

    isApplying = false
    isRemoving = false
    bandagingProgress = 0
    ISBaseTimedAction.stop(self)
end

function ISApplyMyBandage:perform()
    if self.isUseBandage then
        -- 使用绷带时
        print(self.itemType)
        local doctorLevel = self.character:getPerkLevel(Perks.Doctor)


        SetMyBandaged(self.bodyPart , self.itemType , true , doctorLevel)
        RemoveMyBandageFromInv(self.character , self.itemType )


    else
        -- 移除绷带时
        SetMyBandaged(self.bodyPart , self.itemType , false , 0 )
        -- AddMyBandageToInv(self.character , self.itemType )

    end

    isApplying = false
    isRemoving = false
    self.character:setHideWeaponModel(false)
    ISBaseTimedAction.perform(self)
end

function ISApplyMyBandage:getDuration(doctorLevel)

    -- 计算动作持续时间
    local duration = 200 * (1 - doctorLevel * 0.05) -- 每级减少5%时间


    return duration
end
