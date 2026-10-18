BLOCK_GRID_COLUMN = 64
# 1 フレームの移動量（横 6px、ジャンプで縦 21px）より広くとる
BLOCK_GRID_MARGIN = 48

# 判定範囲（画像全体を中心まわりに scale_x 倍）の左端
def block_grid_left(block)
  img = block.image
  block.x + img.width * (1 - block.scale_x.abs) / 2
end

# ブロックを判定範囲の左端の x 座標で BLOCK_GRID_COLUMN ごとの列に振り分ける
def build_block_grid(blocks)
  grid = {}
  blocks.each do |block|
    col = (block_grid_left(block) / BLOCK_GRID_COLUMN).floor
    (grid[col] ||= []) << block
  end
  $block_grid = grid
end

# sprite の画像の範囲に BLOCK_GRID_MARGIN を足した範囲と重なり得るブロックを返す
def nearby_blocks(sprite)
  img = sprite.image
  return [] if img.nil?

  w = img.width  * sprite.scale_x.abs
  h = img.height * sprite.scale_y.abs
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
