require "ISApplyMyBandage"

local myPlayerHandler = {}
myPlayerHandler.__index = myPlayerHandler


local MY_BANDAGE_1_TYPE = "My_Bandaid_1"
local MY_BANDAGE_1_TYPE_BASE = "Base.My_Bandaid_1"

local MY_BANDAGE_2_TYPE = "My_Bandaid_2"
local MY_BANDAGE_2_TYPE_BASE = "Base.My_Bandaid_2"

local MY_BANDAGE_3_TYPE = "My_Bandaid_3"
local MY_BANDAGE_3_TYPE_BASE = "Base.My_Bandaid_3"

local MY_BANDAGE_4_TYPE = "My_Bandaid_4"
local MY_BANDAGE_4_TYPE_BASE = "Base.My_Bandaid_4"

local timer = 0

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

    print("start check...")

    -- for i=0, o.bodyParts:size()-1 do
    --     local bodyPart = o.bodyParts:get(i)
    --     if self:checkMyBandaidOnBodyPart(bodyPart) then
    --         print("Found MyBandaid on body part: " .. tostring(bodyPart:getType()))
    --         table.insert(o.BandaidBodyParts, bodyPart)

    --     end

    --     if bodyPart:isBurnt() then
    --         table.insert(o.BurntBodyParts,bodyPart)
    --     end

    -- end


    return o
end


function myPlayerHandler:checkMyBandaidOnBodyPart(bodyPart)
    if not bodyPart then return end

    -- 检查是否有绷带
    if bodyPart:bandaged() then
        -- 获取绷带类型
        local bandageType = bodyPart:getBandageType()
        -- 检查是否是我的绷带
        for _, myBandageType in ipairs(MY_BANDAGE_TYPES_BASE) do
            if bandageType == myBandageType then
                return true
            end
        end
    end
    return false
end


local test = ISApplyBandage.complete
function ISApplyBandage:complete()
    test(self)

    local bandage = self.item


    -- 移除绷带
    if not bandage then
        print("Bandage removal completed")
        self.bodyPart:setPlantainFactor(0.0)
        -- for i = #BandaidBodyParts, 1, -1 do
        --     if BandaidBodyParts[i] == self.bodyPart then
        --         table.remove(BandaidBodyParts, i)
        --         break
        --     end
        -- end
        return
    end

    -- bandage_1
    if bandage:getType() == MY_BANDAGE_1_TYPE then
        print("MyBandaid_1")
        local t = self.bodyPart:getPlantainFactor()

        local t2 = self.bodyPart:getBandageLife()

        self.bodyPart:setPlantainFactor(t + t2 * 10)

        -- if not playerHandler then
        --     print("no playerHandler")
        --     return
        -- end

        -- table.insert(playerHandler.BandaidBodyParts, self.bodyPart)

    end

    --bandage_2
    if bandage:getType() == MY_BANDAGE_2_TYPE then

        print("MyBandaid_2")


    end


    print("Bandage applied")
    
end


-- local og_complete = ISApplyBandage.perform
-- function ISApplyBandage:perform()
--     og_complete(self)
--     -- 在这里添加你想在完成时执行的代码
    
-- end


-- local of_start = ISApplyBandage.start
-- function ISApplyBandage:start()
--     of_start(self)
--     -- 在这里添加你想在开始时执行的代码


--     if not self.item then
--         print("start removing bandage")
--         local body = self.bodyPart
--         if not body then
--             print("can not get bodypart")
--             return
--         end

--         local bandageType = body:getBandageType()

--         print("bandage type is "..bandageType)


--         return
--     end

--     print("start applying bandage")
-- end

-- everyMinute
local function playerCheck()
    if not playerHandler then return end
    if not playerHandler.bodyParts then return end


    for i=0, playerHandler.bodyParts:size()-1 do
        local bodyPart = playerHandler.bodyParts:get(i)

        if bodyPart:isBurnt() then
            local t = bodyPart:getBurnTime()
            print(t)

            if bodyPart:getBandageType() == MY_BANDAGE_2_TYPE_BASE and t > 0 then
                bodyPart:setBurnTime(math.max(0,t - .05))
            end
        end


        if bodyPart:stitched() then
            local t = bodyPart:getStitchTime()
            print(t)

            if bodyPart:getBandageType() == MY_BANDAGE_3_TYPE_BASE and t < 50 then
                bodyPart:setStitchTime(math.min(50,t + 1))
            end
        end
    end
end








--everySecond
local function playerCheck_2()
    if not playerHandler then return end
    if not playerHandler.bodyParts then return end


    for i=0, playerHandler.bodyParts:size()-1 do
        local bodyPart = playerHandler.bodyParts:get(i)
        local stiffness = bodyPart:getStiffness()
        -- print(bodyPart:getType())
        -- print("stiffness is "..stiffness)

        if stiffness > 0 and IsMyBandaged(bodyPart) then
            bodyPart:setStiffness(math.max(0 , stiffness - MyBandage_4_speed))

            local timeLeft = MyGetBandageTimeLeft(bodyPart)
            print("timeLeft is "..timeLeft)

            local newTimeLeft =math.max(0, timeLeft - MyBandage_4_speed)
            MySetBandageTimeLeft(bodyPart, newTimeLeft)
            if newTimeLeft == 0 then
                MySetBandaged(bodyPart, false , 0)
            end
            

            -- local bandageLife = bodyPart:getBandageLife()
            -- bodyPart:setBandageLife(math.max(0, bandageLife - .5))
        end


    end
end

local function everyTickCheck()
    timer = timer + 1
    if timer >= 60 then
        timer = 0
        playerCheck_2()
    end
end


Events.EveryOneMinute.Add(playerCheck)
--Events.OnPlayerUpdate.Add(playerCheck)

Events.OnTick.Add(everyTickCheck)


Events.OnCreatePlayer.Add(function(playerNum,player)
    playerHandler = myPlayerHandler:new(playerNum,player)
end)

local function applyBandageToPlayer(player, targetPlayer, bandageItem, bodyPart)
    -- 创建绷带使用动作
    local action = ISApplyBandage:new(
        player,          -- 执行动作的玩家
        targetPlayer,    -- 目标玩家(可以是自己)
        bandageItem,     -- 绷带物品
        bodyPart,        -- 要包扎的身体部位
        true            -- doIt参数设为true表示立即执行
    )

    --ISTimedActionQueue.add(action)
    --检查动作是否有效
    if action:isValid() then
        -- 将动作添加到队列
        ISTimedActionQueue.add(action)
    end
end


---Return mybandage_4
---@param player IsoPlayer
---@return InventoryItem?
local function GetMyBandageItem(player)
    local plInv = player:getInventory()
    local bandageItem = plInv:FindAndReturn(MY_BANDAGE_4_TYPE_BASE)

    return bandageItem
end

---@param bodyPart BodyPart
---@param character IsoPlayer
---@param targetPlayer IsoPlayer
---@param item InventoryItem
local function useMyBandage(character, targetPlayer, bodyPart , item)
    if not playerHandler then
        print("no playerHandler")
        return
    end

    if not playerHandler.playerObj then
        print("no playerObj")
        return
    end

    local action = ISApplyMyBandage:new(
        character,          -- 使用绷带的玩家
        targetPlayer,    -- 目标玩家
        item,     -- 绷带物品
        bodyPart,        -- 身体部位
        true            -- 是否立即执行
    )
    
    -- 添加到动作队列
    if action:isValid() then
        ISTimedActionQueue.add(action)
    end
end


local og_ISHealthPanel_doBodyPartContextMenu = ISHealthPanel.doBodyPartContextMenu
function ISHealthPanel:doBodyPartContextMenu(bodyPart, x, y)
    og_ISHealthPanel_doBodyPartContextMenu(self, bodyPart, x, y)

    if not playerHandler then
        print("no playerHandler")
        return
    end
    local playerNum = self.otherPlayer and self.otherPlayer:getPlayerNum() or self.character:getPlayerNum()


    local context = getPlayerContextMenu(playerNum)

    if not context then
        print("no context")
        return
    end

    context:bringToTop()
    context:setVisible(true)
    
    local myBandage_4_item = GetMyBandageItem(playerHandler.playerObj)

    if myBandage_4_item == nil then
        print("no bandage item")
        return
    end

    if IsMyBandaged(bodyPart) then
        local removeBandage_4_option = context:addOption(getText("IGUI_RemoveMyBandage_4"), nil, function()
            print("Remove My Bandage clicked")

            if not playerHandler.playerObj then
                print("no playerObj")
                return
            end

            local action = ISApplyMyBandage:new(
                self.character,
                self.otherPlayer or self.character,
                nil,
                bodyPart,
                true
            )
            
            -- 添加到动作队列
            if action:isValid() then
                ISTimedActionQueue.add(action)
            end
        end)
        removeBandage_4_option.iconTexture = getTexture("media/textures/item_MyBandaid4.png")

    else
        if not playerHandler then
            print("no playerObj")
            return
        end



        if not playerHandler.playerObj:getInventory():contains(MY_BANDAGE_4_TYPE_BASE) then
            return
        end

        local applyBandage_4_option = context:addOption(getText("IGUI_UseMyBandage_4"),nil,function ()

            print("Use My Bandage clicked")
            useMyBandage(self.character, self.otherPlayer or self.character, bodyPart, myBandage_4_item)
        end)

        applyBandage_4_option.iconTexture = getTexture("media/textures/item_MyBandaid4.png")

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
    
    -- 获取身体部位信息
    -- ---@type BodyPart
    -- local bodyPart = item.item.bodyPart
    -- local bodyPartType = bodyPart:getType()
    
    if IsMyBandaged(item.item.bodyPart) then
        self:drawText(getText("IGUI_Bandaged_4") , x, y, 0.28, 0.89, 0.28, 1, UIFont.Small)


        y = y + fontHgt
    end

    y = y + 5
    return y
end





