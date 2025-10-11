local _player = nil
local _bodyparts = nil
local _playerModData = nil
CONFIG_DedaultBandage_4_Duration = 50 -- 默认绷带持续时间
CONFIG_DedaultBandage_5_Duration = 50 -- 默认绷带持续时间
CONFIG_DefaultBandage_4_ConsumptionRate = 1 -- 绷带消耗速度倍率
CONFIG_DefaultBandage_5_ConsumptionRate = 1 -- 绷带消耗速度倍率
local isPlayerCreated = false

local CONFIG_MyBandageSystem_old = {
    Hand_L = {bandaged = false, timeLeft = 0},
    Hand_R = {bandaged = false, timeLeft = 0},
    ForeArm_L = {bandaged = false, timeLeft = 0},
    ForeArm_R = {bandaged = false, timeLeft = 0},
    UpperArm_L = {bandaged = false, timeLeft = 0},
    UpperArm_R = {bandaged = false, timeLeft = 0},
    Torso_Upper = {bandaged = false, timeLeft = 0},
    Torso_Lower = {bandaged = false, timeLeft = 0},
    Head = {bandaged = false, timeLeft = 0},
    Neck = {bandaged = false, timeLeft = 0},
    Groin = {bandaged = false, timeLeft = 0},
    UpperLeg_L = {bandaged = false, timeLeft = 0},
    UpperLeg_R = {bandaged = false, timeLeft = 0},
    LowerLeg_L = {bandaged = false, timeLeft = 0},
    LowerLeg_R = {bandaged = false, timeLeft = 0},
    Foot_L = {bandaged = false, timeLeft = 0},
    Foot_R = {bandaged = false, timeLeft = 0},
}
local CONFIG_MyBandageSystem = {
    Hand_L = {
        bandage_4 = {bandaged = false, timeLeft = 0},
        bandage_5 = {bandaged = false, timeLeft = 0}
    },
    Hand_R = {
        bandage_4 = {bandaged = false, timeLeft = 0},
        bandage_5 = {bandaged = false, timeLeft = 0}
    },
    ForeArm_L = {
        bandage_4 = {bandaged = false, timeLeft = 0},
        bandage_5 = {bandaged = false, timeLeft = 0}
    },
    ForeArm_R = {
        bandage_4 = {bandaged = false, timeLeft = 0},
        bandage_5 = {bandaged = false, timeLeft = 0}
    },
    UpperArm_L = {
        bandage_4 = {bandaged = false, timeLeft = 0},
        bandage_5 = {bandaged = false, timeLeft = 0}
    },
    UpperArm_R = {
        bandage_4 = {bandaged = false, timeLeft = 0},
        bandage_5 = {bandaged = false, timeLeft = 0}
    },
    Torso_Upper = {
        bandage_4 = {bandaged = false, timeLeft = 0},
        bandage_5 = {bandaged = false, timeLeft = 0}
    },
    Torso_Lower = {
        bandage_4 = {bandaged = false, timeLeft = 0},
        bandage_5 = {bandaged = false, timeLeft = 0}
    },
    Head = {
        bandage_4 = {bandaged = false, timeLeft = 0},
        bandage_5 = {bandaged = false, timeLeft = 0}
    },
    Neck = {
        bandage_4 = {bandaged = false, timeLeft = 0},
        bandage_5 = {bandaged = false, timeLeft = 0}
    },
    Groin = {
        bandage_4 = {bandaged = false, timeLeft = 0},
        bandage_5 = {bandaged = false, timeLeft = 0}
    },
    UpperLeg_L = {
        bandage_4 = {bandaged = false, timeLeft = 0},
        bandage_5 = {bandaged = false, timeLeft = 0}
    },
    UpperLeg_R = {
        bandage_4 = {bandaged = false, timeLeft = 0},
        bandage_5 = {bandaged = false, timeLeft = 0}
    },
    LowerLeg_L = {
        bandage_4 = {bandaged = false, timeLeft = 0},
        bandage_5 = {bandaged = false, timeLeft = 0}
    },
    LowerLeg_R = {
        bandage_4 = {bandaged = false, timeLeft = 0},
        bandage_5 = {bandaged = false, timeLeft = 0}
    },
    Foot_L = {
        bandage_4 ={bandaged = false, timeLeft = 0},
        bandage_5 = {bandaged = false, timeLeft = 0}
    },
    Foot_R = {
        bandage_4 = {bandaged = false, timeLeft = 0},
        bandage_5 = {bandaged = false, timeLeft = 0}
    }
}

CONFIG_my_bodyParts = {
    "Hand_L", "Hand_R", "ForeArm_L", "ForeArm_R", "UpperArm_L", "UpperArm_R",
    "Torso_Upper", "Torso_Lower", "Head", "Neck", "Groin",
    "UpperLeg_L", "UpperLeg_R", "LowerLeg_L", "LowerLeg_R", "Foot_L", "Foot_R"
}
CONFIG_my_bandageTypes = {
    My_Bandaid_4 = "My_Bandaid_4",
    My_Bandaid_5 = "My_Bandaid_5"
}
CONFIG_my_Base_bandageTypes = {
    My_Bandaid_4 = "Base.My_Bandaid_4",
    My_Bandaid_5 = "Base.My_Bandaid_5"
}

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

    if not _playerModData.MyBandageSystem then
        _playerModData.MyBandageSystem = initMyBandageSystem()
        return
    end

    for _, v in pairs(_playerModData.MyBandageSystem) do
        if type(v) == "table" and (v.bandaged ~= nil or v.timeLeft ~= nil) then
            _playerModData.MyBandageSystem = initMyBandageSystem()
            break
        end
        
    end
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
   playerObj:getInventory():Remove("Base."..bandageType)
end
---@param playerObj IsoPlayer
---@param bandageType string -- no base
function AddMyBandageToInv(playerObj , bandageType)
   playerObj:getInventory():AddItem("Base."..bandageType)
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
    self.character:setHideWeaponModel(true)
    -- 动作开始时的逻辑
    if self.item then
        self.item:setJobType("Bandaging")
        self.item:setJobDelta(0.0)
    end
    
    -- 设置动画
    self:setActionAnim(CharacterActionAnims.Bandage)
    self:setAnimVariable("BandageType", ISHealthPanel.getBandageType(self.bodyPart))
    self.sound = self.character:playSound("Bandage")
end

function ISApplyMyBandage:update()
    -- 更新进度
    if self.item then
        self.item:setJobDelta(self:getJobDelta())
    end
    
end

function ISApplyMyBandage:stop()
    -- 动作停止时的逻辑
    if self.item then
        self.item:setJobDelta(0.0)
    end
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
        -- AddMyBandageToInv(self.character , self.itemType ) --不返还

    end

    self.character:setHideWeaponModel(false)
    ISBaseTimedAction.perform(self)
end

function ISApplyMyBandage:getDuration(doctorLevel)

    -- 计算动作持续时间
    local duration = 200 * (1 - doctorLevel * 0.05) -- 每级减少5%时间


    return duration
end




