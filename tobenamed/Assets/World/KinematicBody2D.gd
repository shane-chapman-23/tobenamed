extends KinematicBody2D

const GRAVITY = 20

enum {
	MOVE,
	ATTACK,
}

var velocity = Vector2.ZERO
var state = MOVE

func _physics_process(delta):
	velocity.y = GRAVITY
	match state:
		MOVE:
			pass
		ATTACK:
			pass
			
	velocity = move_and_slide(velocity)
