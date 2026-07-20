# scripts

## prune-agent-worktrees.sh

`claude remote-control` がセッションごとに作る `.claude/worktrees/*` を、
成果物を持たないものだけ選んで削除する。

```sh
./prune-agent-worktrees.sh          # dry-run。何が消えるか出すだけ
./prune-agent-worktrees.sh --apply  # 実行
./prune-agent-worktrees.sh --days 3 # 「古い」の閾値 (既定 7 日)
```

削除するのは以下を**すべて**満たすものだけ。

1. 最終更新が `--days` より古い
2. `git status --porcelain` が空(未コミット変更なし)
3. リモートに無いコミットを持たない(未 push の成果がない)
4. 生きた Claude プロセスにロックされていない

### なぜ必要か

Claude Code には同等の判定を行う `cleanupStaleAgentWorktrees` が組み込まれているが、
その閾値は `settings.json` の `cleanupPeriodDays`(会話ログの保持期間と共用)を
参照する。ログを長期保持するために日数を伸ばすと worktree の掃除まで遅くなり、
1 個あたり数百 MB が積み上がる。そこを短い周期で補うのがこのスクリプト。

### 注意

- worktree を消してもブランチは残す。コミット済みの成果は失われない
- 逆に**未コミットの変更は git のどこにも残らない**ため、条件 2 で必ず除外している
- `SessionEnd` フックで worktree を消す運用は、`/clear` や Ctrl-C でも発火して
  未コミットの変更ごと消えるため使わないこと(実際に失った事例あり)
