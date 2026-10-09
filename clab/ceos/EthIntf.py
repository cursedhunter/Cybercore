# Copyright (c) 2025 Arista Networks, Inc.  All rights reserved.
# Arista Networks, Inc. Confidential and Proprietary.
# Subject to Arista Networks, Inc.'s EULA.
# FOR INTERNAL USE ONLY. NOT FOR DISTRIBUTION.
from os import environ

from SysConstants.if_ether_h import ETH_FCS_LEN
from SysConstants.if_vlan_h import VLAN_ETH_HLEN

MAX_SUPPORTED_FRAME_SIZE = int(environ.get("MAX_SUPPORTED_FRAME_SIZE", 9236))
MAX_SUPPORTED_MTU = MAX_SUPPORTED_FRAME_SIZE - VLAN_ETH_HLEN - ETH_FCS_LEN
MAX_MGMT_MTU = 1500
