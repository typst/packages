# flupke-headstamp

Lightweight Git metadata for your documents. ✨

## Why flupke-headstamp

Need your PDF or report to say exactly which Git state it came from? `flupke-headstamp`
peeks at the reflog and HEAD and hands you the branch, hash, message, and time. 🧭

## Features

- Read branch and HEAD hash from `.git`.
- Read last commit message and date from `.git/logs/HEAD`.
- Format reflog timestamps as `dd-mm-yyyy hh:mm` (24-hour time).

## Quick start

```typst
#import "@preview/flupke-headstamp:0.1.0": git-branch, git-head-hash, git-last-commit, git-format-date

#let git-read = path => read(path)
#let info = git-last-commit(read: git-read)

Git branch: #git-branch(read: git-read) \
HEAD hash: #git-head-hash(read: git-read) \
Last commit: #info.message \
Last commit date: #(git-format-date(info.date))
```

## API

- `git-branch(git-dir: ".git", read: none) -> str | none`
- `git-head-hash(git-dir: ".git", read: none) -> str | none`
- `git-last-commit(git-dir: ".git", read: none) -> (branch, hash, message, date)`
- `git-format-date(date) -> str | none`

## Notes

- Commit message/date come from `.git/logs/HEAD` (reflog). The date is stored as
  `unix_timestamp timezone`, e.g. `1768468178 +0100`.
- Pass `read: path => read(path)` so the package reads files relative to your
  document, not the package cache.
- The package only reads files; it does not run Git commands or modify the
  repository. ✅
