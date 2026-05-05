import common

# These functions are Nim conversions of an original implementation
# from the Chromium repository. That implementation is:
#
# Copyright 2017 The Chromium Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the Chromium source repository LICENSE file.

const
  nmax = 5552
  blockSize = 32.uint32

when defined(amd64):
  when defined(gcc) or defined(clang):
    {.localPassC: "-mssse3".}

  {.push header: "emmintrin.h".}

  type M128i {.importc: "__m128i".} = object

  template MM_SHUFFLE(z, y, x, w: int | uint): int32 =
    ((z shl 6) or (y shl 4) or (x shl 2) or w).int32

  func mm_loadu_si128(p: pointer): M128i {.importc: "_mm_loadu_si128".}
  func mm_setzero_si128(): M128i {.importc: "_mm_setzero_si128".}
  func mm_set_epi32(a, b, c, d: int32 | uint32): M128i {.importc: "_mm_set_epi32".}
  func mm_setr_epi8(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p: int8 | uint8): M128i {.importc: "_mm_setr_epi8".}
  func mm_set1_epi16(a: int16 | uint16): M128i {.importc: "_mm_set1_epi16".}
  func mm_add_epi32(a, b: M128i): M128i {.importc: "_mm_add_epi32".}
  func mm_sad_epu8(a, b: M128i): M128i {.importc: "_mm_sad_epu8".}
  func mm_madd_epi16(a, b: M128i): M128i {.importc: "_mm_madd_epi16".}
  func mm_slli_epi32(a: M128i, imm8: int32 | uint32): M128i {.importc: "_mm_slli_epi32".}
  func mm_shuffle_epi32(a: M128i, imm8: int32 | uint32): M128i {.importc: "_mm_shuffle_epi32".}
  func mm_cvtsi128_si32(a: M128i): int32 {.importc: "_mm_cvtsi128_si32".}

  {.pop.}

  {.push header: "tmmintrin.h".}

  func mm_maddubs_epi16(a, b: M128i): M128i {.importc: "_mm_maddubs_epi16".}

  {.pop.}

  proc adler32_ssse3*(src: pointer, len: int): uint32 =
    if len == 0:
      return 1

    if len < 0:
      raise newException(ZippyError, "Adler-32 len < 0")
    if len.uint64 > uint32.high:
      raise newException(ZippyError, "Adler-32 len > uint32.high")

    let src = cast[ptr UncheckedArray[uint8]](src)

    var
      pos: uint32
      remaining = cast[uint32](len)
      s1 = 1.uint32
      s2 = 0.uint32

    var blocks = remaining div blockSize

    remaining -= (blocks * blockSize)

    let
      tap1 = mm_setr_epi8(32, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17)
      tap2 = mm_setr_epi8(16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1)
      zero = mm_setzero_si128()
      ones = mm_set1_epi16(1)

    while blocks > 0:
      var n = nmax div blockSize
      if n > blocks:
        n = blocks

      blocks -= n

      var
        vecPs = mm_set_epi32(0, 0, 0, s1 * n)
        vecS2 = mm_set_epi32(0, 0, 0, s2)
        vecS1 = mm_set_epi32(0, 0, 0, 0)

      while n > 0:
        let
          bytes1 = mm_loadu_si128(src[pos + 0].addr)
          bytes2 = mm_loadu_si128(src[pos + 16].addr)

        vecPs = mm_add_epi32(vecPs, vecS1)

        vecS1 = mm_add_epi32(vecS1, mm_sad_epu8(bytes1, zero))
        let mad1 = mm_maddubs_epi16(bytes1, tap1)
        vecS2 = mm_add_epi32(vecS2, mm_madd_epi16(mad1, ones))
        vecS1 = mm_add_epi32(vecS1, mm_sad_epu8(bytes2, zero))
        let mad2 = mm_maddubs_epi16(bytes2, tap2)
        vecS2 = mm_add_epi32(vecS2, mm_madd_epi16(mad2, ones))

        dec n
        pos += 32

      vecS2 = mm_add_epi32(vecS2, mm_slli_epi32(vecPs, 5))

      vecS1 = mm_add_epi32(vecS1, mm_shuffle_epi32(vecS1, MM_SHUFFLE(2, 3, 0, 1)))
      vecS1 = mm_add_epi32(vecS1, mm_shuffle_epi32(vecS1, MM_SHUFFLE(1, 0, 3, 2)))
      s1 += cast[uint32](mm_cvtsi128_si32(vecS1))
      vecS2 = mm_add_epi32(vecS2, mm_shuffle_epi32(vecS2, MM_SHUFFLE(2, 3, 0, 1)))
      vecS2 = mm_add_epi32(vecS2, mm_shuffle_epi32(vecS2, MM_SHUFFLE(1, 0, 3, 2)))
      s2 = cast[uint32](mm_cvtsi128_si32(vecS2))

      s1 = s1 mod 65521
      s2 = s2 mod 65521

    for i in 0 ..< remaining:
      s1 += src[pos + i]
      s2 += s1

    s1 = s1 mod 65521
    s2 = s2 mod 65521

    result = (s2 shl 16) or s1

elif defined(arm64):
  {.push header: "arm_neon.h".}

  type
    uint8x16 {.importc: "uint8x16_t".} = object
    uint16x8 {.importc: "uint16x8_t".} = object
    uint32x4 {.importc: "uint32x4_t".} = object
    uint8x8 {.importc: "uint8x8_t".} = object
    uint16x4 {.importc: "uint16x4_t".} = object
    uint32x2 {.importc: "uint32x2_t".} = object

  func vmovq_n_u32(a: uint32): uint32x4
  func vmovq_n_u16(a: uint16): uint16x8
  func vld1q_u32(p: pointer): uint32x4
  func vld1q_lane_u32(p: pointer, v: uint32x4, lane: int): uint32x4
  func vld1q_u8(p: pointer): uint8x16
  func vld1_u16(p: pointer): uint16x4
  func vaddq_u32(a, b: uint32x4): uint32x4
  func vpaddlq_u8(a: uint8x16): uint16x8
  func vpadalq_u8(a: uint16x8, b: uint8x16): uint16x8
  func vpadalq_u16(a: uint32x4, b: uint16x8): uint32x4
  func vget_low_u8(a: uint8x16): uint8x8
  func vget_high_u8(a: uint8x16): uint8x8
  func vaddw_u8(a: uint16x8, b: uint8x8): uint16x8
  func vshlq_n_u32(a: uint32x4, n: int): uint32x4
  func vpadd_u32(a, b: uint32x2): uint32x2
  func vget_low_u32(a: uint32x4): uint32x2
  func vget_high_u32(a: uint32x4): uint32x2
  func vget_lane_u32(a: uint32x2, lane: int): uint32
  func vget_low_u16(a: uint16x8): uint16x4
  func vget_high_u16(a: uint16x8): uint16x4
  func vmlal_u16(a: uint32x4, b, c: uint16x4): uint32x4

  {.pop.}

  proc adler32_neon*(src: pointer, len: int): uint32 =
    if len == 0:
      return 1

    if len < 0:
      raise newException(ZippyError, "Adler-32 len < 0")
    if len.uint64 > uint32.high:
      raise newException(ZippyError, "Adler-32 len > uint32.high")

    let src = cast[ptr UncheckedArray[uint8]](src)

    var
      pos: uint32
      remaining = cast[uint32](len)
      s1 = 1.uint32
      s2 = 0.uint32

    const blockSize = 32.uint32

    var blocks = remaining div blockSize

    remaining -= (blocks * blockSize)

    var wtf1, wtf2, wtf3, wtf4, wtf5, wtf6, wtf7, wtf8, wtf9: uint16x4
    block:
      var tmp = [32.uint16, 31, 30, 29]
      wtf1 = vld1_u16(tmp.addr)
      tmp = [28.uint16, 27, 26, 25]
      wtf2 = vld1_u16(tmp.addr)
      tmp = [24.uint16, 23, 22, 21]
      wtf3 = vld1_u16(tmp.addr)
      tmp = [20.uint16, 19, 18, 17]
      wtf4 = vld1_u16(tmp.addr)
      tmp = [16.uint16, 15, 14, 13]
      wtf5 = vld1_u16(tmp.addr)
      tmp = [12.uint16, 11, 10, 9]
      wtf6 = vld1_u16(tmp.addr)
      tmp = [8.uint16, 7, 6, 5]
      wtf7 = vld1_u16(tmp.addr)
      tmp = [4.uint16, 3, 2, 1]
      wtf8 = vld1_u16(tmp.addr)

    while blocks > 0:
      var n = nmax div blockSize
      if n > blocks:
        n = blocks

      blocks -= n
      var
        vecS2 = vmovq_n_u32(0)
        vecS1 = vmovq_n_u32(0)
        vecColumnSum1 = vmovq_n_u16(0)
        vecColumnSum2 = vmovq_n_u16(0)
        vecColumnSum3 = vmovq_n_u16(0)
        vecColumnSum4 = vmovq_n_u16(0)
      block:
        var tmp = s1 * n
        vecS2 = vld1q_lane_u32(tmp.addr, vecS2, 0)

      while n > 0:
        let
          bytes1 = vld1q_u8(src[pos + 0].addr)
          bytes2 = vld1q_u8(src[pos + 16].addr)
        vecS2 = vaddq_u32(vecS2, vecS1)
        vecS1 = vpadalq_u16(vecS1, vpadalq_u8(vpaddlq_u8(bytes1), bytes2))
        vecColumnSum1 = vaddw_u8(vecColumnSum1, vget_low_u8(bytes1))
        vecColumnSum2 = vaddw_u8(vecColumnSum2, vget_high_u8(bytes1))
        vecColumnSum3 = vaddw_u8(vecColumnSum3, vget_low_u8(bytes2))
        vecColumnSum4 = vaddw_u8(vecColumnSum4, vget_high_u8(bytes2))
        dec n
        pos += 32

      vecS2 = vshlq_n_u32(vecS2, 5)

      vecS2 = vmlal_u16(vecS2, vget_low_u16(vecColumnSum1), wtf1)
      vecS2 = vmlal_u16(vecS2, vget_high_u16(vecColumnSum1), wtf2)
      vecS2 = vmlal_u16(vecS2, vget_low_u16(vecColumnSum2), wtf3)
      vecS2 = vmlal_u16(vecS2, vget_high_u16(vecColumnSum2), wtf4)
      vecS2 = vmlal_u16(vecS2, vget_low_u16(vecColumnSum3), wtf5)
      vecS2 = vmlal_u16(vecS2, vget_high_u16(vecColumnSum3), wtf6)
      vecS2 = vmlal_u16(vecS2, vget_low_u16(vecColumnSum4), wtf7)
      vecS2 = vmlal_u16(vecS2, vget_high_u16(vecColumnSum4), wtf8)

      let
        sum1 = vpadd_u32(vget_low_u32(vecS1), vget_high_u32(vecS1))
        sum2 = vpadd_u32(vget_low_u32(vecS2), vget_high_u32(vecS2))
        s1s2 = vpadd_u32(sum1, sum2)

      s1 += vget_lane_u32(s1s2, 0)
      s2 += vget_lane_u32(s1s2, 1)

      s1 = s1 mod 65521
      s2 = s2 mod 65521

    for i in 0 ..< remaining:
      s1 += src[pos + i]
      s2 += s1

    s1 = s1 mod 65521
    s2 = s2 mod 65521

    result = (s2 shl 16) or s1
