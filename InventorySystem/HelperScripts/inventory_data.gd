extends RefCounted

const SLOT_SIZE = 9
const GAP = 1
const STEP = SLOT_SIZE + GAP

const MAIN_COLS = 10
const MAIN_ROWS = 10

const HAVE_COLS = 5
const HAVE_ROWS = 5

const slot_texture = preload("res://Assets/Images/Slots2.png")
const select_font = preload("res://InventorySystem/Assets/Fonts/ItemName.otf")
const place_particle = preload("res://InventorySystem/Assets/Scenes/place_particle.tscn")

const ITEM_FILL_COLORS = [
	#Color(0.651, 0.373, 0.145, 1.0),
	Color(1.0, 0.933, 0.761, 0)
]

const IMAGES = {
	"new_pickaxe": preload("res://InventorySystem/Assets/Tres/new_pick.tres"),
	"old_pickaxe": preload("res://InventorySystem/Assets/Tres/old_pick.tres"),
	"new_bundle": preload("res://InventorySystem/Assets/Tres/new_bundle.tres"),
	"old_bundle": preload("res://InventorySystem/Assets/Tres/old_bundle.tres"),
	"hammer": preload("res://InventorySystem/Assets/Tres/hammer.tres"),
	"wings": preload("res://InventorySystem/Assets/Tres/wings.tres"),
	"clover": preload("res://InventorySystem/Assets/Tres/clover.tres"),
	"clock": preload("res://InventorySystem/Assets/Tres/clock.tres"),
	"ring": preload("res://InventorySystem/Assets/Tres/ring.tres"),
	"new_boots": preload("res://InventorySystem/Assets/Tres/new_boots.tres"),
	"old_boots": preload("res://InventorySystem/Assets/Tres/old_boots.tres")
}

const ITEMS = {
	"new_pickaxe": {
		"name": "New Pickaxe",
		"color": IMAGES["new_pickaxe"],
		"scale": 1.0,
		"shape": [
			[0, 1, 1],
			[0, 1, 1],
			[1, 0, 0]
		]
	},
	"old_pickaxe": {
		"name": "Old Pickaxe",
		"color": IMAGES["old_pickaxe"],
		"scale": 1.0,
		"shape": [
			[0, 1, 1, 1],
			[0, 0, 1, 1],
			[1, 1, 0, 1],
			[1, 1, 0, 0]
		]
	},
	"new_bundle": {
		"name": "New Bundle",
		"color": IMAGES["new_bundle"],
		"scale": 0.8,
		"shape": [
			[0, 1, 0],
			[1, 1, 1],
			[0, 1, 0]
		]
	},
	"old_bundle": {
		"name": "Old Bundle",
		"color": IMAGES["old_bundle"],
		"scale": 0.8,
		"shape": [
			[0, 1, 0],
			[1, 1, 1],
			[0, 1, 0]
		]
	},
	"hammer": {
		"name": "Hammer",
		"color": IMAGES["hammer"],
		"scale": 0.9,
		"shape": [
			[0, 1, 1],
			[0, 1, 1],
			[1, 0, 0]
		]
	},
	"wings": {
		"name": "Wings",
		"color": IMAGES["wings"],
		"scale": 0.9,
		"shape": [
			[1, 0, 0, 1],
			[1, 1, 1, 1]
		]
	},
	"clover": {
		"name": "Clover",
		"color": IMAGES["clover"],
		"scale": 0.8,
		"shape": [
			[1, 1],
			[1, 1]
		]
	},
	"clock": {
		"name": "Clock",
		"color": IMAGES["clock"],
		"scale": 0.8,
		"shape": [
			[1, 1, 1],
			[1, 1, 1],
			[1, 1, 1]
		]
	},
	"ring": {
		"name": "Ring",
		"color": IMAGES["ring"],
		"scale": 1.5,
		"shape": [
			[1]
		]
	},
	"new_boots": {
		"name": "New Boots",
		"color": IMAGES["new_boots"],
		"scale": 1,
		"shape": [
			[1, 1],
			[1, 1]
		]
	},
	"old_boots": {
		"name": "old_boots",
		"color": IMAGES["old_boots"],
		"scale": 1,
		"shape": [
			[1, 1],
			[1, 1]
		]
	}
}
