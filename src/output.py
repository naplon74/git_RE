import json
from rich.console import Console
from rich.table import Table
from rich import box
from rich.text import Text

console = Console()

with open("../repos_status.json") as f:
    repos = json.load(f)

table = Table(
    title="Multi-Repo Git Status",
    box=box.ROUNDED,
    show_header=True,
    header_style="bold cyan"
)

table.add_column("Repository", style="bold")
table.add_column("Branch", style="cyan")
table.add_column("Status", justify="center")
table.add_column("Path", style="dim")

for repo in repos:
    if repo["dirty"]:
        status = Text("● dirty", style="yellow")
    else:
        status = Text("✓ clean", style="green")

    table.add_row(
        repo["name"],
        repo["branch"],
        status,
        repo["path"]
    )

console.print(table)