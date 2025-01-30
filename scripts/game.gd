extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var mission_text: MissionText = $CanvasLayer/MissionTextPanelContainer
@onready var interaction_buttons: HBoxContainer = $CanvasLayer/InteractionButtons
@onready var gold_label: Label = $CanvasLayer/Gold/Label

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var enemy_sound_player: AudioStreamPlayer = $EnemySoundPlayer
@onready var player_sound_player: AudioStreamPlayer = $PlayerSoundPlayer

@onready var enemy_attack_timer: Timer = Timer.new()

@export var spawner: Spawner

@onready var emitter = $CanvasLayer/MissionTextPanelContainer

var battle_music = preload("res://music/BattleMusic1.1Cello.mp3")

var stick_attack_sound = preload("res://sounds/ES_Wooden Stick, Hit Log, Hard - Epidemic Sound.mp3")
var staff_attack_sound = preload("res://sounds/Weapons/StaffAttackSound.wav")
var spear_attack_sound = preload("res://sounds/Weapons/SpearAttackSound.mp3")
var sword_attack_sound = preload("res://sounds/Weapons/SwordAttackSound.mp3")
var revolver_attack_sound = preload("res://sounds/Weapons/RevolverAttackSound.mp3")

var slime_attack_sound = preload("res://sounds/Monsters/Slime/SlimeAttackSound.mp3")
var wolf_attack_sound = preload("res://sounds/Monsters/Wolf/WolfAttackSound.mp3")
var black_knight_attack_sound = preload("res://sounds/Monsters/BlackKnight/BlackKnightAttackSound.mp3")
var eldritch_attack_sound = preload("res://sounds/Monsters/EldritchBeast/EldritchBeastAttackSound.mp3")
var demon_attack_sound = preload("res://sounds/Monsters/Demon/DemonAttackSound.mp3")

var button_entered_sound = preload("res://sounds/MenuHoverBop.wav")

var player_scene = preload("res://scenes/player.tscn")
var enemy_scene = preload("res://scenes/enemy.tscn")

var player_instance
var enemy_instance
var slime_enemy_instance

var game_active = false
var player_turn = true
var is_animating = false

var attack_hit = false

const PLAYER_SCALE = 2.5
const PLAYER_SPRITE_SCALE = 10

const DEATH_PENALTY = 0.8

enum AttackKind {Strike, Slam, Orbit}

class AttackInfo:
	var ap_cost: int
	var damage_multiplier: float
	var name: String

	func _init(cost: int, multiplier: float, attack_name: String):
		ap_cost = cost
		damage_multiplier = multiplier
		name = attack_name

var attack_kinds = {
	AttackKind.Strike: AttackInfo.new(1, 1.0, "Strike"),
	AttackKind.Slam: AttackInfo.new(1, 2.0, "Slam"),
	AttackKind.Orbit: AttackInfo.new(1, 1.5, "Orbit")
}

func _ready() -> void:

	add_child(enemy_attack_timer)
	enemy_attack_timer.one_shot = true
	enemy_attack_timer.timeout.connect(_on_enemy_attack_timer_timeout)

	player_instance = player_scene.instantiate()
	add_child(player_instance)
	player_instance.scale *= PLAYER_SCALE
	player_instance.sprite.scale /= PLAYER_SPRITE_SCALE
	player_instance.position = Vector2(-500, 0)

	# TODO(Thomas): Set more of the previous player state, e.g weaponkind, stats etc
	if GameState.started == true:
		player_instance.gold = GameState.player_gold
		player_instance.stats = GameState.player_stats
		player_instance.update_stats()
		player_instance.update_weapon()
	else:
		GameState.started = true
		GameState.player_stats = player_instance.stats
		
		# TODO(Thomas): Need better initialization stuff
		GameState.next_level = 2

	player_instance.hide()
	gold_label.text = str(player_instance.gold)


	enemy_instance = spawner.spawn(self, spawner.random_enemy_kind())

func perform_orbit_attack_animation(attacker: Node2D, target: Node2D, on_complete: Callable) -> void:
	if is_animating:
		return
	
	is_animating = true
	attack_hit = false
	
	var start_pos = attacker.position
	var target_pos = target.position
	var original_rotation = attacker.rotation
	
	# Calculate initial orbit angle based on attacker's position relative to target
	var initial_angle = (start_pos - target_pos).angle()
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	
	var orbit_duration = 1.2
	var strike_duration = 0.2
	var return_duration = 0.3
	
	# Start camera zoom out much further for the orbit
	camera.zoom_out(0.4, orbit_duration * 0.2)  # Zoom out to 40% quickly
	
	# Orbit around target
	tween.tween_method(
		func(t: float):
			# Start from the initial angle and do 2 orbits
			var angle = initial_angle + t * PI * 4  # 2 full orbits
			var current_radius = (start_pos - target_pos).length() * (1.0 - t * 0.3)  # Gradually get closer
			
			var orbit_offset = Vector2(
				cos(angle) * current_radius,
				sin(angle) * current_radius
			)
			
			attacker.position = target_pos + orbit_offset
			
			# Keep card oriented to orbit direction
			var tangent_angle = angle + PI/2
			attacker.rotation = tangent_angle, 0.0, 1.0, orbit_duration
	)
	
	# Start zooming back in before the strike
	tween.tween_callback(func():
		camera.zoom_reset(strike_duration * 1.5)  # Slightly longer zoom-in for smoother transition
	)
	
	# Quick strike to target
	tween.tween_method(
		func(t: float):
			attacker.position = attacker.position.lerp(target_pos, t), 0.0, 1.0, strike_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	# Hit impact
	tween.tween_callback(func():
		attack_hit = true
		_on_attack_hit(attacker, target, true)
	)
	
	# Return to start
	tween.tween_method(
		func(t: float):
			attacker.position = target_pos.lerp(start_pos, t)
			attacker.rotation = lerp_angle(attacker.rotation, original_rotation, t), 0.0, 1.0, return_duration
	)
	
	tween.tween_callback(func():
		attacker.position = start_pos
		attacker.rotation = original_rotation
		is_animating = false
		attack_hit = false
		on_complete.call()
	)


func perform_slam_attack_animation(attacker: Node2D, target: Node2D, on_complete: Callable) -> void:
	if is_animating:
		return
	
	is_animating = true
	attack_hit = false
	
	var start_pos = attacker.position
	var target_pos = target.position
	var original_rotation = attacker.rotation
	var slam_rotation = PI/2 if attacker == player_instance else -PI/2  # Adjusted rotation based on attacker
	
	# Calculate arc control points
	var peak_height = 800
	var arc_control = Vector2(
		(start_pos.x + target_pos.x) / 2,
		min(start_pos.y, target_pos.y) - peak_height
	)
	
	var hover_pos = Vector2(target_pos.x, arc_control.y)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	
	var rise_duration = 0.6
	var hover_duration = 0.2
	var slam_duration = 0.15
	var return_duration = 0.3
	
	# Start camera zoom out as we rise
	camera.zoom_out(0.5, rise_duration * 0.5)
	
	# Rise up in arc
	tween.tween_method(
		func(t: float):
			var q0 = start_pos.lerp(arc_control, t)
			var q1 = arc_control.lerp(hover_pos, t)
			attacker.position = q0.lerp(q1, t)
			attacker.rotation = lerp_angle(original_rotation, slam_rotation, t), 0.0, 1.0, rise_duration
	)
	
	tween.tween_interval(hover_duration)
	
	tween.tween_callback(func():
		camera.zoom_reset(slam_duration)
	)
	
	# Slam down
	tween.tween_method(
		func(t: float):
			attacker.position = hover_pos.lerp(target_pos, t), 0.0, 1.0, slam_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	# Trigger hit effect at impact
	tween.tween_callback(func():
		attack_hit = true
		_on_attack_hit(attacker, target, true)
	)
	
	# Return to start
	tween.tween_method(
		func(t: float):
			attacker.position = target_pos.lerp(start_pos, t)
			attacker.rotation = lerp_angle(slam_rotation, original_rotation, t), 0.0, 1.0, return_duration
	)
	
	tween.tween_callback(func():
		attacker.position = start_pos
		attacker.rotation = original_rotation
		is_animating = false
		attack_hit = false
		on_complete.call()
	)

# Modify the original attack animation to be a separate function
func perform_swipe_attack_animation(attacker: Node2D, target: Node2D, on_complete: Callable) -> void: 
	if is_animating:
		return
	
	is_animating = true
	var start_pos = attacker.position
	var target_pos = target.position
	var original_rotation = attacker.rotation
	var attack_rotation = 0.5 if attacker == player_instance else -0.5

	var control_point = Vector2(
		(start_pos.x + target_pos.x) / 2,
		min(start_pos.y, target_pos.y) - 200
	)

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)

	var attack_duration = 0.3
	var return_duration = 0.2
	var rotation_duration = 0.15
	var hit_threshold = 0.9
	
	tween.tween_property(attacker, "rotation", attack_rotation, rotation_duration)
	
	tween.parallel().tween_method(
		func(t: float):
			var q0 = start_pos.lerp(control_point, t)
			var q1 = control_point.lerp(target_pos, t)
			attacker.position = q0.lerp(q1, t)
			
			if t >= hit_threshold and not attack_hit:
				attack_hit = true
				_on_attack_hit(attacker, target), 0.0, 1.0, attack_duration
	)

	tween.tween_property(attacker, "rotation", original_rotation, rotation_duration)
	
	tween.parallel().tween_method(
		func(t: float):
			var q0 = target_pos.lerp(control_point, t)
			var q1 = control_point.lerp(start_pos, t)
			attacker.position = q0.lerp(q1, t), 0.0, 1.0, return_duration
	)

	tween.tween_callback(func():
		is_animating = false
		attack_hit = false
		attacker.position = start_pos
		attacker.rotation = original_rotation
		on_complete.call()
	)

func perform_attack_animation(attacker: Node2D, target: Node2D, on_complete: Callable) -> void:
	if is_animating:
		return
		
	# Random choice between all three attacks
	var attack_choice = randf()
	if attack_choice < 0.33:
		perform_swipe_attack_animation(attacker, target, on_complete)
	elif attack_choice < 0.66:
		perform_slam_attack_animation(attacker, target, on_complete)
	else:
		perform_orbit_attack_animation(attacker, target, on_complete)


func start_enemy_attack_timer() -> void:
	var delay = 1.0
	enemy_attack_timer.start(delay)

func _on_enemy_attack_timer_timeout() -> void:
	if game_active and not player_turn and not is_animating and player_instance.alive and enemy_instance.alive:
		perform_attack_animation(enemy_instance, player_instance, func():
			var alive = player_instance.take_damage(player_instance.stats.calculate_damage(enemy_instance.stats))
			# TODO(Thomas): Make a screen pop up or something about the player having died
			if not alive:
				GameState.player_gold = int(DEATH_PENALTY * GameState.player_gold)
				get_tree().change_scene_to_file("res://scenes/shop.tscn")
		)

		player_turn = true

func _process(delta: float) -> void:	
	if Input.is_action_just_pressed("ui_accept"):
		mission_text.stop_typing_effect()
		
func _on_ok_button_pressed() -> void:
	start_battle_scene()

# Modified attack function to handle attack types
func perform_attack(attack_kind: AttackKind) -> void:
	if not game_active or not player_turn or is_animating or not player_instance.alive or not enemy_instance.alive:
		return
		
	var attack = attack_kinds[attack_kind]
	
	# Check if player has enough AP
	#if player_instance.stats.current_ap < attack.ap_cost:
	if player_instance.stats.ap < attack.ap_cost:
		# TODO: Show "Not enough AP" message to player
		return
		
	# Deduct AP cost
	#player_instance.stats.current_ap -= attack.ap_cost
	
	# Choose the appropriate animation
	match attack_kind:
		AttackKind.Strike:
			perform_swipe_attack_animation(player_instance, enemy_instance, func():
				_handle_attack_complete(attack.damage_multiplier))
		AttackKind.Slam:
			perform_slam_attack_animation(player_instance, enemy_instance, func():
				_handle_attack_complete(attack.damage_multiplier))
		AttackKind.Orbit:
			perform_orbit_attack_animation(player_instance, enemy_instance, func():
				_handle_attack_complete(attack.damage_multiplier))

	
func _on_attack_pressed() -> void:
	if game_active and player_turn and not is_animating and player_instance.alive and enemy_instance.alive:
		perform_attack_animation(player_instance, enemy_instance, func():
			var alive = enemy_instance.take_damage(enemy_instance.stats.calculate_damage(player_instance.stats))
			if not alive:
				# Drops
				var gold_amount = enemy_instance.generate_drop()
				GameState.player_gold += gold_amount
				gold_label.text = str(GameState.player_gold)

				# Despawn
				enemy_instance.hide()
				spawner.despawn(enemy_instance)

				#Spawn
				enemy_instance = spawner.spawn(self, spawner.random_enemy_kind())
				enemy_instance.show()
				
			player_turn = false
			start_enemy_attack_timer()
		)


func _handle_attack_complete(damage_multiplier: float) -> void:
	var damage = enemy_instance.stats.calculate_damage(player_instance.stats)
	damage = int(damage * damage_multiplier)
	
	var alive = enemy_instance.take_damage(damage)
	if not alive:
		# Drops
		var gold_amount = enemy_instance.generate_drop()
		GameState.player_gold += gold_amount
		gold_label.text = str(GameState.player_gold)

		# Despawn
		enemy_instance.hide()
		spawner.despawn(enemy_instance)

		#Spawn
		enemy_instance = spawner.spawn(self, spawner.random_enemy_kind())
		enemy_instance.show()
	
	# Move turn management to after the animation completes
	player_turn = false
	start_enemy_attack_timer()

func start_battle_scene() -> void:
	mission_text.hide()
	mission_text.stop_typing_effect()
	player_instance.show()
	enemy_instance.show()
	audio_player.stream = battle_music
	audio_player.play()
	game_active = true
	interaction_buttons.show()

func _on_escape_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/shop.tscn")

func _on_mission_text_panel_container_start_battle_scene_signal() -> void:
	await get_tree().process_frame
	start_battle_scene()

func _on_attack_hit(attacker: Node2D, target: Node2D, is_slam: bool = false) -> void:
	# Play hit sound effects
	if attacker == player_instance:
		match player_instance.kind:
			Player.WeaponKind.Stick:
				player_sound_player.stream = stick_attack_sound
			Player.WeaponKind.Staff:
				player_sound_player.stream = staff_attack_sound
			Player.WeaponKind.Spear:
				player_sound_player.stream = spear_attack_sound
			Player.WeaponKind.Sword:
				player_sound_player.stream = sword_attack_sound
			Player.WeaponKind.Revolver:
				player_sound_player.stream = revolver_attack_sound
		player_sound_player.play()
	else:  # Enemy attack
		match enemy_instance.kind:
			Enemy.EnemyKind.Slime:
				enemy_sound_player.stream = slime_attack_sound
			Enemy.EnemyKind.Wolf:
				enemy_sound_player.stream = wolf_attack_sound
			Enemy.EnemyKind.BlackKnight:
				enemy_sound_player.stream = black_knight_attack_sound
			Enemy.EnemyKind.Eldritch:
				enemy_sound_player.stream = eldritch_attack_sound
			Enemy.EnemyKind.Demon:
				enemy_sound_player.stream = demon_attack_sound
		enemy_sound_player.play()

	# Trigger appropriate camera shake
	camera.start_shake(is_slam)

func _on_strike_pressed() -> void:
	perform_attack(AttackKind.Strike)

func _on_slam_pressed() -> void:
	perform_attack(AttackKind.Slam)

func _on_orbit_pressed() -> void:
	perform_attack(AttackKind.Orbit)
