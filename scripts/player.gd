extends CharacterBody2D

class_name Player

@export var health_bar: ProgressBar
@export var sprite: Sprite2D

enum WeaponKind {Stick, Staff, Spear, Sword, Revolver}

var stick_texture = preload("res://sprites/Stick_Version_3_Merged_10xScaled.png")
var staff_texture = preload("res://sprites/Staff_version_2_merged_10xScaled.png")
var sword_knight_texture = preload("res://sprites/Sword_version_2_Merged_10xScaled.png")
var spear_texutre = preload("res://sprites/Spear_version_2_Merged_10xScaled.png")
var sword_texture = preload("res://sprites/Sword_version_2_Merged_10xScaled.png")
var revolver_texture = preload("res://sprites/Revolver_version_2_10xScaled.png")

const BASE_HEALTH := 100
const BASE_ATTACK := 10
const BASE_DEFENCE := 1
const BASE_AP := 1

const WEAPON_MULTIPLIERS = {
    WeaponKind.Stick: {
        "health": 1.0,
        "atk": 1.0,
        "def": 1.0,
        "ap": 1.0
    },
    WeaponKind.Staff: {
        "health": 1.1,
        "atk": 1.3,
        "def": 1.1,
        "ap": 1.0
    },
    WeaponKind.Spear: {
        "health": 1.2,
        "atk": 1.5,
        "def": 1.2,
        "ap": 1.1
    },
    WeaponKind.Sword: {
        "health": 1.3,
        "atk": 1.8,
        "def": 1.4,
        "ap": 1.0
    },
    WeaponKind.Revolver: {
        "health": 1.5,
        "atk": 2.2,
        "def": 1.3,
        "ap": 1.2
    }
}

var alive: bool = true
var stats: Stats
var gold: int
var kind: WeaponKind

func random_weapon_kind() -> WeaponKind:
	var weapon_kinds = WeaponKind.values()
	var random_index = randi() % weapon_kinds.size()
	return weapon_kinds[random_index]

func apply_weapon_multipliers(base_stats: Stats, weapon: WeaponKind) -> Stats:
	var multipliers = WEAPON_MULTIPLIERS[weapon]
	return Stats.new(
		int(base_stats.max_health * multipliers.health),
		int(base_stats.atk * multipliers.atk),
		int(base_stats.def * multipliers.def),
		int(base_stats.max_ap * multipliers.ap),
	)

func change_weapon_kind(new_kind: WeaponKind) -> void:
	kind = new_kind
	match kind:
		WeaponKind.Stick:
			sprite.texture = stick_texture
		WeaponKind.Staff:
			sprite.texture = staff_texture
		WeaponKind.Spear:
			sprite.texture = spear_texutre
		WeaponKind.Sword:
			sprite.texture = sword_texture
		WeaponKind.Revolver:
			sprite.texture = revolver_texture
	
	# Recalculate stats with new weapon multipliers
	stats = apply_weapon_multipliers(GameState.player_stats, kind)
	update_stats()

func setup(new_kind: WeaponKind) -> void:
	kind = new_kind

func take_damage(amount: int) -> bool:
	alive = stats.take_damage(amount)

	update_stats()
	return alive

func _ready() -> void:
	stats = Stats.new(BASE_HEALTH, BASE_ATTACK, BASE_DEFENCE, BASE_AP)
	update_stats()

func _process(delta: float) -> void:
	#position = Vector2(100, 100) * cos(Time.get_unix_time_from_system()) + Vector2(100, 100) * sin(Time.get_unix_time_from_system())
	pass

func update_stats():
	health_bar.value = (stats.health / float(stats.max_health)) * 100
	$HP.text = stats.health_string()
	$ATK.text = stats.atk_string()
	$DEF.text = stats.def_string()
	$AP.text = stats.ap_string()

func update_weapon():
	match GameState.next_level:
		2: change_weapon_kind(WeaponKind.Stick)
		3: change_weapon_kind(WeaponKind.Staff)
		4: change_weapon_kind(WeaponKind.Spear)
		5: change_weapon_kind(WeaponKind.Sword)
		6: change_weapon_kind(WeaponKind.Revolver)