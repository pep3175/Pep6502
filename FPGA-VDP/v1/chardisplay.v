
`include "hvsync_generator.v"
`include "patternTable.v"
`include "nameTable.v"
`include "ram.v"

/*
Displays a grid of ascii characters.
*/

module chardisplay(clk, hsync, vsync, rgb);

  input clk;
  output hsync, vsync;
  output [2:0] rgb;

  wire display_on;
  wire [9:0] hpos;
  wire [9:0] vpos;
  
  reg [10:0] tile_ctr = 0;
  reg [10:0] ram_addr;
  wire [7:0] rom_dout;
  wire [7:0] ram_dout;
  wire [7:0] ram_write;
  reg ram_writeenable = 0;

    
  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(0),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
  );
 
  wire [4:0] row = vpos[8:4];	// 5-bit row, vpos / 16 = 30 rows
  wire [5:0] col = hpos[9:4];	// 6-bit column, hpos / 16 = 40 cols
  wire [2:0] rom_yofs = vpos[3:1]; // scanline of cell //sizex2
  wire [7:0] rom_bits;		   // 8 pixels per scanline
  wire [7:0] bits2display = rom_bits>>1;
  wire [2:0] xofs = hpos[3:1];      // which pixel to draw (0-7) //sizex2
  

  // RAM to hold 32x32 array of bytes
  /*RAM_sync #(11,8) ram(
    .clk(clk),
    .dout(ram_dout),
    .din(ram_write),
    .addr(ram_addr),
    .we(ram_writeenable)
  );*/
  RAM_async2 #(11,8) ram(
    .we(ram_writeenable),
    .dout(ram_dout),
    .din(rom_dout),
    .addr(ram_addr)
  );

  
  
 // patternTable
  ascii_array patternTable(
    .code(ram_dout),     //rom_dout->ROM | ram_dout->RAM
    .yofs(rom_yofs),
    .bits(rom_bits)
  );

  // extract bit from ROM output
  wire r = display_on && bits2display[~xofs];
  wire g = 0;
  wire b = 0;
  assign rgb = {b,g,r};

  
  always @(posedge clk)
    if (display_on) begin
      if (hpos[3:0] == 0)
        ram_addr <= {row,col}-(24*row);
    end else
      ram_addr <= tile_ctr;
  
  /*always @(posedge clk)
    if (!ram_writeenable && !display_on)
      ram_addr <= tile_ctr;*/
  
  always @(negedge ram_writeenable)
    if (tile_ctr > 1198)
      tile_ctr <= 0;
    else
      tile_ctr <= tile_ctr + 1;
 
  
  //////////////////////////
  //reg [7:0] cntr = 0;
  //wire cntr_div;
  //
  //
  //always @(posedge clk)
  //begin
  //    cntr <= cntr + 1;
  //end
  //
  //assign cntr_div = cntr[0];
  //////////////////////////

  
  
  ////////////////////////////////////////////////////////
  // write the nameTable ROM into the RAM
  
  reg [10:0] tile_ctr_CPU = 0;
  
  // name table
  nameTable nameTable(
    .addr(tile_ctr_CPU),
    .data(rom_dout)
  );

  always @(posedge clk)
    if (!display_on) begin
        case (hpos[1:0])
          0: begin
            //ram_write <= rom_dout;
            //ram_addr <= tile_ctr;
          end
          1: begin
            ram_writeenable <= 1;
          end
          2: begin
            ram_writeenable <= 0;
            //tile_ctr_CPU <= tile_ctr_CPU + 1;
            if (tile_ctr_CPU > 1198)
              tile_ctr_CPU <= 0;
            else
              tile_ctr_CPU <= tile_ctr_CPU + 1;
          end
          3: begin            
          end
        endcase
    end
  
     
endmodule