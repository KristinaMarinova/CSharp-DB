using _01.InitialSetup;
using System;
using System.Data.SqlClient;

namespace _03.MinionNames
{
    class StartUp : ConnectionOptions
    {
        static void Main(string[] args)
        {
            string vilianName = "SELECT Name FROM Villains WHERE Id = @Id";
            string minionsNames = @"SELECT ROW_NUMBER() OVER (ORDER BY m.Name) as RowNum,
                                    m.Name, 
                                    m.Age
                                    FROM MinionsVillains AS mv
                                    JOIN Minions As m ON mv.MinionId = m.Id
                                    WHERE mv.VillainId = @Id
                                    ORDER BY m.Name";


            int id = int.Parse(Console.ReadLine() ?? throw new InvalidOperationException());

            connection.Open();

            using (connection)
            {
                var command = new SqlCommand(vilianName, connection);
                command.Parameters.AddWithValue("@Id", id);
                string villainName = (string)command.ExecuteScalar();

                if (villainName == null)
                {
                    Console.WriteLine($"No villain with ID {id} exists in the database.");
                    return;
                }

                Console.WriteLine($"Villain: {villainName}");

                SqlCommand commandMinions = new SqlCommand(minionsNames, connection);

                commandMinions.Parameters.AddWithValue("@Id", id);

                SqlDataReader reader = commandMinions.ExecuteReader();

                if (!reader.HasRows)
                {
                    Console.WriteLine("(no minions)");
                    return;
                }

                while (reader.Read())
                {
                    long row = (long)reader[0];
                    string name = (string)reader[1];
                    int age = (int)reader[2];

                    Console.WriteLine($"{row}. {name} {age}");
                }
            }
        }
    }
}
