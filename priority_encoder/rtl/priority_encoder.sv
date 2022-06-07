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

logic [WIDTH-1:0] left  = WIDTH - 1;
logic [WIDTH-1:0] right = '0;

logic [WIDTH-1:0] temp_l;
logic [WIDTH-1:0] temp_r;

logic left_val;
logic right_val;
logic val;

always_ff @( posedge clk_i )
  begin
    if( srst_i )
      begin
        data_left_o       <= '0;
        data_right_o      <= '0;
        deser_data_val_o  <= 1'b0;

        left_val          <= 1'b0;
        right_val         <= 1'b0;
        val               <= 1'b0;

        data_left         <= '0;
        data_right        <= '0;

        temp_l            <= WIDTH - 1;
        temp_r            <= 1'b0;
      end
    else
      begin
        if( data_val_i )
          val <= 1'b1;
        
        data_left_o      <= data_left;
        data_right_o     <= data_right;
        deser_data_val_o <= left_val & right_val;
      end
  end

// left logic
always_ff @( posedge clk_i )
  if( val )
    if( !left_val )
      begin
        for(int i = left; i >= right; i--)
          begin
            if( data_i[i] )
              begin
                left_val          <= 1'b1;
                data_left[i]      <= 1'b1;
                data_left_o       <= data_left;
                break;
              end
            else
              if( i == right )
                begin
                  data_left_o <= data_left;
                  left_val    <= 1'b1;
                  break;
                end
          end
      end

// right logic
always_ff @( posedge clk_i )
  if( val )
    if( !right_val )
      begin
        for(int i = right; i <= left; i++)
          begin
            if( data_i[i] )
              begin
                right_val          <= 1'b1;
                data_right[i]      <= 1'b1;
                data_right_o       <= data_right;
                break;
              end
            else
              if( i == left )
                begin
                  data_right_o <= data_right;
                  right_val    <= 1'b1;
                  break;
                end
          end
      end

always_ff @( posedge clk_i )
  begin
    if( deser_data_val_o )
      begin
        left_val   <= 1'b0;
        right_val  <= 1'b0;
        val        <= 1'b0;
        
        data_left  <= '0;
        data_right <= '0;
      end
  end

endmodule
