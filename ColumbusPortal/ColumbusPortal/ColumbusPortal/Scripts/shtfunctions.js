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

function GetCurrentConfLIST() {
    $('.loading').show();
    $('.Conf').hide();
    var organization = $("select[name=organization]").val();

    $.get("/Level30/GetCurrentConfLIST", { "organization": organization }, function (data) {

        var json = JSON.parse(data);

        for (i = 0; i < json.length; i++) {
            // Trigger a correct change event understanded by newer browsers...

                // For all modern browsers!!
            var element = document.getElementById('Platform');
            element.value = json[i].Platform;

            var event = new Event('change');
            element.dispatchEvent(event);

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
            document.getElementById("AppID").value = json[i].AppID;
            document.getElementById("AppSecret").value = json[i].AppSecret;
            if (json[i].ServiceCompute == "True") { document.getElementById("servicecompute").checked = true; } else { document.getElementById("servicecompute").checked = false; }
            if (json[i].Service365 == "True") { document.getElementById("service365").checked = true; } else { document.getElementById("service365").checked = false; }
            if (json[i].ServiceIntune == "True") { document.getElementById("serviceintune").checked = true; } else { document.getElementById("serviceintune").checked = false; }
        }
        $('.loading').hide();
        $('.Conf').fadeIn({ queue: false, duration: 'slow' });
    });
}

function GetAliases() {
    $('.loading').show();
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
        $('.loading').hide();
    });
}

function AddMailboxToList(json, recipientType, selectElement) {
    if (recipientType && json.RecipientTypeDetails != recipientType && recipientType.toUpperCase() != "ALL") { return }

    var selected = '';

    selectElement.append('<option value="' + json.UserPrincipalName + '"' + selected + '>' + json.Name + ' [' + json.RecipientTypeDetails + '] - ' + json.UserPrincipalName + '</option>');
}
function GetMailbox(recipientType, selectElement) {
    $('.loading').show();
    $('.hide').hide();
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
        $('.hide').fadeIn();
        $('.loading').hide();
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
function GetADUsersList(selectElement) {
    $('.loading').show();
    $('.hide').hide();
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
            if (json.length == 0) {
                AddUserToList(json, selectElement);
            }
            else {
                for (i = 0; i < json.length; i++) {
                    AddUserToList(json[i], selectElement);
                }
            }
        }
        selectElement.change();
        $('.hide').fadeIn();
        $('.loading').hide();
    });
}

function AddVMToList(json, selectElement) {

    var selected = '';

    selectElement.append('<option value="' + json.id + '"' + selected + '>' + json.Name + '</option>');
}
function GetVMServers(level, selectElement) {
    $('.loading').show();
    $('.hide').hide();
    if (!selectElement) {
        selectElement = $("select[name=vmid]");
    }

    selectElement.html('<option>loading, this could take some time (VMM is a little slow)...</option>');

    $.get("/Ajax/GetVMSQL", { "level": level }, function (data) {
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
        $('.hide').fadeIn();
        $('.loading').hide();
    });
}

function AddVHDToList(json, selectElement) {

    var selected = '';

    selectElement.append('<option value="' + json.VHDID + '"' + selected + '>' + json.Name + ' - [' + json.Size + ' ' + "GB" + ']</option>');
}
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

function GetLatestVMs(callback) {
    $('.loading').show();
    $('#latestvms').fadeOut({ queue: false, duration: 'slow' });
    $("#latestvms").load("/Service/GetLatestVMs", function (data) {
        $('.loading').hide();
        $('#latestvms').fadeIn({ queue: false, duration: 'slow' });
        callback();
    });
}

function GetScheduledJobs(job) {
    $("#scheduledjobs").html("Contacting DB... please be patient..");

    $.get("/Service/GetScheduledJobs?job=" + job, function (data) {
        $("#scheduledjobs").html(data);
    });
}
function GetScheduledJobsJSON(job) {
    $("#scheduledjobs").html("Contacting DB... please be patient..");

    $.get("/Service/GetScheduledJobsJSON?job=" + job, function (data) {

        var json = JSON.parse(data);

        if (json.length == 0) {
            $("#scheduledjobs").html("<div><b>No current schedules!..</b></div>");
            $('#buttonRemove').hide();
        }
        else {
            $("#scheduledjobs").html("");
            for (i = 0; i < json.length; i++) {
                $("#scheduledjobs").append("" +
                "<div style=\"width: 50px; height: 50px; float:left; vertical-align: middle;\"><center><input class=\"deleteBox\" value=\"" + json[i].JobID + "\" type=\"checkbox\" /></center></div><table class='SQLlight'><tr><td style='width: 150px; text-align: left;'><b>Scheduled Time</b></td><td style='text-align: left;'>" + json[i].ScheduledTime + "</td>" +
                "<tr><td style='width: 150px; text-align: left;'><b>Status</b></td><td style='text-align: left'>" + json[i].Status + "</td></tr>" +
                "<tr><td style='width: 150px; text-align: left;'><b>VM Name</b></td><td style='text-align: left'>" + json[i].VMName + "</td></tr>" +
                "<tr><td style='width: 150px; text-align: left;'><b>Parameters</b></td><td style='text-align: left; color: #e60000; font-weight:bold'>" + json[i].Parameters + "</td></tr>" +
                "<tr><td style='width: 150px; text-align: left;'><b>Opgave nr.</b></td><td style='text-align: left; color: #e60000; font-weight:bold'>" + json[i].TaskID + "</td></tr>" +
                "<tr><td style='width: 150px; text-align: left;'><b>Email Status To</b></td><td style='text-align: left; color: #e60000; font-weight:bold'>" + json[i].EmailStatusTo + "</td></tr>" +
                "<tr><td style='width: 150px; text-align: left;'><b>Runbook ID</b></td><td style='text-align: left'>" + json[i].RunbookID + "</td></tr></table></br>")
            }
            $('#buttonRemove').show();
        }
    });
}
function RemoveSelectedSchedules(type) {
    jsonObj = [];
    $('input[class=deleteBox]:checked').each(function () {
        jsonObj.push($(this).val())
    });
    $.get("/Ajax/RemoveScheduledJobs", { "id": JSON.stringify(jsonObj) }, function (data) {
        var json = JSON.parse(data);
        if (json.Failure) {
            AddError(json);
        }
        else {
            GetScheduledJobsJSON(type);
        }
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

function GetXKCDPassword(type, callback) {

    $.get("/Ajax/GetXKCDPassword", { "type": type, }, function (data) {
        callback(data);
    });
    
}

function GeneratePassword(type) {
    var randomstring = '';

    if (type == 'user') {
        var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz!"#¤%&()=/';
        var string_length = 8;
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
    }
    else {
        var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz!"#¤%&()=/';
        var string_length = 16;
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

function AddCASAdminToListALL(json, selectElement) {

    var selected = '';
    if (json == '')
    {
        selectElement.append('<option>It appears there are no admins in the database..</option>');
    }
    else
    {
        selectElement.append('<option value="' + json.UserName + '"' + selected + '>' + json.FirstName + ' ' + json.LastName + ' ' + " - " + ' [' + json.UserName + '] - [' + json.Email + ']</option>');
    }

}

function GetCASAdminUsersALLLIST(selectElement) {
    if (!selectElement) {
        selectElement = $("select[name=username]");
    }
    var id = '';

    selectElement.html('<option>Contacting DB... please be patient..</option>');

    $.get("/Level30/GetCASAdminUsersSELECTALL?", function (data) {
        selectElement.html('');

        var json = JSON.parse(data);
        if (json.Failure) {
            AddError(json);
        }
        else {
            selectElement.html("");
            if (json.length == null) {
                AddCASAdminToListALL(json, selectElement);
            }
            else {
                for (i = 0; i < json.length; i++) {
                    AddCASAdminToListALL(json[i], selectElement);
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

function GetCurrentNAVCustomerConfLIST() {
    var organization = $("select[name=organization]").val();

    $.get("/Level30/GetCurrentNAVCustomerConfLIST", { "organization": organization }, function (data) {

        var json = JSON.parse(data);

        for (i = 0; i < json.length; i++) {

            var element = document.getElementById('Platform');
            element.value = json[i].Platform;

            var event = new Event('change');
            element.dispatchEvent(event);

            document.getElementById("Name").value = json[i].Name;
            document.getElementById("NavMiddleTier").value = json[i].NavMiddleTier;
            document.getElementById("SQLServer").value = json[i].SQLServer;
            document.getElementById("RDSServer").value = json[i].RDSServer;
            tinymce.get("LoginInfo").setContent('');
            tinymce.get("LoginInfo").execCommand('mceInsertContent', false, json[i].LoginInfo);

        }

    });
}

function GetCASOrganizations() {
    $("#CasOrganizations").html("Contacting DB... please be patient..");

    $.get("/Level30/GetCASOrganizations?", function (data) {
        $("#CasOrganizations").html(data);
    });
}

function WriteToLog(string) {

    $.get("/Ajax/Log", { "entry": string }, function (data) {

    });
}

function GetCurrentOOF() {
    $("#currentOOF").html("loading...");

    var organization = $("select[name=organization]").val();
    var userprincipalname = $("select[name=userprincipalname]").val();

    $.get("/Ajax/GetCurrentOOF", { organization: organization, userprincipalname: userprincipalname }, function (data) {

        var json = JSON.parse(data);

        if (json.AutoReplyState != "Disabled") {
            if (json.AutoReplyState != "Enabled") {

                if (json.ExternalAudience != "None") {
                    $("#currentOOF").html("<br/><b>Start</b> - " + json.StartTime + " - <b>End</b> - " + json.EndTime + " <p><hr><br/><b>Internal:</b><p>" + json.InternalMessage + "<br/><b>External:</b><p>" + json.ExternalMessage + "");
                }
                else {
                    $("#currentOOF").html("<br/><b>Start</b> - " + json.StartTime + " - <b>End</b> - " + json.EndTime + " <p><hr><br/><b>Internal:</b><p>" + json.InternalMessage + "<br/><b>External:</b><p>External is disabled");
                }
            }
            else
            {
                if (json.ExternalAudience != "None") {
                    $("#currentOOF").html("Enabled <p><hr><br/><b>Internal:</b><p>" + json.InternalMessage + "<br/><b>External:</b><p>" + json.ExternalMessage + "");
                }
                else {
                    $("#currentOOF").html("Enabled <p><hr><br/><b>Internal:</b><p>" + json.InternalMessage + "<br/><b>External:</b><p>External is disabled");
                }
            }
        }
        else {
            $("#currentOOF").html("Disabled");
        }
    });
}

function downloadfile(filename, text) {
    var pom = document.createElement('a');
    pom.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(text));
    pom.setAttribute('download', filename);

    if (document.createEvent) {
        var event = document.createEvent('MouseEvents');
        event.initEvent('click', true, true);
        pom.dispatchEvent(event);
    }
    else {
        pom.click();
    }
}

function GetIntuneOverview(callback) {
    $('.loading').show();
    var organization = $("select[name=organization]").val();
    $("#intuneoverview").load("/Azure/GetIntuneOverview", { organization: organization }, function (data) {
        callback();
    });
}
function GetAzureVM(callback) {
    $('.loading').show();
    var organization = $("select[name=organization]").val();
    $("#AzureVMS").load("/Azure/GetAzureVM", { organization: organization }, function () {
        callback();
    });
}
function GetAzureSecurityCenter(callback) {
    $('.loading').show();
    var organization = $("select[name=organization]").val();
    $("#AzureSecurityCenter").load("/Azure/GetAzureSecurityCenter", { organization: organization }, function () {
        callback();
    });
}
function GetAzureIntuneDevice(callback) {
    $('.loading').show();
    var organization = $("select[name=organization]").val();
    $("#AzureIntuneDevice").load("/Azure/GetAzureIntuneDevice", { organization: organization }, function () {
        callback();
    });
}

function GetAzureIntunePolicyOverview(callback) {
    $('.loading').show();
    var organization = $("select[name=organization]").val();
    $("#AzureIntuneComplianceOverview").load("/Azure/GetAzureIntunePolicyOverview", { organization: organization }, function () {
        callback();
    });
}

function StartIntuneDeviceTask(task, id, name) {
    var textcontent = '';
    var textcolor = '';
    if (task == "wipe") {
        textcontent = '<p><b>Are you 100% sure</b> you want to send <b>' + task + '</b></p>' +
                      '<p>To: ' + name + '????</p>' +
                      '<br />' +
                      '<p><b>ALL DATA WILL BE DELETED!</b>' +
                      '<br />';
        themecolor = 'red';
        autoClose = 'cancel|4000';
    }
    else {
        textcontent = '<p>Are you sure you want to send ' + task + '</p>' +
                  '<p>To: ' + name + '</p>' +
                  '<br />';
        themecolor = 'green';
        autoClose = 'false';
    }
    $('.loading').show();
    var organization = $("select[name=organization]").val();

    if (task == "enableLostMode") {
        $.confirm({
            title: 'Enable Lost Mode',
            theme: 'light',
            type: 'green',
            typeAnimated: true,
            autoClose: autoClose,
            content: '' +
            '<form action="" class="formName">' +
            '<div class="form-group"><table>' +
            '<tr><td class="lefttd">Message to display</td>' +
            '<td class="lefttd"><input type="text" id="message" name="message" placeholder="ex. This phone has been lost, please call below phonenumber." required /></td></tr>' +
            '<p>' +
            '<tr><td class="lefttd">Phone number to display</td>' +
            '<td class="lefttd"><input type="text" id="phone" name="phone" placeholder="+45 0000 0000" required /></td></tr>' +
            '<p>' +
            '<tr><td class="lefttd">Footer to display</td>' +
            '<td class="lefttd"><input type="text" id="footer" name="footer" placeholder="Columbus A/S" value="Columbus A/S" required /></td></tr>' +
            '</table></div>' +
            '</form>',
            buttons: {
                formSubmit: {
                    text: 'Enable Lost Mode',
                    theme: 'light',
                    type: 'green',
                    typeAnimated: true,
                    action: function () {
                        var message = this.$content.find('#message').val();
                        var phone = this.$content.find('#phone').val();
                        var footer = this.$content.find('#footer').val();
                        if (!message) { $.alert('Provide a message'); return false; }
                        if (!phone) { $.alert('Provide a phonenumber'); return false; }
                        if (!footer) { $.alert('Provide a footer'); return false; }
                        $.get("/Azure/StartIntuneDeviceTask", { organization: organization, task: task, id: id, name: name, message: message, phone: phone, footer: footer }, function (data) {
                            var json = JSON.parse(data);
                            if (json.Failure) {
                                $.confirm({
                                    theme: 'light',
                                    type: 'red',
                                    typeAnimated: true,
                                    title: 'WARNING:',
                                    content: 'Failed with data:' + data + ' And json ' + json +
                                             'status: ' + data.Status,
                                    buttons: {
                                        OK: function () {
                                        },
                                    }
                                });
                            }
                            else {
                                if (json == null) {
                                    $.confirm({
                                        theme: 'light',
                                        type: 'red',
                                        typeAnimated: true,
                                        title: 'WARNING:',
                                        content: 'data is null',
                                        buttons: {
                                            OK: function () {
                                            },
                                        }
                                    });
                                }
                                else {
                                    if (json.Status == "Success") {
                                        $.confirm({
                                            theme: 'light',
                                            type: 'green',
                                            typeAnimated: true,
                                            title: 'INFO:',
                                            content: '<p>ID: ' + id + '</p>' +
                                                     '<p>Name: ' + name + '</p>' +
                                                     '<br />' +
                                                     '<p>Has been scheduled for <b>' + task + '</b></p>',
                                            buttons: {
                                                OK: function () {
                                                },
                                            }
                                        });
                                    }
                                    if (json.Status == "Error") {
                                        $.confirm({
                                            theme: 'light',
                                            type: 'red',
                                            typeAnimated: true,
                                            title: 'WARNING:',
                                            content: json.Status,
                                            buttons: {
                                                OK: function () {
                                                },
                                            }
                                        });
                                    }
                                }
                            }
                            $('.loading').hide();
                        });
                    }
                },
                cancel: function () {
                    $('.loading').hide();
                },
            },
            onContentReady: function () {
                // bind to events
                var jc = this;
                this.$content.find('form').on('submit', function (e) {
                    // if the user submits the form by pressing enter in the field.
                    e.preventDefault();
                    jc.$$formSubmit.trigger('click'); // reference the button and click it
                });
            }
        });
    }
    else {
        $.confirm({
            theme: 'light',
            type: themecolor,
            typeAnimated: true,
            title: 'Confirm:',
            content: textcontent,
            autoClose: autoClose,
            buttons: {
                confirm: function () {
                    $.get("/Azure/StartIntuneDeviceTask", { organization: organization, task: task, id: id, name: name }, function (data) {
                        var json = JSON.parse(data);
                        if (json.Failure) {
                            $.confirm({
                                theme: 'light',
                                type: 'red',
                                typeAnimated: true,
                                title: 'WARNING:',
                                content: 'Failed with data:' + data + ' And json ' + json +
                                         'status: ' + data.Status,
                                buttons: {
                                    OK: function () {
                                    },
                                }
                            });
                        }
                        else {
                            if (json == null) {
                                $.confirm({
                                    theme: 'light',
                                    type: 'red',
                                    typeAnimated: true,
                                    title: 'WARNING:',
                                    content: 'data is null',
                                    buttons: {
                                        OK: function () {
                                        },
                                    }
                                });
                            }
                            else {
                                if (json.Status == "Success") {
                                    $.confirm({
                                        theme: 'light',
                                        type: 'green',
                                        typeAnimated: true,
                                        title: 'INFO:',
                                        content: '<p>ID: ' + id + '</p>' +
                                                 '<p>Name: ' + name + '</p>' +
                                                 '<br />' +
                                                 '<p>Has been scheduled for <b>' + task + '</b></p>',
                                        buttons: {
                                            OK: function () {
                                            },
                                        }
                                    });
                                }
                                if (json.Status == "Error") {
                                    $.confirm({
                                        theme: 'light',
                                        type: 'red',
                                        typeAnimated: true,
                                        title: 'WARNING:',
                                        content: json.Status,
                                        buttons: {
                                            OK: function () {
                                            },
                                        }
                                    });
                                }
                            }
                        }
                        $('.loading').hide();
                    });
                },
                cancel: function () {
                    $('.loading').hide();
                },
            }
        });
    }
}

function GetAzureOverview() {
    $('.loading').show();

    $("#AzureVMS").hide();
    $("#AzureSecurityCenter").hide();
    $("#intuneoverview").hide();
    $("#AzureIntuneDevice").hide();
    $("#AzureIntuneComplianceOverview").hide();

    var organization = $("select[name=organization]").val();
    $.get("/Azure/GetCustomerConf?organization=" + organization, function (data) {

        var json = JSON.parse(data);

        for (i = 0; i < json.length; i++) {

            if (json[i].ServiceCompute == "True") {
                
                GetAzureVM(function () {
                    $("#AzureVMS").fadeIn({ queue: false, duration: 'slow' });
                    $('.loading').hide();
                });
                
                GetAzureSecurityCenter(function () {
                    $("#AzureSecurityCenter").fadeIn({ queue: false, duration: 'slow' });
                    $('.loading').hide();
                });
            }
            else {
                $('.loading').hide();
                $("#AzureVMS").html("<span class='warning2'>Azure Compute not enabled in Configuration</span>");
                $("#AzureVMS").fadeIn({ queue: false, duration: 'slow' });
            }
            if (json[i].ServiceIntune == "True") {

                GetIntuneOverview(function () {
                    $('#intuneoverview').fadeIn({ queue: false, duration: 'slow' });
                    $('.loading').hide();
                });
                GetAzureIntuneDevice(function () {
                    $('#AzureIntuneDevice').fadeIn({ queue: false, duration: 'slow' });
                    $('.loading').hide();
                });
                GetAzureIntunePolicyOverview(function () {
                    $('#AzureIntuneComplianceOverview').fadeIn({ queue: false, duration: 'slow' });
                    $('.loading').hide();
                });
            }
            else {
                $('.loading').hide();
                $("#intuneoverview").html("<span class='warning2'>Intune not enabled in Configuration</span>");
                $('#intuneoverview').fadeIn({ queue: false, duration: 'slow' });
            }
        }
    });

}


function AddAzureRessourceGroupToList(json, selectElement) {

    var selected = '';
    if (json == '') {
        selectElement.append('<option>It appears there are no RessourceGroups in the tenant..</option>');
    }
    else {
        selectElement.append('<option value="' + json.Name + '"' + selected + '>' + json.Name + ' - ' + ' [' + json.Location + ']</option>');
    }

}
function GetAzureRessourceGroups(selectElement) {
    if (!selectElement) {
        selectElement = $("select[name=ressourcegroup]");
    }

    var organization = $("select[name=organization]").val();
    selectElement.html('<option>Contacting Azure... please be patient..</option>');

    $.get("/Azure/GetAzureRessourceGroups", { organization: organization }, function (data) {
        selectElement.html('');

        var json = JSON.parse(data);
        if (json.Failure) {
            AddError(json);
        }
        else {
            selectElement.html("");
            if (json.length == null) {
                AddAzureRessourceGroupToList(json, selectElement);
            }
            else {
                for (i = 0; i < json.length; i++) {
                    AddAzureRessourceGroupToList(json[i], selectElement);
                }
            }
        }
        selectElement.change();
    });
}

function AddAzureStorageAccountToList(json, selectElement) {

    var selected = '';
    if (json == '') {
        selectElement.append('<option>It appears there are no StorageAccounts in the tenant..</option>');
    }
    else {
        selectElement.append('<option value="' + json.Name + '"' + selected + '>' + json.Name + ' - ' + ' [' + json.Location + ']</option>');
    }

}
function GetAzureStorageAccounts(selectElement) {
    if (!selectElement) {
        selectElement = $("select[name=storageaccount]");
    }
    var organization = $("select[name=organization]").val();
    var ressourcegroupname = $("select[name=ressourcegroup]").val();

    selectElement.html('<option>Contacting Azure... please be patient..</option>');

    $.get("/Azure/GetAzureStorageAccounts", { organization: organization, ressourcegroupname: ressourcegroupname }, function (data) {
        selectElement.html('');

        var json = JSON.parse(data);
        if (json.Failure) {
            AddError(json);
        }
        else {
            selectElement.html("");
            if (json.length == null) {
                AddAzureStorageAccountToList(json, selectElement);
            }
            else {
                for (i = 0; i < json.length; i++) {
                    AddAzureStorageAccountToList(json[i], selectElement);
                }
            }
        }
        selectElement.change();
    });
}

function AddAzureVirtualNetworksToList(json, selectElement) {

    var selected = '';
    if (json == '') {
        selectElement.append('<option>It appears there are no Virtual Networks in the tenant..</option>');
    }
    else {
        selectElement.append('<option value="' + json.Name + '"' + selected + '>' + json.Name + ' - ' + ' [' + json.Location + ']</option>');
    }

}
function GetAzureVirtualNetworks(selectElement) {
    if (!selectElement) {
        selectElement = $("select[name=virtualnetwork]");
    }
    var organization = $("select[name=organization]").val();
    var ressourcegroupname = $("select[name=ressourcegroup]").val();

    selectElement.html('<option>Contacting Azure... please be patient..</option>');

    $.get("/Azure/GetAzureVirtualNetworks", { organization: organization, ressourcegroupname: ressourcegroupname }, function (data) {
        selectElement.html('');

        var json = JSON.parse(data);
        if (json.Failure) {
            AddError(json);
        }
        else {
            selectElement.html("");
            if (json.length == null) {
                AddAzureVirtualNetworksToList(json, selectElement);
            }
            else {
                for (i = 0; i < json.length; i++) {
                    AddAzureVirtualNetworksToList(json[i], selectElement);
                }
            }
        }
        selectElement.change();
    });
}

function AddAzureAvailabilitySetsToList(json, selectElement) {

    var selected = '';
    if (json == '') {
        selectElement.append('<option>It appears there are no AvailabilitySets in the tenant..</option>');
    }
    else {
        selectElement.append('<option value="' + json.Name + '"' + selected + '>' + json.Name + ' - ' + json.Sku + ' [' + json.Location + ']</option>');
    }

}
function GetAzureAvailabilitySets(selectElement) {
    if (!selectElement) {
        selectElement = $("select[name=availabilityset]");
    }
    var organization = $("select[name=organization]").val();
    var ressourcegroupname = $("select[name=ressourcegroup]").val();

    selectElement.html('<option>Contacting Azure... please be patient..</option>');

    $.get("/Azure/GetAzureAvailabilitySets", { organization: organization, ressourcegroupname: ressourcegroupname }, function (data) {
        selectElement.html('');

        var json = JSON.parse(data);
        if (json.Failure) {
            AddError(json);
        }
        else {
            selectElement.html("");
            if (json.length == null) {
                AddAzureAvailabilitySetsToList(json, selectElement);
            }
            else {
                for (i = 0; i < json.length; i++) {
                    AddAzureAvailabilitySetsToList(json[i], selectElement);
                }
            }
        }
        selectElement.change();
    });
}

function AddAzureVMSizesToList(json, selectElement) {

    var selected = '';
    if (json == '') {
        selectElement.append('<option>It appears there are no AvailabilitySets in the tenant..</option>');
    }
    else {
        selectElement.append('<option value="' + json.name + '"' + selected + '>' + json.name + ' - [ CPU:' + json.numberOfCores + ' - RAM:' + json.memoryInMB + ' ]</option>');
    }

}
function GetAzureVMSizes(selectElement) {
    if (!selectElement) {
        selectElement = $("select[name=vmsize]");
    }
    var organization = $("select[name=organization]").val();

    selectElement.html('<option>Contacting Azure... please be patient..</option>');

    $.get("/Azure/GetAzureVMSizes", { organization: organization }, function (data) {
        selectElement.html('');

        var json = JSON.parse(data);
        if (json.Failure) {
            AddError(json);
        }
        else {
            selectElement.html("");
            if (json.length == null) {
                AddAzureVMSizesToList(json, selectElement);
            }
            else {
                for (i = 0; i < json.length; i++) {
                    AddAzureVMSizesToList(json[i], selectElement);
                }
            }
        }
        selectElement.change();
    });
}

function AddAzureLocationsToList(json, selectElement) {

    var selected = '';
    if (json == '') {
        selectElement.append('<option>It appears there are no AvailabilitySets in the tenant..</option>');
    }
    else {
        selectElement.append('<option value="' + json.name + '"' + selected + '>' + json.displayName + '</option>');
    }

}
function GetAzureLocations(selectElement) {
    if (!selectElement) {
        selectElement = $("select[name=location]");
    }
    var organization = $("select[name=organization]").val();

    selectElement.html('<option>Contacting Azure... please be patient..</option>');

    $.get("/Azure/GetAzureLocations", { organization: organization }, function (data) {
        selectElement.html('');

        var json = JSON.parse(data);
        if (json.Failure) {
            AddError(json);
        }
        else {
            selectElement.html("");
            if (json.length == null) {
                AddAzureLocationsToList(json, selectElement);
            }
            else {
                for (i = 0; i < json.length; i++) {
                    AddAzureLocationsToList(json[i], selectElement);
                }
            }
        }
        selectElement.change();
    });
}

function AddAzureVirtualSubnetsToList(json, selectElement) {

    var selected = '';
    if (json == '') {
        selectElement.append('<option>It appears there are no AvailabilitySets in the tenant..</option>');
    }
    else {
        selectElement.append('<option value="' + json.Id + '"' + selected + '>' + json.Name + ' - [ ' + json.AddressPrefix + ' ]</option>');
    }

}
function GetAzureVirtualSubnets(selectElement) {
    if (!selectElement) {
        selectElement = $("select[name=subnet]");
    }
    var organization = $("select[name=organization]").val();
    var ressourcegroupname = $("select[name=ressourcegroup]").val();
    var name = $("select[name=virtualnetwork]").val();

    selectElement.html('<option>Contacting Azure... please be patient..</option>');

    $.get("/Azure/GetAzureVirtualSubnets", { organization: organization, name: name, ressourcegroupname: ressourcegroupname }, function (data) {
        selectElement.html('');

        var json = JSON.parse(data);
        if (json.Failure) {
            AddError(json);
        }
        else {
            selectElement.html("");
            if (json.length == null) {
                AddAzureVirtualSubnetsToList(json, selectElement);
            }
            else {
                for (i = 0; i < json.length; i++) {
                    AddAzureVirtualSubnetsToList(json[i], selectElement);
                }
            }
        }
        selectElement.change();
    });
}

function AddAzurePublicIPsToList(json, selectElement) {

    var selected = '';
    if (json == '') {
        selectElement.append('<option>It appears there are no PublicIPs in the tenant..</option>');
    }
    else {
        selectElement.append('<option value="' + json.Id + '"' + selected + '>' + json.Name + ' - [ ' + json.AllocationMethod + ' ]</option>');
    }

}
function GetAzurePublicIPs(selectElement) {
    if (!selectElement) {
        selectElement = $("select[name=publicip]");
    }
    var organization = $("select[name=organization]").val();
    var location = $("select[name=location]").val();

    selectElement.html('<option>Contacting Azure... please be patient..</option>');

    $.get("/Azure/GetAzurePublicIPs", { organization: organization, location: location }, function (data) {
        selectElement.html('');

        var json = JSON.parse(data);
        if (json.Failure) {
            AddError(json);
        }
        else {
            selectElement.html("");
            if (json.length == null) {
                AddAzurePublicIPsToList(json, selectElement);
            }
            else {
                for (i = 0; i < json.length; i++) {
                    AddAzurePublicIPsToList(json[i], selectElement);
                }
            }
        }
        selectElement.change();
    });
}

function AddAzureNetworkInterfacesToList(json, selectElement) {

    var selected = '';
    if (json == '') {
        selectElement.append('<option>It appears there are no Networkinterfaces in the tenant..</option>');
    }
    else {
        selectElement.append('<option value="' + json.Id + '"' + selected + '>' + json.Name + ' - [ ' + json.Location + ' ]</option>');
    }

}
function GetAzureNetworkInterfaces(selectElement) {
    if (!selectElement) {
        selectElement = $("select[name=networkinterface]");
    }
    var organization = $("select[name=organization]").val();
    var ressourcegroupname = $("select[name=ressourcegroup]").val();

    selectElement.html('<option>Contacting Azure... please be patient..</option>');

    $.get("/Azure/GetAzureNetworkInterfaces", { organization: organization, ressourcegroupname: ressourcegroupname }, function (data) {
        selectElement.html('');

        var json = JSON.parse(data);
        if (json.Failure) {
            AddError(json);
        }
        else {
            selectElement.html("");
            if (json.length == null) {
                AddAzureNetworkInterfacesToList(json, selectElement);
            }
            else {
                for (i = 0; i < json.length; i++) {
                    AddAzureNetworkInterfacesToList(json[i], selectElement);
                }
            }
        }
        selectElement.change();
    });
}

function AddAzureIntuneDeviceConfigurationsToList(json, selectElement) {

    var selected = '';
    if (json == '') {
        selectElement.append('<option>It appears there are no deviceconfs in the tenant..</option>');
    }
    else {
        selectElement.append('<option value="' + json.id + '"' + selected + '>' + json.displayName + '</option>');
    }

}
function GetAzureIntuneDeviceConfiguration(selectElement) {
    if (!selectElement) {
        selectElement = $("select[name=deviceconf]");
    }
    var organization = $("select[name=organization]").val();

    selectElement.html('<option>Contacting Azure... please be patient..</option>');

    $.get("/Azure/GetAzureIntuneDeviceConfiguration", { organization: organization }, function (data) {
        selectElement.html('');

        var json = JSON.parse(data);
        if (json.Failure) {
            AddError(json);
        }
        else {
            selectElement.html("");
            if (json.length == null) {
                AddAzureIntuneDeviceConfigurationsToList(json, selectElement);
            }
            else {
                for (i = 0; i < json.length; i++) {
                    AddAzureIntuneDeviceConfigurationsToList(json[i], selectElement);
                }
            }
        }
        selectElement.change();
    });
}

function GetAzureIntuneDeviceConfigurationsettings() {
    $('.loading').show();
    var organization = $("select[name=organization]").val();
    var deviceconf = $("select[name=deviceconf]").val();

    $.get("/Azure/GetAzureIntuneDeviceConfiguration", { organization: organization, id: deviceconf }, function (data) {

        var json = JSON.parse(data);

        for (i = 0; i < json.length; i++) {
            // Create change event
            var platform = document.getElementById('platform');
            platform.value = json[i].platform;
            var event = new Event('change');
            platform.dispatchEvent(event);

            if (json[i].platform == "Android") {

                var password = document.getElementById('passwordRequired');
                password.value = json[i].passwordRequired;
                var event = new Event('change');
                password.dispatchEvent(event);

                document.getElementById("description").value = json[i].description;
                document.getElementById("displayName").value = json[i].displayName;
                document.getElementById("appsBlockClipboardSharing").value = json[i].appsBlockClipboardSharing;
                document.getElementById("appsBlockCopyPaste").value = json[i].appsBlockCopyPaste;
                document.getElementById("appsBlockYouTube").value = json[i].appsBlockYouTube;
                document.getElementById("bluetoothBlocked").value = json[i].bluetoothBlocked;
                document.getElementById("cameraBlocked").value = json[i].cameraBlocked;
                document.getElementById("cellularBlockDataRoaming").value = json[i].cellularBlockDataRoaming;
                document.getElementById("cellularBlockMessaging").value = json[i].cellularBlockMessaging;
                document.getElementById("cellularBlockVoiceRoaming").value = json[i].cellularBlockVoiceRoaming;
                document.getElementById("cellularBlockWiFiTethering").value = json[i].cellularBlockWiFiTethering;
                document.getElementById("locationServicesBlocked").value = json[i].locationServicesBlocked;
                document.getElementById("googleAccountBlockAutoSync").value = json[i].googleAccountBlockAutoSync;
                document.getElementById("googlePlayStoreBlocked").value = json[i].googlePlayStoreBlocked;
                document.getElementById("nfcBlocked").value = json[i].nfcBlocked;
                document.getElementById("passwordRequired").value = json[i].passwordRequired;                
                if (json[i].passwordMinimumLength != "null") { document.getElementById("passwordMinimumLength").value = json[i].passwordMinimumLength;}
                if (json[i].passwordRequiredType != "null") { document.getElementById("passwordRequiredType").value = json[i].passwordRequiredType;}
                if (json[i].passwordExpirationDays != "null") { document.getElementById("passwordExpirationDays").value = json[i].passwordExpirationDays;}
                if (json[i].passwordMinutesOfInactivityBeforeScreenTimeout != "null") { document.getElementById("passwordMinutesOfInactivityBeforeScreenTimeout").value = json[i].passwordMinutesOfInactivityBeforeScreenTimeout;}
                if (json[i].passwordPreviousPasswordBlockCount != "null") { document.getElementById("passwordPreviousPasswordBlockCount").value = json[i].passwordPreviousPasswordBlockCount;}
                if (json[i].passwordSignInFailureCountBeforeFactoryReset != "null") { document.getElementById("passwordSignInFailureCountBeforeFactoryReset").value = json[i].passwordSignInFailureCountBeforeFactoryReset;}
                if (json[i].passwordBlockFingerprintUnlock != "null") { document.getElementById("passwordBlockFingerprintUnlock").value = json[i].passwordBlockFingerprintUnlock;}
                if (json[i].passwordBlockTrustAgents != "null") { document.getElementById("passwordBlockTrustAgents").value = json[i].passwordBlockTrustAgents;}
                document.getElementById("factoryResetBlocked").value = json[i].factoryResetBlocked;
                document.getElementById("powerOffBlocked").value = json[i].powerOffBlocked;
                document.getElementById("screenCaptureBlocked").value = json[i].screenCaptureBlocked;
                document.getElementById("deviceSharingAllowed").value = json[i].deviceSharingAllowed;
                document.getElementById("storageBlockGoogleBackup").value = json[i].storageBlockGoogleBackup;
                document.getElementById("storageBlockRemovableStorage").value = json[i].storageBlockRemovableStorage;
                document.getElementById("storageRequireDeviceEncryption").value = json[i].storageRequireDeviceEncryption;
                document.getElementById("storageRequireRemovableStorageEncryption").value = json[i].storageRequireRemovableStorageEncryption;
                document.getElementById("voiceAssistantBlocked").value = json[i].voiceAssistantBlocked;
                document.getElementById("voiceDialingBlocked").value = json[i].voiceDialingBlocked;
                document.getElementById("webBrowserBlockPopups").value = json[i].webBrowserBlockPopups;
                document.getElementById("webBrowserBlockAutofill").value = json[i].webBrowserBlockAutofill;
                document.getElementById("webBrowserBlockJavaScript").value = json[i].webBrowserBlockJavaScript;
                document.getElementById("webBrowserBlocked").value = json[i].webBrowserBlocked;
                document.getElementById("webBrowserCookieSettings").value = json[i].webBrowserCookieSettings;
                document.getElementById("wiFiBlocked").value = json[i].wiFiBlocked;
            }
            if (json[i].platform == "AFW") {
                document.getElementById("description").value = json[i].description;
                document.getElementById("displayName").value = json[i].displayName;
                document.getElementById("workProfileDataSharingType").value = json[i].workProfileDataSharingType;
                document.getElementById("workProfileBlockNotificationsWhileDeviceLocked").value = json[i].workProfileBlockNotificationsWhileDeviceLocked;
                document.getElementById("workProfileDefaultAppPermissionPolicy").value = json[i].workProfileDefaultAppPermissionPolicy;

                var password = document.getElementById('workProfileRequirePassword');
                password.value = json[i].workProfileRequirePassword;
                var event = new Event('change');
                password.dispatchEvent(event);

                if (json[i].workProfilePasswordMinimumLength != "null") { document.getElementById("workProfilePasswordMinimumLength").value = json[i].workProfilePasswordMinimumLength; }
                if (json[i].workProfilePasswordMinutesOfInactivityBeforeScreenTimeout != "null") { document.getElementById("workProfilePasswordMinutesOfInactivityBeforeScreenTimeout").value = json[i].workProfilePasswordMinutesOfInactivityBeforeScreenTimeout; }
                if (json[i].workProfilePasswordSignInFailureCountBeforeFactoryReset != "null") { document.getElementById("workProfilePasswordSignInFailureCountBeforeFactoryReset").value = json[i].workProfilePasswordSignInFailureCountBeforeFactoryReset; }
                if (json[i].workProfilePasswordExpirationDays != "null") { document.getElementById("workProfilePasswordExpirationDays").value = json[i].workProfilePasswordExpirationDays; }
                document.getElementById("workProfilePasswordRequiredType").value = json[i].workProfilePasswordRequiredType;
                if (json[i].workProfilePasswordPreviousPasswordBlockCount != "null") { document.getElementById("workProfilePasswordPreviousPasswordBlockCount").value = json[i].workProfilePasswordPreviousPasswordBlockCount; }
                document.getElementById("workProfilePasswordBlockFingerprintUnlock").value = json[i].workProfilePasswordBlockFingerprintUnlock;
                document.getElementById("workProfilePasswordBlockTrustAgents").value = json[i].workProfilePasswordBlockTrustAgents;

                if (json[i].afwpasswordMinimumLength != "null") { document.getElementById("afwpasswordMinimumLength").value = json[i].afwpasswordMinimumLength; }
                if (json[i].afwpasswordMinutesOfInactivityBeforeScreenTimeout != "null") { document.getElementById("afwpasswordMinutesOfInactivityBeforeScreenTimeout").value = json[i].afwpasswordMinutesOfInactivityBeforeScreenTimeout; }
                if (json[i].afwpasswordSignInFailureCountBeforeFactoryReset != "null") { document.getElementById("afwpasswordSignInFailureCountBeforeFactoryReset").value = json[i].afwpasswordSignInFailureCountBeforeFactoryReset; }
                if (json[i].afwpasswordExpirationDays != "null") { document.getElementById("afwpasswordExpirationDays").value = json[i].afwpasswordExpirationDays; }
                if (json[i].afwpasswordPreviousPasswordBlockCount != "null") { document.getElementById("afwpasswordPreviousPasswordBlockCount").value = json[i].afwpasswordPreviousPasswordBlockCount; }
                document.getElementById("afwpasswordRequiredType").value = json[i].afwpasswordRequiredType;
                document.getElementById("afwpasswordBlockFingerprintUnlock").value = json[i].afwpasswordBlockFingerprintUnlock;
                document.getElementById("afwpasswordBlockTrustAgents").value = json[i].afwpasswordBlockTrustAgents;
            }
            if (json[i].platform == "IOS") {

                var passcode = document.getElementById('passcodeRequired');
                passcode.value = json[i].passcodeRequired;
                var event = new Event('change');
                passcode.dispatchEvent(event);

                document.getElementById("description").value = json[i].description;
                document.getElementById("displayName").value = json[i].displayName;
                document.getElementById("accountBlockModification").value = json[i].accountBlockModification;
                document.getElementById("activationLockAllowWhenSupervised").value = json[i].activationLockAllowWhenSupervised;
                document.getElementById("airDropBlocked").value = json[i].airDropBlocked;
                document.getElementById("airDropForceUnmanagedDropTarget").value = json[i].airDropForceUnmanagedDropTarget;
                document.getElementById("airPlayForcePairingPasswordForOutgoingRequests").value = json[i].airPlayForcePairingPasswordForOutgoingRequests;
                document.getElementById("appleWatchBlockPairing").value = json[i].appleWatchBlockPairing;
                document.getElementById("appleWatchForceWristDetection").value = json[i].appleWatchForceWristDetection;
                document.getElementById("appleNewsBlocked").value = json[i].appleNewsBlocked;
                document.getElementById("appStoreBlockAutomaticDownloads").value = json[i].appStoreBlockAutomaticDownloads;
                document.getElementById("appStoreBlocked").value = json[i].appStoreBlocked;
                document.getElementById("appStoreBlockInAppPurchases").value = json[i].appStoreBlockInAppPurchases;
                document.getElementById("appStoreBlockUIAppInstallation").value = json[i].appStoreBlockUIAppInstallation;
                document.getElementById("appStoreRequirePassword").value = json[i].appStoreRequirePassword;
                document.getElementById("bluetoothBlockModification").value = json[i].bluetoothBlockModification;
                document.getElementById("ioscameraBlocked").value = json[i].cameraBlocked;
                document.getElementById("ioscellularBlockDataRoaming").value = json[i].cellularBlockDataRoaming;
                document.getElementById("cellularBlockGlobalBackgroundFetchWhileRoaming").value = json[i].cellularBlockGlobalBackgroundFetchWhileRoaming;
                document.getElementById("cellularBlockPerAppDataModification").value = json[i].cellularBlockPerAppDataModification;
                document.getElementById("cellularBlockPersonalHotspot").value = json[i].cellularBlockPersonalHotspot;
                document.getElementById("ioscellularBlockVoiceRoaming").value = json[i].cellularBlockVoiceRoaming;
                document.getElementById("certificatesBlockUntrustedTlsCertificates").value = json[i].certificatesBlockUntrustedTlsCertificates;
                document.getElementById("classroomAppBlockRemoteScreenObservation").value = json[i].classroomAppBlockRemoteScreenObservation;
                document.getElementById("classroomAppForceUnpromptedScreenObservation").value = json[i].classroomAppForceUnpromptedScreenObservation;
                document.getElementById("configurationProfileBlockChanges").value = json[i].configurationProfileBlockChanges;
                document.getElementById("definitionLookupBlocked").value = json[i].definitionLookupBlocked;
                document.getElementById("deviceBlockEnableRestrictions").value = json[i].deviceBlockEnableRestrictions;
                document.getElementById("deviceBlockEraseContentAndSettings").value = json[i].deviceBlockEraseContentAndSettings;
                document.getElementById("deviceBlockNameModification").value = json[i].deviceBlockNameModification;
                document.getElementById("diagnosticDataBlockSubmission").value = json[i].diagnosticDataBlockSubmission;
                document.getElementById("diagnosticDataBlockSubmissionModification").value = json[i].diagnosticDataBlockSubmissionModification;
                document.getElementById("documentsBlockManagedDocumentsInUnmanagedApps").value = json[i].documentsBlockManagedDocumentsInUnmanagedApps;
                document.getElementById("documentsBlockUnmanagedDocumentsInManagedApps").value = json[i].documentsBlockUnmanagedDocumentsInManagedApps;
                document.getElementById("enterpriseAppBlockTrust").value = json[i].enterpriseAppBlockTrust;
                document.getElementById("enterpriseAppBlockTrustModification").value = json[i].enterpriseAppBlockTrustModification;
                document.getElementById("faceTimeBlocked").value = json[i].faceTimeBlocked;
                document.getElementById("findMyFriendsBlocked").value = json[i].findMyFriendsBlocked;
                document.getElementById("gamingBlockGameCenterFriends").value = json[i].gamingBlockGameCenterFriends;
                document.getElementById("gamingBlockMultiplayer").value = json[i].gamingBlockMultiplayer;
                document.getElementById("gameCenterBlocked").value = json[i].gameCenterBlocked;
                document.getElementById("hostPairingBlocked").value = json[i].hostPairingBlocked;
                document.getElementById("iBooksStoreBlocked").value = json[i].iBooksStoreBlocked;
                document.getElementById("iBooksStoreBlockErotica").value = json[i].iBooksStoreBlockErotica;
                document.getElementById("iCloudBlockActivityContinuation").value = json[i].iCloudBlockActivityContinuation;
                document.getElementById("iCloudBlockBackup").value = json[i].iCloudBlockBackup;
                document.getElementById("iCloudBlockDocumentSync").value = json[i].iCloudBlockDocumentSync;
                document.getElementById("iCloudBlockManagedAppsSync").value = json[i].iCloudBlockManagedAppsSync;
                document.getElementById("iCloudBlockPhotoLibrary").value = json[i].iCloudBlockPhotoLibrary;
                document.getElementById("iCloudBlockPhotoStreamSync").value = json[i].iCloudBlockPhotoStreamSync;
                document.getElementById("iCloudBlockSharedPhotoStream").value = json[i].iCloudBlockSharedPhotoStream;
                document.getElementById("iCloudRequireEncryptedBackup").value = json[i].iCloudRequireEncryptedBackup;
                document.getElementById("iTunesBlockExplicitContent").value = json[i].iTunesBlockExplicitContent;
                document.getElementById("iTunesBlockMusicService").value = json[i].iTunesBlockMusicService;
                document.getElementById("iTunesBlockRadio").value = json[i].iTunesBlockRadio;
                document.getElementById("keyboardBlockAutoCorrect").value = json[i].keyboardBlockAutoCorrect;
                document.getElementById("keyboardBlockDictation").value = json[i].keyboardBlockDictation;
                document.getElementById("keyboardBlockPredictive").value = json[i].keyboardBlockPredictive;
                document.getElementById("keyboardBlockShortcuts").value = json[i].keyboardBlockShortcuts;
                document.getElementById("keyboardBlockSpellCheck").value = json[i].keyboardBlockSpellCheck;
                document.getElementById("lockScreenBlockControlCenter").value = json[i].lockScreenBlockControlCenter;
                document.getElementById("lockScreenBlockNotificationView").value = json[i].lockScreenBlockNotificationView;
                document.getElementById("lockScreenBlockPassbook").value = json[i].lockScreenBlockPassbook;
                document.getElementById("lockScreenBlockTodayView").value = json[i].lockScreenBlockTodayView;
                document.getElementById("mediaContentRatingApps").value = json[i].mediaContentRatingApps;
                document.getElementById("messagesBlocked").value = json[i].messagesBlocked;
                document.getElementById("notificationsBlockSettingsModification").value = json[i].notificationsBlockSettingsModification;
                document.getElementById("passcodeBlockFingerprintUnlock").value = json[i].passcodeBlockFingerprintUnlock;
                document.getElementById("passcodeBlockFingerprintModification").value = json[i].passcodeBlockFingerprintModification;
                document.getElementById("passcodeBlockModification").value = json[i].passcodeBlockModification;
                document.getElementById("passcodeBlockSimple").value = json[i].passcodeBlockSimple;
                if (json[i].passcodeMinimumLength != "null") { document.getElementById("passcodeMinimumLength").value = json[i].passcodeMinimumLength; }
                if (json[i].passcodeExpirationDays != "null") { document.getElementById("passcodeExpirationDays").value = json[i].passcodeExpirationDays; }
                if (json[i].passcodeMinutesOfInactivityBeforeScreenTimeout != "null") { document.getElementById("passcodeMinutesOfInactivityBeforeScreenTimeout").value = json[i].passcodeMinutesOfInactivityBeforeScreenTimeout; }
                if (json[i].passcodePreviousPasscodeBlockCount != "null") { document.getElementById("passcodePreviousPasscodeBlockCount").value = json[i].passcodePreviousPasscodeBlockCount; }
                if (json[i].passcodeSignInFailureCountBeforeWipe != "null") { document.getElementById("passcodeSignInFailureCountBeforeWipe").value = json[i].passcodeSignInFailureCountBeforeWipe; }
                if (json[i].passcodeMinimumCharacterSetCount != "null") { document.getElementById("passcodeMinimumCharacterSetCount").value = json[i].passcodeMinimumCharacterSetCount; }
                if (json[i].passcodeMinutesOfInactivityBeforeLock != "null") { document.getElementById("passcodeMinutesOfInactivityBeforeLock").value = json[i].passcodeMinutesOfInactivityBeforeLock; }
                document.getElementById("passcodeRequiredType").value = json[i].passcodeRequiredType;
                //document.getElementById("passcodeRequired").value = json[i].passcodeRequired;
                document.getElementById("podcastsBlocked").value = json[i].podcastsBlocked;
                document.getElementById("safariBlockAutofill").value = json[i].safariBlockAutofill;
                document.getElementById("safariBlockJavaScript").value = json[i].safariBlockJavaScript;
                document.getElementById("safariBlockPopups").value = json[i].safariBlockPopups;
                document.getElementById("safariBlocked").value = json[i].safariBlocked;
                document.getElementById("safariCookieSettings").value = json[i].safariCookieSettings;
                document.getElementById("safariRequireFraudWarning").value = json[i].safariRequireFraudWarning;
                document.getElementById("iosscreenCaptureBlocked").value = json[i].screenCaptureBlocked;
                document.getElementById("siriBlocked").value = json[i].siriBlocked;
                document.getElementById("siriBlockedWhenLocked").value = json[i].siriBlockedWhenLocked;
                document.getElementById("siriBlockUserGeneratedContent").value = json[i].siriBlockUserGeneratedContent;
                document.getElementById("siriRequireProfanityFilter").value = json[i].siriRequireProfanityFilter;
                document.getElementById("spotlightBlockInternetResults").value = json[i].spotlightBlockInternetResults;
                document.getElementById("iosvoiceDialingBlocked").value = json[i].voiceDialingBlocked;
                document.getElementById("wallpaperBlockModification").value = json[i].wallpaperBlockModification;
                document.getElementById("wiFiConnectOnlyToConfiguredNetworks").value = json[i].wiFiConnectOnlyToConfiguredNetworks;
            }
            if (json[i].platform == "Win10") {
                var password = document.getElementById('winpasswordRequired');
                password.value = json[i].winpasswordRequired;
                var event = new Event('change');
                password.dispatchEvent(event);

                var edgeSearchEngine = document.getElementById('edgeSearchEngine');
                edgeSearchEngine.value = json[i].edgeSearchEngine;
                var event = new Event('change');
                edgeSearchEngine.dispatchEvent(event);

                document.getElementById("description").value = json[i].description;
                document.getElementById("displayName").value = json[i].displayName;
                document.getElementById("winscreenCaptureBlocked").value = json[i].winscreenCaptureBlocked;
                document.getElementById("copyPasteBlocked").value = json[i].copyPasteBlocked;
                document.getElementById("deviceManagementBlockManualUnenroll").value = json[i].deviceManagementBlockManualUnenroll;
                document.getElementById("certificatesBlockManualRootCertificateInstallation").value = json[i].certificatesBlockManualRootCertificateInstallation;
                document.getElementById("wincameraBlocked").value = json[i].wincameraBlocked;
                document.getElementById("oneDriveDisableFileSync").value = json[i].oneDriveDisableFileSync;
                document.getElementById("winstorageBlockRemovableStorage").value = json[i].winstorageBlockRemovableStorage;
                document.getElementById("winlocationServicesBlocked").value = json[i].winlocationServicesBlocked;
                document.getElementById("internetSharingBlocked").value = json[i].internetSharingBlocked;
                document.getElementById("deviceManagementBlockFactoryResetOnMobile").value = json[i].deviceManagementBlockFactoryResetOnMobile;
                document.getElementById("usbBlocked").value = json[i].usbBlocked;
                document.getElementById("antiTheftModeBlocked").value = json[i].antiTheftModeBlocked;
                document.getElementById("cortanaBlocked").value = json[i].cortanaBlocked;
                document.getElementById("voiceRecordingBlocked").value = json[i].voiceRecordingBlocked;
                document.getElementById("settingsBlockEditDeviceName").value = json[i].settingsBlockEditDeviceName;
                document.getElementById("settingsBlockAddProvisioningPackage").value = json[i].settingsBlockAddProvisioningPackage;
                document.getElementById("settingsBlockRemoveProvisioningPackage").value = json[i].settingsBlockRemoveProvisioningPackage;
                document.getElementById("experienceBlockDeviceDiscovery").value = json[i].experienceBlockDeviceDiscovery;
                document.getElementById("experienceBlockTaskSwitcher").value = json[i].experienceBlockTaskSwitcher;
                document.getElementById("experienceBlockErrorDialogWhenNoSIM").value = json[i].experienceBlockErrorDialogWhenNoSIM;
                document.getElementById("winpasswordRequired").value = json[i].winpasswordRequired;
                document.getElementById("winpasswordRequiredType").value = json[i].winpasswordRequiredType;
                if (json[i].winpasswordMinimumLength != "null") {document.getElementById("winpasswordMinimumLength").value = json[i].winpasswordMinimumLength; }
                if (json[i].winpasswordMinutesOfInactivityBeforeScreenTimeout != "null") { document.getElementById("winpasswordMinutesOfInactivityBeforeScreenTimeout").value = json[i].winpasswordMinutesOfInactivityBeforeScreenTimeout; }
                if (json[i].winpasswordSignInFailureCountBeforeFactoryReset != "null") { document.getElementById("winpasswordSignInFailureCountBeforeFactoryReset").value = json[i].winpasswordSignInFailureCountBeforeFactoryReset; }
                if (json[i].winpasswordExpirationDays != "null") { document.getElementById("winpasswordExpirationDays").value = json[i].winpasswordExpirationDays; }
                if (json[i].winpasswordPreviousPasswordBlockCount != "null") { document.getElementById("winpasswordPreviousPasswordBlockCount").value = json[i].winpasswordPreviousPasswordBlockCount; }
                document.getElementById("winpasswordRequireWhenResumeFromIdleState").value = json[i].winpasswordRequireWhenResumeFromIdleState;
                document.getElementById("winpasswordBlockSimple").value = json[i].winpasswordBlockSimple;
                document.getElementById("storageRequireMobileDeviceEncryption").value = json[i].storageRequireMobileDeviceEncryption;
                if (json[i].personalizationDesktopImageUrl != "null") { document.getElementById("personalizationDesktopImageUrl").value = json[i].personalizationDesktopImageUrl; }
                document.getElementById("privacyBlockInputPersonalization").value = json[i].privacyBlockInputPersonalization;
                document.getElementById("privacyAutoAcceptPairingAndConsentPrompts").value = json[i].privacyAutoAcceptPairingAndConsentPrompts;
                document.getElementById("lockScreenBlockActionCenterNotifications").value = json[i].lockScreenBlockActionCenterNotifications;
                if (json[i].personalizationLockScreenImageUrl != "null") { document.getElementById("personalizationLockScreenImageUrl").value = json[i].personalizationLockScreenImageUrl; }
                document.getElementById("lockScreenAllowTimeoutConfiguration").value = json[i].lockScreenAllowTimeoutConfiguration;
                document.getElementById("lockScreenBlockCortana").value = json[i].lockScreenBlockCortana;
                document.getElementById("lockScreenBlockToastNotifications").value = json[i].lockScreenBlockToastNotifications;
                if (json[i].lockScreenTimeoutInSeconds != "null") { document.getElementById("lockScreenTimeoutInSeconds").value = json[i].lockScreenTimeoutInSeconds; }
                document.getElementById("windowsStoreBlocked").value = json[i].windowsStoreBlocked;
                document.getElementById("windowsStoreBlockAutoUpdate").value = json[i].windowsStoreBlockAutoUpdate;
                document.getElementById("appsAllowTrustedAppsSideloading").value = json[i].appsAllowTrustedAppsSideloading;
                document.getElementById("developerUnlockSetting").value = json[i].developerUnlockSetting;
                document.getElementById("sharedUserAppDataAllowed").value = json[i].sharedUserAppDataAllowed;
                document.getElementById("windowsStoreEnablePrivateStoreOnly").value = json[i].windowsStoreEnablePrivateStoreOnly;
                document.getElementById("appsBlockWindowsStoreOriginatedApps").value = json[i].appsBlockWindowsStoreOriginatedApps;
                document.getElementById("storageRestrictAppDataToSystemVolume").value = json[i].storageRestrictAppDataToSystemVolume;
                document.getElementById("storageRestrictAppInstallToSystemVolume").value = json[i].storageRestrictAppInstallToSystemVolume;
                document.getElementById("gameDvrBlocked").value = json[i].gameDvrBlocked;
                document.getElementById("smartScreenEnableAppInstallControl").value = json[i].smartScreenEnableAppInstallControl;
                document.getElementById("edgeBlocked").value = json[i].edgeBlocked;
                document.getElementById("edgeBlockAddressBarDropdown").value = json[i].edgeBlockAddressBarDropdown;
                document.getElementById("edgeSyncFavoritesWithInternetExplorer").value = json[i].edgeSyncFavoritesWithInternetExplorer;
                document.getElementById("edgeClearBrowsingDataOnExit").value = json[i].edgeClearBrowsingDataOnExit;
                document.getElementById("edgeBlockSendingDoNotTrackHeader").value = json[i].edgeBlockSendingDoNotTrackHeader;
                document.getElementById("edgeCookiePolicy").value = json[i].edgeCookiePolicy;
                document.getElementById("edgeBlockJavaScript").value = json[i].edgeBlockJavaScript;
                document.getElementById("edgeBlockPopups").value = json[i].edgeBlockPopups;
                document.getElementById("edgeBlockSearchSuggestions").value = json[i].edgeBlockSearchSuggestions;
                document.getElementById("edgeBlockSendingIntranetTrafficToInternetExplorer").value = json[i].edgeBlockSendingIntranetTrafficToInternetExplorer;
                document.getElementById("edgeBlockAutofill").value = json[i].edgeBlockAutofill;
                document.getElementById("edgeBlockPasswordManager").value = json[i].edgeBlockPasswordManager;
                if (json[i].edgeEnterpriseModeSiteListLocation != "null") { document.getElementById("edgeEnterpriseModeSiteListLocation").value = json[i].edgeEnterpriseModeSiteListLocation; }
                document.getElementById("edgeBlockDeveloperTools").value = json[i].edgeBlockDeveloperTools;
                document.getElementById("edgeBlockExtensions").value = json[i].edgeBlockExtensions;
                document.getElementById("edgeBlockInPrivateBrowsing").value = json[i].edgeBlockInPrivateBrowsing;
                document.getElementById("edgeDisableFirstRunPage").value = json[i].edgeDisableFirstRunPage;
                if (json[i].edgeFirstRunUrl != "null") { document.getElementById("edgeFirstRunUrl").value = json[i].edgeFirstRunUrl; }
                document.getElementById("edgeAllowStartPagesModification").value = json[i].edgeAllowStartPagesModification;
                document.getElementById("edgeBlockAccessToAboutFlags").value = json[i].edgeBlockAccessToAboutFlags;
                document.getElementById("webRtcBlockLocalhostIpAddress").value = json[i].webRtcBlockLocalhostIpAddress;
                if (json[i].edgeSearchEngine != "null") { document.getElementById("edgeSearchEngine").value = json[i].edgeSearchEngine; } else { document.getElementById("edgeSearchEngine").value = ""; }
                if (json[i].edgeCustomURL != "null") { document.getElementById("edgeCustomURL").value = json[i].edgeCustomURL; }
                document.getElementById("edgeBlockCompatibilityList").value = json[i].edgeBlockCompatibilityList;
                document.getElementById("edgeBlockLiveTileDataCollection").value = json[i].edgeBlockLiveTileDataCollection;
                document.getElementById("edgeRequireSmartScreen").value = json[i].edgeRequireSmartScreen;
                document.getElementById("smartScreenBlockPromptOverride").value = json[i].smartScreenBlockPromptOverride;
                document.getElementById("smartScreenBlockPromptOverrideForFiles").value = json[i].smartScreenBlockPromptOverrideForFiles;
                document.getElementById("safeSearchFilter").value = json[i].safeSearchFilter;
                document.getElementById("microsoftAccountBlocked").value = json[i].microsoftAccountBlocked;
                document.getElementById("accountsBlockAddingNonMicrosoftAccountEmail").value = json[i].accountsBlockAddingNonMicrosoftAccountEmail;
                document.getElementById("microsoftAccountBlockSettingsSync").value = json[i].microsoftAccountBlockSettingsSync;
                document.getElementById("cellularData").value = json[i].cellularData;
                document.getElementById("cellularBlockDataWhenRoaming").value = json[i].cellularBlockDataWhenRoaming;
                document.getElementById("cellularBlockVpn").value = json[i].cellularBlockVpn;
                document.getElementById("cellularBlockVpnWhenRoaming").value = json[i].cellularBlockVpnWhenRoaming;
                document.getElementById("winbluetoothBlocked").value = json[i].winbluetoothBlocked;
                document.getElementById("bluetoothBlockDiscoverableMode").value = json[i].bluetoothBlockDiscoverableMode;
                document.getElementById("bluetoothBlockPrePairing").value = json[i].bluetoothBlockPrePairing;
                document.getElementById("bluetoothBlockAdvertising").value = json[i].bluetoothBlockAdvertising;
                document.getElementById("connectedDevicesServiceBlocked").value = json[i].connectedDevicesServiceBlocked;
                document.getElementById("winnfcBlocked").value = json[i].winnfcBlocked;
                document.getElementById("winwiFiBlocked").value = json[i].winwiFiBlocked;
                document.getElementById("wiFiBlockAutomaticConnectHotspots").value = json[i].wiFiBlockAutomaticConnectHotspots;
                document.getElementById("wiFiBlockManualConfiguration").value = json[i].wiFiBlockManualConfiguration;
                if (json[i].wiFiScanInterval != "null") { document.getElementById("wiFiScanInterval").value = json[i].wiFiScanInterval; }
                document.getElementById("settingsBlockSettingsApp").value = json[i].settingsBlockSettingsApp;
                document.getElementById("settingsBlockSystemPage").value = json[i].settingsBlockSystemPage;
                document.getElementById("settingsBlockChangePowerSleep").value = json[i].settingsBlockChangePowerSleep;
                document.getElementById("settingsBlockDevicesPage").value = json[i].settingsBlockDevicesPage;
                document.getElementById("settingsBlockNetworkInternetPage").value = json[i].settingsBlockNetworkInternetPage;
                document.getElementById("settingsBlockPersonalizationPage").value = json[i].settingsBlockPersonalizationPage;
                document.getElementById("settingsBlockAppsPage").value = json[i].settingsBlockAppsPage;
                document.getElementById("settingsBlockAccountsPage").value = json[i].settingsBlockAccountsPage;
                document.getElementById("settingsBlockTimeLanguagePage").value = json[i].settingsBlockTimeLanguagePage;
                document.getElementById("settingsBlockChangeSystemTime").value = json[i].settingsBlockChangeSystemTime;
                document.getElementById("settingsBlockChangeRegion").value = json[i].settingsBlockChangeRegion;
                document.getElementById("settingsBlockChangeLanguage").value = json[i].settingsBlockChangeLanguage;
                document.getElementById("settingsBlockGamingPage").value = json[i].settingsBlockGamingPage;
                document.getElementById("settingsBlockEaseOfAccessPage").value = json[i].settingsBlockEaseOfAccessPage;
                document.getElementById("settingsBlockPrivacyPage").value = json[i].settingsBlockPrivacyPage;
                document.getElementById("settingsBlockUpdateSecurityPage").value = json[i].settingsBlockUpdateSecurityPage;
                document.getElementById("defenderRequireRealTimeMonitoring").value = json[i].defenderRequireRealTimeMonitoring;
                document.getElementById("defenderRequireBehaviorMonitoring").value = json[i].defenderRequireBehaviorMonitoring;
                document.getElementById("defenderRequireNetworkInspectionSystem").value = json[i].defenderRequireNetworkInspectionSystem;
                document.getElementById("defenderScanDownloads").value = json[i].defenderScanDownloads;
                document.getElementById("defenderScanScriptsLoadedInInternetExplorer").value = json[i].defenderScanScriptsLoadedInInternetExplorer;
                document.getElementById("defenderBlockEndUserAccess").value = json[i].defenderBlockEndUserAccess;
                if (json[i].defenderSignatureUpdateIntervalInHours != "null") { document.getElementById("defenderSignatureUpdateIntervalInHours").value = json[i].defenderSignatureUpdateIntervalInHours; }
                document.getElementById("defenderMonitorFileActivity").value = json[i].defenderMonitorFileActivity;
                if (json[i].defenderDaysBeforeDeletingQuarantinedMalware != "null") { document.getElementById("defenderDaysBeforeDeletingQuarantinedMalware").value = json[i].defenderDaysBeforeDeletingQuarantinedMalware; }
                if (json[i].defenderScanMaxCpu != "null") { document.getElementById("defenderScanMaxCpu").value = json[i].defenderScanMaxCpu; }
                document.getElementById("defenderScanArchiveFiles").value = json[i].defenderScanArchiveFiles;
                document.getElementById("defenderScanIncomingMail").value = json[i].defenderScanIncomingMail;
                document.getElementById("defenderScanRemovableDrivesDuringFullScan").value = json[i].defenderScanRemovableDrivesDuringFullScan;
                document.getElementById("defenderScanMappedNetworkDrivesDuringFullScan").value = json[i].defenderScanMappedNetworkDrivesDuringFullScan;
                document.getElementById("defenderScanNetworkFiles").value = json[i].defenderScanNetworkFiles;
                document.getElementById("defenderRequireCloudProtection").value = json[i].defenderRequireCloudProtection;
                document.getElementById("defenderPromptForSampleSubmission").value = json[i].defenderPromptForSampleSubmission;
                if (json[i].defenderScheduledQuickScanTime != "null") { document.getElementById("defenderScheduledQuickScanTime").value = json[i].defenderScheduledQuickScanTime; }

                var defenderScanType = document.getElementById('defenderScanType');
                defenderScanType.value = json[i].defenderScanType;
                var event = new Event('change');
                defenderScanType.dispatchEvent(event);

                document.getElementById("defenderSystemScanSchedule").value = json[i].defenderSystemScanSchedule;
                document.getElementById("defenderScheduledScanTime").value = json[i].defenderScheduledScanTime;
                if (json[i].defenderPotentiallyUnwantedAppAction != "null") { document.getElementById("defenderPotentiallyUnwantedAppAction").value = json[i].defenderPotentiallyUnwantedAppAction; }

                var defenderDetectedMalwareActions = document.getElementById('defenderDetectedMalwareActions');
                defenderDetectedMalwareActions.value = json[i].defenderDetectedMalwareActions;
                var event = new Event('change');
                defenderDetectedMalwareActions.dispatchEvent(event);

                document.getElementById("defenderlowseverity").value = json[i].defenderlowseverity;
                document.getElementById("defendermoderateseverity").value = json[i].defendermoderateseverity;
                document.getElementById("defenderhighseverity").value = json[i].defenderhighseverity;
                document.getElementById("defendersevereseverity").value = json[i].defendersevereseverity;

                document.getElementById("startBlockUnpinningAppsFromTaskbar").value = json[i].startBlockUnpinningAppsFromTaskbar;
                document.getElementById("logonBlockFastUserSwitching").value = json[i].logonBlockFastUserSwitching;
                document.getElementById("startMenuHideFrequentlyUsedApps").value = json[i].startMenuHideFrequentlyUsedApps;
                document.getElementById("startMenuHideRecentlyAddedApps").value = json[i].startMenuHideRecentlyAddedApps;
                document.getElementById("startMenuMode").value = json[i].startMenuMode;
                document.getElementById("startMenuHideRecentJumpLists").value = json[i].startMenuHideRecentJumpLists;
                document.getElementById("startMenuAppListVisibility").value = json[i].startMenuAppListVisibility;
                document.getElementById("startMenuHidePowerButton").value = json[i].startMenuHidePowerButton;
                document.getElementById("startMenuHideUserTile").value = json[i].startMenuHideUserTile;
                document.getElementById("startMenuHideLock").value = json[i].startMenuHideLock;
                document.getElementById("startMenuHideSignOut").value = json[i].startMenuHideSignOut;
                document.getElementById("startMenuHideShutDown").value = json[i].startMenuHideShutDown;
                document.getElementById("startMenuHideSleep").value = json[i].startMenuHideSleep;
                document.getElementById("startMenuHideHibernate").value = json[i].startMenuHideHibernate;
                document.getElementById("startMenuHideSwitchAccount").value = json[i].startMenuHideSwitchAccount;
                document.getElementById("startMenuHideRestartOptions").value = json[i].startMenuHideRestartOptions;
                document.getElementById("startMenuPinnedFolderDocuments").value = json[i].startMenuPinnedFolderDocuments;
                document.getElementById("startMenuPinnedFolderDownloads").value = json[i].startMenuPinnedFolderDownloads;
                document.getElementById("startMenuPinnedFolderFileExplorer").value = json[i].startMenuPinnedFolderFileExplorer;
                document.getElementById("startMenuPinnedFolderHomeGroup").value = json[i].startMenuPinnedFolderHomeGroup;
                document.getElementById("startMenuPinnedFolderMusic").value = json[i].startMenuPinnedFolderMusic;
                document.getElementById("startMenuPinnedFolderNetwork").value = json[i].startMenuPinnedFolderNetwork;
                document.getElementById("startMenuPinnedFolderPersonalFolder").value = json[i].startMenuPinnedFolderPersonalFolder;
                document.getElementById("startMenuPinnedFolderPictures").value = json[i].startMenuPinnedFolderPictures;
                document.getElementById("startMenuPinnedFolderSettings").value = json[i].startMenuPinnedFolderSettings;
                document.getElementById("startMenuPinnedFolderVideos").value = json[i].startMenuPinnedFolderVideos;
            }
            if (json[i].platform == "macOS") {
                document.getElementById("description").value = json[i].description;
                document.getElementById("displayName").value = json[i].displayName;
                var password = document.getElementById('macpasswordRequired');
                password.value = json[i].macpasswordRequired;
                var event = new Event('change');
                password.dispatchEvent(event);

                document.getElementById("macpasswordBlockSimple").value = json[i].macpasswordBlockSimple;
                if (json[i].macpasswordMinutesOfInactivityBeforeLock != "null") { document.getElementById("macpasswordMinutesOfInactivityBeforeLock").value = json[i].macpasswordMinutesOfInactivityBeforeLock; }
                if (json[i].macpasswordMinimumLength != "null") { document.getElementById("macpasswordMinimumLength").value = json[i].macpasswordMinimumLength; }
                if (json[i].macpasswordMinimumCharacterSetCount != "null") { document.getElementById("macpasswordMinimumCharacterSetCount").value = json[i].macpasswordMinimumCharacterSetCount; }
                if (json[i].macpasswordExpirationDays != "null") { document.getElementById("macpasswordExpirationDays").value = json[i].macpasswordExpirationDays; }
                document.getElementById("macpasswordRequiredType").value = json[i].macpasswordRequiredType;
                if (json[i].macpasswordPreviousPasswordBlockCount != "null") { document.getElementById("macpasswordPreviousPasswordBlockCount").value = json[i].macpasswordPreviousPasswordBlockCount; }
                if (json[i].macpasswordMinutesOfInactivityBeforeScreenTimeout != "null") { document.getElementById("macpasswordMinutesOfInactivityBeforeScreenTimeout").value = json[i].macpasswordMinutesOfInactivityBeforeScreenTimeout; }
            }
        }
        $('.loading').hide();
    });
}

function AddAzureIntuneComplianceSettingsToList(json, selectElement) {

    var selected = '';
    if (json == '') {
        selectElement.append('<option>It appears there are no deviceconfs in the tenant..</option>');
    }
    else {
        selectElement.append('<option value="' + json.id + '"' + selected + '>' + json.displayName + '</option>');
    }

}

function GetAzureIntuneComplianceSettings(selectElement) {
    if (!selectElement) {
        selectElement = $("select[name=deviceconf]");
    }
    var organization = $("select[name=organization]").val();

    selectElement.html('<option>Contacting Azure... please be patient..</option>');

    $.get("/Azure/GetAzureIntuneComplianceSetting", { organization: organization }, function (data) {
        selectElement.html('');

        var json = JSON.parse(data);
        if (json.Failure) {
            AddError(json);
        }
        else {
            selectElement.html("");
            if (json.length == null) {
                AddAzureIntuneComplianceSettingsToList(json, selectElement);
            }
            else {
                for (i = 0; i < json.length; i++) {
                    AddAzureIntuneComplianceSettingsToList(json[i], selectElement);
                }
            }
        }
        selectElement.change();
    });
}

function GetAzureIntuneComplianceSetting() {
    $('.loading').show();
    var organization = $("select[name=organization]").val();
    var deviceconf = $("select[name=deviceconf]").val();

    $.get("/Azure/GetAzureIntuneComplianceSetting", { organization: organization, id: deviceconf }, function (data) {

        var json = JSON.parse(data);

        for (i = 0; i < json.length; i++) {
            // Create change event
            var platform = document.getElementById('platform');
            platform.value = json[i].platform;
            var event = new Event('change');
            platform.dispatchEvent(event);

            if (json[i].platform == "Android") {
                if (json[i].description != "null") { document.getElementById("description").value = json[i].description; }
                document.getElementById("displayName").value = json[i].displayName;
                document.getElementById("securityBlockJailbrokenDevices").value = json[i].securityBlockJailbrokenDevices;
                document.getElementById("deviceThreatProtectionRequiredSecurityLevel").value = json[i].deviceThreatProtectionRequiredSecurityLevel;
                if (json[i].osMinimumVersion != "null") { document.getElementById("osMinimumVersion").value = json[i].osMinimumVersion; }
                if (json[i].osMaximumVersion != "null") { document.getElementById("osMaximumVersion").value = json[i].osMaximumVersion; }

                var password = document.getElementById('passwordRequired');
                password.value = json[i].passwordRequired;
                var event = new Event('change');
                password.dispatchEvent(event);

                if (json[i].passwordMinimumLength != "null") { document.getElementById("passwordMinimumLength").value = json[i].passwordMinimumLength; }
                document.getElementById("passwordRequiredType").value = json[i].passwordRequiredType;
                if (json[i].passwordMinutesOfInactivityBeforeLock != "null") { document.getElementById("passwordMinutesOfInactivityBeforeLock").value = json[i].passwordMinutesOfInactivityBeforeLock; }
                if (json[i].passwordPreviousPasswordBlockCount != "null") { document.getElementById("passwordPreviousPasswordBlockCount").value = json[i].passwordPreviousPasswordBlockCount; }
                if (json[i].passwordExpirationDays != "null") { document.getElementById("passwordExpirationDays").value = json[i].passwordExpirationDays; }
                document.getElementById("storageRequireEncryption").value = json[i].storageRequireEncryption;
                document.getElementById("securityPreventInstallAppsFromUnknownSources").value = json[i].securityPreventInstallAppsFromUnknownSources;
                document.getElementById("securityDisableUsbDebugging").value = json[i].securityDisableUsbDebugging;
                if (json[i].minAndroidSecurityPatchLevel != "null") { document.getElementById("minAndroidSecurityPatchLevel").value = json[i].minAndroidSecurityPatchLevel; }
            }
            if (json[i].platform == "AFW") {
                if (json[i].description != "null") { document.getElementById("description").value = json[i].description; }
                document.getElementById("displayName").value = json[i].displayName;
                document.getElementById("afwsecurityBlockJailbrokenDevices").value = json[i].afwsecurityBlockJailbrokenDevices;
                document.getElementById("afwdeviceThreatProtectionRequiredSecurityLevel").value = json[i].afwdeviceThreatProtectionRequiredSecurityLevel;
                if (json[i].afwosMinimumVersion != "null") { document.getElementById("afwosMinimumVersion").value = json[i].afwosMinimumVersion; }
                if (json[i].afwosMaximumVersion != "null") { document.getElementById("afwosMaximumVersion").value = json[i].afwosMaximumVersion; }

                var password = document.getElementById('afwpasswordRequired');
                password.value = json[i].afwpasswordRequired;
                var event = new Event('change');
                password.dispatchEvent(event);

                if (json[i].afwpasswordMinimumLength != "null") { document.getElementById("afwpasswordMinimumLength").value = json[i].afwpasswordMinimumLength; }
                document.getElementById("afwpasswordRequiredType").value = json[i].afwpasswordRequiredType;
                if (json[i].afwpasswordMinutesOfInactivityBeforeLock != "null") { document.getElementById("afwpasswordMinutesOfInactivityBeforeLock").value = json[i].afwpasswordMinutesOfInactivityBeforeLock; }
                if (json[i].afwpasswordPreviousPasswordBlockCount != "null") { document.getElementById("afwpasswordPreviousPasswordBlockCount").value = json[i].afwpasswordPreviousPasswordBlockCount; }
                if (json[i].afwpasswordExpirationDays != "null") { document.getElementById("afwpasswordExpirationDays").value = json[i].afwpasswordExpirationDays; }
                document.getElementById("afwstorageRequireEncryption").value = json[i].afwstorageRequireEncryption;
                document.getElementById("afwsecurityPreventInstallAppsFromUnknownSources").value = json[i].afwsecurityPreventInstallAppsFromUnknownSources;
                document.getElementById("afwsecurityDisableUsbDebugging").value = json[i].afwsecurityDisableUsbDebugging;
                if (json[i].afwminAndroidSecurityPatchLevel != "null") { document.getElementById("afwminAndroidSecurityPatchLevel").value = json[i].afwminAndroidSecurityPatchLevel; }
            }
            if (json[i].platform == "IOS") {
                if (json[i].description != "null") { document.getElementById("description").value = json[i].description; }
                document.getElementById("displayName").value = json[i].displayName;
                document.getElementById("managedEmailProfileRequired").value = json[i].managedEmailProfileRequired;
                document.getElementById("iossecurityBlockJailbrokenDevices").value = json[i].iossecurityBlockJailbrokenDevices;
                document.getElementById("iosdeviceThreatProtectionRequiredSecurityLevel").value = json[i].iosdeviceThreatProtectionRequiredSecurityLevel;
                if (json[i].iososMinimumVersion != "null") { document.getElementById("iososMinimumVersion").value = json[i].iososMinimumVersion; }
                if (json[i].iososMaximumVersion != "null") { document.getElementById("iososMaximumVersion").value = json[i].iososMaximumVersion; }

                var passcode = document.getElementById('passcodeRequired');
                passcode.value = json[i].passcodeRequired;
                var event = new Event('change');
                passcode.dispatchEvent(event);

                document.getElementById("passcodeBlockSimple").value = json[i].passcodeBlockSimple;
                if (json[i].passcodeMinimumLength != "null") { document.getElementById("passcodeMinimumLength").value = json[i].passcodeMinimumLength; }
                document.getElementById("passcodeRequiredType").value = json[i].passcodeRequiredType;
                if (json[i].passcodeMinimumCharacterSetCount != "null") { document.getElementById("passcodeMinimumCharacterSetCount").value = json[i].passcodeMinimumCharacterSetCount; }
                if (json[i].passcodeMinutesOfInactivityBeforeLock != "null") { document.getElementById("passcodeMinutesOfInactivityBeforeLock").value = json[i].passcodeMinutesOfInactivityBeforeLock; }
                if (json[i].passcodeExpirationDays != "null") { document.getElementById("passcodeExpirationDays").value = json[i].passcodeExpirationDays; }
                if (json[i].passcodePreviousPasscodeBlockCount != "null") { document.getElementById("passcodePreviousPasscodeBlockCount").value = json[i].passcodePreviousPasscodeBlockCount; }
            }
            if (json[i].platform == "Win10") {
                if (json[i].description != "null") { document.getElementById("description").value = json[i].description; }
                document.getElementById("displayName").value = json[i].displayName;
                document.getElementById("bitLockerEnabled").value = json[i].bitLockerEnabled;
                document.getElementById("secureBootEnabled").value = json[i].secureBootEnabled;
                document.getElementById("codeIntegrityEnabled").value = json[i].codeIntegrityEnabled;
                if (json[i].winosMinimumVersion != "null") { document.getElementById("winosMinimumVersion").value = json[i].winosMinimumVersion; }
                if (json[i].winosMaximumVersion != "null") { document.getElementById("winosMaximumVersion").value = json[i].winosMaximumVersion; }
                if (json[i].mobileOsMinimumVersion != "null") { document.getElementById("mobileOsMinimumVersion").value = json[i].mobileOsMinimumVersion; }
                if (json[i].mobileOsMaximumVersion != "null") { document.getElementById("mobileOsMaximumVersion").value = json[i].mobileOsMaximumVersion; }

                var password = document.getElementById('winpasswordRequired');
                password.value = json[i].winpasswordRequired;
                var event = new Event('change');
                password.dispatchEvent(event);

                document.getElementById("passwordBlockSimple").value = json[i].passwordBlockSimple;
                document.getElementById("winpasswordRequiredType").value = json[i].winpasswordRequiredType;
                if (json[i].winpasswordMinimumLength != "null") { document.getElementById("winpasswordMinimumLength").value = json[i].winpasswordMinimumLength; }
                if (json[i].winpasswordMinutesOfInactivityBeforeLock != "null") { document.getElementById("winpasswordMinutesOfInactivityBeforeLock").value = json[i].winpasswordMinutesOfInactivityBeforeLock; }
                if (json[i].winpasswordExpirationDays != "null") { document.getElementById("winpasswordExpirationDays").value = json[i].winpasswordExpirationDays; }
                if (json[i].winpasswordPreviousPasswordBlockCount != "null") { document.getElementById("winpasswordPreviousPasswordBlockCount").value = json[i].winpasswordPreviousPasswordBlockCount; }
                document.getElementById("winpasswordRequiredToUnlockFromIdle").value = json[i].winpasswordRequiredToUnlockFromIdle;
                document.getElementById("winstorageRequireEncryption").value = json[i].winstorageRequireEncryption;
            }
            if (json[i].platform == "macOS") {
                if (json[i].description != "null") { document.getElementById("description").value = json[i].description; }
                document.getElementById("displayName").value = json[i].displayName;
                document.getElementById("systemIntegrityProtectionEnabled").value = json[i].systemIntegrityProtectionEnabled;
                if (json[i].macosMinimumVersion != "null") { document.getElementById("macosMinimumVersion").value = json[i].macosMinimumVersion; }
                if (json[i].macosMaximumVersion != "null") { document.getElementById("macosMaximumVersion").value = json[i].macosMaximumVersion; }

                var password = document.getElementById('macpasswordRequired');
                password.value = json[i].macpasswordRequired;
                var event = new Event('change');
                password.dispatchEvent(event);

                document.getElementById("macpasswordBlockSimple").value = json[i].macpasswordBlockSimple;
                if (json[i].macpasswordMinimumLength != "null") { document.getElementById("macpasswordMinimumLength").value = json[i].macpasswordMinimumLength; }
                document.getElementById("macpasswordRequiredType").value = json[i].macpasswordRequiredType;
                if (json[i].macpasswordMinimumCharacterSetCount != "null") { document.getElementById("macpasswordMinimumCharacterSetCount").value = json[i].macpasswordMinimumCharacterSetCount; }
                if (json[i].macpasswordMinutesOfInactivityBeforeLock != "null") { document.getElementById("macpasswordMinutesOfInactivityBeforeLock").value = json[i].macpasswordMinutesOfInactivityBeforeLock; }
                if (json[i].macpasswordExpirationDays != "null") { document.getElementById("macpasswordExpirationDays").value = json[i].macpasswordExpirationDays; }
                if (json[i].macpasswordPreviousPasswordBlockCount != "null") { document.getElementById("macpasswordPreviousPasswordBlockCount").value = json[i].macpasswordPreviousPasswordBlockCount; }
                document.getElementById("macstorageRequireEncryption").value = json[i].macstorageRequireEncryption;
            }
        }
        $('.loading').hide();
    });
}

function AddCrayonInvoiceProfileToList(json, selectElement) {

    var selected = '';

    selectElement.append('<option value="' + json.Id + '"' + selected + '>' + json.Name + '</option>');
}
function GetCrayonInvoiceProfiles(selectElement) {
    if (!selectElement) {
        selectElement = $("select[name=InvoiceProfile]");
    }

    var organization = $("select[name=organization]").val();
    selectElement.html('<option>loading...</option>');

    $.get("/Crayon/GetCrayonInvoiceProfiles", function (data) {
        selectElement.html('');

        var json = JSON.parse(data);
        if (json.Failure) {
            AddError(json);
        }
        else {
            selectElement.html("");
            if (json.length == null) {
                AddCrayonInvoiceProfileToList(json, selectElement);
            }
            else {
                for (i = 0; i < json.length; i++) {
                    AddCrayonInvoiceProfileToList(json[i], selectElement);
                }

            }
        }
        selectElement.change();
    });
}