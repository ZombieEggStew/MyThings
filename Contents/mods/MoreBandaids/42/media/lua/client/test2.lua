require "ISApplyMyBandage"

local myPlayerHandler = {}
myPlayerHandler.__index = myPlayerHandler

local MY_BANDAGE_1_TYPE = "My_Bandaid_1"
local MY_BANDAGE_1_TYPE_BASE = "Base.My_Bandaid_1"

local MY_BANDAGE_2_TYPE = "My_Bandaid_2"
local MY_BANDAGE_2_TYPE_BASE = "Base.My_Bandaid_2"

local MY_BANDAGE_3_TYPE = "My_Bandaid_3"
local MY_BANDAGE_3_TYPE_BASE = "Base.My_Bandaid_3"


local playerHandler = nil

function myPlayerHandler:new(playerNum , playerObj)
    local o = {}
    setmetatable(o, self)

    if not playerObj then
        print("no playerObj")
        return nil
    end

    o.index = playerNum

    o.playerObj = playerObj

    o.bodyDamage = playerObj:getBodyDamage()

    if not o.bodyDamage then
        print("no bodyDamage")
        return nil
    end

    o.bodyParts = o.bodyDamage:getBodyParts()

    if not o.bodyParts then
        print("no bodyParts")
        return nil
    end

    o.stats = playerObj:getStats()

    if not o.stats then
        print("no stats")
        return nil
    end

    return o
end


-- function myPlayerHandler:checkMyBandaidOnBodyPart(bodyPart)
--     if not bodyPart then return end

--     -- 检查是否有绷带
--     if bodyPart:bandaged() then
--         -- 获取绷带类型
--         local bandageType = bodyPart:getBandageType()
--         -- 检查是否是我的绷带
--         for _, myBandageType in ipairs(MY_BANDAGE_TYPES_BASE) do
--             if bandageType == myBandageType then
--                 return true
--             end
--         end
--     end
--     return false
-- end


local test___ = ISApplyBandage.complete
function ISApplyBandage:complete()
    test___(self)

    local bandage = self.item


    -- 移除绷带
    if not bandage then
        print("Bandage removal completed")
        self.bodyPart:setPlantainFactor(0.0)

        return
    end

    -- bandage_1
    if bandage:getType() == MY_BANDAGE_1_TYPE then
        print("MyBandaid_1")
        --local t = self.bodyPart:getPlantainFactor()

        local t2 = self.bodyPart:getBandageLife()

        self.bodyPart:setPlantainFactor(t2 * 10)



    end

    -- --bandage_2
    -- if bandage:getType() == MY_BANDAGE_2_TYPE then

    --     print("MyBandaid_2")

    -- end

    -- print("Bandage applied")
    
end


-- everyMinute
local function playerCheck()
    if not playerHandler then return end
    if not playerHandler.bodyParts then return end


    for i=0, playerHandler.bodyParts:size()-1 do


        local bodyPart = playerHandler.bodyParts:get(i)
        print(tostring(bodyPart:getType()) .. tostring(bodyPart:getBandageType()) .. tostring(bodyPart:bandaged()))

        -- 加快烧伤恢复
        -- if bodyPart:isBurnt() then
        --     local t = bodyPart:getBurnTime()
        --     print(t)

        --     if bodyPart:getBandageType() == MY_BANDAGE_2_TYPE_BASE and t > 0 then
        --         bodyPart:setBurnTime(math.max(0,t - .05))
        --     end
        -- end

        local t = bodyPart:getStitchTime()

        if bodyPart:stitched() then


            if bodyPart:getBandageType() == MY_BANDAGE_2_TYPE_BASE and t < 50 then
                bodyPart:setStitchTime(math.min(50,t + 1))
            end
        end

    end
end


--TO DO 为是否减低恐慌添加沙盒设置
--everySecond
local function playerCheck_2()
    if not playerHandler then return end
    if not playerHandler.bodyParts then return end

    local fatigue = playerHandler.stats:getFatigue()  --疲惫 0-1
    -- print("fatigue is "..fatigue)

    local endurance = playerHandler.stats:getEndurance() -- 耐力 0-1
    -- print("endurance is "..endurance)

    local panic = playerHandler.stats:getPanic() --恐慌 0-100  
    -- print("panic is "..panic)



    for i=0, playerHandler.bodyParts:size()-1 do
        local bodyPart = playerHandler.bodyParts:get(i)

        local bandageType__ = bodyPart:getBandageType()
        

        local isBandage_4 = IsMyBandaged(bodyPart ,CONFIG_my_bandageTypes.My_Bandaid_4)
        local isBandage_5 = IsMyBandaged(bodyPart ,CONFIG_my_bandageTypes.My_Bandaid_5)

        -- if (not isBandage_4) and (not isBandage_5) then
        --     return
        -- end


        if  bodyPart:bandaged() and bandageType__ == MY_BANDAGE_2_TYPE_BASE then 
            local t = bodyPart:getStitchTime()
            print(tostring(bodyPart:getType()) .. t)
            if t > 0 and t < 50 then

                bodyPart:setStitchTime(math.min(50,t + .025))
            end
        end


        local stiffness = bodyPart:getStiffness()
        -- print(bodyPart:getType())
        -- print("stiffness is "..stiffness)

        if stiffness > 0 and isBandage_4 then
            local newConsumptionRate = CONFIG_DefaultBandage_4_ConsumptionRate * (1 + playerHandler.playerObj:getPerkLevel(Perks.Doctor) * 0.1) --每级医疗增加10%消耗速度
            -- print("newConsumptionRate is "..newConsumptionRate)
            local newStiffness = math.max(0 , stiffness - newConsumptionRate)
            bodyPart:setStiffness(newStiffness)

            local timeLeft = GetMyBandageTimeLeft(bodyPart , CONFIG_my_bandageTypes.My_Bandaid_4)
            local newTimeLeft =math.max(0, timeLeft - (stiffness - newStiffness))

            SetMyBandageTimeLeft(bodyPart, CONFIG_my_bandageTypes.My_Bandaid_4,newTimeLeft)
            if newTimeLeft == 0 then
                SetMyBandaged(bodyPart, CONFIG_my_bandageTypes.My_Bandaid_4,false , 0 )
            end
        end

        if isBandage_5 then
            local newConsumptionRate = CONFIG_DefaultBandage_5_ConsumptionRate * (1 + playerHandler.playerObj:getPerkLevel(Perks.Doctor) * 0.1) --每级医疗增加10%消耗速度
            

            local stress2 = playerHandler.stats:getStressFromCigarettes() --压力 0-1 
            local stress = playerHandler.stats:getStress() - stress2 --压力 0-1 太阴险了set和get到的不是一个东西
            print("stress is "..stress)
            print("stress2 is "..stress2)


            local unhappyness = playerHandler.bodyDamage:getUnhappynessLevel() -- 不开心 0-100
            -- print("unhappyness is "..unhappyness)

            local boardness = playerHandler.bodyDamage:getBoredomLevel() -- 无聊 0-100


            local newUnhappyness = math.max(0 , unhappyness - newConsumptionRate) -- 不开心 - 1~2 
            playerHandler.bodyDamage:setUnhappynessLevel(newUnhappyness) 

            local newStress = math.max(0 , stress - newConsumptionRate * .01 )--压力  -.01~.02
            playerHandler.stats:setStress(newStress)

            local newStress2 = math.max(0 , stress2 - (newConsumptionRate * .01 - (stress - newStress)))--压力  先减少普通压力，减到0之后减少抽烟压力
            playerHandler.stats:setStressFromCigarettes(newStress2)

            local newBoardness = math.max(0 , boardness - newConsumptionRate) -- 无聊  - 1~2
            playerHandler.bodyDamage:setBoredomLevel(newBoardness)


            local timeLeft = GetMyBandageTimeLeft(bodyPart , CONFIG_my_bandageTypes.My_Bandaid_5)
            local newTimeLeft = timeLeft - 1

            SetMyBandageTimeLeft(bodyPart, CONFIG_my_bandageTypes.My_Bandaid_5 , newTimeLeft)
            if newTimeLeft == 0 then
                SetMyBandaged(bodyPart, CONFIG_my_bandageTypes.My_Bandaid_5,false , 0 )
            end

        end
    end
end


-- TO DO 撕下创可贴无法返还
local og_ISHealthPanel_doBodyPartContextMenu = ISHealthPanel.doBodyPartContextMenu
function ISHealthPanel:doBodyPartContextMenu(bodyPart, x, y)
    og_ISHealthPanel_doBodyPartContextMenu(self, bodyPart, x, y)

    if not playerHandler then
        print("no playerHandler")
        return
    end
    if not playerHandler.playerObj then
        print("no playerObj")
        return
    end

    local isBandage_3 = IsMyBandaged(bodyPart ,CONFIG_my_bandageTypes.My_Bandaid_3)
    local isBandage_4 = IsMyBandaged(bodyPart ,CONFIG_my_bandageTypes.My_Bandaid_4)
    local isBandage_5 = IsMyBandaged(bodyPart ,CONFIG_my_bandageTypes.My_Bandaid_5)
    local haveBandage_3 = playerHandler.playerObj:getInventory():contains(CONFIG_my_bandageTypes.My_Bandaid_3)
    local haveBandage_4 = playerHandler.playerObj:getInventory():contains(CONFIG_my_bandageTypes.My_Bandaid_4)
    local haveBandage_5 = playerHandler.playerObj:getInventory():contains(CONFIG_my_bandageTypes.My_Bandaid_5)

    local playerNum = self.otherPlayer and self.otherPlayer:getPlayerNum() or self.character:getPlayerNum()

    local context = getPlayerContextMenu(playerNum)

    if not context then
        print("no context")
        return
    end

    context:bringToTop()
    context:setVisible(true)




    -- remove bandage4
    if isBandage_4 then
        local removeBandage_4_option = context:addOption(getText("IGUI_RemoveMyBandage_4"), nil, function()
            print("Remove My Bandage clicked")

            ApplyMyBandageAction(self.character, self.otherPlayer or self.character, bodyPart, CONFIG_my_bandageTypes.My_Bandaid_4 , false)
        end)
        removeBandage_4_option.iconTexture = getTexture("media/textures/item_MyBandaid4.png")
    else
    -- apply bandage4
        if  haveBandage_4 then
            local applyBandage_4_option = context:addOption(getText("IGUI_UseMyBandage_4"),nil,function ()

                print("Use My Bandage clicked")
                ApplyMyBandageAction(self.character, self.otherPlayer or self.character, bodyPart, CONFIG_my_bandageTypes.My_Bandaid_4 ,true)
            end)

            applyBandage_4_option.iconTexture = getTexture("media/textures/item_MyBandaid4.png")
        end 
    end

    -- remove bandage5
    if isBandage_5 then
        local removeBandage_5_option = context:addOption(getText("IGUI_RemoveMyBandage_5"), nil, function()
            print("Remove My Bandage clicked")

            ApplyMyBandageAction(self.character, self.otherPlayer or self.character, bodyPart, CONFIG_my_bandageTypes.My_Bandaid_5 , false)
        end)
        removeBandage_5_option.iconTexture = getTexture("media/textures/item_MyBandaid5.png")
    else
    -- apply bandage5
        if  haveBandage_5 then
            local applyBandage_5_option = context:addOption(getText("IGUI_UseMyBandage_5"),nil,function ()

                print("Use My Bandage clicked")
                ApplyMyBandageAction(self.character, self.otherPlayer or self.character, bodyPart, CONFIG_my_bandageTypes.My_Bandaid_5 ,true)
            end)

            applyBandage_5_option.iconTexture = getTexture("media/textures/item_MyBandaid5.png")
        end 
    end


    -- remove bandage3
    if isBandage_3 then
        local removeBandage_3_option = context:addOption(getText("IGUI_RemoveMyBandage_3"), nil, function()
            print("Remove My Bandage clicked")

            ApplyMyBandageAction(self.character, self.otherPlayer or self.character, bodyPart, CONFIG_my_bandageTypes.My_Bandaid_3 , false)
        end)
        removeBandage_3_option.iconTexture = getTexture("media/textures/item_MyBandaid3.png")
    else
    -- apply bandage3
        if  haveBandage_3 then
            local applyBandage_3_option = context:addOption(getText("IGUI_UseMyBandage_3"),nil,function ()

                print("Use My Bandage clicked")
                ApplyMyBandageAction(self.character, self.otherPlayer or self.character, bodyPart, CONFIG_my_bandageTypes.My_Bandaid_3 ,true)
            end)

            applyBandage_3_option.iconTexture = getTexture("media/textures/item_MyBandaid3.png")
        end 
    end


end

-- TO DO 实现进度条显示
local og_ISHealthBodyPartListBox_doDrawItem = ISHealthBodyPartListBox.doDrawItem
function ISHealthBodyPartListBox:doDrawItem(y, item, alt)
    -- 调用原始函数并获取返回的y坐标
    y = og_ISHealthBodyPartListBox_doDrawItem(self, y, item, alt)
    
    -- 设置文本起始位置和样式
    local x = 15  -- 文本缩进
    y = y - 5     -- 微调y坐标
    local fontHgt = getTextManager():getFontHeight(UIFont.Small)

    local progressBarWidth = 150
    local progressBarHight = 25
    local progressBarTextMargin_Left = 5
    local textMargin_Bottom = 5

    local isBandage_3 = IsMyBandaged(item.item.bodyPart ,CONFIG_my_bandageTypes.My_Bandaid_3)
    local isBandage_4 = IsMyBandaged(item.item.bodyPart ,CONFIG_my_bandageTypes.My_Bandaid_4)
    local isBandage_5 = IsMyBandaged(item.item.bodyPart ,CONFIG_my_bandageTypes.My_Bandaid_5)
    
    -- 获取身体部位信息
    -- ---@type BodyPart
    -- local bodyPart = item.item.bodyPart
    -- local bodyPartType = bodyPart:getType()

    if GetIsBodyPartBandaing(item.item.bodyPart) then
        self:drawRect(x, y, progressBarWidth , progressBarHight, .9, .15, .15, .15)
        self:drawRect(x, y, progressBarWidth * GetBandagingProgress(), progressBarHight, .9 ,.35, .35, .35)
        if GetIsRemoving() then
            self:drawText(getText("IGUI_Removing"), x + progressBarTextMargin_Left, y, .8, .8, .8, 1, UIFont.Small)
        else
            self:drawText(getText("IGUI_Bandaging"), x + progressBarTextMargin_Left, y, .8, .8, .8, 1, UIFont.Small)
        end
        y = y + progressBarHight
    end



    if isBandage_4 then
        self:drawText(getText("IGUI_Bandaged_4") .. " : " .. GetMyBandageTimeLeft(item.item.bodyPart , CONFIG_my_bandageTypes.My_Bandaid_4), x, y, 0.28, 0.89, 0.28, 1, UIFont.Small)
        y = y + fontHgt + textMargin_Bottom
    end

    if isBandage_5 then
        self:drawText(getText("IGUI_Bandaged_5") .." : ".. GetMyBandageTimeLeft(item.item.bodyPart , CONFIG_my_bandageTypes.My_Bandaid_5), x, y, 0.28, 0.89, 0.28, 1, UIFont.Small)
        y = y + fontHgt + textMargin_Bottom
    end
    if isBandage_3 then
        self:drawText(getText("IGUI_Bandaged_3"), x, y, 0.28, 0.89, 0.28, 1, UIFont.Small)
        y = y + fontHgt + textMargin_Bottom
    end
    y = y + 5
    return y
end


local interval = 1      -- 游戏世界中实际间隔1秒
local timeAcc = 0



-- Events.EveryOneMinute.Add(playerCheck)


Events.OnTick.Add(function ()
    local dt = getGameTime():getMultipliedSecondsSinceLastUpdate()
    timeAcc = timeAcc + dt
    if timeAcc >= interval then
        timeAcc = timeAcc - interval
        playerCheck_2()
    end
end)

-- local function accelerateAllActions()
--     local player = getPlayer()
--     if not player then print("qweeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee ") return end
    
--     -- 获取角色统计数据
--     local stats = player:getStats()
    
--     -- 设置全局动作乘数（默认1.0，大于1加快，小于1减慢）
--     player:getModData().actionSpeedMultiplier = 10 -- 加快50%
    
--     -- 或者通过修改特定属性来影响各种动作
-- end



Events.OnCreatePlayer.Add(function(playerNum,player)
    playerHandler = myPlayerHandler:new(playerNum,player)
end)



--TO DO 为所有绷带添加耐久
--TO DO 测试60帧 无highFPSmod


