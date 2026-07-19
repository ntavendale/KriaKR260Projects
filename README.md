# KR260Projects

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
