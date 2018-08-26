extends KinematicBody2D

signal die

const Bullet = preload("res://Missile.tscn")
onready var Artillery = get_node("/root/Artillery")

export (int) var speed = 30
var max_accel = speed * 0.5
var lv = Vector2()

export (NodePath) var nav_path
var nav
export (int) var goal_radius = 1000
var path = []
var goal = null

onready var space_state = get_world_2d().direct_space_state
var can_shoot = false
var targets  = {}
export var draw_lasers = false
var laser_color = Color(1.0, 0, 0)
export var shot_precision = 0.1

func _ready():
    if nav_path:
        nav = get_node(nav_path)
        choose_random_goal()
    $ShotTimer.start()
    
func clean_targets():
    for target_ref in targets.keys():
        if not target_ref.get_ref():
            targets.erase(target_ref)
    if targets:
        $Label.text = str(targets.size())
    else:
        $Label.text = ""
    update()
    
func _draw():
    if not draw_lasers:
        return
    for target_ref in targets.keys():
        var target = target_ref.get_ref()
        if target:
            draw_line(Vector2(), 
                (target.position - position).rotated(-rotation),
                laser_color, 0.25)

func shoot(target):
    if not can_shoot:
        return
    can_shoot = false
    var bullet = Bullet.instance()
    bullet.add_collision_exception_with(self)
    get_parent().add_child(bullet)
    bullet.global_position = $Turret.global_position
    bullet.global_rotation = $Turret.global_rotation 
    bullet.target = weakref(target)
    bullet.owner = get_parent()
    bullet.set_physics_process(true)
    $ShotTimer.start()
    
func aim():
    var target = null
    for target_ref in targets.keys():
        target = target_ref.get_ref()
        var target_pos = shoot_aim_ray(target)
        if target_pos and aim_turret(target_pos) and can_shoot:
            shoot(target)
    update()
                   
func aim_turret(pos):
        var angle_diff = Artillery.calc_angle_diff(self, pos)
        var goal_angle = angle_diff
        $Turret.rotation = lerp($Turret.rotation, goal_angle, 0.1)
        return abs($Turret.rotation - goal_angle) < shot_precision


func shoot_aim_ray(target): 
    var result = space_state.intersect_ray(position, target.position,
                    [self], collision_mask)
    if result and result.collider == target:
        return result.position
        
func _on_ShotTimer_timeout():
    can_shoot = true
    
func update_nav():
    if goal and nav:
        path = nav.get_simple_path(global_position, goal, false)
        
func _physics_process(delta):
    clean_targets()
    if not goal:
        choose_random_goal()
    update_nav()
    if not path.size() > 1:
        return
        
    if not targets:
        $Turret.rotation = lerp($Turret.rotation, 0, 0.1)
          
    var move = path[1] - global_position
    var distance = move.length()
    var target_angle = get_angle_to(path[1])
    if abs(target_angle) > 0.01 and distance > 20 :
        rotation += min(0.025, abs(target_angle)) * sign(target_angle)
    else:
        var direction  = move.normalized()
        
        var vel = lv.length()
        if ((vel < speed and
                direction.dot(Vector2(1,0).rotated(rotation)) > 0) 
                or (lv.length() >= 0.001)):
            move = move.normalized() * min(max_accel, 
                min(speed - vel, pow(distance, 2)))
            if test_move(transform, move):
                choose_random_goal()
            else:
                lv += move
            
    move_and_slide(lv)
    if get_slide_count():
        die()
    lv *= 0.9
    aim()
        
    if (global_position - path[-1]).length() < 10:
        goal = null
            
    
func choose_random_goal():
    if not nav: return
    var point = Vector2(1,0)
    var angle = deg2rad(randi() % 360)
    point = position + point.rotated(angle) * goal_radius
    goal = nav.get_closest_point(point)
    
func die():
    emit_signal('die')
    queue_free()
    
func hit(body):
    die()

func _on_Visibility_body_entered(body):
    if body != self and body.is_in_group('Tanks'):
        targets[weakref(body)] = 1
        if randi() % 4 == 0:
            goal = nav.get_closest_point(body.position)

func _on_Visibility_body_exited(body):
    for target_ref in targets.keys():
        var target = target_ref.get_ref()
        if (target and target == body) or not target:
            targets.erase(target_ref)
