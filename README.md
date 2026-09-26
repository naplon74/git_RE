# Git Repo Extension - Git_RE

Simple multi-repository git status tool for Linux.

It scans your system for git repositories, collects their status, and displays a clean summary.

## Features

- Finds all git repositories under your home directory
- Shows branch and dirty/clean status
- Pretty table output with [rich](https://pypi.org/project/rich/)
- Configurable path via `config.json`

## Requirements

- `bash`
- `git`
- `jq`
- `python3`

Needed for python : [rich](https://pypi.org/project/rich/)

## Setup

1. Edit `config.json` and set your preferred path (default is /usr/bin/git):

```json
{
    "path_to_git": "/home/yourusername/Projects"
}
``` 

>[!TIP]
>The default path usualy always works. If you installed git on your system and `/usr/bin/git` isn't the path then use `where git` or `whereis git` to locate it.

2. Make the script executable:

```bash
chmod +x src/git_re.sh
```

## Usage
```bash
./src/git_re.sh
```

## Project Structure

    git_ME/
    ├── config.json
    ├── repos_status.json
    ├── src/
    │   ├── git_re.sh
    │   └── output.py
    └── README.md

## Exemple output

<img width="1150" height="500" alt="Screenshot From 2026-09-24 16-41-13" src="https://github.com/user-attachments/assets/faab7c72-fcb5-433e-9d94-acf217c7055a" />

>[!NOTE]
>This is a demo image.
>`Dirty` means they are modified, added, or deleted files that haven't been committed yet.

## v1.1
What's new?

- Added ahead / behind in the python output table.
- Added logs.
- Added / modified relevents text.

And that's about it!

## v1.0
Inital release.
