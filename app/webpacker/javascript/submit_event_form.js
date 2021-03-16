import { enhanceSelectElement } from 'accessible-autocomplete';

const selectId = '#submit-event-form-building-field';

enhanceSelectElement({
  selectElement: document.querySelector(selectId),
  placeholder: 'E.g., M1 7JA',
});

document.querySelector(selectId).addEventListener('change', (event) => {
  const manualBuildingInput = document.querySelector('#manual-building-input');
  if (event.target.value === '') {
    setElementDisplay(manualBuildingInput, 'block');
  } else {
    setElementDisplay(manualBuildingInput, 'none');
  }
});

function setElementDisplay(element, display) {
  element.style.display = display;
}
