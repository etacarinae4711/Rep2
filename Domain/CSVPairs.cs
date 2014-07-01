using System;
using System.Collections.Generic;
using System.Resources;

namespace Converter
{
    public class CsvPairs
    {
        private static readonly ResourceManager ResManager = Domain.Properties.Resources.ResourceManager;
        /// <summary>
        /// L(ocalize) - Looks the value to the index up
        /// </summary>
        /// <param name="index">Which field should be localized</param>
        /// <returns>The localized value</returns>
        private static string L(string index)
        {
            return ResManager.GetString(index);
        }
        public static Dictionary<String, String> Fields = new Dictionary<string, string>
        {
            {"First Name", L("CsvPairs_FirstName")},
            {"Middle Name", L("Weitere Vornamen")},
            {"Last Name", L("Nachname")},
            {"Title", L("Anrede")},
            {"Suffix", L("Suffix")},
            {"Initials", L("Initialen")},
            {"Web Page", L("Webseite")},
            {"Gender", L("Geschlecht")},
            {"Birthday", L("Geburtstag")},
            {"Anniversary", L("Jahrestagv")},
            {"Location", L("Location")}, //Kein Feld in Oulook vorhanden
            {"Language", L("Sprache")},
            {"Internet Free Busy", L("Internet Frei/Gebucht")},
            {"Notes", L("Notizen")},
            {"E-mail Address", L("E-Mail-Adresse")},
            {"E-mail 2 Address", L("E-Mail 2: Adresse")},
            {"E-mail 3 Address", L("E-Mail 3: Adresse")},
            {"Primary Phone", L("Haupttelefon")},
            {"Home Phone", L("Telefon (privat)")},
            {"Home Phone 2", L("Telefon (privat 2)")},
            {"Mobile Phone", L("Mobiltelefon")},
            {"Mobile Phone 2", L("Mobiltelefon 2")},
            {"Pager", L("Pager")},
            {"Home Fax", L("Fax privat")},
            {"Home Address", L("Ort")},
            {"Home Street", L("Straße privat")},
            {"Home Street 2", L("Straße privat 2")},
            {"Home Street 3", L("Straße privat 3")},
            {"Home Address PO Box", L("Postfach privat")},
            {"Home City", L("Ort privat")},
            {"Home State", L("Bundesland/Kanton privat")},
            {"Home Postal Code", L("Postleitzahl privat")},
            {"Home Country", L("Land/Region privat")},
            {"Spouse", L("Partner")},
            {"Children", L("Kinder")},
            {"Manager's Name", L("Name des/r Vorgesetzten")},
            {"Assistant's Name", L("Assistent(in)")},
            {"Referred By", L("Empfohlen von")},
            {"Company Main Phone", L("Telefon Firma")},
            {"Business Phone", L("Telefon geschäftlich")},
            {"Business Phone 2", L("Telefon geschäftlich 2")},
            {"Business Fax", L("Fax geschäftlich")},
            {"Assistant's Phone", L("Telefon Assistent")},
            {"Company", L("Firma")},
            {"Job Title", L("Position")},
            {"Department", L("Abteilung")},
            {"Office Location", L("Adresse geschäftlich")},
            {"Organizational ID Number", L("Organisationsnr.")},
            {"Profession", L("Beruf")},
            {"Account", L("Konto")},
            {"Business Address", L("Büro")},
            {"Business Street", L("Straße geschäftlich")},
            {"Business Street 2", L("Straße geschäftlich 2")},
            {"Business Street 3", L("Straße geschäftlich 3")},
            {"Business Address PO Box", L("Postfach geschäftlich")},
            {"Business City", L("Ort geschäftlich")},
            {"Business State", L("Region geschäftlich")},
            {"Business Postal Code", L("Postleitzahl geschäftlich")},
            {"Business Country", L("Land/Region geschäftlich")},
            {"Other Phone", L("Weiteres Telefon")},
            {"Other Fax", L("Weiteres Fax")},
            {"Other Address", L("Weitere Adresse")},
            {"Other Street", L("Weitere Straße")},
            {"Other Street 2", L("Weitere Straße 2")},
            {"Other Street 3", L("Weitere Straße 3")},
            {"Other Address PO Box", L("Weiteres Postfach")},
            {"Other City", L("Weiterer Ort")},
            {"Other State", L("Weiteres/r Bundesland/Kanton")},
            {"Other Postal Code", L("Weitere Postleitzahl")},
            {"Other Country", L("Weiteres/e Land/Region")},
            {"Callback", L("Rückmeldung")},
            {"Car Phone", L("Autotelefon")},
            {"Radio Phone", L("Funkruf")},
            {"ISDN", L("ISDN")},
            {"TTY/TDD Phone", L("Telefon für Hörbehinderte")},
            {"Telex", L("Telex")},
            {"User 1", L("Benutzer 1")},
            {"User 2", L("Benutzer 2")},
            {"User 3", L("Benutzer 3")},
            {"User 4", L("Benutzer 4")},
            {"Keywords", L("Stichwörter")},
            {"Mileage", L("Reisekilometer")},
            {"Hobby", L("Hobby")},
            {"Billing Information", L("Abrechnungsinformation")},
            {"Directory Server", L("Verzeichnisserver")},
            {"Sensitivity", L("Vertraulichkeit")},
            {"Priority", L("Priorität")},
            {"Private", L("Privat")},
            {"Categories", L("Kategorien")}
        };
    }
}