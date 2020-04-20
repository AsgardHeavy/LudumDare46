extends Node

enum actionMode {GARDENING,OBSTACLES,SUMMONING}

onready var treeOfLife = $Garden/Landmarks/TreeOfLife
onready var nav2D : Navigation2D = $Garden/Navigation2D
onready var tileMap : TileMap = $Garden/Navigation2D/TileMap
onready var seedCounter : Label = $GardeningBag/BigContainer/NinePatchRect/SeedContainer/VBoxContainer/SeedCount
onready var manaCounter : Label = $GardeningBag/BigContainer/NinePatchRect2/SpellBook/VBoxContainer/ManaCount
onready var seedContainer = $GardeningBag/BigContainer/NinePatchRect/SeedContainer
onready var spellBook = $GardeningBag/BigContainer/NinePatchRect2/SpellBook
onready var summoningBook = $GardeningBag/BigContainer/NinePatchRect3/SummoningBook

export var minSpawnTime : int = 3
export var maxSpawnTime : int  = 8
export var maxBadGuys : int  = 1
export var seedStock : int  = 5
export var maxSeedStock : int = 20
export var mana : int = 10
export var maxMana : int = 20

var first_spawn : bool = true
var spawnPoints = []
var badGuys = {}
var gardenPlantTypes = {}
var obstacleTypes = {}
var creatureTypes = {}
var gameMode : int = actionMode.GARDENING
var actionReference : int = 0
var tutorialFinished : bool = false


func _ready():
	load_spawn_points()
	badGuys = load_options("res://Scenes/BadGuys/")
	gardenPlantTypes = load_options("res://Scenes/GardenPlants/")
	obstacleTypes = load_options("res://Scenes/Obstacles/")
	creatureTypes = load_options("res://Scenes/Creatures/")
	seedCounter.text = str(seedStock)
	manaCounter.text = str(mana)
	tutorial()

func change_game_mode(mode):
	#Input.set_custom_mouse_cursor(cursor_image, Input.CURSOR_ARROW, Vector2(64, 64))
	pass

func _unhandled_input(event):
	var mousePos = get_viewport().get_mouse_position()
	var tilePos = tileMap.map_to_world(tileMap.world_to_map(mousePos))
	#print(tilePos)
	if not event is InputEventMouseButton:
		return
	else:
		if event.button_index == BUTTON_LEFT && event.pressed && tutorialFinished == true:
			match gameMode:
				actionMode.GARDENING:
					plant_seed(gardenPlantTypes[actionReference],tilePos)
				actionMode.OBSTACLES:
					place_obstacle(obstacleTypes[actionReference],tilePos)
				actionMode.SUMMONING:
					summon_creature(creatureTypes[actionReference],tilePos)

func load_spawn_points():
	if spawnPoints.empty():
		for point in $BadGuys/BadGuySpawns.get_children():
			spawnPoints.append(point)

func _on_InitialTimer_timeout():
	randomize()
	$BadGuys/SpawnTimer.wait_time = randi() % maxSpawnTime + minSpawnTime
	$BadGuys/SpawnTimer.start()
	$BadGuys/InitialTimer.stop()

func _on_SpawnTimer_timeout():
	randomize()
	var numBadGuys
	numBadGuys = randi() % maxBadGuys + 1
	print("Spawning " + str(numBadGuys) + " Bad Guys!")
	for i in range(numBadGuys):
		spawn_unit()
	$BadGuys/SpawnTimer.wait_time = randi() % maxSpawnTime + 1
	$BadGuys/SpawnTimer.start()

func spawn_unit():
	print("Spawned a BadGuy!")
	randomize()
	var badGuy 
	var spawnPoint
	var newPath
	badGuy = load(badGuys[randi() % badGuys.size()]).instance()
	$BadGuys.add_child(badGuy)
	spawnPoint = spawnPoints[randi() % spawnPoints.size()]
	badGuy.start_at(spawnPoint.position)
	badGuy.localNav2D = nav2D
	newPath = nav2D.get_simple_path(badGuy.global_position, treeOfLife.global_position)
	badGuy.walkingPath = newPath
	badGuy.target = treeOfLife.global_position
	$Sound/ArrivingEnemySFX.play()
	
func plant_seed(plantType,pos):
	if seedStock > 0:
		var plant
		plant = load(plantType).instance()
		$Garden/Plants.add_child(plant)
		plant.start_at(pos)
		seedStock -= 1
		seedCounter.text = str(seedStock)
		$Sound/DiggingSFX.play()
		#print(seedStock)
		
func place_obstacle(obstacleType,pos):
	if mana > 0:
		var obstacle
		obstacle = load(obstacleType).instance()
		if mana >= obstacle.manaCost:
			$Garden/Obstacles.add_child(obstacle)
			obstacle.start_at(pos)
			mana -= obstacle.manaCost
			manaCounter.text = str(mana)
			$Sound/MagicSFX.play()
			#print(mana)
		else:
			obstacle.queue_free()
	
func summon_creature(creatureType,pos):
	if mana > 0:
		var creature
		creature = load(creatureType).instance()
		if mana >= creature.manaCost:
			$Garden/Obstacles.add_child(creature)
			creature.start_at(pos)
			creature.localNav2D = nav2D
			creature.pick_new_path()
			mana -= creature.manaCost
			manaCounter.text = str(mana)
			$Sound/MagicSFX.play()
			#print(mana)
		else:
			creature.queue_free()
	
func load_options(folder):
	var possibleOptions = {}
	var fileCount = 0
	var dir = Directory.new()
	dir.open(folder)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			possibleOptions[fileCount] = folder + file
			fileCount += 1
	return possibleOptions


func _on_ManaTimer_timeout():
	if mana < maxMana:
		mana += 1
		manaCounter.text = str(mana)
		#print("Mana: " + str(mana))

func _on_SeedStockTimer_timeout():
	if seedStock < maxSeedStock:
		seedStock += 1
		seedCounter.text = str(seedStock)
		#print("SeedStock: " + str(seedStock))

func tutorial():
	var dialogueLine1 : String = "Sorcerer:   Finally... After so many years, the TREE OF IMMORTALITY is finally ready to bear fruit..."
	var dialogueLine2 : String = "Now all I need to do is keep those pesky villagers from chopping it down."
	var dialogueLine3 : String = "I can plant a glorious, malevolent garden to protect my Tree by LEFT CLICKING."
	var dialogueLine4 : String = "Or maybe I should put some obstacles on the ground to slow down my enemies?"
	var dialogueLine5 : String = "If I need to weed or clear the paths I've blocked, I can always just RIGHT CLICK..."
	var dialogueLine6 : String = "Hm! Servants? Yes! I DO have an army of the undead I can summon to my aid..."
	var dialogueLine7 : String = "I'll just have to be judicious in my use of my ENORMOUS MAGICAL POWER."
	var dialogueLine8 : String = "... What's this!?"
	var dialogueLine9 : String = "Ranger:   !!!"
	var dialogueLine10 : String = "HARK! A MALEVOLENT TREE! I MUSTE WARNE THE GOODE TOWNSPEOPLE!"
	var dialogueLine11 : String = "Sorcerer:   ... So it begins..."
	var newPath
	if tutorialFinished == true:
		return
	$Garden/Landmarks/FirstAdventurer/GetBackToWorkTimer.stop()
	newPath = nav2D.get_simple_path($Garden/Landmarks/Sorcerer.global_position, $Garden/Landmarks/SorcererArrivalPoint.global_position)
	$Garden/Landmarks/Sorcerer.walkingPath = newPath
	yield(get_tree().create_timer(5.0), "timeout" )
	tutorial_dialogue(dialogueLine1)
	yield($DialoguePopup,"popup_hide")
	tutorial_dialogue(dialogueLine2)
	yield($DialoguePopup,"popup_hide")
	tutorial_dialogue(dialogueLine3)
	yield($DialoguePopup,"popup_hide")
	tutorial_dialogue(dialogueLine4)
	yield($DialoguePopup,"popup_hide")
	tutorial_dialogue(dialogueLine5)
	yield($DialoguePopup,"popup_hide")
	tutorial_dialogue(dialogueLine6)
	yield($DialoguePopup,"popup_hide")
	tutorial_dialogue(dialogueLine7)
	yield($DialoguePopup,"popup_hide")
	
	newPath = nav2D.get_simple_path($Garden/Landmarks/FirstAdventurer.global_position, $Garden/Landmarks/ScoutingPosition.global_position)
	$Garden/Landmarks/FirstAdventurer.walkingPath = newPath
	$Sound/ArrivingEnemySFX.play()
	yield(get_tree().create_timer(5.0), "timeout" )
	
	tutorial_dialogue(dialogueLine8) #What's this?! <-- The Ranger has just entered
	yield($DialoguePopup,"popup_hide")
	tutorial_dialogue(dialogueLine9)
	yield($DialoguePopup,"popup_hide")
	tutorial_dialogue(dialogueLine10)
	yield($DialoguePopup,"popup_hide")
	
	newPath = nav2D.get_simple_path($Garden/Landmarks/FirstAdventurer.global_position, $BadGuys/RetreatPoint.global_position)
	$Garden/Landmarks/FirstAdventurer.walkingPath = newPath
	yield(get_tree().create_timer(3.5), "timeout" )
	
	tutorial_dialogue(dialogueLine11)
	yield($DialoguePopup,"popup_hide")
	get_tree().paused = false
	finish_tutorial()

func finish_tutorial():
	$Garden/Landmarks/TreeOfLife/SeasonTimer.start()
	$Garden/Landmarks/TreeOfLife/VictoryTimer.start()
	$BadGuys/InitialTimer.start()
	$ManaTimer.start()
	$SeedStockTimer.start()
	$Garden/Landmarks/Sorcerer.localNav2D = nav2D
	$Garden/Landmarks/Sorcerer/MoveTimer.start()
	tutorialFinished = true
	$Garden/Landmarks/FirstAdventurer.queue_free()

func tutorial_dialogue(dialogueText):
	$DialoguePopup/Label.text = dialogueText
	$DialoguePopup.popup_centered()
	get_tree().paused = true
	
func _on_PlantButton_pressed(ref):
	gameMode = actionMode.GARDENING
	actionReference = ref
	
func _on_ObstacleButton_pressed(ref):
	gameMode = actionMode.OBSTACLES
	actionReference = ref

func _on_SummonButton_pressed(ref):
	gameMode = actionMode.SUMMONING
	actionReference = ref
