module datapath(note_data, octave_data, ld_note, ld_play, note_counter, clk, display_note, reset, clear, freq_out, x, y, writeEn, colour);
	input [3:0] note_data;
	input [1:0] octave_data;
	input ld_note;
	input ld_play;
	input [3:0] note_counter;
	input clk;
	input reset;
	input clear;
	input display_note;
	
	output [31:0] freq_out;
	output [7:0] x;
	output [6:0] y;
	output writeEn;
	output [2:0] colour;
	
	
	
	reg [3:0] mem_addr;
	reg [5:0] in_data;
	wire [5:0] note_read;
	
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
				mem_addr <= 0;
				enable <= 1;
				in_data <= 0;
			end
		else
			begin
				if(ld_play)
					begin
						mem_addr <= note_counter;
						enable <= 0;
					end
				else if(ld_note)
					begin
					if(enable == 0)
						begin
							mem_addr <= mem_addr == 4'b1111 ? 0 : mem_addr + 1;
							in_data <= {octave_data, note_data};
							enable <= 1;
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

				 
	vga_data vgad(
					.note(note_read[3:0]), 
					.octave(note_read[5:4]), 
					.clk(CLOCK_50), 
					.clear(clear),
					.ld_note(display_note),
					.x(mem_addr * 36), //from coord picker/datapath
					.y(30), //from coord picker/datapath
					.x_out(x), 
					.y_out(y), 
					.writeEn(writeEn),
					.colour(colour)
					);
endmodule
