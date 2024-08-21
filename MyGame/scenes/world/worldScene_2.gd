extends Node2D
@onready var transition = $TransitionScene
@onready var player = $Player
@onready var player_anim = $Player/Player_sprite
var dialogue = false
var to_where: String

func _ready():
	GameState.player_died = false
	GameState.player_health = 120
	$Player.walk = load("res://assets/music/SoundEffects/walk_grass.wav")
	Dialogic.start("1worldscene2")
	MusicPlayer.play_music_fight()
	$dead.visible = false
	transition.fade_out()
	transition.connect("fade_in_done", _on_fade_in_done)
	Dialogic.signal_event.connect(_on_dialogic_signal)
	if GameState.scene == "worldscene1":
		player.position = $init.position
		player_anim.flip_h = false
		player_anim.play("right")
		player_anim.stop()
	elif GameState.scene == "worldscene3":
		player.position = $village.position
		player_anim.play("down")
		player_anim.stop()
	GameState.scene = "worldscene2"

func _on_dialogic_signal(argument):
	if argument == "done1":
		GameState.spawn = true
		GameState.game_state = "play"
		$fight_timer.start()

func _physics_process(_delta):
	if not GameState.player_died:
		if GameState.player_health == 0:
			GameState.player_died = true
			$dead.set_position(player.position) 
			var camera = player.get_node("Camera2D")
			player.remove_child(camera)
			get_tree().root.add_child(camera)
			camera.position = player.position
			$Player.queue_free()
			$dead.visible = true
			GameState.spawn = false
			get_tree().change_scene_to_file("res://scenes/world/worldScene_2.tscn")

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		to_where = "worldscene3"
		transition.fade_in()
func _on_fade_in_done():
	if to_where == "worldscene1":
		get_tree().change_scene_to_file("res://scenes/world/worldScene_1.tscn")
	elif to_where == "worldscene3":
		MusicPlayer.stop()
		get_tree().change_scene_to_file("res://scenes/world/worldScene_3.tscn")
func _on_clouds_animation_finished():
	$CanvasLayer/clouds.hide()


func _on_to_worldscene_1_body_entered(body):
	if body.name == "Player":
		to_where = "worldscene1"
		transition.fade_in()



func _on_fight_timer_timeout():
	$StaticBody2D.queue_free()
	GameState.spawn = false
