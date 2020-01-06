using System;
using System.Collections.Generic;
using System.Text;
using tanks;

namespace world
{
    public class StationaryAgent : Agent
    {
        public override (bool up, bool down, bool left, bool right, bool go, bool fire) React(int x, int y, int angle, int ox, int oy, int oangle, List<Bullet> bullets)
        {
            return (false, false, false, false, false, false);
        }
    }
}
