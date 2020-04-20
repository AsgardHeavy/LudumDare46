extends Popup

func _ready():
	pass

func _on_TryAgainButton_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Scenes/SorcerersGarden.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()
