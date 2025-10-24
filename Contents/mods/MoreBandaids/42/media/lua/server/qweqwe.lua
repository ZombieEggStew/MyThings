require 'Items/SuburbsDistributions'
require "Items/ProceduralDistributions"
require "Vehicles/VehicleDistributions"

local sandboxVars = SandboxVars.MyBandaid or {}
local factor = sandboxVars.Factor or 1

local ItemDist = {
  {
    Distributions = {
      {"AmbulanceDriverTools", 50},
      {"AmbulanceDriverTools", 20},
      {"ArmyBunkerMedical", 4},
      {"ArmyStorageMedical", 8},
      {"BathroomCabinet", 8},
      {"BathroomCounter", 8},
      {"BathroomShelf", 8},
      {"CortmanOfficeDesk", 4},
      {"CrateHumanitarian", 2},
      {"DoctorTools", 20},
      {"DoctorTools", 20},
      {"KitchenRandom", 6},
      {"MedicalCabinet", 10},
      {"MedicalClinicDrugs", 8},
      {"MedicalClinicTools", 4},
      {"MedicalOfficeCounter", 4},
      {"MedicalOfficeDesk", 4},
      {"MedicalStorageDrugs", 20},
      {"MedicalStorageDrugs", 10},
      {"MedicalStorageTools", 10},
      {"NurseTools", 20},
      {"NurseTools", 20},
      {"SafehouseMedical", 50},
      {"SafehouseMedical", 20},
      {"SafehouseMedical_Mid", 20},
      {"SafehouseMedical_Mid", 10},
      {"StoreShelfMedical", 20},
      {"StoreShelfMedical", 10},
      {"VacationStuff", 8},
      {"WaitingRoomDesk", 4},
    },
    Vehicles = {
      {"ArmyGloveBox", 10 },
      {"EvacueeGloveBox", 10},
      {"AmbulanceTruckBed", 10},
      {"EvacueeGloveBox", 10},
    },
    Vehicles_GloveBoxJunk = {
      {"GloveBoxWorkItems", 10},
      {"GloveBoxItems", 10},
    },
    Items = {
        "Base.My_Bandaid_1",
        "Base.My_Bandaid_2",
        "Base.My_Bandaid_3",
        "Base.My_Bandaid_4",
        "Base.My_Bandaid_5",
    }
  },

}

local function getLootTable(name)
  return ProceduralDistributions.list[name] or (SuburbsDistributions["all"] and SuburbsDistributions["all"][name])
end

local function insertItem(tLootTable, item, weight)
  if tLootTable and weight > 0 then
    table.insert(tLootTable.items, item)
    table.insert(tLootTable.items, weight)
  end
end

local function insertVehicleItem(vehicleTable, item, weight)
  if vehicleTable and weight > 0 then
    table.insert(vehicleTable.items, item)
    table.insert(vehicleTable.items, weight)
  end
end
local function insertVehicleItem_2(vehicleTable, item, weight)
  if vehicleTable and weight > 0 then
    table.insert(vehicleTable, item)
    table.insert(vehicleTable, weight)
  end
end

local function preDistributionMerge()
  for _, group in ipairs(ItemDist) do
    if group.Distributions then
      for _, dist in ipairs(group.Distributions) do
        local weight = dist[2]
        if weight > 0 then
          local lootTable = getLootTable(dist[1])
          for _, item in ipairs(group.Items) do
            insertItem(lootTable, item, weight * factor)
          end
        end
      end
    end
    if group.Vehicles then
      for _, veh in ipairs(group.Vehicles) do
        local weight = veh[2]
        if weight > 0 then
          local vehicleTable = VehicleDistributions[veh[1]]
          for _, item in ipairs(group.Items) do
            insertVehicleItem(vehicleTable, item, weight * factor)
          end
        end
      end
    end
    if group.Vehicles_GloveBoxJunk then
      for _, veh in ipairs(group.Vehicles_GloveBoxJunk) do
        local weight = veh[2]
        if weight > 0 then
          local vehicleTable = ClutterTables[veh[1]]
          for _, item in ipairs(group.Items) do
            insertVehicleItem_2(vehicleTable, item, weight * factor)
          end
        end
      end
    end
  end
end

Events.OnPreDistributionMerge.Add(preDistributionMerge)