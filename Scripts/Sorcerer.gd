extends "res://Scripts/Creature.gd"

func pick_new_path():
	randomize()
	var newDir = randi() % 4 + 1
	var newDestination : Vector2
	match newDir:
		directions.LEFT:
			newDestination = Vector2(clamp(self.position.x - (tileSize * 2),0,screensize.x),self.position.y)
			set_path(self.localNav2D.get_simple_path(self.global_position, newDestination))
		directions.RIGHT:
			newDestination = Vector2(clamp(self.position.x + (tileSize * 2),0,screensize.x),self.position.y)
			set_path(self.localNav2D.get_simple_path(self.global_position, newDestination))
