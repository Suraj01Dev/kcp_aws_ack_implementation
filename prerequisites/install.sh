#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# bin/ is created in whatever directory you run this script FROM
BIN_DIR="$(pwd)/bin"
mkdir -p "$BIN_DIR"

# Detect OS and arch
GOOS="$(uname | tr '[:upper:]' '[:lower:]' | grep -E 'linux|darwin')"
GOARCH="$(uname -m | sed 's/x86_64/amd64/ ; s/aarch64/arm64/' | grep -E 'amd64|arm64')"

[[ -n "${GOOS}" ]]   || { echo "❌ Unsupported OS: $(uname)" >&2;     exit 1; }
[[ -n "${GOARCH}" ]] || { echo "❌ Unsupported arch: $(uname -m)" >&2; exit 1; }

echo "📦 Platform: ${GOOS}/${GOARCH}"
echo "📁 Installing to: ${BIN_DIR}"
echo ""

# --- kcp ---
if [[ ! -f "${BIN_DIR}/.checkpoint-kcp" ]]; then
  echo "🚀 Downloading kcp"
  curl -fsSL "https://github.com/kcp-dev/kcp/releases/download/v0.26.1/kcp_0.26.1_${GOOS}_${GOARCH}.tar.gz" \
    | tar -C "${BIN_DIR}" -xzf - --strip-components=1 bin/kcp
  touch "${BIN_DIR}/.checkpoint-kcp"
else
  echo "✅ kcp already downloaded"
fi

# --- api-syncagent ---
if [[ ! -f "${BIN_DIR}/.checkpoint-api-syncagent" ]]; then
  echo "🚀 Downloading api-syncagent"
  curl -fsSL "https://github.com/kcp-dev/api-syncagent/releases/download/v0.2.0-alpha.1/api-syncagent_0.2.0-alpha.1_${GOOS}_${GOARCH}.tar.gz" \
    | tar -C "${BIN_DIR}" -xzf - api-syncagent
  touch "${BIN_DIR}/.checkpoint-api-syncagent"
else
  echo "✅ api-syncagent already downloaded"
fi

# --- kind ---
if [[ ! -f "${BIN_DIR}/.checkpoint-kind" ]]; then
  echo "🚀 Downloading kind"
  curl -fsSLo "${BIN_DIR}/kind" "https://github.com/kubernetes-sigs/kind/releases/download/v0.27.0/kind-${GOOS}-${GOARCH}"
  chmod +x "${BIN_DIR}/kind"
  touch "${BIN_DIR}/.checkpoint-kind"
else
  echo "✅ kind already downloaded"
fi

# --- kubectl ---
if [[ ! -f "${BIN_DIR}/.checkpoint-kubectl" ]]; then
  echo "🚀 Downloading kubectl"
  curl -fsSLo "${BIN_DIR}/kubectl" "https://dl.k8s.io/v1.31.7/bin/${GOOS}/${GOARCH}/kubectl"
  chmod +x "${BIN_DIR}/kubectl"
  touch "${BIN_DIR}/.checkpoint-kubectl"
else
  echo "✅ kubectl already downloaded"
fi

# --- kubectl-krew ---
if [[ ! -f "${BIN_DIR}/.checkpoint-kubectl-krew" ]]; then
  echo "🚀 Downloading kubectl-krew"
  curl -fsSL "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-${GOOS}_${GOARCH}.tar.gz" \
    | tar -xzf - --strip-components=1 -C "${BIN_DIR}" "./krew-${GOOS}_${GOARCH}"
  mv "${BIN_DIR}/krew-${GOOS}_${GOARCH}" "${BIN_DIR}/kubectl-krew" 2>/dev/null || true
  touch "${BIN_DIR}/.checkpoint-kubectl-krew"
else
  echo "✅ kubectl-krew already downloaded"
fi

# --- jq ---
if [[ ! -f "${BIN_DIR}/.checkpoint-jq" ]]; then
  echo "🚀 Downloading jq"
  jq_os="${GOOS}"
  [[ "${jq_os}" == "darwin" ]] && jq_os="macos"
  curl -fsSLo "${BIN_DIR}/jq" "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-${jq_os}-${GOARCH}"
  chmod +x "${BIN_DIR}/jq"
  touch "${BIN_DIR}/.checkpoint-jq"
else
  echo "✅ jq already downloaded"
fi

echo ""
echo "🎉 All binaries ready in ${BIN_DIR}"
echo ""
echo "Add to your PATH:"
echo "  export PATH=\"${BIN_DIR}:\$PATH\""