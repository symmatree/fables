So you can't just "attach a USB device" to the WSL instance I guess. But you can virtualize it over the network...
https://devblogs.microsoft.com/commandline/connecting-usb-devices-to-wsl/
https://github.com/dorssel/usbipd-win/releases
https://stackoverflow.com/questions/69429069/wsl-and-serial-port
1. Download and install [USBIPD-WIN](https://github.com/dorssel/usbipd-win/releases)
2. Open PowerShell as an administrator.
3. Obtain a list of USB devices using `usbipd list`.
4. Find the bus ID of the device (e.g. `4-4`) and use `usbipd bind --busid <id>` to share it with WSL.
5. Use `usbipd attach --wsl --busid <id>` to attach the USB port to WSL.
6. In WSL, you can use `lsusb` to see the device.

Once you are done using the device in WSL, you can either physically disconnect the device or run this command from an _administrator_ command prompt on Windows.

```ada
usbipd detach --busid <busid>
```