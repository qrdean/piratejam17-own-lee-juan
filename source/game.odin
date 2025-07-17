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
	terrain:                ThreeDeeEntity,
	terrainHeightMap:       rl.Image,
	terrainTexture:         rl.Texture2D,
	camera:                 rl.Camera,
	cubes:                  [dynamic]ThreeDeeEntity,
	travelPoints:           [dynamic]ThreeDeeEntity,
	travel:                 [dynamic]TravelEntity,
	// editing:                bool,
	currentRay:             rl.Ray,
	mouseRay:               rl.Ray,
	allResources:           AllResources,
	selected:               SelectedEntity,
	waterPos:               rl.Vector3,
	current_collision_info: rl.RayCollision,
	button_event:           Event,
	player_mode:            PlayerMode,
	current_placing_info:   Placing_Info,
}

Placing_Info :: struct {
	modelType:      ModelType,
	collision_info: bool,
}

PlayerMode :: enum {
	Editing,
	Viewing,
	Placing,
}

Event :: struct {
	EventType: ButtonNumb,
	Data:      valunion,
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
}

Selected_Entity_Actions :: [9]string
Selected_Entity_Action_Events :: [9]Event

SelectedEntity :: struct {
	id:                      int,
	ThreeDeeEntity:          ThreeDeeEntity,
	selected_entity_actions: Selected_Entity_Actions,
}

ThreeDeeEntity :: struct {
	mesh:     rl.Mesh,
	model:    rl.Model,
	bb:       rl.BoundingBox,
	selected: bool,
	position: rl.Vector3,
	type:     ModelType,
	color:    rl.Color,
}

TravelEntity :: struct {
	ThreeDeeEntity:    ThreeDeeEntity,
	current_target_id: int,
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
	Boat,
}

get_model :: proc(stuff: ModelType) -> rl.Model {
	switch stuff {
	case ModelType.Cube:
		return g.allResources.cubeModel
	case ModelType.Rectangle:
		return g.allResources.rectangleModel
	case ModelType.Boat:
		return g.allResources.boatModel
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
	}
	return "undefined"
}

get_model_bounding_box :: proc(stuff: ModelType) -> rl.BoundingBox {
	#partial switch stuff {
	case .Cube:
		return rl.GetModelBoundingBox(get_model(stuff))
	}
	return rl.GetModelBoundingBox(g.allResources.cubeModel)
}

get_selected_entity_actions :: proc(modelType: ModelType) -> Selected_Entity_Actions {
	switch modelType {
	case ModelType.Cube:
		return Selected_Entity_Actions{"", "", "", "", "", "", "", "", ""}
	case ModelType.Rectangle:
		return Selected_Entity_Actions{"Add", "x", "y", "z", "a", "b", "c", "d", "e"}
	case ModelType.Boat:
		return Selected_Entity_Actions{"", "", "", "", "", "", "", "", ""}
	}
	return Selected_Entity_Actions{"", "", "", "", "", "", "", "", ""}
}

FactoryButtonEvent :: enum {
	BuyShip,
}


g: ^Game_Memory

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

handle_editor_update :: proc() {
	if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
		g.currentRay = rl.GetScreenToWorldRay(rl.GetMousePosition(), g.camera)
		for i in 0 ..< len(g.cubes) {
			cubeBB := bounding_box_and_transform(g.cubes[i].bb, g.cubes[i].position)
			rCollision := rl.GetRayCollisionBox(g.currentRay, cubeBB)
			if rCollision.hit {

				g.selected = SelectedEntity {
					id                      = i,
					ThreeDeeEntity          = g.cubes[i],
					selected_entity_actions = get_selected_entity_actions(g.cubes[i].type),
				}
			}
			g.cubes[i].selected = rCollision.hit
		}

		for i in 0 ..< len(g.travelPoints) {
			cubeBB := bounding_box_and_transform(g.travelPoints[i].bb, g.travelPoints[i].position)
			rCollision := rl.GetRayCollisionBox(g.currentRay, cubeBB)
			if rCollision.hit {
				actions := get_selected_entity_actions(g.travelPoints[i].type)
				type := type_to_string(g.travelPoints[i].type)
				fmt.println(type)
				fmt.println(actions)
				g.selected = SelectedEntity {
					id                      = i,
					ThreeDeeEntity          = g.travelPoints[i],
					selected_entity_actions = actions,
				}
			}
			g.travelPoints[i].selected = rCollision.hit
		}
	}
}

handle_placing_mode :: proc() {
	g.current_placing_info.collision_info = false
	for i in 0 ..< len(g.travelPoints) {
		bb := bounding_box_and_transform(g.travelPoints[i].bb, g.travelPoints[i].position)
		if rl.CheckCollisionBoxes(
			bb,
			bounding_box_and_transform(
				get_model_bounding_box(g.current_placing_info.modelType),
				g.current_collision_info.point,
			),
		) {
			g.current_placing_info.collision_info = true
		}
	}
	if rl.IsMouseButtonPressed(.LEFT) {
		if g.current_placing_info.collision_info {
			cubeEntity := ThreeDeeEntity {
				position = rl.Vector3 {
					g.current_collision_info.point.x,
					0.5,
					g.current_collision_info.point.z,
				},
				type     = g.current_placing_info.modelType,
				color    = rl.BROWN,
				bb       = get_model_bounding_box(g.current_placing_info.modelType),
			}
			append(&g.cubes, cubeEntity)
			g.player_mode = .Editing
		}
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
	}

	for i in 0 ..< len(g.travel) {
		// distanceTo := rl.Vector3Distance(g.travel[i].ThreeDeeEntity.position, g.travel[i].target) 
		// fmt.println(distanceTo)
		next_pos := rl.Vector3MoveTowards(
			g.travel[i].ThreeDeeEntity.position,
			g.travelPoints[g.travel[i].current_target_id].position,
			0.01,
		)
		g.travel[i].ThreeDeeEntity.position = next_pos
		// if math.abs(distanceTo) < 5. {
		// }
	}

	if rl.IsKeyPressed(.R) {
		if g.player_mode != .Editing {
			g.player_mode = .Editing
		} else {
			g.player_mode = .Viewing
		}

		// g.player_mode = !g.editing
		// if !g.editing {rl.DisableCursor()} else {rl.EnableCursor()}
		if g.player_mode == .Viewing {rl.DisableCursor()} else {rl.EnableCursor()}
	}


	wave := math.sin_f32(f32(rl.GetTime()) * 0.9) * 0.9 // slow, subtle vertical motion
	animatedWaterLevel := waterHeightY + wave
	g.waterPos = rl.Vector3{0, animatedWaterLevel, 0}

	if rl.IsKeyPressed(.ESCAPE) {
		g.run = false
	}
}

bounding_box_and_transform :: proc(bb: rl.BoundingBox, position: rl.Vector3) -> rl.BoundingBox {
	return {
		rl.Vector3{bb.min.x + position.x, bb.min.y + position.y, bb.min.z + position.z},
		rl.Vector3{bb.max.x + position.x, bb.max.y + position.y, bb.max.z + position.z},
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

draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.SKYBLUE)

	rl.BeginMode3D(g.camera)
	rlgl.DisableBackfaceCulling()
	rlgl.DisableDepthMask()
	rlgl.DisableDepthTest()
	// rlgl.EnableBackfaceCulling()
	rl.DrawModel(g.allResources.skyModel, g.camera.position, 10000., rl.WHITE)
	rlgl.EnableDepthMask()
	rlgl.EnableDepthTest()
	rlgl.SetBlendMode(i32(rl.BlendMode.ALPHA))
	// rl.DrawModel(g.terrain.model, rl.Vector3(0), 1., rl.WHITE)
	rl.DrawGrid(10, 1.)
	// rl.DrawModel(g.allResources.waterModel, g.waterPos, 1., rl.WHITE)
	// rl.DrawModel(g.allResources.waterModel, g.waterPos - rl.Vector3{0., 100., 0.}, 1., rl.DARKBLUE)
	// rl.DrawModel(g.allResources.baseCubeModel, rl.Vector3{1., 4., 1.}, 1.0, rl.WHITE)
	if g.player_mode == .Placing {
		draw_placing_object()
	}

	for i in 0 ..< len(g.cubes) {
		rl.DrawModel(get_model(g.cubes[i].type), g.cubes[i].position, 1., g.cubes[i].color)
		if g.player_mode == .Editing && g.cubes[i].selected {
			rl.DrawBoundingBox(
				bounding_box_and_transform(g.cubes[i].bb, g.cubes[i].position),
				rl.GREEN,
			)

			zvector := rl.Vector3(0)
			zvector.z = 5.
			yvector := rl.Vector3(0)
			yvector.y = 5.
			xvector := rl.Vector3(0)
			xvector.x = 5.

			rl.DrawLine3D(g.cubes[i].position, g.cubes[i].position + zvector, rl.BLUE)
			rl.DrawLine3D(g.cubes[i].position, g.cubes[i].position + xvector, rl.RED)
			rl.DrawLine3D(g.cubes[i].position, g.cubes[i].position + yvector, rl.YELLOW)
		}
	}

	for i in 0 ..< len(g.travelPoints) {
		rl.DrawModel(
			get_model(g.travelPoints[i].type),
			g.travelPoints[i].position,
			1.,
			g.travelPoints[i].color,
		)

		if g.player_mode == .Editing && g.travelPoints[i].selected {
			rl.DrawBoundingBox(
				bounding_box_and_transform(g.travelPoints[i].bb, g.travelPoints[i].position),
				rl.GREEN,
			)

			zvector := rl.Vector3(0)
			zvector.z = 5.
			yvector := rl.Vector3(0)
			yvector.y = 5.
			xvector := rl.Vector3(0)
			xvector.x = 5.

			rl.DrawLine3D(
				g.travelPoints[i].position,
				g.travelPoints[i].position + zvector,
				rl.BLUE,
			)
			rl.DrawLine3D(g.travelPoints[i].position, g.travelPoints[i].position + xvector, rl.RED)
			rl.DrawLine3D(
				g.travelPoints[i].position,
				g.travelPoints[i].position + yvector,
				rl.YELLOW,
			)
		}
	}


	// for i in 0 ..< len(g.travel) {
	// 	rl.DrawModel(
	// 		get_model(g.travel[i].ThreeDeeEntity.type),
	// 		g.travel[i].ThreeDeeEntity.position,
	// 		1.,
	// 		g.travel[i].ThreeDeeEntity.color,
	// 	)
	// }

	rl.EndBlendMode()
	rl.EndMode3D()

	rl.BeginMode2D(ui_camera())
	text_spacing: int = 5
	rl.DrawText(
		fmt.ctprintf("Mouse Pos %v\n", rl.GetMousePosition()),
		5,
		auto_cast text_spacing,
		8.,
		rl.BLACK,
	)
	text_spacing += 11
	rl.DrawText(
		fmt.ctprintf("Mouse Collision %v\n", g.current_collision_info.point),
		5,
		auto_cast text_spacing,
		8.,
		rl.BLACK,
	)
	text_spacing += 11
	rl.DrawText(
		fmt.ctprintf("Player Mode %v\n", g.player_mode),
		5,
		auto_cast text_spacing,
		8.,
		rl.BLACK,
	)
	rl.EndMode2D()

	if g.player_mode == .Editing {
		// draw_button_ui(g.selected)
		draw_default_button_ui()
	}

	rl.EndDrawing()
}

ButtonNumb :: enum {
	Button1,
	Button2,
	Button3,
	Button4,
	Button5,
	Button6,
	Button7,
	Button8,
	Button9,
}

Gui_Buttons_Rectangles: [9]rl.Rectangle = {
	{22, 42, 50, 50},
	{74, 42, 50, 50},
	{126, 42, 50, 50},
	{178, 42, 50, 50},
	{22, 94, 50, 50},
	{74, 94, 50, 50},
	{126, 94, 50, 50},
	{178, 94, 50, 50},
	{178, 94, 50, 50},
}

get_default_actions :: proc() -> Selected_Entity_Action_Events {
	return Selected_Entity_Action_Events {
		{.Button1, Place_Object{model = ModelType.Cube}},
		{.Button2, Place_Object{model = ModelType.Rectangle}},
		{},
		{},
		{},
		{},
		{},
		{},
		{},
	}

}

valunion :: union {
	something,
	somethingelse,
	Place_Object,
}

something :: struct {
	a: string,
	b: int,
}

somethingelse :: struct {
	c: f32,
	d: bool,
}

ButtonActions :: union {
	Place_Object,
}

Place_Object :: struct {
	model: ModelType,
}

draw_default_button_ui :: proc() {
	rl.GuiEnable()
	rl.GuiPanel(
		rl.Rectangle{f32(rl.GetScreenWidth()) - 240, 20, 210, 128},
		fmt.ctprintf("Actions"),
	)

	actions := get_default_actions()
	for i in 0 ..< len(actions) {
		gui_button_rectangle := Gui_Buttons_Rectangles[i]
		gui_button_rectangle.x = gui_button_rectangle.x + (f32(rl.GetScreenWidth()) - 260)
		if actions[i].Data != nil {
			if rl.GuiButton(gui_button_rectangle, fmt.ctprintf("%s", actions[i].EventType)) {
				g.button_event = Event {
					EventType = actions[i].EventType,
					Data      = actions[i].Data,
				}
			}
		}
	}
}


draw_button_ui :: proc(selected: SelectedEntity) {
	rl.GuiEnable()
	rl.GuiPanel(
		rl.Rectangle{20, 20, 210, 128},
		fmt.ctprintf("%s", type_to_string(selected.ThreeDeeEntity.type)),
	)

	for i in 0 ..< len(selected.selected_entity_actions) {
		if selected.selected_entity_actions[i] == "" {
			rl.GuiDisable()
			return
		}
		if rl.GuiButton(
			Gui_Buttons_Rectangles[i],
			fmt.ctprintf("%s", selected.selected_entity_actions[i]),
		) {
			// g.button_event = Event{.Button1, selected.selected_entity_actions[i]}
		}
	}

	// if rl.GuiButton(rl.Rectangle{22, 42, 50, 50}, "click") {
	// 	if selected.ThreeDeeEntity.type == ModelType.Rectangle {
	// 		a := ThreeDeeEntity {
	// 			position = selected.ThreeDeeEntity.position,
	// 			type     = ModelType.Rectangle,
	// 			color    = rl.BLACK,
	// 		}
	// 		next_id := selected.id + 1
	// 		if len(g.travelPoints) <= next_id {
	// 			next_id = 0
	// 		}
	// 		travelEntity := TravelEntity{a, next_id}
	// 		append(&g.travel, travelEntity)
	// 	}
	// }
	//
	// rl.GuiDisable()
	// rl.GuiButton(rl.Rectangle{74, 42, 50, 50}, "click")
	// rl.GuiButton(rl.Rectangle{126, 42, 50, 50}, "click")
	// rl.GuiButton(rl.Rectangle{178, 42, 50, 50}, "click")
	// rl.GuiButton(rl.Rectangle{22, 94, 50, 50}, "click")
	// rl.GuiButton(rl.Rectangle{74, 94, 50, 50}, "click")
	// rl.GuiButton(rl.Rectangle{126, 94, 50, 50}, "click")
	// rl.GuiButton(rl.Rectangle{178, 94, 50, 50}, "click")
}

handle_button :: proc() {
	if g.button_event.Data != nil {
		fmt.println(g.button_event.EventType)
		switch d in g.button_event.Data {
		case something:
			fmt.println(d)
		case somethingelse:
			fmt.println(d)
		case Place_Object:
			fmt.println(d)
			g.current_placing_info.modelType = d.model
			g.current_placing_info.collision_info = false
			g.player_mode = .Placing
		case:
			fmt.println("unhandled?")
		}
		g.button_event.Data = nil
	}
}

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

	terrainHeightMap := rl.LoadImage("assets/MiddleIsland.png")
	terrainTexture := rl.LoadTextureFromImage(terrainHeightMap)
	mesh := rl.GenMeshPlane(100., 100., 10., 5.)
	// mesh := rl.GenMeshHeightmap(terrainHeightMap, rl.Vector3{10000., 200., 10000.})
	model := rl.LoadModelFromMesh(mesh)
	// model.materials[0].maps[rl.MaterialMapIndex.ALBEDO].texture = terrainTexture
	terrainStruct := ThreeDeeEntity {
		mesh     = mesh,
		model    = model,
		position = rl.Vector3(0),
	}

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
	}

	g^ = Game_Memory {
		run              = true,
		some_number      = 100,

		// You can put textures, sounds and music in the `assets` folder. Those
		// files will be part any release or web build.
		player_texture   = rl.LoadTexture("assets/round_cat.png"),
		terrain          = terrainStruct,
		terrainTexture   = terrainTexture,
		terrainHeightMap = terrainHeightMap,
		camera           = get_new_camera(),
		// editing          = false,
		allResources     = resources,
		player_mode      = PlayerMode.Viewing,
	}

	// for i in 0 ..< 2 {
	// 	cubeEntity := ThreeDeeEntity {
	// 		// mesh     = cubeMesh,
	// 		// model    = cubeModel,
	// 		position = rl.Vector3{f32(i), 1., f32(i * 2)},
	// 		type     = ModelType.Cube,
	// 		color    = rl.BROWN,
	// 		bb       = cubeBB,
	// 	}
	// 	append(&g.cubes, cubeEntity)
	// }

	for i in 0 ..< 2 {
		wareHouseEntity := ThreeDeeEntity {
			position = rl.Vector3{f32(i * 50) + 15, 1., f32(i * 50) + 15},
			type     = ModelType.Rectangle,
			color    = rl.ORANGE,
			bb       = rectBB,
		}
		append(&g.travelPoints, wareHouseEntity)
	}

	// for i in 0 ..< 1 {
	// 	boatEntity := ThreeDeeEntity {
	// 		position = rl.Vector3{f32(i), 2., f32(i)},
	// 		type     = ModelType.Boat,
	// 		bb       = boatBb,
	// 	}
	// 	append(&g.cubes, boatEntity)
	// }

	// for i in 0 ..< 2 {
	// 	cubeEntity := ThreeDeeEntity {
	// 		// mesh     = cubeMesh,
	// 		// model    = cubeModel,
	// 		position = rl.Vector3{f32(i * 2), 1., f32(i)},
	// 		type     = ModelType.Rectangle,
	// 		bb       = rectBB,
	// 	}
	// 	append(&g.cubes, cubeEntity)
	// }


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
	rl.UnloadImage(g.terrainHeightMap)
	rl.UnloadTexture(g.terrainTexture)
	rl.UnloadModel(g.terrain.model)
	rl.UnloadModel(g.allResources.cubeModel)
	rl.UnloadModel(g.allResources.rectangleModel)
	// for i in 0 ..< len(g.cubes) {
	// 	rl.UnloadModel(g.cubes[i].model)
	// 	break
	// }
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
