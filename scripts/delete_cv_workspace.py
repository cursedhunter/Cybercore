# Copyright (c) 2025 Arista Networks, Inc.  All rights reserved.
# Arista Networks, Inc. Confidential and Proprietary.
# Subject to Arista Networks, Inc.'s EULA.
# FOR INTERNAL USE ONLY. NOT FOR DISTRIBUTION.
import argparse
import asyncio
import logging

from pyavd._cv.client import CVClient  # type: ignore
from pyavd._cv.workflows.models import (  # type: ignore
    CloudVision,
)

logger = logging.getLogger()


async def main():
    parser = argparse.ArgumentParser(description="Delete a CV workspace by id.")
    parser.add_argument("id", help="The id of the CV workspace.")
    parser.add_argument("--cv-server", nargs="*", required=True, help="The CV servers.")
    parser.add_argument("--cv-token", required=True, help="The CV token.")
    parser.add_argument("--no-cv-verify-certs", default=False, action="store_true", help="Verify certs when connecting to CV.")

    args = parser.parse_args()

    logging.basicConfig(level=logging.INFO)
    logger.info("workspace id: %s", args.id)

    # Create CloudVision object
    cloudvision = CloudVision(
        servers=args.cv_server,
        token=args.cv_token,
        verify_certs=not args.no_cv_verify_certs,
    )

    async with CVClient(servers=cloudvision.servers, token=cloudvision.token, verify_certs=cloudvision.verify_certs) as cv_client:
        await cv_client.delete_workspace(workspace_id=args.id)
    logger.info("workspace id %s deleted", args.id)


if __name__ == "__main__":
    asyncio.run(main())
