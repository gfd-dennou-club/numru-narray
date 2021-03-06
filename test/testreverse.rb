require 'numru/narray'
include NumRu

def px(a)
  puts a
  puts "#=> " + eval(a).inspect
end

px "$a = NArray.int(3,3).indgen!   "
px "$a.reverse                     "
px "$a.reverse(0)                  "
px "$a.reverse(1)                  "
px "$a.rot90                       "
px "$a.rot90(2)                    "
px "$a.rot90(-1)                   "
px "$a = NArray.int(3,3,3).indgen! "
px "$a.reverse                     "
px "$a.reverse(0)                  "
px "$a.reverse(1)                  "
px "$a.rot90                       "
px "$a.rot90(2)                    "
px "$a.rot90(-1)                   "
px "$a = NArray.int(3).indgen!     "
px "$a.reverse                     "
px "$a.reverse(0)                  "


puts "..... the next will fail ....."

begin
px "$a.rot90                       "
rescue RuntimeError
else
  raise "RuntimeError is not raised"
end

begin
px "$a.rot90(-1)                   "
rescue RuntimeError
else
  raise "RuntimeError is not raised"
end
