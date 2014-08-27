using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace Domain
{
    public static class Converter
    {
        public static void ReadCsvValues(String sourcePath)
        {
            string tempPath = Path.GetTempFileName();
            const string delimiter = ",";
            var splitExpression = new Regex(@"(" + delimiter + @")(?=(?:[^""]|""[^""]*"")*$)");

            using (var writer = new StreamWriter(tempPath, false, Encoding.Default))
            using (var reader = new StreamReader(sourcePath, Encoding.Default))
            {
                int lineNumber = 0;
                string lineContent = reader.ReadLine();

                if (lineContent != null)
                {
                    IEnumerable<string> csvHeader = splitExpression.Split(lineContent).Where(s => s != delimiter);

                    foreach (string header in csvHeader)
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
    }
}