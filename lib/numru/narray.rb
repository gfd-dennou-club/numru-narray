unless ENV["OMP_NUM_THREADS"]
  ENV["OMP_NUM_THREADS"] = "1"
end
if defined?(NArray)
  raise "NArray is alread loaded.\nNumRu::NArray cannot use with NArray.\n"
end
require "numru/narray/narray.so"
