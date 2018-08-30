extends TileMap

var offset = Vector2()
    
func _ready():
    randomize()
    
    var base_rect = Rect2(0,0,48,48)
    paint_rect(base_rect)
    for rect in mappy([base_rect]):
        print(rect)
        if randi() % 2 == 0:
            continue
        paint_rect(rect)
        yield(get_tree(), 'idle_frame')
        
    
    
func paint_rect(rect):
    for x in range(rect.size.x+1):
        for y in range(rect.size.y+1):
            if (x == 0 or x == rect.size.x or y == 0 or y == rect.size.y):
                set_cell(x + rect.position.x, y + rect.position.y, 0)
                update_bitmask_region()
    
func mappy(squares=[]):
    for square in squares:
        if (square.size.x > 6):
            var half_size = (square.size / 2).floor()
            var offset = square.position
            var sub = []
            for x in range (2):
                for y in range (2):
                    var pos = offset + (half_size * Vector2(x,y))
                    sub.append(Rect2(pos, half_size))
            squares += mappy(sub)
            squares.erase(square)
    return squares
                       
    
