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

logic [7:0] errors        = '0;
logic [2*WIDTH:0] test_vectors [50:0];
logic [6:0] num_vector    = '0;

logic [WIDTH-1:0] left_expected;
logic [WIDTH-1:0] right_expected;
logic        val_expected;

initial
  begin
    clk_i = 0;
    forever
      #5 clk_i = ~clk_i;
  end

initial
  begin
    $readmemb("test.tv", test_vectors);
    #27;
    srst_i <= 1;
    @( posedge clk_i )
    srst_i <= 0;
    // example
    data_val_i <= 0;
    data_i     <= 'b0000_1000_0100_0000;
    @( posedge clk_i )
    data_val_i <= 1;
    @( posedge clk_i )
    data_val_i <= 0;  
  end

always @( posedge clk_i )
  #1 {left_expected, right_expected, val_expected} = {test_vectors[num_vector][2*WIDTH:WIDTH+2], test_vectors[num_vector][WIDTH+1:1], test_vectors[num_vector][0]};
   
always @( negedge clk_i )
  if( !srst_i )
    begin
      if( num_vector != 6 )
        begin
          if( data_left_o !== left_expected )
            begin
              $display("data_left_o failed (%d)", num_vector);
              errors <= errors + 1;
            end
          if( data_right_o !== right_expected )
            begin
              $display("data_right_o failed (%d)", num_vector);
              errors <= errors + 1;
            end
          if( deser_data_val_o !== val_expected )
            begin
              $display("deser_data_val_o failed (%d)", num_vector);
              errors <= errors + 1;
            end
          num_vector <= num_vector + 1;
        end
      else
        begin
          $display("%d tests completed with %d errors", num_vector, errors);
          $finish;
        end
    end

endmodule
