#import "../../helpers.typ": *

#let solution(lists) = {
  // Store (list-ref, current-node-id) pairs
  let heads = lists.enumerate().map(it => (it.at(0), it.at(1).head))
  let heap = ()
  for (idx, head-id) in heads {
    let list = lists.at(idx)
    let val = (list.get-val)(head-id)
    if val != none {
      heap.push((val, idx))
    }
  }
  heap = heap.sorted()
  let ans = ()
  while heap.len() > 0 {
    let (val, idx) = heap.at(0)
    ans.push(val)

    // --- sift-down (standard method) ---
    heap.at(0) = heap.at(-1)
    let _ = heap.pop()
    let curr = 0
    while true {
      let left = 2 * curr + 1
      let right = 2 * curr + 2
      let smallest = curr
      if left < heap.len() and heap.at(left) < heap.at(smallest) {
        smallest = left
      }
      if right < heap.len() and heap.at(right) < heap.at(smallest) {
        smallest = right
      }
      if smallest != curr {
        let tmp = heap.at(curr)
        heap.at(curr) = heap.at(smallest)
        heap.at(smallest) = tmp
        curr = smallest
      } else {
        break
      }
    }
    // --- end sift-down ---

    let list = lists.at(idx)
    let curr-node-id = heads.at(idx).at(1)
    let next-id = (list.get-next)(curr-node-id)
    if next-id != none {
      heads.at(idx) = (idx, next-id)
      let val = (list.get-val)(next-id)
      if val != none {
        heap.push((val, idx))
        let curr = heap.len() - 1
        while curr > 0 {
          let parent = calc.floor((curr - 1) / 2)
          if heap.at(parent) > heap.at(curr) {
            let tmp = heap.at(curr)
            heap.at(curr) = heap.at(parent)
            heap.at(parent) = tmp
            curr = parent
          } else {
            break
          }
        }
      }
    }
  }
  linkedlist(ans)
}

// Use hold method for sift-down
#let solution-extra(lists) = {
  // Store (list-ref, current-node-id) pairs
  let heads = lists.enumerate().map(it => (it.at(0), it.at(1).head))
  let heap = ()
  for (idx, head-id) in heads {
    let list = lists.at(idx)
    let val = (list.get-val)(head-id)
    if val != none {
      heap.push((val, idx))
    }
  }
  heap = heap.sorted()
  let ans = ()
  while heap.len() > 0 {
    let (val, idx) = heap.at(0)
    ans.push(val)

    // --- sift-down (hole method) ---
    // Save the last element, then remove it.
    let last = heap.at(-1)
    let _ = heap.pop()

    // If heap is not empty after pop, fill the hole at root with `last`
    // and push the hole down until `last` fits.
    if heap.len() > 0 {
      let curr = 0
      while true {
        let left = 2 * curr + 1
        if left >= heap.len() {
          break
        }
        let right = left + 1

        // pick smaller child
        let child = left
        if right < heap.len() and heap.at(right) < heap.at(left) {
          child = right
        }

        // if `last` belongs here, stop
        if last <= heap.at(child) {
          break
        }

        // move child up, hole goes down
        heap.at(curr) = heap.at(child)
        curr = child
      }
      heap.at(curr) = last
    }
    // --- end sift-down ---

    let list = lists.at(idx)
    let curr-node-id = heads.at(idx).at(1)
    let next-id = (list.get-next)(curr-node-id)
    if next-id != none {
      heads.at(idx) = (idx, next-id)
      let val = (list.get-val)(next-id)
      if val != none {
        heap.push((val, idx))
        let curr = heap.len() - 1
        while curr > 0 {
          let parent = calc.floor((curr - 1) / 2)
          if heap.at(parent) > heap.at(curr) {
            let tmp = heap.at(curr)
            heap.at(curr) = heap.at(parent)
            heap.at(parent) = tmp
            curr = parent
          } else {
            break
          }
        }
      }
    }
  }
  linkedlist(ans)
}

#let solution-py(lists) = {
  import "@preview/pyrunner:0.3.0" as py
  let code = ```python
  import heapq

  def lst_to_array(lst):
    array = []
    if not lst or lst.get("head") is None:
      return array
    curr = lst["head"]
    nodes = lst["nodes"]
    while curr is not None:
      node = nodes.get(curr)
      if node is None:
        break
      array.append(node["val"])
      curr = node["next"]
    return array

  def array_to_lst(array):
    if not array:
      return {"type": "linkedlist", "head": None, "nodes": {}}
    nodes = {}
    for i, val in enumerate(array):
      node_id = str(i)
      next_id = str(i + 1) if i + 1 < len(array) else None
      nodes[node_id] = {"val": val, "next": next_id}
    return {"type": "linkedlist", "head": "0", "nodes": nodes}

  def merge_k_lists(lists):
    heap = []
    lists = list(map(lst_to_array, lists))
    n = len(lists)
    heads = [0] * n
    for i in range(n):
      if lists[i]:
        heapq.heappush(heap, (lists[i][0], i))

    ans = []
    while heap:
      val, i = heapq.heappop(heap)
      ans.append(val)
      if heads[i] + 1 < len(lists[i]):
        heads[i] += 1
        heapq.heappush(heap, (lists[i][heads[i]], i))

    if not ans:
      return {"type": "linkedlist", "head": None, "nodes": {}}
    return array_to_lst(ans)

  merge_k_lists(lists)
  ```

  py.block(code, globals: (lists: lists))
}
