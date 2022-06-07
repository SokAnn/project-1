module serializer (
  input  logic        clk_i,
  input  logic        srst_i,

  input  logic [15:0] data_i,
  input  logic [3:0]  data_mod_i,
  input  logic        data_val_i,

  output logic        ser_data_o,
  output logic        ser_data_val_o,
  output logic        busy_o
);

logic [15:0] buffer;
logic [3:0]  temp;
logic        val;
logic        end_flag;

always_ff @( posedge clk_i )
  if( srst_i )
    begin
      ser_data_o     <= 1'b0;
      ser_data_val_o <= 1'b0;
      busy_o         <= 1'b0;
      
      buffer         <= '0;
      val            <= 1'b0;
      end_flag       <= 1'b0;
    end

always_ff @( posedge clk_i )
  if( !busy_o )
    if( data_val_i )
      begin
        buffer <= data_i;
        temp   <= '1;
        val    <= 1'b1;
        busy_o <= 1'b1;
      end

always_ff @( posedge clk_i )
  if( val )
    if( data_mod_i != 4'b0001 && data_mod_i != 4'b0010 )
      begin
        if ( data_mod_i != 4'b0000 )
          begin
            if( temp != (15 - data_mod_i) )
              begin
                busy_o         <= 1'b1;
                ser_data_o     <= data_i[temp];
                temp           <= temp - 1;
                ser_data_val_o <= 1'b1;
              end
            else
              begin
                ser_data_o     <= 1'b0;
                ser_data_val_o <= 1'b0;
                busy_o         <= 1'b0;
      
                buffer         <= '0;
                val            <= 1'b0;
                temp           <= '0;
              end
          end
        else
          begin
            if( temp != 0 )
              begin
                busy_o         <= 1'b1;
                ser_data_o     <= data_i[temp];
                temp           <= temp - 1;
                ser_data_val_o <= 1'b1;
              end
            else
              begin
                ser_data_o <= data_i[temp];
                end_flag   <= 1;
                busy_o     <= 1'b0;
              end
          end
      end

always_ff @( posedge clk_i )
  if( end_flag )
    begin
      ser_data_o     <= 1'b0;
      ser_data_val_o <= 1'b0;
      
      buffer         <= '0;
      val            <= 1'b0;
      temp           <= '0;
      end_flag       <= 1'b0;
    end

endmodule
