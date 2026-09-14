#import "/src/utils.typ": *

#let tests = (
  // Main tests (covers most of English language)
  ("Europe","a"),
  ("European","a"),
  ("Hannah","a"),
  ("T-shirt","a"),
  ("Xerox","a"),
  ("Zebra","a"),
  ("aardvark","an"),
  ("apple","an"),
  ("boat","a"),
  ("car","a"),
  ("cat","a"),
  ("chair","a"),
  ("dog","a"),
  ("egg","an"),
  ("elephant","an"),
  ("emu","an"),
  ("eucalyptus","a"),
  ("eulogy","a"),
  ("euphemism","a"),
  ("exhausted","an"),
  ("ghost","a"),
  ("hat","a"),
  ("heir","an"),
  ("heiress","an"),
  ("herb","an"),
  ("herbal","an"),
  ("historic","a"),
  ("history","a"),
  ("homage","an"),
  ("honest","an"),
  ("honestly","an"),
  ("honor","an"),
  ("honorary","an"),
  ("honour","an"),
  ("horse","a"),
  ("hour","an"),
  ("hourglass","an"),
  ("house","a"),
  ("iris","an"),
  ("orange","an"),
  ("owl","an"),
  ("table","a"),
  ("ugly","an"),
  ("umbrella","an"),
  ("umpire","an"),
  ("unicorn","a"),
  ("unique","a"),
  ("university","a"),
  ("urn","an"),
  ("usage","a"),
  ("user","a"),
  ("utensil","a"),

  // Acronym tests
  ("ASCII","an"),
  ("CFO","a"),
  ("F.A.Q.","an"),
  ("FBI","an"),
  ("GIF","a"),
  ("HIV","an"),
  ("JPEG","a"),
  ("LED","an"),
  ("MRI","an"),
  ("NATO","an"),
  ("PNG","a"),
  ("Q&A","a"),
  ("RF","an"),
  ("RNG","an"),
  ("SAS","an"),
  ("SMS","an"),
  ("SOS","an"),
  ("SQL","an"),
  ("UFO","a"),
  ("URL","a"),
  ("VCR","a"),
  ("WWW","a"),
  ("X.Y.Z.","an"),
  ("YAML","a"),

  // Extra tests (courtesy of LLM)

  // Common English words starting with vowels
  ("idea","an"),
  ("island","an"),
  ("offer","an"),
  ("option","an"),
  ("operation","an"),
  ("appletree","an"),
  ("iguana","an"),
  ("octopus","an"),
  ("atom","an"),
  ("item","an"),

  // Words starting with vowel but "yoo" sound (thus 'a')
  ("universe","a"),
  ("unicycle","a"),
  ("uniform","a"),
  ("union","a"),
  ("united","a"),
  ("unique","a"), // already tested, reaffirmed
  ("usual","a"),
  ("useful","a"),
  ("utility","a"),
  ("utopia","a"),

  // More common vowel words with a/an
  ("umbrella","an"), // repeated but reaffirming
  ("eggplant","an"),
  ("insect","an"),
  ("eleven","an"),
  ("olive","an"),
  ("impulse","an"),
  ("ox","an"),
  ("aroma","an"),
  ("ear","an"),
  ("ocean","an"),

  // Words starting with 'h' but pronounced, so 'a'
  ("house","a"), // repeated for emphasis
  ("hammer","a"),
  ("helmet","a"),
  ("history","a"), // repeated
  ("hero","a"),
  ("hill","a"),
  ("hobby","a"),
  ("holiday","a"),
  ("harmony","a"),
  ("hover","a"),

  // More silent 'h' words (already in set, but variations)
  ("honorific","an"),
  ("honorarium","an"),
  ("honesties","an"),
  ("hourly","an"),
  ("heirloom","an"),

  // Words starting with 'e' + 'u' combo with "yoo" sound
  ("Europe","a"),    // repeated
  ("European","a"),  // repeated
  ("euphoric","a"),
  ("eureka","a"),
  ("euphemistic","a"),
  ("euphonious","a"),
  ("eucalyptus","a"), // repeated
  ("euthanasia","a"),
  ("eugenics","a"),
  ("Eurasia","a"),

  // Common consonant-start words
  ("book","a"),
  ("pen","a"),
  ("fork","a"),
  ("spoon","a"),
  ("knife","a"),
  ("ball","a"),
  ("tree","a"),
  ("river","a"),
  ("mountain","a"),
  ("cloud","a"),

  // More vowel-start words
  ("ostrich","an"),
  ("amphibian","an"),
  ("eleven","an"), // repeated
  ("issue","an"),
  ("incense","an"),
  ("antenna","an"),
  ("echo","an"),
  ("aisle","an"),
  ("oracle","an"),
  ("overcoat","an"),

  // More acronym/initialism tests:
  ("ATM","an"),  // A = 'ay'
  ("EPA","an"),  // E = 'ee'
  ("FAQ","an"),  // F = 'eff', repeated as F.A.Q.
  ("HTML","an"), // H = 'aitch'
  ("IBM","an"),  // I = 'eye'
  ("LAN","an"),  // L = 'el'
  ("NFL","an"),  // N = 'en'
  ("OSHA","an"), // O = 'oh'
  ("RAM","an"),  // R = 'ar'
  ("SMS","an"),  // repeated, S = 'ess'

  // Acronyms starting with consonant sound letters
  ("GIF","a"),  // G = 'jee', repeated
  ("CFO","a"),  // C = 'see', repeated (consonant sound 's')
  ("CEO","a"),  // C = 'see'
  ("DNA","a"),  // D = 'dee' starts with 'd' consonant sound
  ("PGA","a"),  // P = 'pee' starts with 'p' consonant sound
  ("QVC","a"),  // Q = 'kyoo' starts with 'k' consonant sound
  ("TNT","a"),  // T = 'tee' starts with 't' consonant sound
  ("UPS","a"),  // U = 'yoo' sound, hence 'a'
  ("VIP","a"),  // V = 'vee' starts with 'v' consonant sound
  ("WIPO","a"), // W = 'double-u' starts with 'd' consonant sound

  // More tricky 'u' words with 'yoo' sound for 'a'
  ("unify","a"),
  ("unilateral","a"),
  ("ubiquitous","a"), // 'yoo-bik...'
  ("usurp","a"),
  ("usuary","a"),    // 'yoo-zhoo-ary' (rare, but treat like usual)
  ("uterus","a"),    // 'yoo-terus'
  ("usher","an"),    // 'uh-sher' vowel sound
  ("ugly","an"),     // repeated, 'uh-glee'
  ("upper","an"),     // 'uh-pur' (vowel sound but actually 'uh' sound = 'an'? Actually "upper" starts with a simple vowel sound 'uh', so should it be 'an'? It's commonly "an upper hand".
  ("update","an"),    // 'up-date' starts with 'uh' vowel sound → 'an update' normally. Actually we say "an update" commonly. Correcting to 'an':

  // Words starting with 'u' that actually take "an"
  // (because they start with a vowel sound 'uh'):
  ("under","an"),
  ("understand","an"),
  ("unusual","an"),
  ("unreal","an"),
  ("unemployed","an"),
  ("unequal","an"),
  ("unopened","an"),
  ("unarmed","an"),
  ("uneasy","an"),
  ("united","a"), // 'yoo-nited' is 'a united front'
  ("universal","a"),
  ("umbrella","an"), // repeated
  ("upset","an"),    // 'uh-pset' vowel start

  // More vowel words to ensure coverage:
  ("animal","an"),
  ("image","an"),
  ("order","an"),
  ("arrow","an"),
  ("ace","an"),
  ("acre","an"),
  ("agent","an"),
  ("artist","an"),
  ("idea","an"), // repeated
  ("aim","an"),
  ("item","an"), // repeated
  ("isotope","an"),
  ("opera","an"),

  // Words starting with vowels but pronounced with consonant sound 'y' → 'a'
  ("euphemistic","a"), // repeated
  ("euphoric","a"),
  ("eulogy","a"), // repeated
  ("Europe","a"), // repeated
  ("European","a"), // repeated
  ("eugenics","a"), // repeated
  ("euphemism","a"), // repeated
  ("eureka","a"), // repeated
  ("euphonious","a"),
  ("Eurasia","a"),

  // Common consonant-start words:
  ("milk","a"),
  ("road","a"),
  ("stone","a"),
  ("book","a"), // repeated
  ("pen","a"),  // repeated
  ("fork","a"), // repeated
  ("spoon","a"), // repeated
  ("knife","a"), // 'knife' actually starts with /n/ sound because 'k' is silent. "a knife" or "an knife"? It's "a knife" (starts with 'n' consonant sound?), actually 'kn' in 'knife' is silent, so 'knife' is pronounced 'nife' with a consonant sound 'n', so "a knife" is correct.
  ("glass","a"),
  ("window","a"),

  // Final checks with tricky silent letters:
  ("gnome","a"), // 'g' silent, pronounced 'nome' with 'n' consonant sound → 'a gnome'
  ("gnat","a"),  // 'nat' consonant sound → 'a gnat'
  ("xylophone","a"), // 'zylophone' → 'z' consonant sound → 'a xylophone'
  ("xenon","a"), // 'zee-non' consonant sound 'z' → 'a xenon'
  ("honorific","an"), // repeated but reaffirming
  ("hourly","an"), // repeated but reaffirming
  ("honorably","an"),
  ("honorifics","an"),
  ("honors","an"),
)

#for (word, article) in tests {
  let chosen = __determine_article(word)
  if chosen != article {
    panic("bad choice! word: " + word + ", article: " + article + ", chosen: " + chosen)
  }
}

#set page(height: auto, width: auto, margin: 1em)

Success! All articles determined properly!
