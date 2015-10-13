using ServiceBroker;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;

namespace ConsoleQueueReader
{
    class Program
    {
        internal static string ConnectionString = @"Data Source=localhost\sqlexpress;Initial Catalog=UmbracoServiceBroker;Integrated Security=True;";
        
        /// <summary>
        /// 
        /// </summary>
        /// <param name="args"></param>
        static void Main(string[] args)
        {
            var conn = new SqlConnection(ConnectionString);
            if (conn.State != System.Data.ConnectionState.Open)
            {
                conn.Open();
            }

            bool running = true;
            while (running)
            {
                ProcessContentQueue(conn);
                ProcessMemberQueue(conn);
                ProcessMediaQueue(conn);
            }

            conn.Close();

            Console.WriteLine("Hit enter to exit.");
            Console.ReadLine();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="conn"></param>
        private static void ProcessMediaQueue(SqlConnection conn)
        {
            Console.WriteLine("Checking Media Queue...");
            SqlTransaction tran = conn.BeginTransaction();

            var queue = new MediaQueue(conn);
            SqlCommand command = queue.CreateReadCommand(tran);

            int rows = command.ExecuteNonQuery();
            if (rows > 0)
            {
                var bodyXml = (System.Data.SqlTypes.SqlXml)command.Parameters["@message_body"].SqlValue;
                if (!bodyXml.IsNull)
                {
                    XElement messageBodyXml;
                    string resource;
                    string messageType = (string)command.Parameters["@message_type"].Value;
                    Console.WriteLine(" -> Message: [" + messageType + "]");
                    switch (messageType)
                    {
                        case "//Media/Cdn/SetInvalidationMessage":
                            messageBodyXml = XElement.Parse(bodyXml.Value);
                            resource = messageBodyXml.Elements().Where(p => p.Name == "resource").First().Value;

                            /* Invoke CDN API to invalidate resource. */
                            Console.WriteLine("     -> Resource: {0}", resource);
                            tran.Commit();
                            break;

                        case "//Media/Cdn/SetPolicyMessage":
                            messageBodyXml = XElement.Parse(bodyXml.Value);
                            resource = messageBodyXml.Elements().Where(p => p.Name == "resource").First().Value;

                            /* Invoke CDN API to set policy on a resource. */
                            Console.WriteLine("     -> Resource: {0}", resource);
                            tran.Commit();
                            break;

                        default:
                            tran.Rollback();
                            throw new InvalidOperationException("Unknown message type " + messageType);
                    }
                }
            }
            else
            {
                tran.Rollback();
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="conn"></param>
        private static void ProcessMemberQueue(SqlConnection conn)
        {
            Console.WriteLine("Checking Member Queue...");
            SqlTransaction tran = conn.BeginTransaction();
            
            var queue = new MemberQueue(conn);
            SqlCommand command = queue.CreateReadCommand(tran);

            int rows = command.ExecuteNonQuery();
            if (rows > 0)
            {
                var bodyXml = (System.Data.SqlTypes.SqlXml)command.Parameters["@message_body"].SqlValue;
                if (!bodyXml.IsNull)
                {
                    string messageType = (string)command.Parameters["@message_type"].Value;
                    Console.WriteLine(" -> Message: [" + messageType + "]");
                    switch (messageType)
                    {
                        case "//Member/Email/WelcomePackMessage":
                            XElement messageBodyXml = XElement.Parse(bodyXml.Value);
                            string name = messageBodyXml.Elements().Where(p => p.Name == "name").First().Value;
                            string email = messageBodyXml.Elements().Where(p => p.Name == "email").First().Value;

                            /* Invoke CRM API using name & email to request enrolemant in welcome pack workflow. */
                            Console.WriteLine("     -> Name: {0}, Email: {1}", name, email);
                            tran.Commit();
                            break;

                        default:
                            tran.Rollback();
                            throw new InvalidOperationException("Unknown message type " + messageType);
                    }
                }
            } else
            {
                tran.Rollback();
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="conn"></param>
        private static void ProcessContentQueue(SqlConnection conn)
        {
            Console.WriteLine("Checking Content Queue...");
            SqlTransaction tran = conn.BeginTransaction();

            var queue = new ContentQueue(conn);
            SqlCommand command = queue.CreateReadCommand(tran);

            int rows = command.ExecuteNonQuery();
            if (rows > 0)
            {
                var bodyXml = (System.Data.SqlTypes.SqlXml)command.Parameters["@message_body"].SqlValue;
                if (!bodyXml.IsNull)
                {
                    string messageType = (string)command.Parameters["@message_type"].Value;
                    Console.WriteLine(" -> Message: [" + messageType + "]");
                    switch (messageType)
                    {
                        case "//Recommendations/UpdateBlogPostMessage":
                            XElement messageBodyXml = XElement.Parse(bodyXml.Value);
                            string nodeType = messageBodyXml.Elements().Where(p => p.Name == "nodeType").First().Value;
                            string summary = messageBodyXml.Elements().Where(p => p.Name == "summary").First().Value;
                            var nodeId = int.Parse(messageBodyXml.Elements().Where(p => p.Name == "nodeId").First().Value);

                            Console.WriteLine("     -> nodeId = {0}, nodeType = {1}, summary = {2}", nodeId, nodeType, summary);
                            /* Do whatever needs to be done with the Recommendations API using nodeType, summary and NodeId. */

                            tran.Commit();
                            break;

                        default:
                            tran.Rollback();
                            throw new InvalidOperationException("Unknown message type " + messageType);
                    }
                }
            }
            else
            {
                tran.Rollback();
            }
        }
    }
}
