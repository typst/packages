function getDefaultExportFromCjs(x) {
  return x && x.__esModule && Object.prototype.hasOwnProperty.call(x, "default") ? x["default"] : x;
}
function getAugmentedNamespace(n) {
  if (n.__esModule)
    return n;
  var f = n.default;
  if (typeof f == "function") {
    var a = function a2() {
      if (this instanceof a2) {
        return Reflect.construct(f, arguments, this.constructor);
      }
      return f.apply(this, arguments);
    };
    a.prototype = f.prototype;
  } else
    a = {};
  Object.defineProperty(a, "__esModule", { value: true });
  Object.keys(n).forEach(function(k) {
    var d = Object.getOwnPropertyDescriptor(n, k);
    Object.defineProperty(a, k, d.get ? d : {
      enumerable: true,
      get: function() {
        return n[k];
      }
    });
  });
  return a;
}
var lib$2 = {};
const isObject = (o) => o && Object.prototype.toString.call(o) === "[object Object]";
function indenter(indentation) {
  if (!(indentation > 0)) {
    return (txt) => txt;
  }
  var space = " ".repeat(indentation);
  return (txt) => {
    if (typeof txt !== "string") {
      return txt;
    }
    const arr = txt.split("\n");
    if (arr.length === 1) {
      return space + txt;
    }
    return arr.map((e) => e.trim() === "" ? e : space + e).join("\n");
  };
}
const clean = (txt) => txt.split("\n").filter((e) => e.trim() !== "").join("\n");
function stringify$5(a, indentation) {
  const cr = indentation > 0 ? "\n" : "";
  const indent = indenter(indentation);
  function rec2(a2) {
    let body = "";
    let isFlat = true;
    let res;
    const isEmpty = a2.some((e, i, arr) => {
      if (i === 0) {
        res = "<" + e;
        return arr.length === 1;
      }
      if (i === 1) {
        if (isObject(e)) {
          Object.keys(e).map((key2) => {
            let val = e[key2];
            if (Array.isArray(val)) {
              val = val.join(" ");
            }
            res += " " + key2 + '="' + val + '"';
          });
          if (arr.length === 2) {
            return true;
          }
          res += ">";
          return;
        }
        res += ">";
      }
      switch (typeof e) {
        case "string":
        case "number":
        case "boolean":
        case "undefined":
          body += e + cr;
          return;
      }
      isFlat = false;
      body += rec2(e);
    });
    if (isEmpty) {
      return res + "/>" + cr;
    }
    return isFlat ? res + clean(body) + "</" + a2[0] + ">" + cr : res + cr + indent(body) + "</" + a2[0] + ">" + cr;
  }
  return rec2(a);
}
var stringify_1 = stringify$5;
var tt$a = (x, y, obj) => {
  let objt = {};
  if (x || y) {
    const tt2 = [x || 0].concat(y ? [y] : []);
    objt = { transform: "translate(" + tt2.join(",") + ")" };
  }
  obj = typeof obj === "object" ? obj : {};
  return Object.assign(objt, obj);
};
const name = "wavedrom";
const version = "3.3.0";
const description = "Digital timing diagram in your browser";
const homepage = "http://wavedrom.com";
const author = "alex.drom@gmail.com";
const license = "MIT";
const repository = {
  type: "git",
  url: "https://github.com/wavedrom/wavedrom.git"
};
const bugs = {
  url: "https://github.com/wavedrom/wavedrom/issues"
};
const main = "./lib";
const unpkg = "wavedrom.unpkg.min.js";
const files = [
  "bin/cli.js",
  "wavedrom.js",
  "wavedrom.min.js",
  "wavedrom.unpkg.js",
  "wavedrom.unpkg.min.js",
  "LICENSE",
  "lib/**",
  "skins/**"
];
const scripts = {
  test: "npm-run-all eslint nyc",
  eslint: "eslint lib/*.js",
  nyc: "nyc -r=lcov -r=text mocha test",
  dist: "browserify ./lib/wave-drom.js > wavedrom.js",
  "watch.dist": "watchify ./lib/wave-drom.js -o wavedrom.js -v",
  "dist.min": "terser --compress --mengle -- wavedrom.js | node ./bin/header.js > wavedrom.min.js",
  unpkg: "browserify --standalone wavedrom lib/index.js > wavedrom.unpkg.js",
  "unpkg.min": "terser --compress --mengle -- wavedrom.unpkg.js | node ./bin/header.js > wavedrom.unpkg.min.js",
  cli: "{ echo '#!/usr/bin/env node' ; browserify --node bin/cli.js ; } > bin/wavedrom.js ; chmod +x bin/wavedrom.js",
  prepare: "npm-run-all test dist dist.min unpkg unpkg.min",
  coverage: "nyc report -r=text-lcov | coveralls",
  clean: "rm -rf wavedrom.js wavedrom.*.js coverage .nyc_output",
  skins: "for S in default narrow dark lowkey ; do node bin/svg2js.js -i unpacked/skins/$S.svg > skins/$S.js ; done"
};
const keywords = [
  "waveform",
  "verilog",
  "RTL"
];
const devDependencies = {
  "@drom/eslint-config": "^0.11.0",
  browserify: "^17.0.0",
  chai: "^4.3",
  coveralls: "^3.1.1",
  eslint: "^8.44",
  "fs-extra": "^11.1",
  json5: "^2.2.3",
  mocha: "^10",
  "npm-run-all": "^4.1.5",
  nyc: "^15.1.0",
  terser: "^5.18",
  watchify: "^4.0.0",
  yargs: "^17.7"
};
const dependencies = {
  "bit-field": "^1.8.0",
  logidrom: "^0.3.1",
  onml: "^2.1.0",
  tspan: "^0.4.0"
};
const eslintConfig = {
  "extends": "@drom/eslint-config/eslint4/node4",
  rules: {
    camelcase: 0
  }
};
const require$$2 = {
  name,
  version,
  description,
  homepage,
  author,
  license,
  repository,
  bugs,
  main,
  unpkg,
  files,
  scripts,
  keywords,
  devDependencies,
  dependencies,
  eslintConfig
};
function erra(e) {
  console.log("Error in WaveJS: ", e);
  const msg = ["tspan", ["tspan", { class: "error h5" }, "Error: "], e.message];
  msg.textWidth = 1e3;
  return { signal: [{ name: msg }] };
}
function eva$3(id) {
  const TheTextBox = document.getElementById(id);
  let source;
  if (TheTextBox.type && TheTextBox.type === "textarea") {
    try {
      source = eval("(" + TheTextBox.value + ")");
    } catch (e) {
      return erra(e);
    }
  } else {
    try {
      source = eval("(" + TheTextBox.innerHTML + ")");
    } catch (e) {
      return erra(e);
    }
  }
  if (Object.prototype.toString.call(source) !== "[object Object]") {
    return erra({ message: '[Semantic]: The root has to be an Object: "{signal:[...]}"' });
  }
  if (source.signal) {
    if (!Array.isArray(source.signal)) {
      return erra({ message: '[Semantic]: "signal" object has to be an Array "signal:[]"' });
    }
  } else if (source.assign) {
    if (!Array.isArray(source.assign)) {
      return erra({ message: '[Semantic]: "assign" object hasto be an Array "assign:[]"' });
    }
  } else if (source.reg)
    ;
  else {
    return erra({ message: '[Semantic]: "signal:[...]" or "assign:[...]" property is missing inside the root Object' });
  }
  return source;
}
var eva_1 = eva$3;
function appendSaveAsDialog$1(index, output) {
  let menu;
  function closeMenu(e) {
    const left = parseInt(menu.style.left, 10);
    const top = parseInt(menu.style.top, 10);
    if (e.x < left || e.x > left + menu.offsetWidth || e.y < top || e.y > top + menu.offsetHeight) {
      menu.parentNode.removeChild(menu);
      document.body.removeEventListener("mousedown", closeMenu, false);
    }
  }
  const div = document.getElementById(output + index);
  div.childNodes[0].addEventListener(
    "contextmenu",
    function(e) {
      menu = document.createElement("div");
      menu.className = "wavedromMenu";
      menu.style.top = e.y + "px";
      menu.style.left = e.x + "px";
      const list = document.createElement("ul");
      const savePng = document.createElement("li");
      savePng.innerHTML = "Save as PNG";
      list.appendChild(savePng);
      const saveSvg = document.createElement("li");
      saveSvg.innerHTML = "Save as SVG";
      list.appendChild(saveSvg);
      menu.appendChild(list);
      document.body.appendChild(menu);
      savePng.addEventListener(
        "click",
        function() {
          let html = "";
          if (index !== 0) {
            const firstDiv = document.getElementById(output + 0);
            html += firstDiv.innerHTML.substring(166, firstDiv.innerHTML.indexOf('<g id="waves_0">'));
          }
          html = [div.innerHTML.slice(0, 166), html, div.innerHTML.slice(166)].join("");
          const svgdata = "data:image/svg+xml;base64," + btoa(html);
          const img = new Image();
          img.src = svgdata;
          const canvas = document.createElement("canvas");
          canvas.width = img.width;
          canvas.height = img.height;
          const context = canvas.getContext("2d");
          context.drawImage(img, 0, 0);
          const pngdata = canvas.toDataURL("image/png");
          const a = document.createElement("a");
          a.href = pngdata;
          a.download = "wavedrom.png";
          a.click();
          menu.parentNode.removeChild(menu);
          document.body.removeEventListener("mousedown", closeMenu, false);
        },
        false
      );
      saveSvg.addEventListener(
        "click",
        function() {
          let html = "";
          if (index !== 0) {
            const firstDiv = document.getElementById(output + 0);
            html += firstDiv.innerHTML.substring(166, firstDiv.innerHTML.indexOf('<g id="waves_0">'));
          }
          html = [div.innerHTML.slice(0, 166), html, div.innerHTML.slice(166)].join("");
          const svgdata = "data:image/svg+xml;base64," + btoa(html);
          const a = document.createElement("a");
          a.href = svgdata;
          a.download = "wavedrom.svg";
          a.click();
          menu.parentNode.removeChild(menu);
          document.body.removeEventListener("mousedown", closeMenu, false);
        },
        false
      );
      menu.addEventListener(
        "contextmenu",
        function(ee) {
          ee.preventDefault();
        },
        false
      );
      document.body.addEventListener("mousedown", closeMenu, false);
      e.preventDefault();
    },
    false
  );
}
var appendSaveAsDialog_1 = appendSaveAsDialog$1;
function render$4(tree, state) {
  state.xmax = Math.max(state.xmax, state.x);
  const y = state.y;
  const ilen = tree.length;
  for (let i = 1; i < ilen; i++) {
    const branch = tree[i];
    if (Array.isArray(branch)) {
      state = render$4(branch, {
        x: state.x + 1,
        y: state.y,
        xmax: state.xmax
      });
    } else {
      tree[i] = {
        name: branch,
        x: state.x + 1,
        y: state.y
      };
      state.y += 2;
    }
  }
  tree[0] = {
    name: tree[0],
    x: state.x,
    y: Math.round((y + (state.y - 2)) / 2)
  };
  state.x--;
  return state;
}
var render_1$1 = render$4;
var lib$1 = {};
var escapeMap = {
  "&": "&amp;",
  '"': "&quot;",
  "<": "&lt;",
  ">": "&gt;"
};
function xscape(val) {
  if (typeof val !== "string") {
    return val;
  }
  return val.replace(
    /([&"<>])/g,
    function(_, e) {
      return escapeMap[e];
    }
  );
}
var token$1 = /<o>|<ins>|<s>|<sub>|<sup>|<b>|<i>|<tt>|<\/o>|<\/ins>|<\/s>|<\/sub>|<\/sup>|<\/b>|<\/i>|<\/tt>/;
function update(s, cmd) {
  if (cmd.add) {
    cmd.add.split(";").forEach(function(e) {
      var arr = e.split(" ");
      s[arr[0]][arr[1]] = true;
    });
  }
  if (cmd.del) {
    cmd.del.split(";").forEach(function(e) {
      var arr = e.split(" ");
      delete s[arr[0]][arr[1]];
    });
  }
}
var trans = {
  "<o>": { add: "text-decoration overline" },
  "</o>": { del: "text-decoration overline" },
  "<ins>": { add: "text-decoration underline" },
  "</ins>": { del: "text-decoration underline" },
  "<s>": { add: "text-decoration line-through" },
  "</s>": { del: "text-decoration line-through" },
  "<b>": { add: "font-weight bold" },
  "</b>": { del: "font-weight bold" },
  "<i>": { add: "font-style italic" },
  "</i>": { del: "font-style italic" },
  "<sub>": { add: "baseline-shift sub;font-size .7em" },
  "</sub>": { del: "baseline-shift sub;font-size .7em" },
  "<sup>": { add: "baseline-shift super;font-size .7em" },
  "</sup>": { del: "baseline-shift super;font-size .7em" },
  "<tt>": { add: "font-family monospace" },
  "</tt>": { del: "font-family monospace" }
};
function dump(s) {
  return Object.keys(s).reduce(function(pre, cur) {
    var keys = Object.keys(s[cur]);
    if (keys.length > 0) {
      pre[cur] = keys.join(" ");
    }
    return pre;
  }, {});
}
function parse$5(str) {
  var state, res, i, m, a;
  if (str === void 0) {
    return [];
  }
  if (typeof str === "number") {
    return [str + ""];
  }
  if (typeof str !== "string") {
    return [str];
  }
  res = [];
  state = {
    "text-decoration": {},
    "font-weight": {},
    "font-style": {},
    "baseline-shift": {},
    "font-size": {},
    "font-family": {}
  };
  while (true) {
    i = str.search(token$1);
    if (i === -1) {
      res.push(["tspan", dump(state), xscape(str)]);
      return res;
    }
    if (i > 0) {
      a = str.slice(0, i);
      res.push(["tspan", dump(state), xscape(a)]);
    }
    m = str.match(token$1)[0];
    update(state, trans[m]);
    str = str.slice(i + m.length);
    if (str.length === 0) {
      return res;
    }
  }
}
var parse_1$1 = parse$5;
var parse$4 = parse_1$1;
function deDash(str) {
  var m = str.match(/(\w+)-(\w)(\w+)/);
  if (m === null) {
    return str;
  }
  var newStr = m[1] + m[2].toUpperCase() + m[3];
  return newStr;
}
function reparse$1(React) {
  var $ = React.createElement;
  function reTspan(e, i) {
    var tag = e[0];
    var attr = e[1];
    var newAttr = Object.keys(attr).reduce(function(res, key2) {
      var newKey = deDash(key2);
      res[newKey] = attr[key2];
      return res;
    }, {});
    var body = e[2];
    newAttr.key = i;
    return $(tag, newAttr, body);
  }
  return function(str) {
    return parse$4(str).map(reTspan);
  };
}
var reparse_1 = reparse$1;
var parse$3 = parse_1$1, reparse = reparse_1;
lib$1.parse = parse$3;
lib$1.reparse = reparse;
const tspan$7 = lib$1;
const circle = "M 4,0 C 4,1.1 3.1,2 2,2 0.9,2 0,1.1 0,0 c 0,-1.1 0.9,-2 2,-2 1.1,0 2,0.9 2,2 z";
const buf1 = "M -11,-6 -11,6 0,0 z m -5,6 5,0";
const and2 = "m -16,-10 5,0 c 6,0 11,4 11,10 0,6 -5,10 -11,10 l -5,0 z";
const or2 = "m -18,-10 4,0 c 6,0 12,5 14,10 -2,5 -8,10 -14,10 l -4,0 c 2.5,-5 2.5,-15 0,-20 z";
const xor2 = "m -21,-10 c 1,3 2,6 2,10 m 0,0 c 0,4 -1,7 -2,10 m 3,-20 4,0 c 6,0 12,5 14,10 -2,5 -8,10 -14,10 l -4,0 c 1,-3 2,-6 2,-10 0,-4 -1,-7 -2,-10 z";
const circle2 = "c 0,4.418278 -3.581722,8 -8,8 -4.418278,0 -8,-3.581722 -8,-8 0,-4.418278 3.581722,-8 8,-8 4.418278,0 8,3.581722 8,8 z";
const gates = {
  "=": buf1,
  "~": buf1 + circle,
  "&": and2,
  "~&": and2 + circle,
  "|": or2,
  "~|": or2 + circle,
  "^": xor2,
  "~^": xor2 + circle,
  "+": "m -8,5 0,-10 m -5,5 10,0 m 3,0" + circle2,
  "*": "m -4,4 -8,-8 m 0,8 8,-8  m 4,4" + circle2,
  "-": "m -3,0 -10,0 m 13,0" + circle2
};
const aliasGates = {
  add: "+",
  mul: "*",
  sub: "-",
  and: "&",
  or: "|",
  xor: "^",
  andr: "&",
  orr: "|",
  xorr: "^",
  input: "="
};
Object.keys(aliasGates).reduce((res, key2) => {
  res[key2] = gates[aliasGates[key2]];
  return res;
}, gates);
const gater1 = {
  is: (type) => gates[type] !== void 0,
  render: (type) => ["path", { class: "gate", d: gates[type] }]
};
const iec = {
  eq: "==",
  ne: "!=",
  slt: "<",
  sle: "<=",
  sgt: ">",
  sge: ">=",
  ult: "<",
  ule: "<=",
  ugt: ">",
  uge: ">=",
  BUF: 1,
  INV: 1,
  AND: "&",
  NAND: "&",
  OR: "≥1",
  NOR: "≥1",
  XOR: "=1",
  XNOR: "=1",
  box: "",
  MUX: "M"
};
const circled = { INV: 1, NAND: 1, NOR: 1, XNOR: 1 };
const gater2 = {
  is: (type) => iec[type] !== void 0,
  render: (type, ymin, ymax) => {
    if (ymin === ymax) {
      ymin = -4;
      ymax = 4;
    }
    return [
      "g",
      ["path", {
        class: "gate",
        d: "m -16," + (ymin - 3) + " 16,0 0," + (ymax - ymin + 6) + " -16,0 z" + (circled[type] ? circle : "")
      }],
      ["text", { x: -14, y: 4, class: "wirename" }].concat(tspan$7.parse(iec[type]))
    ];
  }
};
function drawBody$1(type, ymin, ymax) {
  if (gater1.is(type)) {
    return gater1.render(type);
  }
  if (gater2.is(type)) {
    return gater2.render(type, ymin, ymax);
  }
  return ["text", { x: -14, y: 4, class: "wirename" }].concat(tspan$7.parse(type));
}
var draw_body = drawBody$1;
const tspan$6 = lib$1;
const drawBody = draw_body;
function drawGate$1(spec) {
  const ilen = spec.length;
  const ys = [];
  for (let i = 2; i < ilen; i++) {
    ys.push(spec[i][1]);
  }
  const ret = ["g"];
  const ymin = Math.min.apply(null, ys);
  const ymax = Math.max.apply(null, ys);
  ret.push([
    "g",
    { transform: "translate(16,0)" },
    ["path", {
      d: "M" + spec[2][0] + "," + ymin + " " + spec[2][0] + "," + ymax,
      class: "wire"
    }]
  ]);
  for (let i = 2; i < ilen; i++) {
    ret.push([
      "g",
      ["path", {
        d: "m" + spec[i][0] + "," + spec[i][1] + " 16,0",
        class: "wire"
      }]
    ]);
  }
  ret.push([
    "g",
    { transform: "translate(" + spec[1][0] + "," + spec[1][1] + ")" },
    ["title"].concat(tspan$6.parse(spec[0])),
    drawBody(spec[0], ymin - spec[1][1], ymax - spec[1][1])
  ]);
  return ret;
}
var draw_gate = drawGate$1;
const tspan$5 = lib$1;
const drawGate = draw_gate;
function drawBoxes$1(tree, xmax) {
  const ret = ["g"];
  const spec = [];
  if (Array.isArray(tree)) {
    spec.push(tree[0].name);
    spec.push([32 * (xmax - tree[0].x), 8 * tree[0].y]);
    for (let i = 1; i < tree.length; i++) {
      const branch = tree[i];
      if (Array.isArray(branch)) {
        spec.push([32 * (xmax - branch[0].x), 8 * branch[0].y]);
      } else {
        spec.push([32 * (xmax - branch.x), 8 * branch.y]);
      }
    }
    ret.push(drawGate(spec));
    for (let i = 1; i < tree.length; i++) {
      const branch = tree[i];
      ret.push(drawBoxes$1(branch, xmax));
    }
    return ret;
  }
  const fname = tree.name;
  const fx = 32 * (xmax - tree.x);
  const fy = 8 * tree.y;
  ret.push(
    [
      "g",
      { transform: "translate(" + fx + "," + fy + ")" },
      ["title"].concat(tspan$5.parse(fname)),
      ["path", { d: "M 2,0 a 2,2 0 1 1 -4,0 2,2 0 1 1 4,0 z" }],
      ["text", { x: -4, y: 4, class: "pinname" }].concat(tspan$5.parse(fname))
    ]
  );
  return ret;
}
var draw_boxes = drawBoxes$1;
function insertSVGTemplateAssign$1() {
  return ["style", ".pinname {font-size:12px; font-style:normal; font-variant:normal; font-weight:500; font-stretch:normal; text-align:center; text-anchor:end; font-family:Helvetica} .wirename {font-size:12px; font-style:normal; font-variant:normal; font-weight:500; font-stretch:normal; text-align:center; text-anchor:start; font-family:Helvetica} .wirename:hover {fill:blue} .gate {color:#000; fill:#ffc; fill-opacity: 1;stroke:#000; stroke-width:1; stroke-opacity:1} .gate:hover {fill:red !important; } .wire {fill:none; stroke:#000; stroke-width:1; stroke-opacity:1} .grid {fill:#fff; fill-opacity:1; stroke:none}"];
}
var insertSvgTemplateAssign = insertSVGTemplateAssign$1;
const render$3 = render_1$1;
const drawBoxes = draw_boxes;
const insertSVGTemplateAssign = insertSvgTemplateAssign;
function renderAssign$1(index, source2) {
  let state = { x: 0, y: 2, xmax: 0 };
  const tree = source2.assign;
  const ilen = tree.length;
  for (let i = 0; i < ilen; i++) {
    state = render$3(tree[i], state);
    state.x++;
  }
  const xmax = state.xmax + 3;
  const svg = ["g"];
  for (let i = 0; i < ilen; i++) {
    svg.push(drawBoxes(tree[i], xmax));
  }
  const width = 32 * (xmax + 1) + 1;
  const height = 8 * (state.y + 1) - 7;
  return [
    "svg",
    {
      id: "svgcontent_" + index,
      viewBox: "0 0 " + width + " " + height,
      width,
      height
    },
    insertSVGTemplateAssign(),
    ["g", { transform: "translate(0.5, 0.5)" }, svg]
  ];
}
var renderAssign_1 = renderAssign$1;
const tspan$4 = lib$1;
const round = Math.round;
const getSVG = (w, h) => ["svg", {
  xmlns: "http://www.w3.org/2000/svg",
  // TODO link ns?
  width: w,
  height: h,
  viewBox: [0, 0, w, h].join(" ")
}];
const tt$9 = (x, y, obj) => Object.assign(
  { transform: "translate(" + x + (y ? "," + y : "") + ")" },
  typeof obj === "object" ? obj : {}
);
const colors$1 = {
  // TODO compare with WaveDrom
  2: 0,
  3: 80,
  4: 170,
  5: 45,
  6: 126,
  7: 215
};
const typeStyle = (t) => colors$1[t] !== void 0 ? ";fill:hsl(" + colors$1[t] + ",100%,50%)" : "";
const norm = (obj, other2) => Object.assign(
  Object.keys(obj).reduce((prev, key2) => {
    const val = Number(obj[key2]);
    const valInt = isNaN(val) ? 0 : Math.round(val);
    if (valInt !== 0) {
      prev[key2] = valInt;
    }
    return prev;
  }, {}),
  other2
);
const trimText = (text2, availableSpace, charWidth2) => {
  if (!(typeof text2 === "string" || text2 instanceof String))
    return text2;
  const textWidth2 = text2.length * charWidth2;
  if (textWidth2 <= availableSpace)
    return text2;
  var end = text2.length - (textWidth2 - availableSpace) / charWidth2 - 3;
  if (end > 0)
    return text2.substring(0, end) + "...";
  return text2.substring(0, 1) + "...";
};
const text = (body, x, y, rotate) => {
  const props = { y: 6 };
  if (rotate !== void 0) {
    props.transform = "rotate(" + rotate + ")";
  }
  return ["g", tt$9(round(x), round(y)), ["text", props].concat(tspan$4.parse(body))];
};
const hline = (len, x, y) => ["line", norm({ x1: x, x2: x + len, y1: y, y2: y })];
const vline = (len, x, y) => ["line", norm({ x1: x, x2: x, y1: y, y2: y + len })];
const getLabel = (val, x, y, step, len, rotate) => {
  if (typeof val !== "number") {
    return text(val, x, y, rotate);
  }
  const res = ["g", {}];
  for (let i = 0; i < len; i++) {
    res.push(text(
      val >> i & 1,
      x + step * (len / 2 - i - 0.5),
      y
    ));
  }
  return res;
};
const getAttr = (e, opt, step, lsbm, msbm) => {
  const x = opt.vflip ? step * ((msbm + lsbm) / 2) : step * (opt.mod - (msbm + lsbm) / 2 - 1);
  if (!Array.isArray(e.attr)) {
    return getLabel(e.attr, x, 0, step, e.bits);
  }
  return e.attr.reduce(
    (prev, a, i) => a === void 0 || a === null ? prev : prev.concat([getLabel(a, x, opt.fontsize * i, step, e.bits)]),
    ["g", {}]
  );
};
const labelArr = (desc, opt) => {
  const { margin, hspace, vspace, mod, index, fontsize, vflip, trim, compact } = opt;
  const width = hspace - margin.left - margin.right - 1;
  const height = vspace - margin.top - margin.bottom;
  const step = width / mod;
  const blanks = ["g"];
  const bits = ["g", tt$9(round(step / 2), -round(0.5 * fontsize + 4))];
  const names = ["g", tt$9(round(step / 2), round(0.5 * height + 0.4 * fontsize - 6))];
  const attrs = ["g", tt$9(round(step / 2), round(height + 0.7 * fontsize - 2))];
  desc.map((e) => {
    let lsbm = 0;
    let msbm = mod - 1;
    let lsb = index * mod;
    let msb = (index + 1) * mod - 1;
    if (e.lsb / mod >> 0 === index) {
      lsbm = e.lsbm;
      lsb = e.lsb;
      if (e.msb / mod >> 0 === index) {
        msb = e.msb;
        msbm = e.msbm;
      }
    } else {
      if (e.msb / mod >> 0 === index) {
        msb = e.msb;
        msbm = e.msbm;
      } else if (!(lsb > e.lsb && msb < e.msb)) {
        return;
      }
    }
    if (!compact) {
      bits.push(text(lsb, step * (vflip ? lsbm : mod - lsbm - 1)));
      if (lsbm !== msbm) {
        bits.push(text(msb, step * (vflip ? msbm : mod - msbm - 1)));
      }
    }
    if (e.name !== void 0) {
      names.push(getLabel(
        trim ? trimText(e.name, step * e.bits, trim) : e.name,
        step * (vflip ? (msbm + lsbm) / 2 : mod - (msbm + lsbm) / 2 - 1),
        0,
        step,
        e.bits,
        e.rotate
      ));
    }
    if (e.name === void 0 || e.type !== void 0) {
      if (!(opt.compact && e.type === void 0)) {
        blanks.push(["rect", norm({
          x: step * (vflip ? lsbm : mod - msbm - 1),
          width: step * (msbm - lsbm + 1),
          height
        }, {
          field: e.name,
          style: "fill-opacity:0.1" + typeStyle(e.type)
        })]);
      }
    }
    if (e.attr !== void 0) {
      attrs.push(getAttr(e, opt, step, lsbm, msbm));
    }
  });
  return ["g", blanks, bits, names, attrs];
};
const getLabelMask = (desc, mod) => {
  const mask = [];
  let idx = 0;
  desc.map((e) => {
    mask[idx % mod] = true;
    idx += e.bits;
    mask[(idx - 1) % mod] = true;
  });
  return mask;
};
const getLegendItems = (opt) => {
  const { hspace, margin, fontsize, legend } = opt;
  const width = hspace - margin.left - margin.right - 1;
  const items = ["g", tt$9(margin.left, -10)];
  const legendSquarePadding = 36;
  const legendNamePadding = 24;
  let x = width / 2 - Object.keys(legend).length / 2 * (legendSquarePadding + legendNamePadding);
  for (const key2 in legend) {
    const value = legend[key2];
    items.push(["rect", norm({
      x,
      width: 12,
      height: 12
    }, {
      style: "fill-opacity:0.15; stroke: #000; stroke-width: 1.2;" + typeStyle(value)
    })]);
    x += legendSquarePadding;
    items.push(text(
      key2,
      x,
      0.1 * fontsize + 4
    ));
    x += legendNamePadding;
  }
  return items;
};
const compactLabels = (desc, opt) => {
  const { hspace, margin, mod, fontsize, vflip, legend } = opt;
  const width = hspace - margin.left - margin.right - 1;
  const step = width / mod;
  const labels = ["g", tt$9(margin.left, legend ? 0 : -3)];
  const mask = getLabelMask(desc, mod);
  for (let i = 0; i < mod; i++) {
    const idx = vflip ? i : mod - i - 1;
    if (mask[idx]) {
      labels.push(text(
        idx,
        step * (i + 0.5),
        0.5 * fontsize + 4
      ));
    }
  }
  return labels;
};
const skipDrawingEmptySpace = (desc, opt, laneIndex, laneLength, globalIndex) => {
  if (!opt.compact)
    return false;
  const isEmptyBitfield = (bitfield) => bitfield.name === void 0 && bitfield.type === void 0;
  const bitfieldIndex = desc.findIndex((e) => isEmptyBitfield(e) && globalIndex >= e.lsb && globalIndex <= e.msb + 1);
  if (bitfieldIndex === -1) {
    return false;
  }
  if (globalIndex > desc[bitfieldIndex].lsb && globalIndex < desc[bitfieldIndex].msb + 1) {
    return true;
  }
  if (globalIndex == desc[bitfieldIndex].lsb && (laneIndex === 0 || bitfieldIndex > 0 && isEmptyBitfield(desc[bitfieldIndex - 1]))) {
    return true;
  }
  if (globalIndex == desc[bitfieldIndex].msb + 1 && (laneIndex === laneLength || bitfieldIndex < desc.length - 1 && isEmptyBitfield(desc[bitfieldIndex + 1]))) {
    return true;
  }
  return false;
};
const cage = (desc, opt) => {
  const { hspace, vspace, mod, margin, index, vflip } = opt;
  const width = hspace - margin.left - margin.right - 1;
  const height = vspace - margin.top - margin.bottom;
  const res = [
    "g",
    {
      stroke: "black",
      "stroke-width": 1,
      "stroke-linecap": "round"
    }
  ];
  if (opt.sparse) {
    const skipEdge = opt.uneven && opt.bits % 2 === 1 && index === opt.lanes - 1;
    if (skipEdge) {
      if (vflip) {
        res.push(
          hline(width - width / mod, 0, 0),
          hline(width - width / mod, 0, height)
        );
      } else {
        res.push(
          hline(width - width / mod, width / mod, 0),
          hline(width - width / mod, width / mod, height)
        );
      }
    } else if (!opt.compact) {
      res.push(
        hline(width, 0, 0),
        hline(width, 0, height),
        vline(height, vflip ? width : 0, 0)
      );
    }
  } else {
    res.push(
      hline(width, 0, 0),
      vline(height, vflip ? width : 0, 0),
      hline(width, 0, height)
    );
  }
  let i = index * mod;
  const delta = vflip ? 1 : -1;
  let j = vflip ? 0 : mod;
  if (opt.sparse) {
    for (let k = 0; k <= mod; k++) {
      if (skipDrawingEmptySpace(desc, opt, k, mod, i)) {
        i++;
        j += delta;
        continue;
      }
      const xj = j * (width / mod);
      if (k === 0 || k === mod || desc.some((e) => e.msb + 1 === i)) {
        res.push(vline(height, xj, 0));
      } else {
        res.push(
          vline(height >>> 3, xj, 0),
          vline(-(height >>> 3), xj, height)
        );
      }
      if (opt.compact && k !== 0 && !skipDrawingEmptySpace(desc, opt, k - 1, mod, i - 1)) {
        res.push(
          hline(width / mod, xj, 0),
          hline(width / mod, xj, height)
        );
      }
      i++;
      j += delta;
    }
  } else {
    for (let k = 0; k < mod; k++) {
      const xj = j * (width / mod);
      if (k === 0 || desc.some((e) => e.lsb === i)) {
        res.push(vline(height, xj, 0));
      } else {
        res.push(
          vline(height >>> 3, xj, 0),
          vline(-(height >>> 3), xj, height)
        );
      }
      i++;
      j += delta;
    }
  }
  return res;
};
const lane$2 = (desc, opt) => {
  const { index, vspace, hspace, margin, hflip, lanes, compact, label } = opt;
  const height = vspace - margin.top - margin.bottom;
  const width = hspace - margin.left - margin.right - 1;
  let tx = margin.left;
  const idx = hflip ? index : lanes - index - 1;
  let ty = round(idx * vspace + margin.top);
  if (compact) {
    ty = round(idx * height + margin.top);
  }
  const res = [
    "g",
    tt$9(tx, ty),
    cage(desc, opt),
    labelArr(desc, opt)
  ];
  if (label && label.left !== void 0) {
    const lab = label.left;
    let txt = index;
    if (typeof lab === "string") {
      txt = lab;
    } else if (typeof lab === "number") {
      txt += lab;
    } else if (typeof lab === "object") {
      txt = lab[index] || txt;
    }
    res.push([
      "g",
      { "text-anchor": "end" },
      text(txt, -4, round(height / 2))
    ]);
  }
  if (label && label.right !== void 0) {
    const lab = label.right;
    let txt = index;
    if (typeof lab === "string") {
      txt = lab;
    } else if (typeof lab === "number") {
      txt += lab;
    } else if (typeof lab === "object") {
      txt = lab[index] || txt;
    }
    res.push([
      "g",
      { "text-anchor": "start" },
      text(txt, width + 4, round(height / 2))
    ]);
  }
  return res;
};
const getMaxAttributes = (desc) => desc.reduce(
  (prev, field) => Math.max(
    prev,
    field.attr === void 0 ? 0 : Array.isArray(field.attr) ? field.attr.length : 1
  ),
  0
);
const getTotalBits = (desc) => desc.reduce((prev, field) => prev + (field.bits === void 0 ? 0 : field.bits), 0);
const isIntGTorDefault = (opt) => (row) => {
  const [key2, min, def2] = row;
  const val = Math.round(opt[key2]);
  opt[key2] = typeof val === "number" && val >= min ? val : def2;
};
const optDefaults = (opt) => {
  opt = typeof opt === "object" ? opt : {};
  [
    // key         min default
    // ['vspace', 20, 60],
    ["hspace", 40, 800],
    ["lanes", 1, 1],
    ["bits", 1, void 0],
    ["fontsize", 6, 14]
  ].map(isIntGTorDefault(opt));
  opt.fontfamily = opt.fontfamily || "sans-serif";
  opt.fontweight = opt.fontweight || "normal";
  opt.compact = opt.compact || false;
  opt.hflip = opt.hflip || false;
  opt.uneven = opt.uneven || false;
  opt.margin = opt.margin || {};
  return opt;
};
const render$2 = (desc, opt) => {
  opt = optDefaults(opt);
  const maxAttributes = getMaxAttributes(desc);
  opt.vspace = opt.vspace || (maxAttributes + 4) * opt.fontsize;
  if (opt.bits === void 0) {
    opt.bits = getTotalBits(desc);
  }
  const { hspace, vspace, lanes, margin, compact, fontsize, bits, label, legend } = opt;
  if (margin.right === void 0) {
    if (label && label.right !== void 0) {
      margin.right = round(0.1 * hspace);
    } else {
      margin.right = 4;
    }
  }
  if (margin.left === void 0) {
    if (label && label.left !== void 0) {
      margin.left = round(0.1 * hspace);
    } else {
      margin.left = 4;
    }
  }
  if (margin.top === void 0) {
    margin.top = 1.5 * fontsize;
    if (margin.bottom === void 0) {
      margin.bottom = fontsize * maxAttributes + 4;
    }
  } else {
    if (margin.bottom === void 0) {
      margin.bottom = 4;
    }
  }
  const width = hspace;
  let height = vspace * lanes;
  if (compact) {
    height -= (lanes - 1) * (margin.top + margin.bottom);
  }
  const res = [
    "g",
    tt$9(0.5, legend ? 12.5 : 0.5, {
      "text-anchor": "middle",
      "font-size": opt.fontsize,
      "font-family": opt.fontfamily,
      "font-weight": opt.fontweight
    })
  ];
  let lsb = 0;
  const mod = Math.ceil(bits * 1 / lanes);
  opt.mod = mod | 0;
  desc.map((e) => {
    e.lsb = lsb;
    e.lsbm = lsb % mod;
    lsb += e.bits;
    e.msb = lsb - 1;
    e.msbm = e.msb % mod;
  });
  for (let i = 0; i < lanes; i++) {
    opt.index = i;
    res.push(lane$2(desc, opt));
  }
  if (compact) {
    res.push(compactLabels(desc, opt));
  }
  if (legend) {
    res.push(getLegendItems(opt));
  }
  return getSVG(width, height).concat([res]);
};
var render_1 = render$2;
const render$1 = render_1;
function renderReg$1(index, source2) {
  return render$1(source2.reg, source2.config);
}
var renderReg_1 = renderReg$1;
function rec$1(tmp, state) {
  let deltaX = 10;
  let name2;
  if (typeof tmp[0] === "string" || typeof tmp[0] === "number") {
    name2 = tmp[0];
    deltaX = 25;
  }
  state.x += deltaX;
  for (let i = 0; i < tmp.length; i++) {
    if (typeof tmp[i] === "object") {
      if (Array.isArray(tmp[i])) {
        const oldY = state.y;
        state = rec$1(tmp[i], state);
        state.groups.push({ x: state.xx, y: oldY, height: state.y - oldY, name: state.name });
      } else {
        state.lanes.push(tmp[i]);
        state.width.push(state.x);
        state.y += 1;
      }
    }
  }
  state.xx = state.x;
  state.x -= deltaX;
  state.name = name2;
  return state;
}
var rec_1 = rec$1;
const lane$1 = {
  xs: 20,
  // tmpgraphlane0.width
  ys: 20,
  // tmpgraphlane0.height
  xg: 120,
  // tmpgraphlane0.x
  // yg     : 0,     // head gap
  yh0: 0,
  // head gap title
  yh1: 0,
  // head gap
  yf0: 0,
  // foot gap
  yf1: 0,
  // foot gap
  y0: 5,
  // tmpgraphlane0.y
  yo: 30,
  // tmpgraphlane1.y - y0;
  tgo: -10,
  // tmptextlane0.x - xg;
  ym: 15,
  // tmptextlane0.y - y0
  xlabel: 6,
  // tmptextlabel.x - xg;
  xmax: 1,
  scale: 1,
  head: {},
  foot: {}
};
var lane_1 = lane$1;
function parseConfig$1(source2, lane2) {
  function tonumber(x) {
    return x > 0 ? Math.round(x) : 1;
  }
  lane2.hscale = 1;
  if (lane2.hscale0) {
    lane2.hscale = lane2.hscale0;
  }
  if (source2 && source2.config && source2.config.hscale) {
    let hscale = Math.round(tonumber(source2.config.hscale));
    if (hscale > 0) {
      if (hscale > 100) {
        hscale = 100;
      }
      lane2.hscale = hscale;
    }
  }
  lane2.yh0 = 0;
  lane2.yh1 = 0;
  lane2.head = source2.head;
  lane2.xmin_cfg = 0;
  lane2.xmax_cfg = 1e12;
  if (source2 && source2.config && source2.config.hbounds && source2.config.hbounds.length == 2) {
    source2.config.hbounds[0] = Math.floor(source2.config.hbounds[0]);
    source2.config.hbounds[1] = Math.ceil(source2.config.hbounds[1]);
    if (source2.config.hbounds[0] < source2.config.hbounds[1]) {
      lane2.xmin_cfg = 2 * Math.floor(source2.config.hbounds[0]);
      lane2.xmax_cfg = 2 * Math.floor(source2.config.hbounds[1]);
    }
  }
  if (source2 && source2.head) {
    if (source2.head.tick || source2.head.tick === 0 || source2.head.tock || source2.head.tock === 0) {
      lane2.yh0 = 20;
    }
    if (source2.head.tick || source2.head.tick === 0) {
      source2.head.tick = source2.head.tick + lane2.xmin_cfg / 2;
    }
    if (source2.head.tock || source2.head.tock === 0) {
      source2.head.tock = source2.head.tock + lane2.xmin_cfg / 2;
    }
    if (source2.head.text) {
      lane2.yh1 = 46;
      lane2.head.text = source2.head.text;
    }
  }
  lane2.yf0 = 0;
  lane2.yf1 = 0;
  lane2.foot = source2.foot;
  if (source2 && source2.foot) {
    if (source2.foot.tick || source2.foot.tick === 0 || source2.foot.tock || source2.foot.tock === 0) {
      lane2.yf0 = 20;
    }
    if (source2.foot.tick || source2.foot.tick === 0) {
      source2.foot.tick = source2.foot.tick + lane2.xmin_cfg / 2;
    }
    if (source2.foot.tock || source2.foot.tock === 0) {
      source2.foot.tock = source2.foot.tock + lane2.xmin_cfg / 2;
    }
    if (source2.foot.text) {
      lane2.yf1 = 46;
      lane2.foot.text = source2.foot.text;
    }
  }
}
var parseConfig_1 = parseConfig$1;
const genBrick$2 = (texts, extra, times) => {
  const R = [];
  if (!Array.isArray(texts)) {
    texts = [texts];
  }
  if (texts.length === 4) {
    for (let j = 0; j < times; j += 1) {
      R.push(texts[0]);
      for (let i = 0; i < extra; i += 1) {
        R.push(texts[1]);
      }
      R.push(texts[2]);
      for (let i = 0; i < extra; i += 1) {
        R.push(texts[3]);
      }
    }
    return R;
  }
  if (texts.length === 1) {
    texts.push(texts[0]);
  }
  R.push(texts[0]);
  for (let i = 0; i < times * (2 * (extra + 1)) - 1; i += 1) {
    R.push(texts[1]);
  }
  return R;
};
var genBrick_1 = genBrick$2;
const genBrick$1 = genBrick_1;
const lookUpTable = {
  p: ["pclk", "111", "nclk", "000"],
  n: ["nclk", "000", "pclk", "111"],
  P: ["Pclk", "111", "nclk", "000"],
  N: ["Nclk", "000", "pclk", "111"],
  l: "000",
  L: "000",
  0: "000",
  h: "111",
  H: "111",
  1: "111",
  "=": "vvv-2",
  2: "vvv-2",
  3: "vvv-3",
  4: "vvv-4",
  5: "vvv-5",
  6: "vvv-6",
  7: "vvv-7",
  8: "vvv-8",
  9: "vvv-9",
  d: "ddd",
  u: "uuu",
  z: "zzz",
  default: "xxx"
};
const genFirstWaveBrick$1 = (text2, extra, times) => genBrick$1(lookUpTable[text2] || lookUpTable.default, extra, times);
var genFirstWaveBrick_1 = genFirstWaveBrick$1;
const genBrick = genBrick_1;
function genWaveBrick$1(text2, extra, times) {
  const x1 = { p: "pclk", n: "nclk", P: "Pclk", N: "Nclk", h: "pclk", l: "nclk", H: "Pclk", L: "Nclk" };
  const x2 = {
    "0": "0",
    "1": "1",
    "x": "x",
    "d": "d",
    "u": "u",
    "z": "z",
    "=": "v",
    "2": "v",
    "3": "v",
    "4": "v",
    "5": "v",
    "6": "v",
    "7": "v",
    "8": "v",
    "9": "v"
  };
  const x3 = {
    "0": "",
    "1": "",
    "x": "",
    "d": "",
    "u": "",
    "z": "",
    "=": "-2",
    "2": "-2",
    "3": "-3",
    "4": "-4",
    "5": "-5",
    "6": "-6",
    "7": "-7",
    "8": "-8",
    "9": "-9"
  };
  const y1 = {
    "p": "0",
    "n": "1",
    "P": "0",
    "N": "1",
    "h": "1",
    "l": "0",
    "H": "1",
    "L": "0",
    "0": "0",
    "1": "1",
    "x": "x",
    "d": "d",
    "u": "u",
    "z": "z",
    "=": "v",
    "2": "v",
    "3": "v",
    "4": "v",
    "5": "v",
    "6": "v",
    "7": "v",
    "8": "v",
    "9": "v"
  };
  const y2 = {
    "p": "",
    "n": "",
    "P": "",
    "N": "",
    "h": "",
    "l": "",
    "H": "",
    "L": "",
    "0": "",
    "1": "",
    "x": "",
    "d": "",
    "u": "",
    "z": "",
    "=": "-2",
    "2": "-2",
    "3": "-3",
    "4": "-4",
    "5": "-5",
    "6": "-6",
    "7": "-7",
    "8": "-8",
    "9": "-9"
  };
  const x4 = {
    "p": "111",
    "n": "000",
    "P": "111",
    "N": "000",
    "h": "111",
    "l": "000",
    "H": "111",
    "L": "000",
    "0": "000",
    "1": "111",
    "x": "xxx",
    "d": "ddd",
    "u": "uuu",
    "z": "zzz",
    "=": "vvv-2",
    "2": "vvv-2",
    "3": "vvv-3",
    "4": "vvv-4",
    "5": "vvv-5",
    "6": "vvv-6",
    "7": "vvv-7",
    "8": "vvv-8",
    "9": "vvv-9"
  };
  const x5 = { p: "nclk", n: "pclk", P: "nclk", N: "pclk" };
  const x6 = { p: "000", n: "111", P: "000", N: "111" };
  const xclude = { hp: "111", Hp: "111", ln: "000", Ln: "000", nh: "111", Nh: "111", pl: "000", Pl: "000" };
  const atext = text2.split("");
  const tmp0 = x4[atext[1]];
  let tmp1 = x1[atext[1]];
  if (tmp1 === void 0) {
    const tmp2 = x2[atext[1]];
    if (tmp2 === void 0) {
      return genBrick("xxx", extra, times);
    } else {
      const tmp3 = y1[atext[0]];
      if (tmp3 === void 0) {
        return genBrick("xxx", extra, times);
      }
      return genBrick([tmp3 + "m" + tmp2 + y2[atext[0]] + x3[atext[1]], tmp0], extra, times);
    }
  } else {
    const tmp4 = xclude[text2];
    if (tmp4 !== void 0) {
      tmp1 = tmp4;
    }
    const tmp5 = x5[atext[1]];
    if (tmp5 === void 0) {
      return genBrick([tmp1, tmp0], extra, times);
    }
    return genBrick([tmp1, tmp0, tmp5, x6[atext[1]]], extra, times);
  }
}
var genWaveBrick_1 = genWaveBrick$1;
function findLaneMarkers$2(lanetext) {
  let gcount = 0;
  let lcount = 0;
  const ret = [];
  lanetext.forEach(function(e) {
    if (e === "vvv-2" || e === "vvv-3" || e === "vvv-4" || e === "vvv-5" || e === "vvv-6" || e === "vvv-7" || e === "vvv-8" || e === "vvv-9") {
      lcount += 1;
    } else {
      if (lcount !== 0) {
        ret.push(gcount - (lcount + 1) / 2);
        lcount = 0;
      }
    }
    gcount += 1;
  });
  if (lcount !== 0) {
    ret.push(gcount - (lcount + 1) / 2);
  }
  return ret;
}
var findLaneMarkers_1 = findLaneMarkers$2;
const genFirstWaveBrick = genFirstWaveBrick_1;
const genWaveBrick = genWaveBrick_1;
const findLaneMarkers$1 = findLaneMarkers_1;
function parseWaveLane$1(src, extra, lane2) {
  const Stack = src.split("");
  let Next = Stack.shift();
  let Repeats = 1;
  while (Stack[0] === "." || Stack[0] === "|") {
    Stack.shift();
    Repeats += 1;
  }
  let R = [];
  R = R.concat(genFirstWaveBrick(Next, extra, Repeats));
  let Top;
  let subCycle = false;
  while (Stack.length) {
    Top = Next;
    Next = Stack.shift();
    if (Next === "<") {
      subCycle = true;
      Next = Stack.shift();
    }
    if (Next === ">") {
      subCycle = false;
      Next = Stack.shift();
    }
    Repeats = 1;
    while (Stack[0] === "." || Stack[0] === "|") {
      Stack.shift();
      Repeats += 1;
    }
    if (subCycle) {
      R = R.concat(genWaveBrick(Top + Next, 0, Repeats - lane2.period));
    } else {
      R = R.concat(genWaveBrick(Top + Next, extra, Repeats));
    }
  }
  const unseen_bricks = [];
  for (let i = 0; i < lane2.phase; i += 1) {
    unseen_bricks.push(R.shift());
  }
  let num_unseen_markers;
  if (unseen_bricks.length > 0) {
    num_unseen_markers = findLaneMarkers$1(unseen_bricks).length;
    if (findLaneMarkers$1([unseen_bricks[unseen_bricks.length - 1]]).length == 1 && findLaneMarkers$1([R[0]]).length == 1) {
      num_unseen_markers -= 1;
    }
  } else {
    num_unseen_markers = 0;
  }
  return [R, num_unseen_markers];
}
var parseWaveLane_1 = parseWaveLane$1;
const parseWaveLane = parseWaveLane_1;
function data_extract(e, num_unseen_markers) {
  let ret_data = e.data;
  if (ret_data === void 0) {
    return null;
  }
  if (typeof ret_data === "string") {
    ret_data = ret_data.trim().split(/\s+/);
  }
  ret_data = ret_data.slice(num_unseen_markers);
  return ret_data;
}
function parseWaveLanes$1(sig, lane2) {
  const content = [];
  const tmp0 = [];
  sig.map(function(sigx) {
    const current = [];
    content.push(current);
    lane2.period = sigx.period || 1;
    lane2.phase = (sigx.phase ? sigx.phase * 2 : 0) + lane2.xmin_cfg;
    tmp0[0] = sigx.name || " ";
    tmp0[1] = (sigx.phase || 0) + lane2.xmin_cfg / 2;
    let content_wave = null;
    let num_unseen_markers;
    if (typeof sigx.wave === "string") {
      const parsed_wave_lane = parseWaveLane(sigx.wave, lane2.period * lane2.hscale - 1, lane2);
      content_wave = parsed_wave_lane[0];
      num_unseen_markers = parsed_wave_lane[1];
    }
    current.push(
      tmp0.slice(0),
      content_wave,
      data_extract(sigx, num_unseen_markers),
      sigx
    );
  });
  return content;
}
var parseWaveLanes_1 = parseWaveLanes$1;
const tspan$3 = lib$1;
const tt$8 = tt$a;
function renderGroups$1(groups, index, lane2) {
  const res = ["g"];
  groups.map((e, i) => {
    res.push([
      "path",
      {
        id: "group_" + i + "_" + index,
        d: "m " + (e.x + 0.5) + "," + (e.y * lane2.yo + 3.5 + lane2.yh0 + lane2.yh1) + " c -3,0 -5,2 -5,5 l 0," + (e.height * lane2.yo - 16) + " c 0,3 2,5 5,5",
        style: "stroke:#0041c4;stroke-width:1;fill:none"
      }
    ]);
    if (e.name === void 0) {
      return;
    }
    const x = e.x - 10;
    const y = lane2.yo * (e.y + e.height / 2) + lane2.yh0 + lane2.yh1;
    const ts = tspan$3.parse(e.name);
    res.push([
      "g",
      tt$8(x, y),
      [
        "g",
        { transform: "rotate(270)" },
        ["text", {
          "text-anchor": "middle",
          class: "info",
          "xml:space": "preserve"
        }].concat(ts)
      ]
    ]);
  });
  return res;
}
var renderGroups_1 = renderGroups$1;
const tspan$2 = lib$1;
function captext(cxt, anchor, y) {
  if (cxt[anchor] && cxt[anchor].text) {
    return [
      ["text", {
        x: cxt.xmax * cxt.xs / 2,
        y,
        fill: "#000",
        "text-anchor": "middle",
        "xml:space": "preserve"
      }].concat(tspan$2.parse(cxt[anchor].text))
    ];
  }
  return [];
}
function ticktock(cxt, ref1, ref2, x, dx, y, len) {
  let offset;
  let L = [];
  if (cxt[ref1] === void 0 || cxt[ref1][ref2] === void 0) {
    return [];
  }
  let val = cxt[ref1][ref2];
  if (typeof val === "string") {
    val = val.trim().split(/\s+/);
  } else if (typeof val === "number" || typeof val === "boolean") {
    offset = Number(val);
    val = [];
    for (let i = 0; i < len; i += 1) {
      val.push(i + offset);
    }
  }
  if (Array.isArray(val)) {
    if (val.length === 0) {
      return [];
    } else if (val.length === 1) {
      offset = Number(val[0]);
      if (isNaN(offset)) {
        L = val;
      } else {
        for (let i = 0; i < len; i += 1) {
          L[i] = i + offset;
        }
      }
    } else if (val.length === 2) {
      offset = Number(val[0]);
      const step = Number(val[1]);
      const tmp = val[1].split(".");
      let dp = 0;
      if (tmp.length === 2) {
        dp = tmp[1].length;
      }
      if (isNaN(offset) || isNaN(step)) {
        L = val;
      } else {
        offset = step * offset;
        for (let i = 0; i < len; i += 1) {
          L[i] = (step * i + offset).toFixed(dp);
        }
      }
    } else {
      L = val;
    }
  } else {
    return [];
  }
  const res = ["g", {
    class: "muted",
    "text-anchor": "middle",
    "xml:space": "preserve"
  }];
  for (let i = 0; i < len; i += 1) {
    if (cxt[ref1] && cxt[ref1].every && (i + offset) % cxt[ref1].every != 0) {
      continue;
    }
    res.push(["text", { x: i * dx + x, y }].concat(tspan$2.parse(L[i])));
  }
  return [res];
}
function renderMarks$1(content, index, lane2, source2) {
  const mstep = 2 * lane2.hscale;
  const mmstep = mstep * lane2.xs;
  const marks = lane2.xmax / mstep;
  const gy = content.length * lane2.yo;
  const res = ["g", { id: "gmarks_" + index }];
  const gmarkLines = ["g", { style: "stroke:#888;stroke-width:0.5;stroke-dasharray:1,3" }];
  if (!(source2 && source2.config && source2.config.marks === false)) {
    for (let i = 0; i < marks + 1; i += 1) {
      gmarkLines.push(["line", {
        id: "gmark_" + i + "_" + index,
        x1: i * mmstep,
        y1: 0,
        x2: i * mmstep,
        y2: gy
      }]);
    }
    res.push(gmarkLines);
  }
  return res.concat(
    captext(lane2, "head", lane2.yh0 ? -33 : -13),
    captext(lane2, "foot", gy + (lane2.yf0 ? 45 : 25)),
    ticktock(lane2, "head", "tick", 0, mmstep, -5, marks + 1),
    ticktock(lane2, "head", "tock", mmstep / 2, mmstep, -5, marks),
    ticktock(lane2, "foot", "tick", 0, mmstep, gy + 15, marks + 1),
    ticktock(lane2, "foot", "tock", mmstep / 2, mmstep, gy + 15, marks)
  );
}
var renderMarks_1 = renderMarks$1;
function arcShape$1(Edge, from, to) {
  const dx = to.x - from.x;
  const dy = to.y - from.y;
  let lx = (from.x + to.x) / 2;
  const ly = (from.y + to.y) / 2;
  let d;
  let style;
  switch (Edge.shape) {
    case "-": {
      break;
    }
    case "~": {
      d = "M " + from.x + "," + from.y + " c " + 0.7 * dx + ", 0 " + 0.3 * dx + ", " + dy + " " + dx + ", " + dy;
      break;
    }
    case "-~": {
      d = "M " + from.x + "," + from.y + " c " + 0.7 * dx + ", 0 " + dx + ", " + dy + " " + dx + ", " + dy;
      if (Edge.label) {
        lx = from.x + (to.x - from.x) * 0.75;
      }
      break;
    }
    case "~-": {
      d = "M " + from.x + "," + from.y + " c 0, 0 " + 0.3 * dx + ", " + dy + " " + dx + ", " + dy;
      if (Edge.label) {
        lx = from.x + (to.x - from.x) * 0.25;
      }
      break;
    }
    case "-|": {
      d = "m " + from.x + "," + from.y + " " + dx + ",0 0," + dy;
      if (Edge.label) {
        lx = to.x;
      }
      break;
    }
    case "|-": {
      d = "m " + from.x + "," + from.y + " 0," + dy + " " + dx + ",0";
      if (Edge.label) {
        lx = from.x;
      }
      break;
    }
    case "-|-": {
      d = "m " + from.x + "," + from.y + " " + dx / 2 + ",0 0," + dy + " " + dx / 2 + ",0";
      break;
    }
    case "->": {
      style = "marker-end:url(#arrowhead);stroke:#0041c4;stroke-width:1;fill:none";
      break;
    }
    case "~>": {
      style = "marker-end:url(#arrowhead);stroke:#0041c4;stroke-width:1;fill:none";
      d = "M " + from.x + "," + from.y + " c " + 0.7 * dx + ", 0 " + 0.3 * dx + ", " + dy + " " + dx + ", " + dy;
      break;
    }
    case "-~>": {
      style = "marker-end:url(#arrowhead);stroke:#0041c4;stroke-width:1;fill:none";
      d = "M " + from.x + "," + from.y + " c " + 0.7 * dx + ", 0 " + dx + ", " + dy + " " + dx + ", " + dy;
      if (Edge.label) {
        lx = from.x + (to.x - from.x) * 0.75;
      }
      break;
    }
    case "~->": {
      style = "marker-end:url(#arrowhead);stroke:#0041c4;stroke-width:1;fill:none";
      d = "M " + from.x + "," + from.y + " c 0, 0 " + 0.3 * dx + ", " + dy + " " + dx + ", " + dy;
      if (Edge.label) {
        lx = from.x + (to.x - from.x) * 0.25;
      }
      break;
    }
    case "-|>": {
      style = "marker-end:url(#arrowhead);stroke:#0041c4;stroke-width:1;fill:none";
      d = "m " + from.x + "," + from.y + " " + dx + ",0 0," + dy;
      if (Edge.label) {
        lx = to.x;
      }
      break;
    }
    case "|->": {
      style = "marker-end:url(#arrowhead);stroke:#0041c4;stroke-width:1;fill:none";
      d = "m " + from.x + "," + from.y + " 0," + dy + " " + dx + ",0";
      if (Edge.label) {
        lx = from.x;
      }
      break;
    }
    case "-|->": {
      style = "marker-end:url(#arrowhead);stroke:#0041c4;stroke-width:1;fill:none";
      d = "m " + from.x + "," + from.y + " " + dx / 2 + ",0 0," + dy + " " + dx / 2 + ",0";
      break;
    }
    case "<->": {
      style = "marker-end:url(#arrowhead);marker-start:url(#arrowtail);stroke:#0041c4;stroke-width:1;fill:none";
      break;
    }
    case "<~>": {
      style = "marker-end:url(#arrowhead);marker-start:url(#arrowtail);stroke:#0041c4;stroke-width:1;fill:none";
      d = "M " + from.x + "," + from.y + " c " + 0.7 * dx + ", 0 " + 0.3 * dx + ", " + dy + " " + dx + ", " + dy;
      break;
    }
    case "<-~>": {
      style = "marker-end:url(#arrowhead);marker-start:url(#arrowtail);stroke:#0041c4;stroke-width:1;fill:none";
      d = "M " + from.x + "," + from.y + " c " + 0.7 * dx + ", 0 " + dx + ", " + dy + " " + dx + ", " + dy;
      if (Edge.label) {
        lx = from.x + (to.x - from.x) * 0.75;
      }
      break;
    }
    case "<-|>": {
      style = "marker-end:url(#arrowhead);marker-start:url(#arrowtail);stroke:#0041c4;stroke-width:1;fill:none";
      d = "m " + from.x + "," + from.y + " " + dx + ",0 0," + dy;
      if (Edge.label) {
        lx = to.x;
      }
      break;
    }
    case "<-|->": {
      style = "marker-end:url(#arrowhead);marker-start:url(#arrowtail);stroke:#0041c4;stroke-width:1;fill:none";
      d = "m " + from.x + "," + from.y + " " + dx / 2 + ",0 0," + dy + " " + dx / 2 + ",0";
      break;
    }
    case "+": {
      style = "marker-end:url(#tee);marker-start:url(#tee);fill:none;stroke:#00F;stroke-width:1";
      break;
    }
    default: {
      style = "fill:none;stroke:#F00;stroke-width:1";
    }
  }
  return {
    lx,
    ly,
    d,
    style
  };
}
var arcShape_1 = arcShape$1;
const chars = [
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  34,
  47,
  74,
  74,
  118,
  89,
  25,
  44,
  44,
  52,
  78,
  37,
  44,
  37,
  37,
  74,
  74,
  74,
  74,
  74,
  74,
  74,
  74,
  74,
  74,
  37,
  37,
  78,
  78,
  78,
  74,
  135,
  89,
  89,
  96,
  96,
  89,
  81,
  103,
  96,
  37,
  67,
  89,
  74,
  109,
  96,
  103,
  89,
  103,
  96,
  89,
  81,
  96,
  89,
  127,
  89,
  87,
  81,
  37,
  37,
  37,
  61,
  74,
  44,
  74,
  74,
  67,
  74,
  74,
  37,
  74,
  74,
  30,
  30,
  67,
  30,
  112,
  74,
  74,
  74,
  74,
  44,
  67,
  37,
  74,
  67,
  95,
  66,
  65,
  67,
  44,
  34,
  44,
  78,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  37,
  43,
  74,
  74,
  74,
  74,
  34,
  74,
  44,
  98,
  49,
  74,
  78,
  0,
  98,
  73,
  53,
  73,
  44,
  44,
  44,
  77,
  71,
  37,
  44,
  44,
  49,
  74,
  111,
  111,
  111,
  81,
  89,
  89,
  89,
  89,
  89,
  89,
  133,
  96,
  89,
  89,
  89,
  89,
  37,
  37,
  37,
  37,
  96,
  96,
  103,
  103,
  103,
  103,
  103,
  78,
  103,
  96,
  96,
  96,
  96,
  87,
  89,
  81,
  74,
  74,
  74,
  74,
  74,
  74,
  118,
  67,
  74,
  74,
  74,
  74,
  36,
  36,
  36,
  36,
  74,
  74,
  74,
  74,
  74,
  74,
  74,
  73,
  81,
  74,
  74,
  74,
  74,
  65,
  74,
  65,
  89,
  74,
  89,
  74,
  89,
  74,
  96,
  67,
  96,
  67,
  96,
  67,
  96,
  67,
  96,
  82,
  96,
  74,
  89,
  74,
  89,
  74,
  89,
  74,
  89,
  74,
  89,
  74,
  103,
  74,
  103,
  74,
  103,
  74,
  103,
  74,
  96,
  74,
  96,
  74,
  37,
  36,
  37,
  36,
  37,
  36,
  37,
  30,
  37,
  36,
  98,
  59,
  67,
  30,
  89,
  67,
  67,
  74,
  30,
  74,
  30,
  74,
  39,
  74,
  44,
  74,
  30,
  96,
  74,
  96,
  74,
  96,
  74,
  80,
  96,
  74,
  103,
  74,
  103,
  74,
  103,
  74,
  133,
  126,
  96,
  44,
  96,
  44,
  96,
  44,
  89,
  67,
  89,
  67,
  89,
  67,
  89,
  67,
  81,
  38,
  81,
  50,
  81,
  37,
  96,
  74,
  96,
  74,
  96,
  74,
  96,
  74,
  96,
  74,
  96,
  74,
  127,
  95,
  87,
  65,
  87,
  81,
  67,
  81,
  67,
  81,
  67,
  30,
  84,
  97,
  91,
  84,
  91,
  84,
  94,
  92,
  73,
  104,
  109,
  91,
  84,
  81,
  84,
  100,
  82,
  76,
  74,
  103,
  91,
  131,
  47,
  40,
  99,
  77,
  37,
  79,
  130,
  100,
  84,
  104,
  114,
  87,
  126,
  101,
  87,
  84,
  93,
  84,
  69,
  84,
  46,
  52,
  82,
  52,
  82,
  114,
  89,
  102,
  96,
  100,
  98,
  91,
  70,
  88,
  88,
  77,
  70,
  85,
  89,
  77,
  67,
  84,
  39,
  65,
  61,
  39,
  189,
  173,
  153,
  111,
  105,
  61,
  123,
  123,
  106,
  89,
  74,
  37,
  30,
  103,
  74,
  96,
  74,
  96,
  74,
  96,
  74,
  96,
  74,
  96,
  74,
  81,
  91,
  81,
  91,
  81,
  130,
  131,
  102,
  84,
  103,
  84,
  87,
  78,
  104,
  81,
  104,
  81,
  88,
  76,
  37,
  189,
  173,
  153,
  103,
  84,
  148,
  90,
  100,
  84,
  89,
  74,
  133,
  118,
  103,
  81
];
const other = 114;
const require$$0 = {
  chars,
  other
};
const charWidth = require$$0;
var textWidth$2 = function(str, size) {
  size = size || 11;
  let width = 0;
  for (let i = 0; i < str.length; i++) {
    const c2 = str.charCodeAt(i);
    let w = charWidth.chars[c2];
    if (w === void 0) {
      w = charWidth.other;
    }
    width += w;
  }
  return width * size / 100;
};
const tspan$1 = lib$1;
const tt$7 = tt$a;
const textWidth$1 = textWidth$2;
function renderLabel$1(p, text2, fontSize) {
  fontSize = fontSize || 11;
  const w = textWidth$1(text2, fontSize) + 2;
  return [
    "g",
    tt$7(p.x, p.y),
    ["rect", {
      x: -(w >> 1),
      y: -(fontSize >> 1),
      width: w,
      height: fontSize,
      style: "fill:#FFF;"
    }],
    ["text", {
      "text-anchor": "middle",
      y: Math.round(0.3 * fontSize),
      style: "font-size:" + fontSize + "px;"
    }].concat(tspan$1.parse(text2))
  ];
}
var renderLabel_1 = renderLabel$1;
const arcShape = arcShape_1;
const renderLabel = renderLabel_1;
const renderArc = (Edge, from, to, shapeProps) => ["path", {
  id: "gmark_" + Edge.from + "_" + Edge.to,
  d: shapeProps.d || "M " + from.x + "," + from.y + " " + to.x + "," + to.y,
  style: shapeProps.style || "fill:none;stroke:#00F;stroke-width:1"
}];
const labeler = (lane2, Events) => (element, i) => {
  const text2 = element.node;
  lane2.period = element.period ? element.period : 1;
  lane2.phase = (element.phase ? element.phase * 2 : 0) + lane2.xmin_cfg;
  if (text2) {
    const stack2 = text2.split("");
    let pos2 = 0;
    while (stack2.length) {
      const eventname = stack2.shift();
      if (eventname !== ".") {
        Events[eventname] = {
          x: lane2.xs * (2 * pos2 * lane2.period * lane2.hscale - lane2.phase) + lane2.xlabel,
          y: i * lane2.yo + lane2.y0 + lane2.ys * 0.5
        };
      }
      pos2 += 1;
    }
  }
};
const archer = (res, Events, arcFontSize) => (element) => {
  const words = element.trim().split(/\s+/);
  const Edge = {
    words,
    label: element.substring(words[0].length).substring(1),
    from: words[0].substr(0, 1),
    to: words[0].substr(-1, 1),
    shape: words[0].slice(1, -1)
  };
  const from = Events[Edge.from];
  const to = Events[Edge.to];
  if (from && to) {
    const shapeProps = arcShape(Edge, from, to);
    const lx = shapeProps.lx;
    const ly = shapeProps.ly;
    res.push(renderArc(Edge, from, to, shapeProps));
    if (Edge.label) {
      res.push(renderLabel({ x: lx, y: ly }, Edge.label, arcFontSize));
    }
  }
};
function renderArcs$1(lanes, index, source2, lane2) {
  const arcFontSize = source2 && source2.config && source2.config.arcFontSize ? source2.config.arcFontSize : 11;
  const res = ["g", { id: "wavearcs_" + index }];
  const Events = {};
  if (Array.isArray(lanes)) {
    lanes.map(labeler(lane2, Events));
    if (Array.isArray(source2.edge)) {
      source2.edge.map(archer(res, Events, arcFontSize));
    }
    Object.keys(Events).map(function(k) {
      if (k === k.toLowerCase()) {
        if (Events[k].x > 0) {
          res.push(renderLabel({
            x: Events[k].x,
            y: Events[k].y
          }, k + "", arcFontSize));
        }
      }
    });
  }
  return res;
}
var renderArcs_1 = renderArcs$1;
const tt$6 = tt$a;
function renderGapUses(text2, lane2) {
  const res = [];
  const Stack = (text2 || "").split("");
  let pos2 = 0;
  let subCycle = false;
  while (Stack.length) {
    let next = Stack.shift();
    if (next === "<") {
      subCycle = true;
      next = Stack.shift();
    }
    if (next === ">") {
      subCycle = false;
      next = Stack.shift();
    }
    if (subCycle) {
      pos2 += 1;
    } else {
      pos2 += 2 * lane2.period;
    }
    if (next === "|") {
      res.push(["use", tt$6(
        lane2.xs * ((pos2 - (subCycle ? 0 : lane2.period)) * lane2.hscale - lane2.phase),
        0,
        { "xlink:href": "#gap" }
      )]);
    }
  }
  return res;
}
function renderGaps$1(lanes, index, source2, lane2) {
  let res = [];
  if (lanes) {
    const lanesLen = lanes.length;
    const vline2 = (x) => ["line", {
      x1: x,
      x2: x,
      y2: lanesLen * lane2.yo,
      style: "stroke:#000;stroke-width:1px"
    }];
    const lineStyle = "fill:none;stroke:#000;stroke-width:1px";
    const bracket = {
      square: {
        left: ["path", { d: "M  2 0 h -4 v " + (lanesLen * lane2.yo - 1) + " h  4", style: lineStyle }],
        right: ["path", { d: "M -2 0 h  4 v " + (lanesLen * lane2.yo - 1) + " h -4", style: lineStyle }]
      },
      round: {
        left: ["path", { d: "M  2 0 a 4 4 0 0 0 -4 4 v " + (lanesLen * lane2.yo - 9) + " a 4 4 0 0 0  4 4", style: lineStyle }],
        right: ["path", { d: "M -2 0 a 4 4 1 0 1  4 4 v " + (lanesLen * lane2.yo - 9) + " a 4 4 1 0 1 -4 4", style: lineStyle }],
        rightLeft: ["path", {
          d: "M -5 0 a 4 4 1 0 1  4 4 v " + (lanesLen * lane2.yo - 9) + " a 4 4 1 0 1 -4 4M  5 0 a 4 4 0 0 0 -4 4 v " + (lanesLen * lane2.yo - 9) + " a 4 4 0 0 0  4 4",
          style: lineStyle
        }],
        leftLeft: ["path", {
          d: "M  2 0 a 4 4 0 0 0 -4 4 v " + (lanesLen * lane2.yo - 9) + " a 4 4 0 0 0  4 4M  5 1 a 3 3 0 0 0 -3 3 v " + (lanesLen * lane2.yo - 9) + " a 3 3 0 0 0  3 3",
          style: lineStyle
        }],
        rightRight: ["path", {
          d: "M -5 1 a 3 3 1 0 1  3 3 v " + (lanesLen * lane2.yo - 9) + " a 3 3 1 0 1 -3 3M -2 0 a 4 4 1 0 1  4 4 v " + (lanesLen * lane2.yo - 9) + " a 4 4 1 0 1 -4 4",
          style: lineStyle
        }]
      }
    };
    const backDrop = (w) => ["rect", {
      x: -w / 2,
      width: w,
      height: lanesLen * lane2.yo,
      style: "fill:#ffffffcc;stroke:none"
    }];
    if (source2 && typeof source2.gaps === "string") {
      const scale2 = lane2.hscale * lane2.xs * 2;
      const gaps = source2.gaps.trim().split(/\s+/);
      for (let x = 0; x < gaps.length; x++) {
        const c2 = gaps[x];
        if (c2.match(/^[.]$/)) {
          continue;
        }
        const offset = c2 === c2.toLowerCase() ? 0.5 : 0;
        let marks = [];
        switch (c2) {
          case "0":
            marks = [backDrop(4)];
            break;
          case "1":
            marks = [backDrop(4), vline2(0)];
            break;
          case "|":
            marks = [backDrop(4), vline2(0)];
            break;
          case "2":
            marks = [backDrop(4), vline2(-2), vline2(2)];
            break;
          case "3":
            marks = [backDrop(6), vline2(-3), vline2(0), vline2(3)];
            break;
          case "[":
            marks = [backDrop(4), bracket.square.left];
            break;
          case "]":
            marks = [backDrop(4), bracket.square.right];
            break;
          case "(":
            marks = [backDrop(4), bracket.round.left];
            break;
          case ")":
            marks = [backDrop(4), bracket.round.right];
            break;
          case ")(":
            marks = [backDrop(8), bracket.round.rightLeft];
            break;
          case "((":
            marks = [backDrop(8), bracket.round.leftLeft];
            break;
          case "))":
            marks = [backDrop(8), bracket.round.rightRight];
            break;
          case "s":
            for (let idx = 0; idx < lanesLen; idx++) {
              if (lanes[idx] && lanes[idx].wave && lanes[idx].wave.length > x) {
                marks.push(["use", tt$6(2, 5 + lane2.yo * idx, { "xlink:href": "#gap" })]);
              }
            }
            break;
        }
        res.push(["g", tt$6(scale2 * (x + offset))].concat(marks));
      }
    }
    for (let idx = 0; idx < lanesLen; idx++) {
      const val = lanes[idx];
      lane2.period = val.period ? val.period : 1;
      lane2.phase = (val.phase ? val.phase * 2 : 0) + lane2.xmin_cfg;
      if (typeof val.wave === "string") {
        const gaps = renderGapUses(val.wave, lane2);
        res = res.concat([["g", tt$6(
          0,
          lane2.y0 + idx * lane2.yo,
          { id: "wavegap_" + idx + "_" + index }
        )].concat(gaps)]);
      }
    }
  }
  return ["g", { id: "wavegaps_" + index }].concat(res);
}
var renderGaps_1 = renderGaps$1;
const tt$5 = tt$a;
const scaled = (d, sx, sy) => {
  if (sy === void 0) {
    sy = sx;
  }
  let i = 0;
  while (i < d.length) {
    switch (d[i].toLowerCase()) {
      case "h":
        while (i < d.length && !isNaN(d[i + 1])) {
          d[i + 1] *= sx;
          i++;
        }
        break;
      case "v":
        while (i < d.length && !isNaN(d[i + 1])) {
          d[i + 1] *= sy;
          i++;
        }
        break;
      case "m":
      case "l":
      case "t":
        while (i + 1 < d.length && !isNaN(d[i + 1])) {
          d[i + 1] *= sx;
          d[i + 2] *= sy;
          i += 2;
        }
        break;
      case "q":
        while (i + 3 < d.length && !isNaN(d[i + 1])) {
          d[i + 1] *= sx;
          d[i + 2] *= sy;
          d[i + 3] *= sx;
          d[i + 4] *= sy;
          i += 4;
        }
        break;
      case "a":
        while (i + 6 < d.length && !isNaN(d[i + 1])) {
          d[i + 1] *= sx;
          d[i + 2] *= sy;
          d[i + 6] *= sx;
          d[i + 7] *= sy;
          i += 7;
        }
        break;
    }
    i++;
  }
  return d;
};
function scale(d, cfg) {
  if (typeof d === "string") {
    d = d.trim().split(/[\s,]+/);
  }
  if (!Array.isArray(d)) {
    return;
  }
  return scaled(d, 2 * cfg.xs, -cfg.ys);
}
function renderLane(wave, idx, cfg) {
  if (Array.isArray(wave)) {
    const tag = wave[0];
    const attr = wave[1];
    if (tag === "pw" && typeof attr === "object") {
      const d = scale(attr.d, cfg);
      return [
        "g",
        tt$5(0, cfg.yo * idx + cfg.ys + cfg.y0),
        ["path", { style: "fill:none;stroke:#000;stroke-width:1px;", d }]
      ];
    }
  }
}
function renderPieceWise$1(lanes, index, cfg) {
  let res = ["g"];
  lanes.map((row, idx) => {
    const wave = row.wave;
    if (Array.isArray(wave)) {
      res.push(renderLane(wave, idx, cfg));
    }
  });
  return res;
}
var renderPieceWise_1 = renderPieceWise$1;
const renderMarks = renderMarks_1;
const renderArcs = renderArcs_1;
const renderGaps = renderGaps_1;
const renderPieceWise = renderPieceWise_1;
function renderLanes$1(index, content, waveLanes, ret, source2, lane2) {
  return [
    renderMarks(content, index, lane2, source2)
  ].concat(
    waveLanes.res,
    [
      renderArcs(ret.lanes, index, source2, lane2),
      renderGaps(ret.lanes, index, source2, lane2),
      renderPieceWise(ret.lanes, index, lane2)
    ]
  );
}
var renderLanes_1 = renderLanes$1;
const tt$4 = tt$a;
const colors = {
  1: "#000000",
  2: "#e90000",
  3: "#3edd00",
  4: "#0074cd",
  5: "#ff15db",
  6: "#af9800",
  7: "#00864f",
  8: "#a076ff"
};
function renderOverUnder$1(el, key2, lane2) {
  const xs = lane2.xs;
  const ys = lane2.ys;
  const period = (el.period || 1) * 2 * xs;
  const xoffset = -(el.phase || 0) * 2 * xs;
  const gap1 = 12;
  const serif = 7;
  let color;
  const y = key2 === "under" ? ys : 0;
  let start;
  function line2(x) {
    return start === void 0 ? [] : [["line", {
      style: "stroke:" + color,
      x1: period * start + gap1,
      x2: period * x
    }]];
  }
  if (el[key2]) {
    let res = ["g", tt$4(
      xoffset,
      y,
      { style: "stroke-width:3" }
    )];
    const arr = el[key2].split("");
    arr.map(function(dot, i) {
      if (dot !== "." && start !== void 0) {
        res = res.concat(line2(i));
        if (key2 === "over") {
          res.push(["path", {
            style: "stroke:none;fill:" + color,
            d: "m" + (period * i - serif) + " 0 l" + serif + " " + serif + " v-" + serif + " z"
          }]);
        }
      }
      if (dot === "0") {
        start = void 0;
      } else if (dot !== ".") {
        start = i;
        color = colors[dot] || colors[1];
      }
    });
    if (start !== void 0) {
      res = res.concat(line2(arr.length));
    }
    return [res];
  }
  return [];
}
var renderOverUnder_1 = renderOverUnder$1;
const tt$3 = tt$a;
const tspan = lib$1;
const textWidth = textWidth$2;
const findLaneMarkers = findLaneMarkers_1;
const renderOverUnder = renderOverUnder_1;
function renderLaneUses(cont, lane2) {
  const res = [];
  if (cont[1]) {
    cont[1].map(function(ref, i) {
      res.push(["use", tt$3(i * lane2.xs, 0, { "xlink:href": "#" + ref })]);
    });
    if (cont[2] && cont[2].length) {
      const labels = findLaneMarkers(cont[1]);
      if (labels.length) {
        labels.map(function(label, i) {
          if (cont[2] && cont[2][i] !== void 0) {
            res.push(["text", {
              x: label * lane2.xs + lane2.xlabel,
              y: lane2.ym,
              "text-anchor": "middle",
              "xml:space": "preserve"
            }].concat(tspan.parse(cont[2][i])));
          }
        });
      }
    }
  }
  return res;
}
function renderWaveLane$1(content, index, lane2) {
  let xmax = 0;
  const glengths = [];
  const res = [];
  content.map(function(el, j) {
    const name2 = el[0][0];
    if (name2) {
      let xoffset = el[0][1];
      xoffset = xoffset > 0 ? Math.ceil(2 * xoffset) - 2 * xoffset : -2 * xoffset;
      res.push(
        ["g", tt$3(
          0,
          lane2.y0 + j * lane2.yo,
          { id: "wavelane_" + j + "_" + index }
        )].concat([
          ["text", {
            x: lane2.tgo,
            y: lane2.ym,
            class: "info",
            "text-anchor": "end",
            "xml:space": "preserve"
          }].concat(tspan.parse(name2))
        ]).concat([
          ["g", tt$3(
            xoffset * lane2.xs,
            0,
            { id: "wavelane_draw_" + j + "_" + index }
          )].concat(renderLaneUses(el, lane2))
        ]).concat(
          renderOverUnder(el[3], "over", lane2),
          renderOverUnder(el[3], "under", lane2)
        )
      );
      xmax = Math.max(xmax, (el[1] || []).length);
      glengths.push(name2.textWidth ? name2.textWidth : name2.charCodeAt ? textWidth(name2, 11) : 0);
    }
  });
  lane2.xmax = Math.min(xmax, lane2.xmax_cfg - lane2.xmin_cfg);
  const xgmax = 0;
  lane2.xg = xgmax + 20;
  return { glengths, res };
}
var renderWaveLane_1 = renderWaveLane$1;
var w3$3 = {
  svg: "http://www.w3.org/2000/svg",
  xlink: "http://www.w3.org/1999/xlink",
  xmlns: "http://www.w3.org/XML/1998/namespace"
};
const tt$2 = tt$a;
const w3$2 = w3$3;
function insertSVGTemplate$1(index, source2, lane2, waveSkin, content, lanes, groups, notFirstSignal) {
  const waveSkinNames = Object.keys(waveSkin);
  let skin = waveSkin.default || waveSkin[waveSkinNames[0]];
  if (source2 && source2.config && source2.config.skin && waveSkin[source2.config.skin]) {
    skin = waveSkin[source2.config.skin];
  }
  const e = notFirstSignal ? ["svg", { id: "svg", xmlns: w3$2.svg, "xmlns:xlink": w3$2.xlink }, ["g"]] : skin;
  const width = lane2.xg + lane2.xs * (lane2.xmax + 1);
  const height = content.length * lane2.yo + lane2.yh0 + lane2.yh1 + lane2.yf0 + lane2.yf1;
  const body = e[e.length - 1];
  body[1] = { id: "waves_" + index };
  body[2] = ["rect", { width, height, style: "stroke:none;fill:white" }];
  body[3] = ["g", tt$2(
    lane2.xg + 0.5,
    lane2.yh0 + lane2.yh1 + 0.5,
    { id: "lanes_" + index }
  )].concat(lanes);
  body[4] = ["g", {
    id: "groups_" + index
  }, groups];
  const head = e[1];
  head.id = "svgcontent_" + index;
  head.height = height;
  head.width = width;
  head.viewBox = "0 0 " + width + " " + height;
  head.overflow = "hidden";
  return e;
}
var insertSvgTemplate = insertSVGTemplate$1;
const rec = rec_1;
const lane = lane_1;
const parseConfig = parseConfig_1;
const parseWaveLanes = parseWaveLanes_1;
const renderGroups = renderGroups_1;
const renderLanes = renderLanes_1;
const renderWaveLane = renderWaveLane_1;
const insertSVGTemplate = insertSvgTemplate;
function laneParamsFromSkin(index, source2, lane2, waveSkin) {
  if (index !== 0) {
    return;
  }
  const waveSkinNames = Object.keys(waveSkin);
  if (waveSkinNames.length === 0) {
    throw new Error("no skins found");
  }
  let skin = waveSkin.default || waveSkin[waveSkinNames[0]];
  if (source2 && source2.config && source2.config.skin && waveSkin[source2.config.skin]) {
    skin = waveSkin[source2.config.skin];
  }
  const socket = skin[3][1][2][1];
  lane2.xs = Number(socket.width);
  lane2.ys = Number(socket.height);
  lane2.xlabel = Number(socket.x);
  lane2.ym = Number(socket.y);
}
function renderSignal$1(index, source2, waveSkin, notFirstSignal) {
  laneParamsFromSkin(index, source2, lane, waveSkin);
  parseConfig(source2, lane);
  const ret = rec(source2.signal, { x: 0, y: 0, xmax: 0, width: [], lanes: [], groups: [] });
  const content = parseWaveLanes(ret.lanes, lane);
  const waveLanes = renderWaveLane(content, index, lane);
  const waveGroups = renderGroups(ret.groups, index, lane);
  const xmax = waveLanes.glengths.reduce((res, len, i) => Math.max(res, len + ret.width[i]), 0);
  lane.xg = Math.ceil((xmax - lane.tgo) / lane.xs) * lane.xs;
  return insertSVGTemplate(
    index,
    source2,
    lane,
    waveSkin,
    content,
    renderLanes(index, content, waveLanes, ret, source2, lane),
    waveGroups,
    notFirstSignal
  );
}
var renderSignal_1 = renderSignal$1;
const renderAssign = renderAssign_1;
const renderReg = renderReg_1;
const renderSignal = renderSignal_1;
function renderAny$2(index, source2, waveSkin, notFirstSignal) {
  const res = source2.signal ? renderSignal(index, source2, waveSkin, notFirstSignal) : source2.assign ? renderAssign(index, source2) : source2.reg ? renderReg(index, source2) : ["div", {}];
  res[1].class = "WaveDrom";
  return res;
}
var renderAny_1 = renderAny$2;
const stringify$4 = stringify_1;
const w3$1 = w3$3;
function createElement$1(arr) {
  arr[1].xmlns = w3$1.svg;
  arr[1]["xmlns:xlink"] = w3$1.xlink;
  const s1 = stringify$4(arr);
  const parser2 = new DOMParser();
  const doc = parser2.parseFromString(s1, "image/svg+xml");
  return doc.firstChild;
}
var createElement_1 = createElement$1;
const renderAny$1 = renderAny_1;
const createElement = createElement_1;
function renderWaveElement$2(index, source2, outputElement, waveSkin, notFirstSignal) {
  while (outputElement.childNodes.length) {
    outputElement.removeChild(outputElement.childNodes[0]);
  }
  outputElement.insertBefore(createElement(
    renderAny$1(index, source2, waveSkin, notFirstSignal)
  ), null);
}
var renderWaveElement_1 = renderWaveElement$2;
const renderWaveElement$1 = renderWaveElement_1;
function renderWaveForm$3(index, source2, output, notFirstSignal) {
  renderWaveElement$1(index, source2, document.getElementById(output + index), window.WaveSkin, notFirstSignal);
}
var renderWaveForm_1 = renderWaveForm$3;
const eva$2 = eva_1;
const appendSaveAsDialog = appendSaveAsDialog_1;
const renderWaveForm$2 = renderWaveForm_1;
function processAll$1() {
  let index = 0;
  const points = document.querySelectorAll("*");
  for (let i = 0; i < points.length; i++) {
    if (points.item(i).type && points.item(i).type.toLowerCase() === "wavedrom") {
      points.item(i).setAttribute("id", "InputJSON_" + index);
      const node0 = document.createElement("div");
      node0.id = "WaveDrom_Display_" + index;
      points.item(i).parentNode.insertBefore(node0, points.item(i));
      index += 1;
    }
  }
  let notFirstSignal = false;
  for (let i = 0; i < index; i += 1) {
    const obj = eva$2("InputJSON_" + i);
    renderWaveForm$2(i, obj, "WaveDrom_Display_", notFirstSignal);
    if (obj && obj.signal && !notFirstSignal) {
      notFirstSignal = true;
    }
    appendSaveAsDialog(i, "WaveDrom_Display_");
  }
  document.head.insertAdjacentHTML("beforeend", '<style type="text/css">div.wavedromMenu{position:fixed;border:solid 1pt#CCCCCC;background-color:white;box-shadow:0px 10px 20px #808080;cursor:default;margin:0px;padding:0px;}div.wavedromMenu>ul{margin:0px;padding:0px;}div.wavedromMenu>ul>li{padding:2px 10px;list-style:none;}div.wavedromMenu>ul>li:hover{background-color:#b5d5ff;}</style>');
}
var processAll_1 = processAll$1;
const eva$1 = eva_1;
const renderWaveForm$1 = renderWaveForm_1;
function editorRefresh$1() {
  renderWaveForm$1(0, eva$1("InputJSON_0"), "WaveDrom_Display_");
}
var editorRefresh_1 = editorRefresh$1;
var _default = { exports: {} };
var WaveSkin$2 = WaveSkin$2 || {};
WaveSkin$2.default = ["svg", { id: "svg", xmlns: "http://www.w3.org/2000/svg", "xmlns:xlink": "http://www.w3.org/1999/xlink", height: "0" }, ["style", { type: "text/css" }, "text{font-size:11pt;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-align:center;fill-opacity:1;font-family:Helvetica}.h1{font-size:33pt;font-weight:bold}.h2{font-size:27pt;font-weight:bold}.h3{font-size:20pt;font-weight:bold}.h4{font-size:14pt;font-weight:bold}.h5{font-size:11pt;font-weight:bold}.h6{font-size:8pt;font-weight:bold}.muted{fill:#aaa}.warning{fill:#f6b900}.error{fill:#f60000}.info{fill:#0041c4}.success{fill:#00ab00}.s1{fill:none;stroke:#000;stroke-width:1;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none}.s2{fill:none;stroke:#000;stroke-width:0.5;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none}.s3{color:#000;fill:none;stroke:#000;stroke-width:1;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:1, 3;stroke-dashoffset:0;marker:none;visibility:visible;display:inline;overflow:visible}.s4{color:#000;fill:none;stroke:#000;stroke-width:1;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none;stroke-dashoffset:0;marker:none;visibility:visible;display:inline;overflow:visible}.s5{fill:#fff;stroke:none}.s6{fill:#000;fill-opacity:1;stroke:none}.s7{color:#000;fill:#fff;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:1px;marker:none;visibility:visible;display:inline;overflow:visible}.s8{color:#000;fill:#ffffb4;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:1px;marker:none;visibility:visible;display:inline;overflow:visible}.s9{color:#000;fill:#ffe0b9;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:1px;marker:none;visibility:visible;display:inline;overflow:visible}.s10{color:#000;fill:#b9e0ff;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:1px;marker:none;visibility:visible;display:inline;overflow:visible}.s11{color:#000;fill:#ccfdfe;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:1px;marker:none;visibility:visible;display:inline;overflow:visible}.s12{color:#000;fill:#cdfdc5;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:1px;marker:none;visibility:visible;display:inline;overflow:visible}.s13{color:#000;fill:#f0c1fb;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:1px;marker:none;visibility:visible;display:inline;overflow:visible}.s14{color:#000;fill:#f5c2c0;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:1px;marker:none;visibility:visible;display:inline;overflow:visible}.s15{fill:#0041c4;fill-opacity:1;stroke:none}.s16{fill:none;stroke:#0041c4;stroke-width:1;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none}"], ["defs", ["g", { id: "socket" }, ["rect", { y: "15", x: "6", height: "20", width: "20" }]], ["g", { id: "pclk" }, ["path", { d: "M0,20 0,0 20,0", class: "s1" }]], ["g", { id: "nclk" }, ["path", { d: "m0,0 0,20 20,0", class: "s1" }]], ["g", { id: "000" }, ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "0m0" }, ["path", { d: "m0,20 3,0 3,-10 3,10 11,0", class: "s1" }]], ["g", { id: "0m1" }, ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "0mx" }, ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m20,15 -5,5", class: "s2" }], ["path", { d: "M20,10 10,20", class: "s2" }], ["path", { d: "M20,5 5,20", class: "s2" }], ["path", { d: "M20,0 4,16", class: "s2" }], ["path", { d: "M15,0 6,9", class: "s2" }], ["path", { d: "M10,0 9,1", class: "s2" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "0md" }, ["path", { d: "m8,20 10,0", class: "s3" }], ["path", { d: "m0,20 5,0", class: "s1" }]], ["g", { id: "0mu" }, ["path", { d: "m0,20 3,0 C 7,10 10.107603,0 20,0", class: "s1" }]], ["g", { id: "0mz" }, ["path", { d: "m0,20 3,0 C 10,10 15,10 20,10", class: "s1" }]], ["g", { id: "111" }, ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "1m0" }, ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }]], ["g", { id: "1m1" }, ["path", { d: "M0,0 3,0 6,10 9,0 20,0", class: "s1" }]], ["g", { id: "1mx" }, ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }], ["path", { d: "m20,15 -5,5", class: "s2" }], ["path", { d: "M20,10 10,20", class: "s2" }], ["path", { d: "M20,5 8,17", class: "s2" }], ["path", { d: "M20,0 7,13", class: "s2" }], ["path", { d: "M15,0 6,9", class: "s2" }], ["path", { d: "M10,0 5,5", class: "s2" }], ["path", { d: "M3.5,1.5 5,0", class: "s2" }]], ["g", { id: "1md" }, ["path", { d: "m0,0 3,0 c 4,10 7,20 17,20", class: "s1" }]], ["g", { id: "1mu" }, ["path", { d: "M0,0 5,0", class: "s1" }], ["path", { d: "M8,0 18,0", class: "s3" }]], ["g", { id: "1mz" }, ["path", { d: "m0,0 3,0 c 7,10 12,10 17,10", class: "s1" }]], ["g", { id: "xxx" }, ["path", { d: "m0,20 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }], ["path", { d: "M0,5 5,0", class: "s2" }], ["path", { d: "M0,10 10,0", class: "s2" }], ["path", { d: "M0,15 15,0", class: "s2" }], ["path", { d: "M0,20 20,0", class: "s2" }], ["path", { d: "M5,20 20,5", class: "s2" }], ["path", { d: "M10,20 20,10", class: "s2" }], ["path", { d: "m15,20 5,-5", class: "s2" }]], ["g", { id: "xm0" }, ["path", { d: "M0,0 4,0 9,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }], ["path", { d: "M0,5 4,1", class: "s2" }], ["path", { d: "M0,10 5,5", class: "s2" }], ["path", { d: "M0,15 6,9", class: "s2" }], ["path", { d: "M0,20 7,13", class: "s2" }], ["path", { d: "M5,20 8,17", class: "s2" }]], ["g", { id: "xm1" }, ["path", { d: "M0,0 20,0", class: "s1" }], ["path", { d: "M0,20 4,20 9,0", class: "s1" }], ["path", { d: "M0,5 5,0", class: "s2" }], ["path", { d: "M0,10 9,1", class: "s2" }], ["path", { d: "M0,15 7,8", class: "s2" }], ["path", { d: "M0,20 5,15", class: "s2" }]], ["g", { id: "xmx" }, ["path", { d: "m0,20 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }], ["path", { d: "M0,5 5,0", class: "s2" }], ["path", { d: "M0,10 10,0", class: "s2" }], ["path", { d: "M0,15 15,0", class: "s2" }], ["path", { d: "M0,20 20,0", class: "s2" }], ["path", { d: "M5,20 20,5", class: "s2" }], ["path", { d: "M10,20 20,10", class: "s2" }], ["path", { d: "m15,20 5,-5", class: "s2" }]], ["g", { id: "xmd" }, ["path", { d: "m0,0 4,0 c 3,10 6,20 16,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }], ["path", { d: "M0,5 4,1", class: "s2" }], ["path", { d: "M0,10 5.5,4.5", class: "s2" }], ["path", { d: "M0,15 6.5,8.5", class: "s2" }], ["path", { d: "M0,20 8,12", class: "s2" }], ["path", { d: "m5,20 5,-5", class: "s2" }], ["path", { d: "m10,20 2.5,-2.5", class: "s2" }]], ["g", { id: "xmu" }, ["path", { d: "M0,0 20,0", class: "s1" }], ["path", { d: "m0,20 4,0 C 7,10 10,0 20,0", class: "s1" }], ["path", { d: "M0,5 5,0", class: "s2" }], ["path", { d: "M0,10 10,0", class: "s2" }], ["path", { d: "M0,15 10,5", class: "s2" }], ["path", { d: "M0,20 6,14", class: "s2" }]], ["g", { id: "xmz" }, ["path", { d: "m0,0 4,0 c 6,10 11,10 16,10", class: "s1" }], ["path", { d: "m0,20 4,0 C 10,10 15,10 20,10", class: "s1" }], ["path", { d: "M0,5 4.5,0.5", class: "s2" }], ["path", { d: "M0,10 6.5,3.5", class: "s2" }], ["path", { d: "M0,15 8.5,6.5", class: "s2" }], ["path", { d: "M0,20 11.5,8.5", class: "s2" }]], ["g", { id: "ddd" }, ["path", { d: "m0,20 20,0", class: "s3" }]], ["g", { id: "dm0" }, ["path", { d: "m0,20 10,0", class: "s3" }], ["path", { d: "m12,20 8,0", class: "s1" }]], ["g", { id: "dm1" }, ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "dmx" }, ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m20,15 -5,5", class: "s2" }], ["path", { d: "M20,10 10,20", class: "s2" }], ["path", { d: "M20,5 5,20", class: "s2" }], ["path", { d: "M20,0 4,16", class: "s2" }], ["path", { d: "M15,0 6,9", class: "s2" }], ["path", { d: "M10,0 9,1", class: "s2" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "dmd" }, ["path", { d: "m0,20 20,0", class: "s3" }]], ["g", { id: "dmu" }, ["path", { d: "m0,20 3,0 C 7,10 10.107603,0 20,0", class: "s1" }]], ["g", { id: "dmz" }, ["path", { d: "m0,20 3,0 C 10,10 15,10 20,10", class: "s1" }]], ["g", { id: "uuu" }, ["path", { d: "M0,0 20,0", class: "s3" }]], ["g", { id: "um0" }, ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }]], ["g", { id: "um1" }, ["path", { d: "M0,0 10,0", class: "s3" }], ["path", { d: "m12,0 8,0", class: "s1" }]], ["g", { id: "umx" }, ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }], ["path", { d: "m20,15 -5,5", class: "s2" }], ["path", { d: "M20,10 10,20", class: "s2" }], ["path", { d: "M20,5 8,17", class: "s2" }], ["path", { d: "M20,0 7,13", class: "s2" }], ["path", { d: "M15,0 6,9", class: "s2" }], ["path", { d: "M10,0 5,5", class: "s2" }], ["path", { d: "M3.5,1.5 5,0", class: "s2" }]], ["g", { id: "umd" }, ["path", { d: "m0,0 3,0 c 4,10 7,20 17,20", class: "s1" }]], ["g", { id: "umu" }, ["path", { d: "M0,0 20,0", class: "s3" }]], ["g", { id: "umz" }, ["path", { d: "m0,0 3,0 c 7,10 12,10 17,10", class: "s4" }]], ["g", { id: "zzz" }, ["path", { d: "m0,10 20,0", class: "s1" }]], ["g", { id: "zm0" }, ["path", { d: "m0,10 6,0 3,10 11,0", class: "s1" }]], ["g", { id: "zm1" }, ["path", { d: "M0,10 6,10 9,0 20,0", class: "s1" }]], ["g", { id: "zmx" }, ["path", { d: "m6,10 3,10 11,0", class: "s1" }], ["path", { d: "M0,10 6,10 9,0 20,0", class: "s1" }], ["path", { d: "m20,15 -5,5", class: "s2" }], ["path", { d: "M20,10 10,20", class: "s2" }], ["path", { d: "M20,5 8,17", class: "s2" }], ["path", { d: "M20,0 7,13", class: "s2" }], ["path", { d: "M15,0 6.5,8.5", class: "s2" }], ["path", { d: "M10,0 9,1", class: "s2" }]], ["g", { id: "zmd" }, ["path", { d: "m0,10 7,0 c 3,5 8,10 13,10", class: "s1" }]], ["g", { id: "zmu" }, ["path", { d: "m0,10 7,0 C 10,5 15,0 20,0", class: "s1" }]], ["g", { id: "zmz" }, ["path", { d: "m0,10 20,0", class: "s1" }]], ["g", { id: "gap" }, ["path", { d: "m7,-2 -4,0 c -5,0 -5,24 -10,24 l 4,0 C 2,22 2,-2 7,-2 z", class: "s5" }], ["path", { d: "M-7,22 C -2,22 -2,-2 3,-2", class: "s1" }], ["path", { d: "M-3,22 C 2,22 2,-2 7,-2", class: "s1" }]], ["g", { id: "Pclk" }, ["path", { d: "M-3,12 0,3 3,12 C 1,11 -1,11 -3,12 z", class: "s6" }], ["path", { d: "M0,20 0,0 20,0", class: "s1" }]], ["g", { id: "Nclk" }, ["path", { d: "M-3,8 0,17 3,8 C 1,9 -1,9 -3,8 z", class: "s6" }], ["path", { d: "m0,0 0,20 20,0", class: "s1" }]], ["g", { id: "0mv-2" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s7" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "1mv-2" }, ["path", { d: "M2.875,0 20,0 20,20 9,20 z", class: "s7" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "xmv-2" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s7" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,5 3.5,1.5", class: "s2" }], ["path", { d: "M0,10 4.5,5.5", class: "s2" }], ["path", { d: "M0,15 6,9", class: "s2" }], ["path", { d: "M0,20 4,16", class: "s2" }]], ["g", { id: "dmv-2" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s7" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "umv-2" }, ["path", { d: "M3,0 20,0 20,20 9,20 z", class: "s7" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "zmv-2" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s7" }], ["path", { d: "m6,10 3,10 11,0", class: "s1" }], ["path", { d: "M0,10 6,10 9,0 20,0", class: "s1" }]], ["g", { id: "vvv-2" }, ["path", { d: "M20,20 0,20 0,0 20,0", class: "s7" }], ["path", { d: "m0,20 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vm0-2" }, ["path", { d: "M0,20 0,0 3,0 9,20", class: "s7" }], ["path", { d: "M0,0 3,0 9,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vm1-2" }, ["path", { d: "M0,0 0,20 3,20 9,0", class: "s7" }], ["path", { d: "M0,0 20,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0", class: "s1" }]], ["g", { id: "vmx-2" }, ["path", { d: "M0,0 0,20 3,20 6,10 3,0", class: "s7" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m20,15 -5,5", class: "s2" }], ["path", { d: "M20,10 10,20", class: "s2" }], ["path", { d: "M20,5 8,17", class: "s2" }], ["path", { d: "M20,0 7,13", class: "s2" }], ["path", { d: "M15,0 7,8", class: "s2" }], ["path", { d: "M10,0 9,1", class: "s2" }]], ["g", { id: "vmd-2" }, ["path", { d: "m0,0 0,20 20,0 C 10,20 7,10 3,0", class: "s7" }], ["path", { d: "m0,0 3,0 c 4,10 7,20 17,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vmu-2" }, ["path", { d: "m0,0 0,20 3,0 C 7,10 10,0 20,0", class: "s7" }], ["path", { d: "m0,20 3,0 C 7,10 10,0 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vmz-2" }, ["path", { d: "M0,0 3,0 C 10,10 15,10 20,10 15,10 10,10 3,20 L 0,20", class: "s7" }], ["path", { d: "m0,0 3,0 c 7,10 12,10 17,10", class: "s1" }], ["path", { d: "m0,20 3,0 C 10,10 15,10 20,10", class: "s1" }]], ["g", { id: "0mv-3" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s8" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "1mv-3" }, ["path", { d: "M2.875,0 20,0 20,20 9,20 z", class: "s8" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "xmv-3" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s8" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,5 3.5,1.5", class: "s2" }], ["path", { d: "M0,10 4.5,5.5", class: "s2" }], ["path", { d: "M0,15 6,9", class: "s2" }], ["path", { d: "M0,20 4,16", class: "s2" }]], ["g", { id: "dmv-3" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s8" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "umv-3" }, ["path", { d: "M3,0 20,0 20,20 9,20 z", class: "s8" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "zmv-3" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s8" }], ["path", { d: "m6,10 3,10 11,0", class: "s1" }], ["path", { d: "M0,10 6,10 9,0 20,0", class: "s1" }]], ["g", { id: "vvv-3" }, ["path", { d: "M20,20 0,20 0,0 20,0", class: "s8" }], ["path", { d: "m0,20 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vm0-3" }, ["path", { d: "M0,20 0,0 3,0 9,20", class: "s8" }], ["path", { d: "M0,0 3,0 9,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vm1-3" }, ["path", { d: "M0,0 0,20 3,20 9,0", class: "s8" }], ["path", { d: "M0,0 20,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0", class: "s1" }]], ["g", { id: "vmx-3" }, ["path", { d: "M0,0 0,20 3,20 6,10 3,0", class: "s8" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m20,15 -5,5", class: "s2" }], ["path", { d: "M20,10 10,20", class: "s2" }], ["path", { d: "M20,5 8,17", class: "s2" }], ["path", { d: "M20,0 7,13", class: "s2" }], ["path", { d: "M15,0 7,8", class: "s2" }], ["path", { d: "M10,0 9,1", class: "s2" }]], ["g", { id: "vmd-3" }, ["path", { d: "m0,0 0,20 20,0 C 10,20 7,10 3,0", class: "s8" }], ["path", { d: "m0,0 3,0 c 4,10 7,20 17,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vmu-3" }, ["path", { d: "m0,0 0,20 3,0 C 7,10 10,0 20,0", class: "s8" }], ["path", { d: "m0,20 3,0 C 7,10 10,0 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vmz-3" }, ["path", { d: "M0,0 3,0 C 10,10 15,10 20,10 15,10 10,10 3,20 L 0,20", class: "s8" }], ["path", { d: "m0,0 3,0 c 7,10 12,10 17,10", class: "s1" }], ["path", { d: "m0,20 3,0 C 10,10 15,10 20,10", class: "s1" }]], ["g", { id: "0mv-4" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s9" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "1mv-4" }, ["path", { d: "M2.875,0 20,0 20,20 9,20 z", class: "s9" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "xmv-4" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s9" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,5 3.5,1.5", class: "s2" }], ["path", { d: "M0,10 4.5,5.5", class: "s2" }], ["path", { d: "M0,15 6,9", class: "s2" }], ["path", { d: "M0,20 4,16", class: "s2" }]], ["g", { id: "dmv-4" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s9" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "umv-4" }, ["path", { d: "M3,0 20,0 20,20 9,20 z", class: "s9" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "zmv-4" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s9" }], ["path", { d: "m6,10 3,10 11,0", class: "s1" }], ["path", { d: "M0,10 6,10 9,0 20,0", class: "s1" }]], ["g", { id: "vvv-4" }, ["path", { d: "M20,20 0,20 0,0 20,0", class: "s9" }], ["path", { d: "m0,20 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vm0-4" }, ["path", { d: "M0,20 0,0 3,0 9,20", class: "s9" }], ["path", { d: "M0,0 3,0 9,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vm1-4" }, ["path", { d: "M0,0 0,20 3,20 9,0", class: "s9" }], ["path", { d: "M0,0 20,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0", class: "s1" }]], ["g", { id: "vmx-4" }, ["path", { d: "M0,0 0,20 3,20 6,10 3,0", class: "s9" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m20,15 -5,5", class: "s2" }], ["path", { d: "M20,10 10,20", class: "s2" }], ["path", { d: "M20,5 8,17", class: "s2" }], ["path", { d: "M20,0 7,13", class: "s2" }], ["path", { d: "M15,0 7,8", class: "s2" }], ["path", { d: "M10,0 9,1", class: "s2" }]], ["g", { id: "vmd-4" }, ["path", { d: "m0,0 0,20 20,0 C 10,20 7,10 3,0", class: "s9" }], ["path", { d: "m0,0 3,0 c 4,10 7,20 17,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vmu-4" }, ["path", { d: "m0,0 0,20 3,0 C 7,10 10,0 20,0", class: "s9" }], ["path", { d: "m0,20 3,0 C 7,10 10,0 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vmz-4" }, ["path", { d: "M0,0 3,0 C 10,10 15,10 20,10 15,10 10,10 3,20 L 0,20", class: "s9" }], ["path", { d: "m0,0 3,0 c 7,10 12,10 17,10", class: "s1" }], ["path", { d: "m0,20 3,0 C 10,10 15,10 20,10", class: "s1" }]], ["g", { id: "0mv-5" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s10" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "1mv-5" }, ["path", { d: "M2.875,0 20,0 20,20 9,20 z", class: "s10" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "xmv-5" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s10" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,5 3.5,1.5", class: "s2" }], ["path", { d: "M0,10 4.5,5.5", class: "s2" }], ["path", { d: "M0,15 6,9", class: "s2" }], ["path", { d: "M0,20 4,16", class: "s2" }]], ["g", { id: "dmv-5" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s10" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "umv-5" }, ["path", { d: "M3,0 20,0 20,20 9,20 z", class: "s10" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "zmv-5" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s10" }], ["path", { d: "m6,10 3,10 11,0", class: "s1" }], ["path", { d: "M0,10 6,10 9,0 20,0", class: "s1" }]], ["g", { id: "vvv-5" }, ["path", { d: "M20,20 0,20 0,0 20,0", class: "s10" }], ["path", { d: "m0,20 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vm0-5" }, ["path", { d: "M0,20 0,0 3,0 9,20", class: "s10" }], ["path", { d: "M0,0 3,0 9,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vm1-5" }, ["path", { d: "M0,0 0,20 3,20 9,0", class: "s10" }], ["path", { d: "M0,0 20,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0", class: "s1" }]], ["g", { id: "vmx-5" }, ["path", { d: "M0,0 0,20 3,20 6,10 3,0", class: "s10" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m20,15 -5,5", class: "s2" }], ["path", { d: "M20,10 10,20", class: "s2" }], ["path", { d: "M20,5 8,17", class: "s2" }], ["path", { d: "M20,0 7,13", class: "s2" }], ["path", { d: "M15,0 7,8", class: "s2" }], ["path", { d: "M10,0 9,1", class: "s2" }]], ["g", { id: "vmd-5" }, ["path", { d: "m0,0 0,20 20,0 C 10,20 7,10 3,0", class: "s10" }], ["path", { d: "m0,0 3,0 c 4,10 7,20 17,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vmu-5" }, ["path", { d: "m0,0 0,20 3,0 C 7,10 10,0 20,0", class: "s10" }], ["path", { d: "m0,20 3,0 C 7,10 10,0 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vmz-5" }, ["path", { d: "M0,0 3,0 C 10,10 15,10 20,10 15,10 10,10 3,20 L 0,20", class: "s10" }], ["path", { d: "m0,0 3,0 c 7,10 12,10 17,10", class: "s1" }], ["path", { d: "m0,20 3,0 C 10,10 15,10 20,10", class: "s1" }]], ["g", { id: "0mv-6" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s11" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "1mv-6" }, ["path", { d: "M2.875,0 20,0 20,20 9,20 z", class: "s11" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "xmv-6" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s11" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,5 3.5,1.5", class: "s2" }], ["path", { d: "M0,10 4.5,5.5", class: "s2" }], ["path", { d: "M0,15 6,9", class: "s2" }], ["path", { d: "M0,20 4,16", class: "s2" }]], ["g", { id: "dmv-6" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s11" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "umv-6" }, ["path", { d: "M3,0 20,0 20,20 9,20 z", class: "s11" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "zmv-6" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s11" }], ["path", { d: "m6,10 3,10 11,0", class: "s1" }], ["path", { d: "M0,10 6,10 9,0 20,0", class: "s1" }]], ["g", { id: "vvv-6" }, ["path", { d: "M20,20 0,20 0,0 20,0", class: "s11" }], ["path", { d: "m0,20 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vm0-6" }, ["path", { d: "M0,20 0,0 3,0 9,20", class: "s11" }], ["path", { d: "M0,0 3,0 9,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vm1-6" }, ["path", { d: "M0,0 0,20 3,20 9,0", class: "s11" }], ["path", { d: "M0,0 20,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0", class: "s1" }]], ["g", { id: "vmx-6" }, ["path", { d: "M0,0 0,20 3,20 6,10 3,0", class: "s11" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m20,15 -5,5", class: "s2" }], ["path", { d: "M20,10 10,20", class: "s2" }], ["path", { d: "M20,5 8,17", class: "s2" }], ["path", { d: "M20,0 7,13", class: "s2" }], ["path", { d: "M15,0 7,8", class: "s2" }], ["path", { d: "M10,0 9,1", class: "s2" }]], ["g", { id: "vmd-6" }, ["path", { d: "m0,0 0,20 20,0 C 10,20 7,10 3,0", class: "s11" }], ["path", { d: "m0,0 3,0 c 4,10 7,20 17,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vmu-6" }, ["path", { d: "m0,0 0,20 3,0 C 7,10 10,0 20,0", class: "s11" }], ["path", { d: "m0,20 3,0 C 7,10 10,0 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vmz-6" }, ["path", { d: "M0,0 3,0 C 10,10 15,10 20,10 15,10 10,10 3,20 L 0,20", class: "s11" }], ["path", { d: "m0,0 3,0 c 7,10 12,10 17,10", class: "s1" }], ["path", { d: "m0,20 3,0 C 10,10 15,10 20,10", class: "s1" }]], ["g", { id: "0mv-7" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s12" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "1mv-7" }, ["path", { d: "M2.875,0 20,0 20,20 9,20 z", class: "s12" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "xmv-7" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s12" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,5 3.5,1.5", class: "s2" }], ["path", { d: "M0,10 4.5,5.5", class: "s2" }], ["path", { d: "M0,15 6,9", class: "s2" }], ["path", { d: "M0,20 4,16", class: "s2" }]], ["g", { id: "dmv-7" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s12" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "umv-7" }, ["path", { d: "M3,0 20,0 20,20 9,20 z", class: "s12" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "zmv-7" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s12" }], ["path", { d: "m6,10 3,10 11,0", class: "s1" }], ["path", { d: "M0,10 6,10 9,0 20,0", class: "s1" }]], ["g", { id: "vvv-7" }, ["path", { d: "M20,20 0,20 0,0 20,0", class: "s12" }], ["path", { d: "m0,20 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vm0-7" }, ["path", { d: "M0,20 0,0 3,0 9,20", class: "s12" }], ["path", { d: "M0,0 3,0 9,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vm1-7" }, ["path", { d: "M0,0 0,20 3,20 9,0", class: "s12" }], ["path", { d: "M0,0 20,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0", class: "s1" }]], ["g", { id: "vmx-7" }, ["path", { d: "M0,0 0,20 3,20 6,10 3,0", class: "s12" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m20,15 -5,5", class: "s2" }], ["path", { d: "M20,10 10,20", class: "s2" }], ["path", { d: "M20,5 8,17", class: "s2" }], ["path", { d: "M20,0 7,13", class: "s2" }], ["path", { d: "M15,0 7,8", class: "s2" }], ["path", { d: "M10,0 9,1", class: "s2" }]], ["g", { id: "vmd-7" }, ["path", { d: "m0,0 0,20 20,0 C 10,20 7,10 3,0", class: "s12" }], ["path", { d: "m0,0 3,0 c 4,10 7,20 17,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vmu-7" }, ["path", { d: "m0,0 0,20 3,0 C 7,10 10,0 20,0", class: "s12" }], ["path", { d: "m0,20 3,0 C 7,10 10,0 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vmz-7" }, ["path", { d: "M0,0 3,0 C 10,10 15,10 20,10 15,10 10,10 3,20 L 0,20", class: "s12" }], ["path", { d: "m0,0 3,0 c 7,10 12,10 17,10", class: "s1" }], ["path", { d: "m0,20 3,0 C 10,10 15,10 20,10", class: "s1" }]], ["g", { id: "0mv-8" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s13" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "1mv-8" }, ["path", { d: "M2.875,0 20,0 20,20 9,20 z", class: "s13" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "xmv-8" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s13" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,5 3.5,1.5", class: "s2" }], ["path", { d: "M0,10 4.5,5.5", class: "s2" }], ["path", { d: "M0,15 6,9", class: "s2" }], ["path", { d: "M0,20 4,16", class: "s2" }]], ["g", { id: "dmv-8" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s13" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "umv-8" }, ["path", { d: "M3,0 20,0 20,20 9,20 z", class: "s13" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "zmv-8" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s13" }], ["path", { d: "m6,10 3,10 11,0", class: "s1" }], ["path", { d: "M0,10 6,10 9,0 20,0", class: "s1" }]], ["g", { id: "vvv-8" }, ["path", { d: "M20,20 0,20 0,0 20,0", class: "s13" }], ["path", { d: "m0,20 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vm0-8" }, ["path", { d: "M0,20 0,0 3,0 9,20", class: "s13" }], ["path", { d: "M0,0 3,0 9,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vm1-8" }, ["path", { d: "M0,0 0,20 3,20 9,0", class: "s13" }], ["path", { d: "M0,0 20,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0", class: "s1" }]], ["g", { id: "vmx-8" }, ["path", { d: "M0,0 0,20 3,20 6,10 3,0", class: "s13" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m20,15 -5,5", class: "s2" }], ["path", { d: "M20,10 10,20", class: "s2" }], ["path", { d: "M20,5 8,17", class: "s2" }], ["path", { d: "M20,0 7,13", class: "s2" }], ["path", { d: "M15,0 7,8", class: "s2" }], ["path", { d: "M10,0 9,1", class: "s2" }]], ["g", { id: "vmd-8" }, ["path", { d: "m0,0 0,20 20,0 C 10,20 7,10 3,0", class: "s13" }], ["path", { d: "m0,0 3,0 c 4,10 7,20 17,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vmu-8" }, ["path", { d: "m0,0 0,20 3,0 C 7,10 10,0 20,0", class: "s13" }], ["path", { d: "m0,20 3,0 C 7,10 10,0 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vmz-8" }, ["path", { d: "M0,0 3,0 C 10,10 15,10 20,10 15,10 10,10 3,20 L 0,20", class: "s13" }], ["path", { d: "m0,0 3,0 c 7,10 12,10 17,10", class: "s1" }], ["path", { d: "m0,20 3,0 C 10,10 15,10 20,10", class: "s1" }]], ["g", { id: "0mv-9" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s14" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "1mv-9" }, ["path", { d: "M2.875,0 20,0 20,20 9,20 z", class: "s14" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "xmv-9" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s14" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,5 3.5,1.5", class: "s2" }], ["path", { d: "M0,10 4.5,5.5", class: "s2" }], ["path", { d: "M0,15 6,9", class: "s2" }], ["path", { d: "M0,20 4,16", class: "s2" }]], ["g", { id: "dmv-9" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s14" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "umv-9" }, ["path", { d: "M3,0 20,0 20,20 9,20 z", class: "s14" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "zmv-9" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s14" }], ["path", { d: "m6,10 3,10 11,0", class: "s1" }], ["path", { d: "M0,10 6,10 9,0 20,0", class: "s1" }]], ["g", { id: "vvv-9" }, ["path", { d: "M20,20 0,20 0,0 20,0", class: "s14" }], ["path", { d: "m0,20 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vm0-9" }, ["path", { d: "M0,20 0,0 3,0 9,20", class: "s14" }], ["path", { d: "M0,0 3,0 9,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vm1-9" }, ["path", { d: "M0,0 0,20 3,20 9,0", class: "s14" }], ["path", { d: "M0,0 20,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0", class: "s1" }]], ["g", { id: "vmx-9" }, ["path", { d: "M0,0 0,20 3,20 6,10 3,0", class: "s14" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m20,15 -5,5", class: "s2" }], ["path", { d: "M20,10 10,20", class: "s2" }], ["path", { d: "M20,5 8,17", class: "s2" }], ["path", { d: "M20,0 7,13", class: "s2" }], ["path", { d: "M15,0 7,8", class: "s2" }], ["path", { d: "M10,0 9,1", class: "s2" }]], ["g", { id: "vmd-9" }, ["path", { d: "m0,0 0,20 20,0 C 10,20 7,10 3,0", class: "s14" }], ["path", { d: "m0,0 3,0 c 4,10 7,20 17,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vmu-9" }, ["path", { d: "m0,0 0,20 3,0 C 7,10 10,0 20,0", class: "s14" }], ["path", { d: "m0,20 3,0 C 7,10 10,0 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vmz-9" }, ["path", { d: "M0,0 3,0 C 10,10 15,10 20,10 15,10 10,10 3,20 L 0,20", class: "s14" }], ["path", { d: "m0,0 3,0 c 7,10 12,10 17,10", class: "s1" }], ["path", { d: "m0,20 3,0 C 10,10 15,10 20,10", class: "s1" }]], ["g", { id: "vmv-2-2" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s7" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s7" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-3-2" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s7" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s8" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-4-2" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s7" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s9" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-5-2" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s7" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s10" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-6-2" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s7" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s11" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-7-2" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s7" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s12" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-8-2" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s7" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s13" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-9-2" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s7" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s14" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-2-3" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s8" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s7" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-3-3" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s8" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s8" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-4-3" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s8" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s9" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-5-3" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s8" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s10" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-6-3" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s8" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s11" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-7-3" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s8" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s12" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-8-3" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s8" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s13" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-9-3" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s8" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s14" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-2-4" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s9" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s7" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-3-4" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s9" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s8" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-4-4" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s9" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s9" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-5-4" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s9" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s10" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-6-4" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s9" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s11" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-7-4" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s9" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s12" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-8-4" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s9" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s13" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-9-4" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s9" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s14" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-2-5" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s10" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s7" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-3-5" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s10" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s8" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-4-5" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s10" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s9" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-5-5" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s10" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s10" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-6-5" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s10" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s11" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-7-5" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s10" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s12" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-8-5" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s10" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s13" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-9-5" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s10" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s14" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-2-6" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s11" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s7" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-3-6" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s11" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s8" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-4-6" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s11" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s9" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-5-6" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s11" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s10" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-6-6" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s11" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s11" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-7-6" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s11" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s12" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-8-6" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s11" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s13" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-9-6" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s11" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s14" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-2-7" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s12" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s7" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-3-7" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s12" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s8" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-4-7" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s12" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s9" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-5-7" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s12" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s10" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-6-7" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s12" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s11" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-7-7" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s12" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s12" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-8-7" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s12" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s13" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-9-7" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s12" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s14" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-2-8" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s13" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s7" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-3-8" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s13" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s8" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-4-8" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s13" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s9" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-5-8" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s13" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s10" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-6-8" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s13" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s11" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-7-8" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s13" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s12" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-8-8" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s13" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s13" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-9-8" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s13" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s14" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-2-9" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s14" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s7" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-3-9" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s14" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s8" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-4-9" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s14" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s9" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-5-9" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s14" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s10" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-6-9" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s14" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s11" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-7-9" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s14" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s12" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-8-9" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s14" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s13" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-9-9" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s14" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s14" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "arrow0" }, ["path", { d: "m-12,-3 9,3 -9,3 c 1,-2 1,-4 0,-6 z", class: "s15" }], ["path", { d: "M0,0 -15,0", class: "s16" }]], ["marker", { id: "arrowhead", style: "fill:#0041c4", markerHeight: 7, markerWidth: 10, markerUnits: "strokeWidth", viewBox: "0 -4 11 8", refX: 15, refY: 0, orient: "auto" }, ["path", { d: "M0 -4 11 0 0 4z" }]], ["marker", { id: "arrowtail", style: "fill:#0041c4", markerHeight: 7, markerWidth: 10, markerUnits: "strokeWidth", viewBox: "-11 -4 11 8", refX: -15, refY: 0, orient: "auto" }, ["path", { d: "M0 -4 -11 0 0 4z" }]], ["marker", { id: "tee", style: "fill:#0041c4", markerHeight: 6, markerWidth: 1, markerUnits: "strokeWidth", viewBox: "0 0 1 6", refX: 0, refY: 3, orient: "auto" }, ["path", { d: "M 0 0 L 0 6", style: "stroke:#0041c4;stroke-width:2" }]]], ["g", { id: "waves" }, ["g", { id: "lanes" }], ["g", { id: "groups" }]]];
try {
  _default.exports = WaveSkin$2;
} catch (err) {
}
var _defaultExports = _default.exports;
const def$1 = /* @__PURE__ */ getDefaultExportFromCjs(_defaultExports);
const stringify$3 = stringify_1;
const tt$1 = tt$a;
const pkg = require$$2;
const processAll = processAll_1;
const eva = eva_1;
const renderWaveForm = renderWaveForm_1;
const renderWaveElement = renderWaveElement_1;
const renderAny = renderAny_1;
const editorRefresh = editorRefresh_1;
const def = _defaultExports;
lib$2.version = pkg.version;
lib$2.processAll = processAll;
lib$2.eva = eva;
lib$2.renderAny = renderAny;
lib$2.renderWaveForm = renderWaveForm;
lib$2.renderWaveElement = renderWaveElement;
lib$2.editorRefresh = editorRefresh;
lib$2.waveSkin = def;
lib$2.onml = {
  stringify: stringify$3,
  tt: tt$1
};
var narrow$1 = { exports: {} };
var WaveSkin$1 = WaveSkin$1 || {};
WaveSkin$1.narrow = ["svg", { id: "svg", xmlns: "http://www.w3.org/2000/svg", "xmlns:xlink": "http://www.w3.org/1999/xlink", height: "0" }, ["style", { type: "text/css" }, "text{font-size:11pt;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-align:center;fill-opacity:1;font-family:Helvetica}.h1{font-size:33pt;font-weight:bold}.h2{font-size:27pt;font-weight:bold}.h3{font-size:20pt;font-weight:bold}.h4{font-size:14pt;font-weight:bold}.h5{font-size:11pt;font-weight:bold}.h6{font-size:8pt;font-weight:bold}.muted{fill:#aaa}.warning{fill:#f6b900}.error{fill:#f60000}.info{fill:#0041c4}.success{fill:#00ab00}.s1{fill:none;stroke:#000000;stroke-width:1;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none}.s2{fill:none;stroke:#000000;stroke-width:0.5;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none}.s3{color:#000000;fill:none;stroke:#000000;stroke-width:1;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:1, 3;stroke-dashoffset:0;marker:none;visibility:visible;display:inline;overflow:visible}.s4{color:#000000;fill:none;stroke:#000000;stroke-width:1;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none;stroke-dashoffset:0;marker:none;visibility:visible;display:inline;overflow:visible}.s5{fill:#ffffff;stroke:none}.s6{fill:#000000;fill-opacity:1;stroke:none}.s7{color:#000000;fill:#fff;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:1px;marker:none;visibility:visible;display:inline;overflow:visible}.s8{color:#000000;fill:#ffffb4;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:1px;marker:none;visibility:visible;display:inline;overflow:visible}.s9{color:#000000;fill:#ffe0b9;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:1px;marker:none;visibility:visible;display:inline;overflow:visible}.s10{color:#000000;fill:#b9e0ff;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:1px;marker:none;visibility:visible;display:inline;overflow:visible}.s11{color:#000000;fill:#ccfdfe;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:1px;marker:none;visibility:visible;display:inline;overflow:visible}.s12{color:#000000;fill:#cdfdc5;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:1px;marker:none;visibility:visible;display:inline;overflow:visible}.s13{color:#000000;fill:#f0c1fb;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:1px;marker:none;visibility:visible;display:inline;overflow:visible}.s14{color:#000000;fill:#f5c2c0;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:1px;marker:none;visibility:visible;display:inline;overflow:visible}"], ["defs", ["g", { id: "socket" }, ["rect", { y: "15", x: "4", height: "20", width: "10" }]], ["g", { id: "pclk" }, ["path", { d: "M 0,20 0,0 10,0", class: "s1" }]], ["g", { id: "nclk" }, ["path", { d: "m 0,0 0,20 10,0", class: "s1" }]], ["g", { id: "000" }, ["path", { d: "m 0,20 10,0", class: "s1" }]], ["g", { id: "0m0" }, ["path", { d: "m 0,20 1,0 3,-10 3,10 3,0", class: "s1" }]], ["g", { id: "0m1" }, ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "0mx" }, ["path", { d: "M 1,20 7,0 10,0", class: "s1" }], ["path", { d: "M 10,15 5,20", class: "s2" }], ["path", { d: "M 10,10 2,18", class: "s2" }], ["path", { d: "M 10,5 4,11", class: "s2" }], ["path", { d: "M 10,0 6,4", class: "s2" }], ["path", { d: "m 0,20 10,0", class: "s1" }]], ["g", { id: "0md" }, ["path", { d: "m 1,20 9,0", class: "s3" }], ["path", { d: "m 0,20 1,0", class: "s1" }]], ["g", { id: "0mu" }, ["path", { d: "m 0,20 1,0 C 2,13 5,0 10,0", class: "s1" }]], ["g", { id: "0mz" }, ["path", { d: "m 0,20 1,0 C 3,14 7,10 10,10", class: "s1" }]], ["g", { id: "111" }, ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "1m0" }, ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }]], ["g", { id: "1m1" }, ["path", { d: "M 0,0 1,0 4,10 7,0 10,0", class: "s1" }]], ["g", { id: "1mx" }, ["path", { d: "m 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }], ["path", { d: "M 10,15 6.5,18.5", class: "s2" }], ["path", { d: "M 10,10 5.5,14.5", class: "s2" }], ["path", { d: "M 10,5 4.5,10.5", class: "s2" }], ["path", { d: "M 10,0 3,7", class: "s2" }], ["path", { d: "M 2,3 5,0", class: "s2" }]], ["g", { id: "1md" }, ["path", { d: "m 0,0 1,0 c 1,7 4,20 9,20", class: "s1" }]], ["g", { id: "1mu" }, ["path", { d: "M 0,0 1,0", class: "s1" }], ["path", { d: "m 1,0 9,0", class: "s3" }]], ["g", { id: "1mz" }, ["path", { d: "m 0,0 1,0 c 2,4 6,10 9,10", class: "s1" }]], ["g", { id: "xxx" }, ["path", { d: "m 0,20 10,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }], ["path", { d: "M 0,5 5,0", class: "s2" }], ["path", { d: "M 0,10 10,0", class: "s2" }], ["path", { d: "M 0,15 10,5", class: "s2" }], ["path", { d: "M 0,20 10,10", class: "s2" }], ["path", { d: "m 5,20 5,-5", class: "s2" }]], ["g", { id: "xm0" }, ["path", { d: "M 0,0 1,0 7,20", class: "s1" }], ["path", { d: "m 0,20 10,0", class: "s1" }], ["path", { d: "M 0,5 2,3", class: "s2" }], ["path", { d: "M 0,10 3,7", class: "s2" }], ["path", { d: "M 0,15 4,11", class: "s2" }], ["path", { d: "M 0,20 5,15", class: "s2" }], ["path", { d: "M 5,20 6,19", class: "s2" }]], ["g", { id: "xm1" }, ["path", { d: "M 0,0 10,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0", class: "s1" }], ["path", { d: "M 0,5 5,0", class: "s2" }], ["path", { d: "M 0,10 6,4", class: "s2" }], ["path", { d: "M 0,15 3,12", class: "s2" }], ["path", { d: "M 0,20 1,19", class: "s2" }]], ["g", { id: "xmx" }, ["path", { d: "m 0,20 10,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }], ["path", { d: "M 0,5 5,0", class: "s2" }], ["path", { d: "M 0,10 10,0", class: "s2" }], ["path", { d: "M 0,15 10,5", class: "s2" }], ["path", { d: "M 0,20 10,10", class: "s2" }], ["path", { d: "m 5,20 5,-5", class: "s2" }]], ["g", { id: "xmd" }, ["path", { d: "m 0,0 1,0 c 1,7 4,20 9,20", class: "s1" }], ["path", { d: "m 0,20 10,0", class: "s1" }], ["path", { d: "M 0,5 1.5,3.5", class: "s2" }], ["path", { d: "M 0,10 2.5,7.5", class: "s2" }], ["path", { d: "M 0,15 3.5,11.5", class: "s2" }], ["path", { d: "M 0,20 5,15", class: "s2" }], ["path", { d: "M 5,20 7,18", class: "s2" }]], ["g", { id: "xmu" }, ["path", { d: "M 0,0 10,0", class: "s1" }], ["path", { d: "m 0,20 1,0 C 2,13 5,0 10,0", class: "s1" }], ["path", { d: "M 0,5 5,0", class: "s2" }], ["path", { d: "M 0,10 5,5", class: "s2" }], ["path", { d: "M 0,15 2,13", class: "s2" }], ["path", { d: "M 0,20 1,19", class: "s2" }]], ["g", { id: "xmz" }, ["path", { d: "m 0,0 1,0 c 2,6 6,10 9,10", class: "s1" }], ["path", { d: "m 0,20 1,0 C 3,14 7,10 10,10", class: "s1" }], ["path", { d: "M 0,5 2,3", class: "s2" }], ["path", { d: "M 0,10 4,6", class: "s2" }], ["path", { d: "m 0,15.5 6,-7", class: "s2" }], ["path", { d: "M 0,20 1,19", class: "s2" }]], ["g", { id: "ddd" }, ["path", { d: "m 0,20 10,0", class: "s3" }]], ["g", { id: "dm0" }, ["path", { d: "m 0,20 7,0", class: "s3" }], ["path", { d: "m 7,20 3,0", class: "s1" }]], ["g", { id: "dm1" }, ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "dmx" }, ["path", { d: "M 1,20 7,0 10,0", class: "s1" }], ["path", { d: "M 10,15 5,20", class: "s2" }], ["path", { d: "M 10,10 1.5,18.5", class: "s2" }], ["path", { d: "M 10,5 4,11", class: "s2" }], ["path", { d: "M 10,0 6,4", class: "s2" }], ["path", { d: "m 0,20 10,0", class: "s1" }]], ["g", { id: "dmd" }, ["path", { d: "m 0,20 10,0", class: "s3" }]], ["g", { id: "dmu" }, ["path", { d: "m 0,20 1,0 C 2,13 5,0 10,0", class: "s1" }]], ["g", { id: "dmz" }, ["path", { d: "m 0,20 1,0 C 3,14 7,10 10,10", class: "s1" }]], ["g", { id: "uuu" }, ["path", { d: "M 0,0 10,0", class: "s3" }]], ["g", { id: "um0" }, ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }]], ["g", { id: "um1" }, ["path", { d: "M 0,0 7,0", class: "s3" }], ["path", { d: "m 7,0 3,0", class: "s1" }]], ["g", { id: "umx" }, ["path", { d: "M 1.4771574,0 7,20 l 3,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }], ["path", { d: "M 10,15 6.5,18.5", class: "s2" }], ["path", { d: "M 10,10 5.5,14.5", class: "s2" }], ["path", { d: "M 10,5 4.5,10.5", class: "s2" }], ["path", { d: "M 10,0 3.5,6.5", class: "s2" }], ["path", { d: "M 2.463621,2.536379 5,0", class: "s2" }]], ["g", { id: "umd" }, ["path", { d: "m 0,0 1,0 c 1,7 4,20 9,20", class: "s1" }]], ["g", { id: "umu" }, ["path", { d: "M 0,0 10,0", class: "s3" }]], ["g", { id: "umz" }, ["path", { d: "m 0,0 1,0 c 2,6 6,10 9,10", class: "s4" }]], ["g", { id: "zzz" }, ["path", { d: "m 0,10 10,0", class: "s1" }]], ["g", { id: "zm0" }, ["path", { d: "m 0,10 1,0 4,10 5,0", class: "s1" }]], ["g", { id: "zm1" }, ["path", { d: "M 0,10 1,10 5,0 10,0", class: "s1" }]], ["g", { id: "zmx" }, ["path", { d: "m 1,10 4,10 5,0", class: "s1" }], ["path", { d: "M 0,10 1,10 5,0 10,0", class: "s1" }], ["path", { d: "M 10,15 5,20", class: "s2" }], ["path", { d: "M 10,10 4,16", class: "s2" }], ["path", { d: "M 10,5 2.5,12.5", class: "s2" }], ["path", { d: "M 10,0 2,8", class: "s2" }]], ["g", { id: "zmd" }, ["path", { d: "m 0,10 1,0 c 2,6 6,10 9,10", class: "s1" }]], ["g", { id: "zmu" }, ["path", { d: "m 0,10 1,0 C 3,4 7,0 10,0", class: "s1" }]], ["g", { id: "zmz" }, ["path", { d: "m 0,10 10,0", class: "s1" }]], ["g", { id: "gap" }, ["path", { d: "m 7,-2 -4,0 c -5,0 -5,24 -10,24 l 4,0 C 2,22 2,-2 7,-2 z", class: "s5" }], ["path", { d: "M -7,22 C -2,22 -2,-2 3,-2", class: "s1" }], ["path", { d: "M -3,22 C 2,22 2,-2 7,-2", class: "s1" }]], ["g", { id: "Pclk" }, ["path", { d: "M -3,12 0,3 3,12 C 1,11 -1,11 -3,12 z", class: "s6" }], ["path", { d: "M 0,20 0,0 10,0", class: "s1" }]], ["g", { id: "Nclk" }, ["path", { d: "M -3,8 0,17 3,8 C 1,9 -1,9 -3,8 z", class: "s6" }], ["path", { d: "m 0,0 0,20 10,0", class: "s1" }]], ["g", { id: "0mv-2" }, ["path", { d: "m 7,0 3,0 0,20 -9,0 z", class: "s7" }], ["path", { d: "M 1,20 7,0 10,0", class: "s1" }], ["path", { d: "m 0,20 10,0", class: "s1" }]], ["g", { id: "1mv-2" }, ["path", { d: "m 1,0 9,0 0,20 -3,0 z", class: "s7" }], ["path", { d: "m 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "xmv-2" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s7" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,5 2,3", class: "s2" }], ["path", { d: "M 0,10 3,7", class: "s2" }], ["path", { d: "M 0,15 3,12", class: "s2" }], ["path", { d: "M 0,20 1,19", class: "s2" }]], ["g", { id: "dmv-2" }, ["path", { d: "m 7,0 3,0 0,20 -9,0 z", class: "s7" }], ["path", { d: "M 1,20 7,0 10,0", class: "s1" }], ["path", { d: "m 0,20 10,0", class: "s1" }]], ["g", { id: "umv-2" }, ["path", { d: "m 1,0 9,0 0,20 -3,0 z", class: "s7" }], ["path", { d: "m 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "zmv-2" }, ["path", { d: "M 5,0 10,0 10,20 5,20 1,10 z", class: "s7" }], ["path", { d: "m 1,10 4,10 5,0", class: "s1" }], ["path", { d: "M 0,10 1,10 5,0 10,0", class: "s1" }]], ["g", { id: "vvv-2" }, ["path", { d: "M 10,20 0,20 0,0 10,0", class: "s7" }], ["path", { d: "m 0,20 10,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "vm0-2" }, ["path", { d: "m 0,20 0,-20 1.000687,-0.00391 6,20", class: "s7" }], ["path", { d: "m 0,0 1.000687,-0.00391 6,20", class: "s1" }], ["path", { d: "m 0,20 10.000687,-0.0039", class: "s1" }]], ["g", { id: "vm1-2" }, ["path", { d: "M 0,0 0,20 1,20 7,0", class: "s7" }], ["path", { d: "M 0,0 10,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0", class: "s1" }]], ["g", { id: "vmx-2" }, ["path", { d: "M 0,0 0,20 1,20 4,10 1,0", class: "s7" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }], ["path", { d: "M 10,15 6.5,18.5", class: "s2" }], ["path", { d: "M 10,10 5.5,14.5", class: "s2" }], ["path", { d: "M 10,5 4,11", class: "s2" }], ["path", { d: "M 10,0 6,4", class: "s2" }]], ["g", { id: "vmd-2" }, ["path", { d: "m 0,0 0,20 10,0 C 5,20 2,7 1,0", class: "s7" }], ["path", { d: "m 0,0 1,0 c 1,7 4,20 9,20", class: "s1" }], ["path", { d: "m 0,20 10,0", class: "s1" }]], ["g", { id: "vmu-2" }, ["path", { d: "m 0,0 0,20 1,0 C 2,13 5,0 10,0", class: "s7" }], ["path", { d: "m 0,20 1,0 C 2,13 5,0 10,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "vmz-2" }, ["path", { d: "M 0,0 1,0 C 3,6 7,10 10,10 7,10 3,14 1,20 L 0,20", class: "s7" }], ["path", { d: "m 0,0 1,0 c 2,6 6,10 9,10", class: "s1" }], ["path", { d: "m 0,20 1,0 C 3,14 7,10 10,10", class: "s1" }]], ["g", { id: "0mv-3" }, ["path", { d: "m 7,0 3,0 0,20 -9,0 z", class: "s8" }], ["path", { d: "M 1,20 7,0 10,0", class: "s1" }], ["path", { d: "m 0,20 10,0", class: "s1" }]], ["g", { id: "1mv-3" }, ["path", { d: "m 1,0 9,0 0,20 -3,0 z", class: "s8" }], ["path", { d: "m 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "xmv-3" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s8" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,5 2,3", class: "s2" }], ["path", { d: "M 0,10 3,7", class: "s2" }], ["path", { d: "M 0,15 3,12", class: "s2" }], ["path", { d: "M 0,20 1,19", class: "s2" }]], ["g", { id: "dmv-3" }, ["path", { d: "m 7,0 3,0 0,20 -9,0 z", class: "s8" }], ["path", { d: "M 1,20 7,0 10,0", class: "s1" }], ["path", { d: "m 0,20 10,0", class: "s1" }]], ["g", { id: "umv-3" }, ["path", { d: "m 1,0 9,0 0,20 -3,0 z", class: "s8" }], ["path", { d: "m 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "zmv-3" }, ["path", { d: "M 5,0 10,0 10,20 5,20 1,10 z", class: "s8" }], ["path", { d: "m 1,10 4,10 5,0", class: "s1" }], ["path", { d: "M 0,10 1,10 5,0 10,0", class: "s1" }]], ["g", { id: "vvv-3" }, ["path", { d: "M 10,20 0,20 0,0 10,0", class: "s8" }], ["path", { d: "m 0,20 10,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "vm0-3" }, ["path", { d: "m 0,20 0,-20 1.000687,-0.00391 6,20", class: "s8" }], ["path", { d: "m 0,0 1.000687,-0.00391 6,20", class: "s1" }], ["path", { d: "m 0,20 10.000687,-0.0039", class: "s1" }]], ["g", { id: "vm1-3" }, ["path", { d: "M 0,0 0,20 1,20 7,0", class: "s8" }], ["path", { d: "M 0,0 10,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0", class: "s1" }]], ["g", { id: "vmx-3" }, ["path", { d: "M 0,0 0,20 1,20 4,10 1,0", class: "s8" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }], ["path", { d: "M 10,15 6.5,18.5", class: "s2" }], ["path", { d: "M 10,10 5.5,14.5", class: "s2" }], ["path", { d: "M 10,5 4,11", class: "s2" }], ["path", { d: "M 10,0 6,4", class: "s2" }]], ["g", { id: "vmd-3" }, ["path", { d: "m 0,0 0,20 10,0 C 5,20 2,7 1,0", class: "s8" }], ["path", { d: "m 0,0 1,0 c 1,7 4,20 9,20", class: "s1" }], ["path", { d: "m 0,20 10,0", class: "s1" }]], ["g", { id: "vmu-3" }, ["path", { d: "m 0,0 0,20 1,0 C 2,13 5,0 10,0", class: "s8" }], ["path", { d: "m 0,20 1,0 C 2,13 5,0 10,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "vmz-3" }, ["path", { d: "M 0,0 1,0 C 3,6 7,10 10,10 7,10 3,14 1,20 L 0,20", class: "s8" }], ["path", { d: "m 0,0 1,0 c 2,6 6,10 9,10", class: "s1" }], ["path", { d: "m 0,20 1,0 C 3,14 7,10 10,10", class: "s1" }]], ["g", { id: "0mv-4" }, ["path", { d: "m 7,0 3,0 0,20 -9,0 z", class: "s9" }], ["path", { d: "M 1,20 7,0 10,0", class: "s1" }], ["path", { d: "m 0,20 10,0", class: "s1" }]], ["g", { id: "1mv-4" }, ["path", { d: "m 1,0 9,0 0,20 -3,0 z", class: "s9" }], ["path", { d: "m 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "xmv-4" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s9" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,5 2,3", class: "s2" }], ["path", { d: "M 0,10 3,7", class: "s2" }], ["path", { d: "M 0,15 3,12", class: "s2" }], ["path", { d: "M 0,20 1,19", class: "s2" }]], ["g", { id: "dmv-4" }, ["path", { d: "m 7,0 3,0 0,20 -9,0 z", class: "s9" }], ["path", { d: "M 1,20 7,0 10,0", class: "s1" }], ["path", { d: "m 0,20 10,0", class: "s1" }]], ["g", { id: "umv-4" }, ["path", { d: "m 1,0 9,0 0,20 -3,0 z", class: "s9" }], ["path", { d: "m 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "zmv-4" }, ["path", { d: "M 5,0 10,0 10,20 5,20 1,10 z", class: "s9" }], ["path", { d: "m 1,10 4,10 5,0", class: "s1" }], ["path", { d: "M 0,10 1,10 5,0 10,0", class: "s1" }]], ["g", { id: "vvv-4" }, ["path", { d: "M 10,20 0,20 0,0 10,0", class: "s9" }], ["path", { d: "m 0,20 10,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "vm0-4" }, ["path", { d: "m 0,20 0,-20 1.000687,-0.00391 6,20", class: "s9" }], ["path", { d: "m 0,0 1.000687,-0.00391 6,20", class: "s1" }], ["path", { d: "m 0,20 10.000687,-0.0039", class: "s1" }]], ["g", { id: "vm1-4" }, ["path", { d: "M 0,0 0,20 1,20 7,0", class: "s9" }], ["path", { d: "M 0,0 10,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0", class: "s1" }]], ["g", { id: "vmx-4" }, ["path", { d: "M 0,0 0,20 1,20 4,10 1,0", class: "s9" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }], ["path", { d: "M 10,15 6.5,18.5", class: "s2" }], ["path", { d: "M 10,10 5.5,14.5", class: "s2" }], ["path", { d: "M 10,5 4,11", class: "s2" }], ["path", { d: "M 10,0 6,4", class: "s2" }]], ["g", { id: "vmd-4" }, ["path", { d: "m 0,0 0,20 10,0 C 5,20 2,7 1,0", class: "s9" }], ["path", { d: "m 0,0 1,0 c 1,7 4,20 9,20", class: "s1" }], ["path", { d: "m 0,20 10,0", class: "s1" }]], ["g", { id: "vmu-4" }, ["path", { d: "m 0,0 0,20 1,0 C 2,13 5,0 10,0", class: "s9" }], ["path", { d: "m 0,20 1,0 C 2,13 5,0 10,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "vmz-4" }, ["path", { d: "M 0,0 1,0 C 3,6 7,10 10,10 7,10 3,14 1,20 L 0,20", class: "s9" }], ["path", { d: "m 0,0 1,0 c 2,6 6,10 9,10", class: "s1" }], ["path", { d: "m 0,20 1,0 C 3,14 7,10 10,10", class: "s1" }]], ["g", { id: "0mv-5" }, ["path", { d: "m 7,0 3,0 0,20 -9,0 z", class: "s10" }], ["path", { d: "M 1,20 7,0 10,0", class: "s1" }], ["path", { d: "m 0,20 10,0", class: "s1" }]], ["g", { id: "1mv-5" }, ["path", { d: "m 1,0 9,0 0,20 -3,0 z", class: "s10" }], ["path", { d: "m 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "xmv-5" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s10" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,5 2,3", class: "s2" }], ["path", { d: "M 0,10 3,7", class: "s2" }], ["path", { d: "M 0,15 3,12", class: "s2" }], ["path", { d: "M 0,20 1,19", class: "s2" }]], ["g", { id: "dmv-5" }, ["path", { d: "m 7,0 3,0 0,20 -9,0 z", class: "s10" }], ["path", { d: "M 1,20 7,0 10,0", class: "s1" }], ["path", { d: "m 0,20 10,0", class: "s1" }]], ["g", { id: "umv-5" }, ["path", { d: "m 1,0 9,0 0,20 -3,0 z", class: "s10" }], ["path", { d: "m 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "zmv-5" }, ["path", { d: "M 5,0 10,0 10,20 5,20 1,10 z", class: "s10" }], ["path", { d: "m 1,10 4,10 5,0", class: "s1" }], ["path", { d: "M 0,10 1,10 5,0 10,0", class: "s1" }]], ["g", { id: "vvv-5" }, ["path", { d: "M 10,20 0,20 0,0 10,0", class: "s10" }], ["path", { d: "m 0,20 10,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "vm0-5" }, ["path", { d: "m 0,20 0,-20 1.000687,-0.00391 6,20", class: "s10" }], ["path", { d: "m 0,0 1.000687,-0.00391 6,20", class: "s1" }], ["path", { d: "m 0,20 10.000687,-0.0039", class: "s1" }]], ["g", { id: "vm1-5" }, ["path", { d: "M 0,0 0,20 1,20 7,0", class: "s10" }], ["path", { d: "M 0,0 10,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0", class: "s1" }]], ["g", { id: "vmx-5" }, ["path", { d: "M 0,0 0,20 1,20 4,10 1,0", class: "s10" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }], ["path", { d: "M 10,15 6.5,18.5", class: "s2" }], ["path", { d: "M 10,10 5.5,14.5", class: "s2" }], ["path", { d: "M 10,5 4,11", class: "s2" }], ["path", { d: "M 10,0 6,4", class: "s2" }]], ["g", { id: "vmd-5" }, ["path", { d: "m 0,0 0,20 10,0 C 5,20 2,7 1,0", class: "s10" }], ["path", { d: "m 0,0 1,0 c 1,7 4,20 9,20", class: "s1" }], ["path", { d: "m 0,20 10,0", class: "s1" }]], ["g", { id: "vmu-5" }, ["path", { d: "m 0,0 0,20 1,0 C 2,13 5,0 10,0", class: "s10" }], ["path", { d: "m 0,20 1,0 C 2,13 5,0 10,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "vmz-5" }, ["path", { d: "M 0,0 1,0 C 3,6 7,10 10,10 7,10 3,14 1,20 L 0,20", class: "s10" }], ["path", { d: "m 0,0 1,0 c 2,6 6,10 9,10", class: "s1" }], ["path", { d: "m 0,20 1,0 C 3,14 7,10 10,10", class: "s1" }]], ["g", { id: "0mv-6" }, ["path", { d: "m 7,0 3,0 0,20 -9,0 z", class: "s11" }], ["path", { d: "M 1,20 7,0 10,0", class: "s1" }], ["path", { d: "m 0,20 10,0", class: "s1" }]], ["g", { id: "1mv-6" }, ["path", { d: "m 1,0 9,0 0,20 -3,0 z", class: "s11" }], ["path", { d: "m 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "xmv-6" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s11" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,5 2,3", class: "s2" }], ["path", { d: "M 0,10 3,7", class: "s2" }], ["path", { d: "M 0,15 3,12", class: "s2" }], ["path", { d: "M 0,20 1,19", class: "s2" }]], ["g", { id: "dmv-6" }, ["path", { d: "m 7,0 3,0 0,20 -9,0 z", class: "s11" }], ["path", { d: "M 1,20 7,0 10,0", class: "s1" }], ["path", { d: "m 0,20 10,0", class: "s1" }]], ["g", { id: "umv-6" }, ["path", { d: "m 1,0 9,0 0,20 -3,0 z", class: "s11" }], ["path", { d: "m 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "zmv-6" }, ["path", { d: "M 5,0 10,0 10,20 5,20 1,10 z", class: "s11" }], ["path", { d: "m 1,10 4,10 5,0", class: "s1" }], ["path", { d: "M 0,10 1,10 5,0 10,0", class: "s1" }]], ["g", { id: "vvv-6" }, ["path", { d: "M 10,20 0,20 0,0 10,0", class: "s11" }], ["path", { d: "m 0,20 10,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "vm0-6" }, ["path", { d: "m 0,20 0,-20 1.000687,-0.00391 6,20", class: "s11" }], ["path", { d: "m 0,0 1.000687,-0.00391 6,20", class: "s1" }], ["path", { d: "m 0,20 10.000687,-0.0039", class: "s1" }]], ["g", { id: "vm1-6" }, ["path", { d: "M 0,0 0,20 1,20 7,0", class: "s11" }], ["path", { d: "M 0,0 10,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0", class: "s1" }]], ["g", { id: "vmx-6" }, ["path", { d: "M 0,0 0,20 1,20 4,10 1,0", class: "s11" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }], ["path", { d: "M 10,15 6.5,18.5", class: "s2" }], ["path", { d: "M 10,10 5.5,14.5", class: "s2" }], ["path", { d: "M 10,5 4,11", class: "s2" }], ["path", { d: "M 10,0 6,4", class: "s2" }]], ["g", { id: "vmd-6" }, ["path", { d: "m 0,0 0,20 10,0 C 5,20 2,7 1,0", class: "s11" }], ["path", { d: "m 0,0 1,0 c 1,7 4,20 9,20", class: "s1" }], ["path", { d: "m 0,20 10,0", class: "s1" }]], ["g", { id: "vmu-6" }, ["path", { d: "m 0,0 0,20 1,0 C 2,13 5,0 10,0", class: "s11" }], ["path", { d: "m 0,20 1,0 C 2,13 5,0 10,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "vmz-6" }, ["path", { d: "M 0,0 1,0 C 3,6 7,10 10,10 7,10 3,14 1,20 L 0,20", class: "s11" }], ["path", { d: "m 0,0 1,0 c 2,6 6,10 9,10", class: "s1" }], ["path", { d: "m 0,20 1,0 C 3,14 7,10 10,10", class: "s1" }]], ["g", { id: "0mv-7" }, ["path", { d: "m 7,0 3,0 0,20 -9,0 z", class: "s12" }], ["path", { d: "M 1,20 7,0 10,0", class: "s1" }], ["path", { d: "m 0,20 10,0", class: "s1" }]], ["g", { id: "1mv-7" }, ["path", { d: "m 1,0 9,0 0,20 -3,0 z", class: "s12" }], ["path", { d: "m 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "xmv-7" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s12" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,5 2,3", class: "s2" }], ["path", { d: "M 0,10 3,7", class: "s2" }], ["path", { d: "M 0,15 3,12", class: "s2" }], ["path", { d: "M 0,20 1,19", class: "s2" }]], ["g", { id: "dmv-7" }, ["path", { d: "m 7,0 3,0 0,20 -9,0 z", class: "s12" }], ["path", { d: "M 1,20 7,0 10,0", class: "s1" }], ["path", { d: "m 0,20 10,0", class: "s1" }]], ["g", { id: "umv-7" }, ["path", { d: "m 1,0 9,0 0,20 -3,0 z", class: "s12" }], ["path", { d: "m 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "zmv-7" }, ["path", { d: "M 5,0 10,0 10,20 5,20 1,10 z", class: "s12" }], ["path", { d: "m 1,10 4,10 5,0", class: "s1" }], ["path", { d: "M 0,10 1,10 5,0 10,0", class: "s1" }]], ["g", { id: "vvv-7" }, ["path", { d: "M 10,20 0,20 0,0 10,0", class: "s12" }], ["path", { d: "m 0,20 10,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "vm0-7" }, ["path", { d: "m 0,20 0,-20 1.000687,-0.00391 6,20", class: "s12" }], ["path", { d: "m 0,0 1.000687,-0.00391 6,20", class: "s1" }], ["path", { d: "m 0,20 10.000687,-0.0039", class: "s1" }]], ["g", { id: "vm1-7" }, ["path", { d: "M 0,0 0,20 1,20 7,0", class: "s12" }], ["path", { d: "M 0,0 10,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0", class: "s1" }]], ["g", { id: "vmx-7" }, ["path", { d: "M 0,0 0,20 1,20 4,10 1,0", class: "s12" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }], ["path", { d: "M 10,15 6.5,18.5", class: "s2" }], ["path", { d: "M 10,10 5.5,14.5", class: "s2" }], ["path", { d: "M 10,5 4,11", class: "s2" }], ["path", { d: "M 10,0 6,4", class: "s2" }]], ["g", { id: "vmd-7" }, ["path", { d: "m 0,0 0,20 10,0 C 5,20 2,7 1,0", class: "s12" }], ["path", { d: "m 0,0 1,0 c 1,7 4,20 9,20", class: "s1" }], ["path", { d: "m 0,20 10,0", class: "s1" }]], ["g", { id: "vmu-7" }, ["path", { d: "m 0,0 0,20 1,0 C 2,13 5,0 10,0", class: "s12" }], ["path", { d: "m 0,20 1,0 C 2,13 5,0 10,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "vmz-7" }, ["path", { d: "M 0,0 1,0 C 3,6 7,10 10,10 7,10 3,14 1,20 L 0,20", class: "s12" }], ["path", { d: "m 0,0 1,0 c 2,6 6,10 9,10", class: "s1" }], ["path", { d: "m 0,20 1,0 C 3,14 7,10 10,10", class: "s1" }]], ["g", { id: "0mv-8" }, ["path", { d: "m 7,0 3,0 0,20 -9,0 z", class: "s13" }], ["path", { d: "M 1,20 7,0 10,0", class: "s1" }], ["path", { d: "m 0,20 10,0", class: "s1" }]], ["g", { id: "1mv-8" }, ["path", { d: "m 1,0 9,0 0,20 -3,0 z", class: "s13" }], ["path", { d: "m 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "xmv-8" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s13" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,5 2,3", class: "s2" }], ["path", { d: "M 0,10 3,7", class: "s2" }], ["path", { d: "M 0,15 3,12", class: "s2" }], ["path", { d: "M 0,20 1,19", class: "s2" }]], ["g", { id: "dmv-8" }, ["path", { d: "m 7,0 3,0 0,20 -9,0 z", class: "s13" }], ["path", { d: "M 1,20 7,0 10,0", class: "s1" }], ["path", { d: "m 0,20 10,0", class: "s1" }]], ["g", { id: "umv-8" }, ["path", { d: "m 1,0 9,0 0,20 -3,0 z", class: "s13" }], ["path", { d: "m 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "zmv-8" }, ["path", { d: "M 5,0 10,0 10,20 5,20 1,10 z", class: "s13" }], ["path", { d: "m 1,10 4,10 5,0", class: "s1" }], ["path", { d: "M 0,10 1,10 5,0 10,0", class: "s1" }]], ["g", { id: "vvv-8" }, ["path", { d: "M 10,20 0,20 0,0 10,0", class: "s13" }], ["path", { d: "m 0,20 10,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "vm0-8" }, ["path", { d: "m 0,20 0,-20 1.000687,-0.00391 6,20", class: "s13" }], ["path", { d: "m 0,0 1.000687,-0.00391 6,20", class: "s1" }], ["path", { d: "m 0,20 10.000687,-0.0039", class: "s1" }]], ["g", { id: "vm1-8" }, ["path", { d: "M 0,0 0,20 1,20 7,0", class: "s13" }], ["path", { d: "M 0,0 10,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0", class: "s1" }]], ["g", { id: "vmx-8" }, ["path", { d: "M 0,0 0,20 1,20 4,10 1,0", class: "s13" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }], ["path", { d: "M 10,15 6.5,18.5", class: "s2" }], ["path", { d: "M 10,10 5.5,14.5", class: "s2" }], ["path", { d: "M 10,5 4,11", class: "s2" }], ["path", { d: "M 10,0 6,4", class: "s2" }]], ["g", { id: "vmd-8" }, ["path", { d: "m 0,0 0,20 10,0 C 5,20 2,7 1,0", class: "s13" }], ["path", { d: "m 0,0 1,0 c 1,7 4,20 9,20", class: "s1" }], ["path", { d: "m 0,20 10,0", class: "s1" }]], ["g", { id: "vmu-8" }, ["path", { d: "m 0,0 0,20 1,0 C 2,13 5,0 10,0", class: "s13" }], ["path", { d: "m 0,20 1,0 C 2,13 5,0 10,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "vmz-8" }, ["path", { d: "M 0,0 1,0 C 3,6 7,10 10,10 7,10 3,14 1,20 L 0,20", class: "s13" }], ["path", { d: "m 0,0 1,0 c 2,6 6,10 9,10", class: "s1" }], ["path", { d: "m 0,20 1,0 C 3,14 7,10 10,10", class: "s1" }]], ["g", { id: "0mv-9" }, ["path", { d: "m 7,0 3,0 0,20 -9,0 z", class: "s14" }], ["path", { d: "M 1,20 7,0 10,0", class: "s1" }], ["path", { d: "m 0,20 10,0", class: "s1" }]], ["g", { id: "1mv-9" }, ["path", { d: "m 1,0 9,0 0,20 -3,0 z", class: "s14" }], ["path", { d: "m 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "xmv-9" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s14" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,5 2,3", class: "s2" }], ["path", { d: "M 0,10 3,7", class: "s2" }], ["path", { d: "M 0,15 3,12", class: "s2" }], ["path", { d: "M 0,20 1,19", class: "s2" }]], ["g", { id: "dmv-9" }, ["path", { d: "m 7,0 3,0 0,20 -9,0 z", class: "s14" }], ["path", { d: "M 1,20 7,0 10,0", class: "s1" }], ["path", { d: "m 0,20 10,0", class: "s1" }]], ["g", { id: "umv-9" }, ["path", { d: "m 1,0 9,0 0,20 -3,0 z", class: "s14" }], ["path", { d: "m 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "zmv-9" }, ["path", { d: "M 5,0 10,0 10,20 5,20 1,10 z", class: "s14" }], ["path", { d: "m 1,10 4,10 5,0", class: "s1" }], ["path", { d: "M 0,10 1,10 5,0 10,0", class: "s1" }]], ["g", { id: "vvv-9" }, ["path", { d: "M 10,20 0,20 0,0 10,0", class: "s14" }], ["path", { d: "m 0,20 10,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "vm0-9" }, ["path", { d: "m 0,20 0,-20 1.000687,-0.00391 6,20", class: "s14" }], ["path", { d: "m 0,0 1.000687,-0.00391 6,20", class: "s1" }], ["path", { d: "m 0,20 10.000687,-0.0039", class: "s1" }]], ["g", { id: "vm1-9" }, ["path", { d: "M 0,0 0,20 1,20 7,0", class: "s14" }], ["path", { d: "M 0,0 10,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0", class: "s1" }]], ["g", { id: "vmx-9" }, ["path", { d: "M 0,0 0,20 1,20 4,10 1,0", class: "s14" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }], ["path", { d: "M 10,15 6.5,18.5", class: "s2" }], ["path", { d: "M 10,10 5.5,14.5", class: "s2" }], ["path", { d: "M 10,5 4,11", class: "s2" }], ["path", { d: "M 10,0 6,4", class: "s2" }]], ["g", { id: "vmd-9" }, ["path", { d: "m 0,0 0,20 10,0 C 5,20 2,7 1,0", class: "s14" }], ["path", { d: "m 0,0 1,0 c 1,7 4,20 9,20", class: "s1" }], ["path", { d: "m 0,20 10,0", class: "s1" }]], ["g", { id: "vmu-9" }, ["path", { d: "m 0,0 0,20 1,0 C 2,13 5,0 10,0", class: "s14" }], ["path", { d: "m 0,20 1,0 C 2,13 5,0 10,0", class: "s1" }], ["path", { d: "M 0,0 10,0", class: "s1" }]], ["g", { id: "vmz-9" }, ["path", { d: "M 0,0 1,0 C 3,6 7,10 10,10 7,10 3,14 1,20 L 0,20", class: "s14" }], ["path", { d: "m 0,0 1,0 c 2,6 6,10 9,10", class: "s1" }], ["path", { d: "m 0,20 1,0 C 3,14 7,10 10,10", class: "s1" }]], ["g", { id: "vmv-2-2" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s7" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s7" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-3-2" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s7" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s8" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-4-2" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s7" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s9" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-5-2" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s7" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s10" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-6-2" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s7" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s11" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-7-2" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s7" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s12" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-8-2" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s7" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s13" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-9-2" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s7" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s14" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-2-3" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s8" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s7" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-3-3" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s8" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s8" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-4-3" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s8" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s9" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-5-3" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s8" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s10" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-6-3" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s8" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s11" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-7-3" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s8" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s12" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-8-3" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s8" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s13" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-9-3" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s8" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s14" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-2-4" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s9" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s7" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-3-4" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s9" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s8" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-4-4" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s9" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s9" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-5-4" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s9" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s10" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-6-4" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s9" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s11" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-7-4" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s9" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s12" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-8-4" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s9" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s13" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-9-4" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s9" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s14" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-2-5" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s10" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s7" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-3-5" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s10" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s8" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-4-5" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s10" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s9" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-5-5" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s10" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s10" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-6-5" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s10" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s11" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-7-5" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s10" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s12" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-8-5" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s10" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s13" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-9-5" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s10" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s14" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-2-6" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s11" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s7" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-3-6" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s11" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s8" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-4-6" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s11" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s9" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-5-6" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s11" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s10" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-6-6" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s11" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s11" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-7-6" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s11" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s12" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-8-6" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s11" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s13" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-9-6" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s11" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s14" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-2-7" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s12" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s7" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-3-7" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s12" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s8" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-4-7" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s12" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s9" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-5-7" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s12" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s10" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-6-7" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s12" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s11" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-7-7" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s12" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s12" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-8-7" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s12" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s13" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-9-7" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s12" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s14" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-2-8" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s13" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s7" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-3-8" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s13" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s8" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-4-8" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s13" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s9" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-5-8" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s13" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s10" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-6-8" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s13" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s11" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-7-8" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s13" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s12" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-8-8" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s13" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s13" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-9-8" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s13" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s14" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-2-9" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s14" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s7" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-3-9" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s14" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s8" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-4-9" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s14" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s9" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-5-9" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s14" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s10" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-6-9" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s14" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s11" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-7-9" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s14" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s12" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-8-9" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s14" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s13" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["g", { id: "vmv-9-9" }, ["path", { d: "M 7,0 10,0 10,20 7,20 4,10 z", class: "s14" }], ["path", { d: "M 1,0 0,0 0,20 1,20 4,10 z", class: "s14" }], ["path", { d: "m 0,0 1,0 6,20 3,0", class: "s1" }], ["path", { d: "M 0,20 1,20 7,0 10,0", class: "s1" }]], ["marker", { id: "arrowhead", style: "fill:#0041c4", markerHeight: 7, markerWidth: 10, markerUnits: "strokeWidth", viewBox: "0 -4 11 8", refX: 15, refY: 0, orient: "auto" }, ["path", { d: "M0 -4 11 0 0 4z" }]], ["marker", { id: "arrowtail", style: "fill:#0041c4", markerHeight: 7, markerWidth: 10, markerUnits: "strokeWidth", viewBox: "-11 -4 11 8", refX: -15, refY: 0, orient: "auto" }, ["path", { d: "M0 -4 -11 0 0 4z" }]], ["marker", { id: "tee", style: "fill:#0041c4", markerHeight: 6, markerWidth: 1, markerUnits: "strokeWidth", viewBox: "0 0 1 6", refX: 0, refY: 3, orient: "auto" }, ["path", { d: "M 0 0 L 0 6", style: "stroke:#0041c4;stroke-width:2" }]]], ["g", { id: "waves" }, ["g", { id: "lanes" }], ["g", { id: "groups" }]]];
try {
  narrow$1.exports = WaveSkin$1;
} catch (err) {
}
var narrowExports = narrow$1.exports;
const narrow = /* @__PURE__ */ getDefaultExportFromCjs(narrowExports);
var lowkey$1 = { exports: {} };
var WaveSkin = WaveSkin || {};
WaveSkin.lowkey = ["svg", { id: "svg", xmlns: "http://www.w3.org/2000/svg", "xmlns:xlink": "http://www.w3.org/1999/xlink", height: "0" }, ["style", { type: "text/css" }, "text{font-size:11pt;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-align:center;fill-opacity:1;font-family:Helvetica}.h1{font-size:33pt;font-weight:bold}.h2{font-size:27pt;font-weight:bold}.h3{font-size:20pt;font-weight:bold}.h4{font-size:14pt;font-weight:bold}.h5{font-size:11pt;font-weight:bold}.h6{font-size:8pt;font-weight:bold}.muted{fill:#aaa}.warning{fill:#f6b900}.error{fill:#f60000}.info{fill:#0041c4}.success{fill:#00ab00}.s1{fill:none;stroke:#606060;stroke-width:0.75px;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none}.s2{fill:none;stroke:#606060;stroke-width:0.5;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none}.s3{color:#000;fill:none;stroke:#606060;stroke-width:0.75px;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:1, 3;stroke-dashoffset:0;marker:none;visibility:visible;display:inline;overflow:visible}.s4{color:#000;fill:none;stroke:#606060;stroke-width:0.75px;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none;stroke-dashoffset:0;marker:none;visibility:visible;display:inline;overflow:visible}.s5{fill:#ffffff;stroke:none}.s6{fill:#606060;fill-opacity:1;stroke:none}.s7{color:#000;fill:#fff;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.25px;marker:none;visibility:visible;display:inline;overflow:visible}.s8{color:#000;fill:#eaeaea;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.25px;marker:none;visibility:visible;display:inline;overflow:visible}.s9{color:#000;fill:#d7d7d7;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.25px;marker:none;visibility:visible;display:inline;overflow:visible}.s10{color:#000;fill:#c0c0c0;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.25px;marker:none;visibility:visible;display:inline;overflow:visible}.s11{color:#000;fill:#b0b0b0;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.25px;marker:none;visibility:visible;display:inline;overflow:visible}.s12{color:#000;fill:#a0a0a0;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.25px;marker:none;visibility:visible;display:inline;overflow:visible}.s13{color:#000;fill:#909090;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.25px;marker:none;visibility:visible;display:inline;overflow:visible}.s14{color:#000;fill:#808080;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.25px;marker:none;visibility:visible;display:inline;overflow:visible}.s15{fill:#0041c4;fill-opacity:1;stroke:none}.s16{fill:none;stroke:#0041c4;stroke-width:0.75px;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none}"], ["defs", ["g", { id: "socket" }, ["rect", { y: "15", x: "6", height: "20", width: "20", style: "fill:#606060;stroke:#606060;stroke-width:0.5" }]], ["g", { id: "pclk" }, ["path", { d: "M0,20 0,0 20,0", class: "s1" }]], ["g", { id: "nclk" }, ["path", { d: "m0,0 0,20 20,0", class: "s1" }]], ["g", { id: "000" }, ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "0m0" }, ["path", { d: "m0,20 3,0 3,-10 3,10 11,0", class: "s1" }]], ["g", { id: "0m1" }, ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "0mx" }, ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m20,15 -5,5", class: "s2" }], ["path", { d: "M20,10 10,20", class: "s2" }], ["path", { d: "M20,5 5,20", class: "s2" }], ["path", { d: "M20,0 4,16", class: "s2" }], ["path", { d: "M15,0 6,9", class: "s2" }], ["path", { d: "M10,0 9,1", class: "s2" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "0md" }, ["path", { d: "m8,20 10,0", class: "s3" }], ["path", { d: "m0,20 5,0", class: "s1" }]], ["g", { id: "0mu" }, ["path", { d: "m0,20 3,0 C 7,10 10.107603,0 20,0", class: "s1" }]], ["g", { id: "0mz" }, ["path", { d: "m0,20 3,0 C 10,10 15,10 20,10", class: "s1" }]], ["g", { id: "111" }, ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "1m0" }, ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }]], ["g", { id: "1m1" }, ["path", { d: "M0,0 3,0 6,10 9,0 20,0", class: "s1" }]], ["g", { id: "1mx" }, ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }], ["path", { d: "m20,15 -5,5", class: "s2" }], ["path", { d: "M20,10 10,20", class: "s2" }], ["path", { d: "M20,5 8,17", class: "s2" }], ["path", { d: "M20,0 7,13", class: "s2" }], ["path", { d: "M15,0 6,9", class: "s2" }], ["path", { d: "M10,0 5,5", class: "s2" }], ["path", { d: "M3.5,1.5 5,0", class: "s2" }]], ["g", { id: "1md" }, ["path", { d: "m0,0 3,0 c 4,10 7,20 17,20", class: "s1" }]], ["g", { id: "1mu" }, ["path", { d: "M0,0 5,0", class: "s1" }], ["path", { d: "M8,0 18,0", class: "s3" }]], ["g", { id: "1mz" }, ["path", { d: "m0,0 3,0 c 7,10 12,10 17,10", class: "s1" }]], ["g", { id: "xxx" }, ["path", { d: "m0,20 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }], ["path", { d: "M0,5 5,0", class: "s2" }], ["path", { d: "M0,10 10,0", class: "s2" }], ["path", { d: "M0,15 15,0", class: "s2" }], ["path", { d: "M0,20 20,0", class: "s2" }], ["path", { d: "M5,20 20,5", class: "s2" }], ["path", { d: "M10,20 20,10", class: "s2" }], ["path", { d: "m15,20 5,-5", class: "s2" }]], ["g", { id: "xm0" }, ["path", { d: "M0,0 4,0 9,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }], ["path", { d: "M0,5 4,1", class: "s2" }], ["path", { d: "M0,10 5,5", class: "s2" }], ["path", { d: "M0,15 6,9", class: "s2" }], ["path", { d: "M0,20 7,13", class: "s2" }], ["path", { d: "M5,20 8,17", class: "s2" }]], ["g", { id: "xm1" }, ["path", { d: "M0,0 20,0", class: "s1" }], ["path", { d: "M0,20 4,20 9,0", class: "s1" }], ["path", { d: "M0,5 5,0", class: "s2" }], ["path", { d: "M0,10 9,1", class: "s2" }], ["path", { d: "M0,15 7,8", class: "s2" }], ["path", { d: "M0,20 5,15", class: "s2" }]], ["g", { id: "xmx" }, ["path", { d: "m0,20 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }], ["path", { d: "M0,5 5,0", class: "s2" }], ["path", { d: "M0,10 10,0", class: "s2" }], ["path", { d: "M0,15 15,0", class: "s2" }], ["path", { d: "M0,20 20,0", class: "s2" }], ["path", { d: "M5,20 20,5", class: "s2" }], ["path", { d: "M10,20 20,10", class: "s2" }], ["path", { d: "m15,20 5,-5", class: "s2" }]], ["g", { id: "xmd" }, ["path", { d: "m0,0 4,0 c 3,10 6,20 16,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }], ["path", { d: "M0,5 4,1", class: "s2" }], ["path", { d: "M0,10 5.5,4.5", class: "s2" }], ["path", { d: "M0,15 6.5,8.5", class: "s2" }], ["path", { d: "M0,20 8,12", class: "s2" }], ["path", { d: "m5,20 5,-5", class: "s2" }], ["path", { d: "m10,20 2.5,-2.5", class: "s2" }]], ["g", { id: "xmu" }, ["path", { d: "M0,0 20,0", class: "s1" }], ["path", { d: "m0,20 4,0 C 7,10 10,0 20,0", class: "s1" }], ["path", { d: "M0,5 5,0", class: "s2" }], ["path", { d: "M0,10 10,0", class: "s2" }], ["path", { d: "M0,15 10,5", class: "s2" }], ["path", { d: "M0,20 6,14", class: "s2" }]], ["g", { id: "xmz" }, ["path", { d: "m0,0 4,0 c 6,10 11,10 16,10", class: "s1" }], ["path", { d: "m0,20 4,0 C 10,10 15,10 20,10", class: "s1" }], ["path", { d: "M0,5 4.5,0.5", class: "s2" }], ["path", { d: "M0,10 6.5,3.5", class: "s2" }], ["path", { d: "M0,15 8.5,6.5", class: "s2" }], ["path", { d: "M0,20 11.5,8.5", class: "s2" }]], ["g", { id: "ddd" }, ["path", { d: "m0,20 20,0", class: "s3" }]], ["g", { id: "dm0" }, ["path", { d: "m0,20 10,0", class: "s3" }], ["path", { d: "m12,20 8,0", class: "s1" }]], ["g", { id: "dm1" }, ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "dmx" }, ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m20,15 -5,5", class: "s2" }], ["path", { d: "M20,10 10,20", class: "s2" }], ["path", { d: "M20,5 5,20", class: "s2" }], ["path", { d: "M20,0 4,16", class: "s2" }], ["path", { d: "M15,0 6,9", class: "s2" }], ["path", { d: "M10,0 9,1", class: "s2" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "dmd" }, ["path", { d: "m0,20 20,0", class: "s3" }]], ["g", { id: "dmu" }, ["path", { d: "m0,20 3,0 C 7,10 10.107603,0 20,0", class: "s1" }]], ["g", { id: "dmz" }, ["path", { d: "m0,20 3,0 C 10,10 15,10 20,10", class: "s1" }]], ["g", { id: "uuu" }, ["path", { d: "M0,0 20,0", class: "s3" }]], ["g", { id: "um0" }, ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }]], ["g", { id: "um1" }, ["path", { d: "M0,0 10,0", class: "s3" }], ["path", { d: "m12,0 8,0", class: "s1" }]], ["g", { id: "umx" }, ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }], ["path", { d: "m20,15 -5,5", class: "s2" }], ["path", { d: "M20,10 10,20", class: "s2" }], ["path", { d: "M20,5 8,17", class: "s2" }], ["path", { d: "M20,0 7,13", class: "s2" }], ["path", { d: "M15,0 6,9", class: "s2" }], ["path", { d: "M10,0 5,5", class: "s2" }], ["path", { d: "M3.5,1.5 5,0", class: "s2" }]], ["g", { id: "umd" }, ["path", { d: "m0,0 3,0 c 4,10 7,20 17,20", class: "s1" }]], ["g", { id: "umu" }, ["path", { d: "M0,0 20,0", class: "s3" }]], ["g", { id: "umz" }, ["path", { d: "m0,0 3,0 c 7,10 12,10 17,10", class: "s4" }]], ["g", { id: "zzz" }, ["path", { d: "m0,10 20,0", class: "s1" }]], ["g", { id: "zm0" }, ["path", { d: "m0,10 6,0 3,10 11,0", class: "s1" }]], ["g", { id: "zm1" }, ["path", { d: "M0,10 6,10 9,0 20,0", class: "s1" }]], ["g", { id: "zmx" }, ["path", { d: "m6,10 3,10 11,0", class: "s1" }], ["path", { d: "M0,10 6,10 9,0 20,0", class: "s1" }], ["path", { d: "m20,15 -5,5", class: "s2" }], ["path", { d: "M20,10 10,20", class: "s2" }], ["path", { d: "M20,5 8,17", class: "s2" }], ["path", { d: "M20,0 7,13", class: "s2" }], ["path", { d: "M15,0 6.5,8.5", class: "s2" }], ["path", { d: "M10,0 9,1", class: "s2" }]], ["g", { id: "zmd" }, ["path", { d: "m0,10 7,0 c 3,5 8,10 13,10", class: "s1" }]], ["g", { id: "zmu" }, ["path", { d: "m0,10 7,0 C 10,5 15,0 20,0", class: "s1" }]], ["g", { id: "zmz" }, ["path", { d: "m0,10 20,0", class: "s1" }]], ["g", { id: "gap" }, ["path", { d: "m7,-2 -4,0 c -5,0 -5,24 -10,24 l 4,0 C 2,22 2,-2 7,-2 z", class: "s5" }], ["path", { d: "M-7,22 C -2,22 -2,-2 3,-2", class: "s1" }], ["path", { d: "M-3,22 C 2,22 2,-2 7,-2", class: "s1" }]], ["g", { id: "Pclk" }, ["path", { d: "M-3,12 0,3 3,12 C 1,11 -1,11 -3,12 z", class: "s6" }], ["path", { d: "M0,20 0,0 20,0", class: "s1" }]], ["g", { id: "Nclk" }, ["path", { d: "M-3,8 0,17 3,8 C 1,9 -1,9 -3,8 z", class: "s6" }], ["path", { d: "m0,0 0,20 20,0", class: "s1" }]], ["g", { id: "0mv-2" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s7" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "1mv-2" }, ["path", { d: "M2.875,0 20,0 20,20 9,20 z", class: "s7" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "xmv-2" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s7" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,5 3.5,1.5", class: "s2" }], ["path", { d: "M0,10 4.5,5.5", class: "s2" }], ["path", { d: "M0,15 6,9", class: "s2" }], ["path", { d: "M0,20 4,16", class: "s2" }]], ["g", { id: "dmv-2" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s7" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "umv-2" }, ["path", { d: "M3,0 20,0 20,20 9,20 z", class: "s7" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "zmv-2" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s7" }], ["path", { d: "m6,10 3,10 11,0", class: "s1" }], ["path", { d: "M0,10 6,10 9,0 20,0", class: "s1" }]], ["g", { id: "vvv-2" }, ["path", { d: "M20,20 0,20 0,0 20,0", class: "s7" }], ["path", { d: "m0,20 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vm0-2" }, ["path", { d: "M0,20 0,0 3,0 9,20", class: "s7" }], ["path", { d: "M0,0 3,0 9,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vm1-2" }, ["path", { d: "M0,0 0,20 3,20 9,0", class: "s7" }], ["path", { d: "M0,0 20,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0", class: "s1" }]], ["g", { id: "vmx-2" }, ["path", { d: "M0,0 0,20 3,20 6,10 3,0", class: "s7" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m20,15 -5,5", class: "s2" }], ["path", { d: "M20,10 10,20", class: "s2" }], ["path", { d: "M20,5 8,17", class: "s2" }], ["path", { d: "M20,0 7,13", class: "s2" }], ["path", { d: "M15,0 7,8", class: "s2" }], ["path", { d: "M10,0 9,1", class: "s2" }]], ["g", { id: "vmd-2" }, ["path", { d: "m0,0 0,20 20,0 C 10,20 7,10 3,0", class: "s7" }], ["path", { d: "m0,0 3,0 c 4,10 7,20 17,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vmu-2" }, ["path", { d: "m0,0 0,20 3,0 C 7,10 10,0 20,0", class: "s7" }], ["path", { d: "m0,20 3,0 C 7,10 10,0 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vmz-2" }, ["path", { d: "M0,0 3,0 C 10,10 15,10 20,10 15,10 10,10 3,20 L 0,20", class: "s7" }], ["path", { d: "m0,0 3,0 c 7,10 12,10 17,10", class: "s1" }], ["path", { d: "m0,20 3,0 C 10,10 15,10 20,10", class: "s1" }]], ["g", { id: "0mv-3" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s8" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "1mv-3" }, ["path", { d: "M2.875,0 20,0 20,20 9,20 z", class: "s8" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "xmv-3" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s8" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,5 3.5,1.5", class: "s2" }], ["path", { d: "M0,10 4.5,5.5", class: "s2" }], ["path", { d: "M0,15 6,9", class: "s2" }], ["path", { d: "M0,20 4,16", class: "s2" }]], ["g", { id: "dmv-3" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s8" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "umv-3" }, ["path", { d: "M3,0 20,0 20,20 9,20 z", class: "s8" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "zmv-3" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s8" }], ["path", { d: "m6,10 3,10 11,0", class: "s1" }], ["path", { d: "M0,10 6,10 9,0 20,0", class: "s1" }]], ["g", { id: "vvv-3" }, ["path", { d: "M20,20 0,20 0,0 20,0", class: "s8" }], ["path", { d: "m0,20 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vm0-3" }, ["path", { d: "M0,20 0,0 3,0 9,20", class: "s8" }], ["path", { d: "M0,0 3,0 9,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vm1-3" }, ["path", { d: "M0,0 0,20 3,20 9,0", class: "s8" }], ["path", { d: "M0,0 20,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0", class: "s1" }]], ["g", { id: "vmx-3" }, ["path", { d: "M0,0 0,20 3,20 6,10 3,0", class: "s8" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m20,15 -5,5", class: "s2" }], ["path", { d: "M20,10 10,20", class: "s2" }], ["path", { d: "M20,5 8,17", class: "s2" }], ["path", { d: "M20,0 7,13", class: "s2" }], ["path", { d: "M15,0 7,8", class: "s2" }], ["path", { d: "M10,0 9,1", class: "s2" }]], ["g", { id: "vmd-3" }, ["path", { d: "m0,0 0,20 20,0 C 10,20 7,10 3,0", class: "s8" }], ["path", { d: "m0,0 3,0 c 4,10 7,20 17,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vmu-3" }, ["path", { d: "m0,0 0,20 3,0 C 7,10 10,0 20,0", class: "s8" }], ["path", { d: "m0,20 3,0 C 7,10 10,0 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vmz-3" }, ["path", { d: "M0,0 3,0 C 10,10 15,10 20,10 15,10 10,10 3,20 L 0,20", class: "s8" }], ["path", { d: "m0,0 3,0 c 7,10 12,10 17,10", class: "s1" }], ["path", { d: "m0,20 3,0 C 10,10 15,10 20,10", class: "s1" }]], ["g", { id: "0mv-4" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s9" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "1mv-4" }, ["path", { d: "M2.875,0 20,0 20,20 9,20 z", class: "s9" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "xmv-4" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s9" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,5 3.5,1.5", class: "s2" }], ["path", { d: "M0,10 4.5,5.5", class: "s2" }], ["path", { d: "M0,15 6,9", class: "s2" }], ["path", { d: "M0,20 4,16", class: "s2" }]], ["g", { id: "dmv-4" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s9" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "umv-4" }, ["path", { d: "M3,0 20,0 20,20 9,20 z", class: "s9" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "zmv-4" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s9" }], ["path", { d: "m6,10 3,10 11,0", class: "s1" }], ["path", { d: "M0,10 6,10 9,0 20,0", class: "s1" }]], ["g", { id: "vvv-4" }, ["path", { d: "M20,20 0,20 0,0 20,0", class: "s9" }], ["path", { d: "m0,20 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vm0-4" }, ["path", { d: "M0,20 0,0 3,0 9,20", class: "s9" }], ["path", { d: "M0,0 3,0 9,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vm1-4" }, ["path", { d: "M0,0 0,20 3,20 9,0", class: "s9" }], ["path", { d: "M0,0 20,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0", class: "s1" }]], ["g", { id: "vmx-4" }, ["path", { d: "M0,0 0,20 3,20 6,10 3,0", class: "s9" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m20,15 -5,5", class: "s2" }], ["path", { d: "M20,10 10,20", class: "s2" }], ["path", { d: "M20,5 8,17", class: "s2" }], ["path", { d: "M20,0 7,13", class: "s2" }], ["path", { d: "M15,0 7,8", class: "s2" }], ["path", { d: "M10,0 9,1", class: "s2" }]], ["g", { id: "vmd-4" }, ["path", { d: "m0,0 0,20 20,0 C 10,20 7,10 3,0", class: "s9" }], ["path", { d: "m0,0 3,0 c 4,10 7,20 17,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vmu-4" }, ["path", { d: "m0,0 0,20 3,0 C 7,10 10,0 20,0", class: "s9" }], ["path", { d: "m0,20 3,0 C 7,10 10,0 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vmz-4" }, ["path", { d: "M0,0 3,0 C 10,10 15,10 20,10 15,10 10,10 3,20 L 0,20", class: "s9" }], ["path", { d: "m0,0 3,0 c 7,10 12,10 17,10", class: "s1" }], ["path", { d: "m0,20 3,0 C 10,10 15,10 20,10", class: "s1" }]], ["g", { id: "0mv-5" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s10" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "1mv-5" }, ["path", { d: "M2.875,0 20,0 20,20 9,20 z", class: "s10" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "xmv-5" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s10" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,5 3.5,1.5", class: "s2" }], ["path", { d: "M0,10 4.5,5.5", class: "s2" }], ["path", { d: "M0,15 6,9", class: "s2" }], ["path", { d: "M0,20 4,16", class: "s2" }]], ["g", { id: "dmv-5" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s10" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "umv-5" }, ["path", { d: "M3,0 20,0 20,20 9,20 z", class: "s10" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "zmv-5" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s10" }], ["path", { d: "m6,10 3,10 11,0", class: "s1" }], ["path", { d: "M0,10 6,10 9,0 20,0", class: "s1" }]], ["g", { id: "vvv-5" }, ["path", { d: "M20,20 0,20 0,0 20,0", class: "s10" }], ["path", { d: "m0,20 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vm0-5" }, ["path", { d: "M0,20 0,0 3,0 9,20", class: "s10" }], ["path", { d: "M0,0 3,0 9,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vm1-5" }, ["path", { d: "M0,0 0,20 3,20 9,0", class: "s10" }], ["path", { d: "M0,0 20,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0", class: "s1" }]], ["g", { id: "vmx-5" }, ["path", { d: "M0,0 0,20 3,20 6,10 3,0", class: "s10" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m20,15 -5,5", class: "s2" }], ["path", { d: "M20,10 10,20", class: "s2" }], ["path", { d: "M20,5 8,17", class: "s2" }], ["path", { d: "M20,0 7,13", class: "s2" }], ["path", { d: "M15,0 7,8", class: "s2" }], ["path", { d: "M10,0 9,1", class: "s2" }]], ["g", { id: "vmd-5" }, ["path", { d: "m0,0 0,20 20,0 C 10,20 7,10 3,0", class: "s10" }], ["path", { d: "m0,0 3,0 c 4,10 7,20 17,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vmu-5" }, ["path", { d: "m0,0 0,20 3,0 C 7,10 10,0 20,0", class: "s10" }], ["path", { d: "m0,20 3,0 C 7,10 10,0 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vmz-5" }, ["path", { d: "M0,0 3,0 C 10,10 15,10 20,10 15,10 10,10 3,20 L 0,20", class: "s10" }], ["path", { d: "m0,0 3,0 c 7,10 12,10 17,10", class: "s1" }], ["path", { d: "m0,20 3,0 C 10,10 15,10 20,10", class: "s1" }]], ["g", { id: "0mv-6" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s11" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "1mv-6" }, ["path", { d: "M2.875,0 20,0 20,20 9,20 z", class: "s11" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "xmv-6" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s11" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,5 3.5,1.5", class: "s2" }], ["path", { d: "M0,10 4.5,5.5", class: "s2" }], ["path", { d: "M0,15 6,9", class: "s2" }], ["path", { d: "M0,20 4,16", class: "s2" }]], ["g", { id: "dmv-6" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s11" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "umv-6" }, ["path", { d: "M3,0 20,0 20,20 9,20 z", class: "s11" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "zmv-6" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s11" }], ["path", { d: "m6,10 3,10 11,0", class: "s1" }], ["path", { d: "M0,10 6,10 9,0 20,0", class: "s1" }]], ["g", { id: "vvv-6" }, ["path", { d: "M20,20 0,20 0,0 20,0", class: "s11" }], ["path", { d: "m0,20 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vm0-6" }, ["path", { d: "M0,20 0,0 3,0 9,20", class: "s11" }], ["path", { d: "M0,0 3,0 9,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vm1-6" }, ["path", { d: "M0,0 0,20 3,20 9,0", class: "s11" }], ["path", { d: "M0,0 20,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0", class: "s1" }]], ["g", { id: "vmx-6" }, ["path", { d: "M0,0 0,20 3,20 6,10 3,0", class: "s11" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m20,15 -5,5", class: "s2" }], ["path", { d: "M20,10 10,20", class: "s2" }], ["path", { d: "M20,5 8,17", class: "s2" }], ["path", { d: "M20,0 7,13", class: "s2" }], ["path", { d: "M15,0 7,8", class: "s2" }], ["path", { d: "M10,0 9,1", class: "s2" }]], ["g", { id: "vmd-6" }, ["path", { d: "m0,0 0,20 20,0 C 10,20 7,10 3,0", class: "s11" }], ["path", { d: "m0,0 3,0 c 4,10 7,20 17,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vmu-6" }, ["path", { d: "m0,0 0,20 3,0 C 7,10 10,0 20,0", class: "s11" }], ["path", { d: "m0,20 3,0 C 7,10 10,0 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vmz-6" }, ["path", { d: "M0,0 3,0 C 10,10 15,10 20,10 15,10 10,10 3,20 L 0,20", class: "s11" }], ["path", { d: "m0,0 3,0 c 7,10 12,10 17,10", class: "s1" }], ["path", { d: "m0,20 3,0 C 10,10 15,10 20,10", class: "s1" }]], ["g", { id: "0mv-7" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s12" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "1mv-7" }, ["path", { d: "M2.875,0 20,0 20,20 9,20 z", class: "s12" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "xmv-7" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s12" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,5 3.5,1.5", class: "s2" }], ["path", { d: "M0,10 4.5,5.5", class: "s2" }], ["path", { d: "M0,15 6,9", class: "s2" }], ["path", { d: "M0,20 4,16", class: "s2" }]], ["g", { id: "dmv-7" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s12" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "umv-7" }, ["path", { d: "M3,0 20,0 20,20 9,20 z", class: "s12" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "zmv-7" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s12" }], ["path", { d: "m6,10 3,10 11,0", class: "s1" }], ["path", { d: "M0,10 6,10 9,0 20,0", class: "s1" }]], ["g", { id: "vvv-7" }, ["path", { d: "M20,20 0,20 0,0 20,0", class: "s12" }], ["path", { d: "m0,20 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vm0-7" }, ["path", { d: "M0,20 0,0 3,0 9,20", class: "s12" }], ["path", { d: "M0,0 3,0 9,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vm1-7" }, ["path", { d: "M0,0 0,20 3,20 9,0", class: "s12" }], ["path", { d: "M0,0 20,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0", class: "s1" }]], ["g", { id: "vmx-7" }, ["path", { d: "M0,0 0,20 3,20 6,10 3,0", class: "s12" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m20,15 -5,5", class: "s2" }], ["path", { d: "M20,10 10,20", class: "s2" }], ["path", { d: "M20,5 8,17", class: "s2" }], ["path", { d: "M20,0 7,13", class: "s2" }], ["path", { d: "M15,0 7,8", class: "s2" }], ["path", { d: "M10,0 9,1", class: "s2" }]], ["g", { id: "vmd-7" }, ["path", { d: "m0,0 0,20 20,0 C 10,20 7,10 3,0", class: "s12" }], ["path", { d: "m0,0 3,0 c 4,10 7,20 17,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vmu-7" }, ["path", { d: "m0,0 0,20 3,0 C 7,10 10,0 20,0", class: "s12" }], ["path", { d: "m0,20 3,0 C 7,10 10,0 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vmz-7" }, ["path", { d: "M0,0 3,0 C 10,10 15,10 20,10 15,10 10,10 3,20 L 0,20", class: "s12" }], ["path", { d: "m0,0 3,0 c 7,10 12,10 17,10", class: "s1" }], ["path", { d: "m0,20 3,0 C 10,10 15,10 20,10", class: "s1" }]], ["g", { id: "0mv-8" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s13" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "1mv-8" }, ["path", { d: "M2.875,0 20,0 20,20 9,20 z", class: "s13" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "xmv-8" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s13" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,5 3.5,1.5", class: "s2" }], ["path", { d: "M0,10 4.5,5.5", class: "s2" }], ["path", { d: "M0,15 6,9", class: "s2" }], ["path", { d: "M0,20 4,16", class: "s2" }]], ["g", { id: "dmv-8" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s13" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "umv-8" }, ["path", { d: "M3,0 20,0 20,20 9,20 z", class: "s13" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "zmv-8" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s13" }], ["path", { d: "m6,10 3,10 11,0", class: "s1" }], ["path", { d: "M0,10 6,10 9,0 20,0", class: "s1" }]], ["g", { id: "vvv-8" }, ["path", { d: "M20,20 0,20 0,0 20,0", class: "s13" }], ["path", { d: "m0,20 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vm0-8" }, ["path", { d: "M0,20 0,0 3,0 9,20", class: "s13" }], ["path", { d: "M0,0 3,0 9,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vm1-8" }, ["path", { d: "M0,0 0,20 3,20 9,0", class: "s13" }], ["path", { d: "M0,0 20,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0", class: "s1" }]], ["g", { id: "vmx-8" }, ["path", { d: "M0,0 0,20 3,20 6,10 3,0", class: "s13" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m20,15 -5,5", class: "s2" }], ["path", { d: "M20,10 10,20", class: "s2" }], ["path", { d: "M20,5 8,17", class: "s2" }], ["path", { d: "M20,0 7,13", class: "s2" }], ["path", { d: "M15,0 7,8", class: "s2" }], ["path", { d: "M10,0 9,1", class: "s2" }]], ["g", { id: "vmd-8" }, ["path", { d: "m0,0 0,20 20,0 C 10,20 7,10 3,0", class: "s13" }], ["path", { d: "m0,0 3,0 c 4,10 7,20 17,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vmu-8" }, ["path", { d: "m0,0 0,20 3,0 C 7,10 10,0 20,0", class: "s13" }], ["path", { d: "m0,20 3,0 C 7,10 10,0 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vmz-8" }, ["path", { d: "M0,0 3,0 C 10,10 15,10 20,10 15,10 10,10 3,20 L 0,20", class: "s13" }], ["path", { d: "m0,0 3,0 c 7,10 12,10 17,10", class: "s1" }], ["path", { d: "m0,20 3,0 C 10,10 15,10 20,10", class: "s1" }]], ["g", { id: "0mv-9" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s14" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "1mv-9" }, ["path", { d: "M2.875,0 20,0 20,20 9,20 z", class: "s14" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "xmv-9" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s14" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,5 3.5,1.5", class: "s2" }], ["path", { d: "M0,10 4.5,5.5", class: "s2" }], ["path", { d: "M0,15 6,9", class: "s2" }], ["path", { d: "M0,20 4,16", class: "s2" }]], ["g", { id: "dmv-9" }, ["path", { d: "M9,0 20,0 20,20 3,20 z", class: "s14" }], ["path", { d: "M3,20 9,0 20,0", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "umv-9" }, ["path", { d: "M3,0 20,0 20,20 9,20 z", class: "s14" }], ["path", { d: "m3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "zmv-9" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s14" }], ["path", { d: "m6,10 3,10 11,0", class: "s1" }], ["path", { d: "M0,10 6,10 9,0 20,0", class: "s1" }]], ["g", { id: "vvv-9" }, ["path", { d: "M20,20 0,20 0,0 20,0", class: "s14" }], ["path", { d: "m0,20 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vm0-9" }, ["path", { d: "M0,20 0,0 3,0 9,20", class: "s14" }], ["path", { d: "M0,0 3,0 9,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vm1-9" }, ["path", { d: "M0,0 0,20 3,20 9,0", class: "s14" }], ["path", { d: "M0,0 20,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0", class: "s1" }]], ["g", { id: "vmx-9" }, ["path", { d: "M0,0 0,20 3,20 6,10 3,0", class: "s14" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }], ["path", { d: "m20,15 -5,5", class: "s2" }], ["path", { d: "M20,10 10,20", class: "s2" }], ["path", { d: "M20,5 8,17", class: "s2" }], ["path", { d: "M20,0 7,13", class: "s2" }], ["path", { d: "M15,0 7,8", class: "s2" }], ["path", { d: "M10,0 9,1", class: "s2" }]], ["g", { id: "vmd-9" }, ["path", { d: "m0,0 0,20 20,0 C 10,20 7,10 3,0", class: "s14" }], ["path", { d: "m0,0 3,0 c 4,10 7,20 17,20", class: "s1" }], ["path", { d: "m0,20 20,0", class: "s1" }]], ["g", { id: "vmu-9" }, ["path", { d: "m0,0 0,20 3,0 C 7,10 10,0 20,0", class: "s14" }], ["path", { d: "m0,20 3,0 C 7,10 10,0 20,0", class: "s1" }], ["path", { d: "M0,0 20,0", class: "s1" }]], ["g", { id: "vmz-9" }, ["path", { d: "M0,0 3,0 C 10,10 15,10 20,10 15,10 10,10 3,20 L 0,20", class: "s14" }], ["path", { d: "m0,0 3,0 c 7,10 12,10 17,10", class: "s1" }], ["path", { d: "m0,20 3,0 C 10,10 15,10 20,10", class: "s1" }]], ["g", { id: "vmv-2-2" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s7" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s7" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-3-2" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s7" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s8" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-4-2" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s7" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s9" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-5-2" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s7" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s10" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-6-2" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s7" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s11" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-7-2" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s7" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s12" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-8-2" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s7" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s13" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-9-2" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s7" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s14" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-2-3" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s8" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s7" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-3-3" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s8" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s8" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-4-3" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s8" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s9" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-5-3" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s8" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s10" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-6-3" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s8" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s11" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-7-3" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s8" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s12" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-8-3" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s8" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s13" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-9-3" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s8" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s14" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-2-4" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s9" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s7" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-3-4" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s9" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s8" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-4-4" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s9" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s9" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-5-4" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s9" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s10" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-6-4" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s9" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s11" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-7-4" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s9" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s12" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-8-4" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s9" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s13" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-9-4" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s9" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s14" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-2-5" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s10" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s7" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-3-5" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s10" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s8" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-4-5" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s10" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s9" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-5-5" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s10" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s10" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-6-5" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s10" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s11" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-7-5" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s10" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s12" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-8-5" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s10" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s13" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-9-5" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s10" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s14" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-2-6" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s11" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s7" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-3-6" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s11" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s8" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-4-6" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s11" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s9" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-5-6" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s11" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s10" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-6-6" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s11" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s11" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-7-6" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s11" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s12" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-8-6" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s11" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s13" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-9-6" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s11" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s14" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-2-7" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s12" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s7" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-3-7" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s12" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s8" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-4-7" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s12" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s9" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-5-7" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s12" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s10" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-6-7" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s12" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s11" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-7-7" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s12" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s12" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-8-7" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s12" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s13" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-9-7" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s12" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s14" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-2-8" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s13" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s7" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-3-8" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s13" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s8" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-4-8" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s13" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s9" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-5-8" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s13" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s10" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-6-8" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s13" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s11" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-7-8" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s13" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s12" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-8-8" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s13" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s13" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-9-8" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s13" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s14" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-2-9" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s14" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s7" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-3-9" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s14" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s8" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-4-9" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s14" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s9" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-5-9" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s14" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s10" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-6-9" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s14" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s11" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-7-9" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s14" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s12" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-8-9" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s14" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s13" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "vmv-9-9" }, ["path", { d: "M9,0 20,0 20,20 9,20 6,10 z", class: "s14" }], ["path", { d: "M3,0 0,0 0,20 3,20 6,10 z", class: "s14" }], ["path", { d: "m0,0 3,0 6,20 11,0", class: "s1" }], ["path", { d: "M0,20 3,20 9,0 20,0", class: "s1" }]], ["g", { id: "arrow0" }, ["path", { d: "m-12,-3 9,3 -9,3 c 1,-2 1,-4 0,-6 z", class: "s15" }], ["path", { d: "M0,0 -15,0", class: "s16" }]], ["marker", { id: "arrowhead", style: "fill:#0041c4", markerHeight: 7, markerWidth: 10, markerUnits: "strokeWidth", viewBox: "0 -4 11 8", refX: 15, refY: 0, orient: "auto" }, ["path", { d: "M0 -4 11 0 0 4z" }]], ["marker", { id: "arrowtail", style: "fill:#0041c4", markerHeight: 7, markerWidth: 10, markerUnits: "strokeWidth", viewBox: "-11 -4 11 8", refX: -15, refY: 0, orient: "auto" }, ["path", { d: "M0 -4 -11 0 0 4z" }]], ["marker", { id: "tee", style: "fill:#0041c4", markerHeight: 6, markerWidth: 1, markerUnits: "strokeWidth", viewBox: "0 0 1 6", refX: 0, refY: 3, orient: "auto" }, ["path", { d: "M 0 0 L 0 6", style: "stroke:#0041c4;stroke-width:2" }]]], ["g", { id: "waves" }, ["g", { id: "lanes" }], ["g", { id: "groups" }]]];
try {
  lowkey$1.exports = WaveSkin;
} catch (err) {
}
var lowkeyExports = lowkey$1.exports;
const lowkey = /* @__PURE__ */ getDefaultExportFromCjs(lowkeyExports);
var onml = {};
var sax = {};
const __viteBrowserExternal = {};
const __viteBrowserExternal$1 = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  default: __viteBrowserExternal
}, Symbol.toStringTag, { value: "Module" }));
const require$$1 = /* @__PURE__ */ getAugmentedNamespace(__viteBrowserExternal$1);
(function(exports) {
  (function(sax2) {
    sax2.parser = function(strict, opt) {
      return new SAXParser(strict, opt);
    };
    sax2.SAXParser = SAXParser;
    sax2.SAXStream = SAXStream;
    sax2.createStream = createStream;
    sax2.MAX_BUFFER_LENGTH = 64 * 1024;
    var buffers = [
      "comment",
      "sgmlDecl",
      "textNode",
      "tagName",
      "doctype",
      "procInstName",
      "procInstBody",
      "entity",
      "attribName",
      "attribValue",
      "cdata",
      "script"
    ];
    sax2.EVENTS = [
      "text",
      "processinginstruction",
      "sgmldeclaration",
      "doctype",
      "comment",
      "opentagstart",
      "attribute",
      "opentag",
      "closetag",
      "opencdata",
      "cdata",
      "closecdata",
      "error",
      "end",
      "ready",
      "script",
      "opennamespace",
      "closenamespace"
    ];
    function SAXParser(strict, opt) {
      if (!(this instanceof SAXParser)) {
        return new SAXParser(strict, opt);
      }
      var parser2 = this;
      clearBuffers(parser2);
      parser2.q = parser2.c = "";
      parser2.bufferCheckPosition = sax2.MAX_BUFFER_LENGTH;
      parser2.opt = opt || {};
      parser2.opt.lowercase = parser2.opt.lowercase || parser2.opt.lowercasetags;
      parser2.looseCase = parser2.opt.lowercase ? "toLowerCase" : "toUpperCase";
      parser2.tags = [];
      parser2.closed = parser2.closedRoot = parser2.sawRoot = false;
      parser2.tag = parser2.error = null;
      parser2.strict = !!strict;
      parser2.noscript = !!(strict || parser2.opt.noscript);
      parser2.state = S.BEGIN;
      parser2.strictEntities = parser2.opt.strictEntities;
      parser2.ENTITIES = parser2.strictEntities ? Object.create(sax2.XML_ENTITIES) : Object.create(sax2.ENTITIES);
      parser2.attribList = [];
      if (parser2.opt.xmlns) {
        parser2.ns = Object.create(rootNS);
      }
      parser2.trackPosition = parser2.opt.position !== false;
      if (parser2.trackPosition) {
        parser2.position = parser2.line = parser2.column = 0;
      }
      emit(parser2, "onready");
    }
    if (!Object.create) {
      Object.create = function(o) {
        function F() {
        }
        F.prototype = o;
        var newf = new F();
        return newf;
      };
    }
    if (!Object.keys) {
      Object.keys = function(o) {
        var a = [];
        for (var i in o)
          if (o.hasOwnProperty(i))
            a.push(i);
        return a;
      };
    }
    function checkBufferLength(parser2) {
      var maxAllowed = Math.max(sax2.MAX_BUFFER_LENGTH, 10);
      var maxActual = 0;
      for (var i = 0, l = buffers.length; i < l; i++) {
        var len = parser2[buffers[i]].length;
        if (len > maxAllowed) {
          switch (buffers[i]) {
            case "textNode":
              closeText(parser2);
              break;
            case "cdata":
              emitNode(parser2, "oncdata", parser2.cdata);
              parser2.cdata = "";
              break;
            case "script":
              emitNode(parser2, "onscript", parser2.script);
              parser2.script = "";
              break;
            default:
              error(parser2, "Max buffer length exceeded: " + buffers[i]);
          }
        }
        maxActual = Math.max(maxActual, len);
      }
      var m = sax2.MAX_BUFFER_LENGTH - maxActual;
      parser2.bufferCheckPosition = m + parser2.position;
    }
    function clearBuffers(parser2) {
      for (var i = 0, l = buffers.length; i < l; i++) {
        parser2[buffers[i]] = "";
      }
    }
    function flushBuffers(parser2) {
      closeText(parser2);
      if (parser2.cdata !== "") {
        emitNode(parser2, "oncdata", parser2.cdata);
        parser2.cdata = "";
      }
      if (parser2.script !== "") {
        emitNode(parser2, "onscript", parser2.script);
        parser2.script = "";
      }
    }
    SAXParser.prototype = {
      end: function() {
        end(this);
      },
      write,
      resume: function() {
        this.error = null;
        return this;
      },
      close: function() {
        return this.write(null);
      },
      flush: function() {
        flushBuffers(this);
      }
    };
    var Stream;
    try {
      Stream = require$$1.Stream;
    } catch (ex) {
      Stream = function() {
      };
    }
    if (!Stream)
      Stream = function() {
      };
    var streamWraps = sax2.EVENTS.filter(function(ev) {
      return ev !== "error" && ev !== "end";
    });
    function createStream(strict, opt) {
      return new SAXStream(strict, opt);
    }
    function SAXStream(strict, opt) {
      if (!(this instanceof SAXStream)) {
        return new SAXStream(strict, opt);
      }
      Stream.apply(this);
      this._parser = new SAXParser(strict, opt);
      this.writable = true;
      this.readable = true;
      var me = this;
      this._parser.onend = function() {
        me.emit("end");
      };
      this._parser.onerror = function(er) {
        me.emit("error", er);
        me._parser.error = null;
      };
      this._decoder = null;
      streamWraps.forEach(function(ev) {
        Object.defineProperty(me, "on" + ev, {
          get: function() {
            return me._parser["on" + ev];
          },
          set: function(h) {
            if (!h) {
              me.removeAllListeners(ev);
              me._parser["on" + ev] = h;
              return h;
            }
            me.on(ev, h);
          },
          enumerable: true,
          configurable: false
        });
      });
    }
    SAXStream.prototype = Object.create(Stream.prototype, {
      constructor: {
        value: SAXStream
      }
    });
    SAXStream.prototype.write = function(data) {
      if (typeof Buffer === "function" && typeof Buffer.isBuffer === "function" && Buffer.isBuffer(data)) {
        if (!this._decoder) {
          var SD = require$$1.StringDecoder;
          this._decoder = new SD("utf8");
        }
        data = this._decoder.write(data);
      }
      this._parser.write(data.toString());
      this.emit("data", data);
      return true;
    };
    SAXStream.prototype.end = function(chunk) {
      if (chunk && chunk.length) {
        this.write(chunk);
      }
      this._parser.end();
      return true;
    };
    SAXStream.prototype.on = function(ev, handler) {
      var me = this;
      if (!me._parser["on" + ev] && streamWraps.indexOf(ev) !== -1) {
        me._parser["on" + ev] = function() {
          var args = arguments.length === 1 ? [arguments[0]] : Array.apply(null, arguments);
          args.splice(0, 0, ev);
          me.emit.apply(me, args);
        };
      }
      return Stream.prototype.on.call(me, ev, handler);
    };
    var CDATA = "[CDATA[";
    var DOCTYPE = "DOCTYPE";
    var XML_NAMESPACE = "http://www.w3.org/XML/1998/namespace";
    var XMLNS_NAMESPACE = "http://www.w3.org/2000/xmlns/";
    var rootNS = { xml: XML_NAMESPACE, xmlns: XMLNS_NAMESPACE };
    var nameStart = /[:_A-Za-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02FF\u0370-\u037D\u037F-\u1FFF\u200C-\u200D\u2070-\u218F\u2C00-\u2FEF\u3001-\uD7FF\uF900-\uFDCF\uFDF0-\uFFFD]/;
    var nameBody = /[:_A-Za-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02FF\u0370-\u037D\u037F-\u1FFF\u200C-\u200D\u2070-\u218F\u2C00-\u2FEF\u3001-\uD7FF\uF900-\uFDCF\uFDF0-\uFFFD\u00B7\u0300-\u036F\u203F-\u2040.\d-]/;
    var entityStart = /[#:_A-Za-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02FF\u0370-\u037D\u037F-\u1FFF\u200C-\u200D\u2070-\u218F\u2C00-\u2FEF\u3001-\uD7FF\uF900-\uFDCF\uFDF0-\uFFFD]/;
    var entityBody = /[#:_A-Za-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02FF\u0370-\u037D\u037F-\u1FFF\u200C-\u200D\u2070-\u218F\u2C00-\u2FEF\u3001-\uD7FF\uF900-\uFDCF\uFDF0-\uFFFD\u00B7\u0300-\u036F\u203F-\u2040.\d-]/;
    function isWhitespace(c2) {
      return c2 === " " || c2 === "\n" || c2 === "\r" || c2 === "	";
    }
    function isQuote(c2) {
      return c2 === '"' || c2 === "'";
    }
    function isAttribEnd(c2) {
      return c2 === ">" || isWhitespace(c2);
    }
    function isMatch(regex, c2) {
      return regex.test(c2);
    }
    function notMatch(regex, c2) {
      return !isMatch(regex, c2);
    }
    var S = 0;
    sax2.STATE = {
      BEGIN: S++,
      // leading byte order mark or whitespace
      BEGIN_WHITESPACE: S++,
      // leading whitespace
      TEXT: S++,
      // general stuff
      TEXT_ENTITY: S++,
      // &amp and such.
      OPEN_WAKA: S++,
      // <
      SGML_DECL: S++,
      // <!BLARG
      SGML_DECL_QUOTED: S++,
      // <!BLARG foo "bar
      DOCTYPE: S++,
      // <!DOCTYPE
      DOCTYPE_QUOTED: S++,
      // <!DOCTYPE "//blah
      DOCTYPE_DTD: S++,
      // <!DOCTYPE "//blah" [ ...
      DOCTYPE_DTD_QUOTED: S++,
      // <!DOCTYPE "//blah" [ "foo
      COMMENT_STARTING: S++,
      // <!-
      COMMENT: S++,
      // <!--
      COMMENT_ENDING: S++,
      // <!-- blah -
      COMMENT_ENDED: S++,
      // <!-- blah --
      CDATA: S++,
      // <![CDATA[ something
      CDATA_ENDING: S++,
      // ]
      CDATA_ENDING_2: S++,
      // ]]
      PROC_INST: S++,
      // <?hi
      PROC_INST_BODY: S++,
      // <?hi there
      PROC_INST_ENDING: S++,
      // <?hi "there" ?
      OPEN_TAG: S++,
      // <strong
      OPEN_TAG_SLASH: S++,
      // <strong /
      ATTRIB: S++,
      // <a
      ATTRIB_NAME: S++,
      // <a foo
      ATTRIB_NAME_SAW_WHITE: S++,
      // <a foo _
      ATTRIB_VALUE: S++,
      // <a foo=
      ATTRIB_VALUE_QUOTED: S++,
      // <a foo="bar
      ATTRIB_VALUE_CLOSED: S++,
      // <a foo="bar"
      ATTRIB_VALUE_UNQUOTED: S++,
      // <a foo=bar
      ATTRIB_VALUE_ENTITY_Q: S++,
      // <foo bar="&quot;"
      ATTRIB_VALUE_ENTITY_U: S++,
      // <foo bar=&quot
      CLOSE_TAG: S++,
      // </a
      CLOSE_TAG_SAW_WHITE: S++,
      // </a   >
      SCRIPT: S++,
      // <script> ...
      SCRIPT_ENDING: S++
      // <script> ... <
    };
    sax2.XML_ENTITIES = {
      "amp": "&",
      "gt": ">",
      "lt": "<",
      "quot": '"',
      "apos": "'"
    };
    sax2.ENTITIES = {
      "amp": "&",
      "gt": ">",
      "lt": "<",
      "quot": '"',
      "apos": "'",
      "AElig": 198,
      "Aacute": 193,
      "Acirc": 194,
      "Agrave": 192,
      "Aring": 197,
      "Atilde": 195,
      "Auml": 196,
      "Ccedil": 199,
      "ETH": 208,
      "Eacute": 201,
      "Ecirc": 202,
      "Egrave": 200,
      "Euml": 203,
      "Iacute": 205,
      "Icirc": 206,
      "Igrave": 204,
      "Iuml": 207,
      "Ntilde": 209,
      "Oacute": 211,
      "Ocirc": 212,
      "Ograve": 210,
      "Oslash": 216,
      "Otilde": 213,
      "Ouml": 214,
      "THORN": 222,
      "Uacute": 218,
      "Ucirc": 219,
      "Ugrave": 217,
      "Uuml": 220,
      "Yacute": 221,
      "aacute": 225,
      "acirc": 226,
      "aelig": 230,
      "agrave": 224,
      "aring": 229,
      "atilde": 227,
      "auml": 228,
      "ccedil": 231,
      "eacute": 233,
      "ecirc": 234,
      "egrave": 232,
      "eth": 240,
      "euml": 235,
      "iacute": 237,
      "icirc": 238,
      "igrave": 236,
      "iuml": 239,
      "ntilde": 241,
      "oacute": 243,
      "ocirc": 244,
      "ograve": 242,
      "oslash": 248,
      "otilde": 245,
      "ouml": 246,
      "szlig": 223,
      "thorn": 254,
      "uacute": 250,
      "ucirc": 251,
      "ugrave": 249,
      "uuml": 252,
      "yacute": 253,
      "yuml": 255,
      "copy": 169,
      "reg": 174,
      "nbsp": 160,
      "iexcl": 161,
      "cent": 162,
      "pound": 163,
      "curren": 164,
      "yen": 165,
      "brvbar": 166,
      "sect": 167,
      "uml": 168,
      "ordf": 170,
      "laquo": 171,
      "not": 172,
      "shy": 173,
      "macr": 175,
      "deg": 176,
      "plusmn": 177,
      "sup1": 185,
      "sup2": 178,
      "sup3": 179,
      "acute": 180,
      "micro": 181,
      "para": 182,
      "middot": 183,
      "cedil": 184,
      "ordm": 186,
      "raquo": 187,
      "frac14": 188,
      "frac12": 189,
      "frac34": 190,
      "iquest": 191,
      "times": 215,
      "divide": 247,
      "OElig": 338,
      "oelig": 339,
      "Scaron": 352,
      "scaron": 353,
      "Yuml": 376,
      "fnof": 402,
      "circ": 710,
      "tilde": 732,
      "Alpha": 913,
      "Beta": 914,
      "Gamma": 915,
      "Delta": 916,
      "Epsilon": 917,
      "Zeta": 918,
      "Eta": 919,
      "Theta": 920,
      "Iota": 921,
      "Kappa": 922,
      "Lambda": 923,
      "Mu": 924,
      "Nu": 925,
      "Xi": 926,
      "Omicron": 927,
      "Pi": 928,
      "Rho": 929,
      "Sigma": 931,
      "Tau": 932,
      "Upsilon": 933,
      "Phi": 934,
      "Chi": 935,
      "Psi": 936,
      "Omega": 937,
      "alpha": 945,
      "beta": 946,
      "gamma": 947,
      "delta": 948,
      "epsilon": 949,
      "zeta": 950,
      "eta": 951,
      "theta": 952,
      "iota": 953,
      "kappa": 954,
      "lambda": 955,
      "mu": 956,
      "nu": 957,
      "xi": 958,
      "omicron": 959,
      "pi": 960,
      "rho": 961,
      "sigmaf": 962,
      "sigma": 963,
      "tau": 964,
      "upsilon": 965,
      "phi": 966,
      "chi": 967,
      "psi": 968,
      "omega": 969,
      "thetasym": 977,
      "upsih": 978,
      "piv": 982,
      "ensp": 8194,
      "emsp": 8195,
      "thinsp": 8201,
      "zwnj": 8204,
      "zwj": 8205,
      "lrm": 8206,
      "rlm": 8207,
      "ndash": 8211,
      "mdash": 8212,
      "lsquo": 8216,
      "rsquo": 8217,
      "sbquo": 8218,
      "ldquo": 8220,
      "rdquo": 8221,
      "bdquo": 8222,
      "dagger": 8224,
      "Dagger": 8225,
      "bull": 8226,
      "hellip": 8230,
      "permil": 8240,
      "prime": 8242,
      "Prime": 8243,
      "lsaquo": 8249,
      "rsaquo": 8250,
      "oline": 8254,
      "frasl": 8260,
      "euro": 8364,
      "image": 8465,
      "weierp": 8472,
      "real": 8476,
      "trade": 8482,
      "alefsym": 8501,
      "larr": 8592,
      "uarr": 8593,
      "rarr": 8594,
      "darr": 8595,
      "harr": 8596,
      "crarr": 8629,
      "lArr": 8656,
      "uArr": 8657,
      "rArr": 8658,
      "dArr": 8659,
      "hArr": 8660,
      "forall": 8704,
      "part": 8706,
      "exist": 8707,
      "empty": 8709,
      "nabla": 8711,
      "isin": 8712,
      "notin": 8713,
      "ni": 8715,
      "prod": 8719,
      "sum": 8721,
      "minus": 8722,
      "lowast": 8727,
      "radic": 8730,
      "prop": 8733,
      "infin": 8734,
      "ang": 8736,
      "and": 8743,
      "or": 8744,
      "cap": 8745,
      "cup": 8746,
      "int": 8747,
      "there4": 8756,
      "sim": 8764,
      "cong": 8773,
      "asymp": 8776,
      "ne": 8800,
      "equiv": 8801,
      "le": 8804,
      "ge": 8805,
      "sub": 8834,
      "sup": 8835,
      "nsub": 8836,
      "sube": 8838,
      "supe": 8839,
      "oplus": 8853,
      "otimes": 8855,
      "perp": 8869,
      "sdot": 8901,
      "lceil": 8968,
      "rceil": 8969,
      "lfloor": 8970,
      "rfloor": 8971,
      "lang": 9001,
      "rang": 9002,
      "loz": 9674,
      "spades": 9824,
      "clubs": 9827,
      "hearts": 9829,
      "diams": 9830
    };
    Object.keys(sax2.ENTITIES).forEach(function(key2) {
      var e = sax2.ENTITIES[key2];
      var s2 = typeof e === "number" ? String.fromCharCode(e) : e;
      sax2.ENTITIES[key2] = s2;
    });
    for (var s in sax2.STATE) {
      sax2.STATE[sax2.STATE[s]] = s;
    }
    S = sax2.STATE;
    function emit(parser2, event, data) {
      parser2[event] && parser2[event](data);
    }
    function emitNode(parser2, nodeType, data) {
      if (parser2.textNode)
        closeText(parser2);
      emit(parser2, nodeType, data);
    }
    function closeText(parser2) {
      parser2.textNode = textopts(parser2.opt, parser2.textNode);
      if (parser2.textNode)
        emit(parser2, "ontext", parser2.textNode);
      parser2.textNode = "";
    }
    function textopts(opt, text2) {
      if (opt.trim)
        text2 = text2.trim();
      if (opt.normalize)
        text2 = text2.replace(/\s+/g, " ");
      return text2;
    }
    function error(parser2, er) {
      closeText(parser2);
      if (parser2.trackPosition) {
        er += "\nLine: " + parser2.line + "\nColumn: " + parser2.column + "\nChar: " + parser2.c;
      }
      er = new Error(er);
      parser2.error = er;
      emit(parser2, "onerror", er);
      return parser2;
    }
    function end(parser2) {
      if (parser2.sawRoot && !parser2.closedRoot)
        strictFail(parser2, "Unclosed root tag");
      if (parser2.state !== S.BEGIN && parser2.state !== S.BEGIN_WHITESPACE && parser2.state !== S.TEXT) {
        error(parser2, "Unexpected end");
      }
      closeText(parser2);
      parser2.c = "";
      parser2.closed = true;
      emit(parser2, "onend");
      SAXParser.call(parser2, parser2.strict, parser2.opt);
      return parser2;
    }
    function strictFail(parser2, message) {
      if (typeof parser2 !== "object" || !(parser2 instanceof SAXParser)) {
        throw new Error("bad call to strictFail");
      }
      if (parser2.strict) {
        error(parser2, message);
      }
    }
    function newTag(parser2) {
      if (!parser2.strict)
        parser2.tagName = parser2.tagName[parser2.looseCase]();
      var parent = parser2.tags[parser2.tags.length - 1] || parser2;
      var tag = parser2.tag = { name: parser2.tagName, attributes: {} };
      if (parser2.opt.xmlns) {
        tag.ns = parent.ns;
      }
      parser2.attribList.length = 0;
      emitNode(parser2, "onopentagstart", tag);
    }
    function qname(name2, attribute) {
      var i = name2.indexOf(":");
      var qualName = i < 0 ? ["", name2] : name2.split(":");
      var prefix = qualName[0];
      var local = qualName[1];
      if (attribute && name2 === "xmlns") {
        prefix = "xmlns";
        local = "";
      }
      return { prefix, local };
    }
    function attrib(parser2) {
      if (!parser2.strict) {
        parser2.attribName = parser2.attribName[parser2.looseCase]();
      }
      if (parser2.attribList.indexOf(parser2.attribName) !== -1 || parser2.tag.attributes.hasOwnProperty(parser2.attribName)) {
        parser2.attribName = parser2.attribValue = "";
        return;
      }
      if (parser2.opt.xmlns) {
        var qn = qname(parser2.attribName, true);
        var prefix = qn.prefix;
        var local = qn.local;
        if (prefix === "xmlns") {
          if (local === "xml" && parser2.attribValue !== XML_NAMESPACE) {
            strictFail(
              parser2,
              "xml: prefix must be bound to " + XML_NAMESPACE + "\nActual: " + parser2.attribValue
            );
          } else if (local === "xmlns" && parser2.attribValue !== XMLNS_NAMESPACE) {
            strictFail(
              parser2,
              "xmlns: prefix must be bound to " + XMLNS_NAMESPACE + "\nActual: " + parser2.attribValue
            );
          } else {
            var tag = parser2.tag;
            var parent = parser2.tags[parser2.tags.length - 1] || parser2;
            if (tag.ns === parent.ns) {
              tag.ns = Object.create(parent.ns);
            }
            tag.ns[local] = parser2.attribValue;
          }
        }
        parser2.attribList.push([parser2.attribName, parser2.attribValue]);
      } else {
        parser2.tag.attributes[parser2.attribName] = parser2.attribValue;
        emitNode(parser2, "onattribute", {
          name: parser2.attribName,
          value: parser2.attribValue
        });
      }
      parser2.attribName = parser2.attribValue = "";
    }
    function openTag(parser2, selfClosing) {
      if (parser2.opt.xmlns) {
        var tag = parser2.tag;
        var qn = qname(parser2.tagName);
        tag.prefix = qn.prefix;
        tag.local = qn.local;
        tag.uri = tag.ns[qn.prefix] || "";
        if (tag.prefix && !tag.uri) {
          strictFail(parser2, "Unbound namespace prefix: " + JSON.stringify(parser2.tagName));
          tag.uri = qn.prefix;
        }
        var parent = parser2.tags[parser2.tags.length - 1] || parser2;
        if (tag.ns && parent.ns !== tag.ns) {
          Object.keys(tag.ns).forEach(function(p) {
            emitNode(parser2, "onopennamespace", {
              prefix: p,
              uri: tag.ns[p]
            });
          });
        }
        for (var i = 0, l = parser2.attribList.length; i < l; i++) {
          var nv = parser2.attribList[i];
          var name2 = nv[0];
          var value = nv[1];
          var qualName = qname(name2, true);
          var prefix = qualName.prefix;
          var local = qualName.local;
          var uri = prefix === "" ? "" : tag.ns[prefix] || "";
          var a = {
            name: name2,
            value,
            prefix,
            local,
            uri
          };
          if (prefix && prefix !== "xmlns" && !uri) {
            strictFail(parser2, "Unbound namespace prefix: " + JSON.stringify(prefix));
            a.uri = prefix;
          }
          parser2.tag.attributes[name2] = a;
          emitNode(parser2, "onattribute", a);
        }
        parser2.attribList.length = 0;
      }
      parser2.tag.isSelfClosing = !!selfClosing;
      parser2.sawRoot = true;
      parser2.tags.push(parser2.tag);
      emitNode(parser2, "onopentag", parser2.tag);
      if (!selfClosing) {
        if (!parser2.noscript && parser2.tagName.toLowerCase() === "script") {
          parser2.state = S.SCRIPT;
        } else {
          parser2.state = S.TEXT;
        }
        parser2.tag = null;
        parser2.tagName = "";
      }
      parser2.attribName = parser2.attribValue = "";
      parser2.attribList.length = 0;
    }
    function closeTag(parser2) {
      if (!parser2.tagName) {
        strictFail(parser2, "Weird empty close tag.");
        parser2.textNode += "</>";
        parser2.state = S.TEXT;
        return;
      }
      if (parser2.script) {
        if (parser2.tagName !== "script") {
          parser2.script += "</" + parser2.tagName + ">";
          parser2.tagName = "";
          parser2.state = S.SCRIPT;
          return;
        }
        emitNode(parser2, "onscript", parser2.script);
        parser2.script = "";
      }
      var t = parser2.tags.length;
      var tagName = parser2.tagName;
      if (!parser2.strict) {
        tagName = tagName[parser2.looseCase]();
      }
      var closeTo = tagName;
      while (t--) {
        var close = parser2.tags[t];
        if (close.name !== closeTo) {
          strictFail(parser2, "Unexpected close tag");
        } else {
          break;
        }
      }
      if (t < 0) {
        strictFail(parser2, "Unmatched closing tag: " + parser2.tagName);
        parser2.textNode += "</" + parser2.tagName + ">";
        parser2.state = S.TEXT;
        return;
      }
      parser2.tagName = tagName;
      var s2 = parser2.tags.length;
      while (s2-- > t) {
        var tag = parser2.tag = parser2.tags.pop();
        parser2.tagName = parser2.tag.name;
        emitNode(parser2, "onclosetag", parser2.tagName);
        var x = {};
        for (var i in tag.ns) {
          x[i] = tag.ns[i];
        }
        var parent = parser2.tags[parser2.tags.length - 1] || parser2;
        if (parser2.opt.xmlns && tag.ns !== parent.ns) {
          Object.keys(tag.ns).forEach(function(p) {
            var n = tag.ns[p];
            emitNode(parser2, "onclosenamespace", { prefix: p, uri: n });
          });
        }
      }
      if (t === 0)
        parser2.closedRoot = true;
      parser2.tagName = parser2.attribValue = parser2.attribName = "";
      parser2.attribList.length = 0;
      parser2.state = S.TEXT;
    }
    function parseEntity(parser2) {
      var entity = parser2.entity;
      var entityLC = entity.toLowerCase();
      var num;
      var numStr = "";
      if (parser2.ENTITIES[entity]) {
        return parser2.ENTITIES[entity];
      }
      if (parser2.ENTITIES[entityLC]) {
        return parser2.ENTITIES[entityLC];
      }
      entity = entityLC;
      if (entity.charAt(0) === "#") {
        if (entity.charAt(1) === "x") {
          entity = entity.slice(2);
          num = parseInt(entity, 16);
          numStr = num.toString(16);
        } else {
          entity = entity.slice(1);
          num = parseInt(entity, 10);
          numStr = num.toString(10);
        }
      }
      entity = entity.replace(/^0+/, "");
      if (isNaN(num) || numStr.toLowerCase() !== entity) {
        strictFail(parser2, "Invalid character entity");
        return "&" + parser2.entity + ";";
      }
      return String.fromCodePoint(num);
    }
    function beginWhiteSpace(parser2, c2) {
      if (c2 === "<") {
        parser2.state = S.OPEN_WAKA;
        parser2.startTagPosition = parser2.position;
      } else if (!isWhitespace(c2)) {
        strictFail(parser2, "Non-whitespace before first tag.");
        parser2.textNode = c2;
        parser2.state = S.TEXT;
      }
    }
    function charAt(chunk, i) {
      var result = "";
      if (i < chunk.length) {
        result = chunk.charAt(i);
      }
      return result;
    }
    function write(chunk) {
      var parser2 = this;
      if (this.error) {
        throw this.error;
      }
      if (parser2.closed) {
        return error(
          parser2,
          "Cannot write after close. Assign an onready handler."
        );
      }
      if (chunk === null) {
        return end(parser2);
      }
      if (typeof chunk === "object") {
        chunk = chunk.toString();
      }
      var i = 0;
      var c2 = "";
      while (true) {
        c2 = charAt(chunk, i++);
        parser2.c = c2;
        if (!c2) {
          break;
        }
        if (parser2.trackPosition) {
          parser2.position++;
          if (c2 === "\n") {
            parser2.line++;
            parser2.column = 0;
          } else {
            parser2.column++;
          }
        }
        switch (parser2.state) {
          case S.BEGIN:
            parser2.state = S.BEGIN_WHITESPACE;
            if (c2 === "\uFEFF") {
              continue;
            }
            beginWhiteSpace(parser2, c2);
            continue;
          case S.BEGIN_WHITESPACE:
            beginWhiteSpace(parser2, c2);
            continue;
          case S.TEXT:
            if (parser2.sawRoot && !parser2.closedRoot) {
              var starti = i - 1;
              while (c2 && c2 !== "<" && c2 !== "&") {
                c2 = charAt(chunk, i++);
                if (c2 && parser2.trackPosition) {
                  parser2.position++;
                  if (c2 === "\n") {
                    parser2.line++;
                    parser2.column = 0;
                  } else {
                    parser2.column++;
                  }
                }
              }
              parser2.textNode += chunk.substring(starti, i - 1);
            }
            if (c2 === "<" && !(parser2.sawRoot && parser2.closedRoot && !parser2.strict)) {
              parser2.state = S.OPEN_WAKA;
              parser2.startTagPosition = parser2.position;
            } else {
              if (!isWhitespace(c2) && (!parser2.sawRoot || parser2.closedRoot)) {
                strictFail(parser2, "Text data outside of root node.");
              }
              if (c2 === "&") {
                parser2.state = S.TEXT_ENTITY;
              } else {
                parser2.textNode += c2;
              }
            }
            continue;
          case S.SCRIPT:
            if (c2 === "<") {
              parser2.state = S.SCRIPT_ENDING;
            } else {
              parser2.script += c2;
            }
            continue;
          case S.SCRIPT_ENDING:
            if (c2 === "/") {
              parser2.state = S.CLOSE_TAG;
            } else {
              parser2.script += "<" + c2;
              parser2.state = S.SCRIPT;
            }
            continue;
          case S.OPEN_WAKA:
            if (c2 === "!") {
              parser2.state = S.SGML_DECL;
              parser2.sgmlDecl = "";
            } else if (isWhitespace(c2))
              ;
            else if (isMatch(nameStart, c2)) {
              parser2.state = S.OPEN_TAG;
              parser2.tagName = c2;
            } else if (c2 === "/") {
              parser2.state = S.CLOSE_TAG;
              parser2.tagName = "";
            } else if (c2 === "?") {
              parser2.state = S.PROC_INST;
              parser2.procInstName = parser2.procInstBody = "";
            } else {
              strictFail(parser2, "Unencoded <");
              if (parser2.startTagPosition + 1 < parser2.position) {
                var pad = parser2.position - parser2.startTagPosition;
                c2 = new Array(pad).join(" ") + c2;
              }
              parser2.textNode += "<" + c2;
              parser2.state = S.TEXT;
            }
            continue;
          case S.SGML_DECL:
            if ((parser2.sgmlDecl + c2).toUpperCase() === CDATA) {
              emitNode(parser2, "onopencdata");
              parser2.state = S.CDATA;
              parser2.sgmlDecl = "";
              parser2.cdata = "";
            } else if (parser2.sgmlDecl + c2 === "--") {
              parser2.state = S.COMMENT;
              parser2.comment = "";
              parser2.sgmlDecl = "";
            } else if ((parser2.sgmlDecl + c2).toUpperCase() === DOCTYPE) {
              parser2.state = S.DOCTYPE;
              if (parser2.doctype || parser2.sawRoot) {
                strictFail(
                  parser2,
                  "Inappropriately located doctype declaration"
                );
              }
              parser2.doctype = "";
              parser2.sgmlDecl = "";
            } else if (c2 === ">") {
              emitNode(parser2, "onsgmldeclaration", parser2.sgmlDecl);
              parser2.sgmlDecl = "";
              parser2.state = S.TEXT;
            } else if (isQuote(c2)) {
              parser2.state = S.SGML_DECL_QUOTED;
              parser2.sgmlDecl += c2;
            } else {
              parser2.sgmlDecl += c2;
            }
            continue;
          case S.SGML_DECL_QUOTED:
            if (c2 === parser2.q) {
              parser2.state = S.SGML_DECL;
              parser2.q = "";
            }
            parser2.sgmlDecl += c2;
            continue;
          case S.DOCTYPE:
            if (c2 === ">") {
              parser2.state = S.TEXT;
              emitNode(parser2, "ondoctype", parser2.doctype);
              parser2.doctype = true;
            } else {
              parser2.doctype += c2;
              if (c2 === "[") {
                parser2.state = S.DOCTYPE_DTD;
              } else if (isQuote(c2)) {
                parser2.state = S.DOCTYPE_QUOTED;
                parser2.q = c2;
              }
            }
            continue;
          case S.DOCTYPE_QUOTED:
            parser2.doctype += c2;
            if (c2 === parser2.q) {
              parser2.q = "";
              parser2.state = S.DOCTYPE;
            }
            continue;
          case S.DOCTYPE_DTD:
            parser2.doctype += c2;
            if (c2 === "]") {
              parser2.state = S.DOCTYPE;
            } else if (isQuote(c2)) {
              parser2.state = S.DOCTYPE_DTD_QUOTED;
              parser2.q = c2;
            }
            continue;
          case S.DOCTYPE_DTD_QUOTED:
            parser2.doctype += c2;
            if (c2 === parser2.q) {
              parser2.state = S.DOCTYPE_DTD;
              parser2.q = "";
            }
            continue;
          case S.COMMENT:
            if (c2 === "-") {
              parser2.state = S.COMMENT_ENDING;
            } else {
              parser2.comment += c2;
            }
            continue;
          case S.COMMENT_ENDING:
            if (c2 === "-") {
              parser2.state = S.COMMENT_ENDED;
              parser2.comment = textopts(parser2.opt, parser2.comment);
              if (parser2.comment) {
                emitNode(parser2, "oncomment", parser2.comment);
              }
              parser2.comment = "";
            } else {
              parser2.comment += "-" + c2;
              parser2.state = S.COMMENT;
            }
            continue;
          case S.COMMENT_ENDED:
            if (c2 !== ">") {
              strictFail(parser2, "Malformed comment");
              parser2.comment += "--" + c2;
              parser2.state = S.COMMENT;
            } else {
              parser2.state = S.TEXT;
            }
            continue;
          case S.CDATA:
            if (c2 === "]") {
              parser2.state = S.CDATA_ENDING;
            } else {
              parser2.cdata += c2;
            }
            continue;
          case S.CDATA_ENDING:
            if (c2 === "]") {
              parser2.state = S.CDATA_ENDING_2;
            } else {
              parser2.cdata += "]" + c2;
              parser2.state = S.CDATA;
            }
            continue;
          case S.CDATA_ENDING_2:
            if (c2 === ">") {
              if (parser2.cdata) {
                emitNode(parser2, "oncdata", parser2.cdata);
              }
              emitNode(parser2, "onclosecdata");
              parser2.cdata = "";
              parser2.state = S.TEXT;
            } else if (c2 === "]") {
              parser2.cdata += "]";
            } else {
              parser2.cdata += "]]" + c2;
              parser2.state = S.CDATA;
            }
            continue;
          case S.PROC_INST:
            if (c2 === "?") {
              parser2.state = S.PROC_INST_ENDING;
            } else if (isWhitespace(c2)) {
              parser2.state = S.PROC_INST_BODY;
            } else {
              parser2.procInstName += c2;
            }
            continue;
          case S.PROC_INST_BODY:
            if (!parser2.procInstBody && isWhitespace(c2)) {
              continue;
            } else if (c2 === "?") {
              parser2.state = S.PROC_INST_ENDING;
            } else {
              parser2.procInstBody += c2;
            }
            continue;
          case S.PROC_INST_ENDING:
            if (c2 === ">") {
              emitNode(parser2, "onprocessinginstruction", {
                name: parser2.procInstName,
                body: parser2.procInstBody
              });
              parser2.procInstName = parser2.procInstBody = "";
              parser2.state = S.TEXT;
            } else {
              parser2.procInstBody += "?" + c2;
              parser2.state = S.PROC_INST_BODY;
            }
            continue;
          case S.OPEN_TAG:
            if (isMatch(nameBody, c2)) {
              parser2.tagName += c2;
            } else {
              newTag(parser2);
              if (c2 === ">") {
                openTag(parser2);
              } else if (c2 === "/") {
                parser2.state = S.OPEN_TAG_SLASH;
              } else {
                if (!isWhitespace(c2)) {
                  strictFail(parser2, "Invalid character in tag name");
                }
                parser2.state = S.ATTRIB;
              }
            }
            continue;
          case S.OPEN_TAG_SLASH:
            if (c2 === ">") {
              openTag(parser2, true);
              closeTag(parser2);
            } else {
              strictFail(parser2, "Forward-slash in opening tag not followed by >");
              parser2.state = S.ATTRIB;
            }
            continue;
          case S.ATTRIB:
            if (isWhitespace(c2)) {
              continue;
            } else if (c2 === ">") {
              openTag(parser2);
            } else if (c2 === "/") {
              parser2.state = S.OPEN_TAG_SLASH;
            } else if (isMatch(nameStart, c2)) {
              parser2.attribName = c2;
              parser2.attribValue = "";
              parser2.state = S.ATTRIB_NAME;
            } else {
              strictFail(parser2, "Invalid attribute name");
            }
            continue;
          case S.ATTRIB_NAME:
            if (c2 === "=") {
              parser2.state = S.ATTRIB_VALUE;
            } else if (c2 === ">") {
              strictFail(parser2, "Attribute without value");
              parser2.attribValue = parser2.attribName;
              attrib(parser2);
              openTag(parser2);
            } else if (isWhitespace(c2)) {
              parser2.state = S.ATTRIB_NAME_SAW_WHITE;
            } else if (isMatch(nameBody, c2)) {
              parser2.attribName += c2;
            } else {
              strictFail(parser2, "Invalid attribute name");
            }
            continue;
          case S.ATTRIB_NAME_SAW_WHITE:
            if (c2 === "=") {
              parser2.state = S.ATTRIB_VALUE;
            } else if (isWhitespace(c2)) {
              continue;
            } else {
              strictFail(parser2, "Attribute without value");
              parser2.tag.attributes[parser2.attribName] = "";
              parser2.attribValue = "";
              emitNode(parser2, "onattribute", {
                name: parser2.attribName,
                value: ""
              });
              parser2.attribName = "";
              if (c2 === ">") {
                openTag(parser2);
              } else if (isMatch(nameStart, c2)) {
                parser2.attribName = c2;
                parser2.state = S.ATTRIB_NAME;
              } else {
                strictFail(parser2, "Invalid attribute name");
                parser2.state = S.ATTRIB;
              }
            }
            continue;
          case S.ATTRIB_VALUE:
            if (isWhitespace(c2)) {
              continue;
            } else if (isQuote(c2)) {
              parser2.q = c2;
              parser2.state = S.ATTRIB_VALUE_QUOTED;
            } else {
              strictFail(parser2, "Unquoted attribute value");
              parser2.state = S.ATTRIB_VALUE_UNQUOTED;
              parser2.attribValue = c2;
            }
            continue;
          case S.ATTRIB_VALUE_QUOTED:
            if (c2 !== parser2.q) {
              if (c2 === "&") {
                parser2.state = S.ATTRIB_VALUE_ENTITY_Q;
              } else {
                parser2.attribValue += c2;
              }
              continue;
            }
            attrib(parser2);
            parser2.q = "";
            parser2.state = S.ATTRIB_VALUE_CLOSED;
            continue;
          case S.ATTRIB_VALUE_CLOSED:
            if (isWhitespace(c2)) {
              parser2.state = S.ATTRIB;
            } else if (c2 === ">") {
              openTag(parser2);
            } else if (c2 === "/") {
              parser2.state = S.OPEN_TAG_SLASH;
            } else if (isMatch(nameStart, c2)) {
              strictFail(parser2, "No whitespace between attributes");
              parser2.attribName = c2;
              parser2.attribValue = "";
              parser2.state = S.ATTRIB_NAME;
            } else {
              strictFail(parser2, "Invalid attribute name");
            }
            continue;
          case S.ATTRIB_VALUE_UNQUOTED:
            if (!isAttribEnd(c2)) {
              if (c2 === "&") {
                parser2.state = S.ATTRIB_VALUE_ENTITY_U;
              } else {
                parser2.attribValue += c2;
              }
              continue;
            }
            attrib(parser2);
            if (c2 === ">") {
              openTag(parser2);
            } else {
              parser2.state = S.ATTRIB;
            }
            continue;
          case S.CLOSE_TAG:
            if (!parser2.tagName) {
              if (isWhitespace(c2)) {
                continue;
              } else if (notMatch(nameStart, c2)) {
                if (parser2.script) {
                  parser2.script += "</" + c2;
                  parser2.state = S.SCRIPT;
                } else {
                  strictFail(parser2, "Invalid tagname in closing tag.");
                }
              } else {
                parser2.tagName = c2;
              }
            } else if (c2 === ">") {
              closeTag(parser2);
            } else if (isMatch(nameBody, c2)) {
              parser2.tagName += c2;
            } else if (parser2.script) {
              parser2.script += "</" + parser2.tagName;
              parser2.tagName = "";
              parser2.state = S.SCRIPT;
            } else {
              if (!isWhitespace(c2)) {
                strictFail(parser2, "Invalid tagname in closing tag");
              }
              parser2.state = S.CLOSE_TAG_SAW_WHITE;
            }
            continue;
          case S.CLOSE_TAG_SAW_WHITE:
            if (isWhitespace(c2)) {
              continue;
            }
            if (c2 === ">") {
              closeTag(parser2);
            } else {
              strictFail(parser2, "Invalid characters in closing tag");
            }
            continue;
          case S.TEXT_ENTITY:
          case S.ATTRIB_VALUE_ENTITY_Q:
          case S.ATTRIB_VALUE_ENTITY_U:
            var returnState;
            var buffer2;
            switch (parser2.state) {
              case S.TEXT_ENTITY:
                returnState = S.TEXT;
                buffer2 = "textNode";
                break;
              case S.ATTRIB_VALUE_ENTITY_Q:
                returnState = S.ATTRIB_VALUE_QUOTED;
                buffer2 = "attribValue";
                break;
              case S.ATTRIB_VALUE_ENTITY_U:
                returnState = S.ATTRIB_VALUE_UNQUOTED;
                buffer2 = "attribValue";
                break;
            }
            if (c2 === ";") {
              if (parser2.opt.unparsedEntities) {
                var parsedEntity = parseEntity(parser2);
                parser2.entity = "";
                parser2.state = returnState;
                parser2.write(parsedEntity);
              } else {
                parser2[buffer2] += parseEntity(parser2);
                parser2.entity = "";
                parser2.state = returnState;
              }
            } else if (isMatch(parser2.entity.length ? entityBody : entityStart, c2)) {
              parser2.entity += c2;
            } else {
              strictFail(parser2, "Invalid character in entity name");
              parser2[buffer2] += "&" + parser2.entity + c2;
              parser2.entity = "";
              parser2.state = returnState;
            }
            continue;
          default: {
            throw new Error(parser2, "Unknown state: " + parser2.state);
          }
        }
      }
      if (parser2.position >= parser2.bufferCheckPosition) {
        checkBufferLength(parser2);
      }
      return parser2;
    }
    /*! http://mths.be/fromcodepoint v0.1.0 by @mathias */
    if (!String.fromCodePoint) {
      (function() {
        var stringFromCharCode = String.fromCharCode;
        var floor = Math.floor;
        var fromCodePoint = function() {
          var MAX_SIZE = 16384;
          var codeUnits = [];
          var highSurrogate;
          var lowSurrogate;
          var index = -1;
          var length = arguments.length;
          if (!length) {
            return "";
          }
          var result = "";
          while (++index < length) {
            var codePoint = Number(arguments[index]);
            if (!isFinite(codePoint) || // `NaN`, `+Infinity`, or `-Infinity`
            codePoint < 0 || // not a valid Unicode code point
            codePoint > 1114111 || // not a valid Unicode code point
            floor(codePoint) !== codePoint) {
              throw RangeError("Invalid code point: " + codePoint);
            }
            if (codePoint <= 65535) {
              codeUnits.push(codePoint);
            } else {
              codePoint -= 65536;
              highSurrogate = (codePoint >> 10) + 55296;
              lowSurrogate = codePoint % 1024 + 56320;
              codeUnits.push(highSurrogate, lowSurrogate);
            }
            if (index + 1 === length || codeUnits.length > MAX_SIZE) {
              result += stringFromCharCode.apply(null, codeUnits);
              codeUnits.length = 0;
            }
          }
          return result;
        };
        if (Object.defineProperty) {
          Object.defineProperty(String, "fromCodePoint", {
            value: fromCodePoint,
            configurable: true,
            writable: true
          });
        } else {
          String.fromCodePoint = fromCodePoint;
        }
      })();
    }
  })(exports);
})(sax);
const parser = sax.parser;
function parse$2(data, config) {
  const res = [];
  const stack2 = [];
  let pointer = res;
  let trim = true;
  let strict = true;
  if (config && config.strict !== void 0) {
    strict = config.strict;
  }
  if (config !== void 0) {
    if (config.trim !== void 0) {
      trim = config.trim;
    }
  }
  const p = parser(strict);
  p.ontext = function(e) {
    if (trim === false || e.trim() !== "") {
      pointer.push(e);
    }
  };
  p.onopentag = function(e) {
    const leaf = [e.name, e.attributes];
    stack2.push(pointer);
    pointer.push(leaf);
    pointer = leaf;
  };
  p.onclosetag = function() {
    pointer = stack2.pop();
  };
  p.oncdata = function(e) {
    if (trim === false || e.trim() !== "") {
      pointer.push("<![CDATA[" + e + "]]>");
    }
  };
  p.write(data).close();
  return res[0];
}
var parse_1 = parse$2;
function skipFn() {
  this._skip = true;
}
function removeFn() {
  this._remove = true;
}
function nameFn(name2) {
  this._name = name2;
}
function replaceFn(node) {
  this._replace = node;
}
function traverse$1(origin, callbacks) {
  const empty = function() {
  };
  const enter = callbacks && callbacks.enter || empty;
  const leave = callbacks && callbacks.leave || empty;
  function rec2(tree, parent) {
    if (tree === void 0)
      return;
    if (tree === null)
      return;
    if (tree === true)
      return;
    if (tree === false)
      return;
    const node = {
      attr: {},
      full: tree
    };
    const cxt = {
      name: nameFn,
      skip: skipFn,
      // break: breakFn,
      remove: removeFn,
      replace: replaceFn,
      _name: void 0,
      _skip: false,
      // _break: false,
      _remove: false,
      _replace: void 0
    };
    let e1IsNotAnObject = true;
    switch (Object.prototype.toString.call(tree)) {
      case "[object String]":
      case "[object Number]":
        return;
      case "[object Array]":
        tree.some(function(e, i) {
          if (i === 0) {
            node.name = e;
            return false;
          }
          if (i === 1) {
            if (Object.prototype.toString.call(e) === "[object Object]") {
              e1IsNotAnObject = false;
              node.attr = e;
            }
            return true;
          }
        });
        enter.call(cxt, node, parent);
        if (cxt._name) {
          tree[0] = cxt._name;
        }
        if (cxt._replace) {
          return cxt._replace;
        }
        if (cxt._remove) {
          return null;
        }
        if (!cxt._skip) {
          let index = 0;
          let ilen = tree.length;
          while (index < ilen) {
            if (index > 1 || index === 1 && e1IsNotAnObject) {
              const returnRes = rec2(tree[index], node);
              if (returnRes === null) {
                tree.splice(index, 1);
                ilen -= 1;
                continue;
              }
              if (returnRes) {
                tree[index] = returnRes;
              }
            }
            index += 1;
          }
          leave.call(cxt, node, parent);
          if (cxt._name) {
            tree[0] = cxt._name;
          }
          if (cxt._replace) {
            return cxt._replace;
          }
          if (cxt._remove) {
            return null;
          }
        }
    }
  }
  rec2(origin, void 0);
}
var traverse_1 = traverse$1;
const stringify$2 = stringify_1;
const renderer$1 = (root2) => {
  const content = typeof root2 === "string" ? document.getElementById(root2) : root2;
  return (ml) => {
    let str;
    try {
      str = stringify$2(ml);
      content.innerHTML = str;
    } catch (err) {
      console.log(ml);
    }
  };
};
var renderer_1 = renderer$1;
const w3 = {
  svg: "http://www.w3.org/2000/svg",
  xlink: "http://www.w3.org/1999/xlink",
  xmlns: "http://www.w3.org/XML/1998/namespace"
};
var genSvg$1 = (w, h) => ["svg", {
  xmlns: w3.svg,
  "xmlns:xlink": w3.xlink,
  width: w,
  height: h,
  viewBox: "0 0 " + w + " " + h
}];
const parse$1 = parse_1;
const stringify$1 = stringify_1;
const traverse = traverse_1;
const renderer = renderer_1;
const tt = tt$a;
const genSvg = genSvg$1;
onml.renderer = renderer;
onml.parse = parse$1;
onml.stringify = stringify$1;
onml.traverse = traverse;
onml.tt = tt;
onml.gen = {
  svg: genSvg
};
onml.p = parse$1;
onml.s = stringify$1;
onml.t = traverse;
var Space_Separator = /[\u1680\u2000-\u200A\u202F\u205F\u3000]/;
var ID_Start = /[\xAA\xB5\xBA\xC0-\xD6\xD8-\xF6\xF8-\u02C1\u02C6-\u02D1\u02E0-\u02E4\u02EC\u02EE\u0370-\u0374\u0376\u0377\u037A-\u037D\u037F\u0386\u0388-\u038A\u038C\u038E-\u03A1\u03A3-\u03F5\u03F7-\u0481\u048A-\u052F\u0531-\u0556\u0559\u0561-\u0587\u05D0-\u05EA\u05F0-\u05F2\u0620-\u064A\u066E\u066F\u0671-\u06D3\u06D5\u06E5\u06E6\u06EE\u06EF\u06FA-\u06FC\u06FF\u0710\u0712-\u072F\u074D-\u07A5\u07B1\u07CA-\u07EA\u07F4\u07F5\u07FA\u0800-\u0815\u081A\u0824\u0828\u0840-\u0858\u0860-\u086A\u08A0-\u08B4\u08B6-\u08BD\u0904-\u0939\u093D\u0950\u0958-\u0961\u0971-\u0980\u0985-\u098C\u098F\u0990\u0993-\u09A8\u09AA-\u09B0\u09B2\u09B6-\u09B9\u09BD\u09CE\u09DC\u09DD\u09DF-\u09E1\u09F0\u09F1\u09FC\u0A05-\u0A0A\u0A0F\u0A10\u0A13-\u0A28\u0A2A-\u0A30\u0A32\u0A33\u0A35\u0A36\u0A38\u0A39\u0A59-\u0A5C\u0A5E\u0A72-\u0A74\u0A85-\u0A8D\u0A8F-\u0A91\u0A93-\u0AA8\u0AAA-\u0AB0\u0AB2\u0AB3\u0AB5-\u0AB9\u0ABD\u0AD0\u0AE0\u0AE1\u0AF9\u0B05-\u0B0C\u0B0F\u0B10\u0B13-\u0B28\u0B2A-\u0B30\u0B32\u0B33\u0B35-\u0B39\u0B3D\u0B5C\u0B5D\u0B5F-\u0B61\u0B71\u0B83\u0B85-\u0B8A\u0B8E-\u0B90\u0B92-\u0B95\u0B99\u0B9A\u0B9C\u0B9E\u0B9F\u0BA3\u0BA4\u0BA8-\u0BAA\u0BAE-\u0BB9\u0BD0\u0C05-\u0C0C\u0C0E-\u0C10\u0C12-\u0C28\u0C2A-\u0C39\u0C3D\u0C58-\u0C5A\u0C60\u0C61\u0C80\u0C85-\u0C8C\u0C8E-\u0C90\u0C92-\u0CA8\u0CAA-\u0CB3\u0CB5-\u0CB9\u0CBD\u0CDE\u0CE0\u0CE1\u0CF1\u0CF2\u0D05-\u0D0C\u0D0E-\u0D10\u0D12-\u0D3A\u0D3D\u0D4E\u0D54-\u0D56\u0D5F-\u0D61\u0D7A-\u0D7F\u0D85-\u0D96\u0D9A-\u0DB1\u0DB3-\u0DBB\u0DBD\u0DC0-\u0DC6\u0E01-\u0E30\u0E32\u0E33\u0E40-\u0E46\u0E81\u0E82\u0E84\u0E87\u0E88\u0E8A\u0E8D\u0E94-\u0E97\u0E99-\u0E9F\u0EA1-\u0EA3\u0EA5\u0EA7\u0EAA\u0EAB\u0EAD-\u0EB0\u0EB2\u0EB3\u0EBD\u0EC0-\u0EC4\u0EC6\u0EDC-\u0EDF\u0F00\u0F40-\u0F47\u0F49-\u0F6C\u0F88-\u0F8C\u1000-\u102A\u103F\u1050-\u1055\u105A-\u105D\u1061\u1065\u1066\u106E-\u1070\u1075-\u1081\u108E\u10A0-\u10C5\u10C7\u10CD\u10D0-\u10FA\u10FC-\u1248\u124A-\u124D\u1250-\u1256\u1258\u125A-\u125D\u1260-\u1288\u128A-\u128D\u1290-\u12B0\u12B2-\u12B5\u12B8-\u12BE\u12C0\u12C2-\u12C5\u12C8-\u12D6\u12D8-\u1310\u1312-\u1315\u1318-\u135A\u1380-\u138F\u13A0-\u13F5\u13F8-\u13FD\u1401-\u166C\u166F-\u167F\u1681-\u169A\u16A0-\u16EA\u16EE-\u16F8\u1700-\u170C\u170E-\u1711\u1720-\u1731\u1740-\u1751\u1760-\u176C\u176E-\u1770\u1780-\u17B3\u17D7\u17DC\u1820-\u1877\u1880-\u1884\u1887-\u18A8\u18AA\u18B0-\u18F5\u1900-\u191E\u1950-\u196D\u1970-\u1974\u1980-\u19AB\u19B0-\u19C9\u1A00-\u1A16\u1A20-\u1A54\u1AA7\u1B05-\u1B33\u1B45-\u1B4B\u1B83-\u1BA0\u1BAE\u1BAF\u1BBA-\u1BE5\u1C00-\u1C23\u1C4D-\u1C4F\u1C5A-\u1C7D\u1C80-\u1C88\u1CE9-\u1CEC\u1CEE-\u1CF1\u1CF5\u1CF6\u1D00-\u1DBF\u1E00-\u1F15\u1F18-\u1F1D\u1F20-\u1F45\u1F48-\u1F4D\u1F50-\u1F57\u1F59\u1F5B\u1F5D\u1F5F-\u1F7D\u1F80-\u1FB4\u1FB6-\u1FBC\u1FBE\u1FC2-\u1FC4\u1FC6-\u1FCC\u1FD0-\u1FD3\u1FD6-\u1FDB\u1FE0-\u1FEC\u1FF2-\u1FF4\u1FF6-\u1FFC\u2071\u207F\u2090-\u209C\u2102\u2107\u210A-\u2113\u2115\u2119-\u211D\u2124\u2126\u2128\u212A-\u212D\u212F-\u2139\u213C-\u213F\u2145-\u2149\u214E\u2160-\u2188\u2C00-\u2C2E\u2C30-\u2C5E\u2C60-\u2CE4\u2CEB-\u2CEE\u2CF2\u2CF3\u2D00-\u2D25\u2D27\u2D2D\u2D30-\u2D67\u2D6F\u2D80-\u2D96\u2DA0-\u2DA6\u2DA8-\u2DAE\u2DB0-\u2DB6\u2DB8-\u2DBE\u2DC0-\u2DC6\u2DC8-\u2DCE\u2DD0-\u2DD6\u2DD8-\u2DDE\u2E2F\u3005-\u3007\u3021-\u3029\u3031-\u3035\u3038-\u303C\u3041-\u3096\u309D-\u309F\u30A1-\u30FA\u30FC-\u30FF\u3105-\u312E\u3131-\u318E\u31A0-\u31BA\u31F0-\u31FF\u3400-\u4DB5\u4E00-\u9FEA\uA000-\uA48C\uA4D0-\uA4FD\uA500-\uA60C\uA610-\uA61F\uA62A\uA62B\uA640-\uA66E\uA67F-\uA69D\uA6A0-\uA6EF\uA717-\uA71F\uA722-\uA788\uA78B-\uA7AE\uA7B0-\uA7B7\uA7F7-\uA801\uA803-\uA805\uA807-\uA80A\uA80C-\uA822\uA840-\uA873\uA882-\uA8B3\uA8F2-\uA8F7\uA8FB\uA8FD\uA90A-\uA925\uA930-\uA946\uA960-\uA97C\uA984-\uA9B2\uA9CF\uA9E0-\uA9E4\uA9E6-\uA9EF\uA9FA-\uA9FE\uAA00-\uAA28\uAA40-\uAA42\uAA44-\uAA4B\uAA60-\uAA76\uAA7A\uAA7E-\uAAAF\uAAB1\uAAB5\uAAB6\uAAB9-\uAABD\uAAC0\uAAC2\uAADB-\uAADD\uAAE0-\uAAEA\uAAF2-\uAAF4\uAB01-\uAB06\uAB09-\uAB0E\uAB11-\uAB16\uAB20-\uAB26\uAB28-\uAB2E\uAB30-\uAB5A\uAB5C-\uAB65\uAB70-\uABE2\uAC00-\uD7A3\uD7B0-\uD7C6\uD7CB-\uD7FB\uF900-\uFA6D\uFA70-\uFAD9\uFB00-\uFB06\uFB13-\uFB17\uFB1D\uFB1F-\uFB28\uFB2A-\uFB36\uFB38-\uFB3C\uFB3E\uFB40\uFB41\uFB43\uFB44\uFB46-\uFBB1\uFBD3-\uFD3D\uFD50-\uFD8F\uFD92-\uFDC7\uFDF0-\uFDFB\uFE70-\uFE74\uFE76-\uFEFC\uFF21-\uFF3A\uFF41-\uFF5A\uFF66-\uFFBE\uFFC2-\uFFC7\uFFCA-\uFFCF\uFFD2-\uFFD7\uFFDA-\uFFDC]|\uD800[\uDC00-\uDC0B\uDC0D-\uDC26\uDC28-\uDC3A\uDC3C\uDC3D\uDC3F-\uDC4D\uDC50-\uDC5D\uDC80-\uDCFA\uDD40-\uDD74\uDE80-\uDE9C\uDEA0-\uDED0\uDF00-\uDF1F\uDF2D-\uDF4A\uDF50-\uDF75\uDF80-\uDF9D\uDFA0-\uDFC3\uDFC8-\uDFCF\uDFD1-\uDFD5]|\uD801[\uDC00-\uDC9D\uDCB0-\uDCD3\uDCD8-\uDCFB\uDD00-\uDD27\uDD30-\uDD63\uDE00-\uDF36\uDF40-\uDF55\uDF60-\uDF67]|\uD802[\uDC00-\uDC05\uDC08\uDC0A-\uDC35\uDC37\uDC38\uDC3C\uDC3F-\uDC55\uDC60-\uDC76\uDC80-\uDC9E\uDCE0-\uDCF2\uDCF4\uDCF5\uDD00-\uDD15\uDD20-\uDD39\uDD80-\uDDB7\uDDBE\uDDBF\uDE00\uDE10-\uDE13\uDE15-\uDE17\uDE19-\uDE33\uDE60-\uDE7C\uDE80-\uDE9C\uDEC0-\uDEC7\uDEC9-\uDEE4\uDF00-\uDF35\uDF40-\uDF55\uDF60-\uDF72\uDF80-\uDF91]|\uD803[\uDC00-\uDC48\uDC80-\uDCB2\uDCC0-\uDCF2]|\uD804[\uDC03-\uDC37\uDC83-\uDCAF\uDCD0-\uDCE8\uDD03-\uDD26\uDD50-\uDD72\uDD76\uDD83-\uDDB2\uDDC1-\uDDC4\uDDDA\uDDDC\uDE00-\uDE11\uDE13-\uDE2B\uDE80-\uDE86\uDE88\uDE8A-\uDE8D\uDE8F-\uDE9D\uDE9F-\uDEA8\uDEB0-\uDEDE\uDF05-\uDF0C\uDF0F\uDF10\uDF13-\uDF28\uDF2A-\uDF30\uDF32\uDF33\uDF35-\uDF39\uDF3D\uDF50\uDF5D-\uDF61]|\uD805[\uDC00-\uDC34\uDC47-\uDC4A\uDC80-\uDCAF\uDCC4\uDCC5\uDCC7\uDD80-\uDDAE\uDDD8-\uDDDB\uDE00-\uDE2F\uDE44\uDE80-\uDEAA\uDF00-\uDF19]|\uD806[\uDCA0-\uDCDF\uDCFF\uDE00\uDE0B-\uDE32\uDE3A\uDE50\uDE5C-\uDE83\uDE86-\uDE89\uDEC0-\uDEF8]|\uD807[\uDC00-\uDC08\uDC0A-\uDC2E\uDC40\uDC72-\uDC8F\uDD00-\uDD06\uDD08\uDD09\uDD0B-\uDD30\uDD46]|\uD808[\uDC00-\uDF99]|\uD809[\uDC00-\uDC6E\uDC80-\uDD43]|[\uD80C\uD81C-\uD820\uD840-\uD868\uD86A-\uD86C\uD86F-\uD872\uD874-\uD879][\uDC00-\uDFFF]|\uD80D[\uDC00-\uDC2E]|\uD811[\uDC00-\uDE46]|\uD81A[\uDC00-\uDE38\uDE40-\uDE5E\uDED0-\uDEED\uDF00-\uDF2F\uDF40-\uDF43\uDF63-\uDF77\uDF7D-\uDF8F]|\uD81B[\uDF00-\uDF44\uDF50\uDF93-\uDF9F\uDFE0\uDFE1]|\uD821[\uDC00-\uDFEC]|\uD822[\uDC00-\uDEF2]|\uD82C[\uDC00-\uDD1E\uDD70-\uDEFB]|\uD82F[\uDC00-\uDC6A\uDC70-\uDC7C\uDC80-\uDC88\uDC90-\uDC99]|\uD835[\uDC00-\uDC54\uDC56-\uDC9C\uDC9E\uDC9F\uDCA2\uDCA5\uDCA6\uDCA9-\uDCAC\uDCAE-\uDCB9\uDCBB\uDCBD-\uDCC3\uDCC5-\uDD05\uDD07-\uDD0A\uDD0D-\uDD14\uDD16-\uDD1C\uDD1E-\uDD39\uDD3B-\uDD3E\uDD40-\uDD44\uDD46\uDD4A-\uDD50\uDD52-\uDEA5\uDEA8-\uDEC0\uDEC2-\uDEDA\uDEDC-\uDEFA\uDEFC-\uDF14\uDF16-\uDF34\uDF36-\uDF4E\uDF50-\uDF6E\uDF70-\uDF88\uDF8A-\uDFA8\uDFAA-\uDFC2\uDFC4-\uDFCB]|\uD83A[\uDC00-\uDCC4\uDD00-\uDD43]|\uD83B[\uDE00-\uDE03\uDE05-\uDE1F\uDE21\uDE22\uDE24\uDE27\uDE29-\uDE32\uDE34-\uDE37\uDE39\uDE3B\uDE42\uDE47\uDE49\uDE4B\uDE4D-\uDE4F\uDE51\uDE52\uDE54\uDE57\uDE59\uDE5B\uDE5D\uDE5F\uDE61\uDE62\uDE64\uDE67-\uDE6A\uDE6C-\uDE72\uDE74-\uDE77\uDE79-\uDE7C\uDE7E\uDE80-\uDE89\uDE8B-\uDE9B\uDEA1-\uDEA3\uDEA5-\uDEA9\uDEAB-\uDEBB]|\uD869[\uDC00-\uDED6\uDF00-\uDFFF]|\uD86D[\uDC00-\uDF34\uDF40-\uDFFF]|\uD86E[\uDC00-\uDC1D\uDC20-\uDFFF]|\uD873[\uDC00-\uDEA1\uDEB0-\uDFFF]|\uD87A[\uDC00-\uDFE0]|\uD87E[\uDC00-\uDE1D]/;
var ID_Continue = /[\xAA\xB5\xBA\xC0-\xD6\xD8-\xF6\xF8-\u02C1\u02C6-\u02D1\u02E0-\u02E4\u02EC\u02EE\u0300-\u0374\u0376\u0377\u037A-\u037D\u037F\u0386\u0388-\u038A\u038C\u038E-\u03A1\u03A3-\u03F5\u03F7-\u0481\u0483-\u0487\u048A-\u052F\u0531-\u0556\u0559\u0561-\u0587\u0591-\u05BD\u05BF\u05C1\u05C2\u05C4\u05C5\u05C7\u05D0-\u05EA\u05F0-\u05F2\u0610-\u061A\u0620-\u0669\u066E-\u06D3\u06D5-\u06DC\u06DF-\u06E8\u06EA-\u06FC\u06FF\u0710-\u074A\u074D-\u07B1\u07C0-\u07F5\u07FA\u0800-\u082D\u0840-\u085B\u0860-\u086A\u08A0-\u08B4\u08B6-\u08BD\u08D4-\u08E1\u08E3-\u0963\u0966-\u096F\u0971-\u0983\u0985-\u098C\u098F\u0990\u0993-\u09A8\u09AA-\u09B0\u09B2\u09B6-\u09B9\u09BC-\u09C4\u09C7\u09C8\u09CB-\u09CE\u09D7\u09DC\u09DD\u09DF-\u09E3\u09E6-\u09F1\u09FC\u0A01-\u0A03\u0A05-\u0A0A\u0A0F\u0A10\u0A13-\u0A28\u0A2A-\u0A30\u0A32\u0A33\u0A35\u0A36\u0A38\u0A39\u0A3C\u0A3E-\u0A42\u0A47\u0A48\u0A4B-\u0A4D\u0A51\u0A59-\u0A5C\u0A5E\u0A66-\u0A75\u0A81-\u0A83\u0A85-\u0A8D\u0A8F-\u0A91\u0A93-\u0AA8\u0AAA-\u0AB0\u0AB2\u0AB3\u0AB5-\u0AB9\u0ABC-\u0AC5\u0AC7-\u0AC9\u0ACB-\u0ACD\u0AD0\u0AE0-\u0AE3\u0AE6-\u0AEF\u0AF9-\u0AFF\u0B01-\u0B03\u0B05-\u0B0C\u0B0F\u0B10\u0B13-\u0B28\u0B2A-\u0B30\u0B32\u0B33\u0B35-\u0B39\u0B3C-\u0B44\u0B47\u0B48\u0B4B-\u0B4D\u0B56\u0B57\u0B5C\u0B5D\u0B5F-\u0B63\u0B66-\u0B6F\u0B71\u0B82\u0B83\u0B85-\u0B8A\u0B8E-\u0B90\u0B92-\u0B95\u0B99\u0B9A\u0B9C\u0B9E\u0B9F\u0BA3\u0BA4\u0BA8-\u0BAA\u0BAE-\u0BB9\u0BBE-\u0BC2\u0BC6-\u0BC8\u0BCA-\u0BCD\u0BD0\u0BD7\u0BE6-\u0BEF\u0C00-\u0C03\u0C05-\u0C0C\u0C0E-\u0C10\u0C12-\u0C28\u0C2A-\u0C39\u0C3D-\u0C44\u0C46-\u0C48\u0C4A-\u0C4D\u0C55\u0C56\u0C58-\u0C5A\u0C60-\u0C63\u0C66-\u0C6F\u0C80-\u0C83\u0C85-\u0C8C\u0C8E-\u0C90\u0C92-\u0CA8\u0CAA-\u0CB3\u0CB5-\u0CB9\u0CBC-\u0CC4\u0CC6-\u0CC8\u0CCA-\u0CCD\u0CD5\u0CD6\u0CDE\u0CE0-\u0CE3\u0CE6-\u0CEF\u0CF1\u0CF2\u0D00-\u0D03\u0D05-\u0D0C\u0D0E-\u0D10\u0D12-\u0D44\u0D46-\u0D48\u0D4A-\u0D4E\u0D54-\u0D57\u0D5F-\u0D63\u0D66-\u0D6F\u0D7A-\u0D7F\u0D82\u0D83\u0D85-\u0D96\u0D9A-\u0DB1\u0DB3-\u0DBB\u0DBD\u0DC0-\u0DC6\u0DCA\u0DCF-\u0DD4\u0DD6\u0DD8-\u0DDF\u0DE6-\u0DEF\u0DF2\u0DF3\u0E01-\u0E3A\u0E40-\u0E4E\u0E50-\u0E59\u0E81\u0E82\u0E84\u0E87\u0E88\u0E8A\u0E8D\u0E94-\u0E97\u0E99-\u0E9F\u0EA1-\u0EA3\u0EA5\u0EA7\u0EAA\u0EAB\u0EAD-\u0EB9\u0EBB-\u0EBD\u0EC0-\u0EC4\u0EC6\u0EC8-\u0ECD\u0ED0-\u0ED9\u0EDC-\u0EDF\u0F00\u0F18\u0F19\u0F20-\u0F29\u0F35\u0F37\u0F39\u0F3E-\u0F47\u0F49-\u0F6C\u0F71-\u0F84\u0F86-\u0F97\u0F99-\u0FBC\u0FC6\u1000-\u1049\u1050-\u109D\u10A0-\u10C5\u10C7\u10CD\u10D0-\u10FA\u10FC-\u1248\u124A-\u124D\u1250-\u1256\u1258\u125A-\u125D\u1260-\u1288\u128A-\u128D\u1290-\u12B0\u12B2-\u12B5\u12B8-\u12BE\u12C0\u12C2-\u12C5\u12C8-\u12D6\u12D8-\u1310\u1312-\u1315\u1318-\u135A\u135D-\u135F\u1380-\u138F\u13A0-\u13F5\u13F8-\u13FD\u1401-\u166C\u166F-\u167F\u1681-\u169A\u16A0-\u16EA\u16EE-\u16F8\u1700-\u170C\u170E-\u1714\u1720-\u1734\u1740-\u1753\u1760-\u176C\u176E-\u1770\u1772\u1773\u1780-\u17D3\u17D7\u17DC\u17DD\u17E0-\u17E9\u180B-\u180D\u1810-\u1819\u1820-\u1877\u1880-\u18AA\u18B0-\u18F5\u1900-\u191E\u1920-\u192B\u1930-\u193B\u1946-\u196D\u1970-\u1974\u1980-\u19AB\u19B0-\u19C9\u19D0-\u19D9\u1A00-\u1A1B\u1A20-\u1A5E\u1A60-\u1A7C\u1A7F-\u1A89\u1A90-\u1A99\u1AA7\u1AB0-\u1ABD\u1B00-\u1B4B\u1B50-\u1B59\u1B6B-\u1B73\u1B80-\u1BF3\u1C00-\u1C37\u1C40-\u1C49\u1C4D-\u1C7D\u1C80-\u1C88\u1CD0-\u1CD2\u1CD4-\u1CF9\u1D00-\u1DF9\u1DFB-\u1F15\u1F18-\u1F1D\u1F20-\u1F45\u1F48-\u1F4D\u1F50-\u1F57\u1F59\u1F5B\u1F5D\u1F5F-\u1F7D\u1F80-\u1FB4\u1FB6-\u1FBC\u1FBE\u1FC2-\u1FC4\u1FC6-\u1FCC\u1FD0-\u1FD3\u1FD6-\u1FDB\u1FE0-\u1FEC\u1FF2-\u1FF4\u1FF6-\u1FFC\u203F\u2040\u2054\u2071\u207F\u2090-\u209C\u20D0-\u20DC\u20E1\u20E5-\u20F0\u2102\u2107\u210A-\u2113\u2115\u2119-\u211D\u2124\u2126\u2128\u212A-\u212D\u212F-\u2139\u213C-\u213F\u2145-\u2149\u214E\u2160-\u2188\u2C00-\u2C2E\u2C30-\u2C5E\u2C60-\u2CE4\u2CEB-\u2CF3\u2D00-\u2D25\u2D27\u2D2D\u2D30-\u2D67\u2D6F\u2D7F-\u2D96\u2DA0-\u2DA6\u2DA8-\u2DAE\u2DB0-\u2DB6\u2DB8-\u2DBE\u2DC0-\u2DC6\u2DC8-\u2DCE\u2DD0-\u2DD6\u2DD8-\u2DDE\u2DE0-\u2DFF\u2E2F\u3005-\u3007\u3021-\u302F\u3031-\u3035\u3038-\u303C\u3041-\u3096\u3099\u309A\u309D-\u309F\u30A1-\u30FA\u30FC-\u30FF\u3105-\u312E\u3131-\u318E\u31A0-\u31BA\u31F0-\u31FF\u3400-\u4DB5\u4E00-\u9FEA\uA000-\uA48C\uA4D0-\uA4FD\uA500-\uA60C\uA610-\uA62B\uA640-\uA66F\uA674-\uA67D\uA67F-\uA6F1\uA717-\uA71F\uA722-\uA788\uA78B-\uA7AE\uA7B0-\uA7B7\uA7F7-\uA827\uA840-\uA873\uA880-\uA8C5\uA8D0-\uA8D9\uA8E0-\uA8F7\uA8FB\uA8FD\uA900-\uA92D\uA930-\uA953\uA960-\uA97C\uA980-\uA9C0\uA9CF-\uA9D9\uA9E0-\uA9FE\uAA00-\uAA36\uAA40-\uAA4D\uAA50-\uAA59\uAA60-\uAA76\uAA7A-\uAAC2\uAADB-\uAADD\uAAE0-\uAAEF\uAAF2-\uAAF6\uAB01-\uAB06\uAB09-\uAB0E\uAB11-\uAB16\uAB20-\uAB26\uAB28-\uAB2E\uAB30-\uAB5A\uAB5C-\uAB65\uAB70-\uABEA\uABEC\uABED\uABF0-\uABF9\uAC00-\uD7A3\uD7B0-\uD7C6\uD7CB-\uD7FB\uF900-\uFA6D\uFA70-\uFAD9\uFB00-\uFB06\uFB13-\uFB17\uFB1D-\uFB28\uFB2A-\uFB36\uFB38-\uFB3C\uFB3E\uFB40\uFB41\uFB43\uFB44\uFB46-\uFBB1\uFBD3-\uFD3D\uFD50-\uFD8F\uFD92-\uFDC7\uFDF0-\uFDFB\uFE00-\uFE0F\uFE20-\uFE2F\uFE33\uFE34\uFE4D-\uFE4F\uFE70-\uFE74\uFE76-\uFEFC\uFF10-\uFF19\uFF21-\uFF3A\uFF3F\uFF41-\uFF5A\uFF66-\uFFBE\uFFC2-\uFFC7\uFFCA-\uFFCF\uFFD2-\uFFD7\uFFDA-\uFFDC]|\uD800[\uDC00-\uDC0B\uDC0D-\uDC26\uDC28-\uDC3A\uDC3C\uDC3D\uDC3F-\uDC4D\uDC50-\uDC5D\uDC80-\uDCFA\uDD40-\uDD74\uDDFD\uDE80-\uDE9C\uDEA0-\uDED0\uDEE0\uDF00-\uDF1F\uDF2D-\uDF4A\uDF50-\uDF7A\uDF80-\uDF9D\uDFA0-\uDFC3\uDFC8-\uDFCF\uDFD1-\uDFD5]|\uD801[\uDC00-\uDC9D\uDCA0-\uDCA9\uDCB0-\uDCD3\uDCD8-\uDCFB\uDD00-\uDD27\uDD30-\uDD63\uDE00-\uDF36\uDF40-\uDF55\uDF60-\uDF67]|\uD802[\uDC00-\uDC05\uDC08\uDC0A-\uDC35\uDC37\uDC38\uDC3C\uDC3F-\uDC55\uDC60-\uDC76\uDC80-\uDC9E\uDCE0-\uDCF2\uDCF4\uDCF5\uDD00-\uDD15\uDD20-\uDD39\uDD80-\uDDB7\uDDBE\uDDBF\uDE00-\uDE03\uDE05\uDE06\uDE0C-\uDE13\uDE15-\uDE17\uDE19-\uDE33\uDE38-\uDE3A\uDE3F\uDE60-\uDE7C\uDE80-\uDE9C\uDEC0-\uDEC7\uDEC9-\uDEE6\uDF00-\uDF35\uDF40-\uDF55\uDF60-\uDF72\uDF80-\uDF91]|\uD803[\uDC00-\uDC48\uDC80-\uDCB2\uDCC0-\uDCF2]|\uD804[\uDC00-\uDC46\uDC66-\uDC6F\uDC7F-\uDCBA\uDCD0-\uDCE8\uDCF0-\uDCF9\uDD00-\uDD34\uDD36-\uDD3F\uDD50-\uDD73\uDD76\uDD80-\uDDC4\uDDCA-\uDDCC\uDDD0-\uDDDA\uDDDC\uDE00-\uDE11\uDE13-\uDE37\uDE3E\uDE80-\uDE86\uDE88\uDE8A-\uDE8D\uDE8F-\uDE9D\uDE9F-\uDEA8\uDEB0-\uDEEA\uDEF0-\uDEF9\uDF00-\uDF03\uDF05-\uDF0C\uDF0F\uDF10\uDF13-\uDF28\uDF2A-\uDF30\uDF32\uDF33\uDF35-\uDF39\uDF3C-\uDF44\uDF47\uDF48\uDF4B-\uDF4D\uDF50\uDF57\uDF5D-\uDF63\uDF66-\uDF6C\uDF70-\uDF74]|\uD805[\uDC00-\uDC4A\uDC50-\uDC59\uDC80-\uDCC5\uDCC7\uDCD0-\uDCD9\uDD80-\uDDB5\uDDB8-\uDDC0\uDDD8-\uDDDD\uDE00-\uDE40\uDE44\uDE50-\uDE59\uDE80-\uDEB7\uDEC0-\uDEC9\uDF00-\uDF19\uDF1D-\uDF2B\uDF30-\uDF39]|\uD806[\uDCA0-\uDCE9\uDCFF\uDE00-\uDE3E\uDE47\uDE50-\uDE83\uDE86-\uDE99\uDEC0-\uDEF8]|\uD807[\uDC00-\uDC08\uDC0A-\uDC36\uDC38-\uDC40\uDC50-\uDC59\uDC72-\uDC8F\uDC92-\uDCA7\uDCA9-\uDCB6\uDD00-\uDD06\uDD08\uDD09\uDD0B-\uDD36\uDD3A\uDD3C\uDD3D\uDD3F-\uDD47\uDD50-\uDD59]|\uD808[\uDC00-\uDF99]|\uD809[\uDC00-\uDC6E\uDC80-\uDD43]|[\uD80C\uD81C-\uD820\uD840-\uD868\uD86A-\uD86C\uD86F-\uD872\uD874-\uD879][\uDC00-\uDFFF]|\uD80D[\uDC00-\uDC2E]|\uD811[\uDC00-\uDE46]|\uD81A[\uDC00-\uDE38\uDE40-\uDE5E\uDE60-\uDE69\uDED0-\uDEED\uDEF0-\uDEF4\uDF00-\uDF36\uDF40-\uDF43\uDF50-\uDF59\uDF63-\uDF77\uDF7D-\uDF8F]|\uD81B[\uDF00-\uDF44\uDF50-\uDF7E\uDF8F-\uDF9F\uDFE0\uDFE1]|\uD821[\uDC00-\uDFEC]|\uD822[\uDC00-\uDEF2]|\uD82C[\uDC00-\uDD1E\uDD70-\uDEFB]|\uD82F[\uDC00-\uDC6A\uDC70-\uDC7C\uDC80-\uDC88\uDC90-\uDC99\uDC9D\uDC9E]|\uD834[\uDD65-\uDD69\uDD6D-\uDD72\uDD7B-\uDD82\uDD85-\uDD8B\uDDAA-\uDDAD\uDE42-\uDE44]|\uD835[\uDC00-\uDC54\uDC56-\uDC9C\uDC9E\uDC9F\uDCA2\uDCA5\uDCA6\uDCA9-\uDCAC\uDCAE-\uDCB9\uDCBB\uDCBD-\uDCC3\uDCC5-\uDD05\uDD07-\uDD0A\uDD0D-\uDD14\uDD16-\uDD1C\uDD1E-\uDD39\uDD3B-\uDD3E\uDD40-\uDD44\uDD46\uDD4A-\uDD50\uDD52-\uDEA5\uDEA8-\uDEC0\uDEC2-\uDEDA\uDEDC-\uDEFA\uDEFC-\uDF14\uDF16-\uDF34\uDF36-\uDF4E\uDF50-\uDF6E\uDF70-\uDF88\uDF8A-\uDFA8\uDFAA-\uDFC2\uDFC4-\uDFCB\uDFCE-\uDFFF]|\uD836[\uDE00-\uDE36\uDE3B-\uDE6C\uDE75\uDE84\uDE9B-\uDE9F\uDEA1-\uDEAF]|\uD838[\uDC00-\uDC06\uDC08-\uDC18\uDC1B-\uDC21\uDC23\uDC24\uDC26-\uDC2A]|\uD83A[\uDC00-\uDCC4\uDCD0-\uDCD6\uDD00-\uDD4A\uDD50-\uDD59]|\uD83B[\uDE00-\uDE03\uDE05-\uDE1F\uDE21\uDE22\uDE24\uDE27\uDE29-\uDE32\uDE34-\uDE37\uDE39\uDE3B\uDE42\uDE47\uDE49\uDE4B\uDE4D-\uDE4F\uDE51\uDE52\uDE54\uDE57\uDE59\uDE5B\uDE5D\uDE5F\uDE61\uDE62\uDE64\uDE67-\uDE6A\uDE6C-\uDE72\uDE74-\uDE77\uDE79-\uDE7C\uDE7E\uDE80-\uDE89\uDE8B-\uDE9B\uDEA1-\uDEA3\uDEA5-\uDEA9\uDEAB-\uDEBB]|\uD869[\uDC00-\uDED6\uDF00-\uDFFF]|\uD86D[\uDC00-\uDF34\uDF40-\uDFFF]|\uD86E[\uDC00-\uDC1D\uDC20-\uDFFF]|\uD873[\uDC00-\uDEA1\uDEB0-\uDFFF]|\uD87A[\uDC00-\uDFE0]|\uD87E[\uDC00-\uDE1D]|\uDB40[\uDD00-\uDDEF]/;
var unicode = {
  Space_Separator,
  ID_Start,
  ID_Continue
};
var util = {
  isSpaceSeparator(c2) {
    return typeof c2 === "string" && unicode.Space_Separator.test(c2);
  },
  isIdStartChar(c2) {
    return typeof c2 === "string" && (c2 >= "a" && c2 <= "z" || c2 >= "A" && c2 <= "Z" || c2 === "$" || c2 === "_" || unicode.ID_Start.test(c2));
  },
  isIdContinueChar(c2) {
    return typeof c2 === "string" && (c2 >= "a" && c2 <= "z" || c2 >= "A" && c2 <= "Z" || c2 >= "0" && c2 <= "9" || c2 === "$" || c2 === "_" || c2 === "‌" || c2 === "‍" || unicode.ID_Continue.test(c2));
  },
  isDigit(c2) {
    return typeof c2 === "string" && /[0-9]/.test(c2);
  },
  isHexDigit(c2) {
    return typeof c2 === "string" && /[0-9A-Fa-f]/.test(c2);
  }
};
let source;
let parseState;
let stack;
let pos;
let line;
let column;
let token;
let key;
let root;
var parse = function parse2(text2, reviver) {
  source = String(text2);
  parseState = "start";
  stack = [];
  pos = 0;
  line = 1;
  column = 0;
  token = void 0;
  key = void 0;
  root = void 0;
  do {
    token = lex();
    parseStates[parseState]();
  } while (token.type !== "eof");
  if (typeof reviver === "function") {
    return internalize({ "": root }, "", reviver);
  }
  return root;
};
function internalize(holder, name2, reviver) {
  const value = holder[name2];
  if (value != null && typeof value === "object") {
    if (Array.isArray(value)) {
      for (let i = 0; i < value.length; i++) {
        const key2 = String(i);
        const replacement = internalize(value, key2, reviver);
        if (replacement === void 0) {
          delete value[key2];
        } else {
          Object.defineProperty(value, key2, {
            value: replacement,
            writable: true,
            enumerable: true,
            configurable: true
          });
        }
      }
    } else {
      for (const key2 in value) {
        const replacement = internalize(value, key2, reviver);
        if (replacement === void 0) {
          delete value[key2];
        } else {
          Object.defineProperty(value, key2, {
            value: replacement,
            writable: true,
            enumerable: true,
            configurable: true
          });
        }
      }
    }
  }
  return reviver.call(holder, name2, value);
}
let lexState;
let buffer;
let doubleQuote;
let sign;
let c;
function lex() {
  lexState = "default";
  buffer = "";
  doubleQuote = false;
  sign = 1;
  for (; ; ) {
    c = peek();
    const token2 = lexStates[lexState]();
    if (token2) {
      return token2;
    }
  }
}
function peek() {
  if (source[pos]) {
    return String.fromCodePoint(source.codePointAt(pos));
  }
}
function read() {
  const c2 = peek();
  if (c2 === "\n") {
    line++;
    column = 0;
  } else if (c2) {
    column += c2.length;
  } else {
    column++;
  }
  if (c2) {
    pos += c2.length;
  }
  return c2;
}
const lexStates = {
  default() {
    switch (c) {
      case "	":
      case "\v":
      case "\f":
      case " ":
      case " ":
      case "\uFEFF":
      case "\n":
      case "\r":
      case "\u2028":
      case "\u2029":
        read();
        return;
      case "/":
        read();
        lexState = "comment";
        return;
      case void 0:
        read();
        return newToken("eof");
    }
    if (util.isSpaceSeparator(c)) {
      read();
      return;
    }
    return lexStates[parseState]();
  },
  comment() {
    switch (c) {
      case "*":
        read();
        lexState = "multiLineComment";
        return;
      case "/":
        read();
        lexState = "singleLineComment";
        return;
    }
    throw invalidChar(read());
  },
  multiLineComment() {
    switch (c) {
      case "*":
        read();
        lexState = "multiLineCommentAsterisk";
        return;
      case void 0:
        throw invalidChar(read());
    }
    read();
  },
  multiLineCommentAsterisk() {
    switch (c) {
      case "*":
        read();
        return;
      case "/":
        read();
        lexState = "default";
        return;
      case void 0:
        throw invalidChar(read());
    }
    read();
    lexState = "multiLineComment";
  },
  singleLineComment() {
    switch (c) {
      case "\n":
      case "\r":
      case "\u2028":
      case "\u2029":
        read();
        lexState = "default";
        return;
      case void 0:
        read();
        return newToken("eof");
    }
    read();
  },
  value() {
    switch (c) {
      case "{":
      case "[":
        return newToken("punctuator", read());
      case "n":
        read();
        literal("ull");
        return newToken("null", null);
      case "t":
        read();
        literal("rue");
        return newToken("boolean", true);
      case "f":
        read();
        literal("alse");
        return newToken("boolean", false);
      case "-":
      case "+":
        if (read() === "-") {
          sign = -1;
        }
        lexState = "sign";
        return;
      case ".":
        buffer = read();
        lexState = "decimalPointLeading";
        return;
      case "0":
        buffer = read();
        lexState = "zero";
        return;
      case "1":
      case "2":
      case "3":
      case "4":
      case "5":
      case "6":
      case "7":
      case "8":
      case "9":
        buffer = read();
        lexState = "decimalInteger";
        return;
      case "I":
        read();
        literal("nfinity");
        return newToken("numeric", Infinity);
      case "N":
        read();
        literal("aN");
        return newToken("numeric", NaN);
      case '"':
      case "'":
        doubleQuote = read() === '"';
        buffer = "";
        lexState = "string";
        return;
    }
    throw invalidChar(read());
  },
  identifierNameStartEscape() {
    if (c !== "u") {
      throw invalidChar(read());
    }
    read();
    const u = unicodeEscape();
    switch (u) {
      case "$":
      case "_":
        break;
      default:
        if (!util.isIdStartChar(u)) {
          throw invalidIdentifier();
        }
        break;
    }
    buffer += u;
    lexState = "identifierName";
  },
  identifierName() {
    switch (c) {
      case "$":
      case "_":
      case "‌":
      case "‍":
        buffer += read();
        return;
      case "\\":
        read();
        lexState = "identifierNameEscape";
        return;
    }
    if (util.isIdContinueChar(c)) {
      buffer += read();
      return;
    }
    return newToken("identifier", buffer);
  },
  identifierNameEscape() {
    if (c !== "u") {
      throw invalidChar(read());
    }
    read();
    const u = unicodeEscape();
    switch (u) {
      case "$":
      case "_":
      case "‌":
      case "‍":
        break;
      default:
        if (!util.isIdContinueChar(u)) {
          throw invalidIdentifier();
        }
        break;
    }
    buffer += u;
    lexState = "identifierName";
  },
  sign() {
    switch (c) {
      case ".":
        buffer = read();
        lexState = "decimalPointLeading";
        return;
      case "0":
        buffer = read();
        lexState = "zero";
        return;
      case "1":
      case "2":
      case "3":
      case "4":
      case "5":
      case "6":
      case "7":
      case "8":
      case "9":
        buffer = read();
        lexState = "decimalInteger";
        return;
      case "I":
        read();
        literal("nfinity");
        return newToken("numeric", sign * Infinity);
      case "N":
        read();
        literal("aN");
        return newToken("numeric", NaN);
    }
    throw invalidChar(read());
  },
  zero() {
    switch (c) {
      case ".":
        buffer += read();
        lexState = "decimalPoint";
        return;
      case "e":
      case "E":
        buffer += read();
        lexState = "decimalExponent";
        return;
      case "x":
      case "X":
        buffer += read();
        lexState = "hexadecimal";
        return;
    }
    return newToken("numeric", sign * 0);
  },
  decimalInteger() {
    switch (c) {
      case ".":
        buffer += read();
        lexState = "decimalPoint";
        return;
      case "e":
      case "E":
        buffer += read();
        lexState = "decimalExponent";
        return;
    }
    if (util.isDigit(c)) {
      buffer += read();
      return;
    }
    return newToken("numeric", sign * Number(buffer));
  },
  decimalPointLeading() {
    if (util.isDigit(c)) {
      buffer += read();
      lexState = "decimalFraction";
      return;
    }
    throw invalidChar(read());
  },
  decimalPoint() {
    switch (c) {
      case "e":
      case "E":
        buffer += read();
        lexState = "decimalExponent";
        return;
    }
    if (util.isDigit(c)) {
      buffer += read();
      lexState = "decimalFraction";
      return;
    }
    return newToken("numeric", sign * Number(buffer));
  },
  decimalFraction() {
    switch (c) {
      case "e":
      case "E":
        buffer += read();
        lexState = "decimalExponent";
        return;
    }
    if (util.isDigit(c)) {
      buffer += read();
      return;
    }
    return newToken("numeric", sign * Number(buffer));
  },
  decimalExponent() {
    switch (c) {
      case "+":
      case "-":
        buffer += read();
        lexState = "decimalExponentSign";
        return;
    }
    if (util.isDigit(c)) {
      buffer += read();
      lexState = "decimalExponentInteger";
      return;
    }
    throw invalidChar(read());
  },
  decimalExponentSign() {
    if (util.isDigit(c)) {
      buffer += read();
      lexState = "decimalExponentInteger";
      return;
    }
    throw invalidChar(read());
  },
  decimalExponentInteger() {
    if (util.isDigit(c)) {
      buffer += read();
      return;
    }
    return newToken("numeric", sign * Number(buffer));
  },
  hexadecimal() {
    if (util.isHexDigit(c)) {
      buffer += read();
      lexState = "hexadecimalInteger";
      return;
    }
    throw invalidChar(read());
  },
  hexadecimalInteger() {
    if (util.isHexDigit(c)) {
      buffer += read();
      return;
    }
    return newToken("numeric", sign * Number(buffer));
  },
  string() {
    switch (c) {
      case "\\":
        read();
        buffer += escape();
        return;
      case '"':
        if (doubleQuote) {
          read();
          return newToken("string", buffer);
        }
        buffer += read();
        return;
      case "'":
        if (!doubleQuote) {
          read();
          return newToken("string", buffer);
        }
        buffer += read();
        return;
      case "\n":
      case "\r":
        throw invalidChar(read());
      case "\u2028":
      case "\u2029":
        separatorChar(c);
        break;
      case void 0:
        throw invalidChar(read());
    }
    buffer += read();
  },
  start() {
    switch (c) {
      case "{":
      case "[":
        return newToken("punctuator", read());
    }
    lexState = "value";
  },
  beforePropertyName() {
    switch (c) {
      case "$":
      case "_":
        buffer = read();
        lexState = "identifierName";
        return;
      case "\\":
        read();
        lexState = "identifierNameStartEscape";
        return;
      case "}":
        return newToken("punctuator", read());
      case '"':
      case "'":
        doubleQuote = read() === '"';
        lexState = "string";
        return;
    }
    if (util.isIdStartChar(c)) {
      buffer += read();
      lexState = "identifierName";
      return;
    }
    throw invalidChar(read());
  },
  afterPropertyName() {
    if (c === ":") {
      return newToken("punctuator", read());
    }
    throw invalidChar(read());
  },
  beforePropertyValue() {
    lexState = "value";
  },
  afterPropertyValue() {
    switch (c) {
      case ",":
      case "}":
        return newToken("punctuator", read());
    }
    throw invalidChar(read());
  },
  beforeArrayValue() {
    if (c === "]") {
      return newToken("punctuator", read());
    }
    lexState = "value";
  },
  afterArrayValue() {
    switch (c) {
      case ",":
      case "]":
        return newToken("punctuator", read());
    }
    throw invalidChar(read());
  },
  end() {
    throw invalidChar(read());
  }
};
function newToken(type, value) {
  return {
    type,
    value,
    line,
    column
  };
}
function literal(s) {
  for (const c2 of s) {
    const p = peek();
    if (p !== c2) {
      throw invalidChar(read());
    }
    read();
  }
}
function escape() {
  const c2 = peek();
  switch (c2) {
    case "b":
      read();
      return "\b";
    case "f":
      read();
      return "\f";
    case "n":
      read();
      return "\n";
    case "r":
      read();
      return "\r";
    case "t":
      read();
      return "	";
    case "v":
      read();
      return "\v";
    case "0":
      read();
      if (util.isDigit(peek())) {
        throw invalidChar(read());
      }
      return "\0";
    case "x":
      read();
      return hexEscape();
    case "u":
      read();
      return unicodeEscape();
    case "\n":
    case "\u2028":
    case "\u2029":
      read();
      return "";
    case "\r":
      read();
      if (peek() === "\n") {
        read();
      }
      return "";
    case "1":
    case "2":
    case "3":
    case "4":
    case "5":
    case "6":
    case "7":
    case "8":
    case "9":
      throw invalidChar(read());
    case void 0:
      throw invalidChar(read());
  }
  return read();
}
function hexEscape() {
  let buffer2 = "";
  let c2 = peek();
  if (!util.isHexDigit(c2)) {
    throw invalidChar(read());
  }
  buffer2 += read();
  c2 = peek();
  if (!util.isHexDigit(c2)) {
    throw invalidChar(read());
  }
  buffer2 += read();
  return String.fromCodePoint(parseInt(buffer2, 16));
}
function unicodeEscape() {
  let buffer2 = "";
  let count = 4;
  while (count-- > 0) {
    const c2 = peek();
    if (!util.isHexDigit(c2)) {
      throw invalidChar(read());
    }
    buffer2 += read();
  }
  return String.fromCodePoint(parseInt(buffer2, 16));
}
const parseStates = {
  start() {
    if (token.type === "eof") {
      throw invalidEOF();
    }
    push();
  },
  beforePropertyName() {
    switch (token.type) {
      case "identifier":
      case "string":
        key = token.value;
        parseState = "afterPropertyName";
        return;
      case "punctuator":
        pop();
        return;
      case "eof":
        throw invalidEOF();
    }
  },
  afterPropertyName() {
    if (token.type === "eof") {
      throw invalidEOF();
    }
    parseState = "beforePropertyValue";
  },
  beforePropertyValue() {
    if (token.type === "eof") {
      throw invalidEOF();
    }
    push();
  },
  beforeArrayValue() {
    if (token.type === "eof") {
      throw invalidEOF();
    }
    if (token.type === "punctuator" && token.value === "]") {
      pop();
      return;
    }
    push();
  },
  afterPropertyValue() {
    if (token.type === "eof") {
      throw invalidEOF();
    }
    switch (token.value) {
      case ",":
        parseState = "beforePropertyName";
        return;
      case "}":
        pop();
    }
  },
  afterArrayValue() {
    if (token.type === "eof") {
      throw invalidEOF();
    }
    switch (token.value) {
      case ",":
        parseState = "beforeArrayValue";
        return;
      case "]":
        pop();
    }
  },
  end() {
  }
};
function push() {
  let value;
  switch (token.type) {
    case "punctuator":
      switch (token.value) {
        case "{":
          value = {};
          break;
        case "[":
          value = [];
          break;
      }
      break;
    case "null":
    case "boolean":
    case "numeric":
    case "string":
      value = token.value;
      break;
  }
  if (root === void 0) {
    root = value;
  } else {
    const parent = stack[stack.length - 1];
    if (Array.isArray(parent)) {
      parent.push(value);
    } else {
      Object.defineProperty(parent, key, {
        value,
        writable: true,
        enumerable: true,
        configurable: true
      });
    }
  }
  if (value !== null && typeof value === "object") {
    stack.push(value);
    if (Array.isArray(value)) {
      parseState = "beforeArrayValue";
    } else {
      parseState = "beforePropertyName";
    }
  } else {
    const current = stack[stack.length - 1];
    if (current == null) {
      parseState = "end";
    } else if (Array.isArray(current)) {
      parseState = "afterArrayValue";
    } else {
      parseState = "afterPropertyValue";
    }
  }
}
function pop() {
  stack.pop();
  const current = stack[stack.length - 1];
  if (current == null) {
    parseState = "end";
  } else if (Array.isArray(current)) {
    parseState = "afterArrayValue";
  } else {
    parseState = "afterPropertyValue";
  }
}
function invalidChar(c2) {
  if (c2 === void 0) {
    return syntaxError(`JSON5: invalid end of input at ${line}:${column}`);
  }
  return syntaxError(`JSON5: invalid character '${formatChar(c2)}' at ${line}:${column}`);
}
function invalidEOF() {
  return syntaxError(`JSON5: invalid end of input at ${line}:${column}`);
}
function invalidIdentifier() {
  column -= 5;
  return syntaxError(`JSON5: invalid identifier character at ${line}:${column}`);
}
function separatorChar(c2) {
  console.warn(`JSON5: '${formatChar(c2)}' in strings is not valid ECMAScript; consider escaping`);
}
function formatChar(c2) {
  const replacements = {
    "'": "\\'",
    '"': '\\"',
    "\\": "\\\\",
    "\b": "\\b",
    "\f": "\\f",
    "\n": "\\n",
    "\r": "\\r",
    "	": "\\t",
    "\v": "\\v",
    "\0": "\\0",
    "\u2028": "\\u2028",
    "\u2029": "\\u2029"
  };
  if (replacements[c2]) {
    return replacements[c2];
  }
  if (c2 < " ") {
    const hexString = c2.charCodeAt(0).toString(16);
    return "\\x" + ("00" + hexString).substring(hexString.length);
  }
  return c2;
}
function syntaxError(message) {
  const err = new SyntaxError(message);
  err.lineNumber = line;
  err.columnNumber = column;
  return err;
}
var stringify = function stringify2(value, replacer, space) {
  const stack2 = [];
  let indent = "";
  let propertyList;
  let replacerFunc;
  let gap = "";
  let quote;
  if (replacer != null && typeof replacer === "object" && !Array.isArray(replacer)) {
    space = replacer.space;
    quote = replacer.quote;
    replacer = replacer.replacer;
  }
  if (typeof replacer === "function") {
    replacerFunc = replacer;
  } else if (Array.isArray(replacer)) {
    propertyList = [];
    for (const v of replacer) {
      let item;
      if (typeof v === "string") {
        item = v;
      } else if (typeof v === "number" || v instanceof String || v instanceof Number) {
        item = String(v);
      }
      if (item !== void 0 && propertyList.indexOf(item) < 0) {
        propertyList.push(item);
      }
    }
  }
  if (space instanceof Number) {
    space = Number(space);
  } else if (space instanceof String) {
    space = String(space);
  }
  if (typeof space === "number") {
    if (space > 0) {
      space = Math.min(10, Math.floor(space));
      gap = "          ".substr(0, space);
    }
  } else if (typeof space === "string") {
    gap = space.substr(0, 10);
  }
  return serializeProperty("", { "": value });
  function serializeProperty(key2, holder) {
    let value2 = holder[key2];
    if (value2 != null) {
      if (typeof value2.toJSON5 === "function") {
        value2 = value2.toJSON5(key2);
      } else if (typeof value2.toJSON === "function") {
        value2 = value2.toJSON(key2);
      }
    }
    if (replacerFunc) {
      value2 = replacerFunc.call(holder, key2, value2);
    }
    if (value2 instanceof Number) {
      value2 = Number(value2);
    } else if (value2 instanceof String) {
      value2 = String(value2);
    } else if (value2 instanceof Boolean) {
      value2 = value2.valueOf();
    }
    switch (value2) {
      case null:
        return "null";
      case true:
        return "true";
      case false:
        return "false";
    }
    if (typeof value2 === "string") {
      return quoteString(value2);
    }
    if (typeof value2 === "number") {
      return String(value2);
    }
    if (typeof value2 === "object") {
      return Array.isArray(value2) ? serializeArray(value2) : serializeObject(value2);
    }
    return void 0;
  }
  function quoteString(value2) {
    const quotes = {
      "'": 0.1,
      '"': 0.2
    };
    const replacements = {
      "'": "\\'",
      '"': '\\"',
      "\\": "\\\\",
      "\b": "\\b",
      "\f": "\\f",
      "\n": "\\n",
      "\r": "\\r",
      "	": "\\t",
      "\v": "\\v",
      "\0": "\\0",
      "\u2028": "\\u2028",
      "\u2029": "\\u2029"
    };
    let product = "";
    for (let i = 0; i < value2.length; i++) {
      const c2 = value2[i];
      switch (c2) {
        case "'":
        case '"':
          quotes[c2]++;
          product += c2;
          continue;
        case "\0":
          if (util.isDigit(value2[i + 1])) {
            product += "\\x00";
            continue;
          }
      }
      if (replacements[c2]) {
        product += replacements[c2];
        continue;
      }
      if (c2 < " ") {
        let hexString = c2.charCodeAt(0).toString(16);
        product += "\\x" + ("00" + hexString).substring(hexString.length);
        continue;
      }
      product += c2;
    }
    const quoteChar = quote || Object.keys(quotes).reduce((a, b) => quotes[a] < quotes[b] ? a : b);
    product = product.replace(new RegExp(quoteChar, "g"), replacements[quoteChar]);
    return quoteChar + product + quoteChar;
  }
  function serializeObject(value2) {
    if (stack2.indexOf(value2) >= 0) {
      throw TypeError("Converting circular structure to JSON5");
    }
    stack2.push(value2);
    let stepback = indent;
    indent = indent + gap;
    let keys = propertyList || Object.keys(value2);
    let partial = [];
    for (const key2 of keys) {
      const propertyString = serializeProperty(key2, value2);
      if (propertyString !== void 0) {
        let member = serializeKey(key2) + ":";
        if (gap !== "") {
          member += " ";
        }
        member += propertyString;
        partial.push(member);
      }
    }
    let final;
    if (partial.length === 0) {
      final = "{}";
    } else {
      let properties;
      if (gap === "") {
        properties = partial.join(",");
        final = "{" + properties + "}";
      } else {
        let separator = ",\n" + indent;
        properties = partial.join(separator);
        final = "{\n" + indent + properties + ",\n" + stepback + "}";
      }
    }
    stack2.pop();
    indent = stepback;
    return final;
  }
  function serializeKey(key2) {
    if (key2.length === 0) {
      return quoteString(key2);
    }
    const firstChar = String.fromCodePoint(key2.codePointAt(0));
    if (!util.isIdStartChar(firstChar)) {
      return quoteString(key2);
    }
    for (let i = firstChar.length; i < key2.length; i++) {
      if (!util.isIdContinueChar(String.fromCodePoint(key2.codePointAt(i)))) {
        return quoteString(key2);
      }
    }
    return key2;
  }
  function serializeArray(value2) {
    if (stack2.indexOf(value2) >= 0) {
      throw TypeError("Converting circular structure to JSON5");
    }
    stack2.push(value2);
    let stepback = indent;
    indent = indent + gap;
    let partial = [];
    for (let i = 0; i < value2.length; i++) {
      const propertyString = serializeProperty(String(i), value2);
      partial.push(propertyString !== void 0 ? propertyString : "null");
    }
    let final;
    if (partial.length === 0) {
      final = "[]";
    } else {
      if (gap === "") {
        let properties = partial.join(",");
        final = "[" + properties + "]";
      } else {
        let separator = ",\n" + indent;
        let properties = partial.join(separator);
        final = "[\n" + indent + properties + ",\n" + stepback + "]";
      }
    }
    stack2.pop();
    indent = stepback;
    return final;
  }
};
const JSON5 = {
  parse,
  stringify
};
var lib = JSON5;
const skins = Object.assign({}, def$1, narrow, lowkey);
function render(src) {
  if (src === void 0) {
    return;
  }
  const source2 = lib.parse(src);
  const res = lib$2.renderAny(0, source2, skins);
  const attrs = res[1];
  if (!("xmlns" in attrs)) {
    attrs.xmlns = "http://www.w3.org/2000/svg";
  }
  const svg = onml.s(res);
  return svg;
}
render(void 0);
