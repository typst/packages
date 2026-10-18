
#let fa(name) = {
  text(
    font: "Font Awesome 6 Free Solid",
    size: 10pt,
    box[ #name ]
  )
}

// Regular icons

#let ad = symbol("\u{f641}")
#let address-book = symbol("\u{f2b9}")
#let address-card = symbol("\u{f2bb}")
#let adjust = symbol("\u{f042}")
#let air-freshener = symbol("\u{f5d0}")
#let align-icon = symbol(
  ("left",    "\u{f036}"),
  ("center",  "\u{f037}"),
  ("right",   "\u{f038}"),
  ("justify", "\u{f039}"),
)
#let allergies = symbol("\u{f461}")
#let ambulance = symbol("\u{f0f9}")
#let american-sign-language-interpreting = symbol("\u{f2a3}")
#let anchor = symbol("\u{f13d}")
#let angle = symbol(
  ("left",         "\u{f104}"), // by default angle.left
  ("right",        "\u{f105}"),
  ("up",           "\u{f106}"),
  ("down",         "\u{f107}"),
  ("double.left",  "\u{f100}"),
  ("double.right", "\u{f101}"),
  ("double.up",    "\u{f102}"),
  ("double.down",  "\u{f103}"),
)
#let angry = symbol("\u{f556}")
#let ankh = symbol("\u{f644}")
#let apple = symbol(
  "\u{f179}",
  ("alt", "\u{f5d1}"),
  ("pay", "\u{f415}"),
  ("pay.cc", "\u{f416}")
)
#let archive = symbol("\u{f187}")
#let archway = symbol("\u{f557}")
#let arrow-icon = symbol(
  ("left",             "\u{f060}"),
  ("right",            "\u{f061}"),
  ("up",               "\u{f062}"),
  ("down",             "\u{f063}"),
  ("circle.left",      "\u{f0a8}"),
  ("circle.right",     "\u{f0a9}"),
  ("circle.up",        "\u{f0aa}"),
  ("circle.down",      "\u{f0ab}"),
  ("circle.alt.down",  "\u{f358}"),
  ("circle.alt.left",  "\u{f359}"),
  ("circle.alt.right", "\u{f35a}"),
  ("circle.alt.up",    "\u{f35b}"),
  ("long.down",        "\u{f309}"),
  ("long.left",        "\u{f30a}"),
  ("long.right",       "\u{f30b}"),
  ("long.up",          "\u{f30c}"),
  ("plural", "\u{f0b2}"),
  ("plural.h", "\u{f337}"),
  ("plural.v", "\u{f338}"),
)

#let assistive-listening-systems = symbol("\u{f2a2}")
#let asterisk = symbol("\u{f069}")
#let at = symbol("\u{f1fa}")
#let atlas = symbol("\u{f558}")
#let atom = symbol("\u{f5d2}")
#let audio-description = symbol("\u{f29e}")
#let award = symbol("\u{f559}")
#let baby = symbol("\u{f77c}")
#let baby-carriage = symbol("\u{f77d}")
#let backspace = symbol("\u{f55a}")
#let backward = symbol("\u{f04a}")
#let bacon = symbol("\u{f7e5}")
#let bacterium = symbol(
  "\u{e05a}",
  ("plural", "\u{e059}")
)


#let bahai = symbol("\u{f666}")
#let balance-scale = symbol(
  "\u{f24e}",
  ("balance-scale.left", "\u{f515}"),
  ("balance-scale.right", "\u{f516}"),
)
#let ball = symbol(
  ("basketball", "\u{f434}"),
  ("baseball", "\u{f433}"),
  ("bowling", "\u{f436}"),
  ("football", "\u{f44e}"),
  ("golf", "\u{f450}"),
  ("volleyball", "\u{f45f}"),
)
#let ban = symbol("\u{f05e}")
#let band-aid = symbol("\u{f462}")
#let barcode = symbol("\u{f02a}")
#let bars = symbol("\u{f0c9}")
#let bath = symbol("\u{f2cd}")
#let battery = symbol(
  ("empty", "\u{f244}"),
  ("full", "\u{f240}"),
  ("half", "\u{f242}"),
  ("quarter", "\u{f243}"),
  ("three-quarters", "\u{f241}"),
)
#let bed = symbol("\u{f236}")
#let beer = symbol("\u{f0fc}")
#let bell = symbol(
  "\u{f0f3}",
  ("slash", "\u{f1f6}"),
  ("concierge", "\u{f562}"),
)

#let bezier-curve = symbol("\u{f55b}")
#let bible = symbol("\u{f647}")
#let bicycle = symbol("\u{f206}")
#let biking = symbol("\u{f84a}")
#let binoculars = symbol("\u{f1e5}")
#let biohazard = symbol("\u{f780}")
#let birthday-cake = symbol("\u{f1fd}")
#let blender = symbol(
  "\u{f517}",
  ("phone", "\u{f6b6}"),
)

#let blind = symbol("\u{f29d}")
#let blog = symbol("\u{f781}")
#let bold = symbol("\u{f032}")
#let bolt = symbol("\u{f0e7}")
#let bomb = symbol("\u{f1e2}")
#let bone = symbol("\u{f5d7}")
#let bong = symbol("\u{f55c}")
#let book = symbol(
  "\u{f02d}",
  ("dead", "\u{f6b7}"),
  ("medical", "\u{f7e6}"),
  ("open", "\u{f518}"),
  ("reader", "\u{f5da}"),
)


#let bookmark = symbol("\u{f02e}")
#let border = symbol(
  ("all", "\u{f84c}"),
  ("none", "\u{f850}"),
  ("style", "\u{f853}"),
)

#let box-icon = symbol(
  "\u{f466}",
  ("open", "\u{f49e}"),
  ("tissue", "\u{e05b}"),
  ("plural", "\u{f468}"),
)
#let braille = symbol("\u{f2a1}")
#let brain = symbol("\u{f5dc}")
#let bread-slice = symbol("\u{f7ec}")
#let briefcase = symbol(
  "\u{f0b1}",
  ("medical", "\u{f469}"),
)
#let broadcast-tower = symbol("\u{f519}")
#let broom = symbol("\u{f51a}")
#let brush = symbol("\u{f55d}")
#let bug = symbol("\u{f188}")
#let building = symbol("\u{f1ad}")
#let bullhorn = symbol("\u{f0a1}")
#let bullseye = symbol("\u{f140}")
#let burn = symbol("\u{f46a}")
#let bus = symbol(
  "\u{f207}",
  ("alt", "\u{f55e}"),
)
#let business-time = symbol("\u{f64a}")
#let calculator = symbol("\u{f1ec}")
#let calendar = symbol(
  "\u{f133}",
  ("alt", "\u{f073}"),
  ("check", "\u{f274}"),
  ("day", "\u{f783}"),
  ("minus", "\u{f272}"),
  ("plus", "\u{f271}"),
  ("times", "\u{f273}"),
  ("week", "\u{f784}"),
)
#let camera = symbol(
  "\u{f030}",
  ("retro", "\u{f083}"),
)
#let campground = symbol("\u{f6bb}")
#let candy-cane = symbol("\u{f786}")
#let cannabis = symbol("\u{f55f}")
#let capsules = symbol("\u{f46b}")
#let car = symbol(
  "\u{f1b9}",
  ("alt", "\u{f5de}"),
  ("battery", "\u{f5df}"),
  ("crash", "\u{f5e1}"),
  ("side", "\u{f5e4}"),
)
#let caravan = symbol("\u{f8ff}")
#let caret = symbol(
  ("down", "\u{f0d7}"),
  ("up", "\u{f0d8}"),
  ("left", "\u{f0d9}"),
  ("right", "\u{f0da}"),
  ("square.down", "\u{f150}"),
  ("square.up", "\u{f151}"),
  ("square.right", "\u{f152}"),
  ("square.left", "\u{f191}"),
)
#let carrot = symbol("\u{f787}")
#let cart = symbol(
  "\u{f07a}",
  ("plus", "\u{f217}"),
  ("arrow.down", "\u{f218}"),
)
#let cash-register = symbol("\u{f788}")
#let cat = symbol("\u{f6be}")
#let certificate = symbol("\u{f0a3}")
#let chair = symbol("\u{f6c0}")
#let chalkboard = symbol(
  "\u{f51b}",
  ("teacher", "\u{f51c}"),
)
#let charging-station = symbol("\u{f5e7}")
#let chart = symbol(
  ("bar", "\u{f080}"),
  ("area", "\u{f1fe}"),
  ("pie", "\u{f200}"),
  ("line", "\u{f201}"),
)
#let check = symbol(
  "\u{f00c}",
  ("circle", "\u{f058}"),
  ("double", "\u{f560}"),
  ("square", "\u{f14a}"),
)
#let cheese = symbol("\u{f7ef}")
#let chess = symbol(
  "\u{f439}",
  ("bishop", "\u{f43a}"),
  ("board", "\u{f43c}"),
  ("king", "\u{f43f}"),
  ("knight", "\u{f441}"),
  ("pawn", "\u{f443}"),
  ("queen", "\u{f445}"),
  ("rook", "\u{f447}"),
)
#let chevron = symbol(
  ("left", "\u{f053}"),
  ("right", "\u{f054}"),
  ("up", "\u{f077}"),
  ("down", "\u{f078}"),
  ("circle.left", "\u{f137}"),
  ("circle.right", "\u{f138}"),
  ("circle.up", "\u{f139}"),
  ("circle.down", "\u{f13a}"),
)
#let child = symbol("\u{f1ae}")
#let church = symbol("\u{f51d}")

#let circle-icon = symbol(
  "\u{f111}",
  ("notch", "\u{f1ce}"),
)
#let city = symbol("\u{f64f}")
#let clinic-medical = symbol("\u{f7f2}")
#let clipboard = symbol(
  "\u{f328}",
  ("check", "\u{f46c}"),
  ("list", "\u{f46d}"),
)
#let clock = symbol("\u{f017}")
#let clone = symbol("\u{f24d}")
#let closed-captioning = symbol("\u{f20a}")
#let cloud = symbol(
  "\u{f0c2}",
  ("download", "\u{f381}"),
  ("meatball", "\u{f73b}"),
  ("moon", "\u{f6c3}"),
  ("moon.rain", "\u{f73c}"),
  ("rain", "\u{f73d}"),
  ("rain.heavy", "\u{f740}"),
  ("sun", "\u{f6c4}"),
  ("sun.rain", "\u{f743}"),
  ("upload", "\u{f382}"),
)
#let cocktail = symbol("\u{f561}")
#let code = symbol(
  "\u{f121}",
  ("branch", "\u{f126}"),
)
#let coffee = symbol("\u{f0f4}")
#let cog = symbol(
  "\u{f013}",
  ("plural", "\u{f085}"),
)
#let coins = symbol("\u{f51e}")
#let columns = symbol("\u{f0db}")
#let comment = symbol(
  "\u{f075}",
  ("alt", "\u{f27a}"),
  ("dollar", "\u{f651}"),
  ("dots", "\u{f4ad}"),
  ("medical", "\u{f7f5}"),
  ("slash", "\u{f4b3}"),
  ("plural.", "\u{f086}"),
  ("plural.dollar", "\u{f653}"),
)
#let compact-disc = symbol("\u{f51f}")
#let compass = symbol("\u{f14e}")
#let compress = symbol(
  "\u{f066}",
  ("alt", "\u{f422}"),
  ("alt.arrows", "\u{f78c}"),
)

#let cookie = symbol(
  "\u{f563}",
  ("bite", "\u{f564}"),
)
#let copy = symbol("\u{f0c5}")
#let copyright = symbol("\u{f1f9}")
#let couch = symbol("\u{f4b8}")
#let credit-card = symbol("\u{f09d}")
#let crop = symbol(
  "\u{f125}",
  ("alt", "\u{f565}"),
)
#let cross = symbol("\u{f654}")
#let crosshairs = symbol("\u{f05b}")
#let crow = symbol("\u{f520}")
#let crown = symbol("\u{f521}")
#let crutch = symbol("\u{f7f7}")
#let cube = symbol(
  "\u{f1b2}",
  ("plural", "\u{f1b3}"),
)
#let cut = symbol("\u{f0c4}")
#let database = symbol("\u{f1c0}")
#let deaf = symbol("\u{f2a4}")
#let democrat = symbol("\u{f747}")
#let desktop = symbol("\u{f108}")
#let dharmachakra = symbol("\u{f655}")
#let diagnoses = symbol("\u{f470}")
#let dice = symbol(
  "\u{f522}",
  ("d20", "\u{f6cf}"),
  ("d6", "\u{f6d1}"),
  ("five", "\u{f523}"),
  ("four", "\u{f524}"),
  ("one", "\u{f525}"),
  ("six", "\u{f526}"),
  ("three", "\u{f527}"),
  ("two", "\u{f528}"),
)
#let digital-tachograph = symbol("\u{f566}")
#let directions = symbol("\u{f5eb}")
#let disease = symbol("\u{f7fa}")
#let divide = symbol("\u{f529}")
#let dizzy = symbol("\u{f567}")
#let dna = symbol("\u{f471}")
#let dog = symbol("\u{f6d3}")
#let dolly = symbol(
  "\u{f472}",
  ("flatbed", "\u{f474}"),
)
#let donate = symbol("\u{f4b9}")
#let door = symbol(
  ("closed", "\u{f52a}"),
  ("open", "\u{f52b}"),
)
#let dot-circle = symbol("\u{f192}")
#let dove = symbol("\u{f4ba}")
#let download = symbol("\u{f019}")
#let drafting-compass = symbol("\u{f568}")
#let dragon = symbol("\u{f6d5}")
#let draw-polygon = symbol("\u{f5ee}")
#let drum = symbol(
  "\u{f569}",
  ("steelpan", "\u{f56a}"),
)
#let drumstick-bite = symbol("\u{f6d7}")
#let dumbbell = symbol("\u{f44b}")
#let dumpster = symbol(
  "\u{f793}",
  ("fire", "\u{f794}"),
)
#let dungeon = symbol("\u{f6d9}")
#let edit = symbol("\u{f044}")
#let egg = symbol("\u{f7fb}")
#let eject = symbol("\u{f052}")
#let ellipsis = symbol(
  ("h", "\u{f141}"),
  ("v", "\u{f142}"),
)
#let envelope = symbol(
  "\u{f0e0}",
  ("open", "\u{f2b6}"),
  ("open.text", "\u{f658}"),
  ("square", "\u{f199}"),
)
#let equals = symbol("\u{f52c}")
#let eraser = symbol("\u{f12d}")
#let ethernet = symbol("\u{f796}")

#let exchange = symbol("\u{f362}")

#let exclamation = symbol(
  "\u{f12a}",
  ("circle", "\u{f06a}"),
  ("triangle", "\u{f071}"),
)
#let expand = symbol(
  "\u{f065}",
  ("alt", "\u{f424}"),
  ("alt.arrows", "\u{f31e}"),
)
#let link-icon = symbol("\u{f0c1}")
#let external-link = symbol(
  "\u{f35d}",
  ("square", "\u{f360}"),
)

#let eye = symbol(
  "\u{f06e}",
  ("dropper", "\u{f1fb}"),
  ("slash", "\u{f070}"),
)
#let fan = symbol("\u{f863}")
#let fast = symbol(
  ("backward", "\u{f049}"),
  ("forward", "\u{f050}"),
)
#let faucet = symbol("\u{e005}")
#let fax = symbol("\u{f1ac}")
#let feather = symbol(
  "\u{f52d}",
  ("alt", "\u{f56b}"),
)
#let female = symbol("\u{f182}")
#let fighter-jet = symbol("\u{f0fb}")
#let file = symbol(
  "\u{f15b}",
  ("alt", "\u{f15c}"),
  ("archive", "\u{f1c6}"),
  ("audio", "\u{f1c7}"),
  ("code", "\u{f1c9}"),
  ("contract", "\u{f56c}"),
  ("csv", "\u{f6dd}"),
  ("download", "\u{f56d}"),
  ("excel", "\u{f1c3}"),
  ("export", "\u{f56e}"),
  ("image", "\u{f1c5}"),
  ("import", "\u{f56f}"),
  ("invoice", "\u{f570}"),
  ("invoice.dollar", "\u{f571}"),
  ("medical", "\u{f477}"),
  ("medical-alt", "\u{f478}"),
  ("pdf", "\u{f1c1}"),
  ("powerpoint", "\u{f1c4}"),
  ("prescription", "\u{f572}"),
  ("signature", "\u{f573}"),
  ("upload", "\u{f574}"),
  ("video", "\u{f1c8}"),
  ("word", "\u{f1c2}"),
)
#let fill = symbol(
  "\u{f575}",
  ("drip", "\u{f576}"),
)
#let film = symbol("\u{f008}")
#let filter = symbol("\u{f0b0}")
#let fingerprint = symbol("\u{f577}")
#let fire = symbol(
  "\u{f06d}",
  ("alt", "\u{f7e4}"),
  ("extinguisher", "\u{f134}"),
)
#let first-aid = symbol("\u{f479}")
#let fish = symbol("\u{f578}")
#let fist-raised = symbol("\u{f6de}")
#let flag = symbol(
  "\u{f024}",
  ("checkered", "\u{f11e}"),
  ("usa", "\u{f74d}"),
)
#let flask = symbol("\u{f0c3}")
#let flushed = symbol("\u{f579}")
#let folder = symbol(
  "\u{f07b}",
  ("minus", "\u{f65d}"),
  ("open", "\u{f07c}"),
  ("plus", "\u{f65e}"),
)
#let font = symbol("\u{f031}")
#let forward = symbol("\u{f04e}")
#let frog = symbol("\u{f52e}")
#let frown = symbol(
  "\u{f119}",
  ("open", "\u{f57a}"),
)
#let funnel-dollar = symbol("\u{f662}")
#let futbol = symbol("\u{f1e3}")
#let gamepad = symbol("\u{f11b}")
#let gas-pump = symbol("\u{f52f}")
#let gavel = symbol("\u{f0e3}")
#let gem = symbol("\u{f3a5}")
#let genderless = symbol("\u{f22d}")
#let ghost = symbol("\u{f6e2}")
#let gift = symbol(
  "\u{f06b}",
  ("plural", "\u{f79c}"),
)
#let glass = symbol(
  ("cheers", "\u{f79f}"),
  ("martini", "\u{f000}"),
  ("martini.alt", "\u{f57b}"),
  ("whiskey", "\u{f7a0}"),
  ("plural", "\u{f530}"),
)
#let globe = symbol(
  "\u{f0ac}",
  ("africa", "\u{f57c}"),
  ("americas", "\u{f57d}"),
  ("asia", "\u{f57e}"),
  ("europe", "\u{f7a2}"),
)
#let gopuram = symbol("\u{f664}")
#let graduation-cap = symbol("\u{f19d}")
#let greater-than = symbol(
  "\u{f531}",
  ("equal", "\u{f532}"),
)
#let grimace = symbol("\u{f57f}")
#let grin = symbol(
  "\u{f580}",
  ("alt", "\u{f581}"),
  ("beam", "\u{f582}"),
  ("beam-sweat", "\u{f583}"),
  ("hearts", "\u{f584}"),
  ("squint", "\u{f585}"),
  ("squint-tears", "\u{f586}"),
  ("stars", "\u{f587}"),
  ("tears", "\u{f588}"),
  ("tongue", "\u{f589}"),
  ("tongue-squint", "\u{f58a}"),
  ("tongue-wink", "\u{f58b}"),
  ("wink", "\u{f58c}"),
)
#let grip = symbol(
  ("horizontal", "\u{f58d}"),
  ("lines", "\u{f7a4}"),
  ("lines-vertical", "\u{f7a5}"),
  ("vertical", "\u{f58e}"),
)
#let guitar = symbol("\u{f7a6}")
#let h-square = symbol("\u{f0fd}")
#let hamburger = symbol("\u{f805}")
#let hammer = symbol("\u{f6e3}")
#let hamsa = symbol("\u{f665}")
#let hand = symbol(
  ("holding", "\u{f4bd}"),
  ("holding.heart", "\u{f4be}"),
  ("holding.medical", "\u{e05c}"),
  ("holding.usd", "\u{f4c0}"),
  ("holding.water", "\u{f4c1}"),
  ("lizard", "\u{f258}"),
  ("middle-finger", "\u{f806}"),
  ("paper", "\u{f256}"),
  ("peace", "\u{f25b}"),
  ("point.right", "\u{f0a4}"),
  ("point.left", "\u{f0a5}"),
  ("point.up", "\u{f0a6}"),
  ("point.down", "\u{f0a7}"),
  ("pointer", "\u{f25a}"),
  ("rock", "\u{f255}"),
  ("scissors", "\u{f257}"),
  ("sparkles", "\u{e05d}"),
  ("spock", "\u{f259}"),
  ("plural", "\u{f4c2}"),
  ("helping", "\u{f4c4}"),
  ("wash", "\u{e05e}"),
  ("shake", "\u{f2b5}"),
  ("shake.slash", "\u{e060}"),
  ("shake.slash.alt", "\u{e05f}"),
  ("praying", "\u{f684}"),
)
#let hanukiah = symbol("\u{f6e6}")
#let hat-icon = symbol(
  ("hard", "\u{f807}"),
  ("cowboy", "\u{f8c0}"),
  ("cowboy-side", "\u{f8c1}"),
  ("wizard", "\u{f6e8}"),
)
#let hashtag = symbol("\u{f292}")
#let hdd = symbol("\u{f0a0}")
#let head-side = symbol(
  ("cough", "\u{e061}"),
  ("cough-slash", "\u{e062}"),
  ("mask", "\u{e063}"),
  ("virus", "\u{e064}"),
)
#let heading-icon = symbol("\u{f1dc}")
#let headphones = symbol(
  "\u{f025}",
  ("alt", "\u{f58f}"),
  ("mic", "\u{f590}")
)
#let heart = symbol(
  "\u{f004}",
  ("broken", "\u{f7a9}"),
  ("beat", "\u{f21e}"),
)
#let helicopter = symbol("\u{f533}")
#let highlighter = symbol("\u{f591}")
#let hiking = symbol("\u{f6ec}")
#let hippo = symbol("\u{f6ed}")
#let history = symbol("\u{f1da}")
#let hockey-puck = symbol("\u{f453}")
#let holly-berry = symbol("\u{f7aa}")
#let home = symbol("\u{f015}")
#let horse = symbol(
  "\u{f6f0}",
  ("head", "\u{f7ab}"),
)
#let hospital = symbol(
  "\u{f0f8}",
  ("alt", "\u{f47d}"),
  ("symbol", "\u{f47e}"),
  ("user", "\u{f80d}"),
)
#let hot-tub = symbol("\u{f593}")
#let hotdog = symbol("\u{f80f}")
#let hotel = symbol("\u{f594}")
#let hourglass = symbol(
  "\u{f254}",
  ("start", "\u{f251}"),
)
#let house = symbol(
  ("user", "\u{e065}"),
  ("damage", "\u{f6f1}"),
)
#let hryvnia = symbol("\u{f6f2}")
#let i-cursor = symbol("\u{f246}")
#let ice-cream = symbol("\u{f810}")
#let icicles = symbol("\u{f7ad}")
#let icons = symbol("\u{f86d}")
#let id = symbol(
  ("badge", "\u{f2c1}"),
  ("card", "\u{f2c2}"),
  ("card-alt", "\u{f47f}"),
)
#let igloo = symbol("\u{f7ae}")
#let image = symbol(
  "\u{f03e}",
  ("plural", "\u{f302}"),
)
#let inbox = symbol("\u{f01c}")
#let indent = symbol("\u{f03c}")
#let industry = symbol("\u{f275}")
#let infinity = symbol("\u{f534}")
#let info = symbol(
  "\u{f129}",
  ("circle", "\u{f05a}"),
)
#let italic = symbol("\u{f033}")
#let jedi = symbol("\u{f669}")
#let joint = symbol("\u{f595}")
#let journal-whills = symbol("\u{f66a}")
#let kaaba = symbol("\u{f66b}")
#let key = symbol("\u{f084}")
#let keyboard = symbol("\u{f11c}")
#let khanda = symbol("\u{f66d}")
#let kiss = symbol(
  "\u{f596}",
  ("beam", "\u{f597}"),
  ("wink.heart", "\u{f598}"),
)
#let kiwi-bird = symbol("\u{f535}")
#let landmark = symbol("\u{f66f}")
#let language = symbol("\u{f1ab}")
#let laptop = symbol(
  "\u{f109}",
  ("code", "\u{f5fc}"),
  ("house", "\u{e066}"),
  ("medical", "\u{f812}"),
)
#let laugh = symbol(
  "\u{f599}",
  ("beam", "\u{f59a}"),
  ("squint", "\u{f59b}"),
  ("wink", "\u{f59c}"),
)
#let layer-group = symbol("\u{f5fd}")
#let leaf = symbol("\u{f06c}")
#let lemon = symbol("\u{f094}")
#let less-than = symbol(
  "\u{f536}",
  ("equal", "\u{f537}"),
)
#let level-down = symbol("\u{f3be}")
#let level-up = symbol("\u{f3bf}")
#let life-ring = symbol("\u{f1cd}")
#let lightbulb = symbol("\u{f0eb}")
#let list-icon = symbol(
  "\u{f03a}",
  ("alt", "\u{f022}"),
  ("ol", "\u{f0cb}"),
  ("ul", "\u{f0ca}"),
)
#let location-arrow = symbol("\u{f124}")
#let lock = symbol(
  "\u{f023}",
  ("open", "\u{f3c1}"),
)
#let low-vision = symbol("\u{f2a8}")
#let luggage-cart = symbol("\u{f59d}")
#let lungs = symbol(
  "\u{f604}",
  ("virus", "\u{e067}"),
)
#let magic = symbol("\u{f0d0}")
#let magnet = symbol("\u{f076}")
#let mail-bulk = symbol("\u{f674}")
#let male = symbol("\u{f183}")
#let map-icon = symbol(
  "\u{f279}",
  ("marked", "\u{f59f}"),
  ("marked-alt", "\u{f5a0}"),
  ("marker", "\u{f041}"),
  ("marker-alt", "\u{f3c5}"),
  ("pin", "\u{f276}"),
  ("signs", "\u{f277}"),
)
#let marker = symbol("\u{f5a1}")
#let mars = symbol(
  "\u{f222}",
  ("double", "\u{f227}"),
  ("stroke", "\u{f229}"),
  ("stroke.h", "\u{f22b}"),
  ("stroke.v", "\u{f22a}"),
)
#let mask = symbol("\u{f6fa}")
#let medal = symbol("\u{f5a2}")
#let medkit = symbol("\u{f0fa}")
#let meh = symbol(
  "\u{f11a}",
  ("blank", "\u{f5a4}"),
  ("rolling-eyes", "\u{f5a5}"),
)
#let memory = symbol("\u{f538}")
#let menorah = symbol("\u{f676}")
#let mercury = symbol("\u{f223}")
#let meteor = symbol("\u{f753}")
#let microchip = symbol("\u{f2db}")
#let microphone = symbol(
  "\u{f130}",
  ("slash", "\u{f131}"),
  ("alt", "\u{f3c9}"),
  ("alt.slash", "\u{f539}"),
)
#let microscope = symbol("\u{f610}")
#let minus = symbol(
  "\u{f068}",
  ("circle", "\u{f056}"),
  ("square", "\u{f146}"),
)
#let mitten = symbol("\u{f7b5}")
#let mobile = symbol(
  "\u{f10b}",
  ("alt", "\u{f3cd}"),
)
#let money = symbol(
  ("bill", "\u{f0d6}"),
  ("bill.alt", "\u{f3d1}"),
  ("bill.wave", "\u{f53a}"),
  ("bill.wave.alt", "\u{f53b}"),
  ("check", "\u{f53c}"),
  ("check.alt", "\u{f53d}"),
  ("sign.dollar", "\u{f155}"),
  ("sign.euro", "\u{f153}"),
  ("sign.pound", "\u{f154}"),
  ("sign.ruble", "\u{f158}"),
  ("sign.rupee", "\u{f156}"),
  ("sign.shekel", "\u{f20b}"),
  ("sign.lira", "\u{f195}"),
  ("sign.won", "\u{f159}"),
  ("sign.yen", "\u{f157}"),
)
#let monument = symbol("\u{f5a6}")
#let moon = symbol("\u{f186}")
#let mortar-pestle = symbol("\u{f5a7}")
#let mosque = symbol("\u{f678}")
#let motorcycle = symbol("\u{f21c}")
#let mountain = symbol("\u{f6fc}")
#let mouse = symbol("\u{f8cc}")
#let mouse-pointer = symbol("\u{f245}")
#let mug-hot = symbol("\u{f7b6}")
#let music = symbol("\u{f001}")
#let network-wired = symbol("\u{f6ff}")
#let neuter = symbol("\u{f22c}")
#let newspaper = symbol("\u{f1ea}")
#let not-equal = symbol("\u{f53e}")
#let notes-medical = symbol("\u{f481}")
#let object-group = symbol("\u{f247}")
#let object-ungroup = symbol("\u{f248}")
#let oil-can = symbol("\u{f613}")
#let om = symbol("\u{f679}")
#let otter = symbol("\u{f700}")
#let outdent = symbol("\u{f03b}")
#let pager = symbol("\u{f815}")
#let paintbrush = symbol(
  "\u{f1fc}",
  ("roller", "\u{f5aa}"),
)
#let palette = symbol("\u{f53f}")
#let pallet = symbol("\u{f482}")
#let paper-plane = symbol("\u{f1d8}")
#let paperclip = symbol("\u{f0c6}")
#let parachute-box = symbol("\u{f4cd}")
#let paragraph = symbol("\u{f1dd}")
#let parking = symbol("\u{f540}")
#let passport = symbol("\u{f5ab}")
#let pastafarianism = symbol("\u{f67b}")
#let paste = symbol("\u{f0ea}")
#let pause = symbol(
  "\u{f04c}",
  ("circle", "\u{f28b}"),
)
#let paw = symbol("\u{f1b0}")
#let peace = symbol("\u{f67c}")
#let pen = symbol(
  "\u{f304}",
  ("alt", "\u{f305}"),
  ("fancy", "\u{f5ac}"),
  ("nib", "\u{f5ad}"),
  ("square", "\u{f14b}"),
)
#let pencil = symbol(
  ("alt", "\u{f303}"),
  ("ruler", "\u{f5ae}"),
)
#let people = symbol(
  ("arrows", "\u{e068}"),
  ("carry", "\u{f4ce}"),
)
#let pepper-hot = symbol("\u{f816}")
#let percent = symbol("\u{f295}")
#let percentage = symbol("\u{f541}")
#let person-booth = symbol("\u{f756}")

#let phone = symbol(
  "\u{f095}",
  ("alt", "\u{f879}"),
  ("slash", "\u{f3dd}"),
  ("square", "\u{f098}"),
  ("square-alt", "\u{f87b}"),
  ("volume", "\u{f2a0}"),
)


#let photo-video = symbol("\u{f87c}")
#let piggy-bank = symbol("\u{f4d3}")
#let pills = symbol("\u{f484}")
#let pizza-slice = symbol("\u{f818}")
#let place-of-worship = symbol("\u{f67f}")
#let plane = symbol(
  "\u{f072}",
  ("arrival", "\u{f5af}"),
  ("departure", "\u{f5b0}"),
  ("slash", "\u{e069}"),
)
#let play = symbol(
  "\u{f04b}",
  ("circle", "\u{f144}"),
)
#let plug = symbol("\u{f1e6}")
#let plus = symbol(
  "\u{f067}",
  ("circle", "\u{f055}"),
  ("square", "\u{f0fe}"),
)
#let podcast = symbol("\u{f2ce}")
#let poll = symbol(
  "\u{f681}",
  ("h", "\u{f682}"),
)
#let poop = symbol(
  "\u{f619}",
  ("face", "\u{f2fe}"),
  ("storm", "\u{f75a}"),
)
#let portrait = symbol("\u{f3e0}")
#let power-off = symbol("\u{f011}")
#let pray = symbol("\u{f683}")
#let prescription = symbol(
  "\u{f5b1}",
  ("bottle", "\u{f485}"),
  ("bottle.alt", "\u{f486}"),
)
#let print = symbol("\u{f02f}")
#let procedures = symbol("\u{f487}")
#let project-diagram = symbol("\u{f542}")

#let pump = symbol(
  ("soap", "\u{e06b}"),
  ("medical", "\u{e06a}"),
)
#let puzzle-piece = symbol("\u{f12e}")
#let qrcode = symbol("\u{f029}")
#let question = symbol(
  "\u{f128}",
  ("circle", "\u{f059}"),
)
#let quidditch = symbol("\u{f458}")
#let quote = symbol(
  ("left", "\u{f10d}"),
  ("right", "\u{f10e}"),
)
#let quran = symbol("\u{f687}")
#let radiation = symbol(
  "\u{f7b9}",
  ("alt", "\u{f7ba}"),
)
#let rainbow = symbol("\u{f75b}")
#let random = symbol("\u{f074}")
#let receipt = symbol("\u{f543}")
#let record-vinyl = symbol("\u{f8d9}")
#let recycle = symbol("\u{f1b8}")
#let redo = symbol(
  "\u{f01e}",
  ("alt", "\u{f2f9}"),
)
#let registered = symbol("\u{f25d}")
#let remove-format = symbol("\u{f87d}")
#let reply = symbol(
  "\u{f3e5}",
  ("all", "\u{f122}"),
)
#let republican = symbol("\u{f75e}")
#let restroom = symbol("\u{f7bd}")
#let retweet = symbol("\u{f079}")
#let ribbon = symbol("\u{f4d6}")
#let ring = symbol("\u{f70b}")


#let road = symbol("\u{f018}")
#let robot = symbol("\u{f544}")
#let rocket = symbol("\u{f135}")
#let route = symbol("\u{f4d7}")
#let rss = symbol(
  "\u{f09e}",
  ("square", "\u{f143}"),
)
#let ruler = symbol(
  "\u{f545}",
  ("combined", "\u{f546}"),
  ("horizontal", "\u{f547}"),
  ("vertical", "\u{f548}"),
)
#let running = symbol("\u{f70c}")
#let sad = symbol(
  ("cry", "\u{f5b3}"),
  ("tear", "\u{f5b4}"),
)
#let satellite = symbol(
  "\u{f7bf}",
  ("dish", "\u{f7c0}"),
)
#let save = symbol("\u{f0c7}")
#let school = symbol("\u{f549}")
#let screwdriver = symbol("\u{f54a}")
#let scroll = symbol("\u{f70e}")
#let sd-card = symbol("\u{f7c2}")
#let search = symbol(
  "\u{f002}",
  ("dollar", "\u{f688}"),
  ("location", "\u{f689}"),
  ("minus", "\u{f010}"),
  ("plus", "\u{f00e}"),
)
#let seedling = symbol("\u{f4d8}")
#let server = symbol("\u{f233}")
#let shapes = symbol("\u{f61f}")
#let share = symbol(
  "\u{f064}",
  ("alt", "\u{f1e0}"),
  ("alt-square", "\u{f1e1}"),
  ("square", "\u{f14d}"),
)

#let shield = symbol(
  "\u{f3ed}",
  ("virus", "\u{e06c}"),
)
#let ship = symbol("\u{f21a}")
#let shipping-fast = symbol("\u{f48b}")
#let shoe-prints = symbol("\u{f54b}")
#let shopping-bag = symbol("\u{f290}")
#let shopping-basket = symbol("\u{f291}")

#let shower = symbol("\u{f2cc}")
#let shuttle-van = symbol("\u{f5b6}")
#let sign = symbol("\u{f4d9}")
#let sign-in = symbol("\u{f2f6}")
#let sign-out = symbol("\u{f2f5}")
#let sign-language = symbol("\u{f2a7}")
#let signal = symbol("\u{f012}")
#let signature = symbol("\u{f5b7}")
#let sim-card = symbol("\u{f7c4}")
#let sink = symbol("\u{e06d}")
#let sitemap = symbol("\u{f0e8}")
#let skating = symbol("\u{f7c5}")
#let skiing = symbol(
  "\u{f7c9}",
  ("nordic", "\u{f7ca}"),
)
#let skull = symbol(
  "\u{f54c}",
  ("crossbones", "\u{f714}"),
)
#let slash = symbol("\u{f715}")
#let sleigh = symbol("\u{f7cc}")
#let sliders-h = symbol("\u{f1de}")
#let smile = symbol(
  "\u{f118}",
  ("beam", "\u{f5b8}"),
  ("wink", "\u{f4da}"),
)
#let smog = symbol("\u{f75f}")
#let smoking = symbol(
  "\u{f48d}",
  ("ban", "\u{f54d}"),
)
#let sms = symbol("\u{f7cd}")
#let snowboarding = symbol("\u{f7ce}")
#let snowflake = symbol("\u{f2dc}")
#let snowman = symbol("\u{f7d0}")
#let snowplow = symbol("\u{f7d2}")
#let soap = symbol("\u{e06e}")
#let socks = symbol("\u{f696}")
#let solar-panel = symbol("\u{f5ba}")
#let sort = symbol(
  "\u{f0dc}",
  ("alpha.down", "\u{f15d}"),
  ("alpha.down.alt", "\u{f881}"),
  ("alpha.up", "\u{f15e}"),
  ("alpha.up.alt", "\u{f882}"),
  ("amount.down", "\u{f160}"),
  ("amount.down.alt", "\u{f884}"),
  ("amount.up", "\u{f161}"),
  ("amount.up.alt", "\u{f885}"),
  ("down", "\u{f0dd}"),
  ("numeric.down", "\u{f162}"),
  ("numeric.down.alt", "\u{f886}"),
  ("numeric.up", "\u{f163}"),
  ("numeric.up.alt", "\u{f887}"),
  ("up", "\u{f0de}"),
)


#let spa = symbol("\u{f5bb}")
#let space-shuttle = symbol("\u{f197}")
#let spell-check = symbol("\u{f891}")
#let spider = symbol("\u{f717}")
#let spinner = symbol("\u{f110}")
#let splotch = symbol("\u{f5bc}")
#let spray-can = symbol("\u{f5bd}")
#let square = symbol(
  "\u{f0c8}",
  ("full", "\u{f45c}"),
)
#let square-root = symbol("\u{f698}")
#let stamp = symbol("\u{f5bf}")
#let star = symbol(
  "\u{f005}",
  ("crescent", "\u{f699}"),
  ("half", "\u{f089}"),
  ("half.alt", "\u{f5c0}"),
  ("david", "\u{f69a}"),
  ("life", "\u{f621}"),
)
#let step-backward = symbol("\u{f048}")
#let step-forward = symbol("\u{f051}")
#let stethoscope = symbol("\u{f0f1}")
#let sticky-note = symbol("\u{f249}")
#let stop = symbol(
  "\u{f04d}",
  ("circle", "\u{f28d}"),
)
#let stopwatch = symbol(
  "\u{f2f2}",
  ("sec20", "\u{e06f}"),
)
#let store = symbol(
  "\u{f54e}",
  ("slash", "\u{e071}"),
  ("alt", "\u{f54f}"),
  ("alt.slash", "\u{e070}"),
)
#let stream = symbol("\u{f550}")
#let street-view = symbol("\u{f21d}")
#let strikethrough = symbol("\u{f0cc}")
#let stroopwafel = symbol("\u{f551}")
#let subscript = symbol("\u{f12c}")
#let subway = symbol("\u{f239}")
#let suitcase = symbol(
  "\u{f0f2}",
  ("rolling", "\u{f5c1}"),
)
#let sun = symbol("\u{f185}")
#let superscript = symbol("\u{f12b}")
#let surprise = symbol("\u{f5c2}")
#let swatchbook = symbol("\u{f5c3}")
#let swimmer = symbol("\u{f5c4}")
#let swimming-pool = symbol("\u{f5c5}")
#let synagogue = symbol("\u{f69b}")
#let sync = symbol(
  "\u{f021}",
  ("alt", "\u{f2f1}"),
)
#let syringe = symbol("\u{f48e}")
#let table = symbol("\u{f0ce}")
#let table-tennis = symbol("\u{f45d}")
#let tablet = symbol(
  "\u{f10a}",
  ("alt", "\u{f3fa}"),
)
#let tablets = symbol("\u{f490}")
#let tachometer = symbol("\u{f3fd}")
#let tag = symbol(
  "\u{f02b}",
  ("plural", "\u{f02c}"),
)
#let tape = symbol("\u{f4db}")
#let tasks = symbol("\u{f0ae}")
#let taxi = symbol("\u{f1ba}")
#let teeth = symbol(
  "\u{f62e}",
  ("open", "\u{f62f}"),
)
#let temperature = symbol(
  ("high", "\u{f769}"),
  ("low", "\u{f76b}"),
)
#let tenge = symbol("\u{f7d7}")
#let terminal = symbol("\u{f120}")
#let text-height = symbol("\u{f034}")
#let text-width = symbol("\u{f035}")
#let th = symbol(
  "\u{f00a}",
  ("large", "\u{f009}"),
  ("list", "\u{f00b}"),
)
#let theater-masks = symbol("\u{f630}")
#let thermometer = symbol(
  "\u{f491}",
  ("empty", "\u{f2cb}"),
  ("full", "\u{f2c7}"),
  ("half", "\u{f2c9}"),
  ("quarter", "\u{f2ca}"),
  ("three-quarters", "\u{f2c8}"),
)
#let thumbs = symbol(
  ("up", "\u{f164}"),
  ("down", "\u{f165}"),
)
#let thumbtack = symbol("\u{f08d}")
#let ticket = symbol("\u{f3ff}")
#let times = symbol(
  "\u{f00d}",
  ("circle", "\u{f057}"),
)
#let tint = symbol(
  "\u{f043}",
  ("slash", "\u{f5c7}"),
)
#let tired = symbol("\u{f5c8}")
#let toggle = symbol(
  ("off", "\u{f204}"),
  ("on", "\u{f205}"),
)
#let toilet = symbol("\u{f7d8}")
#let toilet-paper = symbol(
  "\u{f71e}",
  ("slash", "\u{e072}"),
)
#let toolbox = symbol("\u{f552}")
#let tools = symbol("\u{f7d9}")
#let tooth = symbol("\u{f5c9}")
#let torah = symbol("\u{f6a0}")
#let torii-gate = symbol("\u{f6a1}")
#let tractor = symbol("\u{f722}")
#let trademark = symbol("\u{f25c}")
#let traffic-light = symbol("\u{f637}")
#let trailer = symbol("\u{e041}")
#let train = symbol("\u{f238}")
#let tram = symbol("\u{f7da}")
#let transgender = symbol(
  "\u{f224}",
  ("alt", "\u{f225}"),
)
#let trash = symbol(
  "\u{f1f8}",
  ("alt", "\u{f2ed}"),
  ("restore", "\u{f829}"),
  ("restore.alt", "\u{f82a}"),
)
#let tree = symbol("\u{f1bb}")
#let trophy = symbol("\u{f091}")
#let truck = symbol(
  "\u{f0d1}",
  ("loading", "\u{f4de}"),
  ("monster", "\u{f63b}"),
  ("moving", "\u{f4df}"),
  ("pickup", "\u{f63c}"),
)
#let tshirt = symbol("\u{f553}")
#let tty = symbol("\u{f1e4}")
#let tv = symbol("\u{f26c}")
#let umbrella = symbol(
  "\u{f0e9}",
  ("beach", "\u{f5ca}"),
)
#let underline-icon = symbol("\u{f0cd}")
#let undo = symbol(
  "\u{f0e2}",
  ("alt", "\u{f2ea}"),
)
#let universal-access = symbol("\u{f29a}")
#let university = symbol("\u{f19c}")
#let unlink = symbol("\u{f127}")
#let unlock = symbol(
  "\u{f09c}",
  ("alt", "\u{f13e}"),
)
#let upload = symbol("\u{f093}")
#let user = symbol(
  "\u{f007}",
  ("alt", "\u{f406}"),
  ("alt.slash", "\u{f4fa}"),
  ("astronaut", "\u{f4fb}"),
  ("check", "\u{f4fc}"),
  ("circle", "\u{f2bd}"),
  ("clock", "\u{f4fd}"),
  ("cog", "\u{f4fe}"),
  ("edit", "\u{f4ff}"),
  ("friends", "\u{f500}"),
  ("graduate", "\u{f501}"),
  ("injured", "\u{f728}"),
  ("lock", "\u{f502}"),
  ("md", "\u{f0f0}"),
  ("minus", "\u{f503}"),
  ("ninja", "\u{f504}"),
  ("nurse", "\u{f82f}"),
  ("plus", "\u{f234}"),
  ("secret", "\u{f21b}"),
  ("shield", "\u{f505}"),
  ("slash", "\u{f506}"),
  ("tag", "\u{f507}"),
  ("tie", "\u{f508}"),
  ("times", "\u{f235}"),
  ("plural", "\u{f0c0}"),
  ("plural.cog", "\u{f509}"),
  ("plural.slash", "\u{e073}"),
)
#let utensils = symbol(
  "\u{f2e7}",
  ("spoon", "\u{f2e5}"),
)
#let vector-square = symbol("\u{f5cb}")
#let venus = symbol(
  "\u{f221}",
  ("double", "\u{f226}"),
  ("mars", "\u{f228}"),
)
#let vest = symbol(
  "\u{e085}",
  ("patches", "\u{e086}"),
)
#let vial = symbol(
  "\u{f492}",
  ("plural", "\u{f493}"),
)
#let video = symbol(
  "\u{f03d}",
  ("slash", "\u{f4e2}"),
)
#let vihara = symbol("\u{f6a7}")
#let virus = symbol(
  "\u{e074}",
  ("slash", "\u{e075}"),
  ("plural", "\u{e076}"),
)
#let voicemail = symbol("\u{f897}")

#let volume = symbol(
  ("down", "\u{f027}"),
  ("mute", "\u{f6a9}"),
  ("off", "\u{f026}"),
  ("up", "\u{f028}"),
)

#let vote-yea = symbol("\u{f772}")
#let vr-cardboard = symbol("\u{f729}")
#let walking = symbol("\u{f554}")
#let wallet = symbol("\u{f555}")
#let warehouse = symbol("\u{f494}")
#let water = symbol("\u{f773}")
#let wave-square = symbol("\u{f83e}")
#let weight = symbol("\u{f496}")
#let weight-hanging = symbol("\u{f5cd}")
#let wheelchair = symbol("\u{f193}")
#let wifi = symbol("\u{f1eb}")
#let wind = symbol("\u{f72e}")
#let window = symbol(
  ("close", "\u{f410}"),
  ("maximize", "\u{f2d0}"),
  ("minimize", "\u{f2d1}"),
  ("restore", "\u{f2d2}"),
)
#let wine = symbol(
  ("bottle", "\u{f72f}"),
  ("glass", "\u{f4e3}"),
  ("glass-alt", "\u{f5ce}"),
)
#let wrench = symbol("\u{f0ad}")
#let x-ray = symbol("\u{f497}")
#let yin-yang = symbol("\u{f6ad}")

// Brand icons

#let px500 = symbol("\u{f26e}")
#let accessible-icon = symbol("\u{f368}")
#let accusoft = symbol("\u{f369}")
#let acquisitions-incorporated = symbol("\u{f6af}")
#let adn = symbol("\u{f170}")
#let adversal = symbol("\u{f36a}")
#let affiliatetheme = symbol("\u{f36b}")
#let airbnb = symbol("\u{f834}")
#let algolia = symbol("\u{f36c}")
#let alipay = symbol("\u{f642}")
#let amazon = symbol(
  "\u{f270}",
  ("pay", "\u{f42c}"),
  ("pay.cc", "\u{f42d}")
)
#let amilia = symbol("\u{f36d}")
#let android = symbol("\u{f17b}")
#let angellist = symbol("\u{f209}")
#let angrycreative = symbol("\u{f36e}")
#let angular = symbol("\u{f420}")
#let app-store = symbol(
  "\u{f36f}",
  ("ios", "\u{f370}"),
)
#let apper = symbol("\u{f371}")
#let artstation = symbol("\u{f77a}")
#let asymmetrik = symbol("\u{f372}")
#let atlassian = symbol("\u{f77b}")
#let audible = symbol("\u{f373}")
#let autoprefixer = symbol("\u{f41c}")
#let avianex = symbol("\u{f374}")
#let aviato = symbol("\u{f421}")
#let aws = symbol("\u{f375}")
#let bandcamp = symbol("\u{f2d5}")
#let battle-net = symbol("\u{f835}")
#let behance = symbol(
  "\u{f1b4}",
  ("square", "\u{f1b5}"),
)
#let bimobject = symbol("\u{f378}")
#let bitbucket = symbol("\u{f171}")
#let bitcoin = symbol("\u{f379}")
#let bity = symbol("\u{f37a}")
#let black-tie = symbol("\u{f27e}")
#let blackberry = symbol("\u{f37b}")
#let blogger = symbol(
  "\u{f37c}",
  ("b", "\u{f37d}"),
)
#let bluetooth = symbol(
  "\u{f293}",
  ("b", "\u{f294}"),
)
#let bootstrap = symbol("\u{f836}")
#let btc = symbol("\u{f15a}")
#let buffer = symbol("\u{f837}")
#let buromobelexperte = symbol("\u{f37f}")
#let buy-n-large = symbol("\u{f8a6}")
#let canadian-maple-leaf = symbol("\u{f785}")
#let amex = symbol("\u{f1f3}")
#let diners-club = symbol("\u{f24c}")
#let discover = symbol("\u{f1f2}")
#let jcb = symbol("\u{f24b}")
#let mastercard = symbol("\u{f1f1}")
#let visa = symbol("\u{f1f0}")
#let centercode = symbol("\u{f380}")
#let centos = symbol("\u{f789}")
#let chrome = symbol("\u{f268}")
#let chromecast = symbol("\u{f838}")
#let cloudflare = symbol("\u{e07d}")
#let cloudscale = symbol("\u{f383}")
#let cloudsmith = symbol("\u{f384}")
#let cloudversify = symbol("\u{f385}")
#let codepen = symbol("\u{f1cb}")
#let codiepie = symbol("\u{f284}")
#let confluence = symbol("\u{f78d}")
#let connectdevelop = symbol("\u{f20e}")
#let contao = symbol("\u{f26d}")
#let cotton-bureau = symbol("\u{f89e}")
#let cpanel = symbol("\u{f388}")
#let creative-commons = symbol(
  "\u{f25e}",
  ("by", "\u{f4e7}"),
  ("nc", "\u{f4e8}"),
  ("nc.eu", "\u{f4e9}"),
  ("nc.jp", "\u{f4ea}"),
  ("nd", "\u{f4eb}"),
  ("pd", "\u{f4ec}"),
  ("pd.alt", "\u{f4ed}"),
  ("remix", "\u{f4ee}"),
  ("sa", "\u{f4ef}"),
  ("sampling", "\u{f4f0}"),
  ("sampling.plus", "\u{f4f1}"),
  ("share", "\u{f4f2}"),
  ("zero", "\u{f4f3}"),
)
#let critical-role = symbol("\u{f6c9}")
#let css3 = symbol(
  "\u{f13c}",
  ("alt", "\u{f38b}"),
)
#let cuttlefish = symbol("\u{f38c}")
#let d-and-d = symbol("\u{f38d}")
#let d-and-d-beyond = symbol("\u{f6ca}")
#let dailymotion = symbol("\u{e052}")
#let dashcube = symbol("\u{f210}")
#let deezer = symbol("\u{e077}")
#let delicious = symbol("\u{f1a5}")
#let deploydog = symbol("\u{f38e}")
#let deskpro = symbol("\u{f38f}")
#let dev = symbol("\u{f6cc}")
#let deviantart = symbol("\u{f1bd}")
#let dhl = symbol("\u{f790}")
#let diaspora = symbol("\u{f791}")
#let digg = symbol("\u{f1a6}")
#let digital-ocean = symbol("\u{f391}")
#let discord = symbol("\u{f392}")
#let discourse = symbol("\u{f393}")
#let dochub = symbol("\u{f394}")
#let docker = symbol("\u{f395}")
#let draft2digital = symbol("\u{f396}")
#let dribbble = symbol(
  "\u{f17d}",
  ("square", "\u{f397}"),
)
#let dropbox = symbol("\u{f16b}")
#let drupal = symbol("\u{f1a9}")
#let dyalog = symbol("\u{f399}")
#let earlybirds = symbol("\u{f39a}")
#let ebay = symbol("\u{f4f4}")
#let edge = symbol(
  "\u{f282}",
  ("legacy", "\u{e078}"),
)
#let elementor = symbol("\u{f430}")
#let ello = symbol("\u{f5f1}")
#let ember = symbol("\u{f423}")
#let empire = symbol("\u{f1d1}")
#let envira = symbol("\u{f299}")
#let erlang = symbol("\u{f39d}")
#let ethereum = symbol("\u{f42e}")
#let etsy = symbol("\u{f2d7}")
#let evernote = symbol("\u{f839}")
#let expeditedssl = symbol("\u{f23e}")
#let facebook = symbol(
  "\u{f09a}",
  ("f", "\u{f39e}"),
  ("messenger", "\u{f39f}"),
  ("square", "\u{f082}"),
)
#let fantasy-flight-games = symbol("\u{f6dc}")
#let fedex = symbol("\u{f797}")
#let fedora = symbol("\u{f798}")
#let figma = symbol("\u{f799}")
#let firefox = symbol(
  "\u{f269}",
  ("browser", "\u{e007}"),
)
#let first-order = symbol(
  "\u{f2b0}",
  ("alt", "\u{f50a}"),
)
#let firstdraft = symbol("\u{f3a1}")
#let flickr = symbol("\u{f16e}")
#let flipboard = symbol("\u{f44d}")
#let fly = symbol("\u{f417}")
#let font-awesome = symbol(
  "\u{f2b4}",
  ("alt", "\u{f35c}"),
  ("flag", "\u{f425}"),
)
#let fonticons = symbol(
  "\u{f280}",
  ("fi", "\u{f3a2}"),
)
#let fort-awesome = symbol(
  "\u{f286}",
  ("alt", "\u{f3a3}"),
)
#let forumbee = symbol("\u{f211}")
#let foursquare = symbol("\u{f180}")
#let free-code-camp = symbol("\u{f2c5}")
#let freebsd = symbol("\u{f3a4}")
#let fulcrum = symbol("\u{f50b}")
#let galactic-republic = symbol("\u{f50c}")
#let galactic-senate = symbol("\u{f50d}")
#let get-pocket = symbol("\u{f265}")
#let gg = symbol(
  "\u{f260}",
  ("circle", "\u{f261}"),
)
#let git = symbol(
  "\u{f1d3}",
  ("alt", "\u{f841}"),
  ("square", "\u{f1d2}"),
)
#let github = symbol(
  "\u{f09b}",
  ("alt", "\u{f113}"),
  ("square", "\u{f092}"),
)
#let gitkraken = symbol("\u{f3a6}")
#let gitlab = symbol("\u{f296}")
#let gitter = symbol("\u{f426}")
#let glide = symbol(
  "\u{f2a5}",
  ("g", "\u{f2a6}"),
)
#let gofore = symbol("\u{f3a7}")
#let goodreads = symbol(
  "\u{f3a8}",
  ("g", "\u{f3a9}"),
)
#let google = symbol(
  "\u{f1a0}",
  ("drive", "\u{f3aa}"),
  ("pay", "\u{e079}"),
  ("play", "\u{f3ab}"),
  ("plus", "\u{f2b3}"),
  ("plus-g", "\u{f0d5}"),
  ("plus-square", "\u{f0d4}"),
  ("wallet", "\u{f1ee}"),
)
#let gratipay = symbol("\u{f184}")
#let grav = symbol("\u{f2d6}")
#let gripfire = symbol("\u{f3ac}")
#let grunt = symbol("\u{f3ad}")
#let guilded = symbol("\u{e07e}")
#let gulp = symbol("\u{f3ae}")
#let hacker-news = symbol(
  "\u{f1d4}",
  ("square", "\u{f3af}"),
)
#let hackerrank = symbol("\u{f5f7}")
#let hips = symbol("\u{f452}")
#let hire-a-helper = symbol("\u{f3b0}")
#let hive = symbol("\u{e07f}")
#let hooli = symbol("\u{f427}")
#let hornbill = symbol("\u{f592}")
#let hotjar = symbol("\u{f3b1}")
#let houzz = symbol("\u{f27c}")
#let html5 = symbol("\u{f13b}")
#let hubspot = symbol("\u{f3b2}")
#let ideal = symbol("\u{e013}")
#let imdb = symbol("\u{f2d8}")
#let innosoft = symbol("\u{e080}")
#let instagram = symbol(
  "\u{f16d}",
  ("square", "\u{e055}"),
)
#let instalod = symbol("\u{e081}")
#let intercom = symbol("\u{f7af}")
#let internet-explorer = symbol("\u{f26b}")
#let invision = symbol("\u{f7b0}")
#let ioxhost = symbol("\u{f208}")
#let itch-io = symbol("\u{f83a}")
#let itunes = symbol(
  "\u{f3b4}",
  ("note", "\u{f3b5}"),
)
#let java = symbol("\u{f4e4}")
#let jedi-order = symbol("\u{f50e}")
#let jenkins = symbol("\u{f3b6}")
#let jira = symbol("\u{f7b1}")
#let joget = symbol("\u{f3b7}")
#let joomla = symbol("\u{f1aa}")
#let js = symbol(
  "\u{f3b8}",
  ("square", "\u{f3b9}"),
)
#let jsfiddle = symbol("\u{f1cc}")
#let kaggle = symbol("\u{f5fa}")
#let keybase = symbol("\u{f4f5}")
#let keycdn = symbol("\u{f3ba}")
#let kickstarter = symbol(
  "\u{f3bb}",
  ("k", "\u{f3bc}"),
)
#let korvue = symbol("\u{f42f}")
#let laravel = symbol("\u{f3bd}")
#let lastfm = symbol("\u{f202}")
#let lastfm-square = symbol("\u{f203}")
#let leanpub = symbol("\u{f212}")
#let less = symbol("\u{f41d}")
#let line-icon = symbol("\u{f3c0}")
#let linkedin = symbol(
  "\u{f08c}",
  ("in", "\u{f0e1}"),
)
#let linode = symbol("\u{f2b8}")
#let linux = symbol("\u{f17c}")
#let lyft = symbol("\u{f3c3}")
#let magento = symbol("\u{f3c4}")
#let mailchimp = symbol("\u{f59e}")
#let mandalorian = symbol("\u{f50f}")
#let markdown = symbol("\u{f60f}")
#let mastodon = symbol("\u{f4f6}")
#let maxcdn = symbol("\u{f136}")
#let mdb = symbol("\u{f8ca}")
#let medapps = symbol("\u{f3c6}")
#let medium = symbol(
  "\u{f23a}",
  ("m", "\u{f3c7}"),
)
#let medrt = symbol("\u{f3c8}")
#let meetup = symbol("\u{f2e0}")
#let megaport = symbol("\u{f5a3}")
#let mendeley = symbol("\u{f7b3}")
#let microblog = symbol("\u{e01a}")
#let microsoft = symbol("\u{f3ca}")
#let mix = symbol("\u{f3cb}")
#let mixcloud = symbol("\u{f289}")
#let mixer = symbol("\u{e056}")
#let mizuni = symbol("\u{f3cc}")
#let modx = symbol("\u{f285}")
#let monero = symbol("\u{f3d0}")
#let napster = symbol("\u{f3d2}")
#let neos = symbol("\u{f612}")
#let nimblr = symbol("\u{f5a8}")
#let node = symbol(
  "\u{f419}",
  ("js", "\u{f3d3}"),
)
#let npm = symbol("\u{f3d4}")
#let ns8 = symbol("\u{f3d5}")
#let nutritionix = symbol("\u{f3d6}")
#let octopus-deploy = symbol("\u{e082}")
#let odnoklassniki = symbol(
  "\u{f263}",
  ("square", "\u{f264}"),
)
#let old-republic = symbol("\u{f510}")
#let opencart = symbol("\u{f23d}")
#let openid = symbol("\u{f19b}")
#let opera = symbol("\u{f26a}")
#let optin-monster = symbol("\u{f23c}")
#let orcid = symbol("\u{f8d2}")
#let osi = symbol("\u{f41a}")
#let page4 = symbol("\u{f3d7}")
#let pagelines = symbol("\u{f18c}")
#let palfed = symbol("\u{f3d8}")
#let patreon = symbol("\u{f3d9}")
#let paypal = symbol(
  "\u{f1ed}",
  ("cc", "\u{f1f4}"),
)
#let penny-arcade = symbol("\u{f704}")
#let perbyte = symbol("\u{e083}")
#let periscope = symbol("\u{f3da}")
#let phabricator = symbol("\u{f3db}")
#let phoenix-framework = symbol("\u{f3dc}")
#let phoenix-squadron = symbol("\u{f511}")
#let php = symbol("\u{f457}")
#let pied-piper = symbol(
  "\u{f2ae}",
  ("alt", "\u{f1a8}"),
  ("hat", "\u{f4e5}"),
  ("pp", "\u{f1a7}"),
  ("square", "\u{e01e}"),
)
#let pinterest = symbol(
  "\u{f0d2}",
  ("p", "\u{f231}"),
  ("square", "\u{f0d3}"),
)
#let playstation = symbol("\u{f3df}")
#let product-hunt = symbol("\u{f288}")
#let pushed = symbol("\u{f3e1}")
#let python = symbol("\u{f3e2}")
#let qq = symbol("\u{f1d6}")
#let quinscape = symbol("\u{f459}")
#let quora = symbol("\u{f2c4}")
#let r-project = symbol("\u{f4f7}")
#let raspberry-pi = symbol("\u{f7bb}")
#let ravelry = symbol("\u{f2d9}")
#let react = symbol("\u{f41b}")
#let reacteurope = symbol("\u{f75d}")
#let readme = symbol("\u{f4d5}")
#let rebel = symbol("\u{f1d0}")
#let red-river = symbol("\u{f3e3}")
#let reddit = symbol(
  "\u{f1a1}",
  ("alien", "\u{f281}"),
  ("square", "\u{f1a2}"),
)
#let redhat = symbol("\u{f7bc}")
#let renren = symbol("\u{f18b}")
#let replyd = symbol("\u{f3e6}")
#let researchgate = symbol("\u{f4f8}")
#let resolving = symbol("\u{f3e7}")
#let rev = symbol("\u{f5b2}")
#let rocketchat = symbol("\u{f3e8}")
#let rockrms = symbol("\u{f3e9}")
#let rust = symbol("\u{e07a}")
#let safari = symbol("\u{f267}")
#let salesforce = symbol("\u{f83b}")
#let sass = symbol("\u{f41e}")
#let schlix = symbol("\u{f3ea}")
#let scribd = symbol("\u{f28a}")
#let searchengin = symbol("\u{f3eb}")
#let sellcast = symbol("\u{f2da}")
#let sellsy = symbol("\u{f213}")
#let servicestack = symbol("\u{f3ec}")
#let shirtsinbulk = symbol("\u{f214}")
#let shopify = symbol("\u{e057}")
#let shopware = symbol("\u{f5b5}")
#let simplybuilt = symbol("\u{f215}")
#let sistrix = symbol("\u{f3ee}")
#let sith = symbol("\u{f512}")
#let sketch = symbol("\u{f7c6}")
#let skyatlas = symbol("\u{f216}")
#let skype = symbol("\u{f17e}")
#let slack = symbol(
  "\u{f198}",
  ("hash", "\u{f3ef}"),
)
#let slideshare = symbol("\u{f1e7}")
#let snapchat = symbol(
  "\u{f2ab}",
  ("ghost", "\u{f2ac}"),
  ("square", "\u{f2ad}"),
)
#let soundcloud = symbol("\u{f1be}")
#let sourcetree = symbol("\u{f7d3}")
#let speakap = symbol("\u{f3f3}")
#let speaker-deck = symbol("\u{f83c}")
#let spotify = symbol("\u{f1bc}")
#let squarespace = symbol("\u{f5be}")
#let stack-exchange = symbol("\u{f18d}")
#let stack-overflow = symbol("\u{f16c}")
#let stackpath = symbol("\u{f842}")
#let staylinked = symbol("\u{f3f5}")
#let steam = symbol(
  "\u{f1b6}",
  ("square", "\u{f1b7}"),
  ("symbol", "\u{f3f6}"),
)
#let sticker-mule = symbol("\u{f3f7}")
#let strava = symbol("\u{f428}")
#let stripe = symbol(
  "\u{f429}",
  ("s", "\u{f42a}"),
  ("cc", "\u{f1f5}"),
)
#let studiovinari = symbol("\u{f3f8}")
#let stumbleupon = symbol(
  "\u{f1a4}",
  ("circle", "\u{f1a3}"),
)
#let superpowers = symbol("\u{f2dd}")
#let supple = symbol("\u{f3f9}")
#let suse = symbol("\u{f7d6}")
#let swift = symbol("\u{f8e1}")
#let symfony = symbol("\u{f83d}")
#let teamspeak = symbol("\u{f4f9}")
#let telegram = symbol(
  "\u{f2c6}",
  ("plane", "\u{f3fe}"),
)
#let tencent-weibo = symbol("\u{f1d5}")
#let the-red-yeti = symbol("\u{f69d}")
#let themeco = symbol("\u{f5c6}")
#let themeisle = symbol("\u{f2b2}")
#let think-peaks = symbol("\u{f731}")
#let tiktok = symbol("\u{e07b}")
#let trade-federation = symbol("\u{f513}")
#let trello = symbol("\u{f181}")
#let tumblr = symbol(
  "\u{f173}",
  ("square", "\u{f174}"),
)
#let twitch = symbol("\u{f1e8}")
#let twitter = symbol(
  "\u{f099}",
  ("square", "\u{f081}"),
)
#let typo3 = symbol("\u{f42b}")
#let uber = symbol("\u{f402}")
#let ubuntu = symbol("\u{f7df}")
#let uikit = symbol("\u{f403}")
#let umbraco = symbol("\u{f8e8}")
#let uncharted = symbol("\u{e084}")
#let uniregistry = symbol("\u{f404}")
#let unity = symbol("\u{e049}")
#let unsplash = symbol("\u{e07c}")
#let untappd = symbol("\u{f405}")
#let ups = symbol("\u{f7e0}")
#let usb = symbol("\u{f287}")
#let usps = symbol("\u{f7e1}")
#let ussunnah = symbol("\u{f407}")
#let vaadin = symbol("\u{f408}")
#let viacoin = symbol("\u{f237}")
#let viadeo = symbol(
  "\u{f2a9}",
  ("square", "\u{f2aa}"),
)
#let viber = symbol("\u{f409}")
#let vimeo = symbol(
  "\u{f40a}",
  ("square", "\u{f194}"),
  ("v", "\u{f27d}"),
)
#let vine = symbol("\u{f1ca}")
#let vk = symbol("\u{f189}")
#let vnv = symbol("\u{f40b}")
#let vuejs = symbol("\u{f41f}")
#let watchman-monitoring = symbol("\u{e087}")
#let waze = symbol("\u{f83f}")
#let weebly = symbol("\u{f5cc}")
#let weibo = symbol("\u{f18a}")
#let weixin = symbol("\u{f1d7}")
#let whatsapp = symbol(
  "\u{f232}",
  ("square", "\u{f40c}"),
)
#let whmcs = symbol("\u{f40d}")
#let wikipedia = symbol("\u{f266}")
#let windows = symbol("\u{f17a}")
#let wix = symbol("\u{f5cf}")
#let wizards-of-the-coast = symbol("\u{f730}")
#let wodu = symbol("\u{e088}")
#let wolf-pack-battalion = symbol("\u{f514}")
#let wordpress = symbol(
  "\u{f19a}",
  ("simple", "\u{f411}"),
)
#let wpbeginner = symbol("\u{f297}")
#let wpexplorer = symbol("\u{f2de}")
#let wpforms = symbol("\u{f298}")
#let wpressr = symbol("\u{f3e4}")
#let xbox = symbol("\u{f412}")
#let xing = symbol(
  "\u{f168}",
  ("square", "\u{f169}"),
)
#let y-combinator = symbol("\u{f23b}")
#let yahoo = symbol("\u{f19e}")
#let yammer = symbol("\u{f840}")
#let yandex = symbol(
  "\u{f413}",
  ("international", "\u{f414}"),
)
#let yarn = symbol("\u{f7e3}")
#let yelp = symbol("\u{f1e9}")
#let yoast = symbol("\u{f2b1}")
#let youtube = symbol(
  "\u{f167}",
  ("square", "\u{f431}"),
)
#let zhihu = symbol("\u{f63f}")
