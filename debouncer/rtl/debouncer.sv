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

logic [$clog2(GLITCH_TIME_NS):0] counter       = '0;
logic [$clog2(GLITCH_TIME_NS):0] glitch_cnt    = '0;

localparam T_NS   = 1000 / CLK_FREQ_MHZ;


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
    if( d1 !== d2 )
      counter <= '0;
    else
      if( glitch_cnt == 0 )
        if( counter < GLITCH_TIME_NS - 2 * T_NS )
          counter <= counter + ($clog2(GLITCH_TIME_NS))'( T_NS );
        else
          counter <= '0;
      else
        counter <= '0;
  end

// glitch_cnt logic
always_ff @( posedge clk_i )
  begin
    if( flag )
      glitch_cnt <= glitch_cnt + ($clog2(GLITCH_TIME_NS))'(1);
    else
      if( d1 !== d2 )
        glitch_cnt <= '0;
  end

// flag logic
always_ff @( posedge clk_i )
  begin
    if( counter == ( GLITCH_TIME_NS - 3 * T_NS ) )
      flag <= 1'b1;
    else
      flag <= 1'b0;
  end

// key pressed logic
assign key_pressed_stb_o = ( flag &&  d1 === d2  ) ? ( 1'b1 ) : ( 1'b0 );

endmodule
 
