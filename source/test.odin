package game

import "core:fmt"

// test_item_check :: proc() {
// 	grass_recipe := get_recipe(.Grass)
// 	concrete_recipe := get_recipe(.Concrete)
// 	is_in := check_type_for_recipe(.Gnome, grass_recipe)
// 	fmt.printf("gnome is in grass_recipe: %v", is_in)
// 	is_in = check_type_for_recipe(.Concrete, grass_recipe)
// 	fmt.printf("concrete is in grass_recipe: %v", is_in)
// 	is_in = check_type_for_recipe(.Grass, grass_recipe)
// 	fmt.printf("grass is in grass_recipe: %v", is_in)
// 	is_in = check_type_for_recipe(.Gnome, concrete_recipe)
// 	fmt.printf("gnome is in concrete_recipe: %v", is_in)
// 	is_in = check_type_for_recipe(.Grass, concrete_recipe)
// 	fmt.printf("grass is in concrete_recipe: %v", is_in)
// 	is_in = check_type_for_recipe(.Concrete, concrete_recipe)
// 	fmt.printf("conrete is in concrete_recipe: %v", is_in)
// }

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
