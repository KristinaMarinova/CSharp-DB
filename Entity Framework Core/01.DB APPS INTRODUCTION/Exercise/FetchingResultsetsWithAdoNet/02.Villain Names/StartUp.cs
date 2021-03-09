using _01.InitialSetup;
using System;
using System.Data.SqlClient;

namespace _02.Villain_Names
{
    class StartUp : ConnectionOptions
    {
        static void Main(string[] args)
        {
            connection.Open();

            using (connection)
            {
                var queryText = @"SELECT v.Name, COUNT(mv.VillainId) AS MinionsCount  
                                  FROM Villains AS v 
                                  JOIN MinionsVillains AS mv ON v.Id = mv.VillainId 
                                  GROUP BY v.Id, v.Name 
                                  HAVING COUNT(mv.VillainId) > 3 
                                  ORDER BY COUNT(mv.VillainId)";

                SqlCommand cmd = new SqlCommand(queryText, connection);

                var reader = cmd.ExecuteReader();

                using (reader)
                {
                    while (reader.Read())
                    {
                        Console.WriteLine($"{reader["Name"]} - {reader["MinionsCount"]}");
                    }
                }

            }
        }
    }
}
