extends RichTextLabel

var item = ""
func _process(delta: float) -> void:
	if owner and "recipe_crafting" in owner:
		item = str(owner.recipe_crafting)
	#print(item)
	if item == "old_boots":
		text = "[color=#4a3b16][font_size=9]Old Boots ( $40 )[/font_size]\n[font_size=8]Provides Protection[/font_size][/color]"
	elif item == "new_boots":
		text = "[color=#4a3b16][font_size=9]New Boots ( $15 )[/font_size]\n[font_size=8]Provides Poor Protection[/font_size][/color]"
	elif item == "clover":
		text = "[color=#4a3b16][font_size=9]Clover ( $100 )[/font_size]\n[font_size=8] Luckier Shop Items[/font_size][/color]"
	elif item == "new_bundle":
		text = "[color=#4a3b16][font_size=9]New Bundle ( $20 )[/font_size]\n[font_size=7]Expands Storage[/font_size][/color]"
	elif item == "old_bundle":
		text = "[color=#4a3b16][font_size=9]Old Bundle ( $40 )[/font_size]\n[font_size=7]Expands Storage More[/font_size][/color]"
	elif item == "hammer":
		text = "[color=#4a3b16][font_size=9]Hammer ( $50 )[/font_size]\n[font_size=7]Handy Tool[/font_size][/color]"
	elif item == "new_pickaxe":
		text = "[color=#4a3b16][font_size=9]New Pickaxe ( $30 )[/font_size]\n[font_size=7]Faster Mining Speed[/font_size][/color]"
	elif item == "old_pickaxe":
		text = "[color=#4a3b16][font_size=9]Old Pickaxe ( $60 )[/font_size]\n[font_size=7]Even Faster Mining [/font_size][/color]"
	elif item == "mining_ring": 
		text = "[color=#4a3b16][font_size=9]Mining Ring ( $200 )[/font_size]\n[font_size=7]Faster Mining [/font_size][/color]"
	elif item == "gold_wings":
		text = "[color=#4a3b16][font_size=9]Gold Wings ( $30 )[/font_size]\n[font_size=7]Allows You to Dash[/font_size][/color]"
	elif item == "condensed_gold":
		text = "[color=#4a3b16][font_size=9]Condensed Gold[/font_size]\n[font_size=7]Used to Make Better Items[/font_size][/color]"
	elif item == "clock":
		text = "[color=#4a3b16][font_size=9]Gold Clock ( $40 )[/font_size]\n[font_size=7]Allows for More Time[/font_size][/color]"
	else:
		text = ""
