package snake_game

import "../ring_buf_snake"
import "core:fmt"
import rl "vendor:raylib"

W_WIDTH :: 800
W_HEIGHT :: 600
WIN_TITLE :: "snake"
TARGET_FPS :: 60

MAP_WIDTH :: 20
MAP_HEIGHT :: 20

TICK_INTERVAL: f32 = 1.0

Vec2 :: [2]int
GameMap :: [MAP_HEIGHT][MAP_WIDTH]Tile


Tile :: enum u8 {
	TileEmpty,
	TileFood,
	TileSnakeBody,
}

Game :: struct {
	snake:    ^Snake,
	game_map: ^GameMap,
}

Direction :: enum {
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

DIR_OFFSETS := [Direction]Vec2 {
	.UP    = {0, -1},
	.DOWN  = {0, 1},
	.LEFT  = {-1, 0},
	.RIGHT = {1, 0},
}


run :: proc() {
	rl.InitWindow(W_WIDTH, W_HEIGHT, WIN_TITLE)
	rl.SetTargetFPS(TARGET_FPS)

	game_map := game_map_create()
	s := snake_new(10, Vec2{0, 0})
	defer free(s)
	g := &Game{snake = s, game_map = &game_map}

	timer: f32 = 0.0
	curr_direction: Direction = .RIGHT

	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()

		if rl.IsKeyPressed(.LEFT) do curr_direction = .LEFT
		if rl.IsKeyPressed(.RIGHT) do curr_direction = .RIGHT
		if rl.IsKeyPressed(.UP) do curr_direction = .UP
		if rl.IsKeyPressed(.DOWN) do curr_direction = .DOWN

		timer += dt

		if timer >= TICK_INTERVAL {
			fmt.print("game tick!\n")

			game_tick(g.snake, curr_direction)

			timer -= TICK_INTERVAL
		}

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		game_map_draw(g.game_map)
		snake_draw(g.snake, 10)

		rl.EndDrawing()
	}
	rl.CloseWindow()
}

game_map_create :: proc() -> GameMap {
	g := GameMap{}
	for &row, ri in &g {
		for &tile, ti in &row {
			tile = .TileEmpty
		}
	}
	return g
}
game_map_draw :: proc(game_map: ^GameMap) {
	for row, y in game_map {
		for tile, x in row {
			da_x := i32(x) * 10
			da_y := i32(y) * 10
			rl.DrawRectangle(da_x, da_y, 4, 4, rl.BLUE)
		}
	}
}

game_tick :: proc(s: ^Snake, curr_direction: Direction) {
	curr_head := snake_get_current_head_pos(s)
	dir := DIR_OFFSETS[curr_direction]
	new_head := Vec2{curr_head.x + dir.x, curr_head.y + dir.y}
	if new_head.x < 0 || new_head.x >= MAP_WIDTH || new_head.y < 0 || new_head.y >= MAP_HEIGHT {
		fmt.printf("snake hit the wal!\n")
		return
	}
	is_food_tile := false
	if is_food_tile {
		snake_grow(s, new_head)
	} else {
		snake_move(s, new_head)
	}
}

Snake :: struct {
	tail: int,
	head: int,
	size: int,
	cap:  int,
	arr:  [dynamic]Vec2,
}

snake_new :: proc(max_size: int, start_pos: Vec2) -> ^Snake {
	s := new(Snake)
	s.tail = 0
	s.head = 1
	s.size = 1
	s.cap = max_size
	s.arr = make([dynamic]Vec2, max_size)

	s.arr[0] = start_pos
	return s
}


snake_move :: proc(s: ^Snake, new_head_pos: Vec2) {
	s.arr[s.head] = new_head_pos
	s.head = (s.head + 1) % s.cap
	s.tail = (s.tail + 1) % s.cap
}

snake_grow :: proc(s: ^Snake, new_head_pos: Vec2) {
	if s.size >= s.cap {
		return
	}

	s.arr[s.head] = new_head_pos
	s.head = (s.head + 1) % s.cap
	s.size += 1
}

snake_draw :: proc(s: ^Snake, cell_size: int) {
	curr_index := s.tail
	for i := 0; i < s.size; i += 1 {
		pos := s.arr[curr_index]
		rl.DrawRectangle(i32(pos.x * cell_size), i32(pos.y * cell_size), 10, 10, rl.RED)
		curr_index = (curr_index + 1) % s.cap
	}
}

snake_get_current_head_pos :: proc(s: ^Snake) -> Vec2 {
	last_head_idx := (s.head - 1 + s.cap) % s.cap
	return s.arr[last_head_idx]
}
