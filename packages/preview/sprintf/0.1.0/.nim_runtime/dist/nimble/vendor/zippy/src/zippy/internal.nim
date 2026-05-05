import common, std/bitops, std/os, std/strutils

const allowSimd* =
  when (NimMajor, NimMinor, NimPatch) >= (1, 2, 0):
    not defined(zippyNoSimd) and not defined(tcc)
  else:
    false

const
  maxCodeLength* = 15
  maxLitLenCodes* = 286
  maxDistanceCodes* = 30
  maxFixedLitLenCodes* = 288
  maxWindowSize* = 32768
  maxUncompressedBlockSize* = 65535
  maxBlockSize* = 4194304
  firstLengthCodeIndex* = 257
  baseMatchLen* = 3
  minMatchLen* = 4
  maxMatchLen* = 258

  # For run length encodings (lz77, snappy), the uint16 high bit is reserved
  # to signal that a offset and length are encoded in the uint16.
  maxLiteralLength* = uint16.high.int shr 1

  baseLengths* = [
    3.uint16, 4, 5, 6, 7, 8, 9, 10, # 257 - 264
    11, 13, 15, 17, # 265 - 268
    19, 23, 27, 31, # 269 - 273
    35, 43, 51, 59, # 274 - 276
    67, 83, 99, 115, # 278 - 280
    131, 163, 195, 227, # 281 - 284
    258 # 285
  ]

  baseLengthsExtraBits* = [
    0.uint8, 0, 0, 0, 0, 0, 0, 0, # 257 - 264
    1, 1, 1, 1, # 265 - 268
    2, 2, 2, 2, # 269 - 273
    3, 3, 3, 3, # 274 - 276
    4, 4, 4, 4, # 278 - 280
    5, 5, 5, 5, # 281 - 284
    0 # 285
  ]

  baseLengthIndices* = [
    0.uint8, 1, 2, 3, 4, 5, 6, 7, 8, 8,
    9, 9, 10, 10, 11, 11, 12, 12, 12, 12,
    13, 13, 13, 13, 14, 14, 14, 14, 15, 15,
    15, 15, 16, 16, 16, 16, 16, 16, 16, 16,
    17, 17, 17, 17, 17, 17, 17, 17, 18, 18,
    18, 18, 18, 18, 18, 18, 19, 19, 19, 19,
    19, 19, 19, 19, 20, 20, 20, 20, 20, 20,
    20, 20, 20, 20, 20, 20, 20, 20, 20, 20,
    21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
    21, 21, 21, 21, 21, 21, 22, 22, 22, 22,
    22, 22, 22, 22, 22, 22, 22, 22, 22, 22,
    22, 22, 23, 23, 23, 23, 23, 23, 23, 23,
    23, 23, 23, 23, 23, 23, 23, 23, 24, 24,
    24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
    24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
    24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
    25, 25, 25, 25, 25, 25, 25, 25, 25, 25,
    25, 25, 25, 25, 25, 25, 25, 25, 25, 25,
    25, 25, 25, 25, 25, 25, 25, 25, 25, 25,
    25, 25, 26, 26, 26, 26, 26, 26, 26, 26,
    26, 26, 26, 26, 26, 26, 26, 26, 26, 26,
    26, 26, 26, 26, 26, 26, 26, 26, 26, 26,
    26, 26, 26, 26, 27, 27, 27, 27, 27, 27,
    27, 27, 27, 27, 27, 27, 27, 27, 27, 27,
    27, 27, 27, 27, 27, 27, 27, 27, 27, 27,
    27, 27, 27, 27, 27, 28
  ]

  baseDistances* = [
    1.uint16, 2, 3, 4, # 0-3
    5, 7, # 4-5
    9, 13, # 6-7
    17, 25, # 8-9
    33, 49, # 10-11
    65, 97, # 12-13
    129, 193, # 14-15
    257, 385, # 16-17
    513, 769, # 18-19
    1025, 1537, # 20-21
    2049, 3073, # 22-23
    4097, 6145, # 24-25
    8193, 12289, # 26-27
    16385, 24577 # 28-29
  ]

  baseDistanceExtraBits* = [
    0.uint8, 0, 0, 0, # 0-3
    1, 1, # 4-5
    2, 2, # 6-7
    3, 3, # 8-9
    4, 4, # 10-11
    5, 5, # 12-13
    6, 6, # 14-15
    7, 7, # 16-17
    8, 8, # 18-19
    9, 9, # 20-21
    10, 10, # 22-23
    11, 11, # 24-25
    12, 12, # 26-27
    13, 13 # 28-29
  ]

  clclOrder* = [
    16.uint8, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15
  ]

  S_IFDIR* = 0o0040000'u32
  TUREAD* = 0o00400'u32 # read by owner */
  TUWRITE* = 0o00200'u32 # write by owner */
  TUEXEC* = 0o00100'u32 # execute/search by owner */
  TGREAD* = 0o00040'u32 # read by group */
  TGWRITE* = 0o00020'u32 # write by group */
  TGEXEC* = 0o00010'u32 # execute/search by group */
  TOREAD* = 0o00004'u32 # read by other */
  TOWRITE* = 0o00002'u32 # write by other */
  TOEXEC* = 0o00001'u32 # execute/search by other */

type
  CompressionConfig* = object
    good*, lazy*, nice*, chain*: int

  BlockMetadata* = object
    litLenFreq*: array[maxLitLenCodes, uint32]
    distanceFreq*: array[maxDistanceCodes, uint32]
    numLiterals*: int

proc makeCodes(lengths: seq[uint8]): seq[uint16] =
  result = newSeq[uint16](lengths.len)

  var lengthCounts: array[16, uint8]
  for l in lengths:
    inc lengthCounts[l]

  lengthCounts[0] = 0

  var nextCode: array[16, uint16]
  for i in 1 .. maxCodeLength:
    nextCode[i] = (nextCode[i - 1] + lengthCounts[i - 1]) shl 1

  for i in 0 ..< result.len:
    if lengths[i] != 0:
      result[i] = reverseBits(nextCode[lengths[i]]) shr (16.uint8 - lengths[i])
      inc nextCode[lengths[i]]

const
  fixedLitLenCodeLengths* = block:
    var lengths = newSeq[uint8](maxFixedLitLenCodes)
    for i in 0 ..< lengths.len:
      if i <= 143:
        lengths[i] = 8
      elif i <= 255:
        lengths[i] = 9
      elif i <= 279:
        lengths[i] = 7
      else:
        lengths[i] = 8
    lengths

  fixedLitLenCodes* = block:
    makeCodes(fixedLitLenCodeLengths)

  fixedDistanceCodeLengths* = block:
    var lengths = newSeq[uint8](maxDistanceCodes)
    for i in 0 ..< lengths.len:
      lengths[i] = 5
    lengths

  fixedDistanceCodes* = block:
    makeCodes(fixedDistanceCodeLengths)

  configurationTable* = [
    ## See https://github.com/madler/zlib/blob/master/deflate.c#L134
    CompressionConfig(), # No compression
    CompressionConfig(good: 4, lazy: 4, nice: 8, chain: 4),
    CompressionConfig(good: 4, lazy: 5, nice: 16, chain: 8),
    CompressionConfig(good: 4, lazy: 6, nice: 32, chain: 32),
    CompressionConfig(good: 4, lazy: 4, nice: 16, chain: 16),
    CompressionConfig(good: 8, lazy: 16, nice: 32, chain: 32),
    CompressionConfig(good: 8, lazy: 16, nice: 128, chain: 128), # Default
    CompressionConfig(good: 8, lazy: 32, nice: 256, chain: 256),
    CompressionConfig(good: 32, lazy: 128, nice: 258, chain: 1024),
    CompressionConfig(good: 32, lazy: 258, nice: 258, chain: 4096) # Max compression
  ]

template failUncompress*() =
  raise newException(ZippyError, "Invalid buffer, unable to uncompress")

template failCompress*() =
  raise newException(ZippyError, "Unexpected error while compressing")

template failArchiveEOF*() =
  raise newException(ZippyError, "Unexpected EOF, invalid archive?")

when defined(release):
  {.push checks: off.}

proc read16*(src: ptr UncheckedArray[uint8], ip: int): uint16 {.inline.} =
  copyMem(result.addr, src[ip].unsafeAddr, 2)

proc read32*(src: ptr UncheckedArray[uint8], ip: int): uint32 {.inline.} =
  copyMem(result.addr, src[ip].unsafeAddr, 4)

proc read64*(src: ptr UncheckedArray[uint8], ip: int): uint64 {.inline.} =
  copyMem(result.addr, src[ip].unsafeAddr, 8)

proc write64*(dst: ptr UncheckedArray[uint8], op: int, v: uint64) {.inline.} =
  copyMem(dst[op].unsafeAddr, v.unsafeAddr, 8)

proc copy64*(dst, src: ptr UncheckedArray[uint8], op, ip: int) {.inline.} =
  write64(dst, op, read64(src, ip))

proc read16*(s: string, pos: int): uint16 {.inline.} =
  copyMem(result.addr, s[pos].unsafeAddr, 2)

proc read32*(s: string, pos: int): uint32 {.inline.} =
  copyMem(result.addr, s[pos].unsafeAddr, 4)

proc distanceCodeIndex*(value: uint16): uint16 =
  const distanceCodes = [
    0.uint8, 1, 2, 3, 4, 4, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7,
    8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 9, 9,
    10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
    11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11,
    12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,
    12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,
    13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13,
    13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13,
    14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14,
    14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14,
    14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14,
    14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14,
    15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
    15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
    15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
    15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15
  ]

  if value < distanceCodes.len:
    distanceCodes[value]
  elif (value shr 7) < distanceCodes.len:
    distanceCodes[value shr 7] + 14
  else:
    distanceCodes[value shr 14] + 28

proc determineMatchLength*(
  src: ptr UncheckedArray[uint8],
  s1, s2, limit: int
): int {.inline.} =
  var
    s1 = s1
    s2 = s2
  while s2 <= limit - 8:
    let x = read64(src, s2) xor read64(src, s1 + result)
    if x != 0:
      let matchingBits = countTrailingZeroBits(x)
      result += matchingBits shr 3
      return
    s2 += 8
    result += 8
  while s2 < limit:
    if src[s2] != src[s1 + result]:
      return
    inc s2
    inc result

proc toUnixPath*(path: string): string =
  path.replace('\\', '/')

proc parseFilePermissions*(permissions: uint32): set[FilePermission] =
  if defined(windows) or permissions == 0:
    # Ignore file permissions on Windows. If they are absent (.zip made on
    # Windows for example), set default permissions.
    result.incl fpUserRead
    result.incl fpUserWrite
    result.incl fpGroupRead
    result.incl fpOthersRead
  else:
    if (permissions and TUREAD) != 0: result.incl(fpUserRead)
    if (permissions and TUWRITE) != 0: result.incl(fpUserWrite)
    if (permissions and TUEXEC) != 0: result.incl(fpUserExec)
    if (permissions and TGREAD) != 0: result.incl(fpGroupRead)
    if (permissions and TGWRITE) != 0: result.incl(fpGroupWrite)
    if (permissions and TGEXEC) != 0: result.incl(fpGroupExec)
    if (permissions and TOREAD) != 0: result.incl(fpOthersRead)
    if (permissions and TOWRITE) != 0: result.incl(fpOthersWrite)
    if (permissions and TOEXEC) != 0: result.incl(fpOthersExec)

proc verifyPathIsSafeToExtract*(path: string) =
  if path.isAbsolute():
    raise newException(ZippyError, "Absolute path not allowed " & path)

  if path.startsWith("../") or path.startsWith(r"..\"):
    raise newException(ZippyError, "Path ../ not allowed " & path)

  if "/../" in path or r"\..\" in path:
    raise newException(ZippyError, "Path /../ not allowed " & path)

# Nim std/os is missing a openArray[char] writeFile
proc writeFile*(filename: string, content: openArray[char]) =
  ## Opens a file named `filename` for writing. Then writes the
  ## `content` completely to the file and closes the file afterwards.
  ## Raises an IO exception in case of an error.
  var f: File = nil
  if open(f, filename, fmWrite):
    try:
      discard f.writeBuffer(cast[pointer](content), content.len)
    finally:
      close(f)
  else:
    raise newException(IOError, "cannot open: " & filename)

template currentExceptionAsZippyError*(): untyped =
  ## Gets the current exception and returns it as a ZippyError with stack trace.
  let e = getCurrentException()
  newException(ZippyError, e.getStackTrace & e.msg, e)

when defined(amd64):
  # Runtime check if SSE 4.1 and PCLMULQDQ are available
  proc cpuid*(eaxi, ecxi: int32): tuple[eax, ebx, ecx, edx: int32] =
    when defined(vcc):
      proc cpuid(cpuInfo: ptr int32, functionId, subFunctionId: int32)
        {.cdecl, importc: "__cpuidex", header: "intrin.h".}
      cpuid(result.eax.addr, eaxi, ecxi)
    else:
      var (eaxr, ebxr, ecxr, edxr) = (0'i32, 0'i32, 0'i32, 0'i32)
      asm """
        cpuid
        :"=a"(`eaxr`), "=b"(`ebxr`), "=c"(`ecxr`), "=d"(`edxr`)
        :"a"(`eaxi`), "c"(`ecxi`)"""
      (eaxr, ebxr, ecxr, edxr)

when defined(release):
  {.pop.}
