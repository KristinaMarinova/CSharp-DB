using System;
using System.Data.SqlClient;

namespace _01.InitialSetup
{
    public class ConnectionOptions
    {
        public static string connectionString = "Server=.;Database=MinionsDB;Integrated Security=true";
        public static SqlConnection connection = new SqlConnection(String.Format(connectionString, "master"));
    }
}
