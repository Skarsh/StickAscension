extends Resource

class_name Stats

var max_health: int
var health: int
var atk: int
var def: int
var ap: int

func _init(new_max_health: int, new_atk: int, new_def: int, new_ap: int):
	max_health = new_max_health
	health = new_max_health
	atk = new_atk
	def = new_def
	ap = new_ap

func health_string() -> String:
	return "HP: " + str(health)

func atk_string() -> String:
	return "ATK: " + str(atk)
	
func def_string() -> String:
	return "DEF: " + str(def)

func ap_string() -> String:
	return "AP: " + str(ap)

func calculate_damage(attacker: Stats) -> int:
	if def >= attacker.atk:
		return 0

	return attacker.atk - def

func take_damage(amount: int) -> bool:
	var alive = true
	if health - amount <= 0:
		health = 0
		alive = false
	else:
		health -= amount
	return alive