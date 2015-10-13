using System;
using System.Collections.Generic;
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

        public void MediaService_Created(IMediaService sender, NewEventArgs<IMedia> e)
        {
            throw new NotImplementedException();
        }

        public void MediaService_Deleted(IMediaService sender, DeleteEventArgs<IMedia> e)
        {
            throw new NotImplementedException();
        }
        
    }
}
