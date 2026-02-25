# Contributing

Contributions are welcome, and they are greatly appreciated! Every little bit helps, and credit will always be given.

You can contribute in many ways:

## Types of Contributions

### Report Bugs

Report bugs at [`github.com/npikall/rubber-article`][repo].

If you are reporting a bug, please include:

- Your operating system name and version. (run `just info`)
- Any details about your local setup that might be helpful in troubleshooting.
- Detailed steps to reproduce the bug.

### Fix Bugs

Look through the GitHub issues for bugs. Anything tagged with "bug" and "help wanted" is open to whoever wants to implement it.

### Implement Features

Look through the GitHub issues for features. Anything tagged with "enhancement" and "help wanted" is open to whoever wants to implement it.

### Write Documentation

`rubber-article` could always use more documentation, whether as part of the official docs, in docstrings, or even on the web in blog posts, articles, and such.

### Submit Feedback

The best way to send feedback is to file an issue at [`github.com/npikall/rubber-article`][repo].

If you are proposing a feature:

- Explain in detail how it would work.
- Keep the scope as narrow as possible, to make it easier to implement.
- Remember that this is a volunteer-driven project, and that contributions are welcome :)

## Get Started!

Ready to contribute? Here's how to set up `rubber-article` for local development.

1. Fork the `rubber-article` repo on GitHub.
2. Clone your fork locally:

   ```sh
   git clone git@github.com:npikall/rubber-article.git
   ```

3. Install the dependencies. This project only needs [`typst`][typst]

4. Install Tools to run all the workflows. You will need to install:
   - [just][Just] a taskrunner
   - [tytanic][tytanic] a typst testing framework
   - [gotpm][gotpm] a minimal typst package manager

5. Create a branch for local development:

   ```sh
   git checkout -b name-of-your-bugfix-or-feature
   ```

   Now you can make your changes locally.

6. When you're done making changes, check that your changes are formatted correctly and the tests are passing

   ```sh
   just test-all
   ```

   To get the linter, formatter and the typechecker all you need is [uv].

7. Commit your changes and push your branch to GitHub:

   ```sh
   git add .
   git commit -m "Your detailed description of your changes."
   git push origin name-of-your-bugfix-or-feature
   ```

8. Submit a pull request through the GitHub website.

## Pull Request Guidelines

Before you submit a pull request, check that it meets these guidelines:

1. The pull request should include tests.
2. If the pull request adds functionality, the docs should be updated. Put your new functionality into a function with a docstring, and add the feature to the list in README.md.

## Deploying

A reminder for the maintainers on how to deploy. Make sure all your changes are committed. Then run:

```sh
just release patch # target can be semver or bump incrementation
git push
git push --tags
```

[uv]: https://docs.astral.sh/uv/
[Just]: https://github.com/casey/just
[repo]: https://github.com/npikall/rubber-article/issues
[typst]: https://github.com/typst/typst
[tytanic]: https://github.com/typst-community/tytanic
[gotpm]: https://github.com/npikall/gotpm
