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
    public class MemberQueue
    {
        private SqlConnection connection;

        public MemberQueue(SqlConnection queueConnection)
        {
            this.connection = queueConnection;
        }

        /// <summary>
        /// Invoke dbo.[SendMemberWelcomePack]
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        public void MemberService_Created(IMemberService sender, NewEventArgs<IMember> e)
        {
            string Name = e.Entity.Name;
            string Email = e.Entity.Email;
            
            if (connection.State != System.Data.ConnectionState.Open)
            {
                connection.Open();
            }

            SqlTransaction tran = connection.BeginTransaction();
            var command = new SqlCommand("dbo.[SendMemberWelcomePack]", connection, tran);
            command.CommandType = CommandType.StoredProcedure;

            command.Parameters.Add("@name", SqlDbType.NVarChar, 256);
            command.Parameters["@name"].Value = Name;

            command.Parameters.Add("@email", SqlDbType.NVarChar, 256);
            command.Parameters["@email"].Value = Email;

            command.Parameters.Add("@ConversationHandle", SqlDbType.UniqueIdentifier);
            command.Parameters["@ConversationHandle"].Direction = ParameterDirection.Output;

            command.ExecuteNonQuery();
            tran.Commit();
        }

        /// <summary>
        /// Creates a command to invoke dbo.[ReadFromMemberQueue].
        /// </summary>
        /// <param name="tran"></param>
        /// <returns></returns>
        public SqlCommand CreateReadCommand(SqlTransaction tran)
        {
            var command = new SqlCommand("dbo.[ReadFromMemberQueue]", connection, tran);
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
