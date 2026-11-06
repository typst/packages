# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project partly adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
This project also follows a yearly release cycle, releasing a new calendar in January of each year.
Yearly releases are not tracked in this changelog.

## [Unreleased]


## [1.1.0](https://github.com/extua/october/releases/tag/v1.1.0) - 2026-10-07

This release includes two changes by Vinesh Benny (@VBenny42):

- Add a layout option for weeks starting on Sunday or Monday ([#8](https://github.com/extua/october/pull/8)).
  My partner's shift calendar starts on Sundays, so this is a very useful feature!
  This can be enabled by passing `sunday_as_start: true` to the calendar function.
- Remove border around empty cells ([#6](https://github.com/extua/october/pull/6)),
  which makes the calendar look a lot neater.

Thanks Vinesh!

## [1.0.2](https://github.com/extua/october/releases/tag/v1.0.2) - 2025-10-28

Remove the `$CURRENT_YEAR` variable from the release workflow, which allowed the release to run successfully.
I would like to set this up to release a new version automatically on January 1 of each year; but not now.

## [1.0.1](https://github.com/extua/october/releases/tag/v1.0.1) - 2025-10-28

Small changes to the design of the calendar to set margin and text size in main document;
remove the border around month headings and align them to the left.
Inspired by similar work done by @sermuns.

## [1.0.0](https://github.com/extua/october/releases/tag/v1.0.0) - 2024-10-20

🌱 Initial release, added to Typst Universe on 18 October 2024.
