# hygrometer

REST application to read write from hygrometer.

First clone the mORMot2 github repository:

```
git clone https://github.com/synopse/mORMot2.git /home/ubuntu/development/mORMot2
```

To build:
```
./do_build.sh
```

To run:
```
./hygrometer
```

If /dev/dma_proxt_tx & /dev/dma_proxt_rx don't have read write permissions for regular users, run as root.

```
sudo ./hygrometer
```
