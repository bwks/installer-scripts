#!/bin/bash
set -euo pipefail

# Install tmux terminal multiplexer on Debian/Ubuntu via apt.
# Also writes the local tmux configuration and installs required plugins.

echo "Installing tmux..."

if ! command -v apt-get &> /dev/null; then
  echo "Error: apt-get not found. This script targets Debian/Ubuntu-based systems."
  exit 1
fi

if [ "$(id -u)" -ne 0 ] && ! command -v sudo &> /dev/null; then
  echo "Error: sudo is required when running as a non-root user."
  exit 1
fi

as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

# If run through sudo, configure tmux for the invoking user rather than root.
TARGET_USER="${SUDO_USER:-$(id -un)}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6 || true)"
if [ -z "$TARGET_HOME" ]; then
  TARGET_HOME="$HOME"
fi
TARGET_GROUP="$(id -gn "$TARGET_USER")"

as_target() {
  if [ "$(id -u)" -eq 0 ] && [ "$TARGET_USER" != "root" ]; then
    if command -v runuser &> /dev/null; then
      runuser -u "$TARGET_USER" -- env HOME="$TARGET_HOME" "$@"
    elif command -v sudo &> /dev/null; then
      sudo -H -u "$TARGET_USER" "$@"
    else
      "$@"
    fi
  else
    env HOME="$TARGET_HOME" "$@"
  fi
}

TMUX_CONF="${TMUX_CONF:-$TARGET_HOME/.config/tmux/tmux.conf}"
TMUX_PLUGIN_DIR="$TARGET_HOME/.config/tmux/plugins"

install_or_update_plugin() {
  local plugin_path="$1"
  local repo_url="$2"
  local fallback_branch="$3"
  local plugin_dir="$TMUX_PLUGIN_DIR/$plugin_path"
  local default_branch

  as_target mkdir -p "$(dirname "$plugin_dir")"

  if [ -d "$plugin_dir/.git" ]; then
    echo "Updating tmux plugin: $plugin_path"
    if as_target git -C "$plugin_dir" remote get-url origin > /dev/null 2>&1; then
      as_target git -C "$plugin_dir" remote set-url origin "$repo_url"
    else
      as_target git -C "$plugin_dir" remote add origin "$repo_url"
    fi
    as_target git -C "$plugin_dir" fetch --depth=1 --quiet origin

    default_branch="$(as_target git -C "$plugin_dir" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2> /dev/null | sed 's#^origin/##' || true)"
    if [ -z "$default_branch" ]; then
      as_target git -C "$plugin_dir" remote set-head origin -a > /dev/null 2>&1 || true
      default_branch="$(as_target git -C "$plugin_dir" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2> /dev/null | sed 's#^origin/##' || true)"
    fi
    if [ -z "$default_branch" ]; then
      default_branch="$fallback_branch"
    fi

    if as_target git -C "$plugin_dir" show-ref --verify --quiet "refs/heads/$default_branch"; then
      as_target git -C "$plugin_dir" checkout --quiet "$default_branch"
      as_target git -C "$plugin_dir" pull --ff-only --quiet origin "$default_branch"
    else
      as_target git -C "$plugin_dir" checkout --quiet -B "$default_branch" "origin/$default_branch"
    fi
    as_target git -C "$plugin_dir" branch --set-upstream-to="origin/$default_branch" "$default_branch" > /dev/null 2>&1 || true
  elif [ -e "$plugin_dir" ]; then
    echo "Error: $plugin_dir exists but is not a git repository."
    echo "Move it out of the way and rerun this script."
    exit 1
  else
    echo "Installing tmux plugin: $plugin_path"
    as_target git clone --depth=1 --quiet "$repo_url" "$plugin_dir"
  fi
}

# Install tmux and git for plugin management.
as_root apt-get update -qq
as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq tmux git > /dev/null

# Install/update plugins referenced by the tmux configuration.
if [ "$(id -u)" -eq 0 ] && [ "$TARGET_USER" != "root" ] && [ -d "$TARGET_HOME/.config/tmux" ]; then
  chown -R "$TARGET_USER:$TARGET_GROUP" "$TARGET_HOME/.config/tmux"
fi
as_target mkdir -p "$TMUX_PLUGIN_DIR"
install_or_update_plugin "tmux-resurrect" "https://github.com/tmux-plugins/tmux-resurrect" "master"
install_or_update_plugin "catppuccin/tmux" "https://github.com/catppuccin/tmux.git" "main"

# Write local tmux configuration.
echo "Writing tmux configuration to $TMUX_CONF..."
as_target mkdir -p "$(dirname "$TMUX_CONF")"
tmpfile="$(mktemp)"
cat > "$tmpfile" <<'CONFIGEOF'
set -g prefix C-Space

# Enable mouse support for pane selection, resizing, and scrolling.
set -g mouse on

# Extended modifier keys
set -g extended-keys on

# Use a large scrollback buffer.
set -g history-limit 100000

# Prefer 256-color/truecolor capable terminal settings.
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",xterm-256color:RGB"

# Start window and pane numbering at 1.
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on

# Use vi-style copy mode.
setw -g mode-keys vi
bind-key -T copy-mode-vi v send -X begin-selection
bind-key -T copy-mode-vi y send -X copy-selection-and-cancel

# Easier pane/window bindings that keep the current working directory.
unbind '"'
unbind %
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"

# Vim-style pane navigation.
# Alt+hjkl to switch panes — no prefix needed
bind -n M-S-h select-pane -L
bind -n M-S-j select-pane -D
bind -n M-S-k select-pane -U
bind -n M-S-l select-pane -R

# Alt+HJKL (shifted) to resize panes
bind -n -r M-H resize-pane -L 5
bind -n -r M-J resize-pane -D 5
bind -n -r M-K resize-pane -U 5
bind -n -r M-L resize-pane -R 5

# Switch sessions with Alt+Left/Right — no prefix needed
bind -n M-h previous-window
bind -n M-l next-window

# Reload configuration quickly with prefix + r.
bind r source-file ~/.config/tmux/tmux.conf \; display-message "Reloaded ~/.config/tmux/tmux.conf"

set -g @catppuccin_flavor "mocha"
set -g @catppuccin_window_status_style "rounded"

# Plugins
run '~/.config/tmux/plugins/tmux-resurrect/resurrect.tmux'
run '~/.config/tmux/plugins/catppuccin/tmux/catppuccin.tmux'

# Status bar layout
set -g status-position top
set -g status-right-length 100
set -g status-left-length 100
set -g status-left ""
set -g pane-border-lines heavy
set -g status-right "#{E:@catppuccin_status_application}"
set -ag status-right "#{E:@catppuccin_status_session}"
CONFIGEOF
mv "$tmpfile" "$TMUX_CONF"
chmod 0644 "$TMUX_CONF"

if [ "$(id -u)" -eq 0 ] && [ "$TARGET_USER" != "root" ]; then
  chown "$TARGET_USER:$TARGET_GROUP" "$TMUX_CONF"
  if [ -d "$TARGET_HOME/.config/tmux" ]; then
    chown "$TARGET_USER:$TARGET_GROUP" "$TARGET_HOME/.config/tmux"
  fi
  chown -R "$TARGET_USER:$TARGET_GROUP" "$TMUX_PLUGIN_DIR"
fi

echo ""
echo "tmux version: $(tmux -V)"
echo ""
echo "Installation complete. Start tmux with: tmux"
