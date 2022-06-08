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
  if( srst_i )
    begin
      state      <= OFF;
      count      <= '0;
      state_flag <= 1'b0;
    end
  else
    //if( cmd_valid_i )
      begin
        state      <= next_state;
        count      <= '0;
        state_flag <= 1'b1;
      end

// next state logic
always_comb
  begin
    if( !state_flag  )
      case( state )
        OFF: 
          begin
            if( cmd_type_i == 0 & cmd_valid_i)      next_state = RED;
          end

        RED:
          begin
            if( cmd_type_i == 1 & cmd_valid_i)      next_state = OFF;
            else if( cmd_type_i == 2 & cmd_valid_i) next_state = YELLOW_BLINKS;
            else                                    next_state = RED_YELLOW;
          end

        RED_YELLOW: 
          begin
            if( cmd_type_i == 1 & cmd_valid_i)      next_state = OFF;
            else if( cmd_type_i == 2 & cmd_valid_i) next_state = YELLOW_BLINKS;
            else if( cmd_type_i == 3 & cmd_valid_i) next_state = GREEN;
          end

        GREEN: 
          begin
            if( cmd_type_i == 1 & cmd_valid_i)      next_state = OFF;
            else if( cmd_type_i == 2 & cmd_valid_i) next_state = YELLOW_BLINKS;
            else                                    next_state = GREEN_BLINKS;
          end

        GREEN_BLINKS: 
          begin
            if( cmd_type_i == 1 & cmd_valid_i)      next_state = OFF;
            else if( cmd_type_i == 2 & cmd_valid_i) next_state = YELLOW_BLINKS;
            else if( cmd_type_i == 4 & cmd_valid_i) next_state = YELLOW;
          end

        YELLOW: 
          begin
            if( cmd_type_i == 1 & cmd_valid_i)      next_state = OFF;
            else if( cmd_type_i == 2 & cmd_valid_i) next_state = YELLOW_BLINKS;
            else if( cmd_type_i == 5 & cmd_valid_i) next_state = RED;
          end

        YELLOW_BLINKS: 
          begin
            if( cmd_type_i == 0 & cmd_valid_i)      next_state = RED;
            else if( cmd_type_i == 1 & cmd_valid_i) next_state = OFF;
          end
      
        default:                                    next_state = OFF;
      endcase
  end

// RED
always_ff @( posedge clk_i )
  if( next_state == RED )
    begin
      if( count < (cmd_data_i * 2 - 1) )
        begin
          count    <= count + 1;
          red_l    <= 1'b1;
          yellow_l <= 1'b0;
          green_l  <= 1'b0;
        end
      else
        begin
          count      <= '0;
          state      <= next_state;
          state_flag <= 1'b0;
        end
    end

// RED_YELLOW
always_ff @( posedge clk_i )
  if( next_state == RED_YELLOW )
    begin
      if( count < (STATE_RY_MS * 2 - 1) )
        begin
          count    <= count + 1;
          red_l    <= 1'b1;
          yellow_l <= 1'b1;
          green_l  <= 1'b0;
        end
      else
        begin
          count      <= '0;
          state      <= next_state;
          state_flag <= 1'b0;
        end
    end

// GREEN
always_ff @( posedge clk_i )
  if( next_state == GREEN )
    begin
      if( count < (cmd_data_i * 2 - 1) )
        begin
          count    <= count + 1;
          red_l    <= 1'b0;
          yellow_l <= 1'b0;
          green_l  <= 1'b1;
        end
      else
        begin
          count      <= '0;
          state      <= next_state;
          state_flag <= 1'b0;
        end
    end

// GREEN_BLINKS
always_ff @( posedge clk_i )
  if( next_state == GREEN_BLINKS )
    begin
      if( count < (G_BLINK_T - 1) )
        begin
          count    <= count + 1;
          red_l    <= 1'b0;
          yellow_l <= 1'b0;
          green_l  <= ~green_l;
        end
      else
        begin
          green_l  <= ~green_l;
          count      <= '0;
          state      <= next_state;
          state_flag <= 1'b0;
        end
    end

// YELLOW
always_ff @( posedge clk_i )
  if( next_state == YELLOW )
    begin
      if( count < (cmd_data_i * 2 - 1) )
        begin
          count    <= count + 1;
          red_l    <= 1'b0;
          yellow_l <= 1'b1;
          green_l  <= 1'b0;
        end
      else
        begin
          count      <= '0;
          state      <= next_state;
          state_flag <= 1'b0;
        end
    end

// YELLOW_BLINKS
always_ff @( posedge clk_i )
  if( next_state == YELLOW_BLINKS )
    begin
      if( count < (BLINK_Y_MS * 2 - 1) )
        begin
          count    <= count + 1;
          red_l    <= 1'b0;
          yellow_l <= ~yellow_l;
          green_l  <= 1'b0;
        end
      else
        begin
          yellow_l <= ~yellow_l;
          count      <= '0;
          state      <= next_state;
          state_flag <= 1'b0;
        end
    end

// output logic
assign red_o    = red_l;
assign yellow_o = yellow_l;
assign green_o  = green_l;

endmodule
