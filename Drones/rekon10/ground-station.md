# Ground equipment

[Back to index](README.md)

## Radiomaster Boxer (ELRS 2.4 GHz)

Sourced from GetFPV.

Charges natively via bottom USB-C port. Unified radio, carries control inputs, also carries RTCM corrections (received from base station over WiFi) to the aircraft over ELRS.

Battery: **Radiomaster 6200mAh 2S 7.4V High-Capacity Rechargeable LiPo Battery with XT30/JST-XH Plug** 

### Current Config

* Main Firmware: `EdgeTX "Queen Anne's Revenge" v2.12.0`
* Firmware Options (available): crossfire, ghost, internalmulti, multimodule, lua, luac, cli, passthrough
* Int Module RM Boxer V3.6.3
* SD Card, LUA from v2.12.0

### Internal ELRS Module

Wifi

* `84:1f:e8:83:0a:a0` 
* dhcp reservation `10.0.4.41`
* `http://boxer-tx.local.symmatree.com`

Runtime options

* Wifi auto-on 60s
* TLM Report interval 240ms
* Fan runtime 30s
* Use as Airport serial device: unchecked
* Airport UART Baud: 460800

Self-reports

* RadioMaster Boxer Internal 2.4GHz TX
* Firmware Rev. 3.6.3 (288efe) ISM2G4
* Needs firmware for `Unified_ESP32_2400_TX` target
* It notes that the binding UID was flashed

#### Backpack

* `14:08:08:f3:35:c5`
* `10.0.6.120`
* `http://boxer-txbp.local.symmatree.com`
* Current: RadioMaster Boxer Internal 2.4GHz TX / Firmware Rev. 1.5.5 (149419)
* Initial: DUPLETX_TX_Backpack firmware / Firmware Rev. 1.3.0 (a64338)

MavLink configuration (default):

* Send port 14550
* Listen port 14555

The backpack's UDP MAVLink bridge broadcasts for discovery then **latches to the first ground station that answers** and unicasts only there (firmware never releases the lock), which is how RTK corrections get silently stolen by a stray GCS. Delivery path, the `GET /mavlink` diagnostic (`ip.gcs` names who it latched to), and how it recovers: coordinator [`docs/rtk-corrections-path.md`](https://github.com/symmatree/coordinator/blob/main/docs/rtk-corrections-path.md).

#### Rekon (model 10)

Module config snapshot (`config/elrs-boxer-models.json`, exported from TX module):


| Config field | Lua field | Current semantic value |
|--------------|-----------|------------------------|
| `config.uid` | -- | Module UID `[118,19,55,7,184,191]` |
| `config.model.10.packet-rate = 5` | Packet Rate | `333Hz Full` (Rekon10 profile) |
| `config.model.10.telemetry-ratio = 8` | Telem Ratio | `1:2` |
| `config.model.10.switch-mode = 1` | Switch Mode | `16ch Rate` |
| `config.model.10.power.max-power = 6` | TX Power | `1000 mW` ceiling |
| `config.model.10.power.dynamic-power = 1` | TX Power (Dynamic) | Dynamic power enabled |
| `config.model.10.model-match = 0` | Model Match | Off |
| `config.model.10.tx-antenna = 0` | TX Antenna | Default/auto antenna mode |

#### Firefly (model 16)

| Config field | Lua field | Current semantic value |
|--------------|-----------|------------------------|
| `config.uid` | -- | Module UID `[118,19,55,7,184,191]` |
| `config.model.16.packet-rate = 6` | Packet Rate | Firefly16 profile uses a different packet-rate mode than Rekon10 |
| `config.model.16.telemetry-ratio = 6` | Telem Ratio | Firefly16 telemetry ratio differs from Rekon10 |
| `config.model.16.switch-mode = 1` | Switch Mode | Firefly16 uses `16ch Rate` |
| `config.model.16.power.max-power = 5` | TX Power | Firefly16 max power below Rekon10 (`1000 mW` not selected) |
| `config.model.16.power.dynamic-power = 1` | TX Power (Dynamic) | Dynamic power enabled |
| `config.model.16.model-match = 1` | Model Match | On (Firefly16) |

### Rekon, Boxer state

Internal module enabled.

* Packet Rate 333Hz Full
* Telem Ratio 1:2 (13211 bps)
* Switch Mode 16ch Rate/ (truncated)
* Link Mode: MAVLink
* Model Match: Off (ID: 10)
* TX Power: 1000 mW Dynamic
* "3.6.3 ISM2G4" `288efe`


### Initial state

Boxer initial SD card contents in [drive](https://drive.google.com/drive/folders/1pIM66oXjAqcmOdcDBGGny7LxKtZZ4euo) also the "Factroy" (sic) SD card zip from Radiomaster.

Out of the box Boxer reports `edgetx-boxer` firmware, `2.8.4-RM-Build` version. Flashed using buddy.edgetx.org to `EdgeTX "Queen Anne's Revenge" v2.12.0` then overwrote the SD card with the same version.

After restart it showed internal module as `RM Boxer V3.3.1` Updated to 3.6.3

### Manual edits

Fixed the switchWarning yaml in `model00.yml`. The rest is almost all just different sorting and yaml quoting and the potsConfig and switchConfig are a little different. The current [source `hwdefs`](https://github.com/EdgeTX/edgetx/blob/main/radio/src/boards/hw_defs/boxer.json) 

Google claims that the firmware itself writes the radio.yaml file on first boot; idk; maybe archive the current version then see. It seems to have renamed POT3 to P3 but did not get it under `potsConfig`, only under calibration.

`elrsv3.lua` was missing from the new. Also a lot of games but meh.

Replaced elrsv3.lua from the ELRS Configurator and also flashed with binding phrase (in 1password) and Wifi config. Adjusted some parameters per [oscar's page](https://oscarliang.com/setup-radiomaster-boxer/)

Upgraded to ELRS `3.6.3`, will hold there for SPI compatibility.

Ran ELRS tool (earlier baseline):

* 500 Hz
* Telem 1:2
* Switch Mode hybrid
* Link Mode MAVLink
* TX Power 1A

**ArduPilot FC (TBS Lucid H7):** With Link Mode MAVLink, set **SERIAL6_PROTOCOL = 2** and **SERIAL6_BAUD = 460** (not CRSF / 115200). Flash the **R24-TD** to **ELRS 3.6.3** to match the Boxer. See [ardupilot.md](ardupilot.md) (serial / ELRS) and [flight-platform.md](flight-platform.md) (hardware).

### Multi-model management (Rekon10 + Firefly16)

The Boxer manages two aircraft with different firmware and ELRS settings using three ELRS mechanisms:

1. **Binding phrase** (shared): Both receivers use the same binding phrase (in 1Password). Either will connect at the RF level to the Boxer.
2. **Receiver Number** (per EdgeTX model): Each model file sets a different Receiver Number. ELRS stores a separate configuration profile per Receiver Number on the TX module (packet rate, telemetry ratio, link mode, switch mode, power, dynamic power). Selecting a model in EdgeTX automatically loads the matching ELRS profile.
3. **Model Match** (per receiver): When enabled in the ELRS Lua script, the receiver stores its Receiver Number and refuses to output data to the FC unless the TX's current Receiver Number matches. This prevents accidentally flying the wrong aircraft with the wrong channel mapping.

| EdgeTX model | File | Receiver # | ELRS profile | Aircraft |
|--------------|------|-----------|--------------|----------|
| REKON10 | [`config/MODELS/model01.yml`](config/MODELS/model01.yml) | 10 | MAVLink, 333 Hz Full, 1:2, 16ch Rate | Rekon10 (ArduPilot) |
| FIREFLY16 | [`config/MODELS/model02.yml`](config/MODELS/model02.yml) | 16 | Normal/CRSF, 250 Hz, Std, Hybrid | Firefly16 (Betaflight) |
| BOXER | `model00.yml` | 0 | (legacy, pre-existing) | (original model, kept for reference) |

**Boxer switch physical behavior (observed):**

On the Radiomaster Boxer, the front toggle switches (SA, SB, SD) have no
natural "up" or "down" -- they stick straight up in the air. EdgeTX raw
output for these switches:

- **Toward the pilot** (pulled back) = **high** raw value (+100%, ~2012 us)
- **Away from the pilot** (pushed forward) = **low** raw value (-100%, ~988 us)
- **SB middle position** = center (~1500 us)

The shoulder switches (SE, SF) follow the same convention but are oriented
differently on the radio body.

All front-switch mixes use `weight: -100` to invert the raw signal so that
the CRSF channel output is: **toward = low, away = high**. This means the
FC-side configuration (Betaflight mode ranges, ArduPilot RC params) sees a
consistent convention: low channel value = safe/toward, high = hot/away.

**Switch layout (shared by both models):**

Rekon10 **FC** parameters that must match this layout (`FLTMODE*`, `RCx_OPTION`, relay, etc.) are tracked in [ardupilot.md](ardupilot.md) as **remaining Mission Planner work** on top of this radio design.

| Switch | Toward pilot (safe) | Away from pilot (hot) | Mix weight | Channel |
|--------|--------------------|-----------------------|------------|---------|
| SA (2-pos) | VTX off (low, ~1000 us) | VTX on (high, ~2000 us) | -100 | CH9 |
| SB (3-pos) | ANGLE (low), HORIZON (mid) | ACRO (high) | -100 | CH6 |
| SD (2-pos) | Airmode off / **Land** on **CH7** (low) | Airmode on / normal (high) | -100 | CH7 |
| SE (2-pos shoulder) | Disarmed (used by arm gate) | Armed (used by arm gate) | -- | via L1-L3 |
| SF (momentary shoulder) | Released | Held (gate + buzzer) | 100 | CH8 |
| SC (3-pos) | Unmapped (reserved) | -- | -- | -- |
| P3 (6-pos) | Unmapped (reserved) | -- | -- | -- |

**SD and RTL:** **CH7** is **Land** for tight / canopy flying where **RTL** would be unsafe; see [ardupilot.md](ardupilot.md) (**Why Land on SD, not RTL**).

Toward = safe applies to all switches, including SA: VTX off (toward)
prevents overheating on the bench. The arm gate overrides CH9 to force VTX
on while armed, so SA only controls VTX power when disarmed. **SA (or
airflow) is the only bench-heat control: the VTX comes up energized at boot
and `RELAY4_DEFAULT` cannot be used to keep it cold -- setting it `0` breaks
the ELRS boot link (see [ardupilot.md](ardupilot.md)).**

**Arm safety gate:** SF is configured as truly momentary (2POS in [`config/RADIO/radio.yml`](config/RADIO/radio.yml)). Three logical switches (L1=AND(SE down, SF held), L2=AND(SE up, SF held), L3=Sticky(L1,L2)) implement a gated latch: arming or disarming requires holding SF while flipping SE. Bumping SE without SF has no effect. **CH8** carries **SF** to the FC; **`RC8_OPTION = 30`** drives the craft buzzer **while SF is held** (see [ardupilot.md](ardupilot.md) **CH8** row). **EdgeTX** also plays **Bp1** on the **handset** on **SF2** / **L3** / **!L3** (`customFn` in [`config/MODELS/model01.yml`](config/MODELS/model01.yml)). VTX power (CH9) is forced on while armed to prevent accidental mid-flight video loss.

**Switch warnings:** EdgeTX alerts at model load if SA, SB, SD, or SE are not in their safe positions.

**ELRS profiles must be configured interactively** via the Lua script after loading models onto the SD card. Model Match is enabled per-receiver while connected.

See [ardupilot.md](ardupilot.md) for Rekon10 ArduPilot channel and parameter notes. See [Firefly16 docs](../flywoo-firefly16/firefly16.md) for Betaflight config.

### Boxer: Description of Root Directory Folders in SD Card

```
BACKUP-------------------------Model backups
EEPROM-------------------------Backup for old versions
FIRMWARE----------------------Remote control firmware
LOGS-----------------------------Logs
MODELS-------------------------Location where all model parameters are stored ***VERY IMPORTANT***
RADIO---------------------------Location where system settings parameters are stored ***VERY IMPORTANT***
SCREENSHOTS-----------------Screenshots
SCRIPTS-------------------------Plug-in scripts
    |--FUNCTIONS---------------Function scripts
    |--MIXES----------------------Mix control scripts
    |--TELEMETRY----------------Telemetry scripts
    |--TOOLS----------------------Tool scripts (displayed on the SYS-Tools page in system menu)
    |--WIZARD---------------------Model wizard scripts
SOUNDS-------------------------Voice files, Each language is a subdirectory, named by country code.
edgetx.sdcard.version---------Version description file
```

[EdgeTX user manual (B&W radios)](https://manual.edgetx.org/bw-radios)

**Cross-reference:** [ardupilot.md](ardupilot.md) (ELRS serial modes, RTCM notes); [flight-platform-build-log.md](flight-platform-build-log.md) (build chronicle). Bring-up phases live in the Cursor plan `rekon_flight_stack_bring-up_b564811b.plan.md` (not a separate checklist file in this repo).

[checklists](https://manual.edgetx.org/edgetx-how-to/model-notes-and-checklists) and it definitely sounds like we want to be all GitOps with this kind of thing.

[lua scripts](https://github.com/EdgeTX/lua-scripts) on github are a useful resource.

## Walksnail Avatar Goggles X

Firmware **39.44.5** (match Avatar HD Pro VTX to the same before flight). Flashed from [walksnail.app/firmware](https://walksnail.app/firmware) (SD card procedure).

Hardware source: GetFPV (manufacturer: Walksnail/Avatar).

**7-26 V** internal regulator, natively supports 2S through 6S. A spare 6S flight pack works directly via the included XT60-to-barrel cable. Can also run from a USB-C PD power bank with a PD-to-barrel trigger cable (needs 9 V or 12 V PD output).

## Goggle battery: Lumenier 8000 NAV

[mfg](https://www.lumenier.com/products/lumenier-nav-8000mah-6s-18650-amprius-lithium-ion-battery-xt60)

Hardware source: GetFPV (manufacturer: Lumenier).

2C at 8000 mAh = 16A for half an hour, nominal, burst to 40A.

* WATT HOURS 177.6WH
* CONNECTOR XT60
* LENGTH 110 mm
* WEIGHT 615g
* HEIGHT 70 mm
* WIDTH 37 mm
* VOLTS 22.2
* mAh 8000
* Configuration: 6S2P aka 6 sets in series (6S) of 2 cell(s) (2P) in parallel
* Charging: 
    * Use a 6S LiPo setting to charge up to 25.2v
    * Charge at 8A for maximum energy storage
* Capacity: 8.0Ah (8,000mAh)  / 178Wh
* Discharge Constant: 16A / 2C / 355W
* Discharge Burst: 40A / 8C / 888W
* Voltage Range: 18.0v - 25.2v
* Balance Connector: JST-XH
* Discharge Connector: XT60
* Cell type: Amprius SA10
* Total cell count: 12

## Charger and service tools

* **ToolkitRC M6DAC V2** charger/discharger source: Pyrodrone.
* **Castle Link USB Programming Kit V3** source: ReadyMadeRC (used for Castle CC BEC 2.0 configuration).
