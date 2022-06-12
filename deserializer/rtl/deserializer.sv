module deserializer (
  input  logic        clk_i,
  input  logic        srst_i,
  input  logic        data_i,
  input  logic        data_val_i,
  
  output logic [15:0] deser_data_o,
  output logic        deser_data_val_o
);

logic [4:0]  temp_i;
logic [15:0] temp;

// deser_data_o logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      deser_data_o <= '0;
    else
      if( temp_i == 5'b11111 )
        deser_data_o <= temp;
  end

// deser_data_val_o logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      deser_data_val_o <= 1'b0;
    else
      if( temp_i == 5'b11111 )
        deser_data_val_o <= 1'b1;
  end

// temp bit logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      temp_i <= 5'b01111;
    else
      if( data_val_i )
        temp_i <= temp_i - 5'b00001;
  end

// temp bit logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      temp <= '0;
    else
      if( data_val_i )
        temp[temp_i] <= data_i;
  end

endmodule
