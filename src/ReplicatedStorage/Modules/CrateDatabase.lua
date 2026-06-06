-- CrateDatabase.lua
-- Three crates with pools drawn from real Roblox limited items.

local CrateDatabase = {}

CrateDatabase.Crates = {
	{
		Id          = "starter_crate",
		DisplayName = "Starter Crate",
		Description = "Common and Uncommon Roblox limiteds. Great for beginners.",
		Cost        = 100,
		Color       = Color3.fromRGB(100, 160, 255),
		ImageId     = "rbxthumb://type=Asset&id=63995612&w=150&h=150",
		RarityWeights = {
			Common    = 60,
			Uncommon  = 30,
			Rare      = 9,
			Epic      = 1,
			Legendary = 0,
		},
		ItemPool = {
			-- Commons
			"toy_fall", "freezing_elf_torso", "adventurous_hiker_leg",
			"rugged_survivalist_arm", "locomotion_astronaut_jump",
			"concerned_head", "bold_swim",
			-- Uncommons
			"colonels_cavalry_sabre", "buckled_stove_top_hat", "weekend_warrior",
			"green_slate_hood", "pig_snout_hat", "crumbled_sandcastle_hat", "party_gents_cap",
			-- Rare
			"robot_ninja", "fire_ruby_crest", "slime_sunglasses",
			-- Epic (rare chance)
			"emerald_ambassador",
		},
	},
	{
		Id          = "warrior_crate",
		DisplayName = "Warrior Crate",
		Description = "Rare and Epic Roblox limiteds. Higher stakes.",
		Cost        = 300,
		Color       = Color3.fromRGB(220, 80, 80),
		ImageId     = "rbxthumb://type=Asset&id=8664999198&w=150&h=150",
		RarityWeights = {
			Common    = 20,
			Uncommon  = 30,
			Rare      = 35,
			Epic      = 13,
			Legendary = 2,
		},
		ItemPool = {
			-- Commons
			"toy_fall", "bold_swim", "concerned_head",
			-- Uncommons
			"colonels_cavalry_sabre", "weekend_warrior", "pig_snout_hat",
			-- Rares
			"robot_ninja", "fire_ruby_crest", "slime_sunglasses",
			"unbeelievable_disguise", "retro_shades", "azure_mines_pickaxe", "deluxe_slime_ray",
			-- Epics
			"chrononaut_knight", "galaxy_zack", "emerald_ambassador",
			"double_sided_techno_axe", "tiger_mask",
			-- Legendary (small chance)
			"tython", "split_equinox",
		},
	},
	{
		Id          = "prestige_crate",
		DisplayName = "Prestige Crate",
		Description = "The ultimate crate. Real chance at Legendary Roblox limiteds.",
		Cost        = 1000,
		Color       = Color3.fromRGB(255, 200, 30),
		ImageId     = "rbxthumb://type=Asset&id=21070012&w=150&h=150",
		RarityWeights = {
			Common    = 5,
			Uncommon  = 10,
			Rare      = 30,
			Epic      = 35,
			Legendary = 20,
		},
		ItemPool = {
			-- Rares
			"unbeelievable_disguise", "retro_shades", "azure_mines_pickaxe",
			"deluxe_slime_ray", "slime_sunglasses",
			-- Epics
			"chrononaut_knight", "galaxy_zack", "emerald_ambassador",
			"double_sided_techno_axe", "tiger_mask",
			-- Legendaries
			"dominus_empyreus", "headless_horseman", "split_equinox", "tython",
		},
	},
}

CrateDatabase.ById = {}
for _, crate in ipairs(CrateDatabase.Crates) do
	CrateDatabase.ById[crate.Id] = crate
end

return CrateDatabase
