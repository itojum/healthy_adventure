require 'set'
require './class/block.rb'

def initBlock
  blocks = Set.new

  for num in 0..26 do
      blocks.add (Block.new(num, -1, 1))
      blocks.add  (Block.new(num, -2, 4))
  end
  for num in 32..40 do
      blocks.add (Block.new(num, -1, 1))
      blocks.add (Block.new(num, -2, 4))
  end
  for num in 44..95 do
      blocks.add (Block.new(num, -1, 1))
      blocks.add (Block.new(num, -2, 4))
  end
  for num in 105..137 do
    blocks.add (Block.new(num, -1, 1))
    blocks.add (Block.new(num, -2, 4))
end


  blocks.add (Block.new(15, 2, 3))
  blocks.add (Block.new(16, 2, 3))
  blocks.add (Block.new(17, 2, 3))
  blocks.add (Block.new(16, 5, 5))

  blocks.add (Block.new(25, 2, 4))
  blocks.add (Block.new(26, 2, 4))
  blocks.add (Block.new(28, 5, 2))
  blocks.add (Block.new(29, 5, 2))
  blocks.add (Block.new(30, 5, 2))
 

  for num in 0..5 do
      for i in 0..num do
          blocks.add (Block.new(70+num, i, 0))
          i+=1
      end
      num+=1
  end

  for num in 0..5 do
      for i in 0..5-num do
          blocks.add (Block.new(78+num, i, 0))
          i+=1
      end
      num+=1
  end

  for num in 0..7 do
    for i in 0..num do
        blocks.add (Block.new(130+num, i, 0))
        i+=1
    end
    num+=1
end
  blocks.add (Block.new(44, 0, 3))
  blocks.add (Block.new(44, 1, 3))

  blocks.add (Block.new(39, 0, 4))
  blocks.add (Block.new(40, 0, 4))
  blocks.add (Block.new(40, 1, 4))

  blocks.add (Block.new(20, 0, 5))
  blocks.add (Block.new(98, 0, 1))
  blocks.add (Block.new(101,1, 1))
  blocks.add (Block.new(105,0, 4))
  blocks.add (Block.new(105,1, 4))
  blocks.add (Block.new(105,2, 4))

  blocks.add (Block.new(49,5, 0))
  blocks.add (Block.new(50,5, 0))
  blocks.add (Block.new(51,5, 0))
  blocks.add (Block.new(52,5, 0))
  blocks.add (Block.new(53,5, 0))
  blocks.add (Block.new(54,5, 0))
  blocks.add (Block.new(55,5, 0))
  blocks.add (Block.new(56,5, 0))
  blocks.add (Block.new(57,5, 0))
  blocks.add (Block.new(58,5, 0))
  blocks.add (Block.new(59,5, 0))
  blocks.add (Block.new(60,5, 0))
  blocks.add (Block.new(61,5, 0))
  blocks.add (Block.new(62,5, 0))

  blocks.add (Block.new(52,4, 0))
  blocks.add (Block.new(58,4, 0))

  for num in 49..62 do
    blocks.add (Block.new(num, 5, 0))
    blocks.add (Block.new(num, 6, 0))
    blocks.add (Block.new(num, 7, 0))
    blocks.add (Block.new(num, 8, 0))
    blocks.add (Block.new(num, 9, 0))
    blocks.add  (Block.new(num, 10, 0))
end

  return blocks
end