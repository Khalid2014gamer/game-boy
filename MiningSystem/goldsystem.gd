extends Button
signal gold(value)
const NEW_GOLD = preload("res://new_gold.tscn")
const OLD_GOLD = preload("res://anc_gold.tscn")
func _ready() -> void:
	#self.disabled = true
	pass

func _process(delta: float) -> void:
	pass
	
func _pressed() -> void:
	
	print("gold was clicked!")
	get_tree().get_first_node_in_group("Player").Mine()
	#get_tree().get_nodes_in_group("GameStorage")[0]._on_gold_mined(1)
	self.disabled = true
	$GoldIMG.play("default")
	$GPUParticles2D.emitting=true
	await get_tree().create_timer(3.0).timeout
	$GPUParticles2D.emitting = false
	var new_gold = NEW_GOLD.instantiate()
	new_gold.global_position = $GoldIMG.global_position
	get_parent().add_child(new_gold)
	print("finished mining!")
	get_tree().get_first_node_in_group("Player").StopMine()
	#emit_signal("gold", 1)
	
	$GoldIMG.visible = false
	$Rock.visible = true
	#$HBoxContainer.visible = true
	#$HBoxContainer/GoldValueLabel.start_popup(str(get_tree().get_nodes_in_group("GameStorage")[0].get_player_data()["gold"]) + " Gold")
	await get_tree().create_timer(3.0).timeout
	$HBoxContainer.visible = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if $GoldIMG.visible and body.name == "Player": 
		self.disabled = false

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		self.disabled = true
