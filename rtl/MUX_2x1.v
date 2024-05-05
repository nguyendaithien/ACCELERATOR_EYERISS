module MUX_2x1 #(parameter DATA_WIDTH = 16)(
    input [DATA_WIDTH-1:0] a,
    input [DATA_WIDTH-1:0] b,
    input sel,
    output reg [DATA_WIDTH-1:0] y
);

always @(*) begin
    if (sel)
        y = b;
    else
        y = a;
end

endmodule

