#!/usr/bin/env bash
# Ensures a debug keystore exists at DEBUG_KEYSTORE_PATH and exposes it to Godot
# through the GODOT_ANDROID_KEYSTORE_DEBUG_* environment variables.
# Uses the standard Android debug credentials; this key is not a secret and
# must never be used for release builds.
set -euo pipefail

: "${DEBUG_KEYSTORE_PATH:?}" "${GITHUB_ENV:?}"

alias_name="androiddebugkey"
password="android"

if [[ -f "${DEBUG_KEYSTORE_PATH}" ]]; then
  echo "Reusing cached debug keystore"
else
  echo "Generating new debug keystore"
  mkdir -p "$(dirname "${DEBUG_KEYSTORE_PATH}")"
  keytool -genkeypair -v \
    -keystore "${DEBUG_KEYSTORE_PATH}" \
    -storepass "${password}" -keypass "${password}" \
    -alias "${alias_name}" \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -dname "CN=LOGICA Debug,O=LOGICA,C=US"
fi

{
  echo "GODOT_ANDROID_KEYSTORE_DEBUG_PATH=${DEBUG_KEYSTORE_PATH}"
  echo "GODOT_ANDROID_KEYSTORE_DEBUG_USER=${alias_name}"
  echo "GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD=${password}"
} >> "${GITHUB_ENV}"
