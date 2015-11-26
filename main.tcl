package require Tk

wm title . "TkTetris"
wm geometry . 302x660+200+100
canvas .can -background black -width 302 -height 660
pack .can

# Cells are 30x30px
set height 22
set width 10

# Start Screen
set wall {
  { 0 0 0 0 0 0 0 0 0 0 }
  { 0 0 0 0 0 0 0 0 0 0 }
  { 0 0 0 0 0 0 0 0 0 0 }
  { 0 0 0 0 0 0 0 0 0 0 }
  { 0 0 0 0 0 0 0 0 0 0 }
  { 0 0 0 0 0 0 0 0 0 0 }
  { 0 0 0 0 0 0 0 0 0 0 }
  { 0 0 0 0 0 0 0 0 0 0 }
  { 0 0 0 0 0 0 0 0 0 0 }
  { 0 0 0 0 0 0 0 0 0 0 }
  { 0 0 0 0 0 0 0 0 0 0 }
  { 0 0 0 0 0 0 0 0 0 0 }
  { 0 0 0 0 0 0 0 0 0 0 }
  { 0 0 0 0 0 0 0 0 0 0 }
  { 0 0 0 0 0 0 0 0 0 0 }
  { 0 0 0 0 0 0 0 0 0 0 }
  { 0 0 0 0 0 0 0 0 0 0 }
  { 0 0 0 0 0 0 0 0 0 0 }
  { 0 0 0 0 0 0 0 0 0 0 }
  { 0 0 0 0 0 0 0 0 0 0 }
  { 0 0 0 0 0 0 0 0 0 0 }
  { 0 0 0 0 0 0 0 0 0 0 }
}

# Tetromino Colors
set colors { Black Cyan Yellow Purple Green Red Blue Orange }

# Tetrominos
set blocks(0) {
  { 0 0 0 0 }
  { 0 0 0 0 }
  { 0 0 0 0 }
  { 0 0 0 0 }
}

set blocks(1) {
  { 0 0 0 0 }
  { 1 1 1 1 }
  { 0 0 0 0 }
  { 0 0 0 0 }
}

set blocks(2) {
  { 0 0 0 0 }
  { 0 2 2 0 }
  { 0 2 2 0 }
  { 0 0 0 0 }
}

set blocks(3) {
  { 0 0 0 0 }
  { 0 3 3 3 }
  { 0 0 3 0 }
  { 0 0 0 0 }
}

set blocks(4) {
  { 0 0 0 0 }
  { 0 0 4 4 }
  { 0 4 4 0 }
  { 0 0 0 0 }
}

set blocks(5) {
  { 0 0 0 0 }
  { 0 5 5 0 }
  { 0 0 5 5 }
  { 0 0 0 0 }
}

set blocks(6) {
  { 0 0 0 0 }
  { 0 0 6 0 }
  { 0 0 6 0 }
  { 0 6 6 0 }
}

set blocks(7) {
  { 0 0 0 0 }
  { 0 7 0 0 }
  { 0 7 0 0 }
  { 0 7 7 0 }
}

# Game Functions

proc set_block {} {
  set ::block $::blocks([expr int(rand() * 7 + 1)]) ;# current falling tetromino
  set ::xpos 2                                      ;# x position of falling tetromino
  set ::ypos -2                                     ;# y position of falling tetromino
  set ::locked false                                ;# tetromino locked in place
}

proc draw_screen {} {
  clear
  draw_wall
  draw_block $::xpos $::ypos $::block
}

proc clear { } {
  .can delete "all"
}

proc draw_block { xpos ypos block } {
  set xpos [expr $xpos * 30]
  set ypos [expr $ypos * 30]

  for {set y 0} {$y < 4} {incr y} {
    for {set x 0} {$x < 4} {incr x} {
      set cell [lindex [lindex $block $y] $x]
      if {$cell != 0} {
        .can create rectangle [expr $x*30+$xpos] [expr $y*30+$ypos] [expr $x*30+30+$xpos] [expr $y*30+30+$ypos] -outline black -fill [lindex $::colors $cell]
      }
    }
  }
}

proc draw_wall { } {
  for {set y 0} {$y < $::height} {incr y} {
    for {set x 0} {$x < $::width} {incr x} {
      set cell [lindex [lindex $::wall $y] $x]
      if {$cell != 0} {
        .can create rectangle [expr $x*30] [expr $y*30] [expr $x*30+30] [expr $y*30+30] -outline black -fill [lindex $::colors $cell]
      }
    }
  }
}

proc rotate_block {block} {
  # Rotate 90*
  
  # -   t   r
  # 011 000 000
  # 001 100 001
  # 000 110 011
  
  # transpose
  for {set y 0} {$y < 4} {incr y} {
    for {set x 0} {$x < $y} {incr x} {
      set first_cell [lindex [lindex $block $y] $x]
      set second_cell [lindex [lindex $block $x] $y]

      lset block $x $y $first_cell
      lset block $y $x $second_cell
    }
  }

  # reverse rows
  for {set y 0} {$y < 4} {incr y} {
    lset block $y [lreverse [lindex $block $y]]
  }
  return $block
}

proc block_hit_wall { } {
  # 22  22000
  # 22  22000
  #     11111

  for {set y 0} {$y < 4} {incr y} {
    for {set x 0} {$x < 4} {incr x} {
      set cell [lindex [lindex $::block $y] $x]
      set wall_cell_below [lindex [lindex $::wall [expr $y + $::ypos + 1] [expr $x + $::xpos]]]
      if {$cell != 0 && $wall_cell_below != 0} {
        return true
      }
    }
  }
  return false
}

proc add_current_block_to_wall { } {
  for {set y 0} {$y < 4} {incr y} {
    for {set x 0} {$x < 4} {incr x} {
      set cell [lindex [lindex $::block $y] $x]

      if {[expr $y + $::ypos] < 0} {
        # game over - reset game
        set ::block $::blocks(0)
        wall_clear
      }

      if {$cell != 0} {
        # add block onto wall
        lset ::wall [expr $y + $::ypos] [expr $x + $::xpos] $cell
      }
    }
  }
}

proc check_hit {} {
  if  { [block_hit_wall] } {
    set ::locked true
  }
}

proc clear_lines { } {
  for {set y 0} {$y < $::height} {incr y} {
    if {[lsearch [lindex $::wall $y] 0] == -1} {
      # line cleared -- set to 0
      for {set x 0} {$x < $::width} {incr x} {
        lset ::wall $y $x 0
      }
      # move all lines above it one down
      for {set y2 [expr $y]} {$y2 > 0} {incr y2 -1} {
        lset ::wall $y2 [lindex $::wall [expr $y2-1]]
      }
    }
  }
}

proc wall_clear { } {
  # game over - clear wall
  for {set y 0} {$y < $::height} {incr y} {
    for {set x 0} {$x < $::width} {incr x} {
      lset ::wall $y $x 0
    }
  }
}

proc check_legal_move { block xinc yinc } {
  # disallow illegal moves
  for {set y 0} {$y < 4} {incr y} {
    for {set x 0} {$x < 4} {incr x} {
      set cell [lindex [lindex $block $y] $x]
      set wall_cell [lindex [lindex $::wall [expr $y + $::ypos + $yinc] [expr $x + $::xpos + $xinc]]]
      # hits or is outside of wall
      if {$cell != 0 && $wall_cell != 0} {
        return false
      }
    }
  }
  return true
}

proc lock_block {} {
  # if no movement for one turn and touching wall
  # then add to wall
  # else clear lock
  
  if  { [block_hit_wall] && $::locked } {
    add_current_block_to_wall
    set_block
    clear_lines
  } elseif { $::locked } {
   set ::locked false
  }
}

# Controls
proc move { block x y } {
  if ([check_legal_move $block $x $y]) {
    incr ::ypos $y
    incr ::xpos $x
    set ::block $block
  }

  draw_screen
  check_hit
}

bind . <Key-Down> {
  move $::block 0 1
}

bind . <Key-Up> {
  move [rotate_block $::block] 0 0
}

bind . <Key-Left> {
  move $::block -1 0
}

bind . <Key-Right> {
  move $::block 1 0
}

# Game Loop
proc main { } {
  lock_block
  move $::block 0 1
  after 600 [list main]
}

# init
set_block
main
