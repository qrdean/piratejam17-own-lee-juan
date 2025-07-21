package game

import "core:fmt"

test_constructor_scenario_1 :: proc() {
	recipe := get_recipe(.Grass)
	defer delete(recipe.input_map)
	defer delete(recipe.output_map)
	fmt.println(recipe)
	constructor := Constructor {
		recipe_type = .Grass,
	}
	defer delete(constructor.current_inputs)
	defer delete(constructor.current_outputs)
	constructor.current_inputs[.Gnome] = 3
	constructor.current_outputs[.Grass] = 0
	fmt.println(constructor.current_outputs)
	fmt.println(constructor.current_inputs)
	transform_constructor_item(&constructor)
	fmt.println(constructor.current_inputs)
	fmt.println(constructor.current_outputs)
}

test_constructor_scenario_2 :: proc() {
	recipe := get_recipe(.Concrete)
	defer delete(recipe.input_map)
	defer delete(recipe.output_map)
	fmt.println(recipe)
	constructor := Constructor {
		recipe_type = .Concrete,
	}
	defer delete(constructor.current_inputs)
	defer delete(constructor.current_outputs)
	constructor.current_inputs[.Gnome] = 3
	constructor.current_inputs[.Grass] = 3
	constructor.current_outputs[.Concrete] = 0
	fmt.println(constructor.current_outputs)
	fmt.println(constructor.current_inputs)
	transform_constructor_item(&constructor)
	fmt.println(constructor.current_inputs)
	fmt.println(constructor.current_outputs)
}

test_constructor_scenario_3 :: proc() {
	recipe := get_recipe(.Concrete)
	defer delete(recipe.input_map)
	defer delete(recipe.output_map)
	fmt.println(recipe)
	constructor := Constructor {
		recipe_type = .Concrete,
	}
	defer delete(constructor.current_inputs)
	defer delete(constructor.current_outputs)
	constructor.current_inputs[.Gnome] = 3
	constructor.current_inputs[.Grass] = 0
	constructor.current_outputs[.Concrete] = 0
	fmt.println(constructor.current_outputs)
	fmt.println(constructor.current_inputs)
	transform_constructor_item(&constructor)
	fmt.println(constructor.current_inputs)
	fmt.println(constructor.current_outputs)
}

test_item_check :: proc() {
	grass_recipe := get_recipe(.Grass)
	concrete_recipe := get_recipe(.Concrete)
	is_in := check_type_for_recipe(.Gnome, grass_recipe)
	fmt.printf("gnome is in grass_recipe: %v", is_in)
	is_in = check_type_for_recipe(.Concrete, grass_recipe)
	fmt.printf("concrete is in grass_recipe: %v", is_in)
	is_in = check_type_for_recipe(.Grass, grass_recipe)
	fmt.printf("grass is in grass_recipe: %v", is_in)
	is_in = check_type_for_recipe(.Gnome, concrete_recipe)
	fmt.printf("gnome is in concrete_recipe: %v", is_in)
	is_in = check_type_for_recipe(.Grass, concrete_recipe)
	fmt.printf("grass is in concrete_recipe: %v", is_in)
	is_in = check_type_for_recipe(.Concrete, concrete_recipe)
	fmt.printf("conrete is in concrete_recipe: %v", is_in)
}

test_dynamic_array_removal :: proc() {
	new_array: [dynamic]int
	defer delete(new_array)
	for i in 0 ..< 10 {
		append(&new_array, i)
	}
	fmt.println(new_array)
	fmt.println(new_array[len(new_array) - 1])
	unordered_remove(&new_array, 5)
	fmt.println(new_array)
}
