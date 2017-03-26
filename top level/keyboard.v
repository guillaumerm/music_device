module convert_keyboard_input(keyboard_code, makeBreak, load_n, playback, note, octave);
	input [7:0] keyboard_code;
	input makeBreak;
	output reg load_n;
	output reg playback;
	output reg [3:0] note;
	output reg [1:0] octave;
	

	
	
	localparam K_A = 8'h1C, //A
				  K_AS = 8'h15, //Q
				  K_B = 8'h1B, //S
				  K_C = 8'h23, //D
				  K_CS = 8'h24, //W
				  K_D = 8'h2B, //F
				  K_DS = 8'h2D, //R
				  K_E = 8'h34, //G
				  K_F = 8'h33, //H
				  K_FS = 8'h35, //Y
				  K_G = 8'h3B, //J
				  K_GS = 8'h3C, //U
				  K_1 = 8'h16,
				  K_2 = 8'h1E,
				  K_3 = 8'h26,
				  K_4 = 8'h25,
				  K_BKSP = 8'h66,
				  K_SPACE = 8'h29,
				  K_ENTER = 8'h5A;
	
	// Convert key to input
	always@(*)
	begin
			case(keyboard_code)
				// A
				K_A : note = makeBreak ? 1 : note;
				
				// A#
				K_AS : note = makeBreak ? 2 : note;
				
				// B	
				K_B: note = makeBreak ? 3 : note;
				
				// C
				K_C : note = makeBreak ? 4 : note;	
				
				// C#
				K_CS : note = makeBreak ? 5 : note;
				
				// D
				K_D : note = makeBreak ? 6 : note;	
				
				// D#
				K_DS : note = makeBreak ? 7 : note;
				
				// E
				K_E : note = makeBreak ? 8 : note;
				
				// F
				K_F : note = makeBreak ? 9 : note;
				
				// F#
				K_FS : note = makeBreak ? 10 : note;
				
				// G
				K_G : note = makeBreak ? 11 : note;	
				
				// G#
				K_GS : note = makeBreak ? 12 : note;	
				
				//Octave 0
				K_1 : octave = 0;
				
				//Octave 1
				K_2 : octave = 1;
				
				//Octave 2
				K_3 : octave = 2;
				
				//Octave 3
				K_4 : octave = 3;
				
				//Playback
				K_ENTER : playback = 0;
				
				//Load notes
				K_SPACE : load_n = 0;
				
				default : 
					begin
						octave = 0;
						note = 0;
						playback = 1;
						load_n = 1;
					end
			endcase
			
	end
	
	

endmodule