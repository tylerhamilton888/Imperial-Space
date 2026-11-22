extends CanvasLayer

const UI = preload("res://ui/palette.gd")
const Instruments = preload("res://ui/instrument_theme.gd")
const STATUS_TEXT := {"reload":"Reloading", "guard":"Guard raised", "heal":"Applying medical charge"}
const PLATE: Texture2D = preload("res://art/hud/field_instruments.webp")
const GLASS: Texture2D = preload("res://art/hud/vitality_glass.webp")
var arena: Node2D
var base: Control
var modal: ColorRect
var scenario_name: Label
var status: Label
var counter: Label
var ammo: Label
var meds: Label
var hp_bar: TextureProgressBar
var sword_key: Label
var rifle_key: Label
var health_text: Label
var hint: Label
var toast: Label
var toast_time := 0.0
var commands: Button
var pause_button: Button
var grid_option: CheckButton

func _ready() -> void:
	process_mode=Node.PROCESS_MODE_ALWAYS
	layer=10
	base=Control.new()
	base.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(base)
	base.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var title := Instruments.frame(base, Vector2(17,15), Vector2(257,62))
	Instruments.mark(title,Vector2(10,10),40)
	UI.place(UI.label("Developer Arena",21,UI.PAPER,true),title,Vector2(57,6))
	scenario_name = UI.label("",13,UI.GOLD)
	UI.place(scenario_name,title,Vector2(58,34))
	var top := Instruments.frame(base,Vector2(848,15),Vector2(415,58))
	counter=UI.label("",14,UI.GOLD)
	UI.place(counter,top,Vector2(15,17))
	commands=Instruments.button("Range controls",func(): arena.set_panel("controls"))
	UI.place(commands,top,Vector2(110,9),Vector2(204,39))
	pause_button=Instruments.button("Pause",func(): arena.set_panel("pause"))
	UI.place(pause_button,top,Vector2(321,9),Vector2(80,39))

	var instruments := TextureRect.new()
	instruments.texture = PLATE
	instruments.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	instruments.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UI.place(instruments,base,Vector2(316,619),Vector2(649,95))
	hp_bar = TextureProgressBar.new()
	hp_bar.texture_progress = GLASS
	hp_bar.fill_mode = TextureProgressBar.FILL_BOTTOM_TO_TOP
	hp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hp_bar.scale = Vector2(0.5,0.5)
	UI.place(hp_bar,instruments,Vector2(16,13),Vector2(128,128))
	health_text = UI.label("",22,UI.PAPER,true)
	health_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	health_text.add_theme_constant_override("outline_size",4)
	health_text.add_theme_color_override("font_outline_color",Color("#401524"))
	UI.place(health_text,instruments,Vector2(20,23),Vector2(56,29))
	var hp_unit := UI.label("HP",11,Color("#f2ceba"))
	hp_unit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hp_unit.add_theme_constant_override("outline_size",2)
	hp_unit.add_theme_color_override("font_outline_color",Color("#401524"))
	UI.place(hp_unit,instruments,Vector2(20,50),Vector2(56,14))

	UI.place(UI.label("Service rifle",16,UI.PAPER,true),instruments,Vector2(151,24))
	ammo=UI.label("",15,Color("#ffdc98"))
	UI.place(ammo,instruments,Vector2(151,45))
	rifle_key=UI.label("",12,UI.SOFT)
	UI.place(rifle_key,instruments,Vector2(224,47))
	UI.place(UI.label("Field sword",16,UI.PAPER,true),instruments,Vector2(343,24))
	sword_key=UI.label("",13,UI.SOFT)
	UI.place(sword_key,instruments,Vector2(343,46))
	UI.place(UI.label("Medical charge",16,UI.PAPER,true),instruments,Vector2(506,24))
	meds=UI.label("",14,Color("#ffdc98"))
	UI.place(meds,instruments,Vector2(506,45))
	hint=UI.label("",12,Color("#d4c9b5"))
	hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	UI.place(hint,instruments,Vector2(91,67),Vector2(540,20))
	status=UI.label("",14,UI.PAPER)
	status.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	status.add_theme_constant_override("outline_size",5)
	status.add_theme_color_override("font_outline_color",Color("#18202b"))
	UI.place(status,base,Vector2(520,611),Vector2(270,25))
	toast=UI.label("",16,UI.PAPER)
	toast.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	toast.add_theme_color_override("font_outline_color",Color("#112027"))
	toast.add_theme_constant_override("outline_size",6)
	UI.place(toast,base,Vector2(360,22),Vector2(460,42))

func refresh() -> void:
	if not is_instance_valid(arena.player): return
	var p=arena.player
	if is_instance_valid(grid_option): grid_option.set_pressed_no_signal(arena.grid_on)
	scenario_name.text=arena.scenario.title
	counter.text="%d   TARGET%s" % [arena.live_enemies.size(),"" if arena.live_enemies.size()==1 else "S"]
	health_text.text=str(p.health)
	hp_bar.max_value=p.max_health
	hp_bar.value=p.health
	ammo.text="%d / %d" % [p.magazine,p.reserve]
	meds.text="× %d     %s" % [p.med_charges,arena.prefs.key_text("heal")]
	rifle_key.text=arena.prefs.mouse_text("fire")
	sword_key.text=arena.prefs.mouse_text("melee")
	commands.text="Range controls  [%s]" % arena.prefs.key_text("arena_panel")
	var movement: String = " ".join([arena.prefs.key_text("move_up"),arena.prefs.key_text("move_left"),arena.prefs.key_text("move_down"),arena.prefs.key_text("move_right")])
	var move_legend: String = movement + "   Move" if movement.length() <= 21 else "Movement"
	hint.text="%s      ·      %s   Dodge      ·      %s   Guard      ·      %s   Reload" % [move_legend,arena.prefs.key_text("dodge"),arena.prefs.key_text("guard"),arena.prefs.key_text("reload")]

func _process(dt: float) -> void:
	if is_instance_valid(arena.player):
		var now:String=arena.player.action
		status.text=STATUS_TEXT.get(now,"")
	if toast_time>0:
		toast_time-=dt
		if toast_time<=0: toast.text=""

func notice(message: String) -> void:
	toast.text=message
	toast_time=2.2

func show_panel(kind: String) -> void:
	grid_option=null
	if is_instance_valid(modal):
		remove_child(modal)
		modal.queue_free()
		modal=null
	commands.focus_mode=Control.FOCUS_ALL if kind=="" else Control.FOCUS_NONE
	pause_button.focus_mode=commands.focus_mode
	if kind=="": return
	toast.text=""
	modal=ColorRect.new()
	modal.color=Color("#0a0d14cc")
	UI.place(modal,self,Vector2.ZERO,Vector2(1280,720))
	if kind=="controls": _range_controls()
	else: _pause_or_defeat(kind)

func _pause_or_defeat(kind: String) -> void:
	var p:=Instruments.frame(modal,Vector2(410,199),Vector2(460,322))
	Instruments.mark(p,Vector2(25,24),42)
	UI.place(UI.label("DEVELOPER ARENA",15,UI.GOLD),p,Vector2(78,34))
	UI.place(UI.label("Crusader defeated" if kind=="defeat" else "Paused",39,UI.PAPER,true),p,Vector2(26,83))
	var b:=Instruments.button("Retry scenario" if kind=="defeat" else "Resume",func():
		if kind=="defeat": arena.restart()
		else: arena.set_panel(""),true)
	UI.place(b,p,Vector2(28,163),Vector2(404,47))
	b.grab_focus()
	var second:=Instruments.button("Range controls" if kind=="pause" else "Main menu",func():
		if kind=="pause": arena.set_panel("controls")
		else: arena.leave())
	UI.place(second,p,Vector2(28,220),Vector2(196 if kind=="pause" else 404,42))
	if kind=="pause":
		UI.place(Instruments.button("Main menu",arena.leave),p,Vector2(235,220),Vector2(197,42))

func _range_controls() -> void:
	var p:=Instruments.frame(modal,Vector2(155,80),Vector2(970,560))
	Instruments.mark(p,Vector2(34,23),38)
	UI.place(UI.label("Range controls",39,UI.PAPER,true),p,Vector2(86,16))
	UI.place(UI.label("SIMULATION PAUSED",13,UI.GOLD),p,Vector2(771,39))
	UI.rule(p,32,83,906,Color("#695d49"))
	UI.place(UI.label("Scenarios",23,UI.PAPER,true),p,Vector2(32,100))
	for i: int in arena.SCENARIOS.size():
		var scenario:Resource=arena.SCENARIOS[i]
		var y:=151+i*66
		var b:=Instruments.button(scenario.title,arena.restart.bind(i),i==arena.scenario_index)
		b.tooltip_text=scenario.purpose
		UI.place(b,p,Vector2(32,y),Vector2(168,45))
		var purpose:=UI.label(scenario.purpose,14,UI.SOFT)
		purpose.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		UI.place(purpose,p,Vector2(215,y-1),Vector2(273,50))
	var divider:=ColorRect.new()
	divider.color=Color("#695d49")
	UI.place(divider,p,Vector2(503,111),Vector2(1,346))
	UI.place(UI.label("Spawn an actor",23,UI.PAPER,true),p,Vector2(528,100))
	var role:=OptionButton.new()
	Instruments.selector(role)
	var roles:=["dummy","raider","gunner"]
	for r: String in roles: role.add_item(r.capitalize())
	role.select(roles.find(arena.spawn_role))
	role.item_selected.connect(func(index:int): arena.spawn_role=roles[index])
	UI.place(role,p,Vector2(529,151),Vector2(169,40))
	var count:=OptionButton.new()
	Instruments.selector(count)
	for i in range(1,5): count.add_item("Count    %d" % i)
	count.select(arena.spawn_count-1)
	count.item_selected.connect(func(index:int): arena.spawn_count=index+1)
	UI.place(count,p,Vector2(711,151),Vector2(115,40))
	UI.place(Instruments.button("Spawn",arena.spawn_selected),p,Vector2(836,151),Vector2(100,40))
	var passive:=CheckButton.new()
	passive.text="Passive on spawn"
	passive.button_pressed=arena.spawn_passive
	passive.toggled.connect(func(on:bool): arena.spawn_passive=on)
	UI.place(passive,p,Vector2(529,207),Vector2(214,36))
	UI.place(Instruments.button("Refill Crusader",arena.refill),p,Vector2(529,269),Vector2(191,42))
	UI.place(Instruments.button("Clear targets",arena.clear_enemies),p,Vector2(735,269),Vector2(201,42))
	grid_option=CheckButton.new()
	grid_option.text="Scale grid   [%s]" % arena.prefs.key_text("arena_grid")
	grid_option.button_pressed=arena.grid_on
	grid_option.toggled.connect(func(_on:bool): arena.toggle_grid())
	UI.place(grid_option,p,Vector2(529,333),Vector2(220,34))
	UI.place(UI.label("MEDIUM ARMOR     /     SERVICE RIFLE + SWORD",13,UI.GOLD),p,Vector2(529,407))
	UI.rule(p,32,457,906,Color("#695d49"))
	UI.place(UI.label("Seed %d     •     %s" % [arena.scenario.seed_value,arena.scenario.title],14,UI.SOFT),p,Vector2(32,489))
	UI.place(Instruments.button("Restart  [%s]" % arena.prefs.key_text("arena_reset"),arena.restart),p,Vector2(581,480),Vector2(164,47))
	var resume:=Instruments.button("Resume",func(): arena.set_panel(""),true)
	UI.place(resume,p,Vector2(759,480),Vector2(177,47))
	resume.grab_focus()
