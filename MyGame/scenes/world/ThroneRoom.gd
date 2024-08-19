extends Node2D
var speed = 30
@onready var path = $Path2D/PathFollow2D
@onready var path_mc = $Path2D2/PathFollow2D
var anim_playing = false
var anim_playing_mc = false
var cutscene = true
var once = false
@onready var transition = $TransitionScene
var transition_playing = true
# Called when the node enters the scene tree for the first time.
func _ready():
	transition.fade_out()
	transition.connect("fade_out_done", _on_fade_out_done)
	transition.connect("fade_in_done", _on_fade_in_done)
	$Path2D2/PathFollow2D/mc.visible = true
	$Player.set_position($Path2D2/PathFollow2D.position)
	$Player.visible = false
	GameState.game_state = "pause"
	Dialogic.signal_event.connect(_on_dialogic_signal)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not transition_playing:
		if cutscene:
			$Player.set_position($Path2D2/PathFollow2D.position)
		path.progress += speed*delta
		path_mc.progress += speed*delta
		if path.progress_ratio < 0.9 and not anim_playing:
			$Path2D/PathFollow2D/King.play("up") 
			anim_playing = true
		elif path.progress_ratio < 1 and path.progress_ratio>=0.9:
			anim_playing = false
			if not anim_playing:
				$Path2D/PathFollow2D/King.play("right")
				anim_playing = true
		elif path.progress_ratio == 1.0 and anim_playing:
			anim_playing = false
			$Path2D/PathFollow2D/King.play("down")
			$Path2D/PathFollow2D/King.stop()
			Dialogic.start("inpalace1")
		if path_mc.progress_ratio < 1 and not anim_playing_mc:
			$Path2D2/PathFollow2D/mc.play("up")
			anim_playing_mc = true
		if path_mc.progress_ratio == 1:
			$Path2D2/PathFollow2D/mc.stop()

func _on_dialogic_signal(argument):
	if argument == "done1":
		$Path2D2/PathFollow2D/mc.visible = false
		$Player.visible = true
		GameState.game_state = "play"
		cutscene = false
		$Player/Player_sprite.play("up")
		$Player/Player_sprite.stop()
	elif argument == "done2":
		$Player/Player_sprite.play("up")
		$Player/Player_sprite.stop()
		GameState.game_state = "play"
	elif argument == "done3":
		GameState.game_state = "play"

func _on_fade_out_done():
	transition_playing = false
	
func _on_fade_in_done():
	get_tree().change_scene_to_file("res://scenes/Ending/EndingScene.tscn")
func _on_area_2d_body_entered(body):
	if body.name == "Player" and not once:
		once = true
	elif body.name == "Player" and once:
		$Player/Player_sprite.play("down")
		$Player/Player_sprite.stop()
		GameState.game_state = "pause"
		Dialogic.start("inpalace2")


func _on_end_dialogue_trigger_body_entered(body):
	if body.name == "Player":
		$Player/Player_sprite.play("up")
		$Player/Player_sprite.stop()
		GameState.game_state = "pause"
		Dialogic.start("inpalace3")


func _on_scene_change_trigger_body_entered(body):
	if body.name == "Player":
		GameState.game_state = "pause"
		$Player/Player_sprite.play("up")
		$Player/Player_sprite.stop()
		transition.fade_in()
