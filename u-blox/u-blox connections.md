[[u-blox Serial WSL on Windows]]
https://github.com/symmatree/amateur/blob/main/gnss/ublox/README.md
### u-center

There's u-center which is Windows only but can connect to a network stream. Good for diagnosis and exploration.

- [https://ozzmaker.com/using-u-center-to-connect-to-a-raspberry-pi-with-an-attached-berrygps-imu-gsm/](https://ozzmaker.com/using-u-center-to-connect-to-a-raspberry-pi-with-an-attached-berrygps-imu-gsm/) (uses ser2net)
#### RTCM corrections
Routing RTCM via the host makes sense, it keeps the F9x focused on navigation not radio, and makes room for multiplexing.

Per [F9P integration manual](https://content.u-blox.com/sites/default/files/ZED-F9P_IntegrationManual_UBX-18010802.pdf) the I2C interface has "Maximum bit rate 400 kb/s" which should be plenty though unclear if it's bidirectional.

If I'm using their library I believe this is built in, at least for a single node.