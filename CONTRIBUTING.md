# Contributing to Project Knowledge

---

## Ways to Contribute

- **Improve the Standard (`spec/`)** — Clarify specs, add new dimensions, fix ambiguities
- **Improve the Skill (`skill.md`)** — Better entity extraction, pattern analysis, performance
- **Improve the CLI (`cli/`)** — Better template rendering, platform support
- **Internationalization** — Translate `spec/` and create locale templates
- **Templates (`templates/`)** — Better placeholders, additional sections, examples
- **Tests (`tests/`)** — More conformance checks, test fixtures, CI integration

## PR Guidelines

1. **One PR = one concern.** Don't mix spec changes with CLI changes.
2. **Templates are shared.** Both skill and CLI render from `templates/`. Changes must keep both working.
3. **Spec changes need consensus.** Open an issue first.
4. **Update tests.** If you add a conformance check, test it.

## Communication

- Issues for spec discussions
- Tag: `[spec]`, `[skill]`, `[cli]`, `[i18n]`, `[test]`

---

By contributing, you agree your contributions are licensed under MIT.
