import sys
import json

SLICE = 32

TOPOLOGY = "topology.json"
CONTROL_PLANE = "s1-runtime.json"
DATA_PLANE = "dxr+.p4"

def btod(n):
    return int(n,2)

# def btoip(n):
#     ip_addr = ""
#     index = 0
#     while index < 4:
#         if len(n) > 8:
#             ip_addr += str(btod(n[0:8])) + "."
#             n = n[8:]
#         elif len(n) > 0:
#             ip_addr += str(btod(n) * (2**(8 - len(n)))) + "."
#             n = ""
#         else:
#             ip_addr += str(0) + "."
#         index += 1
#     ip_addr = ip_addr.rstrip(ip_addr[-1])
#     return ip_addr

def gen_next_hop_table(database):
    dict = {}

    with open(database, "r") as file:
        for line in file:
            line = line.rstrip()
            elements = line.split(",")
            next_hop = elements[2]
            if next_hop in dict:
                continue
            dict[next_hop] = len(dict)

    return dict

# def gen_lookup_table(database):
#     dict = {}

#     with open(database, "r") as file:
#         for line in file:
#             line = line.rstrip()
#             elements = line.split(",")
#             prefix = elements[0]
#             length = int(elements[1])
#             next_hop = elements[2]

#             if length > 24:
#                 dict[prefix] = (length, next_hop)

#     return dict

# def gen_bitmap_table(database, next_hop_table):
#     dict = {}
#     for index in range(0, 25):
#         dict[index] = {}

#     with open(database, "r") as file:
#         for line in file:
#             line = line.rstrip()
#             elements = line.split(",")
#             prefix = elements[0]
#             length = int(elements[1])
#             next_hop = elements[2]

#             if length > 24:
#                 continue
#             dict[length][btod(prefix)] = (length, next_hop_table[next_hop])

#     for index in range(CUTOFF-1,-1,-1):
#         for prefix in dict[index]:
#             difference = CUTOFF - index
#             for entry in range(0, 2**difference):
#                 if (prefix*(2**difference)) + entry in dict[CUTOFF]:
#                     continue
#                 else:
#                     dict[CUTOFF][(prefix*(2**difference)) + entry] = (CUTOFF, dict[index][prefix][1])

#     bitmaps = {}
#     for index in range(CUTOFF, 25):
#         bitmaps[index] = {}

#     for index in range(CUTOFF, 25):
#         bitstring = ""
#         for value in range(0, 2**index):
#             if value in dict[index]:
#                 bitstring += "1"
#             else:
#                 bitstring += "0"
#         key_count = int(2**index / 2048)
#         for key_index in range(0, key_count):
#             bitmaps[index][key_index] = btod(bitstring[2048*key_index:2048+(2048*key_index)][::-1])

#     return dict, bitmaps

# def gen_hash_table(bitmap_table):
#     dict = {}

#     for index in range(CUTOFF, 25):
#         for prefix in bitmap_table[index]:
#             difference = 25 - index
#             hash_key = (prefix * (2 ** difference)) + (2 ** (difference-1))
#             dict[hash_key] = bitmap_table[index][prefix][1]
#     return dict

def gen_topology(next_hop_table):
    dict = {}

    dict["hosts"] = { "h1": { "ip": "2001:1:1::a/64", "mac": "08:00:00:00:01:11", "commands": ["ip -4 addr flush dev eth0",
                                                                                               "ip -6 addr flush dev eth0",
                                                                                               "ip -6 addr add 2001:1:1::a/64 dev eth0",
                                                                                               "ip -6 route add default via 2001:1:1::ff"] } }
    dict["switches"] = { "s1": { "runtime_json": "sim-topo/" + CONTROL_PLANE } }
    dict["links"] = [ ["h1", "s1-p1"] ]

    id = 2
    for next_hop in next_hop_table:
        if id == 10:
            print("ERROR: too many hosts requested")
            exit(1)
        fields = next_hop.split(":")
        remainder = int(fields[7], base=16) % 2
        if remainder == 0:
            fields[7] = hex(int(fields[7], base=16) + 1)[2:]
        else:
            fields[7] = hex(int(fields[7], base=16) - 1)[2:]
        gateway_ip = ':'.join(fields)
        dict["hosts"][f"h{id}"] = { "ip": f"{next_hop}/64", "mac": f"08:00:00:00:0{id}:{id}{id}", "commands": ["ip -4 addr flush dev eth0",
                                                                                                               "ip -6 addr flush dev eth0",
                                                                                                               f"ip -6 addr add {next_hop}/64 dev eth0",
                                                                                                               f"ip -6 route add default via {gateway_ip}"] }
        dict["links"].append([f"s1-p{id}", f"h{id}"])
        id += 1

    with open(TOPOLOGY, "w") as file:
        json.dump(dict, file, indent=4)

def gen_control_plane(next_hop_table, lookup_table, bitmap_table, bitmaps, hash_table):
    dict = {}

    dict["target"] = "bmv2"
    dict["p4info"] = f"build/{DATA_PLANE}.p4info.txt"
    dict["bmv2_json"] = "build/dxr+.json"
    dict["table_entries"] = []

    dict["table_entries"].append({ "table": "MyIngress.next_hop_table",
                                            "default_action": True,
                                            "action_name": "MyIngress.drop",
                                            "action_params": { } })

    id = 2
    for next_hop in next_hop_table:
        dict["table_entries"].append({ "table": "MyIngress.next_hop_table",
                                                "match": { "meta.next_hop_index": next_hop_table[next_hop] },
                                                "action_name": "MyIngress.ipv6_forward",
                                                "action_params": { "dstAddr": f"08:00:00:00:0{id}:{id}{id}", "port": id } })
        id += 1

#     for prefix in lookup_table:
#         dict["table_entries"].append({ "table": "MyIngress.lookup_table",
#                                                 "match": { "hdr.ipv4.dstAddr": [ btoip(prefix), lookup_table[prefix][0] ] },
#                                                 "action_name": "MyIngress.set_next_hop_index",
#                                                 "action_params": { "nhi": next_hop_table[lookup_table[prefix][1]] } })

#     for index in range(CUTOFF, 25):
#         for key in bitmaps[index]:
#             dict["table_entries"].append({ "table": f"MyIngress.bitmap_{index}_table",
#                                                     "match": { "meta.bitmap_index": key },
#                                                     "action_name": "MyIngress.get_bitstring",
#                                                     "action_params": { "bitstring": bitmaps[index][key] } })
    
#     for prefix in hash_table:
#         dict["table_entries"].append({ "table": "MyIngress.hash_table",
#                                                 "match": { "meta.hash_key": prefix },
#                                                 "action_name": "MyIngress.set_next_hop_index",
#                                                 "action_params": { "nhi": hash_table[prefix] } })
    
    with open(CONTROL_PLANE, "w") as file:
        json.dump(dict, file, indent=4)

def main(argv):
    if len(argv) != 1:
        print("ERROR: missing argument")
        exit(1)

    database = argv[0]

    next_hop_table = gen_next_hop_table(database)
    lookup_table, bitmap_table, bitmaps, hash_table = 5, 5, 5, 5
    # lookup_table = gen_lookup_table(database)
    # bitmap_table, bitmaps = gen_bitmap_table(database, next_hop_table)
    # hash_table = gen_hash_table(bitmap_table)

    gen_topology(next_hop_table)
    gen_control_plane(next_hop_table, lookup_table, bitmap_table, bitmaps, hash_table)

if __name__ == "__main__":
    main(sys.argv[1:])