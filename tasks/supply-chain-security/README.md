# Add supply-chain security to CI

**Bonus task — Development** · [Assignment](../../README.md) · Time guide: ~1.5–2 h

## Goal

Stop known-vulnerable images, risky infrastructure settings and leaked secrets from being merged, automatically, in CI.

## Deliverables

| What | Where |
|---|---|
| Security steps | `.github/workflows/ci-core-dev.yml`, or a separate workflow your Dev workflow triggers |
| A file recording accepted exceptions | Your repository, a path of your choice |
| Demonstration | EVIDENCE.md, section "Bonus: supply-chain security" |

## Requirements

1. Use established scanners, not custom checks.
2. CI must:
   - scan the application image for known vulnerabilities
   - scan `infra/` for misconfigurations
   - scan the repository for committed secrets
3. CI must generate a software bill of materials (SBOM) for the application image and upload it as a workflow artifact.
4. Every base image (`FROM` line) must be pinned by digest (`@sha256:…`).
5. Choose a severity threshold, for example "fail on HIGH or CRITICAL with a fix available". The build must fail on findings at or above it. Explain your choice in at most 3 lines.
6. Any finding you accept must be listed, with a reason, in the exceptions file. No silent ignores.

## Done when

- [ ] One CI run fails on a real finding (or on a deliberately added one, for example an unpinned base image or a test secret).
- [ ] After a fix, or a recorded exception, the run passes.
- [ ] The SBOM artifact is attached to the passing run.

## Evidence to include in EVIDENCE.md

- Links to the failing and the passing run (or local output, if Actions cannot run).
- The exceptions file contents.
- The threshold explanation.

## Not required

- Image signing, admission control, or license compliance.
