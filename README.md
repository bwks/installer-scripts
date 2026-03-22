# installer-scripts

Install scripts to perform various installs across different operating systems.

## Shell Scripts

All scripts are located in `shell/` and target Ubuntu/Debian-based systems.

| Script | Description | Root Required |
|--------|-------------|:---:|
| `install-claudecode.sh` | Installs [Claude Code](https://claude.ai) CLI via the official installer | No |
| `install-dev-dependencies.sh` | Installs C build toolchain and headers for Rust FFI crates (build-essential, pkg-config, libssl-dev, libvirt-dev, etc.) | Yes |
| `install-docker.sh` | Installs Docker Engine, CLI, Buildx, and Compose via the official Docker apt repository | Yes |
| `install-githubcli.sh` | Installs the GitHub CLI (`gh`) via the official apt repository | Yes (sudo) |
| `install-packer.sh` | Installs HashiCorp Packer via the official apt repository | Yes |
| `install-python-dev.sh` | Installs Python dev tools from [Astral](https://astral.sh): uv (package manager), ruff (linter/formatter), and ty (type checker) | No |
| `install-rust.sh` | Installs the Rust stable toolchain via rustup for the `sherpa` user | No |
| `install-virt.sh` | Installs QEMU/KVM and libvirt for virtual machine management | Yes |
