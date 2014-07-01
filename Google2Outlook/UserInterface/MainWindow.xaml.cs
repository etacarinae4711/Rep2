using System.ComponentModel;
using System.Diagnostics;
using System.Resources;
using System.Windows;
using System.Windows.Input;
using System.Windows.Navigation;
using Microsoft.Win32;

namespace Google2Outlook
{
    public partial class MainWindow
    {
        private static RoutedCommand _convert = new RoutedCommand();
        private static readonly ResourceManager _resManager = Properties.Resources.ResourceManager;
        private readonly BackgroundWorker _worker = new BackgroundWorker();

        public MainWindow()
        {
            InitializeComponent();
            _worker.DoWork += worker_DoWork;
            _worker.RunWorkerCompleted += worker_RunWorkerCompleted;
        }

        public static RoutedCommand Convert
        {
            get { return _convert; }
            set { _convert = value; }
        }

        private void Hyperlink_RequestNavigate(object sender, RequestNavigateEventArgs e)
        {
            Process.Start(new ProcessStartInfo(e.Uri.AbsoluteUri));
            e.Handled = true;
        }

        private void ExitButton_Click(object sender, RoutedEventArgs e)
        {
            Close();
        }

        private void HintButton_Click(object sender, RoutedEventArgs e)
        {
            new Hint(this).ShowDialog();
        }

        private void ConvertButton_Click(object sender, RoutedEventArgs e)
        {
            ReadFile();
        }

        private static void ReadFile()
        {
            var file = new OpenFileDialog
            {
                Filter = _resManager.GetString("MainWindow_Filter"),
                FilterIndex = 0,
                RestoreDirectory = true,
                Title = _resManager.GetString("MainWindow_OpenFile")
            };

            if (file.ShowDialog() == true)
            {
                Domain.Converter.ReadCsvValues(file.FileName);
                new DialogBox().ShowDialog();
            }
        }

        private void ConvertButton_DragOver(object sender, DragEventArgs e)
        {
            e.Effects = e.Data.GetDataPresent(DataFormats.FileDrop) ? DragDropEffects.All : DragDropEffects.None;
            e.Handled = false;
        }

        private void ConvertButton_Drop(object sender, DragEventArgs e)
        {
            if (!e.Data.GetDataPresent(DataFormats.FileDrop))
                return;
            var filePath = (string[]) e.Data.GetData(DataFormats.FileDrop);
            _worker.RunWorkerAsync(filePath[0]);
        }

        private static void worker_DoWork(object sender, DoWorkEventArgs e)
        {
            var filePath = e.Argument.ToString();
            Domain.Converter.ReadCsvValues(filePath);
        }

        private static void worker_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            new DialogBox().ShowDialog();
        }
    }
}