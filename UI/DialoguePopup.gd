extends Popup

func _ready():
	pass

func _on_DialoguePopup_popup_hide():
	get_tree().paused = false
