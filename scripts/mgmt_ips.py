
from ipaddress import IPv4Network
from yaml import safe_dump
from copy import deepcopy

#
# Use this script to create per rack subnets with the associated tools_config.yml exec items
#

def main():
    tools_config=dict(stages=dict(configure=dict(exec=list())))
    exec_list=tools_config["stages"]["configure"]["exec"]
    exec_struct = dict(command="", target="host", phase="on-enter")
    output = dict(mgmt_ip_pool=dict())
    supernet = IPv4Network('100.64.0.0/10')
    subnets = [subnet for subnet in supernet.subnets(14)] # original /10 + 14 = /24
    subnet_index = -1
    for pod in range(1, 16 + 1):
        leaf = 0
        for rack in range(1, 19+1):
            spine = 0
            subnet_index +=1
            subnet = subnets[subnet_index]
            pl=subnet.prefixlen

            # subnet gateway
            gw=str([host for host in subnet.hosts()][-1])
            gw=f"{gw}/{pl}"
            exec_item = deepcopy(exec_struct)
            exec_item["command"] = f"ip addr add {gw} dev br-mgmt"
            exec_list.append(exec_item)

            # production leaves
            for host_idx in range(1, 2 + 1): # leaf1 and leaf2 per rack
                leaf += 1
                ha=subnet.network_address + host_idx
                hostname=f"p{pod:02d}l{leaf:02d}"
                host_addr=f"{ha}/{pl}"
                output["mgmt_ip_pool"][hostname] = host_addr

            # mgmt leaf
            for host_idx in range(3, 4): # leaf1 and leaf2 per rack
                ha = subnet.network_address + host_idx
                hostname = f"mp{pod:02d}l{rack:02d}"
                host_addr = f"{ha}/{pl}"
                output["mgmt_ip_pool"][hostname] = host_addr


            # spines1 & 2
            if rack == 8:
                for host_idx in range(4, 5 + 1):
                    spine += 1
                    ha = subnet.network_address + host_idx
                    hostname = f"p{pod:02d}s{spine:02d}"
                    host_addr = f"{ha}/{pl}"
                    output["mgmt_ip_pool"][hostname] = host_addr

                # mgmt spine1
                ha = subnet.network_address + host_idx + 1
                hostname = f"mp{pod:02d}s01"
                host_addr = f"{ha}/{pl}"
                output["mgmt_ip_pool"][hostname] = host_addr

            # spines3 & 4
            if rack == 9:
                spine += 2
                for host_idx in range(6, 7 + 1):
                    spine += 1
                    ha = subnet.network_address + host_idx
                    hostname = f"p{pod:02d}s{spine:02d}"
                    host_addr = f"{ha}/{pl}"
                    output["mgmt_ip_pool"][hostname] = host_addr

                # mgmt spine2
                ha = subnet.network_address + host_idx + 1
                hostname = f"mp{pod:02d}s02"
                host_addr = f"{ha}/{pl}"
                output["mgmt_ip_pool"][hostname] = host_addr

            # manually added the super spines and route servers

    # print(safe_dump(output))
    print(safe_dump(exec_list))

if __name__ == "__main__":
    main()
