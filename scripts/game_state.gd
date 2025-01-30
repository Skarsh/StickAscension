extends Node

var started: bool
var player_gold: int
var player_weapon_kind: Player.WeaponKind
var player_stats: Stats
var gold_spent: int
var next_level: int
var current_scene: int = 0
var shown_scenes: Array[int] = []
var first_slime_defeated: bool = false

# Gold thresholds for each level
const LEVEL_2_GOLD: int = 1000
const LEVEL_3_GOLD: int = 3000
const LEVEL_4_GOLD: int = 6000
const LEVEL_5_GOLD: int = 10_000
const LEVEL_6_GOLD: int = 15_000
const LEVEL_7_GOLD: int = 21_000
const LEVEL_8_GOLD: int = 28_000

func get_next_gold_spent_needed_for_level() -> int:
    var gold_needed = LEVEL_2_GOLD
    match next_level:
        2: gold_needed = LEVEL_2_GOLD
        3: gold_needed = LEVEL_3_GOLD
        4: gold_needed = LEVEL_4_GOLD
        5: gold_needed = LEVEL_5_GOLD
        6: gold_needed = LEVEL_6_GOLD
        7: gold_needed = LEVEL_7_GOLD
        8: gold_needed = LEVEL_8_GOLD
    return gold_needed

func increment_next_level() -> void:
    next_level += 1

func get_next_scene_text() -> String:
    if not started:
        return ""
    
    # Handle the special case for first slime defeat
    if not shown_scenes.has(1) and first_slime_defeated:
        shown_scenes.append(1)
        return MissionText.scene_1
    
    # After first slime, only show scene text on level ups
    var scene_number = get_current_scene_number()
    
    # Check if we've reached a new level (scene) and haven't shown it yet
    if scene_number > 1 and scene_number > current_scene and not shown_scenes.has(scene_number):
        current_scene = scene_number
        shown_scenes.append(scene_number)
        match scene_number:
            2: return MissionText.scene_2
            3: return MissionText.scene_3
            4: return MissionText.scene_4
            5: return MissionText.scene_5
            6: return MissionText.scene_6
            7: return MissionText.scene_7
            8: return MissionText.scene_8
            9: return MissionText.scene_9
            10: return MissionText.scene_10
            11: return MissionText.scene_11
    
    # Opening monologue case
    if not shown_scenes.has(0):
        shown_scenes.append(0)
        return ""
        
    return ""

func get_current_scene_number() -> int:
    if gold_spent < LEVEL_2_GOLD:
        return 1
    elif gold_spent < LEVEL_3_GOLD:
        return 2
    elif gold_spent < LEVEL_4_GOLD:
        return 3
    elif gold_spent < LEVEL_5_GOLD:
        return 4
    elif gold_spent < LEVEL_6_GOLD:
        return 5
    elif gold_spent < LEVEL_7_GOLD:
        return 6
    elif gold_spent < LEVEL_8_GOLD:
        return 7
    else:
        return 8