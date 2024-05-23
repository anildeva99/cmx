# cmx-runtime-environment

Ansible playbooks, Terraform code, and scripts for managing services at CMX.

## Example Command:

```
ansible-playbook -vvv -e "{env: sandbox}" all.yml
```

## Tools Installation

### Mac

```
scripts/setup.sh
```

## Tools Required

The below are installed via `scripts/setup.sh`:

- ansible
- aws-cliv2
- brew (Mac only)
- aws-iam-authenticator
- docker
- helm
- kubectl
- packer
- terraform

### Python Packages:

All packages within: `scripts/files/requirements.txt`
