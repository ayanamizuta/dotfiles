# AGENTS.md

## ブランチ運用

このリポジトリは **PR を作成せず、main に直接 push する** 運用です。

- 作業ブランチや git worktree は作らず、main 上でコミットして `git push` する
- `gh pr create` などで PR を作らない
- remote-control のセッションも worktree を使わない設定
  (`mac-mini/LaunchAgents/com.mizuta.claude-rc.dotfiles.plist`)

## LaunchAgents (plist) の変更手順

`mac-mini/LaunchAgents/` の plist はリポジトリ内で編集しただけでは反映されない。
launchd が読むのは `~/Library/LaunchAgents/` のコピーなので、変更時は必ず反映作業を行う。

- **即時反映する場合**: `cd mac-mini && ./bootstrap.sh` を実行する
  (bootout → cp → bootstrap で全 plist を冪等に入れ替える)。
  ただし実行中の claude remote-control セッションが落ちるので、
  アクティブなセッションの有無を確認してから行うこと
- **次回ログイン時の反映でよい場合**: `cp mac-mini/LaunchAgents/<変更した plist> ~/Library/LaunchAgents/`
  だけ行う。ロード済みのエージェントには影響せず、再起動 (ログイン) 後に新設定で起動する
