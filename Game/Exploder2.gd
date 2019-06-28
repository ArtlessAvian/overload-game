extends TileMap
signal finished_exploding; # Args are an array of Vector2 (Ints), then a y offset.
class_name Exploder2

# Always a child of a child of Blocks
var board_options : BoardOptions = preload("res://Options/Default.tres");
func set_board_options(thing : BoardOptions):
	self.board_options = thing;

# Kinda RAII?

var physics_time = 0;
var model_explode = [];
var chain = 0;
var y_offset = 0;

var initial_wait = true;
var visual_explode = [];
var animation_time = 0;
var explode_time = 0;
var effects = [];

func initialize():
	# Model
	model_explode = self.get_used_cells();
	for i in range(len(model_explode)):
		model_explode[i].y = -model_explode[i].y-1;
		
	# View
	visual_explode = self.get_used_cells();
	visual_explode.invert();
	
	var combo = len(self.model_explode);
	if (chain != 1):
		$"HBoxContainer/Chain/Label".text = "x" + str(chain);
	else:
		$"HBoxContainer/Chain".free()
	if (combo > 3):
		$"HBoxContainer/Combo/Label".text = str(combo);
	else:
		$"HBoxContainer/Combo".free()
	$"HBoxContainer".rect_position = self.map_to_world(visual_explode[-1]) + self.cell_size/2;
	$"HBoxContainer".rect_position -= $"HBoxContainer".rect_size / 2;
	
	effects.append($"Particles2D");
	while len(effects) <= len(self.visual_explode)-1:
		var temp = $"Particles2D".duplicate();
		effects.append(temp);
		self.add_child(temp);

func _process(delta):
	animation_time += delta;
	
	# Move to its own script?
	var popup_speed = 10 * (0.5 - animation_time);
	$"HBoxContainer".rect_position.y -= delta * self.cell_size.y * popup_speed;
	$"HBoxContainer".modulate.a *= 0.95;
	
	if self.initial_wait:
		if animation_time >= 0.5 * self.board_options.explode_pause:
			initial_wait = false;
		return;
	
	explode_time += delta;
	
	while self.explode_time >= self.board_options.explode_interval and not self.visual_explode.empty():
		# TODO: Move to process
		# Physics Process should only handle the model.
		self.explode_time -= self.board_options.explode_interval;
		var thing = self.visual_explode.pop_back();
		var color = get_cellv(thing);
		
		if (color != self.board_options.GARBAGE):
			self.set_cellv(thing, self.board_options.EMPTY);
		else:
			self.set_cellv(thing, randi() % self.board_options.color_count);
		
		var effect = self.effects.pop_back();
		effect.modulate.r = cos((color/5.0) * 2 * PI)/2 + 0.5;
		effect.modulate.g = cos((color/5.0 - 1/3.0) * 2 * PI)/2 + 0.5;
		effect.modulate.b = cos((color/5.0 - 2/3.0) * 2 * PI)/2 + 0.5;
		effect.position = self.map_to_world(thing);
		effect.position += self.cell_size * 0.5;
		effect.emitting = true;
		effect.get_child(0).play();

func _physics_process(delta):
	physics_time += delta;
	
	if physics_time >= (self.board_options.explode_pause + self.board_options.explode_interval * len(model_explode)):
		self.emit_signal("finished_exploding", self.model_explode, self.y_offset, self.chain);
		# TODO: Move to inside blocks.
#		for block in model_explode:
#			var y = -block.y-1 + y_offset;
#			assert(self.get_blocks().board[block.x][y] == self.board_options.CLEARING);
#			self.get_blocks().make_faller_column(block.x, y+1, chain + 1);
#
#			self.get_blocks().board[block.x][y] = get_cellv(block);
#			self.get_blocks().chain_checker[block.x][y] = chain+1;
		
		self.queue_free();

func true_raise():
	y_offset += 1;