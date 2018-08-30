extends Node2D

const Mob = preload("res://EnemyTank.tscn")
const Player = preload("res://PlayerTank.tscn")
export var max_mobs = 10
export var spawn_enabled = true
export var draw_mob_paths = false
onready var map = find_node('Road')
var player = null
var mob_count = 0
var mob_goals = {}
var player_goal = null
var player_spawn = null
var zones = []
var zone_pops = {}

func _ready():
    randomize()
    spawn_player()
    spawn_mob()
    calc_zones(4)
    
func calc_zones(splits):
    var vrect = get_viewport_rect()
    var split_size = vrect.size / splits

    for x in range(splits):
        for y in range(splits):
            var zone = Rect2(Vector2(x * split_size.x, y * split_size.y), split_size)
            zones.append(zone)
    
func spawn_player():
    print("spawning new player")
    player = Player.instance()
    player.nav = $Navigation2D
    player.map = map
    add_child(player)
    player.connect('chose_goal', self, '_on_player_goal')
    player.connect('die', self, '_on_player_died')
    player.set_owner(self)
    player.position = $PlayerSpawn.position
    
    
func _input(event):
    if event is InputEventMouseButton and has_node('PlayerTank'):
        var pos = $Navigation2D.get_closest_point(event.position)
        var tile = map.world_to_map(pos)
        var goal = map.map_to_world(tile)
        goal += map.cell_size * 0.5
        player.goals = [goal]
        player.update_nav()
        update()
        
func get_depopulated_zone():
    var zone
    if zone_pops.size() < zones.size():
        var candidate_zones = []
        for i in range(zones.size()):
            if not zone_pops.has(i):
                candidate_zones.append(i)
        zone = zones[ candidate_zones[randi() % candidate_zones.size()]]
    return zone
        
func _on_SpawnTimer_timeout():
    spawn_mob()
    
func spawn_mob():
    if not spawn_enabled or  mob_count >= max_mobs:
        return
    var mob = Mob.instance()
    mob.nav_path = $Navigation2D.get_path()
    mob.map = map
    add_child(mob)
    mob_count += 1
    mob.connect('die', self, '_on_mob_died')
    mob.connect("chose_goal", self , '_on_mob_goal')
    mob.set_owner(self)
    mob.position = $Spawn.position
    mob.rotation_degrees = 180
    
func _draw():
    if player_goal:
        paint_goal(player_goal)
        
    if not draw_mob_paths:
        return
    for points in mob_goals.values():
        paint_goal(points)
        
func paint_goal(points):
        if points and points.size() > 1:
            draw_polyline(points, Color(.5, .5, .5, 1.0), 2.0, false)
        for point in points:
            draw_circle(point, 5, Color(.5, .5, .5, 1.0))

func _on_mob_died(mob):
    mob_count -=1
    clear_mob_goal(mob)
    update()
    
func clear_mob_goal(mob):
    if not mob_goals.has(mob):
        return
    var points = mob_goals[mob]
    if not points.size():
        return
    mob_goals.erase(mob)
    for i in range(zones.size()):
      if zones[i].has_point(points[-1]):
        if zone_pops.has(i):
            zone_pops[i] -= 1
            if zone_pops[i] == 0:
                zone_pops.erase(i)
        

func _on_player_died(player):
    print("player died!")
    player = null
    player_goal = null
    for tank in get_tree().get_nodes_in_group('Tanks'):
        tank.goals.push_front($Spawn.position)
        tank.update_nav()
    yield(get_tree().create_timer(3.0), 'timeout')
    spawn_player()
    for tank in get_tree().get_nodes_in_group('Tanks'):
        tank.goals.pop_front()
        tank.choose_random_goal()
        tank.update_nav()
    
    
func _on_mob_goal(mob, point):
    clear_mob_goal(mob)
    mob_goals[mob] = point
    if not point.size():
        return
    for i  in range(zones.size()):
        if zones[i].has_point(point[-1]):
            if zone_pops.has(i):
                zone_pops[i] += 1
            else:
                zone_pops[i] = 1
    update()
    
func _on_player_goal(player, point):
    player_goal = point
    update()