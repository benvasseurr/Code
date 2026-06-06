-- MainGui.lua  (Script inside ScreenGui named "MainGui" in StarterGui)
-- Builds the full GUI. All panels hidden by default — player can move freely.

local ScreenGui = script.Parent
ScreenGui.ResetOnSpawn   = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder   = 5

local function corner(parent, r)
	local c = Instance.new("UICorner", parent)
	c.CornerRadius = UDim.new(0, r or 10)
end
local function listLayout(parent, dir, gap)
	local l = Instance.new("UIListLayout", parent)
	l.FillDirection = dir or Enum.FillDirection.Vertical
	l.SortOrder     = Enum.SortOrder.LayoutOrder
	l.Padding       = UDim.new(0, gap or 8)
end
local function pad(parent, px)
	local p = Instance.new("UIPadding", parent)
	local u = UDim.new(0, px)
	p.PaddingTop, p.PaddingBottom, p.PaddingLeft, p.PaddingRight = u, u, u, u
end

-- ── TOP BAR (HUD) — Active=false so it never blocks character movement ─────
local TopBar = Instance.new("Frame", ScreenGui)
TopBar.Name               = "TopBar"
TopBar.Size               = UDim2.new(1, 0, 0, 52)
TopBar.BackgroundColor3   = Color3.fromRGB(15, 15, 25)
TopBar.BackgroundTransparency = 0.15
TopBar.BorderSizePixel    = 0
TopBar.ZIndex             = 10
TopBar.Active             = false

local TitleLbl = Instance.new("TextLabel", TopBar)
TitleLbl.Size              = UDim2.new(0, 240, 1, 0)
TitleLbl.Position          = UDim2.new(0, 12, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.TextColor3        = Color3.fromRGB(255, 210, 50)
TitleLbl.Font              = Enum.Font.GothamBlack
TitleLbl.TextScaled        = true
TitleLbl.Text              = "🎰  LimitedCrates"
TitleLbl.TextXAlignment    = Enum.TextXAlignment.Left
TitleLbl.ZIndex            = 11

local CoinLabel = Instance.new("TextLabel", TopBar)
CoinLabel.Name             = "CoinLabel"
CoinLabel.Size             = UDim2.new(0, 210, 0, 36)
CoinLabel.AnchorPoint      = Vector2.new(0.5, 0.5)
CoinLabel.Position         = UDim2.new(0.5, 0, 0.5, 0)
CoinLabel.BackgroundColor3 = Color3.fromRGB(22, 22, 42)
CoinLabel.TextColor3       = Color3.fromRGB(255, 215, 50)
CoinLabel.Font             = Enum.Font.GothamBold
CoinLabel.TextScaled       = true
CoinLabel.Text             = "💰 0 Coins"
CoinLabel.ZIndex           = 11
corner(CoinLabel, 8)

local function hudBtn(name, label, xOffset)
	local btn = Instance.new("TextButton", TopBar)
	btn.Name             = name
	btn.Size             = UDim2.new(0, 108, 0, 36)
	btn.AnchorPoint      = Vector2.new(1, 0.5)
	btn.Position         = UDim2.new(1, xOffset, 0.5, 0)
	btn.BackgroundColor3 = Color3.fromRGB(50, 110, 220)
	btn.TextColor3       = Color3.fromRGB(255, 255, 255)
	btn.Font             = Enum.Font.GothamBold
	btn.TextScaled       = true
	btn.Text             = label
	btn.BorderSizePixel  = 0
	btn.ZIndex           = 11
	corner(btn, 7)
	return btn
end
hudBtn("DailyBtn",     "🎁 Daily",   -14)
hudBtn("InventoryBtn", "🎒 Items",   -130)
hudBtn("ShopBtn",      "🛒 Shop",    -246)

-- ── PANEL FACTORY ────────────────────────────────────────────────────────────
local function panel(name)
	local f = Instance.new("Frame", ScreenGui)
	f.Name               = name
	f.Size               = UDim2.new(0.86, 0, 0.80, 0)
	f.AnchorPoint        = Vector2.new(0.5, 0.5)
	f.Position           = UDim2.new(0.5, 0, 0.54, 0)
	f.BackgroundColor3   = Color3.fromRGB(16, 16, 28)
	f.BorderSizePixel    = 0
	f.Visible            = false
	f.ZIndex             = 5
	corner(f, 14)
	return f
end

local function panelTitle(parent, text)
	local l = Instance.new("TextLabel", parent)
	l.Size               = UDim2.new(1, -60, 0, 44)
	l.Position           = UDim2.new(0, 12, 0, 5)
	l.BackgroundTransparency = 1
	l.TextColor3         = Color3.fromRGB(255, 255, 255)
	l.Font               = Enum.Font.GothamBlack
	l.TextScaled         = true
	l.Text               = text
	l.TextXAlignment     = Enum.TextXAlignment.Left
	l.ZIndex             = 6
end

local function closeBtn(parent)
	local btn = Instance.new("TextButton", parent)
	btn.Name             = "CloseBtn"
	btn.Size             = UDim2.new(0, 36, 0, 36)
	btn.AnchorPoint      = Vector2.new(1, 0)
	btn.Position         = UDim2.new(1, -8, 0, 8)
	btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
	btn.TextColor3       = Color3.fromRGB(255, 255, 255)
	btn.Font             = Enum.Font.GothamBold
	btn.TextScaled       = true
	btn.Text             = "✕"
	btn.BorderSizePixel  = 0
	btn.ZIndex           = 8
	corner(btn, 7)
	return btn
end

-- ── SHOP FRAME ───────────────────────────────────────────────────────────────
local ShopFrame = panel("ShopFrame")
panelTitle(ShopFrame, "🛒  Crate Shop")
closeBtn(ShopFrame)

local CrateList = Instance.new("ScrollingFrame", ShopFrame)
CrateList.Name                = "CrateList"
CrateList.Size                = UDim2.new(1, -16, 1, -58)
CrateList.Position            = UDim2.new(0, 8, 0, 54)
CrateList.BackgroundTransparency = 1
CrateList.ScrollBarThickness  = 4
CrateList.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 120)
CrateList.CanvasSize          = UDim2.new(0, 0, 0, 0)
CrateList.AutomaticCanvasSize = Enum.AutomaticSize.Y
CrateList.BorderSizePixel     = 0
CrateList.ZIndex              = 6
listLayout(CrateList, Enum.FillDirection.Vertical, 10)
pad(CrateList, 6)

-- ── INVENTORY FRAME ───────────────────────────────────────────────────────────
local InventoryFrame = panel("InventoryFrame")
panelTitle(InventoryFrame, "🎒  My Items")
closeBtn(InventoryFrame)

local ItemGrid = Instance.new("ScrollingFrame", InventoryFrame)
ItemGrid.Name                 = "ItemGrid"
ItemGrid.Size                 = UDim2.new(1, -16, 1, -58)
ItemGrid.Position             = UDim2.new(0, 8, 0, 54)
ItemGrid.BackgroundTransparency = 1
ItemGrid.ScrollBarThickness   = 4
ItemGrid.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 120)
ItemGrid.CanvasSize           = UDim2.new(0, 0, 0, 0)
ItemGrid.AutomaticCanvasSize  = Enum.AutomaticSize.Y
ItemGrid.BorderSizePixel      = 0
ItemGrid.ZIndex               = 6
local gl = Instance.new("UIGridLayout", ItemGrid)
gl.CellSize    = UDim2.new(0, 110, 0, 130)
gl.CellPadding = UDim2.new(0, 8, 0, 8)
gl.SortOrder   = Enum.SortOrder.LayoutOrder
pad(ItemGrid, 8)

-- ── OPENING FRAME ─────────────────────────────────────────────────────────────
local OpeningFrame = Instance.new("Frame", ScreenGui)
OpeningFrame.Name              = "OpeningFrame"
OpeningFrame.Size              = UDim2.new(1, 0, 1, 0)
OpeningFrame.BackgroundColor3  = Color3.fromRGB(8, 8, 16)
OpeningFrame.BackgroundTransparency = 0.05
OpeningFrame.BorderSizePixel   = 0
OpeningFrame.Visible           = false
OpeningFrame.ZIndex            = 15

local OpenTitle = Instance.new("TextLabel", OpeningFrame)
OpenTitle.Name               = "Title"
OpenTitle.Size               = UDim2.new(1, 0, 0, 56)
OpenTitle.Position           = UDim2.new(0, 0, 0.12, 0)
OpenTitle.BackgroundTransparency = 1
OpenTitle.TextColor3         = Color3.fromRGB(255, 210, 50)
OpenTitle.Font               = Enum.Font.GothamBlack
OpenTitle.TextScaled         = true
OpenTitle.Text               = "Opening Crate..."
OpenTitle.ZIndex             = 16

local SpinContainer = Instance.new("Frame", OpeningFrame)
SpinContainer.Name             = "SpinContainer"
SpinContainer.Size             = UDim2.new(0.94, 0, 0, 180)
SpinContainer.AnchorPoint      = Vector2.new(0.5, 0.5)
SpinContainer.Position         = UDim2.new(0.5, 0, 0.5, 0)
SpinContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 32)
SpinContainer.BorderSizePixel  = 0
SpinContainer.ClipsDescendants = true
SpinContainer.ZIndex           = 16
corner(SpinContainer, 12)

local SpinFrame = Instance.new("Frame", SpinContainer)
SpinFrame.Name                = "SpinFrame"
SpinFrame.Size                = UDim2.new(0, 3200, 1, 0)
SpinFrame.Position            = UDim2.new(0, 0, 0, 0)
SpinFrame.BackgroundTransparency = 1
SpinFrame.ZIndex              = 17
listLayout(SpinFrame, Enum.FillDirection.Horizontal, 8)
pad(SpinFrame, 4)

local PointerLine = Instance.new("Frame", SpinContainer)
PointerLine.Name              = "PointerLine"
PointerLine.Size              = UDim2.new(0, 3, 1, 0)
PointerLine.AnchorPoint       = Vector2.new(0.5, 0)
PointerLine.Position          = UDim2.new(0.5, 0, 0, 0)
PointerLine.BackgroundColor3  = Color3.fromRGB(255, 60, 60)
PointerLine.BorderSizePixel   = 0
PointerLine.ZIndex            = 19

-- ── RESULT FRAME ──────────────────────────────────────────────────────────────
local ResultFrame = panel("ResultFrame")
ResultFrame.Size         = UDim2.new(0, 420, 0, 460)
ResultFrame.ZIndex       = 20

panelTitle(ResultFrame, "✨  You Got!")

local RarityLabel = Instance.new("TextLabel", ResultFrame)
RarityLabel.Name         = "RarityLabel"
RarityLabel.Size         = UDim2.new(0.85, 0, 0, 36)
RarityLabel.AnchorPoint  = Vector2.new(0.5, 0)
RarityLabel.Position     = UDim2.new(0.5, 0, 0, 52)
RarityLabel.BackgroundTransparency = 1
RarityLabel.Font         = Enum.Font.GothamBold
RarityLabel.TextScaled   = true
RarityLabel.Text         = "Legendary"
RarityLabel.ZIndex       = 21

local ItemImage = Instance.new("ImageLabel", ResultFrame)
ItemImage.Name           = "ItemImage"
ItemImage.Size           = UDim2.new(0, 160, 0, 160)
ItemImage.AnchorPoint    = Vector2.new(0.5, 0)
ItemImage.Position       = UDim2.new(0.5, 0, 0, 96)
ItemImage.BackgroundTransparency = 1
ItemImage.ScaleType      = Enum.ScaleType.Fit
ItemImage.ZIndex         = 21

local ItemName = Instance.new("TextLabel", ResultFrame)
ItemName.Name            = "ItemName"
ItemName.Size            = UDim2.new(0.9, 0, 0, 40)
ItemName.AnchorPoint     = Vector2.new(0.5, 0)
ItemName.Position        = UDim2.new(0.5, 0, 0, 266)
ItemName.BackgroundTransparency = 1
ItemName.TextColor3      = Color3.fromRGB(255, 255, 255)
ItemName.Font            = Enum.Font.GothamBold
ItemName.TextScaled      = true
ItemName.Text            = "Item Name"
ItemName.ZIndex          = 21

local DescLabel = Instance.new("TextLabel", ResultFrame)
DescLabel.Name           = "DescLabel"
DescLabel.Size           = UDim2.new(0.85, 0, 0, 44)
DescLabel.AnchorPoint    = Vector2.new(0.5, 0)
DescLabel.Position       = UDim2.new(0.5, 0, 0, 310)
DescLabel.BackgroundTransparency = 1
DescLabel.TextColor3     = Color3.fromRGB(170, 170, 190)
DescLabel.Font           = Enum.Font.Gotham
DescLabel.TextScaled     = true
DescLabel.TextWrapped    = true
DescLabel.Text           = "Description."
DescLabel.ZIndex         = 21

local SellBtn = Instance.new("TextButton", ResultFrame)
SellBtn.Name             = "SellBtn"
SellBtn.Size             = UDim2.new(0, 150, 0, 40)
SellBtn.AnchorPoint      = Vector2.new(0.5, 1)
SellBtn.Position         = UDim2.new(0.33, 0, 1, -12)
SellBtn.BackgroundColor3 = Color3.fromRGB(200, 140, 20)
SellBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
SellBtn.Font             = Enum.Font.GothamBold
SellBtn.TextScaled       = true
SellBtn.Text             = "Sell 🪙0"
SellBtn.BorderSizePixel  = 0
SellBtn.ZIndex           = 22
corner(SellBtn, 8)

local CloseBtn = Instance.new("TextButton", ResultFrame)
CloseBtn.Name            = "CloseBtn"
CloseBtn.Size            = UDim2.new(0, 150, 0, 40)
CloseBtn.AnchorPoint     = Vector2.new(0.5, 1)
CloseBtn.Position        = UDim2.new(0.67, 0, 1, -12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 110, 220)
CloseBtn.TextColor3      = Color3.fromRGB(255, 255, 255)
CloseBtn.Font            = Enum.Font.GothamBold
CloseBtn.TextScaled      = true
CloseBtn.Text            = "Keep & Continue"
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex          = 22
corner(CloseBtn, 8)

print("[MainGui] GUI tree built.")
