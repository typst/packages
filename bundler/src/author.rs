use anyhow::{bail, Context};
use email_address::EmailAddress;
use unscanny::Scanner;

/// Validates the format of an author field. It can contain a name and, in angle
/// brackets, one of a URL, email or GitHub handle.
pub fn validate_author(name: &str) -> anyhow::Result<()> {
    let mut s = Scanner::new(name);

    s.eat_until(|c| c == '<');
    if s.eat_if('<') {
        let contact = s.eat_until('>');
        if let Some(handle) = contact.strip_prefix('@') {
            validate_github_handle(handle).context("GitHub handle is invalid")?;
        } else if contact.starts_with("http") {
            validate_url(contact).context("URL is invalid")?;
        } else {
            let _addr: EmailAddress = contact.parse().context("email is invalid")?;
        }
        if !s.eat_if('>') {
            bail!("expected '>'");
        }
    }

    Ok(())
}

/// Validates a GitHub handle.
fn validate_github_handle(handle: &str) -> anyhow::Result<()> {
    if handle.len() > 39 {
        bail!("cannot be longer than 39 characters");
    }

    if !handle
        .chars()
        .all(|c| c.is_ascii_alphanumeric() || c == '-')
    {
        bail!("must only contain alphanumeric characters and '-'");
    }

    if handle.starts_with('-') || handle.ends_with('-') {
        bail!("must not start or end with a hyphen");
    }

    if handle.contains("--") {
        bail!("cannot contain consecutive hyphens");
    }

    Ok(())
}

/// Performs primitive validation of a URL.
fn validate_url(url: &str) -> anyhow::Result<()> {
    if !url.chars().all(is_legal_in_url) {
        bail!("URL contains invalid characters");
    }
    Ok(())
}

/// Whether a character is legal in a URL.
fn is_legal_in_url(c: char) -> bool {
    c.is_ascii_alphanumeric() || "-_.~:/?#[]@!$&'()*+,;=".contains(c)
}

#[cfg(test)]
mod tests {
    use super::validate_author;

    #[test]
    fn parse_author_name() {
        validate_author("Martin").unwrap();
        validate_author("Martin <@reknih>").unwrap();
        validate_author("Martin <https://mha.ug>").unwrap();
        validate_author("Martin <martin.haug@typst.app>").unwrap();

        // Check wrong GitHub username
        assert!(validate_author("Martin <@reknih->").is_err());
        assert!(validate_author("Martin <@-reknih>").is_err());
        assert!(validate_author("Martin <@räknih>").is_err());
        assert!(validate_author("Martin <@reknih").is_err());

        // Check wrong email addresses
        assert!(validate_author("Martin <>").is_err());
        assert!(validate_author("Martin <martin>").is_err());
        assert!(validate_author("Martin <m@.de>").is_err());
        assert!(validate_author("Martin <m@hello.>").is_err());
        assert!(validate_author("Martin < >").is_err());
        assert!(validate_author("Martin <martin@typst.app").is_err());

        // Check wrong URLs
        assert!(validate_author("Martin <http://mha ug>").is_err());
        assert!(validate_author("Martin <http://mhä.ug>").is_err());
        assert!(validate_author("Martin <http://mha.ug").is_err());
    }
}
