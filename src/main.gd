extends Node2D

const Mob = preload("res://EnemyTank.tscn")
var mob_count = 0
export var max_mobs = 10

func _ready():
    randomize()
    spawn_mob()
    
    
func _input(event):
    if event is InputEventMouseButton:
        $Spawn.position = event.position
        update()


func _on_SpawnTimer_timeout():
    spawn_mob()
    
func spawn_mob():
    if mob_count < max_mobs:
        var mob = Mob.instance()
        mob.nav_path = $Navigation2D.get_path()
        add_child(mob)
        mob_count += 1
        mob.connect('die', self, '_on_mob_died')
        mob.set_owner(self)
        mob.position = $Spawn.position


func _on_mob_died():
    mob_count -=1