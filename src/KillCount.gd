extends Label

func _ready():
    pass


func _on_Game_mob_killed(count):
    text = str(count)