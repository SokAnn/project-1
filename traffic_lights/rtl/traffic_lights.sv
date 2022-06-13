module traffic_lights #(
  parameter BLINK_Y_MS  = 5,
  parameter G_BLINK_T   = 4,
  parameter STATE_RY_MS = 3
)(
  input  logic        clk_i,
  input  logic        srst_i,
  input  logic [2:0]  cmd_type_i,
  input  logic        cmd_valid_i,
  input  logic [15:0] cmd_data_i,

  output logic        red_o,
  output logic        yellow_o,
  output logic        green_o
);

typedef enum logic [2:0] {OFF, RED, RED_YELLOW, GREEN, GREEN_BLINKS, YELLOW, YELLOW_BLINKS} state_type;
state_type state, next_state;

logic red_l, yellow_l, green_l;

logic [15:0] count;
logic state_flag;


// state register
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      state <= OFF;
    else
      state <= next_state;
  end

// state_flag logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      state_flag <= 1'b0;
    else
      begin
        if( next_state == RED  || next_state == YELLOW || next_state == GREEN)
          if( count >= (cmd_data_i * 2 - 1) )
            state_flag <= 1'b0;
          else
            state_flag <= 1'b1;
        else
          if( next_state == RED_YELLOW )
            if( count >= (STATE_RY_MS * 2 - 1) )
              state_flag <= 1'b0;
            else
              state_flag <= 1'b1;
        else
          if( next_state == GREEN_BLINKS )
            if( count >= (G_BLINK_T - 1) )
              state_flag <= 1'b0;
            else
              state_flag <= 1'b1;
        else
          if( next_state == YELLOW_BLINKS )
            if( count >= (BLINK_Y_MS * 2 - 1) )
              state_flag <= 1'b0;
            else
              state_flag <= 1'b1;
        else
          state_flag <= 1'b0;
      end
  end

// count logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      count <= '0;
    else
      begin
        // red/yellow/green state
        if( next_state == RED || next_state == GREEN || next_state == YELLOW )
          if( count < (cmd_data_i * 2 - 1) )
            count <= count + 1'(1);
          else
            count <= '0;

        // red & yellow state
        if( next_state == RED_YELLOW )
          if( count < (STATE_RY_MS * 2 - 1) )
            count <= count + 1'(1);
          else
            count <= '0;

        // green blinks state
        if( next_state == GREEN_BLINKS )
          if( count < (G_BLINK_T - 1) )
            count <= count + 1'(1);
          else
            count <= '0;
        
        // yellow blinks state
        if( next_state == YELLOW_BLINKS )
          if( count < (BLINK_Y_MS * 2 - 1) )
            count <= count + 1'(1);
          else
            count <= '0;
      end
  end

// red_l logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      red_l <= 1'b0;
    else
      begin
        // red/red & yellow state
        if( next_state == RED || next_state == RED_YELLOW )
          red_l <= 1'b1;
        else
          red_l <= 1'b0; // green/green blinks/yellow/yellow blinks/off state
      end
  end

// yellow_l logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      yellow_l <= 1'b0;
    else
      begin
        // red/green/green blinks/off state
        if( next_state == RED || next_state == GREEN || next_state == GREEN_BLINKS || next_state == OFF)
          yellow_l <= 1'b0;
        else
          if( next_state == YELLOW || next_state == RED_YELLOW )
            yellow_l <= 1'b1;  // yellow/red & yellow state
        else
          if( next_state == YELLOW_BLINKS )
            yellow_l <= !yellow_l;  // yellow blinks state
      end
  end

// green_l logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      green_l <= 1'b0;
    else
      begin
        // red/red & yellow/yellow/yellow blinks/off state
        if( next_state == RED || next_state == RED_YELLOW || next_state == YELLOW || next_state == YELLOW_BLINKS || next_state == OFF)
          green_l <= 1'b0;
        else
          if( next_state == GREEN )
            green_l <= 1'b1; // green state
        else
          if( next_state == GREEN_BLINKS )
            green_l <= !green_l; // green blinks state
      end
  end

// next state logic
always_comb
  begin
    next_state = state;
    case( state )
      OFF: 
        begin
          if( (cmd_type_i == 0) && cmd_valid_i && !state_flag )      next_state = RED;
          else if( !state_flag )                                     next_state = OFF;
        end

      RED:
        begin
          if( (cmd_type_i == 1) && cmd_valid_i && !state_flag )      next_state = OFF;
          else if( (cmd_type_i == 2) && cmd_valid_i && !state_flag ) next_state = YELLOW_BLINKS;
          else if( !state_flag )                                     next_state = RED_YELLOW;
        end

      RED_YELLOW: 
        begin
          if( (cmd_type_i == 1) && cmd_valid_i && !state_flag )      next_state = OFF;
          else if( (cmd_type_i == 2) && cmd_valid_i && !state_flag ) next_state = YELLOW_BLINKS;
          else if( (cmd_type_i == 3) && cmd_valid_i && !state_flag ) next_state = GREEN;
        end

      GREEN: 
        begin
          if( (cmd_type_i == 1) && cmd_valid_i && !state_flag )      next_state = OFF;
          else if( (cmd_type_i == 2) && cmd_valid_i && !state_flag ) next_state = YELLOW_BLINKS;
          else if( !state_flag )                                     next_state = GREEN_BLINKS;
        end

      GREEN_BLINKS: 
        begin
          if( (cmd_type_i == 1) && cmd_valid_i && !state_flag )      next_state = OFF;
          else if( (cmd_type_i == 2) && cmd_valid_i && !state_flag ) next_state = YELLOW_BLINKS;
          else if( (cmd_type_i == 4) && cmd_valid_i && !state_flag ) next_state = YELLOW;
        end

      YELLOW: 
        begin
          if( (cmd_type_i == 1) && cmd_valid_i && !state_flag )      next_state = OFF;
          else if( (cmd_type_i == 2) && cmd_valid_i && !state_flag ) next_state = YELLOW_BLINKS;
          else if( (cmd_type_i == 5) && cmd_valid_i && !state_flag ) next_state = RED;
        end

      YELLOW_BLINKS: 
        begin
          if( (cmd_type_i == 0) && cmd_valid_i && !state_flag )      next_state = RED;
          else if( (cmd_type_i == 1) && cmd_valid_i && !state_flag ) next_state = OFF;
        end
      
      default:                                                       next_state = OFF;
    endcase
  end

//output logic
assign red_o    = red_l;
assign yellow_o = yellow_l;
assign green_o  = green_l;

endmodule
