extends TileMap

signal endgame
var running=true

const UNCLEAR=Vector2i(0,0)
const MINE=Vector2i(1,0)
const CLEAR=Vector2i(2,0)
const FLAGGED=Vector2i(3,0)

var remaining=144
var mine_locations=[]
var neighbor_mine_numbers={}

func get_clicked_tile():
	return local_to_map(get_local_mouse_position())

func count_neighbor_mines(coords):
	var x=coords.x
	var y=coords.y
	var count=0
	for ny in range(y-1,y+2):
		if ny<0 or ny>8:
			continue
		for nx in range(x-1,x+2):
			if nx<0 or nx>15:
				continue
			if Vector2i(nx,ny) in mine_locations:
				count+=1
	return count

func generate_mine_locations(exception):
	running=false
	for py in range(0,18):
		var y=(py-py%2)/2
		var temp=Vector2i(randi_range(1,14),y)
		while temp in exception or temp in mine_locations:
			temp=Vector2i(randi_range(1,14),y)
		mine_locations.append(temp)
	print(len(mine_locations))
	for y in range(0,9):
		for x in range(0,16):
			var thisxy=Vector2i(x,y)
			neighbor_mine_numbers[thisxy]=count_neighbor_mines(thisxy)
	running=true

func toggle_flag_tile(coords):
	var tile_type=get_cell_atlas_coords(0,coords,false)
	var target_type=FLAGGED
	if tile_type==FLAGGED:
		target_type=UNCLEAR
	elif tile_type!=UNCLEAR:
		return
	set_cell(0,coords,0,target_type)

func end_game():
	emit_signal("endgame")
	running=false
	for mine in mine_locations:
		set_cell(0,mine,0,MINE)

func clear_tile(coords):
	var tile_type=get_cell_atlas_coords(0,coords,false)
	if tile_type==UNCLEAR or tile_type==FLAGGED:
		if coords in mine_locations:
			end_game()
		else:
			remaining-=1
			var count=neighbor_mine_numbers[coords]
			var count_label=Label.new()
			count_label.text=str(count)
			count_label.add_theme_font_size_override("font_size",25)
			count_label.set_position(coords*60)
			count_label.set_size(Vector2i(60,60))
			count_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
			count_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
			count_label.add_theme_font_override("font",load("res://tres/font.tres"))
			$"..".add_child(count_label)
			set_cell(0,coords,0,CLEAR)
			if not count:
				for y in range(coords.y-1,coords.y+2):
					if y<0 or y>8:
						continue
					for x in range(coords.x-1,coords.x+2):
						if x<0 or x>15:
							continue
						clear_tile(Vector2i(x,y))
	if remaining==18:
		end_game()
		return

func _input(event):
	if not running:
		return
	var action_tile=get_clicked_tile()
	if event.is_action_pressed("flag_mine"):
		toggle_flag_tile(action_tile)
	elif event.is_action_pressed("clear_mine"):
		if mine_locations==[]:
			generate_mine_locations([action_tile])
		clear_tile(action_tile)

func _on_button_pressed():
	get_tree().reload_current_scene()
