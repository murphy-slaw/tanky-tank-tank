extends "res://BaseTank.gd"

onready var camera = get_node("Camera2D")
func _ready():
    can_shoot = true
    if nav_path:
        nav = get_node(nav_path)
    $ShotTimer.start()
    
func safe_move(move):
    lv += move

func shoot(target):
    $LaunchSound.play()
    .shoot(target)

func reached_goal(pos):
    return (global_position - pos).length() < 5
    emit('chose_goal', self, null)
    
func _on_Visibility_body_entered(body):
    if body != self and body.is_in_group(enemy_group):
        targets[weakref(body)] = 1
        
func _on_Visibility_body_exited(body):
    for target_ref in targets.keys():
        var target = target_ref.get_ref()
        if (target and target == body) or not target:
            targets.erase(target_ref)