extends KinematicBody2D

export (int) var shot_speed = 500
export (int) var shot_range = 500
var traveled = 0
var target = null


func _ready():
    set_physics_process(false)

func _physics_process(delta):
    if traveled > shot_range:
        die()
        return
    aim()
    var distance = shot_speed * delta
    traveled += distance
    var move = Vector2(distance,0).rotated(rotation)
    var col = move_and_collide(move)
    
    if col:
        if col.collider.has_method('hit'):
            col.collider.hit(self)
        die()

func aim():
    pass

func die():
    queue_free()

func is_type(type): 
    return type == "Bullet" or .is_type(type)
    
func get_type(): 
    return "Bullet"
