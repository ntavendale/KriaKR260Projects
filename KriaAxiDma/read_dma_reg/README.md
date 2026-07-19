# read_dma_reg

Test application to read contents of DMA registers by mapping into /dev/mem.

To build:
```
fpc -oread_dma_reg dmareg.dpr
```

To run:
```
sudo ./read_dma_reg
```

Must run as root. FPGA application must be loaded on Kria or it will crash system and you will need to restart.