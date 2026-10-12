# ヘルシーアドベンチャー（ブラウザ版）

Ruby合宿2024春 Team5 が DXRuby で作ったゲームを、[PicoRuby.wasm](https://github.com/picoruby/picoruby/tree/master/mrbgems/picoruby-wasm) と
[PicoDX](https://github.com/itojum/picodx)（DXRuby ライクな 2D ゲームライブラリ）でブラウザだけで動くようにしたものです。
原作は [rc2024sp_team5](https://github.com/itojum/rc2024sp_team5) にあります。

原作から変えた点とその理由は [PORTING.md](PORTING.md) にまとめています。

## 遊び方

- Enter キーでスタート
- キャラクターをクリックして選ぶ
- 矢印キー（または WASD）の左右で移動、上でジャンプ、スペースで弾を撃つ

## 動かし方

```bash
bundle install                    # 最初に 1 回（webrick を入れる）
bundle exec ruby script/server    # http://localhost:3001 を開く
```

- `index.html` は静的なページですが、ファイルを直接開く（`file://`）と PicoRuby.wasm の読み込みがブラウザに止められるので、HTTP で配信します
- 会場でネットワークがない場合に備えて、`bundle install` は事前に済ませておいてください
- `dist/game.rb` へのアクセスのたびにビルドし直すので、`.rb` を編集したらリロードするだけで反映されます
- 既定のポートは、PicoDX の開発サーバー（3000）と重ならないよう 3001 です。変えるときは `PORT=8080 bundle exec ruby script/server`

GitHub Pages などに静的ファイルとして置く場合は、先に `ruby script/build.rb` で `dist/game.rb` を生成してから、リポジトリ一式を配置します。

## 構成

```
main.rb, page/, class/, init/   ゲーム本体（原作のファイル構成のまま）
init/block_grid.rb              移植で追加した、衝突判定を近くのブロックに絞る仕組み
compat/                         PicoRuby にない Set と、Range を受け付ける速い rand
script/build.rb                 require をたどって dist/game.rb の 1 ファイルにまとめる
script/server                   開発・デモ用サーバー（WEBrick）
Gemfile                         webrick（script/server で使う）
vendor/picodx.rb                PicoDX（itojum/picodx@7b230b8 のビルド）
vendor/picoruby/                PicoRuby.wasm 4.0.2
index.html                      ゲームを表示するページ
```

## メンバー（Ruby合宿2024春 Team5）

- Ms.T イラスト・曲（グラフィック）
- Mr.I リーダー（ロジック）
- Mr.U グラフィック
- Mr.T Pull Request（グラフィック）
- Ms.S ロジック

## 使用 BGM

フリーBGM・音楽素材 MusMus https://musmus.main.jp

## ライセンス

MIT（[LICENSE](LICENSE)）。PicoDX と PicoRuby.wasm もそれぞれ MIT ライセンスです。
