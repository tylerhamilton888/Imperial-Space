extends CanvasLayer

const UI = preload("res://ui/palette.gd")
var arena: Node2D
var base: Control
var modal: ColorRect
var scenario_name: Label
var status: Label
var counter: Label
var ammo: Label
var meds: Label
var hp_bar: ColorRect
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
	var title:=UI.panel(base,Vector2(20,18),Vector2(288,60))
	UI.mark(title,Vector2(8,6),46)
	UI.place(UI.label("DEVELOPER ARENA",18,UI.PAPER),title,Vector2(62,4))
	scenario_name=UI.label("",14,UI.CYAN)
	UI.place(scenario_name,title,Vector2(63,30))
	var top:=UI.panel(base,Vector2(843,18),Vector2(417,56))
	counter=UI.label("",15,UI.SOFT)
	UI.place(counter,top,Vector2(14,15))
	commands=UI.button("Range controls",func(): arena.set_panel("controls"))
	UI.place(commands,top,Vector2(116,8),Vector2(201,39))
	pause_button=UI.button("Pause",func(): arena.set_panel("pause"))
	UI.place(pause_button,top,Vector2(325,8),Vector2(83,39))
	var vitals:=UI.panel(base,Vector2(20,625),Vector2(421,75))
	UI.place(UI.label("CRUSADER",13,UI.GOLD),vitals,Vector2(15,9))
	health_text=UI.label("",14)
	UI.place(health_text,vitals,Vector2(120,8))
	var track:=ColorRect.new()
	track.color=Color("#3c4a50")
	UI.place(track,vitals,Vector2(16,39),Vector2(146,7))
	hp_bar=ColorRect.new()
	hp_bar.color=UI.CYAN
	UI.place(hp_bar,vitals,Vector2(16,39),Vector2(146,7))
	meds=UI.label("",12,UI.SOFT)
	UI.place(meds,vitals,Vector2(16,51))
	UI.place(UI.label("SERVICE RIFLE",13,UI.GOLD),vitals,Vector2(201,8))
	ammo=UI.label("",24,UI.PAPER)
	UI.place(ammo,vitals,Vector2(201,28))
	status=UI.label("",14,UI.CYAN)
	UI.place(status,vitals,Vector2(320,36))
	var key_bar:=UI.panel(base,Vector2(561,651),Vector2(699,49))
	hint=UI.label("",14,UI.SOFT)
	UI.place(hint,key_bar,Vector2(0,0),Vector2(699,49))
	hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	hint.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
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
	health_text.text="%d HP" % p.health
	hp_bar.size.x=146*float(p.health)/maxf(p.max_health,1)
	hp_bar.color=Color("#e18b70") if float(p.health)/float(p.max_health)<=.3 else UI.CYAN
	ammo.text="%02d  /  %02d" % [p.magazine,p.reserve]
	meds.text="MEDICAL   × %d" % p.med_charges
	commands.text="Range controls  [%s]" % arena.prefs.key_text("arena_panel")
	var movement: String = "".join([arena.prefs.key_text("move_up"),arena.prefs.key_text("move_left"),arena.prefs.key_text("move_down"),arena.prefs.key_text("move_right")])
	if movement.length()>7: movement="Move keys"
	hint.text="%s  Move    %s  Fire    %s  Sword    %s  Dodge    %s  Guard    %s  Reload    %s  Heal" % [movement,arena.prefs.mouse_text("fire"),arena.prefs.mouse_text("melee"),arena.prefs.key_text("dodge"),arena.prefs.key_text("guard"),arena.prefs.key_text("reload"),arena.prefs.key_text("heal")]

func _process(dt: float) -> void:
	if is_instance_valid(arena.player):
		var now:String=arena.player.action
		status.text=now.capitalize() if now in ["reload","guard","parry","heal"] else ""
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
	modal.color=Color("#050c13ce")
	UI.place(modal,self,Vector2.ZERO,Vector2(1280,720))
	if kind=="controls": _range_controls()
	else: _pause_or_defeat(kind)

func _pause_or_defeat(kind: String) -> void:
	var p:=UI.panel(modal,Vector2(410,199),Vector2(460,322))
	UI.mark(p,Vector2(25,24),42)
	UI.place(UI.label("DEVELOPER ARENA",15,UI.GOLD),p,Vector2(78,34))
	UI.place(UI.label("Crusader defeated" if kind=="defeat" else "Paused",39,UI.PAPER,true),p,Vector2(26,83))
	var b:=UI.button("Retry scenario" if kind=="defeat" else "Resume",func():
		if kind=="defeat": arena.restart()
		else: arena.set_panel(""),true)
	UI.place(b,p,Vector2(28,163),Vector2(404,47))
	b.grab_focus()
	var second:=UI.button("Range controls" if kind=="pause" else "Main menu",func():
		if kind=="pause": arena.set_panel("controls")
		else: arena.leave())
	UI.place(second,p,Vector2(28,220),Vector2(196 if kind=="pause" else 404,42))
	if kind=="pause":
		UI.place(UI.button("Main menu",arena.leave),p,Vector2(235,220),Vector2(197,42))

func _range_controls() -> void:
	var p:=UI.panel(modal,Vector2(155,80),Vector2(970,560))
	UI.place(UI.label("Range controls",40,UI.PAPER,true),p,Vector2(32,17))
	UI.place(UI.label("SIMULATION PAUSED",13,UI.CYAN),p,Vector2(771,39))
	UI.rule(p,32,83,906,Color("#485c63"))
	UI.place(UI.label("Scenarios",23,UI.PAPER,true),p,Vector2(32,100))
	for i: int in arena.SCENARIOS.size():
		var scenario:Resource=arena.SCENARIOS[i]
		var y:=151+i*66
		var b:=UI.button(scenario.title,arena.restart.bind(i),i==arena.scenario_index)
		b.tooltip_text=scenario.purpose
		UI.place(b,p,Vector2(32,y),Vector2(168,45))
		var purpose:=UI.label(scenario.purpose,14,UI.SOFT)
		purpose.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		UI.place(purpose,p,Vector2(215,y-1),Vector2(273,50))
	var divider:=ColorRect.new()
	divider.color=Color("#485c63")
	UI.place(divider,p,Vector2(503,111),Vector2(1,346))
	UI.place(UI.label("Spawn an actor",23,UI.PAPER,true),p,Vector2(528,100))
	var role:=OptionButton.new()
	var roles:=["dummy","raider","gunner"]
	for r: String in roles: role.add_item(r.capitalize())
	role.select(roles.find(arena.spawn_role))
	role.item_selected.connect(func(index:int): arena.spawn_role=roles[index])
	UI.place(role,p,Vector2(529,151),Vector2(169,40))
	var count:=OptionButton.new()
	for i in range(1,5): count.add_item("Count    %d" % i)
	count.select(arena.spawn_count-1)
	count.item_selected.connect(func(index:int): arena.spawn_count=index+1)
	UI.place(count,p,Vector2(711,151),Vector2(115,40))
	UI.place(UI.button("Spawn",arena.spawn_selected),p,Vector2(836,151),Vector2(100,40))
	var passive:=CheckButton.new()
	passive.text="Passive on spawn"
	passive.button_pressed=arena.spawn_passive
	passive.toggled.connect(func(on:bool): arena.spawn_passive=on)
	UI.place(passive,p,Vector2(529,207),Vector2(214,36))
	UI.place(UI.button("Refill Crusader",arena.refill),p,Vector2(529,269),Vector2(191,42))
	UI.place(UI.button("Clear targets",arena.clear_enemies),p,Vector2(735,269),Vector2(201,42))
	grid_option=CheckButton.new()
	grid_option.text="Scale grid   [%s]" % arena.prefs.key_text("arena_grid")
	grid_option.button_pressed=arena.grid_on
	grid_option.toggled.connect(func(_on:bool): arena.toggle_grid())
	UI.place(grid_option,p,Vector2(529,333),Vector2(220,34))
	UI.place(UI.label("MEDIUM ARMOR     /     SERVICE RIFLE + SWORD",13,UI.GOLD),p,Vector2(529,407))
	UI.rule(p,32,457,906,Color("#485c63"))
	UI.place(UI.label("Seed %d     •     %s" % [arena.scenario.seed_value,arena.scenario.title],14,UI.SOFT),p,Vector2(32,489))
	UI.place(UI.button("Restart  [%s]" % arena.prefs.key_text("arena_reset"),arena.restart),p,Vector2(581,480),Vector2(164,47))
	var resume:=UI.button("Resume",func(): arena.set_panel(""),true)
	UI.place(resume,p,Vector2(759,480),Vector2(177,47))
	resume.grab_focus()
