import internal

const
  hashBits = 17
  hashSize = 1 shl hashBits

when defined(release):
  {.push checks: off.}

proc encodeLz77*(
  encoding: var seq[uint16],
  ep: var int,
  config: CompressionConfig,
  metadata: var BlockMetadata,
  src: ptr UncheckedArray[uint8],
  blockStart, blockLen: int
) =

  template addLiteral(start, length: int) =
    for i in 0 ..< length:
      inc metadata.litLenFreq[src[start + i]]

    metadata.numLiterals += length

    var remaining = length
    while remaining > 0:
      if ep + 1 > encoding.len:
        encoding.setLen(max(encoding.len * 2, 2))

      let added = min(remaining, (1 shl 15) - 1)
      encoding[ep] = added.uint16
      inc ep
      remaining -= added

  template addCopy(offset, length: int) =
    if ep + 3 > encoding.len:
      encoding.setLen(max(encoding.len * 2, ep + 3))

    let
      lengthIndex = baseLengthIndices[length - baseMatchLen].uint16
      distIndex = distanceCodeIndex((offset - 1).uint16)
    inc metadata.litLenFreq[lengthIndex + firstLengthCodeIndex]
    inc metadata.distanceFreq[distIndex]

    # The length and dist indices are packed into this value with the highest
    # bit set as a flag to indicate this starts a run.
    encoding[ep + 0] = ((lengthIndex shl 8) or distIndex) or (1 shl 15)
    encoding[ep + 1] = offset.uint16
    encoding[ep + 2] = length.uint16
    ep += 3

  metadata.litLenFreq[256] = 1 # Alway 1 end-of-block symbol

  if minMatchLen >= blockLen:
    addLiteral(blockStart, blockLen)
    return

  var
    pos = blockStart
    literalLen: int
    hash: uint32
    windowPos: uint16
    head = newSeq[uint16](hashSize)       # hash -> pos
    chain = newSeq[uint16](maxWindowSize) # pos a -> pos b

  template hash4(start: int): uint32 =
    (read32(src, start) * 0x1e35a7bd) shr (32 - hashBits)

  template updateChain() =
    chain[windowPos] = head[hash]
    head[hash] = windowPos

  while pos < blockStart + blockLen:
    if pos + minMatchLen >= blockStart + blockLen:
      addLiteral(pos - literalLen, blockStart + blockLen - pos + literalLen)
      break

    windowPos = ((pos - blockStart) and (maxWindowSize - 1)).uint16

    hash = hash4(pos)
    updateChain()

    var
      hashPos = chain[windowPos]
      limit = min(blockStart + blockLen, pos + maxMatchLen)
      tries = config.chain
      prevOffset, longestMatchOffset, longestMatchLen: int
    while tries > 0 and hashPos != 0:
      dec tries

      var offset: int
      if hashPos <= windowPos:
        offset = (windowPos - hashPos).int
      else:
        offset = (windowPos - hashPos + maxWindowSize).int

      if offset <= 0 or offset < prevOffset:
        break

      prevOffset = offset

      let matchLen = determineMatchLength(src, pos - offset, pos, limit)
      if matchLen > longestMatchLen:
        if matchLen >= config.good:
          tries = tries shr 2
        longestMatchLen = matchLen
        longestMatchOffset = offset

      if longestMatchLen >= config.nice or hashPos == chain[hashPos]:
        break

      hashPos = chain[hashPos]

    if longestMatchLen > minMatchLen:
      if literalLen > 0:
        addLiteral(pos - literalLen, literalLen)
        literalLen = 0

      addCopy(longestMatchOffset, longestMatchLen)

      for i in 1 ..< longestMatchLen:
        inc pos
        windowPos = (pos and (maxWindowSize - 1)).uint16
        if pos + minMatchLen < blockStart + blockLen:
          hash = hash4(pos)
          updateChain()
    else:
      inc literalLen

    inc pos

when defined(release):
  {.pop.}
