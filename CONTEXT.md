# AI Context & Living Specification — OnePanel_PvP

> **Living Document**: This file serves as the primary context, architectural specification, and state-handoff document for AI-assisted development across sessions. Update this file on every development cycle ("spin").

---

## 🎯 Overview & Scope

- **Addon Name**: OnePanel_PvP
- **Current Version**: 0.0.1
- **Suite**: Part of the **OneSuite** family (OnePanel Plugin)
- **GitHub Repository**:
  - Exists: TRUE
  - URL: https://github.com/Nuros-WoW-Forever-Addons/OnePanel_PvP
- **Branching Policy**: All development must occur on a feature branch != `main` (e.g. `dev`)
- **Live Sync Path**: `/Applications/World of Warcraft/_classic_beta_/Interface/AddOns/OnePanel_PvP/`
- **Rollback Target**: Last working `main` branch commit
- **Release Package**: `.github/workflows/package.yml` generates `OnePanel_PvP-latest.zip` on push to `main`
- **Dependencies**: `OnePanel`, `OnePanelUtils`
- **Target WoW Runtimes**: WoW Forever Beta (v1.60.1 / Interface 16001)
- **Primary Goal**: Deliver a modern, authentic Player vs. Player & Honor tracking interface docked into OnePanel, replacing Blizzard's basic PvP frame with high-resolution faction crests, dynamic rank points progress bars, comprehensive honor performance matrices (Today, Yesterday, This Week, Lifetime), and an interactive rewards preview drawer.

---

## 🏗️ Architecture & Component Map

### File Structure
- `OnePanel_PvP.toc`: Manifest, declares dependencies on `OnePanel` and `OnePanelUtils`.
- `Core.lua`: Complete plugin implementation:
  - Faction crest & military rank title mapper (Alliance Lion / Horde Wolf, Ranks 0..14).
  - Rank Points progress calculation engine (weekly cap scaling up to 24,750 for Rank 14).
  - Performance statistics cards (Today, Yesterday, This Week, Lifetime HKs, DKs).
  - Interactive rewards preview drawer with item tooltips and quartermaster location guidelines.
  - Event listeners: `PLAYER_PVP_KILLS_CHANGED`, `PLAYER_PVP_RANK_CHANGED`, `HONOR_XP_UPDATE`, `PLAYER_ENTERING_WORLD`.
  - Plugin registration with OnePanel (`OnePanel:RegisterPlugin`, `order = 40`).

### Registration Payload with OnePanel
```lua
OnePanel:RegisterPlugin({
    id = "PvP",
    title = "Player vs. Player",
    icon = "Interface\\Icons\\Spell_Holy_FistOfJustice",
    order = 40,
    CreateView = CreatePvPView,
    OnShow = function(container) ... end,
    OnHide = function(container) ... end,
})
```

---

## 🔄 AI Development Cycle & Handoff Protocol

When picking up development on this addon:

1. **Orientation**: Read `CONTEXT.md` (this file) to verify current state, known issues, and active backlog items.
2. **Implementation**: Execute changes. For code refactoring or boilerplate, delegate to `qwen2.5-coder:32b` via the local `gx10_ollama` MCP server as mandated by user rules.
3. **Verification**: Verify in-game syntax with `luac -p` and test in-game using `/op` or Tab 4.
4. **Handoff Update**:
   - Move completed tasks from **Upcoming Backlog** to **Recent Completed Work**.
   - If user-facing features or commands changed, update `README.md` and append a new section in `CHANGELOG.md`.
   - Document newly discovered backlog items or edge cases in **Upcoming Backlog**.

---

## ✅ Recent Completed Work (Latest Spins)

### Spin 0.0.1 (Initial Release)
- Initial addon scaffolding and repository creation.
- Docked into OnePanel as Tab 4 (`order = 40`, golden fist icon).
- Faction crest centerpiece (Alliance Lion / Horde Wolf) with circular rank badge medallion.
- Rank Points progress bar styled with authentic Dragonflight/Camelot gradient textures.
- Lifetime, Weekly, Yesterday, and Today Honor & Honorable Kills performance matrix.
- Interactive side drawer showing Rank Cap explanations, Next Rewards preview with item tooltips, and vendor quartermaster location.

---

## 📋 Living Roadmap & Upcoming Backlog (Next Spins)

### Priority 1: High Priority (Immediate Next Spin)
- [ ] **Battleground Stats Integration**: Quick glance win/loss record for Warsong Gulch, Arathi Basin, and Alterac Valley.
- [ ] **Rank Milestone Selector**: Interactive rank slider or button group in the drawer to preview rewards for any rank from Rank 1 to Rank 14.

### Priority 2: Medium Priority (Enhancements)
- [ ] **Honor Calculator / Est. Weekly Gain**: Estimate the player's rank point gain for the upcoming Tuesday/weekly reset based on accumulated honor.
- [ ] **PvP Equipment Sets Inspector**: Visual dress-up preview of full PvP armor sets for the player's class.

---

## 🧪 Testing & Verification Guide

- **Open Panel**: Press `H` or open OnePanel and click Tab 4 (Golden Fist).
- **Emblem Check**: Confirm Alliance Lion (or Horde Wolf) appears with the player's current military rank title and rank number badge.
- **Rank Points Progress**: Verify current rank points display accurately with a gradient bar.
- **Detail Drawer**: Verify "Next Rewards at Rank X" shows the correct faction tabard, PvP insignia, or equipment with working mouse hover tooltips.
- **Drawer Collapse**: Click the yellow arrow button to verify the side drawer collapses and expands seamlessly.

---

## ⚠️ Technical Constraints & Engine Gotchas

- **Faction Specifics**: Tabards and titles vary by faction (`UnitFactionGroup("player")` returns `"Alliance"` or `"Horde"`).
- **Rank Cap Scaling**: WoW Forever caps weekly rank point gains dynamically based on the progression phase (up to 24,750 for Rank 14).
- **Safe Native Fallbacks**: Inspect native `CharacterHonorFrame` or `PVPFrame` if available without modifying Blizzard globals to avoid taint.
