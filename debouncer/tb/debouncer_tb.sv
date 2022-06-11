`timescale 1 ns / 10 ps

module debouncer_tb;

parameter CLK_FREQ_MHZ   = 10;
parameter GLITCH_TIME_NS = 500;

logic clk_i;
logic key_i;

logic key_pressed_stb_o;

debouncer #(
  .CLK_FREQ_MHZ      ( CLK_FREQ_MHZ      ),
  .GLITCH_TIME_NS    ( GLITCH_TIME_NS    )
) debouncer (
  .clk_i             ( clk_i             ),
  .key_i             ( key_i             ),

  .key_pressed_stb_o ( key_pressed_stb_o )
);

logic [1:0] test_vectors [50:0];
logic [4:0] errors         = '0;
logic [4:0] num_vector     = '0;

logic o_expected;

initial
  begin
    $readmemb("test.tv", test_vectors);
    clk_i = 0;
    forever
      #( 1000 / CLK_FREQ_MHZ / 2) clk_i = !clk_i;
  end

always @( posedge clk_i )
  #1 {key_i, o_expected} = {test_vectors[num_vector][1], test_vectors[num_vector][0]};

always @( negedge clk_i )
  begin
    if( num_vector != 24 )
      begin
        if( key_pressed_stb_o != o_expected )
          begin
            $display("output failed (%d)", num_vector);
            errors <= errors + 1;
          end
        num_vector <= num_vector + 1;
      end
    else
      begin
        $display("%d tests completed with %d errors", num_vector, errors);
        $stop;
      end
  end


/*initial
  begin
  key_i <= 0;   #50;
  key_i <= 1;   #100;
  key_i <= 0;   #100;
  key_i <= 1;   #100;
  key_i <= 0;   #100;
  key_i <= 1;   #700;
  key_i <= 0;
  #500;
  key_i <= 1;
  //$stop;
  end*/

endmodule
