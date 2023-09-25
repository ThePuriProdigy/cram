/*
Copyright 2021 Intel Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#include <core.p4>
// The following line is not needed when using Intel Tofino P4
// compiler.  It is only here to be able to use open source p4test
// with tna.p4 include file in Open-Tofino repository for syntax
// checking.
//#define __TARGET_TOFINO__ 1

#ifdef TOFINO1
#include <tna.p4>
#endif

#ifdef TOFINO2
#include <t2na.p4>
#endif

#include <stdheaders.p4>

#define NEXT_HOP_SIZE 8

typedef bit<NEXT_HOP_SIZE> next_hop_index_t;
typedef bit<32> bitstring_t;
typedef bit<1> bitmap_hit_t;
typedef bit<25> hash_key_t;
typedef bit<25> hash_mask_t;

header bridge_metadata_t {
    // user-defined metadata carried over from ingress to egress.
}

struct ingress_headers_t {
    bridge_metadata_t bridge_md;
    ethernet_h ethernet;
    ipv4_h ipv4;
}

struct egress_headers_t {
    bridge_metadata_t bridge_md;
}

struct ingress_metadata_t {
    // user-defined ingress metadata
    next_hop_index_t next_hop_index;
    bitstring_t bitstring_24;
    bitstring_t bitstring_23;
    bitstring_t bitstring_22;
    bitstring_t bitstring_21;
    bitstring_t bitstring_20;
    bitstring_t bitstring_19;
    bitstring_t bitstring_18;
    bitstring_t bitstring_17;
    bitstring_t bitstring_16;
    bitstring_t bitstring_15;
    bitstring_t bitstring_14;
    bitstring_t bitstring_13;
    bitmap_hit_t bitmap_24_hit;
    bitmap_hit_t bitmap_23_hit;
    bitmap_hit_t bitmap_22_hit;
    bitmap_hit_t bitmap_21_hit;
    bitmap_hit_t bitmap_20_hit;
    bitmap_hit_t bitmap_19_hit;
    bitmap_hit_t bitmap_18_hit;
    bitmap_hit_t bitmap_17_hit;
    bitmap_hit_t bitmap_16_hit;
    bitmap_hit_t bitmap_15_hit;
    bitmap_hit_t bitmap_14_hit;
    bitmap_hit_t bitmap_13_hit;
    hash_key_t hash_key;
    hash_mask_t hash_mask;
}

struct egress_metadata_t {
    // user-defined egress metadata
}

parser ingressParserImpl(
    packet_in pkt,
    out ingress_headers_t  hdr,
    out ingress_metadata_t umd,
    out ingress_intrinsic_metadata_t ig_intr_md)
{
    state start {
        pkt.extract(ig_intr_md);
        transition parse_port_metadata;
    }
    state parse_port_metadata {
        pkt.advance(PORT_METADATA_SIZE);
        transition parse_ethernet;
    }
    state parse_ethernet {
        pkt.extract(hdr.ethernet);
        transition parse_ipv4;
    }
    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
        transition accept;
    }
}

control ingressImpl(
    inout ingress_headers_t  hdr,
    inout ingress_metadata_t umd,
    in    ingress_intrinsic_metadata_t              ig_intr_md,
    in    ingress_intrinsic_metadata_from_parser_t  ig_prsr_md,
    inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
    inout ingress_intrinsic_metadata_for_tm_t       ig_tm_md)
{
    action unicast_to_port(PortId_t p) {
        ig_tm_md.ucast_egress_port = p;
    }
    action drop_packet() {
        ig_dprsr_md.drop_ctl = 1;
        return;
    }
    action set_next_hop_index(next_hop_index_t nhi) {
        umd.next_hop_index = nhi;
    }
    action apply_bitmask_24(bitstring_t mask) {
        umd.bitstring_24 = umd.bitstring_24 & mask;
    }
    action apply_bitmask_23(bitstring_t mask) {
        umd.bitstring_23 = umd.bitstring_23 & mask;
    }
    action apply_bitmask_22(bitstring_t mask) {
        umd.bitstring_22 = umd.bitstring_22 & mask;
    }
    action apply_bitmask_21(bitstring_t mask) {
        umd.bitstring_21 = umd.bitstring_21 & mask;
    }
    action apply_bitmask_20(bitstring_t mask) {
        umd.bitstring_20 = umd.bitstring_20 & mask;
    }
    action apply_bitmask_19(bitstring_t mask) {
        umd.bitstring_19 = umd.bitstring_19 & mask;
    }
    action apply_bitmask_18(bitstring_t mask) {
        umd.bitstring_18 = umd.bitstring_18 & mask;
    }
    action apply_bitmask_17(bitstring_t mask) {
        umd.bitstring_17 = umd.bitstring_17 & mask;
    }
    action apply_bitmask_16(bitstring_t mask) {
        umd.bitstring_16 = umd.bitstring_16 & mask;
    }
    action apply_bitmask_15(bitstring_t mask) {
        umd.bitstring_15 = umd.bitstring_15 & mask;
    }
    action apply_bitmask_14(bitstring_t mask) {
        umd.bitstring_14 = umd.bitstring_14 & mask;
    }
    action apply_bitmask_13(bitstring_t mask) {
        umd.bitstring_13 = umd.bitstring_13 & mask;
    }
    action get_bitstring_24(bitstring_t bitstring) {
        umd.bitstring_24 = bitstring;
    }
    action get_bitstring_23(bitstring_t bitstring) {
        umd.bitstring_23 = bitstring;
    }
    action get_bitstring_22(bitstring_t bitstring) {
        umd.bitstring_22 = bitstring;
    }
    action get_bitstring_21(bitstring_t bitstring) {
        umd.bitstring_21 = bitstring;
    }
    action get_bitstring_20(bitstring_t bitstring) {
        umd.bitstring_20 = bitstring;
    }
    action get_bitstring_19(bitstring_t bitstring) {
        umd.bitstring_19 = bitstring;
    }
    action get_bitstring_18(bitstring_t bitstring) {
        umd.bitstring_18 = bitstring;
    }
    action get_bitstring_17(bitstring_t bitstring) {
        umd.bitstring_17 = bitstring;
    }
    action get_bitstring_16(bitstring_t bitstring) {
        umd.bitstring_16 = bitstring;
    }
    action get_bitstring_15(bitstring_t bitstring) {
        umd.bitstring_15 = bitstring;
    }
    action get_bitstring_14(bitstring_t bitstring) {
        umd.bitstring_14 = bitstring;
    }
    action get_bitstring_13(bitstring_t bitstring) {
        umd.bitstring_13 = bitstring;
    }
    action get_hash_key_24() {
        umd.hash_key = (hdr.ipv4.dst_addr[31:7] & 0x1fffffe);
        umd.hash_mask = 1 << 0;
    }
    action get_hash_key_23() {
        umd.hash_key = (hdr.ipv4.dst_addr[31:7] & 0x1fffffc);
        umd.hash_mask = 1 << 1;
    }
    action get_hash_key_22() {
        umd.hash_key = (hdr.ipv4.dst_addr[31:7] & 0x1fffff8);
        umd.hash_mask = 1 << 2;
    }
    action get_hash_key_21() {
        umd.hash_key = (hdr.ipv4.dst_addr[31:7] & 0x1fffff0);
        umd.hash_mask = 1 << 3;
    }
    action get_hash_key_20() {
        umd.hash_key = (hdr.ipv4.dst_addr[31:7] & 0x1ffffe0);
        umd.hash_mask = 1 << 4;
    }
    action get_hash_key_19() {
        umd.hash_key = (hdr.ipv4.dst_addr[31:7] & 0x1ffffc0);
        umd.hash_mask = 1 << 5;
    }
    action get_hash_key_18() {
        umd.hash_key = (hdr.ipv4.dst_addr[31:7] & 0x1ffff80);
        umd.hash_mask = 1 << 6;
    }
    action get_hash_key_17() {
        umd.hash_key = (hdr.ipv4.dst_addr[31:7] & 0x1ffff00);
        umd.hash_mask = 1 << 7;
    }
    action get_hash_key_16() {
        umd.hash_key = (hdr.ipv4.dst_addr[31:7] & 0x1fffe00);
        umd.hash_mask = 1 << 8;
    }
    action get_hash_key_15() {
        umd.hash_key = (hdr.ipv4.dst_addr[31:7] & 0x1fffc00);
        umd.hash_mask = 1 << 9;
    }
    action get_hash_key_14() {
        umd.hash_key = (hdr.ipv4.dst_addr[31:7] & 0x1fff800);
        umd.hash_mask = 1 << 10;
    }
    action get_hash_key_13() {
        umd.hash_key = (hdr.ipv4.dst_addr[31:7] & 0x1fff000);
        umd.hash_mask = 1 << 11;
    }
    action apply_hash_mask() {
        umd.hash_key = umd.hash_key | umd.hash_mask;
    }
    table initial_lookup_table {
        key = {
            hdr.ipv4.dst_addr : lpm;
        }
        actions = {
            set_next_hop_index;
        }
	    size = INITIAL_LOOKUP_TABLE_SIZE;
    }
    table bitmask_table_24 {
        key = {
            hdr.ipv4.dst_addr[12:8]: ternary;
        }
        actions = {
            apply_bitmask_24;
        }
        const entries = {
            0  &&& 0x1f : apply_bitmask_24(1 << 0);
            1  &&& 0x1f : apply_bitmask_24(1 << 1);
            2  &&& 0x1f : apply_bitmask_24(1 << 2);
            3  &&& 0x1f : apply_bitmask_24(1 << 3);
            4  &&& 0x1f : apply_bitmask_24(1 << 4);
            5  &&& 0x1f : apply_bitmask_24(1 << 5);
            6  &&& 0x1f : apply_bitmask_24(1 << 6);
            7  &&& 0x1f : apply_bitmask_24(1 << 7);
            8  &&& 0x1f : apply_bitmask_24(1 << 8);
            9  &&& 0x1f : apply_bitmask_24(1 << 9);
            10 &&& 0x1f : apply_bitmask_24(1 << 10);
            11 &&& 0x1f : apply_bitmask_24(1 << 11);
            12 &&& 0x1f : apply_bitmask_24(1 << 12);
            13 &&& 0x1f : apply_bitmask_24(1 << 13);
            14 &&& 0x1f : apply_bitmask_24(1 << 14);
            15 &&& 0x1f : apply_bitmask_24(1 << 15);
            16 &&& 0x1f : apply_bitmask_24(1 << 16);
            17 &&& 0x1f : apply_bitmask_24(1 << 17);
            18 &&& 0x1f : apply_bitmask_24(1 << 18);
            19 &&& 0x1f : apply_bitmask_24(1 << 19);
            20 &&& 0x1f : apply_bitmask_24(1 << 20);
            21 &&& 0x1f : apply_bitmask_24(1 << 21);
            22 &&& 0x1f : apply_bitmask_24(1 << 22);
            23 &&& 0x1f : apply_bitmask_24(1 << 23);
            24 &&& 0x1f : apply_bitmask_24(1 << 24);
            25 &&& 0x1f : apply_bitmask_24(1 << 25);
            26 &&& 0x1f : apply_bitmask_24(1 << 26);
            27 &&& 0x1f : apply_bitmask_24(1 << 27);
            28 &&& 0x1f : apply_bitmask_24(1 << 28);
            29 &&& 0x1f : apply_bitmask_24(1 << 29);
            30 &&& 0x1f : apply_bitmask_24(1 << 30);
            31 &&& 0x1f : apply_bitmask_24(1 << 31);
        }
        size = 32;
    }
    table bitmask_table_23 {
        key = {
            hdr.ipv4.dst_addr[13:9]: ternary;
        }
        actions = {
            apply_bitmask_23;
        }
        const entries = {
            0  &&& 0x1f : apply_bitmask_23(1 << 0);
            1  &&& 0x1f : apply_bitmask_23(1 << 1);
            2  &&& 0x1f : apply_bitmask_23(1 << 2);
            3  &&& 0x1f : apply_bitmask_23(1 << 3);
            4  &&& 0x1f : apply_bitmask_23(1 << 4);
            5  &&& 0x1f : apply_bitmask_23(1 << 5);
            6  &&& 0x1f : apply_bitmask_23(1 << 6);
            7  &&& 0x1f : apply_bitmask_23(1 << 7);
            8  &&& 0x1f : apply_bitmask_23(1 << 8);
            9  &&& 0x1f : apply_bitmask_23(1 << 9);
            10 &&& 0x1f : apply_bitmask_23(1 << 10);
            11 &&& 0x1f : apply_bitmask_23(1 << 11);
            12 &&& 0x1f : apply_bitmask_23(1 << 12);
            13 &&& 0x1f : apply_bitmask_23(1 << 13);
            14 &&& 0x1f : apply_bitmask_23(1 << 14);
            15 &&& 0x1f : apply_bitmask_23(1 << 15);
            16 &&& 0x1f : apply_bitmask_23(1 << 16);
            17 &&& 0x1f : apply_bitmask_23(1 << 17);
            18 &&& 0x1f : apply_bitmask_23(1 << 18);
            19 &&& 0x1f : apply_bitmask_23(1 << 19);
            20 &&& 0x1f : apply_bitmask_23(1 << 20);
            21 &&& 0x1f : apply_bitmask_23(1 << 21);
            22 &&& 0x1f : apply_bitmask_23(1 << 22);
            23 &&& 0x1f : apply_bitmask_23(1 << 23);
            24 &&& 0x1f : apply_bitmask_23(1 << 24);
            25 &&& 0x1f : apply_bitmask_23(1 << 25);
            26 &&& 0x1f : apply_bitmask_23(1 << 26);
            27 &&& 0x1f : apply_bitmask_23(1 << 27);
            28 &&& 0x1f : apply_bitmask_23(1 << 28);
            29 &&& 0x1f : apply_bitmask_23(1 << 29);
            30 &&& 0x1f : apply_bitmask_23(1 << 30);
            31 &&& 0x1f : apply_bitmask_23(1 << 31);
        }
        size = 32;
    }
    table bitmask_table_22 {
        key = {
            hdr.ipv4.dst_addr[14:10]: ternary;
        }
        actions = {
            apply_bitmask_22;
        }
        const entries = {
            0  &&& 0x1f : apply_bitmask_22(1 << 0);
            1  &&& 0x1f : apply_bitmask_22(1 << 1);
            2  &&& 0x1f : apply_bitmask_22(1 << 2);
            3  &&& 0x1f : apply_bitmask_22(1 << 3);
            4  &&& 0x1f : apply_bitmask_22(1 << 4);
            5  &&& 0x1f : apply_bitmask_22(1 << 5);
            6  &&& 0x1f : apply_bitmask_22(1 << 6);
            7  &&& 0x1f : apply_bitmask_22(1 << 7);
            8  &&& 0x1f : apply_bitmask_22(1 << 8);
            9  &&& 0x1f : apply_bitmask_22(1 << 9);
            10 &&& 0x1f : apply_bitmask_22(1 << 10);
            11 &&& 0x1f : apply_bitmask_22(1 << 11);
            12 &&& 0x1f : apply_bitmask_22(1 << 12);
            13 &&& 0x1f : apply_bitmask_22(1 << 13);
            14 &&& 0x1f : apply_bitmask_22(1 << 14);
            15 &&& 0x1f : apply_bitmask_22(1 << 15);
            16 &&& 0x1f : apply_bitmask_22(1 << 16);
            17 &&& 0x1f : apply_bitmask_22(1 << 17);
            18 &&& 0x1f : apply_bitmask_22(1 << 18);
            19 &&& 0x1f : apply_bitmask_22(1 << 19);
            20 &&& 0x1f : apply_bitmask_22(1 << 20);
            21 &&& 0x1f : apply_bitmask_22(1 << 21);
            22 &&& 0x1f : apply_bitmask_22(1 << 22);
            23 &&& 0x1f : apply_bitmask_22(1 << 23);
            24 &&& 0x1f : apply_bitmask_22(1 << 24);
            25 &&& 0x1f : apply_bitmask_22(1 << 25);
            26 &&& 0x1f : apply_bitmask_22(1 << 26);
            27 &&& 0x1f : apply_bitmask_22(1 << 27);
            28 &&& 0x1f : apply_bitmask_22(1 << 28);
            29 &&& 0x1f : apply_bitmask_22(1 << 29);
            30 &&& 0x1f : apply_bitmask_22(1 << 30);
            31 &&& 0x1f : apply_bitmask_22(1 << 31);
        }
        size = 32;
    }
    table bitmask_table_21 {
        key = {
            hdr.ipv4.dst_addr[15:11]: ternary;
        }
        actions = {
            apply_bitmask_21;
        }
        const entries = {
            0  &&& 0x1f : apply_bitmask_21(1 << 0);
            1  &&& 0x1f : apply_bitmask_21(1 << 1);
            2  &&& 0x1f : apply_bitmask_21(1 << 2);
            3  &&& 0x1f : apply_bitmask_21(1 << 3);
            4  &&& 0x1f : apply_bitmask_21(1 << 4);
            5  &&& 0x1f : apply_bitmask_21(1 << 5);
            6  &&& 0x1f : apply_bitmask_21(1 << 6);
            7  &&& 0x1f : apply_bitmask_21(1 << 7);
            8  &&& 0x1f : apply_bitmask_21(1 << 8);
            9  &&& 0x1f : apply_bitmask_21(1 << 9);
            10 &&& 0x1f : apply_bitmask_21(1 << 10);
            11 &&& 0x1f : apply_bitmask_21(1 << 11);
            12 &&& 0x1f : apply_bitmask_21(1 << 12);
            13 &&& 0x1f : apply_bitmask_21(1 << 13);
            14 &&& 0x1f : apply_bitmask_21(1 << 14);
            15 &&& 0x1f : apply_bitmask_21(1 << 15);
            16 &&& 0x1f : apply_bitmask_21(1 << 16);
            17 &&& 0x1f : apply_bitmask_21(1 << 17);
            18 &&& 0x1f : apply_bitmask_21(1 << 18);
            19 &&& 0x1f : apply_bitmask_21(1 << 19);
            20 &&& 0x1f : apply_bitmask_21(1 << 20);
            21 &&& 0x1f : apply_bitmask_21(1 << 21);
            22 &&& 0x1f : apply_bitmask_21(1 << 22);
            23 &&& 0x1f : apply_bitmask_21(1 << 23);
            24 &&& 0x1f : apply_bitmask_21(1 << 24);
            25 &&& 0x1f : apply_bitmask_21(1 << 25);
            26 &&& 0x1f : apply_bitmask_21(1 << 26);
            27 &&& 0x1f : apply_bitmask_21(1 << 27);
            28 &&& 0x1f : apply_bitmask_21(1 << 28);
            29 &&& 0x1f : apply_bitmask_21(1 << 29);
            30 &&& 0x1f : apply_bitmask_21(1 << 30);
            31 &&& 0x1f : apply_bitmask_21(1 << 31);
        }
        size = 32;
    }
    table bitmask_table_20 {
        key = {
            hdr.ipv4.dst_addr[16:12]: ternary;
        }
        actions = {
            apply_bitmask_20;
        }
        const entries = {
            0  &&& 0x1f : apply_bitmask_20(1 << 0);
            1  &&& 0x1f : apply_bitmask_20(1 << 1);
            2  &&& 0x1f : apply_bitmask_20(1 << 2);
            3  &&& 0x1f : apply_bitmask_20(1 << 3);
            4  &&& 0x1f : apply_bitmask_20(1 << 4);
            5  &&& 0x1f : apply_bitmask_20(1 << 5);
            6  &&& 0x1f : apply_bitmask_20(1 << 6);
            7  &&& 0x1f : apply_bitmask_20(1 << 7);
            8  &&& 0x1f : apply_bitmask_20(1 << 8);
            9  &&& 0x1f : apply_bitmask_20(1 << 9);
            10 &&& 0x1f : apply_bitmask_20(1 << 10);
            11 &&& 0x1f : apply_bitmask_20(1 << 11);
            12 &&& 0x1f : apply_bitmask_20(1 << 12);
            13 &&& 0x1f : apply_bitmask_20(1 << 13);
            14 &&& 0x1f : apply_bitmask_20(1 << 14);
            15 &&& 0x1f : apply_bitmask_20(1 << 15);
            16 &&& 0x1f : apply_bitmask_20(1 << 16);
            17 &&& 0x1f : apply_bitmask_20(1 << 17);
            18 &&& 0x1f : apply_bitmask_20(1 << 18);
            19 &&& 0x1f : apply_bitmask_20(1 << 19);
            20 &&& 0x1f : apply_bitmask_20(1 << 20);
            21 &&& 0x1f : apply_bitmask_20(1 << 21);
            22 &&& 0x1f : apply_bitmask_20(1 << 22);
            23 &&& 0x1f : apply_bitmask_20(1 << 23);
            24 &&& 0x1f : apply_bitmask_20(1 << 24);
            25 &&& 0x1f : apply_bitmask_20(1 << 25);
            26 &&& 0x1f : apply_bitmask_20(1 << 26);
            27 &&& 0x1f : apply_bitmask_20(1 << 27);
            28 &&& 0x1f : apply_bitmask_20(1 << 28);
            29 &&& 0x1f : apply_bitmask_20(1 << 29);
            30 &&& 0x1f : apply_bitmask_20(1 << 30);
            31 &&& 0x1f : apply_bitmask_20(1 << 31);
        }
        size = 32;
    }
    table bitmask_table_19 {
        key = {
            hdr.ipv4.dst_addr[17:13]: ternary;
        }
        actions = {
            apply_bitmask_19;
        }
        const entries = {
            0  &&& 0x1f : apply_bitmask_19(1 << 0);
            1  &&& 0x1f : apply_bitmask_19(1 << 1);
            2  &&& 0x1f : apply_bitmask_19(1 << 2);
            3  &&& 0x1f : apply_bitmask_19(1 << 3);
            4  &&& 0x1f : apply_bitmask_19(1 << 4);
            5  &&& 0x1f : apply_bitmask_19(1 << 5);
            6  &&& 0x1f : apply_bitmask_19(1 << 6);
            7  &&& 0x1f : apply_bitmask_19(1 << 7);
            8  &&& 0x1f : apply_bitmask_19(1 << 8);
            9  &&& 0x1f : apply_bitmask_19(1 << 9);
            10 &&& 0x1f : apply_bitmask_19(1 << 10);
            11 &&& 0x1f : apply_bitmask_19(1 << 11);
            12 &&& 0x1f : apply_bitmask_19(1 << 12);
            13 &&& 0x1f : apply_bitmask_19(1 << 13);
            14 &&& 0x1f : apply_bitmask_19(1 << 14);
            15 &&& 0x1f : apply_bitmask_19(1 << 15);
            16 &&& 0x1f : apply_bitmask_19(1 << 16);
            17 &&& 0x1f : apply_bitmask_19(1 << 17);
            18 &&& 0x1f : apply_bitmask_19(1 << 18);
            19 &&& 0x1f : apply_bitmask_19(1 << 19);
            20 &&& 0x1f : apply_bitmask_19(1 << 20);
            21 &&& 0x1f : apply_bitmask_19(1 << 21);
            22 &&& 0x1f : apply_bitmask_19(1 << 22);
            23 &&& 0x1f : apply_bitmask_19(1 << 23);
            24 &&& 0x1f : apply_bitmask_19(1 << 24);
            25 &&& 0x1f : apply_bitmask_19(1 << 25);
            26 &&& 0x1f : apply_bitmask_19(1 << 26);
            27 &&& 0x1f : apply_bitmask_19(1 << 27);
            28 &&& 0x1f : apply_bitmask_19(1 << 28);
            29 &&& 0x1f : apply_bitmask_19(1 << 29);
            30 &&& 0x1f : apply_bitmask_19(1 << 30);
            31 &&& 0x1f : apply_bitmask_19(1 << 31);
        }
        size = 32;
    }
    table bitmask_table_18 {
        key = {
            hdr.ipv4.dst_addr[18:14]: ternary;
        }
        actions = {
            apply_bitmask_18;
        }
        const entries = {
            0  &&& 0x1f : apply_bitmask_18(1 << 0);
            1  &&& 0x1f : apply_bitmask_18(1 << 1);
            2  &&& 0x1f : apply_bitmask_18(1 << 2);
            3  &&& 0x1f : apply_bitmask_18(1 << 3);
            4  &&& 0x1f : apply_bitmask_18(1 << 4);
            5  &&& 0x1f : apply_bitmask_18(1 << 5);
            6  &&& 0x1f : apply_bitmask_18(1 << 6);
            7  &&& 0x1f : apply_bitmask_18(1 << 7);
            8  &&& 0x1f : apply_bitmask_18(1 << 8);
            9  &&& 0x1f : apply_bitmask_18(1 << 9);
            10 &&& 0x1f : apply_bitmask_18(1 << 10);
            11 &&& 0x1f : apply_bitmask_18(1 << 11);
            12 &&& 0x1f : apply_bitmask_18(1 << 12);
            13 &&& 0x1f : apply_bitmask_18(1 << 13);
            14 &&& 0x1f : apply_bitmask_18(1 << 14);
            15 &&& 0x1f : apply_bitmask_18(1 << 15);
            16 &&& 0x1f : apply_bitmask_18(1 << 16);
            17 &&& 0x1f : apply_bitmask_18(1 << 17);
            18 &&& 0x1f : apply_bitmask_18(1 << 18);
            19 &&& 0x1f : apply_bitmask_18(1 << 19);
            20 &&& 0x1f : apply_bitmask_18(1 << 20);
            21 &&& 0x1f : apply_bitmask_18(1 << 21);
            22 &&& 0x1f : apply_bitmask_18(1 << 22);
            23 &&& 0x1f : apply_bitmask_18(1 << 23);
            24 &&& 0x1f : apply_bitmask_18(1 << 24);
            25 &&& 0x1f : apply_bitmask_18(1 << 25);
            26 &&& 0x1f : apply_bitmask_18(1 << 26);
            27 &&& 0x1f : apply_bitmask_18(1 << 27);
            28 &&& 0x1f : apply_bitmask_18(1 << 28);
            29 &&& 0x1f : apply_bitmask_18(1 << 29);
            30 &&& 0x1f : apply_bitmask_18(1 << 30);
            31 &&& 0x1f : apply_bitmask_18(1 << 31);
        }
        size = 32;
    }
    table bitmask_table_17 {
        key = {
            hdr.ipv4.dst_addr[19:15]: ternary;
        }
        actions = {
            apply_bitmask_17;
        }
        const entries = {
            0  &&& 0x1f : apply_bitmask_17(1 << 0);
            1  &&& 0x1f : apply_bitmask_17(1 << 1);
            2  &&& 0x1f : apply_bitmask_17(1 << 2);
            3  &&& 0x1f : apply_bitmask_17(1 << 3);
            4  &&& 0x1f : apply_bitmask_17(1 << 4);
            5  &&& 0x1f : apply_bitmask_17(1 << 5);
            6  &&& 0x1f : apply_bitmask_17(1 << 6);
            7  &&& 0x1f : apply_bitmask_17(1 << 7);
            8  &&& 0x1f : apply_bitmask_17(1 << 8);
            9  &&& 0x1f : apply_bitmask_17(1 << 9);
            10 &&& 0x1f : apply_bitmask_17(1 << 10);
            11 &&& 0x1f : apply_bitmask_17(1 << 11);
            12 &&& 0x1f : apply_bitmask_17(1 << 12);
            13 &&& 0x1f : apply_bitmask_17(1 << 13);
            14 &&& 0x1f : apply_bitmask_17(1 << 14);
            15 &&& 0x1f : apply_bitmask_17(1 << 15);
            16 &&& 0x1f : apply_bitmask_17(1 << 16);
            17 &&& 0x1f : apply_bitmask_17(1 << 17);
            18 &&& 0x1f : apply_bitmask_17(1 << 18);
            19 &&& 0x1f : apply_bitmask_17(1 << 19);
            20 &&& 0x1f : apply_bitmask_17(1 << 20);
            21 &&& 0x1f : apply_bitmask_17(1 << 21);
            22 &&& 0x1f : apply_bitmask_17(1 << 22);
            23 &&& 0x1f : apply_bitmask_17(1 << 23);
            24 &&& 0x1f : apply_bitmask_17(1 << 24);
            25 &&& 0x1f : apply_bitmask_17(1 << 25);
            26 &&& 0x1f : apply_bitmask_17(1 << 26);
            27 &&& 0x1f : apply_bitmask_17(1 << 27);
            28 &&& 0x1f : apply_bitmask_17(1 << 28);
            29 &&& 0x1f : apply_bitmask_17(1 << 29);
            30 &&& 0x1f : apply_bitmask_17(1 << 30);
            31 &&& 0x1f : apply_bitmask_17(1 << 31);
        }
        size = 32;
    }
    table bitmask_table_16 {
        key = {
            hdr.ipv4.dst_addr[20:16]: ternary;
        }
        actions = {
            apply_bitmask_16;
        }
        const entries = {
            0  &&& 0x1f : apply_bitmask_16(1 << 0);
            1  &&& 0x1f : apply_bitmask_16(1 << 1);
            2  &&& 0x1f : apply_bitmask_16(1 << 2);
            3  &&& 0x1f : apply_bitmask_16(1 << 3);
            4  &&& 0x1f : apply_bitmask_16(1 << 4);
            5  &&& 0x1f : apply_bitmask_16(1 << 5);
            6  &&& 0x1f : apply_bitmask_16(1 << 6);
            7  &&& 0x1f : apply_bitmask_16(1 << 7);
            8  &&& 0x1f : apply_bitmask_16(1 << 8);
            9  &&& 0x1f : apply_bitmask_16(1 << 9);
            10 &&& 0x1f : apply_bitmask_16(1 << 10);
            11 &&& 0x1f : apply_bitmask_16(1 << 11);
            12 &&& 0x1f : apply_bitmask_16(1 << 12);
            13 &&& 0x1f : apply_bitmask_16(1 << 13);
            14 &&& 0x1f : apply_bitmask_16(1 << 14);
            15 &&& 0x1f : apply_bitmask_16(1 << 15);
            16 &&& 0x1f : apply_bitmask_16(1 << 16);
            17 &&& 0x1f : apply_bitmask_16(1 << 17);
            18 &&& 0x1f : apply_bitmask_16(1 << 18);
            19 &&& 0x1f : apply_bitmask_16(1 << 19);
            20 &&& 0x1f : apply_bitmask_16(1 << 20);
            21 &&& 0x1f : apply_bitmask_16(1 << 21);
            22 &&& 0x1f : apply_bitmask_16(1 << 22);
            23 &&& 0x1f : apply_bitmask_16(1 << 23);
            24 &&& 0x1f : apply_bitmask_16(1 << 24);
            25 &&& 0x1f : apply_bitmask_16(1 << 25);
            26 &&& 0x1f : apply_bitmask_16(1 << 26);
            27 &&& 0x1f : apply_bitmask_16(1 << 27);
            28 &&& 0x1f : apply_bitmask_16(1 << 28);
            29 &&& 0x1f : apply_bitmask_16(1 << 29);
            30 &&& 0x1f : apply_bitmask_16(1 << 30);
            31 &&& 0x1f : apply_bitmask_16(1 << 31);
        }
        size = 32;
    }
    table bitmask_table_15 {
        key = {
            hdr.ipv4.dst_addr[21:17]: ternary;
        }
        actions = {
            apply_bitmask_15;
        }
        const entries = {
            0  &&& 0x1f : apply_bitmask_15(1 << 0);
            1  &&& 0x1f : apply_bitmask_15(1 << 1);
            2  &&& 0x1f : apply_bitmask_15(1 << 2);
            3  &&& 0x1f : apply_bitmask_15(1 << 3);
            4  &&& 0x1f : apply_bitmask_15(1 << 4);
            5  &&& 0x1f : apply_bitmask_15(1 << 5);
            6  &&& 0x1f : apply_bitmask_15(1 << 6);
            7  &&& 0x1f : apply_bitmask_15(1 << 7);
            8  &&& 0x1f : apply_bitmask_15(1 << 8);
            9  &&& 0x1f : apply_bitmask_15(1 << 9);
            10 &&& 0x1f : apply_bitmask_15(1 << 10);
            11 &&& 0x1f : apply_bitmask_15(1 << 11);
            12 &&& 0x1f : apply_bitmask_15(1 << 12);
            13 &&& 0x1f : apply_bitmask_15(1 << 13);
            14 &&& 0x1f : apply_bitmask_15(1 << 14);
            15 &&& 0x1f : apply_bitmask_15(1 << 15);
            16 &&& 0x1f : apply_bitmask_15(1 << 16);
            17 &&& 0x1f : apply_bitmask_15(1 << 17);
            18 &&& 0x1f : apply_bitmask_15(1 << 18);
            19 &&& 0x1f : apply_bitmask_15(1 << 19);
            20 &&& 0x1f : apply_bitmask_15(1 << 20);
            21 &&& 0x1f : apply_bitmask_15(1 << 21);
            22 &&& 0x1f : apply_bitmask_15(1 << 22);
            23 &&& 0x1f : apply_bitmask_15(1 << 23);
            24 &&& 0x1f : apply_bitmask_15(1 << 24);
            25 &&& 0x1f : apply_bitmask_15(1 << 25);
            26 &&& 0x1f : apply_bitmask_15(1 << 26);
            27 &&& 0x1f : apply_bitmask_15(1 << 27);
            28 &&& 0x1f : apply_bitmask_15(1 << 28);
            29 &&& 0x1f : apply_bitmask_15(1 << 29);
            30 &&& 0x1f : apply_bitmask_15(1 << 30);
            31 &&& 0x1f : apply_bitmask_15(1 << 31);
        }
        size = 32;
    }
    table bitmask_table_14 {
        key = {
            hdr.ipv4.dst_addr[22:18]: ternary;
        }
        actions = {
            apply_bitmask_14;
        }
        const entries = {
            0  &&& 0x1f : apply_bitmask_14(1 << 0);
            1  &&& 0x1f : apply_bitmask_14(1 << 1);
            2  &&& 0x1f : apply_bitmask_14(1 << 2);
            3  &&& 0x1f : apply_bitmask_14(1 << 3);
            4  &&& 0x1f : apply_bitmask_14(1 << 4);
            5  &&& 0x1f : apply_bitmask_14(1 << 5);
            6  &&& 0x1f : apply_bitmask_14(1 << 6);
            7  &&& 0x1f : apply_bitmask_14(1 << 7);
            8  &&& 0x1f : apply_bitmask_14(1 << 8);
            9  &&& 0x1f : apply_bitmask_14(1 << 9);
            10 &&& 0x1f : apply_bitmask_14(1 << 10);
            11 &&& 0x1f : apply_bitmask_14(1 << 11);
            12 &&& 0x1f : apply_bitmask_14(1 << 12);
            13 &&& 0x1f : apply_bitmask_14(1 << 13);
            14 &&& 0x1f : apply_bitmask_14(1 << 14);
            15 &&& 0x1f : apply_bitmask_14(1 << 15);
            16 &&& 0x1f : apply_bitmask_14(1 << 16);
            17 &&& 0x1f : apply_bitmask_14(1 << 17);
            18 &&& 0x1f : apply_bitmask_14(1 << 18);
            19 &&& 0x1f : apply_bitmask_14(1 << 19);
            20 &&& 0x1f : apply_bitmask_14(1 << 20);
            21 &&& 0x1f : apply_bitmask_14(1 << 21);
            22 &&& 0x1f : apply_bitmask_14(1 << 22);
            23 &&& 0x1f : apply_bitmask_14(1 << 23);
            24 &&& 0x1f : apply_bitmask_14(1 << 24);
            25 &&& 0x1f : apply_bitmask_14(1 << 25);
            26 &&& 0x1f : apply_bitmask_14(1 << 26);
            27 &&& 0x1f : apply_bitmask_14(1 << 27);
            28 &&& 0x1f : apply_bitmask_14(1 << 28);
            29 &&& 0x1f : apply_bitmask_14(1 << 29);
            30 &&& 0x1f : apply_bitmask_14(1 << 30);
            31 &&& 0x1f : apply_bitmask_14(1 << 31);
        }
        size = 32;
    }
    table bitmask_table_13 {
        key = {
            hdr.ipv4.dst_addr[23:19]: ternary;
        }
        actions = {
            apply_bitmask_13;
        }
        const entries = {
            0  &&& 0x1f : apply_bitmask_13(1 << 0);
            1  &&& 0x1f : apply_bitmask_13(1 << 1);
            2  &&& 0x1f : apply_bitmask_13(1 << 2);
            3  &&& 0x1f : apply_bitmask_13(1 << 3);
            4  &&& 0x1f : apply_bitmask_13(1 << 4);
            5  &&& 0x1f : apply_bitmask_13(1 << 5);
            6  &&& 0x1f : apply_bitmask_13(1 << 6);
            7  &&& 0x1f : apply_bitmask_13(1 << 7);
            8  &&& 0x1f : apply_bitmask_13(1 << 8);
            9  &&& 0x1f : apply_bitmask_13(1 << 9);
            10 &&& 0x1f : apply_bitmask_13(1 << 10);
            11 &&& 0x1f : apply_bitmask_13(1 << 11);
            12 &&& 0x1f : apply_bitmask_13(1 << 12);
            13 &&& 0x1f : apply_bitmask_13(1 << 13);
            14 &&& 0x1f : apply_bitmask_13(1 << 14);
            15 &&& 0x1f : apply_bitmask_13(1 << 15);
            16 &&& 0x1f : apply_bitmask_13(1 << 16);
            17 &&& 0x1f : apply_bitmask_13(1 << 17);
            18 &&& 0x1f : apply_bitmask_13(1 << 18);
            19 &&& 0x1f : apply_bitmask_13(1 << 19);
            20 &&& 0x1f : apply_bitmask_13(1 << 20);
            21 &&& 0x1f : apply_bitmask_13(1 << 21);
            22 &&& 0x1f : apply_bitmask_13(1 << 22);
            23 &&& 0x1f : apply_bitmask_13(1 << 23);
            24 &&& 0x1f : apply_bitmask_13(1 << 24);
            25 &&& 0x1f : apply_bitmask_13(1 << 25);
            26 &&& 0x1f : apply_bitmask_13(1 << 26);
            27 &&& 0x1f : apply_bitmask_13(1 << 27);
            28 &&& 0x1f : apply_bitmask_13(1 << 28);
            29 &&& 0x1f : apply_bitmask_13(1 << 29);
            30 &&& 0x1f : apply_bitmask_13(1 << 30);
            31 &&& 0x1f : apply_bitmask_13(1 << 31);
        }
        size = 32;
    }
    table bitstring_table_24 {
        key = {
            hdr.ipv4.dst_addr[31:13]: exact;
        }
        actions = {
            get_bitstring_24;
        }
        size = 524288;
    }
    table bitstring_table_23 {
        key = {
            hdr.ipv4.dst_addr[31:14]: exact;
        }
        actions = {
            get_bitstring_23;
        }
        size = 262144;
    }
    table bitstring_table_22 {
        key = {
            hdr.ipv4.dst_addr[31:15]: exact;
        }
        actions = {
            get_bitstring_22;
        }
        size = 131072;
    }
    table bitstring_table_21 {
        key = {
            hdr.ipv4.dst_addr[31:16]: exact;
        }
        actions = {
            get_bitstring_21;
        }
        size = 65536;
    }
    table bitstring_table_20 {
        key = {
            hdr.ipv4.dst_addr[31:17]: exact;
        }
        actions = {
            get_bitstring_20;
        }
        size = 32768;
    }
    table bitstring_table_19 {
        key = {
            hdr.ipv4.dst_addr[31:18]: exact;
        }
        actions = {
            get_bitstring_19;
        }
        size = 16384;
    }
    table bitstring_table_18 {
        key = {
            hdr.ipv4.dst_addr[31:19]: exact;
        }
        actions = {
            get_bitstring_18;
        }
        size = 8192;
    }
    table bitstring_table_17 {
        key = {
            hdr.ipv4.dst_addr[31:20]: exact;
        }
        actions = {
            get_bitstring_17;
        }
        size = 4096;
    }
    table bitstring_table_16 {
        key = {
            hdr.ipv4.dst_addr[31:21]: exact;
        }
        actions = {
            get_bitstring_16;
        }
        size = 2048;
    }
    table bitstring_table_15 {
        key = {
            hdr.ipv4.dst_addr[31:22]: exact;
        }
        actions = {
            get_bitstring_15;
        }
        size = 1024;
    }
    table bitstring_table_14 {
        key = {
            hdr.ipv4.dst_addr[31:23]: exact;
        }
        actions = {
            get_bitstring_14;
        }
        size = 512;
    }
    table bitstring_table_13 {
        key = {
            hdr.ipv4.dst_addr[31:24]: exact;
        }
        actions = {
            get_bitstring_13;
        }
        size = 256;
    }
    table hash_key_table {
        key = {
            umd.bitmap_24_hit : ternary;
            umd.bitmap_23_hit : ternary;
            umd.bitmap_22_hit : ternary;
            umd.bitmap_21_hit : ternary;
            umd.bitmap_20_hit : ternary;
            umd.bitmap_19_hit : ternary;
            umd.bitmap_18_hit : ternary;
            umd.bitmap_17_hit : ternary;
            umd.bitmap_16_hit : ternary;
            umd.bitmap_15_hit : ternary;
            umd.bitmap_14_hit : ternary;
            umd.bitmap_13_hit : ternary;
        }
        actions = {
            get_hash_key_24;
            get_hash_key_23;
            get_hash_key_22;
            get_hash_key_21;
            get_hash_key_20;
            get_hash_key_19;
            get_hash_key_18;
            get_hash_key_17;
            get_hash_key_16;
            get_hash_key_15;
            get_hash_key_14;
            get_hash_key_13;
            drop_packet;
        }
        const default_action = drop_packet;
        const entries = {
            (1 &&& 1 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0) : get_hash_key_24();
            (0 &&& 0 , 1 &&& 1 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0) : get_hash_key_23();
            (0 &&& 0 , 0 &&& 0 , 1 &&& 1 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0) : get_hash_key_22();
            (0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 1 &&& 1 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0) : get_hash_key_21();
            (0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 1 &&& 1 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0) : get_hash_key_20();
            (0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 1 &&& 1 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0) : get_hash_key_19();
            (0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 1 &&& 1 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0) : get_hash_key_18();
            (0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 1 &&& 1 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0) : get_hash_key_17();
            (0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 1 &&& 1 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0) : get_hash_key_16();
            (0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 1 &&& 1 , 0 &&& 0 , 0 &&& 0) : get_hash_key_15();
            (0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 1 &&& 1 , 0 &&& 0) : get_hash_key_14();
            (0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 0 &&& 0 , 1 &&& 1) : get_hash_key_13();
        }
        size = 13;
    }
    table hash_table {
        key = {
            umd.hash_key : exact;
        }
        actions = {
            set_next_hop_index;
        }
        // 933643 * (1/.80) for expected hash table utilization of 80%
        // -> 1167053
	size = HASH_TABLE_SIZE;
    }
    table next_hop_table {
        key = {  
            umd.next_hop_index : exact;
        }
        actions = {
            unicast_to_port;
        }
        size = 4;
    }

    apply {
        if (initial_lookup_table.apply().miss) {
            bitstring_table_24.apply();
            bitmask_table_24.apply();
            if (umd.bitstring_24 != 0) {
                umd.bitmap_24_hit = 1;
            }
            else {
                umd.bitmap_24_hit = 0;
            }

            bitstring_table_23.apply();
            bitmask_table_23.apply();
            if (umd.bitstring_23 != 0) {
                umd.bitmap_23_hit = 1;
            }
            else {
                umd.bitmap_23_hit = 0;
            }

            bitstring_table_22.apply();
            bitmask_table_22.apply();
            if (umd.bitstring_22 != 0) {
                umd.bitmap_22_hit = 1;
            }
            else {
                umd.bitmap_22_hit = 0;
            }
            
            bitstring_table_21.apply();
            bitmask_table_21.apply();
            if (umd.bitstring_21 != 0) {
                umd.bitmap_21_hit = 1;
            }
            else {
                umd.bitmap_21_hit = 0;
            }
            
            bitstring_table_20.apply();
            bitmask_table_20.apply();
            if (umd.bitstring_20 != 0) {
                umd.bitmap_20_hit = 1;
            }
            else {
                umd.bitmap_20_hit = 0;
            }
            
            bitstring_table_19.apply();
            bitmask_table_19.apply();
            if (umd.bitstring_19 != 0) {
                umd.bitmap_19_hit = 1;
            }
            else {
                umd.bitmap_19_hit = 0;
            }
            
            bitstring_table_18.apply();
            bitmask_table_18.apply();
            if (umd.bitstring_18 != 0) {
                umd.bitmap_18_hit = 1;
            }
            else {
                umd.bitmap_18_hit = 0;
            }
            
            bitstring_table_17.apply();
            bitmask_table_17.apply();
            if (umd.bitstring_17 != 0) {
                umd.bitmap_17_hit = 1;
            }
            else {
                umd.bitmap_17_hit = 0;
            }
            
            bitstring_table_16.apply();
            bitmask_table_16.apply();
            if (umd.bitstring_16 != 0) {
                umd.bitmap_16_hit = 1;
            }
            else {
                umd.bitmap_16_hit = 0;
            }
            
            bitstring_table_15.apply();
            bitmask_table_15.apply();
            if (umd.bitstring_15 != 0) {
                umd.bitmap_15_hit = 1;
            }
            else {
                umd.bitmap_15_hit = 0;
            }

            bitstring_table_14.apply();
            bitmask_table_14.apply();
            if (umd.bitstring_14 != 0) {
                umd.bitmap_14_hit = 1;
            }
            else {
                umd.bitmap_14_hit = 0;
            }
            
            bitstring_table_13.apply();
            bitmask_table_13.apply();
            if (umd.bitstring_13 != 0) {
                umd.bitmap_13_hit = 1;
            }
            else {
                umd.bitmap_13_hit = 0;
            }
            
            hash_key_table.apply();
            apply_hash_mask();
            hash_table.apply();
        }
        next_hop_table.apply();
    }
}

control ingressDeparserImpl(
    packet_out pkt,
    inout ingress_headers_t  hdr,
    in    ingress_metadata_t umd,
    in    ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md)
{
    apply {
        pkt.emit(hdr.bridge_md);
        pkt.emit(hdr.ethernet);
        pkt.emit(hdr.ipv4);
    }
}

parser egressParserImpl(
    packet_in pkt,
    out egress_headers_t  hdr,
    out egress_metadata_t umd,
    out egress_intrinsic_metadata_t eg_intr_md)
{
    state start {
        pkt.extract(eg_intr_md);
        transition parse_bridge_metadata;
    }

    state parse_bridge_metadata {
        pkt.extract(hdr.bridge_md);
        transition accept;
    }
}

control egressImpl(
    inout egress_headers_t  hdr,
    inout egress_metadata_t umd,
    in    egress_intrinsic_metadata_t                 eg_intr_md,
    in    egress_intrinsic_metadata_from_parser_t     eg_prsr_md,
    inout egress_intrinsic_metadata_for_deparser_t    eg_dprsr_md,
    inout egress_intrinsic_metadata_for_output_port_t eg_oport_md)
{
    apply {
    }
}

control egressDeparserImpl(
    packet_out pkt,
    inout egress_headers_t  hdr,
    in    egress_metadata_t umd,
    in    egress_intrinsic_metadata_for_deparser_t eg_dprsr_md)
{
    apply {
    }
}

Pipeline(ingressParserImpl(),
         ingressImpl(),
         ingressDeparserImpl(),
         egressParserImpl(),
         egressImpl(),
         egressDeparserImpl()) pipe;

// In a multi-pipe Tofino device, the TNA package instantiation below
// implies that the same P4 code behavior is loaded into all of the
// pipes.

Switch(pipe) main;
