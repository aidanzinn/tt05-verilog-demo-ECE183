module MVM_Accelerator (
    input start,                    
    input clk,                      
    input rst_n,                    
    input [1:0] row_val,            
    input [7:0] value,              
    input [1:0] column_val,         
    input sending_CPU,
    input done_list,

    output reg [7:0] output_val,    
    output reg sending_out,
    output reg FETCH_ready
);

reg [1:0] row_pointers[8:0];       
reg [7:0] values[8:0];             
reg [1:0] column_indices[8:0];     
reg [7:0] result[2:0];              
reg [2:0] spike_train = 3'b000;    

parameter [2:0] IDLE        = 3'b000,   
                TRANSMIT    = 3'b001,   
                COMPUTE     = 3'b010,   
                FETCH_CSR   = 3'b011,   
                FETCH_TRAIN = 3'b100;   

reg [2:0] state = IDLE;
reg [1:0] current_row = 0;  
reg [3:0] i = 0;    
reg [1:0] j = 0;            
  
reg [7:0] interval;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;          
        current_row <= 0;
        interval <= 0;
        i <= 0;
        j <= 0;
        spike_train <= 3'b000;
    end else begin
        case (state)
            /*----------------------------------------
            *       Initial State
            *---------------------------------------*/
            IDLE: begin
                current_row <= 0;
                interval <= 0;
                i <= 0;
                j <= 0;
                spike_train <= 3'b000;
                sending_out <= 1;
                if (start) begin                    
                    state <= FETCH_CSR;
                  
                end
            end
            /*----------------------------------------
            *       Get Time Multiplexed Inputs
            *---------------------------------------*/
            FETCH_CSR: begin
                FETCH_ready <= 1;
                if (done_list) begin           
                    FETCH_ready <= 0;                   
                    state <= FETCH_TRAIN;               
                    i <= 0;                       
                end else if (sending_CPU) begin                  
                    FETCH_ready <= 0;                   
                    row_pointers[i] <= row_val;         
                    column_indices[i] <= column_val;    
                    values[i] <= value;
                    i <= i + 1;                           
                end   
            end     
            /*----------------------------------------
            *       Get Spiking Inputs
            *---------------------------------------*/
            FETCH_TRAIN: begin

                FETCH_ready <= 1;                       
                if (sending_CPU) begin
                    spike_train <= value[3:0];          
                    FETCH_ready <= 1;                   
                    state <= COMPUTE;                    
                end            
            end
            /*----------------------------------------
            *       Do Multiplication
            *---------------------------------------*/
            COMPUTE: begin                
                if (row_pointers[i] == current_row) begin
                    interval <= ((spike_train[column_indices[i]])*(values[i])) + interval;
                    i <= i + 1;
                end else if (current_row > 2) begin
                    i <= 0;
                    interval <= 0;
                    current_row <= 0;
                    sending_out <= sending_out ^ 1'b1;
                    state <= TRANSMIT;
                end else begin
                    result[current_row] <= interval;
                    interval <= 0;
                    current_row <= current_row + 1;
                end                                                 
            end
            /*----------------------------------------
            *       Send Outputs
            *---------------------------------------*/
            TRANSMIT: begin               
                output_val <= result[j];
                sending_out <= sending_out^1'b1;
                j <= j+1;

                if (j>2) begin
                    state <= IDLE;  
                    j <= 0; 
               end 
            end 

            default: state <= IDLE;
        endcase
    end
end

endmodule
