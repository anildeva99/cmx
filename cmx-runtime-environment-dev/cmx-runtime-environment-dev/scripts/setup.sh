#!/usr/bin/env bash
#####--------------------------------------------------------------------------
#### Description: Install/Update DevOps related utils
### vim: tabstop=4 expandtab softtabstop=4 shiftwidth=4
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Helper Functions
#-------------------------------------------------------------------------------

# getRealPath $1
# Description: Portable function to get real path to a script
# Return: PATH
getRealPath() {

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

# Error $1
# Description: Echo ERROR message, newline by default
# Return: Nothing
Error() {

    local _MSG="${1}"
    local _NEWLINE="${2:-"newline"}"

    if [ "${_NEWLINE}" = "newline" ]; then
        echo -e "$(tput bold)$(tput setaf 1)ERROR : ${_MSG}$(tput sgr0)\n"
    else
        echo -e "$(tput bold)$(tput setaf 1)ERROR : ${_MSG}$(tput sgr0)"
    fi

}

#-------------------------------------------------------------------------------
# Global variables
#-------------------------------------------------------------------------------
export KUBECTL_URL="${KUBECTL_URL:-"https://amazon-eks.s3-us-west-2.amazonaws.com"}"
export HELM_URL="${HELM_URL:-"https://get.helm.sh"}"
export KREW_URL="${KREW_URL:-"https://github.com/kubernetes-sigs/krew/releases/download"}"
export TERRAFORM_URL=${TERRAFORM_URL:-"https://releases.hashicorp.com/terraform"}
export PACKER_URL=${PACKER_URL:-"https://releases.hashicorp.com/packer"}
SCRIPT_DIR="$(getRealPath "${0}")"
export SCRIPT_DIR

# Source bash-functions
if [ -f "${SCRIPT_DIR}/files/bash-functions" ]; then
    # shellcheck source=/dev/null
    . "${SCRIPT_DIR}/files/bash-functions"
else
    Error "${SCRIPT_DIR}/files/bash-functions does not exist"
    exit 1
fi

#-------------------------------------------------------------------------------
# Getops Section
#-------------------------------------------------------------------------------
Usage() {
    tput sgr0 # Return normal output
    tput bold # Text Bold
    echo >&2 ""
    echo >&2 "
        DESCRIPTION:
            Install tools required for managing environments at Codametrix.

            Tools managed:
                • Xcode CMD Tools (Mac Only)
                • brew (Mac Only)
                • pyenv
                • ansible
                    (includes all modules in ${SCRIPT_DIR}/filesrequirements.txt)
                • ansible collections
                    (within ${SCRIPT_DIR}/files/requirements.yml)
                • kubectl
                • aws-iam-connector
                • helm
                • krew
                • terraform
                • packer

            Special Notes:
                • Ansible is installed to a pyenv controlled venv called ops

        USAGE:
            ${0##*/} <options>

        OPTIONS:

            -B <bin-dir>           :Directory to place binaries
                                    Default: (${BIN_DIR})
            -h                     :Print usage
            -H <helm-version>      :Version of Helm to install
                                    Default: (${HELM_URL})
            -f <krew-plugin-file>  :Krew kubectl plugin file path,
                                    File containing newline seperated
                                    plugins to install
                                    Default: (${KREW_PLUGIN_FILE_PATH})
            -k <kubectl-version>   :AWS kubectl version
                                    Default: (${KUBECTL_VERSION})
            -K <krew-version>      :Krew kubectl plugin manager version
                                    Default: (${KREW_VERSION})
            -p <python-version>    :Python3 version to use for ops venv
                                    Default: (${PYENV_VERSION})
            -P <packer-version>    :Packer version to install
                                    Default: (${PACKER_VERSION})
            -t <terraform-version> :Terraform version to install
                                    Default: (${TERRAFORM_VERSION})

        EXAMPLE:
            1) ./${0##*/}
        "
    echo >&2 ""
    tput sgr0 # Return normal output
    exit 1
}

# Initial getopts variable values
BIN_DIR="${BIN_DIR:-"${HOME}/bin"}"
HELM_VERSION="${HELM_VERSION:-"3.4.1"}"
KUBECTL_VERSION="${KUBECTL_VERSION:-"1.16.15/2020-11-02"}"
KREW_VERSION="${KREW_VERSION:-"0.4.1"}"
KREW_PLUGIN_FILE_PATH="${KREW_PLUGINS_FILE_PATH:-"${SCRIPT_DIR}/files/krew_plugin_file.txt"}"
PYTHON_VERSION="${PYTHON_VERSION:-"3.8.6"}"
PACKER_VERSION="${PACKER_VERSION:-"1.6.5"}"
TERRAFORM_VERSION="${TERRAFORM_VERSION:-"0.12.29"}"
REQUIRE_DOCKER=0

# Do not put a colon after Boolean values.
# Colons only go after arguments that take a string.
while getopts b:hH:f:k:K:p:P:t: OPT; do
    case "${OPT}" in
        b) BIN_DIR="${OPTARG}" ;;
        h) Usage ;;
        H) HELM_VERSION="${OPTARG}" ;;
        f) KREW_PLUGIN_FILE_PATH="${OPTARG}" ;;
        k) KUBECTL_VERSION="${OPTARG}" ;;
        K) KREW_VERSION="${OPTARG}" ;;
        p) PYTHON_VERSION="${OPTARG}" ;;
        P) PACKER_VERSION="${OPTARG}" ;;
        t) TERRAFORM_VERSION="${OPTARG}" ;;
        :)
            Error "Option -${OPTARG} requires an argument.\n"
            Usage
            ;;
        [?]) Usage ;;
    esac
done

shift $((OPTIND - 1))
#-------------
## End Getops
#-------------

#-------------------------------------------------------------------------------
# Main Program
#-------------------------------------------------------------------------------

# Create BIN_DIR if not exists
if [ ! -d "${BIN_DIR}" ]; then
    Info "Creating ${BIN_DIR}..."
    mkdir -p "${BIN_DIR}"/{files,src}
fi

# Based on OSTYPE run required functions
# within bash-functions
if [[ "${OSTYPE}" =~ darwin* ]]; then

    Info "\nDetected OSTYPE of darwin, running Mac setup tasks..."

    export BASHRC="${HOME}/.bash_profile" \
        UNAME="darwin" \
        ZSHRC="${HOME}/.zshrc" \
        REQUIRE_DOCKER=1

    InstallXcodeCMDTools
    InstallBrew
    InstallPyenv
    InstallPythonCreateVenv "${PYTHON_VERSION}" \
        "ops" "${SCRIPT_DIR}/files/requirements.txt"
    InstallAnsibleCollections "${PYTHON_VERSION}" \
        "ops" "${SCRIPT_DIR}/files/requirements.yml"
    InstallPythonCreateVenv "${PYTHON_VERSION}" \
        "ops-legacy" "${SCRIPT_DIR}/files/requirements-legacy.txt"
    InstallAWSCLIv2 "${BIN_DIR}"
    InstallKubectl "${KUBECTL_VERSION}" \
        "${BIN_DIR}" \
        "${UNAME}" "${KUBECTL_URL}"
    InstallAWSIAMAuthenticator "${KUBECTL_VERSION}" \
        "${BIN_DIR}" \
        "${UNAME}" "${KUBECTL_URL}"
    InstallHelm "${HELM_VERSION}" \
        "${BIN_DIR}" \
        "${UNAME}" "${HELM_URL}"
    InstallKrew "${KREW_VERSION}" \
        "${BIN_DIR}" \
        "${UNAME}" "${KREW_URL}" \
        "${KREW_PLUGIN_FILE_PATH}"
    InstallTerraform "${TERRAFORM_VERSION}" \
        "${BIN_DIR}" \
        "${UNAME}" "${TERRAFORM_URL}"
    InstallPacker "${PACKER_VERSION}" \
        "${BIN_DIR}" \
        "${UNAME}" "${PACKER_URL}"
    InstallYoPass "${BIN_DIR}"
    SetupZshCompletions

elif [[ "${OSTYPE}" =~ linux* ]]; then

    Info "\nDetected OSTYPE of linux, running Linux setup tasks..."

    export BASHRC="${HOME}/.bashrc" \
        ZSHRC="${HOME}/.zshrc" \
        UNAME="linux"
else
    Error "Platform not supported"
    exit 1
fi

# Place any functions that should run
# on all supported platforms below
SetupCMXRCAutoSource "${BIN_DIR}/files" \
    "${BASHRC}" \
    "${ZSHRC}"

Success "
#------------------------------------------#
# SETUP COMPLETE: SEE BELOW FOR NEXT STEPS #
#------------------------------------------#"

if [ "${REQUIRE_DOCKER}" = "1" ]; then
    if (! TestCmdInPath "docker"); then
        Info "Docker is not currently installed, please download/install it: "
        Info "https://desktop.docker.com/mac/stable/Docker.dmg"
    fi
fi

Info "\nPlease run: exec \"${SHELL}\" -l

To load the ops virtualenv and installed utlities"
