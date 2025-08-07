# EcoMonster Project

**Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

EcoMonster is a 2D monster ecosystem simulation built with Godot 4.4+. The game features various creatures (dragons, elementals, worms, wisps, etc.) that interact in a dynamic ecosystem with resource management, inventory systems, and autonomous behaviors.

## Working Effectively

### Bootstrap and Environment Setup
- **Install Godot 4.4+** (REQUIRED - the project uses Godot 4.4 features):
  ```bash
  cd /tmp
  wget -O godot.zip https://github.com/godotengine/godot/releases/download/4.4-stable/Godot_v4.4-stable_linux.x86_64.zip
  unzip godot.zip
  chmod +x Godot_v4.4-stable_linux.x86_64
  sudo ln -sf /tmp/Godot_v4.4-stable_linux.x86_64 /usr/local/bin/godot
  ```
  **Timing**: Download takes ~45 seconds, installation is instant.

- **Verify Installation**:
  ```bash
  godot --version
  # Should output: 4.4.stable.official.4c311cbee
  ```

### Build and Run Commands
- **Validate Project** (Fast - takes 5-10 seconds):
  ```bash
  cd /path/to/ecomonster-project
  godot --headless --validate
  ```
  **Expected**: Some warnings about missing Mana.png (known issue), but project loads successfully.

- **Run Game Headless** (For testing logic):
  ```bash
  godot --headless --script-debug-port=23456
  ```
  **Timing**: Loads in 5-10 seconds. NEVER CANCEL - let it initialize ecosystem.
  **Expected Output**: Forest/lake detection, creature spawning, inventory initialization.

- **Run Game with UI** (For visual testing):
  ```bash
  godot
  # OR to run specific scene:
  godot res://Main.tscn
  ```

### Testing and Validation Commands
- **No traditional unit tests** - this is a game project. Use runtime validation instead.
- **Validation Script** (Always run after making changes):
  ```bash
  cd /path/to/ecomonster-project
  timeout 30 godot --headless --script-debug-port=23456 > /tmp/validation.log 2>&1
  echo "Validation completed - check /tmp/validation.log for output"
  ```
  **Expected**: Should see creature spawning, inventory setup, and ecosystem initialization messages.

## Validation Scenarios

**ALWAYS test these scenarios after making changes:**

### Basic Ecosystem Validation
Run the game headless for 30 seconds and verify these messages appear:
- "Found X trees in the world"
- "Found X lakes in the map" 
- Creature spawning messages (Fire Elemental, Wisp, etc.)
- "Created 8 hotbar slots"
- "Found 56 inventory grid slots"

### Creature Behavior Testing  
- **Dragons**: Should see position updates and behavior state changes
- **Elementals**: Should see conversion messages ("Fire Elemental converted melon to water")
- **Wisps**: Should see spawn/despawn messages with life duration
- **Inventory**: Should see item assignment messages

### UI Testing (if running with graphics)
- Press Q to toggle inventory
- Use WASD for movement
- Use X/C for hotbar scrolling
- Press Space to use items

## Project Structure and Navigation

### Key Directories
```
res://
├── creatures/           # All game entities
│   ├── dragon/         # Dragon variants (base, glass)
│   ├── elemental/      # Elemental creatures
│   ├── worm/           # Worm creatures  
│   ├── player/         # Player character
│   └── [others]/       # Golem, Specter, Spider, Wisp
├── systems/            # Core game systems
│   ├── inventory/      # Inventory management
│   ├── modules/        # Shared behavior modules
│   ├── EventBus.gd     # Global event system
│   ├── ForestManager.* # Forest ecosystem
│   └── LakeManager.*   # Lake ecosystem
├── items/              # All collectible items
│   ├── drops/         # Resource drops (ores, materials)
│   └── equipment/     # Weapons, tools
├── ui/                 # User interface
├── sprites/           # Art assets
└── Main.*             # Entry point scene and script
```

### Critical Files for Development
- **Main.gd** - Game initialization, inventory setup, event handling
- **systems/EventBus.gd** - Global communication between systems (AUTOLOAD)
- **systems/modules/SearchModule.gd** - Creature search behavior (AUTOLOAD)
- **systems/modules/ConversionModule.gd** - Resource conversion logic (AUTOLOAD)
- **systems/inventory/InventoryData.gd** - Inventory management (AUTOLOAD)
- **project.godot** - Engine configuration, autoloads, input map

### Autoload Scripts (Always Available)
These scripts are globally accessible via their class names:
- `SearchModule` - Creature search and pathfinding
- `ConversionModule` - Resource transformation
- `InventoryDataScript` - Inventory management
- `TileRefreshModule` - Tilemap updates
- `WormSearchModule` - Worm-specific behavior
- `EventBus` - Global event communication

## Known Issues and Workarounds

### Missing Assets
- **Mana.png sprite is missing** from `res://items/drops/resources/` 
  - **Impact**: Parse error on startup (harmless - game still runs)
  - **Workaround**: Create placeholder 32x32 blue PNG if needed
  - **Fix**: `touch sprites/Mana.png` or copy from similar resource sprite

### Export Configuration
- **No export_presets.cfg** - project cannot be exported without setup
  - **Impact**: Export commands fail
  - **Fix**: Open in Godot editor once to generate export presets

### Resource Loading
- Some .tscn files may show "Busy" errors during initial import
  - **Impact**: Warnings during project loading (harmless)
  - **Fix**: Open project in Godot editor once to reimport assets

## Performance and Timing

### Command Timing Expectations
- **Project load**: 5-10 seconds
- **Godot download**: 45 seconds  
- **Ecosystem initialization**: 2-3 seconds
- **Full validation run**: 30 seconds (recommended timeout)

**CRITICAL**: Set timeouts to at least 60 seconds for all Godot commands. NEVER CANCEL commands early.

## Development Workflow

### Making Code Changes
1. **Always backup**: `git status && git diff` before major changes
2. **Edit files**: Use any text editor for .gd scripts
3. **Test immediately**: Run validation scenario
4. **Check output**: Look for new error messages or missing functionality
5. **Iterate**: Make small, focused changes

### Adding New Creatures
1. **Create folder**: `creatures/new_creature/base/`
2. **Copy template**: Use existing creature as starting point
3. **Update autoloads**: Add to `project.godot` if needed
4. **Test spawning**: Add to appropriate manager script
5. **Validate**: Run ecosystem test to verify behavior

### Modifying Systems
1. **Identify impact**: Check which creatures use the system
2. **Update modules**: Most logic is in `systems/modules/`
3. **Test all users**: Validate all dependent creatures still work
4. **Check EventBus**: Verify event connections remain intact

### Common File Locations
When asked about specific functionality, look here first:

- **Creature AI**: `creatures/[type]/base/[Type].gd`
- **Inventory logic**: `systems/inventory/`
- **Resource spawning**: `systems/ForestManager.gd`, `systems/LakeManager.gd`
- **Search behavior**: `systems/modules/SearchModule.gd`
- **Conversion rules**: `systems/modules/ConversionModule.gd`
- **UI handling**: `ui/` and `Main.gd`
- **Input mapping**: `project.godot` [input] section

## Quick Reference

### Most Frequently Used Commands
```bash
# Basic validation (run after every change)
godot --headless --validate

# Test gameplay (30 second ecosystem test)  
timeout 30 godot --headless --script-debug-port=23456

# Check project structure
find . -name "*.gd" | head -10

# Look for specific functionality
grep -r "search_radius" systems/
```

### Emergency Reset
If project becomes corrupted:
```bash
# Remove import cache
rm -rf .godot/
# Restart validation
godot --headless --validate
```

**Remember**: This is a game project - runtime behavior testing is more important than traditional unit tests. Always validate that creatures spawn and systems initialize correctly after making changes.