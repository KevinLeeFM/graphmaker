extends Line2D

var connections = null : set = _set_connections

func _set_connections(new_connections):
    connections = new_connections.duplicate()
    self.clear_points()
    self.add_point(new_connections[0].get_global_position())
    self.add_point(new_connections[1].get_global_position())

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if connections != null and len(connections) >= 2:
        if connections[0] != null and connections[1] != null:
            self.set_point_position(0, connections[0].get_global_position())
            self.set_point_position(1, connections[1].get_global_position())


func delete():
    connections[0].connection[connections[1]].queue_free()
    connections[0].connection.erase(connections[1])
    connections[1].connection.erase(connections[0])
    self.queue_free()
