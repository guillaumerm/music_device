module freq_select(note, octave, note_freq);
	
	input [3:0] note;
	input [1:0] octave;


	output reg [31:0] note_freq;
	wire enable;
	always@(*)
	begin
		case(note)
			//Range of A's
			4'b0000 : note_freq = 220 * (octave + 1);
			//Range of A#'s
			4'b0001: note_freq = 233 * (octave + 1);
			//Range of B's	
			4'b0010: note_freq = 246 * (octave + 1);
			//Range of C's
			4'b0011: note_freq = 261 * (octave + 1);
			//Range of C#'s
			4'b0100: note_freq = 277 * (octave + 1);
			//Range of D's
			4'b0101: note_freq = 293 * (octave + 1);
			//Range of D#'s
			4'b0110: note_freq = 311 * (octave + 1);
			//Range of E's
			4'b0111: note_freq = 329 * (octave + 1);
			//Range of F's
			4'b1000: note_freq = 349 * (octave + 1);
			//Range of F#'s
			4'b1001: note_freq = 370 * (octave + 1);
			//Range of G's
			4'b1010: note_freq = 391 * (octave + 1);
			//Range of G#'s
			4'b1011: note_freq = 415 * (octave + 1);
			

			default: note_freq = 0;
		endcase
	end


endmodule
