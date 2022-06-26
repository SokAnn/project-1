module bit_population_counter_tb;

parameter WIDTH = 16;

logic                   clk_i;
logic                   srst_i;
logic [WIDTH-1:0]       data_i;
logic                   data_val_i;

logic [$clog2(WIDTH):0] data_o;
logic                   data_val_o;

bit_population_counter #(
  .WIDTH            ( WIDTH            )
) bit_population_counter (
  .clk_i            ( clk_i            ),
  .srst_i           ( srst_i           ),
  .data_i           ( data_i           ),
  .data_val_i       ( data_val_i       ),
  
  .data_o           ( data_o           ),
  .data_val_o       ( data_val_o       )
);

logic [5:0] errors   = '0;
logic [5:0] task_ex  = '0;

logic [$clog2(WIDTH):0] expected;
logic [$clog2(WIDTH):0] outpt;

mailbox #( logic [$clog2(WIDTH):0] ) mb_expected = new();
mailbox #( logic [$clog2(WIDTH):0] ) mb_real     = new();

task generate_data();
  logic [$clog2(WIDTH):0] temp;

  while( task_ex < 6'd63 )
    begin
      ##1;
      data_i     <= $urandom_range( 0, ( 2 ** WIDTH - 1 ) );
      data_val_i <= $urandom_range( 0, 1 );
      
      if( data_val_i === 1'b1 )
        begin
          temp = '0;
          for( int i = WIDTH - 1; i >= 0; i-- )
            begin
              if( data_i[i] == 1'b1 )
                temp = temp + 1;
              else
                continue;
            end
          mb_expected.put( temp );
          task_ex <= task_ex + 7'd1;
        end
    end
endtask

task check_output();
  forever
    begin
      ##1;
      if( data_val_o === 1'b1 )
        mb_real.put( data_o );
    end
endtask

initial
  begin
    clk_i = 0;
    forever
      #5 clk_i = ~clk_i;
  end

default clocking cb
  @ (posedge clk_i);
endclocking

initial
  begin
    srst_i <= 0;
    ##1;
    srst_i <= 1;
    ##1;
    srst_i <= 0;
    
    $display("Starting tests...");
    
    fork
      generate_data();
      check_output();
    join_any
    
    if( mb_expected.num() != mb_real.num() )
      begin
        $display("Error: mailbox(es) size. ");
        $display("Size mailboxes: ( %d ) ( %d )", mb_expected.num(), mb_real.num());
      end
    else
      begin
        $display("Size mailboxes: ( %d ) ( %d )", mb_expected.num(), mb_real.num());
        while( mb_expected.num() != 0 )
          begin
            mb_expected.get( expected );
            mb_real.get( outpt );
            $display("Expected output : ( %b )", expected);
            $display("Real output:      ( %b )", outpt);
            $display("----------------");
            if( expected !== outpt )
              errors = errors + 1;
          end
        $display("Tests completed with ( %d ) errors.", errors);
      end
    
    $stop;
  end
      
endmodule
