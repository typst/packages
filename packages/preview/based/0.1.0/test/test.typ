#import "../src/lib.typ": *

// Test cases from: https://www.rfc-editor.org/rfc/rfc4648#section-10
#{
    // Test encode
    assert.eq(encode64(""), "")
    assert.eq(encode64("f"), "Zg==")
    assert.eq(encode64("fo"), "Zm8=")
    assert.eq(encode64("foo"), "Zm9v")
    assert.eq(encode64("foob"), "Zm9vYg==")
    assert.eq(encode64("fooba"), "Zm9vYmE=")
    assert.eq(encode64("foobar"), "Zm9vYmFy")

    assert.eq(encode32(""), "")
    assert.eq(encode32("f"), "MY======")
    assert.eq(encode32("fo"), "MZXQ====")
    assert.eq(encode32("foo"), "MZXW6===")
    assert.eq(encode32("foob"), "MZXW6YQ=")
    assert.eq(encode32("fooba"), "MZXW6YTB")
    assert.eq(encode32("foobar"), "MZXW6YTBOI======")

    assert.eq(encode32(hex: true, ""), "")
    assert.eq(encode32(hex: true, "f"), "CO======")
    assert.eq(encode32(hex: true, "fo"), "CPNG====")
    assert.eq(encode32(hex: true, "foo"), "CPNMU===")
    assert.eq(encode32(hex: true, "foob"), "CPNMUOG=")
    assert.eq(encode32(hex: true, "fooba"), "CPNMUOJ1")
    assert.eq(encode32(hex: true, "foobar"), "CPNMUOJ1E8======")

    assert.eq(encode16(""), "")
    assert.eq(encode16("f"), "66")
    assert.eq(encode16("fo"), "666f")
    assert.eq(encode16("foo"), "666f6f")
    assert.eq(encode16("foob"), "666f6f62")
    assert.eq(encode16("fooba"), "666f6f6261")
    assert.eq(encode16("foobar"), "666f6f626172")

    // Test decode
    assert.eq(str(decode64("")), "")
    assert.eq(str(decode64("Zg")), "f")
    assert.eq(str(decode64("Zm8=")), "fo")
    assert.eq(str(decode64("Zm9v")), "foo")
    assert.eq(str(decode64("Zm9vYg==")), "foob")
    assert.eq(str(decode64("Zm9vYmE")), "fooba")
    assert.eq(str(decode64("Zm9vYmFy")), "foobar")

    assert.eq(str(decode32("")), "")
    assert.eq(str(decode32("MY======")), "f")
    assert.eq(str(decode32("MZXQ")), "fo")
    assert.eq(str(decode32("MZXW6===")), "foo")
    assert.eq(str(decode32("MZXW6YQ=")), "foob")
    assert.eq(str(decode32("MZXW6YTB")), "fooba")
    assert.eq(str(decode32("MZXW6YTBOI")), "foobar")

    assert.eq(str(decode32(hex: true, "")), "")
    assert.eq(str(decode32(hex: true, "CO======")), "f")
    assert.eq(str(decode32(hex: true, "CPNG")), "fo")
    assert.eq(str(decode32(hex: true, "CPNMU===")), "foo")
    assert.eq(str(decode32(hex: true, "CPNMUOG")), "foob")
    assert.eq(str(decode32(hex: true, "CPNMUOJ1")), "fooba")
    assert.eq(str(decode32(hex: true, "CPNMUOJ1E8======")), "foobar")

    assert.eq(str(decode16("")), "")
    assert.eq(str(decode16("66")), "f")
    assert.eq(str(decode16("666f")), "fo")
    assert.eq(str(decode16("666F6F")), "foo")
    assert.eq(str(decode16("666f6f62")), "foob")
    assert.eq(str(decode16("666F6F6261")), "fooba")
    assert.eq(str(decode16("666F6f626172")), "foobar")
}
