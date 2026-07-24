INC = /home/ubuntu/development/KriaKR260Projects/KriaAxiDma/xilinx/Common/
EXTRA_CFLAGS += -I$(INC)

obj-m += dma-proxy-test.o
all:
	cc -o dma-proxy-test dma-proxy-test.c -I /home/ubuntu/development/KriaKR260Projects/KriaAxiDma/xilinx/Common/ -O0 -g3
clean:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean
