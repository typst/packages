# These functions are Nim conversions of an original implementation
# from the Chromium repository. That implementation is:
#
# Copyright 2017 The Chromium Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the Chromium source repository LICENSE file.

when defined(amd64):
  when defined(gcc) or defined(clang):
    {.localPassC: "-msse4.1 -mpclmul".}

  {.push header: "emmintrin.h".}

  type M128i {.importc: "__m128i".} = object

  func mm_load_si128(p: pointer): M128i {.importc: "_mm_load_si128".}
  func mm_loadu_si128(p: pointer): M128i {.importc: "_mm_loadu_si128".}
  func mm_loadl_epi64(p: pointer): M128i {.importc: "_mm_loadl_epi64".}
  func mm_setr_epi32(a, b, c, d: int32 | uint32): M128i {.importc: "_mm_setr_epi32".}
  func mm_srli_si128(a: M128i, imm8: int32 | uint32): M128i {.importc: "_mm_srli_si128".}
  func mm_xor_si128(a, b: M128i): M128i {.importc: "_mm_xor_si128".}
  func mm_and_si128(a, b: M128i): M128i {.importc: "_mm_and_si128".}
  func mm_cvtsi32_si128(a: int32 | uint32): M128i {.importc: "_mm_cvtsi32_si128".}

  {.pop.}

  {.push header: "smmintrin.h".}

  func mm_extract_epi32(a: M128i, imm8: int32 | uint32): int32 {.importc: "_mm_extract_epi32".}

  {.pop.}

  {.push header: "wmmintrin.h".}

  func mm_clmulepi64_si128(a, b: M128i, imm8: int32 | uint32): M128i {.importc: "_mm_clmulepi64_si128".}

  {.pop.}

  proc crc32_sse41_pcmul*(src: pointer, len: int, crc32: uint32): uint32 =
    ## Computes the crc32 of the buffer, where the buffer
    ## length must be at least 64, and a multiple of 16.
    let
      k1k2 = [0x0154442bd4.uint64, 0x01c6e41596.uint64]
      k3k4 = [0x01751997d0.uint64, 0x00ccaa009e.uint64]
      k5k0 = [0x0163cd6124.uint64, 0x0000000000.uint64]
      poly = [0x01db710641.uint64, 0x01f7011641.uint64]

    let src = cast[ptr UncheckedArray[uint8]](src)

    var
      pos = 0
      len = len
      x0, x1, x2, x3, x4, x5, x6, x7, x8, y5, y6, y7, y8: M128i

    x1 = mm_loadu_si128((src[pos + 0x00].addr))
    x2 = mm_loadu_si128((src[pos + 0x10].addr))
    x3 = mm_loadu_si128((src[pos + 0x20].addr))
    x4 = mm_loadu_si128((src[pos + 0x30].addr))

    x1 = mm_xor_si128(x1, mm_cvtsi32_si128(crc32))

    x0 = mm_load_si128(k1k2.unsafeAddr)

    pos += 64
    len -= 64

    while (len >= 64):
      x5 = mm_clmulepi64_si128(x1, x0, 0x00)
      x6 = mm_clmulepi64_si128(x2, x0, 0x00)
      x7 = mm_clmulepi64_si128(x3, x0, 0x00)
      x8 = mm_clmulepi64_si128(x4, x0, 0x00)

      x1 = mm_clmulepi64_si128(x1, x0, 0x11)
      x2 = mm_clmulepi64_si128(x2, x0, 0x11)
      x3 = mm_clmulepi64_si128(x3, x0, 0x11)
      x4 = mm_clmulepi64_si128(x4, x0, 0x11)

      y5 = mm_loadu_si128(src[pos + 0x00].addr)
      y6 = mm_loadu_si128(src[pos + 0x10].addr)
      y7 = mm_loadu_si128(src[pos + 0x20].addr)
      y8 = mm_loadu_si128(src[pos + 0x30].addr)

      x1 = mm_xor_si128(x1, x5)
      x2 = mm_xor_si128(x2, x6)
      x3 = mm_xor_si128(x3, x7)
      x4 = mm_xor_si128(x4, x8)

      x1 = mm_xor_si128(x1, y5)
      x2 = mm_xor_si128(x2, y6)
      x3 = mm_xor_si128(x3, y7)
      x4 = mm_xor_si128(x4, y8)

      pos += 64
      len -= 64

    x0 = mm_load_si128(k3k4.unsafeAddr)

    x5 = mm_clmulepi64_si128(x1, x0, 0x00)
    x1 = mm_clmulepi64_si128(x1, x0, 0x11)
    x1 = mm_xor_si128(x1, x2)
    x1 = mm_xor_si128(x1, x5)

    x5 = mm_clmulepi64_si128(x1, x0, 0x00)
    x1 = mm_clmulepi64_si128(x1, x0, 0x11)
    x1 = mm_xor_si128(x1, x3)
    x1 = mm_xor_si128(x1, x5)

    x5 = mm_clmulepi64_si128(x1, x0, 0x00)
    x1 = mm_clmulepi64_si128(x1, x0, 0x11)
    x1 = mm_xor_si128(x1, x4)
    x1 = mm_xor_si128(x1, x5)

    while (len >= 16):
      x2 = mm_loadu_si128(src[pos].addr)

      x5 = mm_clmulepi64_si128(x1, x0, 0x00)
      x1 = mm_clmulepi64_si128(x1, x0, 0x11)
      x1 = mm_xor_si128(x1, x2)
      x1 = mm_xor_si128(x1, x5)

      pos += 16
      len -= 16

    x2 = mm_clmulepi64_si128(x1, x0, 0x10)
    x3 = mm_setr_epi32(not 0, 0, not 0, 0)
    x1 = mm_srli_si128(x1, 8)
    x1 = mm_xor_si128(x1, x2)

    x0 = mm_loadl_epi64(k5k0.unsafeAddr)

    x2 = mm_srli_si128(x1, 4)
    x1 = mm_and_si128(x1, x3)
    x1 = mm_clmulepi64_si128(x1, x0, 0x00)
    x1 = mm_xor_si128(x1, x2)

    x0 = mm_load_si128(poly.unsafeAddr)

    x2 = mm_and_si128(x1, x3)
    x2 = mm_clmulepi64_si128(x2, x0, 0x10)
    x2 = mm_and_si128(x2, x3)
    x2 = mm_clmulepi64_si128(x2, x0, 0x00)
    x1 = mm_xor_si128(x1, x2)

    cast[uint32](mm_extract_epi32(x1, 1))

elif defined(arm64):
  func crc32b(crc: uint32, v: uint8): uint32 {.importc: "__builtin_arm_crc32b", nodecl.}
  func crc32d(crc: uint32, v: uint64): uint32 {.importc: "__builtin_arm_crc32d", nodecl.}

  proc crc32_armv8a_crypto*(src: pointer, len: int): uint32 =
    let src = cast[ptr UncheckedArray[uint8]](src)

    var pos = 0

    result = not result

    # Align
    while pos < len and (cast[uint](src[pos].addr) and 7) != 0:
      result = crc32b(result, src[pos])
      inc pos

    while pos + 8 <= len:
      var tmp: uint64
      copyMem(tmp.addr, src[pos].addr, 8)
      result = crc32d(result, tmp)
      pos += 8

    while pos < len:
      result = crc32b(result, src[pos])
      inc pos

    result = not result
