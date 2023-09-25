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

#include "bsic-table-sizes.p4"

// There are two styles of P4 code that can be enabled by choosing to
// #define at most one of the two preprocessor symbols below:

#define COMPARE_PREFIX_IN_ONE_PIECE
#undef COMPARE_PREFIX_IN_TWO_PIECES

const bit<8> SLICE = 24;

#ifdef COMPARE_PREFIX_IN_ONE_PIECE
// Conditions that the code below assumes are true about these
// constant values:

// (2 <= SLICE) && (SLICE <= 62)
// (SLICE % 2) == 0
// (PREFIX_WIDTH >= 1)
// (PREFIX_EXTRA >= 1)
// (SLICE + PREFIX_WIDTH) == 64

#define PREFIX_EXTRA 24
#define PREFIX_WIDTH 40

// SLICE  PREFIX_WIDTH  PREFIX_EXTRA  result  stages
//  24       40               8        PHV allocation was not successful
//  24       40              24        PHV allocation was not successful

#endif  // COMPARE_PREFIX_IN_ONE_PIECE

#ifdef COMPARE_PREFIX_IN_TWO_PIECES
// Conditions that the code below assumes are true about these
// constant values:

// (2 <= SLICE) && (SLICE <= 62)
// (SLICE % 2) == 0
// (HI_WIDTH >= 1)
// (LO_WIDTH >= 1)
// (HI_EXTRA >= 1)
// (LO_EXTRA >= 1)
// (SLICE + HI_WIDTH + LO_WIDTH) == 64

#define HI_EXTRA 4
#define HI_WIDTH 12
#define LO_EXTRA 4
#define LO_WIDTH 12

// Successful compiles with these combinations of values have been tested:

// SLICE  HI_WIDTH  HI_EXTRA  LO_WIDTH  LO_EXTRA  result  stages
//  40       12         0        12        0      ok      19
//  24        8         0        32        0      ok      19
//  22       10         0        32        0      ok      19
//  20       12         0        32        0      ok      19
//   2       30         0        32        0      ok      19

// So far I have found very few combinations of values with HI_EXTRA
// >= 1 and LO_EXTRA >= 1 that compile successfully:
//  40       12         4        12        4      ok      19

#endif  // COMPARE_PREFIX_IN_TWO_PIECES


// PADBITS(n) is intended to be the number of padding bits to put
// next to a field that is n bits wide, so that the total of the n-bit
// field and the padding add up to a multiple of 8 bits, and that the
// padding is as few bits as possible.

// Example values of PADBITS(n):
// n  PADBITS(n)
// 1  7
// 7  1
// 8  0
// 9  7
// 16 0
#define PADBITS(n) (7-(((n)-1) % 8))

const PortId_t LOOPBACK_PORT = 5;

#define NEXT_HOP_SIZE 8
#define BST_INDEX_SIZE 17

typedef bit<NEXT_HOP_SIZE> next_hop_index_t;
typedef bit<BST_INDEX_SIZE> bst_index_t;
typedef bit<1> bst_hit_t;

header bridge_metadata_t {
    // user-defined metadata carried over from ingress to egress.
#if PADBITS(NEXT_HOP_SIZE+1) != 0
    @padding bit<(PADBITS(NEXT_HOP_SIZE+1))> rsvd0;
#endif
    bst_hit_t bst_hit;
    next_hop_index_t next_hop_index;
#if PADBITS(BST_INDEX_SIZE) != 0
    @padding bit<(PADBITS(BST_INDEX_SIZE))> rsvd0b;
#endif
    bst_index_t bst_index;
#ifdef COMPARE_PREFIX_IN_ONE_PIECE
#if PADBITS(PREFIX_WIDTH+PREFIX_EXTRA) != 0
    bit<(PADBITS(PREFIX_WIDTH+PREFIX_EXTRA))> rsvd1;
#endif
    bit<(PREFIX_WIDTH+PREFIX_EXTRA)> dst_addr_prefix;
#if PADBITS(PREFIX_WIDTH+PREFIX_EXTRA) != 0
    bit<(PADBITS(PREFIX_WIDTH+PREFIX_EXTRA))> rsvd3;
#endif
    bit<(PREFIX_WIDTH+PREFIX_EXTRA)> dst_addr_prefix_plus_1;
#endif  // COMPARE_PREFIX_IN_ONE_PIECE

#ifdef COMPARE_PREFIX_IN_TWO_PIECES
#if PADBITS(HI_WIDTH+HI_EXTRA) != 0
    bit<(PADBITS(HI_WIDTH+HI_EXTRA))> rsvd1;
#endif
    bit<(HI_WIDTH+HI_EXTRA)> dst_addr_prefix_hi;
#if PADBITS(LO_WIDTH+LO_EXTRA) != 0
    bit<(PADBITS(LO_WIDTH+LO_EXTRA))> rsvd2;
#endif
    bit<(LO_WIDTH+LO_EXTRA)> dst_addr_prefix_lo;
#if PADBITS(HI_WIDTH+HI_EXTRA) != 0
    bit<(PADBITS(HI_WIDTH+HI_EXTRA))> rsvd3;
#endif
    bit<(HI_WIDTH+HI_EXTRA)> dst_addr_prefix_hi_plus_1;
#if PADBITS(LO_WIDTH+LO_EXTRA) != 0
    bit<(PADBITS(LO_WIDTH+LO_EXTRA))> rsvd4;
#endif
    bit<(LO_WIDTH+LO_EXTRA)> dst_addr_prefix_lo_plus_1;
#endif  // COMPARE_PREFIX_IN_TWO_PIECES
}

header loopback_h {
    @padding bit<15> rsvd;
    bit<1> bst_hit;
#if PADBITS(BST_INDEX_SIZE) != 0
    @padding bit<(PADBITS(BST_INDEX_SIZE))> rsvd0;
#endif
    bst_index_t bst_index;
}

struct ingress_headers_t {
    bridge_metadata_t bridge_md;
    loopback_h loopback;
    ethernet_h ethernet;
    ipv6_h ipv6;
}

struct egress_headers_t {
    bridge_metadata_t bridge_md;
    loopback_h loopback;
}

struct ingress_metadata_t {
    // user-defined ingress metadata
    bit<(PREFIX_WIDTH+PREFIX_EXTRA)> dst_addr_prefix;
    next_hop_index_t tmp_nhi;
    bst_index_t tmp_left_child;
    bst_index_t tmp_right_child;
    bit<1> tmp_left_child_valid;
    bit<1> tmp_right_child_valid;
#ifdef COMPARE_PREFIX_IN_ONE_PIECE
    bit<(PREFIX_WIDTH+PREFIX_EXTRA)> prefix_minus_dst_addr_prefix;
    bit<(PREFIX_WIDTH+PREFIX_EXTRA)> prefix_minus_dst_addr_prefix_minus_1;
#endif  // COMPARE_PREFIX_IN_ONE_PIECE
#ifdef COMPARE_PREFIX_IN_TWO_PIECES
    bit<(HI_WIDTH+HI_EXTRA)> prefix_minus_dst_addr_prefix_hi;
    bit<(LO_WIDTH+LO_EXTRA)> prefix_minus_dst_addr_prefix_lo;
    bit<(HI_WIDTH+HI_EXTRA)> prefix_minus_dst_addr_prefix_hi_minus_1;
    bit<(LO_WIDTH+LO_EXTRA)> prefix_minus_dst_addr_prefix_lo_minus_1;
#endif  // COMPARE_PREFIX_IN_TWO_PIECES
}

struct egress_metadata_t {
    // user-defined egress metadata
    next_hop_index_t tmp_nhi;
    bst_index_t tmp_left_child;
    bst_index_t tmp_right_child;
    bit<1> tmp_left_child_valid;
    bit<1> tmp_right_child_valid;
#ifdef COMPARE_PREFIX_IN_ONE_PIECE
    bit<(PREFIX_WIDTH+PREFIX_EXTRA)> prefix_minus_dst_addr_prefix;
    bit<(PREFIX_WIDTH+PREFIX_EXTRA)> prefix_minus_dst_addr_prefix_minus_1;
#endif  // COMPARE_PREFIX_IN_ONE_PIECE
#ifdef COMPARE_PREFIX_IN_TWO_PIECES
    bit<(HI_WIDTH+HI_EXTRA)> prefix_minus_dst_addr_prefix_hi;
    bit<(LO_WIDTH+LO_EXTRA)> prefix_minus_dst_addr_prefix_lo;
    bit<(HI_WIDTH+HI_EXTRA)> prefix_minus_dst_addr_prefix_hi_minus_1;
    bit<(LO_WIDTH+LO_EXTRA)> prefix_minus_dst_addr_prefix_lo_minus_1;
#endif  // COMPARE_PREFIX_IN_TWO_PIECES
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
        transition parse_if_loopback;
    }
    state parse_if_loopback {
        transition select (ig_intr_md.ingress_port) {
            LOOPBACK_PORT : parse_loopback;
            default : parse_ethernet;
        }
    }
    state parse_loopback {
        pkt.extract(hdr.loopback);
        transition parse_ethernet;
    }
    state parse_ethernet {
        pkt.extract(hdr.ethernet);
        transition parse_ipv6;
    }
    state parse_ipv6 {
        pkt.extract(hdr.ipv6);
        umd.dst_addr_prefix = (bit<(PREFIX_WIDTH+PREFIX_EXTRA)>) hdr.ipv6.dst_addr[127:64];
        transition accept;
    }
}


#ifdef COMPARE_PREFIX_IN_ONE_PIECE
                    // First if condition below should be equivalent to
                    // (prefix == dst_addr_prefix)
                    // Second if condition below should be equivalent to
                    // (prefix < dst_addr_prefix)
#define NODE_DECISION_CODE \
                    if ((umd.prefix_minus_dst_addr_prefix[(PREFIX_WIDTH+PREFIX_EXTRA-1):(PREFIX_WIDTH+PREFIX_EXTRA-1)] == 0) && \
                        (umd.prefix_minus_dst_addr_prefix_minus_1[(PREFIX_WIDTH+PREFIX_EXTRA-1):(PREFIX_WIDTH+PREFIX_EXTRA-1)] == 1)) { \
                        hdr.bridge_md.next_hop_index = umd.tmp_nhi; \
                        hdr.bridge_md.bst_hit = 1; \
                    } \
                    else if (umd.prefix_minus_dst_addr_prefix[(PREFIX_WIDTH+PREFIX_EXTRA-1):(PREFIX_WIDTH+PREFIX_EXTRA-1)] == 1) { \
                        hdr.bridge_md.next_hop_index = umd.tmp_nhi; \
                        if (umd.tmp_right_child_valid == 0) { \
                            hdr.bridge_md.bst_hit = 1; \
                        } \
                        else { \
                            hdr.bridge_md.bst_index = umd.tmp_right_child; \
                        } \
                    } \
                    else { \
                        if (umd.tmp_left_child_valid == 0) { \
                            hdr.bridge_md.bst_hit = 1; \
                        } \
                        else { \
                            hdr.bridge_md.bst_index = umd.tmp_left_child; \
                        } \
                    }
#endif  // COMPARE_PREFIX_IN_ONE_PIECE
#ifdef COMPARE_PREFIX_IN_TWO_PIECES
                    // First if condition below should be equivalent to
                    // (prefix == dst_addr_prefix)
                    // Second if condition below should be equivalent to
                    // (prefix < dst_addr_prefix)
#define NODE_DECISION_CODE \
                    if ((umd.prefix_minus_dst_addr_prefix_hi[(HI_WIDTH+HI_EXTRA-1):(HI_WIDTH+HI_EXTRA-1)] == 0) && \
                        (umd.prefix_minus_dst_addr_prefix_hi_minus_1[(HI_WIDTH+HI_EXTRA-1):(HI_WIDTH+HI_EXTRA-1)] == 1) && \
                        (umd.prefix_minus_dst_addr_prefix_lo[(LO_WIDTH+LO_EXTRA-1):(LO_WIDTH+LO_EXTRA-1)] == 0) && \
                        (umd.prefix_minus_dst_addr_prefix_lo_minus_1[(LO_WIDTH+LO_EXTRA-1):(LO_WIDTH+LO_EXTRA-1)] == 1)) { \
                        hdr.bridge_md.next_hop_index = umd.tmp_nhi; \
                        hdr.bridge_md.bst_hit = 1; \
                    } \
                    else if ((umd.prefix_minus_dst_addr_prefix_hi[(HI_WIDTH+HI_EXTRA-1):(HI_WIDTH+HI_EXTRA-1)] == 1) || \
                        ((umd.prefix_minus_dst_addr_prefix_hi[(HI_WIDTH+HI_EXTRA-1):(HI_WIDTH+HI_EXTRA-1)] == 0) && \
                            (umd.prefix_minus_dst_addr_prefix_hi_minus_1[(HI_WIDTH+HI_EXTRA-1):(HI_WIDTH+HI_EXTRA-1)] == 1) && \
                            (umd.prefix_minus_dst_addr_prefix_lo[(LO_WIDTH+LO_EXTRA-1):(LO_WIDTH+LO_EXTRA-1)] == 1)) \
                    ) { \
                        hdr.bridge_md.next_hop_index = umd.tmp_nhi; \
                        if (umd.tmp_right_child_valid == 0) { \
                            hdr.bridge_md.bst_hit = 1; \
                        } \
                        else { \
                            hdr.bridge_md.bst_index = umd.tmp_right_child; \
                        } \
                    } \
                    else { \
                        if (umd.tmp_left_child_valid == 0) { \
                            hdr.bridge_md.bst_hit = 1; \
                        } \
                        else { \
                            hdr.bridge_md.bst_index = umd.tmp_left_child; \
                        } \
                    }
#endif  // COMPARE_PREFIX_IN_TWO_PIECES

control ingressImpl(
    inout ingress_headers_t  hdr,
    inout ingress_metadata_t umd,
    in    ingress_intrinsic_metadata_t              ig_intr_md,
    in    ingress_intrinsic_metadata_from_parser_t  ig_prsr_md,
    inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
    inout ingress_intrinsic_metadata_for_tm_t       ig_tm_md)
{
    action drop_packet() {
        ig_dprsr_md.drop_ctl = 1;
        return;
    }
    action unicast_to_port(PortId_t p) {
        ig_tm_md.ucast_egress_port = p;
    }
    action set_next_hop_index(next_hop_index_t nhi) {
        hdr.bridge_md.next_hop_index = nhi;
    }
    action set_bst_index(bst_index_t bi) {
	    hdr.bridge_md.bst_index = bi;
    }
    action node_decision(
#ifdef COMPARE_PREFIX_IN_ONE_PIECE
        bit<(PREFIX_WIDTH+PREFIX_EXTRA)> prefix,
#endif  // COMPARE_PREFIX_IN_ONE_PIECE
#ifdef COMPARE_PREFIX_IN_TWO_PIECES
        bit<(HI_WIDTH+HI_EXTRA)> prefix_hi,
        bit<(LO_WIDTH+LO_EXTRA)> prefix_lo,
#endif  // COMPARE_PREFIX_IN_TWO_PIECES
        next_hop_index_t nhi,
        bst_index_t left_child,
        bst_index_t right_child,
        bit<1> left_child_valid,
        bit<1> right_child_valid)
    {
#ifdef COMPARE_PREFIX_IN_ONE_PIECE
        umd.prefix_minus_dst_addr_prefix = (prefix - hdr.bridge_md.dst_addr_prefix);
        umd.prefix_minus_dst_addr_prefix_minus_1 = (prefix - hdr.bridge_md.dst_addr_prefix_plus_1);
#endif  // COMPARE_PREFIX_IN_ONE_PIECE
#ifdef COMPARE_PREFIX_IN_TWO_PIECES
        umd.prefix_minus_dst_addr_prefix_hi = (prefix_hi - hdr.bridge_md.dst_addr_prefix_hi);
        umd.prefix_minus_dst_addr_prefix_lo = (prefix_lo - hdr.bridge_md.dst_addr_prefix_lo);
        umd.prefix_minus_dst_addr_prefix_hi_minus_1 = (prefix_hi - hdr.bridge_md.dst_addr_prefix_hi_plus_1);
        umd.prefix_minus_dst_addr_prefix_lo_minus_1 = (prefix_lo - hdr.bridge_md.dst_addr_prefix_lo_plus_1);
#endif  // COMPARE_PREFIX_IN_TWO_PIECES
        umd.tmp_nhi = nhi;
        umd.tmp_left_child = left_child;
        umd.tmp_right_child = right_child;
        umd.tmp_left_child_valid = left_child_valid;
        umd.tmp_right_child_valid = right_child_valid;
    }
    table initial_lookup_table {
        key = {
            hdr.ipv6.dst_addr[127:128-SLICE] : lpm;
        }
        actions = {
            set_next_hop_index;
            set_bst_index;
            drop_packet;
        }
        const default_action = drop_packet;
	    size = INITIAL_LOOKUP_TABLE_SIZE;
    }
    table bst_0_table {
        key = {
            hdr.bridge_md.bst_index : exact;
        }
        actions = {
            node_decision;
        }
        size = BST_0_SIZE;
    }
    table bst_1_table {
        key = {
            hdr.bridge_md.bst_index : exact;
        }
        actions = {
            node_decision;
        }
        size = BST_1_SIZE;
    }
    table bst_2_table {
        key = {
            hdr.bridge_md.bst_index : exact;
        }
        actions = {
            node_decision;
        }
        size = BST_2_SIZE;
    }
    table bst_3_table {
        key = {
            hdr.bridge_md.bst_index : exact;
        }
        actions = {
            node_decision;
        }
        size = BST_3_SIZE;
    }
    table bst_4_table {
        key = {
            hdr.bridge_md.bst_index : exact;
        }
        actions = {
            node_decision;
        }
        size = BST_4_SIZE;
    }
    table bst_12_table {
        key = {
            hdr.bridge_md.bst_index : exact;
        }
        actions = {
            node_decision;
        }
        size = BST_12_SIZE;
    }
    table bst_13_table {
        key = {
            hdr.bridge_md.bst_index : exact;
        }
        actions = {
            node_decision;
        }
        size = BST_13_SIZE;
    }
    table next_hop_table {
        key = {
            hdr.bridge_md.next_hop_index : exact;
        }
        actions = {
            unicast_to_port;
        }
        size = 4;
    }
    action copy_loopback_fields_to_bridge_md() {
        hdr.bridge_md.bst_hit = hdr.loopback.bst_hit;
        hdr.bridge_md.bst_index = hdr.loopback.bst_index;
    }

    apply {
        if (hdr.loopback.isValid()) {
            copy_loopback_fields_to_bridge_md();
            if (hdr.bridge_md.bst_hit != 1) {
                bst_12_table.apply();
                NODE_DECISION_CODE
            }
            if (hdr.bridge_md.bst_hit != 1) {
                bst_13_table.apply();
                NODE_DECISION_CODE
            }
            if (hdr.bridge_md.bst_hit != 1) {
                drop_packet();
            }
            next_hop_table.apply();
        } else {
            unicast_to_port(LOOPBACK_PORT);
            hdr.bridge_md.setValid();
            hdr.bridge_md.bst_hit = 0;

#ifdef COMPARE_PREFIX_IN_ONE_PIECE
            hdr.bridge_md.dst_addr_prefix = umd.dst_addr_prefix & (-1 >> SLICE);
            hdr.bridge_md.dst_addr_prefix_plus_1 = hdr.bridge_md.dst_addr_prefix + 1;
#endif  // COMPARE_PREFIX_IN_ONE_PIECE
#ifdef COMPARE_PREFIX_IN_TWO_PIECES
            hdr.bridge_md.dst_addr_prefix_hi = (bit<(HI_WIDTH+HI_EXTRA)>) hdr.ipv6.dst_addr[128-SLICE-1:64+LO_WIDTH];
            hdr.bridge_md.dst_addr_prefix_lo = (bit<(LO_WIDTH+LO_EXTRA)>) hdr.ipv6.dst_addr[64+LO_WIDTH-1:64];
            hdr.bridge_md.dst_addr_prefix_hi_plus_1 = (bit<(HI_WIDTH+HI_EXTRA)>) hdr.ipv6.dst_addr[128-SLICE-1:64+LO_WIDTH] + 1;
            hdr.bridge_md.dst_addr_prefix_lo_plus_1 = (bit<(LO_WIDTH+LO_EXTRA)>) hdr.ipv6.dst_addr[64+LO_WIDTH-1:64] + 1;
#endif  // COMPARE_PREFIX_IN_TWO_PIECES

            switch (initial_lookup_table.apply().action_run) {
                set_next_hop_index: {
                    hdr.bridge_md.bst_hit = 1;
                }
                set_bst_index: {
                    bst_0_table.apply();
                    NODE_DECISION_CODE
                    if (hdr.bridge_md.bst_hit != 1) {
                        bst_1_table.apply();
                        NODE_DECISION_CODE
                    }
                    if (hdr.bridge_md.bst_hit != 1) {
                        bst_2_table.apply();
                        NODE_DECISION_CODE
                    }
                    if (hdr.bridge_md.bst_hit != 1) {
                        bst_3_table.apply();
                        NODE_DECISION_CODE
                    }
                    if (hdr.bridge_md.bst_hit != 1) {
                        bst_4_table.apply();
                        NODE_DECISION_CODE
                    }
                }
            }
        }
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
        pkt.emit(hdr.ipv6);
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
    action drop_packet() {
        eg_dprsr_md.drop_ctl = 1;
        return;
    }
    action node_decision(
#ifdef COMPARE_PREFIX_IN_ONE_PIECE
        bit<(PREFIX_WIDTH+PREFIX_EXTRA)> prefix,
#endif  // COMPARE_PREFIX_IN_ONE_PIECE
#ifdef COMPARE_PREFIX_IN_TWO_PIECES
        bit<(HI_WIDTH+HI_EXTRA)> prefix_hi,
        bit<(LO_WIDTH+LO_EXTRA)> prefix_lo,
#endif  // COMPARE_PREFIX_IN_TWO_PIECES
        next_hop_index_t nhi,
        bst_index_t left_child,
        bst_index_t right_child,
        bit<1> left_child_valid,
        bit<1> right_child_valid)
    {
#ifdef COMPARE_PREFIX_IN_ONE_PIECE
        umd.prefix_minus_dst_addr_prefix = (prefix - hdr.bridge_md.dst_addr_prefix);
        umd.prefix_minus_dst_addr_prefix_minus_1 = (prefix - hdr.bridge_md.dst_addr_prefix_plus_1);
#endif  // COMPARE_PREFIX_IN_ONE_PIECE
#ifdef COMPARE_PREFIX_IN_TWO_PIECES
        umd.prefix_minus_dst_addr_prefix_hi = (prefix_hi - hdr.bridge_md.dst_addr_prefix_hi);
        umd.prefix_minus_dst_addr_prefix_lo = (prefix_lo - hdr.bridge_md.dst_addr_prefix_lo);
        umd.prefix_minus_dst_addr_prefix_hi_minus_1 = (prefix_hi - hdr.bridge_md.dst_addr_prefix_hi_plus_1);
        umd.prefix_minus_dst_addr_prefix_lo_minus_1 = (prefix_lo - hdr.bridge_md.dst_addr_prefix_lo_plus_1);
#endif  // COMPARE_PREFIX_IN_TWO_PIECES
        umd.tmp_nhi = nhi;
        umd.tmp_left_child = left_child;
        umd.tmp_right_child = right_child;
        umd.tmp_left_child_valid = left_child_valid;
        umd.tmp_right_child_valid = right_child_valid;
    }
    table bst_5_table {
        key = {
            hdr.bridge_md.bst_index : exact;
        }
        actions = {
            node_decision;
        }
        size = BST_5_SIZE;
    }
    table bst_6_table {
        key = {
            hdr.bridge_md.bst_index : exact;
        }
        actions = {
            node_decision;
        }
        size = BST_6_SIZE;
    }
    table bst_7_table {
        key = {
            hdr.bridge_md.bst_index : exact;
        }
        actions = {
            node_decision;
        }
        size = BST_7_SIZE;
    }
    table bst_8_table {
        key = {
            hdr.bridge_md.bst_index : exact;
        }
        actions = {
            node_decision;
        }
        size = BST_8_SIZE;
    }
    table bst_9_table {
        key = {
            hdr.bridge_md.bst_index : exact;
        }
        actions = {
            node_decision;
        }
        size = BST_9_SIZE;
    }
    table bst_10_table {
        key = {
            hdr.bridge_md.bst_index : exact;
        }
        actions = {
            node_decision;
        }
        size = BST_10_SIZE;
    }
    table bst_11_table {
        key = {
            hdr.bridge_md.bst_index : exact;
        }
        actions = {
            node_decision;
        }
        size = BST_11_SIZE;
    }
    action init_loopback_header() {
        hdr.loopback.setValid();
        hdr.loopback.bst_hit = hdr.bridge_md.bst_hit;
        hdr.loopback.bst_index = hdr.bridge_md.bst_index;
    }

    apply {
        if (eg_intr_md.egress_port == LOOPBACK_PORT) {
            // need to set header to valid because emit depends on the valid bit
            if (hdr.bridge_md.bst_hit != 1) {
                bst_5_table.apply();
                NODE_DECISION_CODE
            }
            if (hdr.bridge_md.bst_hit != 1) {
                bst_6_table.apply();
                NODE_DECISION_CODE
            }
            if (hdr.bridge_md.bst_hit != 1) {
                bst_7_table.apply();
                NODE_DECISION_CODE
            }
            if (hdr.bridge_md.bst_hit != 1) {
                bst_8_table.apply();
                NODE_DECISION_CODE
            }
            if (hdr.bridge_md.bst_hit != 1) {
                bst_9_table.apply();
                NODE_DECISION_CODE
            }
            if (hdr.bridge_md.bst_hit != 1) {
                bst_10_table.apply();
                NODE_DECISION_CODE
            }
            if (hdr.bridge_md.bst_hit != 1) {
                bst_11_table.apply();
                NODE_DECISION_CODE
            }
            init_loopback_header();
        }
    }
}

control egressDeparserImpl(
    packet_out pkt,
    inout egress_headers_t  hdr,
    in    egress_metadata_t umd,
    in    egress_intrinsic_metadata_for_deparser_t eg_dprsr_md)
{
    apply {
        pkt.emit(hdr.loopback);
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
