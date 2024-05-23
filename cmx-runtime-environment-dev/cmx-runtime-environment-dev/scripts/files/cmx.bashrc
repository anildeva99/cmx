# shellcheck shell=bash
# ------------------------------------------------------------------------------
# Description: This file contains useful aliases for managing CMX environments.
#   NOTE: Functions should be placed with bash-functions (see below)
# vim: tabstop=4 expandtab softtabstop=4 shiftwidth=4
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Load First (Things that need to ber loaded for other aliases to work)
# ------------------------------------------------------------------------------

# Load ${SCRIPT_DIR}/bash-functions
# the location were all functions should be placed

# GetRealPathe $1
# Description: Portable function to get real path to a script
# Return: PATH
GetRealPath() {

    if [[ -n "${NO_SYMLINKS}" ]]; then
        local _PWDP='pwd -P'
    else
        local _PWDP='pwd'
    fi
    echo "$(
        cd "${1%/*}" 2>/dev/null || return 1
        ${_PWDP}
    )"
}

# Set FUNCTION_DIR equal to dir this bashrc exists within
FUNCTION_DIR="$(GetRealPath "${BASH_SOURCE[0]:-"${(%):-%N}"}")"
export FUNCTION_DIR

# Set INSTALL_DIR equal to the parent dir of FUNCTION_DIR
INSTALL_DIR="$(dirname "${FUNCTION_DIR}")"
export INSTALL_DIR

# PATH modifications for tools installed via setup.sh
export PATH="${INSTALL_DIR}:${PATH}"

if [ -f "${FUNCTION_DIR}/bash-functions" ]; then
    # shellcheck source=/dev/null
    . "${FUNCTION_DIR}/bash-functions"
fi

# Mac specifc dependencies
if [[ "${OSTYPE}" =~ darwin* ]]; then

    # Load brew openssl (used by pyenv and some scripts)
    export PATH="/usr/local/opt/openssl/bin:${PATH}" \
        LDFLAGS="-L/usr/local/opt/openssl/lib" \
        CPPFLAGS="-I/usr/local/opt/openssl/include"

    # Set BREW_ROOT
    if (TestCmdInPath "brew"); then
        export BREW_ROOT
        BREW_ROOT="$(brew --prefix)"
    fi

    # Load bash-completion (installed via brew)
    # if SHELL = bash
    if [ -n "${BASH_VERSION}" ]; then
        if [ -r "${BREW_ROOT}/etc/profile.d/bash_completion.sh" ]; then
            # shellcheck source=/dev/null
            . /usr/local/etc/profile.d/bash_completion.sh
        fi
    # Setup zsh-completions (installed via brew)
    # if SHELL == zsh
    elif [ -n "${ZSH_VERSION}" ]; then
        if [ -d "${BREW_ROOT}/share/zsh-completions" ]; then
            export FPATH="${BREW_ROOT}/share/zsh-completions:${FPATH}"
            autoload -Uz compinit
            compinit
        fi
    fi

    # Load postgresql11 if installed
    if [ -d "/usr/local/opt/postgresql@11/bin" ]; then
        export PATH="/usr/local/opt/postgresql@11/bin:${PATH}"
    fi

    # WORKAROUND: python forking issues with certain ansible modules
    # https://github.com/ansible/ansible/issues/49207
    export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

    # Set GOPATH if not set and
    # set PATH for go@1.15 installed via brew
    if [ -z "${GOPATH}" ]; then
        export GOPATH="${HOME}/go"
    fi
    export PATH="/usr/local/opt/go@1.15/bin:${GOPATH}/bin:${PATH}"

fi

# Load pyenv and plugins
if [ -d "${HOME}/.pyenv/bin" ]; then
    export PYENV_ROOT="${PYENV_ROOT:-"${HOME}/.pyenv"}"
    export PATH="${PYENV_ROOT}/bin:${PATH}" \
        PYENV_VIRTUALENV_DISABLE_PROMPT=1
    if (TestCmdInPath "pyenv"); then
        eval "$(pyenv init -)"
        if [ -d "${HOME}/.pyenv/plugins/pyenv-virtualenv" ]; then
            eval "$(pyenv virtualenv-init -)"
            pyenv activate ops &> /dev/null
        fi
    fi
fi

# Add krew to PATH if installed
if [ -d "${HOME}/.krew/bin" ]; then
    export PATH="${HOME}/.krew/bin:${PATH}"
fi

# Load completion libs within ${FUNCTION_DIR}/files
if [ -n "${BASH_VERSION}" ]; then
    for CLIB in "${FUNCTION_DIR}"/*-completion.bash; do
        # shellcheck source=/dev/null
        . "${CLIB}"
    done
elif [ -n "${ZSH_VERSION}" ]; then
    for CLIB in "${FUNCTION_DIR}"/*-completion.zsh; do
        # shellcheck source=/dev/null
        . "${CLIB}"
    done
fi

# Load AWSCliv2 completion libs
if (TestCmdInPath "aws_completer"); then
    if [ -n "${BASH_VERSION}" ]; then
        complete -C 'aws_completer' aws
    elif [ -n "${ZSH_VERSION}" ]; then
        autoload -U +X bashcompinit && bashcompinit
        complete -C 'aws_completer' aws
    fi
fi

# ------------------------------------------------------------------------------
# CMX Global Variables
# ------------------------------------------------------------------------------

# Supported AWS regions (used for listing eks clusters)
export SUPPORTED_AWS_REGIONS=("us-east-1" "us-west-2")

# Tools account ID (used for ECRLogin)
export TOOLS_ACCOUNT_ID="643073444324"

# ------------------------------------------------------------------------------
# AWS Aliases
# ------------------------------------------------------------------------------

# Alias to create a docker login to ECR within the tools account
# Optional: $2 == [true (use tools account)| false (use current account)]
#           $1 == REGION
ecrlogin() { ECRLogin  "${1:-"true"}" "${2:-"us-east-1"}"; }

# Alias switch AWS profiles
pswitch() { ChooseProfile "${@}"; }

# Alias to print AWS credentials to STDOUT
pcreds() { PrintAWSCredentials; }

# ------------------------------------------------------------------------------
# General Aliases
# ------------------------------------------------------------------------------

# Alias to create SSH tunnel through a target bastion
btunnel() { BastionTunnel "${@}"; }

# Alias to load ops-legacy python venv
loadopslegacy() { pyenv activate ops-legacy; }

# Alias to load ops python venv
loadops() { pyenv activate ops; }

# ------------------------------------------------------------------------------
# Kubernetes Aliases
# ------------------------------------------------------------------------------s

# Alias to switch Kubernetes cluster context
# Optional: $1 == ENV
kcswitch() { KubeChooseCluster "${1}"; }

# Alias to print current Kubernetes context
kcontext() { KubeCurrentContext; Info "${KUBE_CURRENT_CONTEXT}"; }
