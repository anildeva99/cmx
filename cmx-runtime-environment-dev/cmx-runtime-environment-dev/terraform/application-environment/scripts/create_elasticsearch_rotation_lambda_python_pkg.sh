#!/bin/bash

echo "Creating elasticsearch_lambda_function package..."

# Test for pyenv
if [ ! -d "${HOME}/.pyenv/bin" ]; then
  echo "ERROR : pyenv is not installed you should run setup.sh"
  exit 1
fi

# Install python 2.7.18 if pyenv installed
export PATH="${HOME}/.pyenv/bin:${PATH}"
if [ ! -d "${HOME}/.pyenv/versions/2.7.18" ]; then
  echo "Installing python: 2.7.18..."
  pyenv install 2.7.18
fi

# shellcheck disable=SC2154
rm -rf "${path_cwd}/files/elasticsearch_lambda_function_build"
# shellcheck disable=SC2154
mkdir -p "${path_cwd}/files/elasticsearch_lambda_function_build"
# shellcheck disable=SC2154
pushd "${path_cwd}/files/elasticsearch_lambda_function_build" || exit 1

# Installing python dependencies...
FILE="${path_cwd}/files/elasticsearch_lambda_function/requirements.txt"

if [ -f "${FILE}" ]; then
  echo "Installing requirements..."
  "${HOME}"/.pyenv/versions/2.7.18/bin/pip install -r "${FILE}" --target .
  cp -a "${path_cwd}/files/elasticsearch_lambda_function/" \
    "${path_cwd}/files/elasticsearch_lambda_function_build"
else
  echo "ERROR : ${FILE} does not exist!"
  exit 1
fi
popd || exit 1
