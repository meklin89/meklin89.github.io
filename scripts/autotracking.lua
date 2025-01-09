-- Configuration --------------------------------------
AUTOTRACKER_ENABLE_DEBUG_LOGGING = false
-------------------------------------------------------

print("")
print("Active Auto-Tracker Configuration")
print("---------------------------------------------------------------------")
print("Enable Item Tracking:        ", AUTOTRACKER_ENABLE_ITEM_TRACKING)
print("Enable Location Tracking:    ", AUTOTRACKER_ENABLE_LOCATION_TRACKING)
if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
    print("Enable Debug Logging:        ", "true")
end
print("---------------------------------------------------------------------")
print("")

U8_READ_CACHE = 0
U8_READ_CACHE_ADDRESS = 0
originalBahamut = "-1"

function autotracker_started()
    print("Started Tracking")
end

function InvalidateReadCaches()
    U8_READ_CACHE_ADDRESS = 0
end

function ReadU8(segment, address)
    if U8_READ_CACHE_ADDRESS ~= address then
        U8_READ_CACHE = segment:ReadUInt8(address)
        U8_READ_CACHE_ADDRESS = address
    end
    return U8_READ_CACHE
end

function isInGame(segment)
  local A = ReadU8(segment, 0x6102) -- Party Made
  local B = ReadU8(segment, 0x60FC) -- Not in Battle
  local C = ReadU8(segment, 0x60A3)
  return A ~= 0x00 and B ~= 0x0B and B ~= 0x0C and not (A== 0xF2 and B == 0xF2 and C == 0xF2)
end

function updateToggleItemFromByteAndFlag(segment, code, address, flag)
    local item = Tracker:FindObjectForCode(code)
    if item then
        local value = ReadU8(segment, address)
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print(item.Name, code, flag, value)
        end

        local flagTest = value & flag

        if flagTest ~= 0 then
            item.Active = true
        elseif AUTOTRACKER_ENABLE_SETTING_LOCATIONS_TO_FALSE then
            item.Active = false
        end
    end
end

function updateOrbFromByteAndFlag(segment, code, address, flag)
    local item = Tracker:FindObjectForCode(code)
    if item then
        local value = ReadU8(segment, address)
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print(item.Name, code, flag, value)
        end

        local flagTest = value & flag

        if flagTest ~= 0 then
            item.CurrentStage = 1
        elseif AUTOTRACKER_ENABLE_SETTING_LOCATIONS_TO_FALSE then
            item.CurrentStage = 0
        end
    end
end

function updateCanal(segment)
    local item = Tracker:FindObjectForCode("canal")
    if item then
        local value = ReadU8(segment, 0x600C)
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print(item.Name, "canal", value)
        end

        if value == 0 then
            item.Active = true
        elseif AUTOTRACKER_ENABLE_SETTING_LOCATIONS_TO_FALSE then
            item.Active = false
        end
    end
end

function updateFloater(segment)
    local item = Tracker:FindObjectForCode("floater")
    if item then
        local floater = ReadU8(segment, 0x602B)
        local airship = ReadU8(segment, 0x6004)
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print(item.Name, floater, airship, item.CurrentStage)
        end

        if airship > 0 then
            item.CurrentStage = 2
        elseif floater > 0 then
            item.CurrentStage = 1
        elseif AUTOTRACKER_ENABLE_SETTING_LOCATIONS_TO_FALSE then
          item.CurrentStage = 0
        end
    end
end 

function updateRuby(segment)
    local item = Tracker:FindObjectForCode("ruby")
    if item then
        local ruby = ReadU8(segment, 0x6029)
        local titan = ReadU8(segment, 0x6214)
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print(item.Name, ruby, titan, item.CurrentStage)
        end

        if ruby > 0 then
            item.CurrentStage = 1
        elseif titan & 0x01 == 0 then
            item.CurrentStage = 2
        elseif AUTOTRACKER_ENABLE_SETTING_LOCATIONS_TO_FALSE then
          item.CurrentStage = 0
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING then
        print("Couldn't find ruby")
    end
end

function updateSlab(segment)
    local item = Tracker:FindObjectForCode("slab")
    if item then
        local slab = ReadU8(segment, 0x6028)
        local unne = ReadU8(segment, 0x620B)
        local lefein = ReadU8(segment, 0x620F)
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print(item.Name, slab, unne, item.CurrentStage)
        end


        if lefein & 0x02 ~= 0 then
          item.CurrentStage = 3
        elseif unne & 0x02 ~= 0 then
          item.CurrentStage = 2
        elseif slab > 0 then
          item.CurrentStage = 1
        elseif AUTOTRACKER_ENABLE_SETTING_LOCATIONS_TO_FALSE then
          item.CurrentStage = 0
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING then
        print("Couldn't find slab")
    end
end

function updateTail(segment)
    local item = Tracker:FindObjectForCode("tail")
    if item then
        local tail = ReadU8(segment, 0x602D)
        local bahamut = ReadU8(segment, 0x620E)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print(item.Name, tail, bahamut, item.CurrentStage, hadTail, originalBahamut)
        end

        if tail > 0 and hadTail ~= true then
            item.CurrentStage = 1
      hadTail = true
    end
    if ( originalBahamut == "-1" and hadTail == true ) then
        originalBahamut = bahamut
    end
    
        if ( bahamut ~= originalBahamut and tail == 1 ) or ( bahamut ~= originalBahamut and hadTail == true ) or ( hadTail == true and tail == 0 ) then
      item.CurrentStage = 2
    elseif hadTail == true then
      item.CurrentStage = 1
        elseif AUTOTRACKER_ENABLE_SETTING_LOCATIONS_TO_FALSE then
      item.CurrentStage = 0
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING then
        print("Couldn't find tail")
    end
end

function updateBottle(segment)
    local item = Tracker:FindObjectForCode("bottle")
    if item then
        local bottle = ReadU8(segment, 0x602F)
        local bottlePopped = ReadU8(segment, 0x6213)
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print(item.Name, bottle, bottlePopped)
        end

        if bottlePopped & 0x02 > 0 then
            item.CurrentStage = 2
        elseif bottle > 0 or bottlePopped & 0x01 > 0 then 
            item.CurrentStage = 1
        elseif AUTOTRACKER_ENABLE_SETTING_LOCATIONS_TO_FALSE then
            item.CurrentStage = 0
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING then
        print("Couldn't find bottle")
    end
end

function updateCrown(segment)
    local item = Tracker:FindObjectForCode("crown")
    if item then
        local crown = ReadU8(segment, 0x6022)
        local astos = ReadU8(segment, 0x6207)
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print(item.Name, crown, astos)
        end

        if astos & 0x02 > 0 then 
            item.CurrentStage = 2
        elseif crown > 0 then
            item.CurrentStage = 1
        elseif AUTOTRACKER_ENABLE_SETTING_LOCATIONS_TO_FALSE then
            item.CurrentStage = 0
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING then
        print("Couldn't find adamant")
    end
end

function updateAdamant(segment)
    local item = Tracker:FindObjectForCode("adamant")
    if item then
        local adamant = ReadU8(segment, 0x6027)
        local smith = ReadU8(segment, 0x6209)
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print(item.Name, adamant, smith)
        end

        if smith & 0x02 > 0 then 
            item.CurrentStage = 2
        elseif adamant > 0 then
            item.CurrentStage = 1
        elseif AUTOTRACKER_ENABLE_SETTING_LOCATIONS_TO_FALSE then
            item.CurrentStage = 0
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING then
        print("Couldn't find adamant")
    end
end

function updateCrystal(segment)
    local item = Tracker:FindObjectForCode("crystal")
    if item then
        local crystal = ReadU8(segment, 0x6023)
        local matoya = ReadU8(segment, 0x620A)
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print(item.Name, crystal, matoya)
        end
        if matoya & 0x02 > 0 then
            item.CurrentStage = 2
        elseif crystal > 0 then
            item.CurrentStage = 1
        elseif AUTOTRACKER_ENABLE_SETTING_LOCATIONS_TO_FALSE then
            item.CurrentStage = 0
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING then
        print("Couldn't find crystal")
    end
end

function updateHerb(segment)
    local item = Tracker:FindObjectForCode("herb")
    if item then
        local herb = ReadU8(segment, 0x6024)
        local elfPrince = ReadU8(segment, 0x6205)
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print(item.Name, herb, elfPrince)
        end
        if elfPrince & 0x02 > 0 then
            item.CurrentStage = 2
        elseif herb > 0 then
            item.CurrentStage = 1
        elseif AUTOTRACKER_ENABLE_SETTING_LOCATIONS_TO_FALSE then
            item.CurrentStage = 0
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING then
        print("Couldn't find herb")
    end
end

function updateTNT(segment)
    local item = Tracker:FindObjectForCode("tnt")
    if item then
        local tnt = ReadU8(segment, 0x6026)
        local nerrick = ReadU8(segment, 0x6208)
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print(item.Name, tnt, nerrick)
        end
        if nerrick & 0x02 > 0 then
            item.CurrentStage = 2
        elseif tnt > 0 then
            item.CurrentStage = 1
        elseif AUTOTRACKER_ENABLE_SETTING_LOCATIONS_TO_FALSE then
            item.CurrentStage = 0
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING then
        print("Couldn't find tnt")
    end
end

function updateSectionSingleChestCountFromByteAndFlag(segment, locationRef, address, flag, callback)
    local location = Tracker:FindObjectForCode(locationRef)
    if location then
        -- Do not auto-track this the user has manually modified it
        if location.Owner.ModifiedByUser then
            return
        end

        local value = ReadU8(segment, address)
        
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print(locationRef, value)
        end
  
        if (value & flag) ~= 0 then
            location.AvailableChestCount = 0
            if callback then
                callback(true)
            end
        else
            location.AvailableChestCount = location.ChestCount
            if callback then
                callback(false)
            end
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING then
        print("Couldn't find location", locationRef)
    end
end

function updateSectionMultipleChestCountFromByteAndFlag(segment, locationRef, addressTable, callback)
    local location = Tracker:FindObjectForCode(locationRef)
    if location then
        -- Do not auto-track this the user has manually modified it
        if location.Owner.ModifiedByUser then
            return
        end

        local chestsOpened = 0
        for address,flag in pairs(addressTable) do
          local value = ReadU8(segment, address)
          if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print(locationRef, value)
          end
          if (value & flag) ~= 0 then
            chestsOpened = chestsOpened + 1
          end
        end
  
        if location.AvailableChestCount ~= location.ChestCount - chestsOpened then
            location.AvailableChestCount = location.ChestCount - chestsOpened
            if callback then
                callback(true)
            end
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING then
        print("Couldn't find location", locationRef)
    end
end

function updateShardsFromMemorySegment(segment)
    if AUTOTRACKER_ENABLE_ITEM_TRACKING then
        local shardCount = ReadU8(segment, 0x6035)
        local shardCountItem = Tracker:FindObjectForCode("shards")
        local shardCountMax = Tracker:FindObjectForCode("shardsRequired")
        local goalShardCount = shardCountMax.CurrentStage + 16
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
          print("Shard Count:", shardCount, " Goal Count: ", goalShardCount)
        end
        if shardCount >= goalShardCount then
          shardCountItem.CurrentStage = goalShardCount
        else 
          shardCountItem.CurrentStage = shardCount
        end
    end
end

function updateItemsFromMemorySegment(segment)
    if not isInGame(segment) then
        return false
    end

    InvalidateReadCaches()

    if AUTOTRACKER_ENABLE_ITEM_TRACKING then
        updateToggleItemFromByteAndFlag(segment, "lute", 0x6021, 0xFF)
        updateToggleItemFromByteAndFlag(segment, "key", 0x6025, 0xFF)
        updateToggleItemFromByteAndFlag(segment, "rod", 0x602A, 0xFF)
        updateToggleItemFromByteAndFlag(segment, "chime", 0x602C, 0xFF)
        updateToggleItemFromByteAndFlag(segment, "cube", 0x602E, 0xFF)
        updateToggleItemFromByteAndFlag(segment, "oxyale", 0x6030, 0xFF)
        updateToggleItemFromByteAndFlag(segment, "ship", 0x6000, 0xFF)
        updateToggleItemFromByteAndFlag(segment, "canoe", 0x6012 , 0xFF)
        updateToggleItemFromByteAndFlag(segment, "bridge", 0x6008 , 0xFF)
        updateOrbFromByteAndFlag(segment, "fireorb", 0x6032 , 0xFF)
        updateOrbFromByteAndFlag(segment, "waterorb", 0x6033 , 0xFF)
        updateOrbFromByteAndFlag(segment, "airorb", 0x6034 , 0xFF)
        updateOrbFromByteAndFlag(segment, "earthorb", 0x6031 , 0xFF)
        updateCrown(segment)
        updateAdamant(segment)
        updateCrystal(segment)
        updateHerb(segment)
        updateTNT(segment)
        updateBottle(segment)
        updateSlab(segment)
        updateTail(segment)
        updateRuby(segment)
        updateFloater(segment)
        updateCanal(segment)

    end
    updateLocationsFromMemorySegmentCorridor(segment)
    if Tracker.ActiveVariantUID == "shardHunt" or Tracker.ActiveVariantUID == "shardHuntNoMap" or Tracker.ActiveVariantUID == "shardHuntNOverworld" then
      updateShardsFromMemorySegment(segment)
    end
end

function updateLocationsFromMemorySegmentCorridor(segment)
    if AUTOTRACKER_ENABLE_ITEM_TRACKING then 
      updateToggleItemFromByteAndFlag(segment, "garland", 0x6202, 0x02)
      updateToggleItemFromByteAndFlag(segment, "king", 0x6201, 0x02)
      updateToggleItemFromByteAndFlag(segment, "sara", 0x6212, 0x02)
      updateToggleItemFromByteAndFlag(segment, "sarda", 0x620D, 0x02)
      updateToggleItemFromByteAndFlag(segment, "smith", 0x6209, 0x02)
      updateToggleItemFromByteAndFlag(segment, "nerrick", 0x6208, 0x02)
      updateToggleItemFromByteAndFlag(segment, "sages", 0x6215, 0x02)
      updateToggleItemFromByteAndFlag(segment, "bikke", 0x6204, 0x02)
      updateToggleItemFromByteAndFlag(segment, "marsh", 0x621C, 0x04)
      updateToggleItemFromByteAndFlag(segment, "iceCave", 0x6272, 0x04)
      updateToggleItemFromByteAndFlag(segment, "volcano", 0x626A, 0x04)
      updateToggleItemFromByteAndFlag(segment, "titansTrove", 0x6246, 0x04)
      updateToggleItemFromByteAndFlag(segment, "ordeals", 0x6283, 0x04)
      updateToggleItemFromByteAndFlag(segment, "cardiaIncentive", 0x6287, 0x04)
      updateToggleItemFromByteAndFlag(segment, "coneriaLocked", 0x6203, 0x04)
      updateToggleItemFromByteAndFlag(segment, "marshLocked", 0x6220, 0x04)
      updateToggleItemFromByteAndFlag(segment, "earth", 0x623D, 0x04)
      updateToggleItemFromByteAndFlag(segment, "lefein", 0x620F, 0x02)
      updateToggleItemFromByteAndFlag(segment, "sky", 0x62E9, 0x04)
      updateToggleItemFromByteAndFlag(segment, "sea", 0x62B4, 0x04)
      updateToggleItemFromByteAndFlag(segment, "robot", 0x6211, 0x02)
      updateToggleItemFromByteAndFlag(segment, "fairy", 0x6213, 0x02)
      updateToggleItemFromByteAndFlag(segment, "astos", 0x6207, 0x02)
      updateToggleItemFromByteAndFlag(segment, "elfprince", 0x6206, 0x02)
      updateToggleItemFromByteAndFlag(segment, "matoya", 0x620A, 0x02)
    end

    if AUTOTRACKER_ENABLE_LOCATION_TRACKING then 
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Coneria Castle/King", 0x6201, 0x02)
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Coneria Castle/Sara", 0x6212, 0x02)
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Coneria Castle/Coneria Castle Incentive", 0x6203, 0x04)
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Coneria Castle/Coneria Castle Chests", { [0x6201] = 0x04, [0x6202] = 0x04, [0x6204] = 0x04, [0x6205] = 0x04, [0x6206] = 0x04 })
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Sarda's Cave/Sarda", 0x620D, 0x02)
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Crescent Lake/Sages", 0x6215, 0x02)
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Pravoka/Bikke", 0x6204, 0x02)
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Temple of Fiends/Bottom Left", 0x6209, 0x04)
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Temple of Fiends/Top Left", { [0x6207] = 0x04, [0x6208] = 0x04 })
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Temple of Fiends/Bottom Right", 0x620A, 0x04)
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Temple of Fiends/Top Right", { [0x620B] = 0x04, [0x620C] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Dwarf Cave/Free Chests", { [0x6221] = 0x04, [0x6222] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Dwarf Cave/Dwarf Armory", { [0x6223] = 0x04, [0x6224] = 0x04, [0x6225] = 0x04, [0x6226] = 0x04, [0x6227] = 0x04, [0x6228] = 0x04, [0x6229] = 0x04, [0x622A] = 0x04 })
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Dwarf Cave/Smithy McBeardSmith", 0x6209, 0x02)
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Dwarf Cave/Nerrick (Vanilla Canal)", 0x6208, 0x02)
      updateSectionSingleChestCountFromByteAndFlag(segment, "@North West Castle/Astos", 0x6207, 0x02)
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@North West Castle/Chests", { [0x6211] = 0x04, [0x6212] = 0x04, [0x6213] = 0x04 })
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Matoya's Cave/Matoya", 0x620A, 0x02)
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Matoya's Cave/Chests", { [0x622B] = 0x04, [0x622C] = 0x04, [0x622D] = 0x04 })
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Elf Castle/Elf Prince", 0x6205, 0x02)
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Elf Castle/Chests", { [0x620D] = 0x04, [0x620E] = 0x04, [0x620F] = 0x04, [0x6210] = 0x04 })
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Marsh Cave/Top Floor Right", 0x621B, 0x04)
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Marsh Cave/Top Floor Top Left", 0x621A, 0x04)
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Marsh Cave/Top Floor Bottom Left", { [0x6219] = 0x04, [0x6218] = 0x04 })
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Marsh Cave/Bottom Floor 1,2", 0x6215, 0x04)
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Marsh Cave/Bottom Floor 2,2", { [0x621D] = 0x04, [0x6216] = 0x04 })
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Marsh Cave/Marsh Incentive", 0x621C, 0x04)
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Marsh Cave/Bottom Floor 3,3", 0x6217, 0x04)
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Marsh Cave/Bottom Floor 4,1", 0x6214, 0x04)
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Marsh Cave/Key Locked Left", 0x621E, 0x04)
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Marsh Cave/Key Locked Middle", 0x621F, 0x04)
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Marsh Cave/Marsh Locked Incentive", 0x6220, 0x04)
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Ice Cave/Ice Cave Incentive", 0x6272, 0x04)
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Ice Cave/Incentive Floor Chests", { [0x6270] = 0x04, [0x6271] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Ice Cave/Middle Floor Left", { [0x6279] = 0x04, [0x627A] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Ice Cave/Bottom Floor First Chests", { [0x626B] = 0x04, [0x626C] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Ice Cave/Bottom Floor 3 Pack", { [0x626D] = 0x04, [0x626E] = 0x04, [0x626F] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Ice Cave/Middle Floor 6 Pack", { [0x6273] = 0x04, [0x6274] = 0x04, [0x6275] = 0x04, [0x6276] = 0x04, [0x6277] = 0x04, [0x6278] = 0x04})
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Volcano/Armory Bottom Right", { [0x625A] = 0x04, [0x625B] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Volcano/Armory Right Hairpins", { [0x6258] = 0x04, [0x6259] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Volcano/Armory Left Hairpin", { [0x6256] = 0x04, [0x6257] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Volcano/Armory Main", { [0x624A] = 0x04, [0x624B] = 0x04, [0x624C] = 0x04, [0x624D] = 0x04, [0x624E] = 0x04, [0x624F] = 0x04, [0x6250] = 0x04, [0x6251] = 0x04, [0x6252] = 0x04, [0x6253] = 0x04, [0x6254] = 0x04, [0x6255] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Volcano/Agama Top Right", { [0x625C] = 0x04, [0x625D] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Volcano/Agama Top Middle", { [0x625E] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Volcano/Agama Top Left", { [0x6265] = 0x04, [0x6266] = 0x04, [0x6267] = 0x04, [0x6268] = 0x04, [0x6269] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Volcano/Agama Middle Middle", { [0x6261] = 0x04, [0x6262] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Volcano/Agama Middle Right", { [0x6263] = 0x04, [0x6264] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Volcano/Agama Bottom Right", { [0x625F] = 0x04, [0x6260] = 0x04 })
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Volcano/Volcano Incentive", 0x626A, 0x04)
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Titan's Trove/Incentive", 0x6246, 0x04)
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Titan's Trove/Chests", { [0x6247] = 0x04, [0x6248] = 0x04, [0x6249] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Cardia Grassy/Chests", { [0x628C] = 0x04, [0x628D] = 0x04, [0x628E] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Cardia Swampy/Chests", { [0x6289] = 0x04, [0x628A] = 0x04, [0x628B] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Cardia Forest/Chests", { [0x6284] = 0x04, [0x6285] = 0x04, [0x6286] = 0x04, [0x6288] = 0x04, [0x628F] = 0x04, [0x6290] = 0x04 })
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Cardia Forest/Cardia Incentive", 0x6287, 0x04)
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Ordeals/Chests", { [0x627B] = 0x04, [0x627C] = 0x04, [0x627D] = 0x04, [0x627E] = 0x04, [0x627F] = 0x04, [0x6280] = 0x04, [0x6281] = 0x04, [0x6282] = 0x04 })
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Ordeals/Incentive", 0x6283, 0x04)
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Earth Cave/1 Top", 0x6232, 0x04)
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Earth Cave/1 Bottom", { [0x622E] = 0x04, [0x622F] = 0x04, [0x6230] = 0x04, [0x6231] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Earth Cave/2 Right", { [0x6233] = 0x04, [0x6234] = 0x04, [0x6235] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Earth Cave/2 Bottom", { [0x6236] = 0x04, [0x6237] = 0x04, [0x6238] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Earth Cave/3 Chests", { [0x6239] = 0x04, [0x623A] = 0x04, [0x623B] = 0x04 })
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Earth Cave/3 TFC", 0x623C, 0x04)
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Earth Cave/Earth Incentive", 0x623D, 0x04)
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Earth Cave/4 Armory", { [0x6241] = 0x04, [0x6242] = 0x04, [0x6243] = 0x04, [0x6244] = 0x04, [0x6245] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Earth Cave/4 Bottom", { [0x623E] = 0x04, [0x623F] = 0x04, [0x6240] = 0x04 })
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Lefein/Incentive", 0x620F, 0x02)
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Mirage Tower/Floor 1", { [0x62C4] = 0x04, [0x62C5] = 0x04, [0x62C6] = 0x04, [0x62C7] = 0x04, [0x62C8] = 0x04, [0x62C9] = 0x04, [0x62CA] = 0x04, [0x62CB] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Mirage Tower/< >", { [0x62CC] = 0x04, [0x62CD] = 0x04, [0x62CE] = 0x04, [0x62CF] = 0x04, [0x62D0] = 0x04, [0x62D1] = 0x04, [0x62D2] = 0x04, [0x62D3] = 0x04, [0x62D4] = 0x04, [0x62D5] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Sky Palace/Floor 1 Left", { [0x62D6] = 0x04, [0x62D7] = 0x04, [0x62D8] = 0x04, [0x62D9] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Sky Palace/Floor 1 Right", { [0x62DA] = 0x04, [0x62DB] = 0x04, [0x62DC] = 0x04, [0x62DD] = 0x04, [0x62DE] = 0x04 })
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Sky Palace/Floor 1 Bottom", 0x62DF, 0x04)
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Sky Palace/Sky Incentive", 0x62E9, 0x04)
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Sky Palace/Floor 2 Left", { [0x62E5] = 0x04, [0x62E6] = 0x04, [0x62E7] = 0x04, [0x62E8] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Sky Palace/Floor 2 Right", { [0x62E0] = 0x04, [0x62E1] = 0x04, [0x62E2] = 0x04, [0x62E3] = 0x04, [0x62E4] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Sky Palace/Floor 3 Top", { [0x62F4] = 0x04, [0x62F5] = 0x04, [0x62F6] = 0x04, [0x62F7] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Sky Palace/Floor 3 Right", { [0x62EE] = 0x04, [0x62EF] = 0x04, [0x62F0] = 0x04, [0x62F1] = 0x04, [0x62F2] = 0x04, [0x62F3] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Sky Palace/Floor 3 Left", { [0x62EA] = 0x04, [0x62EB] = 0x04, [0x62EC] = 0x04, [0x62ED] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Waterfall/Chests", { [0x62B5] = 0x04, [0x62B6] = 0x04, [0x62B7] = 0x04, [0x62B8] = 0x04, [0x62B9] = 0x04, [0x62BA] = 0x04 })
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Waterfall/Robot", 0x6211, 0x02)
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Gaia/Fairy", 0x6213, 0x02)
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Sea Shrine/Sea Split", { [0x629F] = 0x04, [0x62A0] = 0x04 })
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Sea Shrine/TFC", 0x62A5, 0x04)
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Sea Shrine/TFC Floor", { [0x62A3] = 0x04, [0x62A4] = 0x04, [0x62A6] = 0x04, [0x62A7] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Sea Shrine/Mermaids", { [0x62A8] = 0x04, [0x62A9] = 0x04, [0x62AA] = 0x04, [0x62AB] = 0x04, [0x62AC] = 0x04, [0x62AD] = 0x04, [0x62AE] = 0x04, [0x62AF] = 0x04, [0x62B0] = 0x04, [0x62B1] = 0x04, [0x62B2] = 0x04, [0x62B3] = 0x04 })
      updateSectionSingleChestCountFromByteAndFlag(segment, "@Sea Shrine/Sea Incentive", 0x62B4, 0x04)
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Sea Shrine/Sea Hallway", { [0x62A1] = 0x04, [0x62A2] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@Sea Shrine/Sharknado", { [0x6295] = 0x04, [0x6296] = 0x04, [0x6297] = 0x04, [0x6298] = 0x04, [0x6299] = 0x04, [0x629A] = 0x04, [0x629B] = 0x04, [0x629C] = 0x04, [0x629D] = 0x04, [0x629E] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@ToFR/Lute Plate Room", { [0x62FD] = 0x04, [0x62FE] = 0x04 })
      updateSectionMultipleChestCountFromByteAndFlag(segment, "@ToFR/Kary Floor", { [0x62F9] = 0x04, [0x62FA] = 0x04, [0x62FB] = 0x04, [0x62FC] = 0x04 })
      updateSectionSingleChestCountFromByteAndFlag(segment, "@ToFR/Vanilla Masa", 0x62F8, 0x04)
    end
end

-- I know this is bad practice but the amount of resets makes it so all the sanity
-- checking needs to be done on the segment
ScriptHost:AddMemoryWatch("FFR Data", 0x6000, 0x300, updateItemsFromMemorySegment)

