#import "@preview/fontawesome:0.1.0": *

  /// A function that creates a clickable link with the passed name as text.
  /// In addition to this, the associated icon of the web page is inserted
  ///
  /// - name (str): The visible name of the clickable link
  /// - url (str): The URL to the website (it is assumed to start with the http(s) scheme)
  /// - icon (function): A function from fontawesome that provides the associated icon
  /// -> content
#let icon-link-generator(
  name,
  url,
  icon,
  ..args
) = {
    if name.len() == 0 {
      panic("The name must contain at least one character")
    }

    if url.len() == 0 {
      panic("The url must contain at least one character")
    }

    let styled_text = text(
      name,
      ..args
    )

    let clickable_link
    if url.ends-with(regex("\.(com|org|net)/@?$")) {
      // links where the name is only appended, i.e. https://github.com/Bi0T1N
      clickable_link = url + name
    } else {
      // links where the profile link is more complicated, i.e. https://stackoverflow.com/users/20742512/bi0t1n
      clickable_link = url
    }

    // unify all links
    if not clickable_link.ends-with("/") {
      clickable_link = clickable_link + "/"
    }

    // content
    icon()
    " "
    link(clickable_link)[#styled_text]
}


#let facebook-info(
  name,
  url: "https://www.facebook.com/",
  ..args
) = {
  icon-link-generator(name, url, fa-facebook, ..args)
}

#let instagram-info(
  name,
  url: "https://www.instagram.com/",
  ..args
) = {
  icon-link-generator(name, url, fa-instagram, ..args)
}

#let tiktok-info(
  name,
  url: "https://www.tiktok.com/@",
  ..args
) = {
  // icon-link-generator(name, url, fa-tiktok, ..args)
  // icon-link-generator(name, url, fa-icon.with("\u{e07b}", fa-set: "Brands"), ..args)
  icon-link-generator(name, url, fa-icon.with("tiktok", fa-set: "Brands"), ..args)
}

#let youtube-info(
  name,
  url: "https://www.youtube.com/@",
  ..args
) = {
  icon-link-generator(name, url, fa-youtube, ..args)
}

#let vimeo-info(
  name,
  url: "https://vimeo.com/",
  ..args
) = {
  icon-link-generator(name, url, fa-vimeo, ..args)
}

#let linkedin-info(
  name,
  url: "https://www.linkedin.com/",
  ..args
) = {
  icon-link-generator(name, url, fa-linkedin, ..args)
}

#let xing-info(
  name,
  url: "https://www.xing.com/",
  ..args
) = {
  icon-link-generator(name, url, fa-xing, ..args)
}

#let github-info(
  name,
  url: "https://github.com/",
  ..args
) = {
  icon-link-generator(name, url, fa-github, ..args)
}

#let gitlab-info(
  name,
  url: "https://gitlab.com/",
  ..args
) = {
  icon-link-generator(name, url, fa-gitlab, ..args)
}

#let bitbucket-info(
  name,
  url: "https://bitbucket.org/",
  ..args
) = {
  icon-link-generator(name, url, fa-bitbucket, ..args)
}

// TODO: no icon available
// #let codeberg-info(
//   name,
//   url: "https://codeberg.org/",
//   ..args
// ) = {
//   icon-link-generator(name, url, fa-question, ..args)
// }

// TODO: no icon available
// #let sourceforge-info(
//   name,
//   url: "https://sourceforge.net/",
//   ..args
// ) = {
//   icon-link-generator(name, url, fa-question, ..args)
// }

#let docker-info(
  name,
  url: "https://hub.docker.com/",
  ..args
) = {
  icon-link-generator(name, url, fa-docker, ..args)
}

#let stackoverflow-info(
  name,
  url: "https://stackoverflow.com/",
  ..args
) = {
  // icon-link-generator(name, url, fa-stack-overflow, ..args)
  // icon-link-generator(name, url, fa-icon.with("\u{f16c}", fa-set: "Brands"), ..args)
  icon-link-generator(name, url, fa-icon.with("stack-overflow", fa-set: "Brands"), ..args)
}

#let stackexchange-info(
  name,
  url: "https://stackexchange.com/",
  ..args
) = {
  // icon-link-generator(name, url, fa-stack-exchange, ..args)
  // icon-link-generator(name, url, fa-icon.with("\u{f18d}", fa-set: "Brands"), ..args)
  icon-link-generator(name, url, fa-icon.with("stack-exchange", fa-set: "Brands"), ..args)
}

#let skype-info(
  name,
  url: "https://www.skype.com/",
  ..args
) = {
  icon-link-generator(name, url, fa-skype, ..args)
}

#let discord-info(
  name,
  url: "https://discord.com/",
  ..args
) = {
  icon-link-generator(name, url, fa-discord, ..args)
}

#let twitter-info(
  name,
  url: "https://twitter.com/",
  ..args
) = {
  icon-link-generator(name, url, fa-twitter, ..args)
}

#let x-twitter-info(
  name,
  url: "https://x.com/",
  ..args
) = {
  icon-link-generator(name, url, fa-icon.with("\u{e61b}"), ..args)
}

#let orcid-info(
  name,
  url: "https://orcid.org/",
  ..args
) = {
  icon-link-generator(name, url, fa-icon.with("orcid", fa-set: "Brands"), ..args)
}
