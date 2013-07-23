CC=../buildroot/output/host/usr/bin/arm-buildroot-linux-uclibcgnueabi-gcc
PASM?=../buildroot/output/host/usr/bin/pasm

LIBDIR_APP_LOADER?=../buildroot/staging/usr/lib
INCDIR_APP_LOADER?=../buildroot/staging/usr/include

CFLAGS+= -Wall -I$(INCDIR_APP_LOADER) -D__DEBUG -O2 -mtune=cortex-a8 -march=armv7-a
LDFLAGS+=-L$(LIBDIR_APP_LOADER) -lprussdrv -lpthread
OBJDIR=obj
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

