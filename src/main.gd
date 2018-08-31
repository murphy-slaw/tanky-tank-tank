extends Node2D

onready var tree = get_tree()
func _on_Game_game_ended():
    print("game ovah")
    tree.set_pause(true)
    $Container/GameOverPopup.show()

func _on_Button_pressed():
    tree.reload_current_scene()
    tree.set_pause(false)
