extends "res://Bullet.gd"
onready var Artillery = get_node("/root/Artillery")

func aim():
    var t = target.get_ref()
    if not t:
        return
    var angle_diff = Artillery.calc_angle_diff(self, t.position)
    rotation = lerp(rotation, rotation + angle_diff, 0.05)