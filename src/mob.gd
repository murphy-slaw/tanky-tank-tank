extends RigidBody2D

signal die

export (NodePath) var nav_path
export (NodePath) var goal_path
export (int) var speed = 30
export (int) var goal_radius = 500
var points = []
var nav
var goal = null

func _ready():
    nav = get_node(nav_path)
    
func update_nav():
    if goal:
        points = nav.get_simple_path(global_position, goal, true)
    
func _physics_process(delta):
    if goal == null:
        goal = get_node(goal_path).position
#        choose_random_goal()
    update_nav()
    if not points.size() > 1:
        return
    

    var impulse_pos = Vector2()

#    look_at(points[1])
    if global_position.floor() != points[-1].floor():
        var vel = linear_velocity.length()
        if vel < speed:
            var move = points[1] - global_position
            var distance = move.length()
            move = move.normalized() * min(speed - vel, distance)
        
            apply_impulse(impulse_pos, Vector2(1,0).rotated(rotation) * move.length())
        
        var distance = (points[-1] - global_position).length()
        if distance < 10:
            choose_random_goal()
            
func _integrate_forces(state):
    var target_angle = global_position.angle_to(points[1])
    target_angle = rotation - target_angle
    
    angular_velocity -= target_angle / -target_angle / 10
    
    
func choose_random_goal():
    var point = Vector2(1,0)
    var angle = deg2rad(randi() % 360)
    point = position + point.rotated(angle) * goal_radius
    goal = nav.get_closest_point(point)
    
func die():
    emit_signal('die')
    queue_free()