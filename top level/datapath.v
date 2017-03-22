module datapath(note_data, octave_data, ld_note, ld_play, note_counter, clk, reset, freq_out);
	input [3:0] note_data;
	input [1:0] octave_data;
	input ld_note;
	input ld_play;
	input [3:0] note_counter;
	input clk;
	input reset;
	
	output [31:0] freq_out;
	
	reg [3:0] notes_recorded;
	
	wire [5:0] note_read;

	reg enable;
  
	memory main(.address(notes_recorded),
				 .clock(clk),
				 .data({octave_data, note_data}),
				 .wren(enable),
				 .q(note_read[5:0])
				);
	
	always@(posedge clk)
	begin
		if(!reset)
			begin
				notes_recorded <= 0;
				enable <= 0;
			end
		else
			begin
				if(ld_play)
					begin
						notes_recorded <= note_counter;
						enable <= 0;
					end
				else if(ld_note)
					begin
					if(enable <= 0)
						begin
							notes_recorded <= notes_recorded == 4'b1111 ? 0 : notes_recorded + 1;
							enable <= 1;
						end
					end
				else
					enable <= 0;
			end
	end
	
  freq_select fs(.note(note_read[3:0]), 
				  .octave(note_read[5:4]), 
				  .note_freq(freq_out[31:0])
				 );

endmodule
