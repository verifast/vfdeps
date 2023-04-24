![build workflow](https://github.com/verifast/vfdeps/actions/workflows/build.yml/badge.svg)
# vfdeps
Dependencies for VeriFast

This repository contains the build script for building OCaml and the OCaml-based packages needed to build [VeriFast](https://github.com/verifast/verifast) for Linux and macOS.

For the Windows version, see [vfdeps-win](https://github.com/verifast/vfdeps-win).

## Supply chain security

This repository's GitHub Actions workflow signs artifacts using [sigstore](https://www.sigstore.dev)'s [cosign](https://docs.sigstore.dev/cosign/overview/) tool, so that anyone can check that the artifact was produced by GitHub Actions from a particular commit from this repository. To do so, first create a SHASUMS file containing the SHA-256 hash and name (without path) of the artifact and then compute the SHA-256 hash of that SHASUMS file:
```bash
cd path/to/artifact_dir && shasum -a 256 artifact_name > SHASUMS && shasum -a 256 SHASUMS
```
Then look up that hash in [Rekor](https://search.sigstore.dev/) and check that it was signed by a GitHub Actions workflow of this repository. If the hash is not in Rekor or does not map to this repository, do not trust it.
