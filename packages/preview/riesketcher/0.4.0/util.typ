// check if array has duplicates
#let _check-dup(arr) = {
  for i in range(0, arr.len() - 1) {
    if arr.at(i) == arr.at(i + 1) {
      return true
    }
  }
  return false
}

#let _is-num(x) = type(x) == int or type(x) == float

// check if partition is valid
#let _validate-partition(partition) = {
  if partition != none and partition.len() > 1 and partition.all(_is-num) {
    let sorted-partition = partition.sorted()
    return partition == sorted-partition and not _check-dup(partition)
  }
  return false
}

// check if a tagged partition is valid
#let _validate-tagged-partition(partition, tags) = {
  if _validate-partition(partition) and tags != none and tags.len() > 0 and partition.len() == tags.len() + 1 and tags.all(_is-num) {
    let sorted-tags = tags.sorted()
    if tags == sorted-tags and not _check-dup(tags) {
      let zipped = (partition.zip(tags), partition.at(-1)).flatten()
      return zipped == zipped.sorted()
    }
  }
  return false
}
