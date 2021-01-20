extends RigidBody2D


var player_picked = false
var throw_strength = Vector2(150, -150)
var max_throw_strength = Vector2(350, -350)
var throwing = false
var pre_throw = false
var dog_overlapped = false
var throw_direction = 0 


onready var Player = get_parent().get_node("Player")
onready var Dog = get_parent().get_node("Dog")



func _physics_process(_delta):
	var distance_from_player = Player.position.x - Dog.position.x
	var player_direction = Player.input_vector
	
	if player_direction.x == 1:
		throw_direction = 1
	elif player_direction.x == -1:
		throw_direction = -1
		
#dog interaction
	if distance_from_player > 150 or distance_from_player < -150:
		var body = $detector.get_overlapping_bodies()
		for b in body:
			if b.name == "Dog":
				dog_overlapped = true
				throwing = false
			
	if Dog.get("dog_picked_up") == true:
		self.position = get_node("../Dog/Position2D").global_position
		self.rotation_degrees = get_node("../Dog/Position2D").rotation_degrees
		dog_overlapped = false
		sleeping = true
	else:
		sleeping = false

#player interaction		
	if player_picked == false:
		if Input.is_action_just_released("pick"):
			var bodies = $detector.get_overlapping_bodies()
			for b in bodies:
				if b.name == "Player":
					player_picked = true
					
	else:
		self.position = get_node("../Player/Position2D").global_position
		self.rotation_degrees = get_node("../Player/Position2D").rotation_degrees
		sleeping = true
	
		if Input.is_action_pressed("pick"):
			pre_throw = true
			if throw_strength < max_throw_strength:
					throw_strength.x += 5
					throw_strength.y -=5
					
		if Input.is_action_just_released("pick"):
			apply_impulse(Vector2(-7 * throw_direction, 0), Vector2(throw_strength.x * throw_direction, throw_strength.y))
			throw_strength = Vector2(150, -150)
			player_picked = false
			pre_throw = false
			throwing = true
			
		
			

