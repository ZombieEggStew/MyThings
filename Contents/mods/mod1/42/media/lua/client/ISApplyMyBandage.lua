local _player = nil
local _bodyparts = nil
local _playerModData = nil
DedaultBandageDuration = 25 -- 默认绷带持续时间
MyBandage_4_speed = 1 -- 绷带使用速度倍率

Events.OnCreatePlayer.Add(function(playerNum,player)
    _player = player
    _playerModData = _player:getModData()
    _bodyparts = _player:getBodyDamage():getBodyParts()

    if not _playerModData.MyBandageSystem then
        _playerModData.MyBandageSystem = {
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
    else
        for k, v in pairs(_playerModData.MyBandageSystem) do
            -- print("MyBandageSystem init ", k, v)


            if type(v) == "boolean" then
                _playerModData.MyBandageSystem[k] = {bandaged = v, timeLeft = 0}
            end
            
            print("MyBandageSystem init ", k, _playerModData.MyBandageSystem[k].bandaged, _playerModData.MyBandageSystem[k].timeLeft)
        end
    end


end)



---@param bodyPart BodyPart
---@param bandaged boolean
---@param duration number
function MySetBandaged(bodyPart, bandaged , duration)
    local bodyPartType = tostring(bodyPart:getType())
    
    -- 确保 ModData 存在
    if not _playerModData.MyBandageSystem then
        _playerModData.MyBandageSystem = {}
        print("no modData mybandagesystem")
    end
    
    -- 保存到 ModData
    if bandaged then
        _playerModData.MyBandageSystem[bodyPartType] = {
            bandaged = true,
            timeLeft = duration
        }
    else
        _playerModData.MyBandageSystem[bodyPartType] = {
            bandaged = false,
            timeLeft = 0
        }
    end

end


-- 设置绷带剩余时间
---@param bodyPart BodyPart
---@param timeLeft number
function MySetBandageTimeLeft(bodyPart, timeLeft)
    local bodyPartType = tostring(bodyPart:getType())
    
    if _playerModData.MyBandageSystem and _playerModData.MyBandageSystem[bodyPartType] then
        _playerModData.MyBandageSystem[bodyPartType].timeLeft = timeLeft
    end
end

-- 获取绷带状态和剩余时间
---@param bodyPart BodyPart
---@return number
function MyGetBandageTimeLeft(bodyPart)
    local bodyPartType = tostring(bodyPart:getType())
    
    if not _playerModData.MyBandageSystem or not _playerModData.MyBandageSystem[bodyPartType] then
        return  0
    end
    
    local data = _playerModData.MyBandageSystem[bodyPartType]
    return data.timeLeft
end


-- 添加一个获取状态的函数
---@param bodyPart BodyPart
---@return boolean
function IsMyBandaged(bodyPart)
    local bodyPartType = tostring(bodyPart:getType())
    
    if not _playerModData.MyBandageSystem or not _playerModData.MyBandageSystem[bodyPartType] then
        return  false
    end
    
    return _playerModData.MyBandageSystem[bodyPartType].bandaged
end

ISApplyMyBandage = ISBaseTimedAction:derive("ISApplyMyBandage")
function ISApplyMyBandage:new(character, otherPlayer, item, bodyPart, doIt)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    
    -- 基础属性设置
    o.character = character
    o.otherPlayer = otherPlayer
    o.item = item
    o.bodyPart = bodyPart
    o.doIt = doIt

    
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
    if not self.item then return true end -- 如果是移除绷带的动作
    return self.character:getInventory():contains(self.item)
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
    if self.item then
        -- 使用绷带时
        print(self.item:getType())


        local doctorLevel = self.character:getPerkLevel(Perks.Doctor)


        local duration_bandage = DedaultBandageDuration * (1 + doctorLevel * 0.1) -- 每级增加10%持续时间


        MySetBandaged(self.bodyPart, true , duration_bandage)
        self.character:getInventory():Remove(self.item)


    else
        -- 移除绷带时

       MySetBandaged(self.bodyPart, false , 0)
       self.character:getInventory():AddItem("Base.My_Bandaid_4")

    end

    self.character:setHideWeaponModel(false)
    ISBaseTimedAction.perform(self)
end

function ISApplyMyBandage:getDuration(doctorLevel)

    -- 计算动作持续时间
    local duration = 200 * (1 - doctorLevel * 0.05) -- 每级减少5%时间


    return duration
end




