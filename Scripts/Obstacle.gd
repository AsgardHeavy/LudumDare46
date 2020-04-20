extends StaticBody2D

export var manaCost : int = 5
export (PackedScene) var deathParticle

func _ready():
	pass

func start_at(pos : Vector2):
	self.position = pos

func destroy_obstacle():
	var deathThroes = deathParticle.instance()
	add_child(deathThroes)
	deathThroes.emitting = true
	yield(get_tree().create_timer(1.1), "timeout" )
	queue_free()

func _on_ClickableZone_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		get_tree().set_input_as_handled()
		if event.button_index == BUTTON_LEFT && event.pressed:
			return
		elif event.button_index == BUTTON_RIGHT && event.pressed:
			destroy_obstacle()

func _hit():
	print("Obstacle Hit")
