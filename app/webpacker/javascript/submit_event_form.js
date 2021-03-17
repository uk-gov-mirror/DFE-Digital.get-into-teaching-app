import { enhanceSelectElement } from 'accessible-autocomplete';

const selectId = '#submit-event-form-building-field';

enhanceSelectElement({
  selectElement: document.querySelector(selectId),
  placeholder: 'E.g., M1 7JA',
});

// document.querySelector(selectId).addEventListener('change', (event) => {
//   const manualBuildingInput = document.querySelector('#manual-building-input');
//   // if (event.target.value === '') {
//   //   setElementDisplay(manualBuildingInput, 'block');
//   // } else {
//   //   setElementDisplay(manualBuildingInput, 'none');
//   // }
// });

const manualBuildingInput = document.querySelector('#manual-building-input');

const searchBuildingInput = document.querySelector('#search-building-input');

document
  .querySelector('#submit-event-form-building-fieldset-search-field')
  .addEventListener('click', () => {
    setElementDisplay(manualBuildingInput, 'none');
    setElementDisplay(searchBuildingInput, 'block');
  });

document
  .querySelector('#submit-event-form-building-fieldset-manual-field')
  .addEventListener('click', () => {
    setElementDisplay(searchBuildingInput, 'none');
    setElementDisplay(manualBuildingInput, 'block');
  });

function setElementDisplay(element, display) {
  element.style.display = display;
}
