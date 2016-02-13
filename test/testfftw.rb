require 'numru/narray'
include NumRu

x = NArray.complex(1024,1024).indgen!

p x
puts 'executing fftw ...'
t1 = Time.now.to_f
y = FFTW.fftw( x, 1 )
t2 = Time.now.to_f
print "time: ",t2 - t1,"\n"
p y

exit

x = NArray.complex(128,128).indgen!
10000.times{ x = FFTW.fftw( x, 1 ) }
