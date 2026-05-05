import bitstreams, common, internal, lz77, snappy, std/bitops, std/heapqueue

type Node = ref object
  symbol, freq: int
  left, right: Node

when defined(release):
  {.push checks: off.}

proc `<`(a, b: Node): bool {.inline.} =
  a.freq < b.freq

proc huffmanCodes(
  frequencies: openArray[uint32],
  minCodes, codeLengthLimit: int
): (seq[uint16], seq[uint8]) =
  # https://en.wikipedia.org/wiki/Huffman_coding#Length-limited_Huffman_coding
  # https://en.wikipedia.org/wiki/Canonical_Huffman_code
  # https://create.stephan-brumme.com/length-limited-prefix-codes/

  var
    highestSymbol: int
    numSymbolsUsed: int
  for symbol, freq in frequencies:
    if freq > 0.uint32:
      highestSymbol = symbol
      inc numSymbolsUsed

  var
    numCodes = max(highestSymbol, minCodes) + 1
    codes = newSeq[uint16](numCodes)
    codeLens = newSeq[uint8](numCodes)

  if numSymbolsUsed == 0:
    codeLens[0] = 1
    codeLens[1] = 1
  elif numSymbolsUsed == 1:
    for i, freq in frequencies:
      if freq != 0:
        codeLens[i] = 1
        if i == 0:
          codeLens[1] = 1
        else:
          codeLens[0] = 1
        break
  else:
    var nodes: seq[Node]
    for symbol, freq in frequencies:
      if freq > 0.uint32:
        nodes.add(Node(symbol: symbol, freq: freq.int))

    proc buildTree(nodes: seq[Node]): bool =
      var heap: HeapQueue[Node]
      for node in nodes:
        heap.push(node)

      while heap.len >= 2:
        let node = Node(
          symbol: -1,
          left: heap.pop(),
          right: heap.pop()
        )
        node.freq = node.left.freq + node.right.freq
        heap.push(node)

      proc visit(node: Node, level: int, needsLengthLimiting: var bool) =
        if node.symbol == -1:
          visit(node.left, level + 1, needsLengthLimiting)
          visit(node.right, level + 1, needsLengthLimiting)
        else:
          node.freq = level # Re-use freq for level
          if level > codeLengthLimit:
            needsLengthLimiting = true

      visit(heap[0], 0, result)

    let needsLengthLimiting = buildTree(nodes)
    if needsLengthLimiting:
      var longestCode: int
      for node in nodes:
        longestCode = max(longestCode, node.freq)

      var histogram = newSeq[int](longestCode + 1)
      for node in nodes:
        inc histogram[node.freq]

      var i = longestCode
      while i > codeLengthLimit:
        if histogram[i] == 0:
          dec i
          continue

        var j = i - 2
        while j > 0 and histogram[j] == 0:
          dec j

        histogram[i] -= 2
        inc histogram[i - 1]

        histogram[j + 1] += 2
        dec histogram[j]

      proc quickSort(a: var seq[Node], inl, inr: int) =
        var
          r = inr
          l = inl
        let n = r - l + 1
        if n < 2:
          return
        let p = a[l + 3 * n div 4].freq
        while l <= r:
          if a[l].freq < p:
            inc l
          elif a[r].freq > p:
            dec r
          else:
            swap(a[l], a[r])
            inc l
            dec r
        quickSort(a, inl, r)
        quickSort(a, l, inr)

      quicksort(nodes, 0, nodes.high)

      var codeLen = 1
      for node in nodes:
        while histogram[codeLen] == 0:
          inc codeLen
          continue
        node.freq = codeLen
        dec histogram[codeLen]

    for node in nodes:
      codeLens[node.symbol] = node.freq.uint8

  var histogram: array[maxCodeLength + 1, uint8]
  for l in codeLens:
    inc histogram[l]
  histogram[0] = 0

  var nextCode: array[maxCodeLength + 1, uint16]
  for i in 1 .. maxCodeLength:
    nextCode[i] = (nextCode[i - 1] + histogram[i - 1]) shl 1

  # Convert to canonical codes (+ reversed)
  for i in 0 ..< codes.len:
    if codeLens[i] != 0:
      codes[i] = reverseBits(nextCode[codeLens[i]]) shr (16.uint8 - codeLens[i])
      inc nextCode[codeLens[i]]

  (codes, codeLens)

proc encodeAllLiterals(
  encoding: var seq[uint16],
  ep: var int,
  metadata: var BlockMetadata,
  src: ptr UncheckedArray[uint8],
  start, len: int
) =
  for i in 0 ..< len:
    inc metadata.litLenFreq[src[start + i]]

  let
    a = len div maxLiteralLength
    b = len mod maxLiteralLength
    c = a + (if b > 0: 1 else: 0)
  if ep + c > encoding.len:
    encoding.setLen(ep + c)
  for i in 0 ..< a:
    encoding[ep] = maxLiteralLength.uint16
    inc ep
  if b > 0:
    encoding[ep] = b.uint16
    inc ep

  metadata.litLenFreq[256] = 1 # Alway 1 end-of-block symbol
  metadata.numLiterals = len

proc addNoCompressionBlock(
  b: var BitStreamWriter,
  dst: var string,
  src: ptr UncheckedArray[uint8],
  blockStart, blockLen: int,
  finalBlock: bool
) =
  let uncompressedBlockCount = max(
    (blockLen + maxUncompressedBlockSize - 1) div maxUncompressedBlockSize,
    1
  )
  for blockNum in 0 ..< uncompressedBlockCount:
    let
      uncompressedFinalBlock = blockNum == (uncompressedBlockCount - 1)
      uncompressedBlockStart = blockStart + blockNum * maxUncompressedBlockSize
      uncompressedBlockLen = min(
        blockStart + blockLen - uncompressedBlockStart,
        maxUncompressedBlockSize
      )

    b.addBits(dst, if finalBlock and uncompressedFinalBlock: 1 else: 0, 1)
    b.addBits(dst, 0, 2)
    b.skipRemainingBitsInCurrentByte()
    b.addBits(dst, uncompressedBlockLen.uint16, 16)
    b.addBits(dst, (maxUncompressedBlockSize - uncompressedBlockLen).uint16, 16)
    if uncompressedBlockLen > 0:
      b.addBytes(dst, src, uncompressedBlockStart, uncompressedBlockLen.int)

proc deflate*(dst: var string, src: ptr UncheckedArray[uint8], len, level: int) =
  if level < -2 or level > 9:
    raise newException(ZippyError, "Invalid compression level " & $level)

  var b: BitStreamWriter
  b.pos = dst.len

  if level == 0:
    let blockCount = max(
      (len + maxUncompressedBlockSize - 1) div maxUncompressedBlockSize,
      1
    )
    for blockNum in 0 ..< blockCount:
      let
        finalBlock = blockNum == (blockCount - 1)
        blockStart = blockNum * maxUncompressedBlockSize
        blockLen = min(len - blockStart, maxUncompressedBlockSize)
      b.addNoCompressionBlock(dst, src, blockStart, blockLen, finalBlock)
    dst.setLen(b.pos)
    return

  let blockCount = max((len + maxBlockSize - 1) div maxBlockSize, 1)

  var
    encoding: seq[uint16]
    encodingLen: int
  for blockNum in 0 ..< blockCount:
    let
      blockStart = blockNum * maxBlockSize
      blockLen = min(len - blockStart, maxBlockSize)
      finalBlock = blockNum == (blockCount - 1)

    encodingLen = 0

    var metadata: BlockMetadata

    case level:
    of -2:
      encodeAllLiterals(
        encoding,
        encodingLen,
        metadata,
        src,
        blockStart,
        blockLen
      )
    of 1:
      encodeSnappy(
        encoding,
        encodingLen,
        metadata,
        src,
        blockStart,
        blockLen
      )
    else:
      # -1 or [2, 9]
      encodeLz77(
        encoding,
        encodingLen,
        configurationTable[if level == -1: 6 else: level],
        metadata,
        src,
        blockStart,
        blockLen
      )

    # If encoding returned almost all literals then write uncompressed.
    if level != -2 and metadata.numLiterals >= (blockLen.float32 * 0.98).int:
      b.addNoCompressionBlock(dst, src, blockStart, blockLen, finalBlock)
      continue

    let
      useFixedCodes = level <= 6 and blockLen <= 2048
      (litLenCodes, litLenCodeLengths) = block:
        if useFixedCodes:
          (fixedLitLenCodes, fixedLitLenCodeLengths)
        else:
          huffmanCodes(metadata.litLenFreq, 257, maxCodeLength)
      (distanceCodes, distanceCodeLengths) = block:
        if useFixedCodes:
          (fixedDistanceCodes, fixedDistanceCodeLengths)
        else:
          huffmanCodes(metadata.distanceFreq, 2, maxCodeLength)

    if useFixedCodes:
      b.addBits(dst, if finalBlock: 1 else: 0, 1)
      b.addBits(dst, 1, 2) # Fixed Huffman codes
    else:
      var
        codeLengths: array[maxLitLenCodes + maxDistanceCodes, uint8]
        numCodes = litLenCodes.len + distanceCodes.len
      block:
        var cli: int
        for i in 0 ..< litLenCodes.len:
          codeLengths[cli] = litLenCodeLengths[i]
          inc cli
        for i in 0 ..< distanceCodes.len:
          codeLengths[cli] = distanceCodeLengths[i]
          inc cli

      var codeLengthsRle: seq[uint8]
      block:
        var i: int
        while i < numCodes:
          var repeatCount: int
          while i + repeatCount + 1 < numCodes and
            codeLengths[i + repeatCount + 1] == codeLengths[i]:
            inc repeatCount

          if codeLengths[i] == 0 and repeatCount >= 2:
            inc repeatCount # Initial zero
            if repeatCount <= 10:
              codeLengthsRle.add(17)
              codeLengthsRle.add(repeatCount.uint8 - 3)
            else:
              repeatCount = min(repeatCount, 138) # Max of 138 zeros for code 18
              codeLengthsRle.add(18)
              codeLengthsRle.add(repeatCount.uint8 - 11)
            i += repeatCount - 1
          elif repeatCount >= 3: # Repeat code for non-zero, must be >= 3 times
            var
              a = repeatCount div 6
              b = repeatCount mod 6
            codeLengthsRle.add(codeLengths[i])
            for j in 0 ..< a:
              codeLengthsRle.add(16)
              codeLengthsRle.add(3)
            if b >= 3:
              codeLengthsRle.add(16)
              codeLengthsRle.add(b.uint8 - 3)
            else:
              repeatCount -= b
            i += repeatCount
          else:
            codeLengthsRle.add(codeLengths[i])
          inc i

      var clFreq: array[19, uint32]
      block:
        var i: int
        while i < codeLengthsRle.len:
          inc clFreq[codeLengthsRle[i]]
          # Skip the number of times codes are repeated
          if codeLengthsRle[i] >= 16.uint8:
            inc i
          inc i

      let (clCodes, clCodeLengths) = huffmanCodes(clFreq, clFreq.len, 7)

      var clclOrdered: array[19, uint16]
      for i in 0 ..< clclOrdered.len:
        clclOrdered[i] = clCodeLengths[clclOrder[i]]

      var hclen = clclOrdered.len
      while clclOrdered[hclen - 1] == 0 and clclOrdered.len > 4:
        dec hclen
      hclen -= 4

      let
        hlit = litLenCodes.len - firstLengthCodeIndex
        hdist = distanceCodes.len - 1

      b.addBits(dst, if finalBlock: 1 else: 0, 1)
      b.addBits(dst, 2, 2) # Dynamic Huffman codes

      b.addBits(dst, hlit.uint32, 5)
      b.addBits(dst, hdist.uint32, 5)
      b.addBits(dst, hclen.uint32, 4)

      for i in 0 ..< hclen + 4:
        b.addBits(dst, clclOrdered[i], 3)

      block:
        var i: int
        while i < codeLengthsRle.len:
          let symbol = codeLengthsRle[i]
          b.addBits(dst, clCodes[symbol], clCodeLengths[symbol].int)
          inc i
          if symbol == 16:
            b.addBits(dst, codeLengthsRle[i], 2)
            inc i
          elif symbol == 17:
            b.addBits(dst, codeLengthsRle[i], 3)
            inc i
          elif symbol == 18:
            b.addBits(dst, codeLengthsRle[i], 7)
            inc i

    block:
      var
        srcPos = blockStart
        encPos: int
      while encPos < encodingLen:
        if (encoding[encPos] and (1 shl 15)) != 0:
          let
            value = encoding[encPos + 0]
            offset = encoding[encPos + 1]
            length = encoding[encPos + 2]
            lengthIndex = (value shr 8) and (uint8.high shr 1)
            distanceIndex = value and uint8.high
            lengthExtraBits = baseLengthsExtraBits[lengthIndex].int
            lengthExtra = length - baseLengths[lengthIndex]
            distanceExtraBits = baseDistanceExtraBits[distanceIndex].int
            distanceExtra = offset - baseDistances[distanceIndex]

          encPos += 3
          srcPos += length.int

          var
            buf = litLenCodes[lengthIndex + 257].uint64
            bitLen = litLenCodeLengths[lengthIndex + 257].int
          buf = buf or (lengthExtra.uint64 shl bitLen)
          bitLen += lengthExtraBits

          buf = buf or (distanceCodes[distanceIndex].uint64 shl bitLen)
          bitLen += distanceCodeLengths[distanceIndex].int
          buf = buf or (distanceExtra.uint64 shl bitLen)
          bitLen += distanceExtraBits

          let firstAddLen = min(bitLen, 32)
          b.addBits(dst, buf.uint32, firstAddLen)
          buf = buf shr firstAddLen
          bitLen -= firstAddLen

          if bitLen > 0:
            b.addBits(dst, buf.uint32, bitLen)

        else:
          let literalsLength = encoding[encPos].int
          inc encPos

          var
            buf: uint32
            bitLen: int
          for _ in 0 ..< literalsLength:
            let codeLength = litLenCodeLengths[src[srcPos]].int
            if bitLen + codeLength > 32:
              # Flush
              b.addBits(dst, buf, bitLen)
              buf = 0
              bitLen = 0
            buf = buf or litLenCodes[src[srcPos]].uint32 shl bitLen
            bitLen += codeLength
            inc srcPos

          if bitLen > 0:
            b.addBits(dst, buf, bitLen)

      if encPos != encodingLen:
        failUncompress()

      assert srcPos == blockStart + blockLen

    if litLenCodeLengths[256] == 0:
      failCompress()

    b.addBits(dst, litLenCodes[256], litLenCodeLengths[256].int) # End of block

  b.skipRemainingBitsInCurrentByte()
  dst.setLen(b.pos)

when defined(release):
  {.pop.}
