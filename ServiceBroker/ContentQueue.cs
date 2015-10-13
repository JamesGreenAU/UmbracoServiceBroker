using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Umbraco.Core.Events;
using Umbraco.Core.Models;
using Umbraco.Core.Persistence;
using Umbraco.Core.Services;

namespace ServiceBroker
{
    public class ContentQueue
    {
        private SqlConnection connection;

        public ContentQueue(SqlConnection connection)
        {
            this.connection = connection;
        }

        /// <summary>
        /// Note that when saving content, one save event may be raised for cascading saves.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        internal void ContentService_Saved(IContentService sender, SaveEventArgs<IContent> e)
        {
            foreach (var item in e.SavedEntities)
            {
                switch (item.ContentType.Alias)
                {
                    case "BlogPost":
                        foreach (var prop in item.Properties)
                        {
                            if (prop.PropertyType.Alias == "summary")
                            {
                                UpdateRecommendationsFromSummary(item.ContentType.Alias, (string)prop.Value, item.Id);
                            }
                        }
                        break;
                }
            }

        }

        /// <summary>
        /// Invoke proc dbo.UpdateRecommendationsFromSummary
        /// </summary>
        /// <param name="value"></param>
        /// <param name="id"></param>
        private void UpdateRecommendationsFromSummary(string ContentTypeAlias, string Summary, int NodeId)
        {
            if (connection.State != ConnectionState.Open)
            {
                connection.Open();
            }

            SqlTransaction tran = connection.BeginTransaction();
            var command = new SqlCommand("dbo.[UpdateRecommendationsFromSummary]", connection, tran);
            command.CommandType = CommandType.StoredProcedure;

            command.Parameters.Add("@nodeType", SqlDbType.NVarChar, 256);
            command.Parameters["@nodeType"].Value = ContentTypeAlias;

            command.Parameters.Add("@summary", SqlDbType.NVarChar, 512);
            command.Parameters["@summary"].Value = Summary;

            command.Parameters.Add("@nodeid", SqlDbType.Int);
            command.Parameters["@nodeid"].Value = NodeId;

            command.Parameters.Add("@ConversationHandle", SqlDbType.UniqueIdentifier);
            command.Parameters["@ConversationHandle"].Direction = ParameterDirection.Output;
            
            var t = command.ExecuteNonQuery();
            tran.Commit();
        }

        /// <summary>
        /// Creates a command to invoke dbo.ReadFromContentQueue.
        /// </summary>
        /// <param name="tran">Transaction to enrole this command in.</param>
        /// <returns></returns>
        public SqlCommand CreateReadCommand(SqlTransaction tran)
        {
            var command = new SqlCommand("dbo.[ReadFromContentQueue]", connection, tran);
            command.CommandType = CommandType.StoredProcedure;

            command.Parameters.Add("@message_type", SqlDbType.NVarChar, 256);
            command.Parameters["@message_type"].Direction = ParameterDirection.Output;
            
            command.Parameters.Add("@message_body", SqlDbType.Xml);
            command.Parameters["@message_body"].Direction = ParameterDirection.Output;
            
            command.Parameters.Add("@conversation_handle", SqlDbType.UniqueIdentifier);
            command.Parameters["@conversation_handle"].Direction = ParameterDirection.Output;
           
            command.Parameters.Add("@conversation_group_id", SqlDbType.UniqueIdentifier);
            command.Parameters["@conversation_group_id"].Direction = ParameterDirection.Output;

            return command;
        }
    }
}
