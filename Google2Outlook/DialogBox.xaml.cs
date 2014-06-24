using System.Windows;

namespace Google2Outlook
{
    public partial class DialogBox
    {
        public DialogBox()
        {
            InitializeComponent();
        }

        private void OkButton_Click(object sender, RoutedEventArgs e)
        {
            Close();
        }

        private void ExitButton_Click(object sender, RoutedEventArgs e)
        {
            Close();
        }
    }
}