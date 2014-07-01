using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Resources;
using Domain.Properties;

namespace Domain
{
    public class CsvPairs
    {
        private static readonly ResourceManager ResManager = Resources.ResourceManager;

        public static Dictionary<String, String> Fields = new Dictionary<string, string>
        {
            {"Account", L("CsvPairs_Account")},
            {"Anniversary", L("CsvPairs_Anniversary")},
            {"Assistant's Name", L("CsvPairs_AssistantsName")},
            {"Assistant's Phone", L("CsvPairs_AssistantsPhone")},
            {"Billing Information", L("CsvPairs_BillingInformation")},
            {"Birthday", L("CsvPairs_Birthday")},
            {"Business Address", L("CsvPairs_BusinessAddress")},
            {"Business Address PO Box", L("CsvPairs_BusinessAddressPOBox")},
            {"Business City", L("CsvPairs_BusinessCity")},
            {"Business Country", L("CsvPairs_BusinessCountry")},
            {"Business Fax", L("CsvPairs_BusinessFax")},
            {"Business Phone", L("CsvPairs_BusinessPhone")},
            {"Business Phone 2", L("CsvPairs_BusinessPhone2")},
            {"Business Postal Code", L("CsvPairs_BusinessPostalCode")},
            {"Business State", L("CsvPairs_BusinessState")},
            {"Business Street", L("CsvPairs_BusinessStreet")},
            {"Business Street 2", L("CsvPairs_BusinessStreet2")},
            {"Business Street 3", L("CsvPairs_BusinessStreet3")},
            {"Callback", L("CsvPairs_Callback")},
            {"Car Phone", L("CsvPairs_CarPhone")},
            {"Categories", L("CsvPairs_Categories")},
            {"Children", L("CsvPairs_Children")},
            {"Company", L("CsvPairs_Company")},
            {"Company Main Phone", L("CsvPairs_CompanyMainPhone")},
            {"Department", L("CsvPairs_Department")},
            {"Directory Server", L("CsvPairs_DirectoryServer")},
            {"E-mail 2 Address", L("CsvPairs_Email2Address")},
            {"E-mail 3 Address", L("CsvPairs_Email3Address")},
            {"E-mail Address", L("CsvPairs_EmailAddress")},
            {"First Name", L("CsvPairs_FirstName")},
            {"Gender", L("CsvPairs_Gender")},
            {"Hobby", L("CsvPairs_Hobby")},
            {"Home Address", L("CsvPairs_HomeAddress")},
            {"Home Address PO Box", L("CsvPairs_HomeAddressPOBox")},
            {"Home City", L("CsvPairs_HomeCity")},
            {"Home Country", L("CsvPairs_HomeCountry")},
            {"Home Fax", L("CsvPairs_HomeFax")},
            {"Home Phone", L("CsvPairs_HomePhone")},
            {"Home Phone 2", L("CsvPairs_HomePhone2")},
            {"Home Postal Code", L("CsvPairs_HomePostalCode")},
            {"Home State", L("CsvPairs_HomeState")},
            {"Home Street", L("CsvPairs_HomeStreet")},
            {"Home Street 2", L("CsvPairs_HomeStreet2")},
            {"Home Street 3", L("CsvPairs_HomeStreet3")},
            {"Initials", L("CsvPairs_Initials")},
            {"Internet Free Busy", L("CsvPairs_InternetFreeBusy")},
            {"ISDN", L("CsvPairs_ISDN")},
            {"Job Title", L("CsvPairs_JobTitle")},
            {"Keywords", L("CsvPairs_Keywords")},
            {"Language", L("CsvPairs_Language")},
            {"Last Name", L("CsvPairs_LastName")},
            {"Location", L("CsvPairs_Location")},
            {"Manager's Name", L("CsvPairs_ManagersName")},
            {"Middle Name", L("CsvPairs_MiddleName")},
            {"Mileage", L("CsvPairs_Mileage")},
            {"Mobile Phone", L("CsvPairs_MobilePhone")},
            {"Mobile Phone 2", L("CsvPairs_MobilePhone2")},
            {"Notes", L("CsvPairs_Notes")},
            {"Office Location", L("CsvPairs_OfficeLocation")},
            {"Organizational ID Number", L("CsvPairs_OrganizationalIDNumber")},
            {"Other Address", L("CsvPairs_OtherAddress")},
            {"Other Address PO Box", L("CsvPairs_OtherAddressPOBox")},
            {"Other City", L("CsvPairs_OtherCity")},
            {"Other Country", L("CsvPairs_OtherCountry")},
            {"Other Fax", L("CsvPairs_OtherFax")},
            {"Other Phone", L("CsvPairs_OtherPhone")},
            {"Other Postal Code", L("CsvPairs_OtherPostalCode")},
            {"Other State", L("CsvPairs_OtherState")},
            {"Other Street", L("CsvPairs_OtherStreet")},
            {"Other Street 2", L("CsvPairs_OtherStreet2")},
            {"Other Street 3", L("CsvPairs_OtherStreet3")},
            {"Pager", L("CsvPairs_Pager")},
            {"Primary Phone", L("CsvPairs_PrimaryPhone")},
            {"Priority", L("CsvPairs_Priority")},
            {"Private", L("CsvPairs_Private")},
            {"Profession", L("CsvPairs_Profession")},
            {"Radio Phone", L("CsvPairs_RadioPhone")},
            {"Referred By", L("CsvPairs_ReferredBy")},
            {"Sensitivity", L("CsvPairs_Sensitivity")},
            {"Spouse", L("CsvPairs_Spouse")},
            {"Suffix", L("CsvPairs_Suffix")},
            {"Telex", L("CsvPairs_Telex")},
            {"Title", L("CsvPairs_Title")},
            {"TTY/TDD Phone", L("CsvPairs_TTY_TDDPhone")},
            {"User 1", L("CsvPairs_User1")},
            {"User 2", L("CsvPairs_User2")},
            {"User 3", L("CsvPairs_User3")},
            {"User 4", L("CsvPairs_User4")},
            {"Web Page", L("CsvPairs_WebPage")}
        };

        /// <summary>
        ///     L(ocalize) - Looks the value to the index up
        /// </summary>
        /// <param name="index">Which field should be localized</param>
        /// <returns>The localized value</returns>
        private static string L(string index)
        {
            var retVal = ResManager.GetString(index);
            if (!string.IsNullOrEmpty(retVal))
            {
                return retVal;
            }
            var errorMessage = string.Format("Für das Feld {0} konnte keine Übersetzung gefunden werden", index);
            Trace.TraceError(errorMessage);
            return "ErrorField";
        }
    }
}