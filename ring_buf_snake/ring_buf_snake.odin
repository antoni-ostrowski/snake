package ring_buf_snake

import rl "vendor:raylib"

Vec2 :: [2]int

Snake :: struct {
	tail: int,
	head: int,
	size: int,
	cap:  int,
	arr:  [dynamic]Vec2,
}

new :: proc(max_size: int, start_pos: Vec2) -> Snake {
	s := Snake {
		tail = 0,
		head = 1,
		size = 1,
		cap  = max_size,
		arr  = make([dynamic]Vec2, max_size),
	}
	s.arr[0] = start_pos
	return s
}


move :: proc(s: ^Snake, new_head_pos: Vec2) {
	s.arr[s.head] = new_head_pos
	s.head = (s.head + 1) % s.cap
	s.tail = (s.tail + 1) % s.cap
}

grow :: proc(s: ^Snake, new_head_pos: Vec2) {
	if s.size >= s.cap {
		return
	}

	s.arr[s.head] = new_head_pos
	s.head = (s.head + 1) % s.cap
	s.size += 1
}

draw :: proc(s: ^Snake, cell_size: int) {
	curr_index := s.tail
	for i := 0; i < s.size; i += 1 {
		pos := s.arr[curr_index]
		rl.DrawRectangle(i32(pos.x * cell_size), i32(pos.y * cell_size), 10, 10, rl.RED)
		curr_index = (curr_index + 1) % s.cap
	}
}

get_current_head_pos :: proc(s: ^Snake) -> Vec2 {
	last_head_idx := (s.head - 1 + s.cap) % s.cap
	return s.arr[last_head_idx]
}
