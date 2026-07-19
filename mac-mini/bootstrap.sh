#!/bin/zsh
# mac-mini bootstrap: ログイン時常駐用 LaunchAgent のインストール
# (claude remote-control / colima)
#
# 使い方:
#   ./bootstrap.sh          # plist を ~/Library/LaunchAgents に配置して起動
#   ./bootstrap.sh --dry-run
#
# 前提:
#   - claude CLI がインストール済みで、claude.ai アカウントにログイン済み
#   - --continue には Claude Code v2.1.200 以上が必要
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
AGENT_SRC="${SCRIPT_DIR}/LaunchAgents"
AGENT_DST="${HOME}/Library/LaunchAgents"
LOG_DIR="${HOME}/Library/Logs/claude-rc"
COLIMA_LOG_DIR="${HOME}/Library/Logs/colima"
GUI_DOMAIN="gui/$(id -u)"
DRY_RUN=${1:-}

mkdir -p "${AGENT_DST}" "${LOG_DIR}" "${COLIMA_LOG_DIR}"

for plist in "${AGENT_SRC}"/com.mizuta.*.plist; do
  label="$(basename "${plist}" .plist)"
  dst="${AGENT_DST}/$(basename "${plist}")"

  if [[ "${DRY_RUN}" == "--dry-run" ]]; then
    echo "[dry-run] install ${label}"
    continue
  fi

  # 既に登録済みなら一旦解除してから入れ替える(冪等)
  launchctl bootout "${GUI_DOMAIN}/${label}" 2>/dev/null || true
  cp "${plist}" "${dst}"
  launchctl bootstrap "${GUI_DOMAIN}" "${dst}"
  echo "installed: ${label}"
done

echo
echo "状態確認: launchctl list | grep claude-rc"
echo "ログ:     ${LOG_DIR}/"
