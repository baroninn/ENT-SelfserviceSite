﻿function GetAcceptedDomain() {
    var organization = $("select[name=organization]").val();
    $("#acceptedDomain").html("loading...");

    $.get("/Mail/GetAcceptedDomain?organization=" + organization, function (data) {
        $("#acceptedDomain").html(data);
    });
}

function GetAliases() {
    var organization = $("select[name=organization]").val();
    var userprincipalname = $("select[name=userprincipalname]").val();

    var aliasUl = $("#existingAliases");
    aliasUl.html("loading...");

    $.getJSON("/Ajax/GetMailbox", { "organization": organization, "name": userprincipalname }, function (data) {
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

function AddMailboxToList(json, recipientType, selectElement) {
    if (recipientType && json.RecipientTypeDetails != recipientType && recipientType.toUpperCase() != "ALL") { return }

    var selected = '';

    selectElement.append('<option value="' + json.UserPrincipalName + '"' + selected + '>' + json.Name + ' [' + json.RecipientTypeDetails + ']</option>');
}

function GetMailbox(recipientType, selectElement) {
    if (!selectElement) {
        selectElement = $("select[name=userprincipalname]");
    }

    var organization = $("select[name=organization]").val();
    selectElement.html('<option>loading...</option>');

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
    var messages = ["Partitioning Social Network", "Blurring Reality Lines", "Reticulating 3-Dimensional Splines", "Preparing Captive Simulators", "Capacitating Genetic Modifiers", "Destabilizing Orbital Payloads", "Manipulating Modal Memory", "Testing Underworld Telecommunications", "Caffeinating Programmer Body", "Initializing Secret Societies", "Reticulating Graduated Splines", "Loading Lightsaber Sounds", "Turning On Turn-Ons", "Disgruntling Employees", "Managing Managers Managers", "Preparing Bacon for Homeward Transportation", "Mitigating Time-Stream Discontinuities", "Loading \"First Batch\" Metrics", "Neutralizing Shuriken Oxidization", "Roof = Roof(1/3*pi*r^2*h)", "Atomizing Atomic Particles", "Readying Relaxation Receptors", "Training File Server Behavior", "Calculating Lifetime Aspirations", "Predicating Predestined Paths", "Writing Scrolling Startup String Text", "Making a Little Bit of Magic", "Rasterizing Reputation Algorithms", "Simulating Sparkling Surfaces", "Reverse-Engineering Coffee", "Cooling Down Refrigerators", "Storing Solar Energy", "Ceiling Fan Rotation = dL/dT", "Filling in the Blanks", "Generating Intrigue", "Inserting Chaos Generator", "Concatenating Vertex Nodes", "Extruding Mesh Terrain", "Simulating Program Execution", "Locating Misplaced Calculations", "Recycling Hex Decimals", "Ensuring Transplanar Synergy", "Abstracting Loading Procedures", "Polarizing Image Conduits"];

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