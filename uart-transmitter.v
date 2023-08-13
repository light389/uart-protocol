`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023 Samarth Gautam
// ///////////////////////////////////////////////////////////////////////////////
// File Name:      UartProtocol.v
// Type:           Module
// Department:     Electronics And Communication Engineering, B.Tech
// Author:         Samarth Gautam
// Authors' Email: samarthgautam2002@gmail.com
// Create Date:    12:56:10 07/09/2023 
// Module Name:    uart_transmiter 
//////////////////////////////////////////////////////////////////////////////////
// Release History
// 06/22/2021 Samarth Gautam UART Transmiter
// 30/07/2021 Samarth Gautam	two always blocks 
//////////////////////////////////////////////////////////////////////////////////
// Keywords:       UART PROTOCOL. UART Transmiter
//////////////////////////////////////////////////////////////////////////////////
// Purpose:         This transmitter is able to 
//                  transmit 8 bits of serial data, one start bit, one stop bit,
//                  and no parity bit.
// Constants:       Frequency of clock = 25MHz and Baud Rate = 115200bps
//                  CLOCKS PER BIT = (Frequency of clock)/(Baud Rate)
//						  CLOCKS PER BIT = 217
//////////////////////////////////////////////////////////////////////////////////
module UART_Transmitter
	#(parameter CLOCKS_PER_BIT = 217)(
    input [7:0] databus,
	 input valid,
	 input clk,
	 output reg outserial
	 );
parameter IDLE = 2'b00, START = 2'b01, DATABIT = 2'b10, STOP = 2'b11;

reg [1:0] next_state;
reg [7:0] clock_count;
reg [2:0] index;

always @(posedge clk)
begin
	case(next_state)
		IDLE: begin
					if(valid == 1'b1)
						next_state <= START;
					else 
						next_state <= IDLE;
		      end
		
		START: begin
					if(clock_count < CLOCKS_PER_BIT - 1)
							next_state <= START;
					else 
							next_state <= DATABIT;
			end
				
		DATABIT: begin
						if(clock_count < CLOCKS_PER_BIT - 1)
								next_state <= DATABIT;
						else
							begin
								if(index < 3'b111)
									next_state <= DATABIT;
								else
									next_state <= STOP;
							end
					end
		STOP: begin
					if(clock_count < CLOCKS_PER_BIT - 1)
							next_state <= STOP;
					else 
							next_state <= IDLE;
				end
		
		default: next_state<=IDLE;
	endcase
end

	always @(next_state)
		begin
			case(next_state)
			IDLE: begin
				index = 1'h0;
				if(valid == 1'b1)
					clock_count = 0;
			      end
			START: begin
				outserial<=1'b0;
				clock_count= (clock_count < CLOCKS_PER_BIT - 1) ? (clock_count + 1'b1) : 1'b0;
				end
			DATABIT:begin
				outserial <= databus[index];
						if(clock_count < CLOCKS_PER_BIT - 1)
							clock_count = clock_count + 1'b1;
						else
							begin
								clock_count = 1'b0;
								index = (index < 1'b111) ? index + 1'b1 : 1'b0;
							end
			        end
			STOP: begin
				outserial = 1'b1;
				clock_count= (clock_count < CLOCKS_PER_BIT - 1) ? (clock_count + 1'b1) : 1'b0;
			      end
			endcase
	 	end
endmodule
