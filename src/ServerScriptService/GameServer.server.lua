-- GameServer.server.lua
-- Core server logic: crate opening, currency, daily bonus, selling items.

local Players          = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedConfig  = require(ReplicatedStorage.Modules.SharedConfig)
local ItemDatabase  = require(ReplicatedStorage.Modules.ItemDatabase)
local CrateDatabase = require(ReplicatedStorage.Modules.CrateDatabase)
local DataManager   = require(script.Parent.DataManager)

-- ────────────────────────────────────────────────────────────────────────────
-- Remote setup (created once here; client accesses via WaitForChild)
-- ────────────────────────────────────────────────────────────────────────────
local Remotes = Instance.new("Folder")
Remotes.Name  = "Remotes"
Remotes.Parent = ReplicatedStorage

local function makeEvent(name)
	local e = Instance.new("RemoteEvent")
	e.Name   = name
	e.Parent = Remotes
	return e
end

local function makeFunction(name)
	local f = Instance.new("RemoteFunction")
	f.Name   = name
	f.Parent = Remotes
	return f
end

-- Events (server → client broadcasts)
local UpdateCurrencyEvent = makeEvent("UpdateCurrency")
local OpenResultEvent     = makeEvent("OpenResult")     -- sends roll result to opening player
local NotifyEvent         = makeEvent("Notify")         -- generic toast notification

-- Functions (client → server request/response)
local GetDataFunction     = makeFunction("GetData")
local OpenCrateFunction   = makeFunction("OpenCrate")
local SellItemFunction    = makeFunction("SellItem")
local ClaimDailyFunction  = makeFunction("ClaimDaily")

-- ────────────────────────────────────────────────────────────────────────────
-- Helpers
-- ────────────────────────────────────────────────────────────────────────────

-- Weighted random selection
local function weightedRandom(weightTable)
	local total = 0
	for _, w in pairs(weightTable) do total += w end
	local roll  = math.random() * total
	local accum = 0
	for key, w in pairs(weightTable) do
		accum += w
		if roll <= accum then return key end
	end
	-- fallback (floating point edge)
	for key in pairs(weightTable) do return key end
end

-- Roll a single item from a crate's pool
local function rollItem(crate)
	-- Filter rarity weights to non-zero entries
	local weights = {}
	for rarity, w in pairs(crate.RarityWeights) do
		if w > 0 and ItemDatabase.ByRarity[rarity] then
			weights[rarity] = w
		end
	end

	local chosenRarity = weightedRandom(weights)

	-- Collect eligible items of that rarity within the pool set
	local poolSet = {}
	for _, id in ipairs(crate.ItemPool) do poolSet[id] = true end

	local eligible = {}
	for _, item in ipairs(ItemDatabase.ByRarity[chosenRarity] or {}) do
		if poolSet[item.Id] then
			table.insert(eligible, item)
		end
	end

	-- If nothing eligible (shouldn't happen with valid data), fall back
	if #eligible == 0 then
		eligible = ItemDatabase.ByRarity[chosenRarity] or ItemDatabase.Items
	end

	return eligible[math.random(1, #eligible)]
end

-- Update the client's displayed coin count
local function syncCurrency(player)
	local data = DataManager.Get(player)
	if data then
		UpdateCurrencyEvent:FireClient(player, data.Coins)
	end
end

-- ────────────────────────────────────────────────────────────────────────────
-- Player lifecycle
-- ────────────────────────────────────────────────────────────────────────────
Players.PlayerAdded:Connect(function(player)
	local data = DataManager.Load(player)
	-- Short wait so client GUI is ready to receive the first sync
	task.wait(2)
	syncCurrency(player)
end)

-- ────────────────────────────────────────────────────────────────────────────
-- Remote handlers
-- ────────────────────────────────────────────────────────────────────────────

-- Return full player data snapshot to the client
GetDataFunction.OnServerInvoke = function(player)
	local data = DataManager.Get(player)
	if not data then return nil end
	-- Return a safe copy
	return {
		Coins     = data.Coins,
		Inventory = data.Inventory,
		LastDaily = data.LastDaily,
		TotalOpens = data.TotalOpens,
	}
end

-- Open a crate: deduct cost, roll item, add to inventory, return result
OpenCrateFunction.OnServerInvoke = function(player, crateId)
	local data  = DataManager.Get(player)
	local crate = CrateDatabase.ById[crateId]

	if not data  then return false, "Data not loaded."        end
	if not crate then return false, "Invalid crate."          end
	if data.Coins < crate.Cost then
		return false, "Not enough " .. SharedConfig.CURRENCY_NAME .. "."
	end

	-- Deduct cost and roll
	data.Coins -= crate.Cost
	data.TotalOpens += 1

	local item = rollItem(crate)

	-- Add to inventory
	table.insert(data.Inventory, {
		ItemId      = item.Id,
		ObtainedAt  = os.time(),
		Slot        = #data.Inventory + 1,
	})

	syncCurrency(player)

	-- Return the rolled item info to the client for the animation
	return true, {
		ItemId      = item.Id,
		DisplayName = item.DisplayName,
		Rarity      = item.Rarity,
		Description = item.Description,
		ImageId     = item.ImageId,
	}
end

-- Sell an item by inventory slot index
SellItemFunction.OnServerInvoke = function(player, slotIndex)
	local data = DataManager.Get(player)
	if not data then return false, "Data not loaded." end

	local entry = data.Inventory[slotIndex]
	if not entry then return false, "Item not found." end

	local item      = ItemDatabase.ById[entry.ItemId]
	if not item then return false, "Unknown item." end

	local sellPrice = SharedConfig.SELL_PRICES[item.Rarity] or 10

	-- Remove from inventory and pay coins
	table.remove(data.Inventory, slotIndex)
	data.Coins += sellPrice

	syncCurrency(player)

	return true, sellPrice
end

-- Claim daily bonus (once per calendar day server-side)
ClaimDailyFunction.OnServerInvoke = function(player)
	local data = DataManager.Get(player)
	if not data then return false, "Data not loaded." end

	-- Allow claim if more than 20 hours have passed
	local now     = os.time()
	local elapsed = now - data.LastDaily
	if elapsed < 72000 then  -- 20 hours in seconds
		local remaining = 72000 - elapsed
		local hours     = math.floor(remaining / 3600)
		local mins      = math.floor((remaining % 3600) / 60)
		return false, string.format("Come back in %dh %dm.", hours, mins)
	end

	data.LastDaily = now
	data.Coins    += SharedConfig.DAILY_BONUS_COINS
	syncCurrency(player)

	return true, SharedConfig.DAILY_BONUS_COINS
end

print("[GameServer] Loaded successfully.")
