module ADDER #(parameter DATA_WIDTH = 16)(
    input [DATA_WIDTH-1:0] a,
    input [DATA_WIDTH-1:0] b,
    output reg [DATA_WIDTH-1:0] sum
);

always @(*) begin
    sum = a + b;
end
endmodule

