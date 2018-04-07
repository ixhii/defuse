



module test_vga(CLOCK_50, SW, LEDR,
      VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,					//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]);
		);

    // Do not change the following outputs
    output		VGA_CLK;   						//	VGA Clock
    output		VGA_HS;							//	VGA H_SYNC
    output		VGA_VS;							//	VGA V_SYNC
    output		VGA_BLANK_N;					//	VGA BLANK
    output		VGA_SYNC_N;						//	VGA SYNC
    output	[9:0]	VGA_R;   					//	VGA Red[9:0]
    output	[9:0]	VGA_G;	 					//	VGA Green[9:0]
    output	[9:0]	VGA_B;   					//	VGA Blue[9:0]
	
	//inputs
	input CLOCK_50;
	input [2:0] SW;
	output [17:0] LEDR;
	wire vga_draw;
   wire [4:0] vga_number;
 
	vga_adapter VGA(
        .resetn(~SW[2]),
        .clock(CLOCK_50),
        .colour(vga_colour),
        .x(vga_x),
        .y(vga_y),
        .plot(vga_plot),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK(VGA_BLANK_N),
        .VGA_SYNC(VGA_SYNC_N),
        .VGA_CLK(VGA_CLK));
        defparam VGA.RESOLUTION = "160x120";
        defparam VGA.MONOCHROME = "FALSE";
        defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
        defparam VGA.BACKGROUND_IMAGE = "white.mif";
   
	sequence_output seq (
        .seq_in(18'b000000000111111111),   //LOAD SEQUENCE FROM CONTROL
        .enable(SW[1]),    //WAIT FOR LEVEL START SIGNAL FROM CONTROL
        .clock(rate_out),         //OUTPUT SHOULD SHOW OUTPUT ON SCREEN FOR APPROX 1/2 SECOND
        .out(vga_draw),         //TELLS DATAPATH THAT A NUMBER HAS TO BE DRAWN
        .output_dec(vga_number) //VALUE OF THE NUMBER TO BE DRAWN
    );
    
    assign LEDR[4:0] = vga_number;
    wire [2:0] vga_colour;
    wire [7:0] vga_x;
    wire [6:0] vga_y;
    wire vga_plot;
    wire rate_out;

    
    vga_number_datapath print_num (
        .in_dec(vga_number),    //VALUE OF THE NUMBER TO BE DRAWN
        .enable(vga_draw),      //ENABLE SIGNAL
        .resetn(~SW[2]),     //STILL NEED TO FIGURE OUT RESET
        .clk(CLOCK_50),         //CLOCK SHOULD BE FAST AS POSSIBLE
        .colourOut(vga_colour), //COLOUR
        .xOut(vga_x),           //X COORD
        .yOut(vga_y),           //Y COORD
        .plot(vga_plot)         //TELLS VGA ADAPTER TO DRAW PIXEL AT X,Y
        );


	ratedivider_28bit rateOne ( //should be 1 per second
        .clock(CLOCK_50),
        .d(28'b0010111110101111000001111111),
        .enable(rate_out)
    );
endmodule

/* verilator lint_off WIDTH */
module vga_number_datapath(in_dec, enable, resetn, clk, colourOut, xOut, yOut, plot);
    input [4:0] in_dec; // Input values range from 0 to 18
    input enable; // CONNECT TO sequence_output: out
    input resetn;
    input clk; //CLOCK_50
    output reg [2:0] colourOut; //Just assign to 3'b0
    output reg [7:0] xOut;
    output reg [6:0] yOut;
    output reg plot;
    
    reg [7:0] square15_counter;


    reg digit;
    
    /*Function based on code from: https://github.com/bdeloeste/Character-Table-VGA-Display/blob/master/CharModule.v */
    function draw;
    input [3:0] xStart;
    input [3:0] yStart;
    input [3:0] xEnd;
    input [3:0] yEnd;
    begin 
        if (square15_counter[3:0] >= xStart && square15_counter[3:0] < xEnd && square15_counter[7:4] >= yStart && square15_counter[7:4] < yEnd)
            colourOut = 3'b000;
    end
    endfunction
    always @(posedge clk) begin
    /*...end of copied function...*/
        if (resetn) begin
		case(in_dec)
            // MAX == 160 x 120		SQUARE = 15x15	1111 1111
            5'd0: begin
                draw(3, 0, 12, 3);
                draw(3, 3, 6, 12);
                draw(3, 12, 12, 15);
                end
            5'd1: begin
                draw(6, 0, 9, 15);
                end
            5'd2: begin
                draw(3, 0, 12, 3);
                draw(9, 3, 12, 6);
                draw(3, 6, 12, 9);
                draw(3, 9, 6, 12);
                draw(3, 12, 12, 15);
                    end
            5'd3: begin
                draw(3, 0, 12, 3);
                draw(9, 3, 12, 6);
                draw(3, 6, 12, 9);
                draw(9, 9, 12, 12);
                draw(3, 12, 12, 15);
                end
            5'd4: begin
                
                draw(3, 0, 6, 9);
                draw(6, 6, 9, 9);
                draw(9, 0, 12, 15);
                
                end
            5'd5: begin
            
                draw(3, 0, 12, 3);
                draw(3, 3, 6, 6);
                draw(3, 6, 12, 9);
                draw(9, 9, 12, 12);
                draw(3, 12, 12, 15);
                
                end
            5'd6: begin
                    
                draw(3, 0, 12, 3);
                draw(3, 3, 6, 6);
                draw(3, 6, 12, 9);
                draw(3, 9, 6, 12);
                draw(9, 9, 12, 12);
                draw(3, 12, 12, 15);
                
                end
            5'd7: begin
            
                draw(3, 0, 12, 3);
                draw(9, 3, 12, 15);
            
                end
            5'd8: begin
            
                draw(3, 0, 12, 3);
                draw(3, 3, 6, 6);
                draw(9, 3, 12, 6);
                draw(3, 6, 12, 9);
                draw(3, 9, 6, 12);
                draw(9, 9, 12, 12);
                draw(3, 12, 12, 15);
                
                end
            5'd9: begin
                
                draw(3, 0, 12, 3);
                draw(3, 3, 6, 6);
                draw(9, 3, 12, 6);
                draw(3, 6, 12, 9);
                draw(9, 9, 12, 12);
                draw(3, 12, 12, 15);
                
                end
            5'd10: begin
                
                draw(0, 0, 3, 15); // 1
                draw(6, 0, 15, 3);
                draw(6, 3, 9, 12);
                draw(12, 3, 15, 12);
                draw(6, 12, 15, 15);
                
                end
            5'd11: begin
                    
                draw(3, 0, 6, 15); // 1
                draw(9, 0, 12, 15);
                
                end
            5'd12: begin
                    
                draw(0, 0, 3, 15); // 1
                draw(6, 0, 15, 3);
                draw(12, 3, 15, 6);
                draw(6, 6, 15, 9);
                draw(6, 9, 9, 12);
                draw(6, 12, 15, 15);
                end
            5'd13: begin                    
                draw(0, 0, 3, 15); // 1
                draw(6, 0, 15, 3);
                draw(12, 3, 15, 6);
                draw(6, 6, 15, 9);
                draw(12, 9, 15, 12);
                draw(6, 12, 15, 15);
                end
            5'd14: begin
                draw(0, 0, 3, 15); // 1
                draw(6, 0, 9, 9);
                draw(9, 6, 12, 9);
                draw(12, 0, 15, 15);
                end
            5'd15: begin
                draw(0, 0, 3, 15); // 1
                draw(6, 0, 15, 3);
                draw(6, 3, 9, 6);
                draw(6, 6, 15, 9);
                draw(12, 9, 15, 12);
                draw(6, 12, 15, 15);
                end
            5'd16: begin
                draw(0, 0, 3, 15); // 1
                draw(6, 0, 15, 3);
                draw(6, 3, 9, 6);
                draw(6, 6, 15, 9);
                draw(6, 9, 9, 12);
                draw(12, 9, 15, 12);
                draw(6, 12, 15, 15);
                end
            5'd17: begin
                draw(0, 0, 3, 15); // 1
                draw(6, 0, 15, 3);
                draw(12, 3, 15, 15);
                end
            5'd18: begin // SHOULD NEVER OCCUR
                draw(0, 0, 3, 15); // 1
                draw(6, 0, 15, 3);
                draw(6, 3, 9, 6);
                draw(12, 3, 15, 6);
                draw(6, 6, 15, 9);
                draw(6, 9, 9, 12);
                draw(12, 9, 15, 12);
                draw(6, 12, 15, 15);
                end
            default: begin
            // CLEAR SIGNAL; DRAWS WHITE SQUARE
            end
        endcase
        end
    end

    always @(posedge clk) begin
        if(!resetn) begin
            xOut <= 8'b0;
            yOut <= 7'b0;
            plot <= 1'b0;
            square15_counter <= 8'b0;
        end
        else begin: number_draw
            if (enable) begin 
							plot <= 1'b1;
                     colourOut <= 3'b111;
							xOut <= 8'd72 + square15_counter[7:4];
                     yOut <= 7'd53 + square15_counter[3:0];
                     square15_counter <= square15_counter + 1'b1;
                end
            end
        end
endmodule

module sequence_output(seq_in, enable, clock, out, output_dec);
    input [17:0] seq_in;
    input enable;
    input clock;
    output reg out;
    output reg [4:0] output_dec;
    reg [17:0] seq;
    reg [4:0] count;
	 reg clear;
    always @(posedge clock) begin
        if (!enable) begin
            out <= 1'b0;
            output_dec <= 5'b00000;
            seq <= seq_in;
            count <= 5'b0;
            clear <= 1'b0;
        end
        else begin
            if (clear) begin
                out <= 1'b1;
                output_dec <= 5'b11111; //CLEAR SIGNAL
                clear <= 1'b0;
                end
            else if (count < 17) begin
                out <= seq[0];
                output_dec <= count;
                seq <= seq >> 1; //right shift to get new sequence[0]
                count <= count + 1'b1;
                clear <= 1'b1;
                end
            end
        end
endmodule

module ratedivider_28bit(clock, d, enable);
    input [27:0] d;
    input clock;
    output reg enable;
    reg [27:0] q;
    always @(posedge clock)
    begin
        if (q == 0)
            q <= d;
        else
            q <= q - 28'b0000000000000000000000000001;
        enable <= (q == 0) ? 1 : 0;
    end
endmodule

 
