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
#define __TARGET_TOFINO__ 1
#include <tna.p4>

#include <stdheaders.p4>

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
    ethernet_h ethernet;
    ipv4_h ipv4;
}

struct ingress_metadata_t {
    // user-defined ingress metadata
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
    action unicast_to_port (PortId_t p) {
        ig_tm_md.ucast_egress_port = p;
    }
    action my_drop () {
        ig_dprsr_md.drop_ctl = 1;
    }
    table forward_by_destmac {
        key = {
            hdr.ethernet.dst_addr : exact;
        }
        actions = {
            unicast_to_port;
            my_drop;
            NoAction;
        }
        const default_action = my_drop;
        size = 1024;
    }

    apply {
        forward_by_destmac.apply();
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
        transition parse_ethernet;
    }

    state parse_ethernet {
        pkt.extract(hdr.ethernet);
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
        pkt.emit(hdr.ethernet);
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