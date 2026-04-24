Because both inventory entries target `localhost`, you should limit each run to the laptop you are currently on. This ensures Ansible loads the correct host-specific variables:

```bash
ansible-playbook -i inventory.yml site.yml --limit home
ansible-playbook -i inventory.yml site.yml --limit work
```

## Host variables and vault files

Host-specific variables are split into plain and vaulted files so Ansible auto-loads them for the matching host:

```text
host_vars/
  home/
    vars.yml
    vault.yml
  work/
    vars.yml
    vault.yml
```

- `host_vars/<host>/vars.yml` stores non-secret host settings such as `ansible_user`, Python path, and Firefox profile path.
- `host_vars/<host>/vault.yml` stores vaulted secrets such as `vault_git_user_name` and `vault_git_user_email`.
- `group_vars/all.yml` maps shared variables like `git_user_name` and `git_user_email` from the vaulted values.

The repository is configured to use `./vault-password.txt` for vault operations:

```bash
ansible-vault encrypt host_vars/home/vault.yml
ansible-vault encrypt host_vars/work/vault.yml
```

`vault-password.txt` must exist locally and must be a plain text password file, not an executable script:

```bash
chmod 600 ./vault-password.txt
chmod -x ./vault-password.txt
```

## Validating config changes

Use check mode for the config-related tasks on the target host:

```bash
ansible-playbook -i inventory.yml site.yml --limit home --tags configs --check
ansible-playbook -i inventory.yml site.yml --limit work --tags configs --check
```
