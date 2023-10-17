extends Camera2D


@export var drag: float = 0.2

var clicked
var current_pos
var last_pos
var new_position = null
var stored_position = position

func _ready():
    last_pos = get_viewport().get_mouse_position()

func _process(delta):
    current_pos = get_viewport().get_mouse_position()
    if clicked:
        new_position = position - (current_pos - last_pos) / zoom
    elif new_position: position = position + (new_position - position) * drag
    last_pos = current_pos

func _input(event):
    if event is InputEventMouseButton:
        clicked = event.is_action_pressed("pan")
    
    if event is InputEventMouseMotion:
        if clicked:
            position -= event.relative / zoom

    if event.is_action_pressed("zoom_in"):
        self.zoom *= 1.2
    
    if event.is_action_pressed("zoom_out"):
        self.zoom *= 1 / 1.2
