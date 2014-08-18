using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace tanks
{
    public partial class MainForm : Form
    {
        public MainForm()
        {
            InitializeComponent();

            _UpdateTimer.Interval = 100;
            _UpdateTimer.Tick += new EventHandler(_UpdateTimer_Tick);
            _UpdateTimer.Start();

            NewGame(Properties.Resources.map1);
        }

        int _TickTock = 0;
        void _UpdateTimer_Tick(object sender, EventArgs e)
        {
            if (_FinishedRound)
            {
                _Mode13hPanel.ShouldDrawScore = true;
                _FinishedRound = false;

                if (Tank.RedScore >= Globals.WinningScore || Tank.BlueScore >= Globals.WinningScore)
                {
                    _Mode13hPanel.GameOver = true;
                }
                else
                {
                    NewRound();
                }
            }
            else if (_Mode13hPanel.ShouldDrawScore)
            {
                _TickTock++;

                if (_TickTock >= 20 || _Mode13hPanel.GameOver)
                {
                    _Mode13hPanel.ShouldDrawScore = false;
                    _Mode13hPanel.Invalidate();

                    _TickTock = 0;
                }
            }

        }

        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            Application.AddMessageFilter(_Keys);
        }

        void newGameToolStripMenuItem_Click(object sender, EventArgs e)
        {
            NewGame(Properties.Resources.map1);
        }

        void instructionsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            using (Form f = new Form())
            {
                f.FormBorderStyle = FormBorderStyle.FixedToolWindow;
                f.AutoSize = true;
                f.AutoSizeMode = AutoSizeMode.GrowAndShrink;

                f.Location = Location;

                RichTextBox rtb = new RichTextBox();
                rtb.Text = Properties.Resources.Help;
                rtb.ReadOnly = true;
                rtb.Width = 200;
                rtb.Height = 250;
                rtb.BackColor = Color.FromArgb(0xf7, 0xf7, 0xf7);

                f.Controls.Add(rtb);

                f.ShowDialog();
            }
        }

        void StopRound()
        {
            _Done = true;
        }

        void NewGame(string map)
        {
            StopRound();

            if (_Thread != null)
                _Thread.Abort();
            LoadMap(map);
            Mode13hPanel.DrawMap(_Map, _Background);
            Mode13hPanel.FlipScreen(_Background, _Mode13hPanel.Screen);
            _Mode13hPanel.GameOver = false;
         
            Tank.RedScore = 0;
            Tank.BlueScore = 0;

            NewRound();
        }

        void NewRound()
        {
            StopRound();
            Mode13hPanel.Clear(_Mode13hPanel.Screen);
            _Mode13hPanel.Invalidate();

            Tank.Red = new Tank();
            Tank.Red.IsAlive = true;
            Tank.Red.VGA = Properties.Resources.T1;
            Tank.Red.Explosion[0] = Properties.Resources.RF1;
            Tank.Red.Explosion[1] = Properties.Resources.RF2;
            Tank.Red.Explosion[2] = Properties.Resources.RF3;
            Tank.Red.X = 270;
            Tank.Red.Y = 175;
            Tank.Red.Angle = 12;
            Tank.Red.Speed = 2;

            Tank.Blue = new Tank();
            Tank.Blue.IsAlive = true;
            Tank.Blue.VGA = Properties.Resources.T2;
            Tank.Blue.Explosion[0] = Properties.Resources.BF1;
            Tank.Blue.Explosion[1] = Properties.Resources.BF2;
            Tank.Blue.Explosion[2] = Properties.Resources.BF3;
            Tank.Blue.X = 60;
            Tank.Blue.Y = 20;
            Tank.Blue.Angle = 4;
            Tank.Blue.Speed = 2;

            _Thread = new System.Threading.Thread(GameLoop);
            _Thread.IsBackground = true;
            _Thread.Start();
        }

        void LoadMap(string map)
        {
            try
            {
                string[] lines = map.Split(new string[] { Environment.NewLine}, StringSplitOptions.RemoveEmptyEntries);

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

                        _Map[i, j] = c;

                        i++;

                        if (i >= 40)
                            break;
                    }

                    j++;
                    if (j >= 25)
                        break;
                }
            }
            catch(Exception ex)
            {
                // Bad map.
            }
        }

        void GameLoop()
        {
            const int ExplodeDelay = 50;

            _FinishedRound = false;
            _Done = false;
            int delay = Globals.GameLoopTick_ms;
            while (!_Done)
            {
                CheckKeys();
                Tank.BulletCheckResults result = Tank.Red.CheckBullets(_Map);
                result |= Tank.Blue.CheckBullets(_Map);

                if ((result & Tank.BulletCheckResults.RedDied) != 0)
                {
                    delay = ExplodeDelay;
                    Tank.Red.Explode();
                }
                if ((result & Tank.BulletCheckResults.BlueDied) != 0)
                {
                    delay = ExplodeDelay;
                    Tank.Blue.Explode();
                }

                Mode13hPanel.FlipScreen(_Background, _Mode13hPanel.Screen);
                Tank.Red.Draw(_Mode13hPanel);
                Tank.Blue.Draw(_Mode13hPanel);

                _Mode13hPanel.DoPaint();

                if ((Tank.Red.IsExploding || Tank.Blue.IsExploding) &&
                    Tank.Red.DoneExploding && Tank.Blue.DoneExploding)
                {
                    if (Tank.Blue.IsExploding)
                        Tank.RedScore++;
                    if (Tank.Red.IsExploding)
                        Tank.BlueScore++;

                    _FinishedRound = true;
                    return;
                }

                if (!_Done)
                    System.Threading.Thread.Sleep(delay);
            }
        }

        protected override void OnClosing(CancelEventArgs e)
        {
            _Done = true;
            base.OnClosing(e);
        }

        #region Keys

        const int AngleChunk = 5;
        const int GoChunk = 1;

        int _RedAngleCounter = 0;
        int _BlueAngleCounter = 0;
        int _RedGoCounter = 0;
        int _BlueGoCounter = 0;
        bool _RedNotFiring = true;
        bool _BlueNotFiring = true;
        void CheckKeys()
        {
            if (_Keys[Keys.Up])
            {
                _RedAngleCounter++;

                if (_RedAngleCounter > AngleChunk)
                {
                    _RedAngleCounter = 0;

                    Tank.Red.Up();
                }
            }

            if (_Keys[Keys.Down])
            {
                _RedAngleCounter++;

                if (_RedAngleCounter > AngleChunk)
                {
                    _RedAngleCounter = 0;

                    Tank.Red.Down();
                }
            }

            if (_Keys[Keys.Left])
            {
                _RedAngleCounter++;

                if (_RedAngleCounter > AngleChunk)
                {
                    _RedAngleCounter = 0;

                    Tank.Red.Left();
                }
            }

            if (_Keys[Keys.Right])
            {
                _RedAngleCounter++;

                if (_RedAngleCounter > AngleChunk)
                {
                    _RedAngleCounter = 0;

                    Tank.Red.Right();
                }
            }

            if (_Keys[Keys.OemQuotes])
            {
                _RedGoCounter++;

                if (_RedGoCounter > GoChunk)
                {
                    _RedGoCounter = 0;

                    Tank.Red.Go();
                }
            }

            Tank.Red.CheckCollisions(_Map);

            if (!_Keys[Keys.Enter])
                _RedNotFiring = true;
            else
            {
                if (_RedNotFiring)
                {
                    Tank.Red.Fire();
                }

                _RedNotFiring = false;
            }

            if (_Keys[Keys.E])
            {
                _BlueAngleCounter++;

                if (_BlueAngleCounter > AngleChunk)
                {
                    _BlueAngleCounter = 0;

                    Tank.Blue.Up();
                }
            }

            if (_Keys[Keys.D])
            {
                _BlueAngleCounter++;

                if (_BlueAngleCounter > AngleChunk)
                {
                    _BlueAngleCounter = 0;

                    Tank.Blue.Down();
                }
            }

            if (_Keys[Keys.S])
            {
                _BlueAngleCounter++;

                if (_BlueAngleCounter > AngleChunk)
                {
                    _BlueAngleCounter = 0;

                    Tank.Blue.Left();
                }
            }

            if (_Keys[Keys.F])
            {
                _BlueAngleCounter++;

                if (_BlueAngleCounter > AngleChunk)
                {
                    _BlueAngleCounter = 0;

                    Tank.Blue.Right();
                }
            }

            if (_Keys[Keys.Oemtilde])
            {
                _BlueGoCounter++;

                if (_BlueGoCounter > GoChunk)
                {
                    _BlueGoCounter = 0;

                    Tank.Blue.Go();
                }
            }

            Tank.Blue.CheckCollisions(_Map);


            if (!_Keys[Keys.D1])
                _BlueNotFiring = true;
            else
            {
                if (_BlueNotFiring)
                {
                    Tank.Blue.Fire();
                }

                _BlueNotFiring = false;
            }
        }

        #endregion

        Cell[,] _Map = new Cell[40, 25];
        Color[,] _Background = new Color[320, 200];
        Timer _UpdateTimer = new Timer();

        KeyMessageFilter _Keys = new KeyMessageFilter();

        bool _Done = false;
        bool _FinishedRound = false;

        System.Threading.Thread _Thread;
    }
}
