`ifndef TYPES_SVH
`define TYPES_SVH

typedef struct packed {
  logic [10:0] rect_x;
  logic [9:0] rect_y;
  logic [10:0] rect_x_2;
  logic [9:0] rect_y_2;
  logic [10:0] saber_x;
  logic [9:0] saber_y;
} location_t;

typedef struct packed {
  logic [2:0] health;
  location_t location;
  logic [1:0] saber_state;
  logic [10:0] saber_attack_x;
  logic [9:0] saber_attack_y;
} data_t;

`endif // TYPES_SVH