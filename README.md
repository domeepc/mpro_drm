# MPRO DRM

A simple DRM driver for VoCore MPRO screen.

## Prerequisites

Install the kernel headers and build tools:

```
sudo apt update
sudo apt install build-essential linux-headers-$(uname -r)
```

## Build & Install

```
git clone https://github.com/Vonger/mpro_drm
cd mpro_drm
make
sudo make install
```

After installing, load the module with:

```
sudo modprobe mpro
```

Or reboot to have it loaded automatically when the device is connected.

## Raspberry Pi OS (Trixie / kernel 6.12)

Raspberry Pi OS based on Debian Trixie ships with kernel 6.12. This driver
is compatible with this kernel out of the box.

```
sudo apt update
sudo apt install build-essential linux-headers-$(uname -r)
git clone https://github.com/Vonger/mpro_drm
cd mpro_drm
make
sudo make install
```

To verify the driver loads:

```
sudo modprobe mpro
```

### DKMS (optional, recommended)

DKMS automatically rebuilds the module when a new kernel is installed.

```
sudo apt install dkms
sudo mkdir -p /usr/src/mpro-0.1
sudo cp mpro.c Makefile dkms.conf /usr/src/mpro-0.1/
sudo dkms add mpro/0.1
sudo dkms build mpro/0.1
sudo dkms install mpro/0.1
```

To remove the DKMS module later:

```
sudo dkms remove mpro/0.1 --all
```

## Uninstall

```
sudo make uninstall
```

## Older Kernel Versions

For kernels older than 6.12, check the upstream repository branches at
https://github.com/Vonger/mpro_drm for a version matching your kernel.
