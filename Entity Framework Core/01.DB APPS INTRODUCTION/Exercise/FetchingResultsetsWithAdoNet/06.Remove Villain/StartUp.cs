using _01.InitialSetup;
using System;
using System.Data.SqlClient;

namespace _06.Remove_Villain
{
    class StartUp : ConnectionOptions
    {
        private static SqlTransaction transaction;
        static void Main(string[] args)
        {
            int id = int.Parse(Console.ReadLine());

            connection.Open();

            using (connection)
            {
                transaction = connection.BeginTransaction();

                try
                {
                    SqlCommand cmd = new SqlCommand();
                    cmd.Connection = connection;
                    cmd.Transaction = transaction;
                    cmd.CommandText = "SELECT Name FROM Villains WHERE Id = @villainId";
                    cmd.Parameters.AddWithValue("@villainId", id);

                    object value = cmd.ExecuteScalar();

                    if (value == null)
                    {
                        throw new ArgumentException("No such villian was found.");
                    }

                    string villianName = (string)value;

                    cmd.CommandText = @"DELETE FROM MinionsVillains 
                                        WHERE VillainId = @villainId";

                    int minionsDeleted = cmd.ExecuteNonQuery();

                    cmd.CommandText = @"DELETE FROM Villains 
                                        WHERE Id = @villainId";

                    cmd.ExecuteNonQuery();

                    transaction.Commit();

                    Console.WriteLine($"{villianName} was deleted.");
                    Console.WriteLine($"{minionsDeleted} minions were released.");

                }
                catch (ArgumentException ex)
                {
                    try
                    {
                        Console.WriteLine(ex.Message);
                        transaction.Rollback();
                    }
                    catch (Exception e)
                    {
                        Console.WriteLine(e.Message);
                    }
                }
                catch (Exception e)
                {
                    try
                    {
                        Console.WriteLine(e.Message);
                        transaction.Rollback();
                    }
                    catch (Exception re)
                    {
                        Console.WriteLine(re.Message);
                    }
                }
            }
        }
    }
}
