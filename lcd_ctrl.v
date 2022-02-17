
module lcd_ctrl(clk, reset, datain, cmd, cmd_valid, dataout, output_valid, busy);
input           clk;
input           reset;
input   [7:0]   datain;
input   [2:0]   cmd;
input           cmd_valid;
output reg  [7:0]   dataout;
output reg         output_valid;
output reg         busy;
reg [9:0]x,y,x_end,y_end,addr;
reg [7:0] arr [35:0];
reg [9:0] load;
reg [2:0] cmd_reg;
reg state,next;//0:ok for next,1:process
always @(posedge clk or posedge reset) begin
    if(reset)begin
      state = 1'd0;
    end
    else begin
      state = next;
    end
end
always @(*) begin
    case (state)
        1'd0: begin
          if(cmd_valid)begin
            next = 1;
          end
          else begin
            next = 0;
          end
        end
        default: begin
          if ( ( cmd_reg == 0 ) && load%9==8  )
                next = 0;
            else
                next = 1;
        end
    endcase
end
always @(posedge clk or posedge reset) begin
    if(reset)begin
      output_valid <= 1'd0;
      busy <= 1'd0;
      load <= 10'd0;
      cmd_reg <= 0;
    end
    else begin
        if(state == 0)begin
          if(cmd_valid ) begin
              cmd_reg <= cmd;
              busy <= 1;    
          end
          output_valid <= 0;
        end
        else begin
          case (cmd_reg)
              3'd0:begin
                load <= load + 1;
                output_valid <= 1;
                dataout = arr[addr];
                if(load%9 == 0||load%9 == 1||load%9 == 3||load%9==4||load%9==6||load%9==7)begin
                    x <= x + 1;
                end
                else if (load%9==2||load%9==5) begin
                    x <= x -2;
                    y <= y + 1;
                end
                else if (load%9==8) begin
                    x <= x - 2;
                    y <= y - 2;
                    busy <= 0;
                    load <= 0;
                end
              end
              3'd1:begin//load
                load <= load + 1;
                if(load == 36)begin
                  cmd_reg <= 0;
                  load <= 0;
                end
                else begin 
                    arr[load] = datain;
                    x <= 2;//start position
                    y <= 2;
                end
              end
              3'd2 : begin//right
                    if ( x >= 3 )
                        x <= x;
                    else
                        x <= x + 3'd1;
                    cmd_reg <= 0;
                end
               3'd3 : begin//left
                    if ( x <= 0 )
                        x <= x;
                    else
                        x <= x - 3'd1;
                    cmd_reg <= 0;
                end
                3'd4 : begin//up
                    if ( y <= 0 )
                        y <= y;
                    else
                        y <= y - 3'd1;
                    cmd_reg <= 0;
                end
                default : begin // SHIFT_DOWN
                    if ( y >= 3 )
                        y <= y;
                    else
                        y <= y + 3'd1;
                    cmd_reg <= 0;
                end
          endcase
        end 




      
    end 
end//always

// assign x_end = x + 2;
// assign y_end = y + 2; 
always @(*) begin
    addr = y*6 + x;
end
                                                                                   
endmodule
