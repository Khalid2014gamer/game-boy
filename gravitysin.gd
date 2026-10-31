extends StaticBody2D

@export var explosion_force: float = 80.0
@export var gravity: float = 400.0

# Ground collision behavior
@export var bounce_strength: float = 0.45
@export var ground_friction: float = 0.85

# Rotation behavior
@export var rotation_force: float = 8.0
@export var rotation_friction: float = 0.92

# When the gold is moving slower than this, it settles
@export var stop_threshold: float = 8.0

var velocity: Vector2
var angular_velocity: float
var ground_y: float
var resting := false


func _ready() -> void:
	ground_y = global_position.y

	# Launch the gold in a random direction
	velocity = Vector2(
		randf_range(-explosion_force, explosion_force),
		randf_range(-explosion_force * 2.0, -explosion_force)
	)

	# Give the gold some random spin
	angular_velocity = randf_range(
		-rotation_force,
		rotation_force
	)


func _physics_process(delta: float) -> void:
	if resting:
		return

	# Gravity pulls the gold down
	velocity.y += gravity * delta

	# Move the gold
	global_position += velocity * delta

	# Rotate the gold
	rotation += angular_velocity * delta

	# Detect the imaginary ground
	if global_position.y >= ground_y and velocity.y > 0.0:
		global_position.y = ground_y

		# Bounce vertically
		velocity.y = -velocity.y * bounce_strength

		# Lose some horizontal speed due to friction
		velocity.x *= ground_friction

		# Ground impact adds a little spin
		angular_velocity += velocity.x * 0.04

		# Reduce spin after each impact
		angular_velocity *= rotation_friction

		# Stop tiny bounces
		if abs(velocity.y) < stop_threshold:
			velocity.y = 0.0

		# Settle when almost all movement is gone
		if (
			abs(velocity.x) < stop_threshold
			and abs(velocity.y) < stop_threshold
		):
			velocity = Vector2.ZERO
			angular_velocity = 0.0
			resting = true
			set_physics_process(false)
