-- ItemDatabase.lua
-- All items are official Roblox-created limited catalog items.
-- Thumbnails use rbxthumb:// which loads automatically in-game.
-- Rarities are assigned by approximate market value (highest value = rarest).

local ItemDatabase = {}

local function thumb(id)
	return "rbxthumb://type=Asset&id=" .. id .. "&w=150&h=150"
end

ItemDatabase.Rarities = {
	Common    = { Name = "Common",    Color = Color3.fromRGB(180, 180, 180), Weight = 60  },
	Uncommon  = { Name = "Uncommon",  Color = Color3.fromRGB(80,  200, 80),  Weight = 25  },
	Rare      = { Name = "Rare",      Color = Color3.fromRGB(80,  130, 220), Weight = 10  },
	Epic      = { Name = "Epic",      Color = Color3.fromRGB(160, 80,  220), Weight = 4   },
	Legendary = { Name = "Legendary", Color = Color3.fromRGB(255, 190, 30),  Weight = 1   },
}

ItemDatabase.Items = {

	-- ── LEGENDARY (highest value items) ─────────────────────────────────────
	{
		Id = "dominus_empyreus",
		DisplayName = "Dominus Empyreus",
		Rarity = "Legendary",
		Description = "One of the most valuable and iconic hats on Roblox.",
		ImageId = thumb("21070012"),
	},
	{
		Id = "headless_horseman",
		DisplayName = "Headless Horseman",
		Rarity = "Legendary",
		Description = "The legendary headless package. Extremely sought after.",
		ImageId = thumb("134082579"),
	},
	{
		Id = "split_equinox",
		DisplayName = "Split Equinox",
		Rarity = "Legendary",
		Description = "A stunning high-value Roblox limited.",
		ImageId = thumb("2566049121"),
	},
	{
		Id = "tython",
		DisplayName = "Tython",
		Rarity = "Legendary",
		Description = "A rare and valuable Roblox original limited.",
		ImageId = thumb("172307899"),
	},

	-- ── EPIC ─────────────────────────────────────────────────────────────────
	{
		Id = "chrononaut_knight",
		DisplayName = "Chrononaut Knight",
		Rarity = "Epic",
		Description = "A knight from another era.",
		ImageId = thumb("230768139"),
	},
	{
		Id = "galaxy_zack",
		DisplayName = "Galaxy Zack: Hello, Nebulon!",
		Rarity = "Epic",
		Description = "An out-of-this-world Roblox limited.",
		ImageId = thumb("110204666"),
	},
	{
		Id = "emerald_ambassador",
		DisplayName = "Emerald Ambassador",
		Rarity = "Epic",
		Description = "A distinguished green ambassador hat.",
		ImageId = thumb("66330060"),
	},
	{
		Id = "double_sided_techno_axe",
		DisplayName = "Double Sided Techno Axe",
		Rarity = "Epic",
		Description = "A futuristic dual-bladed weapon.",
		ImageId = thumb("8664999198"),
	},
	{
		Id = "tiger_mask",
		DisplayName = "Tiger Mask",
		Rarity = "Epic",
		Description = "Fierce and rare tiger-themed face accessory.",
		ImageId = thumb("14205082676"),
	},

	-- ── RARE ─────────────────────────────────────────────────────────────────
	{
		Id = "robot_ninja",
		DisplayName = "Robot Ninja",
		Rarity = "Rare",
		Description = "A mechanical ninja from Roblox's early days.",
		ImageId = thumb("26776961"),
	},
	{
		Id = "fire_ruby_crest",
		DisplayName = "Fire Ruby Crest",
		Rarity = "Rare",
		Description = "A blazing ruby crest of rare quality.",
		ImageId = thumb("17735316"),
	},
	{
		Id = "slime_sunglasses",
		DisplayName = "Slime Sunglasses",
		Rarity = "Rare",
		Description = "Oozing with style.",
		ImageId = thumb("95956628"),
	},
	{
		Id = "unbeelievable_disguise",
		DisplayName = "UnBeelievable Disguise",
		Rarity = "Rare",
		Description = "You won't bee-lieve how rare this is.",
		ImageId = thumb("1427986170"),
	},
	{
		Id = "retro_shades",
		DisplayName = "80's Retro Shades",
		Rarity = "Rare",
		Description = "Classic retro sunglasses from a bygone era.",
		ImageId = thumb("12579496310"),
	},
	{
		Id = "azure_mines_pickaxe",
		DisplayName = "Azure Mines Pickaxe",
		Rarity = "Rare",
		Description = "A pickaxe from the depths of Azure Mines.",
		ImageId = thumb("583030187"),
	},
	{
		Id = "deluxe_slime_ray",
		DisplayName = "Deluxe Slime Ray",
		Rarity = "Rare",
		Description = "Shoots slime in the most deluxe way possible.",
		ImageId = thumb("503957703"),
	},

	-- ── UNCOMMON ─────────────────────────────────────────────────────────────
	{
		Id = "colonels_cavalry_sabre",
		DisplayName = "Colonel's Cavalry Sabre",
		Rarity = "Uncommon",
		Description = "A classic Roblox cavalry sword.",
		ImageId = thumb("49052716"),
	},
	{
		Id = "buckled_stove_top_hat",
		DisplayName = "Buckled Stove Top Hat",
		Rarity = "Uncommon",
		Description = "Tall, buckled, and distinctly Roblox.",
		ImageId = thumb("51242808"),
	},
	{
		Id = "weekend_warrior",
		DisplayName = "Weekend Warrior",
		Rarity = "Uncommon",
		Description = "Ready for battle on the weekend.",
		ImageId = thumb("63995612"),
	},
	{
		Id = "green_slate_hood",
		DisplayName = "Green Slate Hood",
		Rarity = "Uncommon",
		Description = "A smooth green hooded accessory.",
		ImageId = thumb("221259172"),
	},
	{
		Id = "pig_snout_hat",
		DisplayName = "Pig Snout Hat",
		Rarity = "Uncommon",
		Description = "Oink. Just oink.",
		ImageId = thumb("6590440878"),
	},
	{
		Id = "crumbled_sandcastle_hat",
		DisplayName = "Crumbled Sandcastle Hat",
		Rarity = "Uncommon",
		Description = "A sandcastle that didn't survive the tide.",
		ImageId = thumb("9992313179"),
	},
	{
		Id = "party_gents_cap",
		DisplayName = "Party Gent's Cap",
		Rarity = "Uncommon",
		Description = "For the gentleman who loves to party.",
		ImageId = thumb("15694250968"),
	},

	-- ── COMMON ────────────────────────────────────────────────────────────────
	{
		Id = "toy_fall",
		DisplayName = "Toy Fall",
		Rarity = "Common",
		Description = "A classic Roblox toy animation.",
		ImageId = thumb("973768058"),
	},
	{
		Id = "freezing_elf_torso",
		DisplayName = "Freezing Elf Torso",
		Rarity = "Common",
		Description = "Brr. A chilly elf torso piece.",
		ImageId = thumb("1213371194"),
	},
	{
		Id = "adventurous_hiker_leg",
		DisplayName = "Adventurous Hiker Left Leg",
		Rarity = "Common",
		Description = "Part of the Adventurous Hiker package.",
		ImageId = thumb("2016223164"),
	},
	{
		Id = "rugged_survivalist_arm",
		DisplayName = "Rugged Survivalist Right Arm",
		Rarity = "Common",
		Description = "Part of the Rugged Survivalist package.",
		ImageId = thumb("743708567"),
	},
	{
		Id = "locomotion_astronaut_jump",
		DisplayName = "Locomotion Astronaut Jump",
		Rarity = "Common",
		Description = "Jump like an astronaut.",
		ImageId = thumb("10922539792"),
	},
	{
		Id = "concerned_head",
		DisplayName = "Concerned Head",
		Rarity = "Common",
		Description = "A worried Roblox head.",
		ImageId = thumb("15492181060"),
	},
	{
		Id = "bold_swim",
		DisplayName = "Bold Swim",
		Rarity = "Common",
		Description = "A bold swimming animation.",
		ImageId = thumb("16744217055"),
	},
}

-- Build lookup tables
ItemDatabase.ById = {}
for _, item in ipairs(ItemDatabase.Items) do
	ItemDatabase.ById[item.Id] = item
end

ItemDatabase.ByRarity = {}
for _, rarity in pairs(ItemDatabase.Rarities) do
	ItemDatabase.ByRarity[rarity.Name] = {}
end
for _, item in ipairs(ItemDatabase.Items) do
	local bucket = ItemDatabase.ByRarity[item.Rarity]
	if bucket then table.insert(bucket, item) end
end

return ItemDatabase
