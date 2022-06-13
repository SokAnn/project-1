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

logic [8:0]                       errors        = '0;
logic [($clog2(WIDTH)+WIDTH+2):0] test_vectors [50:0];
logic [6:0]                       num_vector    = '0;

logic                             val_expected;
logic [$clog2(WIDTH):0]           o_expected;

initial
  begin
    clk_i = 0;
    forever
      #5 clk_i = ~clk_i;
  end

initial
  begin
    $readmemb("test.tv", test_vectors);
    #7;
    srst_i <= 1;
    @( posedge clk_i )
    srst_i <= 0;
  end

always @( posedge clk_i )
  #1 {data_i, data_val_i, val_expected, o_expected} = { test_vectors[num_vector][$clog2(WIDTH)+WIDTH+2:$clog2(WIDTH)+3], test_vectors[num_vector][$clog2(WIDTH)+2], 
                                                        test_vectors[num_vector][$clog2(WIDTH)+1], test_vectors[num_vector][$clog2(WIDTH):0] };
   
always @( negedge clk_i )
  if( !srst_i )
    begin
      if( num_vector != 20 )
        begin
          if( data_val_o !== val_expected )
            begin
              $display("data_val_o failed (%d)", num_vector);
              errors <= errors + 1;
            end
          if( data_o !== o_expected )
            begin
              $display("data_o failed (%d)", num_vector);
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
