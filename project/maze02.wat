;; Move a pacman ghost around the screen by cursor keys.
;; Counts from 0..63 and uses counter/8 to pick one of the 8 images of the ghost from the artwork.

;; store x at address 0x200
;; store y at address 0x204
;; store ghost state counter at address 0x208

(module
 (import "js" "memory" (memory 1))
 (import "js" "table" (table 1 funcref))
 (global $canvas_width (import "js" "canvas_width") (mut i32))
 (global $canvas_height (import "js" "canvas_height") (mut i32))
 (global $artwork_width (import "js" "artwork_width") (mut i32))
 (global $artwork_height (import "js" "artwork_height") (mut i32))
 (global $canvas_addr (import "js" "canvas_addr") (mut i32))
 (global $artwork_addr (import "js" "artwork_addr") (mut i32))
 (func $console_log (import "js" "console_log") (param i32))
 (func $error_out_of_bounds (import "js" "error_out_of_bounds") (param i32) (param i32) (param i32))
 (func $random (import "js" "random") (param i32) (result i32))
 (func $calc_canvas_address (import "js" "calc_canvas_address") (param i32) (param i32) (result i32))
 (func $calc_artwork_address (import "js" "calc_artwork_address") (param i32) (param i32) (result i32))
 (func $clear_screen (import "js" "clear_screen") (param i32))
 (func $draw_image (import "js" "draw_image") (param i32) (param i32) (param i32) (param i32) (param i32))
 (func $draw_artwork (import "js" "draw_artwork") (param i32) (param i32) (param i32) (param i32) (param i32) (param i32))

(data (offset (i32.const 0x200))
    "\00\01\00\00"
    "\90\00\00\00"
    "\31\01\00\00"
)

(data (offset (i32.const 0x600))
    "\00\2c\00\00"
    ;;"\51\01\00\00"
    ;;"\31\01\00\00"				      ;;
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\00\00\00\00\00\00\00\00\00\01\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\01"
    "\01\00\01\01\00\01\01\01\01\00\01\00\01\01\01\00\00\00\00\01\01\01\01\00\00\00\00\00\00\00\00\01"
    "\01\00\01\00\00\00\01\00\00\00\01\00\00\00\00\00\00\00\00\01\00\00\00\00\00\00\00\00\00\00\00\01"
    "\01\00\01\00\00\00\01\00\01\01\01\01\01\01\01\01\01\00\00\01\00\00\01\01\01\01\01\01\01\01\00\01"
    "\01\00\01\00\00\00\00\00\01\00\00\00\00\00\00\00\00\00\00\01\00\00\00\00\00\00\00\00\00\01\00\01"
    "\01\00\01\01\01\01\01\00\01\00\01\01\01\01\01\01\01\00\00\01\00\00\00\00\00\00\00\00\00\01\00\01"
    "\01\00\00\00\00\00\00\00\00\00\00\00\01\00\00\00\00\00\00\01\00\00\00\00\00\00\00\01\01\01\00\01"
    "\01\00\01\01\01\01\01\01\01\01\01\01\01\01\01\00\00\00\01\01\00\00\00\00\00\00\00\01\00\00\00\01"
    "\01\00\01\00\00\00\00\00\00\00\00\00\01\00\00\00\00\00\01\00\00\00\00\00\00\00\00\01\00\00\00\01" ;;
    "\01\00\01\00\01\01\00\01\01\01\00\00\01\00\00\00\01\00\01\00\01\00\00\00\00\00\00\01\00\00\00\01"
    "\01\00\01\01\01\00\00\00\00\01\00\01\01\01\01\01\01\00\00\00\01\00\00\00\00\00\00\01\00\00\00\01"
    "\01\00\01\00\00\00\00\00\00\01\00\00\00\00\00\00\01\00\01\01\01\00\00\00\00\00\00\01\00\00\00\01"
    "\01\00\01\00\01\01\01\01\00\01\00\00\00\00\00\00\00\00\00\00\01\00\00\00\00\00\00\00\00\00\00\01"
    "\01\00\01\00\00\00\00\00\00\01\00\00\00\00\00\00\00\00\00\00\01\00\00\01\01\01\01\01\01\00\00\01"
    "\01\00\01\00\01\01\01\01\00\01\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\01\00\00\01"
    "\01\00\01\00\00\00\00\00\00\01\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\01\00\00\01"
    "\01\00\01\01\01\01\01\01\00\01\01\01\01\01\01\01\01\00\00\00\00\00\00\00\00\00\00\00\01\00\00\01"
    "\01\00\00\00\00\00\00\01\00\01\00\00\00\00\00\00\00\00\00\00\00\00\00\01\00\00\01\01\01\01\00\01"
    "\01\00\01\01\01\01\00\01\00\01\00\00\00\00\00\00\00\00\00\00\01\01\01\01\01\01\01\00\00\00\00\01"
    "\01\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
 )

 (func $step_maze (export "step_maze") (param $maze_addr i32) (param $progress i32)
    (local $maze_x i32) (local $maze_y i32) (local $maze_index i32)

    (local.set $maze_index (i32.const 0))
    (local.set $maze_x (i32.const 0))
    (local.set $maze_y (i32.const 0))

    block $done
          loop $repeat
    ;;       ...check the value of local variables...if at the end of the array br $done...

             (br_if $done (i32.ge_u (i32.load (local.get $maze_index) (local.get $maze_addr))))

    ;;       ...somewhere in here, call $draw_artwork...

             (i32.load8_u (i32.add (i32.add (i32.const 4 (local.get $maze_addr) (local.get $maze_index)))))

             if $maze_present
	     (call $draw_artwork (i32.const 0) (i32.const 0) (i32.const 16) (i32.const 16) (local.get $maze_x) (local.get $maze_y))
             end $maze_present

    ;;       ...update the value of local variables...

             local.get $maze_x
             i32.const 496
             i32.eq

             if $maze_xy
             (local.set $maze_x (i32.const 0))
             (local.set $maze_y (i32.add (local.get $maze_y) (i32.const 16)))

             else $maze_xy
             (local.set $maze_x (i32.add (local.get $maze_x) (i32.const 16)))

             end $maze_xy

             (local.set $maze_index (i32.add (local.get $maze_index) (i32.const 1)))

             br $repeat
          end $repeat
        end $done
 )

(func $add_to_x (param $n i32)
    (i32.store (i32.const 0x200) (i32.add (i32.load (i32.const 0x200)) (local.get $n)))
 )
 (func $add_to_y (param $n i32)
    (i32.store (i32.const 0x204) (i32.add (i32.load (i32.const 0x204)) (local.get $n)))
 )

 (func $step_pacman (export "step_pacman") (param $pacman_addr i32) (param $progress i32)
    (local $pacman_addr_x i32)
    (local $pacman_addr_y i32)
    (local $pacman_index i32)
    (local $pacman_artwork_width i32)
    (local $pacman_artwork_height i32)
    (local $pacman_artwork_frame i32)
    (local $pacman_movement i32)

    (local.set $pacman_addr_x (i32.add (local.get $pacman_addr) (i32.const 0)))
    (local.set $pacman_addr_y (i32.add (local.get $pacman_addr) (i32.const 4)))
    (local.set $pacman_index (i32.add (local.get $pacman_addr) (i32.const 8)))
    (local.set $pacman_artwork_width (i32.const 16))
    (local.set $pacman_artwork_height (i32.const 16))
    (local.set $pacman_movement (i32.const 16))

    (i32.load8_u (i32.const 37)) ;; left
    if
      (i32.ge_u (i32.load (local.get $pacman_addr_x)) (local.get $pacman_movement))
      if
	
	;;i32.const 1843
	i32.const 2
        i32.const 0x600
        i32.add
        local.get $pacman_index
        i32.load
	i32.add
	i32.load8_u
        i32.eqz

	if
        (i32.store (local.get $pacman_addr_x) (i32.add (i32.load (local.get $pacman_addr_x)) (i32.mul (local.get $pacman_movement) (i32.const -1))))

	local.get $pacman_index
        (i32.store (i32.add (i32.const -1) (i32.load (local.get $pacman_index))))

	end
      end
    end

    (i32.load8_u (i32.const 38)) ;; up
    if
      (i32.ge_u (i32.load (local.get $pacman_addr_y)) (local.get $pacman_movement))
      if

	i32.const 3
        i32.const 0x600
        i32.add
        local.get $pacman_index
        i32.load
        i32.add
        i32.const -32
        i32.add
	i32.load8_u
        i32.eqz

	if
        (i32.store (local.get $pacman_addr_y) (i32.add (i32.load (local.get $pacman_addr_y)) (i32.mul (local.get $pacman_movement) (i32.const -1))))

	local.get $pacman_index
        (i32.store (i32.add (i32.const -32) (i32.load (local.get $pacman_index))))

	end
      end
    end

    (i32.load8_u (i32.const 39)) ;; right
    if
      (i32.le_u (i32.load (local.get $pacman_addr_x)) (i32.sub (i32.sub (global.get $canvas_width) (local.get $pacman_artwork_width)) (local.get $pacman_movement)))
      if

	;;i32.const 1845
	i32.const 4
	i32.const 0x600
	i32.add
	local.get $pacman_index
	i32.load
	i32.add
	i32.load8_u
	i32.eqz
	
	if
        (i32.store (local.get $pacman_addr_x) (i32.add (i32.load (local.get $pacman_addr_x)) (local.get $pacman_movement)))

	local.get $pacman_index
        (i32.store (i32.add (i32.const 1) (i32.load (local.get $pacman_index))))

	end
      end
    end

    (i32.load8_u (i32.const 40)) ;; down
    if
      (i32.le_u (i32.load (local.get $pacman_addr_y)) (i32.sub (i32.sub (global.get $canvas_height) (local.get $pacman_artwork_height)) (local.get $pacman_movement)))
      if

	;;i32.const 1905
	i32.const 3
        i32.const 0x600
        i32.add
        local.get $pacman_index
        i32.load
        i32.add
        i32.const 32
        i32.add
        i32.load8_u
        i32.eqz
	
	if
        (i32.store (local.get $pacman_addr_y) (i32.add (i32.load (local.get $pacman_addr_y)) (local.get $pacman_movement)))

	local.get $pacman_index
        (i32.store (i32.add (i32.const 32) (i32.load (local.get $pacman_index))))

	end
      end
    end

    ;; divide $progress by 2^10 = 1024 and then take the least significant bit to get a number that cycles 0..1 (inclusive)
    (local.set $pacman_artwork_frame (i32.and (i32.shr_u (local.get $progress) (i32.const 8)) (i32.const 1)))
    
    ;; draw pacman
    (call $draw_artwork (i32.const 16) (i32.const 0) (local.get $pacman_artwork_width) (local.get $pacman_artwork_height) (i32.load (local.get $pacman_addr_x)) (i32.load (local.get $pacman_addr_y))) 
)

(func $step (export "step") (param $progress i32)
    (call $clear_screen (i32.const 0xFF000000))
    (call $step_pacman (i32.const 0x200) (local.get $progress))
    (call $step_maze (i32.const 0x600) (local.get $progress))
 )
)