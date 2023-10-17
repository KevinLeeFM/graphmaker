extends Window

signal on_string_confirmed(string)

var string = ""
@onready var textedit = $"Control/TextEdit"

# Called when the node enters the scene tree for the first time.
func _ready():
    textedit.set_text(string)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass


func _on_button_pressed():
    string = textedit.get_text()
    on_string_confirmed.emit(string)
    self.queue_free()
