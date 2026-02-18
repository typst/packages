#import "./iconic-salmon-svg-icons.typ" as icon

/// A function that creates a clickable link with the passed name as text
/// In addition to this, the associated icon of the web page is inserted
///
/// - name (str): The visible name of the clickable link
/// - url (str): The URL to the website (it is assumed to start with the http/https scheme)
/// - icon-provider (function): The function that provides the associated icon
/// -> content
#let icon-link-generator(
  name,
  url,
  icon-provider,
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
    if url.ends-with(regex("\.(com|org|net|social)\/@?$")) {
      // links where the name is only appended, i.e. https://github.com/Bi0T1N
      clickable_link = url + name
    } else {
      // links where the profile link is more complicated, i.e. https://stackoverflow.com/users/20742512/bi0t1n
      clickable_link = url
    }

    // unify all links
    // Google Scholar doesn't find the profile if a slash is appended -.-'
    if not clickable_link.ends-with("/") and not clickable_link.contains("scholar.google") {
      clickable_link = clickable_link + "/"
    }

    // content
      icon-provider()
      " "
      link(clickable_link)[#styled_text]
}


//
// website information definitions
//
#let facebook-info(
  name,
  url: "https://www.facebook.com/",
  icon-func: icon.facebook-icon,
  ..args
) = {
  icon-link-generator(name, url, icon-func, ..args)
}

#let instagram-info(
  name,
  url: "https://www.instagram.com/",
  icon-func: icon.instagram-icon,
  ..args
) = {
  icon-link-generator(name, url, icon-func, ..args)
}

#let tiktok-info(
  name,
  url: "https://www.tiktok.com/@",
  icon-func: icon.tiktok-icon,
  ..args
) = {
  icon-link-generator(name, url, icon-func, ..args)
}

#let youtube-info(
  name,
  url: "https://www.youtube.com/@",
  icon-func: icon.youtube-icon,
  ..args
) = {
  icon-link-generator(name, url, icon-func, ..args)
}

#let vimeo-info(
  name,
  url: "https://vimeo.com/",
  icon-func: icon.vimeo-icon,
  ..args
) = {
  icon-link-generator(name, url, icon-func, ..args)
}

#let linkedin-info(
  name,
  url: "https://www.linkedin.com/",
  icon-func: icon.linkedin-icon,
  ..args
) = {
  icon-link-generator(name, url, icon-func, ..args)
}

#let xing-info(
  name,
  url: "https://www.xing.com/",
  icon-func: icon.xing-icon,
  ..args
) = {
  icon-link-generator(name, url, icon-func, ..args)
}

#let github-info(
  name,
  url: "https://github.com/",
  icon-func: icon.github-icon,
  ..args
) = {
  icon-link-generator(name, url, icon-func, ..args)
}

#let gitlab-info(
  name,
  url: "https://gitlab.com/",
  icon-func: icon.gitlab-icon,
  ..args
) = {
  icon-link-generator(name, url, icon-func, ..args)
}

#let bitbucket-info(
  name,
  url: "https://bitbucket.org/",
  icon-func: icon.bitbucket-icon,
  ..args
) = {
  icon-link-generator(name, url, icon-func, ..args)
}

#let codeberg-info(
  name,
  url: "https://codeberg.org/",
  icon-func: icon.codeberg-icon,
  ..args
) = {
  icon-link-generator(name, url, icon-func, ..args)
}

#let sourceforge-info(
  name,
  url: "https://sourceforge.net/",
  icon-func: icon.sourceforge-icon,
  ..args
) = {
  icon-link-generator(name, url, icon-func, ..args)
}

#let docker-info(
  name,
  url: "https://hub.docker.com/",
  icon-func: icon.docker-icon,
  ..args
) = {
  icon-link-generator(name, url, icon-func, ..args)
}

#let stackoverflow-info(
  name,
  url: "https://stackoverflow.com/",
  icon-func: icon.stackoverflow-icon,
  ..args
) = {
  icon-link-generator(name, url, icon-func, ..args)
}

#let stackexchange-info(
  name,
  url: "https://stackexchange.com/",
  icon-func: icon.stackexchange-icon,
  ..args
) = {
  icon-link-generator(name, url, icon-func, ..args)
}

#let skype-info(
  name,
  url: "https://www.skype.com/",
  icon-func: icon.skype-icon,
  ..args
) = {
  icon-link-generator(name, url, icon-func, ..args)
}

#let discord-info(
  name,
  url: "https://discord.com/",
  icon-func: icon.discord-icon,
  ..args
) = {
  icon-link-generator(name, url, icon-func, ..args)
}

#let twitter-info(
  name,
  url: "https://twitter.com/",
  icon-func: icon.twitter-icon,
  ..args
) = {
  icon-link-generator(name, url, icon-func, ..args)
}

#let x-twitter-info(
  name,
  url: "https://x.com/",
  icon-func: icon.x-twitter-icon,
  ..args
) = {
  icon-link-generator(name, url, icon-func, ..args)
}

#let orcid-info(
  name,
  url: "https://orcid.org/",
  icon-func: icon.orcid-icon,
  ..args
) = {
  icon-link-generator(name, url, icon-func, ..args)
}

#let tryhackme-info(
  name,
  url: "https://tryhackme.com/p/",
  icon-func: icon.tryhackme-icon,
  ..args
) = {
  icon-link-generator(name, url, icon-func, ..args)
}

#let mastodon-info(
  name,
  url: "https://mastodon.social/@",
  icon-func: icon.mastodon-icon,
  ..args
) = {
  icon-link-generator(name, url, icon-func, ..args)
}

#let researchgate-info(
  name,
  url: "https://www.researchgate.net/profile/",
  icon-func: icon.researchgate-icon,
  ..args
) = {
  icon-link-generator(name, url, icon-func, ..args)
}

#let google-scholar-info(
  name,
  url: "https://scholar.google.com/citations?user=",
  icon-func: icon.google-scholar-icon,
  ..args
) = {
  icon-link-generator(name, url, icon-func, ..args)
}
