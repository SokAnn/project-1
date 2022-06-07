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

initial
  begin
    clk_i = 0;
    forever
      #5 clk_i = ~clk_i;
  end

initial
  begin
    srst_i <= 0;
    #17;
    srst_i <= 1;
    @( posedge clk_i )
    srst_i <= 0;
    // example
    @( posedge clk_i )
    data_i <= 1'b0;   data_val_i <= 1'b1;//0
    @( posedge clk_i )
    data_i <= 1'b1;   data_val_i <= 1'b0;//1
    @( posedge clk_i )
    data_i <= 1'b0;   data_val_i <= 1'b0;//2
    @( posedge clk_i )
    data_i <= 1'b1;   data_val_i <= 1'b1;//3
    @( posedge clk_i )
    data_i <= 1'b0;   data_val_i <= 1'b1;//4
    @( posedge clk_i )
    data_i <= 1'b1;   data_val_i <= 1'b1;//5
    @( posedge clk_i )
    data_i <= 1'b0;   data_val_i <= 1'b0;//6
    @( posedge clk_i )
    data_i <= 1'b1;   data_val_i <= 1'b0;//7
    @( posedge clk_i )
    data_i <= 1'b0;   data_val_i <= 1'b1;//8
    @( posedge clk_i )
    data_i <= 1'b1;   data_val_i <= 1'b1;//9
    @( posedge clk_i )
    data_i <= 1'b0;   data_val_i <= 1'b1;//10
    @( posedge clk_i )
    data_i <= 1'b1;   data_val_i <= 1'b1;//11
    @( posedge clk_i )
    data_i <= 1'b0;   data_val_i <= 1'b1;//12
    @( posedge clk_i )
    data_i <= 1'b1;   data_val_i <= 1'b1;//13
    @( posedge clk_i )
    data_i <= 1'b0;   data_val_i <= 1'b1;//14
    @( posedge clk_i )
    data_i <= 1'b1;   data_val_i <= 1'b0;//15
    @( posedge clk_i )
    data_i <= 1'b0;   data_val_i <= 1'b0;//16
    @( posedge clk_i )
    data_i <= 1'b1;   data_val_i <= 1'b0;//17
    @( posedge clk_i )
    data_i <= 1'b0;   data_val_i <= 1'b1;//18
    @( posedge clk_i )
    data_i <= 1'b1;   data_val_i <= 1'b0;//19
    @( posedge clk_i )
    data_i <= 1'b0;   data_val_i <= 1'b1;//20
    @( posedge clk_i )
    data_i <= 1'b1;   data_val_i <= 1'b1;//21
    @( posedge clk_i )
    data_i <= 1'b0;   data_val_i <= 1'b1;//22
    @( posedge clk_i )
    data_i <= 1'b1;   data_val_i <= 1'b1;//23


  end

endmodule
