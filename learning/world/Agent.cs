using System;
using System.Collections.Generic;
using System.Text;

namespace world
{
    public abstract class Agent
    {
        public abstract (bool up, bool down, bool left, bool right, bool go, bool fire) React(int x, int y, int angle, int ox, int oy, int oangle, List<tanks.Bullet> bullets);
    }
}
