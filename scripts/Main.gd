extends Node3D

# Последнее письмо 3D — desktop Godot prototype.
# Управление: WASD — ходьба, мышь — обзор, E — взаимодействие, Esc — отпустить/захватить мышь.

var player: CharacterBody3D
var camera: Camera3D
var ray: RayCast3D
var ui_layer: CanvasLayer
var hint_label: Label
var stats_label: Label
var focus_label: Label
var letter_panel: PanelContainer
var letter_title: Label
var letter_body: RichTextLabel
var choice_box: VBoxContainer
var close_button: Button
var ending_panel: PanelContainer
var ending_title: Label
var ending_body: RichTextLabel
var ending_choices: VBoxContainer

var yaw := 0.0
var pitch := 0.0
var mouse_sensitivity := 0.003
var speed := 4.0
var gravity := 9.8

var love := 0
var guilt := 0
var madness := 0
var current_letter := 0
var can_move := true
var mouse_captured := true

var interactables := {}
var decay_objects: Array[Node3D] = []
var warm_objects: Array[Node3D] = []
var madness_objects: Array[Node3D] = []
var important_nodes := {}

var letters := [
	{
		"title": "Письмо 1 — Я вернулась",
		"body": "Мой любимый, я вернулась. Помнишь дождь в тот день? Ты смеялся, а я пряталась под твоим пальто. Напиши мне... я так одинока здесь.",
		"choices": [
			{"text": "Я тоже скучаю. Прости, что молчал.", "love": 2, "guilt": 0, "madness": 0, "after": "В комнате стало теплее. На стуле будто появился знакомый шарф."},
			{"text": "Анна? Это невозможно. Ты умерла.", "love": 0, "guilt": 1, "madness": 1, "after": "В коридоре раздался одинокий стук. Почтовый ящик замолчал."},
			{"text": "Оставь меня в покое.", "love": -1, "guilt": 2, "madness": 1, "after": "Фотография на стене перекосилась, хотя ты её не трогал."}
		]
	},
	{
		"title": "Письмо 2 — Наша ночь",
		"body": "Ты обещал, что мы всегда будем вместе. Почему в тот вечер ты не ответил на мои звонки? Я ждала. Я всё ещё жду.",
		"choices": [
			{"text": "Я боялся. Но я любил тебя.", "love": 1, "guilt": 1, "madness": 0, "after": "На кухне пахнуло мокрыми цветами и старым кофе."},
			{"text": "Расскажи, что случилось в тот вечер.", "love": 0, "guilt": 2, "madness": 1, "after": "В ванной мелькнуло красное пятно. Через секунду оно исчезло."},
			{"text": "Я не виноват. Ты всё преувеличиваешь.", "love": -1, "guilt": 1, "madness": 2, "after": "За спиной прошли шаги, но коридор был пуст."}
		]
	},
	{
		"title": "Письмо 3 — Правда",
		"body": "Я звала тебя. Боль была невыносимой. А ты сказал, что я опять всё придумываю. Напиши мне правду. Или я сама приду напомнить.",
		"choices": [
			{"text": "Я должен был помочь. Прости меня.", "love": 1, "guilt": 3, "madness": 0, "after": "Зеркало потемнело. В нём появилось второе дыхание."},
			{"text": "Я не помню. Я хочу вспомнить.", "love": 0, "guilt": 2, "madness": 2, "after": "Дом начал дышать в такт твоим шагам."},
			{"text": "Ты не имеешь права обвинять меня.", "love": -2, "guilt": 1, "madness": 3, "after": "На стене проступило слово: 'ПОЗДНО'."}
		]
	},
	{
		"title": "Письмо 4 — Дом помнит",
		"body": "Стены слышали всё. Бутылка на полу, твой голос, мой стук по двери. Ты мог открыть. Ты мог услышать.",
		"choices": [
			{"text": "Я открою дверь, если ты всё ещё там.", "love": 2, "guilt": 1, "madness": 1, "after": "В спальне зашевелилось платье. Оно ждёт."},
			{"text": "Я признаю: я оставил тебя одну.", "love": 0, "guilt": 3, "madness": 0, "after": "Сквозь шум дождя ты впервые услышал своё имя."},
			{"text": "Это письмо — болезнь. Я сожгу ящик.", "love": -1, "guilt": 0, "madness": 3, "after": "Почтовый ящик стал горячим, будто внутри тлели угли."}
		]
	},
	{
		"title": "Письмо 5 — Выбирай",
		"body": "Это никогда не закончится само. Любовь или наказание — выбирай. Сожги письма, продолжай писать или иди за мной.",
		"choices": [
			{"text": "Я дочитаю всё до конца.", "love": 1, "guilt": 1, "madness": 1, "after": "Теперь можно решить судьбу у старого стола в гостиной."},
			{"text": "Я больше не буду прятаться.", "love": 0, "guilt": 2, "madness": 0, "after": "Пламя свечи стало белым. Дом ждёт признания."},
			{"text": "Анна, забери меня.", "love": 2, "guilt": 0, "madness": 3, "after": "Дверь в коридоре открылась сама. За ней не было комнаты."}
		]
	}
]

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_build_world()
	_build_player()
	_build_ui()
	_apply_atmosphere()
	_update_hud()

func _build_world() -> void:
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.02, 0.018, 0.02)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.18, 0.15, 0.13)
	env.ambient_light_energy = 0.7
	world.environment = env
	add_child(world)

	var main_light := DirectionalLight3D.new()
	main_light.name = "ColdMoonLight"
	main_light.light_energy = 0.5
	main_light.rotation_degrees = Vector3(-55, -25, 0)
	add_child(main_light)
	important_nodes["main_light"] = main_light

	var lamp := OmniLight3D.new()
	lamp.name = "OldLamp"
	lamp.position = Vector3(0.5, 2.5, -1.5)
	lamp.light_color = Color(1.0, 0.72, 0.45)
	lamp.light_energy = 1.5
	lamp.omni_range = 7.0
	add_child(lamp)
	important_nodes["lamp"] = lamp

	# Квартира: гостиная, коридор, спальня, кухня, ванная — простая 3D-заглушка под замену ассетами.
	_create_box("Floor_OldWood", Vector3(0, -0.05, 0), Vector3(13, 0.1, 10), Color(0.23, 0.16, 0.10))
	_create_box("Ceiling_Dark", Vector3(0, 3.05, 0), Vector3(13, 0.1, 10), Color(0.08, 0.075, 0.07))
	_create_box("Wall_Back", Vector3(0, 1.5, -5), Vector3(13, 3, 0.12), Color(0.33, 0.30, 0.25))
	_create_box("Wall_Front", Vector3(0, 1.5, 5), Vector3(13, 3, 0.12), Color(0.27, 0.25, 0.23))
	_create_box("Wall_Left", Vector3(-6.5, 1.5, 0), Vector3(0.12, 3, 10), Color(0.30, 0.27, 0.22))
	_create_box("Wall_Right", Vector3(6.5, 1.5, 0), Vector3(0.12, 3, 10), Color(0.30, 0.27, 0.22))
	_create_box("RoomDivider_1", Vector3(-2.4, 1.5, 0), Vector3(0.12, 3, 5.5), Color(0.26, 0.24, 0.21))
	_create_box("RoomDivider_2", Vector3(2.3, 1.5, 1.3), Vector3(0.12, 3, 7.2), Color(0.26, 0.24, 0.21))

	# Гостиная.
	_create_box("Sofa_Worn", Vector3(-4.6, 0.45, -2.8), Vector3(2.4, 0.8, 0.8), Color(0.20, 0.16, 0.15))
	_create_box("Sofa_Back", Vector3(-4.6, 1.0, -3.15), Vector3(2.4, 1.0, 0.25), Color(0.16, 0.12, 0.12))
	_create_box("CoffeeTable", Vector3(-2.9, 0.28, -1.7), Vector3(1.5, 0.22, 0.9), Color(0.18, 0.11, 0.07), "final_table")
	_add_label(Vector3(-2.9, 0.75, -1.7), "Старый стол\n[E] финальный выбор", 0.28)
	_create_box("OldMailbox", Vector3(-5.8, 1.1, 1.8), Vector3(0.45, 0.7, 0.35), Color(0.28, 0.05, 0.04), "mailbox")
	_add_label(Vector3(-5.8, 1.7, 1.8), "Почтовый ящик\n[E] письмо", 0.28)
	_create_box("PhotoFrame", Vector3(-6.42, 1.85, -0.8), Vector3(0.08, 0.85, 1.1), Color(0.38, 0.28, 0.16), "photo")
	_add_label(Vector3(-5.95, 2.25, -0.8), "Фото Анны\n[E]", 0.22)

	# Спальня.
	_create_box("Bed_Old", Vector3(4.4, 0.35, -2.8), Vector3(2.6, 0.55, 1.7), Color(0.20, 0.18, 0.16))
	_create_box("Pillow", Vector3(3.55, 0.75, -3.15), Vector3(0.7, 0.22, 0.5), Color(0.55, 0.52, 0.47))
	_create_box("AnnaDress", Vector3(5.8, 1.3, -1.0), Vector3(0.35, 1.6, 0.12), Color(0.48, 0.42, 0.38), "dress")
	_add_label(Vector3(5.8, 2.25, -1.0), "Платье\n[E]", 0.22)
	_create_box("Mirror", Vector3(6.42, 1.65, -3.2), Vector3(0.08, 1.7, 0.85), Color(0.22, 0.26, 0.28), "mirror")
	_add_label(Vector3(5.95, 2.55, -3.2), "Зеркало\n[E]", 0.22)

	# Кухня / ванная.
	_create_box("KitchenCounter", Vector3(3.9, 0.55, 3.7), Vector3(2.8, 0.9, 0.7), Color(0.17, 0.16, 0.14))
	_create_box("Bottle", Vector3(3.1, 1.25, 3.65), Vector3(0.18, 0.55, 0.18), Color(0.12, 0.20, 0.22), "bottle")
	_add_label(Vector3(3.1, 1.85, 3.65), "Бутылка\n[E]", 0.22)
	_create_box("OldPhone", Vector3(4.1, 1.1, 3.6), Vector3(0.6, 0.25, 0.35), Color(0.05, 0.05, 0.045), "phone")
	_add_label(Vector3(4.1, 1.55, 3.6), "Телефон\n[E]", 0.22)
	_create_box("BathroomDoor", Vector3(-0.4, 1.3, 4.92), Vector3(1.4, 2.4, 0.12), Color(0.12, 0.10, 0.09), "bathroom")
	_add_label(Vector3(-0.4, 2.6, 4.72), "Ванная\n[E]", 0.22)

	# Окно и дождь.
	_create_box("RainWindow", Vector3(-1.2, 1.8, -4.93), Vector3(2.4, 1.3, 0.08), Color(0.08, 0.12, 0.16), "window")
	_add_label(Vector3(-1.2, 2.55, -4.65), "Окно\n[E]", 0.2)
	for i in range(7):
		_create_box("RainLine_%s" % i, Vector3(-2.2 + i * 0.35, 1.8, -4.86), Vector3(0.025, 1.0, 0.02), Color(0.5, 0.58, 0.62, 0.55))

	# Скрытые horror/romance объекты, которые включаются после выборов.
	decay_objects.append(_create_box("BloodStain_1", Vector3(-0.6, 0.01, 2.8), Vector3(1.1, 0.03, 0.55), Color(0.35, 0.0, 0.0)))
	decay_objects.append(_create_box("WallCrack_1", Vector3(-6.43, 1.7, 0.8), Vector3(0.03, 1.4, 0.1), Color(0.03, 0.025, 0.025)))
	decay_objects.append(_create_box("WallCrack_2", Vector3(2.24, 1.5, -2.2), Vector3(0.03, 1.1, 0.1), Color(0.03, 0.025, 0.025)))
	warm_objects.append(_create_box("FlowerVase", Vector3(-2.9, 0.58, -1.7), Vector3(0.22, 0.45, 0.22), Color(0.2, 0.35, 0.16)))
	warm_objects.append(_create_box("WarmScarf", Vector3(-4.3, 1.0, -2.45), Vector3(0.85, 0.08, 0.28), Color(0.55, 0.15, 0.12)))
	madness_objects.append(_create_box("WallWriting_1", Vector3(-6.43, 2.0, 2.6), Vector3(0.03, 0.55, 1.4), Color(0.75, 0.7, 0.65)))
	madness_objects.append(_create_box("GhostShape", Vector3(5.1, 1.5, -3.3), Vector3(0.45, 1.9, 0.08), Color(0.8, 0.82, 0.88, 0.35)))
	for n in decay_objects + warm_objects + madness_objects:
		n.visible = false

func _build_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Player"
	player.position = Vector3(-4.2, 1.0, 2.8)
	add_child(player)

	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.7
	collision.shape = capsule
	player.add_child(collision)

	camera = Camera3D.new()
	camera.name = "PlayerCamera"
	camera.position = Vector3(0, 0.75, 0)
	camera.current = true
	player.add_child(camera)

	ray = RayCast3D.new()
	ray.name = "InteractRay"
	ray.target_position = Vector3(0, 0, -3.2)
	ray.enabled = true
	camera.add_child(ray)

func _build_ui() -> void:
	ui_layer = CanvasLayer.new()
	add_child(ui_layer)

	hint_label = Label.new()
	hint_label.position = Vector2(18, 14)
	hint_label.text = "WASD — ходьба | мышь — обзор | E — взаимодействие | Esc — курсор"
	hint_label.add_theme_font_size_override("font_size", 18)
	ui_layer.add_child(hint_label)

	stats_label = Label.new()
	stats_label.position = Vector2(18, 42)
	stats_label.add_theme_font_size_override("font_size", 16)
	ui_layer.add_child(stats_label)

	focus_label = Label.new()
	focus_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	focus_label.position = Vector2(440, 635)
	focus_label.size = Vector2(400, 40)
	focus_label.add_theme_font_size_override("font_size", 18)
	ui_layer.add_child(focus_label)

	letter_panel = PanelContainer.new()
	letter_panel.visible = false
	letter_panel.position = Vector2(250, 105)
	letter_panel.size = Vector2(780, 500)
	ui_layer.add_child(letter_panel)

	var letter_margin := MarginContainer.new()
	letter_margin.add_theme_constant_override("margin_left", 24)
	letter_margin.add_theme_constant_override("margin_right", 24)
	letter_margin.add_theme_constant_override("margin_top", 20)
	letter_margin.add_theme_constant_override("margin_bottom", 20)
	letter_panel.add_child(letter_margin)

	var letter_vbox := VBoxContainer.new()
	letter_margin.add_child(letter_vbox)

	letter_title = Label.new()
	letter_title.add_theme_font_size_override("font_size", 26)
	letter_vbox.add_child(letter_title)

	letter_body = RichTextLabel.new()
	letter_body.fit_content = false
	letter_body.custom_minimum_size = Vector2(720, 210)
	letter_body.bbcode_enabled = true
	letter_body.add_theme_font_size_override("normal_font_size", 20)
	letter_vbox.add_child(letter_body)

	choice_box = VBoxContainer.new()
	letter_vbox.add_child(choice_box)

	close_button = Button.new()
	close_button.text = "Закрыть"
	close_button.visible = false
	close_button.pressed.connect(_close_letter_panel)
	letter_vbox.add_child(close_button)

	ending_panel = PanelContainer.new()
	ending_panel.visible = false
	ending_panel.position = Vector2(250, 100)
	ending_panel.size = Vector2(780, 520)
	ui_layer.add_child(ending_panel)

	var ending_margin := MarginContainer.new()
	ending_margin.add_theme_constant_override("margin_left", 24)
	ending_margin.add_theme_constant_override("margin_right", 24)
	ending_margin.add_theme_constant_override("margin_top", 20)
	ending_margin.add_theme_constant_override("margin_bottom", 20)
	ending_panel.add_child(ending_margin)

	var ending_vbox := VBoxContainer.new()
	ending_margin.add_child(ending_vbox)

	ending_title = Label.new()
	ending_title.add_theme_font_size_override("font_size", 28)
	ending_vbox.add_child(ending_title)

	ending_body = RichTextLabel.new()
	ending_body.custom_minimum_size = Vector2(720, 260)
	ending_body.bbcode_enabled = true
	ending_body.add_theme_font_size_override("normal_font_size", 20)
	ending_vbox.add_child(ending_body)

	ending_choices = VBoxContainer.new()
	ending_vbox.add_child(ending_choices)

func _physics_process(delta: float) -> void:
	if not can_move:
		return

	var input_vec := Vector2.ZERO
	if Input.is_key_pressed(KEY_W): input_vec.y -= 1.0
	if Input.is_key_pressed(KEY_S): input_vec.y += 1.0
	if Input.is_key_pressed(KEY_A): input_vec.x -= 1.0
	if Input.is_key_pressed(KEY_D): input_vec.x += 1.0
	input_vec = input_vec.normalized()

	var forward := -player.global_transform.basis.z
	var right := player.global_transform.basis.x
	var direction := (right * input_vec.x + forward * -input_vec.y).normalized()

	player.velocity.x = direction.x * speed
	player.velocity.z = direction.z * speed
	if player.is_on_floor():
		player.velocity.y = 0.0
	else:
		player.velocity.y -= gravity * delta
	player.move_and_slide()

	_update_focus_hint()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and mouse_captured and can_move:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, -1.25, 1.25)
		player.rotation.y = yaw
		camera.rotation.x = pitch

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			mouse_captured = not mouse_captured
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if mouse_captured else Input.MOUSE_MODE_VISIBLE)
		elif event.keycode == KEY_E and can_move:
			_try_interact()

func _try_interact() -> void:
	ray.force_raycast_update()
	if not ray.is_colliding():
		_show_small_message("Здесь ничего нет. Только шум дождя.")
		return
	var collider := ray.get_collider()
	if collider and collider.has_meta("interaction_id"):
		_interact(str(collider.get_meta("interaction_id")))
	else:
		_show_small_message("Предмет молчит.")

func _interact(id: String) -> void:
	match id:
		"mailbox":
			if current_letter < letters.size():
				_show_letter(current_letter)
			else:
				_show_small_message("Писем больше нет. Остался только выбор у старого стола.")
		"final_table":
			if current_letter >= letters.size():
				_show_final_choices()
			else:
				_show_small_message("Стол покрыт пылью. Сначала прочитай письма из ящика.")
		"photo":
			love += 1
			guilt += 1
			_show_small_message("На фото Анна улыбается. Чем дольше смотришь, тем сильнее кажется, что улыбка становится печальной.")
		"mirror":
			madness += 1
			if guilt >= 4:
				_show_small_message("В зеркале ты видишь Анну за своим плечом. Когда оборачиваешься — пусто.")
			else:
				_show_small_message("Зеркало мутное. В нём трудно узнать себя.")
		"dress":
			love += 1
			madness += 1
			_show_small_message("Платье пахнет дождём, хотя окно закрыто.")
		"bottle":
			guilt += 2
			_show_small_message("Бутылка пустая. Но почему горлышко ещё влажное?")
		"phone":
			guilt += 1
			madness += 1
			_show_small_message("На экране нет звонков. В памяти — двадцать семь пропущенных.")
		"bathroom":
			guilt += 1
			_show_small_message("Из-за двери пахнет холодной водой и железом.")
		"window":
			love += 1
			_show_small_message("Дождь напоминает первое свидание. И последнюю ночь.")
		_:
			_show_small_message("Ничего не происходит.")
	_apply_atmosphere()
	_update_hud()

func _show_letter(index: int) -> void:
	can_move = false
	mouse_captured = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var letter: Dictionary = letters[index]
	letter_panel.visible = true
	close_button.visible = false
	letter_title.text = str(letter["title"])
	letter_body.text = "[i]" + str(letter["body"]) + "[/i]"
	_clear_children(choice_box)
	for choice in letter["choices"]:
		var btn := Button.new()
		btn.text = str(choice["text"])
		btn.custom_minimum_size = Vector2(700, 46)
		btn.pressed.connect(_select_letter_choice.bind(choice))
		choice_box.add_child(btn)

func _select_letter_choice(choice: Dictionary) -> void:
	love += int(choice.get("love", 0))
	guilt += int(choice.get("guilt", 0))
	madness += int(choice.get("madness", 0))
	current_letter += 1
	_apply_atmosphere()
	_update_hud()
	_clear_children(choice_box)
	letter_body.text = "[b]Ответ отправлен.[/b]\n\n" + str(choice.get("after", "Дом изменился."))
	close_button.visible = true

func _close_letter_panel() -> void:
	letter_panel.visible = false
	can_move = true
	mouse_captured = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _show_final_choices() -> void:
	can_move = false
	mouse_captured = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	ending_panel.visible = true
	ending_title.text = "Финальный выбор"
	ending_body.text = "Все письма прочитаны. Дом больше не притворяется квартирой. Выбери, что сделать с последним письмом."
	_clear_children(ending_choices)
	_add_ending_button("Сжечь письма", "release")
	_add_ending_button("Продолжить писать", "loop")
	_add_ending_button("Пойти за Анной", "follow")
	_add_ending_button("Закрыть и осмотреть дом", "close")

func _add_ending_button(text: String, action: String) -> void:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(700, 46)
	btn.pressed.connect(_resolve_ending.bind(action))
	ending_choices.add_child(btn)

func _resolve_ending(action: String) -> void:
	if action == "close":
		ending_panel.visible = false
		can_move = true
		mouse_captured = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		return
	_clear_children(ending_choices)
	var restart := Button.new()
	restart.text = "Начать заново"
	restart.custom_minimum_size = Vector2(700, 46)
	restart.pressed.connect(func(): get_tree().reload_current_scene())
	ending_choices.add_child(restart)

	if action == "release":
		ending_title.text = "Концовка: Отпускание"
		ending_body.text = "Ты сжигаешь письма. Пламя не греет — оно стирает. Имя Анны исчезает первым, потом твоя вина, потом любовь. Дом становится белым и пустым. Ты свободен, но не уверен, кого именно потерял."
	elif action == "loop":
		ending_title.text = "Концовка: Вечная переписка"
		ending_body.text = "Ты берёшь чистый лист. Почерк оказывается знакомым. Письмо начинается словами: 'Мой любимый, я вернулась'. Дом закрывает двери. Утро больше не наступит."
	elif action == "follow":
		if madness >= guilt and love >= 4:
			ending_title.text = "Концовка: Мы вместе"
			ending_body.text = "Ты открываешь дверь, которой раньше не было. Анна стоит в темноте, но её лицо спокойно. За шаг до неё ты понимаешь: возможно, она не звала тебя. Возможно, это ты всё это время не хотел уходить."
		elif guilt >= 7:
			ending_title.text = "Концовка: Саморазрушение"
			ending_body.text = "Ты идёшь за голосом и проваливаешься в собственную память. Последнее письмо приходит уже без адресата. В графе отправителя — твоё имя."
		else:
			ending_title.text = "Концовка: Ложное прощение"
			ending_body.text = "Анна прощает тебя. Ты плачешь от облегчения, пока не замечаешь: в зеркале она стоит одна, а твоя тень осталась на полу комнаты."

func _show_small_message(text: String) -> void:
	can_move = false
	mouse_captured = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	letter_panel.visible = true
	letter_title.text = "Воспоминание"
	letter_body.text = text
	_clear_children(choice_box)
	close_button.visible = true

func _update_focus_hint() -> void:
	ray.force_raycast_update()
	if ray.is_colliding():
		var collider := ray.get_collider()
		if collider and collider.has_meta("interaction_id"):
			var id := str(collider.get_meta("interaction_id"))
			focus_label.text = "[E] " + str(interactables.get(id, "Взаимодействовать"))
			return
	focus_label.text = ""

func _update_hud() -> void:
	stats_label.text = "Письма: %s/%s | Любовь: %s | Вина: %s | Безумие: %s" % [current_letter, letters.size(), love, guilt, madness]

func _apply_atmosphere() -> void:
	for obj in decay_objects:
		obj.visible = guilt >= 3
	for obj in warm_objects:
		obj.visible = love >= 3
	for obj in madness_objects:
		obj.visible = madness >= 3

	var lamp: OmniLight3D = important_nodes.get("lamp")
	if lamp:
		lamp.light_energy = clamp(1.5 + love * 0.12 - madness * 0.10, 0.35, 2.1)
		lamp.light_color = Color(1.0, 0.72 - min(guilt, 6) * 0.05, 0.45 - min(madness, 6) * 0.04)
	var main_light: DirectionalLight3D = important_nodes.get("main_light")
	if main_light:
		main_light.light_energy = clamp(0.55 - madness * 0.04, 0.15, 0.6)

func _create_box(name: String, pos: Vector3, size: Vector3, color: Color, interaction_id: String = "") -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = name
	body.position = pos

	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	if color.a < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	body.add_child(mesh_instance)
	mesh_instance.material_override = material

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)

	if interaction_id != "":
		body.set_meta("interaction_id", interaction_id)
		interactables[interaction_id] = name.replace("_", " ")
	add_child(body)
	return body

func _add_label(pos: Vector3, text: String, size: float) -> void:
	var label := Label3D.new()
	label.position = pos
	label.text = text
	label.font_size = 42
	label.pixel_size = size * 0.01
	label.modulate = Color(0.95, 0.9, 0.78)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)

func _clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()
