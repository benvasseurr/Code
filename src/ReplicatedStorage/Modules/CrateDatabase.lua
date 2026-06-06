-- CrateDatabase.lua
-- 10 themed crates. Each pool has 10 items: 1 Legendary, 2 Epic, 3 Rare, 2 Uncommon, 2 Common.
-- More expensive crates have better rarity odds.

local CrateDatabase = {}

CrateDatabase.Crates = {

	-- ── 1. VINTAGE CRATE ──────────────────────────────────────────────────────
	{
		Id = "vintage_crate", DisplayName = "Vintage Crate",
		Description = "The oldest Roblox classics. Nostalgic drops at a low price.",
		Cost = 100, Color = Color3.fromRGB(160, 120, 70),
		ImageId = "rbxthumb://type=Asset&id=1029025&w=150&h=150",
		RarityWeights = { Common=60, Uncommon=25, Rare=12, Epic=2, Legendary=1 },
		ItemPool = {
			"dominus_empyreus",                          -- Legendary
			"officials_hat", "classic_pumpkin",          -- Epic
			"classic_fedora", "red_roblox_cap", "red_banded_tophat", -- Rare
			"torso_basic", "leftleg_basic",              -- Uncommon
			"classic_torso_c", "basic_leg_c",            -- Common
		},
	},

	-- ── 2. HALLOWEEN CRATE ────────────────────────────────────────────────────
	{
		Id = "halloween_crate", DisplayName = "Halloween Crate",
		Description = "Spooky limiteds — pumpkins, bats and things that go bump.",
		Cost = 250, Color = Color3.fromRGB(220, 100, 20),
		ImageId = "rbxthumb://type=Asset&id=1158416&w=150&h=150",
		RarityWeights = { Common=55, Uncommon=25, Rare=12, Epic=6, Legendary=2 },
		ItemPool = {
			"dominus_vespertilio",                       -- Legendary
			"eerie_pumpkin_head", "classic_pumpkin",     -- Epic
			"pig_snout", "crumbled_sandcastle", "green_slate_hood", -- Rare
			"freezing_elf_torso", "toy_fall",            -- Uncommon
			"elf_torso_c", "toy_fall_c",                 -- Common
		},
	},

	-- ── 3. ANIMATION CRATE ────────────────────────────────────────────────────
	{
		Id = "animation_crate", DisplayName = "Animation Crate",
		Description = "Emotes, jumps and swim animations for your avatar.",
		Cost = 350, Color = Color3.fromRGB(60, 180, 200),
		ImageId = "rbxthumb://type=Asset&id=10922539792&w=150&h=150",
		RarityWeights = { Common=55, Uncommon=25, Rare=12, Epic=6, Legendary=2 },
		ItemPool = {
			"ghostwalker",                               -- Legendary
			"brighteyes_top_hat", "brighteyes_bloxy",   -- Epic
			"bold_swim", "locomotion_jump", "concerned_head", -- Rare
			"toy_fall", "adventurous_leg",               -- Uncommon
			"astronaut_jump_c", "toy_fall_c",            -- Common
		},
	},

	-- ── 4. ACCESSORIES CRATE ──────────────────────────────────────────────────
	{
		Id = "accessories_crate", DisplayName = "Accessories Crate",
		Description = "Hats, hair, shades and more. Style your avatar properly.",
		Cost = 500, Color = Color3.fromRGB(180, 80, 180),
		ImageId = "rbxthumb://type=Asset&id=63690008&w=150&h=150",
		RarityWeights = { Common=50, Uncommon=25, Rare=15, Epic=7, Legendary=3 },
		ItemPool = {
			"sparkle_time_fedora",                       -- Legendary
			"pal_hair", "tiger_mask",                    -- Epic
			"slime_sunglasses", "retro_shades", "anime_head_6", -- Rare
			"long_curly_gray", "torso_v2",               -- Uncommon
			"basic_arm_c", "elf_torso_c",                -- Common
		},
	},

	-- ── 5. GEAR CRATE ─────────────────────────────────────────────────────────
	{
		Id = "gear_crate", DisplayName = "Gear Crate",
		Description = "Swords, rays and battle gear. Equip yourself for war.",
		Cost = 800, Color = Color3.fromRGB(200, 60, 60),
		ImageId = "rbxthumb://type=Asset&id=16895215&w=150&h=150",
		RarityWeights = { Common=45, Uncommon=25, Rare=18, Epic=8, Legendary=4 },
		ItemPool = {
			"darkheart",                                 -- Legendary
			"windforce", "double_techno_axe",            -- Epic
			"azure_pickaxe", "deluxe_slime_ray", "colonels_sabre", -- Rare
			"rugged_arm", "left_arm_basic",              -- Uncommon
			"rugged_arm_c", "basic_arm_c",               -- Common
		},
	},

	-- ── 6. PACKAGE CRATE ──────────────────────────────────────────────────────
	{
		Id = "package_crate", DisplayName = "Package Crate",
		Description = "Body parts and packages from classic Roblox bundles.",
		Cost = 1000, Color = Color3.fromRGB(80, 160, 100),
		ImageId = "rbxthumb://type=Asset&id=230768139&w=150&h=150",
		RarityWeights = { Common=40, Uncommon=28, Rare=18, Epic=9, Legendary=5 },
		ItemPool = {
			"split_equinox",                             -- Legendary
			"chrononaut_knight", "galaxy_zack",          -- Epic
			"fashion_exec_arm", "richard_arm", "rugged_arm", -- Rare
			"left_arm_basic", "chrono_left_leg",         -- Uncommon
			"classic_torso_c", "hiker_leg_c",            -- Common
		},
	},

	-- ── 7. CLASSIC HAT CRATE ──────────────────────────────────────────────────
	{
		Id = "hat_crate", DisplayName = "Classic Hat Crate",
		Description = "The finest Roblox hats in one crate. Fedoras to legends.",
		Cost = 1500, Color = Color3.fromRGB(220, 180, 40),
		ImageId = "rbxthumb://type=Asset&id=1285307&w=150&h=150",
		RarityWeights = { Common=35, Uncommon=25, Rare=22, Epic=12, Legendary=6 },
		ItemPool = {
			"dominus_messor",                            -- Legendary
			"bluesteel_fedora", "plbh",                  -- Epic
			"classic_fedora", "buckled_stovepipe", "weekend_warrior", -- Rare
			"torso_basic", "adventurous_leg",            -- Uncommon
			"basic_leg_c", "toy_fall_c",                 -- Common
		},
	},

	-- ── 8. VALKYRIE CRATE ─────────────────────────────────────────────────────
	{
		Id = "valkyrie_crate", DisplayName = "Valkyrie Crate",
		Description = "The Valkyrie and Sparkle Time series. Iconic Roblox drops.",
		Cost = 3000, Color = Color3.fromRGB(100, 160, 255),
		ImageId = "rbxthumb://type=Asset&id=1365767&w=150&h=150",
		RarityWeights = { Common=25, Uncommon=22, Rare=25, Epic=18, Legendary=10 },
		ItemPool = {
			"valkyrie_helm",                             -- Legendary
			"violet_valkyrie", "clockworks_hp",          -- Epic
			"red_sparkle_fedora", "white_sparkle_fedora", "robot_ninja", -- Rare
			"galaxy_left_arm", "fire_left_arm",          -- Uncommon
			"basic_arm_c", "elf_torso_c",                -- Common
		},
	},

	-- ── 9. DOMINUS CRATE ──────────────────────────────────────────────────────
	{
		Id = "dominus_crate", DisplayName = "Dominus Crate",
		Description = "Only the rarest Dominus and legendary Roblox limiteds.",
		Cost = 8000, Color = Color3.fromRGB(255, 215, 0),
		ImageId = "rbxthumb://type=Asset&id=21070012&w=150&h=150",
		RarityWeights = { Common=10, Uncommon=15, Rare=25, Epic=30, Legendary=20 },
		ItemPool = {
			"dominus_frigidus",                          -- Legendary
			"emerald_ambassador", "tython",              -- Epic
			"fire_ruby_crest", "unbeelievable", "eerie_pumpkin_head", -- Rare
			"chrono_left_leg", "left_arm_basic",         -- Uncommon
			"basic_arm_c", "classic_torso_c",            -- Common
		},
	},

	-- ── 10. ELITE CRATE ───────────────────────────────────────────────────────
	{
		Id = "elite_crate", DisplayName = "Elite Crate",
		Description = "The absolute rarest items Roblox has ever produced.",
		Cost = 20000, Color = Color3.fromRGB(255, 255, 255),
		ImageId = "rbxthumb://type=Asset&id=134082579&w=150&h=150",
		RarityWeights = { Common=5, Uncommon=10, Rare=20, Epic=35, Legendary=30 },
		ItemPool = {
			"dominus_empyreus",                          -- Legendary
			"illumina", "darkheart",                     -- Legendary as Epic slots (extra rare!)
			"windforce", "clockworks_hp",                -- Epic
			"dominus_astra",                             -- Legendary as bonus
			"galaxy_zack", "emerald_ambassador",         -- Epic
			"rugged_arm", "richard_arm",                 -- Rare
		},
	},
}

-- Build lookup by Id
CrateDatabase.ById = {}
for _, crate in ipairs(CrateDatabase.Crates) do
	CrateDatabase.ById[crate.Id] = crate
end

return CrateDatabase
