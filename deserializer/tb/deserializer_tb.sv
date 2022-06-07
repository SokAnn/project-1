module deserializer_tb;

logic        clk_i;
logic        srst_i;
logic        data_i;
logic        data_val_i;
logic [15:0] deser_data_o;
logic        deser_data_val_o;

deserializer deserializer
(
  .clk_i            ( clk_i            ),
  .srst_i           ( srst_i           ),
  .data_i           ( data_i           ),
  .data_val_i       ( data_val_i       ),
  .deser_data_o     ( deser_data_o     ),
  .deser_data_val_o ( deser_data_val_o )
);


logic [7:0] errors        = '0;
logic [18:0] test_vectors [50:0];
logic [6:0] num_vector    = '0;

logic [15:0] o_expected;
logic o_val_expected;

initial
  begin
    clk_i = 0;
    forever
      #5 clk_i = ~clk_i;
  end


initial
  begin
    $readmemb("test.tv", test_vectors);
    #25;
    @( posedge clk_i )
    srst_i <= 1'b1;
    @( posedge clk_i )
    srst_i <= 1'b0;
  end

always @( posedge clk_i )
  #1 {data_i, data_val_i, o_expected, o_val_expected} = {test_vectors[num_vector][18], test_vectors[num_vector][17], test_vectors[num_vector][16:1], test_vectors[num_vector][0]};
   
always @( negedge clk_i )
  if( ~srst_i )
    begin
      if( num_vector != 26 )
        begin
          if( deser_data_o !== o_expected )
            begin
              $display("deser_data_o failed (%d)", num_vector);
              errors <= errors + 1;
            end
          if( deser_data_val_o !== o_val_expected )
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
