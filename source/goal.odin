package game


GoalType :: enum {
	TierOne,
	TierTwo,
}

Goal :: struct {
	input_map:   map[ItemType]i32,
	reward_text: string,
}

get_goal :: proc(goal_type: GoalType) -> Goal {
	switch goal_type {
	case .TierOne:
		input_map := make(map[ItemType]i32)
		input_map[.Concrete] = 50
		return {input_map = input_map, reward_text = "youcomplete tier. unlock blahblahblah"}
	case .TierTwo:
		input_map := make(map[ItemType]i32)
		input_map[.Concrete] = 250
		return {input_map = input_map, reward_text = "youcomplete tier. unlock blahblahblah"}
	}
	return {}
}

get_goal_from_memory :: proc(goal_type: GoalType) -> Goal {
	switch goal_type {
	case .TierOne:
		return g.all_goals.tier_one
	case .TierTwo:
		return g.all_goals.tier_two
	}
	return {}
}
