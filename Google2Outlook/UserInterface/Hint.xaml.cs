using System.Windows;

namespace Google2Outlook
{
    /// <summary>
    ///     Interaktionslogik für Hint.xaml
    /// </summary>
    public partial class Hint : Window
    {
        public Hint(Window owner)
        {
            Owner = owner;
            InitializeComponent();
        }

        private void ExitButton_Click(object sender, RoutedEventArgs e)
        {
            Close();
        }
    }
}