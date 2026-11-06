#!/usr/bin/env bash
set -euo pipefail

echo "=== pipx -> uv tool migration ==="
echo ""

# Get list of pipx packages as JSON
packages=$(pipx list --output json | jq -r '.venvs | keys[]')

if [[ -z "$packages" ]]; then
  echo "No pipx packages found. Nothing to migrate."
  exit 0
fi

failed=()

while IFS= read -r pkg; do
  echo "--- Migrating: $pkg ---"

  # Attempt to install with uv tool
  if uv tool install --force "$pkg" >/dev/null 2>&1; then
    # uv tool install succeeded; now uninstall from pipx
    if pipx uninstall "$pkg" >/dev/null 2>&1; then
      echo "  ✓ Success: $pkg migrated"
    else
      echo "  ⚠ Warning: $pkg installed via uv tool but pipx uninstall failed"
      failed+=("$pkg")
    fi
  else
    echo "  ✗ Failed: $pkg could not be installed via uv tool"
    failed+=("$pkg")
  fi
done <<< "$packages"

echo ""
echo "=== Migration complete ==="

if [[ ${#failed[@]} -gt 0 ]]; then
  echo ""
  echo "Packages that may still need attention:"
  pipx list --short
fi
