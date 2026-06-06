# LimitedCrates — Roblox Crate Opening Game

A fully featured Roblox crate/pack-opening game with in-game currency, rarities, spinning reel animation, inventory, and daily bonuses.

---

## File Structure

```
src/
  ReplicatedStorage/Modules/
    ItemDatabase.lua       ← All items, rarities, weights
    CrateDatabase.lua      ← Crate configs (cost, pool, rarity overrides)
    SharedConfig.lua       ← Shared constants (currency name, prices, etc.)
  ServerScriptService/
    DataManager.server.lua ← DataStore save/load, auto-save
    GameServer.server.lua  ← Crate rolling, currency, remotes
  StarterGui/MainGui/
    MainGui.lua            ← Builds the full GUI hierarchy at runtime
  StarterPlayerScripts/
    ClientHandler.client.lua ← All client UI logic, animations, remote calls
default.project.json       ← Rojo project file
```

---

## How to load into Roblox Studio

### Option A — Rojo (recommended)
1. Install the [Rojo VS Code extension](https://marketplace.visualstudio.com/items?itemName=evaera.vscode-rojo) and the Roblox Studio plugin.
2. In the project root run: `rojo serve`
3. Click **Connect** in Studio and the whole tree syncs live.

### Option B — Manual copy-paste
1. Open Roblox Studio and create a new **Baseplate** place.
2. Enable **API Services** in Game Settings → Security (needed for DataStore).
3. For each `.lua` file:
   - `ItemDatabase.lua`, `CrateDatabase.lua`, `SharedConfig.lua` → paste into **ModuleScript**s inside `ReplicatedStorage/Modules/`
   - `DataManager.server.lua` → paste into a **Script** in `ServerScriptService` (name it `DataManager`)
   - `GameServer.server.lua` → paste into a **Script** in `ServerScriptService` (name it `GameServer`)
   - `MainGui.lua` → paste into a **Script** inside a **ScreenGui** named `MainGui` in `StarterGui`
   - `ClientHandler.client.lua` → paste into a **LocalScript** in `StarterPlayerScripts`

---

## Gameplay Features

| Feature | Details |
|---|---|
| **3 Crates** | Starter (100🪙), Warrior (300🪙), Prestige (1000🪙) |
| **5 Rarities** | Common · Uncommon · Rare · Epic · Legendary |
| **23 Items** | Swords, hats, shields, wings, auras, rings |
| **Spinning Reel** | Smooth easing animation reveals the result |
| **Inventory** | Scrollable grid of all owned items |
| **Sell** | Sell any item for coins from inventory or result screen |
| **Daily Bonus** | Claim 200 coins once every 20 hours |
| **DataStore** | Persistent saves; auto-saves every 60s and on leave |
| **Starting Coins** | 500 coins on first join |

---

## Customization

### Add a new item
In `ItemDatabase.lua`, add an entry to `ItemDatabase.Items`:
```lua
{ Id = "my_item", DisplayName = "My Item", Rarity = "Epic",
  Description = "A custom item.", ImageId = "rbxassetid://YOUR_ASSET_ID" },
```
Then add `"my_item"` to the `ItemPool` of any crate in `CrateDatabase.lua`.

### Add a new crate
In `CrateDatabase.lua`, add an entry to `CrateDatabase.Crates` with your desired `Cost`, `RarityWeights`, and `ItemPool`.

### Change currency name / starting coins
Edit `SharedConfig.lua` — all values are in one place.

### Add real item images
Replace the placeholder `rbxassetid://6023426912` values in `ItemDatabase.lua` with your own uploaded asset IDs.

---

## Architecture

```
Client                          Server
  │                               │
  │── OpenCrate(crateId) ────────▶│ Roll item, deduct coins
  │◀─ result { item, rarity } ────│ Add to inventory, save
  │                               │
  │── SellItem(slotIndex) ───────▶│ Remove item, add coins
  │◀─ { ok, coinAmount } ─────────│
  │                               │
  │── ClaimDaily() ──────────────▶│ Check cooldown, grant coins
  │◀─ { ok, amount | message } ───│
  │                               │
  │── GetData() ─────────────────▶│ Return snapshot
  │◀─ { coins, inventory, … } ────│
  │                               │
  │◀── UpdateCurrency(n) ─────────│ Fired after any coin change
```