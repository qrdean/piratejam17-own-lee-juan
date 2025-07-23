package game


GoalType :: enum {
	TierOne,
	TierTwo,
	Done,
}

Goal :: struct {
	input_map:   map[ItemType]i32,
	reward_text: string,
}

get_goal :: proc(goal_type: GoalType) -> Goal {
	switch goal_type {
	case .TierOne:
		input_map := make(map[ItemType]i32)
		input_map[.CanFlat] = 50
		return {input_map = input_map, reward_text = "youcomplete tier. unlock blahblahblah"}
	case .TierTwo:
		input_map := make(map[ItemType]i32)
		input_map[.CanStrips] = 50
		return {input_map = input_map, reward_text = "youcomplete tier. unlock blahblahblah"}
	case .Done:
		return {}
	}
	return {}
}

get_goal_from_memory :: proc(goal_type: GoalType) -> Goal {
	switch goal_type {
	case .TierOne:
		return g.all_goals.tier_one
	case .TierTwo:
		return g.all_goals.tier_two
	case .Done:
		return {}
	}
	return {}
}

get_next_goal :: proc(goal_type: GoalType) -> GoalType {
	switch goal_type {
	case .TierOne:
		return .TierTwo
	case .TierTwo:
		return .Done
	case .Done:
		return .Done
	}
	return {}
}

calculate_goals :: proc(constructor: Constructor, goal_type: GoalType) -> bool {
	goal := get_goal_from_memory(goal_type)
	for key in goal.input_map {
		if constructor.current_inputs[key] < goal.input_map[key] {
			return false
		}
	}
	return true
}

check_type_for_goal :: proc(item_type: ItemType, goal: Goal) -> bool {
	for key in goal.input_map {
		if key == item_type {
			return true
		}
	}
	return false
}

check_item_input_to_goal :: proc(item_map: map[ItemType]i32, goal: Goal) -> bool {
	for key in item_map {
		if goal.input_map[key] > item_map[key] {
			return false
		}
	}
	return true
}
