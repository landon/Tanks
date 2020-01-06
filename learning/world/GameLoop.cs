using System;
using System.Collections.Generic;
using System.Text;
using System.Linq;

using tanks;

namespace world
{
    public class GameLoop
    {
        static Cell[,] _map = LoadMap(Globals.OriginalMap);

        public static int RunGame(Agent redAgent, Agent blueAgent)
        {
            var red = new Player(_map, 270, 175, 12);
            var blue = new Player(_map, 60, 20, 4);
            var allBullets = new List<Bullet>();
            var redScore = 0;
            var blueScore = 0;

            while(true)
            {
                var rr = redAgent.React(red.Tank.X, red.Tank.Y, red.Tank.Angle, blue.Tank.X, blue.Tank.Y, blue.Tank.Angle, allBullets);
                var bb = blueAgent.React(blue.Tank.X, blue.Tank.Y, blue.Tank.Angle, red.Tank.X, red.Tank.Y, red.Tank.Angle, allBullets);

                red.Update(rr.up, rr.down, rr.left, rr.right, rr.go, rr.fire);
                blue.Update(bb.up, bb.down, bb.left, bb.right, bb.go, bb.fire);

                allBullets = red.Tank.Bullets.Concat(blue.Tank.Bullets).ToList();

                foreach(var b in allBullets)
                {
                    if (red.Tank.HitByBullet(b))
                    {
                        redScore = 1;
                    }
                    if (blue.Tank.HitByBullet(b))
                    {
                        blueScore = 1;
                    }
                    if (redScore > 0 || blueScore > 0)
                    {
                        return redScore - blueScore;
                    }
                }
            }
        }

        static Cell[,] LoadMap(string map)
        {
            var m = new Cell[40, 25];
            try
            {
                string[] lines = map.Split(new string[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);

                int j = 0;
                foreach (string line in lines)
                {
                    string[] parts = line.Split(new string[] { " " }, StringSplitOptions.RemoveEmptyEntries);

                    int i = 0;

                    foreach (string part in parts)
                    {
                        byte t = 0;
                        byte.TryParse(part, out t);

                        Cell c = new Cell();
                        c.Type = t;
                        c.X = 8 * i;
                        c.Y = 8 * j;

                        m[i, j] = c;

                        i++;

                        if (i >= 40)
                            break;
                    }

                    j++;
                    if (j >= 25)
                        break;
                }
            }
            catch (Exception ex)
            {
                // Bad map.
            }

            return m;
        }
    }
}
