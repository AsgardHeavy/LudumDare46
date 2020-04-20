extends Control

func _ready():
	self.visible = false
	$CreditsPanel.visible = false

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		if self.visible == false:
			self.visible = true
			get_tree().paused = true
		else:
			self.visible = false
			get_tree().paused = false

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_StartOverButton_pressed():
	get_tree().change_scene("res://Scenes/SorcerersGarden.tscn")

func _on_CreditsButton_pressed():
	$CreditsPanel.visible = true

func _on_CloseCreditsButton_pressed():
	$CreditsPanel.visible = false
