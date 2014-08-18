using System;
using System.Collections.Generic;
using System.Text;

using System.Windows.Forms;

namespace tanks
{
    public class KeyMessageFilter : IMessageFilter
    {
        public bool this[Keys k]
        {
            get
            {
                bool pressed;

                if (_KeyTable.TryGetValue(k, out pressed))
                    return pressed;

                return false;
            }
        }

        const int WM_KEYDOWN = 0x0100;
        const int WM_KEYUP = 0x0101;

        public bool PreFilterMessage(ref Message m)
        {
            if (m.Msg == WM_KEYDOWN)
                _KeyTable[(Keys)m.WParam] = true;

            if (m.Msg == WM_KEYUP)
                _KeyTable[(Keys)m.WParam] = false;

            return false;
        }

        Dictionary<Keys, bool> _KeyTable = new Dictionary<Keys, bool>();
    }
}
