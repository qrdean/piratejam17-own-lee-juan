package game

import "core:fmt"
import rl "vendor:raylib"

Selected_Entity_Actions :: [9]string
Selected_Entity_Action_Events :: [9]Event

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
}

Place_Object :: struct {
	model: ModelType,
}

Spawn_Traveler :: struct {
	model:    ModelType,
	position: rl.Vector3,
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
		{"Cube", Place_Object{model = ModelType.Cube}},
		{"Rect", Place_Object{model = ModelType.Rectangle}},
		{},
		{},
		{},
		{},
		{},
		{},
		{},
	}
}

get_selected_entity_action_events_cube :: proc(
	modelType: ModelType,
	position: rl.Vector3,
) -> Selected_Entity_Action_Events {
	return Selected_Entity_Action_Events {
		{"Add", Spawn_Traveler{model = modelType, position = position}},
		{},
		{},
		{},
		{},
		{},
		{},
		{},
		{},
	}
}

get_selected_entity_action_events :: proc(modelType: ModelType) -> Selected_Entity_Action_Events {
	switch modelType {
	case ModelType.Cube:
		return Selected_Entity_Action_Events {
			{"add", Spawn_Traveler{model = .Cube, position = rl.Vector3(0)}},
			{},
			{},
			{},
			{},
			{},
			{},
			{},
			{},
		}
	case ModelType.Rectangle:
		return Selected_Entity_Action_Events{}
	case ModelType.Boat:
		return Selected_Entity_Action_Events{}
	}
	return Selected_Entity_Action_Events{}
}

handle_button :: proc() {
	if g.button_event.Data != nil {
		fmt.println(g.button_event.ButtonText)
		switch d in g.button_event.Data {
		case Place_Object:
			g.current_placing_info.modelType = d.model
			g.current_placing_info.collision_info = false
			g.player_mode = .Placing
		case Spawn_Traveler:
			spawn_travel_entity(d.position, d.model)
		case:
			fmt.println("unhandled?")
		}
		g.button_event.Data = nil
	}
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
			if rl.GuiButton(gui_button_rectangle, fmt.ctprintf("%s", actions[i].ButtonText)) {
				g.button_event = actions[i]
			}
		}
	}
}

draw_button_ui :: proc(selected: SelectedEntity) {
	rl.GuiEnable()
	rl.GuiPanel(
		rl.Rectangle{20, 20, 210, 128},
		fmt.ctprintf("%s", type_to_string(selected.type)),
	)

	for i in 0 ..< len(selected.selected_entity_actions) {
		if selected.selected_entity_actions[i].Data == nil {
			rl.GuiDisable()
			return
		}
		if rl.GuiButton(
			Gui_Buttons_Rectangles[i],
			fmt.ctprintf("%s", selected.selected_entity_actions[i].ButtonText),
		) {
			g.button_event = selected.selected_entity_actions[i]
		}
	}
}
