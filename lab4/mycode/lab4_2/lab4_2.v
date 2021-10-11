module lab4_2(input wire en, input wire reset,input wire clk,input wire dir,input wire record,
output wire [3:0]DIGIT,output wire[6:0]DISPLAY,output wire max,output wire min);

        wire clk23;
        wire clk25;
        wire clk13;
        wire clk16;
        wire en_de;
        wire en_pul;
        wire dir_de;
        wire dir_pul;
        wire record_de;
        wire record_pul;

        clk_divider #(23)clk1 (.clk(clk),.clk_div(clk23));
        clk_divider #(25)clk2 (.clk(clk),.clk_div(clk25));
        clk_divider #(13)clk3 (.clk(clk),.clk_div(clk13));
        clk_divider #(16)clk4 (.clk(clk),.clk_div(clk16));

        debounce de1(.pb_debounced(en_de),.pb(en),.clk(clk13));
        onepulse on1(.clk(clk23),.pb_debounced(en_de),.pb_1pulse(en_pul));

        debounce de2(.pb_debounced(dir_de),.pb(dir),.clk(clk13));
        onepulse on2(.clk(clk23),.pb_debounced(dir_de),.pb_1pulse(dir_pul));

        debounce de3(.pb_debounced(record_de),.pb(record),.clk(clk13));
        onepulse on3(.clk(clk23),.pb_debounced(record_de),.pb_1pulse(record_pul));
        wire [3:0]lastnum;
        wire [3:0]num;
        reg [3:0]nextBCD0 ;
        reg [3:0]nextBCD1 ;
        reg [3:0]nextBCD2 ;
        reg [3:0]nextBCD3 ;
        reg [6:0] display;
        reg [3:0] digit;
        reg enable;
        reg nextenable;
        reg [3:0] val;
        reg [3:0] BCD0;
        reg [3:0] BCD1;
        reg [3:0] BCD2;
        reg [3:0] BCD3;
        reg mini;
        reg maxi;
        reg dire;
        reg nextdir;
        reg rcd;
        always@(*)
            begin
                if(reset==1'b1) begin nextBCD0=4'b0000;nextBCD1=4'b0000;
                nextenable=1'b0; nextdir=1'b1;maxi=1'b0; mini=1'b0; end
                else
                    begin
                        if(en_pul==1'b1) begin nextenable=~enable; end
                        else begin nextenable=enable; end
                        if(enable==1'b0)
                            begin
                                maxi=1'b0;
                                mini=1'b0;
                                nextBCD1=BCD1;
                                nextBCD0=BCD0;
                            end
                        else
                            begin
                            if(dir_pul==1'b1) begin nextdir=~dire; end
                                if(dire==1'b1)
                                    begin
                                        if(BCD0==4'b1001&&BCD1==4'b1001)
                                            begin
                                                maxi=1'b1;
                                                mini=1'b0;
                                                nextBCD1=BCD1;
                                                nextBCD0=BCD0;
                                                
                                            end   
                                        else if(BCD0==4'b1001&&BCD1!=4'b1001)
                                            begin
                                                maxi=1'b0;
                                                mini=1'b0;
                                                nextBCD1=BCD1+1;
                                                nextBCD0=4'b0000;
                                                
                                            end
                                        else 
                                            begin
                                                maxi=1'b0;
                                                mini=1'b0;
                                                nextBCD0=BCD0+1;
                                                nextBCD1=BCD1;
                                            end
                                    end
                                else
                                    begin
                                        if(BCD0==4'b0000&&BCD1==4'b0000)
                                            begin
                                                maxi=1'b0;
                                                mini=1'b1;
                                                nextBCD1=BCD1;
                                                nextBCD0=BCD0;
                                                
                                            end   
                                        else if(BCD0==4'b0000&&BCD1!=4'b0000)
                                            begin
                                                maxi=1'b0;
                                                mini=1'b0;
                                                nextBCD1=BCD1-1;
                                                nextBCD0=4'b1001;
                                                
                                            end
                                        else 
                                            begin
                                                maxi=1'b0;
                                                mini=1'b0;
                                                nextBCD0=BCD0-1;
                                                nextBCD1=BCD1;
                                            end
                                    end
                            end
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
                    4'b1001: begin display=7'b0000100; end
                    default:  begin display=7'b0000001; end
                endcase  
            end
        always@(posedge clk23,posedge reset)
            begin
                if(reset==1'b1)
                    begin
                        BCD2<=4'b0000;
                        BCD3<=4'b0000;
                    end
                else 
                    begin
                        if(record_pul==1'b1) begin BCD2<=BCD0; BCD3<=BCD1; end
                        else begin BCD2<=BCD2; BCD3<=BCD3; end
                    end              
            end
        always@(posedge clk23) //update FSM
            begin
                enable<=nextenable;
                dire<=nextdir;
            end
        always@(posedge clk25, posedge reset) //update counting number
            begin
                if(reset==1'b1)
                    begin
                        BCD0<=4'b0000;
                        BCD1<=4'b0000;
                    end
                else
                    begin
                        BCD0<=nextBCD0;
                        BCD1<=nextBCD1;
                    end
                
                /*if(reset==1'b1) begin enable=1'b0; end
                else */
            end
        always@(posedge clk13)
            begin
                case(digit)
                4'b1110: begin val=BCD1; digit=4'b1101; end
                4'b1101: begin val=BCD2; digit=4'b1011; end
                4'b1011: begin val=BCD3; digit=4'b0111; end
                default: begin val=BCD0; digit=4'b1110; end
                //default: begin val=BCD0; digit=4'b1110; end
                endcase
            end
        assign DISPLAY=display;
        assign DIGIT=digit;
        assign max=maxi;
        assign min=mini;
endmodule
module clk_divider(clk,clk_div);
    parameter n = 4;
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
module debounce(pb_debounced,pb,clk);
    output pb_debounced;
    input pb;
    input clk;

    reg[3:0] shift_reg;
    always@(posedge clk)
        begin 
            shift_reg[3:1] <= shift_reg[2:0];
            shift_reg[0] <= pb;
        end
    assign pb_debounced=(shift_reg==4'b1111)?1'b1:1'b0;
endmodule
/*module onepulse(input wire rst,input wire clk,input wire pb_debounced,output reg pb_1pulse);
    reg pb_1pulse_next;
    reg pb_debounced_delay;
    always@(*)
        begin
            pb_1pulse_next=pb_debounced & (~pb_debounced_delay);
        end
    always@(posedge clk,posedge rst)
        begin
            if(rst==1'b1)
                begin
                    pb_1pulse=1'b0;
                    pb_debounced_delay=1'b0;
                end
            else
                begin
                    pb_1pulse=pb_1pulse_next;
                    pb_debounced_delay=pb_debounced;
                end
        end
endmodule*/
module onepulse (pb_debounced, clk, pb_1pulse);
    input pb_debounced;
    input clk;
    output pb_1pulse;
    reg pb_1pulse;
    reg pb_debounced_delay;
    always @(posedge clk) 
    begin
        pb_debounced_delay <= pb_debounced;
        if (pb_debounced == 1'b1 & pb_debounced_delay == 1'b0)
            begin
                pb_1pulse <= 1'b1;
            end
        else
            begin
                pb_1pulse <= 1'b0;
                
            end
    end
endmodule

