using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(ColumbusPortal.Startup))]
namespace ColumbusPortal
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
