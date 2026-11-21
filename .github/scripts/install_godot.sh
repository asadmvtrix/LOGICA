#!/usr/bin/env bash
# Downloads the pinned Godot editor and Android export templates, verifies
# their SHA-512 checksums, and installs them where Godot looks for them.
# Required env: GODOT_VERSION, GODOT_STATUS, GODOT_LINUX_SHA512, GODOT_TEMPLATES_SHA512
set -euo pipefail

: "${GODOT_VERSION:?}" "${GODOT_STATUS:?}" "${GODOT_LINUX_SHA512:?}" "${GODOT_TEMPLATES_SHA512:?}"

tag="${GODOT_VERSION}-${GODOT_STATUS}"
base_url="https://github.com/godotengine/godot/releases/download/${tag}"
editor_zip="Godot_v${tag}_linux.x86_64.zip"
templates_tpz="Godot_v${tag}_export_templates.tpz"

bin_dir="${HOME}/godot-bin"
templates_dir="${HOME}/.local/share/godot/export_templates/${GODOT_VERSION}.${GODOT_STATUS}"
work_dir="$(mktemp -d)"
trap 'rm -rf "${work_dir}"' EXIT

download() {
  curl --fail --location --silent --show-error --retry 5 --retry-delay 5 \
    --output "${work_dir}/$1" "${base_url}/$1"
}

echo "Downloading ${editor_zip}"
download "${editor_zip}"
echo "${GODOT_LINUX_SHA512}  ${work_dir}/${editor_zip}" | sha512sum --check --strict

echo "Downloading ${templates_tpz} (large; only Android templates are kept)"
download "${templates_tpz}"
echo "${GODOT_TEMPLATES_SHA512}  ${work_dir}/${templates_tpz}" | sha512sum --check --strict

mkdir -p "${bin_dir}" "${templates_dir}"

unzip -q -o "${work_dir}/${editor_zip}" -d "${work_dir}/editor"
install -m 0755 "${work_dir}/editor/Godot_v${tag}_linux.x86_64" "${bin_dir}/godot"

unzip -q -o -j "${work_dir}/${templates_tpz}" \
  "templates/android_debug.apk" \
  "templates/android_release.apk" \
  "templates/version.txt" \
  -d "${templates_dir}"

expected_version="${GODOT_VERSION}.${GODOT_STATUS}"
actual_version="$(tr -d '[:space:]' < "${templates_dir}/version.txt")"
if [[ "${actual_version}" != "${expected_version}" ]]; then
  echo "Template version mismatch: expected ${expected_version}, got ${actual_version}" >&2
  exit 1
fi

"${bin_dir}/godot" --headless --version
ls -l "${templates_dir}"
