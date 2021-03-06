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

logic yellow_l, green_l;

logic [16:0] count;
logic [16:0] red_ms;
logic [16:0] yellow_ms;
logic [16:0] green_ms;

localparam RY_T = STATE_RY_MS * 2 - 1;
localparam YB_T = BLINK_Y_MS * 2 - 1;

// state register
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      state <= OFF_S;
    else
      state <= next_state;
  end

always_ff @( posedge clk_i )
  begin
    if( state == YELLOW_BLINKS_S )
      if( cmd_valid_i )
        begin
          if( cmd_type_i == 4 )
            red_ms    <= cmd_data_i * 2'd2 - 1'(1);
          else if( cmd_type_i == 5 )
            yellow_ms <= cmd_data_i * 2'd2 - 1'(1);
          else if( cmd_type_i == 3 )
            green_ms  <= cmd_data_i * 2'd2 - 1'(1);
        end
  end

// count logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      count <= '0;
    else
      begin
        case( state )
          RED_S:
            begin
              if( count < ( red_ms ) )
                count <= count + 1'(1);
              else
                count <= '0;
            end

          RED_YELLOW_S:
            begin
              if( count < ( RY_T ) )
                count <= count + 1'(1);
              else
                count <= '0;
            end

          GREEN_S:
            begin
              if( count < ( green_ms ) )
                count <= count + 1'(1);
              else
                count <= '0;
            end

          GREEN_BLINKS_S:
            begin
              if( count < ( G_BLINK_T - 1 ) )
                count <= count + 1'(1);
              else
                count <= '0;
            end

          YELLOW_S:
            begin
              if( count < ( yellow_ms ) )
                count <= count + 1'(1);
              else
                count <= '0;
            end

          YELLOW_BLINKS_S:
            begin
              if( next_state == RED_S )
                count <= '0;
              else
                if( count < ( YB_T ) )
                  count <= count + 1'(1);
                else
                  count <= '0;
            end
        endcase
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
          if( ( cmd_type_i == 0 ) && cmd_valid_i )
            next_state = YELLOW_BLINKS_S;
          else
            next_state = OFF_S;
        end
      
      YELLOW_BLINKS_S: 
        begin
          if( ( cmd_type_i == 0 ) && cmd_valid_i )
            next_state = RED_S;
          else if( ( cmd_type_i == 1 ) && cmd_valid_i )
            next_state = OFF_S;
        end
      
      RED_S:
        begin
          if( ( cmd_type_i == 1 ) && cmd_valid_i )
            next_state = OFF_S;
          else if( ( cmd_type_i == 2 ) && cmd_valid_i )
            next_state = YELLOW_BLINKS_S;
          else if( count >= ( red_ms ) )
            next_state = RED_YELLOW_S;
        end

      RED_YELLOW_S: 
        begin
          if( ( cmd_type_i == 1 ) && cmd_valid_i )
            next_state = OFF_S;
          else if( ( cmd_type_i == 2 ) && cmd_valid_i )
            next_state = YELLOW_BLINKS_S;
          else if( count >= ( RY_T ) )
            next_state = GREEN_S;
        end

      GREEN_S: 
        begin
          if( ( cmd_type_i == 1 ) && cmd_valid_i )
            next_state = OFF_S;
          else if( ( cmd_type_i == 2 ) && cmd_valid_i )
            next_state = YELLOW_BLINKS_S;
          else if( count >= ( green_ms ) )
            next_state = GREEN_BLINKS_S;
        end

      GREEN_BLINKS_S: 
        begin
          if( ( cmd_type_i == 1 ) && cmd_valid_i )
            next_state = OFF_S;
          else if( ( cmd_type_i == 2 ) && cmd_valid_i )
            next_state = YELLOW_BLINKS_S;
          else if( count >= ( G_BLINK_T - 1 ) )
            next_state = YELLOW_S;
        end

      YELLOW_S: 
        begin
          if( ( cmd_type_i == 1 ) && cmd_valid_i )
            next_state = OFF_S;
          else if( ( cmd_type_i == 2 ) && cmd_valid_i )
            next_state = YELLOW_BLINKS_S;
          else if( count >= ( yellow_ms ) )
            next_state = RED_S;
        end

      default: next_state = OFF_S;
    endcase
  end

//output logic
assign red_o = ( state == RED_S || state == RED_YELLOW_S );
assign yellow_o = yellow_l;
assign green_o  = green_l;

endmodule