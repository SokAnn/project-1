module traffic_lights_tb;

logic        clk_i;
logic        srst_i;
logic [2:0]  cmd_type_i;
logic        cmd_valid_i;
logic [15:0] cmd_data_i;

logic        red_o;
logic        yellow_o;
logic        green_o;

traffic_lights traffic_lights (
  .clk_i       ( clk_i       ),
  .srst_i      ( srst_i      ),
  .cmd_type_i  ( cmd_type_i  ),
  .cmd_valid_i ( cmd_valid_i ),
  .cmd_data_i  ( cmd_data_i  ),

  .red_o       ( red_o       ),
  .yellow_o    ( yellow_o    ),
  .green_o     ( green_o     )
);

logic [22:0] test_vectors [50:0];
logic [8:0] errors         = '0;
logic [6:0] num_vector      = '0;

logic r_expected, y_expected, g_expected;

initial
  begin
    clk_i = 0;
    forever
      #5 clk_i = !clk_i;
  end

initial
  begin
  $readmemb("test.tv", test_vectors);
  #12;
  srst_i <= 1'b1;
  @( posedge clk_i )
  srst_i <= 1'b0;

  // example
  // on -> red
/*
  cmd_type_i <= 3'b000;
  cmd_valid_i <= 1'b1; 
  cmd_data_i <= 16'b0000_0000_0000_0001;
  @( posedge clk_i )
  cmd_valid_i <= 1'b0; 
  #7;
  // red & yellow
  @( posedge clk_i )
  #57;
  // green
  @( posedge clk_i )
  cmd_type_i <= 3'b011;
  cmd_valid_i <= 1'b1; 
  cmd_data_i <= 16'b0000_0000_0000_0011;
  @( posedge clk_i )
  cmd_valid_i <= 1'b0;
  #17;
  // green blinks
  @( posedge clk_i )
  #67;
  // yellow
  @( posedge clk_i )
  cmd_type_i <= 3'b100;
  cmd_valid_i <= 1'b1; 
  cmd_data_i <= 16'b0000_0000_0000_0100;
  @( posedge clk_i )
  cmd_valid_i <= 1'b0;
  #62;
  // red
  @( posedge clk_i )
  cmd_type_i <= 3'b101;
  cmd_valid_i <= 1'b1; 
  cmd_data_i <= 16'b0000_0000_0000_0010;
  @( posedge clk_i )
  cmd_valid_i <= 1'b0; 
  #22;
  // yellow blinks
  @( posedge clk_i )
  cmd_type_i <= 3'b010;
  cmd_valid_i <= 1'b1; 
  cmd_data_i <= 16'b0000_0000_0000_0001;
  @( posedge clk_i )
  cmd_valid_i <= 1'b0;
  #82;
  // off
  @( posedge clk_i )
  cmd_type_i <= 3'b001;
  cmd_valid_i <= 1'b1; 
  cmd_data_i <= 16'b0000_0000_0000_0001;
  @( posedge clk_i )
  cmd_valid_i <= 1'b0;
*/
  end

always @( posedge clk_i )
  #1 {cmd_type_i, cmd_valid_i, cmd_data_i, r_expected, y_expected, g_expected} = {
      test_vectors[num_vector][22:20], test_vectors[num_vector][19], test_vectors[num_vector][18:3], test_vectors[num_vector][2], test_vectors[num_vector][1], test_vectors[num_vector][0]};

always @( negedge clk_i )
  if( !srst_i )
    begin
      if( num_vector != 42 )
        begin
          if( red_o !== r_expected )
            begin
              $display("red_o failed (%d)", num_vector);
              errors <= errors + 1;
            end
          if( yellow_o !== y_expected )
            begin
              $display("yellow_o failed (%d)", num_vector);
              errors <= errors + 1;
            end
          if( green_o !== g_expected )
            begin
              $display("green_o failed (%d)", num_vector);
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
