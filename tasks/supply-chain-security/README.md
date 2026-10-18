# Add supply-chain security to CI

**Bonus task — Development** · [Assignment](../../README.md)

## Goal

Stop known-vulnerable images, risky infrastructure settings and leaked secrets before they merge.

## Requirements

If you choose this task, in your CI workflows:
- Scan the application image for known vulnerabilities and the Terraform for misconfigurations.
- Generate a software bill of materials (SBOM) for the image and keep it as a build artifact.
- Pin base images by digest, and keep secrets out of images, Compose files and workflows; scan for them.
- Fail the build at a severity threshold you choose, and justify it. Show how a reviewed exception is recorded rather than silently ignored.
- Use established scanners rather than custom checks.

## Suggested starting point

Run the scanners locally first. Expect findings in the base image: deciding what blocks a merge is part of the task.

## How to demonstrate it

A run that fails on a finding, the fix or recorded exception, a passing run, and the SBOM artifact.
