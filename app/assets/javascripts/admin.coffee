$ ->
  $('.field-group').click (e) ->
    e.preventDefault()
    $(this).siblings('ul.sortable').find('li fieldset, li .sortable-summary').toggle()
    $(this).siblings('.add_fields').toggle()
    
    # Change text in re-order toggle link
    alt = $(this).data('alt')
    text = $(this).text()
    $(this).text alt
    $(this).data 'alt', text

  # Hide field sets marked to remove
  $('.simple_form').on 'click', '.destroy .remove', (e) ->
    e.preventDefault()
    $(this).closest('.destroy').siblings('div').hide()
    $(this).hide().siblings('.undo').show()
    $(this).siblings('input').prop 'checked', true
  $('.simple_form').on 'click', '.destroy .undo', (e) ->
    e.preventDefault()
    $(this).closest('.destroy').siblings('div').not('[class$="sort"]').show()
    $(this).hide().siblings('.remove').show()
    $(this).siblings('input').prop 'checked', false

  $('.sortable').sortable
    placeholder: 'ui-state-highlight'
    stop: (e, ui) ->
      moj.reSort $(this)

  # Update the summary
  $('.sortable').on 'change', '.court_contacts_contact_type select', ->
    val = $(this).find(':selected').text()
    $(this).closest('li').find('.sortable-summary .type').text val
  $('.sortable').on 'change', '.court_contacts_name input', ->
    val = $(this).val()
    $(this).closest('li').find('.sortable-summary .name span').text(val).parent()[if val.length then 'show' else 'hide']()
  $('.sortable').on 'change', '.court_contacts_telephone input', ->
    val = $(this).val()
    $(this).closest('li').find('.sortable-summary .tel span').text(val).parent()[if val.length then 'show' else 'hide']()
  
  # Update the opening time summary
  $('.sortable').on 'change', '.court_opening_times_opening_type select', ->
    val = $(this).find(':selected').text()
    $(this).closest('li').find('.sortable-summary .type').text val
  $('.sortable').on 'change', '.court_opening_times_name input', ->
    val = $(this).val()
    $(this).closest('li').find('.sortable-summary .name').text val

  # Update the court facility summary
  $('.sortable').on 'change', '.court_court_facilities_facility select', ->
    val = $(this).find(':selected').text()
    $(this).closest('li').find('.sortable-summary .facility').text val

  # Update the email summary
  $('.sortable').on 'change', '.court_emails_description input', ->
    val = $(this).val()
    $(this).closest('li').find('.sortable-summary .desc').text val
  $('.sortable').on 'change', '.court_emails_address input', ->
    val = $(this).val()
    $(this).closest('li').find('.sortable-summary .add').text val

  # Update the summaries on load
  $('.court_contacts_contact_type, .court_contacts_name, .court_contacts_telephone, .court_opening_times_name, .court_opening_times_opening_type, .court_emails_description, .court_emails_address, .court_court_facilities_facility').find('input, select').change()


window.moj = window.moj or {

  reSort: (list) ->
    items = list.children('li')
    items.each ->
      $(this).find('input[id$="_sort"]').val items.index($(this))

  # Add form partials on the fly (using link_to_add_fields_new)
  initNewFieldBlock: (el) ->
    el.closest('.sortable').sortable 'refreshPositions'
    moj.reSort el

  initNewAddressBlock: (el, newFields) ->
    primary = newFields.siblings('fieldset').filter( ->
      $(this).find('.destroy input[type=checkbox]').prop('checked') is false
    ).first()
    
    if newFields.filter('fieldset')[0] is primary[0]
      console.log 'I am primary'


  # http://stackoverflow.com/questions/359788/how-to-execute-a-javascript-function-when-i-have-its-name-as-a-string/359910#359910
  executeFunctionByName: (functionName, context) -> #, args
    args = Array::slice.call(arguments_).splice(2)
    namespaces = functionName.split(".")
    func = namespaces.pop()
    i = 0

    while i < namespaces.length
      context = context[namespaces[i]]
      i++
    context[func].apply this, args

}