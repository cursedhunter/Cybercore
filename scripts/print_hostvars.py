import logging
from pathlib import Path
from typing import Annotated

import typer

from doppel_tools.ansible.inventory import Inventory

app = typer.Typer()
logger = logging.getLogger()


@app.command()
def main(
    inventory_path: Annotated[
        Path,
        typer.Option(
            "--inventory-path",
            "-i",
            exists=True,
            file_okay=True,
            dir_okay=False,
            writable=False,
            readable=True,
            resolve_path=True,
        ),
    ],
    host: Annotated[str, typer.Argument(help="host")],
):
    """Main function."""
    inventory = Inventory(inventory_path=inventory_path)

    print(inventory.get_vars(host))


if __name__ == "__main__":
    typer.run(main)
