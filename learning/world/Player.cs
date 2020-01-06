using System;
using System.Collections.Generic;
using System.Text;
using tanks;

namespace world
{
    public class Player
    {
        const int AngleChunk = 5;
        const int GoChunk = 1;

        int _angleCounter = 0;
        int _goCounter = 0;
        public Tank Tank;
        bool _firing;
        Cell[,] _map;

        public Player(Cell[,] map, int x, int y, int angle)
        {
            _map = map;
            Tank = new Tank();
            Tank.X = x;
            Tank.Y = y;
            Tank.Angle = angle;
            Tank.Speed = 2;
        }

        public void Update(bool up, bool down, bool left, bool right, bool go, bool fire)
        {
            if (up)
            {
                _angleCounter++;
                if (_angleCounter > AngleChunk)
                {
                    _angleCounter = 0;
                    Tank.Up();
                }
            }
            if (down)
            {
                _angleCounter++;
                if (_angleCounter > AngleChunk)
                {
                    _angleCounter = 0;
                    Tank.Down();
                }
            }
            if (left)
            {
                _angleCounter++;
                if (_angleCounter > AngleChunk)
                {
                    _angleCounter = 0;
                    Tank.Left();
                }
            }
            if (right)
            {
                _angleCounter++;
                if (_angleCounter > AngleChunk)
                {
                    _angleCounter = 0;
                    Tank.Right();
                }
            }
            if (go)
            {
                _goCounter++;
                if (_goCounter > GoChunk)
                {
                    _goCounter = 0;
                    Tank.Go();
                }
            }
            if (fire)
            {
                if (!_firing)
                {
                    Tank.Fire();
                    _firing = true;
                }
            }
            else 
            {
                _firing = false;
            }

            Tank.CheckCollisions(_map);
            Tank.UpdateBullets(_map);
        }
    }
}
