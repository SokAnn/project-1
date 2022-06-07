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

initial 
  begin
    clk_i = 0;
    forever #5 clk_i = ~clk_i;
  end

initial
  begin
    srst_i <= 1'b0;
    #35;
    @( posedge clk_i )
    srst_i <= 1'b1;
    @( posedge clk_i )
    srst_i <= 1'b0;
    data_i <= 16'b1111_0000_1111_0000;
    data_mod_i <= 0;
    data_val_i <= 1;
    #10;
    data_val_i <= 0;
  end

endmodule
