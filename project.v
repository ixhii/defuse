module project(CLOCK_50, LEDR, LEDG, SW, KEY,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
		);

		// Do not change the following outputs
	output		VGA_CLK;   					//	VGA Clock
	output		VGA_HS;						//	VGA H_SYNC
	output		VGA_VS;						//	VGA V_SYNC
	output		VGA_BLANK_N;					//	VGA BLANK
	output		VGA_SYNC_N;					//	VGA SYNC
	output	[9:0]	VGA_R;   					//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 					//	VGA Green[9:0]
	output	[9:0]	VGA_B;   					//	VGA Blue[9:0]
		
	input [17:0] SW;
	input CLOCK_50;
	input [3:0] KEY;
	output [17:0] LEDR;
	output [7:0] LEDG;
	/*
	wire acc_x, acc_y, acc_instr, make_instr, ld_in, check_ans, fail, win, scr_done, ins_done, check_done, check, done_y, gen_done, x_out, y_out;
	*/
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(KEY[0]),
			.clock(CLOCK_50),
			.colour(color),
			.x(x_out),
			.y(y_out),
			.plot(plot),
			/* Signals for the DAC to drive the monitor. */
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
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
	
	//assign LEDG = colour;
	
	wire get_rand3,
		get_rand18,
		instr_reset, 
		instr_next, 
		square_reset, 
		square_draw,
		black_reset,
		black_draw,
		gen_done_reset,
		load_module,
		load_instruct,
		load_code,
		module_reset,
		fail1,
		win,
		gen_done,
		check_done,
		fail2,
		plot;
		
	wire [12:0] black_counter;
	wire [4:0] square_counter;
	wire [3:0] instr_counter;
	wire [6:0] x_out;
	wire [5:0] y_out;
	wire [2:0] randOut; 
	wire [5:0] state;
	wire [2:0] color;
	
	
	datapath d0(
		.clk(CLOCK_50),
		.resetn(KEY[0]),
		.get_rand3(get_rand3),
		.get_rand18(get_rand18),
		.instr_reset(instr_reset), 
		.instr_next(instr_next),
		.square_reset(square_reset), 
		.square_draw(square_draw), 
		.black_reset(black_reset), 
		.black_draw(black_draw),
		.gen_done_reset(gen_done_reset), 
		.load_module(load_module), 
		.load_instruct(load_instruct), 
		.load_code(load_code),  
		.module_reset(module_reset), 
		.fail_in(fail1), 
		.win_in(win),
		.SW(SW),
		.KEY(KEY),
		.gen_done(gen_done),
		.check_done(check_done),
		.fail_out(fail2),
		.plot(plot),
		.instr_counter(instr_counter),
		.black_counter(black_counter),
		.square_counter(square_counter),
		.x_out(x_out),
		.y_out(y_out),
		.LEDG_out(LEDG),
		.LEDR_out(LEDR),
		.randOut(randOut),
		.state(state),
		.colorOut(color)
	);
	
	control c0(
		.clk(CLOCK_50),
		.resetn(KEY[0]),
		.gen_rand3(get_rand3),
		.gen_rand18(get_rand18),
		.instr_reset(instr_reset), 
		.instr_next(instr_next),
		.square_reset(square_reset), 
		.square_draw(square_draw), 
		.black_reset(black_reset), 
		.black_draw(black_draw),
		.gen_done_reset(gen_done_reset), 
		.load_module(load_module), 
		.load_instruct(load_instruct), 
		.load_code(load_code),  
		.module_reset(module_reset), 
		.fail_out(fail1), 
		.win_out(win),
		.gen_done(gen_done),
		.check_done(check_done),
		.fail_in(fail2),
		.instr_counter(instr_counter),
		.black_counter(black_counter),
		.square_counter(square_counter),
		.randOut(randOut),
		.state(state),
		.KEY(KEY)
	);




endmodule

module randomizer3(
	clock,
	randOut,
	get);

	input clock, get;
	output reg [2:0] randOut;

	reg [1:0] int_rand;

	always @(posedge clock)
	begin
		if(get) begin
			randOut <= int_rand + 3'b001;
		end
		else begin
			int_rand <= int_rand + 3'b001;
		end
	end

endmodule

module randomizer18(clock, out, get);
	input clock, get;
	output reg [17:0] out;
	
	reg [17:0] int_rand;
	
	always @(posedge clock)
	begin
		if(get) begin
			out <= int_rand;
		end
		else begin
			int_rand[8:0] <= int_rand[8:0] + 1'b1;
			int_rand[17:9] <= (!out ^ int_rand[17:9]) + 1'b1;
		end
	end
	
endmodule

module datapath(
	clk,
	resetn,
	get_rand3,
	get_rand18,
	instr_reset, 
	instr_next,
	square_reset, 
	square_draw, 
	black_reset, 
	black_draw, 
	gen_done_reset, 
	load_module, 
	load_instruct, 
	load_code,  
	module_reset, 
	fail_in, 
	win_in,
	SW,
	KEY,
	gen_done,
	check_done,
	fail_out,
	plot,
	instr_counter,
	black_counter,
	square_counter,
	x_out,
	y_out,
	LEDG_out,
	LEDR_out,
	state,
	randOut,
	colorOut);
	
	input clk, 
		resetn, 
		get_rand3,
		get_rand18,
		instr_reset,
		instr_next, 
		square_reset, 
		square_draw, 
		black_reset, 
		black_draw, 
		gen_done_reset,
		load_module,
		load_instruct,
		load_code,  
		module_reset, 
		fail_in, 
		win_in;
	input [3:0] KEY;
	input [17:0] SW;
	input [5:0] state;
	

	output reg gen_done, check_done, fail_out, plot;	
	output reg [12:0] black_counter;
	output reg [4:0] square_counter;
	output reg [3:0] instr_counter;
	output reg [6:0] x_out;
	output reg [5:0] y_out;
	output reg [17:0] LEDR_out;
	output reg [7:0] LEDG_out;
	output reg [2:0] randOut;
	output reg [2:0] colorOut;
	
	wire [17:0] r18Out;
	wire [2:0] r3Out;
	wire [17:0] mod1_LEDR, mod2_LEDR, mod3_LEDR, mod4_LEDR, mod5_LEDR, mod6_LEDR;
	wire [7:0] mod1_LEDG, mod2_LEDG, mod3_LEDG, mod4_LEDG, mod5_LEDG, mod6_LEDG;
	wire mod1_done, mod1_fail, mod2_done, mod2_fail, mod3_done, mod3_fail, mod4_done, mod4_fail, mod5_done, mod5_fail, mod6_done, mod6_fail;
	
	
	// setup internal modules
	randomizer3 r3(
		.clock(clk),
		.randOut(r3Out),
		.get(get_rand3));
		
	randomizer18 r18(
		.clock(clk),
		.out(r18Out),
		.get(get_rand18));
	
	red mod4(.rand_in(code), .LEDR(mod4_LEDR), .LEDG(mod4_LEDG), .SW(SW), .KEY(KEY), .Finished(mod4_done), .failed(mod4_fail));
	blue mod1(.rand_in(code), .LEDR(mod1_LEDR), .LEDG(mod1_LEDG), .SW(SW), .KEY(KEY), .Finished(mod1_done), .failed(mod1_fail));
	green mod2(.rand_in(code), .LEDR(mod2_LEDR), .LEDG(mod2_LEDG), .SW(SW), .KEY(KEY), .Finished(mod2_done), .failed(mod2_fail));
	yellow mod6(.rand_in(code), .LEDR(mod6_LEDR), .LEDG(mod6_LEDG), .SW(SW), .KEY(KEY), .Finished(mod6_done), .failed(mod6_fail));
	cyan mod3(.rand_in(code), .LEDR(mod3_LEDR), .LEDG(mod3_LEDG), .SW(SW), .KEY(KEY), .Finished(mod3_done), .failed(mod3_fail));
	purple mod5(.rand_in(code), .LEDR(mod5_LEDR), .LEDG(mod5_LEDG), .SW(SW), .KEY(KEY), .Finished(mod5_done), .failed(mod5_fail));
	//dummy mod6(.rand_in(code), .LEDR(mod6_LEDR), .LEDG(mod6_LEDG), .SW(SW), .KEY(KEY), .Finished(mod6_done), .failed(mod6_fail), .clk(clk));

	// set up internal registers
	
	reg [2:0] instr_0;
   reg [2:0] instr_1;
   reg [2:0] instr_2;
   reg [2:0] instr_3;
   reg [2:0] instr_4;
	reg [2:0] temp_wht;
	reg [6:0] x_start;
	reg [5:0] y_start;
	reg [17:0] code;
	reg [17:0] LEDR_mod;
	reg [7:0] LEDG_mod;
	reg [12:0] instr_screen_counter;
	reg [3:0] challenge_module;

	always @(posedge clk)
	begin
		randOut[2:0] = r3Out[2:0];
		plot <= 1'b0;
		if(!resetn) begin
			
			instr_0   <= 8'd0;
			instr_1   <= 8'd0;
			instr_2   <= 8'd0;
			instr_3   <= 8'd0;
			instr_4   <= 8'd0;
			code   <= 8'd0;
			gen_done <= 1'd0;
		end
		else begin
	
			// used to reset the instruction counters
			if(instr_reset) begin
				instr_counter <= 3'd0;
				instr_screen_counter <= 5'd0;
			end
			
			// used to 	// save randoms to LEDmove to the next instruction
			if(instr_next) begin
				instr_counter <= instr_counter + 1'd1;
				instr_screen_counter <= instr_screen_counter + 2'd3;
			end
			
			// used to reset the screen counters
			if(square_reset) begin
				y_start <= 6'd20;
				x_start <= 7'd20;
				square_counter <= 5'd0;
			end
			
			// used to draw the instruction squares
			if(square_draw) begin
					//enableP <= 1'b1;
					colorOut <= r3Out;
					x_out <= x_start[6:0] + square_counter[1:0] + instr_screen_counter;
					y_out <= y_start[5:0] + square_counter[3:2];
					square_counter <= square_counter + 1'b1;
					plot <= 1'd1;
					 
			end
			
			// Used to reset the values for blacking the screen
			if(black_reset) begin
				black_counter <= 13'b0;
			end
			
			// Used to black the screen
			if(black_draw) begin
				colorOut <= 3'b111;
				x_out <= black_counter[6:0];
				y_out <= black_counter[12:7];
				black_counter <= black_counter + 1'b1;
				plot <= 1'd1;
			end
			
			// Used to reset the gen_done register
			if(gen_done_reset) begin
				gen_done <= 1'd0;
			end
			
			// Used to load the various instruction registers
			if(load_instruct) begin
				case(instr_counter)
					3'd0: instr_0 <= r3Out;
					3'd1: instr_1 <= r3Out;
					3'd2: instr_2 <= r3Out;
					3'd3: instr_3 <= r3Out;
					3'd4: instr_4 <= r3Out;
					default: temp_wht <= r3Out;
				endcase
			end
			
			// Used to load the code given to the player
			if(load_code) begin
				code <= r18Out;
			end
			
			// Used to set which module to check
			if(load_module) begin
				case(instr_counter)
					3'd0: challenge_module <= instr_0;
					3'd1: challenge_module <= instr_1;
					3'd2: challenge_module <= instr_2;
					3'd3: challenge_module <= instr_3;
					3'd4: challenge_module <= instr_4;
					default: challenge_module <= 3'd1;
				endcase
				
				case(challenge_module)
					3'd1: begin
						check_done <= mod1_done;
						fail_out <= mod1_fail;
						LEDG_mod <= mod1_LEDG;
						LEDR_mod <= mod1_LEDR;
					end
					3'd2: begin
						check_done <= mod2_done;
						fail_out <= mod2_fail;
						LEDG_mod <= mod2_LEDG;
						LEDR_mod <= mod2_LEDR;
					end
					3'd3: begin
						check_done <= mod3_done;
						fail_out <= mod3_fail;
						LEDG_mod <= mod3_LEDG;
						LEDR_mod <= mod3_LEDR;
					end
					3'd4: begin
						check_done <= mod4_done;
						fail_out <= mod4_fail;
						LEDG_mod <= mod4_LEDG;
						LEDR_mod <= mod4_LEDR;
					end
					3'd5: begin
						check_done <= mod5_done;
						fail_out <= mod5_fail;
						LEDG_mod <= mod5_LEDG;
						LEDR_mod <= mod5_LEDR;
					end
					3'd6: begin
						check_done <= mod6_done;
						fail_out <= mod6_fail;
						LEDG_mod <= mod6_LEDG;
						LEDR_mod <= mod6_LEDR;
					end
					default: begin
						check_done <= 1'd0;
						fail_out = 1'd0;
						LEDG_mod <= 8'b11111111;
						LEDR_mod <= 18'b111111111111111111;
					end
				endcase
				
				gen_done <= 1'd1;
				
			end
			
			if(fail_in) begin
				LEDR_out <= 18'b111111111111111111;
				LEDG_out <= 8'b00000000;
			end
			else if(win_in) begin
				LEDG_out <= 8'b11111111;
				LEDR_out <= 18'b000000000000000000;
			end
			else begin
				LEDG_out[7:0] <= LEDG_mod;
				LEDR_out <= LEDR_mod;
			end

		end
			
		
	end

endmodule

module control (
	clk,
	resetn,
	gen_done,
	check_done,
	fail_in,
	black_counter,
	square_counter,
	instr_counter,
	instr_reset,
	randOut,
	square_reset,
	square_draw,
	black_reset,
	black_draw,
	gen_rand3,
	gen_rand18,
	load_instruct,
	instr_next,
	load_module,
	module_reset,
	load_code,
	gen_done_reset,
	fail_out,
	state,
	win_out,
	KEY);

	input clk, resetn, gen_done, check_done, fail_in;	
	input [12:0] black_counter;
	input [4:0] square_counter;
	input [3:0] instr_counter;
	input [2:0] randOut;
	input [3:0] KEY;
	
	
	output reg instr_reset, 
		instr_next, 
		load_instruct, 
		square_reset, 
		square_draw, 
		black_reset, 
		black_draw, 
		gen_rand3,
		gen_rand18,
		module_reset, 
		load_module, 
		load_code, 
		gen_done_reset,
		fail_out, 
		win_out;
		
	output [5:0] state;
	
	reg [6:0] current_state, next_state;
	
	assign state = current_state;

	localparam
		S_RESET_VALS 			= 6'd0,
		S_BLANK_SCREEN			= 6'd1,
		S_GEN_INSTRUCT			= 6'd2,
		S_CHECK_RAND			= 6'd3,
		S_LOAD_INSTRUCT 		= 6'd4,
		S_CHECK_INSTRUCT_DONE 	= 6'd5,
		S_PREP_GAME 			= 6'd6,
		S_GEN_CODE				= 6'd7,
		S_LOAD_CODE				= 6'd8,
		S_CHECK					= 6'd9,
		S_CHECK_WAIT			= 6'd10,
		S_CHECK_FAIL			= 6'd11,
		S_FAIL					= 6'd12,
		S_CHECK_WIN				= 6'd13,
		S_WIN					= 6'd14,
		S_NEXT_INSTR			= 6'd15;

	always @(*)
	begin: state_table
		case(current_state)
			S_RESET_VALS: next_state = S_BLANK_SCREEN;
			S_BLANK_SCREEN: next_state = (black_counter[12:0] >= 13'b1111111111111)  ? S_GEN_INSTRUCT : S_BLANK_SCREEN;
			S_GEN_INSTRUCT: next_state =  S_CHECK_RAND;
			S_CHECK_RAND: next_state = (randOut != 3'b000 && randOut != 3'b111) ? S_LOAD_INSTRUCT : S_GEN_INSTRUCT;
			S_LOAD_INSTRUCT: next_state = (square_counter[4:0] >= 5'b10000) ? S_CHECK_INSTRUCT_DONE : S_LOAD_INSTRUCT;
			S_CHECK_INSTRUCT_DONE: next_state = (instr_counter[2:0] >= 3'b101) ? S_PREP_GAME : S_GEN_INSTRUCT;
			S_PREP_GAME: next_state = S_GEN_CODE;
			S_GEN_CODE: next_state = gen_done ? S_LOAD_CODE : S_GEN_CODE;
			S_LOAD_CODE: next_state = S_CHECK;
			S_CHECK: next_state = check_done ? S_CHECK_WAIT : S_CHECK;
			S_CHECK_WAIT: next_state = (KEY[3:1] == 3'b111) ? S_CHECK_FAIL : S_CHECK_WAIT;
			S_CHECK_FAIL: next_state = !fail_in ? S_CHECK_WIN : S_FAIL;
			S_CHECK_WIN: next_state = (instr_counter[2:0] >= 3'b101) ? S_WIN : S_NEXT_INSTR;
			S_NEXT_INSTR: next_state = S_GEN_CODE;
			S_WIN: next_state = S_WIN;
			S_FAIL: next_state = S_FAIL;

			// end
			default: next_state = S_RESET_VALS;
		endcase
	end

	always @(*)
	begin: enable_signals
		
		instr_reset = 1'd0;
		square_reset = 1'd0;
		square_draw = 1'd0;
		black_reset = 1'd0;
		black_draw = 1'd0;
		gen_rand3 = 1'd0;
		gen_rand18 = 1'd0;
		load_instruct = 1'd0;
		instr_next = 1'd0;
		load_module = 1'd0;
		module_reset = 1'd0;
		load_code = 1'd0;
		gen_done_reset = 1'd0;
		fail_out = 1'd0;
		win_out = 1'd0;


		case(current_state)
			
			S_RESET_VALS: begin
				instr_reset = 1'd1;
				square_reset = 1'd1;
				black_reset = 1'd1;
				module_reset = 1'd1;
			end
			
			S_BLANK_SCREEN: begin
				black_draw = 1'b1;
			end
			
			S_GEN_INSTRUCT: begin
				gen_rand3 = 1'd1;
			end
			
			S_LOAD_INSTRUCT: begin
				square_draw = 1'b1;
				load_instruct = 1'd1;
            end
			
			S_CHECK_INSTRUCT_DONE: begin
				instr_next = 1'd1;
				square_reset = 1'd1;
			end
			
			S_PREP_GAME: begin
				instr_reset = 1'd1;
			end
			
			S_GEN_CODE: begin
				gen_rand18 = 1'd1;
				load_module = 1'd1;
			end
			
			S_LOAD_CODE: begin
				load_code = 1'd1;
				gen_done_reset = 1'd1;
			end
			
			S_CHECK: begin
				load_module = 1'd1;
			end
			
			S_FAIL: begin	// save randoms to LED
				fail_out = 1'd1;
			end
			
			S_WIN: 	begin
				win_out = 1'd1;
			end
			
			S_NEXT_INSTR: begin
				instr_next = 1'd1;
				module_reset = 1'd1;
			end
			
		endcase
	end

	always @(posedge clk)
	begin: state_FFs
		if(!resetn)
			current_state <= S_RESET_VALS;
		else
			current_state <= next_state;
	end
endmodule

module dummy(rand_in, LEDR, LEDG, SW, KEY, Finished, failed, clk);
	input [17:0] SW, rand_in;
	input [3:0] KEY;
	input clk;
	output reg [17:0] LEDR;
	output reg [7:0] LEDG;
	output reg Finished, failed;
	
	always @(posedge clk)
	begin
		LEDR <= rand_in;
		LEDG[3:0] <= KEY;
		LEDG[7] <= Finished;
		LEDG[6] <= failed;
		failed  <= 0;
		if(!KEY[1]) begin
			Finished <= 1'b1;
		end
		else begin
			Finished <= 1'b0;
		end
		
		if(!KEY[2]) begin
			failed <= 1'b1;
		end
		else begin
			failed <= 1'b0;
		end
		
	end
	/*always @(posedge KEY[1])
	begin
		Finished <= 1'b1;
	end*/
	/*
	always @(negedge KEY[2])
	begin
		failed <= 1'd1;
	end
	*/
endmodule

module blue(rand_in, LEDR, LEDG, SW, KEY, Finished, failed);
	input [17:0] SW, rand_in;
	input [3:0] KEY;
	output reg [17:0] LEDR;
	output reg [7:0] LEDG;
	output reg Finished, failed;

	// NUMBERS
	reg [7:0] num1, num2;
	reg [8:0] sum;

	
	
	// save randoms to LED
	always @(*)
	begin
		if(!KEY[1] & KEY[2] & KEY[3]) begin
			if(sum == SW[8:0]) begin
				failed <= 1'b0;
			end
			else begin
				failed <= 1'b1;
			end
			Finished <= 1'b1;
		end
		else begin
			Finished <= 1'b0;
			failed <= 1'b0;
			num1 <= rand_in[7:0];
			num2 <= rand_in[17:10];
			LEDR[7:0] <= num1;
			LEDR[17:10] <= num2;
			sum <= num1 + num2;
			
		end
		
	end

endmodule

module green(rand_in, LEDR, LEDG, SW, KEY, Finished, failed);
	input [17:0] SW, rand_in;
	input [3:0] KEY;
	output reg [17:0] LEDR;
	output reg [7:0] LEDG;
	output reg Finished, failed;

	// NUMBERS
	reg [7:0] num1;
	reg [2:0] num2;
	reg [12:0] prod;
	

	// save randoms to LED
	always @(*)
	begin
		if(KEY[1] & !KEY[2] & KEY[3]) begin		
			if(prod == SW[12:0]) begin
				failed <= 1'b0;
			end
			else begin
				failed <= 1'b1;
			end
			Finished <= 1'b1;
		end
		else begin
			num1 <= rand_in[7:0];
			num2 <= rand_in[12:10];
			LEDR[7:0] <= num1;
			LEDG[2:0] <= num2;
			prod <= num1 * num2;
			Finished <= 1'b0;
			failed <= 1'b0;
		end
	end

endmodule

module red(rand_in, LEDR, LEDG, SW, KEY, Finished, failed);
	input [17:0] SW, rand_in;
	input [3:0] KEY;
	output reg [17:0] LEDR;
	output reg [7:0] LEDG;
	output reg Finished, failed;
	
	
	always @(*)
	begin
		if(!KEY[1] & !KEY[2] & !KEY[3]) begin
			LEDR[17:1] <= rand_in[17:1];
			if(SW[0])begin
				if(SW[17:1] == rand_in[17:1]) begin
					failed <= 1'b0;
				end
				else begin
					failed <= 1'b1;
				end
				Finished <= 1'b1;
			end
		end
		else begin
			Finished <= 1'b0;
			failed <= 1'b0;
			LEDR[17:0] <= 18'b0;
		end
	end
endmodule


module yellow(rand_in, LEDR, LEDG, SW, KEY, Finished, failed);
	input [17:0] SW, rand_in;
	input [3:0] KEY;
	output reg [17:0] LEDR;
	output reg [7:0] LEDG;
	output reg Finished, failed;

	reg [5:0] num1, num2, ans;

	always @(*)
	begin
		if(KEY[1] & KEY[2] & !KEY[3]) begin
			if(ans == SW[5:0]) begin
				failed <= 1'b0;
			end
			else begin
				failed <= 1'b0;
			end
			Finished <= 1'b1;
		end
		else begin
			num1 <= rand_in[5:0];
			num2 <= rand_in[12:7];
			ans <= num1 ^ num2;
			LEDR[5:0] <= num1[5:0];
			LEDR[12:7] <= num2[5:0];
			Finished <= 1'b0;
			failed <= 1'b0;
		end
	end
endmodule

module cyan(rand_in, LEDR, LEDG, SW, KEY, Finished, failed);
	input [17:0] SW, rand_in;
	input [3:0] KEY;
	output reg [17:0] LEDR;
	output reg [7:0] LEDG;
	output reg Finished, failed;
	reg [16:0] ans;

	always @(*)
	begin
		if(!KEY[1] & KEY[2] & !KEY[3]) begin
			LEDR[16:0] <= rand_in[16:0];
			if(SW[17])begin
				if(ans == SW[16:0]) begin
					failed <= 1'b0;
				end
				else begin
					failed <= 1'b0;
				end
				Finished <= 1'b1;
			end
		end
		else begin
			ans <= !rand_in[16:0];
			Finished <= 1'b0;
			failed <= 1'b0;
			LEDR[17:0] <= 18'b0;
		end
	end
endmodule

module purple(rand_in, LEDR, LEDG, SW, KEY, Finished, failed);
	input [17:0] SW, rand_in;
	input [3:0] KEY;
	output reg [17:0] LEDR;
	output reg [7:0] LEDG;
	output reg Finished, failed;

	reg [8:0] Xord;

	always @(*)
	begin
		if(!KEY[1] & !KEY[2] & KEY[3]) begin
			LEDR <= rand_in;
			if(SW[8:0] == rand_in[8:0] & SW[17:9] == Xord) begin
				failed <= 1'b0;
			end
			else begin
				failed <= 1'b1;
			end
			Finished <= 1'b1;
		end
		else begin
			Xord = 8'b11111111 ^ rand_in[17:9];
			Finished <= 1'b0;
			failed <= 1'b0;
			LEDR[17:0] <= 18'b0;
		end
	end
endmodule


