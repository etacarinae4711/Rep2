using System;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows;
using System.Windows.Navigation;
using Microsoft.Win32;

namespace Google2Outlook
{
    public partial class MainWindow
    {
        public MainWindow()
        {
            InitializeComponent();
        }

        //private void PatchButton_Click(object sender, RoutedEventArgs e)
        //{
        //    ReadFile();
        //}

        private static void ReadCsvValues(String sourcePath)
        {
            var tempPath = Path.GetTempFileName();
            const string delimiter = ",";
            var splitExpression = new Regex(@"(" + delimiter + @")(?=(?:[^""]|""[^""]*"")*$)");

            using (var writer = new StreamWriter(tempPath, false, Encoding.Default))
            using (var reader = new StreamReader(sourcePath, Encoding.Default))
            {
                var lineNumber = 0;
                var lineContent = reader.ReadLine();

                if (lineContent != null)
                {
                    var csvHeader = splitExpression.Split(lineContent).Where(s => s != delimiter).ToArray();

                    foreach (var header in csvHeader)
                    {
                        WriteValue(lineNumber, writer,
                            CsvPairs.Fields.ContainsKey(header) ? CsvPairs.Fields[header] : header);
                        lineNumber++;
                    }

                    writer.WriteLine();

                    while ((lineContent = reader.ReadLine()) != null)
                    {
                        writer.WriteLine(lineContent);
                    }
                }
            }
            File.Delete(sourcePath);
            File.Move(tempPath, sourcePath);

            new DialogBox().ShowDialog();
        }

        private static void WriteValue(int lineNumber, StreamWriter writer, string header)
        {
            if (lineNumber == 0)
            {
                writer.Write(header);
            }
            else
            {
                writer.Write("," + header);
            }
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

        private void HintUrl_Click(object sender, RoutedEventArgs e)
        {
            new Hint(this).ShowDialog();
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
                Filter = "Google CSV Datei (*.csv)|*.csv;",
                FilterIndex = 0,
                RestoreDirectory = true,
                Title = "CSV Datei öffnnen ..."
            };

            if (file.ShowDialog() == true)
            {
                ReadCsvValues(file.FileName);
            }
        }

        private void ConvertButton_DragOver(object sender, DragEventArgs e)
        {
            e.Effects = e.Data.GetDataPresent(DataFormats.FileDrop) ? DragDropEffects.All : DragDropEffects.None;
            e.Handled = false;
        }

        private void ConvertButton_Drop(object sender, DragEventArgs e)
        {
            if (!e.Data.GetDataPresent(DataFormats.FileDrop)) return;
            var filePath = (string[])e.Data.GetData(DataFormats.FileDrop);
            ReadCsvValues(filePath[0]);
        }
    }
}