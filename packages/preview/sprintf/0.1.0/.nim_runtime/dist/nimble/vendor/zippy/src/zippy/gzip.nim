import common, crc, inflate, internal

proc uncompressGzip*(
  dst: var string,
  src: ptr UncheckedArray[uint8],
  len: int,
  trustSize = false
) =
  # Assumes the gzip src data only contains one file.
  if len < 18:
    failUncompress()

  let
    id1 = src[0].uint8
    id2 = src[1].uint8
    cm = src[2].uint8
    flg = src[3].uint8
    # mtime = src[4 .. 7]
    # xfl = src[8]
    # os = src[9]

  if id1 != 31 or id2 != 139:
    raise newException(ZippyError, "Failed gzip identification values check")

  if cm != 8: # DEFLATE
    raise newException(ZippyError, "Unsupported compression method")

  if (flg and 0b11100000) > 0.uint8:
    raise newException(ZippyError, "Reserved flag bits set")

  let
    # ftext = (flg and (1.uint8 shl 0)) != 0
    fhcrc = (flg and (1.uint8 shl 1)) != 0.uint8
    fextra = (flg and (1.uint8 shl 2)) != 0.uint8
    fname = (flg and (1.uint8 shl 3)) != 0.uint8
    fcomment = (flg and (1.uint8 shl 4)) != 0.uint8

  var pos = 10

  if fextra:
    raise newException(ZippyError, "Currently unsupported flags are set")

  proc nextZeroByte(src: ptr UncheckedArray[uint8], len, start: int): int =
    for i in start ..< len:
      if src[i] == 0:
        return i
    failUncompress()

  if fname:
    pos = nextZeroByte(src, len, pos) + 1

  if fcomment:
    pos = nextZeroByte(src, len, pos) + 1

  if fhcrc:
    if pos + 2 >= len:
      failUncompress()
    # TODO: Need to implement this with a test file
    pos += 2

  if pos + 8 >= len:
    failUncompress()

  let
    checksum = read32(src, len - 8)
    isize = read32(src, len - 4)

  if trustSize:
    dst.setLen(isize + 16) # Leave some room to write past the end

  inflate(dst, src, len, pos)

  if checksum != crc32(dst):
    raise newException(ZippyError, "Checksum verification failed")

  if isize != (dst.len mod (1 shl 32)).uint32:
    raise newException(ZippyError, "Size verification failed")
