# AGENTS.md

## ブランチ運用

このリポジトリは **PR を作成せず、main に直接 push する** 運用です。

- 作業ブランチや git worktree は作らず、main 上でコミットして `git push` する
- `gh pr create` などで PR を作らない
- remote-control のセッションも worktree を使わない設定
  (`mac-mini/LaunchAgents/com.mizuta.claude-rc.dotfiles.plist`)
