using _01.InitialSetup;
using System;
using System.Data.SqlClient;
using System.Linq;

namespace _04.Add_Minion
{
    class StartUp : ConnectionOptions
    {
        static void Main()
        {
            string findTownId = "SELECT Id FROM Towns WHERE Name = @townName";
            string insertIntoTowns = "INSERT INTO Towns(Name) VALUES(@townName)";

            string findMinionId = "SELECT Id FROM Minions WHERE Name = @Name";
            string insertIntoMinions = "INSERT INTO Minions(Name, Age, TownId) VALUES(@nam, @age, @townId)";

            string findVillainId = "SELECT Id FROM Villains WHERE Name = @Name";
            string insertIntoVillains = "INSERT INTO Villains(Name, EvilnessFactorId)  VALUES(@villainName, 4)";

            string insertIntoMinionsVillains = "INSERT INTO MinionsVillains(MinionId, VillainId) VALUES(@villainId, @minionId)";

            try
            {
                var minionInfo = Console.ReadLine()?.Split(" ", StringSplitOptions.RemoveEmptyEntries).Skip(1).ToList();
                var minionName = minionInfo?[0];
                var minionAge = int.Parse(minionInfo?[1] ?? throw new InvalidOperationException());
                var townName = minionInfo?[2];

                var villainInfo = Console.ReadLine()
                    ?.Split(" ", StringSplitOptions.RemoveEmptyEntries)
                    .Skip(1)
                    .ToList();

                var villainName = villainInfo?[0];

                var townId = 0;
                var minionId = 0;
                var villainId = 0;

                connection.Open();

                using (connection)
                {
                    var command = new SqlCommand(findTownId, connection);
                    command.Parameters.AddWithValue("@townName", townName);

                    if (command.ExecuteScalar() != null)
                    {
                        townId = (int)command.ExecuteScalar();
                    }

                    if (townId == 0)
                    {
                        command = new SqlCommand(insertIntoTowns, connection);
                        command.Parameters.AddWithValue("@townName", townName);
                        command.ExecuteNonQuery();

                        command = new SqlCommand(findTownId, connection);
                        command.Parameters.AddWithValue("@townName", townName);

                        townId = (int)command.ExecuteScalar();

                        Console.WriteLine($"Town {townName} was added to the database.");
                    }

                    command = new SqlCommand(findMinionId, connection);
                    command.Parameters.AddWithValue("@Name", minionName);

                    if (command.ExecuteScalar() != null)
                    {
                        minionId = (int)command.ExecuteScalar();
                    }

                    if (minionId == 0)
                    {
                        command = new SqlCommand(insertIntoMinions, connection);
                        command.Parameters.AddWithValue("@nam", minionName);
                        command.Parameters.AddWithValue("@age", minionAge);
                        command.Parameters.AddWithValue("@townId", townId);

                        command.ExecuteNonQuery();

                        command = new SqlCommand(findMinionId, connection);
                        command.Parameters.AddWithValue("@Name", minionName);

                        minionId = (int)command.ExecuteScalar();
                    }

                    command = new SqlCommand(findVillainId, connection);
                    command.Parameters.AddWithValue("@Name", villainName);

                    if (command.ExecuteScalar() != null)
                    {
                        villainId = (int)command.ExecuteScalar();
                    }

                    if (villainId == 0)
                    {
                        command = new SqlCommand(insertIntoVillains, connection);
                        command.Parameters.AddWithValue("@villainName", villainName);
                        command.ExecuteNonQuery();

                        command = new SqlCommand(findVillainId, connection);
                        command.Parameters.AddWithValue("@Name", villainName);

                        villainId = (int)command.ExecuteScalar();

                        Console.WriteLine($"Villain {villainName} was added to the database.");
                    }

                    command = new SqlCommand(insertIntoMinionsVillains, connection);
                    command.Parameters.AddWithValue("@villainId", villainId);
                    command.Parameters.AddWithValue("@minionId", minionId);

                    Console.WriteLine($"Successfully added {minionName} to be minion of {villainName}.");
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
