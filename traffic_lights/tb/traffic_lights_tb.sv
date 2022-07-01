`timescale 1 ms / 1 ns

module traffic_lights_tb;

parameter BLINK_Y_MS = 8;
parameter G_BLINK_T  = 4;
parameter RY_MS      = 3;
parameter LOOP_SIZE  = 7;

logic        clk_i;
logic        srst_i;
logic [2:0]  cmd_type_i;
logic        cmd_valid_i;
logic [15:0] cmd_data_i;

logic        red_o;
logic        yellow_o;
logic        green_o;

traffic_lights #(
  .BLINK_Y_MS  ( BLINK_Y_MS  ),
  .G_BLINK_T   ( G_BLINK_T   ),
  .STATE_RY_MS ( RY_MS )
) traffic_lights (
  .clk_i       ( clk_i       ),
  .srst_i      ( srst_i      ),
  .cmd_type_i  ( cmd_type_i  ),
  .cmd_valid_i ( cmd_valid_i ),
  .cmd_data_i  ( cmd_data_i  ),

  .red_o       ( red_o       ),
  .yellow_o    ( yellow_o    ),
  .green_o     ( green_o     )
);

logic [15:0] errors = '0;
logic [15:0] cnt    = '0;
logic [15:0] r      = '0;
logic [15:0] y      = '0;
logic [15:0] g      = '0;


task configuration( logic [2:0] _cmd_type, logic [15:0] _data );
  cmd_type_i <= _cmd_type;
  cmd_data_i <= _data;
  if( _cmd_type === 3'd4 || _cmd_type === 3'd5 || _cmd_type === 3'd3 )
    begin
      case( _cmd_type )
        3'd4: r <= _data;
        3'd5: y <= _data;
        3'd3: g <= _data;
      endcase
    end
  cmd_valid_i <= 1'b1;
  ##1 cmd_valid_i <= 1'b0;
endtask

task check_out( logic [15:0] _data , logic [1:0] _color );
  while( cnt < ( r * 2 ) )
    begin
      if( red_o !== 1'b1 )
        errors = errors + 1'(1);
      cnt = cnt + 16'd1;
      ##1;
    end
  cnt = '0;
  ##( RY_MS * 2 );
  while( cnt < ( g * 2 ) )
    begin
      if( green_o !== 1'b1 )
        errors = errors + 1'(1);
      cnt = cnt + 16'd1;
      ##1;
    end
  cnt = '0;
  ##( G_BLINK_T );
  while( cnt < ( y * 2 ) )
    begin
      if( yellow_o !== 1'b1 )
        errors = errors + 1'(1);
      cnt = cnt + 16'd1;
      ##1;
    end
  cnt = '0;
endtask

initial
  begin
    clk_i = 0;
    forever
      #0.25 clk_i = !clk_i;
  end

default clocking cb
  @ (posedge clk_i);
endclocking

initial
  begin
    srst_i <= 1'b0;
    ##1;
    srst_i <= 1'b1;
    ##1;
    srst_i <= 1'b0;
    
    $display("Starting tests...");
    repeat( LOOP_SIZE )
      begin
        configuration( 3'd0, $urandom_range(1, 10) );
        configuration( 3'd4, $urandom_range(1, 10) );
        configuration( 3'd5, $urandom_range(1, 10) );
        configuration( 3'd3, $urandom_range(1, 10) );
        configuration( 3'd0, $urandom_range(1, 10) );      

        check_out( r, 2'd0 );

        configuration( 3'd1, $urandom_range(1, 15) );
      end
    $display("Tests completed with ( %d ) errors.", errors );
    $stop;
  end

endmodule
