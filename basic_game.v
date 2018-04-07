


module basic_game(CLOCK_50, KEY, SW, LEDR, LEDG, HEX0, HEX1); //wait states and new levels

	input CLOCK_50;
	input [3:0] KEY;
	input [17:0] SW;
	
	output [17:0] LEDR;
	output [7:0] LEDG;
	output [6:0] HEX0;
	output [6:0] HEX1;
	
	wire rate_out,
		 countdown_reset,
		 countdown_enable,
		 game_over_sig;
		 
	wire [7:0] count_down_from;

	wire level_1_enable;
	wire level_1_win;
	
	wire level_2_enable;
	wire level_2_win;
	
	wire level_3_enable;
	wire level_3_win;
	
	wire level_4_enable;
	wire level_4_win;
	
	wire game_won_enable;
	wire win_reset;
	
	wire game_over_enable;
	wire loss_reset;
	
	wire [17:0] level_key;
	
	instantiate_countdown ctdwn (
		.clock(rate_out), //rate divider output
		.countdown_reset(countdown_reset), //from CONTROL
		.countdown_enable(countdown_enable), //from control
		.count_down_from(count_down_from), //from control
		.hex0(HEX0),
		.hex1(HEX1),
		.game_over_sig(game_over_sig) //output to control
		);
		
	ratedivider_28bit rateOne ( //should be 1 per second
        .clock(CLOCK_50),
        .d(28'b0010111110101111000001111111),
        .enable(rate_out)
    );
	
    control ctrl(
    	.clock(CLOCK_50),
    	.start_button(~KEY[0]), //game start button
    	.game_over_sig(game_over_sig), //from countdown
    	.win_reset(~KEY[2]),
    	.loss_reset(~KEY[2]),
    	.level_1_win(level_1_win),
    	.level_2_win(level_2_win),
    	.level_3_win(level_3_win),
    	.level_4_win(level_4_win),
    	
    	.countdown_reset(countdown_reset),
    	.countdown_enable(countdown_enable),
    	.count_down_from(count_down_from),
    	
    	//outputs
    	.level_1_enable(level_1_enable),
    	.level_2_enable(level_2_enable),
    	.level_3_enable(level_3_enable),
    	.level_4_enable(level_4_enable),
    	.level_key(level_key), //18 bits
    	.game_won_enable(game_won_enable),
    	.game_over_enable(game_over_enable),
    	.ledr(LEDR),
    	.ledg(LEDG)
    	);
		
	// assign LEDG[0] = level_1_enable;
		
	level_1 level_1 (
    	.level_en(level_1_enable), //ENABLE SIGNAL
    	.load_code(~KEY[1]),       //ENTER SIGNAL
    	.sw(SW[17:0]),             //INPUT
    	.level_key(level_key),     //KEY FOR LEVEL... -> MIGHT NEED LOAD SIGNAL FROM CONTROL
    	.level_1_win(level_1_win)
    	);
    	
    level_2 level_2 (
    	.level_en(level_2_enable), //ENABLE SIGNAL
    	.load_code(~KEY[1]),       //ENTER SIGNAL
    	.sw(SW[17:0]),             //INPUT
    	.level_key(level_key),     //KEY FOR LEVEL... -> MIGHT NEED LOAD SIGNAL FROM CONTROL
    	.level_2_win(level_2_win)
    	);
    	
    level_3 level_3 (
    	.level_en(level_3_enable), //ENABLE SIGNAL
    	.load_code(~KEY[1]),       //ENTER SIGNAL
    	.sw(SW[17:0]),             //INPUT
    	.level_key(level_key),     //KEY FOR LEVEL... -> MIGHT NEED LOAD SIGNAL FROM CONTROL
    	.level_3_win(level_3_win)
    	);
    	
    level_4 level_4 (
    	.level_en(level_4_enable), //ENABLE SIGNAL
    	.load_code(~KEY[1]),       //ENTER SIGNAL
    	.sw(SW[17:0]),             //INPUT
    	.level_key(level_key),     //KEY FOR LEVEL... -> MIGHT NEED LOAD SIGNAL FROM CONTROL
    	.level_4_win(level_4_win)
    	);
    	

endmodule

module control(
	input clock,
	input start_button,
	input game_over_sig,
	input win_reset,
	input loss_reset,
	input level_1_win,
	input level_2_win,
	input level_3_win,
	input level_4_win,
	
	output reg countdown_reset,
	output reg countdown_enable,
	output reg [7:0] count_down_from,
	
	output reg level_1_enable,
	output reg level_2_enable,
	output reg level_3_enable,
	output reg level_4_enable,
	output reg [17:0] level_key,
	output reg game_won_enable,
	output reg game_over_enable,
	output reg [17:0] ledr,
	output reg [7:0] ledg
	);
	
	reg [4:0] current_state, next_state;
	
	localparam 	STANDBY 		= 	5'd0,
				STANDBY_WAIT 	= 	5'd1,
				LEVEL_1 		= 	5'd2,
				LEVEL_1_WAIT	=	5'd3,
				LEVEL_2 		= 	5'd4,
				LEVEL_2_WAIT	=	5'd5,
				LEVEL_3 		= 	5'd6,
				LEVEL_3_WAIT	=	5'd7,
				LEVEL_4 		= 	5'd8,
				GAME_WON		= 	5'd9,
				GAME_OVER		=	5'd10;
					
	//state logic (game states)
	always @(*)
	begin: state_table
		case (current_state)
			STANDBY: 		next_state = start_button? STANDBY_WAIT : STANDBY;
			STANDBY_WAIT: 	next_state = start_button? STANDBY_WAIT : LEVEL_1;
			
			LEVEL_1: 		if (game_over_sig)
									next_state = GAME_OVER;
								else if (level_1_win)
									next_state = LEVEL_1_WAIT;
								else
									next_state = LEVEL_1;
									
			LEVEL_1_WAIT:	next_state = start_button? LEVEL_2 : LEVEL_1_WAIT;
									
			LEVEL_2: 		if (game_over_sig)
									next_state = GAME_OVER;
								else if (level_2_win)
									next_state = LEVEL_2_WAIT;
								else
									next_state = LEVEL_2;	
									
			LEVEL_2_WAIT:	next_state = start_button? LEVEL_3 : LEVEL_2_WAIT;
									
			LEVEL_3: 		if (game_over_sig)
									next_state = GAME_OVER;
								else if (level_3_win)
									next_state = LEVEL_3_WAIT;
								else
									next_state = LEVEL_3;
									
			LEVEL_3_WAIT:	next_state = start_button? LEVEL_4 : LEVEL_3_WAIT;
									
			LEVEL_4: 		if (game_over_sig)
									next_state = GAME_OVER;
								else if (level_4_win)
									next_state = GAME_WON;
								else
									next_state = LEVEL_4;
								
			GAME_WON:		next_state = win_reset? STANDBY : GAME_WON;
			GAME_OVER:		next_state = loss_reset? STANDBY : GAME_OVER;
			
			default:     next_state = STANDBY;
		endcase
	end //state logic
	
	always @(*)
	begin: enable_signals
	
		// by default set enable signals to 0
		level_1_enable = 1'b0;
		level_2_enable = 1'b0;
		level_3_enable = 1'b0;
		level_4_enable = 1'b0;
		game_won_enable = 1'b0;
		game_over_enable = 1'b0;
		//?
		countdown_reset = 1'b1;
		countdown_enable = 1'b0;
		
		case (current_state)
			STANDBY: begin
				countdown_reset = 1'b1;
				countdown_enable = 1'b0;
				count_down_from [7:0] = 8'd30;
				
				//level_1_enable = 1'b0;
				//game_won_enable = 1'b0;
				//game_over_enable = 1'b0;
				
				level_key = 18'b0;
				ledr = 18'b0;
				ledg = 8'b0;
				
			end
			
			STANDBY_WAIT: begin
				countdown_reset = 1'b1;
				countdown_enable = 1'b0;
				count_down_from [7:0] =  8'd30; //30 seconds
			end
			
			LEVEL_1: begin
				countdown_reset = 1'b0;
				count_down_from [7:0] =  8'd30; //30 seconds
				countdown_enable = 1'b1;
								
				level_1_enable = 1'b1;
				level_key = 18'b000000000000011111;
				ledr = 18'b000000000000011111;
				ledg = 8'b0;
			end
			
			LEVEL_1_WAIT: begin
				countdown_reset = 1'b1;
				countdown_enable = 1'b0;
				count_down_from [7:0] = 8'd20;
				level_key = 18'b0;
				ledr = 18'b0;
				ledg = 8'b0;
			end
			
			LEVEL_2: begin
				countdown_reset = 1'b0;
				countdown_enable = 1'b1;
				count_down_from [7:0] =  8'd20; //20 seconds
				
				level_2_enable = 1'b1;
				level_key = 18'b101010101010101010;
				ledr = 18'b101010101010101010;
				ledg = 8'b0;
			end
			
			LEVEL_2_WAIT: begin
				countdown_reset = 1'b1;
				countdown_enable = 1'b0;
				count_down_from [7:0] = 8'd10;
				level_key = 18'b0;
				ledr = 18'b0;
				ledg = 8'b0;
			end
			
			LEVEL_3: begin
				countdown_reset = 1'b0;
				countdown_enable = 1'b1;
				count_down_from [7:0] =  8'd10; //10 seconds
				
				level_3_enable = 1'b1;
				level_key = 18'b110000110100101110;
				ledr = 18'b110000110100101110;
				ledg = 8'b0;
			end
			
			LEVEL_3_WAIT: begin
				countdown_reset = 1'b1;
				countdown_enable = 1'b0;
				count_down_from [7:0] = 8'd5;
				level_key = 18'b0;
				ledr = 18'b0;
				ledg = 8'b0;
			end
			
			LEVEL_4: begin
				countdown_reset = 1'b0;
				countdown_enable = 1'b1;
				count_down_from [7:0] =  8'd5; //5 seconds
				
				level_4_enable = 1'b1;
				level_key = 18'b111111111110111111;
				ledr = 18'b111111111110111111;
				ledg = 8'b0;
			end
			
			GAME_WON: begin
				//no timer
				countdown_reset = 1'b1; //reset
				countdown_enable = 1'b0; //disabled
				count_down_from [7:0] = 8'b00000000;
				
				game_won_enable = 1'b1;
				ledr = 18'b0;
				ledg = 8'b11111111;
			end
			
			GAME_OVER: begin
				//no timer
				countdown_reset = 1'b1; //reset
				countdown_enable = 1'b0; //disabled
				count_down_from [7:0] = 8'b00000000;
				
				game_over_enable = 1'b1;
				ledr = 18'b111111111111111111;
				ledg = 8'b0;
			end
			
		endcase
	end //enable signals
	
	// current_state registers
    always@(posedge clock)
    begin: state_FFs
        if (win_reset || loss_reset)
            current_state <= STANDBY;
        else
            current_state <= next_state;
    end

endmodule

module level_1(
	input level_en,
	input [17:0] level_key,
	input load_code,
	input [17:0] sw,
	output reg level_1_win
	);
	
	reg [17:0] code;
	
	always @(*) begin
		if (level_en) begin
			
			//send pass signal if correct switches on
			if (load_code) begin
			       code <= sw[17:0];
                if (code == level_key) 
                    level_1_win = 1'b1;
                else
					level_1_win = 1'b0;
			end
		end
		else
				level_1_win = 1'b0;
      end
		
endmodule

module level_2(
	input level_en,
	input [17:0] level_key,
	input load_code,
	input [17:0] sw,
	output reg level_2_win
	);
	
	reg [17:0] code;
	
	always @(*) begin
		if (level_en) begin
			
			//send pass signal if correct switches on
			if (load_code) begin
			       code <= sw[17:0];
                if (code == level_key) 
                    level_2_win = 1'b1;
                else
					level_2_win = 1'b0;
				end
            end
			else
			level_2_win = 1'b0;
      end
		
endmodule

module level_3(
	input level_en,
	input [17:0] level_key,
	input load_code,
	input [17:0] sw,
	output reg level_3_win
	);
	
	reg [17:0] code;
	
	always @(*) begin
		if (level_en) begin
			
			//send pass signal if correct switches on
			if (load_code) begin
			       code <= sw[17:0];
                if (code == level_key) 
                    level_3_win = 1'b1;
                else
					level_3_win = 1'b0;
				end
            end
			else
			level_3_win = 1'b0;
      end
		
endmodule

module level_4(
	input level_en,
	input [17:0] level_key,
	input load_code,
	input [17:0] sw,
	output reg level_4_win
	);
	
	reg [17:0] code;
	
	always @(*) begin
		if (level_en) begin
			
			//send pass signal if correct switches on
			if (load_code) begin
			       code <= sw[17:0];
                if (code == level_key) 
                    level_4_win = 1'b1;
                else
					level_4_win = 1'b0;
				end
            end
			else
			level_4_win = 1'b0;
      end
		
endmodule


// COUNTDOWN-RELATED THINGS:
module instantiate_countdown(clock, countdown_reset, countdown_enable, count_down_from, hex0, hex1, game_over_sig);
	input clock;
	input countdown_reset;
	input countdown_enable;
	input [7:0] count_down_from;
	output [6:0] hex0, hex1;
	output game_over_sig;
	
	wire [7:0] countdown_out;
	wire [3:0] hundreds, tens, ones;
	
	//countdown
	countdown countdown(
		.clk(clock),
		.countdown_enable(countdown_enable),
		.count_down_from(count_down_from),
		.countdown_reset(countdown_reset),
		.countdown_out(countdown_out),
		.game_over_sig(game_over_sig)
		);
		
	//use bcd to convert output of counter to hex
	bcd bcd(
		.number(countdown_out),
		.hundreds(hundreds),
		.tens(tens),
		.ones(ones)
		);
			
	hex_decoder H0(
        .hex_digit(ones), 
        .segments(hex0)
        );
        
	hex_decoder H1(
        .hex_digit(tens), 
        .segments(hex1)
        );
endmodule

module countdown (clk, countdown_enable, count_down_from, countdown_reset, countdown_out, game_over_sig);
	input clk;
	input countdown_enable; //only count if 1
	input [7:0] count_down_from; //8 bits max
	input countdown_reset;
	
	reg [7:0] q = 8'b0; //counter value
	reg [7:0] r; //count up to
	output reg [7:0] countdown_out;
	output reg game_over_sig;
	
	always @(posedge clk) begin
	
	//if enable, count down
		//if it reaches 0, game_over_sig = 1 to control
		
		//actually start at 0 and count up. If counter reaches the count_down_from value,
		//send game_over_signal
		
		r <= count_down_from;
		if (countdown_reset) begin
			q <= 8'b0;
			countdown_out <= 8'b0;
			game_over_sig = 1'b0;
		end
	
		if (countdown_enable) begin
			
			if (q !== r)
				q <= q + 1;
			else if (q == r)
				game_over_sig = 1'b1;

			countdown_out <= r - q;
		end	

	end
endmodule

//credit: http://www.deathbylogic.com/2013/12/binary-to-binary-coded-decimal-bcd-converter/
module bcd(number, hundreds, tens, ones);
   // I/O Signal Definitions
   input  [7:0] number;
   output reg [3:0] hundreds;
   output reg [3:0] tens;
   output reg [3:0] ones;
   
   // Internal variable for storing bits
   reg [19:0] shift;
   integer i;
   
   always @(number)
   begin
      // Clear previous number and store new number in shift register
      shift[19:8] = 0;
      shift[7:0] = number;
      
      // Loop eight times
      for (i=0; i<8; i=i+1) begin
         if (shift[11:8] >= 5)
            shift[11:8] = shift[11:8] + 3;
            
         if (shift[15:12] >= 5)
            shift[15:12] = shift[15:12] + 3;
            
         if (shift[19:16] >= 5)
            shift[19:16] = shift[19:16] + 3;
         
         // Shift entire register left once.hex_digit(test),
         shift = shift << 1;
      end
      
      // Push decimal numbers to output
      hundreds = shift[19:16];
      tens     = shift[15:12];
      ones     = shift[11:8];
   end
 
endmodule

module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;
            default: segments = 7'h7f;
        endcase
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

 
