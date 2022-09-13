Main firmware is `iprfp3G.dnld`

Contains (concatenated):
* Header (ASCII)
* uImage for uBoot
* Addons (bz2 TAR)

Header format:
```
IP-RFP Firmware Image

header version = 1
header length = 432 bytes

version = SIP-DECT 8.1SP2-FC19
stream = SIP-DECT
stream v2 = SIP-DECT
build at = Mar 19 09:37:54 2020
protocol version = 8.2.1

hardware platform = RFP35 / RFP43
image length = 12516264 bytes
addon length = 5854881 bytes

header md5 = C2B0C451E68558038E17B58F09894B27
image md5 = 76E0DAF566C0144F5CCD7C13BBE61669
addon md5 = A13AAD911E7D93FDFE57E12C14ADF247
```

Unsure how header md5 is calculated,
image and addon md5 match up as expected.

uImage:
```
> file image
image: u-boot legacy uImage, Linux-3.2.93, Linux/ARM, OS Kernel Image (Not compressed), 12516200 bytes, Thu Mar 19 08:37:52 2020, Load Address: 0X008000, Entry Point: 0X008000, Header CRC: 0X348D65AC, Data CRC: 0X2C54499C

> binwalk image

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             uImage header, header size: 64 bytes, header CRC: 0x348D65AC, created: 2020-03-19 08:37:52, image size: 12516200 bytes, Data Address: 0x8000, Entry Point: 0x8000, data CRC: 0x2C54499C, OS: Linux, CPU: ARM, image type: OS Kernel Image, compression type: none, image name: "Linux-3.2.93"
64            0x40            Linux kernel ARM boot executable zImage (little-endian)
17019         0x427B          gzip compressed data, maximum compression, from Unix, last modified: 1970-01-01 00:00:00 (null date)
```

uImage contains initramfs in cpio format, gziped.
```
ASCII cpio archive (SVR4 with no CRC)
```

initramfs extracted to `fs/`
addons extracted to `addons/`

## Board images

Board front
![Board front](https://raw.githubusercontent.com/TheEnbyperor/mitel-firmware/root/images/893936BC-288E-4A5D-94DA-3DFBF24B9FDF.jpg)

Board back
![Board front](https://raw.githubusercontent.com/TheEnbyperor/mitel-firmware/root/images/E109B0F7-2564-4DB4-9F3A-D6CF9AB5FBAF.jpg)

Under primary RF can
![Board front](https://raw.githubusercontent.com/TheEnbyperor/mitel-firmware/root/images/D61AE3BC-3796-41AA-B3B4-2DC2688B8BBC.jpg)

## Board chips

AHC595 - [Datasheet](https://raw.githubusercontent.com/TheEnbyperor/mitel-firmware/root/datasheets/sn74ahc595.pdf) - 8-bit shift register - Seems to be controlling the LEDS

88E1318S - [Datasheet](https://raw.githubusercontent.com/TheEnbyperor/mitel-firmware/root/datasheets/52529f1be34e242f50ea9dc8.pdf) - Gigabit Ethernet PHY

### DECT RF front end
Dialog SC14452 - No datasheet - DECT coprocessor

ISSI IS42S16400J - [Datasheet](https://raw.githubusercontent.com/TheEnbyperor/mitel-firmware/root/datasheets/42-45s16400j.pdf) - 64Mbit SDRAM - Likely for DECT coprocessor

Lacite LC4064V-75TN-10I (possibly LC4064V-75TN100L) [Datasheet](https://raw.githubusercontent.com/TheEnbyperor/mitel-firmware/root/datasheets/FPGA-DS-02091-23-6-ispMACH4000VBCZ.pdf) - CPLD

MVL3019 - No datasheet - Coprocessor firmware makes reference to Marvell 88E3019 PHY, possibly this

2 x LVC08A - [Datasheet](https://raw.githubusercontent.com/TheEnbyperor/mitel-firmware/root/datasheets/sn75lvc08a.pdf) - Quad AND gate

LC112A - [Datasheet](https://raw.githubusercontent.com/TheEnbyperor/mitel-firmware/root/datasheets/sn74lvc112a.pdf) - Dual J-K flip flop

LVC157A - [Datasheet](https://raw.githubusercontent.com/TheEnbyperor/mitel-firmware/root/datasheets/sn74lvc157a.pdf) - Quad 2-1 multiplexer

2 x LW066A - [Datasheet](https://raw.githubusercontent.com/TheEnbyperor/mitel-firmware/root/datasheets/sn74lv4066a.pdf) - Quad analogue switch

2 x LVC14A - [Datasheet](https://raw.githubusercontent.com/TheEnbyperor/mitel-firmware/root/datasheets/sn74lvc14a.pdf) - Hex Schmitt trigger Inverter

2 x 34CZ - [Datasheet](https://raw.githubusercontent.com/TheEnbyperor/mitel-firmware/root/datasheets/sn74ahc595.pdf) - Triple buffer