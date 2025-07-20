/*
This file is the starting point of your game.

Some important procedures are:
- game_init_window: Opens the window
- game_init: Sets up the game state
- game_update: Run once per frame
- game_should_close: For stopping your game when close button is pressed
- game_shutdown: Shuts down game and frees memory
- game_shutdown_window: Closes window

The procs above are used regardless if you compile using the `build_release`
script or the `build_hot_reload` script. However, in the hot reload case, the
contents of this file is compiled as part of `build/hot_reload/game.dll` (or
.dylib/.so on mac/linux). In the hot reload cases some other procedures are
also used in order to facilitate the hot reload functionality:

- game_memory: Run just before a hot reload. That way game_hot_reload.exe has a
	pointer to the game's memory that it can hand to the new game DLL.
- game_hot_reloaded: Run after a hot reload so that the `g` global
	variable can be set to whatever pointer it was in the old DLL.

NOTE: When compiled as part of `build_release`, `build_debug` or `build_web`
then this whole package is just treated as a normal Odin package. No DLL is
created.
*/

package game

import "core:fmt"
import "core:math"
import rl "vendor:raylib"
import rlgl "vendor:raylib/rlgl"

PIXEL_WINDOW_HEIGHT :: 360
TILE_SIZE :: 32

shader_version_folder := "version330"

waterHeightY: f32 = 1.
Game_Memory :: struct {
	player_pos:             rl.Vector2,
	player_texture:         rl.Texture,
	some_number:            int,
	run:                    bool,
	camera:                 rl.Camera,
	cubes:                  [dynamic]ThreeDeeEntity,
	travelPoints:           [dynamic]FactoryEntity,
	travel:                 [dynamic]TravelEntity,
	currentRay:             rl.Ray,
	mouseRay:               rl.Ray,
	allResources:           AllResources,
	all_recipes:            AllRecipes,
	waterPos:               rl.Vector3,
	button_event:           Event,
	player_mode:            PlayerMode,
	selected:               SelectedEntity,
	current_collision_info: rl.RayCollision,
	current_placing_info:   Placing_Info,
	current_output_info:    Output_Info,
	current_recipe_info:    RecipeInfo,
	item_pickup:            map[ItemType]i32,
	debug_info:             DebugInfo,
}

g: ^Game_Memory

DebugInfo :: struct {
	distance_info_1:   f32,
	is_distance_close: bool,
}

Placing_Info :: struct {
	modelType:      ModelType,
	collision_info: bool,
}

Output_Info :: struct {
	open:                    bool,
	building_id:             int,
	output_id:               int,
	collision_info:          bool,
	destination_building_id: int,
}

RecipeInfo :: struct {
	open:        bool,
	building_id: int,
	recipe_type: RecipeType,
}

PlayerMode :: enum {
	Editing,
	Viewing,
	Placing,
	Selecting,
}

AllResources :: struct {
	cubeModel:      rl.Model,
	rectangleModel: rl.Model,
	boatModel:      rl.Model,
	waterModel:     rl.Model,
	skyModel:       rl.Model,
	waterShader:    rl.Shader,
	skyShader:      rl.Shader,
	groundQuad:     GroundQuad,
	baseCubeModel:  rl.Model,
	terrainModel:   rl.Model,
	pointModel:     rl.Model,
}

AllRecipes :: struct {
	concrete_recipe: Recipe,
	grass_recipe:    Recipe,
	gnome_recipe:    Recipe,
}

ThreeDeeEntity :: struct {
	bb:              rl.BoundingBox,
	selected:        bool,
	position:        rl.Vector3,
	type:            ModelType,
	color:           rl.Color,
	original_color:  rl.Color,
	highlight_color: rl.Color,
}

FactoryEntity :: struct {
	using ThreeDeeEntity: ThreeDeeEntity,
	using Constructor:    Constructor,
	output_workers:       [9]Worker,
	worker_count:         int,
}

Worker :: struct {
	origin_id:      int,
	destination_id: int,
}

TravelEntityAction :: enum {
	Pickup,
	Dropoff,
}

TravelEntity :: struct {
	using ThreeDeeEntity: ThreeDeeEntity,
	worker_id:            int,
	building_id:          int,
	current_cargo:        Item,
	current_target_id:    int,
	action:               TravelEntityAction,
	// Add an array of path targets for pathfinding
}

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

RecipeType :: enum {
	Grass,
	Concrete,
	Gnome,
}

Recipe :: struct {
	input_map:  map[ItemType]i32,
	output_map: map[ItemType]i32,
}

get_recipe :: proc(recipe_type: RecipeType) -> Recipe {
	switch recipe_type {
	case .Grass:
		a := make(map[ItemType]i32)
		a[.Gnome] = 1
		b := make(map[ItemType]i32)
		b[.Grass] = 1
		return {input_map = a, output_map = b}
	case .Concrete:
		a := make(map[ItemType]i32)
		a[.Gnome] = 1
		a[.Grass] = 1
		b := make(map[ItemType]i32)
		b[.Concrete] = 1
		return {input_map = a, output_map = b}
	case .Gnome:
		a := make(map[ItemType]i32)
		b := make(map[ItemType]i32)
		a[.None] = 0
		b[.Gnome] = 1
		return {input_map = a, output_map = b}
	}
	return {}
}

get_recipe_from_memory :: proc(recipe_type: RecipeType) -> Recipe {
	switch recipe_type {
	case .Grass:
		return g.all_recipes.grass_recipe
	case .Concrete:
		return g.all_recipes.concrete_recipe
	case .Gnome:
		return g.all_recipes.gnome_recipe
	}
	return {}
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

remove_qty_from_input :: proc(item_map: ^map[ItemType]i32, recipe: Recipe) {
	for key in item_map {
		item_map[key] = item_map[key] - recipe.input_map[key]
		if item_map[key] < 0 {
			item_map[key] = 0
		}
	}
}

add_qty_to_output :: proc(constructor: ^Constructor, recipe: Recipe) {
	for key in recipe.output_map {
		constructor.current_outputs[key] += recipe.output_map[key]
	}
}

Constructor :: struct {
	recipe_type:     RecipeType,
	current_inputs:  map[ItemType]i32,
	current_outputs: map[ItemType]i32,
}

clean_up_constructor :: proc(constructor: ^Constructor) {
	delete(constructor.current_inputs)
	delete(constructor.current_outputs)
}

transform_constructor_item :: proc(constructor: ^Constructor) {
	recipe := get_recipe_from_memory(constructor.recipe_type)
	if check_item_input_to_recipe(constructor.current_inputs, recipe) {
		remove_qty_from_input(&constructor.current_inputs, recipe)
		add_qty_to_output(constructor, recipe)
	}
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

GroundQuad :: struct {
	g0: rl.Vector3,
	g1: rl.Vector3,
	g2: rl.Vector3,
	g3: rl.Vector3,
}

ModelType :: enum {
	Cube,
	Rectangle,
	Point,
	Boat,
}

get_model :: proc(stuff: ModelType) -> rl.Model {
	switch stuff {
	case .Cube:
		return g.allResources.cubeModel
	case .Rectangle:
		return g.allResources.rectangleModel
	case .Boat:
		return g.allResources.boatModel
	case .Point:
		return g.allResources.pointModel
	}
	return g.allResources.cubeModel
}

get_model_from_item :: proc(item_type: ItemType) -> rl.Model {
	#partial switch item_type {
	case .Gnome:
		return g.allResources.cubeModel
	case .Grass:
		return g.allResources.cubeModel
	}
	return g.allResources.cubeModel
}

type_to_string :: proc(modelType: ModelType) -> string {
	switch modelType {
	case ModelType.Cube:
		return "Cube"
	case ModelType.Rectangle:
		return "Rectangle"
	case ModelType.Boat:
		return "Boat"
	case .Point:
		return "Point"
	}
	return "undefined"
}

game_camera :: proc() -> rl.Camera2D {
	w := f32(rl.GetScreenWidth())
	h := f32(rl.GetScreenHeight())

	return {zoom = h / PIXEL_WINDOW_HEIGHT, target = g.player_pos, offset = {w / 2, h / 2}}
}

three_dee_game_camera :: proc() -> rl.Camera3D {
	return {
		position = rl.Vector3(100.),
		target = rl.Vector3{0., 0., 0.},
		up = rl.Vector3{0., 1., 0.},
		fovy = 45.,
		projection = rl.CameraProjection.PERSPECTIVE,
	}
}

ui_camera :: proc() -> rl.Camera2D {
	return {zoom = f32(rl.GetScreenHeight()) / PIXEL_WINDOW_HEIGHT}
}

get_new_camera :: proc() -> rl.Camera3D {
	camera := rl.Camera{}
	camera.position = rl.Vector3{0., 5., 0.} // Camera position
	camera.target = rl.Vector3{5.0, 0.0, 5.0} // Camera looking at point
	camera.up = rl.Vector3{0.0, 1.0, 0.0} // Camera up vector (rotation towards target)
	camera.fovy = 45.0 // Camera field-of-view Y
	camera.projection = rl.CameraProjection.PERSPECTIVE // Camera projection type

	return camera
}

bounding_box_and_transform :: proc(bb: rl.BoundingBox, position: rl.Vector3) -> rl.BoundingBox {
	return {
		rl.Vector3{bb.min.x + position.x, bb.min.y + position.y, bb.min.z + position.z},
		rl.Vector3{bb.max.x + position.x, bb.max.y + position.y, bb.max.z + position.z},
	}
}

spawn_travel_entity :: proc(building_id: int, position: rl.Vector3, model_type: ModelType) {
	worker_count := g.travelPoints[building_id].worker_count
	if worker_count >= 9 {
		return
	}

	worker := g.travelPoints[building_id].output_workers[worker_count]
	g.travelPoints[building_id].output_workers[worker_count].origin_id = building_id
	travel_entity := TravelEntity {
		type = model_type,
		position = position,
		bb = rl.GetModelBoundingBox(get_model(model_type)),
		color = rl.BLUE,
		current_cargo = Item{ItemType = .Gnome},
		current_target_id = worker.destination_id,
		building_id = building_id,
		worker_id = worker_count,
	}
	append(&g.travel, travel_entity)
	g.travelPoints[building_id].worker_count += 1
}

////////////////////////////// UPDATES ////////////////////////////////

update_shaders :: proc() {
	time := rl.GetFrameTime()
	cameraPosition := g.camera.position
	rl.SetShaderValue(
		g.allResources.waterShader,
		rl.GetShaderLocation(g.allResources.waterShader, "time"),
		&time,
		rl.ShaderUniformDataType.FLOAT,
	)
	camLoc := rl.GetShaderLocation(g.allResources.waterShader, "cameraPos")
	rl.SetShaderValue(
		g.allResources.waterShader,
		camLoc,
		&cameraPosition,
		rl.ShaderUniformDataType.VEC3,
	)

	rl.SetShaderValue(
		g.allResources.skyShader,
		rl.GetShaderLocation(g.allResources.skyShader, "time"),
		&time,
		rl.ShaderUniformDataType.FLOAT,
	)

	isDungeonLoc := rl.GetShaderLocation(g.allResources.skyShader, "isDungeon")
	dungeonFlag := 0
	rl.SetShaderValue(
		g.allResources.skyShader,
		isDungeonLoc,
		&dungeonFlag,
		rl.ShaderUniformDataType.INT,
	)
}

handle_collisions_three_dee :: proc(three_dee: ThreeDeeEntity, id: int) -> rl.RayCollision {
	cubeBB := bounding_box_and_transform(three_dee.bb, three_dee.position)
	rCollision := rl.GetRayCollisionBox(g.currentRay, cubeBB)
	if rCollision.hit {
		g.selected = SelectedEntity {
			id                      = id,
			ThreeDeeEntity          = three_dee,
			selected_entity_actions = get_selected_entity_action_events_cube(
				id,
				three_dee.type,
				three_dee.position,
			),
		}
	}
	return rCollision
}

handle_editor_update :: proc() {
	if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
		g.currentRay = rl.GetScreenToWorldRay(rl.GetMousePosition(), g.camera)
		// for i in 0 ..< len(g.cubes) {
		// 	cube := g.cubes[i]
		// 	rCollision := handle_collisions_three_dee(cube, i)
		// 	g.cubes[i].selected = rCollision.hit
		// }

		for i in 0 ..< len(g.travelPoints) {
			travelPoint := g.travelPoints[i]
			rCollision := handle_collisions_three_dee(travelPoint, i)
			g.travelPoints[i].selected = rCollision.hit
		}

		// for i in 0 ..< len(g.travel) {
		// 	traveler := g.travel[i]
		// 	rCollision := handle_collisions_three_dee(traveler, i)
		// 	g.travel[i].selected = rCollision.hit
		// }
	}

	if rl.IsMouseButtonDown(.RIGHT) {
		rl.UpdateCamera(&g.camera, .FREE)
	}
}

handle_placing_mode :: proc() {
	g.current_placing_info.collision_info = false
	for i in 0 ..< len(g.travelPoints) {
		bb := bounding_box_and_transform(g.travelPoints[i].bb, g.travelPoints[i].position)
		if rl.CheckCollisionBoxes(
			bb,
			bounding_box_and_transform(
				rl.GetModelBoundingBox(get_model(g.current_placing_info.modelType)),
				g.current_collision_info.point,
			),
		) {
			g.current_placing_info.collision_info = true
		}
	}
	if rl.IsMouseButtonPressed(.LEFT) {
		#partial switch g.current_placing_info.modelType {
		case .Cube:
			if g.current_placing_info.collision_info {
				cubeEntity := ThreeDeeEntity {
					position = rl.Vector3 {
						g.current_collision_info.point.x,
						0.5,
						g.current_collision_info.point.z,
					},
					type     = g.current_placing_info.modelType,
					color    = rl.BROWN,
					bb       = rl.GetModelBoundingBox(get_model(g.current_placing_info.modelType)),
				}
				append(&g.cubes, cubeEntity)
			}
		case .Rectangle:
			entity := FactoryEntity {
				position        = rl.Vector3 {
					g.current_collision_info.point.x,
					1.0, //TODO: calculate this based on model height
					g.current_collision_info.point.z,
				},
				type            = g.current_placing_info.modelType,
				color           = rl.ORANGE,
				original_color  = rl.ORANGE,
				highlight_color = rl.GREEN,
				bb              = rl.GetModelBoundingBox(
					get_model(g.current_placing_info.modelType),
				),
			}
			append(&g.travelPoints, entity)
		}
		g.player_mode = .Editing
	}
}

calculate_traveler_cargo :: proc(travel_entity: ^TravelEntity) {
	distanceTo := rl.Vector3Distance(
		travel_entity.position,
		g.travelPoints[travel_entity.current_target_id].position,
	)
	g.debug_info.distance_info_1 = math.abs(distanceTo)
	if math.abs(distanceTo) > 2. {
		next_pos := rl.Vector3MoveTowards(
			travel_entity.position,
			g.travelPoints[travel_entity.current_target_id].position,
			0.11,
		)
		travel_entity.position = next_pos
	} else {
		workers :=
			g.travelPoints[travel_entity.building_id].output_workers[travel_entity.worker_id]
		if travel_entity.current_target_id == workers.destination_id {
			// Handle drop off
			factory := g.travelPoints[travel_entity.current_target_id]
			recipe := get_recipe_from_memory(factory.recipe_type)
			if check_type_for_recipe(travel_entity.current_cargo.ItemType, recipe) {
				current_item_type := travel_entity.current_cargo.ItemType
				g.travelPoints[travel_entity.current_target_id].current_inputs[current_item_type] +=
				1
				travel_entity.current_cargo.ItemType = .None
			}
			// Next target
			travel_entity.current_target_id = workers.origin_id
		} else {
			// Handle pick up
			factory := g.travelPoints[travel_entity.current_target_id]
			for key in factory.current_outputs {
				if g.travelPoints[travel_entity.current_target_id].current_outputs[key] > 0 {
					g.travelPoints[travel_entity.current_target_id].current_outputs[key] -= 1
					travel_entity.current_cargo.ItemType = key
				}
			}
			// Next target
			travel_entity.current_target_id = workers.destination_id
		}
	}
}

handle_selecting_update :: proc() {
	g.current_output_info.collision_info = false
	g.currentRay = rl.GetScreenToWorldRay(rl.GetMousePosition(), g.camera)
	for i in 0 ..< len(g.travelPoints) {
		if i == int(g.current_output_info.building_id) {
			continue
		}
		// bb := bounding_box_and_transform(g.travelPoints[i].bb, g.travelPoints[i].position)
		// if rl.CheckCollisionBoxes(
		// 	bb,
		// 	bounding_box_and_transform(
		// 		rl.GetModelBoundingBox(get_model(.Point)),
		// 		g.current_collision_info.point,
		// 	),
		// ) {
		// 	g.current_output_info.collision_info = true
		// 	g.current_output_info.destination_building_id = i
		// }
		travelPoint := g.travelPoints[i]
		rCollision := handle_collisions_three_dee(travelPoint, i)
		if rCollision.hit {
			g.current_output_info.collision_info = true
			g.current_output_info.destination_building_id = i
		}
	}

	if rl.IsMouseButtonPressed(.LEFT) {
		g.currentRay = rl.GetScreenToWorldRay(rl.GetMousePosition(), g.camera)
		for i in 0 ..< len(g.travelPoints) {
			travelPoint := g.travelPoints[i]
			rCollision := handle_collisions_three_dee(travelPoint, i)
			if rCollision.hit {
				g.player_mode = .Viewing
				g.current_output_info.open = false
				rl.DisableCursor()
				g.travelPoints[i].color = g.travelPoints[i].original_color
				g.travelPoints[g.current_output_info.building_id].output_workers[g.current_output_info.output_id].destination_id =
					i
			}
		}

		// if g.current_output_info.collision_info {
		// 	g.travelPoints[int(g.current_output_info.building_id)].output_workers[g.current_output_info.output_id].destination_id =
		// 		g.current_output_info.destination_building_id
		// 	g.player_mode = .Viewing
		// 	g.current_output_info.open = false
		// }
	}
}

update :: proc() {
	g.some_number += 1
	update_shaders()
	g.mouseRay = rl.GetScreenToWorldRay(rl.GetMousePosition(), g.camera)

	ground_collision_info := rl.GetRayCollisionQuad(
		g.mouseRay,
		g.allResources.groundQuad.g0,
		g.allResources.groundQuad.g1,
		g.allResources.groundQuad.g2,
		g.allResources.groundQuad.g3,
	)

	if (ground_collision_info.hit) {
		g.current_collision_info = ground_collision_info
	}

	switch g.player_mode {
	case .Viewing:
		rl.UpdateCamera(&g.camera, rl.CameraMode.FREE)
	case .Editing:
		handle_editor_update()
	case .Placing:
		handle_placing_mode()
	case .Selecting:
		handle_selecting_update()
	}

	for i in 0 ..< len(g.travel) {
		calculate_traveler_cargo(&g.travel[i])
	}

	for i in 0 ..< len(g.travelPoints) {
		transform_constructor_item(&g.travelPoints[i])
	}

	if rl.IsKeyPressed(.R) {
		if g.player_mode != .Editing {
			g.player_mode = .Editing
		} else {
			g.player_mode = .Viewing
		}

		if g.player_mode == .Viewing {rl.DisableCursor()} else {rl.EnableCursor()}
	}

	if rl.IsKeyPressed(.P) {
		test_constructor_scenario_1()
		test_constructor_scenario_2()
		test_constructor_scenario_3()
		test_item_check()
	}


	wave := math.sin_f32(f32(rl.GetTime()) * 0.9) * 0.9 // slow, subtle vertical motion
	animatedWaterLevel := waterHeightY + wave
	g.waterPos = rl.Vector3{0, animatedWaterLevel, 0}

	if rl.IsKeyPressed(.ESCAPE) {
		g.run = false
	}
}

////////////////////////////// DRAW ////////////////////////////////

draw_debug_info :: proc(debug_info: []cstring) {
	text_spacing: int = PIXEL_WINDOW_HEIGHT - 15
	for info in debug_info {
		rl.DrawText(info, 5, auto_cast text_spacing, 8., rl.BLACK)
		text_spacing -= 11
	}
}

draw_placing_object :: proc() {
	current_collision_point := g.current_collision_info.point
	color := rl.RED
	if g.current_placing_info.collision_info {
		color = rl.GREEN
	}
	rl.DrawModel(get_model(g.current_placing_info.modelType), current_collision_point, 1., color)
}

draw_selecting_point :: proc() {
	current_collision_point := g.current_collision_info.point
	color := rl.RED
	if g.current_output_info.collision_info {
		color = rl.GREEN
	}
	for i in 0 ..< len(g.travelPoints) {
		if g.current_output_info.destination_building_id == i {
			g.travelPoints[i].color = g.travelPoints[i].highlight_color
		} else {
			g.travelPoints[i].color = g.travelPoints[i].original_color
		}
	}
	rl.DrawModel(get_model(.Point), current_collision_point, 1., color)
}

draw_three_dee_entity :: proc(three_dee: ThreeDeeEntity) {
	rl.DrawModel(get_model(three_dee.type), three_dee.position, 1., three_dee.color)
}

draw_editing_layer :: proc(three_dee: ThreeDeeEntity) {
	rl.DrawBoundingBox(bounding_box_and_transform(three_dee.bb, three_dee.position), rl.GREEN)

	zvector := rl.Vector3(0)
	zvector.z = 5.
	yvector := rl.Vector3(0)
	yvector.y = 5.
	xvector := rl.Vector3(0)
	xvector.x = 5.

	rl.DrawLine3D(three_dee.position, three_dee.position + zvector, rl.BLUE)
	rl.DrawLine3D(three_dee.position, three_dee.position + xvector, rl.RED)
	rl.DrawLine3D(three_dee.position, three_dee.position + yvector, rl.YELLOW)
}

draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.SKYBLUE)

	rl.BeginMode3D(g.camera)
	rlgl.DisableBackfaceCulling()
	rlgl.DisableDepthMask()
	rlgl.DisableDepthTest()
	rl.DrawModel(g.allResources.skyModel, g.camera.position, 10000., rl.WHITE)
	rlgl.EnableDepthMask()
	rlgl.EnableDepthTest()
	rlgl.SetBlendMode(i32(rl.BlendMode.ALPHA))
	// rl.DrawModel(g.terrain.model, rl.Vector3(0), 1., rl.WHITE)
	rl.DrawGrid(1000, 1.)
	// rl.DrawModel(g.allResources.waterModel, g.waterPos, 1., rl.WHITE)
	// rl.DrawModel(g.allResources.waterModel, g.waterPos - rl.Vector3{0., 100., 0.}, 1., rl.DARKBLUE)
	// rl.DrawModel(g.allResources.baseCubeModel, rl.Vector3{1., 4., 1.}, 1.0, rl.WHITE)
	if g.player_mode == .Placing {
		draw_placing_object()
	}

	if g.player_mode == .Selecting {
		draw_selecting_point()
	}

	for i in 0 ..< len(g.cubes) {
		draw_three_dee_entity(g.cubes[i])
		if g.player_mode == .Editing && g.cubes[i].selected {
			draw_editing_layer(g.cubes[i])
		}
	}

	for i in 0 ..< len(g.travelPoints) {
		draw_three_dee_entity(g.travelPoints[i])
		if g.player_mode == .Editing && g.travelPoints[i].selected {
			draw_editing_layer(g.travelPoints[i])
		}
	}

	for i in 0 ..< len(g.travel) {
		draw_three_dee_entity(g.travel[i])
		if g.travel[i].current_cargo.ItemType != .None {
			rl.DrawModel(
				get_model_from_item(g.travel[i].current_cargo.ItemType),
				g.travel[i].position + g.travel[i].current_cargo.position_offset,
				1.,
				g.travel[i].current_cargo.color,
			)
		}
	}

	rl.EndBlendMode()
	rl.EndMode3D()

	rl.BeginMode2D(ui_camera())
	travel_point_info: FactoryEntity
	for i in 0 ..< len(g.travelPoints) {
		if (g.travelPoints[i].selected) {
			travel_point_info = g.travelPoints[i]
		}
	}
	debug_info := []cstring {
		fmt.ctprintf("Mouse Pos %v\n", rl.GetMousePosition()),
		fmt.ctprintf("Mouse Collision %v\n", g.current_collision_info.point),
		fmt.ctprintf("Player Mode %v\n", g.player_mode),
		fmt.ctprintf("selected info %v\n", travel_point_info.current_outputs),
		fmt.ctprintf("selected info %v\n", travel_point_info.current_inputs),
		fmt.ctprintf("selected info %v\n", travel_point_info.recipe_type),
	}
	draw_debug_info(debug_info)
	rl.EndMode2D()

	if g.player_mode == .Editing {
		draw_button_ui(g.selected)
		draw_default_button_ui()
	}


	rl.EndDrawing()
}


////////////////////////////// EXPORTS ////////////////////////////////

@(export)
game_update :: proc() {
	handle_button()
	update()
	draw()

	// Everything on tracking allocator is valid until end-of-frame.
	free_all(context.temp_allocator)
}

@(export)
game_init_window :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	rl.InitWindow(1280, 720, "Odin + Raylib + Hot Reload template!")
	rl.SetWindowMonitor(0)
	rl.SetTargetFPS(144)
	rl.SetExitKey(nil)
}

@(export)
game_init :: proc() {
	rl.DisableCursor()
	g = new(Game_Memory)

	// terrainHeightMap := rl.LoadImage("assets/MiddleIsland.png")
	// terrainTexture := rl.LoadTextureFromImage(terrainHeightMap)
	terrainMesh := rl.GenMeshPlane(100., 100., 10., 5.)
	terrainModel := rl.LoadModelFromMesh(terrainMesh)
	// mesh := rl.GenMeshHeightmap(terrainHeightMap, rl.Vector3{10000., 200., 10000.})
	// model.materials[0].maps[rl.MaterialMapIndex.ALBEDO].texture = terrainTexture
	// terrainStruct := ThreeDeeEntity {
	// 	mesh     = mesh,
	// 	model    = model,
	// 	position = rl.Vector3(0),
	// }

	g0 := rl.Vector3{-1000.0, 0.0, -1000.0}
	g1 := rl.Vector3{-1000.0, 0.0, 1000.0}
	g2 := rl.Vector3{1000.0, 0.0, 1000.0}
	g3 := rl.Vector3{1000.0, 0.0, -1000.0}

	ground_quad := GroundQuad{g0, g1, g2, g3}

	cubeSize := rl.Vector3(1.)
	cubeMesh := rl.GenMeshCube(cubeSize.x, cubeSize.y, cubeSize.z)
	cubeModel := rl.LoadModelFromMesh(cubeMesh)
	cubeBB := rl.GetModelBoundingBox(cubeModel)
	fmt.println(cubeBB)

	rectSize := rl.Vector3{1., 2., 2.}
	rectMesh := rl.GenMeshCube(rectSize.x, rectSize.y, rectSize.z)
	rectModel := rl.LoadModelFromMesh(rectMesh)
	rectBB := rl.GetModelBoundingBox(rectModel)
	fmt.println(rectBB)

	pointSize := rl.Vector3(0.25)
	pointMesh := rl.GenMeshSphere(pointSize.x, 16, 16)
	pointModel := rl.LoadModelFromMesh(pointMesh)
	pointBB := rl.GetModelBoundingBox(pointModel)
	fmt.println(pointBB)

	boatModel := rl.LoadModel("assets/boat2.glb")
	boatBb := rl.GetModelBoundingBox(boatModel)
	fmt.println(boatBb)

	water_vs := fmt.ctprintf("assets/shaders/%s/water.vs", shader_version_folder)
	water_fs := fmt.ctprintf("assets/shaders/%s/water.fs", shader_version_folder)
	waterShader := rl.LoadShader(water_vs, water_fs)
	rl.SetShaderValue(
		waterShader,
		rl.GetShaderLocation(waterShader, "waterLevel"),
		&waterHeightY,
		rl.ShaderUniformDataType.FLOAT,
	)
	waterModel := rl.LoadModelFromMesh(rl.GenMeshPlane(1000., 1000., 1., 1.))
	waterModel.materials[0].shader = waterShader

	skybox_vs := fmt.ctprintf("assets/shaders/%s/skybox.vs", shader_version_folder)
	skybox_fs := fmt.ctprintf("assets/shaders/%s/skybox.fs", shader_version_folder)
	skyShader := rl.LoadShader(skybox_vs, skybox_fs)
	skyModel := rl.LoadModelFromMesh(rl.GenMeshCube(1., 1., 1.))
	skyModel.materials[0].shader = skyShader

	baseCubeModel := rl.LoadModel("assets/models/basic_cube.glb")

	resources := AllResources {
		cubeModel      = cubeModel,
		rectangleModel = rectModel,
		boatModel      = boatModel,
		waterModel     = waterModel,
		skyModel       = skyModel,
		waterShader    = waterShader,
		skyShader      = skyShader,
		groundQuad     = ground_quad,
		baseCubeModel  = baseCubeModel,
		terrainModel   = terrainModel,
		pointModel     = pointModel,
	}

	recipes := AllRecipes {
		grass_recipe    = get_recipe(.Grass),
		concrete_recipe = get_recipe(.Concrete),
		gnome_recipe    = get_recipe(.Gnome),
	}

	g^ = Game_Memory {
		run          = true,
		some_number  = 100,
		camera       = get_new_camera(),
		allResources = resources,
		all_recipes  = recipes,
		player_mode  = PlayerMode.Viewing,
		debug_info   = DebugInfo{},
	}

	for i in 0 ..< 3 {
		if (i % 2 == 0) {
			wareHouseEntity := FactoryEntity {
				position        = rl.Vector3{f32(i * 15) + 15, 1., f32(i * 15) + 15},
				type            = ModelType.Rectangle,
				color           = rl.ORANGE,
				original_color  = rl.ORANGE,
				highlight_color = rl.GREEN,
				bb              = rectBB,
				recipe_type     = .Grass,
			}

			for key in get_recipe_from_memory(wareHouseEntity.recipe_type).input_map {
				wareHouseEntity.current_inputs[key] = 0
			}
			for key in get_recipe_from_memory(wareHouseEntity.recipe_type).output_map {
				wareHouseEntity.current_outputs[key] = 40
			}
			append(&g.travelPoints, wareHouseEntity)
		} else {
			wareHouseEntity := FactoryEntity {
				position        = rl.Vector3{f32(i * 15) - 15, 1., f32(i * 15) + 15},
				type            = ModelType.Rectangle,
				color           = rl.ORANGE,
				original_color  = rl.ORANGE,
				highlight_color = rl.GREEN,
				bb              = rectBB,
				recipe_type     = .Grass,
			}

			for key in get_recipe_from_memory(wareHouseEntity.recipe_type).input_map {
				wareHouseEntity.current_inputs[key] = 0
			}
			for key in get_recipe_from_memory(wareHouseEntity.recipe_type).output_map {
				wareHouseEntity.current_outputs[key] = 40
			}
			append(&g.travelPoints, wareHouseEntity)
		}
	}

	game_hot_reloaded(g)
}

@(export)
game_should_run :: proc() -> bool {
	when ODIN_OS != .JS {
		// Never run this proc in browser. It contains a 16 ms sleep on web!
		if rl.WindowShouldClose() {
			return false
		}
	}

	return g.run
}

@(export)
game_shutdown :: proc() {
	rl.UnloadModel(g.allResources.cubeModel)
	rl.UnloadModel(g.allResources.rectangleModel)
	rl.UnloadModel(g.allResources.terrainModel)
	for &i in g.travelPoints {
		clean_up_constructor(&i)
	}
	clean_up_recipe(g.all_recipes.grass_recipe)
	clean_up_recipe(g.all_recipes.concrete_recipe)
	clean_up_recipe(g.all_recipes.gnome_recipe)
	delete(g.item_pickup)
	delete(g.cubes)
	delete(g.travelPoints)
	delete(g.travel)
	free(g)
}

@(export)
game_shutdown_window :: proc() {
	rl.CloseWindow()
}

@(export)
game_memory :: proc() -> rawptr {
	return g
}

@(export)
game_memory_size :: proc() -> int {
	return size_of(Game_Memory)
}

@(export)
game_hot_reloaded :: proc(mem: rawptr) {
	g = (^Game_Memory)(mem)

	// Here you can also set your own global variables. A good idea is to make
	// your global variables into pointers that point to something inside `g`.
}

@(export)
game_force_reload :: proc() -> bool {
	return rl.IsKeyPressed(.F5)
}

@(export)
game_force_restart :: proc() -> bool {
	return rl.IsKeyPressed(.F6)
}

// In a web build, this is called when browser changes size. Remove the
// `rl.SetWindowSize` call if you don't want a resizable game.
game_parent_window_size_changed :: proc(w, h: int) {
	rl.SetWindowSize(i32(w), i32(h))
}
