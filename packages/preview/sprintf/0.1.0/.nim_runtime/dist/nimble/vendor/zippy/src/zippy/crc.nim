import internal

when allowSimd:
  import crc32_simd

const crcTables = block:
  var
    tables: array[8, array[256, uint32]]
    c: uint32
  for i in 0.uint32 ..< 256:
    c = i
    for j in 0 ..< 8:
      c = (c shr 1) xor ((c and 1) * 0xedb88320.uint32)
    tables[0][i] = c
  for i in 0 ..< 256:
    tables[1][i] = (tables[0][i] shr 8) xor tables[0][tables[0][i] and 255]
    tables[2][i] = (tables[1][i] shr 8) xor tables[0][tables[1][i] and 255]
    tables[3][i] = (tables[2][i] shr 8) xor tables[0][tables[2][i] and 255]
    tables[4][i] = (tables[3][i] shr 8) xor tables[0][tables[3][i] and 255]
    tables[5][i] = (tables[4][i] shr 8) xor tables[0][tables[4][i] and 255]
    tables[6][i] = (tables[5][i] shr 8) xor tables[0][tables[5][i] and 255]
    tables[7][i] = (tables[6][i] shr 8) xor tables[0][tables[6][i] and 255]
  tables

when defined(release):
  {.push checks: off.}

## See https://create.stephan-brumme.com/crc32/
proc crc32(src: pointer, len: int, crc32: uint32): uint32 =
  let src = cast[ptr UncheckedArray[uint8]](src)

  result = crc32

  var i: int
  for _ in 0 ..< len div 8:
    let
      one = read32(src, i) xor result
      two = read32(src, i + 4)
    result =
      crcTables[7][one and 255] xor
      crcTables[6][(one shr 8) and 255] xor
      crcTables[5][(one shr 16) and 255] xor
      crcTables[4][one shr 24] xor
      crcTables[3][two and 255] xor
      crcTables[2][(two shr 8) and 255] xor
      crcTables[1][(two shr 16) and 255] xor
      crcTables[0][two shr 24]
    i += 8

  for j in i ..< len:
    result = crcTables[0][(result xor src[j]) and 255] xor (result shr 8)

proc crc32*(src: pointer, len: int): uint32 =
  let src = cast[ptr UncheckedArray[uint8]](src)

  var pos: int

  when allowSimd:
    when defined(amd64):
      let
        leaf1 = cpuid(1, 0)
        sse41 = (leaf1[2] and (1 shl 19)) != 0
        pclmulqdq = (leaf1[2] and (1 shl 1)) != 0
      if sse41 and pclmulqdq and len >= 64:
        let simdLen = (len div 16) * 16 # Multiple of 16
        result = not crc32_sse41_pcmul(src[0].addr, simdLen, not result)
        pos += simdLen
    elif defined(arm64) and defined(macosx): # M1 has CRC32*, Pi 3, 4 does not
      return crc32_armv8a_crypto(src, len)

  if pos < len:
    result = not crc32(src[pos].addr, len - pos, not result)

proc crc32*(src: string): uint32 {.inline.} =
  crc32(src.cstring, src.len)

when defined(release):
  {.pop.}
