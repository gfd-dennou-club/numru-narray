unless ENV["OMP_NUM_THREADS"]
  ENV["OMP_NUM_THREADS"] = "1"
end
require "numru/narray/narray"
