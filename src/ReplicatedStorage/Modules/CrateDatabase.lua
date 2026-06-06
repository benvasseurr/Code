-- CrateDatabase.lua
-- Defines all available crates, their costs, and which item pool they draw from.

local CrateDatabase = {}

-- Item pool: list of item Ids eligible to drop from this crate.
-- An empty pool means the crate can drop any item in ItemDatabase.
-- Rarity weights from ItemDatabase are always applied on top.

CrateDatabase.Crates = {
	{
		Id          = "starter_crate",
		DisplayName = "Starter Crate",
		Description = "A basic crate for newcomers. Contains weapons and accessories.",
		Cost        = 100,
		Color       = Color3.fromRGB(100, 160, 255),
		ImageId     = "rbxassetid://6023426912",
		-- Overridden rarity weights for this crate (nil = use defaults)
		RarityWeights = {
			Common    = 65,
			Uncommon  = 25,
			Rare      = 8,
			Epic      = 2,
			Legendary = 0,
		},
		ItemPool = {
			"sword_basic", "hat_simple", "badge_bronze", "backpack_worn", "ring_copper",
			"sword_iron",  "hat_jester", "shield_wood",  "boots_leather", "badge_silver",
			"sword_steel", "hat_wizard", "shield_iron",  "ring_silver",   "cloak_shadows",
			"sword_enchanted", "hat_crown", "wings_obsidian", "ring_gold",
		},
	},
	{
		Id          = "warrior_crate",
		DisplayName = "Warrior Crate",
		Description = "Packed with combat gear and rare blades.",
		Cost        = 300,
		Color       = Color3.fromRGB(220, 80, 80),
		ImageId     = "rbxassetid://6023426912",
		RarityWeights = {
			Common    = 50,
			Uncommon  = 28,
			Rare      = 15,
			Epic      = 6,
			Legendary = 1,
		},
		ItemPool = {
			"sword_basic",     "sword_iron",    "sword_steel",
			"sword_enchanted", "sword_legendary",
			"shield_wood",     "shield_iron",
			"boots_leather",   "cloak_shadows",
		},
	},
	{
		Id          = "prestige_crate",
		DisplayName = "Prestige Crate",
		Description = "The ultimate crate. High chance of Epic and Legendary items.",
		Cost        = 1000,
		Color       = Color3.fromRGB(255, 200, 30),
		ImageId     = "rbxassetid://6023426912",
		RarityWeights = {
			Common    = 20,
			Uncommon  = 25,
			Rare      = 30,
			Epic      = 18,
			Legendary = 7,
		},
		ItemPool = {
			"sword_steel",      "hat_wizard",      "shield_iron",    "ring_silver",    "cloak_shadows",
			"sword_enchanted",  "hat_crown",        "wings_obsidian", "ring_gold",
			"sword_legendary",  "hat_dominus",      "wings_celestial","aura_rainbow",
		},
	},
}

-- Build lookup by Id
CrateDatabase.ById = {}
for _, crate in ipairs(CrateDatabase.Crates) do
	CrateDatabase.ById[crate.Id] = crate
end

return CrateDatabase
