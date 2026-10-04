package snake_game

import "core:fmt"
import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

SCREEN_WIDTH :: 800
SCREEN_HEIGHT :: 600
WIN_TITLE :: "snake"
TARGET_FPS :: 60

MAP_WIDTH :: 20
MAP_HEIGHT :: 20

TICK_INTERVAL: f32 = 0.3

CELL_SIZE :: 24 // px
GAP :: 2 // px
MAP_SCREEN_WIDTH :: MAP_WIDTH * CELL_SIZE
MAP_SCREEN_HEIGHT :: MAP_HEIGHT * CELL_SIZE
ORIGIN_X :: (SCREEN_WIDTH - MAP_SCREEN_WIDTH) / 2
ORIGIN_Y :: (SCREEN_HEIGHT - MAP_SCREEN_HEIGHT) / 2

Vec2 :: [2]int
GameMap :: [MAP_HEIGHT][MAP_WIDTH]Tile


Tile :: enum u8 {
	TileEmpty,
	TileFood,
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

food_gen :: proc() -> Vec2 {
	rand_x := int(rand.int31_max(MAP_WIDTH))
	rand_y := int(rand.int31_max(MAP_HEIGHT))
	return Vec2{rand_x, rand_y}
}
food_clean :: proc(g: ^Game, v: Vec2) {
	g.game_map[v.y][v.x] = .TileEmpty
}

run :: proc() {

	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, WIN_TITLE)
	rl.SetTargetFPS(TARGET_FPS)

	game_map := game_map_create()
	s := snake_new(10, Vec2{MAP_WIDTH / 2, MAP_HEIGHT / 2})
	defer free(s)
	g := &Game{snake = s, game_map = &game_map}
	a := food_gen()
	g.game_map[a.x][a.y] = .TileFood

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

			game_tick(g.snake, g, curr_direction)

			timer -= TICK_INTERVAL
		}

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		game_map_draw(g.game_map)
		snake_draw(g.snake)

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
			da_x := i32(ORIGIN_X + (x * CELL_SIZE))
			da_y := i32(ORIGIN_Y + (y * CELL_SIZE))
			rl.DrawRectangleLines(da_x, da_y, CELL_SIZE, CELL_SIZE, rl.DARKGRAY)

			tile_x := da_x + GAP
			tile_y := da_y + GAP
			tile_size := i32(CELL_SIZE - (GAP * 2))
			switch tile {
			case .TileEmpty:
				rl.DrawRectangle(tile_x, tile_y, tile_size, tile_size, rl.BLUE)
			case .TileFood:
				rl.DrawRectangle(tile_x, tile_y, tile_size, tile_size, rl.GREEN)
			}
		}
	}
}

game_tick :: proc(s: ^Snake, g: ^Game, curr_direction: Direction) {
	curr_head := snake_get_current_head_pos(s)
	dir := DIR_OFFSETS[curr_direction]
	new_head := Vec2{curr_head.x + dir.x, curr_head.y + dir.y}
	if new_head.x < 0 || new_head.x >= MAP_WIDTH || new_head.y < 0 || new_head.y >= MAP_HEIGHT {
		fmt.printf("snake hit the wal!\n")
		return
	}

	is_food_tile := g.game_map[new_head.y][new_head.x] == .TileFood

	if is_food_tile {
		snake_grow(s, new_head)
		food_clean(g, Vec2{new_head.x, new_head.y})
		a := food_gen()
		g.game_map[a.y][a.x] = .TileFood
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
	s.head = snake_next_index(s, s.head)
	s.tail = snake_next_index(s, s.tail)
}

snake_grow :: proc(s: ^Snake, new_head_pos: Vec2) {
	if s.size >= s.cap {
		return
	}

	s.arr[s.head] = new_head_pos
	s.head = snake_next_index(s, s.head)
	s.size += 1
}

snake_draw :: proc(s: ^Snake) {
	curr_index := s.tail
	for _ in 0 ..< s.size {
		pos := s.arr[curr_index]
		screen_x := ORIGIN_X + (pos.x * CELL_SIZE)
		screen_y := ORIGIN_Y + (pos.y * CELL_SIZE)
		rl.DrawRectangle(
			i32(screen_x + GAP),
			i32(screen_y + GAP),
			CELL_SIZE - (GAP * 2),
			CELL_SIZE - (GAP * 2),
			rl.RED,
		)
		curr_index = snake_next_index(s, curr_index)
	}
}

snake_get_current_head_pos :: proc(s: ^Snake) -> Vec2 {
	last_head_idx := (s.head - 1 + s.cap) % s.cap
	return s.arr[last_head_idx]
}

snake_next_index :: proc(s: ^Snake, curr_index: int) -> int {
	return (curr_index + 1) % s.cap
}
