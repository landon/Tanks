using System;
using System.Collections.Generic;
using System.Text;
using System.Windows.Forms;
using System.Drawing;

namespace tanks
{
    public class Mode13hPanel : Panel
    {
        delegate void VoidDelegate();

        public Mode13hPanel()
        {
            SetStyle(ControlStyles.AllPaintingInWmPaint, true);
            SetStyle(ControlStyles.UserPaint, true);
            SetStyle(ControlStyles.OptimizedDoubleBuffer, true);
            SetStyle(ControlStyles.Opaque, true);
        }

        public static void DrawMap(Cell[,] map, Color[,] screen)
        {
            Clear(screen);

            for (int i = 0; i < 320; i++)
                for (int j = 0; j < 6; j++)
                    screen[i, j] = Color.Black;
            for (int i = 0; i < 6; i++)
                for (int j = 0; j < 200; j++)
                    screen[i, j] = Color.Black;
            for (int i = 313; i < 320; i++)
                for (int j = 0; j < 200; j++)
                    screen[i, j] = Color.Black;
            for (int i = 0; i < 320; i++)
                for (int j = 193; j < 200; j++)
                    screen[i, j] = Color.Black;

            for (int i = 0; i < 40; i++)
            {
                for (int j = 0; j < 25; j++)
                {
                    if (map[i, j].Type == 1)
                    {
                        for (int k = 0; k < 8; k++)
                            for (int l = 0; l < 8; l++)
                                screen[map[i, j].X + k, map[i, j].Y + l] = Color.Black;
                    }
                }
            }
        }

        Font _Font = new Font("Arial", 20);
        public void DrawScore(Graphics g)
        {
            string blue = Tank.BlueScore.ToString();
            g.DrawString(blue, _Font, Brushes.Blue, new PointF(10, 10));

            string red = Tank.RedScore.ToString();
            SizeF size = g.MeasureString(red, _Font);
            g.DrawString(red, _Font, Brushes.Red, new PointF(Width - size.Width - 10, 10));

            if (GameOver)
            {
                string gameOver = "GAME OVER";
                size = g.MeasureString(gameOver, _Font);

                g.DrawString(gameOver, _Font, Brushes.White, new PointF((Width - size.Width) / 2, (Height - size.Height) / 2));
            }
        }

        public static void Clear(Color[,] screen)
        {
            for (int x = 0; x < 320; x++)
            {
                for (int y = 0; y < 200; y++)
                {
                    screen[x, y] = Color.SandyBrown;
                }
            }
        }

        public static void FlipScreen(Color[,] source, Color[,] dest)
        {
            if (source.GetUpperBound(0) != dest.GetUpperBound(0) ||
                source.GetUpperBound(1) != dest.GetUpperBound(1))
                return;

            for (int x = 0; x < source.GetUpperBound(0); x++)
            {
                for (int y = 0; y < source.GetUpperBound(1); y++)
                {
                    dest[x, y] = source[x, y];
                }
            }
        }

        public static bool Identical(Color[,] s1, Color[,] s2)
        {
            if (s1.GetUpperBound(0) != s2.GetUpperBound(0) ||
               s1.GetUpperBound(1) != s2.GetUpperBound(1))
                return false;

            for (int x = 0; x < s1.GetUpperBound(0); x++)
            {
                for (int y = 0; y < s1.GetUpperBound(1); y++)
                {
                    if (s1[x, y] != s2[x, y])
                    {
                        return false;
                    }
                }
            }

            return true;
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            InternalPaint(e.Graphics, GetRectanglesToFill(true));
        }

        Dictionary<Color, List<RectangleF>> _RectanglesToFill;
        public void DoPaint()
        {
            _RectanglesToFill = GetRectanglesToFill(false);

            this.Invoke((VoidDelegate)MyPaint);
        }

        void MyPaint()
        {
            using (Graphics g = Graphics.FromHwnd(this.Handle))
            {
                InternalPaint(g, _RectanglesToFill);
            }
        }

        void InternalPaint(Graphics g, Dictionary<Color, List<RectangleF>> rectanglesToFill)
        {
            if (rectanglesToFill == null)
                return;

            foreach (KeyValuePair<Color, List<RectangleF>> kvp in rectanglesToFill)
            {
                _Brush.Color = kvp.Key;
                g.FillRectangles(_Brush, kvp.Value.ToArray());
            }

            if (ShouldDrawScore || GameOver)
                DrawScore(g);
        }

        Dictionary<Color, List<RectangleF>> GetRectanglesToFill(bool redraw)
        {
            Dictionary<Color, List<RectangleF>> rectanglesToFill = new Dictionary<Color, List<RectangleF>>();   

            float pixelWidth = Width / 320.0f;
            float pixelHeight = Height / 200.0f;
            for (int x = 0; x < 320; x++)
            {
                for (int y = 0; y < 200; y++)
                {
                    if (redraw || _Screen[x, y] != _Previous[x, y])
                    {
                        List<RectangleF> l;
                        if (!rectanglesToFill.TryGetValue(_Screen[x, y], out l))
                        {
                            l = new List<RectangleF>();
                            rectanglesToFill[_Screen[x, y]] = l;    
                        }
                        
                        l.Add(new RectangleF(x * pixelWidth, y * pixelHeight, pixelWidth, pixelHeight));

                        _Previous[x, y] = _Screen[x, y];
                    }
                }
            }

            return rectanglesToFill;
        }

        public void PutPixel(int x, int y, Color c)
        {
            if (x < 0 || x >= 320 || y < 0 || y >= 200)
                return;

            if (_Screen[x, y] == Color.SandyBrown || (_Screen[x,y] == Color.Black && c != Color.SandyBrown))
            {
                _Screen[x, y] = c;
            }
        }

        public Color GetPixel(int x, int y)
        {
            if (x < 0 || x >= 320 || y < 0 || y >= 200)
                return Color.Empty;

            return _Screen[x, y];
        }

        public void DrawVGA(int centerX, int centerY, byte[] vga)
        {
            DrawVGARotated(centerX, centerY, 0, vga);
        }

        public void DrawVGARotated(int centerX, int centerY, int angle, byte[] vga)
        {
            int width = vga[0] + 1;
            int height = vga[2] + 1;

            for (int x = -width / 2; x <= width / 2; x++)
            {
                for (int y = -height / 2; y <= height / 2; y++)
                {
                    byte c = vga[4 + x + width / 2 + (y + height / 2) * width];

                    int xr = centerX + (int)Math.Round(x * Globals.CosTable[angle] - y * Globals.SinTable[angle]);
                    int yr = centerY + (int)Math.Round(x * Globals.SinTable[angle] + y * Globals.CosTable[angle]);

                    PutPixel(xr, yr, GetDefaultPaletteColor(c));
                }
            }
            for (int x = centerX - width; x <= centerX + width; x++)
            {
                for (int y = centerY - height; y <= centerY + height; y++)
                {
                    if (GetPixel(x, y) == Color.SandyBrown)
                    {
                        for (int i = -1; i <= 1; i++)
                        {
                            for (int j = -1; j <= 1; j++)
                            {
                                if (GetPixel(x + i, y + j) == GetPixel(x - i, y - j))
                                {
                                    PutPixel(x, y, GetPixel(x + i, y + j));
                                }
                            }
                        }
                    }
                }
            }
        }

        public static Color GetDefaultPaletteColor(byte c)
        {
            if (c == 0)
                return Color.SandyBrown;

            if (c < 16)
            {
                return Color.FromArgb(
                    255 * (2 * ((c & 4) >> 2) + ((c & 8) >> 3)) / 3,
                    255 * (2 * ((c & 2) >> 1) + ((c & 8) >> 3)) / 3,
                    255 * (2 * (c & 1) + ((c & 8) >> 3)) / 3);
            }

            if (c < 32)
            {
                int gray = 255 * (c & 0xf) / 16;
                return Color.FromArgb(gray, gray, gray);
            }

            return Color.SandyBrown;
        }

        protected override void OnResize(EventArgs eventargs)
        {
            base.OnResize(eventargs);

            Invalidate();
        }

        public Color[,] Screen
        {
            get
            {
                return _Screen;
            }
        }
        public Color[,] Previous
        {
            get
            {
                return _Previous;
            }
        }

        public bool ShouldDrawScore
        {
            get;
            set;
        }

        public bool GameOver
        {
            get;
            set;
        }

        Color[,] _Screen = new Color[320, 200];
        Color[,] _Previous = new Color[320, 200];
        SolidBrush _Brush = new SolidBrush(Color.SandyBrown);
    }
}
