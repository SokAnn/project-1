`timescale 1 ms / 1 ns

module traffic_lights_tb;

parameter BLINK_Y_MS  = 5;
parameter G_BLINK_T   = 4;
parameter STATE_RY_MS = 3;

logic        clk_i;
logic        srst_i;
logic [2:0]  cmd_type_i;
logic        cmd_valid_i;
logic [15:0] cmd_data_i;

logic        red_o;
logic        yellow_o;
logic        green_o;

traffic_lights #(
  .BLINK_Y_MS  ( BLINK_Y_MS  ),
  .G_BLINK_T   ( G_BLINK_T   ),
  .STATE_RY_MS ( STATE_RY_MS )
) traffic_lights (
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
logic [8:0] errors          = '0;
logic [6:0] num_vector      = '0;

logic r_expected, y_expected, g_expected;

initial
  begin
    clk_i = 0;
    forever
      #0.25 clk_i = !clk_i;
  end

initial
  begin
  $readmemb("test.tv", test_vectors);
  #0.6;
  srst_i <= 1'b1;
  @( posedge clk_i )
  srst_i <= 1'b0;
  end

always @( posedge clk_i )
  #0.05 {cmd_type_i, cmd_valid_i, cmd_data_i, r_expected, y_expected, g_expected} = {
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
          $stop;
        end
    end

endmodule
