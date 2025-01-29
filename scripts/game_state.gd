extends Node

var started: bool
var player_gold: int
var player_weapon_kind: Player.WeaponKind
var player_stats: Stats
var gold_spent: int

var next_level: int

# TODO(Thomas): Replace with some formula
# 1000
# 3000
# 6000
# 10000
# 15000
# 21000
# 28000
const LEVEL_2_GOLD: int = 1000
const LEVEL_3_GOLD: int = 3000
const LEVEL_4_GOLD: int = 6000

