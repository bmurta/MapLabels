-- NPC Data for all maps
-- Format: [mapID] = { {x = coord/100, y = coord/100, name = "Name", icon = "path"} }
CityGuideNPCData = {
    [84] = { -- Stormwind
        {x = 61.79 / 100, y = 73.00 / 100, name = "Auction House", icon = "Interface\\Icons\\INV_Misc_Coin_01"},
        {x = 62.24 / 100, y = 76.53 / 100, name = "Bank", icon = "Interface\\Icons\\INV_Misc_Bag_07"},
        {x = 49.24 / 100, y = 84.20 / 100, name = "Portal Room", icon = "Interface\\Icons\\Spell_Arcane_PortalDalaran"},
    },
    [85] = { -- Orgrimmar
        {x = 0.54, y = 0.73, name = "Auction House", icon = "Interface\\Icons\\INV_Misc_Coin_01"},
        {x = 0.49, y = 0.82, name = "Bank", icon = "Interface\\Icons\\INV_Misc_Bag_07"},
    },
    [2339] = { -- Dornogal
        -- Main Services
        {x = 45.42 / 100, y = 47.51 / 100, name = "Inn", icon = "Interface\\Icons\\inv_misc_rune_01", noCluster = true}, 
        {x = 52.50 / 100, y = 45.41 / 100, name = "Bank", icon = "Interface\\Icons\\INV_Misc_Bag_07", noCluster = true, textDirection = "right", color = "FFD700"}, 
        {x = 55.81 / 100, y = 48.60 / 100, name = "AH", icon = "Interface\\Icons\\INV_Misc_Coin_01", noCluster = true,},
        {x = 57.96 / 100, y = 56.48 / 100, name = "Orders", icon = "Interface\\Icons\\INV_Misc_Note_06", noCluster = true, textDirection = "right", labelDistance = 1.2},
        {x = 51.66 / 100, y = 42.06 / 100, name = "Upgrades", icon = "Interface\\Icons\\INV_Misc_QirajiCrystal_05", noCluster = true, textDirection = "left", labelDistance = 1.3},
        {x = 47.92 / 100, y = 67.89 / 100, name = "Rostrum", icon = "Interface\\Icons\\Ability_Mount_Drake_Azure", noCluster = true, textDirection = "left", labelDistance = 1.3},
        {x = 44.60 / 100, y = 55.91 / 100, name = "Trading\nPost", icon = "Interface\\Icons\\Tradingpostcurrency", noCluster = true, color = "99CCFF"},
        {x = 55.45 / 100, y = 77.18 / 100, name = "PvP", icon = "Interface\\Icons\\achievement_legionpvp2tier3", color = "FF2020"},
       
        -- Portals
        {x = 41.11 / 100, y = 22.89 / 100, name = "Portals to SW", icon = "Interface\\Icons\\Spell_Arcane_PortalStormWind", noCluster = true},
        {x = 38.29 / 100, y = 27.13 / 100, name = "Portal to Org", icon = "Interface\\Icons\\Spell_Arcane_PortalOrgrimmar", noCluster = true},
        {x = 53.86 / 100, y = 38.72 / 100, name = "M+ Teleports", icon = "Interface\\Icons\\Spell_Shadow_Teleport", noCluster = true, textDirection = "top", labelDistance = 0.9},
       
        -- Profession Tables
        {x = 44.15 / 100, y = 45.83 / 100, name = "Cook", icon = "Interface\\Icons\\INV_Misc_Food_15", color = "00FF00", noCluster = true, textDirection = "left"},
        {x = 50.48 / 100, y = 26.84 / 100, name = "Fishing", icon = "Interface\\Icons\\ui_profession_fishing", color = "00FF00", noCluster = true, textDirection = "top"},
        {x = 47.28 / 100, y = 70.45 / 100, name = "Alch", icon = "Interface\\Icons\\Trade_Alchemy", color = "00FF00"},
        {x = 49.07 / 100, y = 63.20 / 100, name = "BS", icon = "Interface\\Icons\\Trade_BlackSmithing", color = "00FF00"},
        {x = 48.62 / 100, y = 71.16 / 100, name = "Insc", icon = "Interface\\Icons\\INV_Inscription_Tradeskill01", color = "00FF00"},
        {x = 52.46 / 100, y = 71.29 / 100, name = "Ench", icon = "Interface\\Icons\\Trade_Engraving", color = "00FF00"},
        {x = 49.05 / 100, y = 56.06 / 100, name = "Engi", icon = "Interface\\Icons\\Trade_Engineering", color = "00FF00"},
        {x = 49.56 / 100, y = 71.16 / 100, name = "Jewel", icon = "Interface\\Icons\\INV_Misc_Gem_01", color = "00FF00"},
        {x = 54.51 / 100, y = 58.94 / 100, name = "LW", icon = "Interface\\Icons\\INV_Misc_ArmorKit_17", color = "00FF00", labelDistance = 0.8},
        {x = 54.66 / 100, y = 63.37 / 100, name = "Tailor", icon = "Interface\\Icons\\Trade_Tailoring", color = "00FF00", noCluster = true},
        
    },
    [627] = { --Legion / Remix Dalaran
        -- Main
        {x = 55.32 / 100, y = 23.98 / 100, name = "Org", icon = "Interface\\Icons\\Spell_Arcane_PortalOrgrimmar"},
        {x = 39.15 / 100, y = 63.01 / 100, name = "SW", icon = "Interface\\Icons\\Spell_Arcane_PortalStormWind"},
        {x = 47.57 / 100, y = 70.31 / 100, name = "Bazaar", icon = "Interface\\Icons\\Spell_arcane_portalvaldrakken", noCluster = true, textDirection = "top", labelDistance = 1.2},
        {x = 44.46 / 100, y = 74.38 / 100, name = "Bank", icon = "Interface\\Icons\\INV_Misc_Bag_07", color = "FFD700"},
        {x = 47.65 / 100, y = 89.17 / 100, name = "Remix vendors", icon = "ICON_PATH_HERE"},
         -- Profession 
        
    },
    [2112] = { -- Valdrakken (Dragonflight)
        -- Main Services
        {x = 55.18 / 100, y = 57.36 / 100, name = "Bank", icon = "Interface\\Icons\\INV_Misc_Bag_07", noCluster = true, color = "FFD700"},
        {x = 42.65 / 100, y = 59.79 / 100, name = "AH", icon = "Interface\\Icons\\INV_Misc_Coin_01", noCluster = true, textDirection = "top"},
        {x = 47.44 / 100, y = 46.66 / 100, name = "Inn\nCook", icon = "Interface\\Icons\\inv_misc_rune_01", noCluster = true},
        {x = 34.86 / 100, y = 61.61 / 100, name = "Orders", icon = "Interface\\Icons\\INV_Misc_Note_06", noCluster = true, textDirection = "top"},
        {x = 41.00 / 100, y = 44.20 / 100, name = "PvP", icon = "Interface\\Icons\\achievement_legionpvp2tier3", noCluster = true, color = "FF2020"},
        {x = 44.24 / 100, y = 67.84 / 100, name = "Flight\nMaster", icon = "Interface\\Icons\\ability_mount_tawnywindrider"},
        {x = 38.42 / 100, y = 37.21 / 100, name = "Primal\nVendors", icon = "Interface\\Icons\\ability_vehicle_electrocharge"},
        {x = 46.90 / 100, y = 78.90 / 100, name = "Stable", icon = "Interface\\Icons\\classicon_hunter"},
        
        
        -- Portals (in the Seat of the Aspects palace)
        {x = 58.15 / 100, y = 40.05 / 100, name = "Portals", icon = "Interface\\Icons\\Spell_Arcane_PortalDalaran", noCluster = true},
        {x = 26.04 / 100, y = 40.82 / 100, name = "Badlands Portal", icon = "Interface\\Icons\\Spell_Arcane_PortalOrgrimmar", textDirection = "top"},
        
        -- Dragonriding
        {x = 25.03 / 100, y = 50.59 / 100, name = "Rostrum", icon = "Interface\\Icons\\Ability_Mount_Drake_Azure", noCluster = true, textDirection = "left", labelDistance = 1.3},
        
        -- Profession Trainers & Stations
        {x = 44.89 / 100, y = 74.88 / 100, name = "Fishing", icon = "Interface\\Icons\\ui_profession_fishing", color = "00FF00", textDirection = "right", noCluster = true},
        {x = 36.72 / 100, y = 72.20 / 100, name = "Alch", icon = "Interface\\Icons\\Trade_Alchemy", color = "00FF00"},
        {x = 36.39 / 100, y = 50.24 / 100, name = "BS", icon = "Interface\\Icons\\Trade_BlackSmithing", color = "00FF00"},
        {x = 30.83 / 100, y = 59.72 / 100, name = "Ench", icon = "Interface\\Icons\\Trade_Engraving", color = "00FF00"},
        {x = 42.29 / 100, y = 48.83 / 100, name = "Engi", icon = "Interface\\Icons\\Trade_Engineering", color = "00FF00"},
        {x = 39.61 / 100, y = 73.73 / 100, name = "Insc", icon = "Interface\\Icons\\INV_Inscription_Tradeskill01", color = "00FF00"},
        {x = 40.81 / 100, y = 60.55 / 100, name = "JC", icon = "Interface\\Icons\\INV_Misc_Gem_01", color = "00FF00"},
        {x = 28.52 / 100, y = 60.79 / 100, name = "LW", icon = "Interface\\Icons\\INV_Misc_ArmorKit_17", color = "00FF00", noCluster = true},
        {x = 31.88 / 100, y = 67.68 / 100, name = "Tailor", icon = "Interface\\Icons\\Trade_Tailoring", color = "00FF00"},
    },
    [2472] = { -- Tazavesh (K'aresh)
        {x = 40.65 / 100, y = 29.11 / 100, name = "Renown", icon = "Interface\\Icons\\ability_racial_etherealconnection"},
        {x = 41.07 / 100, y = 25.16 / 100, name = "Inn", icon = "Interface\\Icons\\inv_misc_rune_01", textDirection = "top", noCluster = true},
        {x = 47.36 / 100, y = 26.79 / 100, name = "Stable", icon = "Interface\\Icons\\classicon_hunter"},
        {x = 48.99 / 100, y = 20.21 / 100, name = "Portals", icon = "Interface\\Icons\\spell_arcane_portaldalarancrater"},
        {x = 43.52 / 100, y = 8.18 / 100, name = "Al'dani", icon = "Interface\\Icons\\inv_112_achievement_dungeon_ecodome"},
        {x = 36.57 / 100, y = 13.51 / 100, name = "Tazavesh", icon = "Interface\\Icons\\achievement_dungeon_brokerdungeon"},
        {x = 46.80 / 100, y = 56.83 / 100, name = "Phase", icon = "Interface\\Icons\\spell_arcane_prismaticcloak"},
        {x = 38.64 / 100, y = 51.02 / 100, name = "Ky'veza", icon = "Interface\\Icons\\inv_achievement_raidnerubian_etherealassasin"},
   },
     [2393] = {
        {x = 50.81 / 100, y = 65.22 / 100, name = "Bank", icon = "Interface\\Icons\\INV_Misc_Bag_07", noCluster = true, color = "FFD700"},
    },
}