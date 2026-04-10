#import "../iconic-salmon-svg.typ": *
#import "../iconic-salmon-svg-icons.typ" as icon

= Usage Examples
== Facebook
#facebook-info("NEFFEX", url: "https://www.facebook.com/Neffexmusic/")
#h(1cm)
#facebook-info("NEFFEX", url: "https://www.facebook.com/Neffexmusic", blue)
#h(1cm)
#let custom_facebook_icon_size() = icon.facebook-icon(height: 0.5em)
#facebook-info("NEFFEX", url: "https://www.facebook.com/Neffexmusic", icon-func: custom_facebook_icon_size)

== Instagram
#instagram-info("janlo.pulling_pictures")
#h(0.5cm)
#instagram-info("janlo.pulling_pictures", purple)
#h(0.5cm)
#instagram-info("Jan Lo - Tractor-Pulling Media „Jan Knips“", url: "https://www.instagram.com/janlo.pulling_pictures/")

== TikTok
#tiktok-info("neffex", green, style: "italic")
#h(1cm)
#tiktok-info("NEFFEX", url: "https://www.tiktok.com/@neffex/", font: "DejaVu Sans")

== YouTube
#youtube-info("floatingfinish2211")
#h(1cm)
#youtube-info("floatingfinish2211", rgb("#0033cc"), weight: "bold")
#h(1cm)
#youtube-info("Floating Finish", url: "https://www.youtube.com/@floatingfinish2211", green)

== Vimeo
#vimeo-info("osrfoundation")
#h(1cm)
#vimeo-info("Open Robotics", url: "https://vimeo.com/osrfoundation/")

== LinkedIn
#linkedin-info("lexfridman")
#h(1cm)
#linkedin-info("Lex Fridman", url: "https://www.linkedin.com/in/lexfridman/")
\
#linkedin-info-company("Oxford University Innovation", url: "https://uk.linkedin.com/company/oxford-university-innovation/")
#h(1cm)
#linkedin-info-company("bmw-group", rgb("#0166B1"))

== XING
#xing-info("Pooyan_Aliuos")
#h(1cm)
#xing-info("Alexander Kühn", url: "https://www.xing.com/profile/Alexander_Kuehn29")
\
#xing-info-company("ABB Deutschland", url: "https://www.xing.com/pages/abbde")
#h(1cm)
#xing-info-company("CLAAS", url: "https://www.xing.com/pages/claas/", rgb("#FE0000"))
#h(1cm)
#xing-info-company("abbde")

== GitHub
#github-info("Bi0T1N")
#h(1cm)
#github-info("Bi0T1N", rgb("#ffcc00"))
#h(1cm)
#github-info("Bi0T1N", green)

== GitLab
#gitlab-info("Bi0T1N")
#h(1cm)
#gitlab-info("Bi0T1N", rgb("#811052"))
#h(1cm)
#gitlab-info("Bi0T1N", green)
#h(1cm)
#gitlab-info("Bi0T1N", url: "https://gitlab.com/Bi0T1N/fpc-docker")

== Bitbucket
#bitbucket-info("karaiskc")
#h(1cm)
#bitbucket-info("karaiskc", url: "https://bitbucket.org/karaiskc/ros-sensor-info-viewer-and-logger/")

== Codeberg
#codeberg-info("biotite-dev")

== SourceForge
#sourceforge-info("Lazarus", url: "https://sourceforge.net/projects/lazarus/")

== Docker
#docker-info("rust", url: "https://hub.docker.com/_/rust", rgb("b7410e"))
#h(1cm)
#docker-info("Bi0T1N", url: "https://hub.docker.com/u/bi0t1n")
#h(1cm)
#docker-info("debian", url: "https://hub.docker.com/_/debian", red)

== Stack Overflow
#stackoverflow-info("Remy Lebeau", url: "https://stackoverflow.com/users/65863/remy-lebeau")
#h(1cm)
#stackoverflow-info("Bi0T1N", url: "https://stackoverflow.com/users/20742512/bi0t1n", orange)

== Stack Exchange
#stackexchange-info("Remy Lebeau", url: "https://scifi.stackexchange.com/users/42754/remy-lebeau")
#h(1cm)
#stackexchange-info("Bi0T1N", url: "https://robotics.stackexchange.com/users/33077/bi0t1n")

== Skype
#skype-info("callme")

== Discord
#discord-info("messageme")

== Twitter
#twitter-info("elonmusk", rgb("#663300"))
#h(1cm)
#twitter-info("Elon Musk", url: "https://twitter.com/elonmusk/", rgb("#663300"))

== X / Twitter
#x-twitter-info("elonmusk", rgb("#663300"))
#h(1cm)
#x-twitter-info("Elon Musk", url: "https://twitter.com/elonmusk/", rgb("#663300"))

== ORCID
#orcid-info("0000-0002-1825-0097")
#h(1cm)
#orcid-info("Josiah Carberry", url: "https://orcid.org/0000-0002-1825-0097", green)

== TryHackMe
#tryhackme-info("Bi0T1N", url: "https://tryhackme.com/p/Bi0T1N")
#h(1cm)
#let custom_tryhackme_icon_large() = icon.tryhackme-icon(file: "svg/tryhackme_logo_icon_249349.svg", height: 3.3em)
#tryhackme-info("Bi0T1N", url: "https://tryhackme.com/p/Bi0T1N", icon-func: custom_tryhackme_icon_large)
#h(1cm)
#let custom_tryhackme_icon_mini() = icon.tryhackme-icon(file: "svg/tryhackme_logo_icon_249349.svg", height: 0.6em)
#tryhackme-info("Bi0T1N", url: "https://tryhackme.com/p/Bi0T1N", icon-func: custom_tryhackme_icon_mini)

== Mastodon
#mastodon-info("Electronic Frontier Foundation", url: "https://mastodon.social/@eff")
#h(1cm)
#mastodon-info("wikiRandomImgs")

== ResearchGate
#researchgate-info("Josiah-Carberry", url: "https://www.researchgate.net/profile/Josiah-Carberry")
#h(1cm)
#researchgate-info("Josiah Carberry", url: "https://www.researchgate.net/profile/Josiah-Carberry", green)

== Google Scholar
#google-scholar-info("David Campbell", url: "https://scholar.google.com/citations?user=icXJxqwAAAAJ")
