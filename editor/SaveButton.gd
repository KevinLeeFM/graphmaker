extends Button

@onready var save_successful_dialogue = $SaveSuccessfulDialog

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass


func _on_pressed():
    save_successful_dialogue.set_visible(true)
