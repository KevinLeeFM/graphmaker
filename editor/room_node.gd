extends Node2D

@onready var context = $Context
@onready var polygon_inner = $PolygonInner
@onready var exit_indicator = $ExitIndicator
@onready var name_label = $Context/NameLabel

var selected = false : set = _set_selected
var lifted = false
var editor = null
var connection = {}
var room_name = "" : set = _set_room_name
var is_exit = false : set = _set_is_exit

# of format [floor_name,room_name] for each element
var extra_connections = []

func delete():
    var connection_snapshot = connection.duplicate()
    for k in connection_snapshot:
        connection[k].delete()
        
    self.queue_free()
    

func append_extra_connection(conn):
    self.extra_connections.append(conn)
 
   
func remove_extra_connection_at_index(index):
    self.extra_connections.remove_at(index)


func _set_room_name(new_room_name):
    room_name = new_room_name
    if name_label != null:
        name_label.set_text(new_room_name)


func _set_selected(new_selected):
    selected = new_selected
    self.polygon_inner.set_color(Color.DARK_BLUE if new_selected else Color.WHITE)

    if not new_selected:
        context.set_visible(false)
     
       
func _set_is_exit(new_is_exit):
    is_exit = new_is_exit
    
    if exit_indicator != null:
        exit_indicator.set_visible(is_exit)


# Called when the node enters the scene tree for the first time.
func _ready():
    name_label.set_text(room_name)
    exit_indicator.set_visible(is_exit)
    context.set_visible(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass


func _on_area_2d_mouse_entered():
    context.set_visible(true)


func _on_area_2d_mouse_exited():
    if not selected:
        context.set_visible(false)
    

func _unhandled_input(event):
    if event is InputEventMouseMotion and lifted:
        position = get_global_mouse_position()
        
    elif event is InputEventMouseButton and not event.pressed:
        lifted = false


func _on_area_2d_input_event(viewport, event, shape_idx):
    if event is InputEventMouseButton and event.is_action_pressed("move_node"):
        lifted = true
        get_tree().get_nodes_in_group("editor")[0].set_selected(self)
        
    if event is InputEventMouseButton and event.is_action_pressed("create_edge"):
        get_tree().get_nodes_in_group("editor")[0].append_node(self)

