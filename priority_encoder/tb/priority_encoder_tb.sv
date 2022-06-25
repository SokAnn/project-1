module priority_encoder_tb;

parameter WIDTH = 16;

logic             clk_i;
logic             srst_i;
logic [WIDTH-1:0] data_i;
logic             data_val_i;

logic [WIDTH-1:0] data_left_o;
logic [WIDTH-1:0] data_right_o;
logic             deser_data_val_o;

priority_encoder #(
  .WIDTH            ( WIDTH            )
) priority_encoder (
  .clk_i            ( clk_i            ),
  .srst_i           ( srst_i           ),
  .data_i           ( data_i           ),
  .data_val_i       ( data_val_i       ),

  .data_left_o      ( data_left_o      ),
  .data_right_o     ( data_right_o     ),
  .deser_data_val_o ( deser_data_val_o )
);

logic [7:0] errors  = '0;
logic [5:0] task_ex = '0;

typedef struct {
  logic [WIDTH-1:0] left;
  logic [WIDTH-1:0] right;
} task_t;

mailbox #( task_t ) mb_expected = new();
mailbox #( task_t ) mb_real     = new();

task_t expected, outpt;

task generate_data();
  task_t buff;
  
  while( task_ex < 6'd63 )
    begin
      ##1;
      data_i     <= $urandom_range( 0, ( 2 ** WIDTH - 1 ) );
      data_val_i <= $urandom_range( 0, 1 );
      
      buff.left = '0;
      buff.right = '0;
      if( data_val_i === 1'b1 )
        begin
          for( int i = WIDTH - 1; i >= 0; i-- )
            begin
              if( data_i[i] == 1'b1 )
                begin
                  buff.left[i] = 1'b1;
                  break;
                end
            end
          for( int i = 0; i <= WIDTH - 1; i++ )
            begin
              if( data_i[i] == 1'b1 )
                begin
                  buff.right[i] = 1'b1;
                  break;
                end
            end
          mb_expected.put( buff );
          task_ex <= task_ex + 7'd1;
        end
    end
endtask

task check_output();
  forever
    begin
      ##1;
      if( deser_data_val_o === 1'b1 )
        mb_real.put( { data_left_o, data_right_o } );
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
            $display("Expected output : ( %b )( %b )", expected.left, expected.right);
            $display("Real output:      ( %b )( %b )", outpt.left, outpt.right);
            $display("----------------");
            if( expected !== outpt )
              errors = errors + 1;
          end
        $display("Tests completed with ( %d ) errors.", errors);
      end
    $stop;
  end

endmodule
