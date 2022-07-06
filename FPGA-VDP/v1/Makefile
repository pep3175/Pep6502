TARGET=chardisplay
TOP=chardisplay

OBJS+=chardisplay.v hvsync_generator.v ram.v patternTable.v nameTable.v

TRELLIS=/usr/local/share/trellis

all: ${TARGET}.bit

$(TARGET).json: $(OBJS)
	yosys -p "synth_ecp5 -json $@" $(OBJS)

$(TARGET)_out.config: $(TARGET).json
	nextpnr-ecp5 --25k --package CABGA381 --speed 6 --json $< --textcfg $@ --lpf $(TARGET).lpf --freq 65

$(TARGET).bit: $(TARGET)_out.config
	ecppack --compress --svf ${TARGET}.svf $< $@

${TARGET}.svf : ${TARGET}.bit

prog: ${TARGET}.svf
	ecpdap.exe program --freq 5000 $(TARGET).bit

clean:
	rm -f *.svf *.bit *.config *.ys *.json

.PHONY: prog clean
