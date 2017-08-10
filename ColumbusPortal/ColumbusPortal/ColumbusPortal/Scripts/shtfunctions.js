
function GetDomain() {
    var organization = $("select[name=organization]").val();
    $("#Domain").html("loading, this could take some time...");

    $.get("/Mail/GetDomain?organization=" + organization, function (data) {
        $("#Domain").html(data);
    });
}

function GetTenantID() {
    var organization = $("select[name=organization]").val();
    $("#TenantID").html("loading, this could take some time...");

    $.get("/Office365/GetTenantID?organization=" + organization, function (data) {
        $("#TenantID").html(data);
    });
}

function GetCurrentConf() {
    var organization = $("select[name=organization]").val();
    $("#currentConf").html("loading, this could take some time...");

    $.get("/Level30/getCurrentConf?organization=" + organization, function (data) {
        $("#currentConf").html(data);
    });
}

function GetCurrentConfLIST() {
    var organization = $("select[name=organization]").val();

    $.get("/Level30/GetCurrentConfLIST", { "organization": organization }, function (data) {

        var json = JSON.parse(data);

        for (i = 0; i < json.length; i++) {
            document.getElementById("Name").value = json[i].Name;
            document.getElementById("DomainFQDN").value = json[i].DomainFQDN;
            document.getElementById("UserContainer").value = json[i].UserContainer;
            document.getElementById("ExchangeServer").value = json[i].ExchangeServer;
            document.getElementById("NETBIOS").value = json[i].NETBIOS;
            document.getElementById("CustomerOUDN").value = json[i].CustomerOUDN;
            document.getElementById("AdminUserOUDN").value = json[i].AdminUserOUDN;
            document.getElementById("ExternalUserOUDN").value = json[i].ExternalUserOUDN;
            document.getElementById("TenantID").value = json[i].TenantID;
            document.getElementById("AdminUser").value = json[i].AdminUser;
            document.getElementById("AdminPass").value = json[i].AdminPass;
            document.getElementById("AADsynced").value = json[i].AADsynced;
            document.getElementById("ADConnectServer").value = json[i].ADConnectServer;
            document.getElementById("DomainDC").value = json[i].DomainDC;
            document.getElementById("NavMiddleTier").value = json[i].NavMiddleTier;
            document.getElementById("SQLServer").value = json[i].SQLServer;
            document.getElementById("AdminRDS").value = json[i].AdminRDS;
            document.getElementById("AdminRDSPort").value = json[i].AdminRDSPort;
            document.getElementById("EmailDomains").value = json[i].EmailDomains.split(",").join("\n");

        }

    });
}

function GetAliases() {
    var organization = $("select[name=organization]").val();
    var userprincipalname = $("select[name=userprincipalname]").val();

    var aliasUl = $("#existingAliases");
    aliasUl.html("loading...");

    $.getJSON("/Ajax/GetADUsersProxy", { "organization": organization, "userprincipalname": userprincipalname }, function (data) {
        aliasUl.html("");

        $.each(data[0].proxyAddresses, function (index, obj) {
            var aliasType = obj.substring(0, 4);
            var emailString = obj.substring(5);

            if (aliasType == "SMTP") {
                emailString = emailString + " (<b>Primary</b>)";
            }

            aliasUl.append("<li>" + emailString + "</li>");
        });
    });
}

function AddMailboxToList(json, recipientType, selectElement) {
    if (recipientType && json.RecipientTypeDetails != recipientType && recipientType.toUpperCase() != "ALL") { return }

    var selected = '';

    selectElement.append('<option value="' + json.UserPrincipalName + '"' + selected + '>' + json.Name + ' [' + json.RecipientTypeDetails + '] - ' + json.UserPrincipalName + '</option>');
}

function GetMailbox(recipientType, selectElement) {
    if (!selectElement) {
        selectElement = $("select[name=userprincipalname]");
    }

    var organization = $("select[name=organization]").val();
    selectElement.html('<option>Contacting Exchange server / Office365...</option>');

    $.get("/Ajax/GetMailbox", { "organization": organization }, function (data) {
        selectElement.html('');

        var json = JSON.parse(data);
        if (json.Failure) {
            AddError(json);
        }
        else {
            selectElement.html("");
            if (json.length == null) {
                AddMailboxToList(json, recipientType, selectElement);
            }
            else {
                for (i = 0; i < json.length; i++) {
                    AddMailboxToList(json[i], recipientType, selectElement);
                }
            }
        }
        selectElement.change();
    });
}


function GetMailforward() {
    $("#existingforwards").html("... loading");

    var organization = $("select[name=organization]").val();
    var userprincipalname = $("select[name=userprincipalname]").val();

    $.getJSON("/Ajax/GetMailforward", { organization: organization, userprincipalname: userprincipalname }, function (data) {
        if (data.Name != "empty" && data.ForwardingAddress != "empty") {
            var deliverAndForward = "ForwardOnly";
            if (data.DeliverToMailboxAndForward) {
                deliverAndForward = "DeliverToMailboxAndForward"
            }
            $("#existingforwards").html(data.ForwardingAddress + " (" + data.Name + ", " + deliverAndForward + ")");
        }
        else {
            $("#existingforwards").html("None");
        }
    });
}

function GetRandomInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

function GetWorkingMessage() {
    var messages = ["Making a Ninja!!","Just thinking...","Partitioning Social Network", "Blurring Reality Lines", "Reticulating 3-Dimensional Splines", "Preparing Captive Simulators", "Capacitating Genetic Modifiers", "Destabilizing Orbital Payloads", "Manipulating Modal Memory", "Testing Underworld Telecommunications", "Caffeinating Programmer Body", "Initializing Secret Societies", "Reticulating Graduated Splines", "Loading Lightsaber Sounds", "Turning On Turn-Ons", "Disgruntling Employees", "Managing Managers Managers", "Preparing Bacon for Homeward Transportation", "Mitigating Time-Stream Discontinuities", "Loading \"First Batch\" Metrics", "Neutralizing Shuriken Oxidization", "Roof = Roof(1/3*pi*r^2*h)", "Atomizing Atomic Particles", "Readying Relaxation Receptors", "Training File Server Behavior", "Calculating Lifetime Aspirations", "Predicating Predestined Paths", "Writing Scrolling Startup String Text", "Making a Little Bit of Magic", "Rasterizing Reputation Algorithms", "Simulating Sparkling Surfaces", "Reverse-Engineering Coffee", "Cooling Down Refrigerators", "Storing Solar Energy", "Ceiling Fan Rotation = dL/dT", "Filling in the Blanks", "Generating Intrigue", "Inserting Chaos Generator", "Concatenating Vertex Nodes", "Extruding Mesh Terrain", "Simulating Program Execution", "Locating Misplaced Calculations", "Recycling Hex Decimals", "Ensuring Transplanar Synergy", "Abstracting Loading Procedures", "Polarizing Image Conduits"];

    return messages[GetRandomInt(0, messages.length - 1)];
}

function StartSubmitButtonMessage() {
    $("input[type=submit]").val("Working...");

    setTimeout(UpdateSubmitButtonMessage, 5000);
}

function UpdateSubmitButtonMessage() {
    $("input[type=submit]").val(GetWorkingMessage() + "...");

    setTimeout(UpdateSubmitButtonMessage, 30000);
}

function AddDomainToList(json, selectElement) {

    var selected = '';

    selectElement.append('<option value="' + json.DomainName + '"' + selected + '>' + json.DomainName + '</option>');
}

// New function for getting accepted domain. This function is tied to the <Select> list function and can be used as a dropdown menu.
function GetDomainSelect(selectElement) {
    if (!selectElement) {
        selectElement = $("select[name=domainname]");
    }

    var organization = $("select[name=organization]").val();
    selectElement.html('<option>loading...</option>');

    $.get("/Ajax/GetDomain", { "organization": organization }, function (data) {
        selectElement.html('');

        var json = JSON.parse(data);
        if (json.Failure) {
            AddError(json);
        }
        else {
            selectElement.html("");
            if (json.length == null) {
                AddDomainToList(json, selectElement);
            }
            else {
                for (i = 0; i < json.length; i++) {
                    AddDomainToList(json[i], selectElement);
                }
            }
        }
        selectElement.change();
    });
}


function AddSendAsGroupToList(json, selectElement) {

    var selected = '';

    selectElement.append('<option value="' + json.DistinguishedName + '"' + selected + '>' + json.Description + ' - ' + json.Name + '</option>');
}

// New function for getting sendasgroups. This function is tied to the <Select> list function and can be used as a dropdown menu.
function GetSendAsGroups(selectElement) {
    if (!selectElement) {
        selectElement = $("select[name=distinguishedname]");
    }

    var organization = $("select[name=organization]").val();
    selectElement.html('<option>loading...</option>');

    $.get("/Ajax/GetSendAsGroups", { "organization": organization }, function (data) {
        selectElement.html('');

        var json = JSON.parse(data);
        if (json.Failure) {
            AddError(json);
        }
        else {
            selectElement.html("");
            if (json.length == null) {
                AddSendAsGroupToList(json, selectElement);
            }
            else {
                for (i = 0; i < json.length; i++) {
                    AddSendAsGroupToList(json[i], selectElement);
                }
            }
        }
        selectElement.change();
    });
}


function AddUserToList(json, selectElement) {

    var selected = '';

    selectElement.append('<option value="' + json.UserPrincipalName + '"' + selected + '>' + json.Name + ' - ' + json.UserPrincipalName + ' - [' + json.Enabled + ']</option>');
}

// New function for getting AD Users. This function is tied to the <Select> list function and can be used as a dropdown menu.
function GetADUsersList(selectElement) {
    if (!selectElement) {
        selectElement = $("select[name=userprincipalname]");
    }

    var organization = $("select[name=organization]").val();
    selectElement.html('<option>Contacting Domain Controller...</option>');

    $.get("/Ajax/GetADUsersList", { "organization": organization }, function (data) {
        selectElement.html('');

        var json = JSON.parse(data);
        if (json.Failure) {
            AddError(json);
        }
        else {
            selectElement.html("");
            if (json.length == null) {
                AddUserToList(json, selectElement);
            }
            else {
                for (i = 0; i < json.length; i++) {
                    AddUserToList(json[i], selectElement);
                }
            }
        }
        selectElement.change();
    });
}

function AddVMToList(json, selectElement) {

    var selected = '';

    selectElement.append('<option value="' + json.VMID + '"' + selected + '>' + json.Name + '</option>');
}

// New function for getting VMServer. This function is tied to the <Select> list function and can be used as a dropdown menu.
function GetVMServers(selectElement) {
    if (!selectElement) {
        selectElement = $("select[name=vmid]");
    }

    selectElement.html('<option>loading, this could take some time (VMM is a little slow)...</option>');

    $.get("/Ajax/GetVMServers", function (data) {
        selectElement.html('');

        var json = JSON.parse(data);
        if (json.Failure) {
            AddError(json);
        }
        else {
            selectElement.html("");
            if (json.length == null) {
                AddVMToList(json, selectElement);
            }
            else {
                for (i = 0; i < json.length; i++) {
                    AddVMToList(json[i], selectElement);
                }
            }
        }
        selectElement.change();
    });
}

// New function for getting VMServer. This function is tied to the <Select> list function and can be used as a dropdown menu.
function GetVMServerslvl25(selectElement) {
    if (!selectElement) {
        selectElement = $("select[name=vmid]");
    }

    selectElement.html('<option>loading, this could take some time (VMM is a little slow)...</option>');

    $.get("/Ajax/GetVMServerslvl25", function (data) {
        selectElement.html('');

        var json = JSON.parse(data);
        if (json.Failure) {
            AddError(json);
        }
        else {
            selectElement.html("");
            if (json.length == null) {
                AddVMToList(json, selectElement);
            }
            else {
                for (i = 0; i < json.length; i++) {
                    AddVMToList(json[i], selectElement);
                }
            }
        }
        selectElement.change();
    });
}

function AddVHDToList(json, selectElement) {

    var selected = '';

    selectElement.append('<option value="' + json.VHDID + '"' + selected + '>' + json.Name + ' - [' + json.Size + ' ' + "GB" + ']</option>');
}

// New function for getting VHD. This function is tied to the <Select> list function and can be used as a dropdown menu.
function GetVMVHDs(selectElement) {
    if (!selectElement) {
        selectElement = $("select[name=vhdid]");
    }
    var vmid = $("select[name=vmid]").val();
    selectElement.html('<option>loading, this could take some time (VMM is a little slow)...</option>');

    $.get("/Ajax/GetVMVHDs", { "vmid": vmid }, function (data) {
        selectElement.html('');

        var json = JSON.parse(data);
        if (json.Failure) {
            AddError(json);
        }
        else {
            selectElement.html("");
            if (json.length == null) {
                AddVHDToList(json, selectElement);
            }
            else {
                for (i = 0; i < json.length; i++) {
                    AddVHDToList(json[i], selectElement);
                }
            }
        }
        selectElement.change();
    });
}

function GetVMInfo() {
    var vmid = $("select[name=vmid]").val();
    $("#vminfo").html("Loading...");

    $.get("/Level30/GetVMInfo?vmid=" + vmid, function (data) {
        $("#vminfo").html(data);
    });
}

function GetAdminUsers() {
    $("#adminusers").html("Loading...");

    $.get("/Level30/GetAdminUsers?", function (data) {
        $("#adminusers").html(data);
    });
}

function GetVMInfo2() {
    var vmid = $("select[name=vmid]").val();
    $("#vminfo2").html("Loading...");

    $.get("/Level30/GetVMInfo3?vmid=" + vmid, function (data) {
        $("#vminfo2").html(data);
    });
}

function AddO365DomainToList(json, Status, selectElement) {
    if (json.Status != Status) { return }
    var selected = '';

    selectElement.append('<option value="' + json.DomainName + '"' + selected + '>' + json.DomainName + '</option>');
}

function GetO365DomainSelect(Status,selectElement) {
    if (!selectElement) {
        selectElement = $("select[name=domainname]");
    }

    var organization = $("select[name=organization]").val();
    selectElement.html('<option>loading...</option>');

    $.get("/Ajax/GetO365Domain", { "organization": organization }, function (data) {
        selectElement.html('');

        var json = JSON.parse(data);
        if (json.Failure) {
            AddError(json);
        }
        else {
            selectElement.html("");
            if (json.length == null) {
                AddO365DomainToList(json, Status, selectElement);
            }
            else {
                for (i = 0; i < json.length; i++) {
                    AddO365DomainToList(json[i], Status, selectElement);
                }
            }
        }
        selectElement.change();
    });
}


function AddAdminToList(json, selectElement) {

    var selected = '';

    selectElement.append('<option value="' + json.SamAccountName + '"' + selected + '>' + json.DisplayName + ' ' + " - " + ' [' + json.SamAccountName + ']</option>');
}

// New function for getting VMServer. This function is tied to the <Select> list function and can be used as a dropdown menu.
function GetAdminUsersLIST(selectElement) {
    if (!selectElement) {
        selectElement = $("select[name=samaccountname]");
    }

    selectElement.html('<option>loading...</option>');

    $.get("/Level30/GetAdminUsersLIST?", function (data) {
        selectElement.html('');

        var json = JSON.parse(data);
        if (json.Failure) {
            AddError(json);
        }
        else {
            selectElement.html("");
            if (json.length == null) {
                AddAdminToList(json, selectElement);
            }
            else {
                for (i = 0; i < json.length; i++) {
                    AddAdminToList(json[i], selectElement);
                }
            }
        }
        selectElement.change();
    });
}

function GetPendingReboot() {
    $("#pendingreboot").html("loading, this could take some time...");

    $.get("/Service/GetPendingReboot?", function (data) {
        $("#pendingreboot").html(data);
    });
}

function GetLatestAlerts(alert) {

    $("#latestalerts").html("Contacting DB... please be patient..");
    
    $.get("/Service/GetLatestAlerts?alert=" + alert, function (data) {
        $("#latestalerts").html(data);
    });
}

function GetAlertFreeSpace() {
    $("#alertfree").html("Contacting DB... please be patient..");

    $.get("/Service/GetAlertFreeSpace?", function (data) {
        $("#alertfree").html(data);
    });
}

function GetScheduledJobs(job) {
    $("#scheduledjobs").html("Contacting DB... please be patient..");

    $.get("/Service/GetScheduledJobs?job=" + job, function (data) {
        $("#scheduledjobs").html(data);
    });
}

function GetCompletedEXTAdminUsers() {
    var organization = $("select[name=organization]").val();
    var status = 'Done';
    $("#completedAdmins").html("Contacting DB... please be patient..");

    $.get("/Level30/GetEXTAdminUsers", { "status": status, "organization": organization }, function (data) {
        $("#completedAdmins").html(data);
    });
}

function GetscheduledEXTAdminUsers() {
    var organization = $("select[name=organization]").val();
    var status = 'Scheduled';
    $("#scheduledAdmins").html("Contacting DB... please be patient..");

    $.get("/Level30/GetEXTAdminUsers", { "status": status, "organization": organization }, function (data) {
        $("#scheduledAdmins").html(data);
    });
}

function GeneratePassword() {
    var chars = "ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz";
    var string_length = 10;
    var randomstring = '';
    var charCount = 0;
    var numCount = 0;

    for (var i = 0; i < string_length; i++) {
        // If random bit is 0, there are less than 3 digits already saved, and there are not already 5 characters saved, generate a numeric value. 
        if ((Math.floor(Math.random() * 2) == 0) && numCount < 3 || charCount >= 5) {
            var rnum = Math.floor(Math.random() * 10);
            randomstring += rnum;
            numCount += 1;
        } else {
            // If any of the above criteria fail, go ahead and generate an alpha character from the chars string
            var rnum = Math.floor(Math.random() * chars.length);
            randomstring += chars.substring(rnum, rnum + 1);
            charCount += 1;
        }
    }
    return randomstring;
}

function AddEXTAdminToList(json, selectElement) {

    var selected = '';

    selectElement.append('<option value="' + json.ID + '"' + selected + '>' + json.ID + ' ' + json.FirstName + ' ' + json.LastName + ' ' + " - " + ' [' + json.Company + '] - [' + json.Organization + ']</option>');

}

function GetEXTAdminUsersLIST(status, selectElement) {
    if (!selectElement) {
        selectElement = $("select[name=id]");
    }
    var organization = $("select[name=organization]").val();
    var id = '';

    selectElement.html('<option>loading...</option>');

    $.get("/Level30/GetEXTAdminUsersSELECT", { "id": id, "status": status, "organization": organization } , function (data) {
        selectElement.html('');

        var json = JSON.parse(data);
        if (json.Failure) {
            AddError(json);
        }
        else {
            selectElement.html("");
            if (json.length == null) {
                AddEXTAdminToList(json, selectElement);
            }
            else {
                for (i = 0; i < json.length; i++) {
                    AddEXTAdminToList(json[i], selectElement);
                }
            }
        }
        selectElement.change();
    });
}

function GetEXTAdminUser(id) {
    var id = $("select[name=id]").val();
    var organization = $("select[name=organization]").val();

    $.get("/Level30/GetEXTAdminUsersSELECT", { "id": id, "organization": organization }, function (data) {

        var json = JSON.parse(data);

        for (i = 0; i < json.length; i++) {
            document.getElementById("description").value = json[i].Description;
            document.getElementById("email").value = json[i].Email;
            document.getElementById("firstname").value = json[i].FirstName;
            document.getElementById("lastname").value = json[i].LastName;
            document.getElementById("company").value = json[i].Company;
            document.getElementById("customer").value = json[i].Customer;
            document.getElementById("expiredate").value = json[i].ExpireDate;
        }

    });
}

function AddCASAdminToList(json, selectElement) {

    var selected = '';

    selectElement.append('<option value="' + json.ID + '"' + selected + '>' + json.ID + ' ' + json.FirstName + ' ' + json.LastName + ' ' + " - " + ' [' + json.UserName + '] - [' + json.Organization + ']</option>');

}

function GetCASAdminUsersLIST(status, selectElement) {
    if (!selectElement) {
        selectElement = $("select[name=id]");
    }
    var organization = $("select[name=organization]").val();
    var id = '';

    selectElement.html('<option>loading...</option>');

    $.get("/Level30/GetCASAdminUsersSELECT", { "id": id, "status": status, "organization": organization }, function (data) {
        selectElement.html('');

        var json = JSON.parse(data);
        if (json.Failure) {
            AddError(json);
        }
        else {
            selectElement.html("");
            if (json.length == null) {
                AddCASAdminToList(json, selectElement);
            }
            else {
                for (i = 0; i < json.length; i++) {
                    AddCASAdminToList(json[i], selectElement);
                }
            }
        }
        selectElement.change();
    });
}

function GetCASAdminUser(id) {
    var id = $("select[name=id]").val();
    var organization = $("select[name=organization]").val();

    $.get("/Level30/GetCASAdminUsersSELECT", { "id": id, "organization": organization }, function (data) {

        var json = JSON.parse(data);

        for (i = 0; i < json.length; i++) {
            document.getElementById("description").value = json[i].Description;
            document.getElementById("email").value = json[i].Email;
            document.getElementById("firstname").value = json[i].FirstName;
            document.getElementById("lastname").value = json[i].LastName;
            document.getElementById("company").value = json[i].Company;
            document.getElementById("customer").value = json[i].Customer;
            document.getElementById("expiredate").value = json[i].ExpireDate;
        }

    });
}

function GetCompletedCASAdminUsers() {
    var organization = $("select[name=organization]").val();
    var status = 'ALL';
    $("#completedCASAdmins").html("Contacting DB... please be patient..");

    $.get("/Level30/GetCASAdminUsers", { "status": status, "organization": organization }, function (data) {
        $("#completedCASAdmins").html(data);
    });
}

function GetCurrentSharedCustomerConfLIST() {
    var organization = $("select[name=organization]").val();

    $.get("/Level30/GetCurrentSharedCustomerConfLIST", { "organization": organization }, function (data) {

        var json = JSON.parse(data);

        for (i = 0; i < json.length; i++) {
            document.getElementById("Name").value = json[i].Name;
            document.getElementById("NavMiddleTier").value = json[i].NavMiddleTier;
            document.getElementById("SQLServer").value = json[i].SQLServer;

        }

    });
}

function GetCASOrganizations() {
    $("#CasOrganizations").html("Contacting DB... please be patient..");

    $.get("/Level30/GetCASOrganizations?", function (data) {
        $("#CasOrganizations").html(data);
    });
}

if ($('#back-to-top').length) {
    var scrollTrigger = 100, // px
        backToTop = function () {
            var scrollTop = $(window).scrollTop();
            if (scrollTop > scrollTrigger) {
                $('#back-to-top').addClass('show');
            } else {
                $('#back-to-top').removeClass('show');
            }
        };
    backToTop();
    $(window).on('scroll', function () {
        backToTop();
    });
    $('#back-to-top').on('click', function (e) {
        e.preventDefault();
        $('html,body').animate({
            scrollTop: 0
        }, 700);
    });
}