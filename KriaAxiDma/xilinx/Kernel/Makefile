INC = /home/ubuntu/development/KriaKR260Projects/KriaAxiDma/xilinx/Software/Common/
EXTRA_CFLAGS += -I$(INC)

obj-m += dma-proxy.o

all:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules
clean:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean
