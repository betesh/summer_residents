window.SummerResidents ||= {}

window.SummerResidents.item_id = (type, id) ->
  id.replace(type+"_", "")

window.SummerResidents.ajax_fail = (xhr) ->
  alert xhr.statusText+"\nResponse:\n"+xhr.responseText

window.SummerResidents.submit_form_via_link = (name) ->
  form = $("#" + name + "_form")
  link = $("#" + name + "_link")
  link.click ->
    form.submit()
    false
