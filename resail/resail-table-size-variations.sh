#! /bin/bash

# Note: All values of HASH_TABLE_SIZE below are 25% larger than the
# desired number of prefixes to be installed, to account for 80% hash
# table utilization.

# Combinations of INITIAL_LOOKUP_TABLE_SIZE and HASH_TABLE_SIZE to try:
# I     H        #stages  SRAM_blocks  TCAM_blocks
#  801, 1167053    16        750          17
# 1291, 1876612    18        904          18
# 1722, 2502158    19       1040          19
# 1829, 2658513    20       1074          19
# 1935, 2814902    20       1108          19
# 2042, 2971274    failed to fit -- needed 21 stages > 20
# 2150, 3127652    failed to fit -- needed 21 stages > 20
# 2580, 3753205
# 3009, 4378737

I=801
H=1167053
#I=1291
#H=1876612
#I=1722
#H=2502158
#I=1829
#H=2658513
#I=1935
#H=2814902
#I=2042
#H=2971274
#I=2150
#H=3127652
#I=2580
#H=3753205
#I=3009
#H=4378737

compile-tofino2.sh \
    resail_ipv4.p4 \
    -DINITIAL_LOOKUP_TABLE_SIZE=${I} \
    -DHASH_TABLE_SIZE=${H}
