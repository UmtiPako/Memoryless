extends Node

signal player_dashed
signal enemy_killed

var ev_sahne: PackedScene = preload("res://Scenes/Places/ev/sahne_ev.tscn")
var sokak1: PackedScene = preload("res://Scenes/Places/dışarı/sokak_1.tscn")
var sokak2: PackedScene = preload("res://Scenes/Places/dışarı/sokak_2.tscn")
var sokak3: PackedScene = preload("res://Scenes/Places/dışarı/sokak_3.tscn")
var manav1: PackedScene = preload("res://Scenes/Places/dışarı/Manav1.tscn")
var manav2: PackedScene = preload("res://Scenes/Places/dışarı/Manav2.tscn")
var manav3: PackedScene = preload("res://Scenes/Places/dışarı/Manav3.tscn")
const BERBER_1 = preload("res://Scenes/Places/içeri/Berber1.tscn")
const HIJYEN_REYONU_1 = preload("res://Scenes/Places/market/HijyenReyonu1.tscn")
const HIJYEN_REYONU_2 = preload("res://Scenes/Places/market/HijyenReyonu2.tscn")
const HIJYEN_REYONU_3 = preload("res://Scenes/Places/market/HijyenReyonu3.tscn")
const KASAP_1 = preload("res://Scenes/Places/market/Kasap1.tscn")
const KASAP_2 = preload("res://Scenes/Places/market/Kasap2.tscn")
const KASAP_3 = preload("res://Scenes/Places/market/Kasap3.tscn")
const PASTANE_1 = preload("res://Scenes/Places/market/Pastane1.tscn")
const PASTANE_2 = preload("res://Scenes/Places/market/Pastane2.tscn")
const PASTANE_3 = preload("res://Scenes/Places/market/Pastane3.tscn")

var scenes: Array[PackedScene] = [ev_sahne, sokak1, sokak2, sokak3, 
manav1, manav2, manav3, BERBER_1, HIJYEN_REYONU_1, HIJYEN_REYONU_2, HIJYEN_REYONU_3,
KASAP_1, KASAP_2, KASAP_3, PASTANE_1, PASTANE_2, PASTANE_3]

var player_health: int = 4

var enemies_in_room: int

func _process(delta: float) -> void:
	pass

func set_enemy_count_in_room() -> void:
	var count = 0
	for node in get_tree().current_scene.get_children():
		if node.is_in_group("enemies"):
			count += 1
	enemies_in_room = count
			

func select_random_room() -> PackedScene:
	return scenes[randf_range(0, len(scenes))]

func hit_stop(timeScale, duration):
	Engine.time_scale = timeScale
	await get_tree().create_timer(duration * timeScale).timeout
	Engine.time_scale = 1
