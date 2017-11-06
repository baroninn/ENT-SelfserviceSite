function CPOGetAcceptedDomain() {
    var organization = $("select[name=organization]").val();
    $("#acceptedDomain").html("loading...");

    $.get("/Capto/CPOGetAcceptedDomain?organization=" + organization, function (data) {
        $("#acceptedDomain").html(data);
    });
}


function CPOGetTenantInformation() {
    var organization = $("select[name=organization]").val();
    $("#TenantInformation").html("loading, this could take some time...");

    $.get("/Capto/CPOGetTenantInformation?organization=" + organization, function (data) {
        $("#TenantInformation").html(data);
    });
}


function CPOGetAliases() {
    var organization = $("select[name=organization]").val();
    var userprincipalname = $("select[name=userprincipalname]").val();

    var aliasUl = $("#existingAliases");
    aliasUl.html("loading...");

    $.getJSON("/CPOAjax/CPOGetMailbox", { "organization": organization, "name": userprincipalname }, function (data) {
        aliasUl.html("");

        $.each(data[0].EmailAddresses, function (index, obj) {
            var aliasType = obj.substring(0, 4);
            var emailString = obj.substring(5);

            if (aliasType == "SMTP") {
                emailString = emailString + " (<b>Primary</b>)";
            }

            aliasUl.append("<li>" + emailString + "</li>");
        });
    });
}

function CPOAddMailboxToList(json, recipientType, selectElement) {
    if (recipientType && json.RecipientTypeDetails != recipientType && recipientType.toUpperCase() != "ALL") { return }

    var selected = '';

    selectElement.append('<option value="' + json.UserPrincipalName + '"' + selected + '>' + json.Name + ' [' + json.RecipientTypeDetails + '] - ' + json.UserPrincipalName + '</option>');
}

function CPOGetMailbox(recipientType, selectElement) {
    if (!selectElement) {
        selectElement = $("select[name=userprincipalname]");
    }

    var organization = $("select[name=organization]").val();
    selectElement.html('<option>loading...</option>');

    $.get("/CPOAjax/CPOGetMailbox", { "organization": organization }, function (data) {
        selectElement.html('');

        var json = JSON.parse(data);
        if (json.Failure) {
            AddError(json);
        }
        else {
            selectElement.html("");
            if (json.length == null) {
                CPOAddMailboxToList(json, recipientType, selectElement);
            }
            else {
                for (i = 0; i < json.length; i++) {
                    CPOAddMailboxToList(json[i], recipientType, selectElement);
                }
            }
        }
        selectElement.change();
    });
}


function CPOGetMailforward() {
    $("#existingforwards").html("... loading");

    var organization = $("select[name=organization]").val();
    var userprincipalname = $("select[name=userprincipalname]").val();

    $.getJSON("/CPOAjax/CPOGetMailforward", { organization: organization, userprincipalname: userprincipalname }, function (data) {
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

function CPOAddDomainToList(json, selectElement) {

    var selected = '';

    selectElement.append('<option value="' + json.DomainName + '"' + selected + '>' + json.DomainName + '</option>');
}

// New function for getting accepted domain. This function is tied to the <Select> list function and can be used as a dropdown menu.
function CPOGetAcceptedDomain2(selectElement) {
    if (!selectElement) {
        selectElement = $("select[name=domainname]");
    }

    var organization = $("select[name=organization]").val();
    selectElement.html('<option>loading...</option>');

    $.get("/CPOAjax/CPOGetAcceptedDomain", { "organization": organization }, function (data) {
        selectElement.html('');

        var json = JSON.parse(data);
        if (json.Failure) {
            AddError(json);
        }
        else {
            selectElement.html("");
            if (json.length == null) {
                CPOAddDomainToList(json, selectElement);
            }
            else {
                for (i = 0; i < json.length; i++) {
                    CPOAddDomainToList(json[i], selectElement);
                }
            }
        }
        selectElement.change();
    });
}


function CPOAddSendAsGroupToList(json, selectElement) {

    var selected = '';

    selectElement.append('<option value="' + json.DistinguishedName + '"' + selected + '>' + json.Description + ' -- ' + json.Name + '</option>');
}

// New function for getting sendasgroups. This function is tied to the <Select> list function and can be used as a dropdown menu.
function CPOGetSendAsGroups(selectElement) {
    if (!selectElement) {
        selectElement = $("select[name=distinguishedname]");
    }

    var organization = $("select[name=organization]").val();
    selectElement.html('<option>loading...</option>');

    $.get("/CPOAjax/CPOGetSendAsGroups", { "organization": organization }, function (data) {
        selectElement.html('');

        var json = JSON.parse(data);
        if (json.Failure) {
            AddError(json);
        }
        else {
            selectElement.html("");
            if (json.length == null) {
                CPOAddSendAsGroupToList(json, selectElement);
            }
            else {
                for (i = 0; i < json.length; i++) {
                    CPOAddSendAsGroupToList(json[i], selectElement);
                }
            }
        }
        selectElement.change();
    });
}

function CPOAddCTXGoldenToList(json, selectElement) {

    var selected = '';

    selectElement.append('<option value="' + json.Name + '"' + selected + '>' + json.Name + '</option>');
}

// New function for getting GoldenServer. This function is tied to the <Select> list function and can be used as a dropdown menu.
function CPOGetCTXGoldenServers(mcsenabled, selectElement) {
    if (!selectElement) {
        selectElement = $("select[name=server]");
    }

    //var mcsenabled = true;

    var solution = $("select[name=solution]").val();
    selectElement.html('<option>loading, this could take some time (VMM is a little slow)...</option>');

    $.get("/CPOAjax/CPOGetCTXGoldenServers", { "solution": solution, "mcsenabled": mcsenabled }, function (data) {
        selectElement.html('');

        var json = JSON.parse(data);
        if (json.Failure) {
            AddError(json);
        }
        else {
            selectElement.html("");
            if (json.length == null) {
                CPOAddCTXGoldenToList(json, selectElement);
            }
            else {
                for (i = 0; i < json.length; i++) {
                    CPOAddCTXGoldenToList(json[i], selectElement);
                }
            }
        }
        selectElement.change();
    });
}

function CPOGetCurrentOOF() {
    $("#currentOOF").html("loading...");

    var organization = $("select[name=organization]").val();
    var userprincipalname = $("select[name=userprincipalname]").val();

    $.get("/CPOAjax/CPOGetCurrentOOF", { organization: organization, userprincipalname: userprincipalname }, function (data) {

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
            else {
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