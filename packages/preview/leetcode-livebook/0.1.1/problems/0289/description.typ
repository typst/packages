// https://leetcode.com/problems/game-of-life/

= 0289. Game of Life

According to #link("https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life", "Wikipedia"): "The Game of Life, also known simply as Life, is a cellular automaton devised by the British mathematician John Horton Conway in 1970."

The board is made up of an $m times n$ grid of cells, where each cell has an initial state: live (represented by a 1) or dead (represented by a 0). Each cell interacts with its eight neighbors (horizontal, vertical, diagonal) using the following four rules (taken from the above Wikipedia article):

+ Any live cell with fewer than two live neighbors dies as if caused by under-population.
+ Any live cell with two or three live neighbors lives on to the next generation.
+ Any live cell with more than three live neighbors dies, as if by over-population.
+ Any dead cell with exactly three live neighbors becomes a live cell, as if by reproduction.

The next state of the board is determined by applying the above rules simultaneously to every cell in the current state of the $m times n$ grid board. In this process, births and deaths occur simultaneously.

Given the current state of the board, return the board after applying the above rules.
