# dma-proxy-test

Test application to read contents of DMA registers by mapping into /dev/mem.

To build:
```
fpc -odmaProxyTest dmaProxyTest.dpr
```

To run:
```
./dmaProxyTest
```

If /dev/dma_proxt_tx & /dev/dma_proxt_rx don't have read write permissions for regular users, eun as root.

```
sudo ./dmaProxyTest
```
