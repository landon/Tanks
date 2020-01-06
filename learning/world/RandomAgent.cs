using System;
using System.Collections.Generic;
using System.Text;

namespace world
{
    public class RandomAgent : Agent     
    {
        Random RNG = new Random();
        public override (bool up, bool down, bool left, bool right, bool go, bool fire) React(int x, int y, int angle, int ox, int oy, int oangle, List<tanks.Bullet> bullets)
                     => (RNG.NextDouble() < 0.5, RNG.NextDouble() < 0.5, RNG.NextDouble() < 0.5, RNG.NextDouble() < 0.5, RNG.NextDouble() < 0.5, RNG.NextDouble() < 0.5);
    }
}
