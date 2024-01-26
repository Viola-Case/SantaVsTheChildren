extends Node2D

var throw_coal_scene: PackedScene = preload("res://scenes/projectiles/parabola_coal.tscn")
var death_scene: PackedScene = preload("res://scenes/temporary_deathscene.tscn")
var powerup_jump: PackedScene = preload("res://scenes/powerups/powerup_jump.tscn")
var right_side_zombies: PackedScene = preload("res://scenes/characters/zombi_child.tscn")
var left_side_zombies: PackedScene = preload("res://scenes/characters/leftsidezombie.tscn")
var missile_fragment: PackedScene = preload("res://scenes/projectiles/collectable_fragment_missile.tscn")
var POLARBEAR: PackedScene = preload("res://scenes/characters/polar_bear.tscn")
#var pjump: PackedScene = preload("res://scenes/powerups/powerup_jump.tscn")

var did_santa_die: bool = false
var level_num: int = 1
var change_level: bool = false
var check_dead: bool = false
var cured: bool = false
const cured_zombie_rate: int = 2

var Zombie_Positions_Arr: Array = []
var dist_to_left_zomb = 500

func _on_santa_throw(pos,direction):
	const coal_speed: int = 215
	var pcoal = throw_coal_scene.instantiate() as RigidBody2D
	pcoal.position = pos
	pcoal.gravity_scale = 1
	pcoal.linear_velocity = Vector2(direction*(coal_speed+abs($Santa.velocity.x)),-200)
	$Projectiles.add_child(pcoal)
	
var level_length: int = 20000
var level_scale = level_length / 20
var zombie_rate = 2
var start = Vector2(38,596)

func spawn_missile_parts():
	var n=1
	var f=7
	while n<=1.5*f:
		var missile_part = missile_fragment.instantiate() as Area2D
		missile_part.position = Vector2(randi_range(100,level_length),576)
		add_child(missile_part)
		n+=1

func _ready():
	#spawn_missile_parts()
	$ZOMBIES/Zombie_timer.wait_time=zombie_rate
	$ZOMBIES/Zombie_timer.start()
	$Notground1.position.y = 592
	$Notground2.position.y = 592
	$Santa.can_missile = true
	$Notground2.visible=false
	$Notground1.visible=true

func _process(_delta):
	var tree = get_tree()
	if $Santa.position.x <9000 or $Santa.position.x>19400:
		$Notground2.visible=false
		$Notground1.visible=true
		$Notground1.position.x = $Santa.position.x
	if $Santa.position.x >= 9000 and $Santa.position.x<=19400:
		$Notground2.visible=true
		$Notground1.visible=false
		$Notground2.position.x = $Santa.position.x
		for child in $ZOMBIES/new_zombies.get_children():
			$ZOMBIES/new_zombies.remove_child(child)
	if did_santa_die==false and cured==false:
		zombie_rate = (PI/10)+(level_length / ($Santa.position.x + (0.1 * level_length)**(PI/2.718))) #/ level_scale 
		#print(zombie_rate,"     ",$Santa.position.x)
	if did_santa_die==true:
		$Control.reset_level()
		#level_reset(start)
	if check_dead==true:
		var dead_scene = death_scene.instantiate() as Sprite2D
		$child_node.add_child(dead_scene)
		dead_scene.position=$Santa.position
		
	#did_santa_die=true
	

		if Input.is_key_pressed(KEY_Y):
			for i in $child_node.get_children():
				i.queue_free()
			for i in $ZOMBIES/new_zombies.get_children():
				i.queue_free()
			$Control.reset_level()
			check_dead=false
			did_santa_die=true
	Zombie_Positions_Arr=[-500]	
	#if get.tree().has_group("Left Zombies"):	
	for zomb in tree.get_nodes_in_group("Left Zombies"):

		if $Santa.position.x > zomb.position.x:

			Zombie_Positions_Arr.append(zomb.position.x)

	dist_to_left_zomb = floor(($Santa.position.x-Zombie_Positions_Arr.max())/30)

	$Santa/Control/Label.text = str(dist_to_left_zomb)+"m"
	if change_level==true:
		start = Vector2(38,level_num*576)
		level_reset(start)

	$Santa/Control/Label2.text = ": "+str($Santa.collected_missile_fragments)+"/"+str($Santa.needed_missile_fragments)
	$Santa/Control/RichTextLabel.text = str($Santa.lives) + " lives"
	pass


func _on_santa_missile(pos,direction):
	var pcoal = throw_coal_scene.instantiate() as RigidBody2D
	pcoal.position = pos
	pcoal.gravity_scale = 0.05
	pcoal.linear_velocity = Vector2(direction*450,0)
	$Projectiles.add_child(pcoal)


func _on_santa_die():
	check_dead=true

func level_reset(start):
	
	#if level_num==3:
		#spawn_missile_parts()
	if level_num==3:
		cured=true
		zombie_rate = cured_zombie_rate
	
	did_santa_die=false
	$Santa.dead=false
	#$Santa.set_collision_layer_value(4,true)
	$Santa.collected_missile_fragments=0
	$Santa.position = start
	$ZOMBIES/Zombie_timer.wait_time=zombie_rate
	$ZOMBIES/Zombie_timer.start()

#func level_next():
	

func _on_zombie_timer_timeout():
	#if did_santa_die==false:
	var right_zombie = right_side_zombies.instantiate() as CharacterBody2D
	var left_zombie = left_side_zombies.instantiate() as CharacterBody2D
	right_zombie.position.x = $Santa.position.x + 500 + randi_range(-10,10)
	right_zombie.position.y = $Santa.position.y-200
	left_zombie.position.x = $Santa.position.x - 500 + randi_range(-10,10)
	right_zombie.position.y = $Santa.position.y-200
	#if !right_zombie.is_on_wall():
		#$ZOMBIES/new_zombies.add_child(right_zombie)
	$ZOMBIES/new_zombies.add_child(left_zombie)
	left_zombie.add_to_group("Left Zombies")
	if !right_zombie.is_on_wall_only() and !right_zombie.is_on_ceiling_only():	
		$ZOMBIES/new_zombies.add_child(right_zombie)
	#$ZOMBIES/new_zombies.add_child(right_zombie)
	#$ZOMBIES/new_zombies.add_child(left_zombie)
	#left_zombie.add_to_group("Left Zombies")
	#print('new-zombie')
	$ZOMBIES/Zombie_timer.wait_time=zombie_rate
	$ZOMBIES/Zombie_timer.start()

func _on_the_end_1_level_done():
	var tree = get_tree()
	if $Santa.collected_missile_fragments >= $Santa.needed_missile_fragments:
		$the_end_1/ColorRect.visible=false
		var scenePath: String = str(tree.current_scene.scene_file_path)
		var newscenePath = "res://scenes/story_scene_"+str(int(scenePath[24]))+".tscn"
		$Control.change_scene(newscenePath)
	else:
		$the_end_1/ColorRect.visible=true


func _on_idk_what_this_is_anymore_body_entered(body):
	pass
	#if body.name=="Santa":
		#var n = 1
		
		#var right_zombie = right_side_zombies.instantiate() as CharacterBody2D
		#right_zombie.position = Vector2(16064,384)
		#while n < 30:
			#$ZOMBIES/new_zombies.add_child(right_zombie)
			#n+=1

var polar_bear_trigger: int = 0
func _on___body_entered(body):
	if body.name=="Santa":
		var polarbear = POLARBEAR.instantiate()
		if polar_bear_trigger==0:
			polarbear.position = Vector2(14074,400)
			polar_bear_trigger +=1
		else:
			polarbear.position = Vector2(3,3)
		$child_node.add_child(polarbear) # Replace with function body.

