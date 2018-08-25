extends Node2D

const Mob = preload("res://mob.tscn")
var mob_count = 0
export var max_mobs = 10
#onready var map = get_node('Navigation2D/TileMap')

func _ready():
    randomize()
#
#func _process(delta):
#    var used_rect = map.get_used_rect()
#    var x = 1 + randi() % int((used_rect.end.x - 1) / 4)
#    var y = 1 + randi() % int((used_rect.end.y -1 ) / 4)
#    var tile = 0
#    if randi() % 10 == 0:
#        tile = -1
#
#    x *= 4
#    y *= 4
#    map.set_cell(x, y, tile)
#    map.set_cell(x, y+1, tile)
#    map.set_cell(x+1, y, tile)
#    map.set_cell(x+1, y+1, tile)
#
#    map.update_bitmask_region()
#    update()
    
    

func _input(event):
    if event is InputEventMouseButton:
        $Goal.position = event.position
        update()

    
func _draw():
    var line = $Navigation2D.get_simple_path(
        $Spawn.global_position, $Goal.global_position, false)
    if line.size() > 1:
        draw_polyline(line, Color('f00f'))

func _on_SpawnTimer_timeout():
    if mob_count < max_mobs:
        var mob = Mob.instance()
        mob.goal_path = $Goal.get_path()
        mob.nav_path = $Navigation2D.get_path()
        add_child(mob)
        mob_count += 1
        mob.connect('die', self, '_on_mob_died')
        mob.set_owner(self)
        mob.position = $Spawn.position

func _on_mob_died():
    mob_count -=1