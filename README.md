# shofel2_linux

This is compiled version of f0f linux kernel for everyone having issues with compiling itself.
Basically you have to install python3 and pyusb then clone this repo 

```
git clone https://github.com/SoulCipher/shofel2_linux.git
```

I've made a simple script to automate linux boot so hence you have your method to run Switch in RCM mode just run

```
cd shofel2_linux 
sudo ./boot_linux.sh
```

Turn off your Switch
Ground PIN 10 on right JoyCon rail, press VOL+ and connect USB cable to Switch.

All info taken from [https://gbatemp.net/threads/quick-tuto-how-to-boot-linux-on-your-switch.501918/]
All credits go to **natinusala**



**What you'll need**

- A computer running Linux with a blue USB SuperSpeed port, or a Mac
- A Linux VM can work in theory, but it depends on how the USB passthrough is implemented (apparently VMWare works, VirtualBox doesn't)
- A USB A-to-C cable (with data support, obviously)

Then, install those dependencies (how to install them and their name might depend on your distribution) :
- python3
- python-dev
- python3-pip
- pyusb 1.0.0 : "$ sudo pip3 install pyusb==1.0.0"
- libusb-1.0-0-dev

**Building the rootfs**

This is the annoying part. Download this file.
[http://os.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz]

While it's downloading, you'll have to take a microSD card and, using the software of your choice (I used GParted) :
remove every existing partition to only have unallocated space on it (do I need to tell you that you're going to loose everything on the card ?)
create a tiny FAT32 partition (I chose 200mb but it doesn't matter) - that'll be mmcbkl0p1, you can label it "garbage"
create an ext4 partition on the remaining part of the card - that'll be mmcblk0p2, you can label it "rootfs"
it's important that the FAT32 partition comes first and the ext4 one comes after - on the Switch, Linux will look for mmcblk0p2, the second partition, if you have scrolling boot logs and then back to RCM it means you did it wrong
Once the rootfs tarball is downloaded, you can simple extract it to the mounting point of the ext4 partition you just created :

```
tar xvf ArchLinuxARM-aarch64-latest.tar.gz -C /mounting/point/of/ext4/partition
cp ArchLinuxARM-aarch64-latest.tar.gz /mounting/point/of/ext4/partition/root
```

Then you can put the SD card in the console.

**************************************************************************************************************************************
You will most likely need a 1.8V serial cable connected to the right hand side Joy-Con port to do anything useful with this at this point. Please do not bug us with questions about how to get this to run if you do not have a means to debug things yourself. This is not ready for end users. If you really want to try configuring your Linux image standalone to boot with WiFi or X support to get something done without a serial console, you're on your own and you get to suffer through the pain all by yourself. Hint: WiFi is broken on the first boot, you need to reboot on the first Linux launch (which puts you back into RCM mode), and then run the exploit again. Patches welcome.
