module datapath(note_data, octave_data, ld_note, ld_play, note_counter, clk, display_note, reset, next_note_en, notes_recorded, freq_out, x_out, y_out, writeEn, colour);
	input [3:0] note_data;
	input [1:0] octave_data;
	input ld_note;
	input ld_play;
	input [3:0] note_counter;
	input clk;
	input reset;
	input display_note;
	input next_note_en;
	input [3:0] notes_recorded;
	output [31:0] freq_out;
	output [7:0] x_out;
	output [6:0] y_out;
	output writeEn;
	output [2:0] colour;
	
	
	
	reg [3:0] mem_addr;
	reg [2:0] colour_in;
	reg [5:0] in_data;
	wire [5:0] note_read;
	wire [7:0] x;
	wire [6:0] y;
	reg enable;

	memory main(.address(mem_addr),
				 .clock(clk),
				 .data(in_data),
				 .wren(enable),
				 .q(note_read[5:0])
				);
				
	always@(posedge clk)
	begin
		if(!reset)
			begin
				mem_addr <= notes_recorded;
				enable <= 1;
				in_data <= 0;
				colour_in <= 3'b000;
			end
		else
			begin
				if(ld_play)
					begin
						if(note_counter != 0)
							mem_addr <= note_counter - 1;
						else
							mem_addr <= notes_recorded + 1;
						enable <= 0;
						colour_in <= 3'b110;
					end
				else if(ld_note)
					begin
					if(enable == 0)
						begin
							mem_addr <= mem_addr == notes_recorded ? 0 : mem_addr + 1;
							in_data <= {octave_data, note_data};
							enable <= 1;
							colour_in <= 3'b100;
						end
					end
				else
					begin	
						enable <= 0;
						in_data <= 0;
					end
			end
	end
	
	
  freq_select fs(.note(note_read[3:0]), 
				  .octave(note_read[5:4]), 
				  .note_freq(freq_out[31:0])
				 );

	coord_picker cds(.mem_addr(mem_addr),
						  .x_out(x),
						  .y_out(y)
						 );
	vga_data vgad(
					.note(note_read[3:0]), 
					.octave(note_read[5:4]), 
					.clk(clk), 
					.reset(reset),
					.ld_note(ld_note),
					.ld_play(next_note_en),
					.colour_in(colour_in),
					.x(x), //from coord picker/datapath
					.y(y), //from coord picker/datapath
					.x_out(x_out), 
					.y_out(y_out), 
					.writeEn(writeEn),
					.colour(colour)
					);
					
endmodule

module coord_picker(mem_addr, x_out, y_out);
	input [3:0] mem_addr;
	output reg [7:0] x_out;
	output reg [6:0] y_out;
	
	always@(*)
	begin
		case(mem_addr)
		0 : 
			begin
				x_out = 4;
				y_out = 4;
			end
		1 :
			begin
				x_out = 4 + 36 + 4;
				y_out = 4;
			end
		2 :
			begin
				x_out =  4 + 36 +  4 + 36 +  4;
				y_out = 4;
			end
		3 :
			begin
				x_out =  4+ 36 +  4 + 36 +  4 + 36 + 4;
				y_out = 4;
			end
		4 :
			begin
				x_out = 4;
				y_out = 4 + 12 + 4;
			end
		5 :
			begin
				x_out = 4 + 36 + 4;
				y_out = 4 + 12 + 4;
			end
		6 :
			begin
				x_out = 4 + 36 + 4 + 36 + 4;
				y_out = 4 + 12 + 4;
			end
		7 :
			begin
				x_out = 4 + 36 + 4 + 36 + 4 + 36 + 4;
				y_out = 4 + 12 + 4;
			end
		8 :
			begin
				x_out = 4;
				y_out = 4 + 12 + 4 + 12 + 4;
			end
		9 :
			begin
				x_out = 4 + 36 + 4;
				y_out = 4 + 12 + 4 + 12 + 4;
			end
		10 :
			begin
				x_out = 4 + 36 + 4 + 36 + 4;
				y_out = 4 +12 + 4 + 12 + 4;
			end
		11 :
			begin
				x_out = 4 + 36 + 4 + 36 + 4 + 36 + 4;
				y_out = 4 + 12 + 4 + 12 + 4;
			end
		12 :
			begin
				x_out = 4;
				y_out = 4 + 12 + 4 + 12 + 4 +12 + 4;
			end
		13 :
			begin
				x_out = 4 + 36 + 4;
				y_out = 4 +12 + 4 + 12 + 4 + 12 + 4;
			end
		14 :
			begin
				x_out = 4 + 36 + 4 + 36 + 4;
				y_out = 4 + 12 + 4 + 12 + 4 + 12 + 4;
			end
		15 :
			begin
				x_out = 4 + 36 + 4 + 36 + 4 + 36 + 4;
				y_out = 4 + 12 + 4 + 12 + 4 + 12 + 4;
			end
		default :
			begin
				x_out = 0;
				y_out = 0;
			end
		
	endcase
end
endmodule
