#!/bin/bash

echo "1) Turn off Switch"
echo "2) Ground right JoyCon rail PIN10 using paperclip JIG or JoyCon mod"
echo "3) Press VOL+ and connect USB cable to the Switch"
echo "-=-=--=--=--=-=-=-=-=--=-=-=-=-=-=-=-=--=-=-"
echo "Waiting for NVidia APX (Switch in RCM mode)."
echo "-=-=--=--=--=-=-=-=-=--=-=-=-=-=-=-=-=--=-=-"
echo
./shofel2.py coreboot/cbfs.bin coreboot/coreboot.rom
echo
echo "Detected. Waiting 5 seconds"
echo
sleep 5
./imx_usb -c conf/
echo
echo "Done. You should see kernel booting on switch soon"
echo 
echo "-//- kombos.org -//-"
