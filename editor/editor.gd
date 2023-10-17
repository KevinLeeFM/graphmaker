extends Node2D

var project_path = null : set = _set_project_path
var floor_name = ""

func _set_project_path(new_project_path):
    project_path = new_project_path
    save_button.set_visible(project_path != null)

var drawing = true
var roomnode_scene = preload("res://editor/room_node.tscn")
var roomedge_scene = preload("res://editor/room_edge.tscn")

var selected = null
var edge_nodes = []
@onready var toolbar_panel = $"CanvasLayer/Panel"

@onready var name_textedit = %NameTextEdit
@onready var exit_checkbox = %ExitCheckBox
@onready var save_button = %SaveButton

@onready var load_error_dialogue = %LoadErrorDialog

@onready var ec_floor_name = %ECFloorName
@onready var ec_room_name = %ECRoomName
@onready var ec_add_button = %ECAddButton
@onready var ec_remove_button = %ECRemoveButton
@onready var ec_item_list = %ECItemList
@onready var layout_texture_rect = %LayoutTextureRect

func set_selected(new_selected):
    if selected != null:
        selected.selected = false
    
    if new_selected != null:
        new_selected.selected = true
    
    selected = new_selected
    update_toolbar()
    
    
func update_toolbar():
    toolbar_panel.set_visible(selected != null)
    
    if selected != null:
        name_textedit.set_text(selected.room_name)
        exit_checkbox.set_pressed(selected.is_exit)
        
        ec_item_list.clear()
        for i in selected.extra_connections:
            var floor_name = i[0]
            var room_name = i[1]
            ec_item_list.add_item("→ {floor_name} {room_name}".format({"floor_name": floor_name, "room_name": room_name}))

    
func get_selected():
    return selected
    
    
func append_node(node):
    edge_nodes.append(node)
    
    if len(edge_nodes) >= 2:
        if edge_nodes[0] == edge_nodes[1]:
            edge_nodes = []
            return
        
        if edge_nodes[0].connection.has(edge_nodes[1]): # TODO
            # delete node
            edge_nodes[0].connection[edge_nodes[1]].delete()
        else:
            var roomedge = roomedge_scene.instantiate()
            roomedge.connections = edge_nodes
            self.add_child(roomedge)
            
            edge_nodes[0].connection[edge_nodes[1]] = roomedge
            edge_nodes[1].connection[edge_nodes[0]] = roomedge
            
        edge_nodes.clear()

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass


func _unhandled_input(event):
    if event is InputEventMouseButton and event.is_action_pressed("create_node"):
        var roomnode = roomnode_scene.instantiate()
        roomnode.set_global_position(get_global_mouse_position())
        self.add_child(roomnode)


func _on_deselect_button_pressed():
    set_selected(null)
    
    
func _on_delete_button_pressed():
    selected.delete()
    set_selected(null)
    edge_nodes = []


func _on_name_text_edit_text_changed():
    selected.room_name = name_textedit.get_text()


func _on_exit_check_box_pressed():
    selected.is_exit = exit_checkbox.is_pressed()


func _on_load_file_dialog_dir_selected(dir):
    project_path = dir
    print(dir)
    clear_canvas()
    load_project()
    
    
func load_nodes():
    # we only load the nodes if both nodes and edges are available
    if FileAccess.file_exists(project_path + "/nodes.csv") and FileAccess.file_exists(project_path + "/edges.csv"):
        var file = FileAccess.open(project_path + "/nodes.csv", FileAccess.READ)
        var content = file.get_as_text()
        
        var lines = content.split("\r\n", true)
        
        var names_to_nodes = {}
        
        # name,x,y,is_exit
        for l in lines.slice(1):
            print(l)
            var fields = l.split(",", true)
            
            var room_name: String = fields[0]
            var x: float = float(fields[1])
            var y: float = float(fields[2])
            var is_exit: bool = (fields[3] == 'true')
            
            var n = roomnode_scene.instantiate()
            
            n.room_name = room_name
            n.set_global_position(Vector2(x, y))
            n.is_exit = is_exit
            
            self.add_child(n)
            
            names_to_nodes[room_name] = n
            
        return names_to_nodes
    

func load_image(path: String):
    if path.begins_with('res'):
        return load(path)
    else:
        var file = FileAccess.open(path, FileAccess.READ)
        if FileAccess.get_open_error() != OK:
            print(str("Could not load image at: ",path))
            return
        var buffer = file.get_buffer(file.get_length())
        var image = Image.new()
        var error = image.load_png_from_buffer(buffer)
        if error != OK:
            print(str("Could not load image at: ",path," with error: ",error))
            return
        var texture = ImageTexture.create_from_image(image)
        return texture


func load_layout_image():
    var texture = load_image(project_path + "/layout.png")
    if texture != null:
        layout_texture_rect.set_texture(texture)
        
func load_edges(names_to_nodes):
    # we only load the edges if both nodes and edges are available
    if FileAccess.file_exists(project_path + "/edges.csv") and FileAccess.file_exists(project_path + "/edges.csv"):
        var file = FileAccess.open(project_path + "/edges.csv", FileAccess.READ)
        var content = file.get_as_text()
        
        var lines = content.split("\r\n", true)
        
        # start_floor,start_room_name,end_floor,end_room_name
        for l in lines.slice(1):
            print(l)
            var fields = l.split(",", true)
            
            var start_floor: String = fields[0]
            var start_room_name: String = fields[1]
            var end_floor: String = fields[2]
            var end_room_name: String = fields[3]
            
            # TODO: also check if on same floor as ours
#            if not (start_room_name in names_to_nodes or end_room_name in names_to_nodes):
#                # this edge is stray. We ignore it
#                continue
#
#            if not (start_floor == floor_name or end_floor == floor_name):
#                # this edge is stray. We ignore it
#                continue
            
            var extraneous = false
            
            if not (start_room_name in names_to_nodes) or not (start_floor == floor_name):
                if (end_room_name in names_to_nodes):
                    names_to_nodes[end_room_name].extra_connections.append([start_floor, start_room_name])
                
                extraneous = true
            
            
            if not (end_room_name in names_to_nodes) or not (end_floor == floor_name):
                if (start_room_name in names_to_nodes):
                    names_to_nodes[start_room_name].extra_connections.append([end_floor, end_room_name])
                
                extraneous = true
                
            if extraneous: continue
                
            
            var edge_nodes = [names_to_nodes[start_room_name], names_to_nodes[end_room_name]]
            var roomedge = roomedge_scene.instantiate()
            roomedge.connections = edge_nodes
            self.add_child(roomedge)
            
            edge_nodes[0].connection[edge_nodes[1]] = roomedge
            edge_nodes[1].connection[edge_nodes[0]] = roomedge
        
        return
   

func load_project():
        
    if not FileAccess.file_exists(project_path + "/layout.png"):
        load_error_dialogue.display_error("This folder is missing a layout.png. Please download your layout image and place it into this folder for editing the floor.")
        load_error_dialogue.set_visible(true)
        return
    
    load_layout_image()
    
    floor_name = project_path.rsplit("/")[1]
    print(floor_name)
    var map = load_nodes()
    load_edges(map)
    
    
func save_project():
    var node_file = FileAccess.open(project_path + "/nodes.csv", FileAccess.WRITE)
    node_file.store_csv_line(['name','x','y','is_exit'])
    
    var edge_file = FileAccess.open(project_path + "/edges.csv", FileAccess.WRITE)
    edge_file.store_csv_line(['start_floor','start_room_name','end_floor','end_room_name'])

    for node in get_tree().get_nodes_in_group("room_node"):
        node_file.store_csv_line([node.room_name, node.get_global_position().x, node.get_global_position().y, node.is_exit])
        for edge in node.extra_connections:
            edge_file.store_csv_line([floor_name, node.room_name, edge[0], edge[1]])
            
    for edge in get_tree().get_nodes_in_group("room_edge"):
        edge_file.store_csv_line([floor_name, edge.connections[0].room_name, floor_name, edge.connections[1].room_name])


func clear_canvas():
    get_tree().call_group("room_edge", "queue_free")
    get_tree().call_group("room_node", "queue_free")
    selected = null
    edge_nodes = []


func _on_ec_add_button_pressed():
    var floor_name = ec_floor_name.get_text()
    var room_name = ec_room_name.get_text()
    selected.append_extra_connection([floor_name, room_name])
    print(floor_name)
    print(room_name)
    ec_item_list.add_item("→ {floor_name} {room_name}".format({"floor_name": floor_name, "room_name": room_name}))


func _on_ec_remove_button_pressed():
    var index = ec_item_list.get_selected_items()[0] # assume select mode Single
    selected.remove_extra_connection_at_index(index)
    ec_item_list.remove_item(index)


func _on_save_button_pressed():
    save_project()
