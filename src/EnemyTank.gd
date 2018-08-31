extends "res://BaseTank.gd"
var dead = false
func _ready():
    Bullet = preload("res://Bullet.tscn")
    enemy_group = "Player"
    laser_color = Color(1.0, 0, 0)
    if nav_path:
        nav = get_node(nav_path)
        choose_random_goal()
    $ShotTimer.start()

func shoot(target):
    $ShotSound.play()
    .shoot(target)

func _physics_process(delta):
    if goals.empty():
        choose_random_goal()

func handle_collisions():
    if get_slide_count():
        die()

func die(killer=null):
    if not dead:
        dead = true
#        print ('enemy tank %s died' % self.name)
        .die(killer)
    else:
        print ("enemy tank %s died, but already dead!" % self.name)

func choose_random_goal():
    var zone = get_parent().get_depopulated_zone()
    if not zone:
        return
    var point = Vector2( randi() % int(zone.size.x), randi() % int(zone.size.y))
    point += zone.position
    var goal = nav.get_closest_point(point)
    if map:
        var tile = map.world_to_map(goal)
        goal = map.map_to_world(tile)
        goal += map.cell_size * 0.5
    goals.push_front(goal)
    path = null
    
func _on_Visibility_body_entered(body):
    if body != self and body.is_in_group(enemy_group):
        targets[weakref(body)] = 1
        goals.push_front(nav.get_closest_point(body.position))
        update_nav()
    else:
        pass
#        choose_random_goal()

func _on_Visibility_body_exited(body):
    for target_ref in targets.keys():
        var target = target_ref.get_ref()
        if (target and target == body) or not target:
            targets.erase(target_ref)