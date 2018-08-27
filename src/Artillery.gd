extends Node


static func calc_angle_diff(seeker, target_pos):
    var goal_angle = (target_pos - seeker.position).angle()
    var angle_diff = goal_angle - seeker.rotation
    if (angle_diff > PI): 
        angle_diff -= PI * 2
    elif (angle_diff < -PI):
         angle_diff += PI * 2
    return angle_diff