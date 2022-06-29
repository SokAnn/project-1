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

typedef enum logic [2:0] {OFF_S, RED_S, RED_YELLOW_S, GREEN_S, GREEN_BLINKS_S, YELLOW_S, YELLOW_BLINKS_S} state_type;
state_type state, next_state;

logic red_l, yellow_l, green_l;

logic [15:0] count;
logic state_flag;

logic [15:0] RED_MS;
logic [15:0] YELLOW_MS;
logic [15:0] GREEN_MS;

// state register
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      state <= OFF_S;
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
        if( next_state == RED_S )
          if( count >= (RED_MS * 2 - 1) )
            state_flag <= 1'b0;
          else
            state_flag <= 1'b1;
        else
          if( next_state == RED_YELLOW_S )
            if( count >= (STATE_RY_MS * 2 - 1) )
              state_flag <= 1'b0;
            else
              state_flag <= 1'b1;
        else
          if( next_state == GREEN_S )
            if( count >= (GREEN_MS * 2 - 1) )
              state_flag <= 1'b0;
            else
              state_flag <= 1'b1;
        else
          if( next_state == GREEN_BLINKS_S )
            if( count >= (G_BLINK_T - 1) )
              state_flag <= 1'b0;
            else
              state_flag <= 1'b1;
        else
          if( next_state == YELLOW_S )
            if( count >= (YELLOW_MS * 2 - 1) )
              state_flag <= 1'b0;
            else
              state_flag <= 1'b1;
        else
          if( next_state == YELLOW_BLINKS_S )
            if( count >= (BLINK_Y_MS * 2 - 1) )
              state_flag <= 1'b0;
            else
              state_flag <= 1'b1;
        else
          state_flag <= 1'b0;
      end
  end

always_ff @( posedge clk_i )
  begin
    if( state == YELLOW_BLINKS_S )
      if( cmd_valid_i )
        begin
          if( cmd_type_i == 4 )
            RED_MS <= cmd_data_i;
          else if( cmd_type_i == 5 )
            YELLOW_MS <= cmd_data_i;
          else if( cmd_type_i == 3 )
            GREEN_MS <= cmd_data_i;
        end
  end

// count logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      count <= '0;
    else
      begin
        

        if( next_state == RED_S )
          begin
          if( state == YELLOW_BLINKS_S )
            begin
              if( cmd_valid_i && cmd_type_i == 0 )
                count <= '0 + 1'(1);
            end
          else
            begin
              if( count < (RED_MS * 2 - 1) )
                count <= count + 1'(1);
              else
                count <= '0;
            end
          end
        if( next_state == RED_YELLOW_S )
          if( count < (STATE_RY_MS * 2 - 1) )
            count <= count + 1'(1);
          else
            count <= '0;
        if( next_state == GREEN_S )
          if( count < (GREEN_MS * 2 - 1) )
            count <= count + 1'(1);
          else
            count <= '0;
        if( next_state == GREEN_BLINKS_S )
          if( count < (G_BLINK_T - 1) )
            count <= count + 1'(1);
          else
            count <= '0;
        if( next_state == YELLOW_S )
          if( count < (YELLOW_MS * 2 - 1) )
            count <= count + 1'(1);
          else
            count <= '0;
        if( next_state == YELLOW_BLINKS_S )
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
        if( next_state == RED_S || next_state == RED_YELLOW_S )
          red_l <= 1'b1;
        else
          red_l <= 1'b0;
      end
  end

// yellow_l logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      yellow_l <= 1'b0;
    else
      begin
        if( next_state == YELLOW_S || next_state == RED_YELLOW_S )
          yellow_l <= 1'b1;
        else
          if( next_state == YELLOW_BLINKS_S )
            yellow_l <= !yellow_l;
          else
            yellow_l <= 1'b0;
      end
  end

// green_l logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      green_l <= 1'b0;
    else
      begin
        if( next_state == GREEN_S )
          green_l <= 1'b1;
        else
          if( next_state == GREEN_BLINKS_S )
            green_l <= !green_l;
          else
            green_l <= 1'b0;
      end
  end

// next state logic
always_comb
  begin
    next_state = state;
    case( state )
      OFF_S: 
        begin
          if( (cmd_type_i == 0) && cmd_valid_i && !state_flag )
            next_state = YELLOW_BLINKS_S;
          else if( !state_flag )
            next_state = OFF_S;
        end
      
      YELLOW_BLINKS_S: 
        begin
          //if( (cmd_type_i == 0) && cmd_valid_i && !state_flag )
          if( (cmd_type_i == 0) && cmd_valid_i )
            next_state = RED_S;
          else if( (cmd_type_i == 1) && cmd_valid_i && !state_flag )
            next_state = OFF_S;
        end
      
      RED_S:
        begin
          if( (cmd_type_i == 1) && cmd_valid_i && !state_flag )
            next_state = OFF_S;
          else if( (cmd_type_i == 2) && cmd_valid_i && !state_flag )
            next_state = YELLOW_BLINKS_S;
          else if( !state_flag )
            next_state = RED_YELLOW_S;
        end

      RED_YELLOW_S: 
        begin
          if( (cmd_type_i == 1) && cmd_valid_i && !state_flag )
            next_state = OFF_S;
          else if( (cmd_type_i == 2) && cmd_valid_i && !state_flag )
            next_state = YELLOW_BLINKS_S;
          else if( !state_flag )
            next_state = GREEN_S;
        end

      GREEN_S: 
        begin
          if( (cmd_type_i == 1) && cmd_valid_i && !state_flag )
            next_state = OFF_S;
          else if( (cmd_type_i == 2) && cmd_valid_i && !state_flag )
            next_state = YELLOW_BLINKS_S;
          else if( !state_flag )
            next_state = GREEN_BLINKS_S;
        end

      GREEN_BLINKS_S: 
        begin
          if( (cmd_type_i == 1) && cmd_valid_i && !state_flag )
            next_state = OFF_S;
          else if( (cmd_type_i == 2) && cmd_valid_i && !state_flag )
            next_state = YELLOW_BLINKS_S;
          else if( !state_flag )
            next_state = YELLOW_S;
        end

      YELLOW_S: 
        begin
          if( (cmd_type_i == 1) && cmd_valid_i && !state_flag )
            next_state = OFF_S;
          else if( (cmd_type_i == 2) && cmd_valid_i && !state_flag )
            next_state = YELLOW_BLINKS_S;
          else if( !state_flag )
            next_state = RED_S;
        end

      default: next_state = OFF_S;
    endcase
  end

//output logic
assign red_o    = red_l;
assign yellow_o = yellow_l;
assign green_o  = green_l;

endmodule
