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

logic [$clog2(WIDTH):0] left   = '1;
logic [$clog2(WIDTH):0] right  = '0;

logic [$clog2(WIDTH):0] temp_l;
logic [$clog2(WIDTH):0] temp_r;

logic left_val;
logic right_val;
logic val;

// data_left_o logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      data_left_o <= '0;
    else
      data_left_o <= data_left;
  end

// left logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      data_left <= '0;
    else
      if( val )
        if( !left_val )
          if( data_i[temp_l] )
            data_left[temp_l] <= 1'b1;
  end

// temp_l logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      temp_l <= left >> 1;
    else
      if( val && !left_val)
        if( temp_l > right )
          temp_l <= temp_l - 1'(1);
  end

// data_right_o logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      data_right_o <= '0;
    else
      data_right_o <= data_right;
  end

// right logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      data_right <= '0;
    else
      if( val )
        if( !right_val )
          if( data_i[temp_r] )
            data_right[temp_r] <= 1'b1;
  end

// temp_r logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      temp_r <= right;
    else
      if( val && ! right_val)
        if( temp_r < left )
          temp_r <= temp_r + 1'(1);
  end

// deser_data_val_o logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      deser_data_val_o <= 1'b0;
    else
      deser_data_val_o <= left_val & right_val;
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

// left_val logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      left_val <= 1'b0;
    else
      if( ( data_left != 0 ) || ( temp_l == right ) )
        left_val <= 1'b1;
  end

// right_val logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      right_val <= 1'b0;
    else
      if( ( data_right != 0 ) || ( temp_r == left ) )
        right_val <= 1'b1;
  end

endmodule
