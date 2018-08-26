extends Node

func _ready():
    pass


func _input(event):
    if event is InputEventMouseButton:
        var trans = $Missile.get_global_transform_with_canvas()
        var blumba = Node2D.new()
        add_child(blumba)
        blumba.position = event.position
        $Missile.target = weakref(blumba)
        $Missile.set_physics_process(true)