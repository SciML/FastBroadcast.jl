module FastBroadcastStaticExt

import FastBroadcast: fast_materialize!, fast_materialize
using Static: StaticBool

fast_materialize!(t::StaticBool, dst, bc) = fast_materialize!(Bool(t), dst, bc)
fast_materialize(t::StaticBool, bc) = fast_materialize(Bool(t), bc)

end
