using _01.InitialSetup;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;

namespace _07.Print_All_Minion_Names
{
    class StartUp : ConnectionOptions
    {
        static void Main(string[] args)
        {
            string query = "SELECT Name FROM Minions";

            try
            {
                var minionsNames = new List<string>();
                connection.Open();
                using (connection)
                {
                    var command = new SqlCommand(query, connection);
                    using SqlDataReader reader = command.ExecuteReader();

                    while (reader.Read())
                    {
                        minionsNames.Add((string)reader[0]);
                    }
                }

                while (minionsNames.Count > 0)
                {
                    if (minionsNames.Count >= 2)
                    {
                        Console.WriteLine(minionsNames[0]);
                        Console.WriteLine(minionsNames[minionsNames.Count - 1]);

                        minionsNames.RemoveAt(0);
                        minionsNames.RemoveAt(minionsNames.Count - 1);
                    }

                    else if (minionsNames.Count == 1)
                    {
                        Console.WriteLine(minionsNames[0]);

                        minionsNames.RemoveAt(0);
                    }
                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
                throw;
            }
        }
    }
}
