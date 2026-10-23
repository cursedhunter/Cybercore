# Copyright (c) 2025 Arista Networks, Inc.  All rights reserved.
# Arista Networks, Inc. Confidential and Proprietary.
# Subject to Arista Networks, Inc.'s EULA.
# FOR INTERNAL USE ONLY. NOT FOR DISTRIBUTION.
import argparse
import logging
import subprocess
from functools import partial
from socket import gethostname

logger = logging.getLogger()


# backport from python 3.12
def bisect_right(a, x, lo=0, hi=None, *, key=None):
    """Return the index where to insert item x in list a, assuming a is sorted.

    The return value i is such that all e in a[:i] have e <= x, and all e in
    a[i:] have e > x.  So if x already appears in the list, a.insert(i, x) will
    insert just after the rightmost x already there.

    Optional args lo (default 0) and hi (default len(a)) bound the
    slice of a to be searched.

    A custom key function can be supplied to customize the sort order.
    """

    if lo < 0:
        raise ValueError("lo must be non-negative")
    if hi is None:
        hi = len(a)
    # Note, the comparison uses "<" to match the
    # __lt__() logic in list.sort() and in heapq.
    if key is None:
        while lo < hi:
            mid = (lo + hi) // 2
            if x < a[mid]:
                hi = mid
            else:
                lo = mid + 1
    else:
        while lo < hi:
            mid = (lo + hi) // 2
            if x < key(a[mid]):
                hi = mid
            else:
                lo = mid + 1
    return lo


def ping(source_interface: str, host: str, mtu: int):
    icmp_overhead = 8 + 20
    mtu_encapsulated = mtu - icmp_overhead

    command = f"ping -I {source_interface} -c 1 -s {mtu_encapsulated} -W 1 -M do {host}"

    try:
        output = subprocess.check_output(command.split())
    except subprocess.CalledProcessError as e:
        logger.debug("%s -> %s", command, e.output)
        return e.returncode

    logger.debug("%s -> %s", command, output)

    return 0


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Discover max MTU between hosts.")
    parser.add_argument("--source-interface", type=str, help="The source interface for the ICMP requests.")
    parser.add_argument("--min-mtu", default=1500, type=int, help="The minimum MTU allowed on the host.")
    parser.add_argument("--max-mtu", type=int, help="The maximum MTU allowed on the host.")
    parser.add_argument("hosts", nargs="+", help="The hosts to discover.")
    parser.add_argument("-v", "--verbose", action="store_true", help="Enable verbose logging.")
    args = parser.parse_args()

    logging.basicConfig(level=logging.DEBUG if args.verbose else logging.INFO)

    hostname = gethostname()

    logger.info(f"Mtu discovery from {hostname}:{args.source_interface} to {args.hosts}")
    logger.info(f"Source interface: {args.source_interface}")
    logger.info(f"Minimum MTU allowed {args.min_mtu}")
    logger.info(f"Maximum MTU allowed {args.max_mtu}")

    mtu_range = range(args.min_mtu, args.max_mtu)

    def check_ping(source_interface: str, host: str, mtu: int):
        return -1 if ping(source_interface, host, mtu) == 0 else 1

    max_mtu_per_host: dict[str, int] = {}
    for host in args.hosts:
        logger.info(f"Discovering {host}")
        max_mtu_index = bisect_right(mtu_range, 0, key=partial(check_ping, args.source_interface, host))
        max_mtu_per_host[host] = mtu_range[max_mtu_index - 1]
        logger.info(f"Maximum MTU allowed between {hostname} to {host} is {max_mtu_per_host[host]}")

    logger.info("Stats:")
    for host, mtu in max_mtu_per_host.items():
        logger.info(f"{host}: {mtu}")
    max_mtu_between_all_hosts = min(max_mtu_per_host.values())

    print(max_mtu_between_all_hosts)
