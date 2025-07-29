package game

import rl "vendor:raylib"

LogoInfo :: struct {
	state:                 LogoState,
	alpha:                 f32,
	frames_counter:        i32,
	letters_count:         i32,
	top_side_rec_width:    i32,
	left_side_rec_height:  i32,
	bottom_side_rec_width: i32,
	right_side_rec_height: i32,
}

LogoState :: enum {
	One,
	Two,
	Three,
	Four,
	Five,
}

logo_update :: proc(logo_info: ^LogoInfo) {
	switch logo_info.state {
	case .One:
		logo_info.frames_counter += 1
		if logo_info.frames_counter == 120 {
			logo_info.state = .Two
			logo_info.frames_counter = 0
		}
	case .Two:
		logo_info.top_side_rec_width += 4
		logo_info.left_side_rec_height += 4
		if logo_info.top_side_rec_width == 256 {
			logo_info.state = .Three
		}
	case .Three:
		logo_info.bottom_side_rec_width += 4
		logo_info.right_side_rec_height += 4
		if logo_info.bottom_side_rec_width == 256 {
			logo_info.state = .Four
		}
	case .Four:
		logo_info.frames_counter += 1
		if bool(logo_info.frames_counter / 12) {
			logo_info.letters_count += 1
			logo_info.frames_counter = 0
		}
		if logo_info.frames_counter >= 10 {
			logo_info.alpha -= 0.02

			if (logo_info.alpha <= 0.) {
				logo_info.alpha = 0.
				logo_info.state = .Five
			}
		}
	case .Five:
		g.game_state = .Title
	}
}

logo_draw :: proc(logo_info: LogoInfo) {
	logo_position_x: i32 = rl.GetScreenWidth() / 2 - 128
	logo_position_y: i32 = rl.GetScreenHeight() / 2 - 128
	rl.BeginDrawing()
	rl.ClearBackground(rl.SKYBLUE)
	switch logo_info.state {
	case .One:
		if bool((logo_info.frames_counter / 15) % 2) {
			rl.DrawRectangle(logo_position_x, logo_position_y, 16, 16, rl.BLACK)
		}
	case .Two:
		rl.DrawRectangle(
			logo_position_x,
			logo_position_y,
			logo_info.top_side_rec_width,
			16,
			rl.BLACK,
		)
		rl.DrawRectangle(
			logo_position_x,
			logo_position_y,
			16,
			logo_info.left_side_rec_height,
			rl.BLACK,
		)
	case .Three:
		rl.DrawRectangle(
			logo_position_x,
			logo_position_y,
			logo_info.top_side_rec_width,
			16,
			rl.BLACK,
		)
		rl.DrawRectangle(
			logo_position_x,
			logo_position_y,
			16,
			logo_info.left_side_rec_height,
			rl.BLACK,
		)

		rl.DrawRectangle(
			logo_position_x + 240,
			logo_position_y,
			16,
			logo_info.right_side_rec_height,
			rl.BLACK,
		)
		rl.DrawRectangle(
			logo_position_x,
			logo_position_y + 240,
			logo_info.bottom_side_rec_width,
			16,
			rl.BLACK,
		)
	case .Four:
		rl.DrawRectangle(
			logo_position_x,
			logo_position_y,
			logo_info.top_side_rec_width,
			16,
			rl.Fade(rl.BLACK, logo_info.alpha),
		)
		rl.DrawRectangle(
			logo_position_x,
			logo_position_y,
			16,
			logo_info.left_side_rec_height,
			rl.Fade(rl.BLACK, logo_info.alpha),
		)

		rl.DrawRectangle(
			logo_position_x + 240,
			logo_position_y,
			16,
			logo_info.right_side_rec_height,
			rl.Fade(rl.BLACK, logo_info.alpha),
		)
		rl.DrawRectangle(
			logo_position_x,
			logo_position_y + 240,
			logo_info.bottom_side_rec_width,
			16,
			rl.Fade(rl.BLACK, logo_info.alpha),
		)
		rl.DrawRectangle(
			rl.GetScreenWidth() / 2 - 112,
			rl.GetScreenHeight() / 2 - 112,
			224,
			224,
			rl.Fade(rl.SKYBLUE, logo_info.alpha),
		)

		rl.DrawText(
			"made with",
			rl.GetScreenWidth() / 2 - 66,
			rl.GetScreenHeight() / 2 + 20,
			36,
			rl.Fade(rl.BLACK, logo_info.alpha),
		)

		rl.DrawText(
			rl.TextSubtext("raylib", 0, logo_info.letters_count),
			rl.GetScreenWidth() / 2 - 44,
			rl.GetScreenHeight() / 2 + 48,
			50,
			rl.Fade(rl.BLACK, logo_info.alpha),
		)
	case .Five:
	}
	rl.EndDrawing()
}
