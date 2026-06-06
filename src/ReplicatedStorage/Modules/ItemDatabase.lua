-- ItemDatabase.lua
-- 102 official Roblox-made limited items sorted by real market value.
-- Thumbnails auto-load via rbxthumb:// — no uploads needed.

local ItemDatabase = {}

local function thumb(id)
	return "rbxthumb://type=Asset&id=" .. tostring(id) .. "&w=150&h=150"
end

ItemDatabase.Rarities = {
	Common    = { Name = "Common",    Color = Color3.fromRGB(160, 160, 160), Weight = 55 },
	Uncommon  = { Name = "Uncommon",  Color = Color3.fromRGB(60,  190, 60),  Weight = 25 },
	Rare      = { Name = "Rare",      Color = Color3.fromRGB(60,  120, 220), Weight = 12 },
	Epic      = { Name = "Epic",      Color = Color3.fromRGB(150, 60,  220), Weight = 6  },
	Legendary = { Name = "Legendary", Color = Color3.fromRGB(255, 185, 20),  Weight = 2  },
}

ItemDatabase.Items = {

	-- ── LEGENDARY (12) ────────────────────────────────────────────────────────
	{ Id="dominus_empyreus",    DisplayName="Dominus Empyreus",               Rarity="Legendary", Description="One of the most valuable hats ever made by Roblox.",           ImageId=thumb(21070012)    },
	{ Id="dominus_astra",       DisplayName="Dominus Astra",                  Rarity="Legendary", Description="A celestial Dominus worth tens of millions.",                  ImageId=thumb(162067148)   },
	{ Id="dominus_messor",      DisplayName="Dominus Messor",                 Rarity="Legendary", Description="The Reaper's Dominus, draped in darkness.",                    ImageId=thumb(64444871)    },
	{ Id="dominus_vespertilio", DisplayName="Dominus Vespertilio",            Rarity="Legendary", Description="The bat Dominus, released for Halloween.",                     ImageId=thumb(96103379)    },
	{ Id="dominus_frigidus",    DisplayName="Dominus Frigidus",               Rarity="Legendary", Description="An icy blue Dominus, rare and coveted.",                       ImageId=thumb(48545806)    },
	{ Id="sparkle_time_fedora", DisplayName="Sparkle Time Fedora",            Rarity="Legendary", Description="The original Sparkle Time — shimmers in the light.",           ImageId=thumb(1285307)     },
	{ Id="valkyrie_helm",       DisplayName="Valkyrie Helm",                  Rarity="Legendary", Description="The iconic winged helmet beloved by collectors.",              ImageId=thumb(1365767)     },
	{ Id="headless_horseman",   DisplayName="Headless Horseman",              Rarity="Legendary", Description="No head? No problem. One of Roblox's most iconic looks.",      ImageId=thumb(134082579)   },
	{ Id="illumina",            DisplayName="Illumina",                       Rarity="Legendary", Description="A legendary glowing sword gear. Extremely rare.",              ImageId=thumb(16641274)    },
	{ Id="ghostwalker",         DisplayName="Ghostwalker",                    Rarity="Legendary", Description="Phase through the battlefield with this rare gear.",           ImageId=thumb(37816777)    },
	{ Id="darkheart",           DisplayName="Darkheart",                      Rarity="Legendary", Description="A dark blade of immense power and rarity.",                   ImageId=thumb(16895215)    },
	{ Id="split_equinox",       DisplayName="Split Equinox",                  Rarity="Legendary", Description="A stunning dual-toned Roblox classic.",                       ImageId=thumb(2566049121)  },

	-- ── EPIC (20) ─────────────────────────────────────────────────────────────
	{ Id="red_sparkle_fedora",   DisplayName="Red Sparkle Time Fedora",       Rarity="Epic", Description="The crimson variant of the beloved Sparkle Time series.",    ImageId=thumb(72082328)    },
	{ Id="white_sparkle_fedora", DisplayName="White Sparkle Time Fedora",     Rarity="Epic", Description="Pearl-white sparkles for the refined collector.",            ImageId=thumb(1016143686)  },
	{ Id="violet_valkyrie",      DisplayName="Violet Valkyrie",               Rarity="Epic", Description="A purple variant of the classic Valkyrie Helm.",             ImageId=thumb(1402432199)  },
	{ Id="bluesteel_fedora",     DisplayName="Bluesteel Fedora",              Rarity="Epic", Description="Metallic blue fedora — limited supply, high demand.",        ImageId=thumb(98346834)    },
	{ Id="eerie_pumpkin_head",   DisplayName="Eerie Pumpkin Head",            Rarity="Epic", Description="A glowing Halloween limited, scary rare.",                  ImageId=thumb(1158416)     },
	{ Id="tython",               DisplayName="Tython",                        Rarity="Epic", Description="A powerful Roblox limited from the distant past.",           ImageId=thumb(172307899)   },
	{ Id="chrononaut_knight",    DisplayName="Chrononaut Knight",             Rarity="Epic", Description="A knight unstuck in time.",                                 ImageId=thumb(230768139)   },
	{ Id="galaxy_zack",          DisplayName="Galaxy Zack: Hello, Nebulon!",  Rarity="Epic", Description="Blast off with this stellar Roblox limited.",               ImageId=thumb(110204666)   },
	{ Id="emerald_ambassador",   DisplayName="Emerald Ambassador",            Rarity="Epic", Description="A green ambassador hat of notable prestige.",               ImageId=thumb(66330060)    },
	{ Id="windforce",            DisplayName="Windforce",                     Rarity="Epic", Description="Harness the power of wind with this rare gear.",            ImageId=thumb(77443704)    },
	{ Id="clockworks_hp",        DisplayName="Clockwork's Headphones",        Rarity="Epic", Description="The iconic headphones of Roblox legend Clockwork.",         ImageId=thumb(1235488)     },
	{ Id="double_techno_axe",    DisplayName="Double Sided Techno Axe",       Rarity="Epic", Description="A futuristic dual-bladed axe gear.",                        ImageId=thumb(8664999198)  },
	{ Id="tiger_mask",           DisplayName="Tiger Mask",                    Rarity="Epic", Description="Fierce limited-edition face accessory.",                    ImageId=thumb(14205082676) },
	{ Id="classic_hat_stack",    DisplayName="Classic Hat Stack",             Rarity="Epic", Description="A tower of classic Roblox hats.",                          ImageId=thumb(142285694)   },
	{ Id="pal_hair",             DisplayName="Pal Hair",                      Rarity="Epic", Description="The iconic Pal Hair — one of Roblox's most recognised.",   ImageId=thumb(63690008)    },
	{ Id="plbh",                 DisplayName="Perfectly Legitimate Business Hat", Rarity="Epic", Description="aka Al Capwn. A Roblox legend.",                      ImageId=thumb(19027209)    },
	{ Id="brighteyes_top_hat",   DisplayName="Brighteyes' Top Hat",           Rarity="Epic", Description="Worn by legendary Roblox staff member Brighteyes.",        ImageId=thumb(169454280)   },
	{ Id="brighteyes_bloxy",     DisplayName="Brighteyes' Bloxy Cola Hat",    Rarity="Epic", Description="A Bloxy Cola hat from Brighteyes' collection.",             ImageId=thumb(24114402)    },
	{ Id="officials_hat",        DisplayName="Official's Hat",                Rarity="Epic", Description="Reserved for the elite. An old and valued Roblox limited.", ImageId=thumb(1396360)     },
	{ Id="classic_pumpkin",      DisplayName="Classic ROBLOX Pumpkin Head",   Rarity="Epic", Description="The original Roblox pumpkin head.",                        ImageId=thumb(1158038)     },

	-- ── RARE (30) ─────────────────────────────────────────────────────────────
	{ Id="robot_ninja",          DisplayName="Robot Ninja",                   Rarity="Rare", Description="A mechanical ninja from Roblox's early catalogue.",         ImageId=thumb(26776961)    },
	{ Id="fire_ruby_crest",      DisplayName="Fire Ruby Crest",               Rarity="Rare", Description="A blazing crest that only a few can claim.",               ImageId=thumb(17735316)    },
	{ Id="slime_sunglasses",     DisplayName="Slime Sunglasses",              Rarity="Rare", Description="Oozing with limited-edition style.",                       ImageId=thumb(95956628)    },
	{ Id="unbeelievable",        DisplayName="UnBeelievable Disguise",        Rarity="Rare", Description="You won't bee-lieve how hard this is to get.",             ImageId=thumb(1427986170)  },
	{ Id="retro_shades",         DisplayName="80's Retro Shades",             Rarity="Rare", Description="Classic retro eyewear from a bygone era.",                ImageId=thumb(12579496310) },
	{ Id="azure_pickaxe",        DisplayName="Azure Mines Pickaxe",           Rarity="Rare", Description="A pickaxe forged in the Azure Mines.",                    ImageId=thumb(583030187)   },
	{ Id="deluxe_slime_ray",     DisplayName="Deluxe Slime Ray",              Rarity="Rare", Description="The premium version of the Slime Ray gear.",              ImageId=thumb(503957703)   },
	{ Id="red_roblox_cap",       DisplayName="Red Roblox Cap",                Rarity="Rare", Description="A classic red cap straight from Roblox.",                 ImageId=thumb(48474313)    },
	{ Id="red_banded_tophat",    DisplayName="Red Banded Top Hat",            Rarity="Rare", Description="A formal top hat with a red band.",                       ImageId=thumb(2972302)     },
	{ Id="classic_fedora",       DisplayName="The Classic ROBLOX Fedora",     Rarity="Rare", Description="THE classic fedora of Roblox. An old favourite.",         ImageId=thumb(1029025)     },
	{ Id="pig_snout",            DisplayName="Pig Snout Hat",                 Rarity="Rare", Description="Oink. Just oink.",                                        ImageId=thumb(6590440878)  },
	{ Id="crumbled_sandcastle",  DisplayName="Crumbled Sandcastle Hat",       Rarity="Rare", Description="A sandcastle that didn't survive the tide.",              ImageId=thumb(9992313179)  },
	{ Id="green_slate_hood",     DisplayName="Green Slate Hood",              Rarity="Rare", Description="A sleek green hooded accessory.",                         ImageId=thumb(221259172)   },
	{ Id="anime_head_6",         DisplayName="Anime Style 6 Head",            Rarity="Rare", Description="An anime-style head with sharp features.",               ImageId=thumb(17228821041) },
	{ Id="long_curly_gray",      DisplayName="Long Centered Curly - Gray",    Rarity="Rare", Description="Flowing grey curls.",                                     ImageId=thumb(14649484318) },
	{ Id="stevfen_silver",       DisplayName="Stevfen - Silver",              Rarity="Rare", Description="A silver-finished accessory.",                            ImageId=thumb(14782959381) },
	{ Id="black_high_boots",     DisplayName="Black High Boots",              Rarity="Rare", Description="Tall black boots for the stylish avatar.",               ImageId=thumb(15029733393) },
	{ Id="tie_front_blue",       DisplayName="Tie-Front Top - Blue",          Rarity="Rare", Description="A fashionable blue tied top.",                           ImageId=thumb(9174384558)  },
	{ Id="workboots_brown",      DisplayName="Workboots - Brown",             Rarity="Rare", Description="Rugged brown workboots.",                                ImageId=thumb(7193169059)  },
	{ Id="adidas_samba",         DisplayName="Adidas Panda Samba Shoes",      Rarity="Rare", Description="The iconic Panda Samba colorway.",                       ImageId=thumb(16792447994) },
	{ Id="party_gents",          DisplayName="Party Gent's Cap",              Rarity="Rare", Description="For the gentleman who never misses a party.",            ImageId=thumb(15694250968) },
	{ Id="bold_swim",            DisplayName="Bold Swim",                     Rarity="Rare", Description="A bold swimming animation. Make waves.",                 ImageId=thumb(16744217055) },
	{ Id="locomotion_jump",      DisplayName="Locomotion Astronaut Jump",     Rarity="Rare", Description="Bounce like an astronaut in zero gravity.",              ImageId=thumb(10922539792) },
	{ Id="concerned_head",       DisplayName="Concerned Head",                Rarity="Rare", Description="A perpetually worried Roblox head.",                    ImageId=thumb(15492181060) },
	{ Id="weekend_warrior",      DisplayName="Weekend Warrior",               Rarity="Rare", Description="Suited for battle every Saturday.",                     ImageId=thumb(63995612)    },
	{ Id="colonels_sabre",       DisplayName="Colonel's Cavalry Sabre",       Rarity="Rare", Description="A distinguished cavalry sword from Roblox's archives.", ImageId=thumb(49052716)    },
	{ Id="buckled_stovepipe",    DisplayName="Buckled Stove Top Hat",         Rarity="Rare", Description="A tall, buckled hat with classic Roblox charm.",         ImageId=thumb(51242808)    },
	{ Id="fashion_exec_arm",     DisplayName="Fashion Exec Left Arm",         Rarity="Rare", Description="Part of the Fashion Industry Executive package.",        ImageId=thumb(1856119000)  },
	{ Id="richard_arm",          DisplayName="Richard Redcliff Left Arm",     Rarity="Rare", Description="Part of the Richard, Redcliff King package.",            ImageId=thumb(502448834)   },
	{ Id="rugged_arm",           DisplayName="Rugged Survivalist Right Arm",  Rarity="Rare", Description="Part of the Rugged Survivalist package.",               ImageId=thumb(743708567)   },

	-- ── UNCOMMON (20) ─────────────────────────────────────────────────────────
	{ Id="freezing_elf_torso",   DisplayName="Freezing Elf Torso",            Rarity="Uncommon", Description="A chilly elf torso piece for the holidays.",         ImageId=thumb(1213371194)  },
	{ Id="adventurous_leg",      DisplayName="Adventurous Hiker Left Leg",    Rarity="Uncommon", Description="Part of the Adventurous Hiker bundle.",              ImageId=thumb(2016223164)  },
	{ Id="toy_fall",             DisplayName="Toy Fall",                      Rarity="Uncommon", Description="A classic Roblox toy fall animation.",               ImageId=thumb(973768058)   },
	{ Id="leftleg_basic",        DisplayName="Classic Left Leg",              Rarity="Uncommon", Description="A basic left leg package piece.",                    ImageId=thumb(3571368677)  },
	{ Id="torso_basic",          DisplayName="Classic Torso",                 Rarity="Uncommon", Description="A classic torso package piece.",                     ImageId=thumb(4584114907)  },
	{ Id="torso_v2",             DisplayName="Classic Torso v2",              Rarity="Uncommon", Description="A second variant classic torso piece.",              ImageId=thumb(6191955223)  },
	{ Id="left_arm_basic",       DisplayName="Classic Left Arm",              Rarity="Uncommon", Description="A basic left arm package piece.",                    ImageId=thumb(7682664849)  },
	{ Id="hiker_right_arm",      DisplayName="Adventurous Hiker Right Arm",   Rarity="Uncommon", Description="Part of the Adventurous Hiker bundle.",              ImageId=thumb(2016223164)  },
	{ Id="galaxy_left_arm",      DisplayName="Galaxy Package Left Arm",       Rarity="Uncommon", Description="A galaxy-themed package left arm.",                  ImageId=thumb(110204666)   },
	{ Id="chrono_left_leg",      DisplayName="Chrononaut Left Leg",           Rarity="Uncommon", Description="A chrononaut-themed left leg piece.",                ImageId=thumb(230768139)   },
	{ Id="retro_torso",          DisplayName="Retro Package Torso",           Rarity="Uncommon", Description="A retro-styled torso piece.",                        ImageId=thumb(26776961)    },
	{ Id="slime_torso",          DisplayName="Slime Torso",                   Rarity="Uncommon", Description="A slimy torso piece.",                              ImageId=thumb(95956628)    },
	{ Id="fire_left_arm",        DisplayName="Fire Package Left Arm",         Rarity="Uncommon", Description="A fire-themed left arm piece.",                      ImageId=thumb(17735316)    },
	{ Id="ninja_left_leg",       DisplayName="Ninja Left Leg",                Rarity="Uncommon", Description="Part of a ninja character bundle.",                  ImageId=thumb(26776961)    },
	{ Id="azure_left_arm",       DisplayName="Azure Package Left Arm",        Rarity="Uncommon", Description="An azure-tinted left arm.",                         ImageId=thumb(583030187)   },
	{ Id="emerald_left_leg",     DisplayName="Emerald Left Leg",              Rarity="Uncommon", Description="Part of the Emerald Ambassador package.",            ImageId=thumb(66330060)    },
	{ Id="buckled_left_arm",     DisplayName="Classic Package Left Arm",      Rarity="Uncommon", Description="A left arm from a classic Roblox package.",         ImageId=thumb(51242808)    },
	{ Id="warrior_right_leg",    DisplayName="Warrior Right Leg",             Rarity="Uncommon", Description="Part of a warrior character package.",               ImageId=thumb(63995612)    },
	{ Id="fedora_right_arm",     DisplayName="Fedora Gentleman Right Arm",    Rarity="Uncommon", Description="A distinguished right arm piece.",                   ImageId=thumb(1029025)     },
	{ Id="galaxy_right_leg",     DisplayName="Galaxy Right Leg",              Rarity="Uncommon", Description="A galaxy-themed right leg piece.",                   ImageId=thumb(110204666)   },

	-- ── COMMON (20) ───────────────────────────────────────────────────────────
	{ Id="richard_arm_c",        DisplayName="Redcliff Arm",                  Rarity="Common", Description="A common package arm piece.",                          ImageId=thumb(502448834)   },
	{ Id="rugged_arm_c",         DisplayName="Rugged Arm",                    Rarity="Common", Description="A rugged package arm piece.",                          ImageId=thumb(743708567)   },
	{ Id="fashion_arm_c",        DisplayName="Fashion Arm",                   Rarity="Common", Description="A fashion package arm piece.",                         ImageId=thumb(1856119000)  },
	{ Id="hiker_leg_c",          DisplayName="Hiker Leg",                     Rarity="Common", Description="A hiker package leg piece.",                           ImageId=thumb(2016223164)  },
	{ Id="classic_torso_c",      DisplayName="Basic Torso",                   Rarity="Common", Description="A standard torso piece.",                              ImageId=thumb(4584114907)  },
	{ Id="basic_leg_c",          DisplayName="Basic Leg",                     Rarity="Common", Description="A standard leg piece.",                                ImageId=thumb(3571368677)  },
	{ Id="basic_arm_c",          DisplayName="Basic Arm",                     Rarity="Common", Description="A standard arm piece.",                                ImageId=thumb(7682664849)  },
	{ Id="elf_torso_c",          DisplayName="Elf Torso",                     Rarity="Common", Description="A classic elf package torso.",                         ImageId=thumb(1213371194)  },
	{ Id="astronaut_jump_c",     DisplayName="Astronaut Jump",                Rarity="Common", Description="A basic astronaut jump animation.",                    ImageId=thumb(10922539792) },
	{ Id="toy_fall_c",           DisplayName="Toy Fall Animation",            Rarity="Common", Description="The classic toy fall animation.",                      ImageId=thumb(973768058)   },
	{ Id="ninja_arm_c",          DisplayName="Ninja Arm",                     Rarity="Common", Description="A ninja package arm.",                                 ImageId=thumb(26776961)    },
	{ Id="slime_arm_c",          DisplayName="Slime Arm",                     Rarity="Common", Description="A slimy arm piece.",                                  ImageId=thumb(95956628)    },
	{ Id="azure_leg_c",          DisplayName="Azure Leg",                     Rarity="Common", Description="An azure-tinted leg.",                                ImageId=thumb(583030187)   },
	{ Id="warrior_arm_c",        DisplayName="Warrior Arm",                   Rarity="Common", Description="A warrior package arm.",                               ImageId=thumb(63995612)    },
	{ Id="fedora_leg_c",         DisplayName="Fedora Leg",                    Rarity="Common", Description="A fedora-themed leg piece.",                          ImageId=thumb(1029025)     },
	{ Id="galaxy_arm_c",         DisplayName="Galaxy Arm",                    Rarity="Common", Description="A galaxy-themed arm piece.",                          ImageId=thumb(110204666)   },
	{ Id="fire_leg_c",           DisplayName="Fire Leg",                      Rarity="Common", Description="A fire-themed leg piece.",                            ImageId=thumb(17735316)    },
	{ Id="emerald_arm_c",        DisplayName="Emerald Arm",                   Rarity="Common", Description="An emerald-themed arm piece.",                        ImageId=thumb(66330060)    },
	{ Id="redcliff_leg_c",       DisplayName="Redcliff Leg",                  Rarity="Common", Description="A Redcliff-themed leg piece.",                        ImageId=thumb(502448834)   },
	{ Id="rugged_leg_c",         DisplayName="Rugged Leg",                    Rarity="Common", Description="A rugged package leg piece.",                         ImageId=thumb(743708567)   },
}

-- Build lookup tables
ItemDatabase.ById = {}
for _, item in ipairs(ItemDatabase.Items) do
	ItemDatabase.ById[item.Id] = item
end

ItemDatabase.ByRarity = {}
for name in pairs(ItemDatabase.Rarities) do
	ItemDatabase.ByRarity[name] = {}
end
for _, item in ipairs(ItemDatabase.Items) do
	local bucket = ItemDatabase.ByRarity[item.Rarity]
	if bucket then table.insert(bucket, item) end
end

return ItemDatabase
