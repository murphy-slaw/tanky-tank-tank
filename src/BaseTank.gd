extends KinematicBody2D

signal die
signal chose_goal


const RIGHT = Vector2(1,0)
var Bullet = preload("res://Missile.tscn")
onready var Artillery = get_node("/root/Artillery")

onready var label = get_node("Floaty/Label")

export var enemy_group = "Player"
export (int) var speed = 30
export var turn_rate =  0.025
var max_accel = speed * 0.5
var lv = Vector2()

export (NodePath) var nav_path
var nav
export (int) var goal_radius = 1000
var map = null
var path = []
var goals = []

onready var space_state = get_world_2d().direct_space_state

var can_shoot = false
var targets  = {}
export var draw_lasers = false
var laser_color = Color(1.0, 0, 0)
export var shot_precision = 0.1
var stalled = false

func _ready():
    if nav_path:
        nav = get_node(nav_path)
    $ShotTimer.start()

func clean_targets():
    for target_ref in targets.keys():
        if not target_ref.get_ref():
            targets.erase(target_ref)
    if targets:
        label.text = str(targets.size())
    else:
        label.text = ""
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
        if target_pos:
             if aim_turret(target_pos) and can_shoot:
                shoot(target)
             break
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
    if goals and nav:
        var goal = goals[0]
        path = nav.get_simple_path(global_position, goal, false)
        if path.size() >= 3:
            path = simplify_path(path)
        emit_signal("chose_goal", self, path)

func simplify_path(path):
    var compact_path = PoolVector2Array()
    var triple = []
    for point in path:
        triple.append(point)
        if triple.size() == 3:
            if are_collinear(triple):
                triple = [triple[0], triple[2]]
            else:
                compact_path.append(triple[0])
                triple = [triple[1], triple[2]]
    compact_path.append_array(triple)
    return compact_path

func are_collinear(points):
    return (points[0].x == points[1].x and points[1].x == points[2].x or
            points[0].y == points[1].y and points[1].y == points[2].y)

func _physics_process(delta):

    clean_targets()

    if path and reached_goal(path[0]):
        path.remove(0)
        emit_signal("chose_goal", self, path)

    if not path:
        update_nav()

    if not targets:
        $Turret.rotation = lerp($Turret.rotation, 0, 0.1)

    move_tank()
    aim()
    if goals and reached_goal(goals[0]):
        goals.pop_front()
        update_nav()

func reached_goal(pos):
    return (global_position - pos).length() < 20

func move_tank():
    if path.size() == 0 or stalled:
        return
    var move = path[0] - global_position
    var target_angle = Artillery.calc_angle_diff(self, path[0])

    if abs(target_angle) > turn_rate:
        rotation += min(turn_rate, abs(target_angle)) * sign(target_angle)
    else:
        rotation += target_angle
        var dist_sq = move.length_squared()
        var direction  = move.normalized()
        var vel = lv.length()
        if vel < speed and is_facing(direction):
            move = move.normalized() * min(max_accel,
                    min(speed - vel, dist_sq))
            safe_move(move)

    move_and_slide(lv)
    handle_collisions()
    lv *= 0.9

func safe_move(move):
    if test_move(transform, move):
        if randi() % 2:
            var safe_point = position + (get_facing() * -100)
            var safe = nav.get_closest_point(safe_point)
            print(safe)
            goals = [safe]
            update_nav()
        stalled = true
        $StallTimer.start()
        lv = Vector2()
    else:
        lv += move

func get_facing():
    return RIGHT.rotated(rotation)

func is_facing(dir):
    return dir.dot(get_facing()) > 0

func handle_collisions():
    pass
    
func die():
    emit_signal('die', self)
    queue_free()

func hit(body):
    die()
    
func _on_Visibility_body_entered(body):
    pass

func _on_Visibility_body_exited(body):
    pass
    
func _on_StallTimer_timeout():
    stalled = false