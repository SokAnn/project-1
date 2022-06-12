module serializer_tb;

logic        clk_i;
logic        srst_i;

logic [15:0] data_i;
logic [3:0]  data_mod_i;
logic        data_val_i;

logic        ser_data_o;
logic        ser_data_val_o;
logic        busy_o;

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

logic [6:0] errors        = '0;
logic [23:0] test_vectors [50:0];
logic [6:0] num_vector    = '0;
logic [2:0] o_expected;

initial 
  begin
    clk_i = 0;
    forever #5 clk_i = ~clk_i;
  end

initial
  begin
    $readmemb("test.tv", test_vectors);
    #3;
    @( posedge clk_i )
    srst_i <= 1'b1;

    @( posedge clk_i )
    srst_i <= 1'b0;
  end

always @( posedge clk_i )
  {data_i, data_mod_i, data_val_i, o_expected} = {test_vectors[num_vector][23:8], test_vectors[num_vector][7:4], test_vectors[num_vector][3], test_vectors[num_vector][2:0]};
   

always @( negedge clk_i )
  if( !srst_i )
    begin
      if( num_vector != 40 )
        begin
          if( busy_o !== o_expected[0] )
            begin
              $display("busy_o failed (%d)", num_vector);
              errors <= errors + 1;
            end
          if( ser_data_o !== o_expected[1] )
            begin
              $display("ser_data_o failed (%d)", num_vector);
              errors <= errors + 1;
            end
          if( ser_data_val_o !== o_expected[2] )
            begin
              $display("ser_data_val_o failed (%d)", num_vector);
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

endmodule
