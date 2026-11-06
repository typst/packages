/// A function that creates a clickable link with the passed name as text.
/// In addition to this, the associated icon of the web page is inserted
///
/// - name (str): The visible name of the clickable link
/// - url (str): The URL to the website (it is assumed to start with the http(s) scheme)
/// - filename (str): The filename of the associated icon
/// - icon_height (float): The height of the icon
/// -> content
#let icon-link-generator(
  name,
  url,
  filename,
  icon_height: 0.9em,
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
      box(image(
        "svg/" + filename,
        height: icon_height,
      ))
      " "
      link(clickable_link)[#styled_text]
}


#let facebook-info(
  name,
  url: "https://www.facebook.com/",
  filename: "Facebook_Logo_Primary.svg",
  ..args
) = {
  // icon-link-generator(name, url, filename, ..args)
  icon-link-generator(name, url, filename, icon_height: 1.1em, ..args)
}

#let instagram-info(
  name,
  url: "https://www.instagram.com/",
  filename: "Instagram_logo_2022.svg",
  ..args
) = {
  icon-link-generator(name, url, filename, ..args)
}

#let tiktok-info(
  name,
  url: "https://www.tiktok.com/@",
  filename: "TikTok_Icon_Black.svg",
  ..args
) = {
  icon-link-generator(name, url, filename, ..args)
}

#let youtube-info(
  name,
  url: "https://www.youtube.com/@",
  filename: "YouTube_full-color_icon_(2017).svg",
  ..args
) = {
  icon-link-generator(name, url, filename, ..args)
}

#let vimeo-info(
  name,
  url: "https://vimeo.com/",
  filename: "vimeo-tile.svg",
  ..args
) = {
  icon-link-generator(name, url, filename, ..args)
}

#let linkedin-info(
  name,
  url: "https://www.linkedin.com/",
  filename: "LinkedIn_icon.svg",
  ..args
) = {
  icon-link-generator(name, url, filename, ..args)
}

#let xing-info(
  name,
  url: "https://www.xing.com/",
  filename: "xing-icon.svg",
  ..args
) = {
  icon-link-generator(name, url, filename, ..args)
}

#let github-info(
  name,
  url: "https://github.com/",
  filename: "github-mark.svg",
  ..args
) = {
  icon-link-generator(name, url, filename, ..args)
}

#let gitlab-info(
  name,
  url: "https://gitlab.com/",
  filename: "GitLab_icon.svg",
  ..args
) = {
  icon-link-generator(name, url, filename, ..args)
}

#let bitbucket-info(
  name,
  url: "https://bitbucket.org/",
  filename: "mark-gradient-blue-bitbucket.svg",
  ..args
) = {
  icon-link-generator(name, url, filename, ..args)
}

#let codeberg-info(
  name,
  url: "https://codeberg.org/",
  filename: "codeberg-logo_icon_blue.svg",
  ..args
) = {
  icon-link-generator(name, url, filename, ..args)
}

#let sourceforge-info(
  name,
  url: "https://sourceforge.net/",
  filename: "sourceforge-seeklogo.svg",
  ..args
) = {
  icon-link-generator(name, url, filename, ..args)
}

#let docker-info(
  name,
  url: "https://hub.docker.com/",
  filename: "docker-mark-blue.svg",
  ..args
) = {
  icon-link-generator(name, url, filename, ..args)
}

#let stackoverflow-info(
  name,
  url: "https://stackoverflow.com/",
  filename: "Stack_Overflow_icon.svg",
  ..args
) = {
  icon-link-generator(name, url, filename, ..args)
}

#let stackexchange-info(
  name,
  url: "https://stackexchange.com/",
  filename: "Stack_Exchange_icon.svg",
  ..args
) = {
  icon-link-generator(name, url, filename, ..args)
}

#let skype-info(
  name,
  url: "https://www.skype.com/",
  filename: "skype-icon.svg",
  ..args
) = {
  icon-link-generator(name, url, filename, ..args)
}

#let discord-info(
  name,
  url: "https://discord.com/",
  filename: "Discord_icon_clyde_blurple_RGB.svg",
  ..args
) = {
  icon-link-generator(name, url, filename, ..args)
}

#let twitter-info(
  name,
  url: "https://twitter.com/",
  filename: "Logo_of_Twitter.svg",
  ..args
) = {
  icon-link-generator(name, url, filename, ..args)
}

#let x-twitter-info(
  name,
  url: "https://x.com/",
  filename: "X_logo_2023.svg",
  ..args
) = {
  icon-link-generator(name, url, filename, ..args)
}

#let orcid-info(
  name,
  url: "https://orcid.org/",
  filename: "ORCID_iD.svg",
  ..args
) = {
  icon-link-generator(name, url, filename, ..args)
}
