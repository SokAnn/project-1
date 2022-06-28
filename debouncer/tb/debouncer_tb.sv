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

logic [5:0] errors  = '0;
logic [7:0] task_ex = '0;
logic       expected;
logic       real_out;

logic [$clog2(GLITCH_TIME_NS):0] cnt = '0;

mailbox #( logic ) mb_exp  = new();
mailbox #( logic ) mb_real = new();

logic temp_out = 1'b0;

parameter WAIT_TICK = GLITCH_TIME_NS / (1000 / CLK_FREQ_MHZ);

task gen_data();
  logic temp;

  while( task_ex < 8'd254 )
    begin
      ##1;
      key_i <= $urandom_range(0, 1);
      temp  <= key_i;

      if( temp === key_i )
        begin
          cnt <= cnt + ($clog2(GLITCH_TIME_NS))'(1);
          if( cnt === ( WAIT_TICK - 2 ) )
            temp_out = 1'b1;
          else
            temp_out = 1'b0;
        end
      else
        begin
          cnt <= '0;
          temp_out = 1'b0;
        end
      mb_exp.put( temp_out );
      task_ex <= task_ex + 8'd1;
    end
endtask

task check_output();
  forever
    begin
      ##1;
      mb_real.put( key_pressed_stb_o );
    end
endtask

initial
  begin
    clk_i = 0;
    forever
      #( 1000 / CLK_FREQ_MHZ / 2) clk_i = !clk_i;
  end

default clocking cb
  @ (posedge clk_i);
endclocking

initial
  begin
    $display("Starting tests...");
    
    fork
      gen_data();
      check_output();
    join_any
    
    if( mb_exp.num() != mb_real.num() )
      begin
        $display("Error: mailbox(es) size. ");
        $display("Size mailboxes: ( %d ) ( %d )", mb_exp.num(), mb_real.num());
      end
    else
      begin
        $display("Size mailboxes: ( %d ) ( %d )", mb_exp.num(), mb_real.num());
        while( mb_exp.num() != 0 )
          begin
            mb_exp.get( expected );
            mb_real.get( real_out );
            //$display("Expected/Real output : ( %b )( %b )", expected, real_out);
            if( expected !== real_out )
              errors = errors + 1;
          end
        $display("Tests completed with ( %d ) errors.", errors);
      end
    $stop; 
  end

endmodule
