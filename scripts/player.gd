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

var alive: bool = true
var stats: Stats
var gold: int
var kind: WeaponKind

func random_weapon_kind() -> WeaponKind:
	var weapon_kinds = WeaponKind.values()
	var random_index = randi() % weapon_kinds.size()
	return weapon_kinds[random_index]

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

func setup(new_kind: WeaponKind) -> void:
	kind = new_kind

func take_damage(amount: int) -> bool:
	alive = stats.take_damage(amount)

	update_stats()
	return alive

func _ready() -> void:
	stats = Stats.new(100, 100, 100, 4)
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

