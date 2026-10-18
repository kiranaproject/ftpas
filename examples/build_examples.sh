#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

mkdir -p ../target/units

REPO_UNITS="-Fu${HOME}/.pasbuild/repository/floriajs/0.0.1-SNAPSHOT/x86_64-linux-3.2.3/units -Fu${HOME}/.pasbuild/repository/florialib/0.0.1-SNAPSHOT/x86_64-linux-3.2.3/units"

echo "Building ftpas examples..."
for ex in hello_world form_controls floating_navbar creative_canvas ftml_declarative_demo; do
    echo "  Compiling ${ex}.pas..."
    fpc -Mobjfpc -Sh -FU../target/units -Fu../src/main/pascal ${REPO_UNITS} -FE. "${ex}.pas"
done
echo "All examples built successfully."
