module control(reset, load_n, playback, clk, ld_play, ld_note, note_counter);
	input reset;
	input load_n;
	input playback;
	input clk;
	output reg ld_play;
	output reg ld_note;
	//16 notes to play back
	output reg [3:0] note_counter;
	
	wire next_note_en;
	
	RateDivider2 rd(.clk(clk),
						 .next_note_en(next_note_en)
						 );
	
	reg [1:0] current_state, next_state;
	localparam  LOAD_NOTE_WAIT        = 2'b00,
	            LOAD_NOTE             = 2'b01,
	            PLAYBACK		  	 		 = 2'b10;
	
	//state table
	always@(*)
	begin
		case(current_state)
			LOAD_NOTE_WAIT : 
				begin
					if(!load_n)
						next_state = LOAD_NOTE;
					else if(!playback)
						next_state = PLAYBACK;
					else
						next_state = LOAD_NOTE_WAIT;
				end
			LOAD_NOTE :
				begin
					if(load_n)
						next_state = LOAD_NOTE_WAIT;
					else
						next_state = LOAD_NOTE;
				end
			PLAYBACK :
				begin
					next_state = LOAD_NOTE_WAIT;
				end
			default :
				begin
					next_state = LOAD_NOTE_WAIT;
				end
		endcase
	end
	
	always@(posedge clk)
	begin
		if(!reset)
			note_counter <= 0;
		else
			begin
				if(current_state == PLAYBACK && next_note_en && note_counter < 4'b1111)
					note_counter <= note_counter + 1;
				else if(next_note_en && note_counter == 4'b1111)
					note_counter <= 0;
			end
	end
	
	// Output logic of the signals
	always@(*)
	begin
		case(current_state)
			LOAD_NOTE_WAIT : 
				begin
					ld_play = 0;
					ld_note = 0;
				end
			LOAD_NOTE :
				begin
					ld_play = 0;
					ld_note = 1;
				end
			PLAYBACK :
				begin
					ld_play = 1;
					ld_note = 0;
				end
			default :
				begin
					ld_play = 0;
					ld_note = 0;
				end
		endcase
	end
	
	always@(posedge clk)
	begin
		if(!reset)
			begin
				current_state <= LOAD_NOTE_WAIT;
			end
		elsereset
			begin
					if(current_state != PLAYBACK)
						current_state <= next_state;
					else if(next_note_en && note_counter == 4'b1111)
						current_state <= next_state;
			end
	end
	
endmodule


module RateDivider2(clk, next_note_en);
	input clk;
	output next_note_en;
	
	//0.5 second counter
	reg [24:0] counter = 25000000 - 1;
	always @(posedge clk) 
		begin
			if (counter == 0)
				counter <= 25000000 - 1;
			else 
				counter <= counter - 1;
		end
	assign next_note_en = (counter == 0) ? 1 : 0;
endmodule