using System.Collections.Generic;
using System.Web.Mvc;
using System.ComponentModel.DataAnnotations;

namespace ColumbusPortal.Models
{
    public class CrayonModel : BaseModel
    {
        public CustomCrayonTenant CrayonTenant = new CustomCrayonTenant();
        public CustomCrayonTenantInfoDetailed CrayonTenantDetailed = new CustomCrayonTenantInfoDetailed();
        public List<CustomCrayonInvoiceProfile> CrayonInvoiceProfiles = new List<CustomCrayonInvoiceProfile>();

    }
    // Custom Tenant type containing relevant Tenant information
    public class CustomCrayonTenant
    {
        public string Name { get; set; }
        public string Reference { get; set; }
        public string DomainPrefix { get; set; }
        public string CustomerTenantType { get; set; }
        public string InvoiceProfile { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }

        [Required(ErrorMessage = "Email is mandatory!")]
        [RegularExpression(@"^(([-\w\d]+)(\.[-\w\d]+)*@([-\w\d]+)(\.[-\w\d]+)*(\.([a-zA-Z]{2,5}|[\d]{1,3})){1,2})$", ErrorMessage = "Please enter correctly formated email.")]
        public string Email { get; set; }
        public string PhoneNumber { get; set; }
        public string CustomerFirstName { get; set; }
        public string CustomerLastName { get; set; }
        public string AddressLine1 { get; set; }
        public string City { get; set; }
        public string Region { get; set; }
        public string PostalCode { get; set; }
        public string CountryCode { get; set; }

    }

    // Custom Tenant type containing relevant Tenant information
    public class CustomCrayonTenantInfoDetailed
    {
        public string Id { get; set; }
        public string Name { get; set; }
        public string PublisherCustomerId { get; set; }
        public string ExternalPublisherCustomerId { get; set; }
        public string Reference { get; set; }
        public string AdminUser { get; set; }
        public string AdminPass { get; set; }
        public string DomainPrefix { get; set; }
        public string CustomerTenantType { get; set; }
        public string InvoiceProfile { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }

        [Required(ErrorMessage = "Email is mandatory!")]
        [RegularExpression(@"^(([-\w\d]+)(\.[-\w\d]+)*@([-\w\d]+)(\.[-\w\d]+)*(\.([a-zA-Z]{2,5}|[\d]{1,3})){1,2})$", ErrorMessage = "Please enter correctly formated email.")]
        public string Email { get; set; }
        public string PhoneNumber { get; set; }
        public string CustomerFirstName { get; set; }
        public string CustomerLastName { get; set; }
        public string AddressLine1 { get; set; }
        public string City { get; set; }
        public string Region { get; set; }
        public string PostalCode { get; set; }
        public string CountryCode { get; set; }

    }

    public class CustomCrayonInvoiceProfile
    {
        public string Id { get; set; }
        public string Name { get; set; }

    }
}