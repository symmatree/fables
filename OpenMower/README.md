# OpenMower stack discovery (task zero)

This directory holds the first data-gathering wave for understanding the v1 OpenMower stack: what has configurable or updatable state, and how to identify it.

## Documents

| Document | Purpose |
|----------|---------|
| [openmower-os-stack.md](openmower-os-stack.md) | How OpenMowerOS and related repos orchestrate the stack; payload source; config locations; OS vs application version identity. |
| [openmower-docs-summary.md](openmower-docs-summary.md) | Summary of official docs: configuration, testing, monitoring, debugging, customization; step-by-step, Knowledge Base, troubleshooting; v1 legacy and errata. |
| [openmower-architecture.md](openmower-architecture.md) | Architectural summary: v1 stack layers, configurable/updatable pieces, how to identify versions, where an indeterminate (mixed) state can show up and what to inspect first. |

## Intent

- **Task zero:** Identify the various components in the v1 OpenMower stack that have configurable state and how we can identify them.
- **Next:** Use this as the reference to plan version assessment on the robot, choose a target state (old vs new release), and decide how to get there (reflash, reset, or update in place).

Public-safe: no passwords; config and geolocation are fine.
