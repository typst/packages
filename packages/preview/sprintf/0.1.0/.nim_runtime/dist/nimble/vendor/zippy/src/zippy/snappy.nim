import internal

## Use Snappy's algorithm for encoding repeated data instead of LZ77.
## This is much faster but does not compress as well. Perfect for BestSpeed.
## See https://github.com/guzba/supersnappy

const maxCompressTableSize = 1 shl 14

when defined(release):
  {.push checks: off.}

proc encodeFragment(
  encoding: var seq[uint16],
  metadata: var BlockMetadata,
  src: ptr UncheckedArray[uint8],
  ep: var int,
  start, bytesToRead: int,
  compressTable: var array[maxCompressTableSize, uint16]
) =
  let ipEnd = start + bytesToRead
  var
    ip = start
    nextEmit = ip
    tableSize = 256
    shift = 24

  while tableSize < compressTable.len and tableSize < bytesToRead:
    tableSize = tableSize shl 1
    dec shift

  zeroMem(compressTable[0].addr, tableSize * sizeof(uint16))

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

  template emitRemainder() =
    if nextEmit < ipEnd:
      addLiteral(nextEmit, ipEnd - nextEmit)

  template hash(v: uint32): uint32 =
    (v * 0x1e35a7bd) shr shift

  template uint32AtOffset(v: uint64, offset: int): uint32 =
    ((v shr (8 * offset)) and 0xffffffff.uint32).uint32

  if bytesToRead >= 15:
    let ipLimit = start + bytesToRead - 15
    inc ip

    var nextHash = hash(read32(src, ip))
    while true:
      var
        skipBytes = 32
        nextIp = ip
        candidate: int
      while true:
        ip = nextIp
        var
          h = nextHash
          bytesBetweenHashLookups = skipBytes shr 5
        inc skipBytes
        nextIp = ip + bytesBetweenHashLookups
        if nextIp > ipLimit:
          emitRemainder()
          return
        nextHash = hash(read32(src, nextIp))
        candidate = start + compressTable[h].int
        compressTable[h] = (ip - start).uint16

        if read32(src, ip) == read32(src, candidate):
          break

      addLiteral(nextEmit, ip - nextEmit)

      var
        inputBytes: uint64
        candidateBytes: uint32
      while true:
        let
          limit = min(ipEnd, ip + maxMatchLen)
          matched = 4 + determineMatchLength(src, candidate + 4, ip + 4, limit)
          offset = ip - candidate
        ip += matched
        addCopy(offset, matched)

        let insertTail = ip - 1
        nextEmit = ip
        if ip >= ipLimit:
          emitRemainder()
          return
        inputBytes = read64(src, insertTail)
        let
          prevHash = hash(uint32AtOffset(inputBytes, 0))
          curHash = hash(uint32AtOffset(inputBytes, 1))
        compressTable[prevHash] = (ip - start - 1).uint16
        candidate = start + compressTable[curHash].int
        candidateBytes = read32(src, candidate)
        compressTable[curHash] = (ip - start).uint16

        if uint32AtOffset(inputBytes, 1) != candidateBytes:
          break

      nextHash = hash(uint32AtOffset(inputBytes, 2))
      inc ip

  emitRemainder()

proc encodeSnappy*(
  encoding: var seq[uint16],
  ep: var int,
  metadata: var BlockMetadata,
  src: ptr UncheckedArray[uint8],
  blockStart, blockLen: int
) =
  metadata.litLenFreq[256] = 1 # Alway 1 end-of-block symbol

  var
    pos = blockStart
    compressTable: array[maxCompressTableSize, uint16]
  while pos < blockStart + blockLen:
    let
      fragmentSize = blockStart + blockLen - pos
      bytesToRead = min(fragmentSize, maxWindowSize)
    encodeFragment(
      encoding,
      metadata,
      src,
      ep,
      pos,
      bytesToRead,
      compressTable
    )
    pos += bytesToRead

when defined(release):
  {.pop.}
