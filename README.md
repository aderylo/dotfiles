# Automated Development Environment Setup

A fully automated development environment configuration system built with Ansible. This project sets up a complete, personalized development workspace across multiple operating systems with a single command.

## What It Does

This automation toolkit:

- **Installs and configures essential development tools** like Neovim, Zsh with Powerlevel10k, Node Version Manager (nvm), Conda, fzf, and zoxide
- **Sets up a beautiful terminal environment** with custom themes, aliases, and productivity shortcuts
- **Works across operating systems** - currently supports macOS and Ubuntu
- **Handles system differences automatically** - each tool is configured appropriately for your OS
- **Manages privilege requirements intelligently** - gracefully handles environments with or without sudo access
- **Keeps everything up-to-date** - can be run repeatedly to update configurations and tools

Think of it as "Infrastructure as Code" for your personal development environment. Instead of manually installing and configuring dozens of tools every time you set up a new machine, run one command and get a fully configured workspace.

## Quick Start

### Prerequisites

Make sure your system is up to date:

```bash
# macOS
brew update && brew upgrade

# Ubuntu
sudo apt-get update && sudo apt-get upgrade -y
```

### Install Everything

Run this single command to set up your entire development environment:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/aderylo/dotfiles/main/bin/dotfiles)"
```

That's it! The script will:
1. Detect your operating system
2. Install required dependencies (Git, Ansible)
3. Clone this repository to `~/.dotfiles`
4. Run the full setup automatically

**Important:** On first run, you'll need to reboot your computer to complete the setup. Alternatively, you can restart the shell by running `exec zsh` and you should be good to go! 

### Install Specific Tools Only

If you only want certain tools, you can run specific roles:

```bash
curl -fsSL https://raw.githubusercontent.com/aderylo/dotfiles/main/bin/dotfiles | bash -s -- --tags neovim,zsh,fzf
```

Available tags: `conda`, `nvm`, `neovim`, `zsh`, `zoxide`, `fzf`

## Daily Usage (Post Installation) 

After installation, use the `dotfiles` command to update your environment:

```bash
# Update everything
dotfiles

# Update specific tools with verbose output
dotfiles -t neovim,zsh -vvv

# Test changes without applying them
dotfiles --check
```

The `dotfiles` command supports tab completion for tags and passes all arguments directly to Ansible.

## Customization

### Disable Unwanted Tools

Edit `~/.dotfiles/group_vars/all.yml` to customize which tools get installed. For example, 
if you don't need conda, just comment it out:

```yaml
default_roles:
# - conda          # Comment out to skip conda
  - nvm
  - neovim
  - zsh
  - zoxide
  - fzf
```

### Modify Tool Configurations

Each tool lives in its own role under [`roles/`](roles/). For example:
- [`roles/zsh/`](roles/zsh/) - Zsh configuration and themes
- [`roles/neovim/`](roles/neovim/) - Neovim setup and plugins
- [`roles/nvm/`](roles/nvm/) - Node.js version management

## How It Works

### Multi-OS Support

Each role automatically detects your operating system and runs the appropriate tasks. The system works by:

1. Checking if a role supports your OS (looks for `roles/<role>/tasks/<YourOS>.yml`)
2. Running OS-specific installation and configuration tasks
3. Skipping roles that don't support your current OS

### Privilege Management

The system intelligently handles sudo requirements:
- Automatically detects if you have sudo access
- Gracefully skips system-level tasks when sudo isn't available
- Provides user-space alternatives when possible
- See [`roles/README_SUDO.md`](roles/README_SUDO.md) for technical details

## Extending the System

### Adding a New Tool

1. Create a new role: `mkdir -p roles/newtool/tasks`
2. Add OS-specific task files: `roles/newtool/tasks/MacOSX.yml`, `roles/newtool/tasks/Ubuntu.yml`
3. Create the main role file using the template:

```yaml
# roles/newtool/tasks/main.yml
---
- name: "newtool | Checking for Distribution Config: {{ ansible_distribution }}"
  ansible.builtin.stat:
    path: "{{ role_path }}/tasks/{{ ansible_distribution }}.yml"
  register: distribution_config

- name: "newtool | Run Tasks: {{ ansible_distribution }}"
  ansible.builtin.include_tasks: "{{ ansible_distribution }}.yml"
  when: distribution_config.stat.exists
```

4. Add your role to `default_roles` in [`group_vars/all.yml`](group_vars/all.yml)

For a comprehensive tour of how the repository works internally and is structured, watch the TechDufus YouTube video.
This repository follows the same structure, although it is simplified as it strips down the complexity of
secret management and other advanced features, which are useful but require more knowledge to avoid potential issues.

Furthermore, since this repository follows the same structure as the [TechDufus one](https://github.com/TechDufus/dotfiles), you can simply grab one of his role configurations, put it in the `roles` folder, add it as a default role in `group_vars/all.yml`, and you're golden!  

### Supporting a New OS

1. Add OS detection logic to [`bin/dotfiles`](bin/dotfiles)
2. Create OS-specific task files for existing roles
3. Test thoroughly with the new OS

### Working Without Sudo

When creating roles, always consider non-sudo environments:
- Use `when: has_sudo | default(false)` for tasks requiring privileges
- Provide alternatives like installing to `~/.local/bin` instead of `/usr/local/bin`
- See [`roles/README_SUDO.md`](roles/README_SUDO.md) for patterns and examples

## Technical Details

- **Built with:** Ansible playbooks for cross-platform automation
- **Inspired by:** [TechDufus dotfiles](https://github.com/TechDufus/dotfiles) ([YouTube tour](https://youtu.be/hPPIScBt4Gw))
- **License:** Apache 2.0
- **Requirements:** Git (installed automatically), Ansible (installed automatically)
- **Supported OS:** macOS, Ubuntu (others can be added by extending roles)

The project structure prioritizes modularity - each tool is independent and can be run, updated, or modified separately.
