extends KinematicBody2D
onready var animatedSprite = get_node("AnimatedSprite")
const UP = Vector2(0,-1)
var GRAVITY = 20
const MAXFALLSPEED = 135
const MINFALLSPEED = 33
const MAXSPEED = 130
const FRICTION = 500
const JUMPFORCE = 270
const FASTFALLFORCE = 200
var health = 3
var truHealth = 3
var upSpeed  = 20
var motion = Vector2()
var jumps_left = 2
var poop_left = 3
var climbVelocity = Vector2()
var POOP_SCENE = preload("res://Characters/Player_Bullet.tscn")
#var icon1 = preload("res://neutralgirish.png")
#var icon2 = preload("res://happygirish.png")
var ladder_on = false
enum{
	MOVE,
	CLIMB
}
var STATE = MOVE
func _ready():
	pass
func poop():
	var poop = POOP_SCENE.instance()
	poop.position = get_position()
	poop.position.y += 10
	get_parent().add_child(poop)
func CheckLadderAndTakeAction():
	
	if ladder_on == true:
		GRAVITY = 0
		print("ladder boi!")
		if Input.is_action_just_pressed("ui_up"):
			motion.y -= upSpeed
		elif Input.is_action_just_pressed("ui_down"):
			motion.y += upSpeed
func _physics_process(delta):
	match STATE:
		MOVE:
			move_state(delta)
		CLIMB:
			climb_state(delta)
func move_state(delta):
	
	GRAVITY = 20
	#CheckLadderAndTakeAction()
	motion.y += GRAVITY
	if Input.is_action_pressed("glide"):
			motion.y += -1 * (GRAVITY/1.5)
	if motion.y > MAXFALLSPEED:
		motion.y = MAXFALLSPEED
	if Input.is_action_pressed("ui_right"):
		animatedSprite.animation = "Run"
		motion.x = MAXSPEED
	elif Input.is_action_pressed("ui_left"):
		motion.x = -MAXSPEED
		
	else:
		motion = motion.move_toward(Vector2.ZERO, FRICTION * delta)
	if is_on_floor():
		jumps_left = 2
		poop_left = 3
		
	if Input.is_action_just_pressed("ui_up") and ladder_on == false:
		if jumps_left > 0:
			motion.y = -JUMPFORCE
			jumps_left -= 1
	if Input.is_action_just_pressed("ui_down") and ladder_on == false:
		motion.y = MAXSPEED
	#if Input.is_action_just_pressed("glide"):
		#motion.y += -1 * GRAVITY
	motion = move_and_slide(motion, UP)
	if Input.is_action_just_pressed("attack"):
		if poop_left > 0:
			poop()
			poop_left -=1
	var axisX = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if axisX > 0:
		animatedSprite.animation = "Run"
		animatedSprite.flip_h = false
	elif axisX < 0:
		animatedSprite.animation = "Run"
		animatedSprite.flip_h = true
	else:
		animatedSprite.animation = "Idle"
	if truHealth - health == 1:
		truHealth = truHealth - 1
		animatedSprite.animation = "Hit"
	#var tran = get_global_transform()
	#if Input.is_action_just_pressed("jump"):
		#var my_sprite = get_node("neutralgirish")
		#my_sprite.set_texture(icon2)
		#my_sprite.scale.x *= 1.1
		#my_sprite.scale.y *= 1.1
	#if Input.is_action_just_pressed("ui_cancel"):
		#var my_sprite = get_node("neutralgirish")
		#my_sprite.set_texture(icon1)
		#my_sprite.scale.x *= 0.75
		#my_sprite.scale.y *= 0.75
	#if Input.is_action_just_pressed("ui_focus_prev"):
		#var layer = AudioStreamPlayer.new()
		#self.add_child(layer)
		#layer.stream = load("res://Audio/Flume Birthday ID.ogg")
		#layer.play()
func climb_state(delta):
	if ladder_on == true:
		animatedSprite.animation = "Idle"
		print("ladder boi!")
		if Input.is_action_just_pressed("ui_up"):
			
			motion.y += upSpeed 
		elif Input.is_action_just_pressed("ui_down"):
			#climbVelocity.y += upSpeed * delta
			motion.y += upSpeed
		elif Input.is_action_just_pressed("ui_right"):
			motion.x += upSpeed/2
		elif Input.is_action_just_pressed("ui_left"):
			motion.x -= upSpeed/2
		motion = move_and_slide(motion, UP)
	

func _on_Area2D_body_entered(body):
	var bullet = body
	if health == 0:
		queue_free()
	else:
		animatedSprite.animation = "Hit"
		health -= 1
	print(1)
	bullet.queue_free()
	


func _on_LadderBody_body_entered(body):
	ladder_on = true
	STATE = CLIMB


func _on_LadderBody_body_exited(body):
	ladder_on = false
	STATE = MOVE
