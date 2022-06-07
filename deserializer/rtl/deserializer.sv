module deserializer (
  input  logic        clk_i,
  input  logic        srst_i,
  input  logic        data_i,
  input  logic        data_val_i,
  
  output logic [15:0] deser_data_o,
  output logic        deser_data_val_o
);

logic [5:0]  temp_i;
logic [15:0] temp;

always_ff @( posedge clk_i )
  if( srst_i )
    begin
      deser_data_o     <= 1'b0;
      deser_data_val_o <= 1'b0;

      temp_i           <= '0;
      temp             <= '0;
    end
  else
    begin
      if( data_val_i )
        begin
          temp[temp_i] <= data_i;
          temp_i       <= temp_i + 1;
        end
      deser_data_o <= temp;
    end

always_ff @( posedge clk_i )
  if( temp_i > 15)
    begin
      deser_data_o     <= temp;
      deser_data_val_o <= 1'b1;
    end

always_ff @(posedge clk_i)
  if( deser_data_val_o )
    begin
      deser_data_val_o <= 1'b0;
      temp             <= '0;
      temp_i           <= '0;
    end

endmodule
