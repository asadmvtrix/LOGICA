#!/usr/bin/env bash
# Fails if a Godot log contains GDScript errors, or if an expected marker line
# is missing. Godot often exits 0 even when scripts fail to parse, so the log
# has to be checked explicitly.
set -euo pipefail

log_file="${1:?usage: check_godot_log.sh <log-file> [required-marker]}"
required_marker="${2:-}"

if grep -E -n "SCRIPT ERROR|Parse Error" "${log_file}"; then
  echo "GDScript errors found in ${log_file}" >&2
  exit 1
fi

if [[ -n "${required_marker}" ]] && ! grep -F -q "${required_marker}" "${log_file}"; then
  echo "Expected marker '${required_marker}' not found in ${log_file}" >&2
  exit 1
fi

echo "Log check passed: ${log_file}"
