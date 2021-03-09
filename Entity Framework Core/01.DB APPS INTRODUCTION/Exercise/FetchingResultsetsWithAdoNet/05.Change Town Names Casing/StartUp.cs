using _01.InitialSetup;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;

namespace _05.Change_Town_Names_Casing
{
    class StartUp : ConnectionOptions
    {
        static void Main(string[] args)
        {
            string findCountryId = "SELECT c.Id FROM Countries AS c WHERE c.Name = @countryName";

            string updateTowns = @"UPDATE Towns 
                                   SET Name = UPPER(Name)
                                   WHERE CountryCode = (
                                   SELECT c.Id FROM Countries AS c 
                                    WHERE c.Name = @countryName)";

            string updatedTowns = @"SELECT t.Name 
                                    FROM Towns as t
                                    JOIN Countries AS c ON c.Id = t.CountryCode
                                    WHERE c.Name = @countryName";

            try
            {
                var countryName = Console.ReadLine();
                var countryId = 0;

                connection.Open();
                using (connection)
                {
                    var command = new SqlCommand(findCountryId, connection);
                    command.Parameters.AddWithValue("@countryName", countryName);

                    if (command.ExecuteScalar() != null)
                    {
                        countryId = (int)command.ExecuteScalar();
                    }

                    if (countryId == 0)
                    {
                        Console.WriteLine("No town names were affected.");
                        Environment.Exit(0);
                    }


                    command = new SqlCommand(updateTowns, connection);
                    command.Parameters.AddWithValue("@countryName", countryName);
                    var townsAffected = command.ExecuteNonQuery();

                    if (townsAffected == 0)
                    {
                        Console.WriteLine("No town names were affected.");
                        Environment.Exit(0);
                    }

                    Console.WriteLine($"{townsAffected} town names were affected.");

                    var commandFinal = new SqlCommand(updatedTowns, connection);
                    commandFinal.Parameters.AddWithValue("@countryName", countryName);
                    var updatedTownsList = new List<string>();

                    using SqlDataReader reader = commandFinal.ExecuteReader();
                    while (reader.Read())
                    {
                        updatedTownsList.Add((string)reader[0]);
                    }

                    Console.Write("[");
                    Console.Write(string.Join(", ", updatedTownsList));
                    Console.WriteLine("]");
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