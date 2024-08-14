extends Node2D



func _ready():
	if GameState.scene_neww == "Scene_1":
		$Player.set_position($init.position)
	elif GameState.scene_neww == "Scene_2":
		$Player.set_position($right.position)
	$CanvasLayer/ColorRect.visible = true
	$CanvasLayer/ColorRect/AnimationPlayer.play("hi")
	

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		$CanvasLayer/ColorRect.visible = true
		$CanvasLayer/ColorRect/AnimationPlayer.play("bye")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "hi":
		GameState.game_state = 'play'
		$CanvasLayer/ColorRect.visible = false
	if anim_name == "bye":
		GameState.scene_neww = "back"
		get_tree().change_scene_to_file("res://scenes/world/world_init.tscn")




func _on_to_fight_1_body_entered(body):
	if body.name == "Player":
		get_tree().change_scene_to_file("res://scenes/world/worldScene_2.tscn")
