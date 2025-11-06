require "XpSystem/ISUI/ISHealthPanel"
require "ISApplyMyBandage"

local test = {
    My_Bandaid_3 = "My_Bandaid_3",
    My_Bandaid_4 = "My_Bandaid_4",
    My_Bandaid_5 = "My_Bandaid_5"
}

local function IsMyBandaged2(md,bodyPart, BandageType)
    local bodyPartType = BodyPartType.ToString(bodyPart:getType())
    return md.MyBandageSystem[bodyPartType][BandageType].bandaged
end

function ISHealthPanel:getDamagedParts()
    local result = {}
    local bodyParts = self:getPatient():getBodyDamage():getBodyParts()
    local md = self:getPatient():getModData()
    if isClient() and not self:getPatient():isLocalPlayer() then
        bodyParts = self:getPatient():getBodyDamageRemote():getBodyParts()
    end
    for i=1,bodyParts:size() do
        local bodyPart = bodyParts:get(i-1)
        local bodyPartAction = self.bodyPartAction and self.bodyPartAction[bodyPart]

        -- if true then
        --     table.insert(result, bodyPart)
        -- end

        if ISHealthPanel.cheat or bodyPart:HasInjury() or bodyPart:bandaged() or bodyPart:stitched() or bodyPart:getSplintFactor() > 0 or bodyPart:getAdditionalPain() > 10 or bodyPart:getStiffness() > 5  or (isDebug and bodyPart:getStiffness() > 0) then
            table.insert(result, bodyPart)
        end

        for _, bandageType in pairs(test) do
            if IsMyBandaged2(md,bodyPart , bandageType) then
                table.insert(result, bodyPart)
                break
            end
        end

    end
    return result
end

local org_update = ISHealthPanel.update
function ISHealthPanel:update()
    org_update(self)

    --self:setWidthAndParentWidth(800)
end