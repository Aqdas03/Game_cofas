extends CharacterBody2D

signal enemy_freed

var health = 36
@export var speed = 40
@onready var anim = $Enemy_sprite
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D

var player
var player_damage = GameState.sword_damage
var player_in_hitbox
var died = false
var attack_cooldown = true
var animation_playing = false
var last_hit = null
var hit_sound = false
var MC_hit_sound = false

func _ready():
	add_to_group("Enemy")

func _physics_process(_delta):
	if health <= 0 and not died:
		if last_hit == "player":
			last_hit = null
			GameState.points += 40
		elif last_hit == "king":
			last_hit = null
		died = true
		anim.play("die")
	if player and is_instance_valid(player) and not died:
		var min_distance = 12
		var distance_to_player = position.distance_to(player.position)
		var dir = to_local(nav_agent.get_next_path_position()).normalized()
		velocity = dir * speed
		if distance_to_player > min_distance:
			velocity = dir * speed
		else:
			velocity = Vector2.ZERO
		enemy_anim()
		move_and_slide()
	elif player_in_hitbox and not died:
		if not animation_playing and attack_cooldown:
			$attack_timer.start()
			attack_cooldown = false
			var x_diff = player_in_hitbox.position.x - position.x
			var y_diff = player_in_hitbox.position.y - position.y
			if y_diff >= -32 and y_diff <= 0:
				if x_diff >= -36 and x_diff <= -10:
					anim.flip_h = false
					anim.play("attack_left")
				elif x_diff >= 9 and x_diff <= 36:
					anim.flip_h = true
					anim.play("attack_left")
				else:
					anim.flip_h = false
					anim.play("attack_up")
			elif y_diff >= 0 and y_diff <= 23:
				if x_diff >= -36 and x_diff <= -9:
					anim.flip_h = false
					anim.play("attack_left")
				elif x_diff >= 9 and x_diff <= 36:
					anim.flip_h = true
					anim.play("attack_left")
				else:
					anim.flip_h = false
					anim.play("attack_down")
			else:
				pass 
	elif not (animation_playing and player and player_in_hitbox) and not died:
		anim.stop()
	if GameState.player_died:
		$hit.stop()
func _on_detection_area_body_entered(body):
	if body.name == "Player":
		player = body

func _on_detection_area_body_exited(body):
	if body.name == "Player":
		player = null

func _on_attack_area_body_entered(body):
	if body.name == "Player":
		player_in_hitbox = body
		player = null

func _on_attack_area_body_exited(body):
	if body.name == "Player":
		player_in_hitbox = null
		player = body

func _on_enemy_sprite_animation_finished():
	if anim.animation in ["attack_left", "attack_up", "attack_down"]:
		animation_playing = false
		if player_in_hitbox:
			GameState.player_health -= 10
	elif anim.animation == "die":
		emit_signal("enemy_freed")
		randomize()
		var chance = randi_range(1,15)
		if chance == 1:
			GameState.items["health_potion"] += 1
		elif chance == 2:
			GameState.items["invin_potion"] += 1
		queue_free()

func enemy_anim():
	var x_diff = player.position.x - position.x
	var y_diff = player.position.y - position.y
	if x_diff > 5:
		anim.flip_h = true
		if y_diff > 5:
			anim.play("left_down")
		elif y_diff < -5:
			anim.play("left_up")
		else:
			anim.play("left")
	elif x_diff < -5:
		anim.flip_h = false
		if y_diff > 5:
			anim.play("left_down")
		elif y_diff < -5:
			anim.play("left_up")
		else:
			anim.play("left")
	else:
		if y_diff > 5:
			anim.play("down")
		elif y_diff < -5:
			anim.play("up")

func _on_attack_timer_timeout():
	attack_cooldown = true

func _on_hurtbox_area_entered(area):
	if area.is_in_group("player_attack"):
		last_hit = "player"
		health -= player_damage
		if not MC_hit_sound:
			$hit.play()
			MC_hit_sound = true
	if area.is_in_group("king_attack"):
		last_hit = "king"
		health -= 20
		if not hit_sound:
			$hit.play()
			hit_sound = true

func makepath():
	if is_instance_valid(player):
		nav_agent.target_position = get_parent().get_node("Player").position

func _on_timer_timeout():
	makepath()

func stop_music():
	$hit.stop()
