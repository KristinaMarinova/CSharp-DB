using _01.InitialSetup;
using System;
using System.Data.SqlClient;
using System.Linq;

namespace _08.Increase_Minion_Age
{
    class StartUp : ConnectionOptions
    {
        static void Main(string[] args)
        {
            string UpdateMinions = @"UPDATE Minions
                                     SET Name = UPPER(LEFT(Name, 1)) + SUBSTRING(Name, 2, LEN(Name)), Age += 1
                                     WHERE Id = @Id";

            string SelectFromMinions = "SELECT Name, Age FROM Minions";

            try
            {
                var inputIds = Console.ReadLine()
                    .Split(" ", StringSplitOptions.RemoveEmptyEntries)
                    .Select(int.Parse)
                    .ToList();

                connection.Open();
                using (connection)
                {

                    var command = new SqlCommand(UpdateMinions, connection);
                    foreach (var id in inputIds)
                    {
                        command.Parameters.AddWithValue("@Id", id);
                        command.ExecuteNonQuery();
                    }

                    command = new SqlCommand(SelectFromMinions, connection);
                    using SqlDataReader reader = command.ExecuteReader();

                    while (reader.Read())
                    {
                        var name = (string)reader[0];
                        var age = (int)reader[1];

                        Console.WriteLine($"{name} {age}");
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
