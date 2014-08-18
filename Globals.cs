using System;
using System.Collections.Generic;
using System.Text;

namespace tanks
{
    public static class Globals
    {
        public static readonly double[] SinTable = new double[16];
        public static readonly double[] CosTable = new double[16];

        public static int GameLoopTick_ms = 4;

        public static int MaxBullets = 3;
        public static int BulletLifeSpan = 600;

        public static int WinningScore = 15;

        static Globals()
        {
            for (int i = 0; i < 16; i++)
            {
                SinTable[i] = Math.Sin(22.5 * i * Math.PI / 180);
                CosTable[i] = Math.Cos(22.5 * i * Math.PI / 180);
            }
        }
    }
}
