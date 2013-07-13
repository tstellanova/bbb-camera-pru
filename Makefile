CROSS_COMPILE?=../buildroot/output/host/usr/bin/arm-buildroot-linux-uclibcgnueabi-
PASM?=../buildroot/output/host/usr/bin/pasm

LIBDIR_APP_LOADER?=../buildroot/staging/usr/lib
INCDIR_APP_LOADER?=../buildroot/staging/usr/include
BINDIR?=.

CFLAGS+= -Wall -I$(INCDIR_APP_LOADER) -D__DEBUG -O2 -mtune=cortex-a8 -march=armv7-a
LDFLAGS+=-L$(LIBDIR_APP_LOADER) -lprussdrv -lpthread
OBJDIR=obj
TARGET=$(BINDIR)/PRU_memAccess_DDR_PRUsharedRAM

_DEPS = 
DEPS = $(patsubst %,$(INCDIR_APP_LOADER)/%,$(_DEPS))

_OBJ = PRU_memAccess_DDR_PRUsharedRAM.o
OBJ = $(patsubst %,$(OBJDIR)/%,$(_OBJ))

all: $(TARGET) PRU_memAccess_DDR_PRUsharedRAM.bin

%.bin: %.p
	$(PASM) -b $<

$(OBJDIR)/%.o: %.c $(DEPS)
	@mkdir -p obj
	$(CROSS_COMPILE)gcc $(CFLAGS) -c -o $@ $< 

$(TARGET): $(OBJ)
	$(CROSS_COMPILE)gcc $(CFLAGS) -o $@ $^ $(LDFLAGS)


.PHONY: clean

clean:
	rm -rf $(OBJDIR)/ *~  $(TARGET) *.bin

