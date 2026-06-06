-- ItemDatabase.lua
-- Defines all obtainable limiteds with rarity weights and display info.

local ItemDatabase = {}

-- Rarity tiers: weight is relative probability (higher = more common)
ItemDatabase.Rarities = {
	Common    = { Name = "Common",    Color = Color3.fromRGB(180, 180, 180), Weight = 60  },
	Uncommon  = { Name = "Uncommon",  Color = Color3.fromRGB(80,  200, 80),  Weight = 25  },
	Rare      = { Name = "Rare",      Color = Color3.fromRGB(80,  130, 220), Weight = 10  },
	Epic      = { Name = "Epic",      Color = Color3.fromRGB(160, 80,  220), Weight = 4   },
	Legendary = { Name = "Legendary", Color = Color3.fromRGB(255, 190, 30),  Weight = 1   },
}

-- Each item: Id, DisplayName, Rarity, Description, ImageId (asset id string)
ItemDatabase.Items = {
	-- Commons
	{ Id = "sword_basic",       DisplayName = "Wooden Sword",        Rarity = "Common",    Description = "A trusty wooden blade.",         ImageId = "rbxassetid://6023426912" },
	{ Id = "hat_simple",        DisplayName = "Paper Hat",           Rarity = "Common",    Description = "Folded with care.",              ImageId = "rbxassetid://6023426912" },
	{ Id = "badge_bronze",      DisplayName = "Bronze Medal",        Rarity = "Common",    Description = "Participation trophy.",          ImageId = "rbxassetid://6023426912" },
	{ Id = "backpack_worn",     DisplayName = "Old Backpack",        Rarity = "Common",    Description = "Seen better days.",              ImageId = "rbxassetid://6023426912" },
	{ Id = "ring_copper",       DisplayName = "Copper Ring",         Rarity = "Common",    Description = "Cheaply made but shiny.",        ImageId = "rbxassetid://6023426912" },

	-- Uncommons
	{ Id = "sword_iron",        DisplayName = "Iron Sword",          Rarity = "Uncommon",  Description = "A sturdy iron blade.",           ImageId = "rbxassetid://6023426912" },
	{ Id = "hat_jester",        DisplayName = "Jester Hat",          Rarity = "Uncommon",  Description = "For the playful at heart.",      ImageId = "rbxassetid://6023426912" },
	{ Id = "shield_wood",       DisplayName = "Wooden Shield",       Rarity = "Uncommon",  Description = "Offers some protection.",        ImageId = "rbxassetid://6023426912" },
	{ Id = "boots_leather",     DisplayName = "Leather Boots",       Rarity = "Uncommon",  Description = "Comfortable travel wear.",       ImageId = "rbxassetid://6023426912" },
	{ Id = "badge_silver",      DisplayName = "Silver Medal",        Rarity = "Uncommon",  Description = "Above average.",                 ImageId = "rbxassetid://6023426912" },

	-- Rares
	{ Id = "sword_steel",       DisplayName = "Steel Sword",         Rarity = "Rare",      Description = "A finely crafted steel blade.",  ImageId = "rbxassetid://6023426912" },
	{ Id = "hat_wizard",        DisplayName = "Wizard Hat",          Rarity = "Rare",      Description = "Imbued with minor magic.",       ImageId = "rbxassetid://6023426912" },
	{ Id = "shield_iron",       DisplayName = "Iron Shield",         Rarity = "Rare",      Description = "Solid iron protection.",         ImageId = "rbxassetid://6023426912" },
	{ Id = "ring_silver",       DisplayName = "Silver Ring",         Rarity = "Rare",      Description = "Gleams in the moonlight.",       ImageId = "rbxassetid://6023426912" },
	{ Id = "cloak_shadows",     DisplayName = "Shadow Cloak",        Rarity = "Rare",      Description = "Fades into the dark.",           ImageId = "rbxassetid://6023426912" },

	-- Epics
	{ Id = "sword_enchanted",   DisplayName = "Enchanted Blade",     Rarity = "Epic",      Description = "Glows with arcane energy.",      ImageId = "rbxassetid://6023426912" },
	{ Id = "hat_crown",         DisplayName = "Jeweled Crown",       Rarity = "Epic",      Description = "Fit for royalty.",               ImageId = "rbxassetid://6023426912" },
	{ Id = "wings_obsidian",    DisplayName = "Obsidian Wings",      Rarity = "Epic",      Description = "Dark and powerful.",             ImageId = "rbxassetid://6023426912" },
	{ Id = "ring_gold",         DisplayName = "Gold Ring",           Rarity = "Epic",      Description = "Pure and valuable.",             ImageId = "rbxassetid://6023426912" },

	-- Legendaries
	{ Id = "sword_legendary",   DisplayName = "Blade of Eternity",   Rarity = "Legendary", Description = "Forged at the dawn of time.",    ImageId = "rbxassetid://6023426912" },
	{ Id = "hat_dominus",       DisplayName = "Dominus Aureus",      Rarity = "Legendary", Description = "The rarest of hats.",            ImageId = "rbxassetid://6023426912" },
	{ Id = "wings_celestial",   DisplayName = "Celestial Wings",     Rarity = "Legendary", Description = "Wings of a fallen angel.",       ImageId = "rbxassetid://6023426912" },
	{ Id = "aura_rainbow",      DisplayName = "Rainbow Aura",        Rarity = "Legendary", Description = "Radiates all colors.",           ImageId = "rbxassetid://6023426912" },
}

-- Build lookup by Id for quick access
ItemDatabase.ById = {}
for _, item in ipairs(ItemDatabase.Items) do
	ItemDatabase.ById[item.Id] = item
end

-- Build rarity lookup
ItemDatabase.ByRarity = {}
for _, rarity in pairs(ItemDatabase.Rarities) do
	ItemDatabase.ByRarity[rarity.Name] = {}
end
for _, item in ipairs(ItemDatabase.Items) do
	table.insert(ItemDatabase.ByRarity[item.Rarity], item)
end

return ItemDatabase
