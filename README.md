# Dotfiles

Automate macOS workstation setup with Ansible. The playbook installs Homebrew packages, copies shell and editor configuration, configures global Git identity, writes Worktrunk shell integration, and installs Pi agent settings.

## Bootstrap requirements

Install and sign in to the 1Password CLI before running the playbook. `ansible.cfg` uses `./vault-password.sh`, which reads the Ansible vault password from 1Password:

```bash
op signin
op read "op://Private/dotfiles Ansible vault/password"
```

Install Ansible before the first run if the machine does not have it yet:

```bash
brew install ansible
```

## Hosts

Both inventory entries target `localhost`:

- `home` configures the home laptop.
- `work` configures the work laptop.

**Always pass `--limit`** so Ansible loads one host's variables and does not run against both entries.

```bash
ansible-playbook site.yml --limit home
ansible-playbook site.yml --limit work
```

## Repository layout

- `site.yml` installs packages and runs configuration roles.
- `inventory.yml` defines the `home` and `work` localhost targets.
- `ansible.cfg` sets `inventory`, `roles_path`, and `vault_password_file`.
- `group_vars/all.yml` defines shared Homebrew packages, casks, config file mappings, Git variables, and Pi agent packages.
- `host_vars/<host>/vars.yml` defines host-specific non-secret values such as `ansible_user`, `ansible_group`, Python interpreter, and Firefox profile path.
- `host_vars/<host>/vault.yml` stores vaulted host secrets such as Git name and email.
- `roles/config_files/` templates files from `templates/` into the home directory.
- `roles/git/` configures global Git identity and excludes.
- `roles/pi_agent/` merges Pi `settings.json` and `mcp.json` without replacing unrelated existing keys.
- `templates/` contains managed dotfiles, editor settings, agent skills, and Codex rules.

## What the playbook manages

The main playbook performs these steps:

1. Install Homebrew taps from `homebrew_taps`.
2. Update Homebrew and upgrade installed formulae.
3. Install formulae from `homebrew_packages`.
4. Install casks from `homebrew_casks`.
5. Copy templated config files listed in `config_files`.
6. Configure global Git user name, email, and excludes file.
7. Create `~/.config/mise/conf.d`.
8. Generate Worktrunk shell integration at `~/.zshrc.worktrunk`.
9. Configure Pi agent settings and MCP servers.
10. Run `mise upgrade` and `pi update --extensions` after the main tasks.

## Vault files

Host-specific variables are split so Ansible can auto-load plain values and encrypted secrets for the selected host:

```text
host_vars/
  home/
    vars.yml
    vault.yml
  work/
    vars.yml
    vault.yml
```

Edit vaulted files with Ansible Vault so `vault-password.sh` can fetch the password from 1Password:

```bash
ansible-vault edit host_vars/home/vault.yml
ansible-vault edit host_vars/work/vault.yml
```

Encrypt a new or decrypted vault file with:

```bash
ansible-vault encrypt host_vars/home/vault.yml
ansible-vault encrypt host_vars/work/vault.yml
```

## Validation

Check syntax before applying changes:

```bash
ansible-playbook site.yml --limit home --syntax-check
ansible-playbook site.yml --limit work --syntax-check
```

Preview the task list for one host:

```bash
ansible-playbook site.yml --limit home --list-tasks
```

Run check mode when you need a dry run:

```bash
ansible-playbook site.yml --limit home --check --diff
ansible-playbook site.yml --limit work --check --diff
```
