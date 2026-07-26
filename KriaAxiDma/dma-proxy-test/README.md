# dmaProxyTest

Test application to read write from proxy dma channels. This is a port of the xilinx user space demo application to pascal.

Pascal is much more strongly typed than C so there are more explicit type definitions and we try to avoid the use of opaque pointers.

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
