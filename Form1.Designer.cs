namespace tanks
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this._Mode13hPanel = new tanks.Mode13hPanel();
            this.SuspendLayout();
            // 
            // _Mode13hPanel
            // 
            this._Mode13hPanel.Dock = System.Windows.Forms.DockStyle.Fill;
            this._Mode13hPanel.Location = new System.Drawing.Point(0, 0);
            this._Mode13hPanel.Name = "_Mode13hPanel";
            this._Mode13hPanel.Size = new System.Drawing.Size(875, 575);
            this._Mode13hPanel.TabIndex = 0;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.SandyBrown;
            this.ClientSize = new System.Drawing.Size(875, 575);
            this.Controls.Add(this._Mode13hPanel);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.SizableToolWindow;
            this.Name = "Form1";
            this.ResumeLayout(false);

        }

        #endregion

        private Mode13hPanel _Mode13hPanel;
    }
}

