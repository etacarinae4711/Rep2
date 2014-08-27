using System.Windows;

namespace Google2Outlook
{
    public static class CommandRepository
    {
        public static void CloseCurrentWindow(object sender, RoutedEventArgs e)
        {
            Application.Current.MainWindow.Close();
        }
    }
}