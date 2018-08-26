extends KinematicBody2D

export (int) var shot_speed = 500
export (int) var shot_range = 500
var traveled = 0
var target = null


func _ready():
    set_physics_process(false)

func _physics_process(delta):
    if traveled > shot_range:
        queue_free()
        return
    aim()
    var distance = shot_speed * delta
    traveled += distance
    var move = Vector2(distance,0).rotated(rotation)
    var col = move_and_collide(move)
    
    if col:
        if col.collider.has_method('hit'):
            col.collider.hit(self)
        queue_free()

func aim():
    pass
    
