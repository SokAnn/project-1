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

logic [4:0]  temp;
logic        val;

// val logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      val <= 1'b0;
    else
      if( data_val_i )
        begin
          if( data_mod_i != 4'b0001 && data_mod_i != 4'b0010 )
            val <= 1'b1;
          else
            val <= 1'b0;
        end
      else
        begin
          if( val )
            if( data_mod_i != 4'b0001 && data_mod_i != 4'b0010 )
              if ( data_mod_i != 4'b0000 )
                if( temp > ( 15 - data_mod_i ) + 1 )
                  val <= 1'b1;
                else
                  val <= 1'b0;
              else
                if( temp != 0 )
                  val <= 1'b1;
                else
                  val <= 1'b0;
        end
  end

// ser_data_o logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      ser_data_o <= 1'b0;
    else
      if( val )
        if( data_mod_i != 4'b0001 && data_mod_i != 4'b0010 )
          ser_data_o <= data_i[temp];
  end

// ser_data_val_o logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      ser_data_val_o <= 1'b0;
    else
      begin
        if( val )
          begin
            if( data_mod_i != 4'b0001 && data_mod_i != 4'b0010 )
              if ( data_mod_i != 4'b0000 )
                if( temp != ( 15 - data_mod_i ) )
                  ser_data_val_o <= 1'b1;
                else
                  ser_data_val_o <= 1'b0;
              else
                if( temp != -1 )
                  ser_data_val_o <= 1'b1;
                else
                  ser_data_val_o <= 1'b0;
          end
        else
          ser_data_val_o <= 1'b0;
      end
  end

// busy_o logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      busy_o <= 1'b0;
    else
      if( data_val_i )
        begin
          if( data_mod_i != 4'b0001 && data_mod_i != 4'b0010 )
            busy_o <= 1'b1;
          else
            busy_o <= 1'b0;
        end
      else
        if( val )
          if( data_mod_i != 4'b0001 && data_mod_i != 4'b0010 )
            if ( data_mod_i != 4'b0000 )
              if( temp > ( 15 - data_mod_i ) + 1 )
                 busy_o <= 1'b1;
               else
                 busy_o <= 1'b0;
            else
                if( temp != 0 )
                  busy_o <= 1'b1;
                else
                  busy_o <= 1'b0;
        else
          busy_o <= 1'b0;
  end

// temp bit logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      temp <= '0;
    else
      begin
        if( data_val_i )
          temp <= 5'b01111;
        else
          begin
            if( val )
              if( data_mod_i != 4'b0001 && data_mod_i != 4'b0010 )
                begin
                  if( data_mod_i != 4'b0000 )
                    if( temp != ( 15 - data_mod_i ) )
                      temp <= temp - 5'b00001;
                    else
                      temp <= '0;
                  else
                    if( temp != -1 )
                      temp <= temp - 5'b00001;
                end
          end
      end
  end
   
endmodule
