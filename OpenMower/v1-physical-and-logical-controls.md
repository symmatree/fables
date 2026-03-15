# OpenMower v1: Physical and logical controls

Quick reference for the YardForce Classic 500(B) v1 hardware: power switch, mainboard LED (Neopixel), and charging. Sourced from the **v1 legacy docs** ([openmower.de/archive/v1.0.2/docs](https://openmower.de/archive/v1.0.2/docs/)).

---

## Power switch

- **Location:** Back of the robot.
- **Use:** Turn the mower **on** by flipping the switch on; turn **off** immediately if you see/smell anything wrong (smoke, hot electronics, blown fuses).
- **Before connecting power:** Either connect the power connector last, or make sure the switch is **off** before connecting it.

---

## Mainboard RGB LED (Neopixel) meanings

| LED state | Meaning |
|-----------|--------|
| **Boot sequence** | dim red (firmware booted) → bright red (RPi powered on) → blue/turquoise/brown (sound init). Then: |
| **Orange–red flashing** | Emergency mode, **ROS not connected** (e.g. no OpenMower stack running, or crash loop). |
| **Green–red flashing** | Emergency mode, **ROS is connected** (e.g. lift sensor triggered, e-stop pressed, or voltage issue). |
| **Steady green** | **Ready:** ROS connected, no emergency (voltages OK, wheels not lifted, emergency button not pressed). |

For GPS testing: wait until the mainboard LED is **green or green/red** (i.e. ROS talking to the mainboard); **steady green** means the mower is fully enabled and safe to take outside.

---

## Charging (v1)

- **Do not** use the stock YardForce charger with the OpenMower mainboard. Use the **modified docking station** (see v1 Docking Station Assembly).
- **To charge:** Mower must be **turned on** (switch on). Insert the mower into the docking station; the dock powers the electronics and charges the battery (CC/CV typically 29.2 V, 1 A).
- **Fully charged:** No dedicated “fully charged” LED in the v1 docs; leave on the dock until you’re satisfied, or use the OpenMower app / battery state if available. Prerequisite for recording areas and mowing is “Mower fully charged.”

---

## State of charge (software vs hardware)

**Software (ROS):** Battery voltage and charging state come from the **mainboard** over its serial link. The only software that reads this is the **mower_comms** node inside the OpenMower ROS stack. When the stack is running, it publishes:

- **Topic:** `ll/power` (message type `mower_msgs/Power`)
- **Fields:** `v_battery` (V), `v_charge` (charger voltage), `charge_current`, `charger_enabled`, `charger_status`

So to query state of charge from software you need:

1. **ROS running** and the **openmower container** (or at least the part that runs mower_comms) **up**. With your current crash loop, the container exits before any node runs, so there is **no** software way to read voltage until the crash is fixed.
2. After fixing the crash (e.g. set `ROS_MASTER_URI` in the service or in `mower_config.txt`), start the service and then, from a shell that can see ROS (e.g. inside the container or with `ROS_MASTER_URI` set):  
   `rostopic echo /ll/power`  
   You will see `v_battery` (e.g. 24–29 V for a typical 7S pack). The params use ~28.5 V as “full” and ~24 V as “empty” for YardForce 500.

**Without ROS:** There is no other daemon or API that reads the mainboard. The only way to check voltage without bringing up the stack is **hardware**: multimeter on the **charging contacts** (with the mower on or in the dock). Same 24–29 V range; ~28 V+ is well charged, &lt;25 V is low.

**About the “don’t run out of charge before dock mods” warning:** The docs mean that with an **unmodified** dock you cannot charge, so if you drain the battery before finishing the docking-station modifications, you have no way to recharge. If you **already have** the modified dock, you can charge a low or flat pack by putting the mower (switch on) in the dock. A LiPo run to true zero can be damaged or need careful reconditioning, but “unrecoverable” in that context is mainly “no charger available,” not necessarily a dead cell.

---

## Before GPS testing in sunlight

1. **Charge:** Put the mower in the (modified) dock, switch **on**, and leave it to charge.
2. **Enable:** After boot, check the mainboard LED. **Steady green** = fully enabled (ROS connected, no emergency).
3. **Take outside:** With steady green, you can move the mower into the open for GPS quality checks; the GPS antenna needs a clear sky view.

If the LED stays **orange–red flashing**, ROS is not talking to the mainboard (e.g. your current crash loop). You can still do **standalone GPS diagnostics** (Phase 1: stop openmower.service, fix ser2net, use u-center over TCP) without a steady green LED; the mainboard and battery just need to be powered so the GPS has power.
