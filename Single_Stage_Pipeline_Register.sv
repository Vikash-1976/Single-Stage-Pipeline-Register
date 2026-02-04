`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.02.2026 22:37:11
// Design Name: 
// Module Name: Pipeline_Register
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module pipeline_register #(
    parameter int DATA_WIDTH = 32
) (
    input  logic                  clk,
    input  logic                  rst_n,     // Active low reset

    input  logic                  in_valid,
    output logic                  in_ready,
    input  logic [DATA_WIDTH-1:0] in_data,

    output logic                  out_valid,
    input  logic                  out_ready,
    output logic [DATA_WIDTH-1:0] out_data
);

    logic                  valid_reg;
    logic [DATA_WIDTH-1:0] data_reg;

    assign in_ready = (!valid_reg) || out_ready;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_reg <= 1'b0;
            data_reg  <= '0;     
        end else begin
         
            if (in_ready) begin
                valid_reg <= in_valid;
                
              
                if (in_valid) begin
                    data_reg <= in_data;
                end
            end
        end
    end

 
    assign out_valid = valid_reg;
    assign out_data  = data_reg;


  
    property p_stable_data_on_stall;
        @(posedge clk) disable iff (!rst_n)
        (out_valid && !out_ready) |=> ($stable(out_data) && out_valid);
    endproperty
    
    property p_reset_state;
        @(posedge clk) $fell(rst_n) |=> (out_valid == 0);
    endproperty

    a_stable_stall: assert property(p_stable_data_on_stall) 
                    else $error("Protocol Violation: Data lost during backpressure!");
    a_reset_check:  assert property(p_reset_state) 
                    else $error("Reset Failure: Valid bit not cleared!");

endmodule
