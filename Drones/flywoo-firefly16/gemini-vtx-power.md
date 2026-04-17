conversation with gemini about vtx power. it has been confidently wrong before, do not take this as ground truth, but as a speculation that's worth verifying.

You have the correct end goal in mind, but there is a three-way communication breakdown between your radio mix, Betaflight's channel mapping, and Betaflight's activation range.

Here is the technical breakdown of your hardware and exactly why the switch is failing to cut the VTX power.

1. Hardware Misidentification
You have an F405 flight controller, not an F411. The firmware dump explicitly declares board_name FLYWOOF405S_AIO. This is a hardware advantage—the F405 processor has more UARTs and flash memory—but it means F411 pinout documentation will lead you astray.

The configuration resource PINIO 2 C08 is the correct, factory-designated physical pin for the 9V BEC switch on the Flywoo F405 AIO.

2. The Logic Disconnects
To trigger that physical pin, the signal must pass through three gates, and your current configuration fails at two of them.

The Radio Output (EdgeTX): Your radio configuration snippet maps the L3 switch to destCh: 8 (Channel 8). With a source of MAX and a weight of 100, activating L3 sends a 2000us (High) signal on Channel 8.

Betaflight's Listener (The Channel Mismatch): Betaflight starts counting Aux channels at Channel 5. Therefore, Channel 8 is Aux 4. Looking at your dump, aux 3 13 3 1800 2100 maps Aux 4 (index 3) to box 13, which is the Beeper. Right now, flipping L3 is turning on your beeper, not your VTX switch.

The VTX Switch Mapping (The Range Mismatch): Your VTX power switch is controlled by Betaflight mode USER2 (box 41). Your dump shows aux 5 41 4 900 1200. This means the flight controller is waiting for a signal on Channel 9 (Aux 5, index 4), and it specifically requires that signal to drop to between 900us and 1200us (the "Low" switch position) to activate USER2.

3. The Fix
To establish an unbroken logical path from your finger to the VTX, align the radio output with the Betaflight mode listener.

Step 1: Re-route the Radio (EdgeTX)

Open your Mixes page on the transmitter.

Move the VTX switch mix from CH8 to CH9. (Leave CH8 alone so your beeper remains functional).

Ensure the switch outputs 2000 (High) when you want the VTX on, and 1000 (Low) when you want it off.

Step 2: Correct the Range (Betaflight)
While you can alter this in the CLI, fixing mode ranges is significantly safer and easier in the visual GUI.

Open Betaflight Configurator and navigate to the Modes tab.

Scroll to USER2 (This is the PINIO 2 / C08 link).

Verify the dropdown is set to AUX 5 (Channel 9).

Drag the yellow activation slider to the right so it covers the 1800 - 2100 range.

Click Save.

When you flip L3, EdgeTX will now send a 2000us signal on Channel 9. Betaflight will register Aux 5 going High, triggering the USER2 mode, which commands PINIO 2 to pull pin C08 high, successfully powering the video transmitter.