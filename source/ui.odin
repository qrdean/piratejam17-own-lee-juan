package game

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

Selected_Entity_Action_Events :: [8]Event

Extra_UI_State :: enum {
	None,
	Output,
	Recipe,
	AddRemove,
}

SelectedEntity :: struct {
	id:                      int,
	using ThreeDeeEntity:    ThreeDeeEntity,
	selected_entity_actions: Selected_Entity_Action_Events,
}

Event :: struct {
	ButtonText: string,
	Data:       ButtonActions,
}

ButtonActions :: union {
	Place_Object,
	Spawn_Traveler,
	Select_Target,
	Output_View,
	Recipe_View,
	Counter_View,
	Recipe_Select,
	Delete_Building,
}

Place_Object :: struct {
	model: ModelType,
}

Spawn_Traveler :: struct {
	building_id: int,
	model:       ModelType,
	position:    rl.Vector3,
}

Select_Target :: struct {
	output_id: int,
}
Output_View :: struct {
	building_id: int,
}
Recipe_View :: struct {
	building_id: int,
}
Recipe_Select :: struct {
	recipe_type: RecipeType,
}
Delete_Building :: struct {
	building_id: int,
}
Counter_View :: struct {
	building_id: int,
}

GUI_X_SIZE :: 72
GUI_Y_SIZE :: 50
OFFSET_X :: 2

Gui_Buttons_Rectangles: [8]rl.Rectangle = {
	{22, 42, GUI_X_SIZE, GUI_Y_SIZE},
	{22 + GUI_X_SIZE + OFFSET_X, 42, GUI_X_SIZE, GUI_Y_SIZE},
	{22 + 2 * (GUI_X_SIZE + OFFSET_X), 42, GUI_X_SIZE, GUI_Y_SIZE},
	{22 + 3 * (GUI_X_SIZE + OFFSET_X), 42, GUI_X_SIZE, GUI_Y_SIZE},
	{22, 94, GUI_X_SIZE, GUI_Y_SIZE},
	{22 + GUI_X_SIZE + OFFSET_X, 94, GUI_X_SIZE, GUI_Y_SIZE},
	{22 + 2 * (GUI_X_SIZE + OFFSET_X), 94, GUI_X_SIZE, GUI_Y_SIZE},
	{22 + 3 * (GUI_X_SIZE + OFFSET_X), 94, GUI_X_SIZE, GUI_Y_SIZE},
}

get_default_actions :: proc() -> Selected_Entity_Action_Events {
	miner := Event{"Miner", Place_Object{model = ModelType.Miner}}
	transformer := Event{"Transformer", Place_Object{model = ModelType.Construct}}
	constructor := Event{"Constructor", Place_Object{model = ModelType.Assemble}}
	assembler := Event{"Assembler", Place_Object{model = ModelType.Manufacturer}}
	switch g.turn_in_info.goal_type {
	case .Done:
	case .TierOne:
		constructor = Event{}
		assembler = Event{}
	case .TierTwo:
		assembler = Event{}
	}
	return Selected_Entity_Action_Events {
		miner,
		transformer,
		constructor,
		assembler,
		{},
		{},
		{},
		{},
	}
}

get_recipe_list_miner :: proc() -> Selected_Entity_Action_Events {
	opened := Event{"Opened", Recipe_Select{recipe_type = .CanOpened}}
	return Selected_Entity_Action_Events{opened, {}, {}, {}, {}, {}, {}, {}}
}

get_recipe_list :: proc() -> Selected_Entity_Action_Events {
	flat := Event{"Flat", Recipe_Select{recipe_type = .CanFlat}}
	strips := Event{"Strips", Recipe_Select{recipe_type = .CanStrips}}
	nails := Event{"Nails", Recipe_Select{recipe_type = .CanNails}}
	rings := Event{"Rings", Recipe_Select{recipe_type = .CanRing}}
	switch g.turn_in_info.goal_type {
	case .Done:
	case .TierOne:
		nails = Event{}
		rings = Event{}
	case .TierTwo:
		nails = Event{}
		rings = Event{}
	}
	return Selected_Entity_Action_Events{flat, strips, nails, rings, {}, {}, {}, {}}
}

get_recipe_list_assembly :: proc() -> Selected_Entity_Action_Events {
	reinforce := Event{"Reinforce", Recipe_Select{recipe_type = .CanReinforced}}
	rotator := Event{"Rotator", Recipe_Select{recipe_type = .CanRotator}}
	switch g.turn_in_info.goal_type {
	case .Done:
	case .TierOne:
		reinforce = Event{}
		rotator = Event{}
	case .TierTwo:
		reinforce = Event{}
	}
	return Selected_Entity_Action_Events{reinforce, rotator, {}, {}, {}, {}, {}, {}}
}

get_recipe_list_final :: proc() -> Selected_Entity_Action_Events {
	motor := Event{"Motor", Recipe_Select{recipe_type = .CanMotor}}
	propellor := Event{"Propellor", Recipe_Select{recipe_type = .CanPropeller}}
	helm := Event{"Helm", Recipe_Select{recipe_type = .CanHelm}}
	rudder := Event{"Rutter", Recipe_Select{recipe_type = .CanRutter}}
	hull := Event{"Hull", Recipe_Select{recipe_type = .CanHull}}
	switch g.turn_in_info.goal_type {
	case .Done:
	case .TierOne:
		motor = Event{}
		propellor = Event{}
		helm = Event{}
		rudder = Event{}
		hull = Event{}
	case .TierTwo:
		motor = Event{}
		propellor = Event{}
		helm = Event{}
		rudder = Event{}
		hull = Event{}
	}
	return Selected_Entity_Action_Events{motor, propellor, helm, rudder, hull, {}, {}, {}}
}

get_selected_entity_action_events_cube :: proc(
	building_id: int,
	modelType: ModelType,
	position: rl.Vector3,
) -> Selected_Entity_Action_Events {
	return Selected_Entity_Action_Events {
		{"Add", Spawn_Traveler{building_id = building_id, model = modelType, position = position}},
		{"Output", Output_View{building_id = building_id}},
		{"Recipe", Recipe_View{building_id = building_id}},
		{"Delete", Delete_Building{building_id = building_id}},
		{"AddRemove", Counter_View{building_id = building_id}},
		{},
		{},
		{},
	}
}

get_selected_entity_action_events_travel :: proc() -> Selected_Entity_Action_Events {
	return Selected_Entity_Action_Events{{"Target", Select_Target{}}, {}, {}, {}, {}, {}, {}, {}}
}

get_selected_entity_actions_events_output :: proc() -> Selected_Entity_Action_Events {
	return Selected_Entity_Action_Events {
		{"Output 1", Select_Target{output_id = 0}},
		{"Output 2", Select_Target{output_id = 1}},
		{"Output 3", Select_Target{output_id = 2}},
		{"Output 4", Select_Target{output_id = 3}},
		{"Output 5", Select_Target{output_id = 4}},
		{"Output 6", Select_Target{output_id = 5}},
		{"Output 7", Select_Target{output_id = 6}},
		{"Output 8", Select_Target{output_id = 7}},
	}
}

handle_button :: proc() -> bool {
	if g.button_event.Data != nil {
		switch d in g.button_event.Data {
		case Place_Object:
			g.current_placing_info.modelType = d.model
			g.current_placing_info.collision_info = false
			g.player_mode = .Placing
			g.current_extra_ui_state = .None
		case Spawn_Traveler:
			fmt.println(d)
			spawn_travel_entity(d.building_id, d.position, d.model)
			unhighlight_all_travelers()
		case Select_Target:
			g.player_mode = .Selecting
			g.current_output_info.output_id = d.output_id
			g.current_extra_ui_state = .None
		case Output_View:
			if g.current_extra_ui_state == .Output {
				g.current_extra_ui_state = .None
			} else {
				g.current_extra_ui_state = .Output
				g.current_output_info.building_id = d.building_id
			}
			// NOTE: could be slow with a lot of travelers. careful here. Could change to access 
			// Because traveler is tied to a building Id could add the ability to 
			// change this handle a set of keys in a map?
			highlight_all_travelers_by_id(d.building_id)
		case Recipe_View:
			if g.current_extra_ui_state == .Recipe {
				g.current_extra_ui_state = .None
			} else {
				g.current_extra_ui_state = .Recipe
				g.current_recipe_info.building_id = d.building_id
			}
			unhighlight_all_travelers()
		case Counter_View:
			if g.current_extra_ui_state == .AddRemove {
				g.current_extra_ui_state = .None
			} else {
				g.current_extra_ui_state = .AddRemove
			}
		case Recipe_Select:
			g.current_recipe_info.recipe_type = d.recipe_type
			for i in 0 ..< len(g.travelPoints) {
				if g.current_recipe_info.building_id == i {
					set_constructor_recipe(&g.travelPoints[i], d.recipe_type)
					break
				}
			}
			g.current_extra_ui_state = .None
		case Delete_Building:
			delete_factory_from_world(d.building_id)
		case:
			fmt.println("unhandled?")
		}
		g.button_event.Data = nil
		return true
	}
	return false
}

GuiPanelSize :: enum {
	Normal,
	Large,
}

get_gui_panel_rectangle_position :: proc(x, y: f32) -> rl.Rectangle {
	return rl.Rectangle{x, y, 300, 132}
}

draw_default_button_ui :: proc() {
	rl.GuiEnable()
	rl.GuiPanel(
		get_gui_panel_rectangle_position(
			f32(rl.GetScreenWidth()) - 320,
			f32(rl.GetScreenHeight()) - 194,
		),
		// rl.Rectangle{f32(rl.GetScreenWidth()) - 240, f32(rl.GetScreenHeight()) - 194, 210, 128},
		fmt.ctprintf("Actions"),
	)

	actions := get_default_actions()
	for i in 0 ..< len(actions) {
		gui_button_rectangle := Gui_Buttons_Rectangles[i]
		gui_button_rectangle.x = gui_button_rectangle.x + (f32(rl.GetScreenWidth()) - 340)
		gui_button_rectangle.y = gui_button_rectangle.y + (f32(rl.GetScreenHeight()) - 210)
		if actions[i].Data != nil {
			if rl.GuiButton(gui_button_rectangle, fmt.ctprintf("%s", actions[i].ButtonText)) {
				g.button_event = actions[i]
			}
		}
	}
}

draw_extra_ui_layer :: proc(name: string, selected_buttons: Selected_Entity_Action_Events) {
	rl.GuiPanel(
		get_gui_panel_rectangle_position(20, f32(rl.GetScreenHeight()) - 330),
		fmt.ctprintf(name),
	)
	// rl.GuiPanel(rl.Rectangle{20, 154, 212, 132}, fmt.ctprintf(name))
	rl.GuiEnable()
	for i in 0 ..< len(selected_buttons) {
		gui_button_rectangle := Gui_Buttons_Rectangles[i]
		gui_button_rectangle.y = gui_button_rectangle.y + (f32(rl.GetScreenHeight()) - 347)
		if selected_buttons[i].Data != nil {
			if rl.GuiButton(
				gui_button_rectangle,
				fmt.ctprintf("%s", selected_buttons[i].ButtonText),
			) {
				g.button_event = selected_buttons[i]
			}
		}
	}
}

spinner_current_val: i32
input_output_combo_val: i32
item_type_combo_val: i32

draw_counter_ui :: proc(name: string, selected: SelectedEntity) {
	rl.GuiEnable()
	rl.GuiPanel(
		get_gui_panel_rectangle_position(20, f32(rl.GetScreenHeight()) - 330),
		fmt.ctprintf(name),
	)
	rl.GuiSpinner(
		rl.Rectangle{22, f32(rl.GetScreenHeight()) - 305, 120, 30},
		"text",
		&spinner_current_val,
		-250,
		250,
		true,
	)

	// Clamp values
	if spinner_current_val > 250 {
		spinner_current_val = 250
	} else if spinner_current_val < 0 {
		spinner_current_val = 0
	}

	input_key_map := make(map[i32]ItemType)
	output_key_map := make(map[i32]ItemType)
	input: i32 = 0
	output: i32 = 0
	defer delete(input_key_map)
	defer delete(output_key_map)
	b := strings.builder_make(context.temp_allocator)
	c := strings.builder_make(context.temp_allocator)
	for key in get_recipe_from_memory(g.travelPoints[selected.id].recipe_type).input_map {
		input_key_map[input] = key
		if input == 0 {
			fmt.sbprintf(&b, "%s", item_type_to_string(key))
		} else {
			fmt.sbprintf(&b, ";%s", item_type_to_string(key))
		}
		input += 1
	}
	for key in get_recipe_from_memory(g.travelPoints[selected.id].recipe_type).output_map {
		output_key_map[output] = key
		if output == 0 {
			fmt.sbprintf(&c, "%s", item_type_to_string(key))
		} else {
			fmt.sbprintf(&c, ";%s", item_type_to_string(key))
		}
		output += 1
	}
	if rl.GuiButton(rl.Rectangle{22, f32(rl.GetScreenHeight()) - 270, 50, 30}, "Give") {
		// Take from Inventory put into machine
		if spinner_current_val != 0 {
			if input_output_combo_val == 0 {
				// input
				item_type := input_key_map[item_type_combo_val]
				if item_type != .None {
					amount_received := remove_from_inventory(item_type, spinner_current_val)
					if !add_qty_to_input_by_type(
						&g.travelPoints[selected.id],
						item_type,
						spinner_current_val,
					) {
						add_to_inventory(item_type, amount_received)
					}
				}
			} else {
				// ouput
				item_type := output_key_map[item_type_combo_val]
				if item_type != .None {
					amount_received := remove_from_inventory(item_type, spinner_current_val)
					if !add_qty_to_output_by_type(
						&g.travelPoints[selected.id],
						item_type,
						spinner_current_val,
					) {
						add_to_inventory(item_type, amount_received)
					}
				}
			}
		}
		// reset values
		spinner_current_val = 0
	}
	if rl.GuiButton(
		rl.Rectangle{22 + GUI_X_SIZE + 2, f32(rl.GetScreenHeight()) - 270, 50, 30},
		"Take",
	) {
		// Take from Machine put into Inventory
		if spinner_current_val != 0 {
			if input_output_combo_val == 0 {
				// input
				item_type := input_key_map[item_type_combo_val]
				if item_type != .None {
					amount_received := remove_qty_from_input_item_type(
						&g.travelPoints[selected.id],
						item_type,
						spinner_current_val,
					)
					add_to_inventory(item_type, amount_received)
					spinner_current_val = 0
				}
			} else {
				// ouput
				item_type := output_key_map[item_type_combo_val]
				if item_type != .None {
					amount_received := remove_qty_from_output(
						&g.travelPoints[selected.id],
						item_type,
						spinner_current_val,
					)
					add_to_inventory(item_type, amount_received)
					spinner_current_val = 0
				}
			}
		}
		// reset values
	}
	rl.GuiComboBox(
		rl.Rectangle{22, f32(rl.GetScreenHeight()) - 235, 125, 30},
		"Input;Output",
		&input_output_combo_val,
	)
	if input_output_combo_val == 0 {
		res, _ := strings.to_cstring(&b)
		rl.GuiComboBox(
			rl.Rectangle{22 + 130, f32(rl.GetScreenHeight()) - 235, 125, 30},
			res,
			&item_type_combo_val,
		)
	} else {
		res, _ := strings.to_cstring(&c)
		rl.GuiComboBox(
			rl.Rectangle{22 + 130, f32(rl.GetScreenHeight()) - 235, 125, 30},
			res,
			&item_type_combo_val,
		)
	}
}

draw_button_ui :: proc(selected: SelectedEntity) {
	if selected.type == .None {
		return
	}
	rl.GuiEnable()
	rl.GuiPanel(
		get_gui_panel_rectangle_position(20, f32(rl.GetScreenHeight()) - 194),
		fmt.ctprintf("%s", type_to_string(selected.type)),
	)
	switch g.current_extra_ui_state {
	case .None:
	// do nothing
	case .Output:
		draw_extra_ui_layer("Outputs", get_selected_entity_actions_events_output())
	case .Recipe:
		#partial switch selected.type {
		case .Miner:
			draw_extra_ui_layer("Recipes", get_recipe_list_miner())
		case .Construct:
			draw_extra_ui_layer("Recipes", get_recipe_list())
		case .Assemble:
			draw_extra_ui_layer("Recipes", get_recipe_list_assembly())
		case .Manufacturer:
			draw_extra_ui_layer("Recipes", get_recipe_list_final())
		case:
			draw_extra_ui_layer("Recipes", get_recipe_list())
		}
	case .AddRemove:
		draw_counter_ui("Add & Remove", selected)
	}

	for i in 0 ..< len(selected.selected_entity_actions) {
		if selected.selected_entity_actions[i].Data == nil {
			rl.GuiDisable()
			return
		}
		gui_button_rectangle := Gui_Buttons_Rectangles[i]
		gui_button_rectangle.y = gui_button_rectangle.y + (f32(rl.GetScreenHeight()) - 210)
		if rl.GuiButton(
			gui_button_rectangle,
			fmt.ctprintf("%s", selected.selected_entity_actions[i].ButtonText),
		) {
			g.button_event = selected.selected_entity_actions[i]
		}
	}
}

draw_entity_info_ui :: proc(selected: SelectedEntity) {
	if selected.type == .None {
		return
	}
	rl.GuiEnable()
	rl.GuiPanel(
		get_gui_panel_rectangle_position(330, f32(rl.GetScreenHeight()) - 194),
		fmt.ctprintf("Info"),
	)
	travel_point_info := g.travelPoints[g.selected.id]
	recipe := get_recipe_from_memory(travel_point_info.recipe_type)
	a := fmt.ctprintf(
		"\nRecipe: %v\nIn: %v\nOut: %v\nCurrent\nIn: %v\nOut: %v",
		get_recipe_name(travel_point_info.recipe_type),
		get_item_map_text(recipe.input_map),
		get_item_map_text(recipe.output_map),
		get_item_map_text(travel_point_info.current_inputs),
		get_item_map_text(travel_point_info.current_outputs),
	)
	draw_construction_time(520, rl.GetScreenHeight() - 166)
	rl.GuiTextBox(
		get_gui_panel_rectangle_position(330, f32(rl.GetScreenHeight()) - 194),
		a,
		1024,
		false,
	)
}
