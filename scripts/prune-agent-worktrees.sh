#!/bin/zsh
# claude remote-control が作る .claude/worktrees/* のうち、
# 成果物を持たないものだけを安全に削除する。
#
# 使い方:
#   ./prune-agent-worktrees.sh                 # dry-run (既定)。何が消えるか表示するだけ
#   ./prune-agent-worktrees.sh --apply         # 実際に削除する
#   ./prune-agent-worktrees.sh --days 3        # 「古い」の閾値を変える (既定 7 日)
#   ./prune-agent-worktrees.sh --apply /path/to/repo ...  # 対象リポジトリを明示
#
# 削除条件 (すべて満たすもののみ削除する):
#   1. 最終更新が --days より古い
#   2. git status --porcelain が空 (未コミット変更なし)
#   3. リモートに無いコミットを持たない (未 push の成果がない)
#   4. 生きた Claude プロセスにロックされていない
#
# Claude Code 組み込みの cleanupStaleAgentWorktrees と同じ判定を、
# 短い周期で回すためのもの。settings.json の cleanupPeriodDays を
# 長くすると組み込み側の掃除まで遅くなるため、こちらで補う。
set -euo pipefail

DAYS=7
APPLY=0
REPOS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply) APPLY=1; shift ;;
    --days)  DAYS="$2"; shift 2 ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    *) REPOS+=("$1"); shift ;;
  esac
done

# 対象リポジトリ未指定なら LaunchAgents と同じ一覧を使う
if [[ ${#REPOS[@]} -eq 0 ]]; then
  REPOS=(
    "${HOME}/work/dotfiles"
    "${HOME}/work/products/incubate"
    "${HOME}/work/products/kanken"
    "${HOME}/work/products/umigame"
    "${HOME}/work/wedraft/flows"
    "${HOME}/work/loov/Talksmith"
  )
fi

CUTOFF=$(( $(date +%s) - DAYS * 86400 ))
removed=0
kept=0

# ロックが「生きた Claude プロセス」のものかを判定する。
# ロック理由は `claude agent <name> (pid 1234 start ...)` の形式。
# 理由を読めない/形式が違う場合は、安全側に倒して「生きている」とみなす。
is_locked_by_live_process() {
  local main_repo="$1" wt_name="$2"
  local lockfile="${main_repo}/.git/worktrees/${wt_name}/locked"
  [[ -f "${lockfile}" ]] || return 1

  local reason pid
  reason="$(cat "${lockfile}" 2>/dev/null || echo '')"
  pid="${${reason#*\(pid }%% *}"

  if [[ "${pid}" != <-> ]]; then
    return 0  # 想定外の理由が書かれている → 触らない
  fi
  kill -0 "${pid}" 2>/dev/null
}

for repo in "${REPOS[@]}"; do
  [[ -d "${repo}/.git" ]] || continue
  wt_root="${repo}/.claude/worktrees"
  [[ -d "${wt_root}" ]] || continue

  for wt in "${wt_root}"/*(N/); do
    name="${wt:t}"
    reason=''

    if [[ ! -e "${wt}/.git" ]]; then
      reason='git worktree として成立していない (残骸)'
    elif [[ $(stat -f %m "${wt}") -ge ${CUTOFF} ]]; then
      reason=''; kept=$(( kept + 1 )); continue
    elif is_locked_by_live_process "${repo}" "${name}"; then
      kept=$(( kept + 1 )); continue
    elif [[ -n "$(git -C "${wt}" --no-optional-locks status --porcelain 2>/dev/null)" ]]; then
      kept=$(( kept + 1 )); continue
    elif [[ -n "$(git -C "${wt}" rev-list --max-count=1 HEAD --not --remotes 2>/dev/null)" ]]; then
      kept=$(( kept + 1 )); continue
    else
      reason='クリーン かつ push 済み'
    fi

    if [[ ${APPLY} -eq 1 ]]; then
      git -C "${repo}" worktree unlock "${wt}" 2>/dev/null || true
      # 事前チェック済みなので --force で問題ない (ビルド生成物が残るため必要)
      git -C "${repo}" worktree remove --force "${wt}" 2>/dev/null || rm -rf "${wt}"
      echo "removed: ${repo:t}/${name} — ${reason}"
    else
      echo "[dry-run] remove: ${repo:t}/${name} — ${reason}"
    fi
    removed=$(( removed + 1 ))
  done

  [[ ${APPLY} -eq 1 ]] && git -C "${repo}" worktree prune 2>/dev/null || true
done

echo
if [[ ${APPLY} -eq 1 ]]; then
  echo "削除 ${removed} 件 / 保持 ${kept} 件"
else
  echo "削除対象 ${removed} 件 / 保持 ${kept} 件 (--apply で実行)"
fi
