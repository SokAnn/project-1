module serializer_tb;

logic        clk_i;
logic        srst_i;

logic [15:0] data_i;
logic [3:0]  data_mod_i;
logic        data_val_i;

logic        ser_data_o;
logic        ser_data_val_o;
logic        busy_o;

bit          srst_done;
logic [4:0]  cnt;
logic        end_flag;

serializer serializer_ins(
  .clk_i         ( clk_i          ),
  .srst_i        ( srst_i         ),

  .data_i        ( data_i         ),
  .data_mod_i    ( data_mod_i     ),
  .data_val_i    ( data_val_i     ),

  .ser_data_o    ( ser_data_o     ),
  .ser_data_val_o( ser_data_val_o ),
  .busy_o        ( busy_o         )

);

mailbox #(logic) mb_expected = new(39);
mailbox #(logic) mb_output   = new(39);

task generate_data ();
  for ( int i = 0; i < 32; i++ )
    ##1 data_i <= ( i % 2 ) ? ( 16'hffff ) : ( $urandom() );
  ##20 end_flag <= 1'b1;
endtask

task generate_mod ();
  for ( int i = 0; i < 16; i++ )
    begin
      ##1;
      data_mod_i <= i;
      ##1;
    end
endtask

task generate_val ();
  for ( int i = 0; i < 32; i++ )
    ##1 data_val_i <= ( i % 2 ) ? ( 1'b0 ) : ( 1'b1 );
endtask


task check_data ();
  logic [3:0] mod;
  
  while( !end_flag )
    begin
      @( posedge clk_i )
      
      if( cnt == 5'd16 )
        begin
        if( data_val_i )
          if( data_mod_i != 4'd1 && data_mod_i != 4'd2 )
            begin
              mod = data_mod_i;
              cnt =  data_mod_i;
              if( data_mod_i != 4'd0 )
                for( int i = 15; i > ( 15 - data_mod_i ); i-- )
                  mb_expected.put( data_i[i] );
              else
                for( int i = 15; i >= 0; i-- )
                  mb_expected.put( data_i[i] );
            end
        end
      else
        if( mod == 0 )
          if( cnt != 5'd16  )
             ##1 cnt = cnt + 5'd1;
          else
             ##1 cnt = 5'd15;
        else
          if( cnt != 5'd1 )
             ##1 cnt = cnt - 5'd1;
          else
             ##1 cnt = 5'd16;
    end
endtask

task check_output ();
  while( !end_flag )
    begin
      @( posedge clk_i )
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

initial
  begin
    srst_i <= 1'b0;
    ##1;
    srst_i <= 1'b1;
    ##1;
    srst_i <= 1'b0;
    cnt = 5'd16;
    srst_done = 1'b1;
    end_flag = 1'b0;
  end


logic expected;
logic outpt;
logic [7:0] errors = '0;

initial
  begin
    wait( srst_done );
    $display("Starting tests...");
    
    fork
      generate_data();
      generate_mod();
      generate_val();
      check_data();
      check_output();
    join
    
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
      end
    $display("Tests completed with ( %d ) errors.", errors);
    $stop;
  end

endmodule
