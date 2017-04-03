module vga_data(note, octave, clk, reset, ld_note, ld_play, colour_in, x, y, x_out, y_out, writeEn, colour);
	input [3:0] note;
	input [1:0] octave;
	input clk;
	input [7:0] x;
	input [6:0] y;
	input reset;
	input ld_note;
	input ld_play;
	input [2:0] colour_in;
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
						.ld_play(ld_play),
						.reset(reset),
						.colour_in(colour_in),
						.writeEn(writeEn),
						.colour(colour),
						.x_out(x_out),
						.y_out(y_out)
						);
	
endmodule

module draw_note(clk,letter,oct,sharp,x,y, ld_note, ld_play, reset, colour_in, writeEn, colour, x_out,y_out);
	input clk;
	input [143:0] letter;
	input [143:0] oct;
	input [143:0] sharp;
	input [7:0] x;
	input [6:0] y;
	input reset;
	input ld_note;
	input ld_play;
	input [2:0] colour_in;
	output reg writeEn;
	output reg [2:0] colour;
	output reg [7:0] x_out;
	output reg [6:0] y_out;
	
	reg [7:0] x_count = 0;
	reg [6:0] y_count = 0;
	
	//first state
	reg [7:0] prev_x = 0;
	reg [6:0] prev_y = 0;
	
	reg enable_counter_144, enable_counter_19200;
	reg [4:0] current_state, next_state;
	reg [143:0] local_letter, local_oct, local_sharp, prev_letter, prev_oct, prev_sharp, clear_letter, clear_oct, clear_sharp, clear_pletter, clear_poct, clear_psharp;
	
	localparam S_DRAW_SHARP = 5'b00000,
				  S_DRAW_NOTE = 5'b00001,
				  S_DRAW_OCT = 5'b00010,
				  S_DRAW_WAIT = 5'b00011,
				  S_RESET = 5'b00100,
				  S_CLEAR = 5'b00101,
				  S_DRAW_WAIT_GO = 5'b00110,
				  S_RESET_COUNT = 5'b00111,
				  S_CLEAR_COUNT = 5'b01000,
				  S_DS_COUNT = 5'b01001,
				  S_DN_COUNT = 5'b01010,
				  S_DO_COUNT = 5'b01011,
				  
				  S_DRAW_PSHARP = 5'b01100,
				  S_DRAW_PNOTE = 5'b01101,
				  S_DRAW_POCT = 5'b01110,
				  S_PCLEAR = 5'b01111,
				  S_PCLEAR_COUNT = 5'b10000,
				  S_PDS_COUNT = 5'b10001,
				  S_PDN_COUNT = 5'b10010,
				  S_PDO_COUNT = 5'b10011,
				  S_LOAD_PREV = 5'b10100;
	
	always@(*)
	begin
		case(current_state)
			S_RESET:
				begin
				if(!reset)
					next_state = S_RESET;
				else
					next_state = y_count == 119 ? S_DRAW_WAIT : S_RESET;
				end
			S_RESET_COUNT:
				begin
					next_state = S_RESET;
				end
			S_CLEAR:
				begin
				if(!reset)
					next_state = S_RESET_COUNT;
				else
					begin
					if(ld_note)
						next_state = clear_letter == 0 && clear_sharp == 0 && clear_oct == 0 ? S_DRAW_WAIT_GO : S_CLEAR;
					else
						next_state = clear_letter == 0 && clear_sharp == 0 && clear_oct == 0 ? S_DS_COUNT : S_CLEAR;
					end
				end
			S_CLEAR_COUNT:
				begin
					next_state = S_CLEAR;
				end
			S_DRAW_SHARP:
				begin
				if(!reset)
					next_state = S_RESET_COUNT;
				else
					begin
						next_state = local_sharp == 0 ? S_DN_COUNT : S_DRAW_SHARP;
					end
				end
			S_DS_COUNT:
				begin
					next_state = S_DRAW_SHARP;
				end
			S_DRAW_NOTE:
				begin
				if(!reset)
					next_state = S_RESET_COUNT;
				else
					begin
						next_state = local_letter == 0  ? S_DO_COUNT : S_DRAW_NOTE;
					end
				end
			S_DN_COUNT:
				begin
					next_state = S_DRAW_NOTE;
				end
			S_DRAW_OCT:
				begin
				if(!reset)
					next_state = S_RESET_COUNT;
				else
					begin
						next_state = local_oct == 0 ? S_PCLEAR_COUNT : S_DRAW_OCT;
					end
				end
			S_DO_COUNT:
				begin
					next_state = S_DRAW_OCT;
				end
			S_DRAW_WAIT:
				begin
				if(!reset)
					next_state = S_RESET_COUNT;
				next_state = ld_note||ld_play ? S_CLEAR_COUNT : S_DRAW_WAIT;
				end
			S_DRAW_WAIT_GO:
				begin
				if(!reset)
					next_state = S_RESET_COUNT;
				next_state = ld_note ? S_DRAW_WAIT_GO : S_DRAW_SHARP;
				end
				
			//states for redrawing previous note
			S_PCLEAR:
				begin
				if(!reset)
					next_state = S_RESET_COUNT;
				else
					begin
						next_state = clear_letter == 0 && clear_sharp == 0 && clear_oct == 0 ? S_PDS_COUNT : S_PCLEAR;
					end
				end
			S_PCLEAR_COUNT:
				begin
					next_state = S_PCLEAR;
				end
			S_DRAW_PSHARP:
				begin
				if(!reset)
					next_state = S_RESET_COUNT;
				else
					begin
						next_state = local_sharp == 0 ? S_PDN_COUNT : S_DRAW_PSHARP;
					end
				end
			S_PDS_COUNT:
				begin
					next_state = S_DRAW_PSHARP;
				end
			S_DRAW_PNOTE:
				begin
				if(!reset)
					next_state = S_RESET_COUNT;
				else
					begin
						next_state = local_letter == 0  ? S_PDO_COUNT : S_DRAW_PNOTE;
					end
				end
			S_PDN_COUNT:
				begin
					next_state = S_DRAW_PNOTE;
				end
			S_DRAW_POCT:
				begin
				if(!reset)
					next_state = S_RESET_COUNT;
				else
					begin
						next_state = local_oct == 0 ? S_LOAD_PREV : S_DRAW_POCT;
					end
				end
			S_LOAD_PREV:
				begin
				if(!reset)
					next_state = S_RESET_COUNT;
				else
					next_state = S_DRAW_WAIT;
				end
			S_PDO_COUNT:
				begin
					next_state = S_DRAW_POCT;
				end
				
			default :
				begin
				if(!reset)
					next_state = S_RESET_COUNT;
				else
					next_state = S_DRAW_WAIT;
				end
		endcase
	end
	
	always@(posedge clk)
	begin

		current_state <= next_state;
	end
	
		// Output logic of the signals
	always@(*)
	begin
		case(current_state)
			S_RESET:
				begin
					enable_counter_19200 <= 1;
					enable_counter_144 <= 0;
				end
			S_RESET_COUNT:
				begin
					enable_counter_19200 <= 0;
					enable_counter_144 <= 0;
				end
			S_CLEAR:
				begin
					enable_counter_19200 <= 0;
					enable_counter_144 <= 1;
				end
			S_CLEAR_COUNT:
				begin
					enable_counter_19200 <= 0;
					enable_counter_144 <= 0;
				end
			S_DRAW_SHARP:
				begin
					enable_counter_19200 <= 0;
					enable_counter_144 <= 1;
				end
			S_DS_COUNT:
				begin
					enable_counter_19200 <= 0;
					enable_counter_144 <= 0;
				end
			S_DRAW_NOTE:
				begin
					enable_counter_19200 <= 0;
					enable_counter_144 <= 1;
				end
			S_DN_COUNT:
				begin
					enable_counter_19200 <= 0;
					enable_counter_144 <= 0;
				end
			S_DRAW_OCT:
				begin
					enable_counter_19200 <= 0;
					enable_counter_144 <= 1;
				end
			S_DO_COUNT:
				begin
					enable_counter_19200 <= 0;
					enable_counter_144 <= 0;
				end
			S_DRAW_WAIT:
				begin
					enable_counter_19200 <= 0;
					enable_counter_144 <= 0;
				end
				
			//draw over old notes
			S_PCLEAR:
				begin
					enable_counter_19200 <= 0;
					enable_counter_144 <= 1;
				end
			S_PCLEAR_COUNT:
				begin
					enable_counter_19200 <= 0;
					enable_counter_144 <= 0;
				end
			S_DRAW_PSHARP:
				begin
					enable_counter_19200 <= 0;
					enable_counter_144 <= 1;
				end
			S_PDS_COUNT:
				begin
					enable_counter_19200 <= 0;
					enable_counter_144 <= 0;
				end
			S_DRAW_PNOTE:
				begin
					enable_counter_19200 <= 0;
					enable_counter_144 <= 1;
				end
			S_PDN_COUNT:
				begin
					enable_counter_19200 <= 0;
					enable_counter_144 <= 0;
				end
			S_DRAW_POCT:
				begin
					enable_counter_19200 <= 0;
					enable_counter_144 <= 1;
				end
			S_PDO_COUNT:
				begin
					enable_counter_19200 <= 0;
					enable_counter_144 <= 0;
				end
			default :
				begin
					enable_counter_19200 <= 0;
					enable_counter_144 <= 0;
				end
		endcase
	end
	
	always@(posedge clk)
	begin
			if(enable_counter_144)
			begin	
				if(x_count < 11)
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
					if(y_count < 11)
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
			end
			else if(enable_counter_19200)
			begin
				if(x_count < 159)
				begin
					if(y_count < 120)
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
					if(y_count < 119)
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
			end
			else
			begin
				x_count <= 0;
				y_count <= 0;
			end
	end
	
	always@(posedge clk)
	begin
		//include real reset and shift clear ot one's later...
			case(current_state)
				S_RESET:
					begin
						colour <= 3'b000;
						writeEn <= 1;
						x_out <= x_count;
						y_out <= y_count;
						local_oct[143:0] <= oct[143:0];
						local_letter[143:0] <= letter[143:0];
						local_sharp[143:0] <= sharp[143:0];
						prev_oct <= 0;
						prev_letter <= 0;
						prev_sharp <= 0;
						clear_letter <= 2**144 - 1;
						clear_oct <= 2**144 - 1;
						clear_sharp <= 2**144 - 1;
						clear_pletter <= 2**144 - 1;
						clear_poct <= 2**144 - 1;
						clear_psharp <= 2**144 - 1;
					end
				S_DRAW_SHARP:
					begin
									colour <= colour_in;
									if(local_sharp != 0)
										begin
											writeEn <= local_sharp[143];
											local_sharp <= local_sharp << 1;
											x_out <= x + x_count;
											y_out <= y + y_count;
										end
									else
									begin
										writeEn <= 0;
									end
					end
				S_DRAW_NOTE:
					begin
									colour <= colour_in;
									if(local_letter != 0)
										begin
											writeEn <= local_letter[143];
											local_letter <= local_letter << 1;
											x_out <= x + 12 + x_count;
											y_out <= y + y_count;
										end
									else
									begin
										writeEn <= 0;
									end
					end
				S_DRAW_OCT:
					begin
									colour <= colour_in;
									if(local_oct != 0)
										begin
											writeEn <= local_oct[143];
											local_oct <= local_oct << 1;
											x_out <= x + 24 + x_count;
											y_out <= y + y_count;
										end
									else
									begin
										writeEn <= 0;
									end
					end
				S_CLEAR:
					begin
									colour <= 3'b000;
									if(clear_sharp != 0)
										begin
											writeEn <= clear_sharp[143];
											clear_sharp <= clear_sharp << 1;
											x_out <= x + x_count;
											y_out <= y + y_count;
										end
									else if(clear_letter != 0)
										begin
											writeEn <= clear_letter[143];
											clear_letter <= clear_letter << 1;
											x_out <= x + 12 + x_count;
											y_out <= y + y_count;
										end
									else if(clear_oct != 0)
										begin
											writeEn <= clear_oct[143];
											clear_oct <= clear_oct << 1;
											x_out <= x + 24 + x_count;
											y_out <= y + y_count;
										end
									else
									begin
										writeEn <= 0;
										local_oct[143:0] <= oct[143:0];
										local_letter[143:0] <= letter[143:0];
										local_sharp[143:0] <= sharp[143:0];
										
										x_out <= x;
										y_out <= y;	
									end
					end
					
				S_DRAW_PSHARP:
					begin
									colour <= 3'b100;
									if(prev_sharp != 0)
										begin
											writeEn <= prev_sharp[143];
											prev_sharp <= prev_sharp << 1;
											x_out <= prev_x + x_count;
											y_out <= prev_y + y_count;
										end
									else
									begin
										writeEn <= 0;
									end
					end
				S_DRAW_PNOTE:
					begin
									colour <= 3'b100;
									if(prev_letter != 0)
										begin
											writeEn <= prev_letter[143];
											prev_letter <= prev_letter << 1;
											x_out <= prev_x + 12 + x_count;
											y_out <= prev_y + y_count;
										end
									else
									begin
										writeEn <= 0;
									end
					end
				S_DRAW_POCT:
					begin
									colour <= 3'b100;
									if(local_oct != 0)
										begin
											writeEn <= prev_oct[143];
											prev_oct <= prev_oct << 1;
											x_out <= prev_x + 24 + x_count;
											y_out <= prev_y + y_count;
										end
									else
									begin
										writeEn <= 0;
									end
					end
				S_PCLEAR:
					begin
									colour <= 3'b000;
									if(clear_psharp != 0)
										begin
											writeEn <= clear_psharp[143];
											clear_psharp <= clear_psharp << 1;
											x_out <= prev_x + x_count;
											y_out <= prev_y + y_count;
										end
									else if(clear_pletter != 0)
										begin
											writeEn <= clear_pletter[143];
											clear_pletter <= clear_pletter << 1;
											x_out <= prev_x + 12 + x_count;
											y_out <= prev_y + y_count;
										end
									else if(clear_poct != 0)
										begin
											writeEn <= clear_poct[143];
											clear_poct <= clear_poct << 1;
											x_out <= prev_x + 24 + x_count;
											y_out <= prev_y + y_count;
										end
									else
									begin
										writeEn <= 0;
										x_out <= prev_x;
										y_out <= prev_y;	
									end
					end
				S_LOAD_PREV:
					begin
						prev_x <= x;
						prev_y <= y;
						prev_letter <= local_letter;
						prev_oct <= local_oct;
						prev_sharp <= local_sharp;
					end
				S_DRAW_WAIT:
					begin
						clear_letter <= 2**144 - 1;
						clear_oct <= 2**144 - 1;
						clear_sharp <= 2**144 - 1;
						clear_pletter <= 2**144 - 1;
						clear_poct <= 2**144 - 1;
						clear_psharp <= 2**144 - 1;
						x_out <= x;
						y_out <= y;	
						writeEn <= 0;
					end
				default:
					begin
						writeEn <= 0;
						colour <= 3'b000;
						x_out <= x;
						y_out <= y;	
					end
			endcase
	end
endmodule