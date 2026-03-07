https://www.u-blox.com/en/product/zed-f9r-module
The R is for "Dead Reckoning" (or at least it works)
I have [[F9R on Sparkfun Breakout]]

Original (EOL) desc for the 01B module:
> u-blox F9 dual band GNSS module high precision Dead Reckoning LGA, 17x22 mm, 250 pcs/reel $149.00 USD

###  u-blox HPS 1.40 Interface description
[[u-blox-F9-HPS-1.40_InterfaceDescription_UBXDOC-963802114-13138.pdf]] https://content.u-blox.com/sites/default/files/documents/u-blox-F9-HPS-1.40_InterfaceDescription_UBXDOC-963802114-13138.pdf
#### "ZED-F9R Getting started with high-precision sensor fusion" App Note
[[ZED-F9R-GettingStarted_AppNote_UBX-22035176.pdf]]

### F9R Integration Manual
For [[ZED-F9R module]]
https://content.u-blox.com/sites/default/files/ZED-F9R_Integrationmanual_UBX-20039643.pdf
Includes "ZED-F9R-01B-00 Firmware Version HPS 1.20"
[[ZED-F9R_Integrationmanual_UBX-20039643.pdf]]

Similar to [[ZED F9P integration manual]] but includes section on High Precision Sensor Fusion (HPS).
### Datasheet for 01B
https://content.u-blox.com/sites/default/files/ZED-F9R-01B_Datasheet_UBX-19054459.pdf
[[ZED-F9R-01B_Datasheet_UBX-19054459.pdf]]

Lists RTCM messages for RTK.
Block diagram.
Pinout.

### From the mfg

| Product variants                               | ZED-F9R                                      |
| ---------------------------------------------- | -------------------------------------------- |
| GNSS features                                  |                                              |
| GNSS                                           | GPS / QZSS, GLONASS, Galileo, BeiDou         |
| Number of concurrent GNSS                      | 4                                            |
| GNSS bands                                     | L1C/A, L2C, L1OF, L2OF, E1B/C, E5b, B1I, B2I |
| Oscillators                                    | TCXO                                         |
| Interfaces                                     |                                              |
| UART x 2                                       | ✓                                            |
| USB                                            | ✓                                            |
| SPI                                            | ✓                                            |
| I2C                                            | ✓                                            |
| Electrical data                                |                                              |
| Maximum supply [V]                             | 3.6                                          |
| Minimum supply [V]                             | 2.7                                          |
| Environmental data,  <br>quality & reliability |                                              |
| Maximum temperature [°C]                       | 85                                           |
| Minimum temperature [°C]                       | -40                                          |
| Features                                       |                                              |
| Additional SAW                                 | ✓                                            |
| Carrier phase output                           | ✓                                            |
| Data logging                                   | ✓                                            |
| Programmable flash memory                      | ✓                                            |
| RTC crystal                                    | ✓                                            |
| RTK rover                                      | ✓                                            |
| Time pulse output                              | ✓                                            |
| General features                               |                                              |
| Antennas                                       | Pin (active) for external antenna            |
| Dimensions                                     |                                              |
| Dimensions [mm]                                | 17.0 x 22.0 x 2.4                            |
| Services                                       |                                              |
| AssistNow                                      | ✓                                            |
| PointPerfect                                   | ✓                                            |
The ZED-F9R positioning module features the u-blox F9 receiver platform providing a reliable multi-band GNSS sensor fusion solution for industrial applications in a compact form factor. The wide bandwidth allows reception of many satellites simultaneously, resulting in high availability of RTK solutions and quick convergence time.

This high-performance sensor fusion module has an integrated inertial measurement unit (IMU) for RTK positioning. The sophisticated built-in algorithms fuse the IMU data, GNSS measurements, wheel ticks, correction data, and a vehicle dynamics model to provide optimal positioning accuracy where GNSS alone would fail.

The module operates under open sky, in the wooded countryside, in difficult multipath environments, and even in covered areas. Designed for industrial applications like agricultural machinery or heavy trucks, ZED-F9R is the ultimate solution for a data-driven economy where control and position availability are key to success. Low-speed ground robotics are also supported by allowing low-speed calibration. Specialized dynamic models optimize performance for different classes of wheeled vehicles.

The device is a turnkey self-contained solution. This eliminates the technical risk and effort of selecting and integrating RF components and third-party libraries such as precise positioning engines. ZED-F9R offers support for a range of correction services allowing each application to optimize performance according to the application's unique needs. ZED-F9R comes with built-in support for RTCM or SPARTN-formatted corrections, enabling high precision navigation using internet or satellite data.

The ZED-F9R modules use GNSS chips qualified according to AEC‑Q100 and are manufactured in ISO/TS 16949 certified sites. Qualification tests are performed as stipulated in the ISO16750 standard: "Road vehicles – Environmental conditions and testing for electrical and electronic equipment". The ZED-F9R professional grade module adheres to industrial standard quality specifications and production flow.