module serializer_tb;

logic        clk_i;
logic        srst_i;

logic [15:0] data_i;
logic [3:0]  data_mod_i;
logic        data_val_i;

logic        ser_data_o;
logic        ser_data_val_o;
logic        busy_o;

logic [4:0]  cnt;
logic [5:0]  task_ex = '0;

serializer serializer_ins (
  .clk_i         ( clk_i          ),
  .srst_i        ( srst_i         ),

  .data_i        ( data_i         ),
  .data_mod_i    ( data_mod_i     ),
  .data_val_i    ( data_val_i     ),

  .ser_data_o    ( ser_data_o     ),
  .ser_data_val_o( ser_data_val_o ),
  .busy_o        ( busy_o         )
);

mailbox #(logic) mb_expected = new();
mailbox #(logic) mb_output   = new();

task generate_data ();
  logic [15:0] buff;

  while( task_ex < 6'd32 )
    begin
      ##1;
      data_val_i <= ( task_ex % 2 ) ? ( 1'b0 ) : ( 1'b1 );
      data_i     <= ( task_ex % 2 ) ? ( 16'hffff ) : ( $urandom() );
      
      if( data_i != 16'hffff )
        buff = data_i;

      if( !busy_o )
        begin
          data_mod_i <= task_ex / 2;
          task_ex    <= task_ex + 6'd1;
          cnt <= 5'd15;
        end
      else
        begin
          if( data_mod_i != 4'd0 )
            begin
              if( cnt != 15 - data_mod_i )
                begin
                  cnt <= cnt - 5'd1;
                  mb_expected.put( buff[cnt] );
                end
            end
          else
            begin
              if( cnt != 5'd0  )
                begin
                  cnt <= cnt - 5'd1;
                  mb_expected.put( buff[cnt] );
                end
              else
                mb_expected.put( buff[cnt] );
            end
        end
    end
endtask

task check_output ();
  forever
    begin
      ##1;
      if( ser_data_val_o )
        mb_output.put( ser_data_o );
    end
endtask

initial 
  begin
    clk_i = 0;
    forever #5 clk_i = ~clk_i;
  end

default clocking cb
  @ (posedge clk_i);
endclocking

logic expected;
logic outpt;
logic [7:0] errors = '0;

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
    
    if( mb_expected.num() != mb_output.num() )
      begin
        $display("Error: mailbox(es) size. ");
        $display("Size mailboxes: ( %d ) ( %d )", mb_expected.num(), mb_output.num());
      end
    else
      begin
        $display("Size mailboxes: ( %d ) ( %d )", mb_expected.num(), mb_output.num());
        while( mb_expected.num() != 0 )
          begin
            mb_expected.get( expected );
            mb_output.get( outpt );
            $display("Expected output : ( %d ) Real output: ( %d )", expected, outpt);
            if( expected != outpt )
              errors = errors + 1;
          end
        $display("Tests completed with ( %d ) errors.", errors);
      end
    $stop;
  end

endmodule
