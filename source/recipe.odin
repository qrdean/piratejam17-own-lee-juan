package game

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

ItemType :: enum {
	None,
	Gnome,
	Grass,
	Concrete,
}

Item :: struct {
	position_offset: rl.Vector3,
	ItemType:        ItemType,
	color:           rl.Color,
}

item_type_to_string :: proc(item_type: ItemType) -> string {
	switch item_type {
	case .None:
		return ""
	case .Gnome:
		return "Gnome"
	case .Grass:
		return "Grass"
	case .Concrete:
		return "Concrete"
	}
	return ""
}

RecipeType :: enum {
	None,
	Grass,
	Concrete,
	Gnome,
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
	case .Grass:
		a := make(map[ItemType]i32)
		a[.Gnome] = 1
		b := make(map[ItemType]i32)
		b[.Grass] = 1
		construct_time := number_per_minute_to_frame_time(20.)
		return {input_map = a, output_map = b, construct_time = construct_time}
	case .Concrete:
		a := make(map[ItemType]i32)
		a[.Gnome] = 1
		a[.Grass] = 1
		b := make(map[ItemType]i32)
		b[.Concrete] = 1
		construct_time := number_per_minute_to_frame_time(2.)
		return {input_map = a, output_map = b, construct_time = construct_time}
	case .Gnome:
		a := make(map[ItemType]i32)
		b := make(map[ItemType]i32)
		a[.None] = 0
		b[.Gnome] = 1
		construct_time := number_per_minute_to_frame_time(60.)
		return {input_map = a, output_map = b, construct_time = construct_time}
	}
	return {}
}

get_recipe_from_memory :: proc(recipe_type: RecipeType) -> Recipe {
	switch recipe_type {
	case .None:
		return {}
	case .Grass:
		return g.all_recipes.grass_recipe
	case .Concrete:
		return g.all_recipes.concrete_recipe
	case .Gnome:
		return g.all_recipes.gnome_recipe
	}
	return {}
}

overwrite_recipe_time :: proc(recipe: ^Recipe, new_per_minute: f32) {
	recipe.construct_time = number_per_minute_to_frame_time(new_per_minute)
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
