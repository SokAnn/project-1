module debouncer #(
  parameter CLK_FREQ_MHZ   = 5,
  parameter GLITCH_TIME_NS = 7
)
(
  input  logic clk_i,
  input  logic key_i,

  output logic key_pressed_stb_o
);

logic d1;
logic d2;
logic flag;

logic [$clog2(GLITCH_TIME_NS):0] counter    = '0;
logic [$clog2(GLITCH_TIME_NS):0] glitch_cnt = '0;

// d1 logic
always_ff @( posedge clk_i )
  begin
    d1 <= key_i;
  end

// d2 logic
always_ff @( posedge clk_i )
  begin
    d2 <= d1;
  end

// counter logic
always_ff @( posedge clk_i )
  begin
    if( counter < ( GLITCH_TIME_NS - ( 1000 / CLK_FREQ_MHZ ) ) )
      if( d1 != d2 )
        counter <= counter + ($clog2(GLITCH_TIME_NS))'( 1000 / CLK_FREQ_MHZ );
      else
        counter <= '0;
    else
      counter <= '0;
  end

// glitch_cnt logic
always_ff @( posedge clk_i )
  begin
    if( counter < ( GLITCH_TIME_NS - ( 1000 / CLK_FREQ_MHZ ) ) )
      if( d1 != d2 )
        glitch_cnt <= glitch_cnt + 1'(1);
      else
         glitch_cnt <= '0;
    else
      glitch_cnt <= '0;
  end

// flag logic
always_ff @( posedge clk_i )
  begin
    if( counter < ( GLITCH_TIME_NS - ( 1000 / CLK_FREQ_MHZ ) ) )
      if( d1 != d2 )
        flag <= 1'b0;
      else
        begin
          flag <= 1'b0;

          if( d1 == d2 && d2 == 1 && glitch_cnt == 1 )
            flag <= 1'b1;
          else
            if( d1 == d2 && d2 == 1 && glitch_cnt > 1 )
              flag  <= 1'b1;
        end
    else
      begin
        if( glitch_cnt <= ( counter / ( 1000 / CLK_FREQ_MHZ ) ) )
          flag <= 1'b1;
        else
          flag <= 1'b0;
      end
  end

assign key_pressed_stb_o = ( d1 != d2 ) ? ( ( d1 ^^ d2 ) && flag ) : ( flag );

endmodule
