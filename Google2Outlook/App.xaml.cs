using System.Globalization;
using System.Threading;
using System.Windows;


namespace Google2Outlook
{
    /// <summary>
    /// Interaktionslogik für "App.xaml"
    /// </summary>
    public partial class App : Application
    {

        public App()
        {
            const string culture = "de-DE";
            System.Threading.Thread.CurrentThread.CurrentCulture = new CultureInfo(culture);
            System.Threading.Thread.CurrentThread.CurrentUICulture = new CultureInfo(culture);
            Google2Outlook.Properties.Resources.Culture = new CultureInfo(culture);
        }
      
    }
}
