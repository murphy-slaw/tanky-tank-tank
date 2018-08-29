extends Particles2D

func _ready():
    pass

func start_countdown():
    $DissipateTimer.start()

func _on_DissipateTimer_timeout():
    queue_free()