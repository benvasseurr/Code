-- ClientHandler.client.lua
-- All client-side UI logic. Panels hidden by default — player can move freely.
-- Press Escape to close any open panel and return to free movement.

local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")

local Modules       = ReplicatedStorage:WaitForChild("Modules")
local SharedConfig  = require(Modules:WaitForChild("SharedConfig"))
local ItemDatabase  = require(Modules:WaitForChild("ItemDatabase"))
local CrateDatabase = require(Modules:WaitForChild("CrateDatabase"))

local Remotes              = ReplicatedStorage:WaitForChild("Remotes", 15)
local UpdateCurrencyEvent  = Remotes:WaitForChild("UpdateCurrency")
local GetDataFunction      = Remotes:WaitForChild("GetData")
local OpenCrateFunction    = Remotes:WaitForChild("OpenCrate")
local SellItemFunction     = Remotes:WaitForChild("SellItem")
local ClaimDailyFunction   = Remotes:WaitForChild("ClaimDaily")

local LocalPlayer   = Players.LocalPlayer
local PlayerGui     = LocalPlayer:WaitForChild("PlayerGui")
local MainGui       = PlayerGui:WaitForChild("MainGui")

local ShopFrame      = MainGui:WaitForChild("ShopFrame")
local OpeningFrame   = MainGui:WaitForChild("OpeningFrame")
local InventoryFrame = MainGui:WaitForChild("InventoryFrame")
local ResultFrame    = MainGui:WaitForChild("ResultFrame")

local TopBar         = MainGui:WaitForChild("TopBar")
local CoinLabel      = TopBar:WaitForChild("CoinLabel")
local ShopBtn        = TopBar:WaitForChild("ShopBtn")
local InventoryBtn   = TopBar:WaitForChild("InventoryBtn")
local DailyBtn       = TopBar:WaitForChild("DailyBtn")

local SpinContainer  = OpeningFrame:WaitForChild("SpinContainer")
local SpinFrame      = SpinContainer:WaitForChild("SpinFrame")

local ResultItemName  = ResultFrame:WaitForChild("ItemName")
local ResultRarityLbl = ResultFrame:WaitForChild("RarityLabel")
local ResultImage     = ResultFrame:WaitForChild("ItemImage")
local ResultDescLbl   = ResultFrame:WaitForChild("DescLabel")
local ResultCloseBtn  = ResultFrame:WaitForChild("CloseBtn")
local ResultSellBtn   = ResultFrame:WaitForChild("SellBtn")

local state = { isOpening = false }
local pendingResultItem = nil

-- ── Panel visibility ──────────────────────────────────────────────────────────
local function showFrame(frame)
	ShopFrame.Visible      = false
	InventoryFrame.Visible = false
	OpeningFrame.Visible   = false
	ResultFrame.Visible    = false
	if frame then frame.Visible = true end
end

-- ── Toast ─────────────────────────────────────────────────────────────────────
local function notify(msg)
	local toast = Instance.new("TextLabel", MainGui)
	toast.Size               = UDim2.new(0, 340, 0, 42)
	toast.AnchorPoint        = Vector2.new(0.5, 0)
	toast.Position           = UDim2.new(0.5, 0, 0.86, 0)
	toast.BackgroundColor3   = Color3.fromRGB(20, 20, 38)
	toast.BackgroundTransparency = 0.12
	toast.TextColor3         = Color3.fromRGB(255, 255, 255)
	toast.TextScaled         = true
	toast.Font               = Enum.Font.GothamBold
	toast.Text               = msg
	toast.ZIndex             = 30
	toast.BorderSizePixel    = 0
	local uc = Instance.new("UICorner", toast)
	uc.CornerRadius = UDim.new(0, 8)
	local ti = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(toast, ti, { Position = UDim2.new(0.5, 0, 0.81, 0) }):Play()
	task.delay(2.2, function()
		TweenService:Create(toast, ti, {
			Position = UDim2.new(0.5, 0, 0.86, 0),
			TextTransparency = 1, BackgroundTransparency = 1,
		}):Play()
		task.delay(0.35, function() toast:Destroy() end)
	end)
end

-- ── Currency ──────────────────────────────────────────────────────────────────
UpdateCurrencyEvent.OnClientEvent:Connect(function(coins)
	CoinLabel.Text = "💰 " .. tostring(coins) .. " " .. SharedConfig.CURRENCY_NAME
end)

-- ── Shop ──────────────────────────────────────────────────────────────────────
local function buildShop()
	local list = ShopFrame:WaitForChild("CrateList")
	for _, c in ipairs(list:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end

	for _, crate in ipairs(CrateDatabase.Crates) do
		local card = Instance.new("Frame", list)
		card.Size             = UDim2.new(1, -12, 0, 104)
		card.BackgroundColor3 = crate.Color
		card.BorderSizePixel  = 0
		local uc = Instance.new("UICorner", card)
		uc.CornerRadius = UDim.new(0, 10)

		local img = Instance.new("ImageLabel", card)
		img.Size              = UDim2.new(0, 84, 1, -10)
		img.Position          = UDim2.new(0, 5, 0, 5)
		img.BackgroundTransparency = 1
		img.Image             = crate.ImageId
		img.ScaleType         = Enum.ScaleType.Fit

		local nl = Instance.new("TextLabel", card)
		nl.Size          = UDim2.new(1, -100, 0, 28)
		nl.Position      = UDim2.new(0, 96, 0, 6)
		nl.BackgroundTransparency = 1
		nl.TextColor3    = Color3.fromRGB(255, 255, 255)
		nl.Font          = Enum.Font.GothamBold
		nl.TextScaled    = true
		nl.Text          = crate.DisplayName
		nl.TextXAlignment = Enum.TextXAlignment.Left

		local dl = Instance.new("TextLabel", card)
		dl.Size          = UDim2.new(1, -100, 0, 36)
		dl.Position      = UDim2.new(0, 96, 0, 36)
		dl.BackgroundTransparency = 1
		dl.TextColor3    = Color3.fromRGB(230, 230, 230)
		dl.Font          = Enum.Font.Gotham
		dl.TextScaled    = true
		dl.TextWrapped   = true
		dl.Text          = crate.Description
		dl.TextXAlignment = Enum.TextXAlignment.Left

		local ob = Instance.new("TextButton", card)
		ob.Size          = UDim2.new(0, 118, 0, 30)
		ob.AnchorPoint   = Vector2.new(1, 1)
		ob.Position      = UDim2.new(1, -8, 1, -8)
		ob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ob.TextColor3    = Color3.fromRGB(20, 20, 20)
		ob.Font          = Enum.Font.GothamBold
		ob.TextScaled    = true
		ob.Text          = "Open 🪙" .. crate.Cost
		ob.BorderSizePixel = 0
		local uc2 = Instance.new("UICorner", ob)
		uc2.CornerRadius = UDim.new(0, 6)

		local crateRef = crate
		ob.MouseButton1Click:Connect(function()
			startOpening(crateRef)
		end)
	end
end

-- ── Opening animation ─────────────────────────────────────────────────────────
local ITEM_W  = 150
local STRIDE  = ITEM_W + 8

local function makeReelCard(item)
	local rarity = ItemDatabase.Rarities[item.Rarity]
	local card   = Instance.new("Frame")
	card.Size    = UDim2.new(0, ITEM_W, 1, -8)
	card.BackgroundColor3 = rarity and rarity.Color or Color3.fromRGB(100,100,100)
	card.BorderSizePixel  = 0
	local uc = Instance.new("UICorner", card)
	uc.CornerRadius = UDim.new(0, 8)
	local img = Instance.new("ImageLabel", card)
	img.Size   = UDim2.new(1, -8, 0.60, 0)
	img.Position = UDim2.new(0, 4, 0, 4)
	img.BackgroundTransparency = 1
	img.Image  = item.ImageId
	img.ScaleType = Enum.ScaleType.Fit
	local lbl = Instance.new("TextLabel", card)
	lbl.Size   = UDim2.new(1, -4, 0.36, 0)
	lbl.AnchorPoint = Vector2.new(0, 1)
	lbl.Position = UDim2.new(0, 2, 1, -2)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = Color3.fromRGB(255,255,255)
	lbl.Font   = Enum.Font.GothamBold
	lbl.TextScaled = true
	lbl.TextWrapped = true
	lbl.Text   = item.DisplayName
	return card
end

function startOpening(crate)
	if state.isOpening then return end
	state.isOpening = true
	showFrame(OpeningFrame)

	local ok, result = OpenCrateFunction:InvokeServer(crate.Id)
	if not ok then
		notify(result or "Could not open crate.")
		state.isOpening = false
		showFrame(ShopFrame)
		return
	end

	local wonItem = result
	local TOTAL   = SharedConfig.SPIN_ITEM_COUNT
	local WIN_IDX = TOTAL - 4

	for _, ch in ipairs(SpinFrame:GetChildren()) do
		if ch:IsA("Frame") then ch:Destroy() end
	end

	local poolSet = {}
	for _, id in ipairs(crate.ItemPool) do poolSet[id] = true end
	local poolItems = {}
	for _, item in ipairs(ItemDatabase.Items) do
		if poolSet[item.Id] then table.insert(poolItems, item) end
	end
	if #poolItems == 0 then poolItems = ItemDatabase.Items end

	for i = 1, TOTAL do
		local item = (i == WIN_IDX)
			and (ItemDatabase.ById[wonItem.ItemId] or poolItems[math.random(1,#poolItems)])
			or poolItems[math.random(1,#poolItems)]
		local card = makeReelCard(item)
		card.LayoutOrder = i
		card.Parent = SpinFrame
	end

	SpinFrame.Size     = UDim2.new(0, TOTAL * STRIDE + 20, 1, 0)
	SpinFrame.Position = UDim2.new(0, 0, 0, 0)

	local cw    = SpinContainer.AbsoluteSize.X
	local targetX = -((WIN_IDX - 1) * STRIDE) + (cw / 2) - (ITEM_W / 2)
	targetX += math.random(-12, 12)

	TweenService:Create(SpinFrame,
		TweenInfo.new(SharedConfig.SPIN_DURATION, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		{ Position = UDim2.new(0, targetX, 0, 0) }
	):Play()
	task.wait(SharedConfig.SPIN_DURATION + 0.4)
	showResult(wonItem)
	state.isOpening = false
end

-- ── Result screen ─────────────────────────────────────────────────────────────
function showResult(item)
	pendingResultItem = item
	local rarity = ItemDatabase.Rarities[item.Rarity]
	ResultItemName.Text   = item.DisplayName
	ResultRarityLbl.Text  = item.Rarity
	ResultRarityLbl.TextColor3 = rarity and rarity.Color or Color3.fromRGB(200,200,200)
	ResultImage.Image     = item.ImageId
	ResultDescLbl.Text    = item.Description
	ResultSellBtn.Text    = "Sell 🪙" .. (SharedConfig.SELL_PRICES[item.Rarity] or 0)
	showFrame(ResultFrame)
	ResultRarityLbl.Size = UDim2.new(0.5, 0, 0, 18)
	TweenService:Create(ResultRarityLbl,
		TweenInfo.new(0.4, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
		{ Size = UDim2.new(0.85, 0, 0, 38) }
	):Play()
end

-- ── Inventory ─────────────────────────────────────────────────────────────────
local function buildInventory(inv)
	local grid = InventoryFrame:WaitForChild("ItemGrid")
	for _, c in ipairs(grid:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end
	if #inv == 0 then
		local e = Instance.new("TextLabel", grid)
		e.Size = UDim2.new(1, 0, 0, 50)
		e.BackgroundTransparency = 1
		e.TextColor3 = Color3.fromRGB(160,160,180)
		e.Font = Enum.Font.Gotham
		e.TextScaled = true
		e.Text = "No items yet — open some crates!"
		return
	end
	for i, entry in ipairs(inv) do
		local item   = ItemDatabase.ById[entry.ItemId]
		if not item then continue end
		local rarity = ItemDatabase.Rarities[item.Rarity]
		local card = Instance.new("Frame", grid)
		card.Size             = UDim2.new(0, 110, 0, 130)
		card.BackgroundColor3 = rarity and rarity.Color or Color3.fromRGB(80,80,80)
		card.BorderSizePixel  = 0
		local uc = Instance.new("UICorner", card)
		uc.CornerRadius = UDim.new(0, 8)
		local img = Instance.new("ImageLabel", card)
		img.Size   = UDim2.new(1, -8, 0.60, 0)
		img.Position = UDim2.new(0, 4, 0, 4)
		img.BackgroundTransparency = 1
		img.Image  = item.ImageId
		img.ScaleType = Enum.ScaleType.Fit
		local nl = Instance.new("TextLabel", card)
		nl.Size   = UDim2.new(1, -4, 0.22, 0)
		nl.Position = UDim2.new(0, 2, 0.62, 0)
		nl.BackgroundTransparency = 1
		nl.TextColor3 = Color3.fromRGB(255,255,255)
		nl.Font   = Enum.Font.GothamBold
		nl.TextScaled = true
		nl.TextWrapped = true
		nl.Text   = item.DisplayName
		local sb = Instance.new("TextButton", card)
		sb.Size   = UDim2.new(1, -6, 0.18, 0)
		sb.AnchorPoint = Vector2.new(0.5, 1)
		sb.Position = UDim2.new(0.5, 0, 1, -3)
		sb.BackgroundColor3 = Color3.fromRGB(255,255,255)
		sb.TextColor3 = Color3.fromRGB(20,20,20)
		sb.Font   = Enum.Font.GothamBold
		sb.TextScaled = true
		sb.Text   = "Sell"
		sb.BorderSizePixel = 0
		local uc2 = Instance.new("UICorner", sb)
		uc2.CornerRadius = UDim.new(0, 5)
		local slot = i
		sb.MouseButton1Click:Connect(function()
			local ok, pay = SellItemFunction:InvokeServer(slot)
			if ok then
				notify("Sold for 🪙" .. pay .. "!")
				local d = GetDataFunction:InvokeServer()
				if d then buildInventory(d.Inventory) end
			else
				notify(pay or "Could not sell.")
			end
		end)
	end
end

-- ── Buttons ───────────────────────────────────────────────────────────────────
ShopBtn.MouseButton1Click:Connect(function()
	buildShop()
	showFrame(ShopFrame)
end)

InventoryBtn.MouseButton1Click:Connect(function()
	local d = GetDataFunction:InvokeServer()
	if d then buildInventory(d.Inventory) end
	showFrame(InventoryFrame)
end)

DailyBtn.MouseButton1Click:Connect(function()
	local ok, pay = ClaimDailyFunction:InvokeServer()
	notify(ok and ("Daily bonus! +" .. pay .. " 🪙") or (pay or "Already claimed."))
end)

ShopFrame:WaitForChild("CloseBtn").MouseButton1Click:Connect(function()
	showFrame(nil)
end)
InventoryFrame:WaitForChild("CloseBtn").MouseButton1Click:Connect(function()
	showFrame(nil)
end)
ResultCloseBtn.MouseButton1Click:Connect(function()
	showFrame(ShopFrame)
end)
ResultSellBtn.MouseButton1Click:Connect(function()
	if not pendingResultItem then return end
	local d = GetDataFunction:InvokeServer()
	if not d then return end
	local ok, pay = SellItemFunction:InvokeServer(#d.Inventory)
	if ok then
		notify("Sold for 🪙" .. pay .. "!")
		showFrame(ShopFrame)
	else
		notify(pay or "Could not sell.")
	end
	pendingResultItem = nil
end)

-- Escape closes any open panel
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.Escape then
		if not state.isOpening then showFrame(nil) end
	end
end)

-- Start with everything closed so player can move right away
showFrame(nil)

print("[ClientHandler] Loaded successfully.")
