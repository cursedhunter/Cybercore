# Copyright (c) 2025 Arista Networks, Inc.  All rights reserved.
# Arista Networks, Inc. Confidential and Proprietary.
# Subject to Arista Networks, Inc.'s EULA.
# FOR INTERNAL USE ONLY. NOT FOR DISTRIBUTION.
import argparse
import csv
from pathlib import Path

from yaml import safe_load


def main():
    parser = argparse.ArgumentParser(description="Generate etc hosts from host_mapping & clab_hosts.")
    parser.add_argument("--clab-hosts", required=True, type=Path, help="Path to the clab_hosts csv file.")
    parser.add_argument("--host-mapping", required=True, type=Path, help="Path to the host_mapping yaml file.")

    args = parser.parse_args()

    clab_hosts_path = args.clab_hosts
    host_mapping_path = args.host_mapping

    with open(clab_hosts_path, mode="r", encoding="utf8", newline="") as fd:
        reader = csv.DictReader(fd, fieldnames=("host", "ip"))
        clab_hosts = {row["host"]: row["ip"] for row in reader}

    with open(host_mapping_path, mode="r", encoding="utf8") as fd:
        host_to_node = safe_load(fd)

    for host, nodes in host_to_node.items():
        print(f"{clab_hosts[host]} {host} {' '.join(nodes)}")


if __name__ == "__main__":
    main()
