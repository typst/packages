

#let get-length(len, container-length) = {
  if type(len) == length { return len }
  if type(len) == ratio { return len * container-length}
  if type(len) == relative { return len.length + len.ratio * container-length}
}
