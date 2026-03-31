module FastBroadcastStaticExt

import FastBroadcast: fast_materialize!, fast_materialize
using FastBroadcast: Serial, Threaded
using Static: False, True

fast_materialize!(::False, dst, bc) = fast_materialize!(Serial(), dst, bc)
fast_materialize!(::True, dst, bc) = fast_materialize!(Threaded(), dst, bc)
fast_materialize(::False, bc) = fast_materialize(Serial(), bc)
fast_materialize(::True, bc) = fast_materialize(Threaded(), bc)

end
