module alu_4bit(
    input  [3:0] a,
    input  [3:0] b,
    input  [2:0] opcode,
    output [3:0] result,
    output       carry_out
);

    // Internal signals
    wire [3:0] sum;
    wire       carry_internal;

    // Instantiate a 4-bit full adder for addition
    full_adder fa0(a[0], b[0], 1'b0, sum[0], carry_internal);
    full_adder fa1(a[1], b[1], carry_internal, sum[1], carry_internal);
    full_adder fa2(a[2], b[2], carry_internal, sum[2], carry_internal);
    full_adder fa3(a[3], b[3], carry_internal, sum[3], carry_out);

    // Multiplexer to select between operations
    always @(*) begin
        case (opcode)
            3'b000: // Addition
                result = sum;
            3'b001: // Subtraction (A - B)
                result = a + (~b) + 1; // 2's complement subtraction
            3'b010: // AND
                result = a & b;
            3'b011: // OR
                result = a | b;
            3'b100: // XOR
                result = a ^ b;
            3'b101: // NOT A
                result = ~a;
            default:
                result = 4'bxxxx; // Undefined
        endcase
    end

endmodule

// Define a 1-bit full adder module
module full_adder(
    input  a,
    input  b,
    input  cin,
    output sum,
    output cout
);
    wire w1, w2, w3;
    xor x1(w1, a, b);
    xor x2(sum, w1, cin);
    and a1(w2, a, b);
    and a2(w3, w1, cin);
    or  o1(cout, w2, w3);
endmodule 
