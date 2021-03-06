extends KinematicBody2D

enum directions {UP, DOWN, LEFT, RIGHT}

export var speed : float = 50.0
export var health : int = 1
export var damage : int = 1
export var battleCry : String = "Raaaaawrgh!"
export var deathCry : String = "Bwarf!"
export (PackedScene) var deathParticle
var tileSize : int = 64
var screensize : Vector2
var walkingPath : = PoolVector2Array() setget set_path
var localNav2D : Navigation2D
var target : Vector2

func _ready():
	screensize = get_viewport_rect().size
	set_process(false)

func _process(delta: float):
	var moveDistance : = speed * delta
	move_along_path(moveDistance)
	if get_slide_count() > 0:
		var collision = get_slide_collision(0)
		if collision != null:
			pick_new_path()
	
func start_at(pos : Vector2):
	self.position = pos
	
func move_along_path(distance : float):
	var startPosition : = position
	for i in range(walkingPath.size()):
		var distanceToNextPosition : = startPosition.distance_to(walkingPath[0])
		if distance <= distanceToNextPosition and distance >= 0.0:
			#position = startPosition.linear_interpolate(walkingPath[0], distance / distanceToNextPosition)
			var direction = walkingPath[0] - position
			move_and_slide(direction * (distance / distanceToNextPosition) * speed)
			break
		elif distance < 0.0:
			position = walkingPath[0]
			set_process(false)
			break
		distance -= distanceToNextPosition
		startPosition = walkingPath[0]
		walkingPath.remove(0)

func set_path(value : PoolVector2Array):
	walkingPath = value	
	if value.size() == 0:
		return
	set_process(true)

func pick_new_path():
	randomize()
	var newDir = randi() % 4 + 1
	var newDestination : Vector2
	match newDir:
		directions.UP:
			newDestination = Vector2(self.position.x,clamp(self.position.y - (tileSize * 2),0,screensize.y))
			set_path(self.localNav2D.get_simple_path(self.global_position, newDestination))
		directions.DOWN:
			newDestination = Vector2(self.position.x,clamp(self.position.y + (tileSize * 2),0,screensize.y))
			set_path(self.localNav2D.get_simple_path(self.global_position, newDestination))
		directions.LEFT:
			newDestination = Vector2(clamp(self.position.x - (tileSize * 2),0,screensize.x),self.position.y)
			set_path(self.localNav2D.get_simple_path(self.global_position, newDestination))
		directions.RIGHT:
			newDestination = Vector2(clamp(self.position.x + (tileSize * 2),0,screensize.x),self.position.y)
			set_path(self.localNav2D.get_simple_path(self.global_position, newDestination))

func return_to_target_path():
	set_path(self.localNav2D.get_simple_path(self.global_position, target))

func die():
	show_dialogue(deathCry)
	$Sound/DeathCry.play()
	var deathThroes = deathParticle.instance()
	add_child(deathThroes)
	deathThroes.emitting = true
	yield(get_tree().create_timer(1.1), "timeout" )
	queue_free()
	
func receive_damage(damage):
	health = health - damage
	if health <= 0:
		die()
	else:
		var deathThroes = deathParticle.instance()
		add_child(deathThroes)
		deathThroes.emitting = true

func show_dialogue(string):
	$DialogueLabel.text = string
	$DialogueLabel.visible = true
	$DialogueLabel/DialogueTimer.start()

func _on_DialogueTimer_timeout():
	$DialogueLabel.visible = false

func _on_BattleCryTimer_timeout():
	show_dialogue(battleCry)

func _on_GetBackToWorkTimer_timeout():
	return_to_target_path()
