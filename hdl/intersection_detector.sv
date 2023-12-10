`timescale 1ns / 1ps
`default_nettype none
`include "hdl/types.svh"

module intersection_detector(
    input wire [10:0] saber_start_x,
    input wire [9:0] saber_start_y,
    input wire [10:0] saber_current_x,
    input wire [9:0] saber_current_y,
    input location_t opponent,
    output logic is_intersecting
  );

  logic [3:0] intersecting_sides;
  logic [2:0] num_intersections;

  line_segment_intersection_detector #(
    .IS_HORIZONTAL(1)
  ) lsid_top (
    .start_x(saber_start_x),
    .start_y(saber_start_y),
    .end_x(saber_current_x),
    .end_y(saber_current_y),
    .const_coord(opponent.rect_y),
    .other_coord_1(opponent.rect_x_2),
    .other_coord_2(opponent.rect_x),
    .is_intersecting(intersecting_sides[3])
  );
  line_segment_intersection_detector #(
    .IS_HORIZONTAL(0)
  ) lsid_right (
    .start_x(saber_start_x),
    .start_y(saber_start_y),
    .end_x(saber_current_x),
    .end_y(saber_current_y),
    .const_coord(opponent.rect_x_2),
    .other_coord_1(opponent.rect_y_2),
    .other_coord_2(opponent.rect_y),
    .is_intersecting(intersecting_sides[2])
  );
  line_segment_intersection_detector #(
    .IS_HORIZONTAL(1)
  ) lsid_bottom (
    .start_x(saber_start_x),
    .start_y(saber_start_y),
    .end_x(saber_current_x),
    .end_y(saber_current_y),
    .const_coord(opponent.rect_y_2),
    .other_coord_1(opponent.rect_x_2),
    .other_coord_2(opponent.rect_x),
    .is_intersecting(intersecting_sides[1])
  );
  line_segment_intersection_detector #(
    .IS_HORIZONTAL(0)
  ) lsid_left (
    .start_x(saber_start_x),
    .start_y(saber_start_y),
    .end_x(saber_current_x),
    .end_y(saber_current_y),
    .const_coord(opponent.rect_x),
    .other_coord_1(opponent.rect_y_2),
    .other_coord_2(opponent.rect_y),
    .is_intersecting(intersecting_sides[0])
  );

  always_comb begin
    is_intersecting = 1'b0;
    num_intersections = intersecting_sides[0] + intersecting_sides[1] + intersecting_sides[2] + intersecting_sides[3];
    if (num_intersections >= 2) begin
      is_intersecting = 1'b1;
    end
  end
endmodule

module line_segment_intersection_detector(
    // Saber line segment
    input wire [10:0] start_x,
    input wire [9:0] start_y,
    input wire [10:0] end_x,
    input wire [9:0] end_y,
    // Box side line segment
    input wire [10:0] const_coord,
    input wire [10:0] other_coord_1,
    input wire [10:0] other_coord_2,
    output logic is_intersecting
  );
  parameter IS_HORIZONTAL = 1;

  logic sign_cp_1;
  logic sign_cp_2;

  cross_product cp_1(
    .start_x_1(start_x),
    .start_y_1(start_y),
    .end_x_1(IS_HORIZONTAL? other_coord_1: const_coord),
    .end_y_1(IS_HORIZONTAL? const_coord: other_coord_1),
    .start_x_2(start_x),
    .start_y_2(start_y),
    .end_x_2(end_x),
    .end_y_2(end_y),
    .cross_is_positive(sign_cp_1)
  );

  cross_product cp_2(
    .start_x_1(start_x),
    .start_y_1(start_y),
    .end_x_1(IS_HORIZONTAL? other_coord_2: const_coord),
    .end_y_1(IS_HORIZONTAL? const_coord: other_coord_2),
    .start_x_2(start_x),
    .start_y_2(start_y),
    .end_x_2(end_x),
    .end_y_2(end_y),
    .cross_is_positive(sign_cp_2)
  );

  always_comb begin
    if (IS_HORIZONTAL) begin
      is_intersecting = (const_coord < start_y && const_coord > end_y
              || const_coord > start_y && const_coord < end_y);
    end else begin
      is_intersecting = (const_coord < start_x && const_coord > end_x
              || const_coord > start_x && const_coord < end_x);
    end
    is_intersecting = is_intersecting && sign_cp_1 != sign_cp_2;
  end

endmodule

module cross_product(
    // vector_1
    input wire [10:0] start_x_1,
    input wire [9:0] start_y_1,
    input wire [10:0] end_x_1,
    input wire [9:0] end_y_1,
    // vector_2
    input wire [10:0] start_x_2,
    input wire [9:0] start_y_2,
    input wire [10:0] end_x_2,
    input wire [9:0] end_y_2,

    output logic cross_is_positive
  );
  // Compute vector_1 x vector_2's sign
  logic signed [11:0] start_x_1_s;
  logic signed [11:0] start_y_1_s;
  logic signed [11:0] end_x_1_s;
  logic signed [11:0] end_y_1_s;
  // vector_2
  logic signed [11:0] start_x_2_s;
  logic signed [11:0] start_y_2_s;
  logic signed [11:0] end_x_2_s;
  logic signed [11:0] end_y_2_s;

  logic signed [12:0] delta_x_1_s;
  logic signed [12:0] delta_y_1_s;
  logic signed [12:0] delta_x_2_s;
  logic signed [12:0] delta_y_2_s;

  logic signed [25:0] x_1_y_2_s;
  logic signed [25:0] x_2_y_1_s;

  always_comb begin
    start_x_1_s = $signed({1'b0, start_x_1});
    start_y_1_s = $signed({1'b0, start_y_1});
    end_x_1_s = $signed({1'b0, end_x_1});
    end_y_1_s = $signed({1'b0, end_y_1});
    start_x_2_s = $signed({1'b0, start_x_2});
    start_y_2_s = $signed({1'b0, start_y_2});
    end_x_2_s = $signed({1'b0, end_x_2});
    end_y_2_s = $signed({1'b0, end_y_2});

    delta_x_1_s = $signed(end_x_1_s - start_x_1_s);
    delta_y_1_s = $signed(end_y_1_s - start_y_1_s);
    delta_x_2_s = $signed(end_x_2_s - start_x_2_s);
    delta_y_2_s = $signed(end_y_2_s - start_y_2_s);

    x_1_y_2_s = delta_x_1_s * delta_y_2_s;
    x_2_y_1_s = delta_x_2_s * delta_y_1_s;

    cross_is_positive = (x_1_y_2_s > x_2_y_1_s);
  end
endmodule

`default_nettype wire
