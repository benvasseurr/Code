-- SharedConfig.lua
-- Shared constants used by both client and server.

local SharedConfig = {}

SharedConfig.CURRENCY_NAME       = "Coins"
SharedConfig.STARTING_COINS      = 500           -- coins given on first join
SharedConfig.DAILY_BONUS_COINS   = 200           -- coins granted once per day
SharedConfig.DATASTORE_KEY       = "PlayerData_v3"

-- How many items show in the spinning reel before the result is revealed
SharedConfig.SPIN_ITEM_COUNT     = 20
-- Duration (seconds) of the crate opening animation
SharedConfig.SPIN_DURATION       = 3.5

-- Sell prices per rarity (when player sells an item)
SharedConfig.SELL_PRICES = {
	Common    = 20,
	Uncommon  = 60,
	Rare      = 200,
	Epic      = 600,
	Legendary = 2500,
}

return SharedConfig
