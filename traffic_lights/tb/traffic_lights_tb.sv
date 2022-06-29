`timescale 1 ms / 1 ns

module traffic_lights_tb;

parameter BLINK_Y_MS  = 8;
parameter G_BLINK_T   = 4;
parameter RY_MS = 3;

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

logic [15:0] errors  = '0;
logic [2:0] N       = 3'd7;

mailbox #( logic [2:0] ) mb_exp  = new();
mailbox #( logic [2:0] ) mb_real = new();

logic [1:0] flag_ex = '0;
logic [15:0] cnt    = '0;
logic [15:0] r      = '0;
logic [15:0] y      = '0;
logic [15:0] g      = '0;

task configuration();
  logic [1:0] delay;

  while( N > 7'd0 ) 
    begin
      ##1;
      if( flag_ex === 2'd0 )
        begin
          cmd_type_i      <= 0;
          cmd_valid_i     <= 1'b0;
          ##1 cmd_valid_i <= 1'b1;
          ##1 cmd_valid_i <= 1'b0;
      
          delay = $urandom_range(0, 3);
          ##(delay);
          cmd_type_i      <= 4;
          cmd_data_i      <= $urandom_range(1, 7);
          cmd_valid_i     <= 1'b1;
          ##1 cmd_valid_i <= 1'b0;
          r <= cmd_data_i;
          
          delay = $urandom_range(0, 3);
          ##(delay);
          cmd_type_i      <= 5;
          cmd_data_i      <= $urandom_range(1, 7);
          cmd_valid_i     <= 1'b1;
          ##1 cmd_valid_i <= 1'b0;
          y <= cmd_data_i;
          
          delay = $urandom_range(0, 3);
          ##(delay);
          cmd_type_i      <= 3;
          cmd_data_i      <= $urandom_range(1, 7);
          cmd_valid_i     <= 1'b1;
          ##1 cmd_valid_i <= 1'b0;
          g               <= cmd_data_i;
          flag_ex         <= 2'd1;
          ##1;
        end
      else
        begin
          if( flag_ex === 2'd1 )
            begin
              cmd_type_i      <= 0;
              ##1 cmd_valid_i <= 1'b1;
              ##1 cmd_valid_i <= 1'b0;
              flag_ex         <= 2'd2;
            end
          if( flag_ex === 2'd2 )
            begin
              if( cnt !== (2 * RY_MS + G_BLINK_T + r * 2 + y * 2 + g * 2 - 2) )
                cnt <= cnt + 16'd1;
              else
                begin
                  flag_ex         <= 2'd0;
                  N                = N - 3'd1;
                  cnt             <= '0;
                  cmd_type_i      <= 1;
                  cmd_valid_i     <= 1'b1;
                  ##1 cmd_valid_i <= 1'b0;
                end
            end
        end
        
      
    end
endtask

task check_out();
  if( flag_ex === 2'd1 )
    mb_real.put( { red_o, yellow_o, green_o } );
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
    fork
      configuration();
      check_out();
    join
        
    
    
    $stop;
  end

endmodule
