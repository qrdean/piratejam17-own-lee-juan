package game

import "core:fmt"
import "core:strings"

TutorialStep :: enum {
	First,
	Second,
	None,
}

get_tutorial_message :: proc(step: TutorialStep) -> string {
	switch step {
	case .None:
		return ""
	case .First:
		b := strings.builder_make(context.temp_allocator)
		message := "Hey there. Good to see you survived!"
		fmt.sbprintf(&b, "%s\n", message)
		message = "You and your cats crash landed in\nthe middle of the ocean."
		fmt.sbprintf(&b, "\n%s\n", message)
		message = "Luckily, you have 1000's of cats\nand even more cans of cat food!"
		fmt.sbprintf(&b, "%s\n", message)
		message = "Using your ingenuity you need\nto build a boat to get out of here!"
		fmt.sbprintf(&b, "%s\n", message)
		message = "Good Luck!"
		fmt.sbprintf(&b, "\n%s\n", message)
		return strings.to_string(b)
	case .Second:
		b := strings.builder_make(context.temp_allocator)
		message := "Press 'R' and pick the 'miner' building in\nthe right corner."
		fmt.sbprintf(&b, "%s\n", message)
		message = "Place this on top of the cat cans\nsquare to start opening up cans."
		fmt.sbprintf(&b, "%s\n", message)
		message =
		"Pick a 'Transformer' building. Once this\nis placed go into edit mode\n('R') and click on the miner building again"
		fmt.sbprintf(&b, "\n%s\n", message)
		message =
		"Click 'output'->'output 1' and select the\n'Transformer' building. This links\nthe origin building to the destination."
		fmt.sbprintf(&b, "%s\n", message)
		message = "Click 'Add' to add a worker"
		fmt.sbprintf(&b, "%s\n", message)
		message = "Click 'Transformer'->'Recipe' button.\nClick 'Flat'."
		fmt.sbprintf(&b, "%s\n", message)
		message =
		"This sets the output recipe to 'Flat'.\nYou can see the required inputs\nand outputs in the bottom screen."
		fmt.sbprintf(&b, "%s\n", message)
		message =
		"Complete the Objective.\nConnect the 'Transformer' to the 'Cup'\nat the bottom of the island."
		fmt.sbprintf(&b, "\n%s\n", message)
		message = "Press 'K' to open controls \nand 'T' to show this again"
		fmt.sbprintf(&b, "%s\n", message)
		return strings.to_string(b)
	}
	return ""
}

get_next_step :: proc(step: TutorialStep) -> TutorialStep {
	switch step {
	case .None:
		return .None
	case .First:
		return .Second
	case .Second:
		return .None
	}
	return .None
}
