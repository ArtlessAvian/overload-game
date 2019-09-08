extends "res://addons/GUT/test.gd"

var BlocksScript = load("res://board/blocks/BlocksModel.gd");

func test_initable():
	assert_not_null(BlocksScript.new());

func test_width_was_init():
	for i in range(3):
		var b : Blocks = BlocksScript.new(i);
		assert_eq(b.get_width(), i)
		
		assert_eq(len(b._chain_storage), i)
		for queued in b._queued_rows:
			assert_eq(len(queued), i)

func test_queued_was_init():
	var b : Blocks = BlocksScript.new(10);
	assert_eq(len(b._queued_rows), 3);
	for queued in b._queued_rows:
		assert_false(-1 in queued);

func test_no_clears_in_queued():
	var b : Blocks = BlocksScript.new(100);
	assert_true(b.detect_in_jagged(b._queued_rows).empty());

func test_push_up_order():
	var b : Blocks = BlocksScript.new(1);
	
	var remembered = [];
	for i in range(-3, 9):
		remembered.append(b.get_block(0, i));
	
	for i in range(10):
		b.push_up();
		var slice = [];
		for i in range(-2, 10):
			slice.append(b.get_block(0, i));
		assert_eq(remembered, slice);
		remembered.pop_back();
		remembered.push_front(b.get_block(0, -3));

func test_no_clears_without_interaction():
	var b : Blocks = BlocksScript.new(100);
	for i in range(100):
		b.push_up();
	assert_true(b.detect_in_jagged(b._static_blocks).empty())