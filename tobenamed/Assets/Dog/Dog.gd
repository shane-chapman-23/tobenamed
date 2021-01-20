extends KinematicBody2D


const GRAVITY = 20

enum {
	IDLE,
	FOLLOW,
	FETCH
}

var state = IDLE
var velocity = Vector2.ZERO
var speed = 150
var fetch_speed = 200
var holding_stick = false
var stick_direction = 0
var player_direction = 0
var player_facing = 0
var player_distance = 50
var sitting = false
var scratching = false
var dog_picked_up = false

onready var stick = get_parent().get_node("Stick")
onready var Player = get_parent().get_node("Player")
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

func _ready():
	animationTree.active = true

func _physics_process(_delta):
	
	velocity.y += GRAVITY
	
	match state:
		IDLE:
			idle_state()
			
		FOLLOW:
			follow_state()
			
		FETCH:
			fetch_state()
			
	if Player.get("input_vector").x == 1:
		player_facing = 1
	elif Player.get("input_vector").x == -1:
		player_facing = -1
		
func follow_state():
	var distance_from_player = Player.position.x - position.x
	
	$SitTimer.stop()
	$ScratchTimer.stop()
	
	sitting = false
	scratching = false
	
	animationTree.set("parameters/Run/blend_position", player_direction)
	
	animationState.travel("Run")
	velocity.x = player_direction * speed
		
	if Player.position.x > position.x:
		player_direction = 1
	elif Player.position.x < position.x:
		player_direction = -1
			
	
	if distance_from_player < 50 and distance_from_player > -50:
		state = IDLE
		$SitTimer.start()
		velocity.x = 0
		
	if stick.get("throwing") == true:
		state = FETCH
		
	velocity = move_and_slide(velocity)
	
func fetch_state():
	
	var dog_overlapped = stick.get("dog_overlapped")
	var distance_from_player = Player.position.x - position.x
	
	sitting = false
	scratching = false
	
	$SitTimer.stop()
	$ScratchTimer.stop()
	
	if Player.position.x > position.x:
		player_direction = 1
	elif Player.position.x < position.x:
		player_direction = -1
	
	if stick.position.x > position.x:
		stick_direction = 1
	elif stick.position.x < position.x:
		stick_direction = -1
	
	if dog_overlapped == true:
		animationState.travel("PickUp")
		velocity.x = 0
	else:	
		if dog_picked_up == false:
			animationTree.set("parameters/Run/blend_position", stick_direction)
			animationTree.set("parameters/PickUp/blend_position", stick_direction)
			if player_facing == stick_direction:
				velocity.x = stick_direction * speed
				animationState.travel("Run")
		else:
			animationTree.set("parameters/Run/blend_position", player_direction)
			animationTree.set("parameters/Idle/blend_position", player_direction)
			velocity.x = player_direction * speed
			animationState.travel("Run")
			if distance_from_player < 50 and distance_from_player > -50:
				state = IDLE
				$SitTimer.start()
				dog_picked_up = false
				
	velocity = move_and_slide(velocity)

func pickup_animation_finished():
	dog_picked_up = true
	

func idle_state():
	var distance_from_player = Player.position.x - position.x
	
	animationTree.set("parameters/Idle/blend_position", player_direction)
	animationTree.set("parameters/Sit/blend_position", player_direction)
	animationTree.set("parameters/Scratch/blend_position", player_direction)
	
	if sitting == false and scratching == false:
		animationState.travel("Idle")
	if sitting == true and scratching == false:
		animationState.travel("Sit")
	if sitting == false and scratching == true:
		animationState.travel("Scratch")	
	
	
	
	if distance_from_player > 50 or distance_from_player < -50:
		state = FOLLOW
		
		
	if stick.get("throwing") == true:
		state = FETCH
		
	
func _on_Timer_timeout():
	sitting = true
	scratching = false
	$ScratchTimer.start()
	
func _on_ScratchTimer_timeout():
	sitting = false
	scratching = true
	$SitTimer.start()
	


