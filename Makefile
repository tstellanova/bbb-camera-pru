CC=../buildroot/output/host/usr/bin/arm-buildroot-linux-uclibcgnueabi-gcc
PASM?=../buildroot/output/host/usr/bin/pasm

CFLAGS+= -Wall
LDFLAGS+=-lprussdrv -lpthread
TARGET=PRU_memAccess_DDR_PRUsharedRAM

DEPS = PRU_memAccess_DDR_PRUsharedRAM_bin.h
OBJ = PRU_memAccess_DDR_PRUsharedRAM.o

all: $(TARGET)
$(OBJ): $(DEPS)

%_bin.h: %.p
	$(PASM) -c $<

$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)


.PHONY: clean

clean:
	rm -rf *.o *~  $(TARGET) *_bin.h

