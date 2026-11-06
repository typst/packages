#import "utils.typ": *

// This function _sanitizes_ an entry, i.e. it ensures that the entry has the required fields and correct direction.
#let sanitize-entry(entry, solved: false) = {
	// Ensure the entry has the required fields
	assert("word" in entry)
	assert("row" in entry)
	assert("col" in entry)
	// For now, we assume that the entry has a "number" and "definition" field; in the future, we might want to make them optional
	assert("definition" in entry)

	// Ensure the direction is recognized
	if "direction" in entry {
		if not (entry.direction in dir.h or entry.direction in dir.v) {
			error("Unrecognized direction: " + entry.direction)
		}
	}
	if "solved" not in entry {
		entry.solved = solved
	} else {
		assert(type(entry.solved) == bool)
		solved = entry.solved or solved
	}
	return entry
}

// Extracts the definitions from the raw data and organizes them into a structured format.
// Data might have two different formats:
// // 1. A list of entries, each with a word, definition, row, col, number, and direction.
// // 2. A dictionary with "across" and "down" keys, each containing a list of entries.
#let get-definitions(data, solved: false) = {
	let definitions = (
		across: (),
		down: (),
	)

	// Check if the data is a list of entries
	if type(data) == array {
		for entry in data {
			// Sanitize the entry to ensure it has the required fields
			entry = sanitize-entry(entry, solved: solved)
			// Ensure the direction is recognized
			if entry.direction in dir.h {
				definitions.across.push(entry)
			} else if entry.direction in dir.v {
				definitions.down.push(entry)
			} else {
				error("Unrecognized direction: " + direction)
			}
		}
		return definitions
	}
	// If data is not a list, we assume it's a dictionary with "horizontal" and "vertical" keys
	else if type(data) == dictionary {
		assert("horizontal" in data or "across" in data)
		assert("vertical" in data or "down" in data)
		definitions.across = data.at("horizontal", default: data.at("across", default: ()))
		definitions.down = data.at("vertical", default: data.at("down", default: ()))
		// Ensure that all entries in across and down have the required fields
		definitions.across = definitions.across.map(sanitize-entry.with(solved: solved))
		definitions.down = definitions.down.map(sanitize-entry.with(solved: solved))
		return definitions
	}
	// If data is neither a list nor a dictionary, we throw an error 
	else {
		return none 
		//("Unrecognized data format: expected a list of entries or a dictionary, found " + str(type(data)))
	}
}

// Compute the grid size based on the definitions
#let compute-grid-dimensions(definitions) = {
	let rows_num = 0
	let cols_num = 0
	// Iterating over definitions
	for entry in definitions.across {
		rows_num = calc.max(rows_num, entry.row)
		cols_num = calc.max(cols_num, entry.col + entry.word.len())
	}
	for entry in definitions.down {
      rows_num = calc.max(rows_num, entry.row + entry.word.len())
      cols_num = calc.max(cols_num, entry.col)
    }
	assert(rows_num > 0 and cols_num > 0)
	return (rows_num, cols_num)
}

#let is-empty(var) = {
	return var == none or var == [] or var == ""
}

// Create and return the crossword schema, composed of a grid and its dimensions.
#let get-schema(definitions, solved: false) = {
	// Initialize the empty grid
	let (rows_num, cols_num) = compute-grid-dimensions(definitions)
	let empty_cell = ( // Empty cell template
		number: 0, 
		body: none, 
		errors: (), 
		solved: none,
	)
	let grid = (empty_cell, ) * (rows_num * cols_num)
	
	// Computes the index of a cell based on the start of the word
	let index-of-word-across(starting-idx, letter-idx) = {
		return starting-idx + letter-idx
	}
	let index-of-word-down(starting-idx, letter-idx) = {
		return starting-idx + letter-idx * cols_num
	}
	let index-of-word(direction, starting-idx, letter-idx) = {
		if direction in dir.h {
			index-of-word-across(starting-idx, letter-idx)
		} else {
			index-of-word-down(starting-idx, letter-idx)
		}
	}

	let fill-grid-with-entry(grid, direction, entry) = {
		let offset = entry.row * cols_num + entry.col
		// Filling the word cells
		for k in range(entry.word.len()) {
			// Get the current content in the grid
			let grid-index = index-of-word(direction, offset, k)
			let cell-content = grid.at(grid-index).body
			// Get the current letter in the word
			let new-content = entry.word.at(k)
			// We consider this cell to be solved iff (1) the cell is already solved, OR (2) the entry is solved, OR (3) the solved param is true globally.
			if type(grid.at(grid-index).solved) == bool {
				grid.at(grid-index).solved = grid.at(grid-index).solved or entry.solved or solved
			} else {
				grid.at(grid-index).solved = entry.solved or solved
			}

			// Computing the content
			grid.at(grid-index).body = if is-empty(cell-content) {
				// Cell is just empty
				new-content
			} else if is-empty(new-content) {
				// My new content is empty
				cell-content
			} else {
				// There's already a content AND we want to write something
				// We check whether the content corresponds to the one we were about to insert
				if cell-content == new-content {
					cell-content
				} else { // If not => error
					grid.at(grid-index).errors.push("Incompatible contents: " + cell-content + " != " + new-content)
					cell-content + new-content
				}
			}
		}
		// Set the number just for the starting cell
		if entry.number != none {
			grid.at(offset).number = entry.number
		}
		return grid
	}
	
	// Inserting each entry in the grid
	for entry in definitions.across {
		grid = fill-grid-with-entry(grid, dir.h.at(0), entry)
	}
	for entry in definitions.down {
		grid = fill-grid-with-entry(grid, dir.v.at(0), entry)
	}

	return (
		rows: rows_num, 
		cols: cols_num, 
		grid: grid,
	)
}

// Loads a crossword from a YAML file and returns the grid structure.
// The raw data should be read from a YAML file, which can be done using the `yaml` function.
// The `solved` parameter indicates whether the crossword is solved or not.
#let load-crossword(raw-data, solved: false) = {
	let defs = get-definitions(raw-data, solved: solved)
	let sche = get-schema(defs, solved: solved)

	return ( // Crossword data structure
		definitions: defs,
		schema: sche,
	)
}