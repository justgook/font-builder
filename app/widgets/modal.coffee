DialogBox = angular.module("DialogBox", [])

DialogBox.directive "dialogBox", ->
# https://github.com/Fundoo-Solutions/angularjs-modal-service/blob/master/src/createDialog.js
DialogBox.factory "createDialog", ->
  defaults =
    id: null,
    template: null,
    templateUrl: null,
    title: 'Default Title',
    backdrop: true,
    success: {label: 'OK', fn: null},
    cancel: {label: 'Close', fn: null},
    controller: null, #just like route controller declaration
    backdropClass: "modal-backdrop",
    backdropCancel: true,
    footerTemplate: null,
    modalClass: "modal",
    css:
      top: '100px',
      left: '30%',
      margin: '0 auto'

  """
  <div class="md-content">
      <h3>Modal Dialog</h3>
      <div>
        <p>This is a modal window. You can do the following things with it:</p>
        <ul>
          <li><strong>Read:</strong> modal windows will probably tell you something important so don't forget to read what they say.</li>
          <li><strong>Look:</strong> a modal window enjoys a certain kind of attention; just look at it and appreciate its presence.</li>
          <li><strong>Close:</strong> click on the button below to close the modal.</li>
        </ul>
        <button class="md-close">Close me!</button>
      </div>
    </div>
  """