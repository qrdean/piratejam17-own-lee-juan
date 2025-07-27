package game

debug_end_goal :: proc() {
	g.turn_in_info.goal_type = .TierFive
}

debug_many_items :: proc() {
	g.item_pickup[.CanFlat] += 1000
	g.item_pickup[.CanStrips] += 1000
	g.item_pickup[.CanNails] += 1000
	g.item_pickup[.CanRing] += 1000
	g.item_pickup[.CanReinforced] += 1000
	g.item_pickup[.CanRotator] += 1000
}


