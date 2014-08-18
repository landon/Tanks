using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace tanks
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();

            _Timer.Interval = 250;
            _Timer.Tick += new EventHandler(_Timer_Tick);

            _Timer.Start();
        }

        void _Timer_Tick(object sender, EventArgs e)
        {
            _Mode13hPanel.Clear();
            _Mode13hPanel.DrawVGARotated(100, 100, r, Properties.Resources.T2);

            _Mode13hPanel.Invalidate();

            r++;

            r = r % 15;
        }

        Timer _Timer = new Timer();

        int r = 0;
    }
}
