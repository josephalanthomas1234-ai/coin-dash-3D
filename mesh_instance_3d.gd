extends MeshInstance3D

var speed = 5.0
var score = 0
var high_score = 0
var label
var coin
var enemy
var enemy_velocity = Vector3(3, 0, 2)
var time_left = 30.0
var game_over = false

func _ready():
	var orange = StandardMaterial3D.new()
	orange.albedo_color = Color.ORANGE
	material_override = orange

	label = Label.new()
	label.text = "Score: 0   Time: 30"
	label.position = Vector2(20, 20)
	label.add_theme_font_size_override("font_size", 32)
	get_parent().add_child.call_deferred(label)

	var gold = StandardMaterial3D.new()
	gold.albedo_color = Color.GOLD
	coin = MeshInstance3D.new()
	coin.mesh = SphereMesh.new()
	coin.material_override = gold
	coin.position = Vector3(3, 0.5, 0)
	get_parent().add_child.call_deferred(coin)

	var red = StandardMaterial3D.new()
	red.albedo_color = Color.RED
	enemy = MeshInstance3D.new()
	enemy.mesh = BoxMesh.new()
	enemy.material_override = red
	enemy.position = Vector3(-5, 0.5, -5)
	get_parent().add_child.call_deferred(enemy)

	RenderingServer.set_default_clear_color(Color(0.1, 0.12, 0.2))

func _process(delta):
	if game_over:
		if Input.is_key_pressed(KEY_SPACE):
			restart()
		return

	time_left -= delta
	if time_left <= 0:
		end_game("Time's up!")
		return

	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	position.x += direction.x * speed * delta
	position.z += direction.y * speed * delta
	position.x = clamp(position.x, -9.5, 9.5)
	position.z = clamp(position.z, -9.5, 9.5)

	label.text = "Score: " + str(score) + "   Time: " + str(int(time_left))
	coin.rotate_y(3.0 * delta)

	enemy.position += enemy_velocity * delta
	if enemy.position.x < -9.5 or enemy.position.x > 9.5:
		enemy_velocity.x = -enemy_velocity.x
	if enemy.position.z < -9.5 or enemy.position.z > 9.5:
		enemy_velocity.z = -enemy_velocity.z

	if position.distance_to(enemy.position) < 1.2:
		end_game("Hit!")
		return

	if position.distance_to(coin.position) < 1.5:
		score += 1
		coin.position = Vector3(randf_range(-8, 8), 0.5, randf_range(-8, 8))

func end_game(message):
	game_over = true
	if score > high_score:
		high_score = score
	label.text = message + " Final score: " + str(score) + "\nHigh score: " + str(high_score) + "\nPress Space to restart"

func restart():
	score = 0
	time_left = 30.0
	game_over = false
	position = Vector3(0, position.y, 0)
	coin.position = Vector3(3, 0.5, 0)
	enemy.position = Vector3(-5, 0.5, -5)
