# Changelog — OnePanel_PvP

All notable changes to **OnePanel_PvP** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.0.2] - 2026-10-17
### Changed
- **Native Blizzard UI Atlas Adoption**: Extracted and integrated the exact texture atlases from Blizzard's `PVPRankFrame` and `CharacterFrame` (Camelot UI):
  - `UI-Character-Info-Honor-RewardRing`: Perfectly concentric circular golden coin ring, permanently resolving the off-center rank number defect caused by `MiniMap-TrackingBorder`.
  - `UI-Character-Info-Title`: Full-width 192x36 carved header plate for the milestone rewards navigation row.
  - `UI-Character-Info-Honor-Bar`: Authentic metallic dragon-wing bezel ring.
  - `UI-Character-Info-Honor-Bar-BG-Alliance` / `-Horde`: Circular faction background disc.
  - `UI-Character-Info-Honor-Bar-BG-Glow`: Soft radial backlight glow behind the centerpiece emblem.
  - `UI-Character-Info-Honor-Icon-Alliance` / `-Horde` / `UI-Character-Info-Honor-Icon-%d`: Native military rank and faction badges.
  - `UI-Character-Info-GearSlot`: Authentic item reward slot container.
  - `UI-Character-Info-Honor-LevelBG`: Ornamental horizontal line under the rank title.
- **Side Panel Banner Text Fitting**: Integrated left (`<`) and right (`>`) arrow buttons into the outer edges of the 192px wide `UI-Character-Info-Title` banner plate, scaling title typography to 11pt `GameFontNormal` so `"Next Rewards at Rank 1"` fits cleanly with generous breathing room.
- **Rank Number Geometric Centering**: Optical centering at `(0, 1)` inside the concentric `UI-Character-Info-Honor-RewardRing` with circular alpha mask backing.
- **Progress Bar Tooltip Integration**: Detailed combat performance breakdown (Today, Yesterday, This Week, Lifetime HKs/DKs, Highest Rank) displayed in an interactive mouseover tooltip on the Rank Points progress bar.

## [0.0.1] - 2026-10-17
### Added
- **OnePanel Docking**: Registered as Tab 4 (`order = 40`, golden fist icon) in the OnePanel Suite.
- **Faction Honor Centerpiece**: Alliance Lion / Horde Wolf crest with circular rank badge medallion displaying military ranks 0 through 14.
- **Modern Gradient Progress Bar**: Rank Points progress bar styled with authentic Dragonflight/Camelot gradient textures, metallic frame, and dynamic spark.
- **Performance Statistics Cards**: Consolidated Honor & Honorable Kills metrics covering Today, Yesterday, This Week, and Lifetime HKs / DKs.
- **Interactive Rewards Preview Drawer**: Right-hand details panel detailing weekly rank point caps, next rank rewards with item tooltips, and quartermaster locations.
