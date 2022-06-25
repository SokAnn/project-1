module deserializer_tb;

logic        clk_i;
logic        srst_i;
logic        data_i;
logic        data_val_i;
logic [15:0] deser_data_o;
logic        deser_data_val_o;

deserializer deserializer_ins
(
  .clk_i            ( clk_i            ),
  .srst_i           ( srst_i           ),
  .data_i           ( data_i           ),
  .data_val_i       ( data_val_i       ),
  .deser_data_o     ( deser_data_o     ),
  .deser_data_val_o ( deser_data_val_o )
);

logic [7:0]  errors  = '0;
logic [15:0] out_exp = '0;
logic [4:0]  cnt     = '0;
logic [15:0] expected;
logic [15:0] outpt;
logic [8:0]  task_ex = '0;

mailbox #(logic [15:0]) mb_expected = new();
mailbox #(logic [15:0]) mb_real     = new();


task generate_data();
  while( task_ex < 9'd511 )
    begin
      ##1;
      data_i     <= $urandom_range(0, 1);
      data_val_i <= $urandom_range(0, 1);
      task_ex    <= task_ex + 7'd1;
      
      if( data_val_i === 1'b1 )
        begin
          if( cnt !== 5'd16 )
            begin
              cnt <= cnt + 5'd1;
              out_exp[15 - cnt] <= data_i;
            end
          else 
            begin
              cnt <= 5'd1;
              out_exp[15] <= data_i;
              mb_expected.put( out_exp );
            end
          
        end
      else
        begin
          if( cnt === 5'd16 )
            begin
              cnt <= 5'd0;
              mb_expected.put( out_exp );
            end
        end
    end
endtask

task check_output();
  forever
    begin
      ##1;
      if( deser_data_val_o === 1'b1 )
        mb_real.put( deser_data_o );
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
    srst_i <= 1'b0;
    ##1;
    srst_i <= 1'b1;
    ##1;
    srst_i <= 1'b0;
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
