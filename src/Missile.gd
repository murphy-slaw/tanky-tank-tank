extends "res://Bullet.gd"
onready var Artillery = get_node("/root/Artillery")

func aim():
    var t = target.get_ref()
    if not t:
        return
    var angle_diff = Artillery.calc_angle_diff(self, t.position)
    rotation = lerp(rotation, rotation + angle_diff, 0.05)
    
#func die():
#    var particles = get_node('Particles2D')
#    var parent = get_parent()
#    remove_child(particles)
#    parent.add_child(particles)
#    particles.position = position
#    particles.start_countdown()
#    queue_free()