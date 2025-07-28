package game

Constructor :: struct {
	recipe_type:            RecipeType,
	current_inputs:         map[ItemType]i32,
	current_outputs:        map[ItemType]i32,
	current_construct_time: f32,
}

remove_qty_from_input :: proc(item_map: ^map[ItemType]i32, recipe: Recipe) {
	for key in item_map {
		item_map[key] = item_map[key] - recipe.input_map[key]
		if item_map[key] < 0 {
			item_map[key] = 0
		}
	}
}

add_qty_to_input_by_type :: proc(constructor: ^Constructor, key: ItemType, qty: i32) -> bool {
	recipe := get_recipe_from_memory(constructor.recipe_type)
	if check_single_item_input_to_recipe(key, recipe) {
		constructor.current_inputs[key] += qty
		return true
	}
	return false
}

add_qty_to_output_by_type :: proc(constructor: ^Constructor, key: ItemType, qty: i32) -> bool {
	recipe := get_recipe_from_memory(constructor.recipe_type)
	if check_single_item_output_to_recipe(key, recipe) {
		constructor.current_outputs[key] += qty
		return true
	}
	return false
}

remove_qty_from_output :: proc(constructor: ^Constructor, key: ItemType, qty: i32) -> i32 {
	if constructor.current_outputs[key] <= 0 {
		return 0
	}
	if constructor.current_outputs[key] < qty {
		amount := constructor.current_outputs[key]
		constructor.current_outputs[key] = 0
		return amount
	}
	constructor.current_outputs[key] -= qty
	return qty
}

remove_qty_from_input_item_type :: proc(
	constructor: ^Constructor,
	key: ItemType,
	qty: i32,
) -> i32 {
	if constructor.current_inputs[key] <= 0 {
		return 0
	}
	if constructor.current_inputs[key] < qty {
		amount := constructor.current_inputs[key]
		constructor.current_inputs[key] = 0
		return amount
	}
	constructor.current_inputs[key] -= qty
	return qty
}

add_qty_to_output :: proc(constructor: ^Constructor, recipe: Recipe) {
	for key in recipe.output_map {
		constructor.current_outputs[key] += recipe.output_map[key]
	}
}

clean_up_constructor :: proc(constructor: ^Constructor) {
	delete(constructor.current_inputs)
	delete(constructor.current_outputs)
}

check_construction_time :: proc(constructor: Constructor) -> bool {
	return(
		constructor.current_construct_time >
		get_recipe_from_memory(constructor.recipe_type).construct_time \
	)
}

handle_construction_time :: proc(constructor: ^Constructor, dt: f32) {
	constructor.current_construct_time += dt
}

transform_constructor_item :: proc(constructor: ^Constructor, recipe: Recipe) {
	remove_qty_from_input(&constructor.current_inputs, recipe)
	add_qty_to_output(constructor, recipe)
}

// Will move items out of machine into global storage
set_constructor_recipe :: proc(constructor: ^Constructor, recipe_type: RecipeType) {
	for key in constructor.current_inputs {
		g.item_pickup[key] += constructor.current_inputs[key]
	}
	for key in constructor.current_outputs {
		g.item_pickup[key] += constructor.current_outputs[key]
	}
	clear(&constructor.current_inputs)
	clear(&constructor.current_outputs)
	constructor.recipe_type = recipe_type
	recipe := get_recipe_from_memory(recipe_type)
	for key in recipe.input_map {
		constructor.current_inputs[key] = 0
	}
	for key in recipe.output_map {
		constructor.current_outputs[key] = 0
	}
}

get_current_construction_time :: proc(constructor: Constructor) -> f32 {
	if get_recipe_from_memory(constructor.recipe_type).construct_time > 0 {
		return(
			constructor.current_construct_time /
			get_recipe_from_memory(constructor.recipe_type).construct_time \
		)
	} else {
		return 0.
	}
}

clear_all_travelers_from_building :: proc(building_id: int) {
	for i in 0 ..< len(g.travel) {
		if g.travel[i].building_id == building_id {
			if g.travel[i].current_cargo.ItemType != .None {
				g.item_pickup[g.travel[i].current_cargo.ItemType] += 1
				g.travel[i].current_cargo.ItemType = .None
			}
		}
	}
}

delete_factory_from_world :: proc(building_id: int) {
	if len(g.travelPoints) < building_id {
		return
	}
	for key in g.travelPoints[building_id].current_inputs {
		g.item_pickup[key] += g.travelPoints[building_id].current_inputs[key]
	}
	for key in g.travelPoints[building_id].current_outputs {
		g.item_pickup[key] += g.travelPoints[building_id].current_outputs[key]
	}

	// Remove all associated travelers from this building and collect any carrying items
	for i in 0 ..< len(g.travel) {
		workers := g.travelPoints[g.travel[i].building_id].output_workers[g.travel[i].worker_id]
		if (g.travel[i].building_id == building_id) {
			if g.travel[i].current_cargo.ItemType != .None {
				g.item_pickup[g.travel[i].current_cargo.ItemType] += 1
			}
			// unordered_remove(&g.travel, i)
			g.travel[i].active = false
		} else if (g.travel[i].current_target_id == building_id) {
			if g.travel[i].current_cargo.ItemType != .None {
				g.item_pickup[g.travel[i].current_cargo.ItemType] += 1
			}
			g.travel[i].active = false
		} else if (workers.destination_id == building_id) {
			g.travel[i].active = false
		}
	}

	for i in 0 ..< len(g.cargoTravel) {
		workers :=
			g.travelPoints[g.cargoTravel[i].building_id].output_workers[g.cargoTravel[i].worker_id]
		if (g.cargoTravel[i].building_id == building_id) {
			for key in g.cargoTravel[i].current_cargo {
				g.item_pickup[key] += g.cargoTravel[i].current_cargo[key]
			}
			g.cargoTravel[i].active = false
		} else if (g.cargoTravel[i].current_target_id == building_id) {
			for key in g.cargoTravel[i].current_cargo {
				g.item_pickup[key] += g.cargoTravel[i].current_cargo[key]
			}
			g.cargoTravel[i].active = false
		} else if (workers.destination_id == building_id) {
			g.cargoTravel[i].active = false
		}
	}
	g.selected = {}
	clean_up_constructor(&g.travelPoints[building_id])
	g.travelPoints[building_id] = {}
	// Build new array
	new_travel_array: [dynamic]TravelEntity
	for i in 0 ..< len(g.travel) {
		if g.travel[i].active {
			append(&new_travel_array, g.travel[i])
		}
	}
	old_array := g.travel
	g.travel = new_travel_array
	delete(old_array)

	new_travel_cargo_array: [dynamic]CargoTravelEntity
	for i in 0 ..< len(g.cargoTravel) {
		if g.cargoTravel[i].active {
			append(&new_travel_cargo_array, g.cargoTravel[i])
		}
	}
	old_cargo_array := g.cargoTravel
	g.cargoTravel = new_travel_cargo_array
	for &i in old_cargo_array {
		// Clean up the [dynamic] arrays
  	delete(i.current_cargo)
	}
	delete(old_cargo_array)
}
