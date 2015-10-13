using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Umbraco.Core;
using Umbraco.Core.Events;
using Umbraco.Core.Models;
using Umbraco.Core.Services;

namespace ServiceBroker
{
    /// <summary>
    /// Hooks into events via Umbraco.Core.ApplicationEventHandler.
    /// </summary>
    public class ServiceBrokerAppEventHandler : ApplicationEventHandler
    {
        private SqlConnection queueConnection;

        /// <summary>
        /// See https://our.umbraco.org/documentation/Reference/Events/ for event handling documentation.
        /// </summary>
        /// <param name="umbracoApplication"></param>
        /// <param name="applicationContext"></param>
        protected override void ApplicationStarted(UmbracoApplicationBase umbracoApplication, ApplicationContext applicationContext)
        {
            queueConnection = new SqlConnection(applicationContext.DatabaseContext.ConnectionString);

            /*
            ContentService
            MediaService
            ContentTypeService
            MemberService
            FileService
            LocalizationService
            DataTypeService
            */

            var contentQueue = new ContentQueue(queueConnection);
            ContentService.Saved += contentQueue.ContentService_Saved;

            var mediaQueue = new MediaQueue(queueConnection);
            MediaService.Created += mediaQueue.MediaService_Created;
            MediaService.Deleted += mediaQueue.MediaService_Deleted;

            var memberQueue = new MemberQueue(queueConnection);
            MemberService.Created += memberQueue.MemberService_Created;

            base.ApplicationStarted(umbracoApplication, applicationContext);
        }
    }
}
