// ===========================================================================
//  socialbox — dedicated preview page
//
//    typst compile pages/socialbox.typ pages/socialbox.pdf --root . --font-path fonts
// ===========================================================================

#import "/lib.typ": *
#import "/pages/_preview.typ": titre

#set page(width: 17.5cm, height: auto, margin: 10mm)
#set text(font: "DejaVu Sans", size: 10.5pt)
#set par(leading: 0.62em)

= socialbox — social-network posts 

 _#emoji.hand.write FERGOUS Abdelhak_

After ProfCollege’s `Twitter` / `Facebook` / `Instagram` / `Snapchat` /
`Mastodon` environments. Pass `thread:` for a real post with replies.

#titre[1. a real tweet — `thread` + liked replies]

#tweetbox(
  author: "Maxime",
  handle: [maxime],
  date: [23 Aug],
  published: true,
  likes: 128,
  reposts: 17,
  liked: true,
  thread: (
    (
      author: "Léa", handle: [lea.m], time: [4m],
      likes: 24, liked: true,
      body: [Clear — so $A C = 13$ is the hypotenuse.],
    ),
    (
      author: "Yanis", handle: [yanis], time: [12m],
      likes: 6,
      body: [And if a side is missing? Just isolate it.],
    ),
    (
      author: "Nora", handle: [nora.math], time: [20m],
      likes: 15, liked: true,
      body: [$ b = sqrt(c^2 - a^2) $. Same idea for any right triangle.],
    ),
  ),
)[
  In a right triangle, $A C^2 = A B^2 + B C^2$. \
  With $A B = 5$ and $B C = 12$, we get $A C = 13$.
]

#titre[2. a Facebook post with comments]

#facebookbox(
  author: "Collège El-Biar",
  date: [21 Aug], time: [18:40],
  published: true, liked: true,
  likes: 64, shares: 3,
  thread: (
    (author: "Samir", body: [Page 42, exercise 3 as well?],
      likes: 8, liked: true, time: [1 h]),
    (author: "Inès", body: [Yes — and bring a set square.],
      likes: 3, time: [45 min]),
    (author: "Karim", body: [Thanks!], likes: 1, time: [20 min]),
  ),
)[
  Homework is on page 42. Bring a ruler tomorrow.
]

#titre[3. Instagram — caption + comments]

#instabox(
  author: "geo.club",
  caption: [Thales, on the board.],
  likes: 86, liked: true, time: 48,
  thread: (
    (author: "lea.m", body: [The intercept theorem never gets old.],
      likes: 11, liked: true, time: [2 h]),
    (author: "yanis", body: [Saved this.], likes: 2, time: [1 h]),
  ),
)[
  #box(width: 100%, height: 3.2cm, fill: rgb("#E8F0F7"),
    align(center + horizon, text(size: 1.4em)[$ (A M)/(A B) = (A N)/(A C) $]))
]

#titre[4. `tweetbox` — a lone tweet]

#tweetbox(author: "Maxime", handle: [maxime], date: [23 Aug])[
  In a right triangle, $A C^2 = A B^2 + B C^2$. \
  With $A B = 5$ and $B C = 12$, we get $A C = 13$.
]

#titre[2. `tweetbox` with `published: true`]

#tweetbox(author: "Nora", handle: [nora.math], published: true,
  comments: 4, reposts: 11, likes: 37, date: [22 Aug])[
  A short published tweet, with counts on the action row.
]

#titre[3. `facebookbox`]

#facebookbox(author: "Léa Martin", date: [23 Aug], time: [08:12])[
  Today’s exercise: factor $x^2 - 5x + 6$.
]

#titre[4. `facebookbox` published]

#facebookbox(author: "Collège El-Biar", published: true,
  likes: 64, comments: 9, shares: 3, date: [21 Aug], time: [18:40])[
  Homework is on page 42. Bring a ruler tomorrow.
]

#titre[5. `instabox` — media + caption]

#instabox(author: "geo.club", caption: [Thales, on the board.],
  likes: 26, time: 48)[
  #box(width: 100%, height: 3.4cm, fill: rgb("#E8F0F7"),
    align(center + horizon, text(size: 1.4em)[$ (A M)/(A B) = (A N)/(A C) $]))
]

#titre[6. `snapbox`]

#snapbox(author: "Yanis", time: 6)[
  Quick recap: a square has four right angles and four equal sides.
]

#titre[7. `mastodonbox`]

#mastodonbox(author: "Ada", handle: [ada\@mathstodon.xyz],
  date: [2 d], published: true, replies: 7)[
  Open question: how would you introduce negative numbers in year 7?
]

#titre[8. dispatcher `#socialbox(kind: …)`]

#grid(columns: (1fr, 1fr), gutter: 0.35cm,
  socialbox(kind: "tweet", author: "Sam", handle: [sam])[Same box, via `kind`.],
  socialbox(kind: "snap", author: "Inès", time: 2)[A snap, via `kind`.],
)

#titre[9. RTL — avatar, handle, date, and a real thread]

#[
  #set text(lang: "ar", dir: rtl, font: ("Tajawal", "DejaVu Sans"))
  #tweetbox(
    author: "مريم", handle: [maryam], date: [23 أوت],
    published: true, likes: 54, liked: true,
    thread: (
      (author: "يوسف", handle: [youcef], time: [4د],
        likes: 11, liked: true,
        body: [واضح. إذن الوتر يساوي 13.]),
      (author: "ليلى", handle: [layla], time: [12د],
        likes: 5,
        body: [وماذا لو ضلع واحد مجهول؟]),
      (author: "سامي", handle: [sami], time: [20د],
        likes: 8, liked: true,
        body: [نعزل المجهول: $b = sqrt(c^2 - a^2)$.]),
    ),
  )[
    في المثلث القائم: $a^2 + b^2 = c^2$.
  ]
  #v(0.55em)
  #facebookbox(
    author: "ثانوية ابن خلدون",
    date: [22 أوت], time: [10:05],
    published: true, liked: true, likes: 31, shares: 1,
    thread: (
      (author: "سمير", body: [الصفحة 42، التمرين 3 أيضاً؟],
        likes: 7, liked: true, time: [1 س]),
      (author: "إيناس", body: [نعم، وأحضروا الكوس.],
        likes: 2, time: [40 د]),
    ),
  )[
    تمرين اليوم: بسّط الكسر $24/36$.
  ]
  #v(0.55em)
  #instabox(
    author: "نادي.الهندسة",
    caption: [طالبس على السبورة.],
    likes: 41, liked: true, time: 30,
    thread: (
      (author: "ليلى", body: [النظرية لا تقدُم.],
        likes: 9, liked: true, time: [2 س]),
      (author: "يوسف", body: [حفظت المنشور.],
        likes: 3, time: [1 س]),
    ),
  )[
    #box(width: 100%, height: 2.6cm, fill: rgb("#E8F0F7"),
      align(center + horizon, text(size: 1.25em)[$ (A M)/(A B) = (A N)/(A C) $]))
  ]
]

#titre[10. custom `avatar`]

#tweetbox(
  author: [Club Maths],
  handle: [club],
  avatar: text(size: 0.95em)[π],
  avatar-colour: rgb("#6A1B9A"),
  date: [today],
)[
  Custom avatar: any content, clipped to a circle.
]
