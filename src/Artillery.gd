extends Node


static func calc_angle_diff(shooter, target_pos):
    var goal_angle = (target_pos - shooter.position).angle()
    var angle_diff = goal_angle - shooter.rotation
    if (stepify(angle_diff, 0.01) > stepify(PI, 0.01)): angle_diff -= PI * 2
    if (stepify(angle_diff, 0.01) < stepify(-PI, 0.01)): angle_diff += PI * 2
    return angle_diff