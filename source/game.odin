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
MAX_RESOURCES :: 250

shader_version_folder := "version330"

waterHeightY: f32 = 1.
Game_Memory :: struct {
	some_number:            int,
	run:                    bool,
	camera:                 rl.Camera,
	travelPoints:           [dynamic]FactoryEntity,
	travel:                 [dynamic]TravelEntity,
	turn_in_info:           TurnInPoint,
	currentRay:             rl.Ray,
	mouseRay:               rl.Ray,
	allResources:           AllResources,
	all_recipes:            AllRecipes,
	all_goals:              AllGoals,
	waterPos:               rl.Vector3,
	button_event:           Event,
	player_mode:            PlayerMode,
	show_inventory:         bool,
	selected:               SelectedEntity,
	current_collision_info: RayCollisionInfo,
	current_placing_info:   Placing_Info,
	current_output_info:    Output_Info,
	current_recipe_info:    RecipeInfo,
	current_extra_ui_state: Extra_UI_State,
	item_pickup:            map[ItemType]i32,
	debug_info:             DebugInfo,
	terrain_position:       rl.Vector3,
	turn_in_building_id:    int,
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
	building_id:             int,
	output_id:               int,
	collision_info:          bool,
	destination_building_id: int,
}

RayCollisionInfo :: struct {
	using RayCollision:  rl.RayCollision,
	is_hitting_anything: bool,
}


RecipeInfo :: struct {
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
	s_island_model:            rl.Model,
	s_island_sand_outer_model: rl.Model,
	s_island_sand_inner_model: rl.Model,
	m_island_model:            rl.Model,
	m_island_sand_outer_model: rl.Model,
	m_island_sand_inner_model: rl.Model,
	cubeModel:                 rl.Model,
	rectangleModel:            rl.Model,
	boatModel:                 rl.Model,
	waterModel:                rl.Model,
	skyModel:                  rl.Model,
	waterShader:               rl.Shader,
	skyShader:                 rl.Shader,
	groundQuad:                GroundQuad,
	baseCubeModel:             rl.Model,
	terrainModel:              rl.Model,
	pointModel:                rl.Model,
	cat:                       rl.Model,
	can_unopened:              rl.Model,
	can_opened:                rl.Model,
	can_nails:                 rl.Model,
	can_strips:                rl.Model,
	can_flat:                  rl.Model,
	can_reinforced:            rl.Model,
	can_ring:                  rl.Model,
	can_rotator:               rl.Model,
	can_motor:                 rl.Model,
	can_helm:                  rl.Model,
	can_rutter:                rl.Model,
	can_propeller:             rl.Model,
	construction_model:        rl.Model,
	assembly_model:            rl.Model,
	island_model:              rl.Model,
}

AllRecipes :: struct {
	can_opened:     Recipe,
	can_flat:       Recipe,
	can_strip:      Recipe,
	can_nails:      Recipe,
	can_ring:       Recipe,
	can_reinforced: Recipe,
	can_rotator:    Recipe,
	can_motor:      Recipe,
	can_propeller:  Recipe,
	can_hull:       Recipe,
	can_helm:       Recipe,
	can_rutter:     Recipe,
	can_boat:       Recipe,
}

AllGoals :: struct {
	tier_one: Goal,
	tier_two: Goal,
}

ThreeDeeEntity :: struct {
	bb:              rl.BoundingBox,
	selected:        bool,
	position:        rl.Vector3,
	type:            ModelType,
	color:           rl.Color,
	original_color:  rl.Color,
	highlight_color: rl.Color,
	active:          bool,
}

FactoryType :: enum {
	Miner,
	Transformer,
	TurnIn,
}

FactoryEntity :: struct {
	using ThreeDeeEntity: ThreeDeeEntity,
	using Constructor:    Constructor,
	output_workers:       [9]Worker,
	current_pick_worker:  int,
	worker_count:         int,
	factory_type:         FactoryType,
}

Worker :: struct {
	origin_id:      int,
	destination_id: int,
}

TravelEntityAction :: enum {
	Pickup,
	Dropoff,
	TurnIn,
}

TravelEntity :: struct {
	using ThreeDeeEntity: ThreeDeeEntity,
	worker_id:            int,
	building_id:          int,
	current_cargo:        Item,
	current_target_id:    int,
	action:               TravelEntityAction,
}

TurnInPoint :: struct {
	goal_type: GoalType,
}

GroundQuad :: struct {
	g0: rl.Vector3,
	g1: rl.Vector3,
	g2: rl.Vector3,
	g3: rl.Vector3,
}

ModelType :: enum {
	None,
	Cube,
	Rectangle,
	Point,
	Boat,
	Construct,
	Assemble,
	Manufacturer,
	TurnInPoint,
	Miner,
	Cat,
	CanOpened,
	CanUnopened,
	CanStrips,
	CanNails,
	CanReinforced,
	CanRing,
	CanRotator,
	CanMotor,
	CanHelm,
	CanRudder,
	CanPropeller,
	Island_1,
}

get_model :: proc(stuff: ModelType) -> rl.Model {
	switch stuff {
	case .None:
		return g.allResources.cubeModel
	case .Cube:
		return g.allResources.cubeModel
	case .Rectangle:
		return g.allResources.rectangleModel
	case .Boat:
		return g.allResources.boatModel
	case .Point:
		return g.allResources.pointModel
	case .Construct:
		return g.allResources.construction_model
	case .Miner:
		return g.allResources.cubeModel
	case .Assemble:
		return g.allResources.assembly_model
	case .Manufacturer:
		return g.allResources.rectangleModel
	case .TurnInPoint:
		return g.allResources.rectangleModel
	case .Cat:
		return g.allResources.cat
	case .CanOpened:
		return g.allResources.can_opened
	case .CanUnopened:
		return g.allResources.can_unopened
	case .CanStrips:
		return g.allResources.can_strips
	case .CanNails:
		return g.allResources.can_nails
	case .CanReinforced:
		return g.allResources.can_reinforced
	case .CanRing:
		return g.allResources.can_ring
	case .CanRotator:
		return g.allResources.can_rotator
	case .CanMotor:
		return g.allResources.can_motor
	case .CanHelm:
		return g.allResources.can_helm
	case .CanRudder:
		return g.allResources.can_rutter
	case .CanPropeller:
		return g.allResources.can_propeller
	case .Island_1:
		return g.allResources.island_model
	}
	return g.allResources.cubeModel
}

get_model_from_item :: proc(item_type: ItemType) -> rl.Model {
	#partial switch item_type {
	case .CanOpened:
		return g.allResources.can_unopened
	case .CanFlat:
		return g.allResources.can_flat
	case .CanStrips:
		return g.allResources.can_strips
	case .CanNails:
		return g.allResources.can_nails
	case .CanReinforced:
		return g.allResources.can_reinforced
	case .CanRing:
		return g.allResources.can_ring
	case .CanRotator:
		return g.allResources.can_ring
	case .CanHelm:
		return g.allResources.can_helm
	case .CanMotor:
		return g.allResources.can_motor
	case .CanRutter:
		return g.allResources.can_rutter
	case .CanPropeller:
		return g.allResources.can_propeller
	}
	return g.allResources.cubeModel
}

type_to_string :: proc(modelType: ModelType) -> string {
	switch modelType {
	case .None:
		return "None"
	case .Cube:
		return "Cube"
	case .Rectangle:
		return "Rectangle"
	case .Boat:
		return "Boat"
	case .Point:
		return "Point"
	case .Construct:
		return "Construct"
	case .Assemble:
		return "Assembler"
	case .Manufacturer:
		return "Manufacturer"
	case .TurnInPoint:
		return "Turn In Point"
	case .Miner:
		return "Miner"
	case .Cat:
		return "Cat"
	case .CanOpened:
		return "Can Opened"
	case .CanUnopened:
		return "Unopened"
	case .CanStrips:
		return "CanStrips"
	case .CanNails:
		return "Nails"
	case .CanReinforced:
		return "Reinforced"
	case .CanRing:
		return "Ring"
	case .CanRotator:
		return "Rotator"
	case .CanRudder:
		return "Rudder"
	case .CanMotor:
		return "Motor"
	case .CanHelm:
		return "Helm"
	case .CanPropeller:
		return "Propeller"
	case .Island_1:
		return "Island_1"
	}
	return "undefined"
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

	g.travelPoints[building_id].output_workers[worker_count].origin_id = building_id
	travel_entity := TravelEntity {
		type = model_type,
		position = position,
		bb = rl.GetModelBoundingBox(get_model(model_type)),
		color = rl.WHITE,
		current_cargo = Item{ItemType = .None},
		current_target_id = building_id,
		building_id = building_id,
		worker_id = worker_count,
		active = true,
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

handle_collisions_three_dee :: proc(three_dee: ThreeDeeEntity) -> rl.RayCollision {
	cubeBB := bounding_box_and_transform(three_dee.bb, three_dee.position)
	rCollision := rl.GetRayCollisionBox(g.currentRay, cubeBB)
	return rCollision
}

handle_entity_selection :: proc(three_dee: ThreeDeeEntity, id: int, spawn_model_type: ModelType) {
	g.selected = SelectedEntity {
		id                      = id,
		ThreeDeeEntity          = three_dee,
		selected_entity_actions = get_selected_entity_action_events_cube(
			id,
			spawn_model_type,
			three_dee.position,
		),
	}
}

handle_editor_update :: proc() {
	if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
		hit_anything := false
		g.currentRay = rl.GetScreenToWorldRay(rl.GetMousePosition(), g.camera)

		for i in 0 ..< len(g.travelPoints) {
			if !g.travelPoints[i].active {continue}
			travelPoint := g.travelPoints[i]
			rCollision := handle_collisions_three_dee(travelPoint)
			if rCollision.hit {
				if travelPoint.factory_type == .TurnIn {
					// Do something else
				} else {
					handle_entity_selection(travelPoint, i, .Cat)
				}
			}
			g.travelPoints[i].selected = rCollision.hit
			if !hit_anything && rCollision.hit {
				hit_anything = true
			}
		}
	}

	if rl.IsMouseButtonDown(.RIGHT) {
		rl.UpdateCamera(&g.camera, .FREE)
	}

	if rl.IsKeyPressed(.B) {
		g.selected = {}
		g.current_extra_ui_state = .None
		unhighlight_all_travelers()
	}
}

handle_placing_mode :: proc() {
	g.current_placing_info.collision_info = false
	if rl.CheckCollisionBoxes(
		rl.GetModelBoundingBox(g.allResources.terrainModel),
		bounding_box_and_transform(
			rl.GetModelBoundingBox(get_model(g.current_placing_info.modelType)),
			g.current_collision_info.point,
		),
	) {
		g.current_placing_info.collision_info = true
	}

	if rl.IsMouseButtonPressed(.LEFT) {
		#partial switch g.current_placing_info.modelType {
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
				active          = true,
				recipe_type     = .None,
				factory_type    = .Transformer,
			}
			append(&g.travelPoints, entity)
		case .Construct:
			entity := FactoryEntity {
				position        = rl.Vector3 {
					g.current_collision_info.point.x,
					0.0, //TODO: calculate this based on model height
					g.current_collision_info.point.z,
				},
				type            = g.current_placing_info.modelType,
				color           = rl.WHITE,
				original_color  = rl.WHITE,
				highlight_color = rl.RED,
				bb              = rl.GetModelBoundingBox(
					get_model(g.current_placing_info.modelType),
				),
				active          = true,
				recipe_type     = .None,
				factory_type    = .Transformer,
			}
			append(&g.travelPoints, entity)
		case .Assemble:
			entity := FactoryEntity {
				position        = rl.Vector3 {
					g.current_collision_info.point.x,
					0.0, //TODO: calculate this based on model height
					g.current_collision_info.point.z,
				},
				type            = g.current_placing_info.modelType,
				color           = rl.WHITE,
				original_color  = rl.WHITE,
				highlight_color = rl.GREEN,
				bb              = rl.GetModelBoundingBox(
					get_model(g.current_placing_info.modelType),
				),
				active          = true,
				recipe_type     = .None,
				factory_type    = .Transformer,
			}
			append(&g.travelPoints, entity)
		case .Manufacturer:
			entity := FactoryEntity {
				position        = rl.Vector3 {
					g.current_collision_info.point.x,
					0.0, //TODO: calculate this based on model height
					g.current_collision_info.point.z,
				},
				type            = g.current_placing_info.modelType,
				color           = rl.PURPLE,
				original_color  = rl.PURPLE,
				highlight_color = rl.GREEN,
				bb              = rl.GetModelBoundingBox(
					get_model(g.current_placing_info.modelType),
				),
				active          = true,
				recipe_type     = .None,
				factory_type    = .Transformer,
			}
			append(&g.travelPoints, entity)
		case .TurnInPoint:
			entity := FactoryEntity {
				position        = rl.Vector3 {
					g.current_collision_info.point.x,
					1.0,
					g.current_collision_info.point.z,
				},
				type            = g.current_placing_info.modelType,
				color           = rl.BLUE,
				original_color  = rl.BLUE,
				highlight_color = rl.GREEN,
				bb              = rl.GetModelBoundingBox(
					get_model(g.current_placing_info.modelType),
				),
				active          = true,
				recipe_type     = .None,
				factory_type    = .TurnIn,
			}
			append(&g.travelPoints, entity)
		}
		g.player_mode = .Editing
	}
}

calculate_traveler_cargo :: proc(travel_entity: ^TravelEntity) {
	if len(g.travelPoints) < travel_entity.current_target_id {
		return
	}

	if !g.travelPoints[travel_entity.current_target_id].active {return}

	distanceTo := rl.Vector3Distance(
		travel_entity.position,
		g.travelPoints[travel_entity.current_target_id].position,
	)
	g.debug_info.distance_info_1 = math.abs(distanceTo)
	if math.abs(distanceTo) > 2. {
		next_pos := rl.Vector3MoveTowards(
			travel_entity.position,
			g.travelPoints[travel_entity.current_target_id].position,
			0.21,
		)
		travel_entity.position = next_pos
	} else {
		workers :=
			g.travelPoints[travel_entity.building_id].output_workers[travel_entity.worker_id]
		if travel_entity.current_target_id == workers.destination_id {
			// Handle drop off
			factory := g.travelPoints[travel_entity.current_target_id]
			if factory.factory_type == .TurnIn {
				if check_type_for_goal(
					travel_entity.current_cargo.ItemType,
					get_goal_from_memory(g.turn_in_info.goal_type),
				) {
					current_item_type := travel_entity.current_cargo.ItemType
					g.travelPoints[travel_entity.current_target_id].current_inputs[current_item_type] +=
					1
					travel_entity.current_cargo.ItemType = .None
				}
			} else if factory.current_inputs[travel_entity.current_cargo.ItemType] <
			   MAX_RESOURCES {
				recipe := get_recipe_from_memory(factory.recipe_type)
				if check_type_for_recipe(travel_entity.current_cargo.ItemType, recipe) {
					current_item_type := travel_entity.current_cargo.ItemType
					g.travelPoints[travel_entity.current_target_id].current_inputs[current_item_type] +=
					1
					travel_entity.current_cargo.ItemType = .None
				}
			}
			// Next target
			travel_entity.current_target_id = workers.origin_id
		} else {
			// Handle pick up
			if travel_entity.current_cargo.ItemType == .None {
				has_less_than_5 := false
				for key in g.travelPoints[travel_entity.building_id].current_outputs {
					if g.travelPoints[travel_entity.building_id].current_outputs[key] < 5 {
						has_less_than_5 = true
						break
					}
				}
				if travel_entity.worker_id ==
					   g.travelPoints[travel_entity.current_target_id].current_pick_worker ||
				   !has_less_than_5 {
					factory := g.travelPoints[travel_entity.current_target_id]
					for key in factory.current_outputs {
						if g.travelPoints[travel_entity.current_target_id].current_outputs[key] >
						   0 {
							g.travelPoints[travel_entity.current_target_id].current_outputs[key] -=
							1
							travel_entity.current_cargo.ItemType = key
							travel_entity.current_cargo.position_offset = rl.Vector3{0., 1., 0.}
							travel_entity.current_cargo.color = rl.WHITE
						}
					}
					g.travelPoints[travel_entity.building_id].current_pick_worker += 1
					if g.travelPoints[travel_entity.building_id].current_pick_worker >
					   g.travelPoints[travel_entity.building_id].worker_count - 1 {
						g.travelPoints[travel_entity.building_id].current_pick_worker = 0
					}
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
		if !g.travelPoints[i].active {continue}
		if i == int(g.current_output_info.building_id) {
			continue
		}

		travelPoint := g.travelPoints[i]
		rCollision := handle_collisions_three_dee(travelPoint)

		// Check for terrain
		origin_point := g.travelPoints[g.current_output_info.building_id].position
		normal := rCollision.normal
		number_of_points := int(rCollision.distance / 10.)
		for j in 0 ..< number_of_points {
			next_point := origin_point + (normal * f32(j))
			down_ray := rl.Ray {
				position  = next_point,
				direction = rl.Vector3{0., -1., 0.},
			}
			// Going to need to make multiple of these from the heightmap maybe
			rl.GetRayCollisionQuad(
				down_ray,
				g.allResources.groundQuad.g0,
				g.allResources.groundQuad.g1,
				g.allResources.groundQuad.g2,
				g.allResources.groundQuad.g3,
			)
		}

		if rCollision.hit {
			g.current_output_info.collision_info = true
			g.current_output_info.destination_building_id = i
		}
	}

	if rl.IsMouseButtonPressed(.LEFT) {
		g.currentRay = rl.GetScreenToWorldRay(rl.GetMousePosition(), g.camera)
		for i in 0 ..< len(g.travelPoints) {
			travelPoint := g.travelPoints[i]
			rCollision := handle_collisions_three_dee(travelPoint)
			if rCollision.hit {
				g.player_mode = .Viewing
				g.current_extra_ui_state = .None
				rl.DisableCursor()
				g.travelPoints[i].color = g.travelPoints[i].original_color
				g.travelPoints[g.current_output_info.building_id].output_workers[g.current_output_info.output_id].destination_id =
					i
			}
		}
	}
}

highlight_all_travelers_by_id :: proc(building_id: int) {
	for i in 0 ..< len(g.travel) {
		g.travel[i].selected = g.travel[i].building_id == building_id
	}
}

unhighlight_all_travelers :: proc() {
	for i in 0 ..< len(g.travel) {
		g.travel[i].selected = false
	}
}

remove_from_inventory :: proc(key: ItemType, qty: i32) -> i32 {
	if g.item_pickup[key] <= 0 {
		return 0
	}
	if g.item_pickup[key] < qty {
		amount := g.item_pickup[key]
		g.item_pickup[key] = 0
		return amount
	}
	g.item_pickup[key] -= qty
	return qty
}

add_to_inventory :: proc(item_type: ItemType, qty: i32) {
	g.item_pickup[item_type] += qty
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
		g.current_collision_info.RayCollision = ground_collision_info
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
		if !g.travelPoints[i].active {continue}
		if g.travelPoints[i].factory_type == .TurnIn {
			if calculate_goals(g.travelPoints[i], g.turn_in_info.goal_type) {
				// clear(&g.turn_in_info.current_count_map)
				g.turn_in_info.goal_type = get_next_goal(g.turn_in_info.goal_type)
			}
		} else {
			maxed_out := false
			for key in g.travelPoints[i].current_outputs {
				if g.travelPoints[i].current_outputs[key] > MAX_RESOURCES {
					maxed_out = true
				}
			}
			if maxed_out {
				g.travelPoints[i].current_construct_time = 0
				continue
			}
			recipe := get_recipe_from_memory(g.travelPoints[i].recipe_type)
			if check_item_input_to_recipe(g.travelPoints[i].current_inputs, recipe) {
				g.travelPoints[i].current_construct_time += rl.GetFrameTime()
			}
			if check_construction_time(g.travelPoints[i]) {
				transform_constructor_item(&g.travelPoints[i], recipe)
				g.travelPoints[i].current_construct_time = 0
			}
		}
	}

	if rl.IsKeyPressed(.R) {
		if g.player_mode != .Editing {
			g.player_mode = .Editing
		} else {
			g.player_mode = .Viewing
			unhighlight_all_travelers()
		}

		if g.player_mode == .Viewing {rl.DisableCursor()} else {rl.EnableCursor()}
	}

	if rl.IsKeyPressed(.I) {
		g.show_inventory = !g.show_inventory
	}

	if rl.IsKeyPressed(.P) {
		// test_constructor_scenario_1()
		// test_constructor_scenario_2()
		// test_constructor_scenario_3()
		// test_item_check()
		overwrite_recipe_time(&g.all_recipes.can_opened, 0.5)
		test_dynamic_array_removal()
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
	// text_spacing: int = PIXEL_WINDOW_HEIGHT - 15
	text_spacing: int = 5
	for info in debug_info {
		rl.DrawText(info, 5, auto_cast text_spacing, 8., rl.DARKGRAY)
		text_spacing += 11
	}
}

draw_construction_time :: proc(x, y: i32) {
	travel_point_info := g.travelPoints[g.selected.id]
	construction_time_percent := get_current_construction_time(travel_point_info)
	rl.DrawRectangle(x, y, 100., 20, rl.LIGHTGRAY)
	rl.DrawRectangle(x, y, i32(100. * construction_time_percent), 20, rl.ORANGE)
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
		if !g.travelPoints[i].active {continue}
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

Island_Size :: enum {
	Small,
	Medium,
}

draw_island_model :: proc(island_size: Island_Size, position: rl.Vector3) {
	switch island_size {
	case .Small:
		rl.DrawModel(
			g.allResources.s_island_sand_outer_model,
			position - rl.Vector3{0., 1., 0.},
			1.,
			rl.BEIGE,
		)
		rl.DrawModel(
			g.allResources.s_island_sand_inner_model,
			position - rl.Vector3{0., 0.5, 0.},
			1.,
			rl.BEIGE,
		)
		rl.DrawModel(g.allResources.s_island_model, position, 1., rl.DARKGREEN)
	case .Medium:
		rl.DrawModel(
			g.allResources.m_island_sand_outer_model,
			position - rl.Vector3{0., 1., 0.},
			1.,
			rl.BEIGE,
		)
		rl.DrawModel(
			g.allResources.m_island_sand_inner_model,
			position - rl.Vector3{0., 0.5, 0.},
			1.,
			rl.BEIGE,
		)
		rl.DrawModel(g.allResources.m_island_model, position, 1., rl.DARKGREEN)

	}
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
	rl.DrawGrid(1000, 2.)
	draw_island_model(.Small, rl.Vector3{5., -5., 5.})
	draw_island_model(.Medium, rl.Vector3{50., -5., 5.})

	rl.DrawModel(g.allResources.waterModel, g.waterPos - rl.Vector3{0., 2., 0.}, 1., rl.WHITE)
	rl.DrawModel(g.allResources.waterModel, g.waterPos - rl.Vector3{0., 100., 0.}, 1., rl.DARKBLUE)

	if g.player_mode == .Placing {
		draw_placing_object()
	}

	if g.player_mode == .Selecting {
		draw_selecting_point()
	}

	for i in 0 ..< len(g.travelPoints) {
		if !g.travelPoints[i].active {continue}
		draw_three_dee_entity(g.travelPoints[i])
		if g.selected.type != .None {
			if g.player_mode == .Editing && g.selected.id == i {
				draw_editing_layer(g.travelPoints[i])
			}
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
		if g.travel[i].selected {
			draw_editing_layer(g.travel[i])
		}
	}

	rl.EndBlendMode()
	rl.EndMode3D()

	rl.BeginMode2D(ui_camera())
	travel_point_info: FactoryEntity
	if in_model_list(g.selected.type) {
		travel_point_info = g.travelPoints[g.selected.id]
	}

	debug_info := []cstring {
		// fmt.ctprintf("Mouse Pos %v\n", rl.GetMousePosition()),
		// fmt.ctprintf("Mouse Collision %v\n", g.current_collision_info.point),
		// fmt.ctprintf("Player Mode %v\n", g.player_mode),
		fmt.ctprintf(
			"Current Goal\n%v\n",
			get_item_map_with_two_maps_text(
				g.travelPoints[g.turn_in_building_id].current_inputs,
				(get_goal_from_memory(g.turn_in_info.goal_type).input_map),
			),
		),
		// fmt.ctprintf("\nInventory\n%v\n", get_item_map_text_new_line(g.item_pickup)),
	}
	if g.show_inventory {
		debug_info = []cstring {
			fmt.ctprintf(
				"Current Goal\n%v\n",
				get_item_map_with_two_maps_text(
					g.travelPoints[g.turn_in_building_id].current_inputs,
					(get_goal_from_memory(g.turn_in_info.goal_type).input_map),
				),
			),
			fmt.ctprintf("\nInventory\n%v\n", get_item_map_text_new_line(g.item_pickup)),
		}
	}
	rl.DrawRectangle(3, 0, 122, 1, rl.GRAY)
	rl.DrawRectangle(4, 1, 120, 3, rl.LIGHTGRAY)
	rl.DrawRectangle(3, 1, 1, 83, rl.LIGHTGRAY)
	rl.DrawRectangle(3, 83, 122, 2, rl.LIGHTGRAY)
	rl.DrawRectangle(124, 1, 1, 83, rl.LIGHTGRAY)
	if g.show_inventory {
		rl.DrawRectangle(4, 4, 120, 180, rl.RAYWHITE)
	} else {
		rl.DrawRectangle(4, 4, 120, 80, rl.RAYWHITE)
	}
	draw_debug_info(debug_info)
	rl.EndMode2D()

	if g.player_mode == .Editing {
		draw_button_ui(g.selected)
		draw_entity_info_ui(g.selected)
		draw_default_button_ui()
	}


	rl.EndDrawing()
}

in_model_list :: proc(model_type: ModelType) -> bool {
	types := [4]ModelType{.Rectangle, .Construct, .Assemble, .Manufacturer}
	for i in types {
		if i == model_type {
			return true
		}
	}
	return false
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
	rl.SetTargetFPS(60)
	rl.SetExitKey(nil)
	// rl.GuiLoadStyleTerminal()
}

@(export)
game_init :: proc() {
	rl.DisableCursor()
	g = new(Game_Memory)

	terrainMesh := rl.GenMeshPlane(10., 10., 10., 5.)
	terrainModel := rl.LoadModelFromMesh(terrainMesh)

	inner_radius_addition: f32 = 3.5
	outer_radius_addition: f32 = 5.

	s_radius: f32 = 10.
	s_island_mesh := rl.GenMeshCylinder(s_radius, 5., 9.)
	s_island_model := rl.LoadModelFromMesh(s_island_mesh)
	s_island_sand_inner_mesh := rl.GenMeshCylinder(s_radius + inner_radius_addition, 5., 9.)
	s_island_sand_inner_model := rl.LoadModelFromMesh(s_island_sand_inner_mesh)
	s_island_sand_outer_mesh := rl.GenMeshCylinder(s_radius + outer_radius_addition, 5., 9.)
	s_island_sand_outer_model := rl.LoadModelFromMesh(s_island_sand_outer_mesh)

	m_radius: f32 = 20.
	m_island_mesh := rl.GenMeshCylinder(m_radius, 5., 9.)
	m_island_model := rl.LoadModelFromMesh(m_island_mesh)
	m_island_sand_inner_mesh := rl.GenMeshCylinder(m_radius + inner_radius_addition, 5., 9.)
	m_island_sand_inner_model := rl.LoadModelFromMesh(m_island_sand_inner_mesh)
	m_island_sand_outer_mesh := rl.GenMeshCylinder(m_radius + outer_radius_addition, 5., 9.)
	m_island_sand_outer_model := rl.LoadModelFromMesh(m_island_sand_outer_mesh)

	g0 := rl.Vector3{-1000.0, 0.0, -1000.0}
	g1 := rl.Vector3{-1000.0, 0.0, 1000.0}
	g2 := rl.Vector3{1000.0, 0.0, 1000.0}
	g3 := rl.Vector3{1000.0, 0.0, -1000.0}

	// g0 := rl.Vector3{-10.0, 0.0, -10.0}
	// g1 := rl.Vector3{-10.0, 0.0, 10.0}
	// g2 := rl.Vector3{10.0, 0.0, 10.0}
	// g3 := rl.Vector3{10.0, 0.0, -10.0}

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
	unopened_can := rl.LoadModel("assets/models/unopened_can.glb")
	opened_can := rl.LoadModel("assets/models/opened_can.glb")
	nails := rl.LoadModel("assets/models/can_nails.glb")
	strips := rl.LoadModel("assets/models/can_strips.glb")
	flat_can := rl.LoadModel("assets/models/flat_can.glb")
	reinforced := rl.LoadModel("assets/models/reinforced.glb")
	ring := rl.LoadModel("assets/models/ring.glb")
	rotator := rl.LoadModel("assets/models/rotator.glb")
	motor := rl.LoadModel("assets/models/motor.glb")
	helm := rl.LoadModel("assets/models/helm.glb")
	rutter := rl.LoadModel("assets/models/rudder.glb")
	cat := rl.LoadModel("assets/models/cat.glb")
	propeller := rl.LoadModel("assets/models/propeller.glb")
	construction_model := rl.LoadModel("assets/models/construction_building.glb")
	assembly_model := rl.LoadModel("assets/models/assembly_building.glb")

	island_model := rl.LoadModel("assets/models/island_1.glb")

	resources := AllResources {
		s_island_model            = s_island_model,
		m_island_model            = m_island_model,
		s_island_sand_outer_model = s_island_sand_outer_model,
		s_island_sand_inner_model = s_island_sand_inner_model,
		m_island_sand_inner_model = m_island_sand_inner_model,
		m_island_sand_outer_model = m_island_sand_outer_model,
		cubeModel                 = cubeModel,
		rectangleModel            = rectModel,
		boatModel                 = boatModel,
		waterModel                = waterModel,
		skyModel                  = skyModel,
		waterShader               = waterShader,
		skyShader                 = skyShader,
		groundQuad                = ground_quad,
		baseCubeModel             = baseCubeModel,
		terrainModel              = terrainModel,
		pointModel                = pointModel,
		cat                       = cat,
		can_unopened              = unopened_can,
		can_opened                = opened_can,
		can_nails                 = nails,
		can_strips                = strips,
		can_flat                  = flat_can,
		can_reinforced            = reinforced,
		can_ring                  = ring,
		can_rotator               = rotator,
		can_motor                 = motor,
		can_helm                  = helm,
		can_rutter                = rutter,
		can_propeller             = propeller,
		construction_model        = construction_model,
		assembly_model            = assembly_model,
		island_model              = island_model,
	}

	recipes := AllRecipes {
		can_opened     = get_recipe(.CanOpened),
		can_flat       = get_recipe(.CanFlat),
		can_strip      = get_recipe(.CanStrips),
		can_nails      = get_recipe(.CanNails),
		can_ring       = get_recipe(.CanRing),
		can_reinforced = get_recipe(.CanReinforced),
		can_rotator    = get_recipe(.CanRotator),
		can_motor      = get_recipe(.CanMotor),
		can_propeller  = get_recipe(.CanPropeller),
		can_hull       = get_recipe(.CanHull),
		can_helm       = get_recipe(.CanHelm),
		can_rutter     = get_recipe(.CanRutter),
		can_boat       = get_recipe(.Boat),
	}

	goals := AllGoals {
		tier_one = get_goal(.TierOne),
		tier_two = get_goal(.TierTwo),
	}

	turn_in_info := TurnInPoint {
		goal_type = .TierOne,
	}

	g^ = Game_Memory {
		run          = true,
		some_number  = 100,
		camera       = get_new_camera(),
		allResources = resources,
		all_recipes  = recipes,
		all_goals    = goals,
		player_mode  = PlayerMode.Viewing,
		debug_info   = DebugInfo{},
		turn_in_info = turn_in_info,
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
				recipe_type     = .None,
				active          = true,
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
				recipe_type     = .None,
				active          = true,
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

	goal_entity := FactoryEntity {
		position        = rl.Vector3{0, 1., 0.},
		type            = ModelType.TurnInPoint,
		color           = rl.PINK,
		original_color  = rl.ORANGE,
		highlight_color = rl.GREEN,
		bb              = rectBB,
		recipe_type     = .None,
		active          = true,
		factory_type    = .TurnIn,
	}
	goal_id := len(g.travelPoints)
	g.turn_in_building_id = goal_id
	append(&g.travelPoints, goal_entity)

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
	rl.UnloadModel(g.allResources.boatModel)
	rl.UnloadModel(g.allResources.waterModel)
	rl.UnloadModel(g.allResources.skyModel)
	rl.UnloadModel(g.allResources.baseCubeModel)
	rl.UnloadModel(g.allResources.pointModel)
	rl.UnloadModel(g.allResources.cat)
	rl.UnloadModel(g.allResources.can_unopened)
	rl.UnloadModel(g.allResources.can_opened)
	rl.UnloadModel(g.allResources.can_nails)
	rl.UnloadModel(g.allResources.can_strips)
	rl.UnloadModel(g.allResources.can_flat)
	rl.UnloadModel(g.allResources.can_reinforced)
	rl.UnloadModel(g.allResources.can_ring)
	rl.UnloadModel(g.allResources.can_rotator)
	rl.UnloadModel(g.allResources.can_motor)
	rl.UnloadModel(g.allResources.can_helm)
	rl.UnloadModel(g.allResources.can_rutter)
	rl.UnloadModel(g.allResources.can_propeller)
	rl.UnloadModel(g.allResources.construction_model)
	rl.UnloadModel(g.allResources.assembly_model)
	rl.UnloadModel(g.allResources.island_model)

	clean_up_recipe(g.all_recipes.can_opened)
	clean_up_recipe(g.all_recipes.can_flat)
	clean_up_recipe(g.all_recipes.can_strip)
	clean_up_recipe(g.all_recipes.can_nails)
	clean_up_recipe(g.all_recipes.can_ring)
	clean_up_recipe(g.all_recipes.can_reinforced)
	clean_up_recipe(g.all_recipes.can_rotator)
	clean_up_recipe(g.all_recipes.can_motor)
	clean_up_recipe(g.all_recipes.can_propeller)
	clean_up_recipe(g.all_recipes.can_hull)
	clean_up_recipe(g.all_recipes.can_helm)
	clean_up_recipe(g.all_recipes.can_rutter)
	clean_up_recipe(g.all_recipes.can_boat)

	for &i in g.travelPoints {
		clean_up_constructor(&i)
	}

	delete(g.all_goals.tier_one.input_map)
	delete(g.all_goals.tier_two.input_map)
	delete(g.item_pickup)
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
