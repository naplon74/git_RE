#!/usr/bin/env python3

import json
from rich.console import Console
from rich.table import Table
from rich import box
from rich.text import Text

console = Console()

with open("../repos_status.json") as f:
    repos = json.load(f)

table = Table(
    title="Git Repo Extension",
    caption="Git Repo Extension v.1.1 - By naplon_\n Logs can be found in logs.txt",
    box=box.ROUNDED,
    show_header=True,
    header_style="bold cyan"
)

table.add_column("Repository", style="bold")
table.add_column("Branch", style="cyan")
table.add_column("Status", justify="center")
table.add_column("Ahead", justify="right")
table.add_column("Behind", justify="right")
table.add_column("Path", style="dim")

for repo in repos:
    # Status (dirty / clean)
    if repo["dirty"]:
        status = Text("● dirty", style="yellow")
    else:
        status = Text("✓ clean", style="green")

    # Ahead
    ahead = repo.get("ahead", 0)
    if ahead > 0:
        ahead_text = Text(f"↑ {ahead}", style="blue")
    else:
        ahead_text = Text("-", style="dim")

    # Behind
    behind = repo.get("behind", 0)
    if behind > 0:
        behind_text = Text(f"↓ {behind}", style="red")
    else:
        behind_text = Text("-", style="dim")

    table.add_row(
        repo["name"],
        repo["branch"],
        status,
        ahead_text,
        behind_text,
        repo["path"]
    )

console.print(table)