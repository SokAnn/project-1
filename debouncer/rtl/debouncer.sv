module debouncer #(
  parameter CLK_FREQ_MHZ   = 5,
  parameter GLITCH_TIME_NS = 7
)
(
  input  logic clk_i,
  input  logic key_i,

  output logic key_pressed_stb_o
);

logic                            d1;
logic                            d2;
logic                            flag;
logic [$clog2(GLITCH_TIME_NS):0] counter;

localparam CLK_PERIOD_NS = 1000 / CLK_FREQ_MHZ;
localparam WAIT_HW_TICK  = GLITCH_TIME_NS / CLK_PERIOD_NS;

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
    if( d1 != d2 )
      counter <= '0;
    else
      if( counter < WAIT_HW_TICK - 1 )
        counter <= counter + ($clog2(GLITCH_TIME_NS))'(1);
  end

assign flag = ( counter == ( WAIT_HW_TICK - 2 ) );

always_comb
  begin
    if( flag && ( d1 == d2 ) )
      key_pressed_stb_o = 1'b1;
    else
      key_pressed_stb_o = 1'b0;
  end

endmodule
