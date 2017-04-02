module vga_data(note, octave, clk, reset, ld_note, colour_in, x, y, x_out, y_out, writeEn, colour);
	input [3:0] note;
	input [1:0] octave;
	input clk;
	input [7:0] x;
	input [6:0] y;
	input reset;
	input ld_note;
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
						.reset(reset),
						.colour_in(colour_in),
						.writeEn(writeEn),
						.colour(colour),
						.x_out(x_out),
						.y_out(y_out)
						);
	
endmodule

module draw_note(clk,letter,oct,sharp,x,y, ld_note, reset, colour_in, writeEn, colour, x_out,y_out);
	input clk;
	input [143:0] letter;
	input [143:0] oct;
	input [143:0] sharp;
	input [7:0] x;
	input [6:0] y;
	input reset;
	input ld_note;
	input [2:0] colour_in;
	output reg writeEn;
	output reg [2:0] colour;
	output reg [7:0] x_out;
	output reg [6:0] y_out;
	
	reg [7:0] x_count = 0;
	reg [6:0] y_count = 0;

	
	reg enable_counter_144, enable_counter_19200;
	reg [1:0] current_state, next_state;
	reg [143:0] local_letter, local_oct, local_sharp, clear_letter, clear_oct, clear_sharp;
	
	localparam S_DRAW = 2'b00,
				  S_DRAW_WAIT = 2'b01,
				  S_RESET = 2'b10,
				  S_CLEAR = 2'b11;
	
	always@(*)
	begin
		case(current_state)
			S_RESET:
				begin
				if(!reset)
					next_state <= S_RESET;
				else
					next_state = y_count == 119 ? S_DRAW_WAIT : S_RESET;
				end
			S_CLEAR:
				begin
				if(!reset)
					next_state <= S_RESET;
				else
					next_state = clear_letter == 0 && clear_sharp == 0 && clear_oct == 0 ? S_DRAW : S_CLEAR;
				end
			S_DRAW:
				begin
				if(!reset)
					next_state <= S_RESET;
				else
					next_state = local_letter == 0 && local_oct == 0 && local_sharp == 0 ? S_DRAW_WAIT : S_DRAW;
				end
			S_DRAW_WAIT:
				begin
				if(!reset)
					next_state <= S_RESET;
				else
					next_state = ld_note ? S_CLEAR : S_DRAW_WAIT;
				end
			default :
				begin
				if(!reset)
					next_state <= S_RESET;
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
			S_CLEAR:
				begin
					enable_counter_19200 <= 0;
					enable_counter_144 <= 1;
				end
			S_DRAW:
				begin
					enable_counter_19200 <= 0;
					enable_counter_144 <= 1;
				end
			S_DRAW_WAIT:
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
						clear_letter <= 2**144 - 1;
						clear_oct <= 2**144 - 1;
						clear_sharp <= 2**144 - 1;
					end
				S_DRAW:
					begin
									colour <= colour_in;
									if(local_sharp != 0)
										begin
											
											writeEn <= local_sharp[143];
											local_sharp <= local_sharp << 1;
											x_out <= x + x_count;
											y_out <= y + y_count;
										end
									else if(local_letter != 0)
										begin
									
											writeEn <= local_letter[143];
											local_letter <= local_letter << 1;
											x_out <= x + 12 + x_count;
											y_out <= y + y_count;
										end
									else if(local_oct != 0)
										begin
								
											writeEn <= local_oct[143];
											local_oct <= local_oct << 1;
											x_out <= x + 24 + x_count;
											y_out <= y + y_count;
										end
									else
									begin
										x_out <= x;
										y_out <= y;	
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
										x_out <= x;
										y_out <= y;	
									end
					end
				S_DRAW_WAIT:
					begin
						local_oct[143:0] <= oct[143:0];
						local_letter[143:0] <= letter[143:0];
						local_sharp[143:0] <= sharp[143:0];
						clear_letter <= 2**144 - 1;
						clear_oct <= 2**144 - 1;
						clear_sharp <= 2**144 - 1;
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