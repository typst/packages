// ===========================================================================
//  socialyst — social-network post boxes for Typst.
//
//    #import "socialyst/lib.typ": *
//
//    #tweetbox(author: "Maxime", handle: [maxime], thread: (...))[…]
//    #facebookbox(author: "Léa", published: true)[…]
//    #socialbox(kind: "instagram", author: "nora")[…]
//
//  Typst 0.15.x · needs @preview/fontawesome:0.6.2
//  Install Font Awesome 7 Free + Brands, or pass --font-path to those OTFs.
// ===========================================================================

#import "src/socialbox.typ": (
  is-rtl,
  socialbox,
  tweetbox, twitterbox,
  facebookbox,
  instabox, instagrambox,
  snapbox, snapchatbox,
  mastodonbox, tootbox,
)
