`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023 Vaibhav Sharma
// ///////////////////////////////////////////////////////////////////////////////
// File Name:      UartProtocol.v
// Type:           Module
// Department:     Electronics And Communication Engineering, B.Tech
// Author:         Samarth Gautam
// Authors' Email: samarthgautam2002@gmail.com
// Create Date:    04:32:10 04/01/2023  
// Module Name:    uart_receiver 
//////////////////////////////////////////////////////////////////////////////////
// Release History
// 06/22/2021 Vaibhav Sharma UART Receiver
//////////////////////////////////////////////////////////////////////////////////
// Keywords:       UART PROTOCOL. UART Receiver
//////////////////////////////////////////////////////////////////////////////////
// Purpose:         This receiver is able to 
//                  receive 8 bits of serial data, one start bit, one stop bit,
//                  and no parity bit.
// Constants:       Frequency of clock = 25MHz and Baud Rate = 115200bps
//                  CLOCKS PER BIT = (Frequency of clock)/(Baud Rate)
//						  CLOCKS PER BIT = 217
//////////////////////////////////////////////////////////////////////////////////
module UART_Receiver
#(parameter CLOCKS_PER_BIT= 217)(
    input clk,
	 input dataserial,
	 output reg [7:0] dataouts
	 );
	 
parameter IDLE = 2'b00, START = 2'b01, DATABIT = 2'b10, STOP = 2'b11;

reg [1:0] next_state;
reg [7:0] clock_count;
reg [2:0] index;

always @(posedge clk)
begin
	case(next_state)
		IDLE: begin
					next_state <= (dataserial==1'b0) ? START: IDLE;
				end
		
		START: begin
					if(clock_count == ((CLOCKS_PER_BIT - 1)/2))
						begin
							if(dataserial == 1'b0)
								begin
								next_state <= DATABIT;
								end
							else 
								next_state <= IDLE;
							end
					else
						begin
							next_state  <= START;
						end
					end
		
		DATABIT: begin
						if(clock_count < (CLOCKS_PER_BIT -1))
							begin
							next_state  <= DATABIT;
							end
						else
							begin
							
							if(index < 3'b111)
								begin
								next_state <= DATABIT;
								end
							else
								begin
								next_state <= STOP;
								end
							end
						end
			
		STOP: begin
					if(clock_count < (CLOCKS_PER_BIT -1))
						begin
							if(dataserial == 1'b1)
								begin
									next_state <= STOP;
								end
							else 
									next_state <=IDLE;
						end
					else 
						begin
							next_state <= STOP;
						end
					end
		default: next_state <= IDLE;
	endcase
end
	
	always @(next_state)
		begin
			case(next_state)
				IDLE:
					begin
						clock_count = 8'b0;
						index =3'b0;
					end
				START:
					begin
						if(clock_count == ((CLOCKS_PER_BIT - 1)/2))
						begin
							if(dataserial == 1'b0)
								begin
								clock_count = 8'b0;
								end
						else
							begin
								clock_count = clock_count +1'b1;
							end
						end
					end
				DATABIT:
					begin
						if(clock_count < (CLOCKS_PER_BIT -1))
							begin
							clock_count = clock_count + 1'b1;
							end
						else
							begin
							clock_count = 8'b0;
							dataouts[index]= dataserial;
							
							if(index < 3'b111)
								begin
								index = index + 1'b1;
								end
							else
								begin
								index = 3'b0;
								end
							end
					end
				STOP:
					begin
						if(clock_count < (CLOCKS_PER_BIT -1))
							begin
								if(dataserial == 1'b1)
									begin
										clock_count = 8'b0;
									end
							end
						else 
							begin
								clock_count = clock_count + 1'b1;
							end
					end
			endcase
		end
	
endmodule
