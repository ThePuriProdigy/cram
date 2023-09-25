// TABLE_SIZE_SET_<n>  #stages  SRAM_blocks  TCAM_blocks
//                 1     18        646          24
//                 2     19        836          30
//                 3    failed to fit -- needed 21 stages > 20 (also needed bst_index_t to be bit<17> for large binary tree tables)

#ifdef TABLE_SIZE_SET_0
#define PREFIX_SET_SIZE           
#define INITIAL_LOOKUP_TABLE_SIZE 7463
#define BST_0_SIZE                7408
#define BST_1_SIZE                14816
#define BST_2_SIZE                19770
#define BST_3_SIZE                21588
#define BST_4_SIZE                22994
#define BST_5_SIZE                26626
#define BST_6_SIZE                35276
#define BST_7_SIZE                46774
#define BST_8_SIZE                47162
#define BST_9_SIZE                42160
#define BST_10_SIZE               39140
#define BST_11_SIZE               40942
#define BST_12_SIZE               23448
#define BST_13_SIZE               8464
#endif  // TABLE_SIZE_SET_0

#ifdef TABLE_SIZE_SET_1
#define PREFIX_SET_SIZE           247534
#define INITIAL_LOOKUP_TABLE_SIZE 12278
#define BST_0_SIZE                12206
#define BST_1_SIZE                24412
#define BST_2_SIZE                28572
#define BST_3_SIZE                29902
#define BST_4_SIZE                32810
#define BST_5_SIZE                39280
#define BST_6_SIZE                48292
#define BST_7_SIZE                58586
#define BST_8_SIZE                58082
#define BST_9_SIZE                53284
#define BST_10_SIZE               46298
#define BST_11_SIZE               43492
#define BST_12_SIZE               23448
#define BST_13_SIZE               8464
#endif  // TABLE_SIZE_SET_1

#ifdef TABLE_SIZE_SET_2
#define PREFIX_SET_SIZE           389270
#define INITIAL_LOOKUP_TABLE_SIZE 14925
#define BST_0_SIZE                14816
#define BST_1_SIZE                29632
#define BST_2_SIZE                39540
#define BST_3_SIZE                43176
#define BST_4_SIZE                45988
#define BST_5_SIZE                53252
#define BST_6_SIZE                70552
#define BST_7_SIZE                93548
#define BST_8_SIZE                94324
#define BST_9_SIZE                84320
#define BST_10_SIZE               78280
#define BST_11_SIZE               81884
#define BST_12_SIZE               46896
#define BST_13_SIZE               16928
#endif  // TABLE_SIZE_SET_2

#ifdef TABLE_SIZE_SET_3
#define PREFIX_SET_SIZE           442152
#define INITIAL_LOOKUP_TABLE_SIZE 19647
#define BST_0_SIZE                19524
#define BST_1_SIZE                39048
#define BST_2_SIZE                48404
#define BST_3_SIZE                51476
#define BST_4_SIZE                55866
#define BST_5_SIZE                65736
#define BST_6_SIZE                83762
#define BST_7_SIZE                105280
#define BST_8_SIZE                105148
#define BST_9_SIZE                95482
#define BST_10_SIZE               85448
#define BST_11_SIZE               84580
#define BST_12_SIZE               46896
#define BST_13_SIZE               16928
#endif  // TABLE_SIZE_SET_3

#ifdef TABLE_SIZE_SET_4
#define PREFIX_SET_SIZE           583905
#define INITIAL_LOOKUP_TABLE_SIZE 22387
#define BST_0_SIZE                22224
#define BST_1_SIZE                44448
#define BST_2_SIZE                59310
#define BST_3_SIZE                64764
#define BST_4_SIZE                68982
#define BST_5_SIZE                79878
#define BST_6_SIZE                105828
#define BST_7_SIZE                140322
#define BST_8_SIZE                141486
#define BST_9_SIZE                126480
#define BST_10_SIZE               117420
#define BST_11_SIZE               122826
#define BST_12_SIZE               70344
#define BST_13_SIZE               25392
#endif  // TABLE_SIZE_SET_4

#ifdef TABLE_SIZE_SET_5
#define PREFIX_SET_SIZE           636743
#define INITIAL_LOOKUP_TABLE_SIZE 27004
#define BST_0_SIZE                26826
#define BST_1_SIZE                53652
#define BST_2_SIZE                68032
#define BST_3_SIZE                73006
#define BST_4_SIZE                78698
#define BST_5_SIZE                92522
#define BST_6_SIZE                118900
#define BST_7_SIZE                152078
#define BST_8_SIZE                152284
#define BST_9_SIZE                137838
#define BST_10_SIZE               124620
#define BST_11_SIZE               125758
#define BST_12_SIZE               70344
#define BST_13_SIZE               25392
#endif  // TABLE_SIZE_SET_5
