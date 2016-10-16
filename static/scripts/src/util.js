function createForm(data) {
    var form = new FormData();
    for (var i in data) {
        form.append(i, data[i]);
    }
    return form;
}

exports.createForm = createForm;