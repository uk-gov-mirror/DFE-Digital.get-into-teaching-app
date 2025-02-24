import { Application } from 'stimulus';
import NavigationController from 'navigation_controller.js';

describe('NavigationController', () => {
  const navigationTemplate = `<div class="navbar__mobile" data-controller="navigation">
        <div class="navbar__mobile__buttons">
            <a data-action="click->navigation#navToggle" href="javascript:void(0);" class="icon">
                <div data-navigation-target="hamburger" id='hamburger' class="icon-close"></div>
                <div data-navigation-target="label" id="navbar-label" class="icon-hamburger-label">Close</div>
            </a>
        </div>
        <div data-navigation-target="links" id="navbar-mobile-links" class="navbar__mobile__links">
            <ul>
                <li><a href="/">Home</a></li>
                <li><a href="/steps-to-become-a-teacher">Steps to become a teacher</a></li>
                <li><a href="/funding-your-training">Funding your training</a></li>
                <li><a href="/life-as-a-teacher">Teaching as a career</a></li>
                <li><a href="/life-as-a-teacher/teachers-salaries-and-benefits">Salaries and Benefits</a></li>
                <li><%= link_to "Find an event near you", events_path %></li>
                <li><a href="/">Talk to us</a></li>
            </ul>
        </div>
    </div>`;

  const application = Application.start();
  application.register('navigation', NavigationController);

  beforeEach(() => document.body.innerHTML = navigationTemplate)

  describe('when first loaded', () => {
    it('hides the mobile navigation', () => {
      const themobilenav = document.getElementById('navbar-mobile-links');
      expect(themobilenav.style.display).toBe('none');
    });

    it('sets the icon to a hamburger', () => {
      const theicon = document.getElementById('hamburger');
      expect(theicon.className).toBe('icon-hamburger');
    });

    it("sets the label to read 'Menu'", () => {
      const thelabel = document.getElementById('navbar-label');
      expect(thelabel.innerHTML).toBe('Menu');
    });
  });

  describe('once clicked to open', () => {
    beforeEach(() => document.getElementById('hamburger').click())

    it('shows the mobile navigation', () => {
      const themobilenav = document.getElementById('navbar-mobile-links');
      expect(themobilenav.style.display).toBe('block');
    });

    it('sets the icon to a cross', () => {
      const theicon = document.getElementById('hamburger');
      expect(theicon.className).toBe('icon-close');
    });

    it("sets the label to read 'Close'", () => {
      const thelabel = document.getElementById('navbar-label');
      expect(thelabel.innerHTML).toBe('Close');
    });
  });

  describe('search bar opening', () => {
    describe('when mobile menu already open', () => {
      beforeEach(() => {
        document.getElementById('hamburger').click()
        document.dispatchEvent(new CustomEvent('navigation:search'))
      })

      it("hides the mobile navigation", () => {
        const themobilenav = document.getElementById('navbar-mobile-links');
        expect(themobilenav.style.display).toBe('none');
      })
    })

    describe('when mobile menu closed', () => {
      beforeEach(() => {
        document.dispatchEvent(new CustomEvent('navigation:search'))
      })

      it("leaves the mobile navigation closed", () => {
        const themobilenav = document.getElementById('navbar-mobile-links');
        expect(themobilenav.style.display).toBe('none');
      })
    })
  })
});
