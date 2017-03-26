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
	  input PS2_DAT
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
			.makeBreak(valid),
		   .outCode(keyboard_code),
			.PS2_DAT(PS2_DAT), // PS2 data line
			.PS2_CLK(PS2_CLK), // PS2 clock line
			.reset(KEY[0])
);


  
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


endmodule
