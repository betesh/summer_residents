SR = window.SummerResidents

edit_link = (model)-> $('div.summer_residents_family div.summer_residents_'+model+' a.edit_'+model+'_link')
type = (id) -> 'type='+$("div.summer_residents_family div#summer_residents_resident_"+id+" input#resident_type_"+id).val()
update_link = (id,model) -> $('div.summer_residents_family div.summer_residents_'+model+' a#update_'+model+'_link_'+id)
show_link = (id,model) -> $('div.summer_residents_family div.summer_residents_'+model+' a#show_'+model+'_link_'+id)
update_form = (id,model) -> $('div.summer_residents_family div.summer_residents_'+model+' form#update_'+model+'_form_'+id)
delete_link = -> $('div.summer_residents_family a.delete_family_link')
url = (id,model) -> '/summer_residents/'+model+'s/'+id
edit_or_new_url = (id,model) -> if id then (url(id,model) + "/edit") else (url("new",model))
fam_id = (elem) -> 'fam_id='+SR.item_id('summer_residents_family', $(elem).parent().parent().attr('id'))+'&'

ajax_show = (id, fam, model, update) ->
  xhr
  if update
    xhr = $.ajax
      url: url(id, model),
      type: if id then "PUT" else "POST",
      data: fam+update_form(id,model).serialize()
  else
    xhr = $.ajax
      url:  edit_or_new_url(id, model)
      type: "GET",
      data: fam+"cancel=true" + (if 'resident' == model then '&'+type(id) else '')
  xhr.done ->
    xhr.responseText
    set_edit_link(model)
  xhr.fail -> SR.ajax_fail(xhr)
  false

ajax_edit = (elem, model) ->
  id = SR.item_id('edit_'+model+'_link', elem.id)
  fam = fam_id(elem)
  xhr = $.ajax
    url:  edit_or_new_url(id, model)
    type: "GET"
    data: fam + if 'resident' == model then type(id) else ''
  xhr.done ->
    xhr.responseText
    update_link(id, model).click -> ajax_show(id, fam, model, true)
    show_link(id, model).click -> ajax_show(id, fam, model)
  xhr.fail -> SR.ajax_fail(xhr)
  false

set_edit_link = (model) -> edit_link(model).click -> ajax_edit(this, model)

$ ->
  delete_link().keep_centered()

  set_edit_link(model) for model in ['resident', 'bungalow', 'home']

  delete_link().click ->
    id = SR.item_id('delete_family_link', this.id)
    family = $(this).parent()
    xhr = $.ajax
      url: "/summer_residents/families/" + id,
      type: "DELETE"
    xhr.done -> $(family).replaceWith("")
    xhr.fail -> SR.ajax_fail(xhr)
    false
