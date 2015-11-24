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
  { 0 2 5 0 0 0 0 0 4 1 }
  { 7 7 7 2 9 0 0 1 4 1 }
}

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
  { 0 0 6 0 }
  { 0 0 6 0 }
  { 0 6 6 0 }
  { 0 0 0 0 }
}
set blocks(7) {
  { 0 0 7 0 }
  { 0 0 7 0 }
  { 0 0 7 7 }
  { 0 0 0 0 }
}

proc clear { } {
  .can delete "all"
}

proc draw_block { xpos ypos block } {
  set xpos [expr $xpos * 30]
  set ypos [expr $ypos * 30]
  set colors { Black Cyan Yellow Purple Green Red Blue Orange }

  for {set y 0} {$y < 4} {incr y} {
    for {set x 0} {$x < 4} {incr x} {
      set cell [lindex [lindex $block $y] $x]
      if {$cell != 0} {
        .can create rectangle [expr $x*30+$xpos] [expr $y*30+$ypos] [expr $x*30+30+$xpos] [expr $y*30+30+$ypos] -outline black -fill [lindex $colors $cell]
      }
    }
  }
}

proc draw_wall { } {
  set colors { Black Cyan Yellow Purple Green Red Blue Orange }

  for {set y 0} {$y < $::height} {incr y} {
    for {set x 0} {$x < $::width} {incr x} {
      set cell [lindex [lindex $::wall $y] $x]
      if {$cell != 0} {
        .can create rectangle [expr $x*30] [expr $y*30] [expr $x*30+30] [expr $y*30+30] -outline black -fill [lindex $colors $cell]
      }
    }
  }
}

proc rotate_block {block} {
  # Rotate 90*
  for {set y 0} {$y < 4} {incr y} {
    for {set x 0} {$x < $y} {incr x} {
      set first_cell [lindex [lindex $block $y] $x]
      set second_cell [lindex [lindex $block $x] $y]

      lset block $x $y $first_cell
      lset block $y $x $second_cell
    }
  }
  for {set y 0} {$y < 4} {incr y} {
    lset block $y [lreverse [lindex $block $y]]
  }
  return $block
}

proc log_block { block } {
  # Print
  puts "----"
  for {set y 0} {$y < 4} {incr y} {
    for {set x 0} {$x < 4} {incr x} {
      puts -nonewline [lindex [lindex $block $y] $x]
    }
    puts ""
  }
}

proc draw_screen {} {
  clear
  draw_wall
  draw_block $::xpos $::ypos $::block
}

proc block_hit_wall { } {
  #
  # 02  02000
  # 02  02000
  #     11111
  #
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

      if {[expr $y + $::ypos] <= 0} {
        # game over - reset game
        set ::block $::blocks(0)
        wall_clear
      } elseif {$cell != 0} {
        # add block onto wall
        lset ::wall [expr $y + $::ypos] [expr $x + $::xpos] $cell
      }
    }
  }
}

proc generate_block {} {
  set ::xpos 3
  set ::ypos -2
  set ::block $::blocks([expr int(rand() * 7 + 1)])
}

proc check_hit {} {
  if  { [block_hit_wall] } {
    set ::locked true
  }
}

proc line_clears { } {
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

proc check_legal_move { } {
  # disallow illegal moves
  for {set y 0} {$y < 4} {incr y} {
    for {set x 0} {$x < 4} {incr x} {
      set cell [lindex [lindex $::block $y] $x]
      set wall_cell [lindex [lindex $::wall [expr $y + $::ypos] [expr $x + $::xpos]]]
      # hits or is outside of wall
      if {$cell != 0 && $wall_cell != 0} {
        return false
      }
    }
  }
  return true
}

# Game Vars
set block $blocks(1) ;# current falling tetromino
set xpos 0           ;# x position of falling tetromino
set ypos 0           ;# y position of falling tetromino
set locked false

# Controls
bind . <Key-Down> {
  incr ::ypos
  if ([check_legal_move]) {
    check_hit
    draw_screen
  } else {
    incr ::ypos -1
  }
}

bind . <Key-Up> {
  set ::block [rotate_block $::block]
  if ([check_legal_move]) {
    check_hit
    draw_screen
  } else {
    set ::block [rotate_block $::block]
    set ::block [rotate_block $::block]
    set ::block [rotate_block $::block]
  }
}

bind . <Key-Left> {
  incr ::xpos -1
  if ([check_legal_move]) {
    check_hit
    draw_screen
  } else {
    incr ::xpos
  }
}

bind . <Key-Right> {
  incr ::xpos
  if ([check_legal_move]) {
    check_hit
    draw_screen
  } else {
    incr ::xpos -1
  }
}

# Game Loop
proc main { } {
  if { $::locked } {
    add_current_block_to_wall
    generate_block
    set ::locked false
  }
  incr ::ypos
  if ([check_legal_move]) {
    check_hit
    draw_screen
  } else {
    incr ::ypos -1
  }
  after 600 [list main]
}

# init
generate_block
main
