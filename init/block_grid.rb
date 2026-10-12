# [移植] 衝突判定の対象を「近くのブロック」だけに絞るための仕組み。
#
# 原作は敵・弾・プレイヤーのすべてが、毎フレーム全ブロック（約 450 個）と
# Sprite#=== で判定している。DXRuby は判定が C 実装なので間に合っていたが、
# PicoRuby.wasm では 1 回あたり約 10µs かかり、1 フレームが 300ms を超える（約 3fps）。
#
# ブロックは画面全体と一緒にスクロールするだけで、互いの並びは変わらない。
# そこで毎フレーム、ブロックを x 座標の列（64px 幅）ごとに振り分けておき、
# 判定する側は自分のまわりの列にあるブロックだけを候補として受け取る。
# 判定そのもの（Sprite#===）と、どのブロックに当たるかの結果は原作と変わらない。

BLOCK_GRID_COLUMN = 64   # ブロックの判定範囲の幅（128px の画像を 0.5 倍）
BLOCK_GRID_MARGIN = 48   # 1 フレームの移動量（横 6px、ジャンプで縦 21px）より広めにとる余白

# ブロックの判定範囲（画像全体を中心まわりに 0.5 倍）の左端 x
def block_grid_left(block)
  img = block.image
  block.x + img.width * (1 - block.scale_x.abs) / 2
end

def build_block_grid(blocks)
  grid = {}
  blocks.each do |block|
    col = (block_grid_left(block) / BLOCK_GRID_COLUMN).floor
    (grid[col] ||= []) << block
  end
  $block_grid = grid
end

# sprite の画像の範囲（拡縮込み、余白つき）と重なり得るブロックを返す
def nearby_blocks(sprite)
  img = sprite.image
  return [] if img.nil?

  w  = img.width  * sprite.scale_x.abs
  h  = img.height * sprite.scale_y.abs
  if sprite.offset_sync
    cx = sprite.x
    cy = sprite.y
  else
    cx = sprite.x + img.width  / 2
    cy = sprite.y + img.height / 2
  end
  left   = cx - w / 2 - BLOCK_GRID_MARGIN
  right  = cx + w / 2 + BLOCK_GRID_MARGIN
  top    = cy - h / 2 - BLOCK_GRID_MARGIN
  bottom = cy + h / 2 + BLOCK_GRID_MARGIN

  result = []
  col = (left / BLOCK_GRID_COLUMN).floor - 1
  last_col = (right / BLOCK_GRID_COLUMN).floor
  while col <= last_col
    column = $block_grid[col]
    if column
      column.each do |block|
        bimg = block.image
        bh   = bimg.height * block.scale_y.abs
        btop = block.y + (bimg.height - bh) / 2
        result << block if btop < bottom && btop + bh > top
      end
    end
    col += 1
  end
  result
end
