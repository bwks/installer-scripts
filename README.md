# installer-scripts

Install scripts to perform various installs across different operating systems.

## Shell Scripts

All scripts are located in `shell/` and target Ubuntu/Debian-based systems.

| Script | Description | Root Required |
|--------|-------------|:---:|
| `install-awscli.sh` | Installs the [AWS CLI v2](https://aws.amazon.com/cli/) from the official zip bundle | No (uses sudo) |
| `install-azurecli.sh` | Installs the [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/) via the Microsoft apt repository | Yes |
| `install-claudecode.sh` | Installs [Claude Code](https://claude.ai) CLI for the current user via the official install script | No |
| `install-dev-dependencies.sh` | Installs C build toolchain and headers for Rust FFI crates (build-essential, pkg-config, libssl-dev, libvirt-dev, etc.) | Yes |
| `install-docker.sh` | Installs Docker Engine, CLI, Buildx, and Compose via the official Docker apt repository | Yes |
| `install-githubcli.sh` | Installs the GitHub CLI (`gh`) via the official apt repository | Yes (sudo) |
| `install-packer.sh` | Installs HashiCorp Packer via the official apt repository | Yes |
| `install-python-dev.sh` | Installs Python dev tools from [Astral](https://astral.sh) to `/usr/local/bin`: uv (package manager), ruff (linter/formatter), and ty (type checker) | Yes |
| `install-rust.sh` | Installs the Rust stable toolchain for the current user via [rustup](https://rustup.rs/) | No |
| `install-terraform.sh` | Installs [HashiCorp Terraform](https://www.terraform.io/) via the official apt repository | Yes |
| `install-virt.sh` | Installs QEMU/KVM and libvirt for virtual machine management | Yes |
| `install-zellij.sh` | Installs [Zellij](https://zellij.dev) terminal multiplexer via cargo with custom config and layouts | No (requires Rust) |
| `setup-hashicorp-repo.sh` | Adds the HashiCorp apt repository and GPG key (idempotent, used by Packer/Terraform scripts) | Yes |
| `setup-paths.sh` | Adds `$HOME/.local/bin` to PATH in `.bashrc` and `.zshrc` (idempotent) | No |
| `update-claudecode.sh` | Updates Claude Code to the latest version in `/usr/local/bin` | Yes |
| `update-python-dev.sh` | Updates uv, ruff, and ty to the latest versions in `/usr/local/bin` | Yes |
| `update-rust.sh` | Updates the system-wide Rust stable toolchain via rustup | Yes |
