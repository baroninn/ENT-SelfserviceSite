using System;
using Microsoft.Owin;
using Microsoft.Owin.Security.Cookies;
using Owin;


namespace ColumbusPortal
{
    public static class MyAuthentication
    {
        public const String ApplicationCookie = "MyProjectAuthenticationType";
    }

    public partial class Startup
    {
        public void ConfigureAuth(IAppBuilder app)
        {
            // need to add UserManager into owin, because this is used in cookie invalidation
            app.UseCookieAuthentication(new CookieAuthenticationOptions
            {
                AuthenticationType = MyAuthentication.ApplicationCookie,
                LoginPath = new PathString("/Login"),
                Provider = new CookieAuthenticationProvider(),
                CookieName = "ColumbusCookie",
                CookieHttpOnly = true,
                ExpireTimeSpan = TimeSpan.FromHours(1), // adjust to your needs
                ReturnUrlParameter = "returnUrl"
            });
        }
    }
}
