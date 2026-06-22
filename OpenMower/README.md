# OpenMower stack discovery (task zero)

This directory holds the first data-gathering wave for understanding the v1 OpenMower stack: what has configurable or updatable state, and how to identify it.

## Documents

| Document | Purpose |
|----------|---------|
| [openmower-os-stack.md](openmower-os-stack.md) | How OpenMowerOS and related repos orchestrate the stack; payload source; config locations; OS vs application version identity. |
| [openmower-docs-summary.md](openmower-docs-summary.md) | Summary of official docs: configuration, testing, monitoring, debugging, customization; step-by-step, Knowledge Base, troubleshooting; v1 legacy and errata. |
| [openmower-architecture.md](openmower-architecture.md) | Architectural summary: v1 stack layers, configurable/updatable pieces, how to identify versions, where an indeterminate (mixed) state can show up and what to inspect first. |
| [onboard-data-gathering-instructions.md](onboard-data-gathering-instructions.md) | Handoff for the agent (or user) working on the mower via Remote-SSH/SSH: context, inspection order, commands to run, where to write results, and how to behave when something is unexpected. |
| [v1-physical-and-logical-controls.md](v1-physical-and-logical-controls.md) | v1 power switch (back of robot), mainboard Neopixel LED meanings (steady green = ready), and charging via the modified dock. |

## Current state

2026-06-14 - imaged the SD Card to openmower latest. raspi-config set the hostname to kikuyu.

Access under WSL with "ssh.exe openmower@kikuyu.local.symmatree.com" and it will use the OnePKey from 1Password.

