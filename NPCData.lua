-- NPC Data for all maps
-- Format: [mapID] = { {x = coord/100, y = coord/100, name = "Name", icon = "path"} }
MapLabelsNPCData = {
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
        {x = 45.42 / 100, y = 47.51 / 100, name = "Inn", icon = "Interface\\Icons\\INV_Misc_Food_15", noCluster = true, color = "B8574D"}, -- Gold
        {x = 52.50 / 100, y = 45.41 / 100, name = "Bank", icon = "Interface\\Icons\\INV_Misc_Bag_07", noCluster = true, textDirection = "right", color = "FFD700", labelDistance = 1.3}, 
        {x = 55.81 / 100, y = 48.60 / 100, name = "AH", icon = "Interface\\Icons\\INV_Misc_Coin_01", noCluster = true,},
        {x = 57.96 / 100, y = 56.48 / 100, name = "Orders", icon = "Interface\\Icons\\INV_Misc_Note_06", noCluster = true, textDirection = "right", labelDistance = 1.2},
        {x = 51.66 / 100, y = 42.06 / 100, name = "Upgrades", icon = "Interface\\Icons\\INV_Misc_QirajiCrystal_05", noCluster = true, textDirection = "left", labelDistance = 1.8},
        {x = 47.92 / 100, y = 67.89 / 100, name = "Rostrum", icon = "Interface\\Icons\\Ability_Mount_Drake_Azure", noCluster = true, textDirection = "left", labelDistance = 2.4},
       
        -- Portals
        {x = 41.11 / 100, y = 22.89 / 100, name = "Portal to SW", icon = "Interface\\Icons\\Spell_Arcane_PortalStormWind", noCluster = true},
        {x = 38.29 / 100, y = 27.13 / 100, name = "Portal to Org", icon = "Interface\\Icons\\Spell_Arcane_PortalOrgrimmar", noCluster = true},
        {x = 53.86 / 100, y = 38.72 / 100, name = "M+ Teleports", icon = "Interface\\Icons\\Spell_Shadow_Teleport", noCluster = true, textDirection = "top", labelDistance = 0.9},
       
        -- Profession Tables
        {x = 47.28 / 100, y = 70.45 / 100, name = "Alch", icon = "Interface\\Icons\\Trade_Alchemy", color = "00FF00"},
        {x = 49.07 / 100, y = 63.20 / 100, name = "BS", icon = "Interface\\Icons\\Trade_BlackSmithing", color = "00FF00"},
        {x = 48.62 / 100, y = 71.16 / 100, name = "Insc", icon = "Interface\\Icons\\INV_Inscription_Tradeskill01", color = "00FF00"},
        {x = 52.46 / 100, y = 71.29 / 100, name = "Ench", icon = "Interface\\Icons\\Trade_Engraving", color = "00FF00"},
        {x = 49.05 / 100, y = 56.06 / 100, name = "Engi", icon = "Interface\\Icons\\Trade_Engineering", color = "00FF00"},
        {x = 49.56 / 100, y = 71.16 / 100, name = "Jewel", icon = "Interface\\Icons\\INV_Misc_Gem_01", color = "00FF00"},
        {x = 54.51 / 100, y = 58.94 / 100, name = "LW", icon = "Interface\\Icons\\INV_Misc_ArmorKit_17", color = "00FF00", textDirection = "right", labelDistance = 1.0},
        {x = 54.66 / 100, y = 63.37 / 100, name = "Tailor", icon = "Interface\\Icons\\Trade_Tailoring", color = "00FF00", noCluster = true}
    },
    [627] = { --Legion / Remix Dalaran
        -- Main
        {x = 55.32 / 100, y = 23.98 / 100, name = "Portal to Org", icon = "Interface\\Icons\\Spell_Arcane_PortalOrgrimmar"},
        {x = 39.15 / 100, y = 63.01 / 100, name = "Portal to SW", icon = "Interface\\Icons\\Spell_Arcane_PortalStormWind"},
        {x = 47.57 / 100, y = 70.31 / 100, name = "Bazaar", icon = "Interface\\Icons\\Spell_arcane_portalvaldrakken", noCluster = true},
        {x = 44.46 / 100, y = 74.38 / 100, name = "Bank", icon = "Interface\\Icons\\INV_Misc_Bag_07"},
        {x = 47.65 / 100, y = 89.17 / 100, name = "Remix vendors down here", icon = "ICON_PATH_HERE"},
         -- Profession 
        
    }
}