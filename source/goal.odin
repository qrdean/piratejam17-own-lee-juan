package game


GoalType :: enum {
	TierOne,
	TierTwo,
	TierThree,
	TierFour,
	TierFive,
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
		return {input_map = input_map, reward_text = "Unlock: Strips"}
	case .TierTwo:
		input_map := make(map[ItemType]i32)
		input_map[.CanStrips] = 50
		return {
			input_map = input_map,
			reward_text = "Unlock: Nails, Rings.\nUpgrade: Miner Speed Increase",
		}
	case .TierThree:
		input_map := make(map[ItemType]i32)
		input_map[.CanNails] = 120
		input_map[.CanRing] = 100
		return {input_map = input_map, reward_text = "Unlock: Constructor, Port"}
	case .TierFour:
		input_map := make(map[ItemType]i32)
		input_map[.CanReinforced] = 50
		input_map[.CanRotator] = 25
		return {input_map = input_map, reward_text = "Unlock: Assembler"}
	case .TierFive:
		input_map := make(map[ItemType]i32)
		input_map[.CanMotor] = 1
		input_map[.CanPropeller] = 1
		input_map[.CanHull] = 1
		input_map[.CanRutter] = 1
		input_map[.CanHelm] = 1
		return {input_map = input_map, reward_text = "You Escaped with Your Cats!"}
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
	case .TierThree:
		return g.all_goals.tier_three
	case .TierFour:
		return g.all_goals.tier_four
	case .TierFive:
		return g.all_goals.tier_five
	case .Done:
		return {}
	}
	return {}
}

get_goal_and_message :: proc(goal_type: GoalType) -> (string, string) {
	switch goal_type {
	case .TierOne:
	case .TierTwo:
		return "TIER ONE COMPLETE", g.all_goals.tier_one.reward_text
	case .TierThree:
		return "TIER TWO COMPLETE", g.all_goals.tier_two.reward_text
	case .TierFour:
		return "TIER THREE COMPLETE", g.all_goals.tier_three.reward_text
	case .TierFive:
		return "TIER FOUR COMPLETE", g.all_goals.tier_four.reward_text
	case .Done:
		return "TIER FIVE COMPLETE", g.all_goals.tier_five.reward_text
	}
	return "", ""
}

get_next_goal :: proc(goal_type: GoalType) -> GoalType {
	switch goal_type {
	case .TierOne:
		return .TierTwo
	case .TierTwo:
		return .TierThree
	case .TierThree:
		return .TierFour
	case .TierFour:
		return .TierFive
	case .TierFive:
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
