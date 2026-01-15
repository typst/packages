# git-trace

Lightweight Git metadata for your documents. ✨

## Why git-trace

Need your PDF or report to say exactly which Git state it came from? `git-trace`
peeks at the reflog and HEAD and hands you the branch, hash, message, and time. 🧭

## Features

- Read branch and HEAD hash from `.git`.
- Read last commit message and date from `.git/logs/HEAD`.
- Format reflog timestamps as `dd-mm-yyyy hh:mm` (24-hour time).

## Quick start

```typst
#import "@preview/git-trace:0.1.0": git-branch, git-head-hash, git-last-commit, git-format-date

#let info = git-last-commit()

Git branch: #git-branch() \
HEAD hash: #git-head-hash() \
Last commit: #info.message \
Last commit date: #(git-format-date(info.date))
```

## API

- `git-branch(git-dir: ".git") -> str | none`
- `git-head-hash(git-dir: ".git") -> str | none`
- `git-last-commit(git-dir: ".git") -> (branch, hash, message, date)`
- `git-format-date(date) -> str | none`

## Notes

- Commit message/date come from `.git/logs/HEAD` (reflog). The date is stored as
  `unix_timestamp timezone`, e.g. `1768468178 +0100`.
- The package only reads files; it does not run Git commands or modify the
  repository. ✅
