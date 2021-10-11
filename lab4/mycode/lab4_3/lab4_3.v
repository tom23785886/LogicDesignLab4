module lab4_3(input wire en,input wire reset,input wire clk,input wire mode,input wire min_plus,input wire sec_plus,
                output wire [3:0]DIGIT,output wire[6:0]DISPLAY,output wire stop);
        wire en_de;
        wire en_pul;
        wire sec_de;
        wire sec_pul;
        wire min_de;
        wire min_pul;
        wire set_de;
        wire set_pul;
        wire clk23;
        wire clk25;
        wire clk13;
        wire clk16;
        wire clk22;
        wire clk5;
        wire clk_;
        reg enable;
        reg nextenable;
        reg [3:0]nextBCD0;
        reg [3:0]nextBCD1;
        reg [3:0]nextBCD2;
        reg [3:0]nextBCD3;
        reg [6:0]sec;
        reg [6:0]min;
        reg [7:0]tmpnum;
        reg stp;
        reg [3:0] val;
        reg [3:0] BCD0;
        reg [3:0] BCD1;
        reg [3:0] BCD2;
        reg [3:0] BCD3;
        reg [6:0] display;
        reg [3:0] digit;
        reg premode;
        reg nextpremode;

        clk_divider #(23)clk1 (.clk(clk),.clk_div(clk23));
        clk_divider #(25)clk2 (.clk(clk),.clk_div(clk25));
        clk_divider #(13)clk3 (.clk(clk),.clk_div(clk13));
        clk_divider #(16)clk4 (.clk(clk),.clk_div(clk16));
        clk_divider #(22)clk6 (.clk(clk),.clk_div(clk22));
        clk_divider #(5)clk7 (.clk(clk),.clk_div(clk5));

        debounce de1(.pb_debounced(en_de),.pb(en),.clk(clk13));
        onepulse on1(.clk(clk13),.pb_debounced(en_de),.pb_1pulse(en_pul));

        debounce de2(.pb_debounced(sec_de),.pb(sec_plus),.clk(clk13));
        onepulse on2(.clk(clk13),.pb_debounced(sec_de),.pb_1pulse(sec_pul));

        debounce de3(.pb_debounced(min_de),.pb(min_plus),.clk(clk13));
        onepulse on3(.clk(clk13),.pb_debounced(min_de),.pb_1pulse(min_pul));

       /* debounce de4(.pb_debounced(set_de),.pb(setmode),.clk(clk));
        onepulse on4(.clk(clk13),.pb_debounced(set_de),.pb_1pulse(set_pul));*/

        always@(*)
            begin
                if(reset==1'b1) begin nextBCD0=4'b0000;nextBCD1=4'b0000;nextBCD2=4'b0000;nextBCD3=4'b0000;
                nextenable=1'b0; stp=1'b0; end
                nextpremode=mode;
                case(mode)
                1'b1:begin
                    nextenable=(en_pul==1'b1)? !enable:enable;
                        case(enable)
                            1'b0:begin
                                {nextBCD1,nextBCD0}={BCD1,BCD0};
                                {nextBCD3,nextBCD2}={BCD3,BCD2};
                                stp=1'b0;
                                end
                            1'b1:begin
                                if(BCD1==4'b0000&&BCD0==4'b0000)
                                begin 
                                    if(BCD3==4'b0000&&BCD2==4'b0000) begin nextBCD3=BCD3; nextBCD2=BCD2; nextBCD1=BCD1; nextBCD0=BCD0; stp=1'b1; end
                                    else if(BCD2!=4'b0000) begin  nextBCD3=BCD3; nextBCD2=BCD2-1; nextBCD1=4'b0101; nextBCD0=4'b1001; stp=1'b0; end
                                    else if(BCD3!=4'b0000 && BCD2==4'b0000) begin nextBCD3=BCD3-1; nextBCD2=4'b1001; nextBCD1=4'b0101; nextBCD0=4'b1001; stp=1'b0; end
                                    else begin nextBCD3=BCD3; nextBCD2=BCD2-1; nextBCD1=4'b0101; nextBCD0=4'b1001; stp=1'b0; end
                                end
                                else if(BCD1!=4'b0000&&BCD0==4'b0000) begin nextBCD3=BCD3; nextBCD2=BCD2; nextBCD1=BCD1-1; nextBCD0=4'b1001; stp=1'b0; end
                                else begin  nextBCD3=BCD3; nextBCD2=BCD2; nextBCD1=BCD1; nextBCD0=BCD0-1; stp=1'b0; end
                                end
                            
                        endcase
                    end
                1'b0:begin  
                    stp=1'b0;
                    nextenable=1'b0;
                    if(sec_pul==1'b1)
                        begin
                            if(BCD1==4'b0101&&BCD0==4'b1001)
                             begin  
                                nextBCD1=4'b0000;nextBCD0=4'b0000;
                                if(BCD3==4'b0101&&BCD2==4'b1001)begin nextBCD3=4'b0000;nextBCD2=4'b0000; end
                                else if(BCD3!=4'b0101)
                                    begin  
                                        if(BCD2==4'b1001) begin nextBCD3=BCD3+1; nextBCD2=4'b0000; end
                                        else begin nextBCD3=BCD3; nextBCD2=BCD2+1; end
                                    end 
                             end
                            else if(BCD1!=4'b0101&&BCD0==4'b1001) begin nextBCD3=BCD3; nextBCD2=BCD2;nextBCD1=BCD1+1; nextBCD0=4'b0000; end
                            else begin nextBCD3=BCD3; nextBCD2=BCD2; nextBCD1=BCD1; nextBCD0=BCD0+1; end
                            stp=1'b0;
                        end
                    else
                        begin
                             nextBCD1=BCD1;
                            nextBCD0=BCD0;
                            nextBCD2=BCD2;
                            nextBCD3=BCD3;
                        end      
                    if(min_pul==1'b1)
                        begin
                            if(BCD3==4'b0101&&BCD2==4'b1001) begin nextBCD3=4'b0000; nextBCD2=4'b0000; nextBCD1=BCD1; nextBCD0=BCD0; end
                            else if(BCD3!=4'b0101&&BCD2==4'b1001) begin nextBCD3=BCD3+1; nextBCD2=4'b0000; nextBCD1=BCD1; nextBCD0=BCD0; end
                            else begin nextBCD3=BCD3; nextBCD2=BCD2+1; nextBCD1=BCD1; nextBCD0=BCD0; end
                            stp=1'b0;
                        end
                    end
                endcase
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
        always@(posedge clk13) //update FSM
            begin
                enable<=nextenable;
                premode<=nextpremode;
            end
       always@(posedge clk_, posedge reset) //update counting number
            begin
                if(reset==1'b1)
                    begin
                        BCD0<=4'b0000;
                        BCD1<=4'b0000;
                        BCD2<=4'b0000;
                        BCD3<=4'b0000;
                        stp<=1'b0;
                        //enable<=1'b0;
                    end
                else
                    begin
                        BCD0<=(mode==1'b0&&premode==1'b1)?0:nextBCD0;
                        BCD1<=(mode==1'b0&&premode==1'b1)?0:nextBCD1;
                        BCD2<=(mode==1'b0&&premode==1'b1)?0:nextBCD2;
                        BCD3<=(mode==1'b0&&premode==1'b1)?0:nextBCD3;
                        stp<=1'b0;
                        //enable<=1'b1;
                    end
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
        assign stop=stp;
        assign clk_=(mode == 1) ? clk25 : clk13 ;
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
    assign pb_debounced=((shift_reg==4'b1111)?1'b1:1'b0);
endmodule
module onepulse (pb_debounced, clk, pb_1pulse);
    input pb_debounced;
    input clk;
    output pb_1pulse;
    reg pb_1pulse;
    reg pb_debounced_delay;
    always @(posedge clk) 
    begin

        if (pb_debounced == 1'b1 & pb_debounced_delay == 1'b0)
            begin
                pb_1pulse <= 1'b1;
            end
        else
            begin
                pb_1pulse <= 1'b0;
            end
        pb_debounced_delay <= pb_debounced;
    end
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