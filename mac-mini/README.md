# mac-mini

Mac mini (M4) の再起動時セットアップ。

## claude remote-control の自動起動

`LaunchAgents/` の plist は、以下の各ディレクトリで
`claude remote-control --spawn worktree --sandbox` をログイン時に自動起動する
(セッションはリクエストごとに個別の git worktree で立ち上がる)。

| plist | ディレクトリ |
|---|---|
| `com.mizuta.claude-rc.incubate` | `~/work/products/incubate` |
| `com.mizuta.claude-rc.talksmith` | `~/work/loov/Talksmith` |
| `com.mizuta.claude-rc.umigame` | `~/work/products/umigame` |
| `com.mizuta.claude-rc.wedraft-flows` | `~/work/wedraft/flows` |
| `com.mizuta.claude-rc.kanken` | `~/work/products/kanken` |
| `com.mizuta.claude-rc.dotfiles` | `~/work/dotfiles` |

## colima の自動起動

`LaunchAgents/com.mizuta.colima.plist` が、ログイン時に
`colima start --cpus 8 --memory 16` を実行する(各プロジェクトの
`docker compose` 用)。ログは `~/Library/Logs/colima/`。

## セットアップ

```sh
cd mac-mini
./bootstrap.sh
```

## 注意

- 過去のセッションは `~/.claude/projects/<cwd スラグ>/<uuid>.jsonl` に残るので、
  再開したいときは該当 worktree で `claude -r` から個別に選ぶ
- 再起動後に自動で走らせるには、macOS の自動ログインが有効である必要がある
  (ログイン画面のままでは LaunchAgent は起動しない)
- 対象ディレクトリを増減する場合は `LaunchAgents/` に plist を追加/削除して
  `bootstrap.sh` を再実行
