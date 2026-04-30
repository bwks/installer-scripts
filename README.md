# installer-scripts

Install scripts to perform various installs across different operating systems.

## Shell Scripts

All scripts are located in `shell/` and target Ubuntu/Debian-based systems.

| Script | Description | Root Required |
|--------|-------------|:---:|
| `install-awscli.sh` | Installs the [AWS CLI v2](https://aws.amazon.com/cli/) from the official zip bundle | No (uses sudo) |
| `install-azurecli.sh` | Installs the [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/) via the Microsoft apt repository | Yes |
| `install-cargo-tools.sh` | Installs cargo-based dev tools ([cargo-nextest](https://nexte.st/), [cargo-llvm-cov](https://github.com/taiki-e/cargo-llvm-cov)) for the current user | No (requires Rust) |
| `install-claudecode.sh` | Installs [Claude Code](https://claude.ai) CLI for the current user via the official install script | No |
| `install-dev-dependencies.sh` | Installs C build toolchain and headers for Rust FFI crates (build-essential, pkg-config, libssl-dev, libvirt-dev, etc.) | Yes |
| `install-docker.sh` | Installs Docker Engine, CLI, Buildx, and Compose via the official Docker apt repository | Yes |
| `install-githubcli.sh` | Installs the GitHub CLI (`gh`) via the official apt repository | Yes (sudo) |
| `install-nanos.sh` | Installs the [Nanos](https://nanos.org) unikernel toolchain (`ops`) to `$HOME/.ops/bin` via the official installer | No |
| `install-nodejs.sh` | Installs [NVM](https://github.com/nvm-sh/nvm) and Node.js (latest LTS by default) with npm for the current user | No |
| `install-opencode.sh` | Installs [opencode](https://opencode.ai) AI coding agent to `$HOME/.opencode/bin` via the official installer | No |
| `install-packer.sh` | Installs HashiCorp Packer via the official apt repository | Yes |
| `install-pi.sh` | Installs [pi](https://pi.dev) (Pi Coding Agent) globally via npm | No (requires Node.js) |
| `install-qemu-guest-agent.sh` | Installs and enables the [QEMU Guest Agent](https://wiki.qemu.org/Features/GuestAgent) service | Yes |
| `install-python-dev.sh` | Installs Python dev tools from [Astral](https://astral.sh) to `/usr/local/bin`: uv (package manager), ruff (linter/formatter), and ty (type checker) | Yes |
| `install-rust.sh` | Installs the Rust stable toolchain for the current user via [rustup](https://rustup.rs/) | No |
| `install-starship.sh` | Installs the [Starship](https://starship.rs) prompt for the current user and configures bash/zsh shell initialization | No |
| `install-terraform.sh` | Installs [HashiCorp Terraform](https://www.terraform.io/) via the official apt repository | Yes |
| `install-tmux.sh` | Installs [tmux](https://github.com/tmux/tmux/wiki) via apt, writes the custom user config to `~/.config/tmux/tmux.conf`, and installs/updates the required tmux plugins (`tmux-resurrect`, Catppuccin) | No (uses sudo) |
| `install-unikraft.sh` | Installs the [Unikraft](https://unikraft.org) toolchain (`kraft` via [kraftkit](https://kraftkit.sh)) to `/usr/local/bin` via the official installer | No (uses sudo) |
| `install-virt.sh` | Installs QEMU/KVM and libvirt for virtual machine management | Yes |
| `install-zellij.sh` | Installs [Zellij](https://zellij.dev) terminal multiplexer via cargo with custom config and layouts | No (requires Rust) |
| `install-zsh-ohmyzsh.sh` | Installs [zsh](https://www.zsh.org), sets it as the default login shell, and installs [Oh My Zsh](https://ohmyz.sh) for the current user | No (uses sudo) |
| `setup-hashicorp-repo.sh` | Adds the HashiCorp apt repository and GPG key (idempotent, used by Packer/Terraform scripts) | Yes |
| `setup-paths.sh` | Adds `$HOME/.local/bin` to PATH in `.bashrc` and `.zshrc` (idempotent) | No |
| `update-claudecode.sh` | Updates Claude Code to the latest version in `/usr/local/bin` | Yes |
| `update-python-dev.sh` | Updates uv, ruff, and ty to the latest versions in `/usr/local/bin` | Yes |
| `update-rust.sh` | Updates the system-wide Rust stable toolchain via rustup | Yes |
