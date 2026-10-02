package main

import "core:fmt"
import "ring_buf_snake"
import rl "vendor:raylib"

W_WIDTH :: 200
W_HEIGHT :: 200
WIN_TITLE :: "snake"
TARGET_FPS :: 60

MAP_WIDTH :: 20
MAP_HEIGHT :: 20

Vec2 :: [2]f32
GameMap :: [MAP_HEIGHT][MAP_WIDTH]Tile

Snake :: union {
	ring_buf_snake.Snake,
}

Tile :: enum u8 {
	TileEmpty,
	TileFood,
	TileSnakeBody,
}

Game :: struct {
	snake:    Snake,
	game_map: ^GameMap,
}


main :: proc() {
	rl.InitWindow(W_WIDTH, W_HEIGHT, WIN_TITLE)
	rl.SetTargetFPS(TARGET_FPS)

	game_map := create_game_map()
	g := &Game{snake = ring_buf_snake.Snake{}, game_map = &game_map}

	interval := 0
	timer := 0

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.WHITE)
		rl.DrawText(fmt.ctprintf("fdsfjkl"), 16, 10, 20, rl.WHITE)

		for timer >= interval {
			timer -= interval
			fmt.printf("second elapsed")
		}

		rl.EndDrawing()
	}
	rl.CloseWindow()
}

create_game_map :: proc() -> GameMap {
	g := GameMap{}
	for &row, ri in &g {
		for &tile, ti in &row {
			tile = .TileEmpty
		}
	}
	return GameMap{}
}
