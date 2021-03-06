
`include "uart_define.v"

module baudrate_generator( 
	input 			clk,
	input 			rst_n,
	input 			baud_en,
	input 	[15:0]	divisor,
	
	output 			tx_data_sample,
	output  		rx_data_sample
);
	parameter SAMPLE 		= 4'hf;
	
	//=========================  REGISTER FOR GENERATOR CNT  =============================//
	reg [15:0]	sample_cnt;
	reg [3:0]	baud_cnt;
	
	reg     	baud_clk_r;
    reg			sample_clk_r;

	//===================  GET SAMPLE_CLK BY DIV SYSTEM_CLK  ========================//
	//divide clk to get sample_clk	
	always @(posedge clk or negedge rst_n) 
		if(!rst_n) begin 
			sample_clk_r <= 1'b0;
			sample_cnt <= 16'b0;
		end 
		else if(baud_en) begin 
			if(sample_cnt == divisor) begin 
				sample_cnt <= 16'b0;
				sample_clk_r <= 1'b1;
			end 
			else begin 
				sample_cnt <= sample_cnt + 1;
				sample_clk_r <= 1'b0;
			end 
		end 
		else begin 
			sample_clk_r <= 1'b0;
			sample_cnt <= 16'b0;
		end 
	
	//=======================  GETTING POS OF sample_CLK  ==========================//
	assign rx_data_sample = sample_clk_r;

		
	//===================  GET BAUD_CLK BY DIV SAMPLE_CLK  ========================//
	//sample_clk's frequence divide sample will get baud_clk
	always @(posedge clk or negedge rst_n)
		if(!rst_n) begin 
			baud_cnt <= 16'b0;
			baud_clk_r <= 1'b0;
		end 
		else if(rx_data_sample) begin 
			if(baud_cnt == SAMPLE)  begin 
				baud_cnt <= 16'b0;
				baud_clk_r <= 1'b1;
			end 
			else begin 
				baud_cnt <= baud_cnt + 1;
				baud_clk_r <= 1'b0;
			end 
		end 
		else if(!baud_en) begin 
			baud_cnt <= 16'b0;
			baud_clk_r <= 1'b0;
		end 
		else begin 
			baud_cnt <= baud_cnt;
			baud_clk_r <= 1'b0;
		end 

	//=======================  GETTING POS OF BAUD_CLK  ==========================//
	assign tx_data_sample = baud_clk_r;


endmodule 
 
 
 
 