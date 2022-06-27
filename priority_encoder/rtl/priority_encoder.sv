module priority_encoder #(
  parameter WIDTH = 7
)(
  input  logic             clk_i,
  input  logic             srst_i,
  input  logic [WIDTH-1:0] data_i,
  input  logic             data_val_i,

  output logic [WIDTH-1:0] data_left_o,
  output logic [WIDTH-1:0] data_right_o,
  output logic             deser_data_val_o
);

logic [WIDTH-1:0] data_left;
logic [WIDTH-1:0] data_right;

// data_left_o logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      data_left_o <= '0;
    else
      data_left_o <= data_left;
  end

// data_right_o logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      data_right_o <= '0;
    else
      data_right_o <= data_right;
  end

// left logic
always_comb
  begin
  data_left = '0;
  for( int i = WIDTH - 1; i > -1; i-- )
    begin
      if( data_i[i] == 1'b1 )
        begin
          data_left[i] = 1'b1;
          break;
        end
    end
  end

// right logic
always_comb
  begin
  data_right = '0;
  for( int i = 0; i < WIDTH; i++ )
    begin
      if( data_i[i] == 1'b1 )
        begin
          data_right[i] = 1'b1;
          break;
        end
    end
  end

// deser_data_val_o logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      deser_data_val_o <= 1'b0;
    else
      deser_data_val_o <= data_val_i;
  end

endmodule