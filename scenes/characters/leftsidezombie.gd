extends CharacterBody2D

var jumpspeed: int = 500
var jump: bool = false
const SPEED = 100
const Gravity: int = 25
const ZOMBI_CHILD_0 = preload("res://scenes/characters/zombi_child_0.tres")
const ZOMBI_CHILD_1 = preload("res://scenes/characters/zombi_child_1.tres")
const ZOMBI_CHILD_2 = preload("res://scenes/characters/zombi_child_2.tres")
@onready var animSprite = $AnimatedSprite2D

func _ready():
	var foo : int = randi_range(0,2)
	match foo:
		0:
			animSprite.sprite_frames = ZOMBI_CHILD_0
		1:
			animSprite.sprite_frames = ZOMBI_CHILD_1
		2:
			animSprite.sprite_frames = ZOMBI_CHILD_2
		
	#position.y=200
	animSprite.play()
	pass
func _process(delta):
	velocity.x = SPEED*delta*75
	
	if jump==true:# and is_on_floor():
		velocity.y = -jumpspeed
		#jump = false
	velocity.y+=Gravity

	move_and_slide()

func _on_leftsidezombiearea_area_entered(area):
	if area.name=="Area2Dcoal" or area.name=="powerup_protect_zone":
		queue_free() # Replace with function body.


func _on_left_zombie_area_body_entered(body):
	if body.is_in_group("BRICKS"):
		jump = true
		
func _on_left_zombie_area_body_exited(body):
	if body.is_in_group("BRICKS"):
		jump = false
