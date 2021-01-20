extends KinematicBody2D

const UP = Vector2(0, -1)

const ACCELERATION = 50
const JUMP_HEIGHT = -300

enum {
	MOVE,
	ATTACK,
	THROWING
}

var gravity = 20
var state = MOVE
var speed = 150
var velocity = Vector2.ZERO
var input_vector = Vector2.ZERO
var throw_animation_finished = false
var attack_direction = 0
var attack_count: int = 0
var able_to_attack = true

onready var stick = get_parent().get_node("Stick")
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

func _ready():
	animationTree.active = true

func _physics_process(_delta):
	
	match state:
		MOVE:
			move_state(_delta)
		ATTACK:
			attack_state()
		THROWING:
			throw_state()
			
	
	
func move_state(_delta):
	velocity.y += gravity
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if input_vector != Vector2.ZERO:
		animationTree.set("parameters/Idle/blend_position", input_vector.x)
		animationTree.set("parameters/Run/blend_position", input_vector.x)
		animationTree.set("parameters/Dash/blend_position", input_vector.x)
		animationTree.set("parameters/Pullback/blend_position", input_vector.x)
		animationTree.set("parameters/Throw/blend_position", input_vector.x)
		animationTree.set("parameters/PrePunch/blend_position", input_vector.x)
		animationTree.set("parameters/Punch/blend_position", input_vector.x)
		animationTree.set("parameters/PrePunch2/blend_position", input_vector.x)
		animationTree.set("parameters/Punch2/blend_position", input_vector.x)
		animationState.travel("Run")
		velocity.x = lerp(velocity.x, input_vector.x * speed, 0.2)
	else:
		animationState.travel("Idle")
		velocity.x = 0
	
	if Input.is_action_just_pressed("dash") and input_vector.x != 0:
		dash()
		
	if is_on_floor():
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = JUMP_HEIGHT
			
	if stick.get("pre_throw") == true:
		state = THROWING
	
	if Input.is_action_pressed("attack"):
		state = ATTACK
		
		
	velocity = move_and_slide(velocity, UP)

func dash():
	velocity.y = 0
	speed = 800
	animationState.travel("Dash")
	$DashTimer.start()
	
func _on_Timer_timeout():
	speed = 150
	
func throw_state():
		animationState.travel("Pullback")
		throw_animation_finished = false
		if stick.get("throwing") == true:
			animationState.travel("Throw")
			
func throw_animation_finished():
	state = MOVE
	throw_animation_finished = true
		
func attack_state():	
	
	if able_to_attack == true:
		if Input.is_action_pressed("attack"):
			if attack_count == 0:
				$AttackTimer.stop()
				animationState.travel("PrePunch")
			if attack_count == 1:
				$AttackTimer.start()
				animationState.travel("Punch2")
		if Input.is_action_just_released("attack"):
			if attack_count == 0:
				animationState.travel("Punch")
				$AttackTimer.start()
			if attack_count == 1:
				attack_count = 0
				
				able_to_attack = false
		
			
	velocity = move_and_slide(velocity)
	
func punch_animation_finished():
	state = MOVE
	attack_count = 1
	able_to_attack = true
	
func _on_AttackTimer_timeout():
	attack_count = 0
