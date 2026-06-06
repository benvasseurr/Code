-- ClientHandler.client.lua
-- Manages client-side state and wires GUI events to server remotes.

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local SharedConfig  = require(ReplicatedStorage.Modules.SharedConfig)
local ItemDatabase  = require(ReplicatedStorage.Modules.ItemDatabase)
local CrateDatabase = require(ReplicatedStorage.Modules.CrateDatabase)

-- Wait for remotes folder
local Remotes              = ReplicatedStorage:WaitForChild("Remotes", 10)
local UpdateCurrencyEvent  = Remotes:WaitForChild("UpdateCurrency")
local GetDataFunction      = Remotes:WaitForChild("GetData")
local OpenCrateFunction    = Remotes:WaitForChild("OpenCrate")
local SellItemFunction     = Remotes:WaitForChild("SellItem")
local ClaimDailyFunction   = Remotes:WaitForChild("ClaimDaily")

local LocalPlayer          = Players.LocalPlayer
local PlayerGui            = LocalPlayer:WaitForChild("PlayerGui")

-- ────────────────────────────────────────────────────────────────────────────
-- State
-- ────────────────────────────────────────────────────────────────────────────
local state = {
	coins          = 0,
	inventory      = {},
	isOpening      = false,
	selectedCrate  = nil,   -- CrateDatabase entry
}

-- ────────────────────────────────────────────────────────────────────────────
-- GUI References (wait for them to exist)
-- ────────────────────────────────────────────────────────────────────────────
local MainGui       = PlayerGui:WaitForChild("MainGui")
local ShopFrame     = MainGui:WaitForChild("ShopFrame")
local OpeningFrame  = MainGui:WaitForChild("OpeningFrame")
local InventoryFrame= MainGui:WaitForChild("InventoryFrame")
local ResultFrame   = MainGui:WaitForChild("ResultFrame")

-- Top bar refs
local CoinLabel     = MainGui:WaitForChild("TopBar"):WaitForChild("CoinLabel")
local ShopBtn       = MainGui:WaitForChild("TopBar"):WaitForChild("ShopBtn")
local InventoryBtn  = MainGui:WaitForChild("TopBar"):WaitForChild("InventoryBtn")
local DailyBtn      = MainGui:WaitForChild("TopBar"):WaitForChild("DailyBtn")

-- Opening animation refs
local SpinContainer   = OpeningFrame:WaitForChild("SpinContainer")
local SpinFrame       = SpinContainer:WaitForChild("SpinFrame")
local PointerLine     = SpinContainer:WaitForChild("PointerLine")

-- Result refs
local ResultItemName  = ResultFrame:WaitForChild("ItemName")
local ResultRarityLbl = ResultFrame:WaitForChild("RarityLabel")
local ResultImage     = ResultFrame:WaitForChild("ItemImage")
local ResultDescLbl   = ResultFrame:WaitForChild("DescLabel")
local ResultCloseBtn  = ResultFrame:WaitForChild("CloseBtn")
local ResultSellBtn   = ResultFrame:WaitForChild("SellBtn")

-- ────────────────────────────────────────────────────────────────────────────
-- Utility
-- ────────────────────────────────────────────────────────────────────────────
local function showFrame(frame)
	ShopFrame.Visible      = false
	InventoryFrame.Visible = false
	OpeningFrame.Visible   = false
	ResultFrame.Visible    = false
	if frame then frame.Visible = true end
end

local function notify(msg)
	-- Simple floating toast
	local toast = Instance.new("TextLabel")
	toast.Size               = UDim2.new(0, 320, 0, 40)
	toast.AnchorPoint        = Vector2.new(0.5, 0)
	toast.Position           = UDim2.new(0.5, 0, 0.85, 0)
	toast.BackgroundColor3   = Color3.fromRGB(30, 30, 30)
	toast.BackgroundTransparency = 0.2
	toast.TextColor3         = Color3.fromRGB(255, 255, 255)
	toast.TextScaled         = true
	toast.Font               = Enum.Font.GothamBold
	toast.Text               = msg
	toast.ZIndex             = 20
	toast.Parent             = MainGui
	Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 8)

	local ti = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(toast, ti, { Position = UDim2.new(0.5, 0, 0.80, 0) }):Play()
	task.delay(2.2, function()
		TweenService:Create(toast, ti, { Position = UDim2.new(0.5, 0, 0.85, 0),
			TextTransparency = 1, BackgroundTransparency = 1 }):Play()
		task.delay(0.35, function() toast:Destroy() end)
	end)
end

-- ────────────────────────────────────────────────────────────────────────────
-- Currency display
-- ────────────────────────────────────────────────────────────────────────────
local function updateCoinDisplay(coins)
	state.coins   = coins
	CoinLabel.Text = "💰 " .. tostring(coins) .. " " .. SharedConfig.CURRENCY_NAME
end

UpdateCurrencyEvent.OnClientEvent:Connect(updateCoinDisplay)

-- ────────────────────────────────────────────────────────────────────────────
-- Shop
-- ────────────────────────────────────────────────────────────────────────────
local function buildShop()
	local crateList = ShopFrame:WaitForChild("CrateList")

	-- Clear existing
	for _, child in ipairs(crateList:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	for _, crate in ipairs(CrateDatabase.Crates) do
		local card = Instance.new("Frame")
		card.Size              = UDim2.new(1, -20, 0, 110)
		card.BackgroundColor3  = crate.Color
		card.BorderSizePixel   = 0
		card.Parent            = crateList
		Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

		local name = Instance.new("TextLabel", card)
		name.Size              = UDim2.new(1, -10, 0, 30)
		name.Position          = UDim2.new(0, 5, 0, 5)
		name.BackgroundTransparency = 1
		name.TextColor3        = Color3.fromRGB(255, 255, 255)
		name.Font              = Enum.Font.GothamBold
		name.TextScaled        = true
		name.Text              = crate.DisplayName

		local desc = Instance.new("TextLabel", card)
		desc.Size              = UDim2.new(1, -10, 0, 36)
		desc.Position          = UDim2.new(0, 5, 0, 36)
		desc.BackgroundTransparency = 1
		desc.TextColor3        = Color3.fromRGB(230, 230, 230)
		desc.Font              = Enum.Font.Gotham
		desc.TextScaled        = true
		desc.TextWrapped       = true
		desc.Text              = crate.Description

		local openBtn = Instance.new("TextButton", card)
		openBtn.Size           = UDim2.new(0, 130, 0, 32)
		openBtn.AnchorPoint    = Vector2.new(1, 1)
		openBtn.Position       = UDim2.new(1, -8, 1, -8)
		openBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		openBtn.TextColor3     = Color3.fromRGB(30, 30, 30)
		openBtn.Font           = Enum.Font.GothamBold
		openBtn.TextScaled     = true
		openBtn.Text           = "Open  🪙" .. crate.Cost
		openBtn.BorderSizePixel = 0
		Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 6)

		openBtn.MouseButton1Click:Connect(function()
			state.selectedCrate = crate
			startOpening(crate)
		end)
	end
end

-- ────────────────────────────────────────────────────────────────────────────
-- Opening animation
-- ────────────────────────────────────────────────────────────────────────────
local ITEM_WIDTH  = 150   -- px width of each reel item card
local ITEM_GAP    = 8
local ITEM_STRIDE = ITEM_WIDTH + ITEM_GAP

local function makeReelCard(item)
	local rarity       = ItemDatabase.Rarities[item.Rarity]
	local card         = Instance.new("Frame")
	card.Size          = UDim2.new(0, ITEM_WIDTH, 1, -4)
	card.BackgroundColor3 = rarity and rarity.Color or Color3.fromRGB(150,150,150)
	card.BorderSizePixel = 0
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

	local img = Instance.new("ImageLabel", card)
	img.Size              = UDim2.new(1, -10, 0.6, 0)
	img.Position          = UDim2.new(0, 5, 0, 5)
	img.BackgroundTransparency = 1
	img.Image             = item.ImageId
	img.ScaleType         = Enum.ScaleType.Fit

	local lbl = Instance.new("TextLabel", card)
	lbl.Size              = UDim2.new(1, -4, 0.35, 0)
	lbl.AnchorPoint       = Vector2.new(0, 1)
	lbl.Position          = UDim2.new(0, 2, 1, -2)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3        = Color3.fromRGB(255, 255, 255)
	lbl.Font              = Enum.Font.GothamBold
	lbl.TextScaled        = true
	lbl.TextWrapped       = true
	lbl.Text              = item.DisplayName

	return card
end

function startOpening(crate)
	if state.isOpening then return end
	state.isOpening = true

	showFrame(OpeningFrame)

	-- Ask server to roll immediately so the result is determined before animation
	local success, result = OpenCrateFunction:InvokeServer(crate.Id)

	if not success then
		notify(result or "Failed to open crate.")
		state.isOpening = false
		showFrame(ShopFrame)
		return
	end

	-- result is the won item info table
	local wonItem = result

	-- Build reel: SPIN_ITEM_COUNT random items + the winner at a fixed landing index
	local TOTAL_CARDS  = SharedConfig.SPIN_ITEM_COUNT
	local WINNER_INDEX = TOTAL_CARDS - 3   -- land near the end

	-- Clear old reel cards
	for _, child in ipairs(SpinFrame:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	-- Populate reel with random items, placing winner at WINNER_INDEX
	local cratePoolIds = {}
	for _, id in ipairs(crate.ItemPool) do table.insert(cratePoolIds, id) end

	local function randomPoolItem()
		local id = cratePoolIds[math.random(1, #cratePoolIds)]
		return ItemDatabase.ById[id] or ItemDatabase.Items[1]
	end

	local cards = {}
	for i = 1, TOTAL_CARDS do
		local item = (i == WINNER_INDEX) and ItemDatabase.ById[wonItem.ItemId] or randomPoolItem()
		local card = makeReelCard(item)
		card.LayoutOrder = i
		card.Parent = SpinFrame
		table.insert(cards, card)
	end

	-- Position SpinFrame so first card starts at left
	SpinFrame.Size = UDim2.new(0, TOTAL_CARDS * ITEM_STRIDE, 1, 0)
	SpinFrame.Position = UDim2.new(0, 0, 0, 0)

	-- Calculate where winner card center should be: visible center of SpinContainer
	local containerWidth = SpinContainer.AbsoluteSize.X
	local targetX = -(( WINNER_INDEX - 1) * ITEM_STRIDE) + (containerWidth / 2) - (ITEM_WIDTH / 2)
	-- Add small sub-pixel jitter for realism
	targetX += math.random(-20, 20)

	-- Animate: fast start, ease out (simulate deceleration)
	local ti = TweenInfo.new(
		SharedConfig.SPIN_DURATION,
		Enum.EasingStyle.Quart,
		Enum.EasingDirection.Out
	)
	local tween = TweenService:Create(SpinFrame, ti, { Position = UDim2.new(0, targetX, 0, 0) })
	tween:Play()
	tween.Completed:Wait()

	-- Brief pause, then show result
	task.wait(0.4)
	showResult(wonItem)
	state.isOpening = false
end

-- ────────────────────────────────────────────────────────────────────────────
-- Result screen
-- ────────────────────────────────────────────────────────────────────────────
local pendingResultItem = nil

function showResult(item)
	pendingResultItem = item
	local rarity       = ItemDatabase.Rarities[item.Rarity]

	ResultItemName.Text   = item.DisplayName
	ResultRarityLbl.Text  = item.Rarity
	ResultRarityLbl.TextColor3 = rarity and rarity.Color or Color3.fromRGB(200, 200, 200)
	ResultImage.Image     = item.ImageId
	ResultDescLbl.Text    = item.Description
	ResultSellBtn.Text    = "Sell  🪙" .. (SharedConfig.SELL_PRICES[item.Rarity] or 0)

	showFrame(ResultFrame)

	-- Sparkle animation on the rarity label
	local sparkTI = TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
	ResultRarityLbl.Size = UDim2.new(0.6, 0, 0, 20)
	TweenService:Create(ResultRarityLbl, sparkTI, { Size = UDim2.new(0.9, 0, 0, 40) }):Play()
end

-- ────────────────────────────────────────────────────────────────────────────
-- Inventory
-- ────────────────────────────────────────────────────────────────────────────
local function buildInventory(inventoryData)
	local grid = InventoryFrame:WaitForChild("ItemGrid")
	for _, child in ipairs(grid:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	if #inventoryData == 0 then
		local empty = Instance.new("TextLabel", grid)
		empty.Size = UDim2.new(1, 0, 0, 50)
		empty.BackgroundTransparency = 1
		empty.TextColor3 = Color3.fromRGB(180, 180, 180)
		empty.Font = Enum.Font.Gotham
		empty.TextScaled = true
		empty.Text = "Your inventory is empty. Open some crates!"
		return
	end

	for i, entry in ipairs(inventoryData) do
		local item   = ItemDatabase.ById[entry.ItemId]
		if not item then continue end
		local rarity = ItemDatabase.Rarities[item.Rarity]

		local card = Instance.new("Frame", grid)
		card.Size              = UDim2.new(0, 110, 0, 130)
		card.BackgroundColor3  = rarity and rarity.Color or Color3.fromRGB(100,100,100)
		card.BorderSizePixel   = 0
		Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

		local img = Instance.new("ImageLabel", card)
		img.Size               = UDim2.new(1, -8, 0.6, 0)
		img.Position           = UDim2.new(0, 4, 0, 4)
		img.BackgroundTransparency = 1
		img.Image              = item.ImageId
		img.ScaleType          = Enum.ScaleType.Fit

		local nameLbl = Instance.new("TextLabel", card)
		nameLbl.Size           = UDim2.new(1, -4, 0.22, 0)
		nameLbl.Position       = UDim2.new(0, 2, 0.62, 0)
		nameLbl.BackgroundTransparency = 1
		nameLbl.TextColor3     = Color3.fromRGB(255, 255, 255)
		nameLbl.Font           = Enum.Font.GothamBold
		nameLbl.TextScaled     = true
		nameLbl.TextWrapped    = true
		nameLbl.Text           = item.DisplayName

		local sellBtn = Instance.new("TextButton", card)
		sellBtn.Size           = UDim2.new(1, -6, 0.2, 0)
		sellBtn.AnchorPoint    = Vector2.new(0.5, 1)
		sellBtn.Position       = UDim2.new(0.5, 0, 1, -3)
		sellBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		sellBtn.TextColor3     = Color3.fromRGB(30, 30, 30)
		sellBtn.Font           = Enum.Font.GothamBold
		sellBtn.TextScaled     = true
		sellBtn.Text           = "Sell"
		sellBtn.BorderSizePixel = 0
		Instance.new("UICorner", sellBtn).CornerRadius = UDim.new(0, 5)

		local slotIndex = i
		sellBtn.MouseButton1Click:Connect(function()
			local ok, payload = SellItemFunction:InvokeServer(slotIndex)
			if ok then
				notify("Sold for 🪙" .. payload .. " " .. SharedConfig.CURRENCY_NAME .. "!")
				local newData = GetDataFunction:InvokeServer()
				if newData then buildInventory(newData.Inventory) end
			else
				notify(payload or "Could not sell item.")
			end
		end)
	end
end

-- ────────────────────────────────────────────────────────────────────────────
-- Button wiring
-- ────────────────────────────────────────────────────────────────────────────
ShopBtn.MouseButton1Click:Connect(function()
	buildShop()
	showFrame(ShopFrame)
end)

InventoryBtn.MouseButton1Click:Connect(function()
	local data = GetDataFunction:InvokeServer()
	if data then buildInventory(data.Inventory) end
	showFrame(InventoryFrame)
end)

DailyBtn.MouseButton1Click:Connect(function()
	local ok, payload = ClaimDailyFunction:InvokeServer()
	if ok then
		notify("Daily bonus claimed! +" .. payload .. " 🪙")
	else
		notify(payload or "Already claimed today.")
	end
end)

-- Close buttons
ShopFrame:WaitForChild("CloseBtn").MouseButton1Click:Connect(function()
	showFrame(nil)
end)
InventoryFrame:WaitForChild("CloseBtn").MouseButton1Click:Connect(function()
	showFrame(nil)
end)

ResultCloseBtn.MouseButton1Click:Connect(function()
	showFrame(ShopFrame)
end)

-- Sell from result screen (sells the most recently added item = last slot)
ResultSellBtn.MouseButton1Click:Connect(function()
	if not pendingResultItem then return end
	local data = GetDataFunction:InvokeServer()
	if not data then return end
	local slotIndex = #data.Inventory  -- the item we just added is last
	local ok, payload = SellItemFunction:InvokeServer(slotIndex)
	if ok then
		notify("Sold for 🪙" .. payload .. " " .. SharedConfig.CURRENCY_NAME .. "!")
		showFrame(ShopFrame)
	else
		notify(payload or "Could not sell item.")
	end
	pendingResultItem = nil
end)

-- ────────────────────────────────────────────────────────────────────────────
-- Initial load: open shop by default
-- ────────────────────────────────────────────────────────────────────────────
task.wait(0.5)
buildShop()
showFrame(ShopFrame)

print("[ClientHandler] Loaded successfully.")
