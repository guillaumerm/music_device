module freq_select(note, octave, note_freq);
	
	input [3:0] note;
	input [1:0] octave;


	output reg [31:0] note_freq;
	wire enable;
	always@(*)
	begin
		case(note)
			//Range of A's
			1 : note_freq = 220 * (octave + 1);
			//Range of A#'s
			2: note_freq = 233 * (octave + 1);
			//Range of B's	
			3: note_freq = 246 * (octave + 1);
			//Range of C's
			4: note_freq = 261 * (octave + 1);
			//Range of C#'s
			5: note_freq = 277 * (octave + 1);
			//Range of D's
			6: note_freq = 293 * (octave + 1);
			//Range of D#'s
			7: note_freq = 311 * (octave + 1);
			//Range of E's
			8: note_freq = 329 * (octave + 1);
			//Range of F's
			9: note_freq = 349 * (octave + 1);
			//Range of F#'s
			10: note_freq = 370 * (octave + 1);
			//Range of G's
			11: note_freq = 391 * (octave + 1);
			//Range of G#'s
			12: note_freq = 415 * (octave + 1);
			

			default: note_freq = 0;
		endcase
	end


endmodule
