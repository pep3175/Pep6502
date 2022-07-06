
`include "hvsync_generator.v"
`include "patternTable.v"
`include "nameTable.v"
`include "ram.v"

/*
Displays a grid of ascii characters.
*/

module chardisplay(clk, reset, cpu_we, mode, rs, data, hsync, vsync, nmi, rgb, ram_we, clk_o);

  input clk, reset;
  //
  input cpu_we, mode, rs;
  input [7:0] data;
  //reg cpu_we = 0;
  //reg mode = 0;
  //reg rs = 0;
  //reg [7:0] data;
  //
  output hsync, vsync, nmi;
  output [2:0] rgb;
  //Tests&diag
  output ram_we;
  output clk_o;
  assign clk_o = clk;

  reg [7:0] status_reg = 8'b00000000;
  wire active_display = status_reg[7];
  wire interrupt_enable = status_reg[6];
  reg end_frame;
  wire nmi = ~(end_frame && interrupt_enable);
  //wire ram_we = (cpu_we && ~mode);
  //reg ram_we = 0;

  wire display_on;
  wire [9:0] hpos;
  wire [9:0] vpos;
  
  reg [10:0] tile_ctr;
  reg [10:0] ram_addr;
  wire [7:0] rom_dout;
  wire [7:0] ram_dout;
  wire [7:0] ram_write;
  wire [7:0] ram_din;

   
  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(~reset),
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
  

  RAM_sync #(11,8) ram(
    .clk(clk),
    .we(ram_we),
    .dout(ram_dout),
    .din(ram_din),
    .addr(ram_addr)
  );


 // patternTable
  ascii_array patternTable(
    .code(ram_dout),     //rom_dout->ROM | ram_dout->RAM
    .yofs(rom_yofs),
    .bits(rom_bits)
  );

  // extract bit from ROM output
  wire r = active_display && display_on && bits2display[~xofs];
  wire g = active_display && display_on && bits2display[~xofs];
  wire b = active_display && display_on && bits2display[~xofs];
  assign rgb = {b,g,r};
  
  reg topAddByte = 0;
  
  always @(posedge clk)
    if (display_on) begin
      if (hpos[3:0] == 0)
		ram_addr <= {row,col}-(24*row);
    end else
      case (hpos[0])
        0: begin
		  ram_addr <= tile_ctr;
        end
        1: begin
		  ram_we <= (cpu_we && ~mode);
        end
      endcase
		

  
  always @(negedge cpu_we) begin
    if (tile_ctr == 1199)
      tile_ctr <= 0;
    else
      tile_ctr <= (mode == 0) ? tile_ctr + 1 : tile_ctr;
	//// 
    if (mode == 0)
      ram_din <= data;
    else begin
      if (rs == 0)
        status_reg <= data;
      else
        tile_ctr <= (topAddByte == 0) ? {tile_ctr[10:8],data} : {data[2:0],tile_ctr[7:0]};
		topAddByte <= ~topAddByte;
	end
  end


  always @(posedge clk) end_frame <= (vpos > 481) ? 1 : 0;
 

endmodule