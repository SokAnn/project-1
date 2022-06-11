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

always_ff @( posedge clk_i )
  begin
    d1 <= key_i;
  end

always_ff @( posedge clk_i )
  begin
    d2 <= d1;
  end

always_ff @( posedge clk_i )
  begin
    if( counter < ( GLITCH_TIME_NS - ( 1000 / CLK_FREQ_MHZ ) ) )
      begin
        if( d1 != d2 )
          begin
            counter    <= counter + ( 1000 / CLK_FREQ_MHZ );
            glitch_cnt <= glitch_cnt + 1;
            flag       <= 1'b0;
          end
        else
          begin
            counter    <= '0;
            flag       <= 1'b0;
            //glitch_cnt <= '0;
            
            if( d1 == d2 && d2 == 0 )
              glitch_cnt <= '0;
            else
              if( d1 == d2 && d2 == 1 && glitch_cnt == 1 )
                begin
                  glitch_cnt <= '0;
                  flag       <= 1'b1;
                end
              else
                if( d1 == d2 && d2 == 1 && glitch_cnt > 1 )
                  begin
                    glitch_cnt <= '0;
                    flag       <= 1'b1;
                  end
          end
      end
    else
      begin
        counter <= '0;
        flag    <= 1'b1;
        glitch_cnt <= '0;
        /*if( glitch_cnt <= ( counter / ( 1000 / CLK_FREQ_MHZ ) ) )
          flag <= 1'b1;
        else
          flag <= 1'b0;*/
      end
  end


assign key_pressed_stb_o = ( d1 != d2 ) ? ( ( d1 ^^ d2 ) && flag ) : ( flag );

endmodule
