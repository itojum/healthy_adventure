require 'set'

require './class/Enemy/radish.rb'
require './class/Enemy/tomato.rb'
require './class/Enemy/fire.rb'
require './class/Enemy/carrot.rb'
require './class/Enemy/fork&knife.rb'

def initEnemy
  enemys = Set.new

  enemys.add(Radish.new(18, 9))
  enemys.add(Radish.new(77, 4))
  enemys.add(Radish.new(85, 4))
  enemys.add(Radish.new(123, 4))
  enemys.add(Radish.new(123, 4))
  enemys.add(Radish.new(123, 4))
  enemys.add(Radish.new(123, 4))
  enemys.add(Radish.new(123, 4))


  enemys.add(Carrot.new(18, 9))
  enemys.add(Carrot.new(76, 4))
  enemys.add(Carrot.new(47, 10))
  enemys.add(Carrot.new(83, 0))
  enemys.add(Carrot.new(123, 0))
  enemys.add(Carrot.new(123, 0))
  enemys.add(Carrot.new(123, 0))
  enemys.add(Carrot.new(123, 0))
  enemys.add(Carrot.new(123, 0))


  enemys.add(Fire.new(50, 0))
  enemys.add(Fire.new(56, 0))
  enemys.add(Fire.new(61, 0))

  enemys.add(Fire.new(77, 0))
  enemys.add(Fire.new(78, 0))

  enemys.add(Tomato.new(20, 2))

  enemys.add(Tomato.new(38, 0))
  enemys.add(Tomato.new(77, 0))
  enemys.add(Tomato.new(123, 1))
  enemys.add(Tomato.new(116, 0))

  enemys.add(Tomato.new(35, 2))
  enemys.add(Tomato.new(133, 5))
  enemys.add(Tomato.new(80, 0))
 


  
  enemys.add(Fire.new(17, 0.3, 180))

  enemys.add(Fire.new(110, 0))
  enemys.add(Fire.new(117, 0))
  enemys.add(Fire.new(122, 0))

  enemys.add(Fire.new(52.9, 2.25, 180))
  enemys.add(Fire.new(58.9, 2.25, 180)) 

  enemys.add(ForkKnife.new(72, 2, 0))
  enemys.add(ForkKnife.new(74, 4, 0))

  enemys.add(ForkKnife.new(135, 5, 0))
  enemys.add(ForkKnife.new(133, 3, 0))


  return enemys
end