
`ifndef patternTable_H
`define patternTable_H

`include "hvsync_generator.v"

/*
ROM module with 5x5 bitmaps for the ASCII characters.
*/

module ascii_array(code, yofs, bits);
  
  input [7:0] code;		// code ascii
  input [2:0] yofs;		// vertical offset (0-4)
  output [7:0] bits;		// output (5 bits)

  reg [7:0] bitarray[0:1023];
  assign bits = bitarray[(code*8)+yofs];
  
  initial begin/*{w:8,h:8}*/
    $readmemh("font.mem", bitarray);
  end
endmodule

`endif
