
module lcd_ctrl(clk, reset, datain, cmd, cmd_valid, dataout, output_valid, busy);
input           clk;
input           reset;
input   [7:0]   datain;
input   [2:0]   cmd;
input           cmd_valid;
output reg  [7:0]   dataout;
output reg         output_valid;
output reg         busy;
reg [2:0] cmd_reg;
reg [5:0] x,y;
reg [6:0] load_count,output_cnt;
reg [7:0]buffer[35:0];
reg [5:0]cur,next;
always@(*)begin
    if(cur == 0)begin
        if(cmd_valid == 0)begin
            next = 0;
        end
        else begin
            next = 1;
        end
    end//wait
    else if (cur == 1) begin
        if(cmd_reg == 0&&output_cnt == 8)begin
            next = 0;
        end
        else begin
            next = 1;
        end
    end//process
end
always@(posedge clk or posedge reset)begin
    if (reset) begin
        busy <= 0;
        x <= 3;
        y <= 3;
        load_count <= 0;
        output_cnt <= 0;
        cur = 0;
    end
    else begin
        cur <= next;
        if(cur == 0)begin
            if(cmd_valid == 1)begin
                cmd_reg = cmd;
                busy <= 1;
            end  
            output_valid <= 0; 
            output_cnt <= 0;        
        end//wait
        if(cur == 1)begin
            busy <= 1;
            case (cmd_reg)
                0:begin
                    output_cnt <= output_cnt + 1;
                    output_valid <= 1;
                    case(output_cnt)
                        0:begin
                            dataout <= buffer[(y-1)*6+(x-1)];
                        end
                        1:begin
                            dataout <= buffer[(y-1)*6+(x)];
                        end
                        2:begin
                            dataout <= buffer[(y-1)*6+(x+1)];
                        end
                        3:begin
                            dataout <= buffer[(y)*6+(x-1)];
                        end
                        4:begin
                            dataout <= buffer[(y)*6+(x)];
                        end
                        5:begin
                            dataout <= buffer[(y)*6+(x+1)];
                        end
                        6:begin
                            dataout <= buffer[(y+1)*6+(x-1)];
                        end
                        7:begin
                            dataout <= buffer[(y+1)*6+(x)];
                        end
                        8:begin
                            dataout <= buffer[(y+1)*6+(x+1)];
                            busy <= 0;
                        end
                    endcase
                end
                1:begin
                    output_valid <= 0;
                    x <= 3;
                    y <= 3;
                    load_count <= load_count + 1;
                    buffer[load_count] <= datain;
                    if(load_count == 35)begin
                        load_count <= 0;
                        cmd_reg <= 0;    
                    end
                end
                2:begin
                    if(x < 4)begin
                        x <= x + 1;
                    end
                    output_valid <= 0;
                    cmd_reg <= 0;
                end
                3:begin
                    if(x > 1)begin
                        x <= x - 1;
                    end
                    output_valid <= 0;
                    cmd_reg <= 0;
                end
                4:begin
                    if(y > 1)begin
                        y <= y - 1;
                    end
                    output_valid <= 0;
                    cmd_reg <= 0;
                end
                5:begin
                    if(y < 4)begin
                        y <= y + 1;
                    end
                    output_valid <= 0;
                    cmd_reg <= 0;
                end
            endcase
        end
    end
end
endmodule
