extends GraphNode

var rename_dialogue_scene: PackedScene = preload("res://dialogues/set_name_dialogue_window.tscn")
var rename_dialogue = null
var renaming = false
@onready var context_menu = $"ContextMenu"


# Called when the node enters the scene tree for the first time.
func _ready():
    title = 'peepeepoopoo'


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
    

func _rename_flow():
    if not renaming:
        renaming = true
        rename_dialogue = rename_dialogue_scene.instantiate()
        rename_dialogue.string = title
        self.add_child(rename_dialogue)
        rename_dialogue.on_string_confirmed.connect(_on_rename_complete)


func _on_rename_complete(new_title):
    print(new_title)
    title = new_title
    rename_dialogue = null
    renaming = false


func _on_node_selected():
    context_menu.set_visible(true)


func _on_node_deselected():
    context_menu.set_visible(false)


func _on_rename_button_pressed():
    _rename_flow()
