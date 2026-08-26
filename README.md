# KR260Projects

## InitialSetup

Contains instructions for setting up KRIA board, installing OS and dev tools.

## Initial Setup

Setup instructions for loading OS and setting up board. Uses Ubuntu 24.04. Will work with 22.04 which is recommended for all the projects.

## KriaAxiDma

Bare bones Axi Dma project. Zynq UltraScale+ Connect to an AXi-4 Dma running data through a FIFO. Contains xilinx proxy dma driver code and user demo app. Also contains Pascal port of demo app.
If just starting use this and follow instructions for setting up Vivado project, getting it on to Kria and building drivers and xilinx test apps. Then proceed to build Pascal apps.

## TempAndHumidity

Project to monitor temperature and humidity via a REST service running on KR260 board which interfaces with a PMod Hygrometer/Temperature Sensor via DMA.

## List Firmware Apps

```
sudo xmutil listapps
```

Eeach app has it's own folder in the /lib/firmware/xilinx directory.

## Set Default Firmware

Update the following file:

```
/etc/dfx-mgrd/default_firmware
```

## Build dmareg

cd to KR260Projects/test_dma directory

```
fpc -odmareg dmareg.dpr
```

## Git Access

You need to do this every time you log on. Must be a better way - look into it!

Start ssh agent:

```
 eval "$(ssh-agent -s)"
```

Add private key:

```
ssh-add ~/.ssh/<my_key_Name>
```

Clone using ssh:

```
 git clone ssh://git@ssh.github.com:443/ntavendale/KriaKR260Projects.git
```
