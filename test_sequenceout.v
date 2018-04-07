

module test_sequenceout(CLOCK_50, SW, LEDR);
    input CLOCK_50;
    input [2:0] SW;
    output[17:0] LEDR;
    
    wire rate_out;
    sequence_output seq(
        .seq_in(18'b111111111111111111),
        .enable(SW[1]),
        .clock(rate_out),
        .out(LEDR[17]),
        .output_dec(LEDR[4:0])
    );
    ratedivider_28bit div(
        .clock(CLOCK_50),
        .d(28'b0010111110101111000001111111),
        .enable(rate_out)
    );
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
                output_dec <= 5'b11111;
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

 
