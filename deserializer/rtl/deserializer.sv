module deserializer (
  input  logic        clk_i,
  input  logic        srst_i,
  input  logic        data_i,
  input  logic        data_val_i,
  
  output logic [15:0] deser_data_o,
  output logic        deser_data_val_o
);

logic [4:0]  temp_bit;
logic [15:0] temp;

logic [15:0] buff;

assign deser_data_o = ( deser_data_val_o ) ? ( temp ) : ( buff );

always_ff @( posedge clk_i )
  begin
    if( temp_bit == 5'd16 )
      buff <= temp;
  end

assign deser_data_val_o = ( temp_bit == 5'd16 );

// temp bit logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      temp_bit <= 5'd0;
    else
      if( data_val_i )
        if( temp_bit != 5'd16 )
          temp_bit <= temp_bit + 5'd1;
        else
          temp_bit <= 5'd1;
      else
        if( temp_bit == 5'd16 )
          temp_bit <= 5'd0;
  end

// temp logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      temp <= '0;
    else
      if( data_val_i )
        if( temp_bit != 5'd16 )
          temp[15 - temp_bit] <= data_i;
        else
          temp[15] <= data_i;
  end

endmodule
