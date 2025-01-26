extends Resource

class_name Stats

var health: int = 100
var atk: int = 10
var def: int = 3
var ap: int = 10

func health_string() -> String:
	return "HP: " + str(health)

func atk_string() -> String:
	return "ATK: " + str(atk)
	
func def_string() -> String:
	return "DEF: " + str(def)

func ap_string() -> String:
	return "AP: " + str(ap)