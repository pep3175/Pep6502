
`ifndef nameTable_H
`define nameTable_H

module nameTable(addr, data);

  input [10:0] addr;
  output [7:0] data;

  reg [7:0] rom[0:1199];

  assign data = rom[addr];

  initial begin
    $readmemh("nameTable.mem", rom);
  end
endmodule

`endif
