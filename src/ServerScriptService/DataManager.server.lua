-- DataManager.server.lua
-- Handles loading and saving player data via DataStore.
-- Exposes a module-like API used by GameServer.

local DataStoreService = game:GetService("DataStoreService")
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local SharedConfig     = require(game.ReplicatedStorage.Modules.SharedConfig)

local store = DataStoreService:GetDataStore(SharedConfig.DATASTORE_KEY)

local DataManager = {}
DataManager._cache = {}  -- [userId] = dataTable

local function defaultData()
	return {
		Coins     = SharedConfig.STARTING_COINS,
		Inventory = {},         -- list of { ItemId, ObtainedAt }
		LastDaily = 0,          -- os.time() of last daily claim
		TotalOpens = 0,
	}
end

function DataManager.Load(player)
	local key = tostring(player.UserId)
	local success, result = pcall(function()
		return store:GetAsync(key)
	end)

	local data
	if success and result then
		-- Back-fill any keys missing from older saves
		data = result
		for k, v in pairs(defaultData()) do
			if data[k] == nil then data[k] = v end
		end
	else
		data = defaultData()
		if not success then
			warn("[DataManager] Load failed for", player.Name, ":", result)
		end
	end

	DataManager._cache[player.UserId] = data
	return data
end

function DataManager.Save(player)
	local data = DataManager._cache[player.UserId]
	if not data then return end

	local key = tostring(player.UserId)
	local success, err = pcall(function()
		store:SetAsync(key, data)
	end)
	if not success then
		warn("[DataManager] Save failed for", player.Name, ":", err)
	end
end

function DataManager.Get(player)
	return DataManager._cache[player.UserId]
end

-- Periodic auto-save every 60 seconds
local saveTimer = 0
RunService.Heartbeat:Connect(function(dt)
	saveTimer += dt
	if saveTimer >= 60 then
		saveTimer = 0
		for _, player in ipairs(Players:GetPlayers()) do
			DataManager.Save(player)
		end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	DataManager.Save(player)
	DataManager._cache[player.UserId] = nil
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		DataManager.Save(player)
	end
end)

return DataManager
