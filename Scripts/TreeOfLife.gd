extends StaticBody2D

enum seasons {WINTER, SPRING, SUMMER, FALL}

var currentSeason : int = seasons.WINTER


func _ready():
	pass

func grow_up():
	match currentSeason:
		seasons.WINTER:
			$Sprite.frame = 0
		seasons.SPRING:
			$Sprite.frame = 1
		seasons.SUMMER:
			$Sprite.frame = 2
		seasons.FALL:
			$Sprite.frame = 3

func _on_SeasonTimer_timeout():
	currentSeason += 1
	grow_up()

func _on_VictoryTimer_timeout():
	get_tree().paused = true
	$VictoryScreen.popup()

func _on_InteractionRadius_body_shape_entered(body_id, body, body_shape, area_shape):
	if body.is_in_group("BadGuys"):
		$Sound/DefeatSFX.play()
		#get_tree().paused = true
		#$DefeatScreen.popup()
