module lab4_1(input wire [15:0]SW, input wire clk, input wire reset, 
            output wire [3:0]DIGIT, output wire [6:0]DISPLAY);
        
        reg [4:0] val;
        reg nextvalue;
        reg [3:0] digit;
        reg [6:0] display;
        reg [3:0] BCD0;
        reg [3:0] BCD1;
        reg [3:0] BCD2;
        reg [3:0] BCD3;
        wire clk13;
        clock_div clk1(.clk(clk),.clk_div(clk13));
        always@(*)
            begin
                if(reset==1'b1)
                    begin
                        BCD0=4'b0000;
                        BCD1=4'b0000;
                        BCD2=4'b0000;
                        BCD3=4'b0000;
                    end
                else
                    begin
                        BCD0=SW[3:0];
                        BCD1=SW[7:4];
                        BCD2=SW[11:8];
                        BCD3=SW[15:12];
                    end
                case(val)
                4'b0000: begin display=7'b0000001; end
                4'b0001: begin display=7'b1001111; end
                4'b0010: begin display=7'b0010010; end
                4'b0011: begin display=7'b0000110; end
                4'b0100: begin display=7'b1001100; end
                4'b0101: begin display=7'b0100100; end
                4'b0110: begin display=7'b0100000; end
                4'b0111: begin display=7'b0001111; end
                4'b1000: begin display=7'b0000000; end
                default:  begin display=7'b0000100; end
                endcase
            end
            always@(posedge clk13)
                begin
                    case(digit)
                    4'b1110: begin val=BCD1; digit=4'b1101; end
                    4'b1101: begin val=BCD2; digit=4'b1011; end
                    4'b1011: begin val=BCD3; digit=4'b0111; end
                    4'b0111: begin val=BCD0; digit=4'b1110; end
                    default: begin val=BCD0; digit=4'b1110; end 
                    endcase
                end
        assign DISPLAY=display;        
        assign DIGIT=digit;
        

endmodule
module clock_div(clk,clk_div);
    parameter n=13;
    input clk;
    output clk_div;

    reg [n-1:0] num;
    wire [n-1:0] nextnum;
    always@(posedge clk)
        begin
            num=nextnum;
        end
    assign nextnum=num+1;
    assign clk_div=num[n-1];
endmodule