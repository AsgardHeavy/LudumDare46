extends StaticBody2D

export var gardenerBenefit : float = 0.5
export (PackedScene) var deathParticle

enum growthStages {SEEDLING,SAPLING,MATURE,ELDER}
var growthLevel : int
var quality : int = 1
var canBeGardened : bool = true

func _ready():
	growthLevel = growthStages.SEEDLING
	$Sprite.frame = 0
	
func start_at(pos : Vector2):
	self.position = pos

func _on_ActionRadius_body_shape_entered(body_id, body, body_shape, area_shape):
	if body.is_in_group("BadGuys"):
		$Sound/ActionSFX.play()
		handle_growth_stage_activities(body)
	elif body.is_in_group("Gardeners"):
		body.pause_for_activity()
	
func handle_growth_stage_activities(body):
	match growthLevel:
		growthStages.SEEDLING:
			seedling_activity(body)
		growthStages.SAPLING:
			$AnimationPlayer.play("sapling_activity")
			sapling_activity(body)
		growthStages.MATURE:
			$AnimationPlayer.play("mature_activity")
			mature_activity(body)
		growthStages.ELDER:
			$AnimationPlayer.play("elder_activity")
			elder_activity(body)
	
func seedling_activity(body):
	return
	
func sapling_activity(body):
	damage_passerby(body,quality)
	
func mature_activity(body):
	damage_passerby(body,quality*2)
	
func elder_activity(body):
	damage_passerby(body,quality*3)
	
func damage_passerby(body,damage):
	body.receive_damage(damage)

func lure_passerby(body):
	var newPath = body.localNav2D.get_simple_path(body.global_position, self.global_position)
	body.walkingPath = newPath

func grow():
	if growthLevel < 3:
		growthLevel += 1
	else:
		$GrowTimer.stop()
	match growthLevel:
		growthStages.SEEDLING:
			$Sprite.frame = 0
		growthStages.SAPLING:
			$Sprite.frame = 1
		growthStages.MATURE:
			$Sprite.frame = 3
		growthStages.ELDER:
			$Sprite.frame = 5
	print(growthLevel)

func tended_by_gardener():
	if canBeGardened == true:
		match growthLevel:
			growthStages.SEEDLING:
				$GrowTimer.wait_time -= - gardenerBenefit
			growthStages.SAPLING:
				$GrowTimer.wait_time -= - gardenerBenefit/2
				quality += 1
			growthStages.MATURE:
				$GrowTimer.wait_time -= - gardenerBenefit/4
				quality += 1
			growthStages.ELDER:
				quality += 1
		canBeGardened = false
		$GardenerTimer.start()

func kill_plant():
	$Sound/DeathSFX.play()
	var deathThroes = deathParticle.instance()
	add_child(deathThroes)
	deathThroes.emitting = true
	$AnimationPlayer.play("die")
	yield(get_node("AnimationPlayer"), "animation_finished")
	queue_free()

func _on_ClickableZone_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		get_tree().set_input_as_handled()
		if event.button_index == BUTTON_LEFT && event.pressed:
			return
		elif event.button_index == BUTTON_RIGHT && event.pressed:
			kill_plant()
			
func _on_GrowTimer_timeout():
	grow()

func _on_GardenerTimer_timeout():
	canBeGardened == true
