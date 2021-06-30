extends KinematicBody2D

var BULLET_SCENE = preload("res://Characters/Bullet.tscn")
onready var animatedSprite = get_node("AnimatedSprite")


var GRAVITY = 10
const SPEED = 30
const FLOOR = Vector2(0,-1)
var velocity = Vector2.ZERO
var direction = 1
var player = null
var count = rpm
const rpm = 100
enum {  # list
	IDLE,
	ATTACK,
	DEAD
}
var state = IDLE
func _ready():
	pass
	 


func _physics_process(delta): # delta = time that the last fram took to process
	match state:
		IDLE:
			idle_state(delta)
		ATTACK:
			attack_state(delta)	
		DEAD:
			dead_state(delta)
func dead_state(delt):
	velocity = Vector2.ZERO
func idle_state(delta):
	velocity = Vector2.ZERO
	velocity.x = SPEED * direction
	velocity.y += GRAVITY
	velocity = move_and_slide(velocity, FLOOR)
	
	if is_on_wall():
		direction = direction * -1
		$FallOffCast.position.x *= -1
		if animatedSprite.flip_h == false:
			animatedSprite.flip_h = true
		else:
			animatedSprite.flip_h = false
	if $FallOffCast.is_colliding() == false:
		direction = direction * -1
		$FallOffCast.position.x *= -1
		if animatedSprite.flip_h == false:
			animatedSprite.flip_h = true
		else:
			animatedSprite.flip_h = false
	animatedSprite.animation = "Run"
	
func attack_state(delta):
	#var real_player = get_node("/root/Wssorld/player")
	
	animatedSprite.animation = "Idle"
	if player.position.x > self.position.x:
		animatedSprite.flip_h = false
	else:
		animatedSprite.flip_h = true
	velocity = Vector2.ZERO
	velocity.y += GRAVITY
	if player != null:
		velocity = position.direction_to(player.position) * SPEED
		velocity = velocity.normalized()
		if is_on_floor():
			velocity = move_and_slide(velocity, FLOOR)
	if count == 0:
		#animatedSprite.animation = "Attack"
		fire()
		count = rpm
	count+=-1
		#fire()
	#if real_player:
	#	var real_direction = (real_player.position - position).normalized()
	
func _on_Area2D_body_entered(body):
	print("found him")
	if body != self and state != DEAD:
		player = body
		state = ATTACK
func _on_Area2D_body_exited(body):
	player = null
	if state != DEAD:
		state = IDLE

func fire():
	animatedSprite.animation = "Attack"
	var bullet = BULLET_SCENE.instance()
	bullet.position = get_position()
	bullet.player = player
	get_parent().add_child(bullet)
	$Timer.set_wait_time(1)

#func _on_Timer_timeout():
#	if player!=null:
#		fire()


func _on_hurtbox_body_entered(body):
	animatedSprite.animation = "HitandDie"
	if state == DEAD:
		queue_free()
	else:
		state = DEAD
	
