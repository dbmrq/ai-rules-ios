#!/usr/bin/env bash
# Fragment for ci_pre_xcodebuild.sh
set -euo pipefail

if ! command -v swiftlint >/dev/null 2>&1; then brew install swiftlint; fi
if ! command -v swiftformat >/dev/null 2>&1; then brew install swiftformat; fi

cd "$CI_PRIMARY_REPOSITORY_PATH"
./scripts/check.sh
