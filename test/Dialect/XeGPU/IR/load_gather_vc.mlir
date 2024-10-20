// RUN: IMEX_XEGPU_PRINT_DEFAULTS=true imex-opt %s | FileCheck %s
// Verify the printed output can be parsed.
// RUN: IMEX_XEGPU_PRINT_DEFAULTS=true imex-opt %s | IMEX_XEGPU_PRINT_DEFAULTS=true imex-opt | FileCheck %s
// Verify the generic form can be parsed.
// RUN: IMEX_XEGPU_PRINT_DEFAULTS=true imex-opt -mlir-print-op-generic %s | IMEX_XEGPU_PRINT_DEFAULTS=true imex-opt | FileCheck %s


// CHECK-LABEL: func @test_load_gather_vc({{.*}}) {
func.func @test_load_gather_vc(%src: ui64, %offsets : vector<16xindex>) {
  %0 = arith.constant dense<1>: vector<16xi1>
  //CHECK: {{.*}} = xegpu.create_tdesc {{.*}}, {{.*}} : ui64, vector<16xindex>
  //CHECK-SAME: !xegpu.tensor_desc<16xf32, #xegpu.tdesc_attr<scattered = true>>
  %1 = xegpu.create_tdesc %src, %offsets : ui64, vector<16xindex> -> !xegpu.tensor_desc<16xf32, #xegpu.tdesc_attr<scattered = true>>

  // CHECK: {{.*}} = xegpu.load {{.*}}, {{.*}} <{l1_hint = #xegpu.cache_hint<cached>, l2_hint = #xegpu.cache_hint<uncached>}>
  // CHECK-SAME: !xegpu.tensor_desc<16xf32, #xegpu.tdesc_attr<scattered = true>>, vector<16xi1> -> vector<16xf32>
  %2 = xegpu.load %1, %0 {l1_hint = #xegpu.cache_hint<cached>, l2_hint = #xegpu.cache_hint<uncached>}
                : !xegpu.tensor_desc<16xf32, #xegpu.tdesc_attr<scattered = true>>, vector<16xi1> -> vector<16xf32>
  return
}

// CHECK-LABEL: func @test_load_gather_vc_2({{.*}}) {
func.func @test_load_gather_vc_2(%src: ui64, %offsets : vector<16xindex>) {
  %0 = arith.constant dense<1>: vector<16x8xi1>

  //CHECK: {{.*}} = xegpu.create_tdesc {{.*}}, {{.*}} {chunk_size = 8 : i64}
  //CHECK-SAME: ui64, vector<16xindex> -> !xegpu.tensor_desc<16x8xf32, #xegpu.tdesc_attr<scattered = true>>
  %1 = xegpu.create_tdesc %src, %offsets {chunk_size = 8}
                : ui64, vector<16xindex> -> !xegpu.tensor_desc<16x8xf32, #xegpu.tdesc_attr<scattered = true>>

  //CHECK: {{.*}} = xegpu.load {{.*}}, {{.*}} <{l1_hint = #xegpu.cache_hint<cached>, l2_hint = #xegpu.cache_hint<uncached>, transpose = array<i64: 1, 0>}>
  //CHECK-SAME: !xegpu.tensor_desc<16x8xf32, #xegpu.tdesc_attr<scattered = true>>, vector<16x8xi1> -> vector<8x16xf32>
  %2 = xegpu.load %1, %0 {transpose = array<i64: 1, 0>, l1_hint = #xegpu.cache_hint<cached>, l2_hint = #xegpu.cache_hint<uncached>}
               : !xegpu.tensor_desc<16x8xf32, #xegpu.tdesc_attr<scattered = true>>, vector<16x8xi1> -> vector<8x16xf32>
  return
}

// CHECK-LABEL: func @test_load_gather_vc_4({{.*}}) {
func.func @test_load_gather_vc_4(%src: ui64, %offsets : vector<16xindex>) {
  %0 = arith.constant dense<1>: vector<16xi1>

  //CHECK: {{.*}} = xegpu.create_tdesc {{.*}}, {{.*}} : ui64, vector<16xindex> -> !xegpu.tensor_desc<16xf32, #xegpu.tdesc_attr<scattered = true>>
  %1 = xegpu.create_tdesc %src, %offsets {chunk_size = 1}
                : ui64, vector<16xindex> -> !xegpu.tensor_desc<16xf32, #xegpu.tdesc_attr<scattered = true>>

  //CHECK: {{.*}} = xegpu.load {{.*}}, {{.*}} <{l1_hint = #xegpu.cache_hint<cached>, l2_hint = #xegpu.cache_hint<uncached>}>
  //CHECK-SAME: !xegpu.tensor_desc<16xf32, #xegpu.tdesc_attr<scattered = true>>, vector<16xi1> -> vector<16xf32>
  %2 = xegpu.load %1, %0 {l1_hint = #xegpu.cache_hint<cached>, l2_hint = #xegpu.cache_hint<uncached>}
                : !xegpu.tensor_desc<16xf32, #xegpu.tdesc_attr<scattered = true>>, vector<16xi1> -> vector<16xf32>
  return
}
