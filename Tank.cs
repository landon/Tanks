using System;
using System.Collections.Generic;
using System.Text;
using System.Drawing;

namespace tanks
{
    public class Tank
    {
        public static Tank Red;
        public static Tank Blue;
        public static int RedScore = 0;
        public static int BlueScore = 0;

        static readonly Color BulletColor;
        static readonly int[] ExplosionSequence = {1, 2, 3, 2};

        static Tank()
        {
            BulletColor = Mode13hPanel.GetDefaultPaletteColor(8);
        }

        [Flags]
        public enum BulletCheckResults
        {
            AllGood = 0,
            RedDied = 1,
            BlueDied = 2,
        }

        public int X, Y, Speed, Angle;
        public bool IsAlive;
        public byte[] VGA;
        public byte[][] Explosion = new byte[3][];
        List<Bullet> Bullets = new List<Bullet>();
        public bool IsExploding = false;
        int _ExplosionIndex = 0;

        public void Draw(Mode13hPanel panel)
        {
            foreach (Bullet bullet in Bullets)
            {
                panel.PutPixel((int)Math.Round(bullet.X), (int)Math.Round(bullet.Y), BulletColor);
                panel.PutPixel((int)Math.Round(bullet.X) + 1, (int)Math.Round(bullet.Y), BulletColor);
                panel.PutPixel((int)Math.Round(bullet.X), (int)Math.Round(bullet.Y) + 1, BulletColor);
                panel.PutPixel((int)Math.Round(bullet.X) + 1, (int)Math.Round(bullet.Y) + 1, BulletColor);
            }

            if (IsExploding)
            {
                if (_ExplosionIndex < 19)
                {
                    panel.DrawVGARotated(X, Y, Angle, Explosion[ExplosionSequence[_ExplosionIndex % 4] - 1]);
                    _ExplosionIndex++;
                }
                else
                {

                }
            }
            else
            {
                panel.DrawVGARotated(X, Y, Angle, VGA);
            }
        }

        public bool DoneExploding
        {
            get
            {
                return !IsExploding || _ExplosionIndex >= 19;
            }
        }

        public void Explode()
        {
            if (!IsExploding)
            {
                _ExplosionIndex = 0;
                IsExploding = true;
            }
        }

        public void Up()
        {
            if (Angle > 0 && Angle < 8)
                Angle--;
            else if (Angle <= 15 && Angle >= 8)
                Angle++;

            NormalizeAngle();
        }

        public void Down()
        {
            if (Angle >= 0 && Angle < 8)
                Angle++;
            else if (Angle <= 15 && Angle > 8)
                Angle--;

            NormalizeAngle();
        }

        public void Left()
        {
            if (Angle < 12 && Angle >= 4)
                Angle++;
            else if (Angle > 12 && Angle <= 15 || Angle >= 0 && Angle < 4)
                Angle--;

            NormalizeAngle();
        }

        public void Right()
        {
            if (Angle < 12 && Angle > 4)
                Angle--;
            else if (Angle >= 12 && Angle <= 15 || Angle >= 0 && Angle < 4)
                Angle++;

            NormalizeAngle();
        }

        public void Go()
        {
            int a = (Angle + 4) % 16;
            X -= (int)Math.Round(Speed * Globals.CosTable[a]);
            Y -= (int)Math.Round(Speed * Globals.SinTable[a]);
        }

        public void Fire()
        {
            if (Bullets.Count < Globals.MaxBullets)
            {
                var b = new Bullet();
                b.Age = 0;
                int a = (Angle + 4) % 16;

                b.X = X - 11 * Globals.CosTable[a];
                b.Y = Y - 11 * Globals.SinTable[a];
                b.DX = -1.2 * Globals.CosTable[a];
                b.DY = -1.2 * Globals.SinTable[a];

                Bullets.Add(b);
            }
        }

        public void CheckCollisions(Cell[,] map)
        {
            switch (Angle)
            {
                case 0:
                    if (Y < 17) Y = 17;
                    break;
                case 1:
                    if (Y < 16) Y = 16;
                    if (X > 305) X = 305;
                    break;
                case 2:
                    if (Y < 14) Y = 14;
                    if (X > 304) X = 304;
                    break;
                case 3:
                    if (Y < 13) Y = 13;
                    if (X > 302) X = 302;
                    break;
                case 4:
                    if (X > 301) X = 301;
                    break;
                case 5:
                    if (Y > 185) Y = 185;
                    if (X > 302) X = 302;
                    break;
                case 6:
                    if (Y > 184) Y = 184;
                    if (X > 304) X = 304;
                    break;
                case 7:
                    if (Y > 181) Y = 181;
                    if (X > 305) X = 305;
                    break;
                case 8:
                    if (Y > 181) Y = 181;
                    break;
                case 9:
                    if (Y > 181) Y = 181;
                    if (X < 13) X = 13;
                    break;
                case 10:
                    if (Y > 184) Y = 184;
                    if (X < 14) X = 14;
                    break;
                case 11:
                    if (Y > 185) Y = 185;
                    if (X < 16) X = 16;
                    break;
                case 12:
                    if (X < 17) X = 17;
                    break;
                case 13:
                    if (Y < 13) Y = 13;
                    if (X < 16) X = 16;
                    break;
                case 14:
                    if (Y < 14) Y = 14;
                    if (X < 14) X = 14;
                    break;
                case 15:
                    if (Y < 16) Y = 16;
                    if (X < 13) X = 13;
                    break;
            }

            for (int i = 0; i < 40; i++)
                for (int j = 0; j < 25; j++)
                {
                    if (map[i, j].Type == 1)
                    {
                        switch (Angle)
                        {
                            case 0:
                                if ((Y - 10 < map[i, j].Y + 11) && (Y > map[i, j].Y + 4) &&
                                   (((X - 6 <= map[i, j].X + 8) && (X - 6 >= map[i, j].X)) ||
                                   ((X + 6 >= map[i, j].X) && (X + 6 <= map[i, j].X + 8)) ||
                                   ((X >= map[i, j].X) && (X <= map[i, j].X + 8)))) Y = map[i, j].Y + 21;
                                break;
                            case 1:
                                if ((Y - 10 < map[i, j].Y + 11) && (Y > map[i, j].Y + 4) &&
                                   (((X - 6 <= map[i, j].X + 8) && (X - 6 >= map[i, j].X)) ||
                                   ((X + 6 >= map[i, j].X) && (X + 6 <= map[i, j].X + 8)) ||
                                   ((X >= map[i, j].X) && (X <= map[i, j].X + 8)))) Y = map[i, j].Y + 21;
                                if ((X + 10 > map[i, j].X - 2) && (X + 10 < map[i, j].X + 4) &&
                                   (((Y - 6 <= map[i, j].Y + 8) && (Y - 6 >= map[i, j].Y)) ||
                                   ((Y + 6 >= map[i, j].Y) && (Y + 6 <= map[i, j].Y + 8)) ||
                                   ((Y >= map[i, j].Y) && (Y <= map[i, j].Y + 8)))) X = map[i, j].X - 12;
                                break;
                            case 2:
                                if ((Y - 10 < map[i, j].Y + 10) && (Y > map[i, j].Y + 4) &&
                                   (((X - 6 <= map[i, j].X + 8) && (X - 6 >= map[i, j].X)) ||
                                   ((X + 6 >= map[i, j].X) && (X + 6 <= map[i, j].X + 8)) ||
                                   ((X >= map[i, j].X) && (X <= map[i, j].X + 8)))) Y = map[i, j].Y + 20;
                                if ((X + 10 > map[i, j].X - 2) && (X + 10 < map[i, j].X + 4) &&
                                   (((Y - 6 <= map[i, j].Y + 8) && (Y - 6 >= map[i, j].Y)) ||
                                   ((Y + 6 >= map[i, j].Y) && (Y + 6 <= map[i, j].Y + 8)) ||
                                   ((Y >= map[i, j].Y) && (Y <= map[i, j].Y + 8)))) X = map[i, j].X - 12;
                                break;
                            case 3:
                                if ((Y - 10 < map[i, j].Y + 10) && (Y > map[i, j].Y + 4) &&
                                   (((X - 6 <= map[i, j].X + 8) && (X - 6 >= map[i, j].X)) ||
                                   ((X + 6 >= map[i, j].X) && (X + 6 <= map[i, j].X + 8)) ||
                                   ((X >= map[i, j].X) && (X <= map[i, j].X + 8)))) Y = map[i, j].Y + 20;
                                if ((X + 10 > map[i, j].X - 3) && (X + 10 < map[i, j].X + 4) &&
                                   (((Y - 6 <= map[i, j].Y + 8) && (Y - 6 >= map[i, j].Y)) ||
                                   ((Y + 6 >= map[i, j].Y) && (Y + 6 <= map[i, j].Y + 8)) ||
                                   ((Y >= map[i, j].Y) && (Y <= map[i, j].Y + 8)))) X = map[i, j].X - 13;
                                break;
                            case 4:
                                if ((X + 10 > map[i, j].X - 3) && (X + 10 < map[i, j].X + 4) &&
                                   (((Y - 6 <= map[i, j].Y + 8) && (Y - 6 >= map[i, j].Y)) ||
                                   ((Y + 6 >= map[i, j].Y) && (Y + 6 <= map[i, j].Y + 8)) ||
                                   ((Y >= map[i, j].Y) && (Y <= map[i, j].Y + 8)))) X = map[i, j].X - 13;
                                break;
                            case 5:
                                if ((X + 10 > map[i, j].X - 3) && (X + 10 < map[i, j].X + 4) &&
                                   (((Y - 6 <= map[i, j].Y + 8) && (Y - 6 >= map[i, j].Y)) ||
                                   ((Y + 6 >= map[i, j].Y) && (Y + 6 <= map[i, j].Y + 8)) ||
                                   ((Y >= map[i, j].Y) && (Y <= map[i, j].Y + 8)))) X = map[i, j].X - 13;
                                if ((Y + 10 > map[i, j].Y - 2) && (Y + 10 < map[i, j].Y + 4) &&
                                   (((X - 6 <= map[i, j].X + 8) && (X - 6 >= map[i, j].X)) ||
                                   ((X + 6 >= map[i, j].X) && (X + 6 <= map[i, j].X + 8)) ||
                                   ((X >= map[i, j].X) && (X <= map[i, j].X + 8)))) Y = map[i, j].Y - 12;
                                break;
                            case 6:
                                if ((X + 10 > map[i, j].X - 2) && (X + 10 < map[i, j].X + 4) &&
                                   (((Y - 6 <= map[i, j].Y + 8) && (Y - 6 >= map[i, j].Y)) ||
                                   ((Y + 6 >= map[i, j].Y) && (Y + 6 <= map[i, j].Y + 8)) ||
                                   ((Y >= map[i, j].Y) && (Y <= map[i, j].Y + 8)))) X = map[i, j].X - 12;
                                if ((Y + 10 > map[i, j].Y - 2) && (Y + 10 < map[i, j].Y + 4) &&
                                   (((X - 6 <= map[i, j].X + 8) && (X - 6 >= map[i, j].X)) ||
                                   ((X + 6 >= map[i, j].X) && (X + 6 <= map[i, j].X + 8)) ||
                                   ((X >= map[i, j].X) && (X <= map[i, j].X + 8)))) Y = map[i, j].Y - 12;
                                break;
                            case 7:
                                if ((X + 10 > map[i, j].X - 2) && (X + 10 < map[i, j].X + 4) &&
                                   (((Y - 6 <= map[i, j].Y + 8) && (Y - 6 >= map[i, j].Y)) ||
                                   ((Y + 6 >= map[i, j].Y) && (Y + 6 <= map[i, j].Y + 8)) ||
                                   ((Y >= map[i, j].Y) && (Y <= map[i, j].Y + 8)))) X = map[i, j].X - 12;
                                if ((Y + 10 > map[i, j].Y - 3) && (Y + 10 < map[i, j].Y + 4) &&
                                   (((X - 6 <= map[i, j].X + 8) && (X - 6 >= map[i, j].X)) ||
                                   ((X + 6 >= map[i, j].X) && (X + 6 <= map[i, j].X + 8)) ||
                                   ((X >= map[i, j].X) && (X <= map[i, j].X + 8)))) Y = map[i, j].Y - 13;
                                break;
                            case 8:
                                if ((Y + 10 > map[i, j].Y - 3) && (Y + 10 < map[i, j].Y + 4) &&
                                   (((X - 6 <= map[i, j].X + 8) && (X - 6 >= map[i, j].X)) ||
                                   ((X + 6 >= map[i, j].X) && (X + 6 <= map[i, j].X + 8)) ||
                                   ((X >= map[i, j].X) && (X <= map[i, j].X + 8)))) Y = map[i, j].Y - 13;
                                break;
                            case 9:
                                if ((X - 10 <= map[i, j].X + 10) && (X - 10 >= map[i, j].X + 4) &&
                                   (((Y - 6 <= map[i, j].Y + 8) && (Y - 6 >= map[i, j].Y)) ||
                                   ((Y + 6 >= map[i, j].Y) && (Y + 6 <= map[i, j].Y + 8)) ||
                                   ((Y >= map[i, j].Y) && (Y <= map[i, j].Y + 8)))) X = map[i, j].X + 20;
                                if ((Y + 10 > map[i, j].Y - 3) && (Y + 10 < map[i, j].Y + 4) &&
                                   (((X - 6 <= map[i, j].X + 8) && (X - 6 >= map[i, j].X)) ||
                                   ((X + 6 >= map[i, j].X) && (X + 6 <= map[i, j].X + 8)) ||
                                   ((X >= map[i, j].X) && (X <= map[i, j].X + 8)))) Y = map[i, j].Y - 13;
                                break;
                            case 10:
                                if ((X - 10 <= map[i, j].X + 10) && (X - 10 >= map[i, j].X + 4) &&
                                   (((Y - 6 <= map[i, j].Y + 8) && (Y - 6 >= map[i, j].Y)) ||
                                   ((Y + 6 >= map[i, j].Y) && (Y + 6 <= map[i, j].Y + 8)) ||
                                   ((Y >= map[i, j].Y) && (Y <= map[i, j].Y + 8)))) X = map[i, j].X + 20;
                                if ((Y + 10 > map[i, j].Y - 2) && (Y + 10 < map[i, j].Y + 4) &&
                                   (((X - 6 <= map[i, j].X + 8) && (X - 6 >= map[i, j].X)) ||
                                   ((X + 6 >= map[i, j].X) && (X + 6 <= map[i, j].X + 8)) ||
                                   ((X >= map[i, j].X) && (X <= map[i, j].X + 8)))) Y = map[i, j].Y - 12;
                                break;
                            case 11:
                                if ((X - 10 <= map[i, j].X + 11) && (X - 10 >= map[i, j].X + 4) &&
                                   (((Y - 6 <= map[i, j].Y + 8) && (Y - 6 >= map[i, j].Y)) ||
                                   ((Y + 6 >= map[i, j].Y) && (Y + 6 <= map[i, j].Y + 8)) ||
                                   ((Y >= map[i, j].Y) && (Y <= map[i, j].Y + 8)))) X = map[i, j].X + 21;
                                if ((Y + 10 > map[i, j].Y - 2) && (Y + 10 < map[i, j].Y + 4) &&
                                   (((X - 6 <= map[i, j].X + 8) && (X - 6 >= map[i, j].X)) ||
                                   ((X + 6 >= map[i, j].X) && (X + 6 <= map[i, j].X + 8)) ||
                                   ((X >= map[i, j].X) && (X <= map[i, j].X + 8)))) Y = map[i, j].Y - 12;
                                break;
                            case 12:
                                if ((X - 10 <= map[i, j].X + 11) && (X - 10 >= map[i, j].X + 4) &&
                                   (((Y - 6 <= map[i, j].Y + 8) && (Y - 6 >= map[i, j].Y)) ||
                                   ((Y + 6 >= map[i, j].Y) && (Y + 6 <= map[i, j].Y + 8)) ||
                                   ((Y >= map[i, j].Y) && (Y <= map[i, j].Y + 8)))) X = map[i, j].X + 21;
                                break;
                            case 13:
                                if ((X - 10 <= map[i, j].X + 11) && (X - 10 >= map[i, j].X + 4) &&
                                   (((Y - 6 <= map[i, j].Y + 8) && (Y - 6 >= map[i, j].Y)) ||
                                   ((Y + 6 >= map[i, j].Y) && (Y + 6 <= map[i, j].Y + 8)) ||
                                   ((Y >= map[i, j].Y) && (Y <= map[i, j].Y + 8)))) X = map[i, j].X + 21;
                                if ((Y - 10 < map[i, j].Y + 10) && (Y > map[i, j].Y + 4) &&
                                   (((X - 6 <= map[i, j].X + 8) && (X - 6 >= map[i, j].X)) ||
                                   ((X + 6 >= map[i, j].X) && (X + 6 <= map[i, j].X + 8)) ||
                                   ((X >= map[i, j].X) && (X <= map[i, j].X + 8)))) Y = map[i, j].Y + 20;
                                break;
                            case 14:
                                if ((X - 10 <= map[i, j].X + 10) && (X - 10 >= map[i, j].X + 4) &&
                                   (((Y - 6 <= map[i, j].Y + 8) && (Y - 6 >= map[i, j].Y)) ||
                                   ((Y + 6 >= map[i, j].Y) && (Y + 6 <= map[i, j].Y + 8)) ||
                                   ((Y >= map[i, j].Y) && (Y <= map[i, j].Y + 8)))) X = map[i, j].X + 20;
                                if ((Y - 10 < map[i, j].Y + 10) && (Y > map[i, j].Y + 4) &&
                                   (((X - 6 <= map[i, j].X + 8) && (X - 6 >= map[i, j].X)) ||
                                   ((X + 6 >= map[i, j].X) && (X + 6 <= map[i, j].X + 8)) ||
                                   ((X >= map[i, j].X) && (X <= map[i, j].X + 8)))) Y = map[i, j].Y + 20;
                                break;
                            case 15:
                                if ((X - 10 <= map[i, j].X + 10) && (X - 10 >= map[i, j].X + 4) &&
                                   (((Y - 6 <= map[i, j].Y + 8) && (Y - 6 >= map[i, j].Y)) ||
                                   ((Y + 6 >= map[i, j].Y) && (Y + 6 <= map[i, j].Y + 8)) ||
                                   ((Y >= map[i, j].Y) && (Y <= map[i, j].Y + 8)))) X = map[i, j].X + 20;
                                if ((Y - 10 < map[i, j].Y + 11) && (Y > map[i, j].Y + 4) &&
                                   (((X - 6 <= map[i, j].X + 8) && (X - 6 >= map[i, j].X)) ||
                                   ((X + 6 >= map[i, j].X) && (X + 6 <= map[i, j].X + 8)) ||
                                   ((X >= map[i, j].X) && (X <= map[i, j].X + 8)))) Y = map[i, j].Y + 21;
                                break;
                        }
                    }
                }
        }

        void NormalizeAngle()
        {
            if (Angle > 15)
                Angle = 0;
            else if (Angle < 0)
                Angle = 15;
        }

        public BulletCheckResults CheckBullets(Cell[,] map)
        {
            foreach (Bullet bullet in Bullets)
                bullet.Age++;

            Bullets.RemoveAll(bullet => bullet.Age > Globals.BulletLifeSpan);

            bool redHit = false;
            bool blueHit = false;
            foreach (Bullet bullet in Bullets)
            {
                bullet.X += bullet.DX;
                bullet.Y += bullet.DY;

                if (bullet.Y < 4 || bullet.Y > 194)
                    bullet.DY = -bullet.DY;
                if (bullet.X > 314 || bullet.X < 3)
                    bullet.DX = -bullet.DX;

                for (int i = 0; i < 40; i++)
                {
                    for (int j = 0; j < 25; j++)
                    {
                        if (map[i, j].Type == 1)
                        {
                            if (bullet.X < map[i, j].X + 10 && bullet.X > map[i, j].X + 4 &&
                                bullet.Y < map[i, j].Y + 8 && bullet.Y >= map[i, j].Y ||
                                bullet.X > map[i, j].X - 2 && bullet.X < map[i, j].X + 4 &&
                                bullet.Y < map[i, j].Y + 8 && bullet.Y >= map[i, j].Y)
                            {
                                bullet.DX = -bullet.DX;
                            }
                            if (bullet.Y < map[i, j].Y + 10 && bullet.Y > map[i, j].Y + 4 &&
                               bullet.X < map[i, j].X + 8 && bullet.X >= map[i, j].X ||
                               bullet.Y > map[i, j].Y - 2 && bullet.Y < map[i, j].Y + 4 &&
                               bullet.X >= map[i, j].X && bullet.X < map[i, j].X + 8)
                            {
                                bullet.DY = -bullet.DY;
                            }
                        }
                    }
                }

                redHit = redHit || BulletIntersectsTank(bullet, Red);
                blueHit = blueHit || BulletIntersectsTank(bullet, Blue);
            }

            return (redHit ? BulletCheckResults.RedDied : BulletCheckResults.AllGood) |
                (blueHit ? BulletCheckResults.BlueDied : BulletCheckResults.AllGood);
        }

        static bool BulletIntersectsTank(Bullet b, Tank t)
        {
            int x = 6;
            int y = 6;

            if (3 <= t.Angle && t.Angle <= 5 ||
                11 <= t.Angle && t.Angle <= 13)
                x += 4;
            else
                y += 4;

            return b.X >= t.X - x && b.X <= t.X + x && b.Y >= t.Y - y && b.Y <= t.Y + y;
        }
    }
}
