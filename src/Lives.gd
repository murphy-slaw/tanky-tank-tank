extends Label

func _ready():
    pass

func _on_Game_life_count_changed(life_count):
    text = str(life_count)