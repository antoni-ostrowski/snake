package ring_buf_snake

Vec2 :: [2]f32

Snake :: struct {
	tail: i64,
	head: i64,
	arr:  [dynamic]Vec2,
	size: i64,
	move: proc(s: ^Snake, new_head_pos: Vec2),
	grow: proc(s: ^Snake, new_head_pos: Vec2),
	draw: proc(s: ^Snake),
}


move :: proc(s: ^Snake, new_head_pos: Vec2) {
	s.arr[s.head] = new_head_pos
	curr_cap := i64(cap(s.arr))
	s.head = (s.head + 1) % curr_cap
	s.tail = (s.tail + 1) % curr_cap
}

grow :: proc(s: ^Snake, new_head_pos: Vec2) {
	curr_cap := i64(cap(s.arr))

	if s.size == curr_cap {
		return
	}

	s.arr[s.head] = new_head_pos
	s.head = (s.head + 1) % curr_cap
	s.size += 1
}
draw :: proc(s: ^Snake) {
	curr_cap := i64(cap(s.arr))
	curr_index := s.tail
	for curr_index != s.head {
		segment_cords := s.arr[curr_index]
		// here draw the vec2
		curr_index := (curr_index + 1) % curr_cap

	}
}
