using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace Domain
{
    public class Converter
    {
        public static void ReadCsvValues(String sourcePath)
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
                    var csvHeader = splitExpression.Split(lineContent).Where(s => s != delimiter);

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
        }

        public static void WriteValue(int lineNumber, StreamWriter writer, string header)
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
    }
}