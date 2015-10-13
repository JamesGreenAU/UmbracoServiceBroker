using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Umbraco.Core.Events;
using Umbraco.Core.Models;
using Umbraco.Core.Services;

namespace ServiceBroker
{
    public class MediaQueue
    {
        private SqlConnection connection;

        public MediaQueue(SqlConnection Connection)
        {
            connection = Connection;
        }

        /// <summary>
        /// Invokes dbo.RequestCdnPolicyOnResource
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        public void MediaService_Created(IMediaService sender, NewEventArgs<IMedia> e)
        {
            string Resource = e.Entity.Name;

            if (connection.State != ConnectionState.Open)
            {
                connection.Open();
            }

            SqlTransaction tran = connection.BeginTransaction();
            var command = new SqlCommand("dbo.[RequestCdnPolicyOnResource]", connection, tran);
            command.CommandType = CommandType.StoredProcedure;

            command.Parameters.Add("@resource", SqlDbType.NVarChar, 256);
            command.Parameters["@resource"].Value = Resource;

            command.Parameters.Add("@ConversationHandle", SqlDbType.UniqueIdentifier);
            command.Parameters["@ConversationHandle"].Direction = ParameterDirection.Output;

            command.ExecuteNonQuery();
            tran.Commit();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        public void MediaService_Deleted(IMediaService sender, DeleteEventArgs<IMedia> e)
        {
            foreach (var item in e.DeletedEntities)
            {
                string Resource = item.Name;
                
                if (connection.State != ConnectionState.Open)
                {
                    connection.Open();
                }

                SqlTransaction tran = connection.BeginTransaction();
                var command = new SqlCommand("dbo.[RequestCdnResourceInvalidation]", connection, tran);
                command.CommandType = CommandType.StoredProcedure;

                command.Parameters.Add("@resource", SqlDbType.NVarChar, 256);
                command.Parameters["@resource"].Value = Resource;

                command.Parameters.Add("@ConversationHandle", SqlDbType.UniqueIdentifier);
                command.Parameters["@ConversationHandle"].Direction = ParameterDirection.Output;

                command.ExecuteNonQuery();
                tran.Commit();
            }
        }


        /// <summary>
        /// Creates a command to invoke dbo.ReadFromMediaQueue.
        /// </summary>
        /// <param name="tran">Transaction to enrole this command in.</param>
        /// <returns></returns>
        public SqlCommand CreateReadCommand(SqlTransaction tran)
        {
            var command = new SqlCommand("dbo.[ReadFromMediaQueue]", connection, tran);
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
