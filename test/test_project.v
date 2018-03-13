module test_project(KEY, HEX0, HEX1);
input [3:0] KEY;
output [6:0] HEX0, HEX1;

wire [7:0] countdown_out;
wire [3:0] hundreds, tens, ones;

countdown countdown(
		.clk(KEY[0]), //KEY 0 as clock
		.count_down_from(8'd15), //15 seconds
		//.enable(1'b1),
		.countdown_reset(1'b0),
		.countdown_out(countdown_out)
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
        .segments(HEX0)
        );
        
hex_decoder H1(
        .hex_digit(tens), 
        .segments(HEX1)
        );
		
endmodule


module countdown (clk, count_down_from, countdown_reset, countdown_out);
	input clk;
	input [7:0] count_down_from; //8 bits max
	//input enable;
	input countdown_reset;
	reg [7:0] q;
	output reg [7:0] countdown_out;
	
	always @(posedge clk)
	begin
		if (countdown_reset)
			q <= 0;
		else if (q == 0) 
			q <= count_down_from;
		else
			q <= q - 1;
			//enable <= (q == 0) ? 0 : 1; //should stay at 0 when done (disabled)
		
		countdown_out <= q;
		
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
         
         // Shift entire register left once
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