extends Node2D

func _ready():
    $Mob.set_physics_process(false)
    pass

func _input(event):
    if event is InputEventMouseButton:
        var trans = $Mob.get_global_transform_with_canvas()
        var target_pos = event.position - trans.origin
        print(event.global_position)
        print($Mob.get_global_transform_with_canvas().origin)
        $Mob.aim_turret(target_pos)