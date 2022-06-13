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

logic                     val;
logic [$clog2(WIDTH):0]   temp;
logic [$clog2(WIDTH)+1:0] temp_i;
logic [$clog2(WIDTH):0]   cnst = ('1) >> 1;

// data_o logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      data_o <= '0;
    else
      if( val )
        if( temp_i > cnst )
          data_o <= temp;
  end

// data_val_o logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      data_val_o <= '0;
    else
      if( val )
        if( temp_i > cnst )
          data_val_o <= 1'b1;
  end

// val logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      val <= 1'b0;
    else
      if( data_val_i )
        val <= 1'b1;
  end

// temp logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      temp <= '0;
    else
      if( val )
        if( temp_i <= cnst )
          if( data_i[temp_i] )
            temp <= temp + 1'(1);
  end

// temp_i logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      temp_i <= '0;
    else
      if( val )
        if( temp_i <= cnst )
          temp_i <= temp_i + 1'(1);
  end

endmodule
