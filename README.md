# Xx_healthy_adventure_xX

ブラウザで遊ぶ: https://itojum.github.io/healthy_adventure/

## ローカルで動かす

```bash
npm run build    # game/ のスクリプトと素材を web/ にコピーする
ruby script/server
```

http://localhost:8080 を開く。

`main` に push すると、GitHub Actions（`.github/workflows/pages.yml`）が `web/` を GitHub Pages に公開する。
