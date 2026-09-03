# hygrometer

REST application to read write from hygrometer.

Pascal is much more strongly typed than C so there are more explicit type definitions and we try to avoid the use of opaque pointers.

To build:
```
fpc -ohygrometer hygrometer.dpr
```

To run:
```
./hygrometer
```

If /dev/dma_proxt_tx & /dev/dma_proxt_rx don't have read write permissions for regular users, run as root.

```
sudo ./hygrometer
```
