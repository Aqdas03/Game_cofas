extends Node2D
@onready var player = $Player
@onready var player_anim = $Player/Player_sprite
@onready var transition = $TransitionScene

func _ready():
	$Player.walk = load("res://assets/music/SoundEffects/walk_grass.wav")
	GameState.game_state = "play"
	Dialogic.signal_event.connect(_on_dialogic_signal)
	transition.connect("fade_in_done", _on_fade_in_done)
	transition.connect("fade_out_done", _on_fade_out_done)
	if GameState.player_pos:
		player.position = GameState.player_pos
		GameState.player_pos = null
	if GameState.scene == "window": 
		GameState.game_state = "pause"
		$appearing.set_position(Vector2(159,125))
		player.hide()
		player.set_position($init.position)
		$appearing.visible = false
		$CanvasLayer/clouds.play("hi")
	elif GameState.scene == "worldscene1":
		transition.fade_out()
		player.set_position($up.position)
		player_anim.play("down")
		player_anim.stop()
		$CanvasLayer/clouds.hide()
	GameState.scene = "worldinit"

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		transition.fade_in()

func _on_fade_in_done():
	get_tree().change_scene_to_file("res://scenes/world/worldScene_1.tscn")
	
func _on_clouds_animation_finished():
	$CanvasLayer.visible = false
	$appearing.visible = true
	$appearing.play("in")

func _on_fade_out_done():
	GameState.game_state = "play"


func _on_appearing_animation_finished():
	MusicPlayer.stop()
	$appearing.visible = false
	Dialogic.start("world_init1")
	$Player.show()

func _on_dialogic_signal(argument):
	if argument == "play_sound_now":
		MusicPlayer.play_fight()
	elif argument == "done1":
		GameState.pausable = true
		GameState.game_state = "play"
		$dialogue_cooldown.start()
	elif argument == "done2":
		GameState.game_state = "play"
	


func _on_dialogue_cooldown_timeout():
	$Player/Player_sprite.stop()
	GameState.game_state = "pause"
	Dialogic.start("world_init2")

func on_fade_out_done():
	GameState.game_state = "play"
