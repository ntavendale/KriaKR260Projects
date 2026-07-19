# dmaProxyTest

Test application to read write from proxy dma channels.

To build:
```
fpc -odmaProxyTest dmaProxyTest.dpr
```

To run:
```
./dmaProxyTest
```

If /dev/dma_proxt_tx & /dev/dma_proxt_rx don't have read write permissions for regular users, run as root.

```
sudo ./dmaProxyTest
```
