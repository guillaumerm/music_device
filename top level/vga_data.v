module vga_data(note, octave, clk, clear, ld_note, x, y, x_out, y_out, writeEn, colour);
	input [3:0] note;
	input [1:0] octave;
	input clk;
	input [7:0] x;
	input [6:0] y;
	input clear;
	input ld_note;
	output [7:0] x_out;
	output [6:0] y_out;
	output writeEn;
	output [2:0] colour;
	
	
	//144 (12x12) bit representation of note	
	reg [143:0] letter;
	reg [143:0] sharp;
	reg [143:0] oct;
	
	localparam a = 144'b000000000000000001100000000011110000000111111000001110011100001100001100001100001100001100001100001111111100001111111100001100001100001100001100,
					
					b = 144'b000000000000001111111000001111111100001100001100001100001100001100001100001111111000001111111000001100001100001100001100001111111100001111111000,
					c = 144'b000000000000000111111000001111111100001100001100001100000000001100000000001100000000001100000000001100000000001100001100001111111100000111111000,
							 
					d = 	144'b000000000000001111111000001111111100000110001100000110001100000110001100000110001100000110001100000110001100001111111100001111111000000000000000,
					e = 	144'b000000000000001111111100001111111100001100000000001100000000001111100000001111100000001100000000001100000000001111111100001111111100000000000000,
					f = 	144'b000000000000000111111100001111111100001100000000001100000000001111100000001111100000001100000000001100000000001100000000001100000000000000000000,						
					g = 144'b000000000000000111111000001111111100001100000000001100000000001100000000001100111100001100111100001100001100001100001100001111111100000111111000,
					s = 144'b000000000000001100001100001100001100011111111110011111111110001100001100001100001100001100001100011111111110011111111110001100001100001100001100,
					one = 144'b000000000000000000001100000000001100000000001100000000001100000000001100000000001100000000001100000000001100000000001100000000001100000000000000,
					two = 144'b000000000000001111111100001111111100000000001100000000001100001111111100001111111100001100000000001100000000001111111100001111111100000000000000,
					three = 144'b000000000000001111111100001111111100000000001100000000001100001111111100001111111100000000001100000000001100001111111100001111111100000000000000,
					four = 144'b000000000000001100001100001100001100001100001100001100001100001111111100001111111100000000001100000000001100000000001100000000001100000000000000;				

	always@(*)
	begin

			begin
				case(note)
					4'b0001 : 
						begin
							letter <= a;
							sharp  <= 0;
						end
					4'b0010 : 
						begin
							letter <= a;
							sharp  <= s;
						end
					4'b0011 :
						begin
							letter <= b;
							sharp  <= 0;
						end					
					4'b0100 :
						begin
							letter <= c;
							sharp  <= 0;
						end					
					4'b0101 :
						begin
							letter <= c;
							sharp  <= s;
						end					
					4'b0110 :
						begin
							letter <= d;
							sharp  <= 0;
						end					
					4'b0111 :
						begin
							letter <= d;
							sharp  <= s;
						end					
					4'b1000 :
						begin
							letter <= e;
							sharp  <= 0;
						end					
					4'b1001 :
						begin
							letter <= f;
							sharp  <= 0;
						end					
					4'b1010 :
						begin
							letter <= f;
							sharp  <= s;
						end					
					4'b1011 :
						begin
							letter <= g;
							sharp  <= 0;
						end					
					4'b1100 :
						begin
							letter <= g;
							sharp  <= s;
						end					
			
			default : 
						begin
							letter <= 0;
							sharp  <= 0;
						end

			endcase
			end
			begin
				case(octave)
					2'b00 : oct <= one;
					2'b01 : oct <= two;
					2'b10 : oct <= three;
					2'b11 : oct <= four;
			
					default : oct <= 0;
				endcase
			end
	end

	
	draw_note draw(.clk(clk), 
						.letter(letter), 
						.oct(oct), 
						.sharp(sharp), 
						.x(x), 
						.y(y),
						.ld_note(ld_note),
						.clear(clear),
						.writeEn(writeEn),
						.colour(colour),
						.x_out(x_out),
						.y_out(y_out)
						);
	
endmodule

module draw_note(clk,letter,oct,sharp,x,y, ld_note, clear, writeEn,colour,x_out,y_out);
	input clk;
	input [143:0] letter;
	input [143:0] oct;
	input [143:0] sharp;
	input [7:0] x;
	input [6:0] y;
	input clear;
	input ld_note;
	output reg writeEn;
	output reg [2:0] colour;
	output reg [7:0] x_out;
	output reg [6:0] y_out;
	
	reg [7:0] counter = 143;
	reg [7:0] x_count = 0;
	reg [6:0] y_count = 0;

	localparam x_symbol_offset = 12;
	reg draw_sharp, draw_octave, draw_n;
	
	always@(clk)
	begin
		if(ld_note)
		begin
			if(x_count < 12)
			begin
				if(y_count < 12)
				begin
					x_count <= x_count + 1;
				end
				else
				begin
					y_count <= 0;
				end
			end
			else
			begin
				if(y_count < 12)
				begin
					y_count <= y_count + 1;
				end
				else
				begin
					x_count <= 0;
					y_count <= 0;
				end
			end
		end
	end
	
	always@(clk)
	begin
		if(ld_note)
		begin
			writeEn <= 1;
			colour <= 3'b100;
			x_out <= x + x_count;
			y_out <= y + y_count;	
		end
		else
		begin
			x_out <= x;
			y_out <= y;
			writeEn <= 0;
		end
	end
	
	//sharp
	/*always@(clk)
	begin
	if(!clear)
		begin
			colour <= 3'b000;
			writeEn <= 1;
			draw_sharp <= 0;
			draw_n <= 0;
			draw_octave <=0;
			
			if(x_count < 160)
				begin
					x_out <= x_count;
					y_out <= y_count;
					x_count <= x_count + 1;
				end
			else if (x_count == 160 && y_count < 120)
				begin
					x_count <= 0;
					y_count <= y_count + 1;
				end
			else
				begin
					x_count <= 0;
					y_count <= 0;
				end
		end
	else if(ld_note)
		begin
			if(draw_sharp)
				begin
					if(x_count < 12 && y_count < 12)
						begin
							writeEn <= sharp[counter];
							if (writeEn)
								begin
									colour <= 3'b010;
								end
							x_out <= x + x_count;
							x_count <= x_count + 1;
							y_out <= y + y_count;
						end
					else if (x_count == 12 && y_count == 11)
						begin
							x_count <=  0;
							y_count <= 0;
							draw_sharp <= 0;
							draw_n <= 1;
							writeEn <= 0;
						end
					else if (x_count == 12 && y_count < 12)
						begin
							x_count <=  0;
							y_count <= y_count + 1;
						end
				end
			else if(draw_n)
				begin
					if(x_count < 12 && y_count < 12)
						begin
							writeEn <= letter[counter];
							if (writeEn)
								begin
									colour <= 3'b010;
										
								end
							//Offset included
							x_out <= x + x_count + x_symbol_offset;
							x_count <= x_count + 1;
							y_out <= y + y_count;
						end
					else if (x_count == 12 && y_count == 11)
						begin
							x_count <=  0;
							y_count <= 0;
							draw_n <= 0;
							draw_octave <= 1;
							writeEn <= 0;
						end
					else if (x_count == 12 && y_count < 12)
						begin
							x_count <=  0;
							y_count <= y_count + 1;
						end
				end
			else if(draw_octave)
				begin
					if(x_count < 12 && y_count < 12)
						begin
							writeEn <= oct[counter];
							if (writeEn)
							begin
								colour <= 3'b010;
							end
							//offset included
							x_out <= x + x_count + (x_symbol_offset * 2);
							x_count <= x_count + 1;
							y_out <= y + y_count;			
						end
					else if (x_count == 12 && y_count == 11)
						begin
								x_count <=  0;
								y_count <= 0;
								draw_octave <= 0;
								draw_sharp <= 1;
								writeEn <= 0;
						end
					else if (x_count == 12 && y_count < 12)
						begin						
								x_count <=  0;
								y_count <= y_count + 1;
						end
				end
			else
				begin
					writeEn <= 0;
					draw_sharp <= 1;
					draw_octave <= 0;
					draw_n <= 0;
					x_out <= x;
					y_out <= y;
					x_count <= 0;
					y_count <= 0;
				end
		end
		else
			begin
					writeEn <= 0;
					draw_sharp <= 0;
					draw_octave <= 0;
					draw_n <= 0;
					x_out <= x;
					y_out <= y;
					x_count <= 0;
					y_count <= 0;
				end
	end
	
	//counter track
	always@(clk)
	begin
		if(!clear)
			counter <= 0;
		else if(ld_note)
		begin
			if(counter == 0)
				counter <= 143;
			else
				counter <= counter - 1;
		end
		else
			counter <= 0;
	end*/

endmodule

/*
module vga_note_reset(input some reset enable so it knows to "reset" output colours and pixels that get changed)
endmodule

module vga_highlight(inputs note position and some enable so it knows its changing colours, outputs colours and pixels that get changed)
endmodule

choose_coord(x, y, x_pos, y_pos, sharp_offset, octave_offset)
*/