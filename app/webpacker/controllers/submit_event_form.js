import accessibleAutocomplete from 'accessible-autocomplete';

accessibleAutocomplete({
  element: document.querySelector('#my-autocomplete-container'),
  id: 'my-autocomplete', // To match it to the existing <label>.
  source: countries
})
