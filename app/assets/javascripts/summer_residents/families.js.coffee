SR = window.SummerResidents

edit_link = -> $('div.summer_residents_family div.summer_residents_resident a.edit_resident_link')
type = (id) -> $("div.summer_residents_family div#summer_residents_resident_"+id+" input#resident_type_"+id).val()
update_link = (id) -> $('div.summer_residents_family div.summer_residents_resident a#update_resident_link_'+id)
show_link = (id) -> $('div.summer_residents_family div.summer_residents_resident a#show_resident_link_'+id)
update_form = (id) -> $('div.summer_residents_family div.summer_residents_resident form#update_resident_form_'+id)
delete_link = $('div.summer_residents_family a.delete_family_link')
url = (id) -> "/summer_residents/residents/"+id
edit_or_new_url = (id) -> if id then (url(id) + "/edit") else (url("new"))
fam_id = (elem) -> 'fam_id='+SR.item_id('summer_residents_family', $(elem).parent().parent().attr('id'))+'&'

delete_link.keep_centered()

ajax_show = (id, fam, update) ->
  xhr
  if update
    xhr = $.ajax
      url: url(id),
      type: if id then "PUT" else "POST",
      data: fam+update_form(id).serialize()
  else
    xhr = $.ajax
      url:  edit_or_new_url(id)
      type: "GET",
      data: fam+"type="+type(id)+"&cancel=true"
  xhr.done ->
    xhr.responseText
    edit_link().click -> ajax_edit this
  xhr.fail -> SR.ajax_fail(xhr)
  false

ajax_edit = (elem) ->
  id = SR.item_id('edit_resident_link', elem.id)
  fam = fam_id(elem)
  xhr = $.ajax
    url:  edit_or_new_url(id)
    type: "GET",
    data: fam+"type="+type(id)
  xhr.done ->
    xhr.responseText
    update_link(id).click -> ajax_show(id, fam, true)
    show_link(id).click -> ajax_show(id, fam)
  xhr.fail -> SR.ajax_fail(xhr)
  false

$ ->
  edit_link().click -> ajax_edit this

  delete_link.click ->
    id = SR.item_id('delete_family_link', this.id)
    family = $(this).parent()
    xhr = $.ajax
      url: "/summer_residents/families/" + id,
      type: "DELETE"
    xhr.done -> $(family).replaceWith("")
    xhr.fail -> SR.ajax_fail(xhr)
    false
