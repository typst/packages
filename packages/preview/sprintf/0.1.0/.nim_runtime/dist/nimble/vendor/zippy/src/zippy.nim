import zippy/adler32, zippy/common, zippy/crc, zippy/deflate,
    zippy/gzip, zippy/inflate, zippy/internal

when (NimMajor, NimMinor, NimPatch) >= (1, 6, 0):
  import std/sysrand
else:
  import std/random, std/times

export common

proc compress*(
  src: pointer,
  len: int,
  level = DefaultCompression,
  dataFormat = dfGzip
): string {.raises: [ZippyError].} =
  ## Compresses src and returns the compressed data.
  let src = cast[ptr UncheckedArray[uint8]](src)

  case dataFormat:
  of dfGzip:
    result.setLen(10)
    result[0] = 31.char
    result[1] = 139.char
    result[2] = 8.char
    result[3] = (1.uint8 shl 3).char # Set the fname flag

    block: # https://github.com/guzba/zippy/issues/61
      let htbLen =
        when (NimMajor, NimMinor, NimPatch) >= (1, 6, 0):
          var urand: array[1, uint8]
          if not urandom(urand):
            raise newException(ZippyError, "Failed to generate random number")
          (urand[0] mod 26).int
        else:
          let now = getTime()
          var rand = initRand(now.toUnix * 1_000_000_000 + now.nanosecond)
          (rand.next() mod 26).int # mod the uint first to ensure a positive int
      # Add up to 26 characters as the gzip header file name
      for i in 0 ..< htbLen:
        result.add (97 + i).char
      result.add '\0'

    deflate(result, src, len, level)

    let
      checksum = crc32(src, len)
      isize = len

    result.add(((checksum shr 0) and 255).char)
    result.add(((checksum shr 8) and 255).char)
    result.add(((checksum shr 16) and 255).char)
    result.add(((checksum shr 24) and 255).char)

    result.add(((isize shr 0) and 255).char)
    result.add(((isize shr 8) and 255).char)
    result.add(((isize shr 16) and 255).char)
    result.add(((isize shr 24) and 255).char)

  of dfZlib:
    const
      cm = 8.uint8
      cinfo = 7.uint8
      cmf = (cinfo shl 4) or cm
      fcheck = (31.uint32 - (cmf.uint32 * 256) mod 31).uint8

    result.setLen(2)
    result[0] = cmf.char
    result[1] = fcheck.char

    deflate(result, src, len, level)

    let checksum = adler32(src, len)

    result.add(((checksum shr 24) and 255).char)
    result.add(((checksum shr 16) and 255).char)
    result.add(((checksum shr 8) and 255).char)
    result.add(((checksum shr 0) and 255).char)

  of dfDeflate:
    deflate(result, src, len, level)

  else:
    raise newException(ZippyError, "Invalid data format " & $dfDetect)

proc compress*(
  src: string,
  level = DefaultCompression,
  dataFormat = dfGzip
): string {.raises: [ZippyError].} =
  compress(src.cstring, src.len, level, dataFormat)

proc compress*(
  src: seq[uint8],
  level = DefaultCompression,
  dataFormat = dfGzip
): seq[uint8] {.raises: [ZippyError].} =
  cast[seq[uint8]](compress(cast[string](src).cstring, src.len, level, dataFormat))

proc uncompress*(
  src: pointer,
  len: int,
  dataFormat = dfDetect
): string {.raises: [ZippyError].} =
  ## Uncompresses src and returns the uncompressed data.
  let src = cast[ptr UncheckedArray[uint8]](src)

  case dataFormat:
  of dfDetect:
    if (
      len > 18 and
      src[0].uint8 == 31 and src[1].uint8 == 139 and src[2].uint8 == 8 and
      (src[3].uint8 and 0b11100000) == 0
    ):
      return uncompress(src, len, dfGzip)

    if (
      len > 6 and
      (src[0].uint8 and 0b00001111) == 8 and
      (src[0].uint8 shr 4) <= 7 and
      ((src[0].uint16 * 256) + src[1].uint8) mod 31 == 0
    ):
      return uncompress(src, len, dfZlib)

    raise newException(ZippyError, "Unable to detect compressed data format")

  of dfGzip:
    uncompressGzip(result, src, len)

  of dfZlib:
    if len < 6:
      failUncompress()

    let
      cmf = src[0].uint8
      flg = src[1].uint8
      cm = cmf and 0b00001111
      cinfo = cmf shr 4

    if cm != 8: # DEFLATE
      raise newException(ZippyError, "Unsupported compression method")

    if cinfo > 7.uint8:
      raise newException(ZippyError, "Invalid compression info")

    if ((cmf.uint16 * 256) + flg.uint16) mod 31 != 0:
      raise newException(ZippyError, "Invalid header")

    if (flg and 0b00100000) != 0: # FDICT
      raise newException(ZippyError, "Preset dictionary is not yet supported")

    inflate(result, src, len, 2)

    let checksum = (
      src[len - 4].uint32 shl 24 or
      src[len - 3].uint32 shl 16 or
      src[len - 2].uint32 shl 8 or
      src[len - 1].uint32
    )

    if checksum != adler32(result):
      raise newException(ZippyError, "Checksum verification failed")

  of dfDeflate:
    inflate(result, src, len, 0)

proc uncompress*(
  src: string,
  dataFormat = dfDetect
): string {.raises: [ZippyError].} =
  uncompress(src.cstring, src.len, dataFormat)

proc uncompress*(
  src: seq[uint8],
  dataFormat = dfDetect
): seq[uint8] {.raises: [ZippyError].} =
  cast[seq[uint8]](uncompress(cast[string](src).cstring, src.len, dataFormat))
