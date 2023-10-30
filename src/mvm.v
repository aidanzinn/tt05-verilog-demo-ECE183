
module MVM_Accelerator (
    input [3:0] spike_train,       // 4-input spike train
    input start,                   // Signal to start MVM
    input clk,                     // Clock
    input rst,                     // Reset
    input [1:0] row_pointers[15:0],      // CSR row pointers for 4x4 matrix
    input [15:0] values[15:0],           // CSR values for 4x4 matrix (assuming max 16 non-zero values)
    input [1:0] column_indices[15:0],   // CSR column indices for 4x4 matrix (assuming max 16 non-zero values)
    output reg [15:0] result[3:0],       // Resultant output after MVM
    output reg done
);

parameter [1:0] IDLE    = 2'b00,
                ADD     = 2'b01,
                COMPUTE = 2'b10;

reg [1:0] state = IDLE;

reg [1:0] current_row = 0;  // Current row being processed
reg [3:0] i=0;

reg [15:0] interval;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        current_row <= 0;
    end else begin
        case (state)
            IDLE: begin
                if (start) begin
                    state <= COMPUTE;
                    done <= 0;
                end
            end

            COMPUTE: begin
                
                if (row_pointers[i] == current_row) begin
                    interval <= ((spike_train[column_indices[i]])*(values[i])) + interval;
                    i <= i + 1;
                end else if (current_row > 3) begin
                    done <= 1;
                    state <= IDLE;
                end else begin
                    result[current_row] <= interval;
                    interval <= 0;
                    current_row <= current_row + 1;
                end                                               
            end

            default: state <= IDLE;
        endcase
    end
end

endmodule