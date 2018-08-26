extends Node2D

const Mob = preload("res://EnemyTank.tscn")
export var max_mobs = 10
export var spawn_enabled = true
onready var map = find_node('Road')
var mob_count = 0
var mob_goals = {}

func _ready():
    randomize()
    spawn_mob()
    
    
func _input(event):
    if event is InputEventMouseButton:
        $Spawn.position = event.position
        var map_pos = map.world_to_map(event.position)
        print(map.map_to_world(map_pos))
        update()


func _on_SpawnTimer_timeout():
    spawn_mob()
    
func spawn_mob():
    if not spawn_enabled or  mob_count >= max_mobs:
        return
    var mob = Mob.instance()
    mob.nav_path = $Navigation2D.get_path()
    mob.map = map
    mob.connect("chose_goal", self , '_on_mob_goal')
    add_child(mob)
    mob_count += 1
    mob.connect('die', self, '_on_mob_died')
    mob.set_owner(self)
    mob.position = $Spawn.position

    
func _draw():
    for point in mob_goals.values():
        print(point)
        draw_circle(point, 5, Color(1.0, 0.0, 0.0))

func _on_mob_died(mob):
    mob_count -=1
    mob_goals.erase(mob)
    update()
    
    
func _on_mob_goal(mob, point):
    print("oink: %s" % mob)
    mob_goals[mob] = point
    update()