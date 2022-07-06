SOURCES = firmware.s65 zeropage.s65 acia.s65

%.o: %.s65
	ca65 -o $@ -l $(@:.o=.lst) $<

all: firmware

firmware: $(SOURCES:.s65=.o)
	cl65 -C firmware.cfg -t none -o $@ $^

clean:
	rm -f firmware *.o *.lst

flash: clean all
	/mnt/c/cygwin64/bin/bash.exe --login -c 'minipro -p at28c256 -w my6502Computer/06_ACIA/firmware'