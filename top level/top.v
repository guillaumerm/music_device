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
	  inout  [35:0]  GPIO_0, GPIO_1
  );

  wire [31:0] note_freq;
  wire [3:0] note_counter;
  wire ld_play;
  wire ld_note;  
  
  control(.reset(KEY[0]), 
			 .load_n(KEY[2]), 
			 .playback(KEY[3]), 
			 .clk(CLOCK_50), 
			 .ld_play(ld_play), 
			 .ld_note(ld_note), 
			 .note_counter(note_counter[3:0])
			 );
			 
  datapath(.note_data(SW[3:0]),
			  .octave_data(SW[9:8]), 
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
