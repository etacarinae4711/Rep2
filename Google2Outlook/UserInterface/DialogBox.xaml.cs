using System.Windows;

namespace Google2Outlook
{
    public partial class DialogBox
    {
        public DialogBox()
        {
            InitializeComponent();
        }

        private void ExitButton_Click(object sender, RoutedEventArgs e)
        {
            Close();
        }
    }
}