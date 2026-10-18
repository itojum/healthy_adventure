# ブラウザ用の入口。`npm run build` が --root game でこのファイルを bundle する。
# PicoRuby に足りない機能を補ってから、原作の main.rb を読み込む。

require_relative 'compat'
require './main.rb'
