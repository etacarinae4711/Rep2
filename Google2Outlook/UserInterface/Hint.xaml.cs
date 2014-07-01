using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;

namespace Google2Outlook
{
    /// <summary>
    /// Interaktionslogik für Hint.xaml
    /// </summary>
    public partial class Hint : Window
    {
        public Hint(Window owner)
        {
            this.Owner = owner;
            InitializeComponent();
        }

        private void ExitButton_Click(object sender, RoutedEventArgs e)
        {
            Close();
        }
    }
}
