module top(
	  // Clock Input (50 MHz)
	  input CLOCK_50, // 50 MHz
	  input CLOCK_27, // 27 MHz
	  //  Push Buttons
	  input  [3:0] KEY,
	  //  DPDT Switches 
	  input  [9:0]  SW,
	  // TV Decoder
	  output TD_RESET, // TV Decoder Reset
	  // I2C
	  inout  I2C_SDAT, // I2C Data
	  output I2C_SCLK, // I2C Clock
	  // Audio CODEC
	  output/*inout*/ AUD_ADCLRCK, // Audio CODEC ADC LR Clock
	  input	 AUD_ADCDAT,  // Audio CODEC ADC Data
	  output /*inout*/  AUD_DACLRCK, // Audio CODEC DAC LR Clock
	  output AUD_DACDAT,  // Audio CODEC DAC Data
	  inout	 AUD_BCLK,    // Audio CODEC Bit-Stream Clock
	  output AUD_XCK,     // Audio CODEC Chip Clock
	  //  GPIO Connections
	  inout  [35:0]  GPIO_0, GPIO_1,
	  input PS2_CLK,
	  input PS2_DAT,
	  output [6:0] HEX0,
	  output [6:0] HEX1,
	  output [6:0] HEX2,
	  output [6:0] HEX3,
	  output [6:0] HEX4,
	  output [6:0] HEX5,
	  output 	VGA_CLK,   						//	VGA Clock
	  output 	VGA_HS,							//	VGA H_SYNC
	  output 	VGA_VS,							//	VGA V_SYNC
	  output 	VGA_BLANK_N,						//	VGA BLANK
	  output 	VGA_SYNC_N,						//	VGA SYNC
	  output 	[9:0] VGA_R,   						//	VGA Red[9:0]
	  output 	[9:0] VGA_G,	 						//	VGA Green[9:0]
	  output 	[9:0] VGA_B   						//	VGA Blue[9:0]
  );

  wire [31:0] note_freq;
  wire [3:0] note_counter;
  wire ld_play;
  wire ld_note;  
  wire [7:0] keyboard_code;
  wire makeBreak;
  wire valid;
  wire [3:0] note;
  wire [1:0] octave;
  wire load_n;
  wire playback; 
  
keyboard_press_driver keyboard(
			.CLOCK_50(CLOCK_50), 
			.valid(valid), 
			.makeBreak(makeBreak),
		   .outCode(keyboard_code),
			.PS2_DAT(PS2_DAT), // PS2 data line
			.PS2_CLK(PS2_CLK), // PS2 clock line
			.reset(KEY[0])
);

//Four least significant bits of keyboard_code
hex_decoder h0(.hex_digit({3'b000, writeEn}), .segments(HEX0));

//Four most significant bits of keyboard_code
hex_decoder h1(.hex_digit({1'b0, colour}), .segments(HEX1));

//Display the makeBreak value
hex_decoder h2(.hex_digit(x[3:0]), .segments(HEX2));

//Display the valid value
hex_decoder h3(.hex_digit(y[3:0]), .segments(HEX3));

//Display the note
hex_decoder h4(.hex_digit(note), .segments(HEX4));

//Display the ocatave
hex_decoder h5(.hex_digit({2'b00,octave}), .segments(HEX5));


  
  convert_keyboard_input in0(.keyboard_code(keyboard_code), 
									  .makeBreak(makeBreak), 
									  .load_n(load_n), 
									  .playback(playback), 
									  .note(note), 
									  .octave(octave)
									  );
  
  control c0(.reset(KEY[0]), 
			 .load_n(load_n), 
			 .playback(playback), 
			 .clk(CLOCK_50), 
			 .ld_play(ld_play), 
			 .ld_note(ld_note), 
			 .note_counter(note_counter[3:0])
			 );
			 
  datapath d0(.note_data(note),
			  .octave_data(octave), 
			  .ld_note(ld_note), 
			  .ld_play(ld_play), 
			  .note_counter(note_counter[3:0]), 
			  .clk(CLOCK_50),
			  .reset(KEY[0]),
			  .freq_out(note_freq[31:0])
			  );
	

  //ADAPTED CODE FROM http://www.johnloomis.org/digitallab/audio/audio3/audio3.html
  audio3 audio(.CLOCK_50(CLOCK_50),
  			   .CLOCK_27(CLOCK_27),
  			   .reset(KEY[0]),
  			   .freq(note_freq),
  			   .TD_RESET(TD_RESET),
  			   .I2C_SDAT(I2C_SDAT),
  			   .I2C_SCLK(I2C_SCLK),
  			   .AUD_ADCLRCK(AUD_ADCLRCK),
  			   .AUD_ADCDAT(AUD_ADCDAT),
  			   .AUD_DACLRCK(AUD_DACLRCK),
  			   .AUD_DACDAT(AUD_DACDAT),
  			   .AUD_BCLK(AUD_BCLK),
  			   .AUD_XCK(AUD_XCK),
  			   .GPIO_0(GPIO_0),
  			   .GPIO_1(GPIO_1)
  				);

				
				
				
			
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(KEY[0]),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			

			
	vga_data vgad(
					.note(4'b0001), 
					.octave(2'b01), 
					.clk(CLOCK_50), 
					.clear(KEY[2]),
					.ld_note(1'b1),
					.x(30), //from coord picker/datapath
					.y(30), //from coord picker/datapath
					.x_out(x), 
					.y_out(y), 
					.writeEn(writeEn),
					.colour(colour)
					);
endmodule

module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule