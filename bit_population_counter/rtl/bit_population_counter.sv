module bit_population_counter #(
  parameter WIDTH = 7
)(
  input  logic                   clk_i,
  input  logic                   srst_i,
  input  logic [WIDTH-1:0]       data_i,
  input  logic                   data_val_i,

  output logic [$clog2(WIDTH):0] data_o,
  output logic                   data_val_o
);

logic [$clog2(WIDTH):0]   temp;

// data_o logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      data_o <= '0;
    else
      data_o <= temp;
  end

// data_val_o logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      data_val_o <= '0;
    else
      if( data_val_i )
        data_val_o <= 1'b1;
      else
        data_val_o <= 1'b0;
  end

always_comb
  begin
    temp = '0;
    for( int i = 0; i <= WIDTH - 1; i++ )
      begin
        if( data_i[i] == 1'b1 )
          temp = temp + 1'(1);
        else
          continue;
      end
  end

endmodule
