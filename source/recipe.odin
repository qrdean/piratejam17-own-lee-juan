package game

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

// ItemType :: enum {
// 	None,
// 	Gnome,
// 	Grass,
// 	Concrete,
// }

ItemType :: enum {
	None,
	CanOpened,
	CanFlat,
	CanStrips,
	CanNails,
	CanRing,
	CanReinforced,
	CanRotator,
	CanMotor,
	CanPropeller,
	CanHull,
	CanHelm,
	CanRutter,
	Boat,
}

Item :: struct {
	position_offset: rl.Vector3,
	ItemType:        ItemType,
	color:           rl.Color,
}

item_type_to_string :: proc(item_type: ItemType) -> string {
	switch item_type {
	case .None:
		return "None"
	case .CanOpened:
		return "Opened"
	case .CanFlat:
		return "Flat"
	case .CanStrips:
		return "Strips"
	case .CanNails:
		return "Nails"
	case .CanRing:
		return "Ring"
	case .CanReinforced:
		return "Reinforced"
	case .CanRotator:
		return "Rotator"
	case .CanMotor:
		return "Motor"
	case .CanPropeller:
		return "Propellor"
	case .CanHull:
		return "Hull"
	case .CanHelm:
		return "Helm"
	case .CanRutter:
		return "Rutter"
	case .Boat:
		return "Boat"
	}
	return ""
}

// RecipeType :: enum {
// 	None,
// 	Grass,
// 	Concrete,
// 	Gnome,
// }

RecipeType :: enum {
	None,
	CanOpened,
	CanFlat,
	CanStrips,
	CanNails,
	CanRing,
	CanReinforced,
	CanRotator,
	CanMotor,
	CanPropeller,
	CanHull,
	CanHelm,
	CanRutter,
	Boat,
}

Recipe :: struct {
	input_map:      map[ItemType]i32,
	output_map:     map[ItemType]i32,
	construct_time: f32,
}

get_recipe :: proc(recipe_type: RecipeType) -> Recipe {
	switch recipe_type {
	case .None:
		return {}
	case .CanOpened:
		input := make(map[ItemType]i32)
		output := make(map[ItemType]i32)
		input[.None] = 0
		output[.CanOpened] = 1
		construct_time: f32 = seconds_to_minute(2.)
		return {input_map = input, output_map = output, construct_time = construct_time}
	case .CanFlat:
		input := make(map[ItemType]i32)
		output := make(map[ItemType]i32)
		input[.CanOpened] = 3
		output[.CanFlat] = 2
		construct_time: f32 = seconds_to_minute(3.)
		return {input_map = input, output_map = output, construct_time = construct_time}
	case .CanStrips:
		input := make(map[ItemType]i32)
		output := make(map[ItemType]i32)
		input[.CanOpened] = 1
		output[.CanStrips] = 1
		construct_time: f32 = seconds_to_minute(2.)
		return {input_map = input, output_map = output, construct_time = construct_time}
	case .CanNails:
		input := make(map[ItemType]i32)
		output := make(map[ItemType]i32)
		input[.CanStrips] = 1
		output[.CanNails] = 4
		construct_time: f32 = seconds_to_minute(3.)
		return {input_map = input, output_map = output, construct_time = construct_time}
	case .CanRing:
		input := make(map[ItemType]i32)
		output := make(map[ItemType]i32)
		input[.CanOpened] = 1
		output[.CanRing] = 1
		construct_time: f32 = seconds_to_minute(3.)
		return {input_map = input, output_map = output, construct_time = construct_time}
	case .CanReinforced:
		input := make(map[ItemType]i32)
		output := make(map[ItemType]i32)
		input[.CanNails] = 12
		input[.CanFlat] = 6
		output[.CanReinforced] = 1
		construct_time: f32 = seconds_to_minute(6.)
		return {input_map = input, output_map = output, construct_time = construct_time}
	case .CanRotator:
		input := make(map[ItemType]i32)
		output := make(map[ItemType]i32)
		input[.CanNails] = 25
		input[.CanStrips] = 5
		output[.CanRotator] = 1
		construct_time: f32 = seconds_to_minute(5.)
		return {input_map = input, output_map = output, construct_time = construct_time}
	case .CanMotor:
		input := make(map[ItemType]i32)
		output := make(map[ItemType]i32)
		input[.CanRotator] = 1
		input[.CanReinforced] = 2
		output[.CanMotor] = 1
		construct_time: f32 = seconds_to_minute(30.)
		return {input_map = input, output_map = output, construct_time = construct_time}
	case .CanPropeller:
		input := make(map[ItemType]i32)
		output := make(map[ItemType]i32)
		input[.CanReinforced] = 3
		input[.CanRotator] = 2
		output[.CanPropeller] = 1
		construct_time: f32 = seconds_to_minute(60.)
		return {input_map = input, output_map = output, construct_time = construct_time}
	case .CanHull:
		input := make(map[ItemType]i32)
		output := make(map[ItemType]i32)
		input[.CanReinforced] = 50
		input[.CanNails] = 250
		output[.CanHull] = 1
		construct_time: f32 = seconds_to_minute(60.)
		return {input_map = input, output_map = output, construct_time = construct_time}
	case .CanHelm:
		input := make(map[ItemType]i32)
		output := make(map[ItemType]i32)
		input[.CanRotator] = 1
		input[.CanReinforced] = 5
		input[.CanRing] = 120
		output[.CanHelm] = 1
		construct_time: f32 = seconds_to_minute(45.)
		return {input_map = input, output_map = output, construct_time = construct_time}
	case .CanRutter:
		input := make(map[ItemType]i32)
		output := make(map[ItemType]i32)
		input[.CanReinforced] = 20
		input[.CanRotator] = 2
		input[.CanRing] = 10
		output[.CanRutter] = 1
		construct_time: f32 = seconds_to_minute(45.)
		return {input_map = input, output_map = output, construct_time = construct_time}
	case .Boat:
		input := make(map[ItemType]i32)
		output := make(map[ItemType]i32)
		input[.CanMotor] = 5
		input[.CanPropeller] = 2
		input[.CanHull] = 1
		input[.CanHelm] = 1
		input[.CanRutter] = 2
		output[.Boat] = 1
		construct_time: f32 = seconds_to_minute(90.)
		return {input_map = input, output_map = output, construct_time = construct_time}
	}
	return {}
}

get_recipe_from_memory :: proc(recipe_type: RecipeType) -> Recipe {
	switch recipe_type {
	case .None:
		return {}
	case .CanOpened:
		return g.all_recipes.can_opened
	case .CanFlat:
		return g.all_recipes.can_flat
	case .CanStrips:
		return g.all_recipes.can_strip
	case .CanNails:
		return g.all_recipes.can_nails
	case .CanRing:
		return g.all_recipes.can_ring
	case .CanReinforced:
		return g.all_recipes.can_reinforced
	case .CanRotator:
		return g.all_recipes.can_rotator
	case .CanMotor:
		return g.all_recipes.can_motor
	case .CanPropeller:
		return g.all_recipes.can_propeller
	case .CanHull:
		return g.all_recipes.can_hull
	case .CanHelm:
		return g.all_recipes.can_helm
	case .CanRutter:
		return g.all_recipes.can_rutter
	case .Boat:
		return g.all_recipes.can_boat
	}
	return {}
}

get_recipe_name :: proc(recipe_type: RecipeType) -> string {
	switch recipe_type {
	case .None:
		return "Unselected"
	case .CanOpened:
		return "Open Can"
	case .CanFlat:
		return "Flat Can"
	case .CanStrips:
		return "Strips"
	case .CanNails:
		return "Nails"
	case .CanRing:
		return "Ring"
	case .CanReinforced:
		return "Reinforced Can"
	case .CanRotator:
		return "Rotator Can"
	case .CanMotor:
		return "Motor"
	case .CanPropeller:
		return "Propeller"
	case .CanHull:
		return "Hull"
	case .CanHelm:
		return "Helm"
	case .CanRutter:
		return "Rudder"
	case .Boat:
		return "Boat"
	}
	return ""
}

overwrite_recipe_time :: proc(recipe: ^Recipe, seconds: f32) {
	recipe.construct_time = seconds_to_minute(seconds)
}

clean_up_recipe :: proc(recipe: Recipe) {
	delete(recipe.input_map)
	delete(recipe.output_map)
}

check_type_for_recipe :: proc(item_type: ItemType, recipe: Recipe) -> bool {
	for key in recipe.input_map {
		if key == item_type {
			return true
		}
	}
	return false
}

check_item_input_to_recipe :: proc(item_map: map[ItemType]i32, recipe: Recipe) -> bool {
	for key in item_map {
		if recipe.input_map[key] > item_map[key] {
			return false
		}
	}
	return true
}

get_item_map_text :: proc(item_map: map[ItemType]i32) -> string {
	b := strings.builder_make(context.temp_allocator)
	for key in item_map {
		fmt.sbprintf(&b, "%s %d ", item_type_to_string(key), item_map[key])
	}
	return strings.to_string(b)
}

get_item_map_with_two_maps_text :: proc(
	item_map: map[ItemType]i32,
	item_map_2: map[ItemType]i32,
) -> string {
	b := strings.builder_make(context.temp_allocator)
	for key in item_map_2 {
		fmt.println(item_map)
		fmt.println(item_map_2)
		fmt.sbprintf(&b, "%s: %d/%d ", item_type_to_string(key), item_map[key], item_map_2[key])
	}
	return strings.to_string(b)
}

get_item_map_text_new_line :: proc(item_map: map[ItemType]i32) -> string {
	b := strings.builder_make(context.temp_allocator)
	for key in item_map {
		if key != .None {
			fmt.sbprintf(&b, "%s %d\n", item_type_to_string(key), item_map[key])
		}
	}
	return strings.to_string(b)
}
