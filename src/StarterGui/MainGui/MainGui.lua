-- MainGui.lua  (place as a Script inside the ScreenGui named "MainGui" with RunContext = Legacy)
-- Builds the entire GUI tree on the client at runtime.
-- In Studio you can run this once as a Script under StarterGui to generate the hierarchy,
-- then convert it to a static GUI or keep it dynamic.

local ScreenGui = script.Parent   -- the ScreenGui named "MainGui"
ScreenGui.ResetOnSpawn   = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder   = 5

local TweenService = game:GetService("TweenService")

local function corner(parent, radius)
	local c = Instance.new("UICorner", parent)
	c.CornerRadius = UDim.new(0, radius or 10)
	return c
end
local function padding(parent, px)
	local p = Instance.new("UIPadding", parent)
	p.PaddingTop    = UDim.new(0, px)
	p.PaddingBottom = UDim.new(0, px)
	p.PaddingLeft   = UDim.new(0, px)
	p.PaddingRight  = UDim.new(0, px)
	return p
end
local function listLayout(parent, dir, gap)
	local l = Instance.new("UIListLayout", parent)
	l.FillDirection   = dir or Enum.FillDirection.Vertical
	l.SortOrder       = Enum.SortOrder.LayoutOrder
	l.Padding         = UDim.new(0, gap or 8)
	return l
end
local function gridLayout(parent, cellSize, cellPad)
	local g = Instance.new("UIGridLayout", parent)
	g.CellSize    = cellSize or UDim2.new(0, 110, 0, 130)
	g.CellPaddingUDim2 = cellPad or UDim2.new(0, 8, 0, 8)
	g.SortOrder   = Enum.SortOrder.LayoutOrder
	return g
end

-- ────────────────────────────────────────────────────────────────────────────
-- Background overlay
-- ────────────────────────────────────────────────────────────────────────────
local BG = Instance.new("Frame", ScreenGui)
BG.Name                  = "Background"
BG.Size                  = UDim2.new(1, 0, 1, 0)
BG.BackgroundColor3      = Color3.fromRGB(12, 12, 20)
BG.BorderSizePixel       = 0
BG.ZIndex                = 0

-- Subtle gradient
local grad = Instance.new("UIGradient", BG)
grad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0,   Color3.fromRGB(12, 12, 30)),
	ColorSequenceKeypoint.new(1,   Color3.fromRGB(5,  5,  15)),
})
grad.Rotation = 45

-- ────────────────────────────────────────────────────────────────────────────
-- Top Bar
-- ────────────────────────────────────────────────────────────────────────────
local TopBar = Instance.new("Frame", ScreenGui)
TopBar.Name              = "TopBar"
TopBar.Size              = UDim2.new(1, 0, 0, 52)
TopBar.Position          = UDim2.new(0, 0, 0, 0)
TopBar.BackgroundColor3  = Color3.fromRGB(20, 20, 35)
TopBar.BorderSizePixel   = 0
TopBar.ZIndex            = 10

-- Title
local TitleLbl = Instance.new("TextLabel", TopBar)
TitleLbl.Name            = "TitleLabel"
TitleLbl.Size            = UDim2.new(0, 200, 1, 0)
TitleLbl.Position        = UDim2.new(0, 14, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.TextColor3      = Color3.fromRGB(255, 210, 60)
TitleLbl.Font            = Enum.Font.GothamBlack
TitleLbl.TextScaled      = true
TitleLbl.Text            = "🎰 LimitedCrates"
TitleLbl.TextXAlignment  = Enum.TextXAlignment.Left
TitleLbl.ZIndex          = 10

-- Coin Label
local CoinLabel = Instance.new("TextLabel", TopBar)
CoinLabel.Name           = "CoinLabel"
CoinLabel.Size           = UDim2.new(0, 220, 0, 36)
CoinLabel.AnchorPoint    = Vector2.new(0.5, 0.5)
CoinLabel.Position       = UDim2.new(0.5, 0, 0.5, 0)
CoinLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
CoinLabel.TextColor3     = Color3.fromRGB(255, 220, 60)
CoinLabel.Font           = Enum.Font.GothamBold
CoinLabel.TextScaled     = true
CoinLabel.Text           = "💰 0 Coins"
CoinLabel.ZIndex         = 10
corner(CoinLabel, 8)

local function topBtn(name, label, xOffset)
	local btn = Instance.new("TextButton", TopBar)
	btn.Name             = name
	btn.Size             = UDim2.new(0, 110, 0, 36)
	btn.AnchorPoint      = Vector2.new(1, 0.5)
	btn.Position         = UDim2.new(1, xOffset, 0.5, 0)
	btn.BackgroundColor3 = Color3.fromRGB(60, 120, 230)
	btn.TextColor3       = Color3.fromRGB(255, 255, 255)
	btn.Font             = Enum.Font.GothamBold
	btn.TextScaled       = true
	btn.Text             = label
	btn.BorderSizePixel  = 0
	btn.ZIndex           = 10
	corner(btn, 8)
	return btn
end
topBtn("DailyBtn",     "🎁 Daily",    -14)
topBtn("InventoryBtn", "🎒 Items",    -132)
topBtn("ShopBtn",      "🛒 Shop",     -250)

-- ────────────────────────────────────────────────────────────────────────────
-- Helper: make a panel frame
-- ────────────────────────────────────────────────────────────────────────────
local function panel(name, visible)
	local f = Instance.new("Frame", ScreenGui)
	f.Name               = name
	f.Size               = UDim2.new(0.88, 0, 0.78, 0)
	f.AnchorPoint        = Vector2.new(0.5, 0.5)
	f.Position           = UDim2.new(0.5, 0, 0.54, 0)
	f.BackgroundColor3   = Color3.fromRGB(18, 18, 30)
	f.BorderSizePixel    = 0
	f.Visible            = visible or false
	f.ZIndex             = 5
	corner(f, 14)
	return f
end

local function panelTitle(parent, text)
	local lbl = Instance.new("TextLabel", parent)
	lbl.Name             = "Title"
	lbl.Size             = UDim2.new(1, -60, 0, 44)
	lbl.Position         = UDim2.new(0, 10, 0, 6)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3       = Color3.fromRGB(255, 255, 255)
	lbl.Font             = Enum.Font.GothamBlack
	lbl.TextScaled       = true
	lbl.Text             = text
	lbl.TextXAlignment   = Enum.TextXAlignment.Left
	lbl.ZIndex           = 6
	return lbl
end

local function closeBtn(parent)
	local btn = Instance.new("TextButton", parent)
	btn.Name             = "CloseBtn"
	btn.Size             = UDim2.new(0, 38, 0, 38)
	btn.AnchorPoint      = Vector2.new(1, 0)
	btn.Position         = UDim2.new(1, -8, 0, 8)
	btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	btn.TextColor3       = Color3.fromRGB(255, 255, 255)
	btn.Font             = Enum.Font.GothamBold
	btn.TextScaled       = true
	btn.Text             = "✕"
	btn.BorderSizePixel  = 0
	btn.ZIndex           = 8
	corner(btn, 8)
	return btn
end

-- ────────────────────────────────────────────────────────────────────────────
-- Shop Frame
-- ────────────────────────────────────────────────────────────────────────────
local ShopFrame = panel("ShopFrame", true)
panelTitle(ShopFrame, "🛒  Crate Shop")
closeBtn(ShopFrame)

local CrateList = Instance.new("ScrollingFrame", ShopFrame)
CrateList.Name               = "CrateList"
CrateList.Size               = UDim2.new(1, -20, 1, -64)
CrateList.Position           = UDim2.new(0, 10, 0, 56)
CrateList.BackgroundTransparency = 1
CrateList.ScrollBarThickness = 4
CrateList.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 140)
CrateList.CanvasSize         = UDim2.new(0, 0, 0, 0)
CrateList.AutomaticCanvasSize = Enum.AutomaticSize.Y
CrateList.BorderSizePixel    = 0
CrateList.ZIndex             = 6
listLayout(CrateList, Enum.FillDirection.Vertical, 12)
padding(CrateList, 6)

-- ────────────────────────────────────────────────────────────────────────────
-- Inventory Frame
-- ────────────────────────────────────────────────────────────────────────────
local InventoryFrame = panel("InventoryFrame")
panelTitle(InventoryFrame, "🎒  My Items")
closeBtn(InventoryFrame)

local ItemGrid = Instance.new("ScrollingFrame", InventoryFrame)
ItemGrid.Name                = "ItemGrid"
ItemGrid.Size                = UDim2.new(1, -20, 1, -64)
ItemGrid.Position            = UDim2.new(0, 10, 0, 56)
ItemGrid.BackgroundTransparency = 1
ItemGrid.ScrollBarThickness  = 4
ItemGrid.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 140)
ItemGrid.CanvasSize          = UDim2.new(0, 0, 0, 0)
ItemGrid.AutomaticCanvasSize = Enum.AutomaticSize.Y
ItemGrid.BorderSizePixel     = 0
ItemGrid.ZIndex              = 6
gridLayout(ItemGrid, UDim2.new(0, 110, 0, 130), UDim2.new(0, 10, 0, 10))
padding(ItemGrid, 8)

-- ────────────────────────────────────────────────────────────────────────────
-- Opening Frame (the spinning reel)
-- ────────────────────────────────────────────────────────────────────────────
local OpeningFrame = panel("OpeningFrame")
OpeningFrame.Size  = UDim2.new(1, 0, 1, 0)   -- full screen during opening
OpeningFrame.AnchorPoint = Vector2.new(0.5, 0.5)
OpeningFrame.Position    = UDim2.new(0.5, 0, 0.5, 0)
OpeningFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 16)
OpeningFrame.BackgroundTransparency = 0.1

local OpenTitle = Instance.new("TextLabel", OpeningFrame)
OpenTitle.Name           = "Title"
OpenTitle.Size           = UDim2.new(1, 0, 0, 50)
OpenTitle.Position       = UDim2.new(0, 0, 0.1, 0)
OpenTitle.BackgroundTransparency = 1
OpenTitle.TextColor3     = Color3.fromRGB(255, 210, 60)
OpenTitle.Font           = Enum.Font.GothamBlack
OpenTitle.TextScaled     = true
OpenTitle.Text           = "Opening Crate..."
OpenTitle.ZIndex         = 6

-- The spinning reel container (clips overflow)
local SpinContainer = Instance.new("Frame", OpeningFrame)
SpinContainer.Name           = "SpinContainer"
SpinContainer.Size           = UDim2.new(0.92, 0, 0, 170)
SpinContainer.AnchorPoint    = Vector2.new(0.5, 0.5)
SpinContainer.Position       = UDim2.new(0.5, 0, 0.5, 0)
SpinContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
SpinContainer.BorderSizePixel = 0
SpinContainer.ClipsDescendants = true
SpinContainer.ZIndex         = 6
corner(SpinContainer, 12)

-- The moving strip of item cards
local SpinFrame = Instance.new("Frame", SpinContainer)
SpinFrame.Name               = "SpinFrame"
SpinFrame.Size               = UDim2.new(0, 3200, 1, 0)
SpinFrame.Position           = UDim2.new(0, 0, 0, 0)
SpinFrame.BackgroundTransparency = 1
SpinFrame.ZIndex             = 7
listLayout(SpinFrame, Enum.FillDirection.Horizontal, 8)
padding(SpinFrame, 4)

-- Pointer line in the center
local PointerLine = Instance.new("Frame", SpinContainer)
PointerLine.Name             = "PointerLine"
PointerLine.Size             = UDim2.new(0, 3, 1, 0)
PointerLine.AnchorPoint      = Vector2.new(0.5, 0)
PointerLine.Position         = UDim2.new(0.5, 0, 0, 0)
PointerLine.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
PointerLine.BorderSizePixel  = 0
PointerLine.ZIndex           = 9

-- ────────────────────────────────────────────────────────────────────────────
-- Result Frame
-- ────────────────────────────────────────────────────────────────────────────
local ResultFrame = panel("ResultFrame")
ResultFrame.Size         = UDim2.new(0, 420, 0, 460)

panelTitle(ResultFrame, "✨  You Got!")

local RarityLabel = Instance.new("TextLabel", ResultFrame)
RarityLabel.Name         = "RarityLabel"
RarityLabel.Size         = UDim2.new(0.8, 0, 0, 36)
RarityLabel.AnchorPoint  = Vector2.new(0.5, 0)
RarityLabel.Position     = UDim2.new(0.5, 0, 0, 52)
RarityLabel.BackgroundTransparency = 1
RarityLabel.Font         = Enum.Font.GothamBold
RarityLabel.TextScaled   = true
RarityLabel.Text         = "Legendary"
RarityLabel.ZIndex       = 6

local ItemImage = Instance.new("ImageLabel", ResultFrame)
ItemImage.Name           = "ItemImage"
ItemImage.Size           = UDim2.new(0, 160, 0, 160)
ItemImage.AnchorPoint    = Vector2.new(0.5, 0)
ItemImage.Position       = UDim2.new(0.5, 0, 0, 95)
ItemImage.BackgroundTransparency = 1
ItemImage.ScaleType      = Enum.ScaleType.Fit
ItemImage.ZIndex         = 6

local ItemName = Instance.new("TextLabel", ResultFrame)
ItemName.Name            = "ItemName"
ItemName.Size            = UDim2.new(0.9, 0, 0, 40)
ItemName.AnchorPoint     = Vector2.new(0.5, 0)
ItemName.Position        = UDim2.new(0.5, 0, 0, 265)
ItemName.BackgroundTransparency = 1
ItemName.TextColor3      = Color3.fromRGB(255, 255, 255)
ItemName.Font            = Enum.Font.GothamBold
ItemName.TextScaled      = true
ItemName.Text            = "Item Name"
ItemName.ZIndex          = 6

local DescLabel = Instance.new("TextLabel", ResultFrame)
DescLabel.Name           = "DescLabel"
DescLabel.Size           = UDim2.new(0.85, 0, 0, 40)
DescLabel.AnchorPoint    = Vector2.new(0.5, 0)
DescLabel.Position       = UDim2.new(0.5, 0, 0, 308)
DescLabel.BackgroundTransparency = 1
DescLabel.TextColor3     = Color3.fromRGB(180, 180, 200)
DescLabel.Font           = Enum.Font.Gotham
DescLabel.TextScaled     = true
DescLabel.TextWrapped    = true
DescLabel.Text           = "Item description here."
DescLabel.ZIndex         = 6

local SellBtn = Instance.new("TextButton", ResultFrame)
SellBtn.Name             = "SellBtn"
SellBtn.Size             = UDim2.new(0, 150, 0, 40)
SellBtn.AnchorPoint      = Vector2.new(0.5, 1)
SellBtn.Position         = UDim2.new(0.35, 0, 1, -14)
SellBtn.BackgroundColor3 = Color3.fromRGB(220, 160, 30)
SellBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
SellBtn.Font             = Enum.Font.GothamBold
SellBtn.TextScaled       = true
SellBtn.Text             = "Sell 🪙0"
SellBtn.BorderSizePixel  = 0
SellBtn.ZIndex           = 7
corner(SellBtn, 8)

local CloseBtn = Instance.new("TextButton", ResultFrame)
CloseBtn.Name            = "CloseBtn"
CloseBtn.Size            = UDim2.new(0, 150, 0, 40)
CloseBtn.AnchorPoint     = Vector2.new(0.5, 1)
CloseBtn.Position        = UDim2.new(0.65, 0, 1, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 230)
CloseBtn.TextColor3      = Color3.fromRGB(255, 255, 255)
CloseBtn.Font            = Enum.Font.GothamBold
CloseBtn.TextScaled      = true
CloseBtn.Text            = "Keep & Continue"
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex          = 7
corner(CloseBtn, 8)

print("[MainGui] GUI tree built.")
