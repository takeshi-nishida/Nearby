# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
#  $("#select_user").jQselectable() if $("#select_user").length
#  $("#select_who").jQselectable() if $("#select_who").length
#  $("#select_wantable").jQselectable() if $("#select_wantable").length
#  $("#wishlist").hide() if $("#wishlist")
#  $("#want_who_id > option[value=127]").hide()
  $("option[data-participation_type]").each () ->　AddLabelToOption($(this))
  
  $("#narrowdown_button").click (e) =>
    labels = $("#select_affiliations > option:selected").map( () -> $(this).attr("value") ).get()
    types = $("#select_types > option:selected").map( () -> $(this).attr("value") ).get()
    ReflectNarrowdownOptions($("#select_who"), labels, types)
    ReflectNarrowdownOptions($("#select_wantable"), labels, types)

  $("#showall_button").click (e) =>
    $("#select_who :hidden").show()
    $("#select_wantable :hidden").show()
    $("#select_affiliations").val("")
    $("#select_types").val("")

AddLabelToOption = (o) ->
  switch o.data("participation_type")
    when "発表者" then o.prepend("☆")
    when "デモ・ポスター発表" then o.prepend("○")
    when  "PCメンバー" then o.prepend("[委員] ")

ReflectNarrowdownOptions = (select, labels, types) ->
  select.children("optgroup").each () -> ToggleOptgroup($(this), labels.length == 0 || $(this).attr("label") in labels)
  if types.length > 0
    select.find("option").each () -> $(this).hide() unless types.length == 0 || $(this).data("participation_type") in types


ToggleOptgroup = (og, show) ->
  og.children().toggle(show)
  og.toggle(show)