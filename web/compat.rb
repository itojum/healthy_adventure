def rand(*args)
  range = args[0]
  return super unless range.is_a?(Range)

  min  = range.first
  last = range.exclude_end? ? range.last - 1 : range.last
  min + super(last - min + 1)
end
