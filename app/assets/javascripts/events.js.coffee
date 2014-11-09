# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $("option[data-category]").each () -> AddLabelToOption($(this))
  
  $("#narrowdown_button").click (e) => DoNarrowDown()

  $("#cancel_narrowdown_button1").click (e) => CancelNarrowDown(); return false
  $("#cancel_narrowdown_button2").click (e) => CancelNarrowDown()

  $("#want_people").submit (e) =>
    s1 = $("#select_who option:selected")
    s2 = $("#select_wantable option:selected")
    return false if s1.val() == s2.val()
    af1 = $(s1.parent().get(0)).attr("label") 
    af2 = $(s2.parent().get(0)).attr("label")
    return af1 isnt af2 || confirm("その２人は同じ所属ですが、本当に希望しますか？")
    
  $("#select_clone").append( $('#select_who optgroup').clone() )
  $("#select_clone option:selected").removeAttr("selected")
  
  EqualPanelHeight()

AddLabelToOption = (o) ->
  switch o.data("category")
    when "登壇発表" then o.prepend("☆")
    when "デモ・ポスター発表" then o.prepend("○")
    when  "PCメンバー" then o.prepend("□ ")

ReflectNarrowdownOptions = (select, labels, types) ->
  selected_og_label = $(select.find("option:selected").parent().get(0)).attr("label")
  select.children("optgroup[label!=#{selected_og_label}]").remove()
  ogs = $("#select_clone > optgroup[label!=#{selected_og_label}]")
  ogs.each () -> select.append $(this).clone() if $(this).attr("label") in labels || labels.length == 0
  if types.length > 0
    select.find("option").not(":selected").each () -> $(this).remove() unless $(this).data("category") in types
  select.find("optgroup").each () -> $(this).remove() unless $(this).is(":has(option)")

ToggleOptgroup = (og, show) ->
  og.children().toggle(show)
  og.toggle(show)
  
DoNarrowDown = () ->
  labels = $("#select_affiliations > option:selected").map( () -> $(this).attr("value") ).get()
  types = $("#select_types > option:selected").map( () -> $(this).attr("value") ).get()
  ReflectNarrowdownOptions($("#select_who"), labels, types)
  ReflectNarrowdownOptions($("#select_wantable"), labels, types)
  
CancelNarrowDown = () ->
  $("#select_affiliations").val("")
  $("#select_types").val("")
  DoNarrowDown()
  
EqualPanelHeight = () ->
  heights = ($(".panel").map () -> $(this).height()).get()
  max = Math.max.apply(null, heights)
  $(".panel").height(max)