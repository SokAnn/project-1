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
logic [15:0] buffer;
logic [3:0]  data_mod;

// val logic
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      val <= 1'b0;
    else
      if( data_val_i )
        if( !val )
          if( data_mod_i != 4'd1 && data_mod_i != 4'd2 )
            val <= 1'b1;
      if( val )
        if( data_mod != 4'd1 && data_mod != 4'd2 )
          if ( data_mod != 4'd0 )
            if( temp > ( 15 - data_mod ) + 1 )
              val <= 1'b1;
            else
              val <= 1'b0;
          else
            if( temp != 5'd0 )
              val <= 1'b1;
            else
              val <= 1'b0;
  end

logic mod_ok;
assign mod_ok = ( data_mod_i != 4'd1 ) && ( data_mod_i != 4'd2 );

// buffer logic
always_ff @( posedge clk_i )
  begin
    if( !busy_o && data_val_i && mod_ok )
      buffer <= data_i;
  end

// data_mod logic
always_ff @( posedge clk_i )
  begin
  if( !busy_o && data_val_i && mod_ok )
    data_mod <= data_mod_i;
  end

// ser_data_o logic
always_ff @( posedge clk_i )
  begin
    if( val )
      if( data_mod != 4'd1 && data_mod != 4'd2 )
        ser_data_o <= buffer[temp];
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
            if( data_mod != 4'd1 && data_mod != 4'd2 )
              if ( data_mod != 4'd0 )
                if( temp != ( 15 - data_mod ) )
                  ser_data_val_o <= 1'b1;
                else
                  ser_data_val_o <= 1'b0;
              else
                if( temp != 5'd31 )
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
        if( data_mod_i != 4'd1 && data_mod_i != 4'd2 )
          busy_o <= 1'b1;
      if( val )
        if( data_mod != 4'd1 && data_mod != 4'd2 )
          if ( data_mod != 4'd0 )
            if( temp > ( 15 - data_mod ) + 1 )
              busy_o <= 1'b1;
            else
              busy_o <= 1'b0;
          else
            if( temp != 5'd0 )
              busy_o <= 1'b1;
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
        if( data_val_i && !busy_o )
          temp <= 5'b01111;
        else
          begin
            if( val )
              if( data_mod != 4'd1 && data_mod != 4'd2 )
                begin
                  if( data_mod != 4'd0 )
                    if( temp != ( 15 - data_mod ) )
                      temp <= temp - 5'd1;
                    else
                      temp <= '0;
                  else
                    if( temp != 5'd31 )
                      temp <= temp - 5'd1;
                end
          end
      end
  end
   
endmodule

