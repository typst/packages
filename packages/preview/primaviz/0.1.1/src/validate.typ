// validate.typ - Input validation helpers for chart functions

// Validate simple data (labels + values)
#let validate-simple-data(data, chart-name) = {
  assert(type(data) == dictionary or type(data) == array,
    message: chart-name + ": data must be a dictionary or array")
  if type(data) == dictionary {
    assert("labels" in data, message: chart-name + ": data must have 'labels' key")
    assert("values" in data, message: chart-name + ": data must have 'values' key")
    assert(data.labels.len() > 0, message: chart-name + ": labels must not be empty")
    assert(data.labels.len() == data.values.len(),
      message: chart-name + ": labels (" + str(data.labels.len()) + ") and values (" + str(data.values.len()) + ") must have same length")
  }
  if type(data) == array {
    assert(data.len() > 0, message: chart-name + ": data must not be empty")
  }
}

// Validate multi-series data (labels + series array)
#let validate-series-data(data, chart-name) = {
  assert(type(data) == dictionary, message: chart-name + ": data must be a dictionary")
  assert("labels" in data, message: chart-name + ": data must have 'labels' key")
  assert("series" in data, message: chart-name + ": data must have 'series' key")
  assert(data.labels.len() > 0, message: chart-name + ": labels must not be empty")
  assert(data.series.len() > 0, message: chart-name + ": series must not be empty")
  for (i, s) in data.series.enumerate() {
    assert("name" in s, message: chart-name + ": series[" + str(i) + "] must have 'name' key")
    assert("values" in s, message: chart-name + ": series[" + str(i) + "] must have 'values' key")
    assert(s.values.len() == data.labels.len(),
      message: chart-name + ": series '" + s.name + "' has " + str(s.values.len()) + " values but " + str(data.labels.len()) + " labels")
  }
}

// Validate scatter data (x + y arrays)
#let validate-scatter-data(data, chart-name) = {
  if type(data) == dictionary {
    assert("x" in data, message: chart-name + ": data must have 'x' key")
    assert("y" in data, message: chart-name + ": data must have 'y' key")
    assert(data.x.len() > 0, message: chart-name + ": x values must not be empty")
    assert(data.x.len() == data.y.len(),
      message: chart-name + ": x (" + str(data.x.len()) + ") and y (" + str(data.y.len()) + ") must have same length")
  }
  if type(data) == array {
    assert(data.len() > 0, message: chart-name + ": data must not be empty")
  }
}

// Validate bubble data (x + y + size arrays)
#let validate-bubble-data(data, chart-name) = {
  validate-scatter-data(data, chart-name)
  if type(data) == dictionary {
    assert("size" in data, message: chart-name + ": data must have 'size' key")
    assert(data.size.len() == data.x.len(),
      message: chart-name + ": size (" + str(data.size.len()) + ") must match x/y length (" + str(data.x.len()) + ")")
  }
}

// Validate heatmap data (rows + cols + values 2D array)
#let validate-heatmap-data(data, chart-name) = {
  assert(type(data) == dictionary, message: chart-name + ": data must be a dictionary")
  assert("rows" in data, message: chart-name + ": data must have 'rows' key")
  assert("cols" in data, message: chart-name + ": data must have 'cols' key")
  assert("values" in data, message: chart-name + ": data must have 'values' key")
  assert(data.rows.len() > 0, message: chart-name + ": rows must not be empty")
  assert(data.cols.len() > 0, message: chart-name + ": cols must not be empty")
  assert(data.values.len() == data.rows.len(),
    message: chart-name + ": values has " + str(data.values.len()) + " rows but " + str(data.rows.len()) + " row labels")
}

// Validate calendar heatmap data
#let validate-calendar-data(data, chart-name) = {
  assert(type(data) == dictionary, message: chart-name + ": data must be a dictionary")
  assert("dates" in data, message: chart-name + ": data must have 'dates' key")
  assert("values" in data, message: chart-name + ": data must have 'values' key")
  assert(data.dates.len() > 0, message: chart-name + ": dates must not be empty")
  assert(data.dates.len() == data.values.len(),
    message: chart-name + ": dates (" + str(data.dates.len()) + ") and values (" + str(data.values.len()) + ") must have same length")
}

// Validate correlation matrix
#let validate-correlation-data(data, chart-name) = {
  assert(type(data) == dictionary, message: chart-name + ": data must be a dictionary")
  assert("labels" in data, message: chart-name + ": data must have 'labels' key")
  assert("values" in data, message: chart-name + ": data must have 'values' key")
  assert(data.labels.len() > 0, message: chart-name + ": labels must not be empty")
  assert(data.values.len() == data.labels.len(),
    message: chart-name + ": values must be a square matrix matching labels length")
}

// Validate numeric value (for gauge, progress)
#let validate-number(value, chart-name) = {
  assert(type(value) == int or type(value) == float,
    message: chart-name + ": value must be a number, got " + str(type(value)))
}

// Validate boxplot data (labels + boxes array)
#let validate-boxplot-data(data, chart-name) = {
  assert(type(data) == dictionary, message: chart-name + ": data must be a dictionary")
  assert("labels" in data, message: chart-name + ": data must have 'labels' key")
  assert("boxes" in data, message: chart-name + ": data must have 'boxes' key")
  assert(data.labels.len() > 0, message: chart-name + ": labels must not be empty")
  assert(data.labels.len() == data.boxes.len(),
    message: chart-name + ": labels and boxes must have same length")
  for (i, b) in data.boxes.enumerate() {
    for key in ("min", "q1", "median", "q3", "max") {
      assert(key in b,
        message: chart-name + ": box[" + str(i) + "] must have '" + key + "' key")
    }
  }
}

// Validate dual-axis data (labels + left/right series)
#let validate-dual-axis-data(data, chart-name) = {
  assert(type(data) == dictionary, message: chart-name + ": data must be a dictionary")
  assert("labels" in data, message: chart-name + ": data must have 'labels' key")
  assert("left" in data, message: chart-name + ": data must have 'left' key")
  assert("right" in data, message: chart-name + ": data must have 'right' key")
  assert("name" in data.left, message: chart-name + ": left must have 'name' key")
  assert("values" in data.left, message: chart-name + ": left must have 'values' key")
  assert("name" in data.right, message: chart-name + ": right must have 'name' key")
  assert("values" in data.right, message: chart-name + ": right must have 'values' key")
  assert(data.left.values.len() == data.labels.len(), message: chart-name + ": left values must match labels length")
  assert(data.right.values.len() == data.labels.len(), message: chart-name + ": right values must match labels length")
}

// Validate ring-progress data (array of dicts with name, value, max)
#let validate-ring-data(entries, chart-name) = {
  assert(type(entries) == array,
    message: chart-name + ": entries must be an array")
  assert(entries.len() > 0,
    message: chart-name + ": entries must not be empty")
  for (i, e) in entries.enumerate() {
    assert(type(e) == dictionary,
      message: chart-name + ": entries[" + str(i) + "] must be a dictionary")
    for key in ("name", "value", "max") {
      assert(key in e,
        message: chart-name + ": entries[" + str(i) + "] must have '" + key + "' key")
    }
    assert(type(e.value) == int or type(e.value) == float,
      message: chart-name + ": entries[" + str(i) + "].value must be numeric")
    assert(type(e.max) == int or type(e.max) == float,
      message: chart-name + ": entries[" + str(i) + "].max must be numeric")
    assert(e.max > 0,
      message: chart-name + ": entries[" + str(i) + "].max must be positive")
  }
}

// Validate histogram data (raw numeric array)
#let validate-histogram-data(values, chart-name) = {
  assert(type(values) == array, message: chart-name + ": values must be an array")
  assert(values.len() > 0, message: chart-name + ": values must not be empty")
  for (i, v) in values.enumerate() {
    assert(type(v) == int or type(v) == float,
      message: chart-name + ": values[" + str(i) + "] must be numeric, got " + str(type(v)))
  }
}

// Validate waterfall data (labels + values, optional types)
#let validate-waterfall-data(data, chart-name) = {
  validate-simple-data(data, chart-name)
}

// Validate grouped-stacked data (labels + groups, each with name + segments)
#let validate-grouped-stacked-data(data, chart-name) = {
  assert(type(data) == dictionary, message: chart-name + ": data must be a dictionary")
  assert("labels" in data, message: chart-name + ": data must have 'labels' key")
  assert("groups" in data, message: chart-name + ": data must have 'groups' key")
  assert(data.labels.len() > 0, message: chart-name + ": labels must not be empty")
  assert(data.groups.len() > 0, message: chart-name + ": groups must not be empty")
  let n-labels = data.labels.len()
  for (gi, g) in data.groups.enumerate() {
    assert(type(g) == dictionary,
      message: chart-name + ": groups[" + str(gi) + "] must be a dictionary")
    assert("name" in g,
      message: chart-name + ": groups[" + str(gi) + "] must have 'name' key")
    assert("segments" in g,
      message: chart-name + ": groups[" + str(gi) + "] must have 'segments' key")
    assert(g.segments.len() > 0,
      message: chart-name + ": groups[" + str(gi) + "] must have at least one segment")
    for (si, seg) in g.segments.enumerate() {
      assert(type(seg) == dictionary,
        message: chart-name + ": groups[" + str(gi) + "].segments[" + str(si) + "] must be a dictionary")
      assert("name" in seg,
        message: chart-name + ": groups[" + str(gi) + "].segments[" + str(si) + "] must have 'name' key")
      assert("values" in seg,
        message: chart-name + ": groups[" + str(gi) + "].segments[" + str(si) + "] must have 'values' key")
      assert(seg.values.len() == n-labels,
        message: chart-name + ": segment '" + seg.name + "' has " + str(seg.values.len()) + " values but " + str(n-labels) + " labels")
    }
  }
}

// Validate chord data (labels + square matrix)
#let validate-chord-data(data, chart-name) = {
  assert(type(data) == dictionary, message: chart-name + ": data must be a dictionary")
  assert("labels" in data, message: chart-name + ": data must have 'labels' key")
  assert("matrix" in data, message: chart-name + ": data must have 'matrix' key")
  assert(type(data.labels) == array, message: chart-name + ": labels must be an array")
  assert(type(data.matrix) == array, message: chart-name + ": matrix must be an array")
  let n = data.labels.len()
  assert(n > 0, message: chart-name + ": labels must not be empty")
  assert(data.matrix.len() == n,
    message: chart-name + ": matrix must have " + str(n) + " rows to match labels, got " + str(data.matrix.len()))
  for (i, row) in data.matrix.enumerate() {
    assert(type(row) == array,
      message: chart-name + ": matrix[" + str(i) + "] must be an array")
    assert(row.len() == n,
      message: chart-name + ": matrix[" + str(i) + "] must have " + str(n) + " columns, got " + str(row.len()))
  }
}

// Validate sankey data (nodes + flows)
#let validate-sankey-data(data, chart-name) = {
  assert(type(data) == dictionary, message: chart-name + ": data must be a dictionary")
  assert("nodes" in data, message: chart-name + ": data must have 'nodes' key")
  assert("flows" in data, message: chart-name + ": data must have 'flows' key")
  assert(data.nodes.len() > 0, message: chart-name + ": nodes must not be empty")
  assert(data.flows.len() > 0, message: chart-name + ": flows must not be empty")
  let n = data.nodes.len()
  for (i, f) in data.flows.enumerate() {
    assert(type(f) == dictionary,
      message: chart-name + ": flows[" + str(i) + "] must be a dictionary")
    for key in ("from", "to", "value") {
      assert(key in f,
        message: chart-name + ": flows[" + str(i) + "] must have '" + key + "' key")
    }
    assert(f.from >= 0 and f.from < n,
      message: chart-name + ": flows[" + str(i) + "].from index out of range")
    assert(f.to >= 0 and f.to < n,
      message: chart-name + ": flows[" + str(i) + "].to index out of range")
    assert(f.value > 0,
      message: chart-name + ": flows[" + str(i) + "].value must be positive")
  }
}

// Validate bullet chart data (single)
#let validate-bullet-data(data, chart-name) = {
  assert(type(data) == dictionary, message: chart-name + ": data must be a dictionary")
  assert("value" in data, message: chart-name + ": data must have 'value' key")
  assert("target" in data, message: chart-name + ": data must have 'target' key")
  assert("ranges" in data, message: chart-name + ": data must have 'ranges' key")
  assert(type(data.value) == int or type(data.value) == float,
    message: chart-name + ": value must be numeric")
  assert(type(data.target) == int or type(data.target) == float,
    message: chart-name + ": target must be numeric")
  assert(type(data.ranges) == array, message: chart-name + ": ranges must be an array")
  assert(data.ranges.len() == 3, message: chart-name + ": ranges must have exactly 3 thresholds")
}

// Validate bullet charts data (multiple)
#let validate-bullet-charts-data(data, chart-name) = {
  assert(type(data) == dictionary, message: chart-name + ": data must be a dictionary")
  assert("bullets" in data, message: chart-name + ": data must have 'bullets' key")
  assert(type(data.bullets) == array, message: chart-name + ": bullets must be an array")
  assert(data.bullets.len() > 0, message: chart-name + ": bullets must not be empty")
  for (i, b) in data.bullets.enumerate() {
    validate-bullet-data(b, chart-name + ".bullets[" + str(i) + "]")
  }
}

// Validate slope chart data (labels + start-values + end-values, same length)
#let validate-slope-data(data, chart-name) = {
  assert(type(data) == dictionary, message: chart-name + ": data must be a dictionary")
  assert("labels" in data, message: chart-name + ": data must have 'labels' key")
  assert("start-values" in data, message: chart-name + ": data must have 'start-values' key")
  assert("end-values" in data, message: chart-name + ": data must have 'end-values' key")
  assert(data.labels.len() > 0, message: chart-name + ": labels must not be empty")
  assert(data.labels.len() == data.start-values.len(),
    message: chart-name + ": labels (" + str(data.labels.len()) + ") and start-values (" + str(data.start-values.len()) + ") must have same length")
  assert(data.labels.len() == data.end-values.len(),
    message: chart-name + ": labels (" + str(data.labels.len()) + ") and end-values (" + str(data.end-values.len()) + ") must have same length")
}

// Validate dumbbell data (labels + start-values + end-values, same length)
#let validate-dumbbell-data(data, chart-name) = {
  assert(type(data) == dictionary, message: chart-name + ": data must be a dictionary")
  assert("labels" in data, message: chart-name + ": data must have 'labels' key")
  assert("start-values" in data, message: chart-name + ": data must have 'start-values' key")
  assert("end-values" in data, message: chart-name + ": data must have 'end-values' key")
  assert(data.labels.len() > 0, message: chart-name + ": labels must not be empty")
  assert(data.labels.len() == data.start-values.len(),
    message: chart-name + ": labels (" + str(data.labels.len()) + ") and start-values (" + str(data.start-values.len()) + ") must have same length")
  assert(data.labels.len() == data.end-values.len(),
    message: chart-name + ": labels (" + str(data.labels.len()) + ") and end-values (" + str(data.end-values.len()) + ") must have same length")
}

// Validate diverging bar data (labels + left-values + right-values)
#let validate-diverging-data(data, chart-name) = {
  assert(type(data) == dictionary, message: chart-name + ": data must be a dictionary")
  assert("labels" in data, message: chart-name + ": data must have 'labels' key")
  assert("left-values" in data, message: chart-name + ": data must have 'left-values' key")
  assert("right-values" in data, message: chart-name + ": data must have 'right-values' key")
  assert(type(data.labels) == array, message: chart-name + ": labels must be an array")
  assert(type(data.left-values) == array, message: chart-name + ": left-values must be an array")
  assert(type(data.right-values) == array, message: chart-name + ": right-values must be an array")
  assert(data.labels.len() > 0, message: chart-name + ": labels must not be empty")
  assert(data.left-values.len() == data.labels.len(),
    message: chart-name + ": left-values (" + str(data.left-values.len()) + ") must match labels length (" + str(data.labels.len()) + ")")
  assert(data.right-values.len() == data.labels.len(),
    message: chart-name + ": right-values (" + str(data.right-values.len()) + ") must match labels length (" + str(data.labels.len()) + ")")
}

// Validate multi-scatter data
#let validate-multi-scatter-data(data, chart-name) = {
  assert(type(data) == dictionary, message: chart-name + ": data must be a dictionary")
  assert("series" in data, message: chart-name + ": data must have 'series' key")
  assert(data.series.len() > 0, message: chart-name + ": series must not be empty")
  for (i, s) in data.series.enumerate() {
    assert("name" in s, message: chart-name + ": series[" + str(i) + "] must have 'name' key")
    assert("points" in s, message: chart-name + ": series[" + str(i) + "] must have 'points' key")
    assert(s.points.len() > 0, message: chart-name + ": series '" + s.name + "' must have at least one point")
  }
}

// Validate violin data (labels + datasets of raw observations)
#let validate-violin-data(data, chart-name) = {
  assert(type(data) == dictionary, message: chart-name + ": data must be a dictionary")
  assert("labels" in data, message: chart-name + ": data must have 'labels' key")
  assert("datasets" in data, message: chart-name + ": data must have 'datasets' key")
  assert(type(data.labels) == array, message: chart-name + ": labels must be an array")
  assert(type(data.datasets) == array, message: chart-name + ": datasets must be an array")
  assert(data.labels.len() > 0, message: chart-name + ": labels must not be empty")
  assert(data.labels.len() == data.datasets.len(),
    message: chart-name + ": labels (" + str(data.labels.len()) + ") and datasets (" + str(data.datasets.len()) + ") must have same length")
  for (i, ds) in data.datasets.enumerate() {
    assert(type(ds) == array,
      message: chart-name + ": datasets[" + str(i) + "] must be an array")
    assert(ds.len() > 0,
      message: chart-name + ": datasets[" + str(i) + "] must not be empty")
    for (j, v) in ds.enumerate() {
      assert(type(v) == int or type(v) == float,
        message: chart-name + ": datasets[" + str(i) + "][" + str(j) + "] must be numeric")
    }
  }
}

// Validate sunburst data (hierarchical: root with name, children array)
#let validate-sunburst-data(data, chart-name) = {
  assert(type(data) == dictionary, message: chart-name + ": data must be a dictionary")
  assert("name" in data, message: chart-name + ": root must have 'name' key")
  assert("children" in data, message: chart-name + ": root must have 'children' key")
  assert(type(data.children) == array, message: chart-name + ": children must be an array")
  assert(data.children.len() > 0, message: chart-name + ": children must not be empty")
  for (i, child) in data.children.enumerate() {
    assert(type(child) == dictionary,
      message: chart-name + ": children[" + str(i) + "] must be a dictionary")
    assert("name" in child,
      message: chart-name + ": children[" + str(i) + "] must have 'name' key")
    assert("value" in child,
      message: chart-name + ": children[" + str(i) + "] must have 'value' key")
    assert(type(child.value) == int or type(child.value) == float,
      message: chart-name + ": children[" + str(i) + "].value must be numeric")
  }
}

// Validate timeline data (events array, each with date and title)
#let validate-timeline-data(data, chart-name) = {
  assert(type(data) == dictionary, message: chart-name + ": data must be a dictionary")
  assert("events" in data, message: chart-name + ": data must have 'events' key")
  assert(type(data.events) == array, message: chart-name + ": events must be an array")
  assert(data.events.len() > 0, message: chart-name + ": events must not be empty")
  for (i, ev) in data.events.enumerate() {
    assert(type(ev) == dictionary,
      message: chart-name + ": events[" + str(i) + "] must be a dictionary")
    for key in ("date", "title") {
      assert(key in ev,
        message: chart-name + ": events[" + str(i) + "] must have '" + key + "' key")
    }
  }
}

// Validate word cloud data (words array, each with text and weight)
#let validate-wordcloud-data(data, chart-name) = {
  assert(type(data) == dictionary, message: chart-name + ": data must be a dictionary")
  assert("words" in data, message: chart-name + ": data must have 'words' key")
  assert(type(data.words) == array, message: chart-name + ": words must be an array")
  assert(data.words.len() > 0, message: chart-name + ": words must not be empty")
  for (i, w) in data.words.enumerate() {
    assert(type(w) == dictionary,
      message: chart-name + ": words[" + str(i) + "] must be a dictionary")
    assert("text" in w,
      message: chart-name + ": words[" + str(i) + "] must have 'text' key")
    assert("weight" in w,
      message: chart-name + ": words[" + str(i) + "] must have 'weight' key")
    assert(type(w.weight) == int or type(w.weight) == float,
      message: chart-name + ": words[" + str(i) + "].weight must be numeric")
  }
}

// Validate gantt data (tasks array, each with name/start/end)
#let validate-gantt-data(data, chart-name) = {
  assert(type(data) == dictionary, message: chart-name + ": data must be a dictionary")
  assert("tasks" in data, message: chart-name + ": data must have 'tasks' key")
  assert(type(data.tasks) == array, message: chart-name + ": tasks must be an array")
  assert(data.tasks.len() > 0, message: chart-name + ": tasks must not be empty")
  for (i, task) in data.tasks.enumerate() {
    assert(type(task) == dictionary,
      message: chart-name + ": tasks[" + str(i) + "] must be a dictionary")
    for key in ("name", "start", "end") {
      assert(key in task,
        message: chart-name + ": tasks[" + str(i) + "] must have '" + key + "' key")
    }
    assert(type(task.start) == int or type(task.start) == float,
      message: chart-name + ": tasks[" + str(i) + "].start must be numeric")
    assert(type(task.end) == int or type(task.end) == float,
      message: chart-name + ": tasks[" + str(i) + "].end must be numeric")
    assert(task.start < task.end,
      message: chart-name + ": tasks[" + str(i) + "] start (" + str(task.start) + ") must be less than end (" + str(task.end) + ")")
  }
}
