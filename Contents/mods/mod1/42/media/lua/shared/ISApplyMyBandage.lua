local _player = nil
local _bodyparts = nil


local bodyParts_modData = {
    Hand_L = nil,
    Hand_R = nil,
    ForeArm_L = nil,
    ForeArm_R = nil,
    UpperArm_L = nil,
    UpperArm_R = nil,
    Torso_Upper = nil,
    Torso_Lower = nil,
    Head = nil,
    Neck = nil,
    Groin = nil,
    UpperLeg_L = nil,
    UpperLeg_R = nil,
    LowerLeg_L = nil,
    LowerLeg_R = nil,
    Foot_L = nil,
    Foot_R = nil,
}

Events.OnCreatePlayer.Add(function(playerNum,player)
    _player = player
    _bodyparts = _player:getBodyDamage():getBodyParts()

    for i=0, _bodyparts:size()-1 do
        local part = _bodyparts:get(i)
        local t = part:getModData()

        bodyParts_modData[tostring(part:getType())] = t
    end



end)


---@param t boolean
---@param bodyPart BodyPart
local function MySetBandaged(bodyPart,t)
    --if modData.
    local modData = bodyPart:getModData()

    --moddata初始化
    if not modData then modData = false end

    modData.IsMyBandaged = t

end


ISApplyMyBandage = ISApplyBandage:derive("ISApplyMyBandage")
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
    o.doctorLevel = 0
    
    -- 自定义属性
    o.maxTime = 200 -- 使用时间
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
    -- 动作开始时的逻辑
    if self.item then
        self.item:setJobType("Bandaging")
        self.item:setJobDelta(0.0)
    end
    
    -- 设置动画
        self:setActionAnim(CharacterActionAnims.Bandage)
        self:setAnimVariable("BandageType", ISHealthPanel.getBandageType(self.bodyPart))
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
    -- 完成动作时的逻辑
    if self.item then
        -- 使用绷带
        --MySetBandaged(self.bodyPart,true)
        -- 应用自定义效果

    else
        -- 移除绷带逻辑
        --MySetBandaged(self.bodyPart,false)
    end
    
    -- 完成动作
    ISBaseTimedAction.perform(self)
end

function ISApplyMyBandage:getDuration()
    -- 计算动作持续时间
    local duration = 200
    if self.doctorLevel > 0 then
        duration = duration - (self.doctorLevel * 10)
    end
    return duration
end


local og_ISHealthBodyPartListBox_doDrawItem = ISHealthBodyPartListBox.doDrawItem
function ISHealthBodyPartListBox:doDrawItem(y, item, alt)
    -- 调用原始函数并获取返回的y坐标
    y = og_ISHealthBodyPartListBox_doDrawItem(self, y, item, alt)

    ---@type BodyPart
    local bodyPart = item.item.bodyPart
    local bodyPartType = tostring(bodyPart:getType())


    if bodyParts_modData[bodyPartType] == false or nil then
        return y
    end

    
    -- 设置文本起始位置和样式
    local x = 15  -- 文本缩进
    y = y - 5     -- 微调y坐标
    local fontHgt = getTextManager():getFontHeight(UIFont.Small)
    
    -- 获取身体部位信息


    
    -- 添加自定义文本
    -- 示例：显示部位类型和一些状态
    -- if bodyPart:HasInjury() then
    --     self:drawText("- test1111", x, y, 0.89, 0.28, 0.28, 1, UIFont.Small)
    --     y = y + fontHgt
    -- end
    
    -- 添加更多自定义信息
    self:drawText("- test2222" .. tostring(bodyPartType), x, y, 0.28, 0.89, 0.28, 1, UIFont.Small)
    y = y + fontHgt
    
    -- 恢复y坐标的偏移
    y = y + 5
    return y
end