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

logic val;
logic [$clog2(WIDTH):0] temp;
logic [$clog2(WIDTH)+1:0] temp_i;
logic [$clog2(WIDTH):0] cnst = WIDTH-1;

always_ff @( posedge clk_i )
  if( srst_i )
    begin
      data_o     <= '0;
      data_val_o <= 1'b0;
      
      temp       <= '0;
      temp_i     <= '0;
      val        <= 1'b0;
    end
  else
    begin
      if( data_val_i )
        val <= 1'b1;
      
      data_o <= temp;
    end

always_ff @( posedge clk_i )
  begin
    if( val )
      begin
        if( temp_i != cnst && temp_i < cnst)
          begin
            if( data_i[temp_i] )
              temp <= temp + 1;
            temp_i <= temp_i + 1;
          end
        else 
          if( temp_i == cnst )
            begin
              if( data_i[temp_i] )
                temp <= temp + 1;
              temp_i <= temp_i + 1;
            end
        else 
          if( temp_i > cnst )
            begin
              data_val_o <= 1'b1;
              val        <= 1'b0;
              data_o <= temp;
            end
      end
  end

always_ff @( posedge clk_i )
  if( data_val_o )
    data_val_o <= 1'b0;

endmodule
