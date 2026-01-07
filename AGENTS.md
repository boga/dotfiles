# Gemini Code Assistant Project Overview

This project uses Ansible to automate the setup and configuration of a development environment on macOS. It installs various tools and applications, and deploys configuration files for them.

## Project Structure

- `site.yml`: The main Ansible playbook. It defines the tasks to be executed.
- `roles/`: Contains Ansible roles, which are modular units of automation.
  - `cp`: A role for copying files.
  - `fish`: A role for setting up the Fish shell and related tools.
- `templates/`: Contains template files for configurations (e.g., `wezterm.lua.j2`, `vimrc`).
- `README.md`: The project's README file.

## How to Use

To run the full playbook, you need to have Ansible installed. You will also need an inventory file. The `README.md` provides an example of the inventory file structure.

1.  **Create an inventory file** (e.g., `inventory.yml`):

    ```yaml
    all:
      hosts:
        some_host:
          ansible_host: localhost
          ansible_connection: local
          ansible_user: your-username
          ansible_group: your-group
    ```

2.  **Run the playbook**:

    ```bash
    ansible-playbook -i inventory.yml site.yml
    ```

### Running Specific Tasks

The playbook uses tags to allow running specific parts of the setup. You can use the `--tags` flag to specify which tasks to run.

- `configs`: Copies configuration files.
- `fish`: Installs the Fish shell.
- `fisher`: Installs the Fisher plugin manager for Fish.
- `starship`: Installs the Starship prompt.

For example, to only copy the configuration files, you can run:

```bash
ansible-playbook -i inventory.yml site.yml --tags configs
```
