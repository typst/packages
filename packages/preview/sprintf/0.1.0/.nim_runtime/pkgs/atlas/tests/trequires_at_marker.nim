import std/[unittest]
import basic/versions

suite "requires @ parsing":

  test "name without @ for version constraint":
    let req = "mcu_utils@#head"
    expect ValueError:
      let (name, feats, idx) = extractRequirementName(req)

  test "name without @ for version constraint":
    let req = "mcu_utils >= @0.1.0"
    let (name, feats, idx) = extractRequirementName(req)
    check name == "mcu_utils"
    check feats.len == 0
    var err = false
    expect ValueError:
      let iv = parseVersionInterval(req, idx, err)

  test "branch with odd chars":
    let req = "mcu_utils#0.1.0@new"
    let (name, feats, idx) = extractRequirementName(req)
    check name == "mcu_utils"
    check feats.len == 0
    var err = false
    let iv = parseVersionInterval(req, idx, err)
    check not err
    check $iv == "#0.1.0@new"

  test "name with http chars":
    let req = "https://github.com/zedeus/nitter#92cd6abcf6d9935bc0d7f013acbfbfd8ddd896ba"
    let (name, feats, idx) = extractRequirementName(req)
    check name == "https://github.com/zedeus/nitter"
    check feats.len == 0
    var err = false
    let iv = parseVersionInterval(req, idx, err)
    check not err
    check $iv == "#92cd6abcf6d9935bc0d7f013acbfbfd8ddd896ba"

  test "name without reqs":
    let req = "mcu_utils"
    let (name, feats, idx) = extractRequirementName(req)
    check name == "mcu_utils"
    check feats.len == 0
    var err = false
    let iv = parseVersionInterval(req, idx, err)
    check not err
    check $iv == "*"

  test "name without @ for #head":
    let req = "mcu_utils@#head"
    expect ValueError:
      let (name, feats, idx) = extractRequirementName(req)

  test "url without trailing @ in name":
    # not just me: https://github.com/seaqt/nim-seaqt?tab=readme-ov-file#using-the-bindings
    let req = "https://github.com/seaqt/nim-seaqt.git@#qt-6.4"
    expect ValueError:
      let (name, feats, idx) = extractRequirementName(req)
